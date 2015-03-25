module awebview.wrapper.webstring;

import std.algorithm;
import std.traits;
import std.array;

import awebview.wrapper.cpp;
import awebview.wrapper.weakref;

import carbon.nonametype;
import carbon.memory;
import carbon.templates;


enum bool hasCppWebString(T) = is(typeof((T obj){
    awebview.wrapper.cpp.WebString cpp = obj.cppObj;
}));



/**
This type manages $(D WebStringCpp) by reference-counting.
*/
struct WebString
{
    alias PayloadType(This) = typeof(This.init.payload);

    /**
    Return reference to $(D WebStringCpp) that is managed by reference-counting in $(D WebString).

    If $(D this) is not initialized yet,
    $(D WebStringCpp) is initialized by $(awebview.wrapper.cpp.WebString.init).

    If $(D this) is $(D const) or $(D immutable) and $(D this) is not initialized yet,
    this method returns a reference to global empty instance of immutable(WebStringCpp).
    */
    //@property
    //ref WebStringCpp payload() nothrow @nogc
    //{
    //    if(!_instance.refCountedStore.isInitialized)
    //        __ctor(cast(awebview.wrapper.cpp.WebString)null);

    //    return _instance.refCountedPayload;
    //}

    ///// ditto
    //@property
    //ref inout(WebStringCpp) payload(this T)() inout nothrow @nogc
    //if(is(T == const) || is(T == immutable))
    //{
    //    if(this._instance.refCountedStore.isInitialized)
    //        return *cast(typeof(return)*)&(this._instance.refCountedPayload());
    //    else
    //        return *cast(typeof(return)*)WebStringCpp._emptyInstance;
    //}
    @property
    auto ref payload(this T)() nothrow @nogc @trusted
    {
        static if(is(T == WebString))
        {
            if(!_instance.refCountedStore.isInitialized)
                __ctor(cast(awebview.wrapper.cpp.WebString)null);

            return _instance.refCountedPayload;
        }
        else static if(is(T == const) || is(T == immutable) || is(T == inout))
        {
            alias R = typeof(this._instance.refCountedPayload());

            if(this._instance.refCountedStore.isInitialized)
                return this._instance.refCountedPayload;
            else
                return *cast(R*)WebStringCpp._emptyInstance;
        }
    }

    unittest {
        WebString ws;
        assert(!ws._instance.refCountedStore.isInitialized);

        // call this.payload
        assert(ws.payload.cppField.instance_ !is null);
        assert(ws._instance.refCountedStore.isInitialized);
    }

    unittest {
        const WebString cws;
        assert(!cws._instance.refCountedStore.isInitialized);

        assert(&(cws.payload()) == WebStringCpp._emptyInstance);

        WebString ws = "foo";
        const cws2 = ws;
        assert(cws2._instance.refCountedStore.isInitialized);
        assert(&(cws2.payload()) == &(ws.payload()));
    }


    /**
    Construct $(D WebString) by copying.
    */
    this(ref WebStringCpp ws) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!WebStringCpp(ws.cppObj));
    }


    /// ditto
    this(in awebview.wrapper.cpp.WebString cppObj) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!WebStringCpp(cppObj));
    }


    /// ditto
    this(Char)(in Char[] str) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!WebStringCpp(str));
    }

    unittest {
        WebStringCpp wcpp = "foobar";
        WebString ws1 = wcpp;                   // ref WebStringCpp
        assert(ws1.data == "foobar"w);
        assert(ws1.cppObj !is wcpp.cppObj);     // constructed by copying.

        WebString ws2 = wcpp.cppObj;            // CppObj
        assert(ws2.data == "foobar"w);
        assert(ws2.cppObj !is wcpp.cppObj);     // constructed by copying.

        WebString ws3 = wcpp.data;              // const(wchar)[]
        assert(ws3.data == "foobar"w);
        assert(ws3.cppObj !is wcpp.cppObj);     // constructed by copying.
    }


    /**
    Return a reference to an instance of the C++'s class $(D Awesomium::WebString).
    */
    @property
    awebview.wrapper.cpp.WebString
        cppObj() nothrow @nogc
    { return payload.cppObj; }


    /// ditto
    @property
    inout(awebview.wrapper.cpp.WebString)
        cppObj(this T)() inout pure nothrow @nogc
    if(is(T == const) || is(T == immutable))
    { return (cast(T*)&this).payload.cppObj; }

    unittest {
        WebString ws = "foobar";
        assert(ws.cppObj is ws.payload.cppObj);

        const cws = ws;
        assert(ws.cppObj is cws.cppObj);
        assert(cws.cppObj is cws.payload.cppObj);

        WebString e;
        const WebString ce = e;
        assert(ce.cppObj is WebStringCpp._emptyInstance.cppObj);
    }


    /**
    Return reference to $(D WebStringCpp) that is managed by reference-counting in $(D WebString).
    */
    @property
    WeakRef!(PayloadType!This) weakRef(this This)() inout nothrow @nogc
    {
        alias WSCpp = PayloadType!This;
        return refP!WSCpp(cast(WSCpp*)&(cast(This*)&this).payload());
    }

    unittest {
        
    }


    @property
    WebString dup() const @nogc
    {
        auto cppObj = this.payload.cppObj;
        return WebString(cppObj);
    }


    void opAssign(WebString ws) @nogc
    { _instance = ws._instance; }

    void opAssign(Char)(const(Char)[] str) @nogc
    { this = WebString(str); }

    void opAssign(ref const WebStringCpp wrefstr) @nogc
    { this = WebString(wrefstr.cppObj); }

    void opAssign(in awebview.wrapper.cpp.WebString cppObj) @nogc
    { this = WebString(cppObj); }



    const(wchar)* ptr() const nothrow @property @nogc
    { return payload.ptr; }


    alias opDollar = length;

    size_t length() const nothrow @property @nogc
    { return payload.length; }


    bool empty() const nothrow @property @nogc
    { return payload.empty; }


    const(wchar)[] data() const nothrow @property @nogc
    { return this.ptr[0 .. this.length]; }


    const(wchar)[] opSlice() const nothrow @property @nogc
    { return this.data; }


    void opOpAssign(string op : "~")(const WebString ws) nothrow @nogc
    {
        this ~= ws.cppObj;
    }


    void opOpAssign(string op : "~")(ref const WebStringCpp ws) nothrow @nogc
    {
        this ~= ws.cppObj;
    }


    void opOpAssign(string op : "~", Char)(const(Char)[] str) nothrow @nogc
    {
        if(!this._instance.refCountedStore.isInitialized){
            __ctor(ws.cppObj);
            return;
        }

        if(this._instance.refCountedStore.refCount > 1)
            this = this.dup;

        this.payload ~= str;
    }


    void opOpAssign(string op : "~")(in awebview.wrapper.cpp.WebString cppObj)
    {
        if(!this._instance.refCountedStore.isInitialized){
            __ctor(ws.cppObj);
            return;
        }

        if(this._instance.refCountedStore.refCount > 1)
            this = this.dup;

        this.payload ~= cppObj;
    }


    void clear()
    {
        _instance.__dtor();
        assert(!_instance.refCountedStore.isInitialized);
    }


    bool opEquals(const WebString rhs) const nothrow @nogc
    { return this.payload.opEquals(rhs.payload); }

    bool opEquals(ref const WebString rhs) const nothrow @nogc
    { return this.payload.opEquals(rhs.payload); }

    bool opEquals(ref const WebStringCpp rhs) const nothrow @nogc
    { return this.payload.opEquals(rhs); }

    bool opEquals(Char)(const Char[] rhs) const
    { return this.payload.opEquals(rhs); }

    int opCmp(const WebString rhs) const nothrow @nogc
    { return this.payload.opCmp(rhs.payload); }

    int opCmp(ref const WebString rhs) const nothrow @nogc
    { return this.payload.opCmp(rhs.payload); }

    int opCmp(ref const WebStringCpp rhs) const nothrow @nogc
    { return this.payload.opCmp(rhs); }

    int opCmp(Char)(const Char[] rhs) const
    if(isSomeChar!Char)
    { return this.payload.opCmp(rhs); }


    const(wchar)[] toString() const nothrow @nogc
    { return this.data; }

  private:
    /// RefCountedNoGC!WebStringCpp _instance;
    Instance _instance;

    alias Instance = typeof(_dummyTypeCreate());

    static auto _dummyTypeCreate()
    {
        static struct R
        {
            RefCountedNoGC!WebStringCpp obj;
            alias obj this;
        }

        return R();
    }
}



struct WebStringCpp
{
    alias data this;    // const(wchar)[] data() const @property;

    this(const(char)[] str) nothrow @nogc
    in{
        assert(str.length <= uint.max);
    }
    body{
        WebStringMember.ctor(this.cppObj!false);
        WebStringMember.CreateFromUTF8(str.ptr, cast(uint)str.length, this.cppObj!false);
    }

    unittest
    {
        WebStringCpp ws = "foobar";
        assert(ws.data == "foobar");
    }


    this(const(wchar)[] str) nothrow @nogc
    in{
        assert(str.length <= uint.max);
    }
    body{
        WebStringMember.ctor(this.cppObj!false, cast(const(ushort)*)str.ptr, cast(uint)str.length);
    }


    this(const awebview.wrapper.cpp.WebString ws) nothrow @nogc
    {
        if(ws !is null)
            WebStringMember.ctor(this.cppObj!false, ws);
        else
            WebStringMember.ctor(this.cppObj!false);
    }


    this(this) nothrow @nogc
    {
        if(this.cppField.instance_ !is null){
            typeof(_field) f;
            WebStringCpp* vp = cast(WebStringCpp*)cast(void*)&f;
            WebStringMember.ctor(vp.cppObj!false, this.cppObj);
            this._field = vp._field;
        }
    }


    ~this() nothrow @nogc
    {
        if(this.cppField.instance_ !is null)
            WebStringMember.dtor(this.cppObj!false);
    }


    private
    ref inout(awebview.wrapper.cpp.WebString.Field)
        cppField() inout pure nothrow @trusted @property @nogc
    { return *cast(typeof(return)*)_field.ptr; }


    awebview.wrapper.cpp.WebString
        cppObj(bool withInitialize = true)() nothrow @trusted @property @nogc
    {
        typeof(return) o = cast(typeof(return))cast(void*)_field.ptr;

      static if(withInitialize)
        if(cppField.instance_ is null)
            WebStringMember.ctor(o);

        return o;
    }


    inout(awebview.wrapper.cpp.WebString)
        cppObj() inout pure nothrow @trusted @property @nogc
    {
        if(cppField.instance_ is null)
            return cast(typeof(return))cast(inout(void)*)(_emptyInstance._field.ptr);
        else
            return cast(typeof(return))cast(inout(void)*)_field.ptr;
    }


    WeakRef!WebStringCpp weakRef(this T)() inout pure nothrow @trusted @property @nogc
    {
        return refP!T(cast(T*)&this);
    }


    void opAssign()(auto ref const WebStringCpp str) nothrow @nogc
    {
        WebStringMember.opAssign(this.cppObj, str.cppObj);
    }


    void opAssign(Char)(const(Char)[] c) nothrow @nogc
    if(is(Char ==  char) || is(Char == wchar))
    {
        this.clear();
        this ~= c;
    }


    const(wchar)* ptr() const nothrow @property @nogc
    {
        return cast(const(wchar)*)WebStringMember.data(this.cppObj);
    }


    alias opDollar = length;

    size_t length() const nothrow @property @nogc
    {
        return WebStringMember.length(this.cppObj);
    }


    bool empty() const nothrow @property @nogc
    {
        return WebStringMember.IsEmpty(this.cppObj);
    }


    const(wchar)[] data() const nothrow @property @nogc
    {
        return this.ptr[0 .. this.length];
    }


    const(wchar)[] opSlice() const nothrow @property @nogc
    {
        return this.data;
    }


    void opOpAssign(string op : "~")(auto ref const WebStringCpp s) nothrow @nogc
    {
        WebStringMember.Append(this.cppObj, s.cppObj);
    }


    void opOpAssign(string op : "~", Char)(const(Char)[] str) nothrow @nogc
    if(is(Char == char) || is(Char == wchar))
    {
        auto ws = WebStringCpp(str);
        this.opOpAssign!"~"(ws);
    }


    void opOpAssign(string op : "~")(awebview.wrapper.cpp.WebString cppObj) nothrow @nogc
    {
        WebStringMember.Append(this.cppObj, cppObj);
    }


    void clear() nothrow @nogc
    {
        WebStringMember.Clear(this.cppObj);
    }


    bool opEquals()(auto ref const WebStringCpp rhs) const nothrow @nogc
    {
        return WebStringMember.opEquals(this.cppObj, rhs.cppObj);
    }


    bool opEquals(Char)(const Char[] rhs) const
    if(isSomeChar!Char)
    {
        static if(is(Char == wchar))
            return this.data == rhs;
        else
            return opCmp(rhs) == 0;
    }


    int opCmp()(auto ref const WebStringCpp rhs) const
    {
        return WebStringMember.opCmp(this.cppObj, rhs.cppObj);
    }


    int opCmp(Char)(const Char[] rhs) const
    if(isSomeChar!Char)
    {
        return cmp(this.data, rhs);
    }


    const(wchar)[] toString() const nothrow @nogc
    {
        return this.data;
    }


    static
    auto weakRef(HandleWS)(HandleWS ws) @trusted
    if(is(HandleWS : const(awebview.wrapper.cpp.WebString)))
    {
      static if(is(HandleWS == awebview.wrapper.cpp.WebString))
        WebStringCpp* wsp = cast(WebStringCpp*)cast(void*)ws;
      else static if(is(HandleWS == const(awebview.wrapper.cpp.WebString)))
        const(WebStringCpp)* wsp = cast(const(WebStringCpp)*)cast(const(void)*)ws;
      else
        immutable(WebStringCpp)* wsp = cast(immutable(WebStringCpp)*)cast(immutable(void)*)ws;

        return refP(wsp);
    }


  private:
    ubyte[awebview.wrapper.cpp.WebString.Field.sizeof] _field;

    static shared immutable(WebStringCpp*) _emptyInstance;

    shared static this()
    {
        WebStringCpp* s = new WebStringCpp;
        WebStringMember.ctor(s.cppObj!false);

        _emptyInstance = cast(immutable)s;  // s is unique
    }
}


unittest {
    WebStringCpp empty_;
    assert(empty_.length == 0);
    assert(empty_.empty);
    //assert(empty_.ptr is null);
    assert(empty_ == empty_);
    assert(empty_ == "");
    assert(empty_ == ""w);
    assert(empty_ == ""d);
    empty_ ~= "foobar";
    assert(empty_ == "foobar");
    empty_ ~= "ああああ";
    assert(empty_ == "foobarああああ");
}

unittest {
    import std.conv : to;

    wstring src = "オーサミウムｵｰｻﾐｳﾑおーさみうむ";
    WebStringCpp str = src;
    assert(str.length == src.length);
    assert(!str.empty);
    assert(str.ptr != src.ptr); // copy
    assert(str == src);
    assert(str.data == src);
    assert(str == to!string(src));
    assert(str[0 .. 3] == src[0 .. 3]);
    assert(str[0 .. $] == src[0 .. $]);

    WebStringCpp str2 = "foobar"w;
    assert(str2.length == 6);
    assert(!str2.empty);
    assert(str2[0 .. 3] == "foo");
    assert(str2[3 .. $] == "bar");
    assert(str2.front == 'f');

    str2 = str;
    assert(str2 == str);

    WebStringCpp str3 = str;
    assert(str3.ptr != str.ptr);
    assert(str3 == str);
}

unittest {
    WebStringCpp ws;
    auto r1 = ws.weakRef;
    auto r2 = ws.cppObj.weakRef!WebStringCpp;

    assert(ws.cppObj is r1.cppObj);
    assert(r1.cppObj is r2.cppObj);

    ws = "foobar";
    assert(ws.cppObj is r1.cppObj);
    assert(ws.cppObj is r2.cppObj);

    r1 ~= "foobar";
    assert(ws == "foobarfoobar");

    ws = WebStringCpp("f");
    assert(ws.cppObj is r1.cppObj);
    assert(ws.cppObj is r2.cppObj);

    ws.clear();
    assert(ws.cppObj is r1.cppObj);
    assert(ws.cppObj is r2.cppObj);
}
