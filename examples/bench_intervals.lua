-- create n interval timers with a growing delay and do n ticks
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
for i=1,n do
  scheduler:timer(i,-1,cb_inc)
end

print("do "..n.." ticks")
for i=1,n do
  scheduler:tick(i)
end

print("count = "..count)
