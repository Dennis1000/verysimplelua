unit MyLua;

{$M+}

interface

uses
  VerySimple.Lua, System.Diagnostics;

type
  // MyLua example class
  TMyLua = class(TVerySimpleLua)
  public
    MilliSeconds: Int64;
    Sw: TStopWatch;
    Lastbench: Int64;
  published
    constructor Create; override;
    function Start(LuaState: TLuaState): Integer;
    function Finished(LuaState: TLuaState): Integer;
    function HelloWorld(LuaState: TLuaState): Integer;
    class function HelloWorld2(LuaState: TLuaState): Integer;
    class function HelloWorld3(LuaState: TLuaState): Integer; cdecl; static;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

constructor TMyLua.Create;
begin
  inherited;

  {$IF defined(WIN32)}
  LibraryPath :=  '..\..\DLL\WIN32\' + LUA_LIBRARY;
  {$ELSEIF defined(WIN64)}
  LibraryPath :=  '..\..\DLL\WIN64\' + LUA_LIBRARY;
  {$ENDIF}

  Sw := TStopwatch.Create;
end;

function TMyLua.HelloWorld(LuaState: TLuaState): Integer;
begin
  lua_pushinteger(LuaState, Lua_ToInteger(LuaState, 1) * 2);
  Result := 1;
end;

class function TMyLua.HelloWorld2(LuaState: TLuaState): Integer;
begin
  lua_pushinteger(LuaState, Lua_ToInteger(LuaState, 1) * 2);
  Result := 1;
end;

class function TMyLua.HelloWorld3(LuaState: TLuaState): Integer;
begin
  lua_pushinteger(LuaState, Lua_ToInteger(LuaState, 1) * 2);
  Result := 1;
end;


function TMyLua.Start(LuaState: TLuaState): Integer;
begin
  MilliSeconds := Lua_ToInteger(LuaState, 1) * 1000;
  Result := 0;
  Lastbench := 0;
  Sw.Reset;
  Sw.Start;
end;

function TMyLua.Finished(LuaState: TLuaState): Integer;
var
  ElapsedSeconds: Int64;
begin
  ElapsedSeconds := Sw.ElapsedMilliseconds div 1000;

  if ElapsedSeconds > Lastbench then
  begin
    Lastbench := ElapsedSeconds;
    OnPrint('...');
  end;

  if Sw.ElapsedMilliseconds > MilliSeconds then
    lua_pushboolean(LuaState, 1)
  else
    lua_pushboolean(LuaState, 0);
  Result := 1;
end;

end.
