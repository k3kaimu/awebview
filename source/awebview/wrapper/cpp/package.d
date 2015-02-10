module awebview.wrapper.cpp;

import std.algorithm,
       std.array;

enum modules = [`platform`,
                `jsobject`,
                `jsvalue`,
                `jsarray`,
                `webstring`,
                `webstringarray`,
                `weburl`,
                `webmenuitem`,
                `webviewlistener`,
                `webview`,
                `surface`,
                `bitmapsurface`,
                `childprocess`,
                `datasource`,
                `datapak`,
                `mmanager`,
                `printconfig`,
                `resourceinterceptor`,
                `webconfig`,
                `webcore`,
                `webkeyboardcodes`,
                `webkeyboardevent`,
                `webpreferences`,
                `websession`,
                `webtouchevent`];

private string getPublicImports()
{
    return `public import ` ~ modules.map!(a => `awebview.wrapper.cpp.` ~ a).join(", ") ~ ";";
}

private string getMTAwesomium()
{
    return modules.map!(a => `mixin awebview.wrapper.cpp.` ~ a ~ `.Awesomium!();`).join("\n");
}

private string getMTawebview()
{
    return modules.map!(a => `mixin awebview.wrapper.cpp.` ~ a ~ `.Awesomium4D!();`).join("\n");
}

mixin(getPublicImports());

@nogc:
nothrow:

extern(C++, Awesomium)
{
    mixin(getMTAwesomium());
}

extern(C++, Awesomium4D)
{
    mixin(getMTawebview());
}
