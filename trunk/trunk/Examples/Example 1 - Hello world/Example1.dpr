program Example1;
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas',
  VerySimple.Lua.Lib in '..\..\Source\VerySimple.Lua.Lib.pas';

var
  Lua: TVerySimpleLua;

begin
  try
    (* Example 1 - Simple Lua Script Execution *)
    Lua := TVerySimpleLua.Create;
    Lua.LibraryPath := '..\..\DLL\Win32\' + LUA_LIBRARY;
    Lua.DoFile('example1.lua');
    Lua.Free;
    readln;

  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;
end.
