unit SomeClass;

interface

{$M+}

uses
  Lua;

type
  TSomeClass = Class
  published
    function HelloWorld5(LuaState: TLuaState): Integer;
  end;

implementation

{ TSomeClass }

function TSomeClass.HelloWorld5(LuaState: TLuaState): Integer;
begin
  writeln('Hello World5 from SomeClass');
  result := 0;
end;



end.
