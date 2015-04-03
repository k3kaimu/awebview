module switchlink;

import awebview.gui.html;


class SwitchLinkPage : TemplateHTMLPage!(import(`switchlink.html`))
{
    this(string id) { super(id, null); }
}
