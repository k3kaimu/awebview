# awebview

This is [Awesomium](http://www.awesomium.com/) wrapper and WebView GUI library for D programming language.


## Features

## full access Awesomium C++ OOP api.

## You can build GUI from HTML templates.

For example...

~~~~~~~~~~~~~d
// generate html page from top_view.html
auto topPage = new TemplateHTMLPage!(import(`top_view.html`))(`Top`);

// generate html button from my_btn.html and create a JS global object named `btn1`.
auto btn1 = new GenericButton!(import(`my_btn.html`))(`btn1`);

// handle onclick event
size_t cnt;
btn1.onClick.strongConnect(delegate(FiredContext ctx, WeakRef!(const(JSArrayCpp)) args)
{
    ++cnt;

    // DOM access. This code is translated to `document.getElementById("btn1").value = ...;`
    btn1["value"] = format("cnt: %s", cnt);
});

topPage ~= btn1;
~~~~~~~~~~~~~~

~~~~~~~~~~~html
<!-- views/top_view.html -->
<!doctype html>
<html lang="jp">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>TopView</title>

    <link rel="stylesheet" href="views/bootstrap-3.3.2-dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="views/bootstrap-3.3.2-dist/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="views/font-awesome-4.3.0/css/font-awesome.min.css">
    <link href="jquery-ui/jquery-ui.css", rel="stylesheet">
</head>
<body>

%[elements["btn1"].html%]

<script src="views/jquery-ui/external/jquery/jquery.js"></script>
<script src="views/jquery-ui/jquery-ui.js"></script>
<script src="views/bootstrap-3.3.2-dist/js/bootstrap.min.js"></script>
</body>
</html>
~~~~~~~~~~~~~~~

~~~~~~~~~~~html
<!-- views/my_btn.html -->
<!-- -->
<input type="button" class="btn btn-xs btn-primary" id="%[id%]" onclick="%[id%].onClick()" value="%[id%]">
~~~~~~~~~~~~~~~
