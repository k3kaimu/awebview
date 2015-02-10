module awebview.wrapper.webpreferences;


import awebview.wrapper.cpp;
import awebview.wrapper.webstring : WebStringCpp;

import carbon.memory;

struct WebPreferences
{
    static WebPreferences opCall() nothrow @nogc
    {
        WebPreferences wp;
        WebPreferencesMember.ctor(&wp._wp);
        return wp;
    }


    this(this) nothrow @nogc
    {
        static void callPB(T)(ref T b)
        {
          static if(is(typeof(b.__postblit())))
            b.__postblit();
        }

        callPB(userStylesheet);
        callPB(userScript);
        callPB(proxyConfig);
        callPB(acceptLanguage);
        callPB(acceptCharset);
        callPB(defaultEncoding);
    }


    ~this() nothrow @nogc
    {
        callAllDtor(userStylesheet);
        callAllDtor(userScript);
        callAllDtor(proxyConfig);
        callAllDtor(acceptLanguage);
        callAllDtor(acceptCharset);
        callAllDtor(defaultEncoding);
    }


  @property inout pure nothrow @trusted @nogc
  {
    inout(awebview.wrapper.cpp.WebPreferences)* cppObj() @safe
    { return &_wp; }

    ref inout(int) maxHttpCacheStorage()
    { return _wp.max_http_cache_storage; }

    ref inout(bool) enableJavascript()
    { return _wp.enable_javascript; }

    ref inout(bool) enableDart()
    { return _wp.enable_dart; }

    ref inout(bool) enablePlugins()
    { return _wp.enable_plugins; }

    ref inout(bool) enableLocalStorage()
    { return _wp.enable_local_storage; }

    ref inout(bool) enableDatabases()
    { return _wp.enable_databases; }

    ref inout(bool) enableAppCache()
    { return _wp.enable_app_cache; }

    ref inout(bool) enableWebAudio()
    { return _wp.enable_web_audio; }

    ref inout(bool) enableWebGL()
    { return _wp.enable_web_gl; }

    ref inout(bool) enableWebSecurity()
    { return _wp.enable_web_security; }

    ref inout(bool) enableRemoteFonts()
    { return _wp.enable_remote_fonts; }

    ref inout(bool) enableSmoothScrolling()
    { return _wp.enable_smooth_scrolling; }

    ref inout(bool) enableGPUAcceleration()
    { return _wp.enable_gpu_acceleration; }

    ref inout(WebStringCpp) userStylesheet()
    { return *cast(typeof(return)*)&_wp.user_stylesheet; }

    ref inout(WebStringCpp) userScript()
    { return *cast(typeof(return)*)&_wp.user_script; }

    ref inout(WebStringCpp) proxyConfig()
    { return *cast(typeof(return)*)&_wp.proxy_config; }

    ref inout(WebStringCpp) acceptLanguage()
    { return *cast(typeof(return)*)&_wp.accept_language; }

    ref inout(WebStringCpp) acceptCharset()
    { return *cast(typeof(return)*)&_wp.accept_charset; }

    ref inout(WebStringCpp) defaultEncoding()
    { return *cast(typeof(return)*)&_wp.default_encoding; }

    ref inout(bool) shrinkStandaloneImagesToFit()
    { return _wp.shrink_standalone_images_to_fit; }

    ref inout(bool) loadImagesAutomatically()
    { return _wp.load_images_automatically; }

    ref inout(bool) allowScriptsToOpenWindows()
    { return _wp.allow_scripts_to_open_windows; }

    ref inout(bool) allowScriptsToCloseWindows()
    { return _wp.allow_scripts_to_close_windows; }

    ref inout(bool) allowScriptsToAccessClipboard()
    { return _wp.allow_scripts_to_access_clipboard; }

    ref inout(bool) allowUniversalAccessFromFileURL()
    { return _wp.allow_universal_access_from_file_url; }

    ref inout(bool) allowFileAccessFromFileURL()
    { return _wp.allow_file_access_from_file_url; }

    ref inout(bool) allowRunningInsecureContent()
    { return _wp.allow_running_insecure_content; }
  }


  private:
    awebview.wrapper.cpp.WebPreferences _wp;
}
