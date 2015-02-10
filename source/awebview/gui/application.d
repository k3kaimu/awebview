module awebview.gui.application;

import awebview.wrapper.webcore;

import awebview.gui.activity;
import deimos.glfw.glfw3;

class GLFWApplication
{
    this(GLFWActivity activity)
    {
        _act = activity;
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
            glfwPollEvents();

            _act.title = format("fooo %s", fmNum);
            ++fmNum;

            glfwSwapBuffers(_act.glfwWindow);

            Thread.sleep(dur!"msecs"(10));
        }
    }


  private:
    GLFWActivity _act;
    ulong fmNum;
}
