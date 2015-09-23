module awebview.jsvariable;

import std.algorithm;
import std.conv;
import std.string;
import std.typecons;

import awebview.wrapper;
import awebview.gui.activity;



enum bool isJSExpression(T) = is(typeof((T a){
    string str = a.jsExpr;
    Activity act = a.activity;
}));


mixin template JSExpressionOperators()
{
    import std.format : format;
    import std.range : iota;

    void opAssign(JSExpr)(JSExpr expr)
    if(isJSExpression!JSExpr)
    in{
        assert(expr.activity is this.activity);
    }
    body{
        this.activity.runJS(this.jsExpr ~ '=' ~ expr.jsExpr ~ ';');
    }


    auto opIndex()(string name)
    {
        return this.jsUnaryExpression("%s." ~ name);
    }


    void opIndexAssign(JSExpr)(JSExpr expr, string name)
    if(isJSExpression!JSExpr)
    in{
        assert(expr.activity is this.activity);
    }
    body {
        this.activity.runJS(this.jsExpr ~ '.' ~ name ~ '=' ~ expr.jsExpr ~ ';');
    }


    void opIndexAssign(T)(T expr, string name)
    if(is(typeof(JSValue(expr))))
    {
        this.opIndexAssign(JSValue(expr), name);
    }


    void opIndexAssign(JSValue value, string name)
    {
        if(value.isBoolean){
            if(value.get!bool)
                this.activity.runJS(this.jsExpr ~ '.' ~ name ~ "= true;");
            else
                this.activity.runJS(this.jsExpr ~ '.' ~ name ~ "= false;");
        }else{
            auto c = this.activity.carrierObject;
            c.setProperty("value", value);
            this.activity.runJS(this.jsExpr ~ '.' ~ name ~ "=_carrierObject_.value;");
        }
    }


    auto invoke(T...)(string name, auto ref T args) @system // dmd bug
    {
      static if(T.length == 0)
        return this.jsUnaryExpression("%s." ~ name ~ "()");
      else{
        auto v = activity.newJSVariable();
        foreach(i, ref e; args)
            v[format("value%s", i)] = e;

        auto ret = this.jsBinaryExpression(v, "%1$s." ~ name ~ format("(%(%%2$s.value%s, %))", iota(args.length)));
        return ret;
      }
    }
}


mixin template DOMOperators()
{
    /**
    .innerHTML
    */
    void innerHTML(string html) @property
    {
        this["innerHTML"] = html;
    }


    string innerHTML() @property
    {
        return this["innerHTML"].eval().to!string;
    }


    /**
    See also: HTML.insertAdjacentHTML
    */
    void insertAdjacentHTML(string pos, string html)
    {
        this.invoke("insertAdjacentHTML", pos, html).run();
    }


    /**
    append html to this, which is block element.
    See also: jQuery.append
    */
    void append(string html)
    {
        this.insertAdjacentHTML("beforeend", html);
    }


    /**
    prepend html to this which is block element.
    See also: jQuery.prepend
    */
    void prepend(string html)
    {
        this.insertAdjacentHTML("afterbegin", html);
    }


    /**
    insert html after this.
    See also: jQuery.insertAfter
    */
    void insertAfter(string html)
    {
        this.insertAdjacentHTML("afterend", html);
    }


    /**
    insert html before this.
    See also: jQuery.insertBefore
    */
    void insertBefore(string html)
    {
        this.insertAdjacentHTML("beforebegin", html);
    }
}



mixin template JSExprDOMEagerOperators()
{
    auto _jsExprObj() @property { return this.activity.jsExpression(this.jsExpr); }

    JSValue opIndex()(string name)
    {
        return this._jsExprObj[name].eval;
    }


    void opIndexAssign(JSExpr)(JSExpr expr, string name)
    if(isJSExpression!JSExpr)
    in{
        assert(expr.activity is this.activity);
    }
    body {
        this._jsExprObj[name] = expr;
    }


    void opIndexAssign(T)(T expr, string name)
    if(is(typeof(JSValue(expr))))
    {
        this.opIndexAssign(JSValue(expr), name);
    }


    void opIndexAssign(JSValue value, string name)
    {
        this._jsExprObj[name] = value;
    }


    auto invoke(T...)(string name, auto ref T args)
    {
        return this._jsExprObj.invoke(name, forward!args).eval;
    }


        /**
    .innerHTML
    */
    void innerHTML(string html) @property
    {
        this["innerHTML"] = html;
    }


    string innerHTML() @property
    {
        return this["innerHTML"].to!string;
    }


    /**
    See also: HTML.insertAdjacentHTML
    */
    void insertAdjacentHTML(string pos, string html)
    {
        this.invoke("insertAdjacentHTML", pos, html);
    }


    /**
    append html to this, which is block element.
    See also: jQuery.append
    */
    void append(string html)
    {
        this.insertAdjacentHTML("beforeend", html);
    }


    /**
    prepend html to this which is block element.
    See also: jQuery.prepend
    */
    void prepend(string html)
    {
        this.insertAdjacentHTML("afterbegin", html);
    }


    /**
    insert html after this.
    See also: jQuery.insertAfter
    */
    void insertAfter(string html)
    {
        this.insertAdjacentHTML("afterend", html);
    }


    /**
    insert html before this.
    See also: jQuery.insertBefore
    */
    void insertBefore(string html)
    {
        this.insertAdjacentHTML("beforebegin", html);
    }
}



auto newJSVariable(Activity activity)
{
    static ulong number;

    if(number == 0){
        import std.random : rndGen;

        number = rndGen.front;
        rndGen.popFront();
    }else
        ++number;

    immutable name = "jsv" ~ to!string(number);


    static struct JSVariablePayload
    {
        ~this()
        {
            activity.runJS("delete " ~ _name ~ ";");
        }


        string jsExpr() const @property { return _name; }
        Activity activity() @property { return _activity; }

      private:
        Activity _activity;
        string _name;
    }


    struct RefCountedJSVariable
    {
        RefCounted!JSVariablePayload impl;

        alias impl this;
        mixin JSExpressionOperators!();
    }

    activity.runJS(name ~ ` = {};`);
    return RefCountedJSVariable(RefCounted!JSVariablePayload(activity, name));
}


struct JSExpressionCode
{
    string jsExpr() const @property { return _code; }
    Activity activity() @property { return _activity; }

    mixin JSExpressionOperators!();

  private:
    Activity _activity;
    string _code;
}


JSExpressionCode jsExpression(Activity activity, string jscode)
{
    return JSExpressionCode(activity, jscode);
}


auto jsExpression(Activity activity, JSValue value)
{
    auto v = activity.newJSVariable;
    auto c = activity.carrierObject;

    c.setProperty("value", value);
    v = activity.jsExpression("_carrierObject_.value");

    return v;
}


JSValue eval(JSExpr)(JSExpr expr)
if(isJSExpression!JSExpr)
{
    return expr.activity.evalJS(expr.jsExpr);
}


void run(JSExpr)(JSExpr expr)
if(isJSExpression!JSExpr)
{
    expr.activity.runJS(expr.jsExpr);
}


auto bindToJSVariable(JSExpr)(JSExpr expr)
if(isJSExpression!JSExpr)
{
    auto v = expr.activity.newJSVariable;
    v = activity.jsExpression(expr.jsExpr);
    return v;
}


auto jsBinaryExpression(A, B)(A a, B b, string fmt)
if(isJSExpression!A && isJSExpression!B)
in{
    assert(a.activity == b.activity);
}
body{
    static struct JSBinaryExpression
    {
        Activity activity() @property { return _a.activity; }
        string jsExpr() const @property { return _jsExpr; }

        mixin JSExpressionOperators!();

      private:
        A _a;
        B _b;
        string _jsExpr;
    }


    return JSBinaryExpression(a, b, format(fmt, a.jsExpr, b.jsExpr));
}


auto jsUnaryExpression(A)(A a, string fmt)
if(isJSExpression!A)
{
    static struct JSUnaryExpression
    {
        Activity activity() @property { return _a.activity; }
        string jsExpr() const @property { return _jsExpr; }

        mixin JSExpressionOperators!();

      private:
        A _a;
        string _jsExpr;
    }

    return JSUnaryExpression(a, format(fmt, a.jsExpr));
}
