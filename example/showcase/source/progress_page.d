module progress_page;

import awebview.gui.html;
import awebview.gui.widgets.progress;

import carbon.functional;


class ProgressPage : TemplateHTMLPage!(import(`progress_page.html`))
{
    this()
    {
        super("progressPage", null);
        this ~= (new Progress("p1")).observe!((a){ _p1 = a; });
        this ~= new Progress("p2");
    }


    override
    void onUpdate()
    {
        ++cnt;
        if(cnt > 1000)
            cnt = 0;

        _p1.value = cnt / 1000.0;
    }


  private:
    size_t cnt;
    IProgress _p1;
}
