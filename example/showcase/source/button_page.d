module button_page;

import awebview.gui.html;
import awebview.wrapper;
import awebview.gui.widgets.button;
import awebview.gui.activity;
import awebview.gui.application;
import awebview.gui.contextmenu;
import std.conv;

import carbon.utils;
import carbon.nonametype;

class ButtonPage : TemplateHTMLPage!(import(`button_page.html`))
{
    this()
    {
        super("buttonPage", null);

        this ~= (){
            auto button = new InputButton!()("input_button");
            button.staticProps["value"] = "Click me!";
            button.onClick.connect!"onClickInputButton"(this);
            return button;
        }();

        this ~= (){
            auto button = new GenericButton!(`<div id="%[id%]">Click me!</div>`)("div_button");
            button.onClick.connect!"onClickDiv"(this);
            return button;
        }();
    }


    void onClickInputButton(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        //activity.to!SDLActivity.title = "You clicked input_button";
        auto popup = application.to!SDLApplication.popupActivity;
        auto page = new PopupMenu("PopupMenuPage");
        popup.popup(page, this.activity.to!SDLActivity);
    }


    void onClickDiv(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto popup = application.to!SDLApplication.popupActivity;
        auto page = new ContextMenuListPage(
                "fooo",
                "foooo000",
            '-',
                (btn){btn.onMouseOver.connect!"onMouseOverMenuItemDiv"(this); return btn;}(new AssumeImplemented!(DeclDefSignals!(TemplateHTMLElement!(`<div id="%[id%]">Click me!</div>`), "onMouseOver"))("div_button2", true)));
        popup.popup(page, this.activity.to!SDLActivity);
    }


    void onMouseOverMenuItemDiv(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        auto popup = application.to!SDLApplication.popupActivity;
        auto innerH = popup.nowPage.to!ContextMenuListPage.offsetTop(2);
        auto page = new PopupMenu("PopupMenuPage");
        popup.popupChildRight(page, innerH);
    }
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
