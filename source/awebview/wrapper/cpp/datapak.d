module awebview.wrapper.cpp.datapak;


mixin template Awesomium()
{
    interface DataPakSource : DataSource {}
}


mixin template Awesomium4D()
{
    bool WriteDataPak(const(Awesomium.WebString) out_file,
                      const(Awesomium.WebString) in_dir,
                      const(Awesomium.WebString) ignore_ext,
                      ushort* numW);

    extern(C++, DataPakSourceMember)
    {
        size_t sizeofInstance();
        void ctor(Awesomium.DataPakSource p, const Awesomium.WebString);
        Awesomium.DataPakSource newCtor(const Awesomium.WebString);

        void dtor(Awesomium.DataPakSource p);
        void deleteDtor(Awesomium.DataPakSource p);

        void OnRequest(Awesomium.DataPakSource p, int,
                       const Awesomium.ResourceRequest,
                       const Awesomium.WebString);
    }
}
