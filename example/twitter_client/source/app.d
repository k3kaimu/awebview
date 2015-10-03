
import std.stdio;
import std.string;
import std.stdio;
import std.conv;
import std.datetime;
import std.exception;
import std.variant;

import carbon.templates;
import carbon.functional;

import awebview.wrapper;

import awebview.gui.application,
       awebview.gui.activity,
       awebview.gui.html,
       awebview.gui.methodhandler,
       awebview.gui.widgets.button;

import oauth_page;
import main_page;

import std.file : exists;

void main()
{
    auto app = SDLApplication.instance;
    auto pref = WebPreferences.recommended;

    with(app.newFactoryOf!SDLActivity(pref)){
        id = "MainActivity";
        width = 600;
        height = 600;
        title = "Twitter Client by D(awebview HTML GUI)";

        app.addActivity(newInstance.passTo!((a){
            a ~= new OAuthPage();
            a.load(new MainPage());
        }));
    }

    app.run();
}
