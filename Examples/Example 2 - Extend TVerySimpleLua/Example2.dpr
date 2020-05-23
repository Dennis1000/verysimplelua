program Example2;
{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas',
  MyLua in 'MyLua.pas';

var
  Lua: TMyLua;

const
{$IFDEF Win64}
  PLATFORM = 'Win64';
{$ELSE}
  PLATFORM = 'Win32';
{$ENDIF}

begin
  try
    // Example 2 - Extend Lua with own class
    Lua := TMyLua.Create;
    Lua.LibraryPath := '..\..\DLL\' + PLATFORM + '\' + LUA_LIBRARY;
    Lua.DoFile('example2.lua');
    Lua.Free;
    Readln;

  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;
end.
