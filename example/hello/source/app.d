import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.wrapper;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;
    app.createActivity(pref, delegate(WebSession session){

      // MainActivityというIDのActivityを作成
      auto activity = new SDLActivity("MainActivity", 600, 400, "Hello!", session);
      
      // hello.htmlを読み込んで、helloというIDのページを作成
      auto helloPage = new TemplateHTMLPage!(import("hello.html"))("hello", null);
      
      // Activityにページを登録
      activity ~= helloPage;
      
      // IDがhelloのページの読み込み
      activity.load("hello");
      return activity;
    });


    // アプリケーションを走らせる
    app.run();
}