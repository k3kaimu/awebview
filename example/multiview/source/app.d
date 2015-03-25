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

      // MainActivityというIDのActivityを作成
      auto activity = new SDLActivity("MainActivity", 600, 400, "Hello!", session);
      
      // hello.htmlを読み込んで、helloというIDのページを作成
      auto topPage = new TopPage();
      
      // Activityにページを登録
      activity ~= topPage;
      
      // IDがhelloのページの読み込み
      activity.load("topPage");
      return activity;
    });
    
    // アプリケーションを走らせる
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
        application.to!SDLApplication.createActivity(WebPreferences.recommended, delegate(WebSession session){
            // MainActivityというIDのActivityを作成
            ++_n;
            string strN = _n.to!string;

            auto activity = new SDLActivity("MainActivity" ~ strN, 600, 400, strN ~ "!", session);

            // hello.htmlを読み込んで、helloというIDのページを作成
            auto helloPage = new TemplateHTMLPage!(import("hello.html"))("hello", null);

            // Activityにページを登録
            activity ~= helloPage;

            // IDがhello%[N%]のページの読み込み
            activity.load("hello");
            return activity;
        });
    }


  private:
    size_t _n;
}
