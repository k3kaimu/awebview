module awebview.wrapper.constants;

import awebview.wrapper.cpp;

import awebview.wrapper.jsarray;
import awebview.wrapper.jsvalue : JSValue;
import awebview.wrapper.webstring : WebString;
import awebview.wrapper.weburl : WebURL;
import awebview.wrapper.jsobject : JSObject;

struct JSValueConsts
{
    static shared immutable(JSValue*) _emptyInstance;
    static shared immutable(JSValue*) _undefined;
    static shared immutable(JSValue*) _null;

    shared static this()
    {
        JSValue* p = new JSValue;
        JSValueMember.ctor(p.cppObj!false);
        _emptyInstance = cast(immutable)p;

        JSValue* undefined = new JSValue(JSValueMember.Undefined());
        _undefined = cast(immutable)undefined;

        JSValue* null_ = new JSValue(JSValueMember.Null());
        _null = cast(immutable)null_;
    }
}


struct JSObjectConsts
{
    static shared immutable(JSObject*) _emptyInstance;

    shared static this()
    {
        JSObject* obj = new JSObject;
        JSObjectMember.ctor(obj.cppObj!false);
        _emptyInstance = cast(immutable)obj;
    }
}


struct JSArrayConsts
{
    static shared immutable(JSArrayCpp*) _emptyInstance;

    shared static this()
    {
        JSArrayCpp* p = new JSArrayCpp;
        JSArrayMember.ctor(p.cppObj!false);

        _emptyInstance = cast(immutable)p;
    }
}
