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

alias GenericButton(string form) = TemplateHTMLElement!(DefineSignals!(Button, "onClick"), form);
