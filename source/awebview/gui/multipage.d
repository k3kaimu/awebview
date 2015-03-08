module awebview.gui.multipage;

import std.exception;

import awebview.gui.html;


class SwitchingPage : HTMLPage
{
    struct Payload
    {
        HTMLPage page;
        bool wasLoaded;
    }


    this(string id)
    {
        super(id);
    }


    void opOpAssign(string op : "~")(HTMLPage page)
    {
        _pages[page.id] = Payload(page, false);
    }


    void remove(HTMLPage page)
    {
        removePage(page.id);
    }


    void removePage(string id)
    in{
        assert(id in _pages);
    }
    body{
        _pages.remove(id);

        if(_nowPage.id == id){
            foreach(k; _pages.byKey){
                show(k);
                break;
            }
        }
    }


    void show(string id)
    in{
        assert(id in _pages);
    }
    body{
        auto p = enforce(id in _pages);

        if(!p.wasLoaded)
            p.page.onStart(this.activity);

        if(_nowPage !is null)
            _nowPage.onDetach();

        _nowPage = p.page;
        _nowPage.onAttach(!p.wasLoaded);

        this.activity.reload();
    }


    override
    void onLoad(bool isInit)
    {
        if(_nowPage !is null){
            auto p = _nowPage.id in _pages;
            assert(p, "logical error");

            p.page.onLoad(!p.wasLoaded);
            p.wasLoaded = true;
        }
    }


    override
    void onUpdate()
    {
        if(_nowPage !is null)
            _nowPage.onUpdate();
    }


    override @property
    string html() const
    {
        if(auto p = _nowPage.id in _pages)
            return p.page.html;
        else
            return null;
    }


    @property
    const(Payload[string]) pages() const pure nothrow @safe @nogc
    {
        return _pages;
    }


    @property
    inout(HTMLPage) nowPage() inout pure nothrow @safe @nogc
    {
        return _nowPage;
    }


  private:
    HTMLPage _nowPage;
    Payload[string] _pages;
}
