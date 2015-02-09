program LuaTest;
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Lua in '..\Lib\Lua.pas',
  LuaLib in '..\Lib\LuaLib.pas',
  MyLua in 'MyLua.pas';

var
  MyLua: TLua;

begin
  try
    MyLua := TMyLua.Create;
    MyLua.DoFile('Helloworld.lua');
    MyLua.Free;
    readln;

  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;
end.
