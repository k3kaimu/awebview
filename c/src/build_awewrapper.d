
import std.process;
import std.stdio;
import std.exception;
import std.file;
import std.path;
import unzip_parallel;

static immutable srcFileName = "awesomium4d_cw.cpp";

version(Win32)
  static immutable objFileName = "awesomium4d_cw.obj";
else
  static immutable objFileName = "awesomium4d_cw.o";

void buildAweWrapperCXX(string filename)
{
  version(Win32)
  {
    auto cxx = execute(["dmc", "-c", filename, "-I."]);
  }
  else version(linux)
  {
    auto cxx = execute(["g++", "-c", "-fno-rtti", filename]);
  }
  else version(OSX)
  {
    auto cxx = execute(["clang", "-c", "-m32", "-fno-rtti", filename, "-I."]);
  }

    writeln(cxx.output);
    assert(cxx.status == 0, "Failed to build");
}


void main()
{
    import std.stdio;

    /* clear directory */
    if(exists("build"))
        rmdirRecurse("build");
    assert(!exists("build"));
    /* mkdir build */
    mkdir("build");
    /* copy srcFile to build */
    copy(srcFileName, buildPath("build", srcFileName));
    version(OSX) copy("osx_wrapper.mm", buildPath("build", "osx_wrapper.mm"));
    /* cd build */
    chdir("build");
    /* unzip Awesomium.zip */
    unzipParallel(buildPath("..", "Awesomium.zip"), ".");
    //enforce(system("unzip ../Awesomium.zip") == 0, "fail unzip");
    /* build */
    buildAweWrapperCXX(srcFileName);
    version(OSX) buildAweWrapperCXX("osx_wrapper.mm");
    /* cd .. */
    chdir("..");
    /* cp awesomium.obj .. */
    copy(buildPath("build", objFileName), objFileName);
    version(OSX) copy(buildPath("build", "osx_wrapper.o"), "osx_wrapper.o");
    /* rm *.visualproj */
    foreach(de; dirEntries(".", "*.{visualdproj,sln}", SpanMode.shallow))
    {
        std.file.remove(de.name);
    }
    /* rm build_awewrapper.d */
    std.file.remove("build_awewrapper.d");
    /* rm unzip_parallel.d */
    std.file.remove("unzip_parallel.d");
}