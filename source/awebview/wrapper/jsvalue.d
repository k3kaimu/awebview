module awebview.wrapper.jsvalue;

import std.conv;
import std.format;
import std.range;
import std.utf;
import std.traits;

import awebview.wrapper.cpp;
import awebview.wrapper.jsobject : JSObject;
import awebview.wrapper.jsarray : JSArray, JSArrayCpp;
import awebview.wrapper.jsarray;
import awebview.wrapper.jsobject;
import awebview.wrapper.webstring : WebString;
import awebview.wrapper.constants;
import awebview.wrapper.weakref;

import carbon.templates;
import carbon.nonametype;


struct JSValue
{
    this(bool b) nothrow @nogc { JSValueMember.ctor(this.cppObj!false, b); }
    this(int v)  nothrow @nogc { JSValueMember.ctor(this.cppObj!false, v); }
    this(double v)  nothrow @nogc { JSValueMember.ctor(this.cppObj!false, v); }

    this(const awebview.wrapper.cpp.WebString ws) nothrow @nogc
    {
        JSValueMember.ctor(this.cppObj!false, ws);
    }

    this()(auto ref const WebString ws)  nothrow @nogc { this(ws.cppObj); }

    this(Char)(in Char[] str) nothrow @nogc
    if(isSomeChar!Char)
    {
        WebString ws = str;
        this(ws);
    }

    this(const awebview.wrapper.cpp.JSObject jso) nothrow @nogc
    {
        JSValueMember.ctor(this.cppObj!false, jso);
    }

    this()(auto ref const JSObject jo) nothrow @nogc { this(jo.cppObj); }

    this(const awebview.wrapper.cpp.JSArray jsarr) nothrow @nogc
    {
        JSValueMember.ctor(this.cppObj!false, jsarr);
    }

    this()(auto ref const JSArray ja) nothrow @nogc { this(ja.cppObj); }

    this(const awebview.wrapper.cpp.JSValue v) nothrow @nogc
    {
        JSValueMember.ctor(this.cppObj!false, v);
    }

    this(const JSValue v) nothrow @nogc
    {
        this(v.cppObj);
    }


    ~this() nothrow @nogc
    {
        if(this._field.value_ !is null){
            JSValueMember.dtor(this.cppObj!false);
            this._field.value_ = null;
        }
    }


    this(this) nothrow @nogc
    {
        //import core.stdc.stdio;
        //printf("on postblit %d\n", this._field.value_);
        if(this._field.value_ !is null){
            auto copy = JSValue(this.cppObj!false);
            //printf("on postblit %d : %d\n", this._field.value_, copy._field.value_);
            //fflush(stdout);
            this._field.value_ = copy._field.value_;
            copy._field.value_ = null;
        }
    }


    void opAssign(const JSValue rhs) nothrow @nogc
    {
        JSValueMember.opAssign(this.cppObj, rhs.cppObj);
    }


    void opAssign(ref const JSValue rhs) nothrow @nogc
    {
        JSValueMember.opAssign(this.cppObj, rhs.cppObj);
    }


    void opAssign(T)(auto ref const T v)
    if(is(typeof(JSValue(v))))
    {
        auto jv = JSValue(v);
        this.opAssign(jv);
    }


    CppObj cppObj(bool withInitialize = true)() nothrow @trusted @property @nogc
    {
        CppObj ret = cast(CppObj)cast(void*)&_field;

      static if(withInitialize)
        if(_field.value_ is null)
            JSValueMember.ctor(ret);

        return ret;
    }


    inout(CppObj) cppObj() inout pure nothrow @trusted @property @nogc
    {
        if(_field.value_ is null)
            return cast(inout(CppObj))cast(inout(void)*)&JSValueConsts._emptyInstance._field;
        else
            return cast(inout(CppObj))cast(inout(void)*)&_field;
    }


    bool getBooleanProperty(alias f)() const nothrow @nogc { return f(this.cppObj); }
    alias isBoolean = getBooleanProperty!(JSValueMember.IsBoolean);
    alias isInteger = getBooleanProperty!(JSValueMember.IsInteger);
    alias isDouble = getBooleanProperty!(JSValueMember.IsDouble);
    alias isNumber = getBooleanProperty!(JSValueMember.IsNumber);
    alias isString = getBooleanProperty!(JSValueMember.IsString);
    alias isArray = getBooleanProperty!(JSValueMember.IsArray);
    alias isObject = getBooleanProperty!(JSValueMember.IsObject);
    alias isNull = getBooleanProperty!(JSValueMember.IsNull);
    alias isUndefined = getBooleanProperty!(JSValueMember.IsUndefined);

    bool has(T : bool)() const nothrow @nogc @property { return this.isBoolean; }
    bool has(T : int)() const nothrow @nogc @property { return this.isInteger; }
    bool has(T : double)() const nothrow @nogc @property { return this.isDouble; }
    bool has(T : string)() const nothrow @nogc @property { return this.isString; }
    bool has(T : WebString)() const nothrow @nogc @property { return this.isString; }
    bool has(T : JSArray)() const nothrow @nogc @property { return this.isArray; }
    bool has(T : JSObject)() const nothrow @nogc @property { return this.isObject; }
    bool has(T : typeof(null))() const nothrow @nogc @property { return this.isNull; }


    T get(T : bool)(T defVal = T.init) const nothrow @nogc
    {
        if(this.isBoolean)
            return JSValueMember.ToBoolean(this.cppObj);
        else
            return defVal;
    }


    T get(T : int)(T defVal = T.init) const nothrow @nogc
    {
        if(this.isInteger)
            return JSValueMember.ToInteger(this.cppObj);
        else
            return defVal;
    }


    T get(T : double)(T defVal = T.init) const nothrow @nogc
    {
        if(this.isDouble){
            return to!double(to!string(this)); //JSValueMember.ToDouble(this.cppObj);
        }else
            return defVal;
    }


    T get(T : WebString)(T defVal = T.init) const nothrow @nogc
    {
        if(this.isString){
            WebString str;
            JSValueMember.ToString(this.cppObj, str.cppObj);
            return str;
        }else
            return defVal;
    }


    T get(T)(T defVal = T.init) const nothrow @nogc
    if(is(T == JSObject))
    {
        if(this.isObject)
            return JSObject(JSValueMember.ToObject(this.cppObj));
        else
            return defVal;
    }


    WeakRef!JSObject get(T)(WeakRef!JSObject defVal = refP!JSObject(null))
    if(is(T == WeakRef!JSObject))
    {
        if(this.isObject)
            return .weakRef!JSObject(JSValueMember.ToObject(this.cppObj));
        else
            return defVal;
    }


    WeakRef!(const(JSObject)) get(T)(WeakRef!(const(JSObject)) defVal = refP!(const(JSObject))(null)) const
    if(is(T == WeakRef!JSObject))
    {
        if(this.isObject)
            return .weakRef!JSObject(JSValueMember.ToObject(this.cppObj));
        else
            return defVal;
    }


    T get(T)(T defVal = T.init) const nothrow @nogc
    if(is(T == JSArray))
    {
        if(this.isArray)
            return JSArray(JSValueMember.ToArray(this.cppObj));
        else
            return defVal;
    }


    WeakRef!(ApplySameTopQualifier!(This, JSArrayCpp))
        get(T : WeakRef!JSArrayCpp, this This)
        (WeakRef!(ApplySameTopQualifier!(This, JSArrayCpp)) defVal = WeakRef!(ApplySameTopQualifier!(This, JSArrayCpp)).init) inout nothrow @nogc
    {
      static if(is(This == const) || is(This == immutable))
      {
        if(this.isArray)
            return .weakRef!JSArrayCpp(JSValueMember.ToArray(this.cppObj));
        else
            return defVal;
      }
      else
      {
        if(this.isArray)
            return .weakRef!JSArrayCpp(JSValueMember.ToArray(cast(CppObj)this.cppObj));
        else
            return defVal;
      }
    }


    void toString(scope void delegate(const(char)[]) sink) const
    {
        if(this.isArray)
        {
            auto ja = get!(WeakRef!JSArrayCpp);
            ja.toString(sink);
        }
        else if(this.isObject)
        {
            auto jo = get!(WeakRef!JSObject);
            jo.toString(sink);
        }
        else
        {
            WebString str;
            JSValueMember.ToString(this.cppObj, str.cppObj);
            foreach(char e; str.data.byChar)
                put(sink, e);
        }
    }


    static
    ref immutable(JSValue) undefined() pure nothrow @safe @nogc @property
    {
        return *JSValueConsts._undefined;
    }


    static
    ref immutable(JSValue) null_() pure nothrow @safe @nogc @property
    {
        return *JSValueConsts._null;
    }


    static
    auto weakRef(H)(H jsv)
    if(is(H : const(awebview.wrapper.cpp.JSValue)))
    {
      static if(is(H == awebview.wrapper.cpp.JSValue))
        JSValue* wsp = cast(JSValue*)cast(void*)jsv;
      else static if(is(H == const(awebview.wrapper.cpp.JSValue)))
        const(JSValue)* wsp = cast(const(JSValue)*)cast(const(void)*)jsv;
      else
        immutable(JSValue)* wsp = cast(immutable(JSValue)*)cast(immutable(void)*)jsv;

        return refP(wsp);
    }


  private:
    alias CppObj = awebview.wrapper.cpp.JSValue;
    CppObj.Field _field;
}

unittest
{
    JSValue v = true;
    assert(v.isBoolean);
    assert(v.get!bool);
    
    v = false;
    assert(v.isBoolean);
    assert(!v.get!bool);
}

unittest
{
    import std.conv;

    JSValue v = 12;
    assert(v.isInteger);
    assert(v.isNumber);
    assert(!v.isDouble);
    assert(!v.isObject);
    assert(!v.isBoolean);
    assert(v.get!int == 12);
    assert(to!string(v) == "12");

    JSValue v2 = 12.5;
    assert(!v2.isInteger);
    assert(v2.isDouble);
    assert(!v2.isBoolean);
    import std.stdio;
    assert(to!string(v2) == "12.5");

    JSValue v3 = "foo";
    assert(v3.isString);
    assert(to!string(v3) == "foo");

    JSArray ja = [1, 2, 3];
    JSValue v4 = ja;
    assert(v4.isArray);
    auto v4arr = v4.get!(WeakRef!JSArrayCpp);
    assert(v4arr.length == 3);

    const v5 = v4;
    assert(v5.isArray);
    auto v5arr = v5.get!(WeakRef!JSArrayCpp);
    assert(v5arr.length == 3);
}
