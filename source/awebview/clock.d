module awebview.clock;


import std.datetime;
import std.container;


final class Timer
{
    this()
    {
        _tasks = new typeof(_tasks)();
    }


    void addTask(SysTime time, void delegate() task)
    {
        _tasks.insert(Task(time, task));
    }


    void addTask(Duration delay, void delegate() task)
    {
        addTask(Clock.currTime + delay, task);
    }


    void addRepeatTask(Duration delay, Duration interval, ulong times, void delegate() task)
    {
        static struct T
        {
           Duration interval;
           ulong times;
           void delegate() task;
           Timer timer;

           void call()
           {
                task();
                --times;
                if(times > 0)
                    timer.addTask(interval, &call);
           }
        }

        T t;
        t.interval = interval;
        t.times = times;
        t.task = task;
        t.timer = this;

        addTask(delay, &(t.call));
    }


    void onUpdate()
    {
        while(!_tasks.empty && _tasks.front.t < Clock.currTime){
            auto dg = _tasks.front.task;
            _tasks.removeFront();
            dg();
        }
    }


  private:
    static struct Task
    {
        SysTime t;
        void delegate() task;
    }

  private:
    RedBlackTree!(Task, "a.t < b.t") _tasks;
}



final class TimeSchedular(T)
{
    import std.container;
    import std.typecons;

  private
  {
    alias Dg = void delegate();
  }

    this()
    {
        _tasks = new typeof(_tasks)();
    }


    void opIndexAssign(Dg dg, T time)
    {
        _tasks.insert(tuple(time, dg));
    }


    void update(T time)
    {
        while(!_tasks.empty && _tasks.front[0] < time){
            _tasks.front[1]();
            _tasks.removeFront();
        }
    }


    void clear()
    {
        _tasks.clear();
    }

  private:
    RedBlackTree!(Tuple!(T, Dg), "a[0] < b[0]") _tasks;
}
