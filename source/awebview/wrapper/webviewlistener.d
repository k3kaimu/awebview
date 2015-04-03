module awebview.wrapper.webviewlistener;

import awebview.gui.application,
       awebview.gui.activity,
       awebview.wrapper.cpp;


static struct WebViewListener
{
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
                Activity activity;
                _app.opApplyActivities((Activity a){
                    if(a.view.cppObj == wv){
                        activity = a;
                        return 1;
                    }

                    return 0;
                });
                assert(activity);

                onShowPopupMenu(activity, p);
            }

            final
            void onShowContextMenu(Awesomium.WebView wv, const Awesomium.WebContextMenuInfo* p)
            {
                Activity activity;
                _app.opApplyActivities((Activity a){
                    if(a.view.cppObj == wv){
                        activity = a;
                        return 1;
                    }

                    return 0;
                });
                assert(activity);

                onShowContextMenu(activity, p);
            }
        }

      private:
        alias CppObj = Awesomium4D.MenuListenerD2Cpp;

        Application _app;
        CppObj _cppObj;
    }
}