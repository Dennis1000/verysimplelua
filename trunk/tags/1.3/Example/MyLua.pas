unit MyLua;

{$M+}

interface

uses
  Lua, LuaLib;

type
  // MyLua example class
  TMyLua = class(TLua)
  published
    // lua functions this published methods are automatically added
    // to the lua function table if called with TLua.Create(True) or Create()
    function HelloWorld(LuaState: TLuaState): Integer;
    function HelloWorld2(LuaState: TLuaState): Integer;
    function HelloWorld3(LuaState: TLuaState): Integer;
    function HelloWorld4(LuaState: TLuaState): Integer;
    function HelloWorld5(LuaState: TLuaState): Integer;
  end;

implementation

//
//  Print out a Hello World text with all
//  Arguments passed by the script and
//  return some values
//
//  @param      TLuaState       LuaState        The Lua Stack
//  @return     integer
//
function TMyLua.HelloWorld(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  I: integer;
begin
  ArgCount := Lua_GetTop(LuaState);

  writeln('Hello World from Delphi');
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


//  Print out a Hello World text
function TMyLua.HelloWorld2(LuaState: TLuaState): Integer;
begin
  writeln('Hello World2 from Delphi');
  Result := 0;
end;

//  Print out a Hello World text
function TMyLua.HelloWorld3(LuaState: TLuaState): Integer;
begin
  writeln('Hello World3 from Delphi');
  Result := 0;
end;

//  Print out a Hello World text
function TMyLua.HelloWorld4(LuaState: TLuaState): Integer;
begin
  writeln('Hello World4 from Delphi');
  Result := 0;
end;

function TMyLua.HelloWorld5(LuaState: TLuaState): Integer;
begin
  writeln('Hello World5 from Delphi');
  Result := 0;
end;

end.
