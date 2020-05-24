program Example1;
{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas';

var
  Lua: TVerySimpleLua;

const
{$IF defined(WIN32)}
  LIBRARYPATH = '..\..\DLL\Win32\' + LUA_LIBRARY;
{$ELSEIF defined(WIN64)}
  LIBRARYPATH = '..\..\DLL\Win64\' + LUA_LIBRARY;
{$IFEND}

begin
  try
    // Example 1 - Simple Lua script execution
    Lua := TVerySimpleLua.Create;
    Lua.LibraryPath := LIBRARYPATH;
    Lua.DoFile('example1.lua');
    Lua.Free;
    Readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
