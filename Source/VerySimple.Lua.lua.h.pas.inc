{*
** Pseudo-indices
*}
function lua_upvalueindex(i: Integer): Integer; inline;
begin
  Result := LUA_REGISTRYINDEX - i;
end;

{*
** ==============================================================
** some useful macros
** ===============================================================
*}

function lua_getextraspace(L: lua_State): Pointer; inline;
begin
  Result := Ptr(NativeInt(L) - LUA_EXTRASPACE);
end;

function lua_tonumber(L: lua_State; idx: Integer): lua_Number; inline;
begin
  Result := lua_tonumberx(L, idx, NIL);
end;

function lua_tointeger(L: lua_State; idx: Integer): lua_Integer; inline;
begin
  Result := lua_tointegerx(L, idx, NIL);
end;

procedure lua_pop(L: lua_State; n: Integer); inline;
begin
  lua_settop(L, -(n)-1);
end;

procedure lua_newtable(L: lua_state); inline;
begin
  lua_createtable(L, 0, 0);
end;

procedure lua_register(L: lua_State; const n: MarshaledAString; f: lua_CFunction);
begin
  lua_pushcfunction(L, f);
  lua_setglobal(L, n);
end;

procedure lua_pushcfunction(L: lua_State; f: lua_CFunction);
begin
  lua_pushcclosure(L, f, 0);
end;

function lua_isfunction(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TFUNCTION);
end;

function lua_istable(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TTABLE);
end;

function lua_islightuserdata(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TLIGHTUSERDATA);
end;

function lua_isnil(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TNIL);
end;

function lua_isboolean(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TBOOLEAN);
end;

function lua_isthread(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TTHREAD);
end;

function lua_isnone(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) = LUA_TNONE);
end;

function lua_isnoneornil(L: lua_State; n: Integer): Boolean;
begin
  Result := (lua_type(L, n) <= 0);
end;

procedure lua_pushliteral(L: lua_State; s: MarshaledAString);
begin
  lua_pushlstring(L, s, Length(s));
end;

procedure lua_pushglobaltable(L: lua_State);
begin
  lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
end;

function lua_tostring(L: lua_State; i: Integer): MarshaledAString;
begin
  Result := lua_tolstring(L, i, NIL);
end;

procedure lua_insert(L: lua_State; idx: Integer);
begin
  lua_rotate(L, idx, 1);
end;

procedure lua_remove(L: lua_State; idx: Integer);
begin
  lua_rotate(L, idx, -1);
  lua_pop(L, 1);
end;

procedure lua_replace(L: lua_State; idx: Integer);
begin
  lua_copy(L, -1, idx);
  lua_pop(L, 1);
end;


{/*
** 'load' and 'call' functions (load and run Lua code)
*}
procedure lua_call(L: lua_State; nargs: Integer; nresults: Integer); inline;
begin
  lua_callk(L, nargs, nresults, 0, NIL);
end;

function lua_pcall(L: lua_State; nargs: Integer; nresults: Integer; errfunc: Integer): Integer; inline;
begin
  Result := lua_pcallk(L, nargs, nresults, errfunc, 0, NIL);
end;

{*
** coroutine functions
*}
function lua_yield(L: lua_State; nresults: Integer): Integer; inline;
begin
  Result := lua_yieldk(L, nresults, 0, NIL);
end;

