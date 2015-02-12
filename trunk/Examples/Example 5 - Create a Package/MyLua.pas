unit MyLua;

{$M+}

interface

uses
  VerySimple.Lua, VerySimple.Lua.Lib, System.SysUtils, MyPackage, MyPackage2;

type
  // MyLua example class
  TMyLua = class(TVerySimpleLua)
  private
    MyPackage: TMyPackage;
    MyPackage2: TMyPackage2;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TMyLua.Create;
begin
  // Load Lua library and autoregister functions (base "print" function declared in TVerySimpleLua)
  inherited Create('..\..\DLL\Win32\');

  // We're registering two packages: one called "MyPackage"
  MyPackage := TMyPackage.Create;
  MyPackage.PackageReg(LuaState);  //call our own package register function

  // and create a second package and auto register those package functions
  MyPackage2 := TMyPackage2.Create;
  RegisterPackage('MyPackage2', MyPackage2);
end;

destructor TMyLua.Destroy;
begin
  MyPackage.Free;
  MyPackage2.Free;
  inherited;
end;

end.
