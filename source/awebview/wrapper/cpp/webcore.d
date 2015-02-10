module awebview.wrapper.cpp.webcore;


mixin template Awesomium()
{
    enum LogSeverity { info, warning, error, errorReport, fatal }
    interface WebCore {}
}


mixin template Awesomium4D()
{
    //interface IWebCoreD
    //{
    //    Awesomium.WebSession createWebSession_cpp(const WebString path, const(WebPreferences)* pref);
    //    Awesomium.WebView createWebView_cpp(int width, int height, Awesomium.WebSession session, Awesomium.WebViewType type);
    //    void setSurfaceFactory_cpp(Awesomium.SurfaceFactory factory);
    //    Awesomium.SurfaceFactory surfaceFactory_cpp();
    //    const(Awesomium.SurfaceFactory) surfaceFactory_cpp() const;
    //    void setResourceInterceptor_cpp(Awesomium.ResourceInterceptor interceptor);
    //    Awesomium.ResourceInterceptor resourceInterceptor_cpp() const;
    //    const(Awesomium.ResourceInterceptor) resourceInterceptor_cpp();
    //    void update_cpp();
    //    void log_cpp(const Awesomium.WebString msg, Awesomium.LogSeverity s, const Awesomium.WebString file, int line);
    //    const(char)* versionString_cpp() const;
    //}


    //interface WebCoreD2Cpp : Awesomium.WebCore {}
    //extern(C++, WebCoreD2CppMember)
    //{
    //    WebCoreD2Cpp newCtor(IWebCoreD p, ulong mid);
    //    void deleteDtor(WebCoreD2Cpp p);
    //}

    extern(C++, WebCoreMember)
    {
        Awesomium.WebCore Initialize(const WebConfig* config);
        void Shutdown();
        Awesomium.WebCore instance();

        Awesomium.WebSession CreateWebSession(Awesomium.WebCore p,
                                      const Awesomium.WebString path,
                                      const WebPreferences* prefs);

        Awesomium.WebView CreateWebView(Awesomium.WebCore p,
                                int width, int height,
                                Awesomium.WebSession session,
                                WebViewType type);

        void set_surface_factory(Awesomium.WebCore p, Awesomium.SurfaceFactory factory);
        Awesomium.SurfaceFactory surface_factory(const Awesomium.WebCore p);
        void set_resource_interceptor(Awesomium.WebCore p, Awesomium.ResourceInterceptor interceptor);
        Awesomium.ResourceInterceptor resource_interceptor(const Awesomium.WebCore p);
        void Update(Awesomium.WebCore p);

        void Log(Awesomium.WebCore p, const Awesomium.WebString message,
                 LogSeverity severity, const Awesomium.WebString file, int line);

        const(char)* version_string(const Awesomium.WebCore p);
        uint used_memory();
        uint allocated_memory();
        void release_memory();
    }
}
