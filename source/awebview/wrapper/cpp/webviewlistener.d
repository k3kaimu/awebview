module awebview.wrapper.cpp.webviewlistener;


mixin template Awesomium()
{
    enum Cursor
    {
        pointer,
        cross,
        hand,
        iBeam,
        wait,
        help,
        eastResize,
        northResize,
        northEastResize,
        northWestResize,
        southResize,
        southEastResize,
        southWestResize,
        westResize,
        northSouthResize,
        eastWestResize,
        northEastSouthWestResize,
        northWestSouthEastResize,
        columnResize,
        rowResize,
        middlePanning,
        eastPanning,
        northPanning,
        northEastPanning,
        northWestPanning,
        southPanning,
        southEastPanning,
        southWestPanning,
        westPanning,
        move,
        verticalText,
        cell,
        contextMenu,
        alias_,
        progress,
        noDrop,
        copy,
        none,
        notAllowed,
        zoomIn,
        zoomOut,
        grab,
        grabbing,
        custom
    }


    enum FocusedElementType { none, text, link, input, textInput, editableContext, plugin, other }
    enum TerminationStatus { normal, abnormall, killed, crashed, stillRunning }
    enum TextInputType { none, text, password, search, email, number, telephone, url }
    enum WebFileChooserMode { open, openMultiple, openFolder, save }

    align(1) struct WebFileChooserInfo
    {
        WebFileChooserMode mode;
        WebString.Field title;
        WebString.Field default_file_name;
        WebStringArray.Field accept_types;
    }

    align(1) struct WebPopupMenuInfo
    {
        Rect bounds;
        int item_height;
        double item_font_size;
        int selected_item;
        WebMenuItemArray.Field items;
        bool right_aligned; 
    }

    enum MediaType { none, image, vide, audio, file, plugin }
    enum MediaState
    {
        none = 0x0,
        error = 0x1,
        paused = 0x2,
        muted = 0x4,
        loop = 0x8,
        canSave = 0x10,
        hasAudio = 0x20,
        hasVideo = 0x40
    }

    enum CanEditFlags
    {
        nothing = 0x0,
        undo = 0x1,
        redo = 0x2,
        cut = 0x4,
        copy = 0x8,
        paste = 0x10,
        delete_ = 0x20,
        selectAll = 0x40
    }

    enum CertError
    {
        none,
        commonNameInvalid,
        dataInvalid,
        authorityInvalid,
        containsErrors,
        noRevocationMechanism,
        unableToCheckRevocation,
        revoked,
        invalid,
        weakSignatureAlgorithm,
        weakKey,
        notInDNS,
        unknown
    }

    align(1) struct WebContextMenuInfo
    {
        int pos_x;
        int pos_y;
        MediaType media_type;
        int media_state;
        WebURL.Field link_url;
        WebURL.Field src_url;
        WebURL.Field page_url;
        WebURL.Field frame_url;
        long frame_id;
        WebString.Field selection_text;
        bool is_editable;
        int edit_flags;
    }

    align(1) struct WebLoginDialogInfo
    {
        int request_id;
        WebString.Field request_url;
        bool is_proxy;
        WebString.Field host;
        ushort port;
        WebString.Field scheme;
        WebString.Field realm;
    }

    enum SecurityStatus
    {
        unknown, unauthenticated, authenticationBroken, authenticated
    }

    enum ContentStatusFlags
    {
        normal = 0,
        displayedInsecureContent = 1 << 0,
        ranInsecureContent = 1 << 1 
    }

    align(1) struct WebPageInfo
    {
        WebURL.Field page_url;
        SecurityStatus security_status;
        int content_status;
        CertError cert_error;
        WebString.Field cert_subject;
        WebString.Field cert_issuer;
    }


    extern(C++, WebViewListener)
    {
        interface View {}
        interface Load {}
        interface Process {}
        interface Menu {}
        interface Dialog {}
        interface Print {}
        interface Download {}
        interface InputMethodEditor {}
    }
}


mixin template Awesomium4D()
{
    mixin ViewHeader!();
    mixin LoadHeader!();
    mixin ProcessHeader!();
    mixin MenuHeader!();
    mixin DialogHeader!();
    mixin PrintHeader!();
    mixin DownloadHeader!();
    mixin InputMethodEditorHeader!();
}


mixin template ViewHeader()
{
    interface IViewListenerD
    {
        void onChangeTitle(Awesomium.WebView, const Awesomium.WebString);
        void onChangeAddressBar(Awesomium.WebView, const Awesomium.WebURL);
        void onChangeTooltip(Awesomium.WebView, const Awesomium.WebString);
        void onChangeTargetURL(Awesomium.WebView, const Awesomium.WebURL);
        void onChangeCursor(Awesomium.WebView, Awesomium.Cursor);
        void onChangeFocus(Awesomium.WebView, Awesomium.FocusedElementType);
        void onAddConsoleMessage(Awesomium.WebView, const Awesomium.WebString, int, const Awesomium.WebString);
        void onShowCreatedWebView(Awesomium.WebView, Awesomium.WebView, const Awesomium.WebURL, const Awesomium.WebURL, const(Awesomium.Rect)*, bool);
    }


    interface ViewListenerD2Cpp : Awesomium.WebViewListener.View {}

    extern(C++, ViewListenerD2CppMember)
    {
        ViewListenerD2Cpp newCtor(IViewListenerD p, ulong mid);
        void deleteDtor(ViewListenerD2Cpp);
    }

    extern(C++, WebViewListenerViewMember)
    {
        void OnChangeTitle(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                           const Awesomium.WebString title);

        void OnChangeAddressBar(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                                const Awesomium.WebURL url);

        void OnChangeTooltip(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                             const Awesomium.WebString tooltip);

        void OnChangeTargetURL(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                               const Awesomium.WebURL url);

        void OnChangeCursor(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                            Cursor cursor);

        void OnChangeFocus(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                           FocusedElementType fet);

        void OnAddConsoleMessage(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                                 const Awesomium.WebString msg,
                                 int line_num,
                                 const Awesomium.WebString src);

        void OnShowCreatedWebView(Awesomium.WebViewListener.View, Awesomium.WebView caller,
                                  Awesomium.WebView new_view,
                                  const Awesomium.WebURL opener_url,
                                  const Awesomium.WebURL target_url,
                                  const(Rect)* initial_pos,
                                  bool is_popup);
    }
}


mixin template LoadHeader()
{
    interface ILoadListenerD
    {
        void onBeginLoadingFrame(Awesomium.WebView, long, bool, const Awesomium.WebURL, bool);
        void onFailLoadingFrame(Awesomium.WebView, long, bool, const Awesomium.WebURL, int, const Awesomium.WebString);
        void onFinishLoadingFrame(Awesomium.WebView, long, bool, const Awesomium.WebURL);
        void onDocumentReady(Awesomium.WebView, const Awesomium.WebURL);
    }


    interface LoadListenerD2Cpp : Awesomium.WebViewListener.Load {}

    extern(C++, LoadListenerD2CppMember)
    {
        LoadListenerD2Cpp newCtor(ILoadListenerD, ulong mid);
        void deleteDtor(LoadListenerD2Cpp);
    }

    extern(C++, WebViewListenerLoadMember)
    {
        void OnBeginLoadingFrame(Awesomium.WebViewListener.Load p, Awesomium.WebView caller,
                                 long frame_id, bool is_main_frame,
                                 const Awesomium.WebURL url,
                                 bool is_error_page);

        void OnFailLoadingFrame(Awesomium.WebViewListener.Load p, Awesomium.WebView caller,
                                long frame_id, bool is_main_frame,
                                const Awesomium.WebURL url,
                                int error_code,
                                const Awesomium.WebString error_desc);

        void OnFinishLoadingFrame(Awesomium.WebViewListener.Load p, Awesomium.WebView caller,
                                  long frame_id, bool is_main_frame,
                                  const Awesomium.WebURL url);

        void OnDocumentReady(Awesomium.WebViewListener.Load p, Awesomium.WebView caller,
                             const Awesomium.WebURL url);
    }
}


mixin template ProcessHeader()
{
    interface IProcessListenerD
    {
        void onLaunch(Awesomium.WebView);
        void onUnresponsive(Awesomium.WebView);
        void onResponsive(Awesomium.WebView);
        void onCrashed(Awesomium.WebView, Awesomium.TerminationStatus);
    }


    interface ProcessListenerD2Cpp : Awesomium.WebViewListener.Process {}

    extern(C++, ProcessListenerD2CppMember)
    {
        ProcessListenerD2Cpp newCtor(IProcessListenerD p, ulong mid);
        void deleteDtor(ProcessListenerD2Cpp);
    }


    extern(C++, WebViewListenerProcessMember)
    {
        void OnLaunch(Awesomium.WebViewListener.Process p, Awesomium.WebView caller);
        void OnUnresponsive(Awesomium.WebViewListener.Process p, Awesomium.WebView caller);
        void OnResponsive(Awesomium.WebViewListener.Process p, Awesomium.WebView caller);
        void OnCrashed(Awesomium.WebViewListener.Process p, Awesomium.WebView caller,
                       Awesomium.TerminationStatus status);
    }
}


mixin template MenuHeader()
{
    interface IMenuListenerD
    {
        void onShowPopupMenu(Awesomium.WebView, const Awesomium.WebPopupMenuInfo*);
        void onShowContextMenu(Awesomium.WebView, const WebContextMenuInfo*);
    }

    interface MenuListenerD2Cpp : Awesomium.WebViewListener.Menu {}
    extern(C++, MenuListenerD2CppMember)
    {
        MenuListenerD2Cpp newCtor(IMenuListenerD, ulong);
        void deleteDtor(MenuListenerD2Cpp);
    }

    extern(C++, WebViewListenerMenuMember)
    {
        void OnShowPopupMenu(Awesomium.WebViewListener.Menu p, Awesomium.WebView caller,
                             const Awesomium.WebPopupMenuInfo* menu_info);

        void OnShowContextMenu(Awesomium.WebViewListener.Menu p, Awesomium.WebView caller,
                               const Awesomium.WebContextMenuInfo* menu_info);
    }
}


mixin template DialogHeader()
{
    interface IDialogListenerD
    {
        void onShowFileChooser(Awesomium.WebView, const Awesomium.WebFileChooserInfo*);
        void onShowLoginDialog(Awesomium.WebView, const Awesomium.WebLoginDialogInfo*);
        void onShowCertificateErrorDialog(Awesomium.WebView, bool, const Awesomium.WebURL, Awesomium.CertError);
        void onShowPageInfoDialog(Awesomium.WebView, const Awesomium.WebPageInfo*);
    }

    interface DialogListenerD2Cpp : Awesomium.WebViewListener.Dialog {}
    extern(C++, DialogListenerD2CppMember)
    {
        DialogListenerD2Cpp newCtor(IDialogListenerD p, ulong mid);
        void deleteDtor(DialogListenerD2Cpp);
    }


    extern(C++, WebViewListenerDialogMember)
    {
        void OnShowFileChooser(Awesomium.WebViewListener.Dialog p,
                               Awesomium.WebView caller,
                               const Awesomium.WebFileChooserInfo* info);

        void OnShowLoginDialog(Awesomium.WebViewListener.Dialog p,
                               Awesomium.WebView caller,
                               const Awesomium.WebLoginDialogInfo* info);

        void OnShowCertificateErrorDialog(Awesomium.WebViewListener.Dialog p,
                                          Awesomium.WebView caller,
                                          bool is_overridable,
                                          const Awesomium.WebURL url,
                                          Awesomium.CertError error);

        void OnShowPageInfoDialog(Awesomium.WebViewListener.Dialog p,
                                  Awesomium.WebView caller,
                                  const Awesomium.WebPageInfo* info);
    }
}


mixin template PrintHeader()
{
    interface IPrintListenerD
    {
        void onRequestPrint(Awesomium.WebView);
        void onFailPrint(Awesomium.WebView, int);
        void onFinishPrint(Awesomium.WebView, int, const Awesomium.WebStringArray);
    }


    interface PrintListenerD2Cpp : Awesomium.WebViewListener.Print {}
    extern(C++, PrintListenerD2CppMember)
    {
        PrintListenerD2Cpp newCtor(IPrintListenerD, ulong);
        void deleteDtor(PrintListenerD2Cpp);
    }


    extern(C++, WebViewListenerPrintMember)
    {
        void OnRequestPrint(Awesomium.WebViewListener.Print p,
                            Awesomium.WebView caller);

        void OnFailPrint(Awesomium.WebViewListener.Print p,
                         Awesomium.WebView caller,
                         int request_id);

        void OnFinishPrint(Awesomium.WebViewListener.Print p,
                           Awesomium.WebView caller,
                           int request_id,
                           const Awesomium.WebStringArray file_list);
    }
}


mixin template DownloadHeader()
{
    interface IDownloadListenerD
    {
        void onRequestDownload(Awesomium.WebView, int,
                               const Awesomium.WebURL,
                               const Awesomium.WebString,
                               const Awesomium.WebString);

        void onUpdateDownload(Awesomium.WebView, int,
                              long, long, long);

        void onFinishDownload(Awesomium.WebView, int,
                              const Awesomium.WebURL,
                              const Awesomium.WebString);
    }


    interface DownloadListenerD2Cpp : Awesomium.WebViewListener.Download {}
    extern(C++, DownloadListenerD2CppMember)
    {
        DownloadListenerD2Cpp newCtor(IDownloadListenerD, ulong);
        void deleteDtor(DownloadListenerD2Cpp);
    }

    extern(C++, WebViewListenerDownloadMember)
    {
        void OnRequestDownload(Awesomium.WebViewListener.Download p,
                               Awesomium.WebView caller,
                               int download_id,
                               const Awesomium.WebURL url,
                               const Awesomium.WebString suggested_filename,
                               const Awesomium.WebString mime_type);

        void OnUpdateDownload(Awesomium.WebViewListener.Download p,
                              Awesomium.WebView caller,
                              int download_id,
                              long total_bytes,
                              long received_bytes,
                              long current_speed);

        void OnFinishDownload(Awesomium.WebViewListener.Download p,
                              Awesomium.WebView caller,
                              int download_id,
                              const Awesomium.WebURL url,
                              const Awesomium.WebString saved_path);
    }
}


mixin template InputMethodEditorHeader()
{
    interface IInputMethodEditorD
    {
        void onUpdateIME(Awesomium.WebView,
                         Awesomium.TextInputType,
                         int, int);

        void onCancelIME(Awesomium.WebView);

        void onChangeIMERange(Awesomium.WebView,
                              uint, uint);
    }


    interface InputMethodEditorD2Cpp : Awesomium.WebViewListener.InputMethodEditor {}
    extern(C++, InputMethodEditorD2CppMember)
    {
        InputMethodEditorD2Cpp newCtor(IInputMethodEditorD, ulong);
        void deleteDtor(InputMethodEditorD2Cpp);
    }


    extern(C++, WebViewListenerInputMethodEditorMember)
    {
        void OnUpdateIME(Awesomium.WebViewListener.InputMethodEditor p,
                         Awesomium.WebView caller,
                         Awesomium.TextInputType type,
                         int caret_x, int caret_y);

        void OnCancelIME(Awesomium.WebViewListener.InputMethodEditor p,
                         Awesomium.WebView caller);

        void OnChangeIMERange(Awesomium.WebViewListener.InputMethodEditor p,
                              Awesomium.WebView caller,
                              uint start, uint end);
    }
}
