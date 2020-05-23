{*
** $Id: luaconf.h $
** Configuration file for Lua
** See Copyright Notice in lua.h
*}

{*
** ====================================================================
** System Configuration: macros to adapt (if needed) Lua to some
** particular platform, for instance restricting it to C89.
** =====================================================================
*}

// VerySimple.Lua supports 32-bit number and integer types, just set the
// LUA_32BITS definition (see below). By default Lua uses 64-bit
// for both number (Double) and integer (Int64) data types, but depending
// on the targeted platform there could even be a mixture of 32 and 64-bits.
// In that case you need to define the lua_Number, lua_Integer and lua_Unsigned
// data types prior including the VerySimple.Lua unit.
//
// To determine the Lua data size you could run this Lua code (5.4.0 only)
//
// local chunk = string.dump(function() end)
// print("lua_Integer size(byte)", chunk:byte(14))
// print("lua_Number size(byte)", chunk:byte(15))

{*
@@ LUA_32BITS enables Lua with 32-bit integers and 32-bit floats.
*}
//{$DEFINE LUA_32BITS}


type
  // Pointer size depends always on the Delphi selected platform and to
  // comply with the Lua source code "NativeInt" is used here instead of
  // the more common "Pointer" data type.
  ptrdiff_t = NativeInt;

{* type for continuation-function contexts *}
  lua_KContext = ptrdiff_t;


{$IF defined(LUA_32BITS)}
{*
** 32-bit integers and 'float'
*}
{* type of numbers in Lua *}
  lua_Number = Single; // 32-bit

{* type for integer functions *}
  lua_Integer = Integer; // 32-bit

{* unsigned integer type *}
  lua_Unsigned = Cardinal; // 32-bit
{$ENDIF}

{$IF not declared(lua_Number)}
{* type of numbers in Lua *}
  lua_Number = Double; // 64-bit
{$ENDIF}

{$IF not declared(lua_Integer)}
{* type for integer functions *}
  lua_Integer = Int64; // 64-bit
{$ENDIF}

{$IF not declared(lua_Unsigned)}
{* unsigned integer type *}
   lua_Unsigned = UInt64; // 64-bit
{$ENDIF}



{*
@@ LUA_EXTRASPACE defines the size of a raw memory area associated with
** a Lua state with very fast access.
** CHANGE it if you need a different size.
*}
const
  LUA_EXTRASPACE = Sizeof(Pointer);


{*
@@ LUA_IDSIZE gives the maximum size for the description of the source
@@ of a function in debug information.
** CHANGE it if you want a different size.
*}
  LUA_IDSIZE = 60;

{*
** LUAI_MAXSTACK limits the size of the Lua stack.
** CHANGE it if you need a different limit. This limit is arbitrary;
** its only purpose is to stop Lua from consuming unlimited stack
** space (and to reserve some numbers for pseudo-indices).
** (It must fit into max(size_t)/32.)
*}
  LUAI_MAXSTACK	= 1000000;

{*
@@ LUAI_MAXCSTACK defines the maximum depth for nested calls and
** also limits the maximum depth of other recursive algorithms in
** the implementation, such as syntactic analysis. A value too
** large may allow the interpreter to crash (C-stack overflow).
** The default value seems ok for regular machines, but may be
** too high for restricted hardware.
** The test file 'cstack.lua' may help finding a good limit.
** (It will crash with a limit too high.)
*}
  LUAI_MAXCSTACK = 2000;




