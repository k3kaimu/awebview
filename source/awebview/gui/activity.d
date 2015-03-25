module awebview.gui.activity;

import carbon.utils;

import awebview.wrapper.websession,
       awebview.wrapper.webview,
       awebview.wrapper.webcore,
       awebview.wrapper.webstring,
       awebview.wrapper.weburl,
       awebview.wrapper.weakref,
       awebview.wrapper.cpp : NativeWindow;

import awebview.gui.html,
       awebview.gui.application,
       awebview.gui.methodhandler,
       derelict.sdl2.sdl;

import std.exception;


class Activity
{
    this(string id, size_t width, size_t height, WebView view)
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

        foreach(k, p; _pages.maybeModified)
            p.page.onStart(this);

        if(_nowPage !is null){
            string loadId = _nowPage.id;
            _nowPage = null;        // avoid onDetach()
            this.load(loadId);
        }
    }


    void onAttach()
    {
        _isAttached = true;
    }


    void onUpdate()
    {
        _nowPage.onUpdate();
    }


    void onDetach()
    {
        _isAttached = false;
    }


    void onDestroy()
    {
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
    void width(size_t w) nothrow @nogc
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
    void height(size_t h) nothrow @nogc
    {
        _height = h;
        this.resize(_width, _height);
    }


    void resize(size_t w, size_t h) nothrow @nogc
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


        QuerySelector q(string str) pure nothrow @safe @nogc
        {
            return QuerySelector(str);
        }


        alias opCall = q;
    }


    void load(string id)
    {
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
        // save html to disk
        import std.path : buildPath;
        immutable htmlPath = buildPath(this.tempDir, this.id ~ nowPage.id ~ ".html");
        {
            import std.file : write;
            write(htmlPath, _nowPage.html);
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
    string tempDir() const
    {
        import std.path : dirName;
        import std.file : thisExePath;

        return dirName(thisExePath);
    }


    @property
    bool isShouldClosed() { return _isShouldClosed; }


  private:
    Application _app;
    string _id;
    size_t _width;
    size_t _height;
    WebView _view;
    HTMLPage _nowPage;
    MethodHandler _methodHandler;
    JSValue[string] _objects;
    bool _isAttached;
    bool _isShouldClosed;

    struct PageType { HTMLPage page; bool wasLoaded; }
    PageType[string] _pages;
}


class SDLActivity : Activity
{
    this(string id, size_t width, size_t height, string title, WebSession session = null)
    {
        import std.string : toStringz;
        import std.exception : enforce;

        _sdlWind = enforce(SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_RESIZABLE | SDL_WINDOW_HIDDEN));

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
