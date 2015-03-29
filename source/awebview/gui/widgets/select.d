module awebview.gui.select;


import awebview.gui.html;
import std.string;
import std.array;


interface ISelect
{
    @property
    string selected();

    @property
    void selected(string s);
}


class Select(alias attrs = null)
: TemplateHTMLElement!(DefineSignals!(DeclareSignals!(HTMLElement, "onChange"), "onChange"), `<select id=%[id%] onChange="%[id%].onChange()" ` ~ buildHTMLTagAttr(attrs) ~ `>%s</select>`),
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
        return this["selected"].get!uint;
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


    void makeOption(size_t i, string key, string text, scope void delegate(const(char)[]) sink) const
    {
        sink.formattedWrite(`<option value="%s">%s</option>`, key, text);
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


  private:
    string[2][] _opts;
    bool _bShowAllOptions;
}
