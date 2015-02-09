{
/**
 * @package     Delphi Lua
 * @copyright   Copyright (c) 2009 Dennis D. Spreen (http://www.spreendigital.de/blog)
 * @license     http://opensource.org/licenses/gpl-license.php GNU Public License
 * @author      Dennis D. Spreen <dennis@spreendigital.de>
 * @version     $Id: Lua.pas 69 2009-09-18 16:11:08Z dennis.spreen $
 */

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

type
  TLua = class(TObject)
  private
  public
    LuaState: Lua_State;  // Lua instance
    constructor Create(AutoRegister: Boolean = True); virtual;  // Create a new object
    destructor Destroy; override; // dispose Object
    function DoFile(Filename: String): Integer; // load file and execute
    procedure RegisterFunc(FuncName: AnsiString; MethodName: AnsiString = '');  //register function
    procedure AutoRegisterFunc;  // register all published functions
  end;

implementation

type
  TProc = function: Integer of object;

var
  ObjectList: TList;  // We need a global Lua Object List

//
// This function is called by Lua, it extracts the object by
// index and gets a pointer to the objects method by name,
// which is then called.
//
// @param       Lua_State   L   Pointer to Lua instance
// @return      Integer         Number of result arguments on stack
//
function LuaCallBack(L: Lua_State): Integer; cdecl;
var
  Obj: TObject;         // The Object stored in the Object Table
  ObjIndex: Integer;    // Object Table Index
  Routine: TMethod;     // Code and Data for the method
  Exec: TProc;          // Resulting execution function
  MethodName: String;   // Extracted method name
begin
  Result := 0;
  // Retrieve first Closure Value (=Object Index)
  ObjIndex := lua_tointeger(L, lua_upvalueindex(1));

  // Only if object index is stored in ObjectList
  if (ObjIndex < ObjectList.Count) then
  begin
    // Retrieve Object from the Object List
    Obj := ObjectList.Items[ObjIndex];

    // Continue only if Object is valid
    if (assigned(Obj)) then
    begin

      // Retrieve second Closure Value (=Method Name)
      MethodName := String(lua_tostring(L, lua_upvalueindex(2)));

      // Prepare Code and Data pointer for Execution
      Routine.Data := Obj;
      Routine.Code := Obj.MethodAddress(MethodName);

      // And finally execute if Method exists
      if (assigned(Routine.Code)) then
      begin
        Exec := TProc(Routine);
        Result := Exec;
      end;
    end;
  end;
end;

{ TLua }

//
// Create a new Lua instance and optionally create Lua functions
//
// @param       Boolean      AutoRegister       (optional)
// @return      TLua                            Lua Instance
//
constructor TLua.Create(AutoRegister: Boolean = True);
begin
  inherited Create;
  // Load Lua Lib if not already done
  if (not LuaLibLoaded) then
    LoadLuaLib;

  // Open Library
  LuaState := Lua_Open();
  luaopen_base(LuaState);

  // if set then register published functions
  if (AutoRegister) then
    AutoRegisterFunc;
end;

//
// Dispose Lua instance
//
destructor TLua.Destroy;
var
  ObjIndex: Integer;
begin
  // remove self from object list
  ObjIndex := ObjectList.IndexOf(self);
  if (ObjIndex>=0) then
    ObjectList[ObjIndex] := NIL;

  // compact list by removing NIL entries from top until
  // first assigned object discovered
  while (ObjectList.Count>0) and
        (ObjectList[ObjectList.Count-1] = NIL) do
    ObjectList.Delete(ObjectList.Count-1);

  // Close instance
  Lua_Close(LuaState);
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
  Result := lual_dofile(LuaState, PAnsiChar(AnsiString(Filename)));
end;


//
// Register a new Lua Function and map it to the Objects method name
//
// @param       AnsiString      FuncName        Lua Function Name
// @param       AnsiString      MethodName      (optional) Objects Method name
//
procedure TLua.RegisterFunc(FuncName: AnsiString; MethodName: AnsiString = '');
var
  ObjIndex: Integer; // object table index
begin
  // Add Object to the Object Index
  ObjIndex := ObjectList.Add(self);

  // prepare Closure values (Function name and Object Index)
  lua_pushstring(LuaState, PAnsiChar(FuncName));
  lua_pushnumber(LuaState, ObjIndex);

  // if not method name specified use Lua function name
  if (MethodName = '') then
    MethodName := FuncName;

  // prepare Closure value (Method Name)
  lua_pushstring(LuaState, PAnsiChar(MethodName));

  // set new Lua function with Closure values
  lua_pushcclosure(LuaState, LuaCallBack, 2);
  lua_settable(LuaState, LUA_GLOBALSINDEX);
end;


//
// Register all published methods as Lua Functions
//
procedure TLua.AutoRegisterFunc;
type
  PPointer = ^Pointer;
  PMethodRec = ^TMethodRec;

  TMethodRec = packed record
    wSize: Word;
    pCode: Pointer;
    sName: ShortString;
  end;
var
  MethodTable: PAnsiChar;
  MethodRec: PMethodRec;
  wCount: Word;
  nMethod: Integer;
begin
  // Get a pointer to the class's published method table
  MethodTable := PAnsiChar(Pointer(PAnsiChar(self.ClassType) + vmtMethodTable)^);

  if (MethodTable <> Nil) then
  begin
    // Get the count of the methods in the table
    Move(MethodTable^, wCount, 2);

    // Position the MethodRec pointer at the first method in the table
    // (skip over the 2-byte method count)
    MethodRec := PMethodRec(MethodTable + 2);

    // Iterate through all the published methods of this class
    for nMethod := 0 to wCount - 1 do
    begin
      // Add the method name to the lua functions
      RegisterFunc(MethodRec.sName);
      // Skip to the next method
      MethodRec := PMethodRec(PAnsiChar(MethodRec) + MethodRec.wSize);
    end;
  end;
end;

// Create Object List on initialization
initialization

ObjectList := TList.Create;

// dispose Object List on finalization

finalization

ObjectList.Free;

end.
