{/*
** $Id: lualib.h $
** Lua standard libraries
** See Copyright Notice in lua.h
*}

const
{* version suffix for environment variable names *}
  LUA_VERSUFFIX  = '_' + LUA_VERSION_MAJOR + '_' + LUA_VERSION_MINOR;

  LUA_COLIBNAME   = 'coroutine';
  LUA_TABLIBNAME  = 'table';
  LUA_IOLIBNAME   = 'io';
  LUA_OSLIBNAME	  = 'os';
  LUA_STRLIBNAME  = 'string';
  LUA_UTF8LIBNAME = 'utf8';
  LUA_MATHLIBNAME = 'math';
  LUA_DBLIBNAME   = 'debug';
  LUA_LOADLIBNAME = 'package';


{$IFDEF STATICLIBRARY}
  function luaopen_base(L: lua_State): Integer; cdecl; external LUA_LIBRARY;

  function luaopen_coroutine(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_table(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_io(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_os(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_string(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_utf8(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_math(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_debug(L: lua_State): Integer; cdecl; external LUA_LIBRARY;
  function luaopen_package(L: lua_State): Integer; cdecl; external LUA_LIBRARY;

 {* open all previous libraries *}
  procedure luaL_openlibs(L: lua_State); cdecl; external LUA_LIBRARY;
{$ELSE}
var
  luaopen_base: function(L: lua_State): Integer; cdecl;

  luaopen_coroutine: function(L: lua_State): Integer; cdecl;
  luaopen_table: function(L: lua_State): Integer; cdecl;
  luaopen_io: function(L: lua_State): Integer; cdecl;
  luaopen_os: function(L: lua_State): Integer; cdecl;
  luaopen_string: function(L: lua_State): Integer; cdecl;
  luaopen_utf8: function(L: lua_State): Integer; cdecl;
  luaopen_math: function(L: lua_State): Integer; cdecl;
  luaopen_debug: function(L: lua_State): Integer; cdecl;
  luaopen_package: function(L: lua_State): Integer; cdecl;

 {* open all previous libraries *}
  luaL_openlibs: procedure(L: lua_State); cdecl;
{$ENDIF}
