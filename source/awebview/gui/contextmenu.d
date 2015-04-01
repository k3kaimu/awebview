module awebview.gui.contextmenu;

import awebview.gui.html;
import awebview.gui.activity;

import awebview.gui.widgets.button;

import std.array,
       std.format;



class ContextMenuListPage : HTMLPage
{
    this(E...)(auto ref E args)
    {
        super("_contextmenulist_");

        foreach(ref e; args){
          static if(is(typeof(e) : HTMLElement))
          {
            _args ~= Alg(cast(HTMLElement)e);
            _elements[e.id] = e;
          }
          else
            _args ~= Alg(e);
        }

        _elements["_contextmenulist_"] = new IDOnlyElement("_contextmenulist_");
    }


    override
    inout(HTMLElement[string]) elements() inout @property
    {
        return _elements;
    }


    uint offsetTop(uint idx)
    {
        auto jv = this.activity.evalJS(mixin(Lstr!q{
          (function(){
            var es = document.querySelectorAll("tr");
            var elem = es[%[idx%]];
            var y = elem.offsetTop;

            while(elem = elem.offsetParent)
                y += elem.offsetTop;

            return y;
          }())
        }));

        assert(jv.has!uint);
        return jv.get!uint;
    }


    override
    @property
    string html() const
    {
        bool bBorderedTop;
        auto app = appender!string();

        app.put(`<html><head><title>ContextMenuList</title></head><style>tr:hover { background-color: #007bff; color: #000000; }</style>`);
        app.put(`<body style="margin:0px; padding:0px">`);
        app.put(`<table id="_contextmenulist_" style="border-collapse: collapse; border: inset 1px black;">`);

        foreach(ref e; _args)
        {
            if(e.peek!char)
            {
                bBorderedTop = true;
                continue;
            }
            else
            {
                if(bBorderedTop)
                    app.put(`<tr><td style="border-top: solid 1px;">`);
                else
                    app.put(`<tr><td>`);

                if(auto p = e.peek!string)
                {
                    app.put(*p);
                }
                else if(auto p = e.peek!HTMLElement)
                {
                    app.put(p.html);
                }

                app.put(`</td></tr>`);
                bBorderedTop = false;
            }
        }

        app.put(`</table></body></html>`);
        return app.data;
    }


  private:
    import std.variant : Algebraic;

    alias Alg = Algebraic!(char, string, HTMLElement);

    Alg[] _args;
    HTMLElement[string] _elements;
}


/+
struct ContextMenuItem
{
  static:
    class DoOnClick : GenericButton!(`<div onclick="%[id%].onClick"></div>`)
    {
        this(string id, string text, void delegate() dlg)
        {
            super("_contextmenulist_" ~ id, true);
            this.staticProps["innerHTML"] = text;
        }
    }


    class ShowOnMouseOver : HTMLElement
    {
        this(HTMLPage page)
        {

        }
    }
}
+/