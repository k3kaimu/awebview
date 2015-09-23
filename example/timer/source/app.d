
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
import awebview.clock;
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
shared immutable effectMusicFile1 = "nc39753.ogg";
shared immutable effectMusicFile2 = "foo.ogg";


void main()
{
    auto app = SDLApplication.instance;
    with(app.newFactoryOf!SDLActivity(WebPreferences.recommended)){
        id = "MainActivity";
        width = 1200;
        height = 800;
        title = "Timer by D(awebview HTML)";

        app.addActivity(newInstance.passTo!((a){
            a.load(new TimerPage("timer_page"));
        }));
    }

    app.run();
}


class TimerPage : TemplateHTMLPage!(import(`main_view.html`))
{
    this(string id)
    {
        super(id, null);

        this ~= new Paragraph!(["style": "font-size: 20em;"])("txt_timer").passTo!((a){ _txt_timer = a; });
        //this ~= new InputText!()("txt_pres_secs").passTo!((a){ _txt_secs = a; });

        foreach(key; ["txt_pres_secs", "txt_ques_secs", "txt_bell1_secs", "txt_bell2_secs", "txt_bell3_secs", "txt_bell_interval_msecs"])
            this ~= new InputText!()(key).passTo!((a){ _txtTimes[key] = a; });

        this ~= new InputButton!(["class" : "btn btn-lg btn-primary"])("btn_start").passTo!((a){
            a.onClick.connect!"onTimerStart"(this);
        });
        this ~= new InputButton!(["class" : "btn btn-lg btn-warning"])("btn_reset").passTo!((a){
            a.onClick.connect!"onTimerReset"(this);
        });
        _thin = SoundChunk.fromFile(effectMusicFile1);
        _dora = SoundChunk.fromFile(effectMusicFile2);
        _state = State.ended;
        _schedular = new TimeSchedular!SysTime;
    }


    override
    void onStart(Activity activity)
    {
        super.onStart(activity);

        foreach(i, key; ["snd_channel1", "snd_channel2", "snd_channel3"])
            this ~= application.to!SDLApplication.soundManager.newChannel(key).passTo!((a){
                _sndCh[i] = a;
            });
    }


    override
    void onUpdate()
    {
        auto curr = Clock.currTime;

        super.onUpdate();
        reloadTotalSeconds();
        _schedular.update(curr);


        void showTimerText(Duration d)
        {
            auto diffSp = d.split!("minutes", "seconds", "msecs");

            if(d < dur!"seconds"(0))
                _txt_timer.text = format("-%02d:%02d:%02d", -diffSp.minutes, -diffSp.seconds, -diffSp.msecs / 10);
            else
                _txt_timer.text = format("%02d:%02d:%02d", diffSp.minutes, diffSp.seconds, diffSp.msecs / 10);
        }


        void setProgress(float p)
        {
            if(p > 1) p = 1;
            if(p < 0) p = 0;
            p *= 100;
            this.activity[$("#progress_bar")]["style.width"] = format("%f%%", p);
        }


        final switch(_state)
        {
          case State.ended:
            showTimerText(_presDur);
            setProgress(1);
            break;

          case State.started:
            auto remain = _presDur - (curr - _start);
            showTimerText(remain);
            setProgress(remain.total!"msecs" * 1.0 / _presDur.total!"msecs");
            break;

          case State.question:
            auto remain = (_presDur + _quesDur) - (curr - _start);
            showTimerText(remain);
            setProgress(1 - remain.total!"msecs" * 1.0 / _quesDur.total!"msecs");
            break;

          case State.overLimit:
            auto over = -((_presDur + _quesDur) - (curr - _start));
            showTimerText(over);
            setProgress(1);
            break;
        }
    }


    void onTimerStart(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        reloadTotalSeconds();
        _start = Clock.currTime;

        // set timer
        foreach(i; ToTuple!(TRIota!(0, 3)))
            foreach(j; ToTuple!(TRIota!(0, i+1)))
                _schedular[_start + _bellDur[i] + j*_bellInterval] = { _sndCh[j].play( j == 2 ? _dora : _thin ); };

        // set transition timer
        _schedular[_start + _presDur] = { _state = State.question; };
        _schedular[_start + _presDur + _quesDur] = { _state = State.overLimit; };

        _state = State.started;
        foreach(key; ["btn_start", "txt_pres_secs", "txt_ques_secs", "txt_bell1_secs", "txt_bell2_secs", "txt_bell3_secs", "txt_bell_interval_msecs"])
            this.elements[key]["disabled"] = true;
    }


    void onTimerReset(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        _schedular.clear();
        _state = State.ended;
        foreach(key; ["btn_start", "txt_pres_secs", "txt_ques_secs", "txt_bell1_secs", "txt_bell2_secs", "txt_bell3_secs", "txt_bell_interval_msecs"])
            this.elements[key]["disabled"] = false;
    }


    void reloadTotalSeconds()
    {
        void setSeconds(string unit = "seconds", T)(ref T t, string id, uint defSecs)
        {
            try t = _txtTimes[id].text.to!uint.dur!unit;
            catch(ConvException) t = defSecs.dur!unit;
        }

        setSeconds(_presDur, "txt_pres_secs", 5*60);
        setSeconds(_quesDur, "txt_ques_secs", 2*60);
        setSeconds(_bellDur[0], "txt_bell1_secs", 4*60);
        setSeconds(_bellDur[1], "txt_bell2_secs", 5*60);
        setSeconds(_bellDur[2], "txt_bell3_secs", 7*60);
        setSeconds!"msecs"(_bellInterval, "txt_bell_interval_msecs", 700);
    }


    override
    void onLoad(bool isInit)
    {
        void resetTime(string unit = "seconds", T)(T t, string id)
        {
            this.elements[id]["value"] = t.total!unit;
        }

        super.onLoad(isInit);

        this.elements["btn_start"]["value"] = "Start";
        this.elements["btn_reset"]["value"] = "Reset";
        resetTime(_presDur, "txt_pres_secs");
        resetTime(_quesDur, "txt_ques_secs");
        resetTime(_bellDur[0], "txt_bell1_secs");
        resetTime(_bellDur[1], "txt_bell2_secs");
        resetTime(_bellDur[2], "txt_bell3_secs");
        resetTime!"msecs"(_bellInterval, "txt_bell_interval_msecs");
    }

  private:
    SysTime _start/*, _end*/;
    Duration _presDur, _quesDur;
    Duration[3] _bellDur;
    Duration _bellInterval;

    State _state;
    ITextInput[string] _txtTimes;
    ITextOutput _txt_timer;

    SoundChannel[3] _sndCh;
    SoundChunk _dora;
    SoundChunk _thin;

    TimeSchedular!SysTime _schedular;

    enum State { started, question, overLimit, ended }
}
