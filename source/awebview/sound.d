module awebview.sound;


import core.atomic;
import std.internal.scopebuffer;
import std.algorithm;
import std.exception;
import std.functional;
import std.string;
import std.typecons;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;

import awebview.gui.html;


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
        auto rwobj = SDLMixer.callCLib!SDL_RWFromConstMem(buf.ptr, buf.length);
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
    this(this) shared { (*cast(SoundChunkImpl*)&_impl).increment(); }

    ~this() shared
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


private synchronized class SoundChannelImpl
{
    this(shared(SoundManager) sm)
    {
        _sm = sm;
    }


    void onAttachToChannel(int id)
    {
        _id = id;
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


    void onFinished()
    {
        *(cast(SoundChunkImpl*)&_chunk._impl) = SoundChunk.init._impl;
    }


    void onDestroy()
    {
        _sm.detachChannel(_id);
    }


  private:
    uint _id;
    SoundChunkShared _chunk;
    shared(SoundManager) _sm;
}


class SoundChannel : IDOnlyElement
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


    override
    void onDestroy()
    {
        impl.onDestroy();
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
        foreach(i, ref e; _chlist){
            if(e is null){
                e = ch.impl;
                ch.onAttachToChannel(i);
                return ch;
            }
        }

        immutable len = _chlist.length;
        _chlist.length = len + 1;
        _chlist.length = Mix_AllocateChannels(_chlist.capacity.to!int);

        _chlist[len] = ch.impl;
        ch.onAttachToChannel(len);
        return ch;
    }


    void detachChannel(uint chId)
    {
        _chlist[chId] = null;
    }


    void onChannelFinished(uint chId)
    {
        _chlist[chId].onFinished();
    }


  private:
    shared(SoundChannelImpl)[] _chlist;
}
