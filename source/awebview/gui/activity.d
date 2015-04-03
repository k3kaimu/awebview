module awebview.gui.activity;

import carbon.utils;

import awebview.wrapper.websession,
       awebview.wrapper.webview,
       awebview.wrapper.webcore,
       awebview.wrapper.webstring,
       awebview.wrapper.weburl,
       awebview.wrapper.weakref,
       awebview.wrapper.sys,
       awebview.wrapper.cpp : NativeWindow;

import awebview.gui.html,
       awebview.gui.application,
       awebview.gui.methodhandler,
       derelict.sdl2.sdl;

import awebview.gui.menulistener;

import std.exception,
       std.string;

//version = AwebviewSaveHTML;

class Activity
{
    this(string id, uint width, uint height, WebView view)
    {
        _id = id;
        _width = width;
        _height = height;
        _view = view;
        _view.loadURL(WebURL(`data:text/html,<h1></h1>`));
        WebCore.instance.update();
        createObject("_carrierObject_");
        _methodHandler = new MethodHandler();
        _view.jsMethodHandler = _methodHandler;
    }


    void onStart(Application app)
    {
        _app = app;

        auto ml = new SDLMenuListener(_app);
        _view.setMenuListener(ml.cppObj);

        foreach(k, p; _pages.maybeModified)
            p.page.onStart(this);

        if(_nowPage !is null){
            string loadId = _nowPage.id;
            _nowPage = null;        // avoid onDetach()
            this.load(loadId);
        }
    }


    void attach()
    {
        application.attachActivity(this.id);
    }


    void onAttach()
    {
        foreach(k, e; _children.maybeModified)
            if(e.isDetached)
                e.attach();

        _isAttached = true;
    }


    void onUpdate()
    {
        foreach(k, e; _children.maybeModified)
            if(e.isShouldClosed)
                _children.remove(k);

        _nowPage.onUpdate();
    }


    void detach()
    {
        application.detachActivity(this.id);
    }


    void onDetach()
    {
        foreach(k, e; _children.maybeModified)
            if(e.isAttached)
                e.detach();

        _isAttached = false;
    }


    void onDestroy()
    {
        foreach(k, e; _children.maybeModified)
            e.close();

        foreach(k, p; _pages.maybeModified){
            p.page.onDetach();
            p.page.onDestroy();
        }

        _view.destroy();
    }


    final
    void close()
    {
        _isShouldClosed = true;
    }


    final
    @property
    bool isAttached() const pure nothrow @safe @nogc { return _isAttached; }


    final
    @property
    bool isDetached() const pure nothrow @safe @nogc { return !_isAttached; }


    final
    @property
    inout(Application) application() inout pure nothrow @safe @nogc { return _app; }


    final
    @property
    string id() const pure nothrow @safe @nogc { return _id; }


    final
    @property
    inout(WebView) view() inout pure nothrow @safe @nogc
    {
        return _view;
    }


    @property
    inout(MethodHandler) methodHandler() inout pure nothrow @safe @nogc
    {
        return _methodHandler;
    }


    @property
    size_t width() const pure nothrow @safe @nogc
    {
        return _width;
    }


    @property
    void width(uint w)
    {
        _width = w;
        this.resize(_width, _height);
    }


    @property
    size_t height() const pure nothrow @safe @nogc
    {
        return _height;
    }


    @property
    void height(uint h)
    {
        _height = h;
        this.resize(_width, _height);
    }


    void resize(uint w, uint h)
    {
        this._view.resize(w, h);
    }


    void addPage(HTMLPage page)
    {
        _pages[page.id] = PageType(page, false);

        if(_app !is null && _app.isRunning)
            page.onStart(this);
    }


    void opOpAssign(string op : "~")(HTMLPage page)
    {
        addPage(page);
    }


    final
    HTMLPage opIndex(string id)
    {
        return _pages[id].page;
    }


    final
    auto opIndex(Dollar.QuerySelector dollar)
    {
        return .querySelector(this, dollar.selector);
    }


    final
    Dollar opDollar() pure nothrow @safe @nogc { return Dollar.init; }


    static struct Dollar
    {
        static struct QuerySelector
        {
            string selector;
        }


        QuerySelector QS(string str) pure nothrow @safe @nogc
        {
            return QuerySelector(str);
        }


        alias opCall = QS;
    }


    void load(string id)
    {
        import std.stdio;
        immutable bool isStarted = this.application !is null && this.application.isRunning;

        auto p = enforce(id in _pages);

        if(_nowPage !is null && isStarted)
            _nowPage.onDetach();

        _nowPage = p.page;
        if(isStarted)
        {
            bool bInit;
            if(!p.wasLoaded){
                p.wasLoaded = true;
                bInit = true;
            }

            _nowPage.onAttach(bInit);
            _loadImpl(bInit);
        }
    }


    void load(HTMLPage page)
    {
        if(page.id !in _pages || page !is _pages[page.id].page)
            addPage(page);

        this.load(page.id);
    }


    void reload()
    in {
        assert(this.nowPage !is null);
    }
    body {
        _loadImpl(false);
    }


    private void _loadImpl(bool isInit)
    {
        import std.stdio;
        import std.uri : encodeComponent;

        // save html to disk
        import std.path : buildPath;
        import std.file;

        immutable htmlPath = buildPath(application.exeDir, "Activity-" ~ this.id ~ "-HTMLPage-" ~ nowPage.id ~ ".html");

      version(AwebviewSaveHTML)
      {
        try
            std.file.write(htmlPath, _nowPage.html);
        catch(Exception){}
      }

        _view.loadURL(WebURL(htmlPath));
        while(_view.isLoading)
            WebCore.instance.update();

        _nowPage.onLoad(isInit);
    }


    @property
    inout(HTMLPage) nowPage() inout pure nothrow @safe @nogc
    {
        return _nowPage;
    }


    void runJS(string script)
    {
        _view.executeJS(script, "");
    }


    JSValue evalJS(string script)
    {
        return _view.executeJSWithRV(script, "");
    }


    WeakRef!JSObject createObject(string name)
    {
        WebString str = name;
        JSValue v = _view.createGlobalJSObject(str);
        assert(v.isObject);
        _objects[name] = v;
        return _objects[name].get!(WeakRef!JSObject);
    }


    void releaseObject(string name)
    {
        import carbon.templates : Lstr;

        if(auto p = name in _objects){
            runJS(mixin(Lstr!q{%[name%] = null;}));
            _objects[name].opAssign(JSValue.null_);
        }
    }


    final
    @property
    inout(JSValue[string]) objects() inout
    {
        return _objects;
    }


    final
    auto getObject(string name)
    {
        return this._objects[name].get!(WeakRef!JSObject);
    }


    final
    @property
    auto carrierObject()
    {
        return getObject("_carrierObject_");
    }


    @property
    bool isShouldClosed() { return _isShouldClosed; }


    void addChild(Activity act)
    {
        _children[act.id] = act;
    }


    final
    @property
    inout(Activity[string]) children() inout
    {
        return _children;
    }


  private:
    Application _app;
    string _id;
    uint _width;
    uint _height;
    WebView _view;
    HTMLPage _nowPage;
    MethodHandler _methodHandler;
    JSValue[string] _objects;
    bool _isAttached;
    bool _isShouldClosed;

    Activity[string] _children;

    struct PageType { HTMLPage page; bool wasLoaded; }
    PageType[string] _pages;
}


class SDLActivity : Activity
{
    this(string id, size_t width, size_t height, string title, WebSession session = null, uint sdlFlags = SDL_WINDOW_RESIZABLE)
    {
        import std.string : toStringz;
        import std.exception : enforce;

        _sdlWind = enforce(SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, sdlFlags | SDL_WINDOW_HIDDEN));

        auto view = WebCore.instance.createWebView(width, height, session, WebViewType.window);

      version(Windows)
      {
        /* see https://wiki.libsdl.org/SDL_SysWMinfo */
        SDL_SysWMinfo wmi;
        SDL_VERSION(&(wmi.version_));

        if(SDL_GetWindowWMInfo(_sdlWind, &wmi))
            view.parentWindow = wmi.info.win.window;
      }
        super(id, width, height, view);

        _winds[_sdlWind] = this;
    }


    override
    void onAttach()
    {
        super.onAttach();
        SDL_ShowWindow(_sdlWind);
    }


    override
    void onDetach()
    {
        super.onDetach();
        SDL_HideWindow(_sdlWind);
    }


    override
    void onDestroy()
    {
        _winds.remove(_sdlWind);
        SDL_DestroyWindow(_sdlWind);

        super.onDestroy();
    }


    final
    @property
    SDL_Window* sdlWindow()
    {
        return _sdlWind;
    }


    final
    @property
    uint windowID()
    {
        return SDL_GetWindowID(_sdlWind);
    }


    void title(string t)
    {
        import std.string : toStringz;
        SDL_SetWindowTitle(_sdlWind, toStringz(t));
    }


    override
    void onUpdate()
    {
        super.onUpdate();
        SDL_GL_SwapWindow(_sdlWind);
    }


    void onSDLEvent(const SDL_Event* event)
    {
        if(event.type == SDL_WINDOWEVENT
        && event.window.event == SDL_WINDOWEVENT_RESIZED
        && event.window.windowID == this.windowID)
        {
            this.resize(event.window.data1, event.window.data2);
            return;
        }

        if(event.type == SDL_WINDOWEVENT
        && event.window.event == SDL_WINDOWEVENT_CLOSE
        && event.window.windowID == this.windowID)
        {
            this.close();
            return;
        }
    }


  private:
    SDL_Window* _sdlWind;

    static SDLActivity[SDL_Window*] _winds;
}


version(Windows)
{
    import core.sys.windows.com;
    import core.sys.windows.windows;

    extern(Windows) nothrow export @nogc
    {
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


class SDLBorderlessActivity : SDLActivity
{
    this(string id, size_t width, size_t height, string title, WebSession session = null, uint orSDLFlags = SDL_WINDOW_RESIZABLE)
    {
        uint flags = orSDLFlags | SDL_WINDOW_BORDERLESS;
        super(id, width, height, title, session, flags);

      version(Windows)
      {
        enum int GWL_STYLE = -16;
        enum LONG WS_POPUP = 0x80000000;

        /* see https://wiki.libsdl.org/SDL_SysWMinfo */
        SDL_SysWMinfo wmi;
        SDL_VERSION(&(wmi.version_));

        if(SDL_GetWindowWMInfo(_sdlWind, &wmi))
            SetWindowLongW(wmi.info.win.window, GWL_STYLE, WS_POPUP);
      }
    }


    override
    void resize(size_t w, size_t h)
    {
        super.resize(w, h);

        SDL_SetWindowSize(this.sdlWindow, w, h);
    }
}


class SDLPopupActivity : SDLBorderlessActivity
{
    this(size_t idx, WebSession session = null, uint orSDLFlags = SDL_WINDOW_RESIZABLE)
    {
        super(format("_PopupActivity%s_", idx), 0, 0, "", session, orSDLFlags);
        _idx = idx;
        _session = session;
        _flags = orSDLFlags;

      version(Windows)
      {
        /* see https://wiki.libsdl.org/SDL_SysWMinfo */
        SDL_SysWMinfo wmi;
        SDL_VERSION(&(wmi.version_));

        if(SDL_GetWindowWMInfo(_sdlWind, &wmi))
            deleteFromTaskbar(wmi.info.win.window);
      }
    }


    void popup(HTMLPage page, SDLActivity activity, int x, int y)
    {
        _parent = activity;
        SDL_SetWindowPosition(this.sdlWindow, x, y);
        this.attach();
        this.load(page);
        SDL_RaiseWindow(this.sdlWindow);

        _x = x;
        _y = y;
    }


    void popupAtRel(HTMLPage page, SDLActivity activity, int relX, int relY)
    {
        int x,  y;
        SDL_GetWindowPosition(activity.sdlWindow, &x, &y);

        x += relX;
        y += relY;
        popup(page, activity, x, y);
    }


    void popup(HTMLPage page, SDLActivity activity)
    {
      version(Windows)
      {
        import core.sys.windows.windows;
        POINT p;
        GetCursorPos(&p);

        popup(page, activity, p.x, p.y);
      }
      else
      {
        SDL_PumpEvents();
        int dx, dy;
        SDL_GetMouseState(&dx, &dy);

        int x, y;
        SDL_GetWindowPosition(activity.sdlWindow, &x, &y);

        x += dx;
        y += dy;

        popup(page, activity, x, y);
      }
    }


    void popupChild(HTMLPage page, int relX, int relY)
    {
        if(_child is null){
            _child = new SDLPopupActivity(_idx + 1, _session, _flags);
            this.application.addActivity(_child);
        }

        popupChildAtAbs(page, _x + relX, _y + relY);
    }


    void popupChildAtAbs(HTMLPage page, uint x, uint y)
    {
        _child.popup(page, this, x, y);
    }


    void popupChildRight(HTMLPage page, int relY)
    {
        popupChild(page, _w, relY);
    }


    void popupChildButtom(HTMLPage page, int relX)
    {
        popupChild(page, relX, _h);
    }


    override
    void onDetach()
    {
        _x = 0;
        _y = 0;
        _w = 0;
        _h = 0;
        this.resize(0, 0);
        _parent = null;

        super.onDetach();
    }


    override
    void onUpdate()
    {
        super.onUpdate();

        uint sw = evalJS(q{document.documentElement.scrollWidth}).get!uint;
        uint sh = evalJS(q{document.documentElement.scrollHeight}).get!uint;

        if(_w != sw || _h != sh){
            this.resize(sw, sh);
            _w = sw;
            _h = sh;
        }

        if(_parent.isDetached || !this.hasFocus){
            this.detach();
        }
    }


    @property
    bool hasFocus()
    {
        if(_child)
            return isActive(this.sdlWindow) || _child.hasFocus;
        else
            return isActive(this.sdlWindow);
    }


    override
    void onSDLEvent(const SDL_Event* event)
    {
        // ignore resized by user
        if(event.type == SDL_WINDOWEVENT
        && event.window.event == SDL_WINDOWEVENT_RESIZED
        && event.window.windowID == this.windowID)
        {
            this.resize(_w, _h);
            return;
        }

        super.onSDLEvent(event);
    }


  private:
    size_t _idx;
    WebSession _session;
    uint _flags;

    uint _x, _y;
    uint _w, _h;

    SDLActivity _parent;
    SDLPopupActivity _child;
}
