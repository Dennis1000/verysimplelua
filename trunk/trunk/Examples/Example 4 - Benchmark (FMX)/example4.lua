print("Starting benchmark1");

RunEachSeconds=20;



i=0;
count=0;

Start(RunEachSeconds);
repeat
  i=i+1; 
  count=count+HelloWorld(i);
until Finished();
assert(count~=0);

print (i/RunEachSeconds, ' object function calls/second');



k=0;
count=0;
Start(RunEachSeconds);
repeat
  k=k+1; 
  count=count+HelloWorld3(k);
until Finished();
assert(count~=0);

print (k/RunEachSeconds, ' static function calls/second ' .. string.format("%.2f",(k*100/i)-100) .. '%');


