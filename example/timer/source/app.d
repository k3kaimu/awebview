
import std.stdio;
import std.string;
import std.stdio;
import std.conv;
import std.datetime;
import std.exception;
import std.variant;

import carbon.templates;
import carbon.utils;
import carbon.functional;

import awebview.wrapper;

import awebview.sound;

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
    with(app.newFactoryOf!SDLActivity(WebPreferences.recommended)){
        id = "MainActivity";
        width = 1200;
        height = 600;
        title = "Timer by D(awebview HTML)";

        app.addActivity(newInstance.digress!((a){
            a.load(new TimerPage("timer_page", effectMusicFile));
        }));
    }

    app.run();
}


class TimerPage : TemplateHTMLPage!(import(`main_view.html`))
{
    this(string id, string oggFileName)
    {
        super(id, null);

        this ~= new Paragraph!(["style": "font-size: 15em;"])("txt_timer").digress!((a){ _txt_timer = a; });
        this ~= new InputText!()("txt_secs").digress!((a){ _txt_secs = a; });
        this ~= new InputButton!(["class" : "btn btn-lg btn-primary"])("btn_start").digress!((a){
            a.onClick.connect!"onTimerStart"(this);
        });
        this ~= new InputButton!(["class" : "btn btn-lg btn-warning"])("btn_reset").digress!((a){
            a.onClick.connect!"onTimerReset"(this);
        });
        this ~= new GenericButton!(import(`radio_fb_btn.html`))("radio_fb_btn").digress!((a){
            a.onClick.connect!"onChangeDirection"(this);
        });
        _dora = SoundChunk.fromFile(oggFileName);
    }


    override
    void onStart(Activity activity)
    {
        super.onStart(activity);

        this ~= application.to!SDLApplication.soundManager.newChannel("snd_channel").digress!((a){
            _sndCh = a;
        });
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

        bool isPos = curr >= _start;
        auto diff = (curr - _start);
        if(!_isForward){
            isPos = dur!"seconds"(_totalSecs) >= diff;
            diff = dur!"seconds"(_totalSecs) - diff;
        }

        auto diffSp = diff.split!("minutes", "seconds", "msecs")();

        if(!isPos)
            _txt_timer.text = format("-%02d:%02d:%02d", -diffSp.minutes, -diffSp.seconds, -diffSp.msecs / 10);
        else
            _txt_timer.text = format("%02d:%02d:%02d", diffSp.minutes, diffSp.seconds, diffSp.msecs / 10);

        real pg = 100 * ((diffSp.minutes*60 + diffSp.seconds) * 1000 + diffSp.msecs) / (_totalSecs * 1000.0L);

        if(pg >= 100)
            pg = 100;
        else if(pg < 0)
            pg = 0;

        if(_isStarted && !_isForward && !_callLastOneMin){
            if(diffSp.minutes == 0){
                _callLastOneMin = true;
                _sndCh.play(_dora);
            }
        }

        this.activity[$("#progress_bar")]["style.width"] = format("%f%%", pg);
    }


    void onTimerStart(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        _isStarted = true;
        _start = Clock.currTime;
        reloadTotalSeconds();
        this.elements["btn_start"]["disabled"] = true;
        _sndCh.play(_dora);
        _callLastOneMin = false;
    }


    void onTimerReset(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        _isStarted = false;
        this.elements["btn_start"]["disabled"] = false;
        _callLastOneMin = false;
    }


    void onChangeDirection(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        if(_isStarted)
            return;

        assert(args.length == 1);
        assert(args[0].isString);

        _isForward = "forward"w == args[0].get!(WebString).data;
        this.activity[$("#radio_fb_btn_f")]["disabled"] = _isForward;
        this.activity[$("#radio_fb_btn_b")]["disabled"] = !_isForward;
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
        this.activity[$("#radio_fb_btn_f")]["disabled"] = _isForward;
        this.activity[$("#radio_fb_btn_b")]["disabled"] = !_isForward;
    }

  private:
    SysTime _start;
    bool _isStarted;
    uint _totalSecs = 5 * 60;
    bool _isForward = true;
    bool _callLastOneMin = false;
    ITextInput _txt_secs;
    ITextOutput _txt_timer;

    SoundChannel _sndCh;
    SoundChunk _dora;
}
