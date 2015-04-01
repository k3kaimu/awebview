/**
Awesomium4D

Awesomium's version is v1.7.5.0 .

Licence: NYSL
Author: Kazuki Komatsu
*/

#include <new>

#include <Awesomium/BitmapSurface.h>
#include <Awesomium/ChildProcess.h>
#include <Awesomium/DataPak.h>
#include <Awesomium/DataSource.h>
#include <Awesomium/JSArray.h>
#include <Awesomium/JSObject.h>
#include <Awesomium/JSValue.h>
#include <Awesomium/Platform.h>
#include <Awesomium/PrintConfig.h>
#include <Awesomium/ResourceInterceptor.h>
#include <Awesomium/STLHelpers.h>
#include <Awesomium/Surface.h>
#include <Awesomium/WebConfig.h>
#include <Awesomium/WebCore.h>
#include <Awesomium/WebKeyboardCodes.h>
#include <Awesomium/WebKeyboardEvent.h>
#include <Awesomium/WebMenuItem.h>
#include <Awesomium/WebPreferences.h>
#include <Awesomium/WebSession.h>
#include <Awesomium/WebString.h>
#include <Awesomium/WebStringArray.h>
#include <Awesomium/WebTouchEvent.h>
#include <Awesomium/WebURL.h>
#include <Awesomium/WebView.h>
#include <Awesomium/WebViewListener.h>

#include <stdint.h>
#include <iostream>

/**
MemoryManager
*/
namespace Awesomium4D {

void deleteFromMemoryManager(uint64_t id);

}

/**
BitmapSurface.h
*/

namespace Awesomium4D {
using namespace Awesomium;

namespace BitmapSurfaceMember{

size_t sizeOfInstance()
{ return sizeof(BitmapSurface); }

void ctor(BitmapSurface * p, int width, int height)
{ new(p) BitmapSurface(width, height); }

BitmapSurface* newCtor(int width, int height)
{ return new BitmapSurface(width, height); }

void dtor(BitmapSurface * p)
{ p->~BitmapSurface(); }

void deleteDtor(BitmapSurface * p)
{ delete p; }

const unsigned char* buffer(BitmapSurface const * const p) 
{ return p->buffer(); }

int width(BitmapSurface const * const p)
{ return p->width(); }

int height(BitmapSurface const * const p)
{ return p->height(); }

int row_span(BitmapSurface const * const p)
{ return p->row_span(); }

void set_is_dirty(BitmapSurface * p, bool is_dirty)
{ p->set_is_dirty(is_dirty); }

bool is_dirty(BitmapSurface const * const p)
{ return p->is_dirty(); }

void CopyTo(BitmapSurface const * const p, unsigned char* dest_buffer,
                                     int dest_row_span,
                                     int dest_depth,
                                     bool convert_to_rgba,
                                     bool flip_y)
{ p->CopyTo(dest_buffer, dest_row_span, dest_depth, convert_to_rgba, flip_y); }

bool SaveToPNG(BitmapSurface const * const p, Awesomium::WebString const * const file_path,
                                        bool preserve_transparency)
{ return p->SaveToPNG(*file_path, preserve_transparency); }

unsigned char GetAlphaAtPoint(BitmapSurface const * const p, int x, int y)
{ return p->GetAlphaAtPoint(x, y); }

void Paint(BitmapSurface * p, unsigned char* src_buffer,
                              int src_row_span,
                              Awesomium::Rect const * src_rect,
                              Awesomium::Rect const * dest_rect)
{ p->Paint(src_buffer, src_row_span, *src_rect, *dest_rect); }

void Scroll(BitmapSurface * p, int dx, int dy, Awesomium::Rect const * clip_rect)
{ p->Scroll(dx, dy, *clip_rect); }

}   // BitmapSurfaceMember


namespace BitmapSurfaceFactoryMember{

size_t sizeOfInstance()
{ return sizeof(BitmapSurfaceFactory); }

void ctor(BitmapSurfaceFactory * p)
{  new(p) BitmapSurfaceFactory(); }

BitmapSurfaceFactory * newCtor()
{ return new BitmapSurfaceFactory(); }

void dtor(BitmapSurfaceFactory * p)
{ p->~BitmapSurfaceFactory(); }

void deleteDtor(BitmapSurfaceFactory * p)
{ delete p; }

Surface * CreateSurface(BitmapSurfaceFactory * p, WebView * view, int width, int height)
{ return p->CreateSurface(view, width, height); }

void DestroySurface(BitmapSurfaceFactory * p, Surface* surface)
{ p->DestroySurface(surface); }

}   // BitmapSurfaceFactoryMember

}   // Awesomium4D


/**
ChildProcess.h
*/

// no class in ChildProcess.h

/**
DataPak.h
*/

namespace Awesomium4D {
using namespace Awesomium;

bool WriteDataPak(WebString const * const out_file,
                  WebString const * const in_dir,
                  WebString const * const ignore_ext,
                  unsigned short * p_num_w)
{ return Awesomium::WriteDataPak(*out_file, *in_dir, *ignore_ext, *p_num_w); }

namespace DataPakSourceMember {

size_t sizeOfInstance()
{ return sizeof(DataPakSource); }

void ctor(DataPakSource * p, WebString const * const pak_path)
{ new(p) DataPakSource(*pak_path); }

DataPakSource * newCtor(WebString const * const path)
{ return new DataPakSource(*path); }

void dtor(DataPakSource * p)
{ p->~DataPakSource(); }

void deleteDtor(DataPakSource * p)
{ delete p; }

void OnRequest(DataPakSource * p, int request_id,
               ResourceRequest const * const request,
               WebString const * const path)
{ p->OnRequest(request_id, *request, *path); }

}   // namespace DataPackSourceMember
}   // namespace Awesomium4D


/**
DataSource.h
*/

namespace Awesomium4D {
using namespace Awesomium;

/*
class IDataSourceD
{
  public:
    virtual void onRequest(int, ResourceRequest const * const, WebString const * const) = 0;
    virtual void sendSession(int, unsigned int, unsigned char const *, WebString const * const) = 0;
};

class DataSourceD2Cpp : public DataSource
{
  public:
    DataSourceD2Cpp(IDataSourceD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~DataSourceD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnRequest(int reqId, const ResourceRequest& request, const WebString& path)
    { _p->onRequest(reqId, &request, &path); }

    void SendResponse(int reqId, unsigned int bufs, const unsigned char* buf, const WebString& mt)
    { _p->sendSession(reqId, bufs, buf, &mt); }

  private:
    IDataSourceD *_p;
    uint64_t _mid;    // MemoryManaged ID
};


namespace DataSourceD2CppMember {
DataSourceD2Cpp * newCtor(IDataSourceD * di, uint64_t mid) { return new DataSourceD2Cpp(di, mid); }
void deleteDtor(DataSourceD2Cpp * p) { delete p; }
}
*/

namespace DataSourceMember {

/*
DataSource has a pure virtual method `On Request`.
So it shouldn't have any ctor and sizeof.
*/

void dtor(DataSource * p)
{ p->~DataSource(); }

void deleteDtor(DataSource * p)
{ delete p; }

void OnRequest(DataSource * p, int request_id,
               ResourceRequest const * request,
               WebString const * path)
{ p->OnRequest(request_id, *request, *path); }

void SendResponse(DataSource * p, int request_id,
                 unsigned int buffer_size,
                 unsigned char const * buffer,
                 WebString const * mime_type)
{ p->SendResponse(request_id, buffer_size, buffer, *mime_type); }

}   // namespace DataSourceMember
}   // namespace Awesomium4D


/**
JSArray.h
*/

namespace Awesomium4D {
using namespace Awesomium;

namespace JSArrayMember {

size_t sizeOfInstance()
{ return sizeof(JSArray); }

void ctor(JSArray * p)
{ new(p) JSArray(); }

void ctor(JSArray * p, unsigned int n)
{ new(p) JSArray(n); }

void ctor(JSArray * p, JSArray const * const rhs)
{ new(p) JSArray(*rhs); }

JSArray * newCtor()
{ return new JSArray(); }

JSArray * newCtor(unsigned int n)
{ return new JSArray(n); }

JSArray * newCtor(JSArray const * const rhs)
{ return new JSArray(*rhs); }

void dtor(JSArray * p)
{ p->~JSArray(); }

void deleteDtor(JSArray * p)
{ delete p; }

JSArray * opAssign(JSArray * p, JSArray const * const rhs)
{ return &(*p = *rhs); }

unsigned int size(JSArray const * const p)
{ return p->size(); }

unsigned int capacity(JSArray const * const p)
{ return p->capacity(); }

JSValue* At(JSArray * p, unsigned int idx)
{ return &(p->At(idx)); }

JSValue const * const At(JSArray const * const p, unsigned int idx)
{ return &(p->At(idx)); }

JSValue* opIndex(JSArray * p, unsigned int idx)
{ return &((*p)[idx]); }

JSValue const * const opIndex(JSArray const * const p, unsigned int idx)
{ return &((*p)[idx]); }

void Push(JSArray * p, JSValue const * const item)
{ p->Push(*item); }

void Pop(JSArray * p)
{ p->Pop(); }

void Insert(JSArray * p, JSValue const * const item, unsigned int idx)
{ p->Insert(*item, idx); }

void Erase(JSArray * p, unsigned int idx)
{ p->Erase(idx); }

void Clear(JSArray * p)
{ p->Clear(); }

}   // namespace JSArrayMember
}   // namespace Awesomium4D


/**
JSObject.h
*/

namespace Awesomium4D {
using namespace Awesomium;

namespace JSObjectMember {

size_t sizeOfInstance()
{ return sizeof(JSObject); }

void ctor(JSObject * p)
{ new(p) JSObject(); }

void ctor(JSObject * p, JSObject const * const obj)
{ new(p) JSObject(*obj); }

JSObject * newCtor()
{ return new JSObject(); }

JSObject * newCtor(JSObject const * const obj)
{ return new JSObject(*obj); }

void dtor(JSObject * p)
{ p->~JSObject(); }

void deleteDtor(JSObject * p)
{ delete p; }

JSObject * opAssign(JSObject * p, JSObject const * const rhs)
{ return &(*p = *rhs); }

unsigned int remote_id(JSObject const * const p)
{ return p->remote_id(); }

int ref_count(JSObject const * const p)
{ return p->ref_count(); }

JSObjectType type(JSObject const * const p)
{ return p->type(); }

WebView * owner(JSObject const * const p)
{ return p->owner(); }

void GetPropertyNames(JSObject const * const p, JSArray * dst)
{ *dst = p->GetPropertyNames(); }

bool HasProperty(JSObject const * const p, WebString const * const name)
{ return p->HasProperty(*name); }

void GetProperty(JSObject const * const p, WebString const * const name, JSValue * dst)
{ *dst = p->GetProperty(*name); }

void SetProperty(JSObject * p, WebString const * const name, JSValue const * const value)
{ p->SetProperty(*name, *value); }

void SetPropertyAsync(JSObject * p, WebString const * const name, JSObject const * const value)
{ p->SetPropertyAsync(*name, *value); }

void RemoveProperty(JSObject * p, WebString const * const name)
{ p->RemoveProperty(*name); }

void GetMethodNames(JSObject const * const p, JSArray * dst)
{ *dst = p->GetMethodNames(); }

bool HasMethod(JSObject const * const p, WebString const * const name)
{ return p->HasMethod(*name); }

void Invoke(JSObject * p, WebString const * const name, JSArray const * const args, JSValue * dst)
{ *dst = p->Invoke(*name, *args); }

void InvokeAsync(JSObject * p, WebString const * const name, JSArray const * const args)
{ p->InvokeAsync(*name, *args); }

void ToString(JSObject const * const p, WebString * dst)
{ *dst = p->ToString(); }

void SetCustomMethod(JSObject * p, WebString const * const name, bool has_return_value)
{ p->SetCustomMethod(*name, has_return_value); }

Error last_error(JSObject const * const p)
{ return p->last_error(); }

}   // JSObjectMember


class IJSMethodHandlerD
{
  public:
    virtual void call(WebView *, unsigned int, WebString const * const, JSArray const * const) = 0;
    virtual void callWithReturnValue(WebView *, unsigned int, WebString const * const, JSArray const * const, JSValue *) = 0;
};


class JSMethodHandlerD2Cpp : public JSMethodHandler
{
  public:
    JSMethodHandlerD2Cpp(IJSMethodHandlerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~JSMethodHandlerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnMethodCall(Awesomium::WebView* caller,
                            unsigned int remote_object_id,
                            const Awesomium::WebString& method_name,
                            const Awesomium::JSArray& args)
    { _p->call(caller, remote_object_id, &method_name, &args); }


    Awesomium::JSValue
      OnMethodCallWithReturnValue(Awesomium::WebView* caller,
                                  unsigned int remote_object_id,
                                  const Awesomium::WebString& method_name,
                                  const Awesomium::JSArray& args)
    {
        JSValue dst;
        _p->callWithReturnValue(caller, remote_object_id, &method_name, &args, &dst);
        return dst;
    }


  private:
    IJSMethodHandlerD * _p;
    uint64_t _mid;
};

namespace JSMethodHandlerD2CppMember {

// void* newCtor(void* p, uint64_t mid)
// { return new JSMethodHandlerD2Cpp(static_cast<Awesomium4D::IJSMethodHandlerD*>(p), mid); }

// void deleteDtor(void* p)
// { delete static_cast<JSMethodHandlerD2Cpp*>(p); }

JSMethodHandlerD2Cpp * newCtor(IJSMethodHandlerD * p, uint64_t mid)
{ return new JSMethodHandlerD2Cpp(p,  mid); }

void deleteDtor(JSMethodHandlerD2Cpp* p)
{ delete p; }

}


namespace JSMethodHandlerMember {

/*
JSMethodHandler has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

void dtor(JSMethodHandler * p)
{ p->~JSMethodHandler(); }

void deleteDtor(JSMethodHandler * p)
{ delete p; }

void OnMethodCall(JSMethodHandler * p,
                  WebView * caller,
                  unsigned int remote_object_id,
                  WebString const * method_name,
                  JSArray const * args)
{ p->OnMethodCall(caller, remote_object_id, *method_name, *args); }

void OnMethodCallWithReturnValue(JSMethodHandler * p,
                                 WebView * caller,
                                 unsigned int remote_object_id,
                                 WebString const * method_name,
                                 JSArray const * args,
                                 JSValue * dst)
{ *dst = p->OnMethodCallWithReturnValue(caller, remote_object_id, *method_name, *args); }

}   // JSMethodHandlerMember

}   // Awesomium4D


/**
JSValue.h
*/

namespace Awesomium4D {
using namespace Awesomium4D;

namespace JSValueMember {

size_t sizeOfInstance()
{ return sizeof(JSValue); }

void ctor(JSValue * p)
{ new(p) JSValue(); }

void ctor(JSValue * p, bool value)
{ new(p) JSValue(value); }

void ctor(JSValue * p, int value)
{ new(p) JSValue(value); }

void ctor(JSValue * p, double value)
{ new(p) JSValue(value);}

void ctor(JSValue * p, WebString const * const value)
{ new(p) JSValue(*value); }

void ctor(JSValue * p, JSObject const * const value)
{ new(p) JSValue(*value); }

void ctor(JSValue * p, JSArray const * const value)
{ new(p) JSValue(*value); }

void ctor(JSValue * p, JSValue const * const original)
{ new(p) JSValue(*original); }

JSValue * newCtor()
{ return new JSValue(); }

JSValue * newCtor(bool value)
{ return new JSValue(value); }

JSValue * newCtor(int value)
{ return new JSValue(value); }

JSValue * newCtor(double value)
{ return new JSValue(value); }

JSValue * newCtor(WebString const * const value)
{ return new JSValue(*value); }

JSValue * newCtor(JSObject const * const value)
{ return new JSValue(*value); }

JSValue * newCtor(JSArray const * const value)
{ return new JSValue(*value); }

JSValue * newCtor(JSValue const * const original)
{ return new JSValue(*original); }

void dtor(JSValue * p)
{ p->~JSValue(); }

void deleteDtor(JSValue * p)
{ delete p; }

JSValue * opAssign(JSValue * p, JSValue const * const rhs)
{ return &(*p = *rhs); }

JSValue const * const Undefined()
{ return &(JSValue::Undefined()); }

JSValue const * const Null()
{ return &(JSValue::Null()); }

bool IsBoolean(JSValue const * const p)
{ return p->IsBoolean(); }

bool IsInteger(JSValue const * const p)
{ return p->IsInteger(); }

bool IsDouble(JSValue const * const p)
{ return p->IsDouble(); }

bool IsNumber(JSValue const * const p)
{ return p->IsNumber(); }

bool IsString(JSValue const * const p)
{ return p->IsString(); }

bool IsArray(JSValue const * const p)
{ return p->IsArray(); }

bool IsObject(JSValue const * const p)
{ return p->IsObject(); }

bool IsNull(JSValue const * const p)
{ return p->IsNull(); }

bool IsUndefined(JSValue const * const p)
{ return p->IsUndefined(); }

void ToString(JSValue const * const p, WebString * dst)
{ *dst = p->ToString(); }

int ToInteger(JSValue const * const p)
{ return p->ToInteger(); }

double ToDouble(JSValue const * const p)
{ return p->ToDouble(); }

bool ToBoolean(JSValue const * const p)
{ return p->ToBoolean(); }

JSArray * ToArray(JSValue * p)
{ return &(p->ToArray()); }

JSArray const * const ToArray(JSValue const * const p)
{ return &(p->ToArray()); }

JSObject * ToObject(JSValue * p)
{ return &(p->ToObject()); }

JSObject const * const ToObject(JSValue const * const p)
{ return &(p->ToObject()); }

}   // JSValueMember
}   // Awesomium4D


/**
Platform.h
*/

namespace Awesomium4D {
using namespace Awesomium;

namespace RectMember {

bool IsEmpty(Rect const * p)
{ return p->IsEmpty(); }

}   // RectMember
}   // Awesomium


/**
PrintConfig.h
*/

namespace Awesomium4D {
using namespace Awesomium;

namespace PrintConfigMember {

size_t sizeOfInstance()
{ return sizeof(PrintConfig); }

void ctor(PrintConfig * p)
{ new(p) PrintConfig(); }

}   // PrintConfigMember
}   // Awesomium4D


/**
ResourceInterceptor.h
*/

namespace Awesomium4D {
using namespace Awesomium;

class IResourceInterceptorD
{
  public:
    virtual ResourceResponse * onRequest(ResourceRequest * req) = 0;
    virtual bool onFilterNavigation(int opid, int orid, WebString const * const m,
                            WebURL const * const url, bool is_main_frame) = 0;
    virtual void onWillDownload(int opid, int orid, WebURL const * const url) = 0;
};


class ResourceInterceptorD2Cpp : public ResourceInterceptor
{
  public:
    ResourceInterceptorD2Cpp(IResourceInterceptorD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~ResourceInterceptorD2Cpp() { deleteFromMemoryManager(_mid); }

    ResourceResponse * OnRequest(ResourceRequest * req)
    { return _p->onRequest(req); }

    bool OnFilterNavigation(int opid, int orid, const WebString& m, const WebURL& url, bool b)
    { return _p->onFilterNavigation(opid, orid, &m, &url, b); }

    void OnWillDownload(int opid, int orid, const WebURL& url)
    { _p->onWillDownload(opid, orid, &url); }


  private:
    IResourceInterceptorD * _p;
    uint64_t _mid;
};

namespace ResourceInterceptorD2CppMember
{
    ResourceInterceptorD2Cpp * newCtor(IResourceInterceptorD * p, uint64_t mid)
    { return new ResourceInterceptorD2Cpp(p, mid); }

    void deleteDtor(ResourceInterceptorD2Cpp * p)
    { delete p; }
}


namespace ResourceInterceptorMember {

void ctor(ResourceInterceptor * p)
{ new(p) ResourceInterceptor(); }

ResourceInterceptor * newCtor()
{ return new ResourceInterceptor(); }

void dtor(ResourceInterceptor * p)
{ p->~ResourceInterceptor(); }

void deleteDtor(ResourceInterceptor * p)
{ delete p; }

ResourceResponse* OnRequest(ResourceInterceptor * p,
                            ResourceRequest * request)
{ return p->OnRequest(request); }

bool OnFilterNavigation(ResourceInterceptor * p,
                        int origin_process_id,
                        int origin_routing_id,
                        WebString const * const method,
                        WebURL const * const url,
                        bool is_main_frame)
{ return p->OnFilterNavigation(origin_process_id, origin_routing_id, *method, *url, is_main_frame); }

void OnWillDownload(ResourceInterceptor * p,
                    int origin_process_id,
                    int origin_routing_id,
                    WebURL const * const url)
{ return p->OnWillDownload(origin_process_id, origin_routing_id, *url); }

}   // ResourceInterceptorMember


class IResourceRequestD
{
  public:
    virtual void cancel() = 0;
    virtual int originProcessId() const = 0;
    virtual int originRoutingId() const = 0;
    virtual void getUrl(WebURL * dst) const = 0;
    virtual void getMethod(WebString * dst) const = 0;
    virtual void setMethod(WebString const * const) = 0;
    virtual void getReferrer(WebString * dst) const = 0;
    virtual void setReferrer(WebString const * const) = 0;
    virtual void getExtraHandlers(WebString * dst) const = 0;
    virtual void setExtraHeaders(WebString const * const) = 0;
    virtual void appendExtraHeader(WebString const * const name, WebString const * const value) = 0;
    virtual unsigned int numUploadElements() const = 0;
    virtual UploadElement const * const getUploadElement(unsigned int idx) const = 0;
    virtual void clearUploadElements() = 0;
    virtual void appendUploadFilePath(WebString const * const path) = 0;
    virtual void appendUploadBytes(char const * bytes, unsigned int num_bytes) = 0;
    virtual void setIgnoreDataSourceHandler(bool ignore) = 0;
};


class ResourceRequestD2Cpp : public ResourceRequest
{
  public:
    ResourceRequestD2Cpp(IResourceRequestD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~ResourceRequestD2Cpp() { deleteFromMemoryManager(_mid); }

    void Cancel() { _p->cancel(); }
    int origin_process_id() const { return _p->originProcessId(); }
    int origin_routing_id() const { return _p->originRoutingId(); }
    WebURL url() const { WebURL url; _p->getUrl(&url); return url; }
    WebString method() const { WebString dst; _p->getMethod(&dst); return dst; }
    void set_method(const WebString& md) { _p->setMethod(&md); }
    WebString referrer() const { WebString dst; _p->getReferrer(&dst); return dst; }
    void set_referrer(const WebString& rf) { _p->setReferrer(&rf); }
    WebString extra_headers() const { WebString dst; _p->getExtraHandlers(&dst); return dst; }
    void set_extra_headers(const WebString& h) { _p->setExtraHeaders(&h); }
    void AppendExtraHeader(const WebString& n, const WebString& v) { _p->appendExtraHeader(&n, &v); }
    unsigned int num_upload_elements() const { return _p->numUploadElements(); }
    const UploadElement* GetUploadElement(unsigned int idx) const { return _p->getUploadElement(idx); }
    void ClearUploadElements() { _p->clearUploadElements(); }
    void AppendUploadFilePath(const WebString& path) { _p->appendUploadFilePath(&path); }
    void AppendUploadBytes(const char* bytes, unsigned int n) { _p->appendUploadBytes(bytes, n); }
    void set_ignore_data_source_handler(bool ignore) { _p->setIgnoreDataSourceHandler(ignore); }

  private:
    IResourceRequestD * _p;
    uint64_t _mid;
};

namespace ResourceRequestD2CppMember {
ResourceRequestD2Cpp * newCtor(IResourceRequestD * p, uint64_t mid) { return new ResourceRequestD2Cpp(p, mid); }
void deleteDtor(ResourceRequestD2Cpp * p){ delete p; }
}



namespace ResourceRequestMember {

/*
JSMethodHandler has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

void Cancel(ResourceRequest * p)
{ p->Cancel(); }

int origin_process_id(ResourceRequest const * const p)
{ return p->origin_process_id(); }

int origin_routing_id(ResourceRequest const * const p)
{ return p->origin_routing_id(); }

void url(ResourceRequest const * const p, WebURL * dst)
{ *dst = p->url(); }

void method(ResourceRequest const * const p, WebString * dst)
{ *dst = p->method(); }

void set_method(ResourceRequest * p, WebString const * const method)
{ p->set_method(*method); }

void referrer(ResourceRequest const * const p, WebString * dst)
{ *dst = p->referrer(); }

void set_referrer(ResourceRequest * p, WebString const * const referrer)
{ p->set_referrer(*referrer); }

void extra_headers(ResourceRequest const * const p, WebString * dst)
{ *dst = p->extra_headers(); }

void set_extra_headers(ResourceRequest * p, WebString const * const headers)
{ p->set_extra_headers(*headers); }

void AppendExtraHeader(ResourceRequest * p, WebString const * const name, WebString const * const value)
{ p->AppendExtraHeader(*name, *value); }

unsigned int num_upload_elements(ResourceRequest const * const p)
{ return p->num_upload_elements(); }

void const * GetUploadElement(ResourceRequest const * const p, unsigned int idx)
{ return p->GetUploadElement(idx); }

void ClearUploadElements(ResourceRequest * p)
{ p->ClearUploadElements(); }

void AppendUploadFilePath(ResourceRequest * p, WebString const * const path)
{ p->AppendUploadFilePath(*path); }

void AppendUploadBytes(ResourceRequest * p, const char* bytes, unsigned int num_bytes)
{ p->AppendUploadBytes(bytes, num_bytes); }

void set_ignore_data_source_handler(ResourceRequest * p, bool ignore)
{ p->set_ignore_data_source_handler(ignore); }

}   // ResourceRequestMember


namespace ResourceResponseMember {

// buffer is copied, so it can be const.
ResourceResponse * Create(unsigned int num_bytes,
                          unsigned char const * buffer,
                          WebString const * const mime_type)
{ return ResourceResponse::Create(num_bytes, (unsigned char *)buffer, *mime_type); }

ResourceResponse * Create(WebString const * const file_path)
{ return ResourceResponse::Create(*file_path); }

}   // ResourceResponse


class IUploadElementD
{
  public:
    virtual bool isFilePath() const = 0;
    virtual bool isBytes() const = 0;
    virtual unsigned int numBytes() const = 0;
    virtual unsigned char const * bytes() const = 0;
    virtual void getFilePath(WebString * dst) const = 0;
};


class UploadElementD2Cpp : public UploadElement
{
  public:
    UploadElementD2Cpp(IUploadElementD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~UploadElementD2Cpp() { deleteFromMemoryManager(_mid); }

    bool IsFilePath() const { return _p->isFilePath(); }
    bool IsBytes() const { return _p->isBytes(); }
    unsigned int num_bytes() const { return _p->numBytes(); }
    unsigned char const * bytes() const { return _p->bytes(); }
    WebString file_path() const
    {
        WebString dst;
        _p->getFilePath(&dst);
        return dst;
    }

  private:
    IUploadElementD * _p;
    uint64_t _mid;
};

namespace UploadElementD2CppMember {

UploadElementD2Cpp * newCtor(IUploadElementD * p, uint64_t mid)
{ return new UploadElementD2Cpp(p, mid); }

void deleteDtor(UploadElementD2Cpp * p)
{ delete p; }

}

namespace UploadElementMember {

/*
UploadElement has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

bool IsFilePath(UploadElement const * const p)
{ return p->IsFilePath(); }

bool IsBytes(UploadElement const * const p)
{ return p->IsBytes(); }

unsigned int num_bytes(UploadElement const * const p)
{ return p->num_bytes(); }

unsigned char const * bytes(UploadElement const * const p)
{ return p->bytes(); }

void file_path(UploadElement const * const p, WebString * dst)
{ *dst = p->file_path(); }

}   // UploadElement

}   // Awesomium4D


/**
STLHelpers.h
*/

// no classes

/**
Surface.h
*/
namespace Awesomium4D {
using namespace Awesomium;

class ISurfaceD
{
  public:
    virtual void paint(unsigned char const *, int, Rect const *, Rect const *) = 0;
    virtual void scroll(int, int, Rect const *) = 0;
};


class SurfaceD2Cpp : public Surface
{
  public:
    SurfaceD2Cpp(ISurfaceD * p, uint64_t mid) : _p(p), _mid(mid) {}

    void Paint(unsigned char* src, int srcRS, const Rect& sr, const Rect& dr)
    { _p->paint(src, srcRS, &sr, &dr); }

    void Scroll(int dx, int dy, const Rect& cr)
    { _p->scroll(dx, dy, &cr); }

  private:
    ISurfaceD * _p;
    uint64_t _mid;
};

namespace SurfaceD2CppMember {
SurfaceD2Cpp * newCtor(ISurfaceD * p, uint64_t mid) { return new SurfaceD2Cpp(p, mid); }
void deleteDtor(SurfaceD2Cpp * p) { delete p; }
}

namespace SurfaceMember {

/*
Surface has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

void dtor(Surface * p)
{ p->~Surface(); }

void deleteDtor(Surface * p)
{ delete p; }

void Paint(Surface * p,
           unsigned char* src_buffer,
           int src_row_span,
           Rect const * src_rect,
           Rect const * dest_rect)
{ p->Paint(src_buffer, src_row_span, *src_rect, *dest_rect); }

void Scroll(Surface * p, int dx, int dy, Rect const * clip_rect)
{ p->Scroll(dx, dy, *clip_rect); }

}   // SurfaceMember


class ISurfaceFactoryD
{
  public:
    virtual Surface * createSurface(WebView * view, int width, int height) = 0;
    virtual void destroySurface(Surface * surf) = 0;
};


class SurfaceFactoryD2Cpp : public SurfaceFactory
{
  public:
    SurfaceFactoryD2Cpp(ISurfaceFactoryD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~SurfaceFactoryD2Cpp() { deleteFromMemoryManager(_mid); }

    Surface * CreateSurface(WebView * view, int width, int height)
    { return _p->createSurface(view, width, height); }

    void DestroySurface(Surface * surf)
    { _p->destroySurface(surf); }

  private:
    ISurfaceFactoryD * _p;
    uint64_t _mid;
};

namespace SurfaceFactoryD2CppMember {
SurfaceFactoryD2Cpp * newCtor(ISurfaceFactoryD * p, uint64_t mid) { return new SurfaceFactoryD2Cpp(p, mid); }
void deleteDtor(SurfaceFactoryD2Cpp * p) { delete p; }
}


namespace SurfaceFactoryMember {

/*
Surface has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

void dtor(SurfaceFactory * p)
{ p->~SurfaceFactory(); }

void deleteDtor(SurfaceFactory * p)
{ delete p; }

Surface * CreateSurface(SurfaceFactory * p, WebView * view,
                        int width, int height)
{ return p->CreateSurface(view, width, height); }

void DestroySurface(SurfaceFactory * p, Surface * surface)
{ p->DestroySurface(surface); }

}   // SurfaceFactory
}   // Awesomium4D


/**
WebConfig.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebConfigMember {

size_t sizeOfInstance()
{ return sizeof(WebConfig); }

void ctor(WebConfig * p)
{ new(p) WebConfig(); }

void ctor(WebConfig * p, WebConfig const * rhs)
{ ctor(p); *p = *rhs; }

WebConfig * newCtor()
{ WebConfig *p = new WebConfig(); return p; }

WebConfig * newCtor(WebConfig const * rhs)
{ WebConfig *p = newCtor(); *p = *rhs; return p; }

void dtor(WebConfig * p)
{ p->~WebConfig(); }

void deleteDtor(WebConfig * p)
{ delete p; }

void* additionalOptionsPtr(WebConfig * p)
{ return &(p->additional_options); }

void const * additionalOptionsPtr(WebConfig const * p)
{ return &(p->additional_options); }


}   // WebConfigMember
}   // Awesomium4D


/**
WebCore.h
*/
namespace Awesomium4D {
using namespace Awesomium;

/*
class IWebCoreD
{
  public:
    virtual WebSession * createWebSession(WebString const * const, WebPreferences const *) = 0;
    virtual WebView * createWebView(int, int, WebSession *, WebViewType) = 0;
    virtual void setSurfaceFactory(SurfaceFactory *) = 0;
    virtual SurfaceFactory * surfaceFactory() const = 0;
    virtual void setResourceInterceptor(ResourceInterceptor *) = 0;
    virtual ResourceInterceptor * resourceInterceptor() const = 0;
    virtual void update();
    virtual void log(WebString const * const, LogSeverity, WebString const * const, int) = 0;
    virtual unsigned char const * versionString() const = 0;
};


class WebCoreD2Cpp : public WebCore
{
  public:
    WebCoreD2Cpp(IWebCoreD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~WebCoreD2Cpp() { deleteFromMemoryManager(_mid); }

    WebSession * CreateWebSession(const WebString& path,
                                  const WebPreferences& prefs)
    { return _p->createSurface(&path, &prefs); }

    WebView * CreateWebView(int width, int height, WebSession* ss = 0, WebViewType type = kWebViewType_Offscreen)
    { return _p->createWebView(width, height, ss, type); }

    void set_surface_factory(SurfaceFactory* f)
    { _p->setSurfaceFactory(f); }

    SurfaceFactory * surface_factory() const
    { _p->surfaceFactory(); }

    void set_resource_interceptor(ResourceInterceptor* interceptor)
    { _p->setResourceInterceptor(interceptor); }

    ResourceInterceptor* resource_interceptor() const
    { return _p->resourceInterceptor(); }

    void Update() { _p->update(); }

    void Log(const WebString& msg, LogSeverity s, const WebString& f, int line)
    { _p->log(&msg, s, &file, line); }

    const char* version_string() const
    { return _p->versionString(); }

  private:
    IWebCoreD * _p;
    uint64_t _mid;
};


namespace WebCoreD2CppMember {
WebCoreD2Cpp * newCtor(IWebCoreD * p, uint64_t mid)
{ return new WebCoreD2Cpp(p, mid); }

void deleteDtor(WebCoreD2Cpp * p)
{ delete p; }
}
*/


namespace WebCoreMember {

/*
WebCore has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

WebCore * Initialize(WebConfig const * const config)
{ return WebCore::Initialize(*config); }

void Shutdown()
{ WebCore::Shutdown(); }

WebCore * instance()
{ return WebCore::instance(); }

WebSession * CreateWebSession(WebCore * p,
                              WebString const * const path,
                              WebPreferences const * const prefs)
{ return p->CreateWebSession(*path, *prefs); }

WebView * CreateWebView(WebCore * p,
                        int width, int height,
                        WebSession * session,
                        WebViewType type)
{ return p->CreateWebView(width, height, session, type); }

void set_surface_factory(WebCore * p, SurfaceFactory * factory)
{ p->set_surface_factory(factory); }

SurfaceFactory* surface_factory(WebCore const * const p)
{ return p->surface_factory(); }

void set_resource_interceptor(WebCore * p, ResourceInterceptor * interceptor)
{ p->set_resource_interceptor(interceptor); }

ResourceInterceptor * resource_interceptor(WebCore const * const p)
{ return p->resource_interceptor(); }

void Update(WebCore * p)
{ p->Update(); }

void Log(WebCore * p, WebString const * const message,
         LogSeverity severity, WebString const * const file, int line)
{ p->Log(*message, severity, *file, line); }

const char* version_string(WebCore const * const p)
{ return p->version_string(); }

unsigned int used_memory()
{ return WebCore::used_memory(); }

unsigned int allocated_memory()
{ return WebCore::allocated_memory(); }

void release_memory()
{ WebCore::release_memory(); }

}   // WebCoreMember
}   // Awesomium4D

/**
WebKeyboardCodes.h
*/
// no classes


/**
WebKeyboardEvent.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebKeyboardEventMember {

size_t sizeOfInstance()
{ return sizeof(WebKeyboardEvent); }

void ctor(WebKeyboardEvent * p)
{ new(p) WebKeyboardEvent(); }

WebKeyboardEvent * newCtor()
{ return new WebKeyboardEvent(); }

void deleteDtor(WebKeyboardEvent * p)
{ delete p; }

#if defined(_WIN32)
    void ctor(WebKeyboardEvent * p, UINT msg, WPARAM wparam, LPARAM lparam)
    { new(p) WebKeyboardEvent(msg, wparam, lparam); }

    WebKeyboardEvent * newCtor(UINT msg, WPARAM wparam, LPARAM lparam)
    { return new WebKeyboardEvent(msg, wparam, lparam); }

#elif defined(__APPLE__)
    void ctor(WebKeyboardEvent * p, NSEvent * event)
    { new(p) WebKeyboardEvent(event); }

    WebKeyboardEvent * newCtor(NSEvent * event)
    { new(p) WebKeyboardEvent(event); }

#endif

}   // WebKeyboardEventMember
}   // Awesomium4D

/**
WebMenuItem
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebMenuItemMember {

size_t sizeOfInstance()
{ return sizeof(WebMenuItem); }

void ctor(WebMenuItem * p)
{ new(p) WebMenuItem(); }

WebMenuItem * newCtor()
{ return new WebMenuItem(); }

void deleteDtor(WebMenuItem * p)
{ delete p; }

}   // WebMenuItemMember


namespace WebMenuItemArrayMember {

size_t sizeOfInstance()
{ return sizeof(WebMenuItemArray); }

void ctor(WebMenuItemArray * p)
{ new(p) WebMenuItemArray(); }

void ctor(WebMenuItemArray * p, unsigned int n)
{ new(p) WebMenuItemArray(n); }

void ctor(WebMenuItemArray * p, WebMenuItemArray const * const rhs)
{ new(p) WebMenuItemArray(*rhs); }

WebMenuItemArray * newCtor()
{ return new WebMenuItemArray(); }

WebMenuItemArray * newCtor(unsigned int n)
{ return new WebMenuItemArray(n); }

WebMenuItemArray * newCtor(WebMenuItemArray const * const rhs)
{ return new WebMenuItemArray(*rhs); }

void dtor(WebMenuItemArray * p)
{ p->~WebMenuItemArray(); }

void deleteDtor(WebMenuItemArray * p)
{ delete p; }

WebMenuItemArray * opAssign(WebMenuItemArray * p, WebMenuItemArray const * const  rhs)
{ return &(*p = *rhs); }

unsigned int size(WebMenuItemArray const * const p)
{ return p->size(); }

WebMenuItem * At(WebMenuItemArray * p, unsigned int idx)
{ return &(p->At(idx)); }

WebMenuItem const * const At(WebMenuItemArray const * const p, unsigned int idx)
{ return &(p->At(idx)); }

WebMenuItem * opIndex(WebMenuItemArray * p, unsigned int idx)
{ return &((*p)[idx]); }

WebMenuItem const * const opIndex(WebMenuItemArray const * const p, unsigned int idx)
{ return &((*p)[idx]); }

void Push(WebMenuItemArray * p, WebMenuItem const * const item)
{ p->Push(*item); }

}   // WebMenuItemArrayMember

}   // Awesomium4D


/**
WebPreferences.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebPreferencesMember {

size_t sizeOfInstance()
{ return sizeof(WebPreferences); }

void ctor(WebPreferences * p)
{ new(p) WebPreferences(); }

WebPreferences * newCtor()
{ return new WebPreferences(); }

void deleteDtor(WebPreferences * p)
{ delete p; }

}   // WebPreferencesMember
}   // Awesomium4D

/**
WebSession.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebSessionMember {

/*
WebSession has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

void Release(WebSession const * const p)
{ p->Release(); }

bool IsOnDisk(WebSession const * const p)
{ return p->IsOnDisk(); }

void data_path(WebSession const * const p, WebString * dst)
{ *dst = p->data_path(); }

WebPreferences const * const preferences(WebSession const * const p)
{ return &(p->preferences()); }

void AddDataSource(WebSession * p, WebString const * const asset_host, DataSource * source)
{ p->AddDataSource(*asset_host, source); }

void SetCookie(WebSession * p, WebURL const * const url,
               WebString const * const cookie_string,
               bool is_http_only,
               bool force_session_cookie)
{ p->SetCookie(*url, *cookie_string, is_http_only, force_session_cookie); }

void ClearCookies(WebSession * p)
{ p->ClearCookies(); }

void ClearCache(WebSession * p)
{ p->ClearCache(); }

int GetZoomForURL(WebSession * p, WebURL const * const url)
{ return p->GetZoomForURL(*url); }

}   // WebSessionMember
}   // Awesomium4D

/**
WebString.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebStringMember {

size_t sizeOfInstance()
{ return sizeof(WebString); }

void ctor(WebString * p)
{ new(p) WebString(); }

void ctor(WebString * p, WebString const * const src, unsigned int pos, unsigned int n)
{ new(p) WebString(*src, pos, n); }

void ctor(WebString * p, wchar16 const * data)
{ new(p) WebString(data); }

void ctor(WebString * p, wchar16 const * data, unsigned int len)
{ new(p) WebString(data, len); }

void ctor(WebString * p, WebString const * const src)
{ new(p) WebString(*src); }

WebString * newCtor()
{ return new WebString(); }

WebString * newCtor(WebString const * const src, unsigned int pos, unsigned int n)
{ return new WebString(*src, pos, n); }

WebString * newCtor(wchar16 const * data)
{ return new WebString(data); }

WebString * newCtor(wchar16 const * data, unsigned int len)
{ return new WebString(data, len); }

WebString * newCtor(WebString const * const src)
{ return new WebString(*src); }

void dtor(WebString * p)
{ p->~WebString(); }

void deleteDtor(WebString * p)
{ delete p; }

WebString * opAssign(WebString * p, WebString const * const rhs)
{ return &(*p = *rhs); }

void CreateFromUTF8(char const * data, unsigned int len, WebString * dst)
{ *dst = WebString::CreateFromUTF8(data, len); }

wchar16 const * data(WebString const * const p)
{ return p->data(); }

unsigned int length(WebString const * const p)
{ return p->length(); }

bool IsEmpty(WebString const * const p)
{ return p->IsEmpty(); }

int Compare(WebString const * const p,  WebString const * const src)
{ return p->Compare(*src); }

WebString * Assign(WebString * p, WebString const * const src)
{ return &(p->Assign(*src)); }

WebString * Assign(WebString * p, WebString const * const src, unsigned int pos, unsigned int n)
{ return &(p->Assign(*src, pos, n)); }

WebString * Assign(WebString * p, wchar16 const * data)
{ return &(p->Assign(data)); }

WebString * Assign(WebString * p, wchar16 const * data, unsigned int len)
{ return &(p->Assign(data, len)); }

WebString * Append(WebString * p, WebString const * const src)
{ return &(p->Append(*src)); }

void Clear(WebString * p)
{ p->Clear(); }

unsigned int ToUTF8(WebString const * const p, char* dest,  unsigned int len)
{ return p->ToUTF8(dest, len); }

bool opEquals(WebString const * const p, WebString const * const other)
{ return *p == *other; }

int opCmp(WebString const * const p, WebString const * const other)
{
    if(*p < *other)
        return -1;
    else if(*p == *other)
        return 0;
    else
        return 1;
}

}   // WebStringMember
}   // Awesomium4D


/**
WebStringArray.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebStringArrayMember {

size_t sizeOfInstance()
{ return sizeof(WebStringArray); }

void ctor(WebStringArray * p)
{ new(p) WebStringArray(); }

void ctor(WebStringArray * p, unsigned int n)
{ new(p) WebStringArray(n); }

void ctor(WebStringArray * p, WebStringArray const * const rhs)
{ new(p) WebStringArray(*rhs); }

WebStringArray * newCtor()
{ return new WebStringArray(); }

WebStringArray * newCtor(unsigned int n)
{ return new WebStringArray(n); }

WebStringArray * newCtor(WebStringArray const * const rhs)
{ return new WebStringArray(*rhs); }

void dtor(WebStringArray * p)
{ p->~WebStringArray(); }

void deleteDtor(WebStringArray * p)
{ delete p; }

WebStringArray * opAssign(WebStringArray * p, WebStringArray const * const rhs)
{ return &(*p = *rhs); }

unsigned int size(WebStringArray const * const p)
{ return p->size(); }

WebString * At(WebStringArray * p, unsigned int idx)
{ return &(p->At(idx)); }

WebString const * const At(WebStringArray const * const p, unsigned int idx)
{ return &(p->At(idx)); }

WebString * opIndex(WebStringArray * p, unsigned int idx)
{ return &((*p)[idx]); }

WebString const * const opIndex(WebStringArray const * const p, unsigned int idx)
{ return &((*p)[idx]); }

void Push(WebStringArray * p, WebString const * const item)
{ p->Push(*item); }

}   // WebStringArrayMember
}   // Awesomium4D

/**
WebTouchEvent.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebTouchPointMember {

size_t sizeOfInstance()
{ return sizeof(WebTouchPoint); }

void ctor(WebTouchPoint * p)
{ new(p) WebTouchPoint(); }

WebTouchPoint * newCtor()
{ return new WebTouchPoint(); }

void deleteDtor(WebTouchPoint * p)
{ delete p; }

}   // WebTouchPoint

namespace WebTouchEventMember {

size_t sizeOfInstance()
{ return sizeof(WebTouchEvent); }

void ctor(WebTouchEvent * p)
{ new(p) WebTouchEvent(); }

WebTouchEvent * newCtor()
{ return new WebTouchEvent(); }

void deleteDtor(WebTouchEvent * p)
{ delete p; }

}   // WebTouchEventMember
}   // Awesomium4D


/**
WebURL.h
*/
namespace Awesomium4D {
using namespace Awesomium;

namespace WebURLMember {

size_t sizeOfInstance()
{ return sizeof(WebURL); }

void ctor(WebURL * p)
{ new(p) WebURL(); }

void ctor(WebURL * p, WebString const * const  url_string)
{ new(p) WebURL(*url_string); }

void ctor(WebURL * p, WebURL const * const rhs)
{ new(p) WebURL(*rhs); }

WebURL * newCtor()
{ return new WebURL(); }

WebURL * newCtor(WebString const * const url_string)
{ return new WebURL(*url_string); }

WebURL * newCtor(WebURL const * const rhs)
{ return new WebURL(*rhs); }

void dtor(WebURL * p)
{ p->~WebURL(); }

void deleteDtor(WebURL * p)
{ delete p; }

WebURL * opAssign(WebURL * p, WebURL const * const rhs)
{ return &(*p = *rhs); }

bool IsValid(WebURL const * const p)
{ return p->IsValid(); }

bool IsEmpty(WebURL const * const p)
{ return p->IsEmpty(); }

void spec(WebURL const * const p, WebString * dst)
{ *dst = p->spec(); }

void scheme(WebURL const * const p, WebString * dst)
{ *dst = p->scheme(); }

void username(WebURL const * const p, WebString * dst)
{ *dst = p->username(); }

void password(WebURL const * const p, WebString * dst)
{ *dst = p->password(); }

void host(WebURL const * const p, WebString * dst)
{ *dst = p->host(); }

void port(WebURL const * const p, WebString * dst)
{ *dst = p->port(); }

void path(WebURL const * const p, WebString * dst)
{ *dst = p->path(); }

void query(WebURL const * const p, WebString * dst)
{ *dst = p->query(); }

void anchor(WebURL const * const p, WebString * dst)
{ *dst = p->anchor(); }

void filename(WebURL const * const p, WebString * dst)
{ *dst = p->filename(); }

bool opEquals(WebURL const * const p, WebURL const * const other)
{ return *p == *other; }

int opCmp(WebURL const * const p, WebURL const * const other)
{
    if(*p < *other)
        return -1;
    else if(*p == *other)
        return 0;
    else
        return 1;
}


}   // WebURLMember
}   // Awesomium4D

/**
WebView.h
*/
namespace Awesomium4D {
using namespace Awesomium;

class IWebViewD
{
  public:
    virtual void destroy() = 0;
    virtual WebViewType type() = 0;
    virtual int processId() = 0;
    virtual int routingId() = 0;
    virtual int nextRoutingId() = 0;
    virtual ProcessHandle processHandle() = 0;
    virtual void setParentWindow(NativeWindow parent) = 0;
    virtual NativeWindow parentWindow() = 0;
    virtual NativeWindow window() = 0;
    virtual void setViewListener(WebViewListener::View *) = 0;
    virtual void setLoadListener(WebViewListener::Load *) = 0;
    virtual void setProcessListener(WebViewListener::Process *) = 0;
    virtual void setMenuListener(WebViewListener::Menu *) = 0;
    virtual void setDialogListener(WebViewListener::Dialog *) = 0;
    virtual void setPrintListener(WebViewListener::Print *) = 0;
    virtual void setDonwloadListener(WebViewListener::Download *) = 0;
    virtual void setInputMethodEditorListener(WebViewListener::InputMethodEditor *) = 0;
    virtual WebViewListener::View * viewListener() = 0;
    virtual WebViewListener::Load * loadListener() = 0;
    virtual WebViewListener::Process * processListener() = 0;
    virtual WebViewListener::Menu * menuListener() = 0;
    virtual WebViewListener::Dialog * dialogListener() = 0;
    virtual WebViewListener::Print * printListener() = 0;
    virtual WebViewListener::Download * downloadListener() = 0;
    virtual WebViewListener::InputMethodEditor * inputMethodEditorListener() = 0;
    virtual void loadURL(WebURL const * const) = 0;
    virtual void goBack() = 0;
    virtual void goForward() = 0;
    virtual void goToHistoryOffset(int) = 0;
    virtual void stop() = 0;
    virtual void reload(bool) = 0;
    virtual bool canGoBack() = 0;
    virtual bool canGoForward() = 0;
    virtual Surface * surface() = 0;
    virtual void getUrl(WebURL *) = 0;
    virtual void getTitle(WebString *) = 0;
    virtual WebSession * session() = 0;
    virtual bool isLoading() = 0;
    virtual bool isCrashed() = 0;
    virtual void resize(int, int) = 0;
    virtual void setTransparent(bool) = 0;
    virtual bool isTransparent() = 0;
    virtual void pauseRendering() = 0;
    virtual void resumeRendering() = 0;
    virtual void focus() = 0;
    virtual void unfocus() = 0;
    virtual FocusedElementType focusedElementType() = 0;
    virtual void zoomIn() = 0;
    virtual void zoomOut() = 0;
    virtual void setZoom(int) = 0;
    virtual void resetZoom() = 0;
    virtual int getZoom() = 0;
    virtual void injectMouseMove(int, int) = 0;
    virtual void injectMouseDown(MouseButton) = 0;
    virtual void injectMouseUp(MouseButton) = 0;
    virtual void injectMouseWheel(int, int) = 0;
    virtual void injectKeyboardEvent(WebKeyboardEvent const * const) = 0;
    virtual void injectTouchEvent(WebTouchEvent const * const) = 0;
    virtual void activateIME(bool) = 0;
    virtual void setIMEComposition(WebString const * const, int, int, int) = 0;
    virtual void confirmIMEComposition(WebString const * const) = 0;
    virtual void cancelIMEComposition() = 0;
    virtual void undo() = 0;
    virtual void redo() = 0;
    virtual void cut() = 0;
    virtual void copy() = 0;
    virtual void copyImageAt(int, int) = 0;
    virtual void paste() = 0;
    virtual void pasteAndMatchStyle() = 0;
    virtual void selectAll() = 0;
    virtual int printToFile(WebString const * const, PrintConfig const * const) = 0;
    virtual Error lastError() const = 0;
    virtual void createGlobalJSObject(WebString const * const, JSValue *) = 0;
    virtual void executeJS(WebString const * const, WebString const * const) = 0;
    virtual void executeJSWithResult(WebString const * const, WebString const * const, JSValue *) = 0;
    virtual void setJSMethodHandler(JSMethodHandler *) = 0;
    virtual JSMethodHandler * jsMethodHandler() = 0;
    virtual void setSyncMessageTimeout(int) = 0;
    virtual int syncMessageTimeout() = 0;
    virtual void didSelectPopupMenuItem(int) = 0;
    virtual void didCancelPopupMenu() = 0;
    virtual void didChooseFiles(WebStringArray const * const, bool) = 0;
    virtual void didLogin(int, WebString const * const, WebString const * const) = 0;
    virtual void didCancelLogin(int) = 0;
    virtual void didChooseDownloadPath(int, WebString const * const) = 0;
    virtual void didCancelDownload(int) = 0;
    virtual void didOverrideCertificateError() = 0;
    virtual void requestPageInfo() = 0;
    virtual void reduceMemoryUsage() = 0;
};


class WebViewD2Cpp : public WebView
{
  public:
    WebViewD2Cpp(IWebViewD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~WebViewD2Cpp() { deleteFromMemoryManager(_mid); }

    void Destroy() { _p->destroy(); }
    WebViewType type() { return _p->type(); }
    int process_id() { return _p->processId(); }
    int routing_id() { return _p->routingId(); }
    int next_routing_id() { return _p->nextRoutingId(); }
    ProcessHandle process_handle() { return _p->processHandle(); }
    void set_parent_window(NativeWindow w) { return _p->setParentWindow(w); }
    NativeWindow parent_window(){ return _p->parentWindow(); }
    NativeWindow window() { return _p->window(); }
    void set_view_listener(WebViewListener::View* listener) { _p->setViewListener(listener); }
    void set_load_listener(WebViewListener::Load* listener) { _p->setLoadListener(listener); }
    void set_process_listener(WebViewListener::Process* listener) { _p->setProcessListener(listener); }
    void set_menu_listener(WebViewListener::Menu* listener) { _p->setMenuListener(listener); }
    void set_dialog_listener(WebViewListener::Dialog* listener) { _p->setDialogListener(listener); }
    void set_print_listener(WebViewListener::Print* listener) { _p->setPrintListener(listener); }
    void set_download_listener(WebViewListener::Download* listener) { _p->setDonwloadListener(listener); }
    void set_input_method_editor_listener(WebViewListener::InputMethodEditor* listener) { _p->setInputMethodEditorListener(listener); }
    WebViewListener::View * view_listener() { return _p->viewListener(); }
    WebViewListener::Load * load_listener() { return _p->loadListener(); }
    WebViewListener::Process * process_listener() { return _p->processListener(); }
    WebViewListener::Menu * menu_listener() { return _p->menuListener(); }
    WebViewListener::Dialog * dialog_listener() { return _p->dialogListener(); }
    WebViewListener::Print * print_listener() { return _p->printListener(); }
    WebViewListener::Download * download_listener() { return _p->downloadListener(); }
    WebViewListener::InputMethodEditor * input_method_editor_listener() { return _p->inputMethodEditorListener(); }
    void LoadURL(const WebURL& url) { _p->loadURL(&url); }
    void GoBack() { _p->goBack(); }
    void GoForward() { _p->goForward(); }
    void GoToHistoryOffset(int o) { _p->goToHistoryOffset(o); }
    void Stop() { _p->stop(); }
    void Reload(bool i) { _p->reload(i); }
    bool CanGoBack() { return _p->canGoBack(); }
    bool CanGoForward() { return _p->canGoForward(); }
    Surface* surface() { return _p->surface(); }
    WebURL url() { WebURL dst; _p->getUrl(&dst); return dst; }
    WebString title() { WebString dst; _p->getTitle(&dst); return dst; }
    WebSession * session() { return _p->session(); }
    bool IsLoading() { return _p->isLoading(); }
    bool IsCrashed() { return _p->isCrashed(); }
    void Resize(int w, int h) { _p->resize(w, h); }
    void SetTransparent(bool b) { _p->setTransparent(b); }
    bool IsTransparent() { return _p->isTransparent(); }
    void PauseRendering() { _p->pauseRendering(); }
    void ResumeRendering() { _p->resumeRendering(); }
    void Focus() { _p->focus(); }
    void Unfocus() { _p->unfocus(); }
    FocusedElementType focused_element_type() { return _p->focusedElementType(); }
    void ZoomIn() { _p->zoomIn(); }
    void ZoomOut() { _p->zoomOut(); }
    void SetZoom(int z) { _p->setZoom(z); }
    void ResetZoom() { _p->resetZoom(); }
    int GetZoom() { return _p->getZoom(); }
    void InjectMouseMove(int x, int y) { _p->injectMouseMove(x, y); }
    void InjectMouseDown(MouseButton b) { _p->injectMouseDown(b); }
    void InjectMouseUp(MouseButton b) { _p->injectMouseUp(b); }
    void InjectMouseWheel(int v, int h) { _p->injectMouseWheel(v, h); }
    void InjectKeyboardEvent(const WebKeyboardEvent& e) { _p->injectKeyboardEvent(&e); }
    void InjectTouchEvent(const WebTouchEvent& e) { _p->injectTouchEvent(&e); }
    void ActivateIME(bool b) { _p->activateIME(b); }
    void SetIMEComposition(const WebString& s, int cp, int ts, int te) { _p->setIMEComposition(&s, cp, ts, te); }
    void ConfirmIMEComposition(const WebString& s) { _p->confirmIMEComposition(&s); }
    void CancelIMEComposition() { _p->cancelIMEComposition(); }
    void Undo() { _p->undo(); }
    void Redo() { _p->redo(); }
    void Cut() { _p->cut(); }
    void Copy() { _p->copy(); }
    void CopyImageAt(int x, int y) { _p->copyImageAt(x, y); }
    void Paste() { _p->paste(); }
    void PasteAndMatchStyle() { _p->pasteAndMatchStyle(); }
    void SelectAll() { _p->selectAll(); }
    int PrintToFile(const WebString& o, const PrintConfig& c) { return _p->printToFile(&o, &c); }
    Error last_error() const { return _p->lastError(); }
    JSValue CreateGlobalJavascriptObject(const WebString& n) { JSValue v; _p->createGlobalJSObject(&n, &v); return v; }
    void ExecuteJavascript(const WebString& s, const WebString& f) { _p->executeJS(&s, &f); }
    JSValue ExecuteJavascriptWithResult(const WebString& s, const WebString& f) { JSValue v; _p->executeJSWithResult(&s, &f, &v); return v; }
    void set_js_method_handler(JSMethodHandler * p) { _p->setJSMethodHandler(p); }
    JSMethodHandler * js_method_handler() { return _p->jsMethodHandler(); }
    void set_sync_message_timeout(int t) { _p->setSyncMessageTimeout(t); }
    int sync_message_timeout() { return _p->syncMessageTimeout(); }
    void DidSelectPopupMenuItem(int i) { _p->didSelectPopupMenuItem(i); }
    void DidCancelPopupMenu() { _p->didCancelPopupMenu(); }
    void DidChooseFiles(const WebStringArray& fs, bool b) { _p->didChooseFiles(&fs, b); }
    void DidLogin(int id, const WebString& u, const WebString& p) { _p->didLogin(id, &u, &p); }
    void DidCancelLogin(int id) { _p->didCancelLogin(id); }
    void DidChooseDownloadPath(int id, const WebString& p) { _p->didChooseDownloadPath(id, &p); }
    void DidCancelDownload(int id) { _p->didCancelDownload(id); }
    void DidOverrideCertificateError() { _p->didOverrideCertificateError(); }
    void RequestPageInfo() { _p->requestPageInfo(); }
    void ReduceMemoryUsage() { _p->reduceMemoryUsage(); }

  private:
    IWebViewD * _p;
    uint64_t _mid;
};


namespace WebViewD2CppMember {
WebViewD2Cpp * newCtor(IWebViewD * p, uint64_t mid)
{ return new WebViewD2Cpp(p, mid); }

void deleteDtor(WebViewD2Cpp * p)
{ delete p; }
}


namespace WebViewMember {

/*
WebSession has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

void Destroy(WebView * p)
{ p->Destroy(); }

WebViewType type(WebView * p)
{ return p->type(); }

int process_id(WebView * p)
{ return p->process_id(); }

int routing_id(WebView * p)
{ return p->routing_id(); }

int next_routing_id(WebView * p)
{ return p->next_routing_id(); }

ProcessHandle process_handle(WebView * p)
{ return p->process_handle(); }

void set_parent_window(WebView * p, NativeWindow parent)
{ return p->set_parent_window(parent); }

NativeWindow parent_window(WebView * p)
{ return p->parent_window(); }

NativeWindow window(WebView * p)
{ return p->window(); }

void set_view_listener(WebView * p, WebViewListener::View * listener)
{ p->set_view_listener(listener); }

void set_load_listener(WebView * p, WebViewListener::Load * listener)
{ p->set_load_listener(listener); }

void set_process_listener(WebView * p, WebViewListener::Process * listener)
{ p->set_process_listener(listener); }

void set_menu_listener(WebView * p, WebViewListener::Menu * listener)
{ p->set_menu_listener(listener); }

void set_dialog_listener(WebView * p, WebViewListener::Dialog * listener)
{ p->set_dialog_listener(listener); }

void set_print_listener(WebView * p, WebViewListener::Print * listener)
{ p->set_print_listener(listener); }

void set_download_listener(WebView * p, WebViewListener::Download * listener)
{ p->set_download_listener(listener); }

void set_input_method_editor_listener(WebView * p, WebViewListener::InputMethodEditor * listener)
{ p->set_input_method_editor_listener(listener); }

WebViewListener::View * view_listener(WebView * p)
{ return p->view_listener(); }

WebViewListener::Load * load_listener(WebView * p)
{ return p->load_listener(); }

WebViewListener::Process * process_listener(WebView * p)
{ return p->process_listener(); }

WebViewListener::Menu * menu_listener(WebView * p)
{ return p->menu_listener(); }

WebViewListener::Dialog * dialog_listener(WebView * p)
{ return p->dialog_listener(); }

WebViewListener::Print * print_listener(WebView * p)
{ return p->print_listener(); }

WebViewListener::Download * download_listener(WebView * p)
{ return p->download_listener(); }

WebViewListener::InputMethodEditor * input_method_editor_listener(WebView * p)
{ return p->input_method_editor_listener(); }

void LoadURL(WebView * p, WebURL const * const url)
{ p->LoadURL(*url); }

void GoBack(WebView * p)
{ p->GoBack(); }

void GoForward(WebView * p)
{ p->GoForward(); }

void GoToHistoryOffset(WebView * p, int offset)
{ p->GoToHistoryOffset(offset); }

void Stop(WebView * p)
{ p->Stop(); }

void Reload(WebView * p, bool ignore_cache)
{ p->Reload(ignore_cache); }

bool CanGoBack(WebView * p)
{ return p->CanGoBack(); }

bool CanGoForward(WebView * p)
{ return p->CanGoForward(); }

Surface* surface(WebView * p)
{ return p->surface(); }

void url(WebView * p, WebURL * dst)
{ *dst = p->url(); }

void title(WebView * p, WebString * dst)
{ *dst = p->title(); }

WebSession * session(WebView * p)
{ return p->session(); }

bool IsLoading(WebView * p)
{ return p->IsLoading(); }

bool IsCrashed(WebView * p)
{ return p->IsCrashed(); }

void Resize(WebView * p, int width, int height)
{ p->Resize(width, height); }

void SetTransparent(WebView * p, bool is_transparent)
{ p->SetTransparent(is_transparent); }

bool IsTransparent(WebView * p)
{ return p->IsTransparent(); }

void PauseRendering(WebView * p)
{ p->PauseRendering(); }

void ResumeRendering(WebView * p)
{ p->ResumeRendering(); }

void Focus(WebView * p)
{ p->Focus(); }

void Unfocus(WebView * p)
{ p->Unfocus(); }

FocusedElementType focused_element_type(WebView * p)
{ return p->focused_element_type(); }

void ZoomIn(WebView * p)
{ p->ZoomIn(); }

void ZoomOut(WebView * p)
{ p->ZoomOut(); }

void SetZoom(WebView * p, int zoom_percent)
{ p->SetZoom(zoom_percent); }

void ResetZoom(WebView * p)
{ p->ResetZoom(); }

int GetZoom(WebView * p)
{ return p->GetZoom(); }

void InjectMouseMove(WebView * p, int x, int y)
{ p->InjectMouseMove(x, y); }

void InjectMouseDown(WebView * p, MouseButton button)
{ p->InjectMouseDown(button); }

void InjectMouseUp(WebView * p, MouseButton button)
{ p->InjectMouseUp(button); }

void InjectMouseWheel(WebView * p, int scroll_vert, int scroll_horz)
{ p->InjectMouseWheel(scroll_vert, scroll_horz); }

void InjectKeyboardEvent(WebView * p, WebKeyboardEvent const * const key_event)
{ p->InjectKeyboardEvent(*key_event); }

void InjectTouchEvent(WebView * p, WebTouchEvent const * const touch_event)
{ p->InjectTouchEvent(*touch_event); }

void ActivateIME(WebView * p, bool activate)
{ p->ActivateIME(activate); }

void SetIMEComposition(WebView * p, WebString const * const input_string,
                       int cursor_pos, int target_start, int target_end)
{ p->SetIMEComposition(*input_string, cursor_pos, target_start, target_end); }

void ConfirmIMEComposition(WebView * p, WebString const * const input_string)
{ p->ConfirmIMEComposition(*input_string); }

void CancelIMEComposition(WebView * p)
{ p->CancelIMEComposition(); }

void Undo(WebView * p)
{ p->Undo(); }

void Redo(WebView * p)
{ p->Redo(); }

void Cut(WebView * p)
{ p->Cut(); }

void Copy(WebView * p)
{ p->Copy(); }

void CopyImageAt(WebView * p, int x, int y)
{ p->CopyImageAt(x, y); }

void Paste(WebView * p)
{ p->Paste(); }

void PasteAndMatchStyle(WebView * p)
{ p->PasteAndMatchStyle(); }

void SelectAll(WebView * p)
{ p->SelectAll(); }

int PrintToFile(WebView * p,
                WebString const * const  output_direct,
                PrintConfig const * const config)
{ return p->PrintToFile(*output_direct, *config); }

Error last_error(WebView const * const p)
{ return p->last_error(); }

void CreateGlobalJavascriptObject(WebView * p, WebString const * const name, JSValue * dst)
{ *dst = p->CreateGlobalJavascriptObject(*name); }

void ExecuteJavascript(WebView * p, WebString const * const script,
                                    WebString const * const frame_xpath)
{ p->ExecuteJavascript(*script, *frame_xpath); }

void ExecuteJavascriptWithResult(WebView * p, WebString const * const script,
                                              WebString const * const frame_xpath,
                                              JSValue * dst)
{ *dst = p->ExecuteJavascriptWithResult(*script, *frame_xpath); }

void set_js_method_handler(WebView * p, JSMethodHandler * handler)
{ p->set_js_method_handler(handler); }

JSMethodHandler * js_method_handler(WebView * p)
{ return p->js_method_handler(); }

void set_sync_message_timeout(WebView * p, int timeout_ms)
{ p->set_sync_message_timeout(timeout_ms); }

int sync_message_timeout(WebView * p)
{ return p->sync_message_timeout(); }

void DidSelectPopupMenuItem(WebView * p, int item_index)
{ p->DidSelectPopupMenuItem(item_index); }

void DidCancelPopupMenu(WebView * p)
{ p->DidCancelPopupMenu(); }

void DidChooseFiles(WebView * p, WebStringArray const * const files,
                                 bool should_write_files)
{ p->DidChooseFiles(*files, should_write_files); }

void DidLogin(WebView * p, int request_id,
              WebString const * const username,
              WebString const * const password)
{ p->DidLogin(request_id, *username, *password); }

void DidCancelLogin(WebView * p, int request_id)
{ p->DidCancelLogin(request_id); }

void DidChooseDownloadPath(WebView * p, int download_id,
                           WebString const * const path)
{ p->DidChooseDownloadPath(download_id, *path); }

void DidCancelDownload(WebView * p, int download_id)
{ p->DidCancelDownload(download_id); }

void DidOverrideCertificateError(WebView * p)
{ p->DidOverrideCertificateError(); }

void RequestPageInfo(WebView * p)
{ p->RequestPageInfo(); }

void ReduceMemoryUsage(WebView * p)
{ p->ReduceMemoryUsage(); }

}   // WebViewMember
}   // Awesomium4D

/**
WebViewListener.h
*/
namespace Awesomium4D {
using namespace Awesomium;
using namespace WebViewListener;


class IViewListenerD
{
  public:
    virtual void onChangeTitle(WebView *, WebString const * const) = 0;
    virtual void onChangeAddressBar(WebView *, WebURL const * const) = 0;
    virtual void onChangeTooltip(WebView *, WebString const * const) = 0;
    virtual void onChangeTargetURL(WebView *, WebURL const * const) = 0;
    virtual void onChangeCursor(WebView *, Cursor) = 0;
    virtual void onChangeFocus(WebView *, FocusedElementType) = 0;
    virtual void onAddConsoleMessage(WebView *, WebString const * const, int, WebString const * const) = 0;
    virtual void onShowCreatedWebView(WebView *, WebView *, WebURL const * const, WebURL const * const, Rect const *, bool) = 0;
};


class ViewListenerD2Cpp : public WebViewListener::View
{
  public:
    ViewListenerD2Cpp(IViewListenerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~ViewListenerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnChangeTitle(WebView * c, const WebString& title)
    { _p->onChangeTitle(c, &title); }

    void OnChangeAddressBar(WebView * c, const WebURL& url)
    { _p->onChangeAddressBar(c, &url); }

    void OnChangeTooltip(WebView * c, const WebString& url)
    { _p->onChangeTooltip(c, &url); }

    void OnChangeTargetURL(WebView * c, const WebURL& url)
    { _p->onChangeTargetURL(c, &url); }

    void OnChangeCursor(WebView * c, Cursor cr)
    { _p->onChangeCursor(c, cr); }

    void OnChangeFocus(WebView * c, FocusedElementType fet)
    { _p->onChangeFocus(c, fet); }

    void OnAddConsoleMessage(WebView * c, const WebString& msg,
                             int n, const WebString& s)
    { _p->onAddConsoleMessage(c, &msg, n, &s); }

    void OnShowCreatedWebView(WebView * c, WebView * n,
                              const WebURL& ourl, const WebURL& turl,
                              const Rect& pos, bool b)
    { _p->onShowCreatedWebView(c, n, &ourl, &turl, &pos, b); }

  private:
    IViewListenerD * _p;
    uint64_t _mid;
};


namespace ViewListenerD2CppMember {
ViewListenerD2Cpp * newCtor(IViewListenerD * p, uint64_t mid)
{ return new ViewListenerD2Cpp(p, mid); }

void deleteDtor(ViewListenerD2Cpp * p)
{ delete p; }
}


namespace WebViewListenerViewMember {

/*
WebViewListener::View has some pure virtual methods.
So it shouldn't have any ctor and sizeof.
*/

void OnChangeTitle(View * p, WebView * caller,
                   WebString const * const title)
{ p->OnChangeTitle(caller, *title); }

void OnChangeAddressBar(View * p, WebView * caller,
                        WebURL const * const url)
{ p->OnChangeAddressBar(caller, *url); }

void OnChangeTooltip(View * p, WebView * caller,
                     WebString const * const tooltip)
{ p->OnChangeTooltip(caller, *tooltip); }

void OnChangeTargetURL(View * p, WebView * caller,
                       WebURL const * const url)
{ p->OnChangeTargetURL(caller, *url); }

void OnChangeCursor(View * p, WebView * caller,
                    Cursor cursor)
{ p->OnChangeCursor(caller, cursor); }

void OnChangeFocus(View * p, WebView * caller,
                   FocusedElementType fet)
{ p->OnChangeFocus(caller, fet); }

void OnAddConsoleMessage(View * p, WebView * caller,
                         WebString const * const msg,
                         int line_num,
                         WebString const * const src)
{ p->OnAddConsoleMessage(caller, *msg, line_num, *src); }

void OnShowCreatedWebView(View * p, WebView * caller,
                          WebView * new_view,
                          WebURL const * const opener_url,
                          WebURL const * const target_url,
                          Rect const * initial_pos,
                          bool is_popup)
{ p->OnShowCreatedWebView(caller, new_view, *opener_url, *target_url, *initial_pos, is_popup); }

}   // WebViewListenerViewMember


class ILoadListenerD
{
  public:
    virtual void onBeginLoadingFrame(WebView *, int64_t, bool, WebURL const * const, bool) = 0;
    virtual void onFailLoadingFrame(WebView *, int64_t, bool, WebURL const * const, int, const WebString) = 0;
    virtual void onFinishLoadingFrame(WebView *, int64_t, bool, WebURL const * const) = 0;
    virtual void onDocumentReady(WebView *, WebURL const * const) = 0;
};


class LoadListenerD2Cpp : public WebViewListener::Load
{
  public:
    LoadListenerD2Cpp(ILoadListenerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~LoadListenerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnBeginLoadingFrame(WebView * c, int64 f, bool b1, const WebURL& url, bool b2)
    { _p->onBeginLoadingFrame(c, f, b1, &url, b2); }

    void OnFailLoadingFrame(WebView * c, int64 f, bool b, const WebURL& url, int ec, const WebString& em)
    { _p->onFailLoadingFrame(c, f, b, &url, ec, em); }

    void OnFinishLoadingFrame(WebView * c, int64 f, bool b, const WebURL& url)
    { _p->onFinishLoadingFrame(c, f, b, &url); }

    void OnDocumentReady(WebView * c, const WebURL& url)
    { _p->onDocumentReady(c, &url); }

  private:
    ILoadListenerD * _p;
    uint64_t _mid;
};

namespace LoadListenerD2CppMember {
LoadListenerD2Cpp * newCtor(ILoadListenerD * p, uint64_t mid)
{ return new LoadListenerD2Cpp(p, mid); }

void deleteDtor(LoadListenerD2Cpp * p)
{ delete p; }
}


namespace WebViewListenerLoadMember {

void OnBeginLoadingFrame(Load * p, WebView * caller,
                         int64 frame_id, bool is_main_frame,
                         WebURL const * const url,
                         bool is_error_page)
{ p->OnBeginLoadingFrame(caller, frame_id, is_main_frame, *url, is_error_page); }

void OnFailLoadingFrame(Load * p, WebView * caller,
                        int64 frame_id, bool is_main_frame,
                        WebURL const * const url,
                        int error_code,
                        WebString const * const error_desc)
{ p->OnFailLoadingFrame(caller, frame_id, is_main_frame, *url, error_code, *error_desc); }

void OnFinishLoadingFrame(Load * p, WebView * caller,
                          int64 frame_id, bool is_main_frame,
                          WebURL const * const url)
{ p->OnFinishLoadingFrame(caller, frame_id, is_main_frame, *url); }

void OnDocumentReady(Load * p, WebView * caller,
                     WebURL const * const url)
{ p->OnDocumentReady(caller, *url); }

}   // WebViewListenerLoadMember


class IProcessListenerD
{
  public:
    virtual void onLaunch(WebView *);
    virtual void onUnresponsive(WebView *);
    virtual void onResponsive(WebView *);
    virtual void onCrashed(WebView *, TerminationStatus);
};

class ProcessListenerD2Cpp : public WebViewListener::Process
{
  public:
    ProcessListenerD2Cpp(IProcessListenerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~ProcessListenerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnLaunch(WebView * c)
    { _p->onLaunch(c); }

    void OnUnresponsive(WebView * c)
    { _p->onUnresponsive(c); }

    void OnResponsive(WebView * c)
    { _p->onResponsive(c); }

    void OnCrashed(WebView * c, TerminationStatus s)
    { _p->onCrashed(c, s); }

  private:
    IProcessListenerD * _p;
    uint64_t _mid;
};

namespace ProcessListenerD2CppMember {
ProcessListenerD2Cpp * newCtor(IProcessListenerD * p, uint64_t mid)
{ return new ProcessListenerD2Cpp(p, mid); }

void deleteDtor(ProcessListenerD2Cpp * p)
{ delete p; }
}

namespace WebViewListenerProcessMember {

void OnLaunch(Process * p, WebView * caller)
{ p->OnLaunch(caller); }

void OnUnresponsive(Process * p, WebView * caller)
{ p->OnUnresponsive(caller); }

void OnResponsive(Process * p, WebView * caller)
{ p->OnResponsive(caller); }

void OnCrashed(Process * p, WebView * caller,
               TerminationStatus status)
{ p->OnCrashed(caller, status); }

}   // WebViewListenerProcessMember


class IMenuListenerD
{
  public:
    virtual void onShowPopupMenu(WebView *, WebPopupMenuInfo const * const) = 0;
    virtual void onShowContextMenu(WebView *, WebContextMenuInfo const * const) = 0;
};

class MenuListenerD2Cpp : public WebViewListener::Menu
{
  public:
    MenuListenerD2Cpp(IMenuListenerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~MenuListenerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnShowPopupMenu(WebView * p, const WebPopupMenuInfo& m)
    { _p->onShowPopupMenu(p, &m); }

    void OnShowContextMenu(WebView * p, const WebContextMenuInfo& m)
    { _p->onShowContextMenu(p, &m); }

  private:
    IMenuListenerD * _p;
    uint64_t _mid;
};

namespace MenuListenerD2CppMember {
MenuListenerD2Cpp * newCtor(IMenuListenerD * p, uint64_t mid)
{ return new MenuListenerD2Cpp(p, mid); }

void deleteDtor(MenuListenerD2Cpp * p)
{ delete p; }
}


class IDialogListenerD
{
  public:
    virtual void onShowFileChooser(WebView *, WebFileChooserInfo const * const) = 0;
    virtual void onShowLoginDialog(WebView *, WebLoginDialogInfo const * const) = 0;
    virtual void onShowCertificateErrorDialog(WebView *, bool, WebURL const * const, CertError) = 0;
    virtual void onShowPageInfoDialog(WebView *, WebPageInfo const * const) = 0;
};


class DialogListenerD2Cpp : public WebViewListener::Dialog
{
  public:
    DialogListenerD2Cpp(IDialogListenerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~DialogListenerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnShowFileChooser(WebView * c, const WebFileChooserInfo& info)
    { _p->onShowFileChooser(c, &info); }

    void OnShowLoginDialog(WebView * c, const WebLoginDialogInfo& info)
    { _p->onShowLoginDialog(c, &info); }

    void OnShowCertificateErrorDialog(WebView * c, bool b, const WebURL& url, CertError ce)
    { _p->onShowCertificateErrorDialog(c, b, &url, ce); }

    void OnShowPageInfoDialog(WebView * c, const WebPageInfo& info)
    { _p->onShowPageInfoDialog(c, &info); }

  private:
    IDialogListenerD * _p;
    uint64_t _mid;
};


namespace DialogListenerD2CppMember {
DialogListenerD2Cpp * newCtor(IDialogListenerD * p, uint64_t mid)
{ return new DialogListenerD2Cpp(p, mid); }

void deleteDtor(DialogListenerD2Cpp * p)
{ delete p; }
}

namespace WebViewListenerMenuMember {

void OnShowPopupMenu(Menu * p, WebView * caller,
                     WebPopupMenuInfo const * const menu_info)
{ p->OnShowPopupMenu(caller, *menu_info); }

void OnShowContextMenu(Menu * p, WebView * caller,
                       WebContextMenuInfo const * const menu_info)
{ p->OnShowContextMenu(caller, *menu_info); }

}   // WebViewListenerMenuMember


namespace WebViewListenerDialogMember {

void OnShowFileChooser(Dialog * p, WebView * caller,
                       WebFileChooserInfo const * const info)
{ p->OnShowFileChooser(caller, *info); }


void OnShowLoginDialog(Dialog * p, WebView * caller,
                       WebLoginDialogInfo const * const info)
{ p->OnShowLoginDialog(caller, *info); }

void OnShowCertificateErrorDialog(Dialog * p, WebView * caller,
                                  bool is_overridable,
                                  WebURL const * const url,
                                  CertError error)
{ p->OnShowCertificateErrorDialog(caller, is_overridable, *url, error); }

void OnShowPageInfoDialog(Dialog * p, WebView * caller,
                          WebPageInfo const * const info)
{ p->OnShowPageInfoDialog(caller, *info); }

}   // WebViewListenerDialogMember


class IPrintListenerD
{
  public:
    virtual void onRequestPrint(WebView *) = 0;
    virtual void onFailPrint(WebView *, int) = 0;
    virtual void onFinishPrint(WebView *, int, WebStringArray const * const) = 0;
};


class PrintListenerD2Cpp : public WebViewListener::Print
{
  public:
    PrintListenerD2Cpp(IPrintListenerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~PrintListenerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnRequestPrint(WebView * c)
    { _p->onRequestPrint(c); }

    void OnFailPrint(WebView * c, int id)
    { _p->onFailPrint(c, id); }

    void OnFinishPrint(WebView * c, int id, const WebStringArray& fs)
    { _p->onFinishPrint(c, id, &fs); }

  private:
    IPrintListenerD * _p;
    uint64_t _mid;
};


namespace PrintListenerD2CppMember {
PrintListenerD2Cpp * newCtor(IPrintListenerD * p, uint64_t mid)
{ return new PrintListenerD2Cpp(p, mid); }

void deleteDtor(PrintListenerD2Cpp * p)
{ delete p; }
}


namespace WebViewListenerPrintMember {

void OnRequestPrint(Print * p, WebView * caller)
{ p->OnRequestPrint(caller); }

void OnFailPrint(Print * p, WebView * caller,
                 int request_id)
{ p->OnFailPrint(caller, request_id); }

void OnFinishPrint(Print * p, WebView * caller,
                   int request_id,
                   WebStringArray const * const file_list)
{ p->OnFinishPrint(caller, request_id, *file_list); }

}   // WebViewListenerPrintMember


class IDownloadListenerD
{
  public:
    virtual void onRequestDownload(WebView *, int,
                                   WebURL const * const,
                                   WebString const * const,
                                   WebString const * const) = 0;

    virtual void onUpdateDownload(WebView *, int,
                                  long, long, long) = 0;

    virtual void onFinishDownload(WebView *, int,
                                  WebURL const * const,
                                  WebString const * const) = 0;
};

class DownloadListenerD2Cpp : public WebViewListener::Download
{
  public:
    DownloadListenerD2Cpp(IDownloadListenerD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~DownloadListenerD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnRequestDownload(WebView * c, int id, const WebURL& url,
                           const WebString& sgname, const WebString& mt)
    { _p->onRequestDownload(c, id, &url, &sgname, &mt); }

    void OnUpdateDownload(WebView * c, int id, int64 t, int64 r, int64 cs)
    { _p->onUpdateDownload(c, id, t, r, cs); }

    void OnFinishDownload(WebView * c, int id, const WebURL& url, const WebString& sp)
    { _p->onFinishDownload(c, id, &url, &sp); }

  private:
    IDownloadListenerD * _p;
    uint64_t _mid;
};

namespace DownloadListenerD2CppMember {
DownloadListenerD2Cpp * newCtor(IDownloadListenerD * p, uint64_t mid)
{ return new DownloadListenerD2Cpp(p, mid); }

void deleteDtor(DownloadListenerD2Cpp * p)
{ delete p; }
};


namespace WebViewListenerDownloadMember {

void OnRequestDownload(Download * p, WebView * caller,
                       int download_id,
                       WebURL const * const url,
                       WebString const * const suggested_filename,
                       WebString const * const mime_type)
{ p->OnRequestDownload(caller, download_id, *url, *suggested_filename, *mime_type); }

void OnUpdateDownload(Download * p, WebView * caller,
                      int download_id,
                      int64 total_bytes,
                      int64 received_bytes,
                      int64 current_speed)
{ p->OnUpdateDownload(caller, download_id, total_bytes, received_bytes, current_speed); }

void OnFinishDownload(Download * p, WebView * caller,
                      int download_id,
                      WebURL const * const url,
                      WebString const * const saved_path)
{ p->OnFinishDownload(caller, download_id, *url, *saved_path); }

}   // WebViewListenerDownloadMember


class IInputMethodEditorD
{
  public:
    virtual void onUpdateIME(WebView *, TextInputType, int, int) = 0;
    virtual void onCancelIME(WebView *) = 0;
    virtual void onChangeIMERange(WebView *, unsigned int, unsigned int) = 0;
};

class InputMethodEditorD2Cpp : public WebViewListener::InputMethodEditor
{
  public:
    InputMethodEditorD2Cpp(IInputMethodEditorD * p, uint64_t mid) : _p(p), _mid(mid) {}
    ~InputMethodEditorD2Cpp() { deleteFromMemoryManager(_mid); }

    void OnUpdateIME(WebView * c, TextInputType t, int cx, int cy)
    { _p->onUpdateIME(c, t, cx, cy); }

    void OnCancelIME(WebView * c)
    { _p->onCancelIME(c); }

    void OnChangeIMERange(WebView * c, unsigned int s, unsigned int e)
    { _p->onChangeIMERange(c, s, e); }

  private:
    IInputMethodEditorD * _p;
    uint64_t _mid;
};


namespace InputMethodEditorD2CppMember {
InputMethodEditorD2Cpp * newCtor(IInputMethodEditorD * p, uint64_t mid)
{ return new InputMethodEditorD2Cpp(p, mid); }

void deleteDtor(InputMethodEditorD2Cpp * p)
{ delete p; }
}


namespace WebViewListenerInputMethodEditorMember {

void OnUpdateIME(InputMethodEditor * p, WebView * caller,
                 TextInputType type,
                 int caret_x, int caret_y)
{ p->OnUpdateIME(caller, type, caret_x, caret_y); }

void OnCancelIME(InputMethodEditor * p, WebView * caller)
{ p->OnCancelIME(caller); }

void OnChangeIMERange(InputMethodEditor * p, WebView * caller,
                      unsigned int start, unsigned int end)
{ p->OnChangeIMERange(caller, start, end); }

}   // WebViewListenerInputMethodEditorMember

}   // Awesomium4D
