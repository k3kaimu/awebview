module awebview.wrapper.cpp.printconfig;

mixin template Awesomium()
{
    align(1) struct PrintConfig
    {
        Rect pageSize;
        double dpi;
        bool splitPagesIntoMultipleFiles;
        bool printSelectionOnly;

        static
        PrintConfig opCall()
        {
            PrintConfig pc;
            PrintConfigMember.ctor(&pc);
            return pc;
        }
    }

    unittest
    {
        assert(PrintConfig.sizeof == PrintConfigMember.sizeOfInstance());
    }
}


mixin template Awesomium4D()
{
    extern(C++, PrintConfigMember)
    {
        size_t sizeOfInstance();
        void ctor(Awesomium.PrintConfig * p);
    }
}
