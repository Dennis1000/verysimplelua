=============================================
VerySimple.Lua - Lua 5.3.0 for Delphi XE5-XE8
=============================================
(c) 2009-2015 Dennis D. Spreen
http://blog.spreendigital.de/2015/02/18/verysimple-lua-2-0-a-cross-platform-lua-5-3-0-wrapper-for-delphi-xe5-xe7/

History
2.0.3   DS      Fix XE5 - Added Pointer cast for RegisterFunc
2.0.2   DS      Fix: added missing lua_isinteger function
2.0.1   DS      Fix: fixed Register function 
                Added Example 6 - Call a Lua function
2.0     DS      Updated Lua Lib to 5.3.0
                Rewrite of Delphi register functions
                Removed Class only functions
                Removed a lot of convenience overloaded functions
                Support for mobile compiler
1.4     DS      Rewrite of Lua function calls, they use now published static
                methods, no need for a Callbacklist required anymore
                Added Package functions
                Added Class registering functions
1.3     DS      Improved Callback, now uses pointer instead of object index
                Modified RegisterFunctions to allow methods from other class
                to be registered, moved object table into TLua class
1.2	DS	Added example on how to extend lua with a delphi dll
1.1     DS      Improved global object table, this optimizes the delphi
                function calls
1.0     DS      Initial Release


This is a Lua Wrapper for Delphi XE5-D10 which 
automatically creates OOP callback functions for Delphi <-> Lua:


uses
  VerySimple.Lua, VerySimple.Lua.Lib;

type
  TMyLua = class(TVerySimpleLua)
  published
    function HelloWorld(LuaState: TLuaState): Integer;
  end;

function TMyLua.HelloWorld(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  I: integer;
begin
  ArgCount := Lua_GetTop(LuaState);

  writeln('Delphi: Hello World');
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


var
  MyLua: TVerySimpleLua;

begin
  MyLua := TMyLua.Create;
  MyLua.DoFile('Helloworld.lua');
  MyLua.Free;
end;



helloworld.lua  

print("LuaDelphi Test");
p1,p2 = HelloWorld(1,2,3)
print "Results:";
print (p1);
print (p2);


**************************************************************************
Copyright 2015  Dennis D. Spreen (http://blog.spreendigital.de/)

VerySimple.Lua is distributed under the terms of the Mozilla Public License, 
v. 2.0. If a copy of the MPL was not distributed with your software, 
You can obtain one at http://mozilla.org/MPL/2.0/.

**************************************************************************

