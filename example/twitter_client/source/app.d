
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
    auto app = SDLApplication.instance;

    auto pref = WebPreferences.recommended;
    if(exists("style.css"))
        pref.userStylesheet = std.file.readText("style.css");

    if(exists("script.js"))
        pref.userScript = std.file.readText("script.js");

    app.createActivity(pref, delegate(WebSession session){
        // create window-view
        auto activity = new SDLActivity("MainActivity", 600, 600, "Twitter Client by D(awebview HTML GUI)", session);

        // add pages to activity
        activity ~= new OAuthPage();  // .id == "oauthPage"
        activity ~= new MainPage();   // .id == "mainPage"

        // load MainPage as initial page()
        activity.load("mainPage");
        return activity;
    });

    // run main loop
    app.run();
}
