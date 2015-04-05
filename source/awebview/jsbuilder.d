module awebview.jsbuilder;

import awebview.wrapper;
import awebview.gui.activity;

import carbon.utils;

import std.string;
import std.array;
import std.format;

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


    string jsExpr() const @property pure nothrow @safe @nogc
    {
        return _expr;
    }


    JSExpression opIndex(string str)
    {
        return JSExpression(format(`(%s)["%s"]`, _expr, toLiteral(str)));
    }


    JSExpression opIndex(size_t n)
    {
        return JSExpression(format("(%s)[%s]", _expr, n));
    }


    JSExpression invoke(T...)(string name, T args)
    {
        auto app = appender!string();
        app.formattedWrite("(%s).%s(", _expr, name);
        foreach(i, ref e; args){
            static if(isSomeString!(typeof(e)))
                app.put(toLiteral(e));
            else
                app.formattedWrite("%s", e);

            if(i != T.length - 1)
                app.put(",");
        }
        app.put(")");

        return JSExpression(app.data);
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
