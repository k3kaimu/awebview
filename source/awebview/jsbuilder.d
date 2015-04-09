module awebview.jsbuilder;

import awebview.wrapper;
import awebview.gui.activity;

import carbon.utils;

import std.string;
import std.array;
import std.format;
import std.traits;


struct JSExpression
{
    this(string jsexpr, Activity activity = null)
    {
        _expr = jsexpr;
        _activity = activity;
    }


    static
    JSExpression literal(Int)(Int n, Activity activity = null)
    if(is(Int : ulong))
    {
        return JSExpression(to!string(n), activity);
    }


    static
    JSExpression literal(string str, Activity activity = null)
    {
        return JSExpression(toLiteral(str), activity);
    }


    static
    JSExpression literal(bool b, Activity activity = null)
    {
        return JSExpression(b ? "true" : "false", activity);
    }


    string jsExpr() const @property pure nothrow @safe @nogc
    {
        return _expr;
    }


    JSExpression opIndex(string str)
    {
        return JSExpression(format(`(%s)[%s]`, _expr, toLiteral(str)), _activity);
    }


    JSExpression opIndexAssign(JSExpression rhs, string str)
    {
        return JSExpression(format(`(%s)[%s] = (%s)`, _expr, toLiteral(str), rhs._expr), _activity);
    }


    JSExpression opIndexAssign(T)(T rhs, string str)
    if(is(typeof(JSExpression.literal(rhs)) == JSExpression))
    {
        return opIndexAssign(literal(rhs), str);
    }


    JSExpression opIndex(size_t n)
    {
        return JSExpression(format("(%s)[%s]", _expr, n), _activity);
    }


    JSExpression opIndexAssign(JSExpression rhs, size_t n)
    {
        return JSExpression(format(`(%s)[%s] = (%s)`, _expr, n, rhs._expr), _activity);
    }


    JSExpression opIndexAssign(T)(T rhs, size_t n)
    if(is(typeof(JSExpression.literal(rhs)) == JSExpression))
    {
        return opIndexAssign(literal(rhs), n);
    }


    JSExpression invoke(S, T...)(S name, T args)
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

        return JSExpression(app.data, _activity);
    }


    JSExpression invoke(string name, T...)(T args)
    {
        return invoke(name, args);
    }


    JSValue eval()
    {
        return evalOn(_activity);
    }


    void run()
    {
        runOn(_activity);
    }


    JSValue evalOn(Activity activity)
    {
        return activity.evalJS(_expr);
    }


    void runOn(Activity activity)
    {
        activity.runJS(_expr);
    }


    T eval(T)()
    {
        return evalOn!T(_activity);
    }


    T evalOn(T)(Activity activity)
    {
        return activity.evalJS(_expr).get!T;
    }


    Activity activity() @property pure nothrow @safe @nogc { return _activity; }


  private:
    string _expr;
    Activity _activity;
}


//auto querySelector(Activity activity, string query)
//{
//    return JSExpression(format(q{document.querySelector(%s)}), toLiteral(query), activity);
//}


//auto querySelectorAll(Activity activity, string query)
//{
//    return JSExpression(format(q{document.querySelectorAll(%s)}), toLiteral(query), activity);
//}
