unit MyLua;

{$M+}

interface

uses
  VerySimple.Lua;

type
  // MyLua example class
  TMyLua = class(TVerySimpleLua)
  published
    // These published methods are automatically added  to the lua
    // function table if called with TLua.Create(True) or Create()
    function HelloWorld(LuaState: TLuaState): Integer;
    class function HelloWorld2(LuaState: TLuaState): Integer;
    class function HelloWorld3(LuaState: TLuaState): Integer; cdecl; static;
  end;

implementation

// Print arguments and return two values (101 and 102)
function TMyLua.HelloWorld(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  I: Integer;
begin
  ArgCount := Lua_GetTop(LuaState);

  Writeln('Hello World from Delphi');
  Writeln('Arguments: ', ArgCount);

  for I := 1 to ArgCount do
    Writeln('Arg', I, ': ', Lua_ToInteger(LuaState, I));

  // Clear stack
  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  // Push return values
  Lua_PushInteger(LuaState, 101);
  Lua_PushInteger(LuaState, 102);
  Result := 2;
end;


//  Print out a Hello World text
class function TMyLua.HelloWorld2(LuaState: TLuaState): Integer;
begin
  Writeln('Hello World2 from Delphi');
  Result := 0;
end;

//  Print out a Hello World text
class function TMyLua.HelloWorld3(LuaState: TLuaState): Integer;
begin
  Writeln('Hello World3 from Delphi');
  Result := 0;
end;


end.
