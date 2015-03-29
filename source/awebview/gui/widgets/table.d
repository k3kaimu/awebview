module awebview.gui.widgets.table;

__EOF__

import std.array;

enum isTableGenerator(T) = is(typeof((T g){
    import std.array : appender;
    auto app = appender!string();
    string id;
    string content;
    size_t i, j;

    g.id = id;
    g.td(i, j, content, app);   // when i == 0, generate th
    g.tr(i, content, app);      // when i == 0, generate tr of thead
    g.thead(content, app);
    g.tbody(content, app);
    g.table(content, app);
}));


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