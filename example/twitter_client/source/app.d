
import std.stdio;
import std.string;
import std.stdio;
import std.conv;
import std.datetime;
import std.exception;
import std.variant;

import carbon.templates;
import carbon.utils;

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
    auto app = SDLApplication!().instance;

    auto pref = WebPreferences.recommended;
    if(exists("style.css"))
        pref.userStylesheet = std.file.readText("style.css");

    if(exists("script.js"))
        pref.userScript = std.file.readText("script.js");

    app.createActivity(pref, delegate(WebSession session){
        // 画面の作成
        auto activity = new SDLActivity("MainActivity", 600, 600, "Twitter Client by D(awebview HTML GUI)", session);
        activity ~= new OAuthPage();
        activity ~= new MainPage();

        activity.load("mainPage");
        return activity;
    });
    app.run();

    writeln("end");
}
