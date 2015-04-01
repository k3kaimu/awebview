module awebview.wrapper.sys;

import derelict.sdl2.sdl;


version(Windows)
{
    import core.sys.windows.com;
    import core.sys.windows.windows;

    extern(Windows) nothrow export @nogc
    {
        HWND GetActiveWindow();
        LONG SetWindowLongW(HWND,int,LONG);
        BOOL MoveWindow(
              HWND hWnd,      // ウィンドウのハンドル
              int X,          // 横方向の位置
              int Y,          // 縦方向の位置
              int nWidth,     // 幅
              int nHeight,    // 高さ
              BOOL bRepaint   // 再描画オプション
            );
    }

    extern (C)
    {
        extern CLSID CLSID_TaskbarList;
    }

    extern(C)
    {
        extern IID IID_ITaskbarList;
    }

    extern(System)
    interface ITaskbarList : IUnknown
    {
        HRESULT HrInit();
        void unusedAddTab();
        HRESULT DeleteTab(HWND hwnd);
        HRESULT unusedActivateTab();
        HRESULT unusedSetActivateAlt();
    }

    void deleteFromTaskbar(HWND hwnd)
    {
        ITaskbarList tbl;
        CoCreateInstance(&CLSID_TaskbarList,
            null,
            CLSCTX_INPROC_SERVER,
            &IID_ITaskbarList,
            cast(void*)&tbl);
        tbl.HrInit();
        tbl.DeleteTab(hwnd);
    }
}


bool isActive(SDL_Window* sdlWindow)
{
    version(Windows)
    {
        SDL_SysWMinfo wmi;
        SDL_VERSION(&(wmi.version_));

        if(SDL_GetWindowWMInfo(sdlWindow, &wmi))
            return GetActiveWindow() == wmi.info.win.window;
        else
            return false;
    }
    else
        static assert(0, "'isActiveWindow' has not been implemented yet.");

    assert(0);
}


void deleteFromTaskbar(SDL_Window* sdlWindow)
{
    version(Windows)
    {
        SDL_SysWMinfo wmi;
        SDL_VERSION(&(wmi.version_));

        if(SDL_GetWindowWMInfo(sdlWindow, &wmi))
            deleteFromTaskbar(wmi.info.win.window);
    }
    else
        static assert(0, "'deleteFromTaskbar' has not been implemented yet.");
}