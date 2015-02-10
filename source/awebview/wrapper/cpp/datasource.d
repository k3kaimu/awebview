module awebview.wrapper.cpp.datasource;


mixin template Awesomium()
{
    interface DataSource {}
}


mixin template Awesomium4D()
{
  /*
    interface IDataSourceD
    {
        void onRequest(int, const Awesomium.ResourceRequest,
                       const Awesomium.WebString);
        void sendSession(int, uint, const(char)*, const Awesomium.WebString);
    }*/

/*
    interface DataSourceD2Cpp : Awesomium.DataSource {}
    extern(C++, DataSourceD2CppMember)
    {
        DataSourceD2Cpp newCtor(IDataSourceD p);
        void deleteDtor(DataSourceD2Cpp p);
    }*/


    extern(C++, DataSourceMember)
    {
        void dtor(Awesomium.DataSource p);
        void deleteDtor(Awesomium.DataSource p);
        void OnRequest(Awesomium.DataSource p, int reqId,
                       const Awesomium.ResourceRequest req,
                       const Awesomium.WebString path);
        void SendResponse(Awesomium.DataSource * p,
                          int reqId, uint bufSize, const(char)* buf,
                          const Awesomium.WebString mt);
    }
}
