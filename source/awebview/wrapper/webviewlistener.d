module awebview.wrapper.webviewlistener;

import awebview.gui.application,
       awebview.gui.activity;

import awebview.wrapper.cpp;
import awebview.wrapper.webview : WebView;
import awebview.wrapper.weburl : WebURL;
import awebview.wrapper.weakref : weakRef;
import awebview.wrapper.webstring : WebStringCpp;


static struct WebViewListener
{
    static
    Activity findActivity(Application application, Awesomium.WebView wv)
    {
        Activity activity;
        application.opApplyActivities((Activity a){
            if(a.view.cppObj == wv){
                activity = a;
                return 1;
            }

            return 0;
        });

        return activity;
    }


    static class Menu : Awesomium4D.IMenuListenerD
    {
        this(Application app)
        {
            _app = app;

            auto mid = MemoryManager.instance.register(cast(void*)this);
            _cppObj = MenuListenerD2CppMember.newCtor(this, mid);
        }


        final
        inout(CppObj) cppObj() inout pure nothrow @safe @nogc
        {
            return _cppObj;
        }


        void onShowPopupMenu(Activity activity, const Awesomium.WebPopupMenuInfo*){}
        void onShowContextMenu(Activity activity, const Awesomium.WebContextMenuInfo*) {}

        extern(C++)
        {
            final
            void onShowPopupMenu(Awesomium.WebView wv, const Awesomium.WebPopupMenuInfo* p)
            {
                Activity activity = findActivity(_app, wv);
                assert(activity);

                onShowPopupMenu(activity, p);
            }

            final
            void onShowContextMenu(Awesomium.WebView wv, const Awesomium.WebContextMenuInfo* p)
            {
                Activity activity = findActivity(_app, wv);
                assert(activity);

                onShowContextMenu(activity, p);
            }
        }

      private:
        alias CppObj = Awesomium4D.MenuListenerD2Cpp;

        Application _app;
        CppObj _cppObj;
    }


    static class View : Awesomium4D.IViewListenerD
    {
        this(Application app)
        {
            _app = app;

            auto mid = MemoryManager.instance.register(cast(void*)this);
            _cppObj = ViewListenerD2CppMember.newCtor(this, mid);
        }


        final
        inout(CppObj) cppObj() inout pure nothrow @safe @nogc { return _cppObj; }


        void onChangeTitle(WebView view, Activity activity, scope const(wchar)[] title) {}
        void onChangeAddressBar(WebView view, Activity activity, WebURL url) {}
        void onChangeTooltip(WebView view, Activity activity, scope const(wchar)[] s) {}
        void onChangeTargetURL(WebView view, Activity activity, WebURL url) {}
        void onChangeCursor(WebView view, Activity activity, Awesomium.Cursor cursor) {}
        void onChangeFocus(WebView view, Activity activity, Awesomium.FocusedElementType fet) {}
        void onAddConsoleMessage(WebView view, Activity activity, scope const(wchar)[] msg, uint lineNum, scope const(wchar)[] src) {}
        void onShowCreatedWebView(WebView view, Activity activity, WebView newView, WebURL openerURL, WebURL targetURL, Rect rect, bool isPopup) {}

      extern(C++)
      {
        void onChangeTitle(Awesomium.WebView wv, const Awesomium.WebString title)
        {
            auto activity = findActivity(_app, wv);
            auto ws = title.weakRef!WebStringCpp;

            onChangeTitle(WebView(wv), activity, ws.data);
        }


        void onChangeAddressBar(Awesomium.WebView wv, const Awesomium.WebURL url)
        {
            auto activity = findActivity(_app, wv);
            WebURL wu = url;

            onChangeAddressBar(WebView(wv), activity, wu);
        }


        void onChangeTooltip(Awesomium.WebView wv, const Awesomium.WebString tip)
        {
            auto activity = findActivity(_app, wv);
            auto ws = tip.weakRef!WebStringCpp;

            onChangeTooltip(WebView(wv), activity, ws.data);
        }


        void onChangeTargetURL(Awesomium.WebView wv, const Awesomium.WebURL url)
        {
            auto activity = findActivity(_app, wv);
            WebURL wu = url;

            onChangeTargetURL(WebView(wv), activity, wu);
        }


        void onChangeCursor(Awesomium.WebView wv, Awesomium.Cursor c)
        {
            auto activity = findActivity(_app, wv);

            onChangeCursor(WebView(wv), activity, c);
        }


        void onChangeFocus(Awesomium.WebView wv, Awesomium.FocusedElementType fet)
        {
            auto activity = findActivity(_app, wv);

            onChangeFocus(WebView(wv), activity, fet);
        }


        void onAddConsoleMessage(Awesomium.WebView wv, const Awesomium.WebString msg, int lineNum, const Awesomium.WebString src)
        {
            auto activity = findActivity(_app, wv);
            auto m = msg.weakRef!WebStringCpp;
            auto s = src.weakRef!WebStringCpp;

            onAddConsoleMessage(WebView(wv), activity, m.data, lineNum, s.data);
        }


        void onShowCreatedWebView(Awesomium.WebView wv, Awesomium.WebView newView, const Awesomium.WebURL openerURL, const Awesomium.WebURL targetURL, const(Awesomium.Rect)* initialPos, bool isPopup)
        {
            auto activity = findActivity(_app, wv);
            WebURL op = openerURL;
            WebURL tg = targetURL;
            Rect pos = *initialPos;

            onShowCreatedWebView(WebView(wv), activity, WebView(newView), op, tg, pos, isPopup);
        }
      }

      private:
        alias CppObj = Awesomium4D.ViewListenerD2Cpp;

        Application _app;
        CppObj _cppObj;
    }
}
