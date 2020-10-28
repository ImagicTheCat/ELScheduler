-- create n timers
-- params: [n]

package.path = "src/?.lua"
local Scheduler = require("ELScheduler")

local n = ...
n = tonumber(n) or 1e3

local scheduler = Scheduler()

print("create "..n.." timers")
local timers = {}
for i=1,n do
  table.insert(timers, scheduler:timer(0,-1,cb_inc))
end

collectgarbage("collect")
print("GC count = "..collectgarbage("count").." kB")
