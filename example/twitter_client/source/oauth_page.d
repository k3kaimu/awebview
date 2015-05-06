module oauth_page;

import std.typecons;
import std.process;

import awebview.wrapper;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.gui.widgets.text;
import awebview.gui.application;

import graphite.twitter;

import carbon.functional;


class OAuthPage : TemplateHTMLPage!(import(`oauth_page.html`))
{
    private
    alias NormalButton = InputButton!(["class": "btn btn-xs btn-primary"]);


    this()
    {
        super("oauthPage");

        this ~= new InputText!()("iptCnsKey");
        this ~= new InputText!()("iptCnsSct");

        this ~= new NormalButton("btnOpenBrowser").digress!((a){
            a.onClick.connect!"onClickOpenBrowser"(this);
            a.staticProps["value"] = "ブラウザで開く";
        });

        this ~= new NormalButton("btnDoOAuth").digress!((a){
            a.onClick.connect!"onClickDoOAuth"(this);
            a.staticProps["value"] = "認証";
        });

        this ~= new InputText!()("iptPinCode");
    }


    void onClickOpenBrowser(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto cnsKey = elements["iptCnsKey"].to!ITextInput.text(),
             cnsSct = elements["iptCnsSct"].to!ITextInput.text();

        if(_twTkn.isNull && cnsKey.length && cnsSct.length){
            auto cnsTkn = ConsumerToken(cnsKey, cnsSct);
            _twTkn = Twitter(Twitter.oauth.requestToken(cnsTkn, null));
            //browse(_twTkn.callAPI!"oauth.authorizeURL"());
            activity.addChild(application.to!SDLApplication.createActivity(WebPreferences.recommended,
            new WebPage("oauthWebPage", _twTkn.callAPI!"oauth.authorizeURL"()), "oauthWebPageActivity", 600, 400, "Twitter OAuth"));
        }
    }


    override
    void onUpdate()
    {
        if(auto pTwiPage = "oauthWebPageActivity" in activity.children)
        {
            if((*pTwiPage).querySelectorAll("#code-desc")["length"].get!uint){
                string str = (*pTwiPage)[$("code")]["innerHTML"].to!string;
                elements["iptPinCode"].to!ITextOutput.text = str;
                activity.children["oauthWebPageActivity"].close();
                onClickDoOAuthImpl();
            }
        }
    }


    void onClickDoOAuth(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        onClickDoOAuthImpl();
    }


    void onClickDoOAuthImpl()
    {
        auto pinCode = elements["iptPinCode"].to!ITextInput.text();
        if(!_twTkn.isNull && pinCode.length){
            _twTkn = Twitter(_twTkn.callAPI!"oauth.accessToken"(pinCode));
        }

        elements["btnOpenBrowser"]["disabled"] = true;
        elements["btnDoOAuth"]["disabled"] = true;
        activity.load("mainPage");
    }


    Nullable!Twitter token()
    {
        return _twTkn;
    }


  private:
    NormalButton _btnOpenBrowser;
    Nullable!Twitter _twTkn;
}
