module awebview.gui.activity;

import awebview.wrapper.websession,
       awebview.wrapper.webview,
       awebview.wrapper.webcore,
       awebview.wrapper.webstring,
       awebview.wrapper.weburl,
       awebview.wrapper.weakref,
       awebview.wrapper.cpp : NativeWindow;

import awebview.gui.html,
       awebview.gui.methodhandler,
       deimos.glfw.glfw3;

version(Windows)
{
    import core.sys.windows.windows;
    extern(C) HWND glfwGetWin32Window(GLFWwindow* window);
}
else version(linux)
    extern(C) void* glfwGetX11Window(GLFWwindow* window);


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


    @property
    string id() const pure nothrow @safe @nogc { return _id; }


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


    void load(HTMLPage page)
    {
        if(page.id !in _loadedPages){
            page.onStart(this);
        }

        _loadedPages[page.id] = page;

        if(_nowPage !is null)
            _nowPage.onDetach();

        _nowPage = page;
        _nowPage.onAttach();

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

        _nowPage.postLoad();
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


    @property
    JSValue[string] objects()
    {
        return _objects;
    }


    auto getObject(string name)
    {
        return this._objects[name].get!(WeakRef!JSObject);
    }


    @property
    auto carrierObject()
    {
        return getObject("_carrierObject_");
    }


    void onUpdate()
    {
        _nowPage.onUpdate();
    }


    @property
    string tempDir()
    {
        import std.path : dirName;
        import std.file : thisExePath;

        return dirName(thisExePath);
    }


  private:
    string _id;
    size_t _width;
    size_t _height;
    WebView _view;
    HTMLPage _nowPage;
    MethodHandler _methodHandler;
    JSValue[string] _objects;
    HTMLPage[string] _loadedPages;
}


abstract class WindowActivity : Activity
{
    this(string id, NativeWindow wind, size_t width, size_t height, WebView view)
    {
        view.parentWindow = wind;
        super(id, width, height, view);
    }


    @property
    NativeWindow parentWindow()
    {
        return this.view.parentWindow;
    }


    @property
    NativeWindow window()
    {
        return this.view.window;
    }


    @property
    bool isShouldClosed();
}


class GLFWActivity : WindowActivity
{
    this(string id, size_t width, size_t height, string title, WebSession session = null)
    {
        import std.string : toStringz;
        import std.exception : enforce;

        _glfwWind = enforce(glfwCreateWindow(width, height, toStringz(title), null, null));
        glfwMakeContextCurrent(_glfwWind);
        glfwSetWindowSizeCallback(_glfwWind, &windowResizeCallback);

      version(Windows)
        super(id, glfwGetWin32Window(_glfwWind), width, height, WebCore.instance.createWebView(width, height, session, WebViewType.window));
      else
        static assert(0, "Sorry, does not support your platform now.");

      //version(linux)
        //super(id, glfwGetX11Window(_glfwWind), width, height, WebCore.instance.createWebView(width, height, session, WebViewType.window));

        _winds[_glfwWind] = this;
    }


    ~this()
    {
        _winds.remove(_glfwWind);
        glfwDestroyWindow(_glfwWind);
    }


    @property
    GLFWwindow* glfwWindow()
    {
        return _glfwWind;
    }


    void title(string t)
    {
        import std.string : toStringz;
        glfwSetWindowTitle(_glfwWind, toStringz(t));
    }


    override
    void onUpdate()
    {
        super.onUpdate();
        glfwPollEvents();
        glfwSwapBuffers(_glfwWind);
    }


    override
    @property
    bool isShouldClosed()
    {
        return !!glfwWindowShouldClose(_glfwWind);
    }


  private:
    GLFWwindow* _glfwWind;

    static GLFWActivity[GLFWwindow*] _winds;

    static extern(C) void windowResizeCallback(GLFWwindow* window, int width, int height)
    {
        if(auto p = window in _winds)
            (*p).resize(width, height);
    }
}
