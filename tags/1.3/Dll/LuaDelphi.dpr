library LuaDelphi;

uses
  SysUtils,
  Classes,
  LuaLib in '..\Lib\LuaLib.pas',
  Lua in '..\Lib\Lua.pas',
  MyLua in '..\Example\MyLua.pas';

{$R *.res}

var
  MyLua: TMyLua;

function libinit (L: Lua_State): Integer; cdecl;export;
begin
  MyLua := TMyLua.Create(false);  // we don't want to register the functions
  MyLua.LuaInstance := L;         // update LuaInstance
  MyLua.AutoRegisterFunctions(MyLua);         // now register the functions
  result := 1;
end;

exports
  libinit;

begin
end.
