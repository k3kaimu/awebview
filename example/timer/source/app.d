
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
        _dora = SoundChunk.fromFile(oggFileName);
        _state = State.ended;
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
        reloadTotalSeconds();

        if(_state == State.ended){
            auto diffSp = dur!"seconds"(_totalSecs).split!("minutes", "seconds", "msecs");
            _txt_timer.text = format("%02d:%02d:%02d", diffSp.minutes, diffSp.seconds, diffSp.msecs / 10);
            this.activity[$("#progress_bar")]["style.width"] = "100%";
        }else{
            auto curr = Clock.currTime;

            bool isPos = curr < _end;
            auto diff = _end - curr;
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

            if(_state == State.started){
                if(diffSp.minutes == 0){
                    _state = State.lastOneMin;
                    _sndCh.play(_dora);
                }
            }else if(_state == State.lastOneMin && diffSp.seconds <= 0 && diffSp.msecs <= 0){
                _state = State.overLimit;
                _sndCh.play(_dora);
                application.to!SDLApplication.timer.addTask(dur!"msecs"(700), (){ _sndCh.play(_dora); });
            }

            this.activity[$("#progress_bar")]["style.width"] = format("%f%%", pg);
        }
    }


    void onTimerStart(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        reloadTotalSeconds();
        _start = Clock.currTime;
        _end = _start + dur!"seconds"(_totalSecs);

        _state = State.started;
        this.elements["btn_start"]["disabled"] = true;
        this.elements["txt_secs"]["disabled"] = true;

        _sndCh.play(_dora);
    }


    void onTimerReset(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        _state = State.ended;
        this.elements["btn_start"]["disabled"] = false;
        this.elements["txt_secs"]["disabled"] = false;
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
    }

  private:
    SysTime _start, _end;
    uint _totalSecs = 5 * 60;
    State _state;
    ITextInput _txt_secs;
    ITextOutput _txt_timer;

    SoundChannel _sndCh;
    SoundChunk _dora;


    enum State { started, lastOneMin, overLimit, ended }
}
