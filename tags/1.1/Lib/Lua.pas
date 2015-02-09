{
/**
 * @package     Delphi Lua
 * @copyright   Copyright (c) 2009 Dennis D. Spreen (http://www.spreendigital.de/blog)
 * @license     http://opensource.org/licenses/gpl-license.php GNU Public License
 * @author      Dennis D. Spreen <dennis@spreendigital.de>
 * @version     1.1
 * @revision    $Id: Lua.pas 95 2009-09-29 11:38:49Z dennis.spreen $
 */

History
1.1     DS      Improved globale object table, this optimizes the delphi
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

type
  TLuaState = Lua_State;

  TLua = class(TObject)
  private
    procedure AutoRegisterFunc;  // register all published functions
    procedure RegisterFunc(FuncName: AnsiString; MethodName: AnsiString);  //register function
  public
    LuaInstance: TLuaState;  // Lua instance
    constructor Create(AutoRegister: Boolean = True); virtual;
    destructor Destroy; override;
    function DoFile(Filename: String): Integer; virtual;// load file and execute
    procedure RegisterFunction(FuncName: AnsiString; MethodName: AnsiString = ''); virtual; //register function
  end;

implementation

type
  TProc = function(L: TLuaState): Integer of object; // Lua Function

  TCallback = class
    Routine: TMethod;  // Code and Data for the method
    Exec: TProc;       // Resulting execution function
  end;

var
  CallbackList: TList;  // global callback list

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
  Obj: TCallBack;       // The Object stored in the Object Table
  ObjIndex: Integer;    // Object Table Index
begin
  Result := 0;
  // Retrieve first Closure Value (=Object Index)
  ObjIndex := lua_tointeger(L, lua_upvalueindex(1));

  // Only if object index is stored in ObjectList
  if (ObjIndex < CallbackList.Count) then
  begin
    // Retrieve Object from the Object List
    Obj := CallbackList.Items[ObjIndex];

    // Continue only if Object is valid
    if (assigned(Obj) and assigned(Obj.Exec)) then
        Result := Obj.Exec(L);
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
  LuaInstance := Lua_Open();
  luaopen_base(LuaInstance);

  // if set then register published functions
  if (AutoRegister) then
    AutoRegisterFunc;
end;

//
// Dispose Lua instance
//
destructor TLua.Destroy;
var
  I: Integer;
  CallBack: TCallBack;
begin
  // remove self from object list
  for I := 0 to CallBackList.Count - 1 do
  begin
    CallBack := CallBackList[I];
    if (assigned(CallBack)) and (CallBack.Routine.Data = self) then
    begin
       CallBack.Free;
       CallBackList.Items[I] := NIL;
    end;
  end;

  // compact list by removing NIL entries from top until
  // first assigned object discovered
  while (CallBackList.Count>0) and
        (CallBackList[CallBackList.Count-1] = NIL) do
    CallBackList.Delete(CallBackList.Count-1);

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


//
// Register a new Lua Function and map it to the Objects method name
//
// @param       AnsiString      FuncName        Lua Function Name
// @param       AnsiString      MethodName      (optional) Objects Method name
//
procedure TLua.RegisterFunc(FuncName: AnsiString; MethodName: AnsiString);
var
  CallBackIndex: Integer; // object table index
  CallBack: TCallBack;
begin
  // Add Callback Object to the Object Index
  CallBack := TCallBack.Create;
  CallBack.Routine.Data := Self;
  CallBack.Routine.Code := MethodAddress(String(MethodName));
  CallBack.Exec := TProc(CallBack.Routine);
  CallBackIndex := CallbackList.Add(CallBack);

  // prepare Closure value (Method Name)
  lua_pushstring(LuaInstance, PAnsiChar(FuncName));

  // prepare Closure value (CallBack Object Index)
  lua_pushinteger(LuaInstance, CallBackIndex);

  // set new Lua function with Closure value
  lua_pushcclosure(LuaInstance, LuaCallBack, 1);
  lua_settable(LuaInstance, LUA_GLOBALSINDEX);
end;




procedure TLua.RegisterFunction(FuncName: AnsiString; MethodName: AnsiString = '');
begin
  // if method name not specified use Lua function name
  if (MethodName = '') then
    MethodName := FuncName;
  RegisterFunc(FuncName, MethodName);
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
      RegisterFunc(MethodRec.sName, MethodRec.sName);
      // Skip to the next method
      MethodRec := PMethodRec(PAnsiChar(MethodRec) + MethodRec.wSize);
    end;
  end;
end;

// Create Object List on initialization
initialization

CallBackList := TList.Create;

// dispose Object List on finalization
finalization

CallBackList.Free;

end.
