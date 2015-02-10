module awebview.wrapper.cpp.websession;

mixin template Awesomium()
{
    interface WebSession {}
}


mixin template Awesomium4D()
{
    //interface IWebSessionD
    //{
    //    void release() const;
    //    bool isOnDisk() const;
    //    void getDataPath(WebString) const;
    //    const(WebPreferences)* getPreferences() const;
    //    void addDataSource(const WebString, DataSource);
    //    void setCookie(const WebURL, const WebString, bool, bool);
    //    void clearCookie();
    //    void clearCache();
    //    int getZoomForURL(const WebURL);
    //}


    //interface WebSessionD2Cpp : WebSession {}

    //extern(C++, WebSessionD2CppMember)
    //{
    //    WebSessionD2Cpp newCtor(IWebSessionD p, ulong mid);
    //    void deleteDtor(WebSessionD2Cpp p);
    //}

    extern(C++, WebSessionMember)
    {
        void Release(const Awesomium.WebSession p);
        bool IsOnDisk(const Awesomium.WebSession p);
        void data_path(const Awesomium.WebSession p, Awesomium.WebString dst);
        const(WebPreferences*) preferences(const Awesomium.WebSession p);
        void AddDataSource(Awesomium.WebSession p, const Awesomium.WebString asset_host, DataSource * source);

        void SetCookie(Awesomium.WebSession p, const WebURL url,
                       const Awesomium.WebString cookie_string,
                       bool is_http_only,
                       bool force_session_cookie);

        void ClearCookies(Awesomium.WebSession p);
        void ClearCache(Awesomium.WebSession p);
        int GetZoomForURL(Awesomium.WebSession p, const WebURL url);
    }
}
