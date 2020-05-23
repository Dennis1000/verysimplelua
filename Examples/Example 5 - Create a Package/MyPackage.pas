unit MyPackage;

interface

{$M+}

uses
  VerySimple.Lua;

type
  TMyPackage = class
  protected
  public
    function LoadPackage(L: TLuaState): Integer;
    procedure PackageReg(L: TLuaState);
  published
    function Myfunction1(L: TLuaState): Integer;
    function Myfunction2(L: TLuaState): Integer;
  end;


implementation

{ TMyPackage }

uses
  System.SysUtils;

function TMyPackage.LoadPackage(L: TLuaState): Integer;
begin
  lua_newtable(L);

  // Manually add Myfunction1
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('Myfunction1'), 'Myfunction1');
  lua_rawset(L, -3);

  // Manually add Myfunction2
  TVerySimpleLua.PushFunction(L, Self, MethodAddress('Myfunction2'), 'Myfunction2');
  lua_rawset(L, -3);

  Result := 1;
end;

function TMyPackage.Myfunction1(L: TLuaState): Integer;
begin
  // Push a return value
  Lua_PushInteger(L, 54);
  Result := 1;
end;

function TMyPackage.Myfunction2(L: TLuaState): Integer;
begin
  // Push a return value
  Lua_PushInteger(L, 174);
  Result := 1;
end;

procedure TMyPackage.PackageReg(L: TLuaState);
begin
  // Register Lua package 'MyPackage' with the TMyPackage package loader procedure
  TVerySimpleLua.RegisterPackage(L, 'MyPackage', Self, 'LoadPackage');
end;

end.

