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


function LuaAdd(L: TLuaState; X, Y: Integer): Integer;
begin
  lua_getglobal(L, 'add'); // name of the function
  lua_pushinteger(L, x);  // first parameter
  lua_pushinteger(L, y);  // second parameter
  lua_call(L, 2, 1);  // call function with 2 parameters and 1 result
  Result := lua_tointeger(L, -1); // get result
  lua_pop(L, 1);  // remove result from stack
end;


begin
  try
    // Example 6 - Call a lua function
    Lua := TVerySimpleLua.Create;
    Lua.LibraryPath := '..\..\DLL\' + PLATFORM + '\' + LUA_LIBRARY;
    Lua.DoFile('example6.lua');

    Writeln(LuaAdd(Lua.LuaState, 10, 20));
    Lua.Free;
    Readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
