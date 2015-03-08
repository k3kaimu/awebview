
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

import deimos.glfw.glfw3;

import oauth_page;
import main_page;
import core.runtime;

void main()
{
    auto app = new GLFWApplication(delegate(WebSession session){
        // 画面の作成
        auto activity = new GLFWActivity("MainActivity", 600, 600, "Twitter Client by D(awebview HTML GUI)", session);
        activity ~= new OAuthPage();
        activity ~= new MainPage();

        activity.load("mainPage");
        return activity;
    });
    app.run();

    app.shutdown();
}
