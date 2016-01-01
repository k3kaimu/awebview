import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.text;
import awebview.gui.widgets.button;
import awebview.wrapper;

import carbon.functional : passTo;

import std.random;
import std.datetime;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;

    with(app.newFactoryOf!SDLActivity(pref)){
        id = "MainActivity";
        width = 600;
        height = 400;
        title = "aaa";

        // ページの作成とか
        app.addActivity(newInstance.passTo!((a){
            a.load(new DManPage("dmanPage"));
        }));
    }

    app.run();
}


// ページ
class DManPage : TemplateHTMLPage!(import(`dman.html`))
{
    this(string id)
    {
        super(id, null);

        // ボタンの作成
        this ~= _kawaii = new InputButton!()("b_kawaii");
        _kawaii.staticProps["value"] = "D言語くん可愛い!!!";
        _kawaii.onClick.connect!"onClickKawaii"(this);  // クリック時のイベント
    }


    void onClickKawaii()
    {
        // <p>タグの作成
        auto dmanText = new Paragraph!()(format("dmanText%d", ++_count));
        this ~= dmanText;   // このページに登録
        this.activity[$("body")].append(dmanText.html); // このページのbodyの末尾に追加

        dmanText.text = "D言語くん可愛い";     // <p>タグの内部にテキスト

        // 以下3行で, ランダムに位置を表示する
        dmanText.staticProps["style.position"] = "absolute";
        dmanText.staticProps["style.top"] = format("%dpx", uniform(0, 300));
        dmanText.staticProps["style.left"] = format("%dpx", uniform(0, 500));
    }


  private:
    InputButton!() _kawaii;
    size_t _count;
}
