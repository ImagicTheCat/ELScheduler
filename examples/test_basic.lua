package.path = "src/?.lua"
local Scheduler = require("ELScheduler")

local scheduler = Scheduler()

print("[test order]")
local n = 1e3
local prev = 0
local count = 0

-- create timers
for i=1,n,0.5 do
  count = count+1
  scheduler:timer(i, function()
    assert(prev < i, "wrong order")
    prev, count = i, count-1
  end)
end
-- random insertions/deletions
for i=1,300 do
  scheduler.timers[math.random(1, #scheduler.timers)]:remove()
  scheduler:timer(math.random(1, 1000), function() count = count-1 end)
end
-- perform ticks
for i=1,n do scheduler:tick(i) end
assert(count == 0, "wrong trigger count")
