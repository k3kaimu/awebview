module awebview.wrapper.resourceinterceptor;

import awebview.wrapper.webstring,
       awebview.wrapper.weburl,
       awebview.wrapper.cpp,
       awebview.wrapper.weakref;

import awebview.wrapper.webstring : WebString;
import awebview.wrapper.weburl : WebURL;

import std.conv : to;
import std.traits : isSomeString;
import core.exception;

struct UploadElement
{
    this(inout(CppObj) obj) inout pure nothrow @safe @nogc
    {
        _cppObj = obj;
    }


    inout(CppObj) cppObj() inout pure nothrow @safe @nogc @property
    {
        return _cppObj;
    }


    @property
    bool isFilePath() const nothrow @nogc
    {
        return UEM.IsFilePath(_cppObj);
    }


    @property
    bool isBytes() const nothrow @nogc
    {
        return UEM.IsBytes(_cppObj);
    }


    @property
    const(ubyte)[] bytes() const nothrow @nogc
    {
        return (cast(const(ubyte)*)UEM.bytes(_cppObj))[0 .. UEM.num_bytes(_cppObj)];
    }


    @property
    S filePath(S = string)() const nothrow @nogc
    {
        WebString str;
        UEM.file_path(_cppObj, str.cppObj);
        return str.to!string;
    }


  private:
    alias CppObj = Awesomium.UploadElement;
    alias UEM = Awesomium4D.UploadElementMember;

    CppObj _cppObj;
}


struct ResourceRequest
{
    this(inout(CppObj) cppObj) inout pure nothrow @safe @nogc
    {
        _cppObj = cppObj;
    }


    inout(CppObj) cppObj() inout pure nothrow @safe @nogc @property
    {
        return _cppObj;
    }


    void cancel() @nogc
    {
        RReqMmb.Cancel(_cppObj);
    }


    @property
    int originProcessId() const nothrow @nogc
    {
        return RReqMmb.origin_process_id(_cppObj);
    }


    @property
    int originRoutingId() const nothrow @nogc
    {
        return RReqMmb.origin_routing_id(_cppObj);
    }


    @property
    WebURL url() const nothrow @nogc
    {
        WebURL dst;
        RReqMmb.url(_cppObj, dst.cppObj);
        return dst;
    }


    @property
    S method(S = string)() const nothrow
    if(isSomeString!S)
    {
        WebStringCpp str;
        RReqMmb.method(_cppObj, str.cppObj);
        return str.to!S;
    }


    @property
    void method(S)(in S m) nothrow @nogc
    if(isSomeString!S)
    {
        auto ws = WebStringCpp(m);
        RReqMmb.set_method(_cppObj, m.cppObj);
    }


    @property
    S referrer(S = string)() const nothrow
    if(isSomeString!S)
    {
        WebStringCpp dst;
        RReqMmb.referrer(_cppObj, dst.cppObj);
        return dst.to!S;
    }


    @property
    void referrer(S)(in S s) nothrow @nogc
    {
        auto ws = WebStringCpp(s);
        RReqMmb.set_referrer(_cppObj, ws.cppObj);
    }


    @property
    S extraHandlers(S = string)() const nothrow
    {
        WebStringCpp dst;
        RReqMmb.extra_headers(_cppObj, dst.cppObj);
        return dst.to!S;
    }


    @property
    void extraHeaders(S)(in S s) nothrow @nogc
    if(isSomeString!S)
    {
        auto ws = WebStringCpp(s);
        RReqMmb.set_extra_headers(_cppObj, eh);
    }


    void appendExtraHeader(S)(in S name, in S value)
    if(isSomeString!S)
    {
        auto n = WebStringCpp(name),
             v = WebStringCpp(value);

        RReqMmb.AppendExtraHeader(_cppObj, n.cppObj, v.cppObj);
    }


    @property
    uint numUploadElements() const nothrow @nogc
    {
        return RReqMmb.num_upload_elements(_cppObj);
    }


    const(UploadElement) getUploadElement(uint idx) const nothrow @nogc
    {
        return const(UploadElement)(cast(const(Awesomium.UploadElement))RReqMmb.GetUploadElement(_cppObj, idx));
    }


    @property
    auto uploadElements() const nothrow @nogc
    {
        static struct UploadElementsResult()
        {
            @property
            const(UploadElement) front() const nothrow
            {
                if(this.length)
                    return _parent.getUploadElement(_sIdx);
                else
                    onRangeError();

                assert(0);
            }


            @property
            const(UploadElement) back() const nothrow
            {
                if(this.length)
                    return _parent.getUploadElement(_bIdx - 1);
                else
                    onRangeError();

                assert(0);
            }


            const(UploadElement) opIndex(size_t i) const nothrow
            {
                if(i < this.length)
                    return _parent.getUploadElement(_sIdx + i);
                else
                    onRangeError();

                assert(0);
            }


            void popFront() pure nothrow @safe @nogc
            {
                if(_sIdx != size_t.max) ++_sIdx;
            }


            void popBack() pure nothrow @safe @nogc
            {
                if(_bIdx) --_bIdx;
            }


            @property
            bool empty() const pure nothrow @safe @nogc
            {
                return _sIdx >= _bIdx;
            }


            UploadElementsResult save() const pure nothrow @safe @nogc
            {
                return this;
            }


            @property
            size_t length() const pure nothrow @safe @nogc
            {
                if(this.empty)
                    return 0;
                else
                    return _bIdx - _sIdx;
            }


            UploadElementsResult opSlice() const pure nothrow @safe @nogc
            {
                return this;
            }


            UploadElementsResult opSlice(size_t i, size_t j) const pure nothrow @safe
            {
                if(i > j || j > this.length)
                    onRangeError();
                else
                    return UploadElementsResult(_parent, _sIdx + i, _sIdx + j - i);

                assert(0);
            }


            alias opDollar = length;


          private:
            const(ResourceRequest) _parent;
            size_t _sIdx;
            size_t _bIdx;
        }


        return UploadElementsResult!()(this, 0, this.numUploadElements);
    }


    void clearUploadElements() nothrow @nogc
    {
        RReqMmb.ClearUploadElements(_cppObj);
    }


    void appendUploadFilePath(S)(in S path) nothrow @nogc
    if(isSomeString!S)
    {
        auto ws = WebStringCpp(path);
        RReqMmb.AppendUploadFilePath(_cppObj, ws.cppObj);
    }


    void appendUploadBytes(in ubyte[] bytes) nothrow @nogc
    {
        RReqMmb.AppendUploadBytes(_cppObj, cast(const(char)*)(bytes.ptr), bytes.length);
    }


    @property
    void ignoreDataSourceHandler(bool ignore) nothrow @nogc
    {
        RReqMmb.set_ignore_data_source_handler(_cppObj, ignore);
    }


  private:
    alias RReqMmb = Awesomium4D.ResourceRequestMember;
    alias CppObj = Awesomium.ResourceRequest;

    CppObj _cppObj;
}


struct ResourceResponse
{
    this(inout(CppObj) cppObj) inout
    {
        _cppObj = cppObj;
    }


    this(S)(const(ubyte)[] buffer, in S mimeType)
    {
        auto ws = WebStringCpp(mimeType);
        this(Awesomium4D.ResourceResponseMember.Create(buffer.length, buffer.ptr, ws.cppObj));
    }


    this(S)(in S path)
    {
        auto ws = WebStringCpp(path);
        this(Awesomium4D.ResourceResponseMember.Create(ws.cppObj));
    }


    inout(CppObj) cppObj() inout pure nothrow @safe @nogc @property
    {
        return _cppObj;
    }


  private:
    alias CppObj = Awesomium.ResourceResponse;

    CppObj _cppObj;
}


final class ResourceInterceptorCpp
{
    this()
    {
        _cppObj = RIM.newCtor();
    }


    //~this()
    //{
    //    RIM.deleteDtor(_cppObj);
    //    _cppObj = null;
    //}


    inout(CppObj) cppObj() inout pure nothrow @safe @nogc @property
    {
        return _cppObj;
    }


    ResourceResponse onRequest(ResourceRequest req)
    {
        return ResourceResponse(RIM.OnRequest(_cppObj, req.cppObj));
    }


    bool onFilterNavigation(S)(int opid, int orid, in S method, WebURL url, bool isMainFrame)
    if(isSomeString!S)
    {
        WebStringCpp m = method;

        return RIM.OnFilterNavigation(_cppObj, opid, orid, m.cppObj, url.cppObj, isMainFrame);
    }


    void onWillDownload(int opid, int orid, WebURL url)
    {
        return RIM.OnWillDownload(_cppObj, opid, orid, url.cppObj);
    }


  private:
    alias CppObj = Awesomium.ResourceInterceptor;
    alias RIM = Awesomium4D.ResourceInterceptorMember;

    CppObj _cppObj;
}


class ResourceInterceptor : IResourceInterceptorD
{
    this()
    {
        _cppRI = new ResourceInterceptorCpp();

        auto id = MemoryManager.instance.register(cast(void*)this);
        _d2cppObj = Awesomium4D.ResourceInterceptorD2CppMember.newCtor(this, id);
    }


    //~this()
    //{
    //    ResourceInterceptorD2CppMember.deleteDtor(_d2cppObj);
    //    _d2cppObj = null;
    //}


    final
    inout(D2CppObj) cppObj() inout pure nothrow @safe @nogc @property
    {
        return _d2cppObj;
    }


    ResourceResponse onRequest(ResourceRequest req)
    {
        return _cppRI.onRequest(req);
    }


    bool onFilterNavigation(int opid, int orid, const(char)[] method, WebURL url, bool is_main_frame)
    {
        return _cppRI.onFilterNavigation(opid, orid, method, url, is_main_frame);
    }


    void onWillDownload(int opid, int orid, WebURL url)
    {
        return _cppRI.onWillDownload(opid, orid, url);
    }


  extern(C++)
  {
    Awesomium.ResourceResponse onRequest(Awesomium.ResourceRequest req)
    {
        return this.onRequest(ResourceRequest(req)).cppObj;
    }


    bool onFilterNavigation(int opid, int orid,
                            const(Awesomium.WebString) method,
                            const(Awesomium.WebURL) url,
                            bool is_main_frame)
    {
        WebURL u = url;
        return this.onFilterNavigation(opid, orid, method.weakRef!WebStringCpp.to!string, u, is_main_frame);
    }


    void onWillDownload(int opid, int orid,
                        const(Awesomium.WebURL) url)
    {
        WebURL u = url;
        this.onWillDownload(opid, orid, u);
    }
  }


  private:
    alias D2CppObj = Awesomium4D.ResourceInterceptorD2Cpp;

    ResourceInterceptorCpp _cppRI;
    D2CppObj _d2cppObj;
}
