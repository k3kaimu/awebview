module awebview.cssgrammar;

import std.conv;
import std.algorithm;
import std.array;
import std.format;
import std.string;

import awebview.gui.activity;
import awebview.wrapper;

import pegged.grammar;

import carbon.utils;

mixin(grammar(q{
CSSCode:
    Body < (Hash / Ignore)*
    Hash < Selector Ignore "{" Ignore FieldList Ignore "}"

    Comment < "/*" (!"*/" .)* "*/"
    Space < ("\r" / "\n" / "\t" / " ")+
    Ignore < (Space / Comment)*

    FieldList < (Field / Ignore)*
    Field < Symbol Ignore ":" Ignore Value Ignore ";"
    Symbol < [a-zA-Z_] ([a-zA-Z0-9_] / "-")*
    Value < (Statements / (!";" .))*
    Statements < "{" ( (&"{" Statements) / (!"}" .) )* "}"

    Selector < (!(";" / "{") .)+
}));


string matchString(ParseTree p) @property
{
    return p.input[p.begin .. p.end];
}


void foreachAll(ParseTree p, scope bool delegate(ParseTree) dg)
{
    auto res = dg(p);
    if(res)
        return;

    foreach(e; p.children)
        foreachAll(e, dg);
}


void foreachMatch(alias pred)(ParseTree p, scope bool delegate(ParseTree) dg)
{
    if(pred(p))
        if(dg(p))
            return;

    foreach(e; p.children)
        foreachMatch!pred(e, dg);
}


bool getFirstMatch(alias pred)(ParseTree p, out ParseTree dst)
{
    if(pred(p)){
        dst = p;
        return true;
    }

    foreach(e; p.children){
        if(getFirstMatch!pred(e, dst))
            return true;
    }

    return false;
}


ParseTree firstMatch(alias pred)(ParseTree p)
{
    ParseTree dst;
    getFirstMatch!pred(p, dst);
    return dst;
}


string generateResizeStatements(Activity activity)
{
    static string[] getCSSList(Activity activity)
    {
        auto len = activity.evalJS(`(function() {
            var ss = document.styleSheets;
            var hrefs = [];
            for(var i = 0, len = ss.length; i < len; ++i){
                var stylesheet = ss[i];
                if(stylesheet.href && stylesheet.href !== ''){
                    hrefs.push(stylesheet.href);
                }
            }

            _carrierObject_.value = hrefs;
            _carrierObject_.idx = 0;
            return hrefs.length;
        })()`).get!uint;

        string[] res;
        foreach(i; 0 .. len){
            res ~= activity.evalJS(q{_carrierObject_.value[_carrierObject_.idx++]}).to!string;
        }

        return res;
    }


    static string getCSS(string href)
    {
        WebURL url = href;
        if(url.scheme == "file"){
            import std.file : readText;
            string path = url.path.to!string;
            if(path[0] == '/')
                path = path[1 .. $];

            return readText(path);
        }
        else{
            import std.net.curl : get;
            return get(href.to!string).dup;
        }
    }


    static string[2][] getJSExprFieldOfHash(ParseTree p)
    {
        string[2][] res;
        if(p.name == "CSSCode.Hash"){
            p.foreachMatch!(p => p.name == "CSSCode.Field")((p){
                string sym = p.firstMatch!(a => a.name == "CSSCode.Symbol")().matchString;
                string val = p.firstMatch!(a => a.name == "CSSCode.Value")().matchString;

                if(val.startsWith("jsExpr(") && val.endsWith(")"))
                    res ~= [sym, val[7 .. $-1]];

                return true;
            });
        }

        return res;
    }


    import std.algorithm : map;
    import std.array : array;

    auto app = appender!string();

    foreach(stylesheetName; getCSSList(activity)){
        auto stylesheet = getCSS(stylesheetName);
        auto ptree = CSSCode(stylesheet);

        if(!ptree.successful)
            continue;

        ptree.foreachMatch!(p => p.name == "CSSCode.Hash")((p){
            auto sel = toLiteral(matchString(p.children[0]));
            auto exprs = getJSExprFieldOfHash(p);

            foreach(e; exprs)
                app.formattedWrite(`cssResize(document,window,%s,%s,%s);`, sel, toLiteral(e[0]), toLiteral(e[1]));

            return true;
        });
    }

    return app.data;
}
