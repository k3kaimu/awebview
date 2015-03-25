import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.wrapper;

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
            auto btn = new InputButton!(null)("open_new");
            btn.staticSet("value", "Open New Window");
            btn.onClick.connect!"onClickOpenWindow"(this);
            return btn;
        }();
    }


    void onClickOpenWindow(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        application.to!SDLApplication.createActivity(WebPreferences.recommended,
        delegate(WebSession session){
            ++_n;
            string strN = _n.to!string;

            auto activity = new SDLActivity("MainActivity" ~ strN, 600, 400, strN ~ "!", session);
            auto helloPage = new TemplateHTMLPage!(import("hello.html"))("hello", null);

            activity ~= helloPage;
            activity.load("hello");

            return activity;
        });
    }


  private:
    size_t _n;
}
