import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.wrapper;

import carbon.utils;


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

        this ~= (){
            auto btn = new InputButton!()("open_new");
            btn.staticProps["value"] = "Open new window";
            btn.onClick.connect!"onClickOpenWindow"(this);
            return btn;
        }();

        this ~= (){
            auto btn = new InputButton!()("close_all");
            btn.staticProps["value"] = "Close all windows";
            btn.onClick.connect!"onClickCloseAll"(this);
            return btn;
        }();

        this ~= (){
            auto btn = new InputButton!()("show_all");
            btn.staticProps["value"] = "Show all windows";
            btn.onClick.connect!"onClickShowAll"(this);
            return btn;
        }();

        this ~= (){
            auto btn = new InputButton!()("hide_all");
            btn.staticProps["value"] = "Hide all windows";
            btn.onClick.connect!"onClickHideAll"(this);
            return btn;
        }();
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

            this ~= (){
                auto btn = new InputButton!()("close_this");
                btn.staticProps["value"] = "Close this window";
                btn.onClick.strongConnect(delegate(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args){ activity.close(); });
                return btn;
            }();
        }
    }


  private:
    size_t _n;
}
