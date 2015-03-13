module awebview.gui.datapack;

import msgpack;

struct DataPack(T...)
{
    T field;
    ubyte[] parent;

    ubyte[] pack()
    {
        return msgpack.pack(this);
    }


    static
    DataPack unpack(ubyte[] data)
    {
        return msgpack.unpack!DataPack(data);
    }
}
