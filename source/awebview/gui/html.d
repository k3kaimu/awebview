module awebview.gui.html;

import carbon.utils;
import awebview.gui.activity;
import awebview.gui.methodhandler;
import awebview.gui.application;

import awebview.wrapper;
import awebview.cssgrammar;

import std.variant;
import std.typecons;

import std.array : appender;
import std.format : formattedWrite, format;
import std.functional : forward;
import std.conv : to;
import std.datetime;
public import core.time : Duration;

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


    string html() @property;


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

        _clientWidth = activity.evalJS(`document.documentElement.clientWidth`).get!uint;
        _clientHeight = activity.evalJS(`document.documentElement.clientHeight`).get!uint;
        _resizeStatements = generateResizeStatements(this.activity);
        onResize(activity.width, activity.height);
    }


    void onUpdate()
    {
        auto newW = activity.evalJS(`document.documentElement.clientWidth`).get!uint;
        auto newH = activity.evalJS(`document.documentElement.clientHeight`).get!uint;

        if(newW != _clientWidth || newH != _clientHeight)
            onResize(activity.width, activity.height);

        _clientWidth = newW;
        _clientHeight = newH;

        foreach(k, elem; elements.maybeModified)
            elem.onUpdate();
    }


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


    void onResize(size_t w, size_t h)
    {
        this.activity.runJS(_resizeStatements);

        foreach(k, elem; elements.maybeModified)
            elem.onResize(w, h);
    }


    void onReceiveImmediateMessage(ImmediateMessage msg)
    {
        foreach(k, e; elements.maybeModified){
            e.onReceiveImmediateMessage(msg);
        }
    }


  private:
    Activity _activity;
    string _id;

    size_t _clientWidth;
    size_t _clientHeight;

    string _resizeStatements;
}


class WebPage : HTMLPage
{
    this(string id, string url)
    {
        super(id);
        _url = url;
    }


    @property
    void location(string str)
    {
        if(activity){
            _url = str;
            activity.view.loadURL(WebURL(str));
        }
        else
            _url = str;
    }


    @property
    string location()
    {
        if(activity)
            return activity.evalJS(q{document.location}).to!string;
        else
            return _url;
    }


    override
    void onAttach(bool isInitPhase)
    {
        _bLoaded = false;
    }


    override
    void onUpdate()
    {
        if(!_bLoaded)
            this.location = _url;

        _bLoaded = true;
    }


    override
    inout(HTMLElement[string]) elements() inout @property { return null; }


    override
    string html() @property
    {
        return `<html><head><title>Jump</title></head><body>Now loading...</body></html>`;
    }

  private:
    string _url;
    bool _bLoaded;
}


class TemplateHTMLPage(string form) : HTMLPage
{
    this(string id, Variant[string] exts = null)
    {
        super(id);
        _exts = exts;
    }


    final
    auto js(this This)() @property pure nothrow @safe @nogc inout
    {
        static struct Result
        {
            string html() const
            {
                auto app = appender!string();
                foreach(_, e; _this._js)
                    app.formattedWrite(`<script src="%s"></script>`);
                return app.data;
            }


            alias html this;


            void opOpAssign(string op : "~")(string src)
            {
                import std.path : baseName;

                auto bn = src.baseName;
                _this._js[bn] = src;
            }


          private:
            This _this;
        }


        return Result(this);
    }


    final
    auto css(this This)() @property pure nothrow @safe @nogc inout
    {
        static struct Result
        {
            string html() const
            {
                auto app = appender!string();
                foreach(_, e; _this._css)
                    app.formattedWrite(`<link rel="stylesheet" href="%s">`);
                return app.data;
            }


            alias html this;


            void opOpAssign(string op : "~")(string src)
            {
                import std.path : baseName;

                auto bn = src.baseName;
                _this._css[bn] = src;
            }


          private:
            This _this;
        }


        return Result(this);
    }


    override
    @property
    string html()
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
        if(this.activity !is null){
            element.onStart(this);
            element.onAttach(true);
        }
    }


    @property
    inout(Variant[string]) exts() inout { return _exts; }

    @property
    inout(T) exts(T)(string str) inout { return *_exts[str].peek!T; }


  private:
    HTMLElement[string] _elems;
    Variant[string] _exts;
    string[string] _js;
    string[string] _css;
}


class HTMLElement
{
    import awebview.jsvariable;


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


    @property
    string jsExpr()
    in {
        assert(hasObject || hasId);
    }
    body {
        if(this.hasObject)
            return mixin(Lstr!q{_tmp_%[_id%].domObject});
        else
            return `document.getElementById("` ~ id ~ `")`;
    }


    final
    @property
    auto domObject()
    {
        return jsExpression(this.activity, this.jsExpr);
    }


    final @property bool hasId() const pure nothrow @safe @nogc { return _id !is null; }


    final @property string id() const pure nothrow @safe @nogc { return _id; }


    @property string html() { return ""; }
    @property string mime() { return "text/html"; }
    @property const(void)[] rawResource() { return this.html; }


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


    void onUpdate() {}


    void onDetach() {}


    void onLoad(bool isInit)
    {
        if(this.hasObject){
            activity.runJS(mixin(Lstr!q{
                _tmp_%[_id%] = {};
                _tmp_%[_id%].domObject = document.getElementById("%[_id%]");
            }));
        }

        if(this.hasId || this.hasObject){
            foreach(key, ref v; _staticProperties)
                this.opIndexAssign(v, key);
        }
    }


    void onResize(size_t w, size_t h) {}


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


    final
    {
        mixin JSExprDOMEagerOperators!();
    }


    final
    Tuple!(uint, "x", uint, "y", uint, "width", uint, "height")
     boundingClientRect() @property
    {
        this.activity.runJS(mixin(Lstr!q{
            var e = %[domObject.jsExpr%].getBoundingClientRect();
            _carrierObject_.x = e.left;
            _carrierObject_.y = e.top;
            _carrierObject_.w = e.width;
            _carrierObject_.h = e.height;
        }));

        auto co = activity.carrierObject;
        typeof(return) res;
        res.x = co["x"].get!uint;
        res.y = co["y"].get!uint;
        res.width = co["w"].get!uint;
        res.height = co["h"].get!uint;

        return res;
    }


    final
    uint posY() @property
    {
        return domObject.invoke("getBoundingClientRect")["top"].eval().get!uint;
    }


    final
    uint posX() @property
    {
        return domObject.invoke("getBoundingClientRect")["left"].eval().get!uint;
    }


    final
    uint[2] pos() @property
    {
        auto rec = boundingClientRect();
        return [rec.x, rec.y];
    }


    final
    uint width() @property
    {
        return domObject.invoke("getBoundingClientRect")["width"].eval().get!uint;
    }


    final
    uint height() @property
    {
        return domObject.invoke("getBoundingClientRect")["width"].eval().get!uint;
    }



    void onReceiveImmediateMessage(ImmediateMessage msg){}


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


class TagOnlyElement : HTMLElement
{
    this(string id)
    in {
        assert(id !is null);
    }
    body {
        super(id, true);
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
abstract class TemplateHTMLElement(Element, string form) : Element
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
    string html()
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
abstract class DefineSignals(Element, names...) : Element
if(is(Element : HTMLElement) && names.length >= 1)
{
    import carbon.event;

    this(T...)(auto ref T args)
    {
        super(forward!args);

        foreach(name; names)
            mixin(format(`_%1$sEvent = new typeof(_%1$sEvent)();`, name));
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
                app.formattedWrite("EventManager!(WeakRef!(const(JSArrayCpp))) %1$s() { return _%1$sEvent; }\n", s);
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


    final
    void doJSInitialize(bool b) @property
    {
        _doInit = b;
    }


    final
    void stopPropergation(bool b) @property
    {
        _stopProp = b;
    }


    mixin(genDeclMethods);

    override
    void onStart(HTMLPage page)
    {
        super.onStart(page);
        this.activity.methodHandler.set(this);
    }


    override
    void onLoad(bool init)
    {
        super.onLoad(init);

        if(_doInit){
            this.activity.runJS(genSettingEventHandlers(this.id, this.domObject.jsExpr, _stopProp));
        }
    }


  private:
    bool _doInit = true;
    bool _stopProp = false;

    static
    {
        string genDeclMethods()
        {
            auto app = appender!string();

            foreach(s; names)
                app.formattedWrite(`@JSMethodTag("%1$s"w) `"void %1$s(WeakRef!(const(JSArrayCpp)));\n", s);

            return app.data;
        }


        string genSettingEventHandlers(string id, string domExpr, bool stopProp)
        {
            import std.string : toLower;

            auto app = appender!string();
            app.formattedWrite("var e = %s;", domExpr);

            foreach(s; names){
                if(!stopProp)
                    app.formattedWrite(q{e.%3$s = function() { %1$s.%2$s(); };}, id, s, toLower(s));
                else
                    app.formattedWrite(q{e.%3$s = function(ev) { ev.stopPropergation(); %1$s.%2$s(); };}, id, s, toLower(s));
            }

            return app.data;
        }
    }
}


alias DeclDefSignals(Element, names...) = DefineSignals!(DeclareSignals!(Element, names), names);


/**
Open context menu when user click right button.
*/
abstract class DeclareContextMenu(Element, setting...) : DeclareSignals!(Element, "onContextMenu", setting)
{
    this(T...)(auto ref T args)
    {
        super(forward!args);
    }


    HTMLPage menuPage() @property;


    override
    void onContextMenu(WeakRef!(const(JSArrayCpp)))
    {
        this.activity.popup(this.menuPage);
    }
}


/**
Mouse hover event
*/
abstract class DeclareHoverSignal(Element) : DeclareSignals!(Element, "onMouseOver", "onMouseOut")
{
    this(T...)(auto ref T args)
    {
        super(forward!args);
    }


    /**
    */
    final
    bool hover() @property { return _hovered; }


    final
    void onHoverImpl()
    {
        if(_isStarted)
            onHover(_hovered, Clock.currTime - _startTime);
    }


    /**
    */
    void onHover(bool bOver, Duration dur);


    override
    void onUpdate()
    {
        super.onUpdate();

        onHoverImpl();
    }


    override
    void onMouseOver(WeakRef!(const(JSArrayCpp)))
    {
        _isStarted = true;
        _hovered = true;
        _startTime = Clock.currTime;
        onHoverImpl();
    }


    override
    void onMouseOut(WeakRef!(const(JSArrayCpp)))
    {
        _hovered = false;
        _startTime = Clock.currTime;
        onHoverImpl();
    }


  private:
    bool _isStarted;
    bool _hovered;
    SysTime _startTime;
}


/**
EventPipe
*/
final class PageSignalHandler : HTMLElement
{
    import carbon.event;

    this(string id = "_event_signal_pipe")
    {
        super(id, false);
        _onStartEvent = new EventManager!(Activity)();
        _onAttachEvent = new EventManager!bool();
        _onLoadEvent = new EventManager!bool();
        _onUpdateEvent = new EventManager!();
        _onDetachEvent = new EventManager!();
        _onDestroyEvent = new EventManager!();
        _onResizeEvent = new EventManager!(size_t, size_t)();
    }

  @property
  {
    EventManager!(Activity)       onStartHandler  () { return _onStartEvent; }
    EventManager!(bool)           onAttachHandler () { return _onAttachEvent; }
    EventManager!(bool)           onLoadHandler   () { return _onLoadEvent; }
    EventManager!()                 onUpdateHandler () { return _onUpdateEvent; }
    EventManager!()                 onDetachHandler () { return _onDetachEvent; }
    EventManager!()                 onDestroyHandler() { return _onDestroyEvent; }
    EventManager!(size_t, size_t) onResizeHandler () { return _onResizeEvent; }
  }

    override
    void onStart(HTMLPage page)
    {
        super.onStart(page);
        _onStartEvent.emit(this, page.activity);
    }


    override
    void onAttach(bool bInit)
    {
        super.onAttach(bInit);
        _onAttachEvent.emit(this, bInit);
    }


    override
    void onLoad(bool bInit)
    {
        super.onLoad(bInit);
        _onLoadEvent.emit(this, bInit);
    }


    override
    void onUpdate()
    {
        super.onUpdate();
        _onUpdateEvent.emit(this);
    }


    override
    void onDetach()
    {
        super.onDetach();
        _onDetachEvent.emit(this);
    }


    override
    void onDestroy()
    {
        super.onDestroy();
        _onDestroyEvent.emit(this);
    }


    override
    void onResize(size_t w, size_t h)
    {
        super.onResize(w, h);
        _onResizeEvent.emit(this, w, h);
    }


  private:
    EventManager!(Activity) _onStartEvent;
    EventManager!(bool) _onAttachEvent;
    EventManager!(bool) _onLoadEvent;
    EventManager!() _onUpdateEvent;
    EventManager!() _onDetachEvent;
    EventManager!() _onDestroyEvent;
    EventManager!(size_t, size_t) _onResizeEvent;
}


/**
Selectors API
*/
alias querySelector = querySelectorImpl!false;


/// ditto
alias querySelectorAll = querySelectorImpl!true;


auto querySelectorImpl(bool isAll)(Activity activity, string cssSelector)
{
    import awebview.jsvariable;

    static struct QuerySelectorResult
    {
        string jsExpr() const @property { return _jsExpr; }
        Activity activity() @property { return _activity; }


        mixin JSExprDOMEagerOperators!();

      private:
        string _jsExpr;
        Activity _activity;
    }

    QuerySelectorResult res;
    res._jsExpr = mixin(Lstr!q{document.%[isAll ? "querySelectorAll" : "querySelector"%](%[toLiteral(cssSelector)%])});
    res._activity = activity;

    return res;
}
