module progress_page;

import awebview.gui.html;
import awebview.gui.widgets.progress;

import carbon.functional;


class ProgressPage : TemplateHTMLPage!(import(`progress_page.html`))
{
    this()
    {
        super("progressPage", null);
        this ~= new Progress("p1").digress!((a){ _p1 = a; });
        this ~= new Progress("p2");
    }


    override
    void onUpdate()
    {
        if(_backward){
            --cnt;
            if(cnt == 0)
                _backward = false;
        }
        else{
            ++cnt;
            if(cnt == 1000){
                _backward = true;
            }
        }

        _p1.value = cnt / 1000.0;
    }


  private:
    bool _backward;
    size_t cnt;
    IProgress _p1;
}
