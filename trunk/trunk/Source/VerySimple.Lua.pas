{
/**
 * @package     VerySimple.Lua
 * @copyright   Copyright (c) 2009-2015 Dennis D. Spreen (http://blog.spreendigital.de/)
 * @license     http://opensource.org/licenses/gpl-license.php GNU Public License
 * @author      Dennis D. Spreen <dennis@spreendigital.de>
 * @version     2.0
 * @url		http://blog.spreendigital.de/2015/02/18/verysimple-lua-2-0-a-cross-platform-lua-5-3-0-wrapper-for-delphi-xe5-xe7/
 */

History
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

Copyright 2009-2015  Dennis D. Spreen (email: dennis@spreendigital.de)

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

unit VerySimple.Lua;

interface

{$M+}

uses
{$IF defined(POSIX)}
  Posix.Dlfcn, Posix.SysTypes, Posix.StdDef,
{$ENDIF}

{$IF defined(MSWINDOWS)}
  Winapi.Windows,
{$ELSEIF defined(MACOS)}
  {$IFDEF IOS}
    {$DEFINE STATICLIBRARY}
  {$ENDIF}

{$ELSEIF defined(ANDROID)}
{$ENDIF}
  System.Rtti, System.Classes, System.SysUtils, System.IOUtils, Generics.Collections,
  VerySimple.Lua.Lib;

type
  TOnLuaPrint = procedure(Msg: String) of object;

  ELuaLibraryNotFound = class(Exception);
  ELuaLibraryLoadError = class(Exception);
  ELuaLibraryMethodNotFound = class(Exception);

  TVerySimpleLua = class(TObject)
  private
    FLuaState: Lua_State;  // Lua instance
    FOnPrint: TOnLuaPrint;
    FFilePath: String;
    FLibraryPath: String;
    FAutoRegister: boolean;
    FOpened: Boolean;
  protected
    procedure DoPrint(Msg: String); virtual;
    class function ValidMethod(Method: TRttiMethod): Boolean; virtual;

    // Internal package registration
    class procedure RegisterPackage(L: lua_State; Data: Pointer; Code: Pointer; PackageName: String); overload; virtual;
  public
    // constructor with Autoregister published functions or without (default)
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Open; virtual;
    procedure Close; virtual;

    // Convenience Lua function(s)
    function DoFile(Filename: String): Integer; virtual;// load file and execute
    function DoString(Value: String): Integer; virtual;
    function DoChunk(L: Lua_State; Status: Integer): Integer; virtual;
    function DoCall(L: Lua_State; NArg, NRes: Integer): Integer; virtual;
    function LoadFile(Filename: String): Integer; virtual;
    function Run: Integer; virtual;

    // functions for manually registering new lua functions
    class procedure PushFunction(L: lua_State; Data, Code: Pointer; FuncName: String);

    class procedure RegisterFunction(L: lua_State; Func: lua_CFunction; FuncName: String); overload; virtual;
    procedure RegisterFunction(Func: lua_CFunction; FuncName: String); overload;  virtual;

    class procedure RegisterFunction(L: lua_State; Data: Pointer; Code: Pointer; FuncName: String); overload; virtual;
    class procedure RegisterFunction(L: lua_State; AClass: TClass; Func, FuncName: String); overload; virtual;
    class procedure RegisterFunction(L: lua_State; AObject: TObject; Func, FuncName: String); overload;  virtual;
    class procedure RegisterClassFunction(L: lua_State; AObject: TObject; Func, FuncName: String); overload;  virtual;

    procedure RegisterFunction(AClass: TClass; Func: String); overload; virtual;
    procedure RegisterFunction(AClass: TClass; Func, FuncName: String); overload; virtual;
    procedure RegisterFunction(AObject: TObject; Func, FuncName: String); overload; virtual;
    procedure RegisterFunction(AObject: TObject; Func: String); overload; virtual;
    procedure RegisterFunction(Func: String); overload; virtual;
    procedure RegisterFunction(Func, FuncName: String); overload; virtual;

    class procedure RegisterFunctions(L: lua_State; AClass: TClass); overload; virtual;
    class procedure RegisterFunctions(L: lua_State; AObject: TObject); overload; virtual;

    // automatically register all functions published by a class or an object
    procedure RegisterFunctions(AClass: TClass); overload; virtual;
    procedure RegisterFunctions(AObject: TObject); overload; virtual;

    // ***
    // package register functions
    // ***
    // Register all published functions for a Package table on the stack
    class procedure RegisterPackageFunctions(L: lua_State; AObject: TObject); overload; virtual;

    // Register a Package with a specific package loader (cdecl static function)
    class procedure RegisterPackage(L: lua_State; PackageName: String; InitFunc: lua_CFunction); overload; virtual;
    procedure RegisterPackage(PackageName: String; InitFunc: lua_CFunction); overload; inline;

    // Register a Package with a specific object package loader
    class procedure RegisterPackage(L: lua_State; PackageName: String; AObject: TObject; PackageLoader: String); overload; virtual;
    procedure RegisterPackage(PackageName: String; AObject: TObject; PackageLoader: String); overload; inline;

    // Register a Package with the default package loader (auto register all published functions)
    class procedure RegisterPackage(L: lua_State; PackageName: String; AObject: TObject); overload; virtual;
    procedure RegisterPackage(PackageName: String; AObject: TObject); overload; inline;

    // ***
    // library functions
    // ***
    class procedure LoadLuaLibrary(const LibraryPath: String); virtual;
    class procedure FreeLuaLibrary; virtual;
    class function LuaLibraryLoaded: Boolean; virtual;

    // ***
    // properties
    // ***
    property AutoRegister: Boolean read FAutoRegister write FAutoRegister;
    property FilePath: String read FFilePath write FFilePath;
    property LibraryPath: String read FLibraryPath write FLibraryPath;
    property OnPrint: TOnLuaPrint read FOnPrint write FOnPrint;
    property Opened: Boolean read FOpened;
    property LuaState: Lua_State read FLuaState write FLuaState;

  published
    function print(L: Lua_State): Integer; virtual;
  end;


implementation

uses
  System.TypInfo, FMx.Dialogs;

type
  TLuaProc = function(L: Lua_State): Integer of object; // Lua Function

var
  LibraryHandle: HMODULE;

{*
** Message handler used to run all chunks
*}
function MsgHandler(L: Lua_State): Integer; cdecl;
var
  Msg: MarshaledAString;
begin
  Msg := lua_tostring(L, 1);
  if (Msg = NIL) then  //* is error object not a string?
    if (luaL_callmeta(L, 1, '__tostring') <> 0) and  //* does it have a metamethod */
        (lua_type(L, -1) = LUA_TSTRING) then  //* that produces a string? */
      begin
        Result := 1;  //* that is the message */}
        Exit;
      end
    else
      Msg := lua_pushfstring(L, '(error object is a %s value)',
                               [luaL_typename(L, 1)]);

  luaL_traceback(L, L, Msg, 1);  //* append a standard traceback */
  Result := 1; //* return the traceback */
end;

//
// This function is called by Lua, it extracts the object by
// pointer to the objects method by name, which is then called.
//
// @param       Lua_State   L   Pointer to Lua instance
// @return      Integer         Number of result arguments on stack
//
function LuaCallBack(L: Lua_State): Integer; cdecl;
var
  Routine: TMethod; // Code and Data for the call back method
begin
  // Retrieve closure values (=object Pointer)
  Routine.Data := lua_topointer(L, lua_upvalueindex(1));
  Routine.Code := lua_topointer(L, lua_upvalueindex(2));

  // Call object function
  Result := TLuaProc(Routine)(L);
end;


function LuaLoadPackage(L: Lua_State): Integer; cdecl;
var
  Obj: TObject;
begin
  // Retrieve closure values (=object Pointer)
  Obj := lua_topointer(L, lua_upvalueindex(1));

  // Create new table
  lua_newtable(L);

  // Register Package functions
  TVerySimpleLua.RegisterPackageFunctions(L, Obj);

  // Return table
  Result := 1;
end;


{ TVerySimpleLua }



procedure TVerySimpleLua.Close;
begin
  if not FOpened then
    Exit;

  FOpened := False;

  // Close instance
  Lua_Close(LuaState);
end;

constructor TVerySimpleLua.Create;
begin
  FAutoRegister := True;

  {$IF defined(IOS)}
  FilePath := TPath.GetDocumentsPath + PathDelim;
  {$ELSEIF defined(ANDROID)}
  LibraryPath := IncludeTrailingPathDelimiter(System.IOUtils.TPath.GetLibraryPath) + LUA_LIBRARY;
  FilePath := TPath.GetDocumentsPath + PathDelim;
  {$ENDIF}
end;


//
// Dispose Lua instance
//

destructor TVerySimpleLua.Destroy;
begin
  Close;
  inherited;
end;


//
// Wrapper for Lua File load and Execution
//
// @param       String  Filename        Lua Script file name
// @return      Integer
//

function TVerySimpleLua.DoChunk(L: Lua_State; Status: Integer): Integer;
begin
  if Status = LUA_OK then
    Status := DoCall(L, 0, 0);
  Result := Status;
end;

{*
** Interface to 'lua_pcall', which sets appropriate message function
** and C-signal handler. Used to run all chunks.
*}
function TVerySimpleLua.DoCall(L: Lua_State; NArg, NRes: Integer): Integer;
var
  Status: Integer;
  Base: Integer;
begin
  Base := lua_gettop(L) - NArg;  // function index
  lua_pushcfunction(L, msghandler);  // push message handler
  lua_insert(L, base);  // put it under function and args
  Status := lua_pcall(L, narg, nres, base);
  lua_remove(L, base);  // remove message handler from the stack */
  Result := Status;
end;

function TVerySimpleLua.DoFile(Filename: String): Integer;
var
  Marshall: TMarshaller;
  Path: String;
begin
  if not Opened then
    Open;

  Path := FilePath + FileName;
  Result := dochunk(LuaState, lual_loadfile(LuaState, Marshall.AsAnsi(Path).ToPointer));
end;



procedure TVerySimpleLua.DoPrint(Msg: String);
begin
  if Assigned(FOnPrint) then
    FOnPrint(Msg)
  else
    Writeln(Msg);
end;

function TVerySimpleLua.DoString(Value: String): Integer;
var
  Marshall: TMarshaller;
begin
  if not Opened then
    Open;

  Result := luaL_dostring(LuaState, Marshall.AsAnsi(Value).ToPointer);
end;


function TVerySimpleLua.Run: Integer;
begin
  Result := dochunk(LuaState, LUA_OK);
end;




class procedure TVerySimpleLua.RegisterFunction(L: lua_State; Func: lua_CFunction;
  FuncName: String);
var
  Marshall: TMarshaller;
begin
  lua_register(L, Marshall.AsAnsi(FuncName).ToPointer, Func);
end;

class procedure TVerySimpleLua.PushFunction(L: lua_State; Data, Code: Pointer; FuncName: String);
var
  Marshall: TMarshaller;
begin
  // prepare Closure value (Method Name)
  lua_pushstring(L, Marshall.AsAnsi(FuncName).ToPointer);

  // prepare Closure value (CallBack Object Pointer)
  lua_pushlightuserdata(L, Data);
  lua_pushlightuserdata(L, Code);

  // set new Lua function with Closure values
  lua_pushcclosure(L, LuaCallBack, 2);
end;


class procedure TVerySimpleLua.RegisterFunction(L: lua_State; Data, Code: Pointer; FuncName: String);
var
  Marshall: TMarshaller;
begin
  PushFunction(L, Data, Code, FuncName);

  // set table using the method's name
  lua_setglobal(L, Marshall.AsAnsi(FuncName).ToPointer);
end;


class procedure TVerySimpleLua.RegisterFunction(L: lua_State; AObject: TObject; Func, FuncName: String);
begin
  RegisterFunction(L, AObject, AObject.MethodAddress(Func), FuncName);
end;

class procedure TVerySimpleLua.RegisterClassFunction(L: lua_State; AObject: TObject; Func, FuncName: String);
begin
  RegisterFunction(L, AObject.ClassType, AObject.ClassType.MethodAddress(Func), FuncName);
end;


class procedure TVerySimpleLua.RegisterFunction(L: lua_State; AClass: TClass; Func, FuncName: String);
begin
  RegisterFunction(L, AClass.MethodAddress(Func), FuncName);
end;

procedure TVerySimpleLua.RegisterFunction(Func: lua_CFunction;FuncName: String);
begin
  RegisterFunction(LuaState, Func, FuncName);
end;

procedure TVerySimpleLua.RegisterFunction(AClass: TClass; Func: String);
begin
  RegisterFunction(LuaState, AClass.MethodAddress(Func), Func);
end;

procedure TVerySimpleLua.RegisterFunction(AClass: TClass; Func, FuncName: String);
begin
  RegisterFunction(LuaState, AClass.MethodAddress(Func), FuncName);
end;


procedure TVerySimpleLua.RegisterFunction(AObject: TObject; Func, FuncName: String);
begin
  RegisterFunction(LuaState, AObject, Func, FuncName);
end;

procedure TVerySimpleLua.RegisterFunction(AObject: TObject; Func: String);
begin
  RegisterFunction(LuaState, AObject, Func, Func);
end;

procedure TVerySimpleLua.RegisterFunction(Func: String);
begin
  RegisterFunction(LuaState, self, Func, Func);
end;

procedure TVerySimpleLua.RegisterFunction(Func, FuncName: String);
begin
  RegisterFunction(LuaState, self, Func, FuncName);
end;



class procedure TVerySimpleLua.RegisterFunctions(L: lua_State; AClass: TClass);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
begin
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(AClass);
    for LMethod in LType.GetMethods do
      if ValidMethod(LMethod) then
        RegisterFunction(L, AClass, LMethod.Name, LMethod.Name);
  finally
    LContext.Free;
  end;
end;

class function TVerySimpleLua.ValidMethod(Method: TRttiMethod): Boolean;
var
  Params: TArray<TRttiParameter>;
  Param: TRttiParameter;
begin
  Result := False;

  // Only published functions with an Integer result allowed
  if (Method.Visibility <> mvPublished) or (not Assigned(Method.ReturnType)) or
    (Method.ReturnType.TypeKind <> tkInteger) then
      Exit;

  // Only functions with 1 parameter allowed
  Params := Method.GetParameters;
  if Length(Params) <> 1 then
    Exit;

  // Only functions with a Pointer as parameter allowed
  Param := Params[0];
  if Param.ParamType.TypeKind <> tkPointer then
    Exit;

  Result := True;
end;


class procedure TVerySimpleLua.RegisterFunctions(L: lua_State; AObject: TObject);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
begin
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(AObject.ClassType);
    for LMethod in LType.GetMethods do
    begin
      // Only published functions with an Integer result allowed
      if not ValidMethod(LMethod) then
        Continue;

      // Register the method based on calling convention and method kind
      if LMethod.MethodKind = mkFunction then
          RegisterFunction(L, AObject, AObject.MethodAddress(LMethod.Name), LMethod.Name)
        else
        if LMethod.MethodKind = mkClassFunction then
          if (LMethod.IsStatic) and (LMethod.CallingConvention = ccCdecl) then
              RegisterFunction(L, lua_CFunction(AObject.MethodAddress(LMethod.Name)), LMethod.Name)
            else
              RegisterFunction(L, AObject.ClassType, AObject.ClassType.MethodAddress(LMethod.Name), LMethod.Name);
    end;
  finally
    LContext.Free;
  end;
end;

class procedure TVerySimpleLua.RegisterPackageFunctions(L: lua_State; AObject: TObject);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
begin
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(AObject.ClassType);
    for LMethod in LType.GetMethods do
    begin
      // Only published functions with an Integer result allowed
      if not ValidMethod(LMethod) then
        Continue;

       PushFunction(L, AObject, LMethod.CodeAddress, LMethod.Name);
       lua_rawset(L, -3);
    end;
  finally
    LContext.Free;
  end;
end;


class procedure TVerySimpleLua.RegisterPackage(L: lua_State; PackageName: String; AObject: TObject);
var
  Marshall: TMarshaller;
begin
  lua_getglobal(L, 'package');  // get local package table
  lua_getfield(L, -1 , 'preload');  // get preload field

  // prepare Closure value (Object Object Pointer)
  lua_pushlightuserdata(L, AObject);

  // set new Lua function with Closure values
  lua_pushcclosure(L, LuaLoadPackage, 1);

  lua_setfield(L, -2 , Marshall.AsAnsi(PackageName).ToPointer);
  lua_pop(L, 2);
end;

procedure TVerySimpleLua.RegisterFunctions(AClass: TClass);
begin
  RegisterFunctions(LuaState, AClass);
end;

procedure TVerySimpleLua.RegisterFunctions(AObject: TObject);
begin
  RegisterFunctions(LuaState, AObject);
end;



// *******************************
// Package registration procedures
// *******************************

class procedure TVerySimpleLua.RegisterPackage(L: lua_State; PackageName: String;
  InitFunc: lua_CFunction);
var
  Marshall: TMarshaller;
begin
  lua_getglobal(L, 'package');  // get local package table
  lua_getfield(L, -1 , 'preload');  // get preload field
  lua_pushcfunction(L, InitFunc);
  lua_setfield(L, -2 , Marshall.AsAnsi(PackageName).ToPointer);
  lua_pop(L, 2);
end;

procedure TVerySimpleLua.RegisterPackage(PackageName: String; InitFunc: lua_CFunction);
begin
  RegisterPackage(LuaState, PackageName, InitFunc);
end;


class procedure TVerySimpleLua.RegisterPackage(L: lua_State; Data, Code: Pointer; PackageName: String);
var
  Marshall: TMarshaller;
begin
  lua_getglobal(L, 'package');  // get local package table
  lua_getfield(L, -1 , 'preload');  // get preload field

  // prepare Closure value (CallBack Object Pointer)
  lua_pushlightuserdata(L, Data);
  lua_pushlightuserdata(L, Code);

  // set new Lua function with Closure values
  lua_pushcclosure(L, LuaCallBack, 2);

  lua_setfield(L, -2 , Marshall.AsAnsi(PackageName).ToPointer);
  lua_pop(L, 2);
end;


procedure TVerySimpleLua.RegisterPackage(PackageName: String; AObject: TObject);
begin
  RegisterPackage(LuaState, PackageName, AObject);
end;

class procedure TVerySimpleLua.RegisterPackage(L: lua_State; PackageName: String; AObject: TObject;
  PackageLoader: String);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LMethod: TRttiMethod;
  Address: Pointer;
begin
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(AObject.ClassType);
    LMethod := LType.GetMethod(PackageLoader);
    Address := LMethod.CodeAddress;
    RegisterPackage(L, AObject, Address, PackageName);
  finally
    LContext.Free;
  end;
end;

procedure TVerySimpleLua.RegisterPackage(PackageName: String; AObject: TObject; PackageLoader: String);
begin
  RegisterPackage(LuaState, PackageName, AObject, PackageLoader);
end;


(*
** Dynamic library manipulation
*)


function GetAddress(Name: String): Pointer;
begin
  Result := GetProcAddress(LibraryHandle, PWideChar(Name));
  if not Assigned(Result) then
    raise ELuaLibraryMethodNotFound.Create('Entry point "' + QuotedStr(Name) + '" not found');
end;


function TVerySimpleLua.LoadFile(Filename: String): Integer;
var
  Marshall: TMarshaller;
begin
  Result := lual_loadfile(LuaState, Marshall.AsAnsi(Filename).ToPointer);
end;

class procedure TVerySimpleLua.LoadLuaLibrary(const LibraryPath: String);
var
  LoadPath: String;
begin
  FreeLuaLibrary;

  if LibraryPath = '' then
    LoadPath := LUA_LIBRARY
  else
    LoadPath := LibraryPath;

{$IFNDEF STATICLIBRARY}

  // check if Library exists
  if not FileExists(LoadPath) then
    raise ELuaLibraryNotFound.Create('Lua library "' + QuotedStr(LoadPath) + '" not found');

  // try to load the library
  LibraryHandle := LoadLibrary(PChar(LoadPath));
  if LibraryHandle = 0 then
    raise ELuaLibraryLoadError.Create('Failed to load Lua library "' + QuotedStr(LoadPath) + '"'
      {$IF defined(POSIX)} + (String(dlerror)){$ENDIF});

  lua_newstate := GetAddress('lua_newstate');
  lua_close := GetAddress('lua_close');
  lua_newthread := GetAddress('lua_newthread');
  lua_atpanic := GetAddress('lua_atpanic');
  lua_version := GetAddress('lua_version');

  lua_absindex := GetAddress('lua_absindex');
  lua_gettop := GetAddress('lua_gettop');
  lua_settop := GetAddress('lua_settop');
  lua_pushvalue := GetAddress('lua_pushvalue');
  lua_rotate := GetAddress('lua_rotate');
  lua_copy := GetAddress('lua_copy');
  lua_checkstack := GetAddress('lua_checkstack');
  lua_xmove  := GetAddress('lua_xmove');

  lua_isnumber := GetAddress('lua_isnumber');
  lua_isstring := GetAddress('lua_isstring');
  lua_iscfunction := GetAddress('lua_iscfunction');
  lua_isinteger := GetAddress('lua_isinteger');
  lua_isuserdata := GetAddress('lua_isuserdata');
  lua_type  := GetAddress('lua_type');
  lua_typename := GetAddress('lua_typename');

  lua_tonumberx := GetAddress('lua_tonumberx');
  lua_tointegerx := GetAddress('lua_tointegerx');
  lua_toboolean := GetAddress('lua_toboolean');
  lua_tolstring := GetAddress('lua_tolstring');
  lua_rawlen := GetAddress('lua_rawlen');
  lua_tocfunction := GetAddress('lua_tocfunction');
  lua_touserdata := GetAddress('lua_touserdata');
  lua_tothread := GetAddress('lua_tothread');
  lua_topointer := GetAddress('lua_topointer');

  lua_arith := GetAddress('lua_arith');
  lua_rawequal := GetAddress('lua_rawequal');
  lua_compare := GetAddress('lua_compare');

  lua_pushnil := GetAddress('lua_pushnil');
  lua_pushnumber := GetAddress('lua_pushnumber');
  lua_pushinteger := GetAddress('lua_pushinteger');
  lua_pushlstring := GetAddress('lua_pushlstring');
  lua_pushstring := GetAddress('lua_pushstring');
  lua_pushvfstring := GetAddress('lua_pushvfstring');
  lua_pushfstring := GetAddress('lua_pushfstring');
  lua_pushcclosure := GetAddress('lua_pushcclosure');
  lua_pushboolean := GetAddress('lua_pushboolean');
  lua_pushlightuserdata := GetAddress('lua_pushlightuserdata');
  lua_pushthread := GetAddress('lua_pushthread');

  lua_getglobal := GetAddress('lua_getglobal');
  lua_gettable := GetAddress('lua_gettable');
  lua_getfield := GetAddress('lua_getfield');
  lua_geti := GetAddress('lua_geti');
  lua_rawget := GetAddress('lua_rawget');
  lua_rawgeti := GetAddress('lua_rawgeti');
  lua_rawgetp := GetAddress('lua_rawgetp');

  lua_createtable := GetAddress('lua_createtable');
  lua_newuserdata := GetAddress('lua_newuserdata');
  lua_getmetatable := GetAddress('lua_getmetatable');
  lua_getuservalue := GetAddress('lua_getuservalue');

  lua_setglobal := GetAddress('lua_setglobal');
  lua_settable := GetAddress('lua_settable');
  lua_setfield := GetAddress('lua_setfield');
  lua_seti := GetAddress('lua_seti');
  lua_rawset := GetAddress('lua_rawset');
  lua_rawseti := GetAddress('lua_rawseti');
  lua_rawsetp := GetAddress('lua_rawsetp');
  lua_setmetatable := GetAddress('lua_setmetatable');
  lua_setuservalue := GetAddress('lua_setuservalue');

  lua_callk := GetAddress('lua_callk');
  lua_pcallk := GetAddress('lua_pcallk');
  lua_load := GetAddress('lua_load');
  lua_dump := GetAddress('lua_dump');

  lua_yieldk := GetAddress('lua_yieldk');
  lua_resume := GetAddress('lua_resume');
  lua_status := GetAddress('lua_status');
  lua_isyieldable := GetAddress('lua_isyieldable');

  lua_gc := GetAddress('lua_gc');

  lua_error := GetAddress('lua_error');
  lua_next := GetAddress('lua_next');
  lua_concat := GetAddress('lua_concat');
  lua_len := GetAddress('lua_len');

  lua_stringtonumber := GetAddress('lua_stringtonumber');
  lua_getallocf := GetAddress('lua_getallocf');
  lua_setallocf := GetAddress('lua_setallocf');

  lua_getstack := GetAddress('lua_getstack');
  lua_getinfo := GetAddress('lua_getinfo');
  lua_getlocal := GetAddress('lua_getlocal');
  lua_setlocal := GetAddress('lua_setlocal');
  lua_getupvalue := GetAddress('lua_getupvalue');
  lua_setupvalue := GetAddress('lua_setupvalue');
  lua_upvalueid := GetAddress('lua_upvalueid');
  lua_upvaluejoin := GetAddress('lua_upvaluejoin');

  lua_sethook := GetAddress('lua_sethook');
  lua_gethook := GetAddress('lua_gethook');
  lua_gethookmask := GetAddress('lua_gethookmask');
  lua_gethookcount := GetAddress('lua_gethookcount');

  luaopen_base := GetAddress('luaopen_base');
  luaopen_coroutine := GetAddress('luaopen_coroutine');
  luaopen_table := GetAddress('luaopen_table');
  luaopen_io := GetAddress('luaopen_io');
  luaopen_os := GetAddress('luaopen_os');
  luaopen_string := GetAddress('luaopen_string');
  luaopen_utf8 := GetAddress('luaopen_utf8');
  luaopen_bit32 := GetAddress('luaopen_bit32');
  luaopen_math := GetAddress('luaopen_math');
  luaopen_debug := GetAddress('luaopen_debug');
  luaopen_package := GetAddress('luaopen_package');

  luaL_openlibs := GetAddress('luaL_openlibs');

  luaL_checkversion_ := GetAddress('luaL_checkversion_');
  luaL_getmetafield := GetAddress('luaL_getmetafield');
  luaL_callmeta := GetAddress('luaL_callmeta');
  luaL_tolstring := GetAddress('luaL_tolstring');
  luaL_argerror := GetAddress('luaL_argerror');
  luaL_checklstring := GetAddress('luaL_checklstring');
  luaL_optlstring := GetAddress('luaL_optlstring');
  luaL_checknumber := GetAddress('luaL_checknumber');
  luaL_optnumber := GetAddress('luaL_optnumber');
  luaL_checkinteger := GetAddress('luaL_checkinteger');
  luaL_optinteger := GetAddress('luaL_optinteger');

  luaL_checkstack := GetAddress('luaL_checkstack');
  luaL_checktype := GetAddress('luaL_checktype');
  luaL_checkany := GetAddress('luaL_checkany');

  luaL_newmetatable := GetAddress('luaL_newmetatable');
  luaL_setmetatable := GetAddress('luaL_setmetatable');
  luaL_testudata := GetAddress('luaL_testudata');
  luaL_checkudata := GetAddress('luaL_checkudata');

  luaL_where := GetAddress('luaL_where');
  luaL_error := GetAddress('luaL_error');

  luaL_checkoption := GetAddress('luaL_checkoption');
  luaL_fileresult := GetAddress('luaL_fileresult');
  luaL_execresult := GetAddress('luaL_execresult');

  luaL_ref := GetAddress('luaL_ref');
  luaL_unref := GetAddress('luaL_unref');

  luaL_loadfilex := GetAddress('luaL_loadfilex');
  luaL_loadbufferx := GetAddress('luaL_loadbufferx');
  luaL_loadstring := GetAddress('luaL_loadstring');
  luaL_newstate := GetAddress('luaL_newstate');
  luaL_len := GetAddress('luaL_len');

  luaL_gsub := GetAddress('luaL_gsub');
  luaL_setfuncs := GetAddress('luaL_setfuncs');

  luaL_getsubtable := GetAddress('luaL_getsubtable');
  luaL_traceback := GetAddress('luaL_traceback');
  luaL_requiref := GetAddress('luaL_requiref');

  luaL_buffinit := GetAddress('luaL_buffinit');
  luaL_prepbuffsize := GetAddress('luaL_prepbuffsize');
  luaL_addlstring := GetAddress('luaL_addlstring');
  luaL_addstring := GetAddress('luaL_addstring');
  luaL_addvalue := GetAddress('luaL_addvalue');
  luaL_pushresult := GetAddress('luaL_pushresult');
  luaL_pushresultsize := GetAddress('luaL_pushresultsize');
  luaL_buffinitsize := GetAddress('luaL_buffinitsize');
{$ENDIF}
end;

class function TVerySimpleLua.LuaLibraryLoaded: Boolean;
begin
  Result := (LibraryHandle <> 0);
end;


procedure TVerySimpleLua.Open;
begin
  if FOpened then
    Exit;

  FOpened := True;

  // Load Lua Lib if not already done
  if not LuaLibraryLoaded then
    LoadLuaLibrary(LibraryPath);

  // Open Library
  LuaState := lual_newstate; // opens Lua
  lual_openlibs(LuaState); // load all libs

  // register all published functions
   if FAutoRegister then
     RegisterFunctions(Self);
end;

class procedure TVerySimpleLua.FreeLuaLibrary;
begin
  if LibraryHandle <> 0 then
  begin
    FreeLibrary(LibraryHandle);
    LibraryHandle := 0;
  end;
end;


function TVerySimpleLua.Print(L: Lua_State): Integer;
var
  N, I: Integer;
  S: MarshaledAString;
  Sz: size_t;
  Msg: String;
begin
  Msg := '';

  N := lua_gettop(L);  //* number of arguments */
  lua_getglobal(L, 'tostring');
  for I := 1 to N do
  begin
    lua_pushvalue(L, -1);  //* function to be called */
    lua_pushvalue(L, i);   //* value to print */
    lua_call(L, 1, 1);
    S := lua_tolstring(L, -1, @Sz);  //* get result */
    if S = NIL then
    begin
      Result := luaL_error(L, '"tostring" must return a string to "print"',[]);
      Exit;
    end;

    if I > 1 then
      Msg := Msg + #9;
    Msg := Msg + String(S);
    lua_pop(L, 1);  //* pop result */
  end;
  Result := 0;

  DoPrint(Msg);
end;


initialization
  LibraryHandle := 0;

finalization
  if LibraryHandle <> 0 then
    TVerySimpleLua.FreeLuaLibrary;
end.
