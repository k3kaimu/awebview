module awebview.wrapper.cpp.jsarray;

mixin template Awesomium()
{
    interface JSArray
    {
        static struct Field
        {
            void* vector_;
        }
    }
}

mixin template Awesomium4D()
{
    extern(C++, JSArrayMember)
    {
        size_t sizeOfInstance();
        void ctor(JSArray p);
        void ctor(JSArray p, uint n);
        void ctor(JSArray p, const JSArray rhs);
        JSArray newCtor();
        JSArray newCtor(uint n);
        JSArray newCtor(const JSArray rhs);
        void dtor(JSArray p);
        void deleteDtor(JSArray p);
        JSArray opAssign(JSArray p, const JSArray rhs);
        uint size(const JSArray p);
        uint capacity(const JSArray p);
        JSValue At(JSArray p, uint idx);
        const(JSValue) At(const JSArray p, uint idx);
        JSValue opIndex(JSArray p, uint idx);
        const(JSValue) opIndex(const JSArray p, uint idx);
        void Push(JSArray p, const(JSValue) item);
        void Pop(JSArray p);
        void Insert(JSArray p, const(JSValue) item, uint idx);
        void Erase(JSArray p, uint idx);
        void Clear(JSArray p);
    }

    unittest
    {
        assert(JSArrayMember.sizeOfInstance()
            == JSArray.Field.sizeof);
    }
}
