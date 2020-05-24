program Example1;
{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes,
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas';

var
  Lua: TVerySimpleLua;

// Add deployment files with Project | Deployment | Linux 64-bit platform
// Add these files: "DLL\Linux\liblua5.4.0.so" and "example7.lua"

const
{$IF defined(LINUX)}
  LIBRARYPATH = LUA_LIBRARY;
{$IFEND}

begin
  try
    // Example 7 - Simple Lua script execution with Linux
    Lua := TVerySimpleLua.Create;
    Lua.LibraryPath := LIBRARYPATH;
    Lua.DoFile('example7.lua');
    Lua.Free;
    Readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
