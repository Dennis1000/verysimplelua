{*
** $Id: lua.h $
** Lua - A Scripting Language
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of this file
*}

{*
** Translated to Delphi by Dennis D. Spreen <dennis@spreendigital.de>
** Notes:
    - LUA_VERSION string suffixed by '_' to avoid name collision
    - lua_gc with single parameter only

   Not translated:
     - lua_upvalueindex(i)
     - RCS ident string
     - lua_yield(L,n), use lua_yieldk(L, n, 0, NULL) instead
    - compatibility macros
*}

const
  LUA_VERSION_MAJOR   = '5';
  LUA_VERSION_MINOR   = '4';
  LUA_VERSION_RELEASE = '3';

  LUA_VERSION_NUM          = 504;
  LUA_VERSION_RELEASEN_NUM = (LUA_VERSION_NUM * 100 + 0);

  LUA_VERSION_   = 'Lua ' + LUA_VERSION_MAJOR + '.' + LUA_VERSION_MINOR;
  LUA_RELEASE    = LUA_VERSION_ + '.' + LUA_VERSION_RELEASE;
  LUA_COPYRIGHT  = LUA_RELEASE + '  Copyright (C) 1994-2021 Lua.org, PUC-Rio';
  LUA_AUTHORS    = 'R. Ierusalimschy, L. H. de Figueiredo, W. Celes';


{* mark for precompiled code ('<esc>Lua') *}
  LUA_SIGNATURE	= #$1b'Lua';

{* option for multiple returns in 'lua_pcall' and 'lua_call' *}
  LUA_MULTRET	= -1;

{*
** Pseudo-indices
** (-LUAI_MAXSTACK is the minimum valid index; we keep some free empty
** space after that to help overflow detection)
*}
   LUA_REGISTRYINDEX = (-LUAI_MAXSTACK - 1000);
   function lua_upvalueindex(i: Integer): Integer; inline;

{* thread status *}
const
  LUA_OK         = 0;
  LUA_YIELD_     = 1;
  LUA_ERRRUN     = 2;
  LUA_ERRSYNTAX	 = 3;
  LUA_ERRMEM	 = 4;
  LUA_ERRERR	 = 5;

type
  lua_State = Pointer;

{*
** basic types
*}
const
  LUA_TNONE          = (-1);

  LUA_TNIL	     = 0;
  LUA_TBOOLEAN	     = 1;
  LUA_TLIGHTUSERDATA = 2;
  LUA_TNUMBER        = 3;
  LUA_TSTRING        = 4;
  LUA_TTABLE         = 5;
  LUA_TFUNCTION      = 6;
  LUA_TUSERDATA      = 7;
  LUA_TTHREAD        = 8;

  LUA_NUMTYPES       = 9;


{* minimum Lua stack available to a C function *}
  LUA_MINSTACK	     = 20;


{* predefined values in the registry *}
  LUA_RIDX_MAINTHREAD = 1;
  LUA_RIDX_GLOBALS    = 2;
  LUA_RIDX_LAST       = LUA_RIDX_GLOBALS;


type
{*
** Type for C functions registered with Lua
*}
  lua_CFunction = function(L: lua_State): Integer; cdecl;

{*
** Type for continuation functions
*}
  lua_KFunction = function(L: lua_State; status: Integer; ctx: lua_KContext): Integer; cdecl;


{*
** Type for functions that read/write blocks when loading/dumping Lua chunks
*}
  lua_Reader = function(L: lua_State; ud: Pointer; sz: Psize_t): Pointer; cdecl;
  lua_Writer = function(L: lua_State; p: Pointer; sz: size_t; ud: Pointer): Integer; cdecl;

{*
** Type for memory-allocation functions
*}
  lua_Alloc = function(ud: Pointer; ptr: Pointer; osize: size_t; nsize: size_t): Pointer; cdecl;


{*
** Type for warning functions
*}
  lua_WarnFunction = function(ud: Pointer; msg:  MarshaledAString; tocont: Integer): Pointer; cdecl;


{*
** RCS ident string
*}
//extern const char lua_ident[]; {not translated}


{*
** state manipulation
*}
{$IFDEF STATICLIBRARY}
  function lua_newstate(f: lua_Alloc; ud: Pointer): lua_State; cdecl; external LUA_LIBRARY;
  procedure lua_close(L: lua_State); cdecl; external LUA_LIBRARY;
  function lua_newthread(L: lua_State): lua_State; cdecl; external LUA_LIBRARY;
  function lua_resetthread(L: lua_State): Integer; cdecl; external LUA_LIBRARY;

  function lua_atpanic(L: lua_State; panicf: lua_CFunction): lua_CFunction; cdecl; external LUA_LIBRARY;

  function lua_version(L: lua_State): lua_Number; cdecl; external LUA_LIBRARY;
{$ELSE}
var
  lua_newstate: function(f: lua_Alloc; ud: Pointer): lua_State; cdecl;
  lua_close: procedure (L: lua_State); cdecl;
  lua_newthread: function(L: lua_State): lua_State; cdecl;
  lua_resetthread: function(L: lua_State): Integer; cdecl;

  lua_atpanic: function(L: lua_State; panicf: lua_CFunction): lua_CFunction; cdecl;

  lua_version: function(L: lua_State): lua_Number; cdecl;
{$ENDIF}


{*
** basic stack manipulation
*}
{$IFDEF STATICLIBRARY}
  function lua_absindex(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_gettop(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  procedure lua_settop(L: lua_State; idx: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_pushvalue(L: lua_State; idx: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_rotate(L: lua_State; idx: Integer; n: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_copy(L: lua_State; fromidx: Integer; toidx: Integer); cdecl; external LUA_LIBRARY;
  function lua_checkstack(L: lua_State; n: Integer): Integer; cdecl; external LUA_LIBRARY;

  procedure lua_xmove(from: lua_State; to_: lua_State; n: Integer); cdecl; external LUA_LIBRARY;
{$ELSE}
  lua_absindex: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_gettop: function(L: lua_State): Integer; cdecl;
  lua_settop: procedure(L: lua_State; idx: Integer); cdecl;
  lua_pushvalue: procedure(L: lua_State; idx: Integer); cdecl;
  lua_rotate: procedure(L: lua_State; idx: Integer; n: Integer); cdecl;
  lua_copy: procedure(L: lua_State; fromidx: Integer; toidx: Integer); cdecl;
  lua_checkstack: function(L: lua_State; n: Integer): Integer; cdecl;

  lua_xmove: procedure(from: lua_State; to_: lua_State; n: Integer); cdecl;
{$ENDIF}


{*
** access functions (stack -> C)
*}
{$IFDEF STATICLIBRARY}
  function lua_isnumber(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_isstring(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_iscfunction(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_isinteger(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_isuserdata(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_type(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_typename(L: lua_State; tp: Integer): MarshaledAString; cdecl; external LUA_LIBRARY;

  function lua_tonumberx(L: lua_State; idx: Integer; isnum: PLongBool): lua_Number; cdecl; external LUA_LIBRARY;
  function lua_tointegerx(L: lua_State; idx: Integer; isnum: PLongBool): lua_Integer; cdecl; external LUA_LIBRARY;
  function lua_toboolean(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_tolstring(L: lua_State; idx: Integer; len: Psize_t): MarshaledAString; cdecl; external LUA_LIBRARY;
  function lua_rawlen(L: lua_State; idx: Integer): size_t; cdecl; external LUA_LIBRARY;
  function lua_tocfunction(L: lua_State; idx: Integer): lua_CFunction; cdecl; external LUA_LIBRARY;
  function lua_touserdata(L: lua_State; idx: Integer): Pointer; cdecl; external LUA_LIBRARY;
  function lua_tothread(L: lua_State; idx: Integer): lua_State; cdecl; external LUA_LIBRARY;
  function lua_topointer(L: lua_State; idx: Integer): Pointer; cdecl; external LUA_LIBRARY;
{$ELSE}
  lua_isnumber: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_isstring: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_iscfunction: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_isinteger: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_isuserdata: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_type: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_typename: function(L: lua_State; tp: Integer): MarshaledAString; cdecl;

  lua_tonumberx: function(L: lua_State; idx: Integer; isnum: PLongBool): lua_Number; cdecl;
  lua_tointegerx: function(L: lua_State; idx: Integer; isnum: PLongBool): lua_Integer; cdecl;
  lua_toboolean: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_tolstring: function(L: lua_State; idx: Integer; len: Psize_t): MarshaledAString; cdecl;
  lua_rawlen: function(L: lua_State; idx: Integer): size_t; cdecl;
  lua_tocfunction: function(L: lua_State; idx: Integer): lua_CFunction; cdecl;
  lua_touserdata: function(L: lua_State; idx: Integer): Pointer; cdecl;
  lua_tothread: function(L: lua_State; idx: Integer): lua_State; cdecl;
  lua_topointer: function(L: lua_State; idx: Integer): Pointer; cdecl;
{$ENDIF}

{*
** Comparison and arithmetic functions
*}
const
  LUA_OPADD  = 0; {* ORDER TM, ORDER OP *}
  LUA_OPSUB  = 1;
  LUA_OPMUL  = 2;
  LUA_OPMOD  = 3;
  LUA_OPPOW  = 4;
  LUA_OPDIV  = 5;
  LUA_OPIDIV = 6;
  LUA_OPBAND = 7;
  LUA_OPBOR  = 8;
  LUA_OPBXOR = 9;
  LUA_OPSHL  = 10;
  LUA_OPSHR  = 11;
  LUA_OPUNM  = 12;
  LUA_OPBNOT = 13;

{$IFDEF STATICLIBRARY}
type
  procedure lua_arith(L: lua_State; op: Integer); cdecl; external LUA_LIBRARY;
{$ELSE}
var
  lua_arith: procedure(L: lua_State; op: Integer); cdecl;
{$ENDIF}

const
  LUA_OPEQ  = 0;
  LUA_OPLT  = 1;
  LUA_OPLE  = 2;

{$IFDEF STATICLIBRARY}
type
  function lua_rawequal(L: lua_State; idx1: Integer; idx2: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_compare(L: lua_State; idx1: Integer; idx2: Integer; op: Integer): Integer; cdecl; external LUA_LIBRARY;
{$ELSE}
var
  lua_rawequal: function(L: lua_State; idx1: Integer; idx2: Integer): Integer; cdecl;
  lua_compare: function(L: lua_State; idx1: Integer; idx2: Integer; op: Integer): Integer; cdecl;
{$ENDIF}


{*
** push functions (C -> stack)
*}
{$IFDEF STATICLIBRARY}
  procedure lua_pushnil(L: lua_State); cdecl; external LUA_LIBRARY;
  procedure lua_pushnumber(L: lua_State; n: lua_Number); cdecl; external LUA_LIBRARY;
  procedure lua_pushinteger(L: lua_State; n: lua_Integer); cdecl; external LUA_LIBRARY;
  function lua_pushlstring(L: lua_State; s: MarshaledAString; len: size_t): MarshaledAString; cdecl; external LUA_LIBRARY;
  function lua_pushstring(L: lua_State; s: MarshaledAString): MarshaledAString; cdecl; external LUA_LIBRARY;
  function lua_pushvfstring(L: lua_State; fmt: MarshaledAString; argp: Pointer): MarshaledAString; cdecl; external LUA_LIBRARY;

  function lua_pushfstring(L: lua_State; fmt: MarshaledAString; args: array of const): MarshaledAString; cdecl; external LUA_LIBRARY;
  procedure lua_pushcclosure(L: lua_State; fn: lua_CFunction; n: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_pushboolean(L: lua_State; b: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_pushlightuserdata(L: lua_State; p: Pointer); cdecl; external LUA_LIBRARY;
  function lua_pushthread(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
{$ELSE}
  lua_pushnil: procedure(L: lua_State); cdecl;
  lua_pushnumber: procedure(L: lua_State; n: lua_Number); cdecl;
  lua_pushinteger: procedure(L: lua_State; n: lua_Integer); cdecl;
  lua_pushlstring: function(L: lua_State; s: MarshaledAString; len: size_t): MarshaledAString; cdecl;
  lua_pushstring: function(L: lua_State; s: MarshaledAString): MarshaledAString; cdecl;
  lua_pushvfstring: function(L: lua_State; fmt: MarshaledAString; argp: Pointer): MarshaledAString; cdecl;

  lua_pushfstring: function(L: lua_State; fmt: MarshaledAString; args: array of const): MarshaledAString; cdecl;
  lua_pushcclosure: procedure(L: lua_State; fn: lua_CFunction; n: Integer); cdecl;
  lua_pushboolean: procedure(L: lua_State; b: Integer); cdecl;
  lua_pushlightuserdata: procedure(L: lua_State; p: Pointer); cdecl;
  lua_pushthread: function(L: lua_State): Integer; cdecl;
{$ENDIF}


{*
** get functions (Lua -> stack)
*}
{$IFDEF STATICLIBRARY}
  function lua_getglobal(L: lua_State; const name: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function lua_gettable(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_getfield(L: lua_State; idx: Integer; k: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function lua_geti(L: lua_State; idx: Integer; n: lua_Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_rawget(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_rawgeti(L: lua_State; idx: Integer; n: lua_Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_rawgetp(L: lua_State; idx: Integer; p: Pointer): Integer; cdecl; external LUA_LIBRARY;

  procedure lua_createtable(L: lua_State; narr: Integer; nrec: Integer); cdecl; external LUA_LIBRARY;
  function lua_newuserdatauv(L: lua_State; sz: size_t): Pointer; cdecl; external LUA_LIBRARY;
  function lua_getmetatable(L: lua_State; objindex: Integer): Integer; cdecl; external LUA_LIBRARY;
  function lua_getiuservalue(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;
{$ELSE}
  lua_getglobal: function(L: lua_State; const name: MarshaledAString): Integer; cdecl;
  lua_gettable: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_getfield: function(L: lua_State; idx: Integer; k: MarshaledAString): Integer; cdecl;
  lua_geti: function(L: lua_State; idx: Integer; n: lua_Integer): Integer; cdecl;
  lua_rawget: function(L: lua_State; idx: Integer): Integer; cdecl;
  lua_rawgeti: function(L: lua_State; idx: Integer; n: lua_Integer): Integer; cdecl;
  lua_rawgetp: function(L: lua_State; idx: Integer; p: Pointer): Integer; cdecl;

  lua_createtable: procedure(L: lua_State; narr: Integer; nrec: Integer); cdecl;
  lua_newuserdatauv: function(L: lua_State; sz: size_t): Pointer; cdecl;
  lua_getmetatable: function(L: lua_State; objindex: Integer): Integer; cdecl;
  lua_getiuservalue: function(L: lua_State; idx: Integer): Integer; cdecl;
{$ENDIF}


{*
** set functions (stack -> Lua)
*}
{$IFDEF STATICLIBRARY}
  procedure lua_setglobal(L: lua_State; name: MarshaledAString); cdecl; external LUA_LIBRARY;
  procedure lua_settable(L: lua_State; idx: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_setfield(L: lua_State; idx: Integer; k: MarshaledAString); cdecl; external LUA_LIBRARY;
  procedure lua_seti(L: lua_State; idx: Integer; n: lua_Integer); cdecl; external LUA_LIBRARY;
  procedure lua_rawset(L: lua_State; idx: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_rawseti(L: lua_State; idx: Integer; n: lua_Integer); cdecl; external LUA_LIBRARY;
  procedure lua_rawsetp(L: lua_State; idx: Integer; p: Pointer); cdecl; external LUA_LIBRARY;
  function lua_setmetatable(L: lua_State; objindex: Integer): Integer; cdecl; external LUA_LIBRARY;
  procedure lua_setiuservalue(L: lua_State; idx: Integer); cdecl; external LUA_LIBRARY;
{$ELSE}
  lua_setglobal: procedure(L: lua_State; name: MarshaledAString); cdecl;
  lua_settable: procedure(L: lua_State; idx: Integer); cdecl;
  lua_setfield: procedure(L: lua_State; idx: Integer; k: MarshaledAString); cdecl;
  lua_seti: procedure(L: lua_State; idx: Integer; n: lua_Integer); cdecl;
  lua_rawset: procedure(L: lua_State; idx: Integer); cdecl;
  lua_rawseti: procedure(L: lua_State; idx: Integer; n: lua_Integer); cdecl;
  lua_rawsetp: procedure(L: lua_State; idx: Integer; p: Pointer); cdecl;
  lua_setmetatable: function(L: lua_State; objindex: Integer): Integer; cdecl;
  lua_setiuservalue: procedure(L: lua_State; idx: Integer); cdecl;
{$ENDIF}


{*
** 'load' and 'call' functions (load and run Lua code)
*}
{$IFDEF STATICLIBRARY}
  procedure lua_callk(L: lua_State; nargs: Integer; nresults: Integer; ctx: lua_KContext; k: lua_KFunction); cdecl; external LUA_LIBRARY;

  function lua_pcallk(L: lua_State; nargs: Integer; nresults: Integer; errfunc: Integer;
    ctx: lua_KContext; k: lua_KFunction): Integer; cdecl; external LUA_LIBRARY;

  function lua_load(L: lua_State; reader: lua_Reader; dt: Pointer; const chunkname: MarshaledAString;
    const mode: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;

  function lua_dump(L: lua_State; writer: lua_Writer; data: Pointer; strip: Integer): Integer; cdecl; external LUA_LIBRARY;
{$ELSE}
  lua_callk: procedure(L: lua_State; nargs: Integer; nresults: Integer; ctx: lua_KContext; k: lua_KFunction); cdecl;

  lua_pcallk: function(L: lua_State; nargs: Integer; nresults: Integer; errfunc: Integer;
    ctx: lua_KContext; k: lua_KFunction): Integer; cdecl;

  lua_load: function(L: lua_State; reader: lua_Reader; dt: Pointer; const chunkname: MarshaledAString;
    const mode: MarshaledAString): Integer; cdecl;

  lua_dump: function(L: lua_State; writer: lua_Writer; data: Pointer; strip: Integer): Integer; cdecl;
{$ENDIF}

 procedure lua_call(L: lua_State; nargs: Integer; nresults: Integer); inline;
 function lua_pcall(L: lua_State; nargs: Integer; nresults: Integer; errfunc: Integer): integer; inline;



{*
** coroutine functions
*}
{$IFDEF STATICLIBRARY}
  function lua_yieldk(L: lua_State; nresults: Integer; ctx: lua_KContext; k: lua_KFunction): Integer; cdecl; external LUA_LIBRARY;

  function lua_resume(L: lua_State; from: lua_State; narg: Integer): Integer; cdecl; external LUA_LIBRARY;

  function lua_status(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function lua_isyieldable(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
{$ELSE}
var
  lua_yieldk: function(L: lua_State; nresults: Integer; ctx: lua_KContext; k: lua_KFunction): Integer; cdecl;

  lua_resume: function(L: lua_State; from: lua_State; narg: Integer): Integer; cdecl;

  lua_status: function(L: lua_State): Integer; cdecl;
  lua_isyieldable: function(L: lua_State): Integer; cdecl;
{$ENDIF}

function lua_yield(L: lua_State; nresults: Integer): Integer; inline;


{*
** Warning-related functions
*}
{$IFDEF STATICLIBRARY}
  procedure lua_setwarnf(L: lua_State; f: lua_Warnfunction; ud: pointer); cdecl; external LUA_LIBRARY;
  procedure lua_warning(L: lua_State; msg: MarshaledAString; tocont: Integer); cdecl; external LUA_LIBRARY;
{$ELSE}
var
  lua_setwarnf: procedure(L: lua_State; f: lua_Warnfunction; ud: pointer); cdecl;
  lua_warning: procedure(L: lua_State; msg: MarshaledAString; tocont: Integer); cdecl;
{$ENDIF}

{*
** garbage-collection function and options
*}
const
  LUA_GCSTOP	     = 0;
  LUA_GCRESTART	   = 1;
  LUA_GCCOLLECT	   = 2;
  LUA_GCCOUNT	     = 3;
  LUA_GCCOUNTB	   = 4;
  LUA_GCSTEP	     = 5;
  LUA_GCSETPAUSE   = 6;
  LUA_GCSETSTEPMUL = 7;
  LUA_GCISRUNNING  = 9;
  LUA_GCGEN        = 10;
  LUA_GCINC        = 11;

{$IFDEF STATICLIBRARY}
type
  function lua_gc(L: lua_State; what: Integer; data: Integer): Integer; cdecl; external LUA_LIBRARY;
{$ELSE}
var
  lua_gc: function(L: lua_State; what: Integer; data: Integer): Integer; cdecl;
{$ENDIF}


{*
** miscellaneous functions
*}
{$IFDEF STATICLIBRARY}
  function lua_error(L: lua_State): Integer; cdecl; external LUA_LIBRARY;

  function lua_next(L: lua_State; idx: Integer): Integer; cdecl; external LUA_LIBRARY;

  procedure lua_concat(L: lua_State; n: Integer); cdecl; external LUA_LIBRARY;
  procedure lua_len(L: lua_State; idx: Integer); cdecl; external LUA_LIBRARY;

  function lua_stringtonumber(L: lua_State; const s: MarshaledAString): size_t; cdecl; external LUA_LIBRARY;

  function lua_getallocf(L: lua_State; ud: PPointer): lua_Alloc; cdecl; external LUA_LIBRARY;
  procedure lua_setallocf(L: lua_State; f: lua_Alloc; ud: Pointer); cdecl; external LUA_LIBRARY;
{$ELSE}
  lua_error: function(L: lua_State): Integer; cdecl;

  lua_next: function(L: lua_State; idx: Integer): Integer; cdecl;

  lua_concat: procedure(L: lua_State; n: Integer); cdecl;
  lua_len: procedure(L: lua_State; idx: Integer); cdecl;

  lua_stringtonumber: function(L: lua_State; const s: MarshaledAString): size_t; cdecl;

  lua_getallocf: function(L: lua_State; ud: PPointer): lua_Alloc; cdecl;
  lua_setallocf: procedure(L: lua_State; f: lua_Alloc; ud: Pointer); cdecl;
{$ENDIF}


{*
** ==============================================================
** some useful macros
** ==============================================================
*}
  function lua_getextraspace(L: lua_State): Pointer; inline;

  function lua_tonumber(L: lua_State; idx: Integer): lua_Number; inline;
  function lua_tointeger(L: lua_State; idx: Integer): lua_Integer; inline;

  procedure lua_pop(L: lua_State; n: Integer); inline;

  procedure lua_newtable(L: lua_state); inline;

  procedure lua_register(L: lua_State; const n: MarshaledAString; f: lua_CFunction); inline;

  procedure lua_pushcfunction(L: lua_State; f: lua_CFunction); inline;

  function lua_isfunction(L: lua_State; n: Integer): Boolean; inline;
  function lua_istable(L: lua_State; n: Integer): Boolean; inline;
  function lua_islightuserdata(L: lua_State; n: Integer): Boolean; inline;
  function lua_isnil(L: lua_State; n: Integer): Boolean; inline;
  function lua_isboolean(L: lua_State; n: Integer): Boolean; inline;
  function lua_isthread(L: lua_State; n: Integer): Boolean; inline;
  function lua_isnone(L: lua_State; n: Integer): Boolean; inline;
  function lua_isnoneornil(L: lua_State; n: Integer): Boolean; inline;

  procedure lua_pushliteral(L: lua_State; s: MarshaledAString); inline;

  procedure lua_pushglobaltable(L: lua_State); inline;

  function lua_tostring(L: lua_State; i: Integer): MarshaledAString;

  procedure lua_insert(L: lua_State; idx: Integer); inline;

  procedure lua_remove(L: lua_State; idx: Integer); inline;

  procedure lua_replace(L: lua_State; idx: Integer); inline;



{*
** ======================================================================
** Debug API
** =======================================================================
*}

{*
** Event codes
*}
const
  LUA_HOOKCALL     = 0;
  LUA_HOOKRET      = 1;
  LUA_HOOKLINE     = 2;
  LUA_HOOKCOUNT	   = 3;
  LUA_HOOKTAILCALL = 4;


{*
** Event masks
*}
  LUA_MASKCALL =	(1 SHL LUA_HOOKCALL);
  LUA_MASKRET  =  (1 SHL LUA_HOOKRET);
  LUA_MASKLINE =	(1 SHL LUA_HOOKLINE);
  LUA_MASKCOUNT = (1 SHL LUA_HOOKCOUNT);


type
  lua_Debug = record {* activation record *}
    event: Integer;
    name: MarshaledAString;     (* (n) *)
    namewhat: MarshaledAString; (* (n) `global', `local', `field', `method' *)
    what: MarshaledAString;     (* (S) `Lua', `C', `main', `tail'*)
    source: MarshaledAString;   (* (S) *)
    currentline: Integer;       (* (l) *)
    linedefined: Integer;       (* (S) *)
    lastlinedefined: Integer;   (* (S) *)
    nups: Byte;                 (* (u) number of upvalues *)
    nparams: Byte;              (* (u) number of parameters *)
    isvararg: ByteBool;         (* (u) *)
    istailcall: ByteBool;       (* (t) *)
    short_src: array[0..LUA_IDSIZE - 1] of Char; (* (S) *)
    (* private part *)
    i_ci: Pointer;             (* active function *)  // ptr to struct CallInfo
  end;
  Plua_Debug = ^lua_Debug;

{* Functions to be called by the debugger in specific events *}
  lua_Hook = procedure(L: lua_State; ar: Plua_Debug); cdecl;



{$IFDEF STATICLIBRARY}
  function lua_getstack(L: lua_State; level: Integer; ar: Plua_Debug): Integer; cdecl; external LUA_LIBRARY;
  function lua_getinfo(L: lua_State; const what: MarshaledAString; ar: Plua_Debug): Integer; cdecl; external LUA_LIBRARY;
  function lua_getlocal(L: lua_State; const ar: Plua_Debug; n: Integer): MarshaledAString; cdecl; external LUA_LIBRARY;
  function lua_setlocal(L: lua_State; const ar: Plua_Debug; n: Integer): MarshaledAString; cdecl; external LUA_LIBRARY;
  function lua_getupvalue(L: lua_State; funcindex, n: Integer): MarshaledAString; cdecl; external LUA_LIBRARY;
  function lua_setupvalue(L: lua_State; funcindex, n: Integer): MarshaledAString; cdecl; external LUA_LIBRARY;

  function lua_upvalueid(L: lua_State; fidx, n: Integer): Pointer; cdecl; external LUA_LIBRARY;
  procedure lua_upvaluejoin(L: lua_State; fix1, n1, fidx2, n2: Integer); cdecl; external LUA_LIBRARY;

  procedure lua_sethook(L: lua_State; func: lua_Hook; mask: Integer; count: Integer); cdecl; external LUA_LIBRARY;
  function lua_gethook(L: lua_State): lua_Hook; cdecl; external LUA_LIBRARY;
  function lua_gethookmask(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function lua_gethookcount(L: lua_State): Integer; cdecl; external LUA_LIBRARY;

  function lua_setcstacklimit(L: lua_State; limit: Cardinal): Integer; cdecl; external LUA_LIBRARY;
{$ELSE}
var
  lua_getstack: function(L: lua_State; level: Integer; ar: Plua_Debug): Integer; cdecl;
  lua_getinfo: function(L: lua_State; const what: MarshaledAString; ar: Plua_Debug): Integer; cdecl;
  lua_getlocal: function(L: lua_State; const ar: Plua_Debug; n: Integer): MarshaledAString; cdecl;
  lua_setlocal: function(L: lua_State; const ar: Plua_Debug; n: Integer): MarshaledAString; cdecl;
  lua_getupvalue: function(L: lua_State; funcindex, n: Integer): MarshaledAString; cdecl;
  lua_setupvalue: function(L: lua_State; funcindex, n: Integer): MarshaledAString; cdecl;

  lua_upvalueid: function(L: lua_State; fidx, n: Integer): Pointer; cdecl;
  lua_upvaluejoin: procedure(L: lua_State; fix1, n1, fidx2, n2: Integer); cdecl;

  lua_sethook: procedure(L: lua_State; func: lua_Hook; mask: Integer; count: Integer); cdecl;
  lua_gethook: function(L: lua_State): lua_Hook; cdecl;
  lua_gethookmask: function(L: lua_State): Integer; cdecl;
  lua_gethookcount: function(L: lua_State): Integer; cdecl;

  lua_setcstacklimit: function(L: lua_State; limit: Cardinal): Integer; cdecl;
{$ENDIF}



{* ====================================================================== *}


{******************************************************************************
* Copyright (C) 1994-2020 Lua.org, PUC-Rio.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************}

