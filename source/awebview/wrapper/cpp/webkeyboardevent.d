module awebview.wrapper.cpp.webkeyboardevent;

mixin template Awesomium()
{
    final class WebKeyboardEvent
    {
        enum Type { keyDown, keyUp, char_ }
        enum Modifiers
        {
            shiftKey = 1 << 0,
            controlKey = 1 << 1,
            altKey = 1 << 2,
            metaKey = 1 << 3,
            isKeypad = 1 << 4,
            isAutorepeat = 1 << 5,
        }

        static struct Field
        {
            Type type;
            int modifiers;
            int virtual_key_code;
            int native_key_code;
            char[20] key_identifier;
            wchar[4] text;
            wchar[4] unmodified_text;
            bool is_system_key;

            WebKeyboardEvent cppObj() { return cast(WebKeyboardEvent)cast(void*)&this; }
        }
    }


    void GetKeyIdentifierFromVirtualKeyCode(int virtual_key_code, char** dst);
}


mixin template Awesomium4D()
{
    extern(C++, WebKeyboardEventMember)
    {
        size_t sizeOfInstance();
        void ctor(WebKeyboardEvent p);
        WebKeyboardEvent newCtor();
        void deleteDtor(WebKeyboardEvent);

      version(Windows)
      {
        void ctor(WebKeyboardEvent, UINT, WPARAM, LPARAM);
        void newCtor(UINT, WPARAM, LPARAM);
      }
      else version(OSX)
      {
        void ctor(WebKeyboardEvent, NSEvent *);
        WebKeyboardEvent newCtor(NSEvent *);
      }
    }

    unittest
    {
        assert(WebKeyboardEventMember.sizeOfInstance()
                    == Awesomium.WebKeyboardEvent.Field.sizeof);
    }
}
