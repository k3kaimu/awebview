module awebview.utils;


string pathToURI(string path)
{
    import std.uri : encodeComponent;
    import std.array : replace;
    import std.path : buildNormalizedPath, isAbsolute, absolutePath;

    if(!path.isAbsolute)
        path = path.absolutePath();

    version(Windows)
    {
        return "file:///" ~  encodeComponent(buildNormalizedPath(path).replace("\\", "/"));
    }
    else
    {
        return "file://" ~ encodeComponent(buildNormalizedPath(path));
    }
}
