module awebview.wrapper.jsobject;

import std.range;
import std.utf;

import awebview.wrapper.cpp;
import awebview.wrapper.jsarray : JSArray, JSArrayCpp;
import awebview.wrapper.jsvalue : JSValue;
import awebview.wrapper.webstring : WebString, WebStringCpp;
import awebview.wrapper.constants;
import awebview.wrapper.weakref;
import awebview.wrapper.cpp.mmanager;

public import awebview.wrapper.cpp : JSObjectType;

import carbon.nonametype;

struct JSObject
{
    ~this() nothrow @nogc
    {
        if(this._field.instance_.local !is null)
            JSObjectMember.dtor(this.cppObj!false);
    }


    this(this) nothrow @nogc
    {
        JSObject copy;
        JSObjectMember.ctor(copy.cppObj!false, this.cppObj);
        this._field = copy._field;
        copy._field.instance_.local = null;
    }


    @property
    CppObj cppObj(bool withInitialize = true)() nothrow @trusted @nogc
    {
        CppObj ret = cast(CppObj)cast(void*)&_field;

      static if(withInitialize)
        if(_field.instance_.local is null)
            JSObjectMember.ctor(ret);

        return ret;
    }


    @property
    inout(CppObj) cppObj(this T)() inout nothrow @trusted @nogc
    if(is(T == const) || is(T == immutable))
    {
        if(_field.instance_.local is null)
            return cast(inout(CppObj))cast(inout(void)*)&JSObjectConsts._emptyInstance._field;
        else
            return cast(inout(CppObj))cast(inout(void)*)&_field;
    }


    @property
    uint remoteId() const nothrow @nogc
    {
        return JSObjectMember.remote_id(this.cppObj);
    }


    @property
    int refCount() const nothrow @nogc
    {
        return JSObjectMember.ref_count(this.cppObj);
    }


    @property
    JSObjectType type() const nothrow @nogc
    {
        return JSObjectMember.type(this.cppObj);
    }


    @property
    JSArray propertyNames() const nothrow @nogc
    {
        JSArray ja;
        JSObjectMember.GetPropertyNames(this.cppObj, ja.cppObj);
        return ja;
    }


    bool hasProperty(string str) const nothrow @nogc
    {
        WebString ws = str;
        return hasProperty(ws);
    }


    bool hasProperty(in WebString str) const nothrow @nogc
    {
        return JSObjectMember.HasProperty(this.cppObj, str.cppObj);
    }


    JSValue getProperty(string str) const nothrow @nogc
    {
        return getProperty(WebString(str));
    }


    JSValue getProperty(in WebString str) const nothrow @nogc
    {
        JSValue jv;
        JSObjectMember.GetProperty(this.cppObj, str.cppObj, jv.cppObj);
        return jv;
    }


    void setProperty(in string str, in JSValue value) nothrow @nogc
    {
        setProperty(WebString(str), value);
    }


    void setProperty(in WebString str, in JSValue value) nothrow @nogc
    {
        JSObjectMember.SetProperty(this.cppObj, str.cppObj, value.cppObj);
    }


    void opIndexAssign(T)(T v, string str)
    if(is(typeof(JSValue(v)) == JSValue))
    {
        setProperty(str, v);
    }


    JSValue opIndex(string str)
    {
        return getProperty(str);
    }


    void setPropertyAsync(in string str, in JSObject value) nothrow @nogc
    {
        setPropertyAsync(WebString(str), value);
    }


    void setPropertyAsync(in WebString str, in JSObject value) nothrow @nogc
    {
        JSObjectMember.SetPropertyAsync(this.cppObj, str.cppObj, value.cppObj);
    }


    void removeProperty(in string str) nothrow @nogc
    {
        removeProperty(WebString(str));
    }


    void removeProperty(in WebString str) nothrow @nogc
    {
        JSObjectMember.RemoveProperty(this.cppObj, str.cppObj);
    }


    @property
    JSArray getMethodNames() const nothrow @nogc
    {
        JSArray ja;
        JSObjectMember.GetMethodNames(this.cppObj, ja.cppObj);
        return ja;
    }


    @property
    bool hasMethod(Char)(in Char[] str) const nothrow @nogc
    {
        return hasMethod(WebString(str));
    }


    @property
    bool hasMethod(in WebString str) const nothrow @nogc
    {
        return JSObjectMember.HasMethod(this.cppObj, str.cppObj);
    }


    JSValue invoke(in WebString str, in JSArray args) nothrow @nogc
    {
        JSValue jv;
        JSObjectMember.Invoke(this.cppObj, str.cppObj, args.cppObj, jv.cppObj);
        return jv;
    }


    void invokeAsync(in WebString str, in JSArray args) nothrow @nogc
    {
        JSObjectMember.InvokeAsync(this.cppObj, str.cppObj, args.cppObj);
    }


    void toString(scope void delegate(const(char)[]) sink) const
    {
        WebString str;
        JSObjectMember.ToString(this.cppObj, str.cppObj);
        foreach(char e; str.data.byChar)
            put(sink, e);
    }


    void setCustomMethod(in WebString str, bool hasReturnValue) @nogc nothrow
    {
        JSObjectMember.SetCustomMethod(this.cppObj, str.cppObj, hasReturnValue);
    }


    void setCustomMethod(in string str, bool hasReturnValue) @nogc nothrow
    {
        setCustomMethod(WebString(str), hasReturnValue);
    }


    @property
    awebview.wrapper.cpp.Awesomium.Error lastError() const nothrow @nogc
    {
        return JSObjectMember.last_error(this.cppObj);
    }


    static
    auto weakRef(H)(H ws)
    if(is(H : const(CppObj)))
    {
      static if(is(H == CppObj))
        JSObject* wsp = cast(JSObject*)cast(void*)ws;
      else static if(is(H == const(CppObj)))
        const(JSObject)* wsp = cast(const(JSObject)*)cast(const(void)*)ws;
      else
        immutable(JSObject)* wsp = cast(immutable(JSObject)*)cast(immutable(void)*)ws;

        return refP(wsp);
    }

  private:
    alias CppObj = awebview.wrapper.cpp.JSObject;
    CppObj.Field _field;
}


abstract class JSMethodHandler : awebview.wrapper.cpp.IJSMethodHandlerD
{
    this()
    {
        auto id = MemoryManager.instance.register(cast(void*)this);
        _cppObj = JSMethodHandlerD2CppMember.newCtor(this, id);
    }


    ~this()
    {
        JSMethodHandlerD2CppMember.deleteDtor(_cppObj);
    }


    @property
    inout(CppObj) cppObj() inout pure nothrow @safe @nogc
    {
        return _cppObj;
    }


  extern(C++)
  {
    void call(awebview.wrapper.cpp.WebView view,
              uint objId, const(awebview.wrapper.cpp.WebString) methodName,
              const(awebview.wrapper.cpp.JSArray) args)
    {
        onCall(view, objId, methodName.weakRef!WebStringCpp, args.weakRef!JSArrayCpp);
    }


    void callWithReturnValue(
        awebview.wrapper.cpp.WebView view,
        uint objId, const(awebview.wrapper.cpp.WebString) methodName,
        const(awebview.wrapper.cpp.JSArray) args,
        awebview.wrapper.cpp.JSValue dst)
    {
        dst.weakRef!JSValue = onCallWithRV(view, objId, methodName.weakRef!WebStringCpp, args.weakRef!JSArrayCpp);
    }
  }


    void onCall(awebview.wrapper.cpp.WebView view,
                uint objId, WeakRef!(const(WebStringCpp)) methodName,
                WeakRef!(const(JSArrayCpp)) args);


    JSValue onCallWithRV(
        awebview.wrapper.cpp.WebView view,
        uint objId, WeakRef!(const(WebStringCpp)) methodName,
        WeakRef!(const(JSArrayCpp)) args);


  private:
    CppObj _cppObj;

    alias CppObj = awebview.wrapper.cpp.JSMethodHandlerD2Cpp;
}
