unit MyLua;

{$M+}

interface

uses
  VerySimple.Lua, System.SysUtils, MyPackage, MyPackage2;

type
  // MyLua example class
  TMyLua = class(TVerySimpleLua)
  private
    MyPackage: TMyPackage;
    MyPackage2: TMyPackage2;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Open; override;
  end;

implementation


const
{$IFDEF Win64}
  PLATFORM = 'Win64';
{$ELSE}
  PLATFORM = 'Win32';
{$ENDIF}

constructor TMyLua.Create;
begin
  inherited;

  LibraryPath := '..\..\DLL\' + PLATFORM + '\' + LUA_LIBRARY;

  MyPackage := TMyPackage.Create;
  MyPackage2 := TMyPackage2.Create;
end;

destructor TMyLua.Destroy;
begin
  MyPackage.Free;
  MyPackage2.Free;
  inherited;
end;

procedure TMyLua.Open;
begin
  inherited;

  // We're registering two packages: one called "MyPackage"
  MyPackage.PackageReg(LuaState);  //call our own package register function

  // and create a second package and auto register those package functions
  RegisterPackage('MyPackage2', MyPackage2);
end;

end.
