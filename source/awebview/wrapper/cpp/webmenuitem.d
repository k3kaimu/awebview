module awebview.wrapper.cpp.webmenuitem;


mixin template Awesomium()
{
    enum WebMenuItemType { option, checkableOption, group, separator }

    align(1) struct WebMenuItem
    {
        WebMenuItemType type;
        WebString.Field label;
        WebString.Field tooltip;
        uint action;
        bool right_to_left;
        bool has_directional_override;
        bool enabled;
        bool checked;
    }


    interface WebMenuItemArray
    {
        static struct Field { void* vector_; }
    }
}


mixin template Awesomium4D()
{
    extern(C++, WebMenuItemArrayMember)
    {
        size_t sizeOfInstance();
        void ctor(WebMenuItemArray p);
        void ctor(WebMenuItemArray p, uint n);
        void ctor(WebMenuItemArray p, const WebMenuItemArray rhs);
        WebMenuItemArray newCtor();
        WebMenuItemArray newCtor(uint n);
        WebMenuItemArray newCtor(const WebMenuItemArray rhs);
        void dtor(WebMenuItemArray p);
        void deleteDtor(WebMenuItemArray p);
        WebMenuItemArray opAssign(WebMenuItemArray p, const WebMenuItemArray rhs);
        uint size(const WebMenuItemArray p);
        WebMenuItem* At(WebMenuItemArray p, uint idx);
        const(WebMenuItem*) At(const WebMenuItemArray p, uint idx);
        WebMenuItem* opIndex(WebMenuItemArray p, uint idx);
        const(WebMenuItem*) opIndex(const WebMenuItemArray p, uint idx);
        void Push(WebMenuItemArray p, const WebMenuItem* item);
    }

    unittest {
        assert(WebMenuItemArrayMember.sizeOfInstance
            == WebMenuItemArray.Field.sizeof);
    }
}
