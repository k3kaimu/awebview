module awebview.gui.widgets.table;

__EOF__

import std.array;
import std.range;


class Table(alias attrs) : TemplateHTMLElement!(HTMLElement, `<table id="%[id%]" ` ~ buildHTMLTagAttr(attrs) ~ `>%s</table>`)
{
    size_t[2] headerSize() const;
    size_t[2] bodySize() const;
    size_t[2] footerSize() const;

    inout(HTMLElement) getHeaderElement(size_t i, size_t j) inout;
    inout(HTMLElement) getBodyElement(size_t i, size_t j) inout;
    inout(HTMLElement) getFooterElement(size_t i, size_t j) inout;

    void makeTdTag(size_t i, size_t j, HTMLElement element, scope void delegate(const(char)[]) sink) const
    { .put(sink, "<td>"); .put(sink, element.html); .put(sink, "</td>"); }

    void makeTrTag(size_t i, string content, scope void delegate(const(char)[]) sink) const
    { .put(sink, "<tr>"); .put(sink, content); .put(sink, "</tr>"); }

    void makeTdTagOfHeader(size_t i, size_t j, HTMLElement element, scope void delegate(const(char)[]) sink) const
    { makeTdTag(i, j, element, sink); }

    void makeTrTagOfHeader(size_t i, string content, scope void delegate(const(char)[]) sink) const
    { makeTrTag(i, content, sink); }

    void makeTdTagOfFooter(size_t i, size_t j, HTMLElement element, scope void delegate(const(char)[]) sink) const
    { makeTdTag(i, j, element, sink); }

    void makeTrTagOfFooter(size_t i, string content, scope void delegate(const(char)[]) sink) const
    { makeTrTag(i, content, sink); }

    void makeTheadTag(string content, scope void delegate(const(char)[]) sink) const
    { .put(sink, "<thead>"); .put(sink, content); .put(sink, "</thead>"); }

    void makeTbodyTag(string content, scope void delegate(const(char)[]) sink) const
    { .put(sink, "<tbody>"); .put(sink, content); .put(sink, "</tbody>"); }

    void makeTfootTag(string content, scope void delegate(const(char)[]) sink) const
    { .put(sink, "<tfoot>"); .put(sink, content); .put(sink, "</tfoot>"); }

    override
    @property
    string html() const
    {
        auto appHB = appender!string();
        {
            auto appTHs = appender!string();
            foreach(i, e; _hs)
                _g.makeTdTagOfHeader(0, i, e, (const(char)[] buf){ .put(appTHs, buf); });

            auto appHTR = appender!string();
            g.tr(0, appTHs.data, appHTR);

            auto appH = appender!string();
            g.thead(appHTR.data, appHB);
        }

        {
            auto appTRs = appender!string();
            foreach(i, e; _ds){
                auto appTDs = appender!string();
                foreach(j, ee; e)
                    g.td(i+1, j, ee, appTDs);

                g.tr(i+1, appTDs.data, appTRs);
            }
            g.tbody(appTRs.data, appHB);
        }

        auto appT = appender!string();
        g.table(appHB.data, appT);
        return appT.data;
    }


    void addHeaderRow(HTMLElement[] elems)
    {
        _thead ~= elems;
    }


    void addHeaderCol(HTMLElement[] elems)
    {
        foreach(i, e; elems)
            _thead[i] ~= e;
    }


    void addBodyRow(HTMLElement[] elems)
    {
        _tbody ~= elems;
    }


    void addBodyCol(HTMLElement[] elems)
    {
        foreach(i, e; elems)
            _tbody[i] ~= e;
    }


    void addFooterRow(HTMLElement[] elems)
    {
        _tfoot ~= elems;
    }


    void addFooterCol(HTMLElement[] elems)
    {
        foreach(i, e; elems)
            _tfoot[i] ~= e;
    }


    final
    ref inout(HTMLElement[][]) theadContents() inout pure nothrow @safe @nogc @property { return _thead; }

    final
    ref inout(HTMLElement[][]) tbodyContents() inout pure nothrow @safe @nogc @property { return _tbody; }

    final
    ref inout(HTMLElement[][]) tfootContents() inout pure nothrow @safe @nogc @property { return _tfoot; }


  private:
    HTMLElement[][] _thead;
    HTMLElement[][] _tbody;
    HTMLElement[][] _tfoot;
}


/*
class Table(G) : HTMLElement
{
    this(string id, bool doCreateObject, G g)
    {
        super(id, doCreateObject);
        _g = g;
        _g.id = id;
    }


    void genTD(size_t i, size_t j, )


    override
    @property
    string html()
    {
        auto appHB = appender!string();
        {
            auto appTHs = appender!string();
            foreach(i, e; _hs)
                _g.td(0, i, e, appTHs);

            auto appHTR = appender!string();
            g.tr(0, appTHs.data, appHTR);

            auto appH = appender!string();
            g.thead(appHTR.data, appHB);
        }

        {
            auto appTRs = appender!string();
            foreach(i, e; _ds){
                auto appTDs = appender!string();
                foreach(j, ee; e)
                    g.td(i+1, j, ee, appTDs);

                g.tr(i+1, appTDs.data, appTRs);
            }
            g.tbody(appTRs.data, appHB);
        }

        auto appT = appender!string();
        g.table(appHB.data, appT);
        return appT.data;
    }


  private:
    string[] _hs;
    string[][] _ds;
    G _g;
}


//interface ITable
//{
//    void header(IHeader);
    
//}


//abstract class TableHeader : HTMLElement
//{
//    this(string id, bool doCreateObject)
//    {
//        super(id, doCreateObject);
//    }


//    TableHeaderData[] data();
//}


//abstract class TableHeaderData : HTMLElement
//{
//    this(string id, bool doCreateObject)
//    {
//        super(id, doCreateObject);
//    }
//}


//abstract class TableRow : HTMLElement
//{
//    this(string id, bool doCreateObject)
//    {
//        super(id, doCreateObject);
//    }
//}


//abstract class TableData : HTMLElement
//{
//    this(string id, bool doCreateObject)
//    {
//        super(id, doCreateObject);
//    }
//}

///**
//auto table = new Table!(["class": "table table-striped"])("tweetTable");

//foreach(i; 0 .. 10){

//    auto row = new Row;
//    foreach(j; 0 .. 10)
//        row ~= new MyData(....);

//    table ~= row;
//}
//*/
//abstract class Table : HTMLElement
//{
//    this(string id)
//    {
//        super(id);
//    }


//    //void header(TableHeader h) {}
//    //TableHeader header() {}


//    //TableRow[] data() {}
//    //void data(TableRow[]) {}
//}


//class TableHeader
//{

//}


//class TableBody
//{

//}


//class Table
*/