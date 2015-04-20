
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

void buildAweWrapperCXX()
{
  version(Win32)
  {
    auto cxx = execute(["dmc", "-c", srcFileName, "-I."]);
  }
  else version(linux)
  {
    auto cxx = execute(["g++", "-c", "-fno-rtti", srcFileName]);
  }
  else version(OSX)
  {
    auto cxx = execute(["clang", "-c", "-fno-rtti", srcFileName, "-I."]);
  }

    writeln(cxx.output);
    assert(cxx.status == 0, "Failed to build");
}


void main()
{
    /* clear directory */
    if(exists("build"))
        rmdirRecurse("build");

    assert(!exists("build"));

    /* mkdir build */
    mkdir("build");

    /* copy srcFile to build */
    copy(srcFileName, buildPath("build", srcFileName));

    /* cd build */
    chdir("build");

    /* unzip Awesomium.zip */
    unzipParallel(buildPath("..", "Awesomium.zip"), ".");
    //enforce(system("unzip ../Awesomium.zip") == 0, "fail unzip");

    /* build */
    buildAweWrapperCXX();

    /* cd .. */
    chdir("..");

    /* cp awesomium.obj .. */
    copy(buildPath("build", objFileName), objFileName);

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