import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.text;
import awebview.wrapper;

import std.datetime;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;
    app.createActivity(pref, delegate(WebSession session){
      auto activity = new SDLActivity("MainActivity", 600, 400, "Hello!", session);
      activity ~= new ClockPage("clockPage");
      
      activity.load("clockPage");
      return activity;
    });
    
    app.run();
}


class ClockPage : TemplateHTMLPage!(import(`clock.html`))
{
    this(string id)
    {
        super(id, null);
        this ~= _p = new Paragraph!()("p_datetime");
    }


    override
    void onUpdate()
    {
        _p.text = Clock.currTime.toSimpleString();
    }

  private:
    Paragraph!() _p;
}