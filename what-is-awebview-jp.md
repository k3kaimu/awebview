# awebviewはHTMLでGUIが書けるAwesomiumのラッパー

## Awesomiumとは

Awesomiumとは、Chromiumの機能のうち、Web画面のレンダリングやイベント処理などをC++から直接扱えるライブラリです。
このライブラリを使うと、たとえばゲーム画面にウェブブラウザを設置できたり、HTML+Javascript+CSSを用いてGUIアプリケーションを構築可能です。
非オープンソースなライブラリであり、非商用であれば無償で利用することができますが、商用製品に組み込む場合は有償のようです。


##  awebviewとは

awebviewは、AwesomiumをDから扱いやすいようにラッピングしたライブラリで、Awesomiumの機能のうちGUIアプリケーションを書くことに特化したライブラリです。


## awebviewことはじめ

awebviewはdubにより簡単に使用することができます。
使用するには`dub.json`に次のような記述をします。
なぜこのように長い記述が必要であるかというと、awebviewではC++とのインターフェースをDから扱いやするC++のコードをまずビルドしているからです。
そのため、`copyCommand`で必要ファイルをコピーしたあと、`postCopyCommand`でC++のコードをビルドしています。

~~~~js
{
  "name": "hello",
  "description": "A minimal D application.",
  "copyright": "Copyright © 2015, k3kaimu",
  "authors": ["k3kaimu"],
  "dependencies": {
        "awebview": "~>0.1.0",
  },

  "configurations": [
    {
      "name": "application",
      "targetType": "executable",
      "preGenerateCommands":[
        "dub generate --config=copyCommand visuald",
        "dub generate --config=postCopyCommand visuald"
      ],
      "sourceFiles-windows-x86": ["awesomium4d_cw.obj"]
    },

    {
      "name": "copyCommand",
      "subConfigurations": {
        "awebview": "copyCommand"
      }
    },

    {
      "name": "postCopyCommand",
      "subConfigurations": {
        "awebview": "postCopyCommand"
      }
    }
  ],
}
~~~~


## GUIのHello, World

では簡単に画面上にHello, Worldと表示してみましょう。
`views`というディレクトリをつくり、`views/hello.html`として次のHTMLファイルを保存します。

~~~~html
<!doctype html>
<html lang="jp">
<head>
    <title>Hello</title>
</head>
<body>
Hello, World!
</body>
</html>
~~~~

そして、`source/app.d`(もしくは`src/app.d`)を次のように編集します。

~~~~d
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
~~~~

そして、コマンドライン上で`dub`と打つとどうでしょうか？
ウィンドウが表示され、そこに"Hello, World!"と表示されていれば成功です。


## ApplicationとActivity, HTMLPage, HTMLElementについて

awebviewではGUIを構成するクラスは大きく以下の4つのクラスに分けることができます。

+ Application  
Applicationは、SDLやGLFWというバックエンドを管理するクラスです。
アプリケーションひとつにつき、ひとつのApplicationインスタンスを持ちます。
つまり、Applicationはいわゆるシングルトンです。
通常、awebview使用者がApplicationを継承したクラスを作ることはありません。

+ Activity  
Activityは、HTMLPageを適切に管理し、HTMLPageの表示・切り替えを行うためのクラスです。
感覚的に言えば、ウェブブラウザの一つの「タブ」に相当し、表示するページを管理します。
アプリケーションのひとつのウィンドウに対してひとつのActivityが対応します。
つまり、複数のウィンドウを同時に表示するようなアプリケーションでない限り、Activityは一つで十分です。

+ HTMLPage  
HTMLPageは、その名のとおりHTMLで構成されたページとその構成要素であるHTMLElementを管理します。
HTMLPageはアプリケーションの一つの「画面構成」に相当します。

+ HTMLElement  
HTMLElementは、HTMLのボタンだったりテキストエリアといったHTMLPageの構成要素(HTMLタグ)を管理します。


## ページに内容を追加する

たとえば「現在時刻を表示する」には、`awebview.gui.widgets.text`と`std.datetime`を使って次のように書きます。

~~~~html
<!doctype html>
<html lang="jp">
<head>
    <title>Hello</title>
</head>
<body>
%[elements["p_datetime"].html%]
</body>
</html>
~~~~

また、`app.d`は次のようになります。

~~~~d
import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.text;
import awebview.wrapper;

import std.datetime;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;
    app.createActivity(pref, delegate(WebSession session){
        auto activity = new SDLActivity("MainActivity", 600, 400, "Hello!", session);
        activity ~= new ClockPage("clockPage");
      
        activity.load("clockPage");
        return activity;
    });
    
    app.run();
}


class ClockPage : TemplateHTMLPage!(import(`clock.html`))
{
    this(string id)
    {
        super(id, null);
        this ~= _p = new Paragraph!()("p_datetime");
    }


    override
    void onUpdate()
    {
        super.onUpdate();
        _p.text = Clock.currTime.toSimpleString();
    }

  private:
    Paragraph!() _p;
}
~~~~


## 複数のウィンドウを開く

Activityを新たに作成し、Applicationにattachするだけで新たなウィンドウを開くことができます。

~~~~~~~~~~~~~~~d
import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.wrapper;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;
    app.createActivity(pref, delegate(WebSession session){
        auto activity = new SDLActivity("MainActivity1", 600, 400, "Hello!", session);
        auto helloPage = new TemplateHTMLPage!(import("hello.html"))("hello", null);

        activity ~= helloPage;
        activity.load("hello");

        return activity;
    });

    app.createActivity(pref, delegate(WebSession session){
        auto activity = new SDLActivity("MainActivity2", 600, 400, "Hello!", session);
        auto helloPage = new TemplateHTMLPage!(import("hello.html"))("hello", null);

        activity ~= helloPage;
        activity.load("hello");

        return activity;
    });
    
    // アプリケーションを走らせる
    app.run();
}
~~~~~~~~~~~~~~~


## データを保存したり、前回のデータを復元する

ウィンドウやページの終了時にデータを保存したり、逆に開始時にデータを復元することができます。
データを復元したい場合、`onStart`か`onAttach`などで復元処理を行います。
データの保存は`onDestroy`もしくは`onDetach`で行います。
データは、`application.savedData`に`ubyte[][string]`として保存されています。
推奨される保存データの格納方法は、`awebview.gui.datapack. DataPack`をmsgpackでシリアライズし、そのバイト列を`savedData[this.id]`に格納する方法です。
復元は逆に`savedData[this.id]`からバイト列を取得し、msgpackでデシリアライズします。

~~~~~~~~~~~~~~~~~d
class SavedPage : TemplateHTMLPage!(import("hello.html"))
{
    this(string id) { super(id, null); }


    override
    void onStart(Activity activity)
    {
        auto sd = activity.application.savedData;
        if(ubyte[]* p = this.id in sd){
            auto data = unpack!(DataPack!(int, string))(*p);
            
            // 親クラスの復元を行う
            *p = data.parent;
            super.onStart(activity);

            /*
            data.field[0]や、data.field[1]から復元する
            */
        }else
            super.onStart(activity);
    }



    override
    void onDestroy()
    {
        auto sd = activity.application.savedData;

        // 親クラスの破壊と保存
        super.onDestroy();

        DataPack!(int, string) dp;
        dp.field[0] = ...;  // int
        dp.field[1] = ...;  // string
        dp.parent = sd.get(this.id, null);  // 親クラスの情報を保存する

        // シリアライズして格納する
        sd[this.id] = pack(dp);
    }
}
~~~~~~~~~~~~~~~~~~


## CSSでJavascriptの式を評価する

awebviewでは、HTMLPageが読み込まれた際にCSSを解析することで、CSSに特殊な拡張を施しています。
次のように、`jsExpr(...)`と書くと、画面や表示領域の大きさが変更された際に`...`に記述したJavascriptの式が評価されます。

~~~~~~css
html, body {
  width:  100%;
  height: 100%;
}

#btn1 {
  width: jsExpr(docElem.width/2);   // (document.documentElement.width / 2)px となる
}
~~~~~~~~~


## ハイパーリンクによるページ遷移

特殊なフォーマットをしたハイパーリンクにより、HTMLPageを切り替えることができます。

~~~~~~~~html
<!doctype html>
<html lang="jp">
<head>
    <title>Hello</title>
</head>
<body>
Now, you are watching the page whose id is "%[id%]".
<br>
<!-- 'Activity-%[ActivityID%]-HTMLPage-%[PageID%]'というフォーマットで、ActivityIDのアクティビティにPageIDというページを読み込む -->
<!-- この例では、リンクがクリックされると、自分のアクティビティに他のページが読み込まれる -->
<a href='Activity-%[activity.id%]-HTMLPage-%[id == "A" ? "B" : "A"%]'>Load other page.</a>
</body>
</html>
~~~~~~~~
