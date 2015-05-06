module main_page;

import std.concurrency;
import std.file;
import std.json;
import std.typecons;
import std.stdio;

import awebview.wrapper;
import awebview.gui.html;
import awebview.gui.datapack;
import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.widgets.button;
import awebview.gui.widgets.text;

import graphite.twitter;

import carbon.functional;

import msgpack;
import lock_free.dlist;

import consts;
import oauth_page;
import tweet_table;


class MainPage :  TemplateHTMLPage!(import(`main_page.html`))
{
    private
    alias NormalButton = InputButton!(["class": "btn btn-xs btn-primary"]);

    private
    alias TweetTextArea = TextArea!();

    private
    alias PackedDataType = DataPack!(bool, Twitter);


    this()
    {
        super("mainPage");

        _tweetTable = new TweetTable("tweetTable");
        this ~= _tweetTable;

        this ~= new TweetTextArea(`iptTweetText`);

        this ~= new NormalButton(`btnTweet`).digress!((a){
            a.onClick.connect!"onClickTweet"(this);
            a.staticProps["value"] = "ツイート";
        });
    }


    override
    void onStart(Activity activity)
    {
        if(auto p = this.id in activity.application.savedData){
            auto origin = *p;
            auto pd = PackedDataType.unpack(*p);

            if(pd.field[0])
                _twTkn = pd.field[1];

            *p = pd.parent;
            super.onStart(activity);
            *p = origin;
        }
        else
        {
            super.onStart(activity);
        }
    }


    override
    void onLoad(bool isInit)
    {
        super.onLoad(isInit);

        if(this._twTkn.isNull)
        {
            if(activity["oauthPage"].to!OAuthPage.token.isNull)
                activity.load("oauthPage");
            else{
                _twTkn = activity["oauthPage"].to!OAuthPage.token;
                connectUserStream();
            }
        }
        else
            connectUserStream();
    }


    override
    void onDestroy()
    {
        super.onDestroy();

        if(!_twTkn.isNull){
            PackedDataType pd;

            if(auto p = this.id in SDLApplication.instance.savedData)
                pd.parent = *p;

            pd.field[0] = !_twTkn.isNull;
            if(!_twTkn.isNull)
                pd.field[1] = _twTkn.get;

            SDLApplication.instance.savedData[this.id] = pd.pack();

            _usTid.send(false);    // send dummy message
        }
    }


    void connectUserStream()
    {
        auto res = _twTkn.callAPI!"userstream.user"(null);
        _us = res.channel;
        _usTid = res.tid;
    }


    override
    void onUpdate()
    {
        super.onUpdate();

        while(1)
        {
            if(auto p = _us.popFront()){
                try{
                    string tw = *p;
                    auto json = parseJSON(tw);
                    _tweetTable.addTweet(json["user"]["profile_image_url"].str, json["user"]["name"].str, json["text"].str);
                }
                catch(Exception){}
            }
            else
                break;
        }
    }


    void onClickTweet(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto txtArea = elements["iptTweetText"].to!(TextArea!());

        auto tweetText = txtArea.text();
        if(tweetText.length){
            _twTkn.callAPI!"statuses.update"(["status": tweetText]);
            txtArea.text = "";
        }
    }


  private:
    TweetTable _tweetTable;
    Nullable!Twitter _twTkn;
    shared(AtomicDList!string) _us;
    Tid _usTid;
}
