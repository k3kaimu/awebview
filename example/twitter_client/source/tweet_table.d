module tweet_table;

import std.uri : encodeComponent;
import std.algorithm : map;
import std.utf : UTFException;

import carbon.utils : toLiteral;
import carbon.templates;

import awebview.gui.html,
       awebview.gui.activity;

import awebview.wrapper;

import msgpack;


immutable HTMLTableFormat = q{
<div class="col-md-6">
  <table class="table table-striped" id="%[id%]">
    <thead><tr></tr></thead>
    <tbody></tbody>
  </table>
</div>
};


/**
need jQuery
*/
class TweetTable : TemplateHTMLElement!(HTMLElement, HTMLTableFormat)
{
    this(string id)
    {
        super(id, true);
        theaders = ["image", "username", "tweet"];
    }


    @property 
    auto theaders()
    {
        static struct THeaders
        {
            @property const(string[]) array() const { return _parent._ths; }
            string opIndex(size_t idx) const { return _parent._ths[idx]; }


            void opIndexAssign(string th, size_t idx)
            {
                _parent._ths[idx] = th;
                _parent.theaders = _parent._ths;
            }


            void opOpAssign(string op : "~")(string th)
            {
                this ~= [th];
            }


            void opOpAssign(string op : "~")(string[] ths)
            {
                _parent._ths ~= ths;
                _parent.theaders = _parent._ths;
            }


          private:
            TweetTable _parent;
        }

        return THeaders(this);
    }


    @property
    void theaders(string[] ths)
    {
        _ths = ths;
        if(this.activity !is null)
            rerenderingHeader();
    }


    override
    void onStart(HTMLPage page)
    {
        if(auto p = this.id in page.activity.application.savedData){
            ubyte[] myData = *p;

            auto pf = unpack!PackedField(*p);
            this._ths = pf.ths;
            this._tds = pf.tds;

            if(this._tds.length > 100)
                this._tds = this._tds[$-100 .. $];

            *p = pf.parentData;
            super.onStart(page);
            *p = myData;
        }
        else
        {
            super.onStart(page);
        }
    }


    override
    void onDestroy()
    {
        auto app = this.activity.application;

        super.onDestroy();

        PackedField pf;
        pf.ths = _ths;
        pf.tds = _tds;

        if(auto p = this.id in app.savedData)
            pf.parentData = *p;

        app.savedData[this.id] = pack(pf);
    }


    override
    void onLoad(bool isInit)
    {
        super.onLoad(isInit);

        rerenderingHeader();
        rerenderingBody();
    }


    void rerenderingHeader()
    {
        auto app = appender!wstring();
        app.formattedWrite("%-(<th>%s</th>%|%)", _ths.map!encodeComponent());
        activity.carrierObject.setProperty("value", JSValue(app.data));
        activity.runJS(mixin(Lstr!q{$("#%[id%] > thead > tr").html(_carrierObject_.value);}));
    }


    void rerenderingBody()
    {
        auto app = appender!wstring();
        foreach_reverse(e; _tds){
            try
                appendTR(app, e[0], e[1], e[2]);
            catch(UTFException ex)
                appendTR(app, e[0], e[1], ex.to!string);
        }
        activity.carrierObject.setProperty("value", JSValue(app.data));
        activity.runJS(mixin(Lstr!q{$("#%[id%] > tbody").html(_carrierObject_.value);}));
    }


    void addTweet(string imageURL, string username, string tweet)
    {
        //import std.stdio;
        _tds ~= [imageURL, username, tweet];
        if(this.activity !is null){
            auto app = appender!wstring();
            appendTR(app, imageURL, username, tweet);
            //writeln(app.data);
            activity.carrierObject.setProperty("value", JSValue(app.data));
            activity.runJS(mixin(Lstr!q{$("#%[id%] > tbody").prepend(_carrierObject_.value);}));
        }
    }


    private
    void appendTR(Writer)(ref Writer w, string imageURL, string username, string tweet)
    {
        w.put(mixin(Lstr!`<tr><td><img src=%[toLiteral(imageURL)%]></td><td>%[username%]</td><td>%[tweet%]</td></tr>`));
    }


  private:
    string[] _ths;
    string[3][] _tds;

    struct PackedField { string[] ths; string[3][] tds; ubyte[] parentData; }
}
