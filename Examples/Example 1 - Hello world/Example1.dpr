program Example1;
{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas';

var
  Lua: TVerySimpleLua;

const
{$IFDEF Win64}
  PLATFORM = 'Win64';
{$ELSE}
  PLATFORM = 'Win32';
{$ENDIF}

begin
  try
    // Example 1 - Simple Lua script execution
    Lua := TVerySimpleLua.Create;
    Lua.LibraryPath := '..\..\DLL\' + PLATFORM + '\' + LUA_LIBRARY;
    Lua.DoFile('example1.lua');
    Lua.Free;
    Readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
