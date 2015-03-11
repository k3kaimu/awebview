module awebview.wrapper.jsarray;

import std.algorithm;
import std.format;

import awebview.wrapper.cpp;
import awebview.wrapper.jsvalue : JSValue;
import awebview.wrapper.constants;

import carbon.nonametype;
import carbon.templates;
import carbon.memory;


struct JSArray
{
    alias PayloadType(This) = typeof(this.init.payload);


    @property
    ref JSArrayCpp payload() nothrow @nogc
    {
        if(!_instance.refCountedStore.isInitialized)
            __ctor(cast(CppObj)null);

        return _instance.refCountedPayload;
    }


    @property
    ref inout(JSArrayCpp) payload(this T)() inout nothrow @nogc
    if(is(T == const) || is(T == immutable))
    {
        if(_instance.refCountedStore.isInitialized)
            return *cast(typeof(return)*)&(this._instance.refCountedPayload());
        else
            return *cast(typeof(return)*)JSArrayConsts._emptyInstance;
    }


    this(size_t n) nothrow @nogc
    in {
        assert(n <= uint.max);
    }
    body {
        _instance = Instance(RefCountedNoGC!JSArrayCpp(n));
    }


    this(in awebview.wrapper.cpp.JSArray cppInst) nothrow @nogc
    {
        _instance = Instance(RefCountedNoGC!JSArrayCpp(cppInst));
    }


    this(in awebview.wrapper.jsvalue.JSValue[] arr) nothrow @nogc
    in {
        assert(arr.length <= uint.max);
    }
    body {
        _instance = Instance(RefCountedNoGC!JSArrayCpp(arr));
    }


    this(E)(in E[] arr) nothrow @nogc
    if(is(typeof(awebview.wrapper.jsvalue.JSValue(arr[0]))))
    in {
        assert(arr.length <= uint.max);
    }
    body {
        _instance = Instance(RefCountedNoGC!JSArrayCpp(arr));
    }


    JSArray dup() const nothrow @nogc
    {
        return JSArray(this.cppObj);
    }


    inout(CppObj) cppObj(this T)() inout nothrow @nogc @property
    {
        return cast(typeof(return))(cast(T*)&this).payload.cppObj;
    }


    uint length() const nothrow @nogc @property
    { return payload.length; }

    alias opDollar = length;

    uint capacity() const nothrow @nogc @property
    {
        if(_instance.refCountedStore.refCount > 1)
            return 0;
        else
            return payload.capacity;
    }

    auto ref opIndex(size_t idx) nothrow @nogc
    in{ assert(idx < this.length); }
    body { return payload[cast(uint)idx]; }

    auto ref opIndex(size_t idx) const nothrow @nogc
    in{ assert(idx < this.length); }
    body { return payload[cast(uint)idx]; }


    void pushBack()(auto ref const JSValue item) nothrow @nogc
    {
        if(!this._instance.refCountedStore.isInitialized)
            this.payload.__ctor(cast(awebview.wrapper.cpp.JSArray)null);

        if(this._instance.refCountedStore.refCount > 1)
            this = this.dup;

        this.payload.pushBack(item);
    }


    void opOpAssign(string op : "~")(auto ref const JSValue item) nothrow @nogc
    {
        pushBack(item);
    }


    void popBack() nothrow @nogc
    {
        if(!this._instance.refCountedStore.isInitialized)
            this.payload.__ctor(cast(awebview.wrapper.cpp.JSArray)null);

        if(this._instance.refCountedStore.refCount > 1)
            this = this.dup;

        this.payload.popBack();
    }


    void insert()(auto ref const JSValue item, size_t idx) nothrow @nogc
    in { assert(idx < this.length); }
    body {
        if(!this._instance.refCountedStore.isInitialized)
            this.payload.__ctor(cast(awebview.wrapper.cpp.JSArray)null);

        if(this._instance.refCountedStore.refCount > 1)
            this = this.dup;

        this.payload.insert(item, idx);
    }


    void removeAt(size_t idx) nothrow @nogc
    in { assert(idx < this.length); }
    body {
        if(!this._instance.refCountedStore.isInitialized)
            this.payload.__ctor(cast(awebview.wrapper.cpp.JSArray)null);

        if(this._instance.refCountedStore.refCount > 1)
            this = this.dup;

        this.payload.removeAt(cast(uint)idx);
    }


    void clear() nothrow @nogc
    {
        callAllDtor(this.payload);
        assert(!this._instance.refCountedStore.isInitialized);
    }


    int opApply(int delegate(ref size_t, ref awebview.wrapper.jsvalue.JSValue) dg)
    { return payload.opApply(dg); }

    int opApply(int delegate(ref size_t, ref const(awebview.wrapper.jsvalue.JSValue)) dg) const
    { return payload.opApply(dg); }

    int opApply(int delegate(ref awebview.wrapper.jsvalue.JSValue) dg)
    { return payload.opApply(dg); }

    int opApply(int delegate(ref const(awebview.wrapper.jsvalue.JSValue)) dg) const
    { return payload.opApply(dg); }


    void toString(scope void delegate(const(char)[]) sink) const
    {
        payload.toString(sink);
    }


  private:
    Instance _instance;

    static auto _dummyTypeCreate()
    {
        static struct Dummy 
        {
            RefCountedNoGC!JSArrayCpp obj;
            alias obj this;
        }

        return Dummy();
    }

    alias Instance = typeof(_dummyTypeCreate());
    alias CppObj = awebview.wrapper.cpp.JSArray;
}


struct JSArrayCpp
{
    this(size_t n) nothrow @nogc
    in { assert(n <= uint.max); }
    body {
        JSArrayMember.ctor(this.cppObj!false, cast(uint)n);
    }


    this(in awebview.wrapper.cpp.JSArray cppInst) nothrow @nogc
    {
        if(cppInst)
            JSArrayMember.ctor(this.cppObj!false, cppInst);
        else
            JSArrayMember.ctor(this.cppObj!false);
    }


    this(in awebview.wrapper.jsvalue.JSValue[] arr) nothrow @nogc
    in { assert(arr.length <= uint.max); }
    body {
        this(arr.length);

        foreach(i, ref e; arr)
            this[i] = e;
    }


    this(E)(in E[] arr) nothrow @nogc
    if(is(typeof(awebview.wrapper.jsvalue.JSValue(arr[0]))))
    in { assert(arr.length <= uint.max); }
    body {
        this(arr.length);

        foreach(i, const ref e; arr)
            this[i] = awebview.wrapper.jsvalue.JSValue(e);
    }


    this(this) nothrow @nogc
    {
        if(this.isInitialized)
        {
            typeof(_field) f;
            JSArrayCpp* p = cast(JSArrayCpp*)f.ptr;
            JSArrayMember.ctor(p.cppObj!false, this.cppObj!false);
            this._field = p._field;
        }
    }


    ~this() nothrow @nogc
    {
        if(this.isInitialized)
            JSArrayMember.dtor(this.cppObj!false);
    }


    private
    ref inout(CppObj.Field) cppField() inout pure nothrow @trusted @property @nogc
    {
        return *cast(typeof(return)*)_field.ptr;
    }


    private
    bool isInitialized() const pure nothrow @safe @nogc @property
    { return cppField.vector_ !is null; }


    CppObj cppObj(bool withInitialize = true)() nothrow @trusted @property @nogc
    {
        CppObj ret = cast(CppObj)cast(void*)&_field;

      static if(withInitialize)
        if(!this.isInitialized)
            JSArrayMember.ctor(ret);

        return ret;
    }


    inout(CppObj) cppObj() inout nothrow @trusted @property @nogc
    {
        if(!this.isInitialized)
            return cast(inout(CppObj))cast(inout(void)*)&(JSArrayConsts._emptyInstance._field);
        else
            return cast(inout(CppObj))cast(inout(void)*)&_field;
    }


    uint length() const nothrow @nogc @property
    {
        return JSArrayMember.size(this.cppObj);
    }


    alias opDollar = length;


    uint capacity() const nothrow @nogc @property
    {
        return JSArrayMember.capacity(this.cppObj);
    }


    ref awebview.wrapper.jsvalue.JSValue opIndex(size_t idx) nothrow @nogc
    in{ assert(idx <= uint.max); }
    body {
        awebview.wrapper.cpp.JSValue obj = JSArrayMember.At(this.cppObj, cast(uint)idx);
        return *cast(awebview.wrapper.jsvalue.JSValue*)cast(void*)obj;
    }


    ref const(awebview.wrapper.jsvalue.JSValue) opIndex(size_t idx) const nothrow @nogc
    in { assert(idx <= uint.max); }
    body {
        const awebview.wrapper.cpp.JSValue obj = JSArrayMember.At(this.cppObj, cast(uint)idx);
        return *cast(const(awebview.wrapper.jsvalue.JSValue)*)cast(const(void)*)obj;
    }


    void pushBack()(auto ref const awebview.wrapper.jsvalue.JSValue item) nothrow @nogc
    {
        JSArrayMember.Push(this.cppObj, item.cppObj);
    }


    void opOpAssign(string op : "~")(auto ref const awebview.wrapper.jsvalue.JSValue item) nothrow @nogc
    {
        pushBack(/*forward!*/item);
    }


    void popBack() nothrow @nogc
    {
        JSArrayMember.Pop(this.cppObj);
    }


    void insert()(auto ref const awebview.wrapper.jsvalue.JSValue item, uint idx) nothrow @nogc
    {
        JSArrayMember.Insert(this.cppObj, item.cppObj, idx);
    }


    void removeAt(uint idx) nothrow @nogc
    {
        JSArrayMember.Erase(this.cppObj, idx);
    }


    void clear() nothrow @nogc
    {
        JSArrayMember.Clear(this.cppObj);
    }


    int opApply(int delegate(ref size_t, ref awebview.wrapper.jsvalue.JSValue) dg)
    {
        int result;

        foreach(ref size_t i; 0 .. this.length){
            result = dg(i, this[i]);
            if(result)
                break;
        }

        return result;
    }


    int opApply(int delegate(ref size_t, ref const(awebview.wrapper.jsvalue.JSValue)) dg) const
    {
        int result;

        foreach(ref size_t i; 0 .. this.length){
            result = dg(i, this[i]);
            if(result)
                break;
        }

        return result;
    }


    int opApply(int delegate(ref awebview.wrapper.jsvalue.JSValue) dg)
    {
        int result;

        foreach(size_t i; 0 .. this.length){
            result = dg(this[i]);
            if(result)
                break;
        }

        return result;
    }


    int opApply(int delegate(ref const(awebview.wrapper.jsvalue.JSValue)) dg) const
    {
        int result;

        foreach(size_t i; 0 .. this.length){
            result = dg(this[i]);
            if(result)
                break;
        }

        return result;
    }


    @property
    auto weakRef(this This)() inout nothrow @nogc
    {
        return JSArrayRange!This(cast(This*)&this, 0, this.length);
    }


    void toString(scope void delegate(const(char)[]) sink) const
    {
        sink("[");
        foreach(i; 0 .. this.length){
            formattedWrite(sink, "%s", this[i]);
            if(i != this.length - 1)
                sink(", ");
        }
        sink("]");
    }


    static
    auto weakRef(HandleJSArray)(HandleJSArray ws)
    if(is(HandleJSArray : const(awebview.wrapper.cpp.JSArray)))
    {
      static if(is(HandleJSArray == awebview.wrapper.cpp.JSArray))
        JSArrayCpp* wsp = cast(JSArrayCpp*)cast(void*)ws;
      else static if(is(HandleJSArray == const(awebview.wrapper.cpp.JSArray)))
        const(JSArrayCpp)* wsp = cast(const(JSArrayCpp)*)cast(const(void)*)ws;
      else
        immutable(JSArrayCpp)* wsp = cast(immutable(JSArrayCpp)*)cast(immutable(void)*)ws;

        return refP(wsp);
    }


  private:
    alias CppObj = awebview.wrapper.cpp.JSArray;
    ubyte[CppObj.Field.sizeof] _field;
}


unittest
{
    auto arr = JSArrayCpp(8);
    assert(arr.length == 8);

    foreach(ref awebview.wrapper.jsvalue.JSValue e; arr)
        assert(e.isUndefined);

    arr[0] = awebview.wrapper.jsvalue.JSValue(12);
    assert(arr[0].get!int == 12);

    arr ~= awebview.wrapper.jsvalue.JSValue(13);
    assert(arr.length == 9);
    assert(arr[$-1].get!int == 13);

    foreach(ref const awebview.wrapper.jsvalue.JSValue e; arr)
        assert(e.isUndefined || e.isNumber);
}


unittest
{
    import std.range;

    JSArrayCpp arr = ["foo", "bar", "hoge"];
    auto arrRef = arr.weakRef;
    static assert(isInputRange!(typeof(arrRef)));
}


private struct JSArrayRange(WRJSArray)
{
  @nogc:
  nothrow:
    @property
    auto ref front() inout nothrow @nogc { return (*_arr)[_b]; }

    void popFront() pure nothrow @nogc @safe { ++_b; }

    @property
    auto ref back() inout nothrow @nogc { return (*_arr)[_e-1]; }

    void popBack() pure nothrow @nogc @safe { --_e; }

    @property
    bool empty() const nothrow @nogc @safe { return _b >= _e; }

    @property
    size_t length() const pure nothrow @nogc @safe { return _e - _b; }

    alias opDollar = length;

    auto ref opIndex(size_t i) inout nothrow @nogc
    in{ assert(i < this.length); }
    body{ return (*_arr)[_b + i]; }

    typeof(this) opSlice() pure nothrow @safe @nogc { return this; }

    typeof(this) opSlice(size_t a, size_t b) pure nothrow @safe @nogc
    in{
        assert(a <= b);
        assert(b <= this.length);
    }
    body{
        typeof(this) dst = this;
        dst._b += a;
        dst._e -= this.length - b;
        return dst;
    }

    WRJSArray* _arr;
    ref inout(WRJSArray) getArray() inout pure nothrow @safe @nogc @property
    { return *_arr; }

    alias getArray this;

  private:
    size_t _b;
    size_t _e;
}
