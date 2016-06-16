-- a debug inspect function

function inspect(table, name)
  print ("--- " .. name .. " consists of");
  for n,v in pairs(table) do print(n, v) end;
  print();
end


-- show currently loaded packages

inspect(package['preload'],'package[preload]');


-- now "load" two packages

MyPackage = require "MyPackage";
MyPackage2 = require "MyPackage2";


-- show their content

inspect(MyPackage, "MyPackage");
inspect(MyPackage2, "MyPackage2");


-- and exceute some functions


p1 = MyPackage:Myfunction1();
print (p1);

p1 = MyPackage:Myfunction2();
print (p1);


p1 = MyPackage2:Double(100);
print (p1);

