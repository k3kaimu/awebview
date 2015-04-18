/**
from:
https://github.com/jnorwood/file_parallel/blob/master/unzip_parallel.d
*/

module unzip_parallel;
import std.file;
import std.path;
import std.parallelism;
import std.algorithm;
import std.stdio;
import std.stream;
import std.datetime;
import std.zlib;

// unzip a zip file  in parallel.
// Creates the destination directory if it doesn't exist.
// Overwrites if any destination files exist, other than the root destDir
// This is derived from std.zip operations, which is has 32 bit limitations,
// i.e. 4GB archive entries.  The original std.zip operations have been split up
// to enable parallel operation when doing the deflate, as well as to attempt to reduce the 
// peak memory use while processing a large zip file.  It does not break
// individual zip archive entries up so there is the possibility of running out of
// memory if you have a large individual entry in the zip file. 

class UzdException : Exception
{
    this(string msg)
    {
        super("UzdException: " ~ msg);
    }
}

void unzipParallel (string pathname , string destDir){
    DirEntry deSrc = DirEntry(pathname);
    string [] files;

    if (!exists(destDir)){
        mkdirRecurse (destDir); // makes dest root and all required parents
    }
    DirEntry destDe = DirEntry(destDir);
    if(!destDe.isDir()){        
        throw new FileException( destDe.name, " is not a directory"); 
    }
    string destName = destDe.name ~ '/';

    // this is needed when doing the modification time corrections
    immutable TimeZone tz = LocalTime();

    if(!deSrc.isDir()){
        auto f = new std.stream.File(deSrc.name, FileMode.In);
        ZipArchive2 za; 
        ArchiveMember2[] directoryFull = getArchiveDirectory(za,f);
        ArchiveMember2[] directory = directoryFull;

        // for the folder entries (ending in /), just create the folder
        // if it doesn't already exist
        // This is not done in parallel, but is a very short time relative to the
        // file creations for regular files... on the order of 2% of the total task
        // A small improvement might be to do these depth first, since the recursive
        // action would then create multiple directory entries in parallel.

        // Note that we aren't updatign the folder times until later, after all the files have
        // been added
        foreach (ref ArchiveMember2 am;  directory)
        {
            if (am.name[$-1]=='/'){
                string destFolder = destName ~ am.name;
                if (!exists(destFolder)){
                    mkdirRecurse (destFolder); // makes dest root and all required parents
                }
            }
        }

        // ok, this is just some chunk size so we don't try to process all the files at once
        enum CHUNK_SZ =  40_000_000;

        while (directory.length!=0){
            ulong len = 0;

            // this will be a slice of the directory that will be inflated in parallel
            ArchiveMember2[] subd;

            // read the compressed data for some number of entries into the am structure.
            // Limit the number of entries processed by the cumulative compressed length.
            // The read of compressed data from the file is not done in parallel.
            foreach (int j, ref ArchiveMember2 am;  directory)
            {
                // The zip folder name entries all end with '/'.  Exclude them 
                if (am.name[$-1]!='/'){
                    // we are reading these per entry.  That is a lot of small seeks.
                    // It might be faster to sum up the sizes and read the chunk at once,
                    // but we would also need to pre-sort the directory entries by offset.
                    readCompressedData(za.endrecOffset,am,f); 
                    len += am.compressedSize;
                    if (len > CHUNK_SZ){
                        subd = directory[0..j+1];
                        directory = directory[j+1..$];
                        break;
                    }
                }
            }

            // This handles the last block of the directory
            if (len <= CHUNK_SZ){
                subd = directory;
                directory = directory[$..$]; 
            }

            // parallel foreach for inflation of the regular files
            foreach(ref ArchiveMember2 am;  taskPool.parallel(subd,1)) {
                // again, this excludes folder name entries, which end in '/'
                if (am.name[$-1]!='/'){
                    // this call does the inflation of the compressed data
                    expand2(am);

                    // now create the destination filename and write it out
                    // looks like the std.file.write is limited to 4GB
                    // Could we handle larger files if expansion done in fragments?
                    string destFilename = destName ~ am.name;
                    std.file.write(destFilename,am.expandedData);

                    // update the file's modification time based on the zip data
                    SysTime st = DosFileTimeToSysTime(am.time, tz);
                    //std.file.setTimes(destFilename, st, st); 
                    setTimes(destFilename, st, st); 

                    // garbage collector didn't do this for some reason?
                    // Probably something with the c call for the inflate in expand2
                    delete(am.expandedData);
                    am.expandedData = null;
                }
            }
        }
        // parallel foreach to set timestamp on folders
        // This requires a fix to the issue at this link ... errors when setting ts on folders
        // http://d.puremagic.com/issues/show_bug.cgi?id=7819
        // There is a working fix provided in that issue
        foreach(ref ArchiveMember2 am;  taskPool.parallel(directoryFull,100)) {
            if (am.name[$-1]=='/'){
                string folderName = destName ~ am.name[0..$-1]; // trim the trailing /
                SysTime st = DosFileTimeToSysTime(am.time, tz);
                // This setTimes call currently throws an error when trying to set times on folders
                // but a fix in setTimes allows it.  Uncomment the line below
                // to enable restore of timestamps on folders when that is fixed
                // setTimes(folderName, st, st); 
            }
        }
    }
    else    { 
        throw new FileException( deSrc.name, " needs to be a regular zip archive, not a folder");
    }
}

/* ============ Reading the zip archive directory from near file end =================== */

/**
*
* Fills in the property  endrecOffset in za reference.
* For each ArchiveMember2 structure in the directory, fills in
* properties   offset, compressionMethod, time,
* crc32, compressedSize, expandedSize,   name[], 
* Use readCompressedData() later to fill in the compressedData
* Use expand2() later to uncompress the data for each ArchiveMember2.
*
* Params:
*  za = reference to the ZipArchive2 struncture.  za.endrecOffset will be set
*/

// a zip number related to the search for the directory at end of zip file
enum ZIP_MAGIC_66000 = 66000;

ArchiveMember2[] getArchiveDirectory (ref ZipArchive2 za,  std.stream.File f)
{   ptrdiff_t iend;
    ptrdiff_t i;
    ptrdiff_t endcommentlength;
    size_t directorySize;
    size_t directoryOffset;

    ulong flen = f.size();

    // just read the directory at the end of the file
    long fst;
    uint fsz;
    if (flen > ZIP_MAGIC_66000){
        fst =  flen - ZIP_MAGIC_66000;
        fsz = ZIP_MAGIC_66000;
        f.seek (fst,SeekPos.Set);
    }
    else{
        fst = 0;
        fsz = flen & 0x1ffff;
    }

    auto data = new ubyte[fsz];

    // some utility functions that reference the local auto data just created
    ushort getUshort(size_t i)
    {
        version (LittleEndian)
        {
            return *cast(ushort *)&data[i];
        }
        else
        {
            ubyte b0 = data[i];
            ubyte b1 = data[i + 1];
            return (b1 << 8) | b0;
        }
    }

    uint getUint(size_t i)
    {
        version (LittleEndian)
        {
            return *cast(uint *)&data[i];
        }
        else
        {
            return bswap(*cast(uint *)&data[i]);
        }
    }

    if (data.length > 0)
    f.read(data);

    //this.data = cast(ubyte[]) buffer;

    // Find 'end record index' by searching backwards for signature
    iend =  data.length - ZIP_MAGIC_66000;
    if (iend < 0)
        iend = 0;
    for (i = data.length - 22; 1; i--)
    {
        if (i < iend)
            throw new UzdException("no end record");

        if (data[i .. i + 4] == cast(ubyte[])"PK\x05\x06")
        {
            endcommentlength = getUshort(i + 20);
            if (i + 22 + endcommentlength > data.length)
                continue;
            //za.comment = cast(string)(data[i + 22 .. i + 22 + endcommentlength]);
            za.endrecOffset = fst+i;
            break;
        }
    }


    // Read end record data
    // not needed za.diskNumber = getUshort(i + 4);
    // not needed za.diskStartDir = getUshort(i + 6);

    // changed these to local vars since the returned directory array has its own size
    uint numEntries = getUshort(i + 8);
    uint totalEntries = getUshort(i + 10);

    if (numEntries != totalEntries)
        throw new UzdException("multiple disk zips not supported");

    directorySize = getUint(i + 12);
    directoryOffset = getUint(i + 16);

    if (directoryOffset + directorySize > flen)
        throw new UzdException("corrupted directory");

    f.seek (directoryOffset,SeekPos.Set);
    data = new ubyte[directorySize];
    if (data.length >0)
        f.read(data);
    i=0;

    ArchiveMember2[] directory = new ArchiveMember2[numEntries];

    foreach (ref de; directory)
    {
        /* The format of an entry is:
        *  'PK' 1, 2
        *  directory info
        *  path
        *  extra data
        *  comment
        */

        uint offset;
        uint namelen;
        uint extralen;
        uint commentlen;

        if (data[i .. i + 4] != cast(ubyte[])"PK\x01\x02")
            throw new UzdException("invalid directory entry 1");
        //de.madeVersion = getUshort(i + 4);
        //de.extractVersion = getUshort(i + 6);
        de.flags = getUshort(i + 8);
        de.compressionMethod = getUshort(i + 10);
        //DosFileTimeToSysTime may be needed to put in form that can be use to restore file time
        de.time = cast(DosFileTime)getUint(i + 12);
        de.crc32 = getUint(i + 16);
        de.compressedSize = getUint(i + 20);
        de.expandedSize = getUint(i + 24);
        namelen = getUshort(i + 28);
        extralen = getUshort(i + 30);
        commentlen = getUshort(i + 32);
        //de.diskNumber = getUshort(i + 34);
        //de.internalAttributes = getUshort(i + 36);
        //de.externalAttributes = getUint(i + 38);
        de.offset = getUint(i + 42);
        i += 46;

        if (i + namelen + extralen + commentlen > directoryOffset + directorySize)
            throw new UzdException("invalid directory entry 2");

        de.name = cast(string)(data[i .. i + namelen]);
        i += namelen;
        //de.extra = data[i .. i + extralen];
        i += extralen;
        //de.comment = cast(string)(data[i .. i + commentlen]);
        i += commentlen;
    }
    if (i !=  directorySize)
        throw new UzdException("invalid directory entry 3");
    return directory;
}

/*****
* get the compressed data into de.compressedData
*
* Could also compare the other properties from the directory,
* but those are commented out for now . 
*/
void readCompressedData(ulong endrecOffset, ref ArchiveMember2 de, std.stream.File f)
{   
    uint namelen;
    uint extralen;
    f.seek(de.offset,SeekPos.Set);
    auto data = new ubyte[30];
    if (data.length >0)
    f.read(data);

    /* ============ Utility operations that work on the local data array =================== */

    ushort getUshort(size_t i)
    {
        version (LittleEndian)
        {
            return *cast(ushort *)&data[i];
        }
        else
        {
            ubyte b0 = data[i];
            ubyte b1 = data[i + 1];
            return (b1 << 8) | b0;
        }
    }

    /++
    uint getUint(int i)
    {
        version (LittleEndian)
        {
            return *cast(uint *)&data[i];
        }
        else
        {
            return bswap(*cast(uint *)&data[i]);
        }
    }
    ++/

    if (data[0 .. 4] != cast(ubyte[])"PK\x03\x04")
        throw new UzdException("invalid directory entry 4");

    // These values should match what is in the main zip archive directory
    // but we aren't checking this for now

    //de.extractVersion = getUshort(4);
    //de.flags = getUshort(6);
    //de.compressionMethod = getUshort(8);
    //de.time = cast(DosFileTime)getUint(10);
    //de.crc32 = getUint(14);
    //de.compressedSize = getUint(18);
    //de.expandedSize = getUint(22);

    namelen = getUshort(26);
    extralen = getUshort(28);

    /++
    debug(print)
    {
        printf("\t\texpandedSize = %d\n", de.expandedSize);
        printf("\t\tcompressedSize = %d\n", de.compressedSize);
        printf("\t\tnamelen = %d\n", namelen);
        printf("\t\textralen = %d\n", extralen);
    }
    ++/

    if (de.flags & 1)
        throw new UzdException("encryption not supported");

    long i;
    i = de.offset + 30 + namelen + extralen;
    if (i + de.compressedSize > endrecOffset)
        throw new UzdException("invalid directory entry 5");

    f.seek(i,SeekPos.Set);
    data = new ubyte[de.compressedSize];
    // rawRead will throw an error if the data length is 0
    if (data.length >0){
        f.read(data);
    }

    de.compressedData = data[0 .. de.compressedSize];
    //debug(print) arrayPrint(de.compressedData);
    return; 
}

/*****
* Decompress the contents of archive member de and return the expanded
* data in de.expandedData.
* This was originally a portion  of std.zip's expand
* Delete the compressedData as we have no further use for it once we have the 
* uncompressed version required to write the file.  
*/
void expand2(ref ArchiveMember2 de)
{   

    switch (de.compressionMethod)
    {
        case 0:
            de.expandedData = de.compressedData;
            return;

        case 8:
            // -15 is a magic value used to decompress zip files.
            // It has the effect of not requiring the 2 byte header
            // and 4 byte trailer.
            de.expandedData = cast(ubyte[])std.zlib.uncompress(cast(void[])de.compressedData, de.expandedSize, -15);
            delete(de.compressedData);
            de.compressedData = null;
            return;

        default:
            throw new UzdException("unsupported compression method");
    }
}

/**
* A member of the ZipArchive directory, originally from a class in std.zip
* Commenting out the members we aren't using for this unzip task.
*/
struct ArchiveMember2
{
    //ushort madeVersion = 20;       /// Read Only
    //ushort extractVersion = 20;    /// Read Only
    ushort flags;                  /// Read/Write: normally set to 0
    ushort compressionMethod;      /// Read/Write: 0 for compression, 8 for deflate
    std.datetime.DosFileTime time; /// Read/Write: Last modified time of the member. It's in the DOS date/time format.
    uint crc32;                    /// Read Only: cyclic redundancy check (CRC) value
    uint compressedSize;           /// Read Only: size of data of member in compressed form.
    uint expandedSize;             /// Read Only: size of data of member in expanded form.
    //ushort diskNumber;             /// Read Only: should be 0.
    //ushort internalAttributes;     /// Read/Write
    //uint externalAttributes;       /// Read/Write

    uint offset;

    /**
    * Read/Write: Usually the file name of the archive member; it is used to
    * index the archive directory for the member. Each member must have a unique
    * name[]. Do not change without removing member from the directory first.
    */
    string name;

    //ubyte[] extra;              /// Read/Write: extra data for this member.
    //string comment;             /// Read/Write: comment associated with this member.
    ubyte[] compressedData;     /// Read Only: data of member in compressed form.
    ubyte[] expandedData;       /// Read/Write: data of member in uncompressed form.

    /++
    debug(print)
    {
        void print()
        {
            printf("name = '%.*s'\n", name.length, name.ptr);
            printf("\tcomment = '%.*s'\n", comment.length, comment.ptr);
            printf("\tmadeVersion = x%04x\n", madeVersion);
            printf("\textractVersion = x%04x\n", extractVersion);
            printf("\tflags = x%04x\n", flags);
            printf("\tcompressionMethod = %d\n", compressionMethod);
            printf("\ttime = %d\n", time);
            printf("\tcrc32 = x%08x\n", crc32);
            printf("\texpandedSize = %d\n", expandedSize);
            printf("\tcompressedSize = %d\n", compressedSize);
            printf("\tinternalAttributes = x%04x\n", internalAttributes);
            printf("\texternalAttributes = x%08x\n", externalAttributes);
        }
    }
    ++/
}

// This struct was originally the ZipArchive class, but has been whittled away
// until all that is left is endrecOffset, which is just used for boundary checks later

struct ZipArchive2
{
    ulong endrecOffset; // hmm... this is all that is left

    // not needed uint diskNumber;    /// Read Only: 0 since multi-disk zip archives are not supported.
    // not needed uint diskStartDir;  /// Read Only: 0 since multi-disk zip archives are not supported.
    //uint numEntries;    /// Read Only: number of ArchiveMembers in the directory.
    //uint totalEntries;  /// Read Only: same as totalEntries.
    //string comment;     /// Read/Write: the archive comment. Must be less than 65536 bytes in length.

    /**
    * Read Only: array indexed by the name of each member of the archive.
    * Example:
    *  All the members of the archive can be accessed with a foreach loop:
    * --------------------
    * ZipArchive2 archive = new ZipArchive2(data);
    * foreach (ArchiveMember am; archive.directory)
    * {
    *     writefln("member name is '%s'", am.name);
    * }
    * --------------------
    */

    /++
    debug (print)
    {
        void print()
        {
            printf("\tdiskNumber = %u\n", diskNumber);
            printf("\tdiskStartDir = %u\n", diskStartDir);
            printf("\tnumEntries = %u\n", numEntries);
            printf("\ttotalEntries = %u\n", totalEntries);
            printf("\tcomment = '%.*s'\n", comment.length, comment.ptr);
        }
    }

    /* ============ Creating a new archive =================== */

    /** Constructor to use when creating a new archive.
    */
    this()
    {
    }
    ++/
}
