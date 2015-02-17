unit MyLua;

{$M+}

interface

uses
  VerySimple.Lua, VerySimple.Lua.Lib, System.Diagnostics;

type
  // MyLua example class
  TMyLua = class(TVerySimpleLua)
  public
    MilliSeconds: Int64;
    Sw: TStopWatch;
    lastbench: Int64;
  published
    constructor Create; override;
    function Start(LuaState: lua_State): Integer;
    function Finished(LuaState: lua_State): Integer;
    function HelloWorld(LuaState: lua_State): Integer;
    class function HelloWorld2(LuaState: lua_State): Integer;
    class function HelloWorld3(LuaState: lua_State): Integer; cdecl; static;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

constructor TMyLua.Create;
begin
  inherited;

  {$IF defined(WIN32)}
  LibraryPath :=  '..\..\..\..\DLL\WIN32\' + LUA_LIBRARY;
  FilePath := '..\..\';

  {$ELSEIF defined(WIN64)}
  LibraryPath :=  '..\..\..\..\DLL\WIN64\' + LUA_LIBRARY;
  FilePath := '..\..\';
  {$ENDIF}

  Sw := TStopwatch.Create;
end;

function TMyLua.HelloWorld(LuaState: lua_State): Integer;
begin
  lua_pushinteger(LuaState, Lua_ToInteger(LuaState, 1) * 2);
  Result := 1;
end;

class function TMyLua.HelloWorld2(LuaState: lua_State): Integer;
begin
  lua_pushinteger(LuaState, Lua_ToInteger(LuaState, 1) * 2);
  Result := 1;
end;

class function TMyLua.HelloWorld3(LuaState: lua_State): Integer;
begin
  lua_pushinteger(LuaState, Lua_ToInteger(LuaState, 1) * 2);
  Result := 1;
end;


function TMyLua.Start(LuaState: lua_State): Integer;
begin
  MilliSeconds := Lua_ToInteger(LuaState, 1) * 1000;
  Result := 0;
  lastbench := 0;
  Sw.Reset;
  Sw.Start;
end;

function TMyLua.Finished(LuaState: lua_State): Integer;
var
  ElapsedSeconds: Int64;
begin
  ElapsedSeconds := Sw.ElapsedMilliseconds div 1000;

  if ElapsedSeconds > lastbench then
  begin
    lastbench := ElapsedSeconds;
    OnPrint('...');
  end;

  if Sw.ElapsedMilliseconds > MilliSeconds then
    lua_pushboolean(LuaState, 1)
  else
    lua_pushboolean(LuaState, 0);
  Result := 1;
end;

end.
