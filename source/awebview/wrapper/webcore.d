module awebview.wrapper.webcore;

import awebview.wrapper.cpp;
import awebview.wrapper.cpp.mmanager;
import awebview.wrapper.webconfig : WebConfig;
import awebview.wrapper.websession : WebSession;
import awebview.wrapper.webstring : WebString;
//import awebview.wrapper.websession : WebSession;
import awebview.wrapper.webview : WebView;
import awebview.wrapper.webpreferences : WebPreferences;
//import awebview.wrapper.surface;
import awebview.wrapper.resourceinterceptor : ResourceInterceptor;
import awebview.wrapper.cpp : WebViewType;


struct WebCore
{
    static
    WebCore initialize(const ref WebConfig config) nothrow
    {
        _instance = WebCore(config);
        return _instance;
    }


    static initialize() nothrow
    {
        auto wc = WebConfig();
        _instance = WebCore(wc);
        return _instance;
    }


    static
    void shutdown() nothrow @nogc
    {
        WebCoreMember.Shutdown();
    }


    static
    WebCore instance() nothrow @safe @nogc @property
    {
        return _instance;
    }


    @property
    inout(awebview.wrapper.cpp.WebCore) cppObj() inout pure nothrow @safe @nogc { return _cppObj; }


    WebSession createWebSession(in WebString str, in WebPreferences prefs)
    {
        awebview.wrapper.cpp.WebSession co = WebCoreMember.CreateWebSession(this.cppObj, str.cppObj, prefs.cppObj);
        return new WebSession(co);
    }


    WebView createWebView(int w, int h, WebSession session, WebViewType type)
    {
        awebview.wrapper.cpp.WebSession cppSession;
        if(session !is null)
            cppSession = session.cppObj;

        awebview.wrapper.cpp.WebView co = WebCoreMember.CreateWebView(this.cppObj, w, h, cppSession, type);
        return WebView(co);
    }


    //@property
    //void surfaceFactory(ISurfaceFactory factory)
    //{
    //    WebCoreMember.set_surface_factory(this.cppObj, factory.cppObj);
    //}


    //@property
    //ISurfaceFactory surfaceFactory()
    //{
    //    return new SurfaceFactoryCpp2D(WebCoreMember.surface_factory(this.cppObj));
    //}


    @property
    void resourceInterceptor(ResourceInterceptor ri)
    {
        WebCoreMember.set_resource_interceptor(this.cppObj, ri.cppObj);
    }


    //@property
    //IResourceInterceptor resourceInterceptor()
    //{
    //    return new ResourceInterceptorCpp2D(WebCoreMember.resource_interceptor(this.cppObj));
    //}


    void update() nothrow @nogc
    {
        WebCoreMember.Update(this.cppObj);
    }


    static @property
    uint usedMemory() nothrow @nogc
    {
        return WebCoreMember.used_memory();
    }


    static @property
    uint allocatedMemory() nothrow @nogc
    {
        return WebCoreMember.allocated_memory();
    }


    static
    void releaseMemory() nothrow @nogc
    {
        WebCoreMember.release_memory();
    }


  private:
    awebview.wrapper.cpp.WebCore _cppObj;

    static WebCore _instance;

    this(const ref WebConfig config) nothrow @nogc
    {
        this(WebCoreMember.Initialize(config.cppObj));
    }


    this(awebview.wrapper.cpp.WebCore cppObj) pure nothrow @nogc
    {
        _cppObj = cppObj;
    }
}
