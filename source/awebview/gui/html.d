module awebview.gui.html;

import carbon.utils;
import awebview.gui.activity;
import awebview.gui.methodhandler;

import awebview.wrapper.jsobject,
       awebview.wrapper.jsvalue,
       awebview.wrapper.weakref;

import std.variant;

import std.array : appender;
import std.format : formattedWrite;
import std.algorithm : forward;
import std.conv : to;

public import carbon.event : FiredContext;
import carbon.templates : Lstr;
import carbon.utils : toLiteral;



string buildHTMLTagAttr(in string[string] attrs)
{
    auto app = appender!string();
    foreach(k, v; attrs)
        app.formattedWrite("%s=%s ", k, toLiteral(v));

    return app.data;
}


string buildHTMLTagAttr(string tag, string value)
{
    import std.string : format;
    return format("%s=%s ", tag, toLiteral(value));
}

unittest
{
    assert(buildHTMLTagAttr("a", "b") == "a=b ");
    assert(buildHTMLTagAttr(["a", "b"]) == "a=b");
}


abstract class HTMLPage
{
    this(string id)
    {
        _id =  id;
    }


    string id() const @property { return _id; }


    string html() const @property;


    inout(HTMLElement[string]) elements() inout @property;


    void onUpdate() {}


    void onStart(Activity activity)
    {
        _activity = activity;
        foreach(key, elem; elements)
            elem.onStart(activity);
    }


    void onAttach(bool isInitPhase)
    {
        foreach(key, elem; elements)
            elem.onAttach(isInitPhase);
    }


    void onDetach()
    {
        foreach(key, elem; elements)
            elem.onDetach();
    }


    void onLoad(bool isInit)
    {
        foreach(key, elem; elements)
            elem.onLoad(isInit);
    }


    @property
    inout(Activity) activity() inout
    {
        return _activity;
    }


  private:
    Activity _activity;
    string _id;
}


class TemplateHTMLPage(string form) : HTMLPage
{
    this(string id, Variant[string] exts = null)
    {
        super(id);
        _exts = exts;
    }


    override
    @property
    string html() const
    {
        return mixin(Lstr!(form));
    }


    override
    @property
    inout(HTMLElement[string]) elements() inout { return _elems; }


    void opOpAssign(string op : "~")(HTMLElement element)
    {
        addElement(element);
    }


    void addElement(HTMLElement element)
    {
        _elems[element.id] = element;
    }


    @property
    inout(Variant[string]) exts() inout { return _exts; }


  private:
    HTMLElement[string] _elems;
    Variant[string] _exts;
}



class HTMLElement
{
    this(string id, bool doCreateObject)
    {
        _id = id;
        _hasObj = doCreateObject;
    }


    @property
    bool hasObject() pure nothrow @safe @nogc
    {
        return _hasObj;
    }


    @property
    WeakRef!JSObject jsobject()
    in {
        assert(_v.isObject);
    }
    body {
        return _v.get!(WeakRef!JSObject);
    }


    @property string id() const { return _id; }


    @property string html() const { return ""; }


    @property pure nothrow @safe @nogc
    inout(Activity) activity() inout
    {
        return _activity;
    }


    void onStart(Activity activity)
    {
        _activity = activity;

        if(this.hasObject){
            _v = activity.createObject(_id);
            assert(_v.isObject);
        }
    }


    void onDestroy()
    {
        _activity = null;
        _v = JSValue.null_;
    }


    void onAttach(bool isInit) {}


    void onDetach() {}


    void onLoad(bool isInit)
    {
        foreach(key, ref v; _staticProperties)
            this.opIndexAssign(v, key);
    }


    void staticSet(T)(string name, T value)
    if(is(typeof(JSValue(value)) : JSValue))
    {
        JSValue jv = JSValue(value);
        _staticProperties[name] = jv;
        if(this.activity){
            this.opIndexAssign(jv, name);
        }
    }


    void opIndexAssign(T)(T value, string name)
    if(is(typeof(JSValue(value)) : JSValue))
    {
        this.opIndexAssign(JSValue(value), name);
    }


    void opIndexAssign(JSValue value, string name)
    {
        if(value.isBoolean){
            if(value.get!bool)
                activity.runJS(mixin(Lstr!
                    q{document.getElementById("%[id%]").%[name%] = true;}
                ));
            else
                activity.runJS(mixin(Lstr!
                    q{document.getElementById("%[id%]").%[name%] = false;}
                ));
        }else{
            auto carrier = activity.carrierObject;
            carrier.setProperty("value", value);

            activity.runJS(mixin(Lstr!
                q{document.getElementById("%[id%]").%[name%] = _carrierObject_.value;}
            ));
        }
    }


    JSValue opIndex(string name)
    {
        JSValue jv = activity.evalJS(mixin(Lstr!
            q{document.getElementById("%[id%]").%[name%];}
        ));

        return jv;
    }


    void invoke(T...)(string name, auto ref T args)
    {
      static if(T.length == 0)
        activity.evalJS(mixin(Lstr!
            q{document.getElementById("%[id%]").%[name%]();}
        ));
      else{
        auto carrier = activity.carrierObject;
        foreach(i, ref e; args)
            carrier.setProperty(format("value%s", i), JSValue(e));

        activity.evalJS(mixin(Lstr!
            q{document.getElementById("%[id%]").%[name%](%[format("%(_carrierObject_.value%s,%)", iota(args.length))%]);}
        ));
      }
    }


  private:
    string _id;
    bool _hasObj;
    JSValue _v;
    Activity _activity;
    JSValue[string] _staticProperties;
}



class IDOnlyElement : HTMLElement
{
    this(string id)
    {
        super(id, false);
    }
}


/**
Example:
----------------------
class MyButton : TemplateHTMLElement!(HTMLElement,
    q{<input type="button" id="%[id%]" value="Click me!">})
{
    this(string id)
    {
        super(id, null, false);
    }
}

auto btn1 = new MyButton("btn1");
assert(btn1.html == q{<input type="button" id="btn1" value="Click me!">});
----------------------
*/
class TemplateHTMLElement(Element, string form) : Element
if(is(Element : HTMLElement))
{
    this(T...)(auto ref T args)
    {
        import std.algorithm : forward;

      static if(is(typeof(super(forward!args[0 .. $-1]))) &&
                is(typeof(args[$-1]) : Variant[string]))
      {
        super(forward!args[0 .. $-1]);
        _exts = args[$-1];
      }
      else
        super(forward!args);
    }


    @property
    inout(Variant[string]) exts() inout { return _exts; }


    override
    @property
    string html() const
    {
        import carbon.templates : Lstr;
        return mixin(Lstr!(form));
    }


  private:
    Variant[string] _exts;
}


/// ditto
alias TemplateHTMLElement(string form) = TemplateHTMLElement!(HTMLElement, form);


/**
Example:
----------------
class MyButton : DefineSignals!(DeclareSignals!(HTMLElement, "onClick"), "onClick")
{
    this(string id)
    {
        super(id, true);
    }

    string html() const { ... }
}


MyButton btn1 = new MyButton("btn1");
btn1.onClick.strongConnect(delegate(FiredContext ctx, WeakRef!(const(JSArrayCpp)) arr){
    assert(ctx.sender == btn1);

    writeln("fired a signal by ", ctx);
});
----------------
*/
class DefineSignals(Element, names...) : Element
if(is(Element : HTMLElement) && names.length >= 1)
{
    import carbon.event;

    this(T...)(auto ref T args)
    {
        super(forward!args);
    }


    mixin(genMethod());


  private:
    mixin(genField());

    static
    {
        string genField()
        {
            auto app = appender!string;
            foreach(s; names)
                app.formattedWrite("EventManager!(WeakRef!(const(JSArrayCpp))) _%sEvent;\n", s);

            return app.data;
        }


        string genMethod()
        {
            auto app = appender!string;
            foreach(s; names){
                app.formattedWrite("ref RestrictedSignal!(FiredContext, WeakRef!(const(JSArrayCpp))) %1$s() { return _%1$sEvent; }\n", s);
                app.formattedWrite("override void %1$s(WeakRef!(const(JSArrayCpp)) arr) { _%1$sEvent.emit(this, arr); }\n", s);
            }

            return app.data;
        }
    }
}


/**
Example:
-------------------
class MyButton : DeclareSignals!(HTMLElement, "onClick")
{
    this(string id)
    {
        super(id, true);
    }


    override
    void onClick(WeakRef!(JSArrayCpp) args)
    {
        writeln("OK");
    }
}
-------------------
*/
abstract class DeclareSignals(Element, names...) : Element
if(is(Element : HTMLElement) && names.length >= 1)
{
    this(T...)(auto ref T args)
    {
        super(forward!args);
    }


    mixin(genDeclMethods);

    override
    void onStart(Activity activity)
    {
        super.onStart(activity);
        activity.methodHandler.set(this);
    }


  private:
    static
    {
        string genDeclMethods()
        {
            auto app = appender!string();

            foreach(s; names)
                app.formattedWrite(`@JSMethodTag("%1$s"w) `"void %1$s(WeakRef!(const(JSArrayCpp)));\n", s);

            return app.data;
        }
    }
}


alias DeclDefSignals(Element, names...) = DefineSignals!(DefineSignals!(Element, names), names);
