module awebview.wrapper.cpp.platform;

version(Windows)
    import core.sys.windows.windows;
else
    import core.sys.posix.sys.types;


enum OSM_VERSION = "1.7.5.0";


mixin template Awesomium()
{
    enum Error
    {
        none,
        badParameters,
        objectGone,
        connectionGone,
        timeout,
        webViewGone,
        generic,
    }

    version(Windows)
        alias NativeWindow = core.sys.windows.windows.HWND;
    else version(OSX)
    {
        struct NSEvent{}
        struct NSView{}
        alias NativeWindow = NSView*;
    }
    else
        alias NativeWindow = void*;


    version(Windows)
        alias ProcessHandle = core.sys.windows.windows.HANDLE;
    else
        alias ProcessHandle = core.sys.posix.sys.types.pid_t;


    align(1) struct Rect
    {
        int x;
        int y;
        int width;
        int height;

        bool isEmpty() const
        {
            return awebview.wrapper.cpp.RectMember.IsEmpty(&this);
        }
    }
}


mixin template Awesomium4D()
{
    extern(C++, RectMember)
    {
        bool IsEmpty(const(Awesomium.Rect)*);
    }
}
