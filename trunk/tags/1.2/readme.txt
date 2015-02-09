=================================
Lua 5.1 for Delphi 2010 v1.2
=================================
(c) 2009 Dennis D. Spreen
http://www.spreendigital.de/blog/
=================================

History
1.2	DS	Added example on how to extend lua with a delphi dll
1.1     DS      Improved global object table, optimized delphi
                function calls
1.0     DS      Initial Release


This is a Lua Wrapper for Delphi 2009 and 2010. It is based on 
Lua-Pascal v0.2 by Marco Antonio Abreu (www.marcoabreu.eti.br):
 - converted PChar to PAnsiChar
 - converted Char to AnsiChar
 - added function LuaLibLoaded: Boolean;
 - added a new base class (TLua) with OOP call back functions

TLua automatically creates OOP callback functions for Delphi <-> Lua:


uses
  Lua, LuaLib;

type
  TMyLua = class(TLua)
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
  MyLua: TLua;

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
Copyright 2009  Dennis D. Spreen (http://www.spreendigital.de/blog/)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
**************************************************************************

