module awebview.wrapper.cpp.resourceinterceptor;


mixin template Awesomium()
{
    interface ResourceInterceptor {}
    interface ResourceRequest {}
    interface ResourceResponse {}
    interface UploadElement {}
}


mixin template Awesomium4D()
{
    interface IResourceInterceptorD
    {
        Awesomium.ResourceResponse onRequest(Awesomium.ResourceRequest req);
        bool onFilterNavigation(int opid, int orid,
                                const(Awesomium.WebString) method,
                                const(Awesomium.WebURL) url,
                                bool is_main_frame);
        void onWillDownload(int opid, int orid,
                            const(Awesomium.WebURL) url);
    }


    interface ResourceInterceptorD2Cpp : Awesomium.ResourceInterceptor {}
    extern(C++, ResourceInterceptorD2CppMember)
    {
        ResourceInterceptorD2Cpp newCtor(IResourceInterceptorD, ulong);
        void deleteDtor(ResourceInterceptorD2Cpp);
    }

    extern(C++, ResourceInterceptorMember)
    {
        void ctor(ResourceInterceptor p);
        ResourceInterceptor newCtor();
        void dtor(ResourceInterceptor p);
        void deleteDtor(ResourceInterceptor p);

        ResourceResponse OnRequest(ResourceInterceptor p,
                                    ResourceRequest request);

        bool OnFilterNavigation(ResourceInterceptor p,
                                int origin_process_id,
                                int origin_routing_id,
                                const WebString method,
                                const WebURL url,
                                bool is_main_frame);

        void OnWillDownload(ResourceInterceptor p,
                            int origin_process_id,
                            int origin_routing_id,
                            const WebURL url);
    }


    interface IResourceRequestD
    {
        void cancel();
        int originProcessId() const;
        int originRoutingId() const;
        void getUrl(WebURL dst) const;
        void getMethod(WebString dst) const;
        void setMethod(const(WebString) m);
        void getReferrer(WebString dst) const;
        void setReferrer(const(WebString) r);
        void getExtraHandlers(WebString dst) const;
        void setExtraHeaders(const(WebString) eh);
        void appendExtraHeader(const(WebString) name, const(WebString) value);
        uint numUploadElements() const;
        const(Awesomium.UploadElement) getUploadElement(uint idx) const;
        void clearUploadElements();
        void appendUploadFilePath(const(WebString) path);
        void appendUploadBytes(const(char)* bytes, uint num_bytes);
        void ignoreDataSourceHandler(bool ignore) @property;
    }


    interface ResourceRequestD2Cpp : Awesomium.ResourceRequest {}
    extern(C++, ResourceRequestD2CppMember)
    {
        ResourceRequestD2Cpp newCtor(IResourceRequestD p, ulong);
        void deleteDtor(ResourceRequestD2Cpp p);
    }


    extern(C++, ResourceRequestMember)
    {
        void Cancel(Awesomium.ResourceRequest p);
        int origin_process_id(const(Awesomium.ResourceRequest) p);
        int origin_routing_id(const(Awesomium.ResourceRequest) p);
        void url(const(Awesomium.ResourceRequest) p, Awesomium.WebURL dst);
        void method(const(Awesomium.ResourceRequest) p, Awesomium.WebString dst);
        void set_method(Awesomium.ResourceRequest p, const(Awesomium.WebString) method);
        void referrer(const(Awesomium.ResourceRequest) p, Awesomium.WebString dst);
        void set_referrer(Awesomium.ResourceRequest p, const(Awesomium.WebString) referrer);
        void extra_headers(const(Awesomium.ResourceRequest) p, Awesomium.WebString dst);
        void set_extra_headers(Awesomium.ResourceRequest p, const(Awesomium.WebString) headers);
        void AppendExtraHeader(Awesomium.ResourceRequest p, const(Awesomium.WebString) name, const(Awesomium.WebString) value);
        uint num_upload_elements(const(Awesomium.ResourceRequest) p);
        const(void)* GetUploadElement(const(Awesomium.ResourceRequest) p, uint idx);
        void ClearUploadElements(Awesomium.ResourceRequest p);
        void AppendUploadFilePath(Awesomium.ResourceRequest p, const(Awesomium.WebString) path);
        void AppendUploadBytes(Awesomium.ResourceRequest p, const(char)* bytes, uint num_bytes);
        void set_ignore_data_source_handler(Awesomium.ResourceRequest p, bool ignore);
    }


    interface IResourceResponseD {}
    interface ResourceResponseD2Cpp : Awesomium.ResourceResponse {}
    extern(C++, ResourceResponseD2CppMember) {}

    extern(C++, ResourceResponseMember)
    {
        ResourceResponse Create(uint num_bytes, const(ubyte)* buffer, const WebString mime_type);
        ResourceResponse Create(const WebString file_path);
    }


    interface IUploadElementD
    {
        bool isFilePath() const;
        bool isBytes() const;
        uint numBytes() const;
        const(ubyte)* bytes() const;
        void getFilePath(Awesomium.WebString dst) const;
    }

    interface UploadElementD2Cpp : Awesomium.UploadElement {}

    extern(C++, UploadElementD2CppMember)
    {
        UploadElementD2Cpp newCtor(IUploadElementD p, ulong);
        void deleteDtor(UploadElementD2Cpp);
    }

    extern(C++, UploadElementMember)
    {
        bool IsFilePath(const UploadElement p);
        bool IsBytes(const UploadElement p);
        uint num_bytes(const UploadElement p);
        const(ubyte)* bytes(const UploadElement p);
        void file_path(const UploadElement p, WebString dst);
    }
}
