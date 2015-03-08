dmc -c awesomium4d_cw.cpp -I.. -IC:\D\dm\stlport\stlport
del awesomium4d_cw.lib
lib -c awesomium4d_cw.lib ..\..\bin\win32\stlp45dm_static.lib ..\..\bin\win32\awesomium_omf.lib awesomium4d_cw.obj
copy awesomium4d_cw.obj ..\..\bin\win32\