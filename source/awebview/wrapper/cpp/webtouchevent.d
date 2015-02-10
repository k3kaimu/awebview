module awebview.wrapper.cpp.webtouchevent;

mixin template Awesomium()
{
    enum WebTouchPointState { undefined, released, pressed, moved, stationary, cancelled, }

    align(1) struct WebTouchPoint {
        int id;
        WebTouchPointState state;
        int screen_position_x;
        int screen_position_y;
        int position_x;
        int position_y;
        int radius_x;
        int radius_y;
        float rotation_angle;
        float force;
    }

    enum WebTouchEventType { start, move, end, cancel }

    align(1) struct WebTouchEvent {
        WebTouchEventType type;
        uint touches_length;
        WebTouchPoint[8] touches;
        uint changed_touches_length;
        WebTouchPoint[8] changed_touches;
        uint target_touches_length;
        WebTouchPoint[8] target_touches;
    }
}


mixin template Awesomium4D()
{
    extern(C++, WebTouchPointMember)
    {
        size_t sizeOfInstance();
        void ctor(WebTouchPoint * p);
        WebTouchPoint * newCtor();
        void deleteDtor(WebTouchPoint *);
    }

    unittest {
        assert(WebTouchPointMember.sizeOfInstance()
            == Awesomium.WebTouchPoint.sizeof);
    }

    extern(C++, WebTouchEventMember)
    {
        size_t sizeOfInstance();
        void ctor(WebTouchEvent * p);
        WebTouchEvent * newCtor();
        void deleteDtor(WebTouchEvent *);
    }

    unittest {
        assert(WebTouchEventMember.sizeOfInstance()
            == Awesomium.WebTouchEvent.sizeof);
    }
}
