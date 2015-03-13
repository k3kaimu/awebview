
import std.stdio;
import std.string;
import std.stdio;
import std.conv;
import std.datetime;
import std.exception;
import std.variant;

import carbon.templates;
import carbon.utils;

import awebview.wrapper;

import awebview.gui.application,
       awebview.gui.activity,
       awebview.gui.html,
       awebview.gui.methodhandler,
       awebview.gui.widgets.button,
       awebview.gui.widgets.text;


/**
Please put a music file name.
*/
shared immutable effectMusicFile = "foo.ogg";


void main()
{
    auto app = SDLApplication.instance;
    app.createActivity(WebPreferences.recommended,
    delegate(WebSession session){
        auto activity = new SDLActivity("MainActivity", 1200, 600, "Timer by D(awebview HTML)", session);
        auto page = new TimerPage("timer_page", effectMusicFile);

        activity.load(page);
        return activity;
    });

    app.run();
}


class TimerPage : TemplateHTMLPage!(import(`main_view.html`))
{
    this(string id, string oggFileName)
    {
        super(id, ["dora_ogg": Variant(oggFileName)]);

        this ~= {
            auto txt_timer = new Paragraph!(["style": "font-size: 15em;"])("txt_timer");
            _txt_timer = txt_timer;
            return txt_timer;
        }();
        this ~= new IDOnlyElement("progress_bar");
        this ~= {
            auto txt_secs = new InputText!()("txt_secs");
            _txt_secs = txt_secs;
            return txt_secs;
        }();
        this ~= new IDOnlyElement("msc_start");
        this ~= {
            auto btn_start = new InputButton!(["class" : "btn btn-lg btn-primary"])("btn_start");
            btn_start.onClick.connect!"onTimerStart"(this);
            return btn_start;
        }();
        this ~= {
            auto btn_reset = new InputButton!(["class" : "btn btn-lg btn-warning"])("btn_reset");
            btn_reset.onClick.connect!"onTimerReset"(this);
            return btn_reset;
        }();
        this ~= {
            auto radio_fb_btn = new GenericButton!(import(`radio_fb_btn.html`))("radio_fb_btn");
            radio_fb_btn.onClick.connect!"onChangeDirection"(this);

            this ~= new IDOnlyElement("radio_fb_btn_f");
            this ~= new IDOnlyElement("radio_fb_btn_b");
            return radio_fb_btn;
        }();
    }


    override
    void onUpdate()
    {
        super.onUpdate();
        SysTime curr;

        reloadTotalSeconds();

        if(!_isStarted)
            curr = _start;
        else
            curr = Clock.currTime;

        auto diff = (curr - _start).split!("minutes", "seconds", "msecs")();
        if(!_isForward){
            diff = (dur!"seconds"(_totalSecs) - (curr - _start)).split!("minutes", "seconds", "msecs")();
        }

        _txt_timer.text = format("%02d:%02d:%02d", diff.minutes, diff.seconds, diff.msecs / 10);

        real pg = 0;
        if(diff.minutes >= 5)
            pg = 100;
        else
            pg = 100 * ((diff.minutes*60 + diff.seconds) * 1000 + diff.msecs) / (_totalSecs * 1000.0L);

        this.elements["progress_bar"]["style.width"] = format("%f%%", pg);
    }


    void onTimerStart(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        _isStarted = true;
        _start = Clock.currTime;
        reloadTotalSeconds();
        this.elements["btn_start"]["disabled"] = true;
        this.elements["msc_start"].invoke("play");
    }


    void onTimerReset(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        _isStarted = false;
        this.elements["btn_start"]["disabled"] = false;
    }


    void onChangeDirection(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        if(_isStarted)
            return;

        assert(args.length == 1);
        assert(args[0].isString);

        _isForward = "forward"w == args[0].get!(WebString).data;
        this.elements["radio_fb_btn_f"]["disabled"] = _isForward;
        this.elements["radio_fb_btn_b"]["disabled"] = !_isForward;
    }


    void reloadTotalSeconds()
    {
        try
            _totalSecs = _txt_secs.text.to!uint;
        catch(ConvException)
            _totalSecs = 5 * 60;
    }


    override
    void onLoad(bool isInit)
    {
        super.onLoad(isInit);

        this.elements["btn_start"]["value"] = "Start";
        this.elements["btn_reset"]["value"] = "Reset";
        this.elements["txt_secs"]["value"] = _totalSecs;
        this.elements["radio_fb_btn_f"]["disabled"] = _isForward;
        this.elements["radio_fb_btn_b"]["disabled"] = !_isForward;
    }

  private:
    SysTime _start;
    bool _isStarted;
    uint _totalSecs = 5 * 60;
    bool _isForward = true;
    ITextInput _txt_secs;
    ITextOutput _txt_timer;
}
