module awebview.wrapper.cpp.surface;

mixin template Awesomium()
{
    interface Surface {}
    interface SurfaceFactory {}
}


mixin template Awesomium4D()
{
    interface ISurfaceD
    {
        void paint(const(char)* src, int srcRowSpan, const(Rect)* sR, const(Rect)* dR);
        void scroll(int dx, int dy, const(Rect)* clipR);
    }

    interface SurfaceD2Cpp : Awesomium.Surface {}
    extern(C++, SurfaceD2CppMember)
    {
        SurfaceD2Cpp newCtor(ISurfaceD);
        void deleteDtor(SurfaceD2Cpp);
    }

    interface ISurfaceFactoryD
    {
        Awesomium.Surface createSurface(Awesomium.WebView view, int width, int heigth);
        void destroySurface(Awesomium.Surface surf);
    }

    interface SurfaceFactoryD2Cpp : Awesomium.SurfaceFactory {}
    extern(C++, SurfaceFactoryD2CppMember)
    {
        SurfaceFactoryD2Cpp newCtor(ISurfaceFactoryD);
        void deleteDtor(SurfaceFactoryD2Cpp);
    }


    extern(C++, SurfaceMember)
    {
        void dtor(Awesomium.Surface);
        void deleteDtor(Awesomium.Surface);
        void Paint(Awesomium.Surface, char*, int, const(Rect)*, const(Rect)*);
        void Scroll(Awesomium.Surface, int, int, const(Rect)*);
    }


    extern(C++, SurfaceFactoryMember)
    {
        void dtor(Awesomium.SurfaceFactory p);
        void deleteDtor(Awesomium.SurfaceFactory p);
        Awesomium.Surface CreateSurface(Awesomium.SurfaceFactory p, Awesomium.WebView view, int w, int h);
        void DestroySurface(Awesomium.SurfaceFactory p, Awesomium.Surface sf);
    }
}

/+
/**
*/
interface ISurface : Awesomium.ISurfaceD
{
    inout(Awesomium.Surface) cppObj() inout @property;
    void paint(const(char)* src, uint srcRowSpan, Rect sR, Rect dR);
    void scroll(int dx, int dy, Rect clipR);
}


final class SurfaceCpp2D : ISurface
{
    this(Awesomium.Surface surf, bool manage)
    { _obj = surf; _manage = manage; }

    ~this(){ if(_manage) AweSM.deleteDtor(surf); }

  override
  {
    void paint(const(char)* src, int srcRowSpan, const(Rect)* sR, const(Rect)* dR)
    { AweSM.Print(_obj. src, srcRowSpan, sR, dR); }

    void scroll(int dx, int dy, const(Rect)* clipR)
    { AweSM.Scroll(_obj, dx, dy, clipR); }

    inout(Awesomium.Surface) cppObj() inout @property { return _obj; }

    void paint(const(char)* src, uint srcRowSpan, Rect sR, Rect dR)
    { this.print(src, srcRowSpan, &sR, &dR); }

    void scroll(int dx, int dy, Rect clipR)
    { this.scroll(dx, dy, &clipR); }
  }

  private:
    Awesomium.Surface _obj;

    alias AweSM = awebview.SurfaceMember;
} 


/**
*/
interface ISurfaceFactory : Awesomium.ISurfaceFactoryD
{
    inout(Awesomium.SurfaceFactory) cppObj() inout @property;
    ISurface createSurface(IWebView view, uint width, uint height);
    void destroySurface(ISurface sf);
}


final class SurfaceFactoryCpp2D : ISurfaceFactory
{
    this(Awesomium.SurfaceFactory sf, bool manage = false)
    { _obj = sf; _manage = manage; }

    ~this() { if(_manage) AweSFM.deleteDtor(sf); }

  override
  {
    Awesomium.Surface createSurface(Awesomium.WebView view, int width, int heigth)
    { AweSFM.CreateSurface(_obj, view, width, height); }

    void destroySurface(Awesomium.Surface surf)
    { AweSFM.DestroySurface(_obj, surf); }

    inout(Awesomium.SurfaceFactory) cppObj() inout @property { return _obj; }

    ISurface createSurface(IWebView view, uint width, uint height)
    { new SurfaceCpp2D(view.cppObj, width, height); }

    void destroySurface(ISurface sf)
    { destroySurface(sf.cppObj); }
  }


  private:
    Awesomium.SurfaceFactory _obj;
    bool _manage;

    alias AweSFM = awebview.SurfaceFactoryMember;
}
+/