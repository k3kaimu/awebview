module awebview.wrapper.cpp.webstring;


mixin template Awesomium()
{
    interface WebString
    {
        static struct Field { void* instance_; }
    }
}


mixin template Awesomium4D()
{
    extern(C++, WebStringMember)
    {
        size_t sizeOfInstance();
        void ctor(Awesomium.WebString p);
        void ctor(Awesomium.WebString p, const Awesomium.WebString src, uint pos, uint n);
        void ctor(Awesomium.WebString p, const(ushort)* data);
        void ctor(Awesomium.WebString p, const(ushort)* data, uint len);
        void ctor(Awesomium.WebString p, const Awesomium.WebString src);
        Awesomium.WebString newCtor();
        Awesomium.WebString newCtor(const Awesomium.WebString src, uint pos, uint n);
        Awesomium.WebString newCtor (const(ushort)* data);
        Awesomium.WebString newCtor (const(ushort)* data, uint len);
        Awesomium.WebString newCtor(const Awesomium.WebString src);
        void dtor(Awesomium.WebString p);
        void deleteDtor(Awesomium.WebString p);
        Awesomium.WebString opAssign(Awesomium.WebString p, const Awesomium.WebString rhs);
        void CreateFromUTF8(const(char)* data, uint len, Awesomium.WebString dst);
        const(ushort)* data(const Awesomium.WebString p);
        uint length(const Awesomium.WebString p);
        bool IsEmpty(const Awesomium.WebString p);
        int Compare(const Awesomium.WebString p,  const Awesomium.WebString src);
        Awesomium.WebString Assign(Awesomium.WebString p, const Awesomium.WebString src);
        Awesomium.WebString Assign(Awesomium.WebString p, const Awesomium.WebString src, uint pos, uint n);
        Awesomium.WebString Assign(Awesomium.WebString p, const(ushort)* data);
        Awesomium.WebString Assign(Awesomium.WebString p, const(ushort)* data, uint len);
        Awesomium.WebString Append(Awesomium.WebString p, const Awesomium.WebString src);
        void Clear(Awesomium.WebString p);
        uint ToUTF8(const Awesomium.WebString p, char* dest,  uint len);
        bool opEquals(const Awesomium.WebString p, const Awesomium.WebString other);
        int opCmp(const Awesomium.WebString p, const Awesomium.WebString other);
    }

    unittest{
        assert(WebStringMember.sizeOfInstance()
            == WebString.Field.sizeof);
    }
}
