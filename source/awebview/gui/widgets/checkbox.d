module awebview.gui.widgets.checkbox;

import awebview.gui.widgets.button;
import awebview.gui.html;
import awebview.wrapper;

interface ICheckbox : IButton
{
    @property
    bool isChecked();

    @property
    bool isChecked(bool bChecked);
}


abstract class Checkbox : DeclareSignals!(HTMLElement, "onClick"), ICheckbox
{
    this(string id)
    {
        super(id, true);
    }


    override
    void onClick(WeakRef!(const(JSArrayCpp)));
}


class InputCheckbox(alias attrs = null)
: TemplateHTMLElement!(DefineSignals!(Button, "onClick"), `<input type="checkbox" id="%[id%]" ` ~ buildHTMLTagAttr(attrs) ~ `>`)
{
    this(string id) { super(id); }


    override
    void onStart(HTMLPage page)
    {
        super.onStart(page);
        this["checked"] = _defaultValue;
    }


    override
    @property
    bool isChecked()
    {
        if(activity)
            return this["checked"].get!bool;
        else
            return _defaultValue;
    }


    override
    @property
    void isChecked(bool bChecked)
    {
        if(activity)
            this["checked"] = bChecked;
        else
            _defaultValue = bChecked;
    }


  private:
    bool _defaultValue;
}
