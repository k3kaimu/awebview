module awebview.jsbuilder;

import awebview.wrapper;
import awebview.gui.activity;

import carbon.utils;

import std.string;

struct JSExpression
{
    this(string jsexpr)
    {
        _expr = jsexpr;
    }


    static
    JSExpression literal(Int)(Int n)
    if(is(Int : ulong))
    {
        return JSExpression(to!string(n));
    }


    static
    JSExpression literal(string str)
    {
        return JSExpression(toLiteral(str));
    }


    static
    JSExpression literal(bool b)
    {
        return JSExpression(b ? "true" : "false");
    }


    JSExpression opIndex(string str)
    {
        return JSExpression(format("(%s).%s", _expr, toLiteral(str)));
    }


    JSExpression opIndex(size_t n)
    {
        return JSExpression(format("(%s)[%s]", _expr, n));
    }


    JSValue evalOn(Activity activity)
    {
        return activity.evalJS(_expr);
    }


    T evalOn(T)(Activity activity)
    {
        return activity.evalJS(_expr).get!T;
    }


  private:
    string _expr;
}
