module awebview.wrapper.cpp.webview;


mixin template Awesomium()
{
    enum WebViewType { offscreen, window }
    enum MouseButton { left, middle, right }

    interface WebView {}
}

mixin template Awesomium4D()
{
    interface IWebViewD 
    {
        void destroy();
        Awesomium.WebViewType type();
        int processId();
        int routingId();
        int nextRoutingId();
        ProcessHandle processHandle();
        void setParentWindow(NativeWindow parent);
        NativeWindow parentWindow();
        NativeWindow window();
        void setViewListener(Awesomium.WebViewListener.View);
        void setLoadListener(Awesomium.WebViewListener.Load);
        void setProcessListener(Awesomium.WebViewListener.Process);
        void setMenuListener(Awesomium.WebViewListener.Menu);
        void setDialogListener(Awesomium.WebViewListener.Dialog);
        void setPrintListener(Awesomium.WebViewListener.Print);
        void setDonwloadListener(Awesomium.WebViewListener.Download);
        void setInputMethodEditorListener(Awesomium.WebViewListener.InputMethodEditor);
        Awesomium.WebViewListener.View viewListener();
        Awesomium.WebViewListener.Load loadListener();
        Awesomium.WebViewListener.Process processListener();
        Awesomium.WebViewListener.Menu menuListener();
        Awesomium.WebViewListener.Dialog dialogListener();
        Awesomium.WebViewListener.Print printListener();
        Awesomium.WebViewListener.Download downloadListener();
        Awesomium.WebViewListener.InputMethodEditor inputMethodEditorListener();
        void loadURL(const Awesomium.WebURL);
        void goBack();
        void goForward();
        void goToHistoryOffset(int);
        void stop();
        void reload(bool);
        bool canGoBack();
        bool canGoForward();
        Awesomium.Surface surface();
        void getUrl(Awesomium.WebURL);
        void getTitle(Awesomium.WebString);
        WebSession session();
        bool isLoading();
        bool isCrashed();
        void resize(int, int);
        void setTransparent(bool);
        bool isTransparent();
        void pauseRendering();
        void resumeRendering();
        void focus();
        void unfocus();
        FocusedElementType focusedElementType();
        void zoomIn();
        void zoomOut();
        void setZoom(int);
        void resetZoom();
        int getZoom();
        void injectMouseMove(int, int);
        void injectMouseDown(MouseButton);
        void injectMouseUp(MouseButton);
        void injectMouseWheel(int, int);
        void injectKeyboardEvent(const WebKeyboardEvent*);
        void injectTouchEvent(const WebTouchEvent*);
        void activateIME(bool);
        void setIMEComposition(const Awesomium.WebString, int, int, int);
        void confirmIMEComposition(const Awesomium.WebString);
        void cancelIMEComposition();
        void undo();
        void redo();
        void cut();
        void copy();
        void copyImageAt(int, int);
        void paste();
        void pasteAndMatchStyle();
        void selectAll();
        int printToFile(const Awesomium.WebString, const PrintConfig*);
        Awesomium.Error lastError() const;
        void createGlobalJSObject(const Awesomium.WebString, JSValue);
        void executeJS(const Awesomium.WebString, const Awesomium.WebString);
        void executeJSWithResult(const Awesomium.WebString, const Awesomium.WebString, Awesomium.JSValue);
        void setJSMethodHandler(Awesomium.JSMethodHandler);
        Awesomium.JSMethodHandler jsMethodHandler();
        void setSyncMessageTimeout(int);
        int syncMessageTimeout();
        void didSelectPopupMenuItem(int);
        void didCancelPopupMenu();
        void didChooseFiles(const Awesomium.WebStringArray, bool);
        void didLogin(int, const Awesomium.WebString, const Awesomium.WebString);
        void didCancelLogin(int);
        void didChooseDownloadPath(int, const Awesomium.WebString);
        void didCancelDownload(int);
        void didOverrideCertificateError();
        void requestPageInfo();
        void reduceMemoryUsage();
    }


    interface WebViewD2Cpp : Awesomium.WebView {}

    extern(C++, WebViewD2CppMember)
    {
        WebViewD2Cpp newCtor(IWebViewD, ulong);
        void deleteDtor(WebViewD2Cpp);
    }
    extern(C++, WebViewMember)
    {
        void Destroy(Awesomium.WebView p);
        Awesomium.WebViewType type(Awesomium.WebView p);
        int process_id(Awesomium.WebView p);
        int routing_id(Awesomium.WebView p);
        int next_routing_id(Awesomium.WebView p);
        ProcessHandle process_handle(Awesomium.WebView p);
        void set_parent_window(Awesomium.WebView p, NativeWindow parent);
        NativeWindow parent_window(Awesomium.WebView p);
        NativeWindow window(Awesomium.WebView p);
        void set_view_listener(Awesomium.WebView p, Awesomium.WebViewListener.View listener);
        void set_load_listener(Awesomium.WebView p, Awesomium.WebViewListener.Load listener);
        void set_process_listener(Awesomium.WebView p, Awesomium.WebViewListener.Process listener);
        void set_menu_listener(Awesomium.WebView p, Awesomium.WebViewListener.Menu listener);
        void set_dialog_listener(Awesomium.WebView p, Awesomium.WebViewListener.Dialog listener);
        void set_print_listener(Awesomium.WebView p, Awesomium.WebViewListener.Print listener);
        void set_download_listener(Awesomium.WebView p, Awesomium.WebViewListener.Download listener);
        void set_input_method_editor_listener(Awesomium.WebView p, Awesomium.WebViewListener.InputMethodEditor listener);
        Awesomium.WebViewListener.View view_listener(Awesomium.WebView p);
        Awesomium.WebViewListener.Load load_listener(Awesomium.WebView p);
        Awesomium.WebViewListener.Process process_listener(Awesomium.WebView p);
        Awesomium.WebViewListener.Menu menu_listener(Awesomium.WebView p);
        Awesomium.WebViewListener.Dialog dialog_listener(Awesomium.WebView p);
        Awesomium.WebViewListener.Print print_listener(Awesomium.WebView p);
        Awesomium.WebViewListener.Download download_listener(Awesomium.WebView p);
        Awesomium.WebViewListener.InputMethodEditor input_method_editor_listener(Awesomium.WebView p);
        void LoadURL(Awesomium.WebView p, const WebURL url);
        void GoBack(Awesomium.WebView p);
        void GoForward(Awesomium.WebView p);
        void GoToHistoryOffset(Awesomium.WebView p, int offset);
        void Stop(Awesomium.WebView p);
        void Reload(Awesomium.WebView p, bool ignore_cache);
        bool CanGoBack(Awesomium.WebView p);
        bool CanGoForward(Awesomium.WebView p);
        Surface surface(Awesomium.WebView p);
        void url(Awesomium.WebView p, WebURL dst);
        void title(Awesomium.WebView p, WebString dst);
        WebSession session(Awesomium.WebView p);
        bool IsLoading(Awesomium.WebView p);
        bool IsCrashed(Awesomium.WebView p);
        void Resize(Awesomium.WebView p, int width, int height);
        void SetTransparent(Awesomium.WebView p, bool is_transparent);
        bool IsTransparent(Awesomium.WebView p);
        void PauseRendering(Awesomium.WebView p);
        void ResumeRendering(Awesomium.WebView p);
        void Focus(Awesomium.WebView p);
        void Unfocus(Awesomium.WebView p);
        FocusedElementType focused_element_type(Awesomium.WebView p);
        void ZoomIn(Awesomium.WebView p);
        void ZoomOut(Awesomium.WebView p);
        void SetZoom(Awesomium.WebView p, int zoom_percent);
        void ResetZoom(Awesomium.WebView p);
        int GetZoom(Awesomium.WebView p);
        void InjectMouseMove(Awesomium.WebView p, int x, int y);
        void InjectMouseDown(Awesomium.WebView p, MouseButton button);
        void InjectMouseUp(Awesomium.WebView p, MouseButton button);
        void InjectMouseWheel(Awesomium.WebView p, int scroll_vert, int scroll_horz);
        void InjectKeyboardEvent(Awesomium.WebView p, const(WebKeyboardEvent)* key_event);
        void InjectTouchEvent(Awesomium.WebView p, const(WebTouchEvent)* touch_event);
        void ActivateIME(Awesomium.WebView p, bool activate);
        void SetIMEComposition(Awesomium.WebView p, const WebString input_string,
                              int cursor_pos, int target_start, int target_end);
        void ConfirmIMEComposition(Awesomium.WebView p, const WebString input_string);
        void CancelIMEComposition(Awesomium.WebView p);
        void Undo(Awesomium.WebView p);
        void Redo(Awesomium.WebView p);
        void Cut(Awesomium.WebView p);
        void Copy(Awesomium.WebView p);
        void CopyImageAt(Awesomium.WebView p, int x, int y);
        void Paste(Awesomium.WebView p);
        void PasteAndMatchStyle(Awesomium.WebView p);
        void SelectAll(Awesomium.WebView p);
        int PrintToFile(Awesomium.WebView p,
                       const Awesomium.WebString  output_direct,
                       const Awesomium.PrintConfig* config);
        Awesomium.Error last_error(const Awesomium.WebView p);
        void CreateGlobalJavascriptObject(Awesomium.WebView p, const Awesomium.WebString name, JSValue dst);
        void ExecuteJavascript(Awesomium.WebView p, const Awesomium.WebString script,
                                           const Awesomium.WebString frame_xpath);
        void ExecuteJavascriptWithResult(Awesomium.WebView p, const Awesomium.WebString script,
                                                     const Awesomium.WebString frame_xpath,
                                                     Awesomium.JSValue dst);
        void set_js_method_handler(Awesomium.WebView p, Awesomium.JSMethodHandler handler);
        Awesomium.JSMethodHandler js_method_handler(Awesomium.WebView p);
        void set_sync_message_timeout(Awesomium.WebView p, int timeout_ms);
        int sync_message_timeout(Awesomium.WebView p);
        void DidSelectPopupMenuItem(Awesomium.WebView p, int item_index);
        void DidCancelPopupMenu(Awesomium.WebView p);
        void DidChooseFiles(Awesomium.WebView p, const Awesomium.WebStringArray files,
                                        bool should_write_files);
        void DidLogin(Awesomium.WebView p, int request_id,
                     const Awesomium.WebString username,
                     const Awesomium.WebString password);
        void DidCancelLogin(Awesomium.WebView p, int request_id);
        void DidChooseDownloadPath(Awesomium.WebView p, int download_id,
                                  const Awesomium.WebString path);
        void DidCancelDownload(Awesomium.WebView p, int download_id);
        void DidOverrideCertificateError(Awesomium.WebView p);
        void RequestPageInfo(Awesomium.WebView p);
        void ReduceMemoryUsage(Awesomium.WebView p);
    }
}
