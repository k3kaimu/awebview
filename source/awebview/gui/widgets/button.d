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


abstract class Button : DeclareSignals!(HTMLElement, "onClick")
{
    this(string id)
    {
        super(id, true);
    }
}


alias GenericButton(alias format) = TemplateHTMLElement!(DefineSignals!(Button, "onClick"), format);
alias InputButton(alias attrs) = GenericButton!(`<input type="button" id="%[id%]" onclick="%[id%].onClick()" ` ~ buildHTMLTagAttr(attrs) ~ `>`);
