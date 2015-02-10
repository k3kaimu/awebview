module awebview.wrapper.cpp.webconfig;


mixin template Awesomium()
{
    enum LogLevel { none, normal, verbose }

    align(1) struct WebConfig {
      align(1):
        LogLevel log_level;
        WebString.Field package_path;
        WebString.Field plugin_path;
        WebString.Field log_path;
        WebString.Field child_process_path;
        WebString.Field user_agent;
        int remote_debugging_port;
        WebString.Field remote_debugging_host;
        bool reduce_memory_usage_on_navigation;
        WebString.Field user_script;
        WebString.Field user_stylesheet;
        WebString.Field asset_protocol;
        WebStringArray.Field additional_options;
    }
}


mixin template Awesomium4D()
{
    extern(C++, WebConfigMember)
    {
        size_t sizeOfInstance();
        void ctor(Awesomium.WebConfig*);
        void ctor(Awesomium.WebConfig*, const(Awesomium.WebConfig)*);
        Awesomium.WebConfig* newCtor();
        Awesomium.WebConfig* newCtor(const(Awesomium.WebConfig)*);
        void dtor(Awesomium.WebConfig*);
        void deleteDtor(Awesomium.WebConfig*);
        //void* additionalOptionsPtr(Awesomium.WebConfig*);
        //const(void)* additionalOptionsPtr(const(Awesomium.WebConfig)*);
    }

    //unittest {
    //    import std.stdio;
    //    assert(WebConfigMember.sizeOfInstance == Awesomium.WebConfig.sizeof);
    //}
}
