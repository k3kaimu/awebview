module awebview.wrapper.printconfig;

import awebview.wrapper.cpp;
public import awebview.wrapper.cpp : Rect;


struct PrintConfig
{
    awebview.wrapper.cpp.PrintConfig cppInstance;
    alias cppInstance this;


    static PrintConfig opCall()
    {
        PrintConfig dst = { awebview.wrapper.cpp.PrintConfig() };
        return dst;
    }


    @property
    inout(awebview.wrapper.cpp.PrintConfig)* cppObj() inout
    {
        return &cppInstance;
    }
}
