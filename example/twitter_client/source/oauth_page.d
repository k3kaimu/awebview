module oauth_page;

import std.typecons;
import std.process;

import awebview.wrapper;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.gui.widgets.text;

import graphite.twitter;


class OAuthPage : TemplateHTMLPage!(import(`oauth_page.html`))
{
    private
    alias NormalButton = InputButton!(["class": "btn btn-xs btn-primary"]);


    this()
    {
        super("oauthPage");

        this ~= new InputText!()("iptCnsKey");
        this ~= new InputText!()("iptCnsSct");

        this ~= (){
            auto btn = new NormalButton("btnOpenBrowser");
            btn.onClick.connect!"onClickOpenBrowser"(this);
            btn.staticSet("value", "ブラウザで開く");
            return btn;
        }();


        this ~= new InputText!()("iptPinCode");

        this ~= (){
            auto btn = new NormalButton("btnDoOAuth");
            btn.onClick.connect!"onClickDoOAuth"(this);
            btn.staticSet("value", "認証");
            return btn;
        }();
    }


    void onClickOpenBrowser(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto cnsKey = elements["iptCnsKey"].to!ITextInput.text(),
             cnsSct = elements["iptCnsSct"].to!ITextInput.text();

        if(_twTkn.isNull && cnsKey.length && cnsSct.length){
            auto cnsTkn = ConsumerToken(cnsKey, cnsSct);
            _twTkn = Twitter(Twitter.oauth.requestToken(cnsTkn, null));
            browse(_twTkn.callAPI!"oauth.authorizeURL"());
        }
    }


    void onClickDoOAuth(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto pinCode = elements["iptPinCode"].to!ITextInput.text();
        if(!_twTkn.isNull && pinCode.length){
            _twTkn = Twitter(_twTkn.callAPI!"oauth.accessToken"(pinCode));
        }

        elements["btnOpenBrowser"]["disabled"] = true;
        elements["btnDoOAuth"]["disabled"] = true;
        activity.load("mainPage");
    }


    //void onClickTweet(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    //{
    //    auto txtArea = elements["iptTweetText"].to!(TextArea!());

    //    auto tweetText = txtArea.text();
    //    if(!_twTkn.isNull && tweetText.length){
    //        _twTkn.callAPI!"statuses.update"(["status": tweetText]);
    //        txtArea.text = "";
    //    }
    //}


    Nullable!Twitter token()
    {
        return _twTkn;
    }


  private:
    NormalButton _btnOpenBrowser;
    Nullable!Twitter _twTkn;
}
