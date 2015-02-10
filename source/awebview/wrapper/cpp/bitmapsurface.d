module awebview.wrapper.cpp.bitmapsurface;

import awebview.wrapper.cpp;
import awebview.wrapper.cpp.surface;

mixin template Awesomium()
{
    interface BitmapSurface : Awesomium.Surface {}
    interface BitmapSurfaceFactory : SurfaceFactory {}
}

mixin template Awesomium4D()
{
    extern(C++, BitmapSurfaceMember)
    {
        size_t sizeOfInstance();
        void ctor(Awesomium.BitmapSurface p, int width, int height);
        Awesomium.BitmapSurface newCtor(int width, int height);
        void dtor(Awesomium.BitmapSurface p);
        void deleteDtor(Awesomium.BitmapSurface p);
        const(char)* buffer(const Awesomium.BitmapSurface p) ;
        int width(const Awesomium.BitmapSurface p);
        int height(const Awesomium.BitmapSurface p);
        int row_span(const Awesomium.BitmapSurface p);
        void set_is_dirty(Awesomium.BitmapSurface p, bool is_dirty);
        bool is_dirty(const Awesomium.BitmapSurface p);

        void CopyTo(const Awesomium.BitmapSurface p, char* dest_buffer,
                                             int dest_row_span,
                                             int dest_depth,
                                             bool convert_to_rgba,
                                             bool flip_y);

        bool SaveToPNG(const Awesomium.BitmapSurface p, const WebString file_path,
                                                bool preserve_transparency);

        char GetAlphaAtPoint(const Awesomium.BitmapSurface p, int x, int y);

        void Paint(Awesomium.BitmapSurface p, char* src_buffer,
                                      int src_row_span,
                                      const(Rect)* src_rect,
                                      const(Rect)* dest_rect);

        void Scroll(Awesomium.BitmapSurface p, int dx, int dy, const(Rect)* clip_rect);
    }


    extern(C++, BitmapSurfaceFactoryMember)
    {
        size_t sizeOfInstance();
        void ctor(Awesomium.BitmapSurfaceFactory p);
        Awesomium.BitmapSurfaceFactory newCtor();
        void dtor(Awesomium.BitmapSurfaceFactory p);
        void deleteDtor(Awesomium.BitmapSurfaceFactory p);
        Awesomium.Surface CreateSurface(Awesomium.BitmapSurfaceFactory p, Awesomium.WebView view, int width, int height);
        void DestroySurface(Awesomium.BitmapSurfaceFactory p, Awesomium.Surface surface);
    }
}

/*
final class BitmapSurface : ISurface
{
    alias CppObjType = Awesomium.BitmapSurface;

    this(CppObjType cppObj, bool manage) { _obj = cppObj; _manage = manage; }
    this(int width, int height) { this(AweBmSurfMem.newCtor(width, height), true); }
    ~this() { if(_manage) AweBmSurfMem.deleteDtor(_obj); }

    const(char)* bufferPtr() const @property { return AweBmSurfMem.buffer(_obj); }
    const(char)[] buffer() const @property { return this.bufferPtr[0 .. 4 * this.width * this.height]; }

    size_t width() const @property
    {
        int w = AweBmSurfMem.width(_obj);
        assert(w >= 0);
        return w;
    }

    size_t height() const @property
    {
        int h = AweBmSurfMem.height(_obj);
        assert(h >= 0);
        return h;
    }

    size_t rowSpan() const @property
    {
        int ws = AweBmSurfMem.row_span(_obj);
        assert(ws >= 0);
        return ws;
    }

    void isDirty(bool b) @property { AweBmSurfMem.set_is_dirty(_obj, b); }
    bool isDirty(bool b) const @property { return AweBmSurfMem.is_dirty(_obj); }

    void copyTo(const(char)* dst, int dstRowSpan, int dstDepth, bool convToRGBA, bool flipY) const
    { AweBmSurfMem.CopyTo(_obj, dst, dstRowSpan, dstDepth, convToRGBA, flipY); }

    bool saveToPNG(string path, bool presTrans = false) const
    {
        auto str = WebString(path);
        return AweBmSurfMem.SaveToPNG(str.cppObj, presTrans);
    }

    bool saveToJPEG(string path, uint quality = 90) const
    {
        auto str = WebString(path);
        return AweBmSurfMem.SaveToJPEG(str.cppObj, quality);
    }

  override
  {
    void print(const(char)* src, int srcRowSpan, const(Rect)* sr, const(Rect)* dr)
    { AweBmSurfMem.Paint(src, srcRowSpan, sr, dr); }

    void scroll(int dx, int dy, const(Rect)* cr)
    { AweBmSurfMem.Scroll(dx, dy, cr); }

    inout(Awesomium.BitmapSurface) cppObj() inout @property { return _obj; }

    void paint(const(char)* src, uint srcRowSpan, Rect srcR, Rect dstR)
    { AweBmSurfMem.Paint(src, srcRowSpan, &srcR, &dstR); }

    void scroll(int dx, int dy, Rect clipR)
    { AweBmSurfMem.Scroll(dx, dy, &clipR); }
  }

  private:
    CppObjType _obj;
    alias AweBmSurfMem = awebview.BitmapSurfaceMember;
}


final class BitmapSurfaceFactory : ISurfaceFactory
{
    alias CppObjType = Awesomium.BitmapSurfaceFactory;

    this() { _obj = AweBSFM.newCtor(); }
    ~this() { AweBSFM.deleteDtor(_obj); }


    ISurface createSurface(IWebView view, size_t width, size_t height)
    in{
        assert(width <= int.max);
        assert(height <= int.max);
    }
    body{
        Awesomium.Awesomium.Surface cppS = AweBSFM.CreateSurface(_obj, view.cppObj, width, height);
        return new BitmapSurface(cast(Awesomium.BitmapSurface)cppS);
    }


    void destroySurface(ISurface surf)
    {
        AweBSFM.DestroySurface(_obj, surf.cppObj);
    }


  private:
    CppObjType _obj;
    alias AweBSFM = awebview.BitmapSurfaceFactoryMember;
}
*/