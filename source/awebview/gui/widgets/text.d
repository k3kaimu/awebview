module awebview.gui.widgets.text;

import std.variant;

import awebview.gui.html,
       awebview.wrapper;


interface ITextInput
{
    @property
    string text();
}


interface ITextOutput
{
    @property
    void text(string);
}


interface ITextIO : ITextInput, ITextOutput {}


class GenericHTMLTextIO(string format, string property) : TemplateHTMLElement!(format), ITextIO
{
    this(string id, Variant[string] exts = null) { super(id, false, exts); }


    @property
    string text() { return this[property].get!WebString.data.to!string; }


    @property
    void text(string str) { this[property] = str; }
}


alias InputText(alias attrs = null) = GenericHTMLTextIO!(`<input type="text" id="%[id%]" ` ~ buildHTMLTagAttr(attrs) ~ `>`, "value");
alias Paragraph(alias attrs = null) = GenericHTMLTextIO!(`<p id="%[id%]" ` ~ buildHTMLTagAttr(attrs) ~ `></p>`, "innerHTML");
alias TextArea(alias attrs = null) = GenericHTMLTextIO!(`<textarea id="%[id%]" ` ~ buildHTMLTagAttr(attrs) ~ `></textarea>`, "value");
