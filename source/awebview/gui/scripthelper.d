module awebview.gui.scripthelper;

import awebview.gui.activity;
import awebview.gui.methodhandler;
import awebview.wrapper;
import std.conv : to;

struct ScriptHelper
{
    this(Activity activity, string name)
    {
        _activity = activity;
        _sh = activity.createObject(name);
        activity.methodHandler.set(this);
    }


    WeakRef!JSObject jsobject() { return _sh; }


    @JSMethodTag("callDLangFunc"w)
    JSValue callDLangFunc(WeakRef!(const(JSArrayCpp)) args)
    {
        if(args.length < 1){
            _lastValue = JSValue.undefined;
            return _lastValue;
        }

        switch(args[0].to!string)
        {
          case "std.net.curl.get":
            if(args.length < 2)
                break;

            import std.stdio;
            WebURL url = args[1].to!string;
            if(url.scheme == "file"){
                import std.file : readText;
                string path = url.path.to!string;
                if(path[0] == '/')
                    path = path[1 .. $];
                import std.stdio;
                writeln(path);
                return JSValue(readText(path));
            }
            else{
                import std.net.curl : get;
                _lastValue = get(args[1].to!string);
                return _lastValue;
            }

          default:
        }

        _lastValue = JSValue.undefined;
        return _lastValue;
    }


  private:
    JSValue _lastValue;
    Activity _activity;
    WeakRef!JSObject _sh;
}


ScriptHelper createScriptHelper(Activity activity)
{
    auto sh = ScriptHelper(activity, "ScriptHelper");
    return sh;
}
