import awebview.gui.application;
import awebview.gui.activity;
import awebview.gui.html;
import awebview.gui.widgets.text;
import awebview.wrapper;

import std.datetime;
import carbon.functional;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;

    with(app.newFactoryOf!SDLActivity(pref)){
        id = "MainActivity";
        width = 600;
        height = 400;
        title = "Hello!";

        app.addActivity(newInstance.passTo!((a){
            a.load(new ClockPage("clockPage"));
        }));
    }

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