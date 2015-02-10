module awebview.wrapper.cpp.childprocess;

mixin template Awesomium()
{
  version(Windows)
  {
    import core.sys.windows.windows;

    bool IsChildProcess(HINSTANCE);
    int ChildProcessMain(HINSTANCE);
  }
  else
  {
    bool IsChildProcess(int argc, char **argv);
    int ChildProcessMain(int argc, char **argv);
  }
}


mixin template Awesomium4D()
{}
