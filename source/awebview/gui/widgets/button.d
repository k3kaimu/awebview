module awebview.gui.widgets.button;

import carbon.event,
       awebview.gui.activity,
       awebview.gui.methodhandler,
       awebview.gui.html,
       awebview.wrapper.weakref,
       awebview.wrapper.jsarray,
       awebview.wrapper.webstring,
       awebview.wrapper.jsvalue;

public import carbon.event : FiredContext;

import carbon.nonametype;


interface IButton
{
    void onClick(WeakRef!(const(JSArrayCpp)));
}


abstract class Button : DeclareSignals!(HTMLElement, "onClick"), IButton
{
    this(string id)
    {
        super(id, true);
    }


    override
    void onClick(WeakRef!(const(JSArrayCpp)) args) { assert(0); /* this method is not implemented */ }
}


alias GenericButton(alias format) = AssumeImplemented!(TemplateHTMLElement!(DefineSignals!(Button, "onClick"), format));
alias InputButton(alias attrs = null) = GenericButton!(`<input type="button" id="%[id%]" ` ~ buildHTMLTagAttr(attrs) ~ `>`);
