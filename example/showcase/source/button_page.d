module button_page;

import awebview.gui.html;
import awebview.wrapper;
import awebview.gui.widgets.button;
import awebview.gui.activity;
import awebview.gui.application;
import awebview.gui.contextmenu;
import std.conv;
import core.time;

import carbon.utils;
import carbon.nonametype;
import carbon.functional;

class ButtonPage : TemplateHTMLPage!(import(`button_page.html`))
{
    this()
    {
        super("buttonPage", null);

        this ~= (new InputButton!()("input_button")).observe!((a){
            a.staticProps["value"] = "Click me!";
            a.onClick.connect!"onClickInputButton"(this);
        });

        this ~= (new GenericButton!(`<div id="%[id%]">Click me!</div>`)("div_button")).observe!((a){
            a.onClick.connect!"onClickDiv"(this);
        });

        _menu = new PopupMenu("PopupMenuPage");
    }


    void onClickInputButton(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto popup = application.to!SDLApplication.popupActivity;
        popup.popup(_menu, this.activity.to!SDLActivity);
    }


    void onClickDiv(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        class Menu : DeclareHoverSignal!(TemplateHTMLElement!(`<div id="%[id%]">Click me!</div>`))
        {
            this(string id) { super(id, true); }

            override
            void onHover(bool bOver, Duration d)
            {
                auto thisAct = this.activity.to!SDLPopupActivity;
                if(bOver){
                    if(d > 300.msecs && (thisAct.childPopup is null || thisAct.childPopup.isDetached)){
                        auto innerH = thisAct.nowPage.to!ContextMenuListPage.offsetTop(2);
                        thisAct.popupChildRight(_menu, innerH);
                    }
                }
            }
        }

        auto popup = application.to!SDLApplication.popupActivity;
        auto page = new ContextMenuListPage(
                "fooo",
                "foooo000",
            '-',
                new Menu("div_button2")
            );
        popup.popup(page, this.activity.to!SDLActivity);
    }


    void onMouseOverMenuItemDiv(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto popup = application.to!SDLApplication.popupActivity;
        auto innerH = popup.nowPage.to!ContextMenuListPage.offsetTop(2);
        popup.popupChildRight(_menu, innerH);
    }


  private:
    PopupMenu _menu;
}


class PopupMenu : TemplateHTMLPage!(import(`button_page_menu.html`))
{
    this(string id)
    {
        super(id, null);

        this ~= (){
            auto btn = new InputButton!(["style": "width:150px;height:50px;margin:0px;padding:0px"])("btnOpenNewMenuChild");
            btn.staticProps["value"] = "Open new menu!";
            btn.onClick.connect!"onClickOpenNewMenuChild"(this);
            return btn;
        }();
    }


    void onClickOpenNewMenuChild(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        this.activity.to!SDLPopupActivity.popupChildRight(new PopupMenu(this.id), 10);
    }
}
