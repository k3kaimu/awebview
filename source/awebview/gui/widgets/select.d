module awebview.gui.select;


import awebview.gui.html;
import awebview.gui.activity;
import awebview.gui.application;
import awebview.wrapper;

import std.string;
import std.array;
import std.typecons;

import carbon.nonametype;


interface ISelect
{
    @property
    string selected();

    @property
    void selected(string s);
}


class Select(alias attrs = null)
: DefineSignals!(DeclareSignals!(TemplateHTMLElement!(HTMLElement, `<select id="%[id%]" ` ~ buildHTMLTagAttr(attrs) ~ `>%s</select>`),
                                 "onChange", "onClick"),
                "onChange"),
  ISelect
{
    this(string id)
    {
        super(id, true);
    }


    @property
    void showAllOptions(bool bShowAllOption)
    {
        if(!_bShowAllOptions){
            bShowAllOption = true;
            this.staticProps["size"] = this._opts.length;
        }
    }


    @property
    void size(uint s)
    {
        _bShowAllOptions = false;
        this.staticProps["size"] = s;
    }


    final
    @property
    auto options() pure nothrow @safe @nogc
    {
        static struct Result
        {
            void opOpAssign(string op : "~")(string[2] kv)
            {
                _this.appendOption(kv[0], kv[1]);
            }


            string[2] opIndex(size_t idx) { return _this._opts[idx]; }

            string opIndex(string str)
            {
                foreach(i, ref e; _this._opts)
                    if(e[0] == str)
                        return e[1];

                return _this._opts[$][1];  // throw error
            }

            void opIndexAssign(string text, size_t idx)
            {
                _this._opts[idx] = text;
            }

            void opIndexAssign(string text, string str)
            {
                foreach(i, ref e; _this._opts)
                    if(e[0] == str)
                        e[1] = str;

                _this._opts[$] = str;   // throw error
            }

          private:
            Select!attrs _this;
        }


        return Result(this);
    }


    @property
    void options(string[2][] options)
    {
        _opts = options;

        if(_bShowAllOptions)
            this.staticProps["size"] = this._opts.length;
    }


    @property
    void options(string[string] opts)
    {
        _opts.length = 0;
        foreach(k, v; opts)
            _opts ~= [k, v];

        if(_bShowAllOptions)
            this.staticProps["size"] = this._opts.length;
    }


    @property
    void appendOption(string key, string text)
    {
        _opts ~= [key, text];

        if(_bShowAllOptions)
            this.staticProps["size"] = this._opts.length;
    }


    @property
    uint selectedIndex()
    {
        return this["selectedIndex"].get!uint;
    }


    override
    @property
    string selected()
    {
        uint idx = this.selectedIndex;
        return _opts[idx][0];
    }


    @property
    string selectedText()
    {
        uint idx = this.selectedIndex;
        return _opts[idx][1];
    }


    override
    @property
    void selected(string key)
    {
        foreach(i, e; _opts)
            if(e[0] == key){
                this["selectedIndex"] = i;
                return;
            }

        assert(0);
    }


    @property
    void selectedIndex(size_t idx)
    {
        this["selectedIndex"] = idx;
    }


    void makeOption(size_t i, string key, string text, scope void delegate(const(char)[]) sink) const
    {
        sink.formattedWrite(`<option value="%s">%s</option>`, key, text);
    }


    HTMLPage makePopupMenu() @property
    {
        static class Result : HTMLPage
        {
            this(Select sel)
            {
                _sel = sel;
                super(_sel.id ~ "_contextmenu_");

                auto tag = new AssumeImplemented!(DeclDefSignals!(TagOnlyElement, "onClick"))(_sel.id);
                tag.doJSInitialize = false;
                tag.onClick.connect!"onClick"(this);
                _elems[tag.id] = tag;
            }


            override
            inout(HTMLElement[string]) elements() inout @property { return _elems; }


            override
            string html() const @property
            {
                string genRows()
                {
                    auto app = appender!string();
                    foreach(i, e; _sel._opts)
                        app.formattedWrite(q{<tr onclick="%3$s.onClick(%1$s)"><td>%2$s</td></tr>}, i, e[1], _sel.id);
                    return app.data;
                }

                auto app = appender!string();
                app.put(`<html><head><title>select</title></head><style>tr:hover { background-color: #007bff; color: #000000; }</style>`);
                app.put(`<body style="margin:0px; padding:0px">`);
                app.formattedWrite(`<table id="%1$s" style="border-collapse: collapse; border: inset 1px black;">%2$s</table>`, _sel.id, genRows());
                app.put(`</body></html>`);
                return app.data;
            }


            void onClick(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
            {
                assert(args.length == 1);
                auto idx = args[0].get!uint;
                _sel.selectedIndex = idx;
                activity.detach();
            }


          private:
            HTMLElement[string] _elems;
            Select _sel;
        }

        return new Result(this);
    }


    override
    @property
    string html() const
    {
        auto str = super.html();

        auto app = appender!string();
        foreach(i, e; _opts)
            makeOption(i, e[0], e[1], delegate(const(char)[] cs){ app.put(cs); });

        return format(str, app.data);
    }


    override
    void onClick(WeakRef!(const(JSArrayCpp)) args)
    {
        if(_popupMenu is null)
            _popupMenu = makePopupMenu();

        auto pos = this.pos;
        if(auto a = cast(SDLPopupActivity)activity){
            a.popupChild(_popupMenu, pos[0], pos[1] + this["innerHeight"].get!uint);
        }else{
            auto a = cast(SDLApplication)application;
            a.popupActivity.popupAtRel(_popupMenu, cast(SDLActivity)this.activity, pos[0], pos[1] + this["innerHeight"].get!uint);
        }
    }


  private:
    string[2][] _opts;
    bool _bShowAllOptions;

    HTMLPage _popupMenu;
}
