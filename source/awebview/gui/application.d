module awebview.gui.application;

import std.exception;
import std.file;

import awebview.wrapper.webcore;

import awebview.gui.activity;
import derelict.sdl2.sdl;

import core.thread;


/**
Initialize DerelictSDL2 and SDL2, Awesomium
*/
void defaultInitializeFunc()
{
    DerelictSDL2.load();
    enforce(SDL_Init(SDL_INIT_VIDEO) >= 0);

    auto config = WebConfig();
    config.additionalOptions ~= "--use-gl=desktop";
    WebCore.initialize(config);
}


class SDLApplication(alias initializeFunc = defaultInitializeFunc)
{
    private this()
    {
        //_isRunning = false;
        //_isShouldQuit = false;
    }


    static
    SDLApplication instance() @property
    {
        if(_instance is null){
            defaultInitializeFunc();
            _instance = new SDLApplication();
        }

        return _instance;
    }


    A createActivity(A : SDLActivity)(WebPreferences pref, A delegate(WebSession) dg)
    {
        auto session = WebCore.instance.createWebSession(WebString(""), pref);

        auto act = dg(session);
        addActivity(act);

        return act;
    }


    void addActivity(SDLActivity act)
    {
        _acts[act.id] = act;
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


    final
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


    void destroyActivity(string id)
    {
        auto act = getActivity(id);
        act.onDestroy();
        _acts.remove(id);
    }


    void run()
    {
        auto wc = WebCore.instance;

        _isRunning = true;
        while(!_isShouldQuit)
        {
            wc.update();
            {
                SDL_Event event;
                while(SDL_PollEvent(&event)){
                    onSDLEvent(&event);
                }
            }

            foreach(k, a; _acts){
                a.onUpdate();

                if(a.isShouldClosed)
                    destroyActivity(a.id);
            }

            Thread.sleep(dur!"msecs"(10));
        }
        _isRunning = false;

        shutdown();
    }


    void shutdown()
    {
        if(!_isShouldQuit && _isRunning)
            _isShouldQuit = true;
        else{
            _isRunning = false;
            _isShouldQuit = true;

            foreach(k, activity; _acts)
                activity.onDestroy();

            SDL_Quit();
            WebCore.shutdown();
        }
    }


    void onSDLEvent(const SDL_Event* event)
    {
        foreach(k, a; _acts)
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
    bool _isRunning;
    bool _isShouldQuit;

    static SDLApplication _instance;
}
