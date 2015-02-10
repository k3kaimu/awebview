module awebview.wrapper.websession;

import awebview.wrapper.cpp;
import awebview.wrapper.webpreferences : WebPreferences;
import awebview.wrapper.webstring : WebString;
import awebview.wrapper.weburl : WebURL;

final class WebSession
{
    this(awebview.wrapper.cpp.WebSession cppObj) pure nothrow @safe @nogc
    {
        _cppObj = cppObj;
    }


    @property
    inout(awebview.wrapper.cpp.WebSession) cppObj() inout pure nothrow @safe @nogc
    { return _cppObj; }


    void release() const nothrow @nogc
    { WebSessionMember.Release(_cppObj); }

    @property
    bool isOnDisk() const nothrow @nogc
    { return WebSessionMember.IsOnDisk(_cppObj); }

    @property
    WebString dataPath() const nothrow @nogc
    {
        WebString dst;
        WebSessionMember.data_path(_cppObj, dst.cppObj);
        return dst;
    }

    @property
    ref const(WebPreferences) preferences() const nothrow @nogc
    {
        auto p = WebSessionMember.preferences(_cppObj);
        return *cast(const(WebPreferences)*)p;
    }

    //void addDataSource()(auto ref const WebString assetHost, IDataSource source);

    //void setCookie()(auto ref const WebURL url,
    //                 auto ref const WebString cookieString,
    //                 bool isHTTPOnly,
    //                 bool forceSessionCookie);

    void clearCookie() nothrow @nogc
    { WebSessionMember.ClearCookies(_cppObj); }

    void clearCache() nothrow @nogc
    { WebSessionMember.ClearCache(_cppObj); }

    int getZoomForURL()(auto ref WebURL url) nothrow @nogc
    { return WebSessionMember.GetZoomForURL(url); }

  private:
    awebview.wrapper.cpp.WebSession _cppObj;
}
