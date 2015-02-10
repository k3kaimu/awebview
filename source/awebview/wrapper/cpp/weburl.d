module awebview.wrapper.cpp.weburl;


mixin template Awesomium()
{
    interface WebURL
    {
        static struct Field { void* instance_; }
    }
}


mixin template Awesomium4D()
{
    extern(C++, WebURLMember)
    {
        void ctor(Awesomium.WebURL p);
        void ctor(Awesomium.WebURL p, const WebString  url_string);
        void ctor(Awesomium.WebURL p, const Awesomium.WebURL rhs);
        Awesomium.WebURL newCtor();
        Awesomium.WebURL newCtor(const WebString url_string);
        Awesomium.WebURL newCtor(const Awesomium.WebURL rhs);
        void dtor(Awesomium.WebURL p);
        void deleteDtor(Awesomium.WebURL p);
        Awesomium.WebURL opAssign(Awesomium.WebURL p, const Awesomium.WebURL rhs);
        bool IsValid(const Awesomium.WebURL p);
        bool IsEmpty(const Awesomium.WebURL p);
        void spec(const Awesomium.WebURL p, Awesomium.WebString dst);
        void scheme(const Awesomium.WebURL p, Awesomium.WebString dst);
        void username(const Awesomium.WebURL p, Awesomium.WebString dst);
        void password(const Awesomium.WebURL p, Awesomium.WebString dst);
        void host(const Awesomium.WebURL p, Awesomium.WebString dst);
        void port(const Awesomium.WebURL p, Awesomium.WebString dst);
        void path(const Awesomium.WebURL p, Awesomium.WebString dst);
        void query(const Awesomium.WebURL p, Awesomium.WebString dst);
        void anchor(const Awesomium.WebURL p, Awesomium.WebString dst);
        void filename(const Awesomium.WebURL p, Awesomium.WebString dst);
        bool opEquals(const Awesomium.WebURL p, const Awesomium.WebURL other);
        int opCmp(const Awesomium.WebURL p, const Awesomium.WebURL other);
    }
}
