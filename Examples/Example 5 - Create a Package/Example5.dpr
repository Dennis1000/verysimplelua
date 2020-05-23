program Example5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MyLua in 'MyLua.pas',
  MyPackage in 'MyPackage.pas',
  MyPackage2 in 'MyPackage2.pas',
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas';

var
  MyLua: TMyLua;
begin
  try
    // Example 5 - create a Lua package
    MyLua := TMyLua.Create;
    MyLua.DoFile('example5.lua');
    MyLua.Free;
    Readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
