module awebview.wrapper.cpp.mmanager;


mixin template Awesomium()
{

}


mixin template Awesomium4D()
{
    void deleteFromMemoryManager(ulong id) @nogc nothrow
    {
        MemoryManager.instance.unregister(id);
    }
}


class MemoryManager
{
    this(uint nodeLen = 1024)
    {
        _nodeLen = nodeLen;
        appendNewNode();
    }


    ulong register(const(void)* p)
    {
        auto bg = _nodes.ptr;
        const ed = _nodes[$ .. $].ptr;
        while(bg != ed && bg.cnt == _nodeLen)
            ++bg;

        if(bg == ed){
            appendNewNode();
            bg = _nodes[$-1 .. $].ptr;
        }

        auto bg2 = bg.ptbl.ptr;
        const ed2 = bg.ptbl[$ .. $].ptr;
        while(bg2 != ed2 && *bg2 != null)
            ++bg2;

        import std.string;
        assert(bg2 != ed2);
        *bg2 = p;
        ++bg.cnt;
        return ((cast(ulong)(bg - _nodes.ptr)) << 32) | (bg2 - bg.ptbl.ptr + 1);
    }


    void unregister(ulong id) @nogc nothrow
    {
        if(id == 0) return;

        uint nodeIdx = id >> 32;
        uint pIdx = cast(uint)(id & uint.max) - 1;

        --_nodes[nodeIdx].cnt;
        _nodes[nodeIdx].ptbl[pIdx] = null;
    }


    static MemoryManager instance() @property @nogc nothrow
    {
        return _inst;
    }


  private:
    void appendNewNode()
    {
        _nodes ~= Node(new const(void)*[_nodeLen], 0);
    }

    static struct Node {
        const(void)*[] ptbl;
        uint cnt;
    }

    Node[] _nodes;
    immutable(uint) _nodeLen;

    static MemoryManager _inst;

    static this()
    {
        _inst = new MemoryManager();
    }
}
