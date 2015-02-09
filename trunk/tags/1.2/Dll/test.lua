
LuaDelphi = package.loadlib("LuaDelphi.dll","libinit")
if not LuaDelphi then print 'cannot load LuaDelphi.dll!!' end
LuaDelphi();

print "LuaDelphi loaded.";

p1,p2 = HelloWorld(1,2,3);
print "Results:";
print (p1);
print (p2);

HelloWorld2();
HelloWorld3();

print "This is the end.";
