module awebview.wrapper.webview;

public import awebview.wrapper.cpp : WebViewType, MouseButton;
import awebview.wrapper.cpp;
import awebview.wrapper.weburl : WebURL;
import awebview.wrapper.webstring : WebString;
import awebview.wrapper.webstring;
import awebview.wrapper.jsvalue : JSValue;
import awebview.wrapper.jsobject : JSObject, JSMethodHandler;
import awebview.wrapper.weakref;
import awebview.wrapper.surface : Surface;

import std.traits;


struct WebView
{
    this(awebview.wrapper.cpp.WebView cppObj)
    {
        _cppObj = cppObj;
    }


    @property
    inout(awebview.wrapper.cpp.WebView) cppObj() inout pure nothrow @safe @nogc
    { return _cppObj; }


    void destroy() { WebViewMember.Destroy(_cppObj); }

    @property
    WebViewType type() { return WebViewMember.type(_cppObj); }

    @property
    int processId() { return WebViewMember.process_id(_cppObj); }

    @property
    int routingId() { return WebViewMember.routing_id(_cppObj); }

    @property
    int nextRoutingId() { return WebViewMember.next_routing_id(_cppObj); }

    @property
    ProcessHandle processHandle() { return WebViewMember.process_handle(_cppObj); }

    @property
    void parentWindow(NativeWindow parent)
    { WebViewMember.set_parent_window(_cppObj, parent); }

    @property
    NativeWindow parentWindow()
    { return WebViewMember.parent_window(_cppObj); }

    @property
    NativeWindow window() { return WebViewMember.window(_cppObj); }

    void setViewListener(Awesomium.WebViewListener.View vl)
    { WebViewMember.set_view_listener(_cppObj, vl); }

    //void setLoadListener(Awesomium.WebViewListener.Load);
    //void setProcessListener(Awesomium.WebViewListener.Process);

    void setMenuListener(Awesomium.WebViewListener.Menu ml)
    { WebViewMember.set_menu_listener(_cppObj, ml); }

    //void setDialogListener(Awesomium.WebViewListener.Dialog);
    //void setPrintListener(Awesomium.WebViewListener.Print);
    //void setDonwloadListener(Awesomium.WebViewListener.Download);
    //void setInputMethodEditorListener(Awesomium.WebViewListener.InputMethodEditor);
    //Awesomium.WebViewListener.View viewListener();
    //Awesomium.WebViewListener.Load loadListener();
    //Awesomium.WebViewListener.Process processListener();
    //Awesomium.WebViewListener.Menu menuListener();
    //Awesomium.WebViewListener.Dialog dialogListener();
    //Awesomium.WebViewListener.Print printListener();
    //Awesomium.WebViewListener.Download downloadListener();
    //Awesomium.WebViewListener.InputMethodEditor inputMethodEditorListener();


    void loadURL(in WebURL url) nothrow @nogc
    {
        WebViewMember.LoadURL(_cppObj, url.cppObj);
    }

    //void goBack();
    //void goForward();
    //void goToHistoryOffset(int);
    //void stop();
    //void reload(bool);
    //bool canGoBack();
    //bool canGoForward();


    Surface surface() nothrow @nogc @property
    {
        return Surface(WebViewMember.surface(_cppObj));
    }


    //void getUrl(Awesomium.WebURL);
    //void getTitle(Awesomium.WebString);
    //WebSession session();

    @property
    bool isLoading() nothrow @nogc
    {
        return WebViewMember.IsLoading(_cppObj);
    }


    //bool isCrashed();
    void resize(int w, int h) nothrow @nogc
    {
        WebViewMember.Resize(_cppObj, w, h);
    }

    //void setTransparent(bool);
    //bool isTransparent();
    //void pauseRendering();
    //void resumeRendering();
    //void focus();
    //void unfocus();
    //FocusedElementType focusedElementType();
    //void zoomIn();
    //void zoomOut();
    //void setZoom(int);
    //void resetZoom();
    //int getZoom();
    //void injectMouseMove(int, int);
    //void injectMouseDown(MouseButton);
    //void injectMouseUp(MouseButton);
    //void injectMouseWheel(int, int);
    //void injectKeyboardEvent(const WebKeyboardEvent*);
    //void injectTouchEvent(const WebTouchEvent*);
    //void activateIME(bool);
    //void setIMEComposition(const Awesomium.WebString, int, int, int);
    //void confirmIMEComposition(const Awesomium.WebString);
    //void cancelIMEComposition();
    //void undo();
    //void redo();
    //void cut();
    //void copy();
    //void copyImageAt(int, int);
    //void paste();
    //void pasteAndMatchStyle();
    //void selectAll();
    //int printToFile(const Awesomium.WebString, const PrintConfig*);
    //Awesomium.Error lastError() const;
    JSValue createGlobalJSObject(WebString name)
    {
        JSValue dst;
        WebViewMember.CreateGlobalJavascriptObject(_cppObj, name.cppObj, dst.cppObj);
        return dst;
    }


    void executeJS(const awebview.wrapper.cpp.WebString script, const awebview.wrapper.cpp.WebString frameXPath)
    {
        WebViewMember.ExecuteJavascript(_cppObj, script, frameXPath);
    }


    void executeJS(S1, S2)(S1 script, S2 frameXpath)
    if(hasCppWebString!S1 && hasCppWebString!S2)
    {
        WebViewMember.ExecuteJavascript(_cppObj, script.cppObj, frameXPath.cppObj);
    }


    void executeJS(S1, S2)(S1 script, S2 frameXPath)
    if(isSomeString!S1 && isSomeString!S2)
    {
        WebStringCpp s = script;
        WebStringCpp f = frameXPath;
        WebViewMember.ExecuteJavascript(_cppObj, s.cppObj, f.cppObj);
    }


    JSValue executeJSWithRV(const Awesomium.WebString script, const Awesomium.WebString frameXPath)
    {
        JSValue jv;
        WebViewMember.ExecuteJavascriptWithResult(_cppObj, script, frameXPath, jv.cppObj);
        return jv;
    }


    JSValue executeJSWithRV(S1, S2)(S1 script, S2 frameXPath)
    if(hasCppWebString!S1 && hasCppWebString!S2)
    {
        return executeJSWithRV(script.cppObj, frameXPath.cppObj);
    }


    JSValue executeJSWithRV(S1, S2)(S1 script, S2 frameXPath)
    if(isSomeString!S1 && isSomeString!S2)
    {
        return executeJSWithRV(WebString(script), WebString(frameXPath));
    }


    @property
    void jsMethodHandler(awebview.wrapper.cpp.JSMethodHandler h)
    {
        WebViewMember.set_js_method_handler(_cppObj, h);
    }


    @property
    void jsMethodHandler(JSMethodHandler h)
    {
        jsMethodHandler = h.cppObj;
    }

    //Awesomium.JSMethodHandler jsMethodHandler();
    //void setSyncMessageTimeout(int);
    //int syncMessageTimeout();
    //void didSelectPopupMenuItem(int);
    //void didCancelPopupMenu();
    //void didChooseFiles(const Awesomium.WebStringArray, bool);
    //void didLogin(int, const Awesomium.WebString, const Awesomium.WebString);
    //void didCancelLogin(int);
    //void didChooseDownloadPath(int, const Awesomium.WebString);
    //void didCancelDownload(int);
    //void didOverrideCertificateError();
    //void requestPageInfo();
    //void reduceMemoryUsage();


  private:
    awebview.wrapper.cpp.WebView _cppObj;


    //static class Listener
    //{
    //    static class InputMethodEditor : IInputMethodEditorD
    //    {
    //        this(){}


    //        override
    //        void onUpdateIME(awebview.wrapper.cpp.WebView wv,
    //                         TextInputType type, int caret_x, int caret_y)
    //        {
    //            _onUpdateIME.emit(this, WebView(wv), type, caret_x, caret_y);
    //        }


    //        ref RestrictedSignal!


    //        override
    //        void onCancelIME(awebview.wrapper.cpp.WebView wv)
    //        {
    //            _onCancelIME.emit(this, WebView(wv));
    //        }


    //        override
    //        void onChangeIMERange(awebview.wrapper.cpp.WebView view,
    //                              uint start, uint end)
    //        {
    //            _onChangeIMERange.emit(this, WebView(wv), start, end);
    //        }



    //      private:
    //        EventManager!(WebView, TextInputType, int, int) _onUpdateIME;
    //        EventManager!(WebView) _onCancelIME;
    //        EventManager!(WebView, uint, uint) _onChangeIMERange;
    //    }


    //  private:
    //    InputMethodEditor _ime;
    //}
}