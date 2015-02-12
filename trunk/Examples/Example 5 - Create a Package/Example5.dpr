program Example5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MyLua in 'MyLua.pas',
  MyPackage in 'MyPackage.pas',
  MyPackage2 in 'MyPackage2.pas',
  VerySimple.Lua.Lib in '..\..\Source\VerySimple.Lua.Lib.pas',
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas';

var
  MyLua: TMyLua;
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }

    MyLua := TMyLua.Create;
    MyLua.DoFile('example5.lua');
    MyLua.Free;
    readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
