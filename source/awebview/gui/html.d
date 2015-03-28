module awebview.gui.html;

import carbon.utils;
import awebview.gui.activity;
import awebview.gui.methodhandler;
import awebview.gui.application;

import awebview.wrapper.jsobject,
       awebview.wrapper.jsvalue,
       awebview.wrapper.weakref;

import std.variant;

import std.array : appender;
import std.format : formattedWrite;
import std.functional : forward;
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
    assert(buildHTMLTagAttr(["a": "b"]) == "a=b ");
}


abstract class HTMLPage
{
    this(string id)
    {
        _id =  id;
    }


    final
    @property
    inout(Activity) activity() inout pure nothrow @safe @nogc
    {
        return _activity;
    }


    final
    @property
    inout(Application) application() inout pure nothrow @safe @nogc
    {
        if(_activity is null)
            return null;
        else
            return _activity.application;
    }


    final
    string id() const pure nothrow @safe @nogc @property { return _id; }


    string html() const @property;


    inout(HTMLElement[string]) elements() inout @property;


    final
    inout(HTMLElement) opIndex(string id) inout
    {
        return this.elements[id];
    }


    void onStart(Activity activity)
    {
        _activity = activity;
        foreach(key, elem; elements.maybeModified){
            elem.onStart(this);
        }
    }


    void onAttach(bool isInitPhase)
    {
        _activity = activity;
        foreach(key, elem; elements.maybeModified)
            elem.onAttach(isInitPhase);
    }


    void onLoad(bool isInit)
    {
        foreach(key, elem; elements.maybeModified)
            elem.onLoad(isInit);
    }


    void onUpdate() {}


    void onDetach()
    {
        foreach(key, elem; elements.maybeModified)
            elem.onDetach();
    }


    void onDestroy()
    {
        foreach(k, elem; elements.maybeModified)
            elem.onDestroy();
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
    in{
        if(id is null)
            assert(!doCreateObject);
    }
    body{
        _id = id;
        _hasObj = doCreateObject;
    }


    final
    @property
    inout(HTMLPage) page() inout pure nothrow @safe @nogc { return _page; }


    final
    @property
    inout(Activity) activity() inout pure nothrow @safe @nogc
    {
        if(_page is null)
            return null;
        else
            return _page.activity;
    }


    final
    @property
    inout(Application) application() inout pure nothrow @safe @nogc
    {
        if(this.activity is null)
            return null;
        else
            return this.activity.application;
    }


    final
    @property
    bool hasObject() const pure nothrow @safe @nogc
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


    final @property bool hasId() const pure nothrow @safe @nogc { return _id !is null; }


    final @property string id() const pure nothrow @safe @nogc { return _id; }


    @property string html() const { return ""; }


    void onStart(HTMLPage page)
    {
        _page = page;

        if(this.hasObject && !_v.isObject){
            _v = activity.createObject(_id);
        }
    }


    void onDestroy()
    {
        _page = null;
        _v = JSValue.null_;
    }


    void onAttach(bool isInit)
    {
        if(isInit && this.hasObject && !_v.isObject){
            _v = activity.createObject(_id);
        }
    }


    void onDetach() {}


    void onLoad(bool isInit)
    {
        if(this.hasId){
            foreach(key, ref v; _staticProperties)
                this.opIndexAssign(v, key);
        }
    }


    final
    @property
    auto staticProps()
    {
        static struct Result
        {
            void opIndexAssign(T)(T value, string name)
            if(is(typeof(JSValue(value)) : JSValue))
            {
                _elem.staticPropsSet(name, value);
            }


            void remove(string name)
            {
                _elem.staticPropsRemove(name);
            }


            bool opBinaryRight(string op : "in")(string name) inout
            {
                return _elem.inStaticProps(name);
            }

          private:
            HTMLElement _elem;
        }

        return Result(this);
    }


    void staticPropsSet(T)(string name, T value)
    if(is(typeof(JSValue(value)) : JSValue))
    in{
        assert(this.hasId);
    }
    body{
        JSValue jv = JSValue(value);
        _staticProperties[name] = jv;
        if(this.activity){
            this.opIndexAssign(jv, name);
        }
    }


    final
    void staticPropsRemove(string name)
    {
        _staticProperties.remove(name);
    }


    final
    bool inStaticProps(string name) inout
    {
        return !(name !in _staticProperties);
    }


    void opIndexAssign(T)(T value, string name)
    if(is(typeof(JSValue(value)) : JSValue))
    in{
        assert(this.hasId);
    }
    body{
        this.opIndexAssign(JSValue(value), name);
    }


    final
    void opIndexAssign(JSValue value, string name)
    in{
        assert(this.hasId);
    }
    body{
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


    final
    JSValue opIndex(string name)
    in{
        assert(this.hasId);
    }
    body{
        JSValue jv = activity.evalJS(mixin(Lstr!
            q{document.getElementById("%[id%]").%[name%];}
        ));

        return jv;
    }


    /**
    .innerHTML
    */
    void innerHTML(string html)
    in{
        assert(this.hasId);
    }
    body{
        auto ca = activity.carrierObject;
        ca.setProperty("value", JSValue(html));
        activity.evalJS(mixin(Lstr!
            q{document.getElementById("%[id%]").innerHTML = _carrierObject_.value; }));
    }


    /**
    See also: HTML.insertAdjacentHTML
    */
    void insertAdjacentHTML(string pos, string html)
    in{

    }
    body{
        auto ca = activity.carrierObject;
        ca.setProperty("value0", JSValue(pos));
        ca.setProperty("value1", JSValue(html));
        activity.evalJS(mixin(Lstr!
            q{document.getElementById("%[id%]").insertAdjacentHTML(_carrierObject_.value0, _carrierObject_.value1);}));
    }


    /**
    append html to this, which is block element.
    See also: jQuery.append
    */
    void append(string html)
    in{
        assert(this.hasId);
    }
    body{
        this.insertAdjacentHTML("beforeend", html);
    }


    /**
    prepend html to this which is block element.
    See also: jQuery.prepend
    */
    void prepend(string html)
    in{
        assert(this.hasId);
    }
    body{
        this.insertAdjacentHTML("afterbegin", html);
    }


    /**
    insert html after this.
    See also: jQuery.insertAfter
    */
    void insertAfter(string html)
    in{
        assert(this.hasId);
    }
    body{
        this.insertAdjacentHTML("afterend", html);
    }


    /**
    insert html before this.
    See also: jQuery.insertBefore
    */
    void insertBefore(string html)
    in{
        assert(this.hasId);
    }
    body{
        this.insertAdjacentHTML("beforebegin", html);
    }


    void invoke(T...)(string name, auto ref T args)
    in{
        assert(this.hasId);
    }
    body{
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
    HTMLPage _page;
    JSValue[string] _staticProperties;
}


class IDOnlyElement : HTMLElement
{
    this(string id)
    in{
        assert(id !is null);
    }
    body{
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
    void onStart(HTMLPage page)
    {
        super.onStart(page);
        this.activity.methodHandler.set(this);
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



/**
Selectors API
*/
alias querySelector = querySelectorImpl!false;


/// ditto
alias querySelectorAll = querySelectorImpl!true;


auto querySelectorImpl(bool isAll)(Activity activity, string cssSelector)
{
    static struct Result
    {
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
                        q{%[_qs%].%[name%] = true;}
                    ));
                else
                    activity.runJS(mixin(Lstr!
                        q{%[_qs%].%[name%] = false;}
                    ));
            }else{
                auto carrier = activity.carrierObject;
                carrier.setProperty("value", value);

                activity.runJS(mixin(Lstr!
                    q{%[_qs%].%[name%] = _carrierObject_.value;}
                ));
            }
        }


        JSValue opIndex(string name)
        {
            JSValue jv = activity.evalJS(mixin(Lstr!
                q{%[_qs%].%[name%];}
            ));

            return jv;
        }


        /**
        .innerHTML
        */
        void innerHTML(string html)
        {
            auto ca = activity.carrierObject;
            ca.setProperty("value", JSValue(html));
            activity.evalJS(mixin(Lstr!
                q{%[_qs%].innerHTML = _carrierObject_.value; }));
        }


        /**
        See also: HTML.insertAdjacentHTML
        */
        void insertAdjacentHTML(string pos, string html)
        in{

        }
        body{
            auto ca = activity.carrierObject;
            ca.setProperty("value0", JSValue(pos));
            ca.setProperty("value1", JSValue(html));
            activity.evalJS(mixin(Lstr!
                q{%[_qs%].insertAdjacentHTML(_carrierObject_.value0, _carrierObject_.value1);}));
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


        void invoke(T...)(string name, auto ref T args)
        {
          static if(T.length == 0)
            activity.evalJS(mixin(Lstr!
                q{%[_qs%].%[name%]();}
            ));
          else{
            auto carrier = activity.carrierObject;
            foreach(i, ref e; args)
                carrier.setProperty(format("value%s", i), JSValue(e));

            activity.evalJS(mixin(Lstr!
                q{%[_qs%].%[name%](%[format("%(_carrierObject_.value%s,%)", iota(args.length))%]);}
            ));
          }
        }


        Activity activity;
      private:
        string _qs;
    }

    Result res;
    res.activity = activity;
    res._qs = mixin(Lstr!q{document.%[isAll ? "querySelectorAll" : "querySelector"%](%[toLiteral(cssSelector)%])});
    return res;
}
