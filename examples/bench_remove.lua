-- create n timers and remove them
-- params: [n]

package.path = ";src/?.lua;"..package.path
local Scheduler = require("ELScheduler")

local n = ...
n = tonumber(n) or 1e3

local scheduler = Scheduler()

local count = 0
local function cb_inc(timer)
  count = count+1
end

print("create "..n.." timers")
local timers = {}
for i=1,n do
  table.insert(timers, scheduler:timer(0,-1,cb_inc))
end

print("remove "..n.." timers")
for _, timer in ipairs(timers) do timer:remove() end

print("do 10 ticks")
for i=1,10 do
  scheduler:tick(i)
end

print("count = "..count)
