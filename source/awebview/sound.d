module awebview.sound;


import core.atomic;
import std.internal.scopebuffer;
import std.algorithm;
import std.conv;
import std.exception;
import std.functional;
import std.string;
import std.typecons;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;

//import phobosx.signal;

import awebview.gui.html;


enum bool isEffector(E) = is(typeof((E e){
    uint ch;
    void[] stream;
    e.applyEffect(ch, stream);
    e.done(ch);
}));


private
struct SoundChunkImpl
{
    void increment()
    {
        if(_hashId == 0) return;
        SyncSoundChunk.incChunk(_hashId);
    }


    void decrement()
    {
        if(_hashId == 0) return;

        if(SyncSoundChunk.decChunk(_hashId)){
            SDLMixer.callCLib!Mix_FreeChunk(_chunk);
            _chunk = null;
            _hashId = 0;
        }
    }


    static
    SoundChunkImpl fromFile(const(char)[] filename)
    {
        char[1024] tmpbuf;
        auto buf = ScopeBuffer!char(tmpbuf);
        scope(exit) buf.free();

        buf.put(filename);
        buf.put('\0');

        auto chunk = SDLMixer.callCLib!Mix_LoadWAV(buf[].ptr);
        return fromSDLMixChunk(chunk);
    }


    static
    SoundChunkImpl fromMemory(const(void)[] buf)
    {
        auto rwobj = SDLMixer.callCLib!SDL_RWFromConstMem(buf.ptr, buf.length.to!uint);
        auto chunk = SDLMixer.callCLib!Mix_LoadWAV_RW(rwobj, 1);
        return fromSDLMixChunk(chunk);
    }


    static
    auto fromFileOnMemoryTask(const(char)[] filename)
    {
        import std.parallelism;
        return task!(a => fromMemory(std.file.read(a)))(filename);
    }


    static private
    SoundChunkImpl fromSDLMixChunk(Mix_Chunk* chunk)
    {
        auto id = SyncSoundChunk.getNextCount;
        SyncSoundChunk.addChunk(chunk, id);
        return SoundChunkImpl(id, chunk);
    }


    Mix_Chunk* handle() @property { return _chunk; }


  private:
    size_t _hashId;
    Mix_Chunk* _chunk;

  static:
    static final synchronized class SyncSoundChunk
    {
      static:
        struct ChunkField { Mix_Chunk* chunk; size_t refCount; }

        size_t getNextCount() @property
        {
            ++_cnt;
            return _cnt;
        }


        void addChunk(Mix_Chunk* chunk, size_t id)
        {
            removeNull();
            _hash[id] = ChunkField(chunk, 1);
        }


        void incChunk(size_t id)
        {
            ++_hash[id].refCount;
        }


        bool decChunk(size_t id)
        {
            auto p = id in _hash;
            --p.refCount;
            if(p.refCount == 0){
                p.chunk = null;
                return true;
            }
            else
                return false;
        }


        void removeNull()
        {
            size_t[] rmKeys;
            foreach(k, ref e; _hash)
                if(e.chunk is null)
                    rmKeys ~= k;

            foreach(k; rmKeys)
                _hash.remove(k);
        }


        __gshared size_t _cnt;
        __gshared ChunkField[size_t] _hash;
    }
}


private
struct SoundChunkShared
{
    this(this) { (*cast(SoundChunkImpl*)&_impl).increment(); }

    ~this()
    {
        (*cast(SoundChunkImpl*)&_impl).decrement();
    }


    Mix_Chunk* handle() @property { return _impl._chunk; }


  private:
    SoundChunkImpl _impl;
}


struct SoundChunk
{
    this(this) { _impl.increment(); }
    ~this() { _impl.decrement(); }

    Mix_Chunk* handle() @property { return _impl._chunk; }


    static
    SoundChunk fromFile(const(char)[] filename)
    {
        return SoundChunk(SoundChunkImpl.fromFile(filename));
    }


    static
    SoundChunk fromMemory(const(void)[] buf)
    {
        return SoundChunk(SoundChunkImpl.fromMemory(buf));
    }


    static
    auto fromFileOnMemoryTask(const(char)[] filename)
    {
        import std.parallelism;
        return task!(a => fromMemory(std.file.read(a)))(filename);
    }


    static private
    SoundChunk fromSDLMixChunk(Mix_Chunk* chunk)
    {
        return SoundChunk(SoundChunkImpl.fromSDLMixChunk(chunk));
    }


  private:
    SoundChunkImpl _impl;
}


final synchronized class SDLMixer
{
  static:
    auto ref callCLib(alias func, T...)(auto ref T args)
    {
        return func(forward!args);
    }
}


private synchronized final class SoundChannelImpl
{
    this(shared(SoundManager) sm)
    {
        _sm = sm;
    }


    size_t chId() @property
    {
        return _id;
    }


    void onAttachToChannel(int id)
    {
        _id = id;
        SDLMixer.callCLib!Mix_ChannelFinished(&channel_finished);
    }


    void playInf(SoundChunk chunk)
    {
        play(chunk, -1);
    }


    void play(SoundChunk chunk, int loop = 0)
    {
        *(cast(SoundChunkImpl*)&_chunk._impl) = chunk._impl;
        enforce(SDLMixer.callCLib!Mix_PlayChannel(_id, chunk.handle, loop) == _id, "Error on SDL_Mix");
    }


    void playTimeout(SoundChunk chunk, int loop, Duration dur)
    {
        uint msecs = dur.total!"msecs".to!uint;
        enforce(SDLMixer.callCLib!Mix_PlayChannelTimed(_id, chunk.handle, loop, msecs) == _id);
    }


    void playFadeIn(SoundChunk chunk, int loop, Duration dur)
    {
        uint msecs = dur.total!"msecs".to!uint;
        enforce(SDLMixer.callCLib!Mix_FadeInChannel(_id, chunk.handle, loop, msecs) == _id);
    }


    void playFadeInChannelTimed(SoundChunk chunk, int loop, Duration fadeInDur, Duration loopDur)
    {
        uint msFadeIn = fadeInDur.total!"msecs".to!uint;
        uint msLoop = loopDur.total!"msecs".to!uint;
        enforce(SDLMixer.callCLib!Mix_FadeInChannelTimed(_id, chunk.handle, loop, msFadeIn, msLoop));
    }


    //mixin(signal!()("onFinishedCB"));


    void onFinished()
    {
        *(cast(SoundChunkImpl*)&_chunk._impl) = SoundChunk.init._impl;
        //_onFinishedCB.emit();
    }


    void detachFromSM()
    {
        _sm.detachChannel(_id);
        _id = 0;
    }


    void onDestroy()
    {
        _sm.detachChannel(_id);
        _id = 0;
        *(cast(SoundChunkImpl*)&_chunk._impl) = SoundChunk.init._impl;
        _effector = null;
    }


    void effector(E)(E eff)
    if(isEffector!E)
    {
      static if(is(E == class) || is(E == interface))
      {
        static struct Wrapper
        {
          alias instance this;
          E instance;
        }

        this.effector = Wrapper(eff);
      }
      else
      {
        E* p = new E;
        *p = eff;
        _effector = cast(shared(E)*)p;

        SDLMixer.callCLib!Mix_RegisterEffect(_id, &(effectFunc!E), &(effectDone!E), p);
      }
    }


  private:
    uint _id;
    SoundChunkShared _chunk;
    shared(SoundManager) _sm;
    shared(void*) _effector;


    static 
    extern(C) void effectFunc(E)(int chan, void* stream, int len, void* udata)
    {
        try{
            E* p = cast(E*)udata;
            p.applyEffect(chan, stream[0 .. len]);
        }catch(Exception ex){}
    }


    static
    extern(C) void effectDone(E)(int chan, void* udata)
    {
        try{
            E* p = cast(E*)udata;
            p.done(chan);
        }catch(Exception ex){}
    }
}


final class SoundChannel : IDOnlyElement
{
    this(string id, shared(SoundManager) sm)
    {
        this(id, sm, new shared SoundChannelImpl(sm));
    }


    this(string id, shared(SoundManager) sm, shared(SoundChannelImpl) chImpl)
    {
        super(id);
        impl = chImpl;
    }


    alias impl this;
    shared(SoundChannelImpl) impl;


    void onAttachToChannel(int id)
    {
        impl.onAttachToChannel(id);
    }


    void detachFromSM()
    {
        impl.detachFromSM();
    }


    override
    void onDetach()
    {
        impl.detachFromSM();
        super.onDetach();
    }


    override
    void onDestroy()
    {
        impl.onDestroy();
        super.onDestroy();
    }


    void effector(E)(E effector)
    if(isEffector!E)
    {
        impl.effector(effector);
    }
}



synchronized final class SoundManager
{
    SoundChannel newChannel(string id) @property
    {
        return attachChannel(new SoundChannel(id, this));
    }


    SoundChannel attachChannel(SoundChannel ch)
    {
        foreach(uint i, ref e; _chlist){
            if(e is null){
                e = ch.impl;
                ch.onAttachToChannel(i);
                return ch;
            }
        }

        immutable len = _chlist.length.to!uint;
        _chlist.length = len + 1;
        _chlist.length = Mix_AllocateChannels(_chlist.capacity.to!int);

        _chlist[len] = ch.impl;
        ch.onAttachToChannel(len);
        return ch;
    }


    private void detachChannel(uint chId)
    {
        _chlist[chId] = null;
    }


    void detachChannel(SoundChannel ch)
    {
        detachChannel(ch.chId);
        ch.onDetach();
    }


    void onChannelFinished(uint chId)
    {
        if(_chlist.length < chId && _chlist[chId] !is null)
            _chlist[chId].onFinished();
    }


    static
    shared(SoundManager) instance() @property
    {
        if(_instance)
            return _instance;
        else{
            _instance = new shared SoundManager();
            return _instance;
        }
    }


  private:
    shared(SoundChannelImpl)[] _chlist;

  static:
    shared SoundManager _instance;
}


extern(C) void channel_finished(int ch)
{
    if(SoundManager.instance !is null)
        SoundManager.instance.onChannelFinished(ch);
}
