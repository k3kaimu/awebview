module awebview.gui.application;

import std.exception;
import std.file;

import awebview.wrapper.webcore;

import awebview.gui.activity;
import derelict.sdl2.sdl;
import msgpack;
import carbon.utils;

import core.thread;


abstract class Application
{
    this(string savedFileName)
    {
        _savedFileName = savedFileName;
        if(exists(savedFileName))
            _savedData = unpack!(ubyte[][string])(cast(ubyte[])std.file.read(savedFileName));
    }


    void onDestroy();

    final
    @property
    ref ubyte[][string] savedData() pure nothrow @safe @nogc { return _savedData; }

    void addActivity(Activity activity);

    Activity getActivity(string id);

    void attachActivity(string id);
    void detachActivity(string id);
    void destroyActivity(string id);

    void run();
    bool isRunning() @property;

    void shutdown()
    {
        if(_savedData.length)
            std.file.write(_savedFileName, pack(_savedData));
    }

  private:
    ubyte[][string] _savedData;
    string _savedFileName;
}


class SDLApplication : Application
{
    static immutable savedDataFileName = "saved.mpac";

    private
    this()
    {
        super(savedDataFileName);
    }


    static
    SDLApplication instance() @property
    {
        if(_instance is null){
            DerelictSDL2.load();
            enforce(SDL_Init(SDL_INIT_VIDEO) >= 0);

            auto config = WebConfig();
            config.additionalOptions ~= "--use-gl=desktop";
            WebCore.initialize(config);

            _instance = new SDLApplication();
        }

        return _instance;
    }


    override
    void onDestroy()
    {
        while(_acts.length){
            foreach(id, activity; _acts.maybeModified){
                activity.onDetach();
                activity.onDestroy();
                if(_acts[id] is activity)
                    _acts.remove(id);
            }
        }

        while(_detachedActs.length){
            foreach(id, activity; _detachedActs.maybeModified){
                activity.onDestroy();
                if(_detachedActs[id] is activity)
                    _detachedActs.remove(id);
            }
        }
    }


    A createActivity(A : SDLActivity)(WebPreferences pref, A delegate(WebSession) dg)
    {
        auto session = WebCore.instance.createWebSession(WebString(""), pref);

        auto act = dg(session);
        addActivity(act);

        return act;
    }


    override
    void addActivity(Activity act)
    in {
      assert(typeid(act) == typeid(SDLActivity));
    }
    body {
        addActivity(cast(SDLActivity)act);
    }


    void addActivity(SDLActivity act)
    in {
        assert(act !is null);
    }
    body {
        _acts[act.id] = act;

        if(_isRunning){
            act.onStart(this);
            act.onAttach();
        }
    }


    final
    @property
    SDLActivity[string] activities() pure nothrow @safe @nogc
    {
        return _acts;
    }


    final
    SDLActivity getActivity(uint windowID)
    {
        foreach(k, a; _acts)
            if(a.windowID == windowID)
                return a;

        return null;
    }


    final override
    SDLActivity getActivity(string id)
    {
        return _acts.get(id, null);
    }


    final
    SDLActivity getActivity(SDL_Window* sdlWind)
    {
        foreach(k, a; _acts)
            if(a.sdlWindow == sdlWind)
                return a;

        return null;
    }


    override
    void attachActivity(string id)
    {
        auto act = _detachedActs[id];
        act.onAttach();
        _detachedActs.remove(id);
        _acts[id] = act;
    }


    override
    void detachActivity(string id)
    {
        auto act = _acts[id];
        act.onDetach();
        _acts.remove(id);
        _detachedActs[id] = act;
    }


    override
    void destroyActivity(string id)
    {
        if(auto p = id in _acts){
            auto act = *p;
            act.onDetach();
            act.onDestroy();
            _acts.remove(id);
        }else if(auto p = id in _detachedActs){
            auto act = *p;
            act.onDestroy();
            _detachedActs.remove(id);
        }else
            enforce(0);
    }


    override
    void run()
    {
        _isRunning = true;

        auto wc = WebCore.instance;
        wc.update();

        foreach(k, a; _acts.maybeModified){
            a.onStart(this);
            a.onAttach();
        }

      LInf:
        while(!_isShouldQuit)
        {
            {
                SDL_Event event;
                while(SDL_PollEvent(&event)){
                    onSDLEvent(&event);
                    if(_isShouldQuit)
                        break LInf;
                }
            }

            foreach(k, a; _acts.maybeModified){
                a.onUpdate();

                if(a.isShouldClosed)
                    destroyActivity(a.id);

                if(_isShouldQuit)
                    break LInf;
            }

            if(_acts.length == 0)
                shutdown();

            foreach(k, a; _detachedActs.maybeModified){
                if(a.isShouldClosed)
                    destroyActivity(a.id);

                if(_isShouldQuit)
                    break LInf;
            }

            Thread.sleep(dur!"msecs"(10));
            wc.update();
        }
        _isRunning = false;

        shutdown();
    }


    override
    @property
    bool isRunning() { return _isRunning; }


    override
    void shutdown()
    {
        if(!_isShouldQuit && _isRunning)
            _isShouldQuit = true;
        else{
            _isRunning = false;
            _isShouldQuit = true;

            this.onDestroy();
            super.shutdown();

            SDL_Quit();
            WebCore.shutdown();
        }
    }


    void onSDLEvent(const SDL_Event* event)
    {
        foreach(k, a; _acts.maybeModified)
            a.onSDLEvent(event);

        switch(event.type)
        {
          case SDL_QUIT:
            shutdown();
            break;

          default:
            break;
        }
    }


  private:
    SDLActivity[string] _acts;
    SDLActivity[string] _detachedActs;
    bool _isRunning;
    bool _isShouldQuit;
    ubyte[][string] _savedData;

    static SDLApplication _instance;
}
