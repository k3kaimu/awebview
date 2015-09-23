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
import sound_page;

import std.conv;
import carbon.functional;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;

    with(app.newFactoryOf!SDLActivity(pref)){
        id = "MainActivity";
        width = 600;
        height = 400;
        title = "Showcase";

        app.addActivity(newInstance.passTo!((a){
            a.load(new MainPage());
        }));
    }

    app.initPopup(pref);

    // アプリケーションを走らせる
    app.run();
}


final class MainPage : TemplateHTMLPage!(import("main.html"))
{
    this()
    {
        super("mainPage", null);

        this ~= new InputButton!()("open_showcase_button").passTo!((a){
            a.staticProps["value"] = "Open showcase";
            a.onClick.connect!"onClickOpenShowcase"(this);
        });

        this ~= new Select!()("select_page").passTo!((a){
            _select = a;
            a.options ~= ["buttonActivity",     "Button"];
            a.options ~= ["switchLinkActivity", "Link"];
            a.options ~= ["radioActivity", "Radio Button"];
            a.options ~= ["progressActivity", "Progress Bar"];
            a.options ~= ["soundActivity", "Sound"];
        });

        this._pages["buttonActivity"] = [new ButtonPage()];
        this._pages["switchLinkActivity"] = [new SwitchLinkPage("A"), new SwitchLinkPage("B")];
        this._pages["radioActivity"] = [new RadioPage()];
        this._pages["progressActivity"] = [new ProgressPage()];
        this._pages["soundActivity"] = [new SoundPage()];
    }


    void onClickOpenShowcase(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        string str = _select.selected;
        auto app = cast(SDLApplication)application;
        if(str in _pages && str !in app.activities){
            with(app.newFactoryOf!SDLActivity(WebPreferences.recommended)){
                id = str;
                width = 600;
                height = 400;
                title = "Showcase";

                app.addActivity(newInstance.passTo!((a){
                    a.load(_pages[str][0]);
                    foreach(e; _pages[str][1 .. $])
                        a ~= e;

                    activity.addChild(a);
                }));
            }
        }
    }

  private:
    ISelect _select;
    HTMLPage[][string] _pages;
}
