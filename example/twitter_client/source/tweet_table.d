module tweet_table;

import std.uri : encodeComponent;
import std.algorithm : map;

import carbon.utils : toLiteral;
import carbon.templates;

import awebview.gui.html;
import awebview.wrapper;


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
        foreach(e; _tds)
            appendTR(app, e[0], e[1], e[2]);
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
        //import std.stdio;
        //writeln(toLiteral(imageURL)[1 .. $-1]);
        w.put(mixin(Lstr!`<tr><td><img src=%[toLiteral(imageURL)%]></td><td>%[username%]</td><td>%[tweet%]</td></tr>`));
    }


  private:
    string[] _ths;
    string[3][] _tds;
}
