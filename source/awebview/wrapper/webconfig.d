module awebview.wrapper.webconfig;

import awebview.wrapper.webstring : WebString, WebStringCpp;
import awebview.wrapper.webstringarray : WebStringArray, WebStringArrayCpp;
import awebview.wrapper.webstringarray;
public import awebview.wrapper.cpp : LogLevel;
import awebview.wrapper.cpp;
import std.algorithm : move;

import carbon.memory;


struct WebConfig
{
    static WebConfig opCall() nothrow @nogc
    {
        WebConfig dst;
        WebConfigMember.ctor(&dst._wc);

        return dst;
    }


    this(this) nothrow @nogc
    {
        callAllPostblit(packagePath);
        callAllPostblit(pluginPath);
        callAllPostblit(logPath);
        callAllPostblit(childProcessPath);
        callAllPostblit(userAgent);
        callAllPostblit(remoteDebuggingHost);
        callAllPostblit(userScript);
        callAllPostblit(userStyleSheet);
        callAllPostblit(assetProtocol);
        callAllPostblit(additionalOptions);
    }


    ~this() nothrow @nogc
    {
        callAllDtor(packagePath);
        callAllDtor(pluginPath);
        callAllDtor(logPath);
        callAllDtor(childProcessPath);
        callAllDtor(userAgent);
        callAllDtor(remoteDebuggingHost);
        callAllDtor(userScript);
        callAllDtor(userStyleSheet);
        callAllDtor(assetProtocol);
        callAllDtor(additionalOptions);
    }


  @property
  {
    inout(awebview.wrapper.cpp.WebConfig)* cppObj() inout pure nothrow @safe @nogc
    { return &_wc; }

    ref inout(LogLevel) logLevel() inout pure nothrow @trusted @nogc
    { return _wc.log_level; }

    ref inout(WebStringCpp) packagePath() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.package_path; }

    ref inout(WebStringCpp) pluginPath() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.plugin_path; }

    ref inout(WebStringCpp) logPath() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.log_path; }

    ref inout(WebStringCpp) childProcessPath() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.child_process_path; }

    ref inout(WebStringCpp) userAgent() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.user_agent; }

    ref inout(int) remoteDebuggingPort() inout pure nothrow @safe @nogc
    { return _wc.remote_debugging_port; }

    ref inout(WebStringCpp) remoteDebuggingHost() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.remote_debugging_host; }

    ref inout(bool) reduceMemoryUsageOnNavigation() inout pure nothrow @safe @nogc
    { return _wc.reduce_memory_usage_on_navigation; }

    ref inout(WebStringCpp) userScript() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.user_script; }

    ref inout(WebStringCpp) userStyleSheet() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.user_stylesheet; }

    ref inout(WebStringCpp) assetProtocol() inout pure nothrow @trusted @nogc
    { return *cast(typeof(return)*)&_wc.asset_protocol; }

    ref inout(WebStringArrayCpp) additionalOptions() inout nothrow @nogc
    { return *cast(typeof(return)*)&_wc.additional_options; }
  }


  private:
    awebview.wrapper.cpp.WebConfig _wc;
}
