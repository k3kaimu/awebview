module awebview.wrapper.cpp.webstringarray;


mixin template Awesomium()
{
    interface WebStringArray
    {
        static struct Field
        {
            void* vector_;
        }
    }
}


mixin template Awesomium4D()
{
    extern(C++, WebStringArrayMember)
    {
        size_t sizeOfInstance();
        void ctor(Awesomium.WebStringArray p);
        void ctor(Awesomium.WebStringArray p, uint n);
        void ctor(Awesomium.WebStringArray p, const Awesomium.WebStringArray rhs);
        Awesomium.WebStringArray newCtor();
        Awesomium.WebStringArray newCtor(uint n);
        Awesomium.WebStringArray newCtor(const Awesomium.WebStringArray rhs);
        void dtor(Awesomium.WebStringArray p);
        void deleteDtor(Awesomium.WebStringArray p);
        Awesomium.WebStringArray opAssign(Awesomium.WebStringArray p, const Awesomium.WebStringArray rhs);
        uint size(const Awesomium.WebStringArray p);
        WebString At(Awesomium.WebStringArray p, uint idx);
        const(Awesomium.WebString) At(const Awesomium.WebStringArray p, uint idx);
        WebString opIndex(Awesomium.WebStringArray p, uint idx);
        const(Awesomium.WebString) opIndex(const Awesomium.WebStringArray p, uint idx);
        void Push(Awesomium.WebStringArray p, const(Awesomium.WebString) item);
    }

    unittest {
        assert(WebStringArrayMember.sizeOfInstance()
            == Awesomium.WebStringArray.Field.sizeof);
    }
}
