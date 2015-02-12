unit MyLua;

{$M+}

interface

uses
  VerySimple.Lua, VerySimple.Lua.Lib;

type
  // MyLua example class
  TMyLua = class(TVerySimpleLua)
  published
    // lua functions this published methods are automatically added
    // to the lua function table if called with TLua.Create(True) or Create()
    function HelloWorld(LuaState: lua_State): Integer;
    class function HelloWorld2(LuaState: lua_State): Integer;
    class function HelloWorld3(LuaState: lua_State): Integer; cdecl; static;
  end;

implementation

// Print arguments and return two values (101 and 102)
function TMyLua.HelloWorld(LuaState: lua_State): Integer;
var
  ArgCount: Integer;
  I: integer;
begin
  ArgCount := Lua_GetTop(LuaState);

  writeln('Hello World from Delphi');
  writeln('Arguments: ', ArgCount);

  for I := 1 to ArgCount do
    writeln('Arg', I, ': ', Lua_ToInteger(LuaState, I));

  // Clear stack
  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  // Push return values
  Lua_PushInteger(LuaState, 101);
  Lua_PushInteger(LuaState, 102);
  Result := 2;
end;


//  Print out a Hello World text
class function TMyLua.HelloWorld2(LuaState: lua_State): Integer;
begin
  writeln('Hello World2 from Delphi');
  Result := 0;
end;

//  Print out a Hello World text
class function TMyLua.HelloWorld3(LuaState: lua_State): Integer;
begin
  writeln('Hello World3 from Delphi');
  Result := 0;
end;


end.
