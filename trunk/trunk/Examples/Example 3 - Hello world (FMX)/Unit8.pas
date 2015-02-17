unit Unit8;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.Memo;

type
  TForm8 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnPrint(Msg: String);
  end;

var
  Form8: TForm8;

implementation

{$R *.fmx}

uses
  VerySimple.Lua, VerySimple.Lua.Lib, System.IOUtils;


procedure TForm8.Button1Click(Sender: TObject);
var
  Lua: TVerySimpleLua;
begin
  Lua := TVerySimpleLua.Create;

  {$IF defined(WIN32)}
  Lua.LibraryPath :=  '..\..\..\..\DLL\WIN32\' + LUA_LIBRARY;
  Lua.FilePath := '..\..\';

  {$ELSEIF defined(WIN64)}
  Lua.LibraryPath :=  '..\..\..\..\DLL\WIN64\' + LUA_LIBRARY;
  Lua.FilePath := '..\..\';
  {$ENDIF}

  Lua.OnPrint := OnPrint; // Redirect console output to memo
  Lua.DoFile('example3.lua');
  Lua.Free;
end;

procedure TForm8.OnPrint(Msg: String);
begin
  Memo1.Lines.Add(Msg);
  Memo1.GoToTextEnd;
  Application.ProcessMessages;
end;

end.
