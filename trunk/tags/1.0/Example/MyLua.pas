unit MyLua;

{$M+}

interface

uses
  Lua, LuaLib;

type
  // MyLua example class
  TMyLua = class(TLua)
  published
    // published methods are automatically added
    // to the lua function table
    function HelloWorld: Integer;
  end;

implementation

//  Print out a Hello World text with all
//  Arguments passed by the script and
//  return some values
//
//  @return     integer
function TMyLua.HelloWorld: Integer;
var
  ArgCount: Integer;
  I: integer;
begin
  ArgCount := Lua_GetTop(LuaState);

  writeln('Delphi: Hello World');
  writeln('Arguments: ', ArgCount);

  for I := 1 to ArgCount do
    writeln('Arg1', I, ': ', Lua_ToInteger(LuaState, I));

  // Clear stack
  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  // Push return values
  Lua_PushInteger(LuaState, 101);
  Lua_PushInteger(LuaState, 102);
  Result := 2;
end;


end.
