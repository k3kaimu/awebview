module awebview.gui.viewlistener;

import awebview.gui.activity,
       awebview.gui.application,
       awebview.wrapper : WebViewListener, WebURL;

public import awebview.wrapper.webview : WebView;
public import awebview.wrapper.cpp : Cursor, FocusedElementType, Rect;

import std.stdio;

class ViewListener : WebViewListener.View
{
    this(Application app)
    {
        super(app);
    }


    override void onChangeTitle(WebView view, Activity activity, scope const(wchar)[] title) { /*writeln(__FUNCTION__);*/ }
    override void onChangeAddressBar(WebView view, Activity activity, WebURL url) { /*writeln(__FUNCTION__);*/ }
    override void onChangeTooltip(WebView view, Activity activity, scope const(wchar)[] s) { /*writeln(__FUNCTION__);*/ }
    override void onChangeTargetURL(WebView view, Activity activity, WebURL url) { /*writeln(__FUNCTION__);*/ }
    override void onChangeCursor(WebView view, Activity activity, Cursor cursor) { /*writeln(__FUNCTION__);*/ }
    override void onChangeFocus(WebView view, Activity activity, FocusedElementType fet) {/*writeln(__FUNCTION__);*/ }
    override void onAddConsoleMessage(WebView view, Activity activity, scope const(wchar)[] msg, uint lineNum, scope const(wchar)[] src) {
        //writeln(__FUNCTION__);
        //writeln("\tid:  ", activity ? activity.id : "null");
        //writeln("\tmsg: ", msg);
        //writeln("\tln:  ", lineNum);
        //writeln("\tsrc: ", src);
    }
    override void onShowCreatedWebView(WebView view, Activity activity, WebView newView, WebURL openerURL, WebURL targetURL, Rect rect, bool isPopup) { /*writeln(__FUNCTION__);*/ }
}
