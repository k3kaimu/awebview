module main_page;

import std.file;
import std.json;

import awebview.wrapper;
import awebview.gui.html;
import awebview.gui.widgets.button;
import awebview.gui.widgets.text;

import graphite.twitter;

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


    this()
    {
        super("mainPage");

        _tweetTable = new TweetTable("tweetTable");
        this ~= _tweetTable;

        this ~= new TweetTextArea(`iptTweetText`);

        this ~= (){
            auto btn = new NormalButton(`btnTweet`);
            btn.onClick.connect!"onClickTweet"(this);
            btn.staticSet("value", "ツイート");
            return btn;
        }();
    }


    override
    void onLoad(bool isInit)
    {
        super.onLoad(isInit);

        if(exists(tokenFile)){
            _twTkn = unpack!Twitter(cast(ubyte[])std.file.read(tokenFile));
            onConnect();
        }else if(!activity["oauthPage"].to!OAuthPage.token.isNull){
            _twTkn = activity["oauthPage"].to!OAuthPage.token;
            std.file.write(tokenFile, pack(_twTkn));
            onConnect();
        }else{
            activity.load("oauthPage");
        }
    }


    void onConnect()
    {
        auto res = _twTkn.callAPI!"userstream.user"(null);
        _userstream = res.channel;
    }


    override
    void onUpdate()
    {
        super.onUpdate();

        while(1)
        {
            if(auto p = _userstream.popFront()){
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
    Twitter _twTkn;
    shared(AtomicDList!string) _userstream;
}
