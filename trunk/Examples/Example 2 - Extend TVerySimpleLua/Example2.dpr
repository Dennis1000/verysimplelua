program Example2;
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas',
  VerySimple.Lua.Lib in '..\..\Source\VerySimple.Lua.Lib.pas',
  MyLua in 'MyLua.pas';

var
  Lua: TMyLua;

begin
  try
    (* Example 2 - Extend Lua with own class *)
    Lua := TMyLua.Create('..\..\DLL\Win32\');
    Lua.DoFile('example2.lua');
    Lua.Free;
    readln;

  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;
end.
