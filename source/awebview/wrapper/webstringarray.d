module awebview.wrapper.webstringarray;

import std.traits;

import awebview.wrapper.cpp;
import awebview.wrapper.webstring : WebString;
import awebview.wrapper.webstring;
import awebview.wrapper.webstring;
import awebview.wrapper.weakref;

import carbon.memory;
import carbon.nonametype;



struct WebStringArray
{
    alias PayloadType(This) = typeof(This.init.payload);


    @property
    ref WebStringArrayCpp payload() nothrow @nogc
    {
        if(!_instance.refCountedStore.isInitialized)
            __ctor(cast(CppObj)null);

        return _instance.refCountedPayload;
    }


    @property
    ref inout(WebStringArrayCpp) payload(this T)() inout nothrow @nogc
    if(is(T == const) || is(T == immutable))
    {
        if(this._instance.refCountedStore.isInitialized)
            return *cast(typeof(return)*)&(this._instance.refCountedPayload());
        else
            return *cast(typeof(return)*)WebStringArrayCpp._emptyInstance;
    }


    this(ref const WebStringArrayCpp ws) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!WebStringArrayCpp(ws.cppObj));
    }


    this(in WebStringCpp[] ws) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!WebStringArrayCpp(ws));
    }


    this(in WebString[] ws) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!WebStringArrayCpp(ws));
    }


    this(in awebview.wrapper.cpp.WebStringArray cppObj) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!WebStringArrayCpp(cppObj));
    }


    this(uint n)
    {
        _instance = Instance(RefCountedNoGC!WebStringArrayCpp(n));
    }


    this(Char)(in Char[][] str)
    {
        _instance = Instance(RefCountedNoGC!WebStringArrayCpp(str));
    }


    WebStringArray dup() const nothrow @nogc @property
    {
        WebStringArray ws = this.cppObj;
        return ws;
    }


    @property
    inout(awebview.wrapper.cpp.WebStringArray)
        cppObj(this T)() inout nothrow @nogc
    { return cast(typeof(return))(cast(T*)&this).payload.cppObj; }


    uint length() const nothrow @nogc
    { return payload.length; }

    bool empty() const nothrow @nogc
    { return payload.empty; }

    awebview.wrapper.webstring.WeakRef!(WebStringCpp) opIndex(size_t idx) @nogc nothrow
    { return payload[idx]; }

    awebview.wrapper.webstring.WeakRef!(const(WebStringCpp)) opIndex(size_t idx) const @nogc nothrow
    { return payload[idx]; }

    void opOpAssign(string op : "~", Char)(in Char[] str)
    if(isSomeChar!Char)
    {
        WebStringCpp ws = str;
        this ~= ws.cppObj;
    }


    void opOpAssign(string op : "~", Char)(in Char[][] str)
    {
        foreach(e; str){
            WebStringCpp ws = str;
            this ~= str.cppObj;
        }
    }


    void opOpAssign(string op : "~")(const WebString str)
    {
        this ~= str.cppObj;
    }


    void opOpAssign(string op : "~")(ref const WebStringCpp str)
    {
        this ~= str.cppObj;
    }


    void opOpAssign(string op : "~")(in awebview.wrapper.cpp.WebString cppStr)
    {
        if(!_instance.refCountedStore.isInitialized){
            __ctor(0);
            this.payload ~= cppStr;
            return;
        }


        if(_instance.refCountedStore.refCount > 1)
            this = this.dup;

        this.payload ~= cppStr;
    }


    bool opEquals(ref const WebStringArrayCpp rhs) const nothrow @nogc
    { return payload == rhs; }


    bool opEquals(const WebStringArray rhs) const nothrow @nogc
    { return payload == rhs.payload; }

    bool opEquals(E)(in E[] rhs) const
    if(is(typeof(this[0] == rhs[0])))
    { return payload == rhs; }


    int opCmp(ref const WebStringArrayCpp rhs) const nothrow @nogc
    { return payload.opCmp(rhs); }

    int opCmp(const WebStringArray rhs) const nothrow @nogc
    { return payload.opCmp(rhs.payload); }

    int opCmp(E)(in E[] rhs) const
    if(is(typeof(this[0].opCmp(rhs[0]))))
    { return payload.opCmp(rhs); }

  private:
    Instance _instance;

    static auto _dummyTypeCreate()
    {
        static struct Dummy
        {
            RefCountedNoGC!WebStringArrayCpp obj;
            alias obj this;
        }

        return Dummy();
    }

    alias Instance = typeof(_dummyTypeCreate());
    alias CppObj = awebview.wrapper.cpp.WebStringArray;
}

@nogc unittest {
    WebStringArray ws;
}


struct WebStringArrayCpp
{
    this(in awebview.wrapper.cpp.WebStringArray p) @nogc nothrow
    {
        if(p is null)
            WebStringArrayMember.ctor(this.cppObj!false);
        else
            WebStringArrayMember.ctor(this.cppObj!false, p);
    }


    this(uint n) @nogc nothrow
    {
        WebStringArrayMember.ctor(this.cppObj!false, n);
    }


    this(in WebString[] strarr) @nogc nothrow
    {
        WebStringArrayMember.ctor(this.cppObj!false);

        foreach(const ref e; strarr)
            this ~= e;
    }


    this(in WebStringCpp[] strarr) @nogc nothrow
    {
        WebStringArrayMember.ctor(this.cppObj!false);

        foreach(const ref e; strarr)
            this ~= e;
    }


    this(Char)(in Char[][] strarr) @nogc nothrow
    if(isSomeChar!Char)
    {
        WebStringArrayMember.ctor(this.cppObj!false);

        foreach(const ref e; strarr)
            this ~= e;
    }


    this(this) @nogc nothrow
    {
        if(cppField.vector_ !is null){
            WebStringArrayCpp copy = WebStringArrayCpp(this.cppObj!false);
            this._field = copy._field;
            copy.cppField.vector_ = null;
        }
    }


    ~this() @nogc nothrow
    {
        if(cppField.vector_ !is null){
            WebStringArrayMember.dtor(this.cppObj!false);
            cppField.vector_ = null;
        }
    }


    uint length() const @nogc nothrow { return WebStringArrayMember.size(this.cppObj); }

    bool empty() const @nogc nothrow { return this.length == 0; }

    WeakRef!(WebStringCpp) opIndex(size_t idx) @nogc nothrow
    in{
        assert(idx <= uint.max);
    }
    body{
        return WebStringArrayMember.At(this.cppObj, cast(uint)idx).weakRef!WebStringCpp;
    }


    WeakRef!(const(WebStringCpp)) opIndex(size_t idx) const @nogc nothrow
    in{
        assert(idx <= uint.max);
    }
    body{
        return WebStringArrayMember.At(this.cppObj, cast(uint)idx).weakRef!WebStringCpp;
    }


    private
    ref inout(CppObj.Field) cppField() inout @property pure nothrow @trusted @nogc
    {
        return *cast(typeof(return)*)_field.ptr;
    }


    CppObj cppObj(bool withInitialize = true)() nothrow @trusted @property @nogc
    {
        CppObj ret = cast(CppObj)cast(void*)_field.ptr;

      static if(withInitialize)
        if(cppField.vector_ is null)
            WebStringArrayMember.ctor(ret);

        return ret;
    }


    inout(CppObj) cppObj() inout nothrow @trusted @property @nogc
    {
        if(cppField.vector_ is null)
            return cast(inout(CppObj))cast(inout(void)*)_emptyInstance._field.ptr;
        else
            return cast(inout(CppObj))cast(inout(void)*)_field.ptr;
    }


    void opOpAssign(string op : "~", Char)(in Char[] str)
    if(isSomeChar!Char)
    {
        WebString ws = str;
        this ~= ws;
    }


    void opOpAssign(string op : "~", Char)(in Char[][] strs)
    if(isSomeChar!Char)
    {
        foreach(const ref e; strs)
            this ~= e;
    }


    void opOpAssign(string op : "~")(auto ref const WebString str)
    {
        WebStringArrayMember.Push(this.cppObj, str.cppObj);
    }


    void opOpAssign(string op : "~")(auto ref const WebStringArrayCpp strs)
    {
        foreach(i; 0 .. strs.length)
            this ~= strs[i];
    }


    void opOpAssign(string op : "~")(in awebview.wrapper.cpp.WebString cppStr)
    {
        WebStringArrayMember.Push(this.cppObj, cppStr);
    }


    bool opEquals()(ref const WebStringArrayCpp rhs) const nothrow @nogc
    {
        return opEqualsImpl(rhs);
    }


    bool opEquals(E)(in E[] rhs) const
    if(is(typeof(this[0] == rhs[0])))
    {
        return opEqualsImpl(rhs);
    }


    bool opEquals(in awebview.wrapper.cpp.WebStringArray cobj) const nothrow @nogc
    {
        auto wr = cobj.weakRef!WebStringArrayCpp;
        return this == wr.get;
    }


    int opCmp(ref const WebStringArrayCpp rhs) const nothrow @nogc
    {
        return opCmpImpl(rhs);
    }


    int opCmp(E)(in E[] rhs) const
    if(is(typeof(this[0].opCmp(rhs[0]))))
    {
        return opCmpImpl(rhs);
    }


    int opCmp(in awebview.wrapper.cpp.WebStringArray cobj) const nothrow @nogc
    {
        auto wr = cobj.weakRef!WebStringArrayCpp;
        return this.opCmp(wr.get);
    }


    static
    auto weakRef(HandleWSA)(HandleWSA ws) @trusted
    if(is(HandleWSA : const(awebview.wrapper.cpp.WebStringArray)))
    {
      static if(is(HandleWSA == awebview.wrapper.cpp.WebStringArray))
        WebStringArrayCpp* wsp = cast(WebStringArrayCpp*)cast(void*)ws;
      else static if(is(HandleWSA == const(awebview.wrapper.cpp.WebStringArray)))
        const(WebStringArrayCpp)* wsp = cast(const(WebStringArrayCpp)*)cast(const(void)*)ws;
      else
        immutable(WebStringArrayCpp)* wsp = cast(immutable(WebStringArrayCpp)*)cast(immutable(void)*)ws;

        return refP(wsp);
    }


  private:
    ubyte[CppObj.Field.sizeof] _field;

    static shared immutable(WebStringArrayCpp*) _emptyInstance;

    alias CppObj = awebview.wrapper.cpp.WebStringArray;

    shared static this()
    {
        WebStringArrayCpp* _empty = new WebStringArrayCpp;
        WebStringArrayMember.ctor(_empty.cppObj!false);
        _emptyInstance = cast(immutable)_empty;
    }


    bool opEqualsImpl(T)(ref T rhs) const
    {
        immutable lenThis = this.length;

        if(lenThis != rhs.length)
            return false;

        foreach(i; 0 .. lenThis)
            if(this[i] != rhs[i])
                return false;

        return true;
    }


    int opCmpImpl(T)(ref T rhs) const
    {
        immutable lenThis = this.length,
                  lenRhs = rhs.length;

        if(lenThis < lenRhs)
            return -1;
        else if(lenThis > lenRhs)
            return 1;

        foreach(i; 0 .. lenThis){
            if(int res = this[i].opCmp(rhs[i]))
                return res;
        }

        return 0;
    }
}


unittest
{
    WebStringArrayCpp arr;
    assert(arr.length == 0);
    assert(arr.empty);
    assert(arr == arr);

    arr ~= "foobar";
    assert(arr.length == 1);
    assert(arr[0] == "foobar");
    assert(arr == ["foobar"]);

    arr ~= "ああああ";
    assert(arr.length == 2);
    assert(arr[1] == "ああああ");
    assert(arr == ["foobar", "ああああ"]);
}

unittest
{
    WebStringArrayCpp arr = ["オーサミウム", "ｵｰｻﾐｳﾑ", "おーさみうむ"];
    assert(arr.length == 3);
    assert(!arr.empty);

    auto arr2 = arr;
    assert(arr2 == arr);
    assert(arr2.cppObj != arr.cppObj);
}
