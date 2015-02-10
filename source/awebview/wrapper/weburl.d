module awebview.wrapper.weburl;

import awebview.wrapper.cpp;
import awebview.wrapper.webstring : WebStringCpp, WebString;
import awebview.wrapper.weakref;

import carbon.nonametype;
import carbon.memory;


struct WebURL
{
    alias PayloadType(This) = typeof(This.init.payload);


    @property
    ref WebURLCpp payload() nothrow @nogc
    {
        if(!_instance.refCountedStore.isInitialized)
            __ctor(cast(awebview.wrapper.cpp.WebURL)null);

        return _instance.refCountedPayload;
    }


    @property
    ref inout(WebURLCpp) payload(this T)() inout nothrow @nogc
    {
        if(this._instance.refCountedStore.isInitialized)
            return *cast(typeof(return)*)&(this._instance.refCountedPayload());
        else
            return *cast(typeof(return)*)WebURLCpp._emptyInstance;
    }


    this(Char)(in Char[] url) @nogc nothrow
    if(is(typeof(WebStringCpp(url)) == WebStringCpp))
    {
        _instance = Instance(RefCountedNoGC!WebURLCpp(url));
    }


    this(in WebString str) @nogc nothrow
    {
        _instance.obj = str.payload;
    }


    this(const ref WebStringCpp str) @nogc nothrow
    {
        _instance = Instance(RefCountedNoGC!WebURLCpp(str));
    }


    this(const awebview.wrapper.cpp.WebString cppws) @nogc nothrow
    {
        _instance = Instance(RefCountedNoGC!WebURLCpp(cppws));
    }


    this(const awebview.wrapper.cpp.WebURL cppwurl) @nogc nothrow
    {
        _instance = Instance(RefCountedNoGC!WebURLCpp(cppwurl));
    }


    @property
    awebview.wrapper.cpp.WebURL cppObj() nothrow @nogc
    {
        return payload.cppObj;
    }


    @property
    inout(const(awebview.wrapper.cpp.WebURL)) cppObj(this T)() inout nothrow @nogc
    {
        return this.payload.cppObj;
    }


    @property
    WeakRef!(PayloadType!This) weakRef(this This)() inout nothrow @trusted @nogc
    {
        alias WCpp = PayloadType!This;
        return refP!WCpp(cast(WCpp*)&(cast(This*)&this).payload());
    }


    void opAssign(WebURL url)
    {
        _instance.obj = url.payload;
    }


    void opAssign(ref const WebURLCpp url)
    {
        this = WebURL(url.cppObj);
    }


    void opAssign(Char)(in Char[] str)
    if(is(typeof(WebString(str)) == WebString))
    {
        WebURLCpp url = WebString(str);
        this = url;
    }


    bool isValid() const @property nothrow @nogc
    {
        return payload.isValid;
    }


    bool empty() const @property nothrow @nogc
    {
        return payload.empty;
    }


    WebString spec() const @property nothrow @nogc
    {
        return payload.spec;
    }


    WebString scheme() const @property nothrow @nogc
    {
        return payload.scheme;
    }


    WebString username() const @property nothrow @nogc
    {
        return payload.username;
    }


    WebString password() const @property nothrow @nogc
    {
        return payload.password;
    }


    WebString host() const @property nothrow @nogc
    {
        return payload.host;
    }


    WebString port() const @property nothrow @nogc
    {
        return payload.port;
    }


    WebString path() const @property nothrow @nogc
    {
        return payload.path;
    }


    WebString query() const @property nothrow @nogc
    {
        return payload.query;
    }


    WebString anchor() const @property nothrow @nogc
    {
        return payload.anchor;
    }


    WebString filename() const @property nothrow @nogc
    {
        return payload.filename;
    }


    bool opEquals()(auto ref const WebURL rhs) const
    {
        return this.payload == rhs.payload;
    }


    bool opEquals(ref const WebURLCpp rhs) const
    {
        return this.payload == rhs;
    }


    bool opEquals(Char)(in Char[] rhs) const
    if(is(typeof(WebString(rhs)) == WebString))
    {
        WebURLCpp rhsURL = rhs;
        return this == rhsURL;
    }


    int opCmp()(auto ref const WebURL rhs) const
    {
        return this.payload.opCmp(rhs.payload);
    }


    int opCmp(ref const WebURLCpp rhs) const
    {
        return this.payload.opCmp(rhs);
    }


    int opCmp(Char)(in Char[] rhs) const
    {
        WebURLCpp url = rhs;
        return this.payload.opCmp(url);
    }


  private:
    /// RefCountedNoGC!WebURLCpp _instance;
    Instance _instance;

    alias Instance = typeof(_dummyTypeCreate());

    static auto _dummyTypeCreate()
    {
        static struct R
        {
            RefCountedNoGC!WebURLCpp obj;
            alias obj this;
        }

        return R();
    }
}

struct WebURLCpp
{
  nothrow @nogc
  {
    this(Char)(in Char[] url)
    if(is(typeof(WebStringCpp(url)) == WebStringCpp))
    {
        WebStringCpp str = url;
        this(str);
    }


    this(in WebString str)
    {
        this(str.cppObj);
    }


    this(const ref WebStringCpp str)
    {
        this(str.cppObj);
    }


    this(const awebview.wrapper.cpp.WebString cppws)
    {
        WebURLMember.ctor(this.cppObj!false, cppws);
    }


    this(const awebview.wrapper.cpp.WebURL cppwurl)
    {
        if(cppwurl is null)
            WebURLMember.ctor(this.cppObj!false);
        else
            WebURLMember.ctor(this.cppObj!false, cppwurl);
    }


    this(this)
    {
        if(this.cppField.instance_ !is null){
            typeof(_field) f;
            WebURLCpp* vp = cast(WebURLCpp*)cast(void*)&f;
            WebURLMember.ctor(vp.cppObj!false, this.cppObj);
            this._field = vp._field;
        }
    }


    ~this()
    {
        if(cppField.instance_ !is null)
            WebURLMember.dtor(this.cppObj!false);
    }


    private
    ref inout(awebview.wrapper.cpp.WebURL.Field)
        cppField() inout pure nothrow @trusted @property @nogc
    { return *cast(typeof(return)*)_field.ptr; }


    CppWebURL cppObj(bool withInitialize = true)() nothrow @trusted @property @nogc
    {
        CppWebURL ret = cast(CppWebURL)cast(void*)_field.ptr;

      static if(withInitialize)
        if(cppField.instance_ is null)
            WebURLMember.ctor(ret);

        return ret;
    }


    inout(CppWebURL) cppObj() inout nothrow @trusted @property @nogc
    {
        if(cppField.instance_ is null)
            return cast(inout(CppWebURL))cast(inout(void)*)&_emptyInstance._field;
        else
            return cast(inout(CppWebURL))cast(inout(void)*)&_field;
    }


    auto weakRef(this T)() pure nothrow @trusted @property @nogc
    {
        return refP!T(cast(T*)&this);
    }


    void opAssign()(auto ref const WebURLCpp url)
    {
        WebURLMember.opAssign(this.cppObj, url.cppObj);
    }


    void opAssign(Char)(in Char[] str)
    if(is(typeof(WebString(str)) == WebString))
    {
        WebURLCpp url = WebString(str);
        this = url;
    }


    bool isValid() const @property
    {
        return WebURLMember.IsValid(this.cppObj);
    }


    bool empty() const @property
    {
        return WebURLMember.IsEmpty(this.cppObj);
    }


    WebString getStringProperty(alias f)() const @property
    {
        WebString str;
        f(this.cppObj, str.cppObj);
        return str;
    }


    alias spec = getStringProperty!(WebURLMember.spec);
    alias scheme = getStringProperty!(WebURLMember.scheme);
    alias username = getStringProperty!(WebURLMember.username);
    alias password = getStringProperty!(WebURLMember.password);
    alias host = getStringProperty!(WebURLMember.host);
    alias port = getStringProperty!(WebURLMember.port);
    alias path = getStringProperty!(WebURLMember.path);
    alias query = getStringProperty!(WebURLMember.query);
    alias anchor = getStringProperty!(WebURLMember.anchor);
    alias filename = getStringProperty!(WebURLMember.filename);

  }

    bool opEquals()(auto ref const WebURLCpp rhs) const
    {
        return WebURLMember.opEquals(this.cppObj, rhs.cppObj);
    }


    bool opEquals(Char)(in Char[] rhs) const
    if(is(typeof(WebString(rhs)) == WebString))
    {
        WebURLCpp rhsURL = rhs;
        return this == rhsURL;
    }


    int opCmp()(auto ref const WebURLCpp rhs) const
    {
        return WebURLMember.opCmp(this.cppObj, rhs.cppObj);
    }


    static
    auto weakRef(H)(H handle) @trusted
    if(is(H : const(awebview.wrapper.cpp.WebURL)))
    {
      static if(is(H == awebview.wrapper.cpp.WebURL))
        WebURLCpp* p = cast(WebURLCpp*)cast(void*)handle;
      else static if(is(H == const(awebview.wrapper.cpp.WebURL)))
        const(WebURLCpp)* p = cast(const(WebURLCpp*))cast(void*)handle;
      else
        immutable(WebURLCpp)* p = cast(immutable(WebURLCpp)*)cast(void*)handle;

        return refP(p);
    }


  private:
    alias CppWebURL = awebview.wrapper.cpp.WebURL;
    ubyte[CppWebURL.Field.sizeof] _field;

    static shared immutable(WebURLCpp*) _emptyInstance;

    shared static this()
    {
        WebURLCpp* p = new WebURLCpp;
        WebURLMember.ctor(p.cppObj!false);
        _emptyInstance = cast(immutable)p;
    }
}


unittest
{
    WebURL empty_;
    assert(empty_ == empty_);
    assert(!empty_.isValid);
    assert(empty_.empty);
    assert(empty_ == "");
}


unittest
{
    WebURL url = "http://www.google.com";
    assert(url.isValid);

    url = "foo";
    assert(!url.isValid);
    url = "file://foo/foo.txt";
    assert(url.isValid);
    assert(url.filename == "foo.txt");

    WebURL url2 = url;
    assert(url2.cppObj is url.cppObj);  // reference copy
    assert(url2 == url);
}


unittest
{
    WebURLCpp url;

    auto wr1 = url.weakRef;
    auto wr2 = url.cppObj.weakRef!WebURLCpp;
    assert(url.cppObj is wr1.cppObj);
    assert(url.cppObj is wr2.cppObj);

    url = "file://foo/foo.txt";
    assert(url.cppObj is wr1.cppObj);
    assert(url.cppObj is wr2.cppObj);
}
