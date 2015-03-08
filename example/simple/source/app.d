import std.stdio;
import std.string;
import std.stdio;
import std.conv;
import std.datetime;
import std.exception;

import carbon.templates;
import carbon.utils;

import awebview.wrapper;

import awebview.gui.application,
       awebview.gui.activity,
       awebview.gui.html,
       awebview.gui.methodhandler,
       awebview.gui.widgets.button;

import deimos.glfw.glfw3;


void main()
{
    auto app = new GLFWApplication(delegate(WebSession session){
        // 画面の作成
        auto activity = new NavTabsActivity("MainActivity", "navtabs", 800, 640, "foobar", session);
        HTMLPage home, profile, messages;

        auto navtabs = activity.navtabsHTMLElement;

        home = {
            auto home = new TemplateHTMLPage!(import(`main_view.html`))(`Home`);
            home ~= navtabs;

            auto tbl = new AppendableTable("tbl");
            home ~= tbl;

            home ~= {
                // btn.htmlからボタンのHTMLを構築
                auto btn1 = new GenericButton!(import(`btn.html`))("btn1");
                size_t cnt;

                // コールバック関数の追加
                btn1.onClick.strongConnect(delegate(FiredContext ctx, WeakRef!(const(JSArrayCpp)) array){
                    ++cnt;
                    btn1["value"] = format("cnt: %s", cnt);

                    auto ct = Clock.currTime;
                    tbl.appendRow(to!string(ct.year), to!string(ct.month), to!string(ct.day),
                                  to!string(ct.hour), to!string(ct.minute), to!string(ct.second));
                });

                return btn1;
            }();

            return home;
        }();


        profile = {
            auto profile = new TemplateHTMLPage!(import(`profile.html`))("Tab2");
            profile ~= navtabs;

            return profile;
        }();


        messages = {
            auto msg = new TemplateHTMLPage!(import(`messages.html`))("Tab3");
            msg ~= navtabs;

            return msg;
        }();


        activity.addPage(home);
        activity.addPage(profile);
        activity.addPage(messages);

        activity.state = 0;

        return activity;
    });

    app.run();
}


/**
表

main_view.html の id="tbl" に相当
*/
class AppendableTable : TemplateHTMLElement!(HTMLElement, import(`tbl.html`))
{
    this(string id)
    {
        super(id, false);
    }


    void appendRow(string[] args...)
    {
        ++_rows;
        string[] ss = to!string(_rows) ~ args;
        _body ~= mixin(Lstr!q{<tr>%[format(`%-(<td>%s</td>%|%)`, ss)%]</tr>});
        this.activity.runJS(mixin(Lstr!q{$("#%[id%] > tbody").append("%[_body[$-1]%]")}));
    }


    override
    void onLoad(bool isInit)
    {
        foreach(e; _body)
            activity.runJS(mixin(Lstr!q{$("#%[id%] > tbody").append("%[e%]")}));
    }


  private:
    string _id;
    size_t _rows;
    string[] _body;
}


/**
*/
final class NavTabsActivity : GLFWActivity
{
    this(string id, string navtabsId, size_t width, size_t height, string title, WebSession session = null)
    {
        super(id, width, height, title, session);
        _navtabs = new NavTabs(navtabsId);
        _state = -1;
    }


    @property
    void state(uint next)
    {
        if(next == _state) return;

        _state = next;
        this.load(_pages[_state]);
    }


    @property
    uint state()
    {
        return _state;
    }



    @property
    NavTabs navtabsHTMLElement()
    {
        return _navtabs;
    }


    final class NavTabs : DeclareSignals!(HTMLElement, "onClick") /*Button*/
    {
        this(string id)
        {
            super(id, true);
        }


        override
        void onClick(WeakRef!(const(JSArrayCpp)) array)
        {
            assert(array.length == 1);
            assert(array[0].isInteger);

            uint next = array[0].get!uint;
            this.outer.state = next;
        }


        @property
        override
        string html() const
        {
            string dst = `<ul class="nav nav-tabs" role="tablist" id="%[id%]">`;
            foreach(i, e; _pages)
                dst ~= mixin(Lstr!q{<li role="presentation" onclick="%[id%].onClick(%[i%])" %[i == _state ? `class="active"` : ""%]><a href="#">%[e.id%]</a></li>});
            dst ~= `</ul>`;

            return dst;
        }
    }


    void addPage(HTMLPage page)
    {
        _pages ~= page;
    }


  private:
    NavTabs _navtabs;
    HTMLPage[] _pages;
    uint _state;
}
