module awebview.wrapper.cpp.webpreferences;


mixin template Awesomium()
{
    align(1) struct WebPreferences
    {
      align(1):
        int max_http_cache_storage;
        bool enable_javascript;
        bool enable_dart;
        bool enable_plugins;
        bool enable_local_storage;
        bool enable_databases;
        bool enable_app_cache;
        bool enable_web_audio;
        bool enable_web_gl;
        bool enable_web_security;
        bool enable_remote_fonts;
        bool enable_smooth_scrolling;
        bool enable_gpu_acceleration;
        WebString.Field user_stylesheet;
        WebString.Field user_script;
        WebString.Field proxy_config;
        WebString.Field accept_language;
        WebString.Field accept_charset;
        WebString.Field default_encoding;
        bool shrink_standalone_images_to_fit;
        bool load_images_automatically;
        bool allow_scripts_to_open_windows;
        bool allow_scripts_to_close_windows;
        bool allow_scripts_to_access_clipboard;
        bool allow_universal_access_from_file_url;
        bool allow_file_access_from_file_url;
        bool allow_running_insecure_content;
    }
}

mixin template Awesomium4D()
{
    extern(C++, WebPreferencesMember)
    {
        size_t sizeOfInstance();
        void ctor(WebPreferences * p);
        WebPreferences * newCtor();
        void deleteDtor(WebPreferences * p);
    }


    unittest {
        assert(WebPreferencesMember.sizeOfInstance()
            == WebPreferences.sizeof);
    }
}
