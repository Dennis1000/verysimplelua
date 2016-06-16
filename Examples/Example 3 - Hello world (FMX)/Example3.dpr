program Example3;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit8 in 'Unit8.pas' {Form8},
  VerySimple.Lua.Lib in '..\..\Source\VerySimple.Lua.Lib.pas',
  VerySimple.Lua in '..\..\Source\VerySimple.Lua.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm8, Form8);
  Application.Run;
end.
