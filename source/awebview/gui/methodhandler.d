module awebview.gui.methodhandler;

import awebview.wrapper.jsobject,
       awebview.wrapper.weakref;


struct JSMethodTag { wstring name; }


class MethodHandler : JSMethodHandler
{
    void set(JSObj)(JSObj obj)
    {
        foreach(name; __traits(allMembers, JSObj)){
            static if(is(typeof(mixin(`&obj.` ~ name)) == delegate))
                foreach(attr; __traits(getAttributes, mixin(`JSObj.` ~ name)))
                    static if(is(typeof(attr) : JSMethodTag))
                        set(obj.jsobject.get, attr.name, mixin(`&obj.` ~ name));
        }
    }


    void set(ref JSObject obj, wstring name, Dlg dg)
    {
        WebString str = name;

        if(!obj.hasMethod(str))
            obj.setCustomMethod(str, false);

        assert(obj.hasMethod(str));
        _table[obj.remoteId][name] = dg;
    }


    void set(ref JSObject obj, wstring name, DlgRV dg)
    {
        WebString str = name;

        if(!obj.hasMethod(str))
            obj.setCustomMethod(str, true);

        assert(obj.hasMethod(str));
        _tableRV[obj.remoteId][name] = dg;
    }


    void release(JSObj)(JSObj obj)
    {
        release(obj.jsobject.remoteId);
    }


    void release(uint objRemoteId)
    {
        _table.remove(objRemoteId);
        _tableRV.remove(objRemoteId);
    }


    override
    void onCall(awebview.wrapper.cpp.WebView view,
                uint objId, WeakRef!(const(WebStringCpp)) methodName,
                WeakRef!(const(JSArrayCpp)) args)
    {
        if(auto p = objId in _table)
            if(auto q = methodName.data in *p)
                (*q)(args);
    }


    override
    JSValue onCallWithRV(
        awebview.wrapper.cpp.WebView view,
        uint objId, WeakRef!(const(WebStringCpp)) methodName,
        WeakRef!(const(JSArrayCpp)) args)
    {
        if(auto p = objId in _tableRV)
            if(auto q = methodName.data in *p)
                return (*q)(args);

        JSValue v = JSValue(JSValue.null_);
        return v;
    }


  private:
    alias Dlg = void delegate(WeakRef!(const(JSArrayCpp)));
    alias DlgRV = JSValue delegate(WeakRef!(const(JSArrayCpp)));

    Dlg[wstring][uint] _table;
    DlgRV[wstring][uint] _tableRV;
}
