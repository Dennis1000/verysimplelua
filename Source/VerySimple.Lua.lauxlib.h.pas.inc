procedure luaL_checkversion(L: lua_State); inline;
begin
  luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES);
end;


function lual_loadfile(L: lua_State; const filename: MarshaledAString): Integer; inline;
begin
  Result := luaL_loadfilex(L, filename, NIL);
end;


{*
** ======================================================
** Generic Buffer manipulation
** ======================================================
*}

function luaL_prepbuffer(B: Plual_buffer): MarshaledAString; inline;
begin
  Result := luaL_prepbuffsize(B, LUAL_BUFFERSIZE);
end;


{/*
** ===============================================================
** some useful macros
** ===============================================================
*}

procedure luaL_newlibtable(L: lua_State; lr: array of luaL_Reg); overload;
begin
  lua_createtable(L, 0, High(lr));
end;

procedure luaL_newlibtable(L: lua_State; lr: PluaL_Reg); overload;
var
  n: Integer;
begin
  n := 0;
  while lr^.name <> nil do
  begin
    inc(n);
    inc(lr);
  end;
  lua_createtable(L, 0, n);
end;

procedure luaL_newlib(L: lua_State; lr: array of luaL_Reg); overload;
begin
  luaL_newlibtable(L, lr);
  luaL_setfuncs(L, @lr, 0);
end;

procedure luaL_newlib(L: lua_State; lr: PluaL_Reg); overload;
begin
  luaL_newlibtable(L, lr);
  luaL_setfuncs(L, lr, 0);
end;

procedure luaL_argcheck(L: lua_State; cond: Boolean; arg: Integer; extramsg: MarshaledAString);
begin
  if not cond then
    luaL_argerror(L, arg, extramsg);
end;


function luaL_checkstring(L: lua_State; n: Integer): MarshaledAString;
begin
  Result := luaL_checklstring(L, n, nil);
end;

function luaL_optstring(L: lua_State; n: Integer; d: MarshaledAString): MarshaledAString;
begin
  Result := luaL_optlstring(L, n, d, nil);
end;

function luaL_typename(L: lua_State; i: Integer): MarshaledAString;
begin
  Result := lua_typename(L, lua_type(L, i));
end;

function luaL_dofile(L: lua_State; const fn: MarshaledAString): Integer;
begin
  Result := luaL_loadfile(L, fn);
  if Result = 0 then
    Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;


function luaL_dostring(L: lua_State; const s: MarshaledAString): Integer;
begin
   Result := luaL_loadstring(L, s);
   if Result = 0 then
      Result := lua_pcall(L, 0, LUA_MULTRET, 0);
end;

procedure luaL_getmetatable(L: lua_State; n: MarshaledAString);
begin
   lua_getfield(L, LUA_REGISTRYINDEX, n);
end;

function luaL_loadbuffer(L: lua_State; const s: MarshaledAString; sz: size_t; const n: MarshaledAString): Integer;
begin
  Result := luaL_loadbufferx(L, s, sz, n, NIL);
end;

