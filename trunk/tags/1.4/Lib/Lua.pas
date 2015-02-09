{
/**
 * @package     Delphi Lua
 * @copyright   Copyright (c) 2009 Dennis D. Spreen (http://www.spreendigital.de/blog)
 * @license     http://opensource.org/licenses/gpl-license.php GNU Public License
 * @author      Dennis D. Spreen <dennis@spreendigital.de>
 * @version     1.4
 * @revision    $Id: Lua.pas 104 2009-10-01 07:28:14Z dennis.spreen $
 */

History
1.4     DS      Rewrite of Lua function calls, they use now published static
                methods, no need for a Callbacklist required anymore
                Added Package functions
                Addes Class registering functions
1.3     DS      Improved Callback, now uses pointer instead of object index
                Modified RegisterFunctions to allow methods from other class
                to be registered, moved object table into TLua class
1.2	DS	Added example on how to extend lua with a delphi dll
1.1     DS      Improved global object table, this optimizes the delphi
                function calls
1.0     DS      Initial Release

Copyright 2009  Dennis D. Spreen (email : dennis@spreendigital.de)

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
}

unit Lua;

interface

uses
  Classes,
  LuaLib;

const
  ObjectCreateFuncName = '_createObject';
  ObjectDestroyFuncName = '_destroyObject';

type
  TMethodRec = packed record
    wSize: Word;
    pCode: Pointer;
    sName: ShortString;
  end;
  PMethodRec = ^TMethodRec;

  TLua = class(TObject)
  private
    fAutoRegister: Boolean;

    class function GetMethodTable(AClass: TClass): PAnsiChar;
    class function GetMethodCount(MethodTable: PAnsiChar): Integer;
    class function GetMethodNextRec(MethodRec: PMethodRec): PMethodrec;

    class function _createObject(L: lua_State): Integer;static;cdecl;
    class function _destroyObject(L: lua_State): Integer;static;cdecl;
  public
    LuaInstance: lua_State;  // Lua instance

    class var CreateObject: function(L: lua_State; AClass: TClass): TObject;

    // constructor with Autoregister published functions or without (default)
    constructor Create; overload;virtual;
    constructor Create(AutoRegister: Boolean); overload;virtual;
    destructor Destroy; override;

    // Convenience Lua function(s)
    function DoFile(Filename: String): Integer; virtual;// load file and execute

    // functions for manually registering new lua functions
    class procedure RegisterFunction(L: lua_State; Func: lua_CFunction; FuncName: String);overload;
    class procedure RegisterFunction(L: lua_State; AClass: TClass; Func, FuncName: String);overload;
    class procedure RegisterFunction(L: lua_State; AObject: TObject; Func, FuncName: String);overload;

    procedure RegisterFunction(Func: lua_CFunction; FuncName: String);overload;
    procedure RegisterFunction(AClass: TClass; Func: String);overload;
    procedure RegisterFunction(AClass: TClass; Func, FuncName: String);overload;
    procedure RegisterFunction(AObject: TObject; Func, FuncName: String);overload;
    procedure RegisterFunction(AObject: TObject; Func: String);overload;
    procedure RegisterFunction(Func: String);overload;
    procedure RegisterFunction(Func, FuncName: String);overload;

    class procedure RegisterFunctions(L: lua_State; AClass: TClass);overload;
    class procedure RegisterFunctions(L: lua_State; AObject: TObject);overload;

    // automatically register all functions published by a class or an object
    procedure RegisterFunctions(AClass: TClass);overload;
    procedure RegisterFunctions(AObject: TObject);overload;

    // functions for registering new lua classes
    class procedure RegisterClass(L: lua_State; AClass: TClass; Classname: String; AObjectClass: TClass);overload;

    procedure RegisterClass(AClass: TClass);overload;
    procedure RegisterClass(AClass: TClass; Classname: String);overload;
    procedure RegisterClass(AClass: TClass; Classname: String; AObjectClass: TClass);overload;

    // package register functions
    class procedure RegisterPackage(L: lua_State; PackageName: String; InitFunc: lua_CFunction);overload;
    procedure RegisterPackage(PackageName: String; InitFunc: lua_CFunction);overload;
    procedure RegisterPackage(PackageName: String; AClass: TClass; Func: String);overload;
    procedure RegisterPackage(PackageName: String; AObject: TObject; Func: String);overload;
    procedure RegisterPackage(PackageName: String; Func: String);overload;
  end;

implementation

{ TLua }

//
// Create a new Lua instance and optionally create Lua functions
//
// @param       Boolean      AutoRegister       (optional)
// @return      TLua                            Lua Instance
//
constructor TLua.Create(AutoRegister: Boolean);
begin
  Create;

  // if set then register published functions
  if (AutoRegister) then
  begin
    fAutoRegister := True;
    RegisterFunctions(self);
  end;
end;

constructor TLua.Create;
begin
  inherited Create;

  // Load Lua Lib if not already done
  if (not LuaLibLoaded) then
    LoadLuaLib;

  // Open Library
  LuaInstance := Lua_Open();
  luaL_openlibs(LuaInstance); // open all libs

  fAutoRegister := False;
end;


//
// Dispose Lua instance
//
destructor TLua.Destroy;
begin
  // Unregister all functions if previously autoregistered
  if (fAutoRegister) then
    //UnregisterFunctions(Self);

  // Close instance
  Lua_Close(LuaInstance);
  inherited;
end;


//
// Wrapper for Lua File load and Execution
//
// @param       String  Filename        Lua Script file name
// @return      Integer
//
function TLua.DoFile(Filename: String): Integer;
begin
  Result := lual_dofile(LuaInstance, PAnsiChar(AnsiString(Filename)));
end;

  // Get a pointer to the class's published method table
class function TLua.GetMethodCount(MethodTable: PAnsiChar): Integer;
var
  wCount: ^Word;
begin
  // Get the count of the methods in the table
  wCount := Pointer(MethodTable);
  result := wCount^;
end;

class function TLua.GetMethodNextRec(MethodRec: PMethodRec): PMethodrec;
begin
  Result := PMethodRec(PAnsiChar(MethodRec) + MethodRec.wSize);
end;

class function TLua.GetMethodTable(AClass: TClass): PAnsiChar;
begin
  Result := PAnsiChar(Pointer(PAnsiChar(AClass) + vmtMethodTable)^);
end;

class procedure TLua.RegisterFunction(L: lua_State; Func: lua_CFunction;
  FuncName: String);
begin
  lua_pushstring(L, PAnsiChar(AnsiString(FuncName)));
  lua_pushcfunction(L, Func);
  lua_settable(L, LUA_GLOBALSINDEX);
end;

class procedure TLua.RegisterFunction(L: lua_State; AObject: TObject; Func, FuncName: String);
begin
  lua_pushstring(L, PAnsiChar(AnsiString(FuncName)));
  lua_pushlightuserdata(L, AObject); // prepare Closure value (Object)
  lua_pushcclosure(L, AObject.MethodAddress(Func), 1); // set new Lua function with Closure value
  lua_settable(L, LUA_GLOBALSINDEX);
end;

class procedure TLua.RegisterFunction(L: lua_State; AClass: TClass; Func, FuncName: String);
begin
  RegisterFunction(L, AClass.MethodAddress(Func), FuncName);
end;

procedure TLua.RegisterFunction(Func: lua_CFunction;FuncName: String);
begin
  RegisterFunction(LuaInstance, Func, FuncName);
end;

procedure TLua.RegisterFunction(AClass: TClass; Func: String);
begin
  RegisterFunction(LuaInstance, AClass.MethodAddress(Func), Func);
end;

procedure TLua.RegisterFunction(AClass: TClass; Func, FuncName: String);
begin
  RegisterFunction(LuaInstance, AClass.MethodAddress(Func), FuncName);
end;


procedure TLua.RegisterFunction(AObject: TObject; Func, FuncName: String);
begin
  RegisterFunction(LuaInstance, AObject, Func, FuncName);
end;

procedure TLua.RegisterFunction(AObject: TObject; Func: String);
begin
  RegisterFunction(LuaInstance, AObject, Func, Func);
end;

procedure TLua.RegisterFunction(Func: String);
begin
  RegisterFunction(LuaInstance, self, Func, Func);
end;

procedure TLua.RegisterFunction(Func, FuncName: String);
begin
  RegisterFunction(LuaInstance, self, Func, FuncName);
end;


class procedure TLua.RegisterFunctions(L: lua_State; AClass: TClass);
var
  MethodTable: PAnsiChar;
  MethodRec: PMethodRec;
  MethodCount: Integer;
  I: Integer;
begin
  // Get a pointer to the class's published method table
  MethodTable := GetMethodTable(AClass);
  if (MethodTable <> Nil) then
  begin
    MethodCount := GetMethodCount(MethodTable);
    MethodRec := PMethodRec(MethodTable + 2);
    for I := 1 to MethodCount do
    begin
      RegisterFunction(L, MethodRec.pCode, String(MethodRec.sName));
      MethodRec := GetMethodNextRec(MethodRec);
    end;
  end;
end;

class procedure TLua.RegisterFunctions(L: lua_State; AObject: TObject);
var
  MethodTable: PAnsiChar;
  MethodRec: PMethodRec;
  MethodCount: Integer;
  I: Integer;
begin
  // Get a pointer to the class's published method table
  MethodTable := GetMethodTable(AObject.ClassType);
  if (MethodTable <> Nil) then
  begin
    MethodCount := GetMethodCount(MethodTable);
    MethodRec := PMethodRec(MethodTable + 2);
    for I := 1 to MethodCount do
    begin
      RegisterFunction(L, AObject, String(MethodRec.sName), String(MethodRec.sName));
      MethodRec := GetMethodNextRec(MethodRec);
    end;
  end;
end;

procedure TLua.RegisterFunctions(AClass: TClass);
begin
  RegisterFunctions(LuaInstance, AClass);
end;

procedure TLua.RegisterFunctions(AObject: TObject);
begin
  RegisterFunctions(LuaInstance, AObject);
end;

class function TLua._createObject(L: lua_State): Integer;
var
  AClass: TClass;
  AObject: TObject;
  MethodTable: PAnsiChar;
  MethodRec: PMethodRec;
  MethodCount: Integer;
  I: Integer;
begin
  // get class pointer
  AClass := lua_topointer(L, lua_upvalueindex(1));

  // create new object
  if (@CreateObject = NIL) then
    AObject := AClass.Create
  else
    AObject := CreateObject(L, AClass);

  // Get a pointer to the class's published method table and
  // iterate through all the published methods of this class
  MethodTable := GetMethodTable(AClass);
  if (MethodTable <> Nil) then
  begin
    MethodCount := GetMethodCount(MethodTable);
    MethodRec := PMethodRec(MethodTable + 2);
    for I := 1 to MethodCount do
    begin
      // set new object functions with object as closure
      lua_pushstring(L, PAnsiChar(AnsiString(MethodRec.sName)));
      lua_pushlightuserdata(L, AObject);
      lua_pushcclosure(L, MethodRec.pCode, 1);
      lua_rawset(L, -3);

      // next method
      MethodRec := GetMethodNextRec(MethodRec);
    end;
  end;

  // add destroy function
  lua_pushstring(L, ObjectDestroyFuncName);
  lua_pushlightuserdata(L, AObject);
  lua_pushcclosure(L, @TLua._destroyObject , 1);
  lua_rawset(L, -3);
  result := 0;
end;

class function TLua._destroyObject(L: lua_State): Integer;
var
  AObject: TObject;
begin
  AObject := lua_topointer(L, lua_upvalueindex(1));
  AObject.Free;
  result := 0;
end;

class procedure TLua.RegisterClass(L: lua_State; AClass: TClass;
  Classname: String; AObjectClass: TClass);
var
  MethodTable: PAnsiChar;
  MethodRec: PMethodRec;
  MethodCount: Integer;
  I: Integer;
begin
  // create a new table only if it does not exists yet
  lua_getglobal(L, PAnsiChar(AnsiString(Classname)));
  if (not lua_istable(L, -1)) then
  begin
    lua_pop(L, 1); // remove empty value from top
    lua_newtable(L); // create new table
    lua_setglobal(L, PAnsiChar(AnsiString(Classname)));
    lua_getglobal(L, PAnsiChar(AnsiString(Classname)));
  end;

  // new function with AObjectClass pointer closure
  // set new Lua function with Closure value
  lua_pushstring(L, ObjectCreateFuncName);
  lua_pushlightuserdata(L, AObjectClass);
  lua_pushcclosure(L, @TLua._createObject, 1);
  lua_rawset(L, -3);

  // Get a pointer to the class's published method table
  // and iterate through all published methods of the class
  MethodTable := GetMethodTable(AClass);
  if (MethodTable <> Nil) then
  begin
    MethodCount := GetMethodCount(MethodTable);
    MethodRec := PMethodRec(MethodTable + 2);
    for I := 1 to MethodCount do
    begin
      // set new Lua function with Closure value
      // prepare Closure value (CallBack Object Pointer)
      lua_pushstring(L, PAnsiChar(AnsiString(MethodRec.sName)));
      lua_pushlightuserdata(L, AClass);
      lua_pushcclosure(L, MethodRec.pCode, 1);
      lua_rawset(L, -3);
      MethodRec := GetMethodNextRec(MethodRec);
    end;
  end;
end;


procedure TLua.RegisterClass(AClass: TClass; Classname: String;
  AObjectClass: TClass);
begin
  RegisterClass(LuaInstance, AClass, Classname, AObjectClass);
end;

procedure TLua.RegisterClass(AClass: TClass; Classname: String);
begin
  RegisterClass(LuaInstance, AClass, Classname, AClass);
end;

procedure TLua.RegisterClass(AClass: TClass);
begin
  RegisterClass(LuaInstance, AClass, AClass.ClassName, AClass);
end;




class procedure TLua.RegisterPackage(L: lua_State; PackageName: String;
  InitFunc: lua_CFunction);
begin
  lua_getglobal(L, 'package');
  lua_pushstring(L, 'preload');
  lua_rawget(L, -2);
  lua_pushstring(L, PAnsiChar(AnsiString(PackageName)));
  lua_pushcfunction(L, InitFunc);
  lua_rawset(L, -3);
  lua_pop(L,2);
end;

procedure TLua.RegisterPackage(PackageName: String; InitFunc: lua_CFunction);
begin
  RegisterPackage(LuaInstance, PackageName, InitFunc);
end;


procedure TLua.RegisterPackage(PackageName: String; AClass: TClass;
  Func: String);
begin
  RegisterPackage(LuaInstance, Packagename, AClass.MethodAddress(Func));
end;

procedure TLua.RegisterPackage(PackageName: String; AObject: TObject;
  Func: String);
begin
  RegisterPackage(LuaInstance, Packagename, AObject.MethodAddress(Func));
end;

procedure TLua.RegisterPackage(PackageName, Func: String);
begin
  RegisterPackage(LuaInstance, Packagename, self.MethodAddress(Func));
end;

end.


