import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.gui.widgets.select;
import awebview.wrapper;

import button_page;
import switchlink;
import radio_page;
import progress_page;

import std.conv;
import carbon.functional;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;
    app.createActivity(pref, delegate(WebSession session){
      auto activity = new SDLActivity("MainActivity", 600, 400, "Showcase", session);
      auto mainPage = new MainPage();

      activity ~= mainPage;
      activity.load(mainPage);
      return activity;
    });

    app.initPopup(pref);

    // アプリケーションを走らせる
    app.run();
}


final class MainPage : TemplateHTMLPage!(import("main.html"))
{
    this()
    {
        super("mainPage", null);

        this ~= new InputButton!()("open_showcase_button").digress!((a){
            a.staticProps["value"] = "Open showcase";
            a.onClick.connect!"onClickOpenShowcase"(this);
        });

        this ~= new Select!()("select_page").digress!((a){
            _select = a;
            a.options ~= ["buttonActivity",     "Button"];
            a.options ~= ["switchLinkActivity", "Link"];
            a.options ~= ["radioActivity", "Radio Button"];
            a.options ~= ["progressActivity", "Progress Bar"];
        });

        this._pages["buttonActivity"] = [new ButtonPage()];
        this._pages["switchLinkActivity"] = [new SwitchLinkPage("A"), new SwitchLinkPage("B")];
        this._pages["radioActivity"] = [new RadioPage()];
        this._pages["progressActivity"] = [new ProgressPage()];
    }


    void onClickOpenShowcase(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        string str = _select.selected;
        auto app = cast(SDLApplication)application;
        if(str in _pages && str !in app.activities){
            auto act = app.createActivity(WebPreferences.recommended, _pages[str][0], str, 600, 400, "Showcase");

            foreach(e; _pages[str][1 .. $])
                act ~= e;

            activity.addChild(act);
        }
    }

  private:
    ISelect _select;
    HTMLPage[][string] _pages;
}
