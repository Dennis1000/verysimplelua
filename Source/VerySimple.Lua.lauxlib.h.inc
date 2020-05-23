{*
** $Id: lauxlib.h $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*}


{* global table *}
const
  LUA_GNAME	= '_G';

{*
@@ LUAL_BUFFERSIZE is the buffer size used by the lauxlib buffer system.
** CHANGE it if it uses too much C-stack space.
*}
  LUAL_BUFFERSIZE = Integer($80 * sizeof(Pointer) * sizeof(NativeInt));


type
   luaL_Buffer = record
     b: MarshaledAString; {* buffer address *}
     size: size_t;  {* buffer size *}
     n: size_t;  {* number of characters in buffer *}
     L: lua_State;
     initb: array[0..LUAL_BUFFERSIZE - 1] of Byte;  {* initial buffer *}
   end;
   Plual_Buffer = ^lual_Buffer;


{* extra error code for 'luaL_loadfilex' *}
const
  LUA_ERRFILE = (LUA_ERRERR+1);


{* key, in the registry, for table of loaded modules *}
  LUA_LOADED_TABLE = '_LOADED';


{* key, in the registry, for table of preloaded loaders *}
  LUA_PRELOAD_TABLE	= '_PRELOAD';


type
  luaL_Reg = record
    name: MarshaledAString;
    func: lua_CFunction;
  end;
  PluaL_Reg = ^luaL_Reg;

   luaL_Stream = record
     f: Pointer; {* stream (NULL for incompletely created streams) *}
     closef: lua_CFunction; {* to close stream (NULL for closed streams) *}
   end;

{* pre-defined references *}
const
  LUA_NOREF  = -2;
  LUA_REFNIL = -1;


{*
** A file handle is a userdata with metatable 'LUA_FILEHANDLE' and
** initial structure 'luaL_Stream' (it may contain other fields
** after that initial structure).
*}

  LUA_FILEHANDLE = 'FILE*';


const
  LUAL_NUMSIZES = sizeof(NativeInt)*16 + sizeof(Double);


{$IFDEF STATICLIBRARY}
  procedure luaL_checkversion_(L: lua_State; ver: lua_Number; sz: size_t); cdecl; external LUA_LIBRARY;
  function luaL_getmetafield(L: lua_State; obj: Integer; e: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function luaL_callmeta(L: lua_State; obj: Integer; e: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function luaL_tolstring(L: lua_State; idx: Integer; len: Psize_t): MarshaledAString; cdecl; external LUA_LIBRARY;
  function luaL_argerror(L: lua_State; arg: Integer; extramsg: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function luaL_checklstring(L: lua_State; arg: Integer; l_: Psize_t): MarshaledAString; cdecl; external LUA_LIBRARY;
  function luaL_optlstring(L: lua_State; arg: Integer; const def: MarshaledAString; l_: Psize_t): MarshaledAString; cdecl; external LUA_LIBRARY;
  function luaL_checknumber(L: lua_State; arg: Integer): lua_Number; cdecl; external LUA_LIBRARY;
  function luaL_optnumber(L: lua_State; arg: Integer; def: lua_Number): lua_Number; cdecl; external LUA_LIBRARY;
  function luaL_checkinteger(L: lua_State; arg: Integer): lua_Integer; cdecl; external LUA_LIBRARY;
  function luaL_optinteger(L: lua_State; arg: Integer; def: lua_Integer): lua_Integer; cdecl; external LUA_LIBRARY;

  procedure luaL_checkstack(L: lua_State; sz: Integer; const msg: MarshaledAString); cdecl; external LUA_LIBRARY;
  procedure luaL_checktype(L: lua_State; arg: Integer; t: Integer); cdecl; external LUA_LIBRARY;
  procedure luaL_checkany(L: lua_State; arg: Integer); cdecl; external LUA_LIBRARY;

  function luaL_newmetatable(L: lua_State; const tname: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  procedure luaL_setmetatable(L: lua_State; const tname: MarshaledAString); cdecl; external LUA_LIBRARY;
  function luaL_testudata(L: lua_State; ud: Integer; const tname: MarshaledAString): Pointer; cdecl; external LUA_LIBRARY;
  function luaL_checkudata(L: lua_State; ud: Integer; const tname: MarshaledAString): Pointer; cdecl; external LUA_LIBRARY;

  procedure luaL_where(L: lua_State; lvl: Integer); cdecl; external LUA_LIBRARY;
  function luaL_error(L: lua_State; fmt: MarshaledAString; args: array of const): Integer; cdecl; external LUA_LIBRARY;

  function luaL_checkoption(L: lua_State; arg: Integer; const def: MarshaledAString; const lst: PMarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function luaL_fileresult(L: lua_State; stat: Integer; fname: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function luaL_execresult(L: lua_State; stat: Integer): Integer; cdecl; external LUA_LIBRARY;


  function luaL_ref(L: lua_State; t: Integer): Integer; cdecl; external LUA_LIBRARY;
  procedure luaL_unref(L: lua_State; t: Integer; ref: Integer); cdecl; external LUA_LIBRARY;
  function luaL_loadfilex(L: lua_State; const filename: MarshaledAString; const mode: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;

  function luaL_loadbufferx(L: lua_State; const buff: MarshaledAString; sz: size_t;
                                   const name: MarshaledAString; const mode: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;
  function luaL_loadstring(L: lua_State; const s: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;

  function luaL_newstate(): lua_State; cdecl; external LUA_LIBRARY;
  function luaL_len(L: lua_State; idx: Integer): lua_Integer; cdecl; external LUA_LIBRARY;

  function luaL_gsub(L: lua_State; const s: MarshaledAString; const p: MarshaledAString; const r: MarshaledAString): MarshaledAString; cdecl; external LUA_LIBRARY;
  procedure luaL_setfuncs(L: lua_State; const l_: PluaL_Reg; nup: Integer); cdecl; external LUA_LIBRARY;

  function luaL_getsubtable(L: lua_State; idx: Integer; const fname: MarshaledAString): Integer; cdecl; external LUA_LIBRARY;

  procedure luaL_traceback(L: lua_State; L1: lua_State; const msg: MarshaledAString; level: Integer); cdecl; external LUA_LIBRARY;

  procedure luaL_requiref(L: lua_State; const modname: MarshaledAString; openf: lua_CFunction; glb: Integer); cdecl; external LUA_LIBRARY;
{$ELSE}
var
  luaL_checkversion_: procedure(L: lua_State; ver: lua_Number; sz: size_t); cdecl;
  luaL_getmetafield: function(L: lua_State; obj: Integer; e: MarshaledAString): Integer; cdecl;
  luaL_callmeta: function(L: lua_State; obj: Integer; e: MarshaledAString): Integer; cdecl;
  luaL_tolstring: function(L: lua_State; idx: Integer; len: Psize_t): MarshaledAString; cdecl;
  luaL_argerror: function(L: lua_State; arg: Integer; extramsg: MarshaledAString): Integer; cdecl;
  luaL_checklstring: function(L: lua_State; arg: Integer; l_: Psize_t): MarshaledAString; cdecl;
  luaL_optlstring: function(L: lua_State; arg: Integer; const def: MarshaledAString; l_: Psize_t): MarshaledAString; cdecl;
  luaL_checknumber: function(L: lua_State; arg: Integer): lua_Number; cdecl;
  luaL_optnumber: function(L: lua_State; arg: Integer; def: lua_Number): lua_Number; cdecl;
  luaL_checkinteger: function(L: lua_State; arg: Integer): lua_Integer; cdecl;
  luaL_optinteger: function(L: lua_State; arg: Integer; def: lua_Integer): lua_Integer; cdecl;

  luaL_checkstack: procedure(L: lua_State; sz: Integer; const msg: MarshaledAString); cdecl;
  luaL_checktype: procedure(L: lua_State; arg: Integer; t: Integer); cdecl;
  luaL_checkany: procedure(L: lua_State; arg: Integer); cdecl;

  luaL_newmetatable: function(L: lua_State; const tname: MarshaledAString): Integer; cdecl;
  luaL_setmetatable: procedure(L: lua_State; const tname: MarshaledAString); cdecl;
  luaL_testudata: procedure(L: lua_State; ud: Integer; const tname: MarshaledAString); cdecl;
  luaL_checkudata: function(L: lua_State; ud: Integer; const tname: MarshaledAString): Pointer; cdecl;

  luaL_where: procedure(L: lua_State; lvl: Integer); cdecl;
  luaL_error: function(L: lua_State; fmt: MarshaledAString; args: array of const): Integer; cdecl;

  luaL_checkoption: function(L: lua_State; arg: Integer; const def: MarshaledAString; const lst: PMarshaledAString): Integer; cdecl;
  luaL_fileresult: function(L: lua_State; stat: Integer; fname: MarshaledAString): Integer; cdecl;
  luaL_execresult: function(L: lua_State; stat: Integer): Integer; cdecl;


  luaL_ref: function(L: lua_State; t: Integer): Integer; cdecl;
  luaL_unref: procedure(L: lua_State; t: Integer; ref: Integer); cdecl;
  luaL_loadfilex: function(L: lua_State; const filename: MarshaledAString; const mode: MarshaledAString): Integer; cdecl;

  luaL_loadbufferx: function(L: lua_State; const buff: MarshaledAString; sz: size_t;
                                   const name: MarshaledAString; const mode: MarshaledAString): Integer; cdecl;
  luaL_loadstring: function(L: lua_State; const s: MarshaledAString): Integer; cdecl;

  luaL_newstate: function(): lua_State; cdecl;
  luaL_len: function(L: lua_State; idx: Integer): lua_Integer; cdecl;

  luaL_gsub: function(L: lua_State; const s: MarshaledAString; const p: MarshaledAString; const r: MarshaledAString): MarshaledAString; cdecl;
  luaL_setfuncs: procedure(L: lua_State; const l_: PluaL_Reg; nup: Integer); cdecl;

  luaL_getsubtable: function(L: lua_State; idx: Integer; const fname: MarshaledAString): Integer; cdecl;

  luaL_traceback: procedure(L: lua_State; L1: lua_State; const msg: MarshaledAString; level: Integer); cdecl;

  luaL_requiref: procedure(L: lua_State; const modname: MarshaledAString; openf: lua_CFunction; glb: Integer); cdecl;
{$ENDIF}

procedure luaL_checkversion(L: lua_State); inline;
function lual_loadfile(L: lua_State; const filename: MarshaledAString): Integer; inline;


{*
** ======================================================
** Generic Buffer manipulation
** ======================================================
*}
{$IFDEF STATICLIBRARY}
  procedure luaL_buffinit(L: lua_State; B: PluaL_Buffer); cdecl; external LUA_LIBRARY;
  function luaL_prepbuffsize(B: Plual_buffer; sz: size_t): Pointer; cdecl; external LUA_LIBRARY;
  procedure luaL_addlstring(B: Plual_buffer; const s: MarshaledAString; l: size_t); cdecl; external LUA_LIBRARY;
  procedure luaL_addstring(B: Plual_buffer; const s: MarshaledAString); cdecl; external LUA_LIBRARY;
  procedure luaL_addvalue(B: Plual_buffer); cdecl; external LUA_LIBRARY;
  procedure luaL_pushresult(B: Plual_buffer); cdecl; external LUA_LIBRARY;
  procedure luaL_pushresultsize(B: Plual_buffer; sz: size_t); cdecl; external LUA_LIBRARY;
  function luaL_buffinitsize(L: lua_State; B: Plual_buffer; sz: size_t): Pointer; cdecl; external LUA_LIBRARY;
{$ELSE}
var
  luaL_buffinit: procedure(L: lua_State; B: PluaL_Buffer); cdecl;
  luaL_prepbuffsize: function(B: Plual_buffer; sz: size_t): Pointer; cdecl;
  luaL_addlstring: procedure(B: Plual_buffer; const s: MarshaledAString; l: size_t); cdecl;
  luaL_addstring: procedure(B: Plual_buffer; const s: MarshaledAString); cdecl;
  luaL_addvalue: procedure(B: Plual_buffer); cdecl;
  luaL_pushresult: procedure(B: Plual_buffer); cdecl;
  luaL_pushresultsize: procedure(B: Plual_buffer; sz: size_t); cdecl;
  luaL_buffinitsize: function(L: lua_State; B: Plual_buffer; sz: size_t): Pointer; cdecl;
{$ENDIF}

function luaL_prepbuffer(B: Plual_buffer): MarshaledAString; inline;

{*
** ===============================================================
** some useful lauxlib macros
** ===============================================================
*}

  procedure luaL_newlibtable(L: lua_State; lr: array of luaL_Reg); overload;
  procedure luaL_newlibtable(L: lua_State; lr: PluaL_Reg); overload;
  procedure luaL_newlib(L: lua_State; lr: array of luaL_Reg); overload;
  procedure luaL_newlib(L: lua_State; lr: PluaL_Reg); overload;
  procedure luaL_argcheck(L: lua_State; cond: Boolean; arg: Integer; extramsg: MarshaledAString);
  function luaL_checkstring(L: lua_State; n: Integer): MarshaledAString;
  function luaL_optstring(L: lua_State; n: Integer; d: MarshaledAString): MarshaledAString;
  function luaL_typename(L: lua_State; i: Integer): MarshaledAString;
  function luaL_dofile(L: lua_State; const fn: MarshaledAString): Integer;
  function luaL_dostring(L: lua_State; const s: MarshaledAString): Integer;
  procedure luaL_getmetatable(L: lua_State; n: MarshaledAString);
  function luaL_loadbuffer(L: lua_State; const s: MarshaledAString; sz: size_t; const n: MarshaledAString): Integer;
{

#define luaL_addchar(B,c) \
  ((void)((B)->n < (B)->size || luaL_prepbuffsize((B), 1)), \
   ((B)->b[(B)->n++] = (c)))

procedure luaL_addsize(B: PluaL_Buffer; s: MarshaledAString);

#define B,s)	((B)->n += (s))}



