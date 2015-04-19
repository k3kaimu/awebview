import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.wrapper;

import carbon.utils;
import carbon.functional;


void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;

    app.createActivity(pref, delegate(WebSession session){
      auto activity = new SDLActivity("MainActivity", 600, 400, "Hello!", session);
      auto topPage = new TopPage();

      activity ~= topPage;
      activity.load("topPage");

      return activity;
    });

    app.run();
}


final class TopPage : TemplateHTMLPage!(import("top.html"))
{
    this()
    {
        super("topPage", null);

        this ~= (new InputButton!()("open_new")).observe!((a){
            a.staticProps["value"] = "Open new window";
            a.onClick.connect!"onClickOpenWindow"(this);
        });

        this ~= (new InputButton!()("close_all")).observe!((a){
            a.staticProps["value"] = "Close all windows";
            a.onClick.connect!"onClickCloseAll"(this);
        });

        this ~= (new InputButton!()("show_all")).observe!((a){
            a.staticProps["value"] = "Show all windows";
            a.onClick.connect!"onClickShowAll"(this);
        });

        this ~= (new InputButton!()("hide_all")).observe!((a){
            a.staticProps["value"] = "Hide all windows";
            a.onClick.connect!"onClickHideAll"(this);
        });
    }


    void onClickOpenWindow(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        import std.string : format;

        ++_n;
        immutable actId = format("MainActivity%s", _n),
                  title = format("%s!", _n);

        activity.addChild(application.to!SDLApplication.createActivity(
                            WebPreferences.recommended,
                            new ChildPage(), actId, 600, 400, title));
    }


    void onClickCloseAll(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        foreach(k, e; activity.children.maybeModified)
            e.close();
    }


    void onClickShowAll(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        foreach(k, e; activity.children.maybeModified)
            if(e.isDetached)
                e.attach();
    }


    void onClickHideAll(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        foreach(k, e; activity.children.maybeModified)
            if(e.isAttached)
                e.detach();
    }


    override
    void onDestroy()
    {
        foreach(k, e; activity.children.maybeModified)
            e.close();

        super.onDestroy();
    }


    static final class ChildPage : TemplateHTMLPage!(import("child.html"))
    {
        this()
        {
            super("hello", null);

            this ~= (new InputButton!()("close_this")).observe!((a){
                a.staticProps["value"] = "Close this window";
                a.onClick.strongConnect(delegate(ctx, args){ activity.close(); });
            });
        }
    }


  private:
    size_t _n;
}
