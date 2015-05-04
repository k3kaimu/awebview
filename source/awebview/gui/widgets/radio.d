module awebview.gui.widgets.radio;

import awebview.gui.html;
import std.exception;

interface IRadio
{
    @property
    bool isChecked();

    @property
    void isChecked(bool bChecked);
}


abstract class HTMLRadio : HTMLElement, IRadio
{
    this(string id, bool doCreateObject)
    {
        super(id, doCreateObject);
    }


    override
    @property
    bool isChecked(){ return this["checked"].get!bool; }

    override
    @property
    void isChecked(bool bChecked){ this["checked"] = bChecked; }
}


class InputRadio(alias attrs = null)
: TemplateHTMLElement!(HTMLRadio, `<input type="radio" id="%[id%]" value="%[id%]">`)
{
    this(string id)
    {
        super(id, true);
    }
}


class HTMLRadioGroup : HTMLElement
{
    this(string id, HTMLRadio[] rs)
    {
        super(id, false);
        _rs ~= rs.dup;

        foreach(e; _rs)
            e.staticProps["name"] = this.id;
    }


    @property
    inout(HTMLRadio)[] elements() inout
    {
        return _rs;
    }


    @property
    HTMLRadio checked()
    {
        foreach(e; _rs)
            if(e.isChecked)
                return e;

        return null;
    }


    @property
    void checked(string id)
    {
        foreach(i, e; _rs)
            if(e.id == id){
                e.isChecked = true;
                return;
            }

        enforce(0);
    }


  private:
    HTMLRadio[] _rs;
}
