module awebview.gui.widgets.image;

__EOF__

class Image(alias format = q{<img id="%[id%]"> alt="" src="%[src%]"}) : HTMLElement
{
    private this(string id, bool doCreateObject, string uri)
    {
        super(id, false);
        _uri = uri;
    }


    static Image fromURI(string id, string uri)
    {
        return new Image(id, uri);
    }


    static Image fromPath(string id, string path)
    {
        import std.uri : encodeComponent;
        import std.array : replace;
        import std.path : buildNormalizedPath;

        if(path.isAbsolute){
            version(Windows)
                path = "file:///" ~  encodeComponent(buildNormalizedPath(path).replace('\\', '/');
            else
                path = "file://" ~ encodeComponent(buildNormalizedPath(path));

            return fromURI(id, path);
        }
        else
            return fromPath(id, absolutePath(path));
    }


    final
    @property
    string src()
    {
        if(this.activity)
            _uri = this["src"].to!string;

        return _uri;
    }


    final
    @property
    void src(string uri)
    {
        _uri = uri;

        if(this.activity)
            this["src"] = uri;
    }


    string html()
    {

    }


  private:
    string _uri;
}
