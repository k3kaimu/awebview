module awebview.wrapper.cpp.jsvalue;


mixin template Awesomium()
{
    interface JSValue
    {
        static struct Field { void* value_; }
    }
}


mixin template Awesomium4D()
{
    extern(C++, JSValueMember)
    {
        size_t sizeOfInstance();
        void ctor(JSValue p);
        void ctor(JSValue p, bool value);
        void ctor(JSValue p, int value);
        void ctor(JSValue p, double value);
        void ctor(JSValue p, const(WebString) value);
        void ctor(JSValue p, const(JSObject) value);
        void ctor(JSValue p, const(JSArray) value);
        void ctor(JSValue p, const(JSValue) original);
        JSValue newCtor();
        JSValue newCtor(bool value);
        JSValue newCtor(int value);
        JSValue newCtor(double value);
        JSValue newCtor(const(WebString) value);
        JSValue newCtor(const(JSObject) value);
        JSValue newCtor(const(JSArray) value);
        JSValue newCtor(const(JSValue) original);
        void dtor(JSValue p);
        void deleteDtor(JSValue p);
        JSValue opAssign(JSValue p, const(JSValue) rhs);
        const(JSValue) Undefined();
        const(JSValue) Null();
        bool IsBoolean(const JSValue p);
        bool IsInteger(const(JSValue) p);
        bool IsDouble(const(JSValue) p);
        bool IsNumber(const(JSValue) p);
        bool IsString(const(JSValue) p);
        bool IsArray(const(JSValue) p);
        bool IsObject(const(JSValue) p);
        bool IsNull(const(JSValue) p);
        bool IsUndefined(const(JSValue) p);
        void ToString(const(JSValue) p, WebString dst);
        int ToInteger(const JSValue p);
        double ToDouble(const JSValue p);
        bool ToBoolean(const JSValue p);
        JSArray ToArray(JSValue p);
        const(JSArray) ToArray(const(JSValue) p);
        JSObject ToObject(JSValue p);
        const(JSObject) ToObject(const(JSValue) p);
    }

    unittest {
        assert(JSValueMember.sizeOfInstance()
            == JSValue.Field.sizeof);

        static struct JSValueD {;
            JSValue cppObj() @nogc nothrow @trusted { return cast(JSValue)cast(void*)&_field; }
            private JSValue.Field _field;
        }
    }
}
