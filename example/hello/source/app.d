import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.wrapper;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;

    with(app.newFactoryOf!SDLActivity(pref)){
        // Activityの各種設定
        id = "MainActivity";
        width = 600;
        height = 400;
        title = "Hello!";

        // Activityの作成
        auto activity = newInstance;

        // hello.htmlを読み込んで、helloというIDのページを作成
        auto helloPage = new TemplateHTMLPage!(import("hello.html"))("hello", null);

        // Activityにページを登録
        activity ~= helloPage;

        // IDがhelloのページを読み込む
        activity.load("hello");

        // アプリケーションにアクティビティを登録する
        app.addActivity(activity);
    }

    // アプリケーションを走らせる
    app.run();
}