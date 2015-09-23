module sound_page;

import std.functional;

import awebview.wrapper;
import awebview.sound;

import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.methodhandler;
import awebview.gui.widgets.button;
import awebview.gui.widgets.text;
import std.stdio;

class SoundPage : TemplateHTMLPage!(import(`sound_page.html`))
{
    this()
    {
        super("SoundPage", null);
        _amp = new Amplifier;
        _amp.amplitude = 1.0;

        this ~= new InputButton!()("btn_snd").unaryFun!((a){
            a.staticProps["value"] = "Play";
            a.onClick.strongConnect((ctx, args){
                _amp.amplitude = _txt_amp.text.to!float;
                _chunk = SoundChunk.fromFile(_txt_snd.text);
                _ch.play(_chunk);
            });
            return a;
        });

        this ~= new InputText!()("txt_snd").unaryFun!((a){
            _txt_snd = a; return a;
        });

        this ~= new InputText!()("txt_amp").unaryFun!((a){
            _txt_amp = a; return a;
        });
    }


    override
    void onStart(Activity activity)
    {
        super.onStart(activity);
        this ~= application.to!SDLApplication.soundManager.newChannel("ch1").unaryFun!((a){
            _ch = a; return a;
        });
        _ch.effector = _amp;
    }

  private:
    InputText!() _txt_snd;
    InputText!() _txt_amp;
    SoundChunk _chunk;
    SoundChannel _ch;
    Amplifier _amp;
}


final class Amplifier
{
    void applyEffect(uint ch, void[] stream)
    {
        short[] buf = cast(short[])stream;
        foreach(ref e; buf)
            e = cast(short)(e * _amp);
    }


    void done(uint ch)
    {

    }


    void amplitude(float v)
    {
        _amp = v;
    }


  private:
    float _amp;
}
