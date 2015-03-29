module button_page;

import awebview.gui.html;
import awebview.wrapper;
import awebview.gui.widgets.button;
import awebview.gui.activity;
import std.conv;

import carbon.utils;

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
            auto button = new GenericButton!(`<div id="%[id%]" onclick="%[id%].onClick()">Click me!</div>`)("div_button");
            button.onClick.connect!"onClickDiv"(this);
            return button;
        }();
    }


    void onClickInputButton(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        activity.to!SDLActivity.title = "You clicked input_button";
    }


    void onClickDiv(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
    {
        activity.to!SDLActivity.title = "You clicked div_button";
    }
}
