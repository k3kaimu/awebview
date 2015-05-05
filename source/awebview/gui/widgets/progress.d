module awebview.gui.widgets.progress;

import awebview.gui.html;


interface IProgress
{
    void value(float) @property;
}


abstract class HTMLProgress : HTMLElement, IProgress
{
    this(string id)
    {
        super(id, true);
    }


    override
    @property
    void value(float r)
    {
        this["value"] = r;
    }
}


class Progress : TemplateHTMLElement!(HTMLProgress, `<progress id="%[id%]"></progress>`)
{
    this(string id)
    {
        super(id);
    }
}
