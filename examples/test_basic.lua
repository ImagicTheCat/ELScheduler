package.path = ";src/?.lua;"..package.path
local Scheduler = require("ELScheduler")

local scheduler = Scheduler()

print("[test order]")

for i=0,3 do
  scheduler:timer(i, function() print(i) end)
  scheduler:timer(i+0.5, function() print(i+0.5) end)
end

for i=1,10 do
  scheduler:tick(i)
end
