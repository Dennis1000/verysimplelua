program LuaTest;
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Lua in '..\Lib\Lua.pas',
  LuaLib in '..\Lib\LuaLib.pas',
  MyLua in 'MyLua.pas',
  SomeClass in 'SomeClass.pas';


var
  MyLua: TLua;
  Lua: TLua;
  SomeObject: TSomeClass;

begin
  try
    (* Example 1 - Simple Lua Script Execution *)

    Lua := TLua.Create;
    Lua.DoFile('simple.lua');
    Lua.Free;

    (* Example 2 - Lua with own delphi functions *)

    // Create new Lua and autoregister new functions  (see TMyLua.Pas)
    MyLua := TMyLua.Create;
    MyLua.DoFile('Helloworld.lua');
    MyLua.Free;

    (* Example 3 - Lua with own delphi functions in other classes *)

    // Create another object
    SomeObject := TSomeClass.Create;

    // Manually register new lua functions
    MyLua := TMyLua.Create(False);
    MyLua.RegisterFunction('HelloWorld');
    MyLua.RegisterFunction('HelloWorld2');

    // register HelloWorld3 in Lua but link to MyLua.HelloWord4
    MyLua.RegisterFunction('HelloWorld3','HelloWorld4');

    // autoregister all published functions from SomeObject (=HelloWorld5)
    MyLua.AutoRegisterFunctions(SomeObject);

    // Execute Lua script
    MyLua.DoFile('Helloworld.lua');

    // Unregister own functions
    MyLua.UnregisterFunctions(SomeObject);
    MyLua.UnregisterFunctions(MyLua);

    SomeObject.Free;
    MyLua.Free;

    readln;

  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;
end.
