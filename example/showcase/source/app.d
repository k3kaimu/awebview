import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.gui.widgets.select;
import awebview.wrapper;

import button_page;
import switchlink;

import std.conv;

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

        this ~= (){
            auto button = new InputButton!()("open_showcase_button");
            button.staticProps["value"] = "Open showcase";
            button.onClick.connect!"onClickOpenShowcase"(this);
            return button;
        }();

        this ~= (){
            auto sel = new Select!()("select_page");
            _select = sel;
            sel.showAllOptions = true;
            sel.options ~= ["buttonActivity",     "button"];
            sel.options ~= ["switchLinkActivity", "link"];
            return sel;
        }();

        this._pages["buttonActivity"] = [new ButtonPage()];
        this._pages["switchLinkActivity"] = [new SwitchLinkPage("A"), new SwitchLinkPage("B")];
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
