module awebview.gui.application;

import std.exception;
import std.file;

import awebview.wrapper.webcore;

import awebview.gui.activity;
import deimos.glfw.glfw3;

class GLFWApplication
{
    this(GLFWActivity delegate(WebSession) createActivity)
    {
        enforce(glfwInit());
        auto config = WebConfig();
        config.additionalOptions ~= "--use-gl=desktop";
        WebCore webCore = WebCore.initialize(config);
        auto pref = WebPreferences.recommended;

        if(exists("style.css")){
            pref.userStylesheet = readText("style.css");
        }

        auto session = webCore.createWebSession(WebString(""), pref);

        _act = createActivity(session);
    }


    @property
    GLFWActivity activity() pure nothrow @safe @nogc
    {
        return _act;
    }


    void run()
    {
        while(!_act.isShouldClosed)
        {
            import core.thread : Thread, dur;
            import std.string : format;

            WebCore.instance.update();
            _act.onUpdate();
            glfwPollEvents();

            glfwSwapBuffers(_act.glfwWindow);

            Thread.sleep(dur!"msecs"(10));
        }
    }


    void shutdown()
    {
        _act.onDestroy();
        glfwTerminate();
        WebCore.shutdown();
    }


  private:
    GLFWActivity _act;
}
