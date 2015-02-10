module awebview.wrapper.cpp.jsobject;


mixin template Awesomium()
{
    enum JSObjectType { local, remote, remoteGlobal }

    interface JSObject
    {
        static struct Field
        {
            bool is_local_;
            union U_ {
                void* local;
                void* remote;
            }
            U_ instance_;
            Error last_error_;
        }
    }

    interface JSMethodHandler {}
}


mixin template Awesomium4D()
{
    extern(C++, JSObjectMember)
    {
        size_t sizeOfInstance();
        void ctor(Awesomium.JSObject p);
        void ctor(Awesomium.JSObject p, const(Awesomium.JSObject) obj);
        Awesomium.JSObject newCtor();
        Awesomium.JSObject newCtor(const(Awesomium.JSObject) obj);
        void dtor(Awesomium.JSObject p);
        void deleteDtor(Awesomium.JSObject p);
        Awesomium.JSObject opAssign(Awesomium.JSObject p, const(Awesomium.JSObject) rhs);
        uint remote_id(const(Awesomium.JSObject) p);
        int ref_count(const(Awesomium.JSObject) p);
        JSObjectType type(const(Awesomium.JSObject) p);
        Awesomium.WebView owner(const(Awesomium.JSObject) p);
        void GetPropertyNames(const(Awesomium.JSObject) p, JSArray dst);
        bool HasProperty(const(Awesomium.JSObject) p, const(Awesomium.WebString) name);
        void GetProperty(const(Awesomium.JSObject) p, const(Awesomium.WebString) name, Awesomium.JSValue dst);
        void SetProperty(Awesomium.JSObject p, const(Awesomium.WebString) name, const(JSValue) value);
        void SetPropertyAsync(Awesomium.JSObject p, const(Awesomium.WebString) name, const(Awesomium.JSObject) value);
        void RemoveProperty(Awesomium.JSObject p, const(Awesomium.WebString) name);
        void GetMethodNames(const(Awesomium.JSObject) p, JSArray dst);
        bool HasMethod(const(Awesomium.JSObject) p, const(Awesomium.WebString) name);
        void Invoke(Awesomium.JSObject p, const(Awesomium.WebString) name, const(Awesomium.JSArray) args, Awesomium.JSValue dst);
        void InvokeAsync(Awesomium.JSObject p, const(Awesomium.WebString) name, const(Awesomium.JSArray) args);
        void ToString(const(Awesomium.JSObject) p, Awesomium.WebString dst);
        void SetCustomMethod(Awesomium.JSObject p, const(Awesomium.WebString) name, bool has_return_value);
        Awesomium.Error last_error(const(Awesomium.JSObject) p);
    }

    unittest {
        assert(JSObjectMember.sizeOfInstance()
            == JSObject.Field.sizeof);
    }

    interface IJSMethodHandlerD
    {
        void call(Awesomium.WebView, uint, const(Awesomium.WebString), const(Awesomium.JSArray));
        void callWithReturnValue(Awesomium.WebView, uint, const(Awesomium.WebString), const(Awesomium.JSArray), Awesomium.JSValue);
    }


    interface JSMethodHandlerD2Cpp : awebview.wrapper.cpp.JSMethodHandler {}

    extern(C++, JSMethodHandlerD2CppMember)
    {
      version(Windows)
      {
        JSMethodHandlerD2Cpp newCtor(IJSMethodHandlerD, ulong);
        void deleteDtor(JSMethodHandlerD2Cpp);
      }
      else
      {
        void* newCtor(void*, ulong);
        void deleteDtor(void*);

        JSMethodHandlerD2Cpp newCtor(IJSMethodHandlerD p, ulong mid)
        { return cast(JSMethodHandlerD2Cpp)newCtor(cast(void*)p, mid); }

        void deleteDtor(JSMethodHandlerD2Cpp p)
        { deleteDtor(cast(void*)p); }
      }
    }

    extern(C++, JSMethodHandlerMember)
    {
        void dtor(Awesomium.JSMethodHandler p);
        void deleteDtor(Awesomium.JSMethodHandler p);

        void OnMethodCall(Awesomium.JSMethodHandler p,
                          Awesomium.WebView caller,
                          uint remote_object_id,
                          const(Awesomium.WebString) method_name,
                          const(Awesomium.JSArray) args);

        void OnMethodCallWithReturnValue(Awesomium.JSMethodHandler p,
                                         Awesomium.WebView caller,
                                         uint remote_object_id,
                                         const(Awesomium.WebString) method_name,
                                         const(Awesomium.JSArray) args,
                                         JSValue dst);

    }
}
