module awebview.gui.menulistener;

import awebview.wrapper.webviewlistener;
import awebview.gui.activity;
import awebview.gui.application;
import awebview.wrapper.cpp;

import std.stdio;


class MenuListener : awebview.wrapper.webviewlistener.WebViewListener.Menu
{
    this(Application app)
    {
        super(app);
    }


    override
    void onShowPopupMenu(Activity activity, const Awesomium.WebPopupMenuInfo* p) { /*writeln(__FUNCTION__);*/ }


    override
    void onShowContextMenu(Activity activity, const Awesomium.WebContextMenuInfo* p) { /*writeln(__FUNCTION__);*/ }
}
