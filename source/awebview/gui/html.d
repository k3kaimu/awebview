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
        foreach(key, elem; elements)
            elem.onStart(activity);
    }


    void onAttach()
    {
        foreach(key, elem; elements)
            elem.onAttach();
    }


    void onDetach()
    {
        foreach(key, elem; elements)
            elem.onDetach();
    }


    void postLoad()
    {
        foreach(key, elem; elements)
            elem.postLoad();
    }


  private:
    Activity _activity;
    string _id;
}


class TemplateHTMLPage(string form) : HTMLPage
{
    this(string id)
    {
        super(id);
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


  private:
    HTMLElement[string] _elems;
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


    WeakRef!JSObject jsobject()
    in {
        assert(_v.isObject);
    }
    body {
        return _v.get!(WeakRef!JSObject);
    }


    string id() const @property
    {
        return _id;
    }


    string html() const @property
    {
        return "";
    }


    @property pure nothrow @safe @nogc
    Activity activity()
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


    //void onStop()
    //{
    //    _activity = null;
    //    _v = JSValue.null_;
    //}


    void onAttach() {}


    void onDetach() {}


    void postLoad()
    {
        foreach(key, ref v; _cachedProperties)
            this.opIndexAssign(v, key);
    }


    void opIndexAssign(T)(T value, string name)
    if(is(typeof(JSValue(value)) : JSValue))
    {
        this.opIndexAssign(JSValue(value), name);
    }


    void opIndexAssign(JSValue value, string name)
    {
        _cachedProperties[name] = value;

        auto carrier = activity.carrierObject;
        carrier.setProperty("value", value);

        activity.runJS(_cache("value_set", mixin(Lstr!
            q{document.getElementById(%[toLiteral(id)%]).%[name%] = _carrierObject_.value;}
        )));
    }


    JSValue opIndex(string name)
    {
        JSValue jv = activity.evalJS(_cache("value_get", mixin(Lstr!
            q{document.getElementById(%[toLiteral(id)%]).%[name%];}
        )));

        return jv;
    }


  private:
    string _id;
    bool _hasObj;
    JSValue _v;
    Activity _activity;
    Cache!(string[string]) _cache;
    JSValue[string] _cachedProperties;
}


/**
Example:
----------------------
class MyButton : TemplateHTMLElement!(Element, import(`my_button.html`))
{
    this(string id)
    {
        super(id, false);
    }
}

auto btn1 = new MyButton("btn1");
assert(btn1.html == q{<input type="button" id="btn1" value="Click me!">});

// my_button.html
<input type="button" id="%[id%]" value="Click me!">
----------------------
*/
class TemplateHTMLElement(Element, string form) : Element
if(is(Element : HTMLElement))
{
    this(T...)(auto ref T args)
    {
        import std.algorithm : forward;
        super(forward!args);
    }


    override
    @property
    string html() const
    {
        import carbon.templates : Lstr;
        return mixin(Lstr!(form));
    }
}


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
