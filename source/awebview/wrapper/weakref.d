module awebview.wrapper.weakref;

import awebview.wrapper.cpp;

import carbon.nonametype;


template WeakRef(T)
if(is(typeof(T.weakRef(T.init.cppObj))))
{
    alias WeakRef = typeof(T.weakRef(T.init.cppObj));
}


auto weakRef(T, H)(H handle)
if(is(typeof(T.weakRef(handle))))
{
    return T.weakRef(handle);
}
