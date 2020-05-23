unit MyPackage2;

interface

uses
  VerySimple.Lua;

{$M+}

type
  TMyPackage2 = class
  published
    function Double(L: TLuaState): Integer;
  end;


implementation

{ TMyPackage2 }

function TMyPackage2.Double(L: TLuaState): Integer;
var
  ArgCount: Integer;
  Value: Integer;
begin
  ArgCount := Lua_GetTop(L);

  // Get last argument as value - ArgCount is different if called via MyPackage2.Double() or MayPackage2:Double()!
  Value := Lua_ToInteger(L, ArgCount);

  // Double the value
  Value := Value * 2;

  // Push the result
  Lua_PushInteger(L, Value);

  // There is one value on the result stack
  Result := 1;
end;

end.
