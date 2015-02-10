module awebview.wrapper.surface;

import carbon.templates;



struct Surface
{
    pure nothrow @safe @nogc
    this(awebview.wrapper.cpp.Surface surf)
    {
        _cppObj = surf;
    }


    pure nothrow @safe @nogc
    inout(awebview.wrapper.cpp.Surface) cppObj() inout @property
    {
        return _cppObj;
    }


    /*
    WeakRef!(ApplySameTopQualifier!(This, BitmapSurfaceCpp)) opCast(U : const(BitmapSurface), this This)()
    {
        return weakRef!(ApplySameTopQualifier!(This, BitmapSurfaceCpp))
                        (cast(ApplySameTopQualifier!(This, awebview.wrapper.cpp.BitmapSurface))cast(void*)_cppObj);
    }*/

/*
    void paint(const(char)* src, int srcRowSpan, in Rect srcRect, in Rect destRect)
    {
        SurfaceMember.Paint(_cppObj, src, srcRowSpan, &srcRect, &destRect);
    }


    void scroll(int dx, int dy, in Rect clipRect)
    {
        SurfaceMember.Scroll(_cppObj, dx, dy, &clipRect);
    }
*/

  private:
    awebview.wrapper.cpp.Surface _cppObj;
}
