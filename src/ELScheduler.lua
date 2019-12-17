-- https://github.com/ImagicTheCat/ELScheduler
-- MIT license (see LICENSE)

--[[
MIT License

Copyright (c) 2019 ImagicTheCat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--=[ Scheduler ]=--

local Scheduler = {}

-- PRIVATE METHODS

local function scheduler_add(self, timer)
  -- iteration decrement
  if timer.count > 0 then timer.count = timer.count-1 end

  -- add
  timer.wake = self.time+timer.delay

  --- binary heap insert
  local timers = self.timers

  table.insert(timers, timer)
  timer.index = #timers

  local current, parent = timer.index, math.floor(timer.index/2)
  while parent > 0 and timers[parent].wake > timers[current].wake do -- heapify
    -- swap
    timers[parent], timers[current] = timers[current], timers[parent]
    -- update indexes
    timers[parent].index, timers[current].index = parent, current
    -- next: parent
    current, parent = parent, math.floor(parent/2)
  end
end

-- get smallest child of a node
-- return (timer,index)
local function get_smallest_child(self, index)
  local c1, c2 = self.timers[index*2], self.timers[index*2+1]
  if c2 then
    if c1.wake < c2.wake then return c1, index*2
    else return c2, index*2+1 end
  else
    return c1, index*2
  end
end

-- delete a heap node
local function scheduler_heap_delete(self, index)
  -- binary heap delete
  local timers = self.timers

  timers[index].index = nil
  if index == #timers then -- remove last node
    table.remove(timers)
  else -- remove by replacing the node
    timers[index] = table.remove(timers) -- replace
    timers[index].index = index

    local child, cindex = get_smallest_child(self, index)
    while child and timers[index].wake > child.wake do -- heapify
      -- swap
      timers[index], timers[cindex] = child, timers[index]
      -- update indexes
      timers[index].index, timers[cindex].index = index, cindex
      -- next: child
      index = cindex
      child, cindex = get_smallest_child(self, index)
    end
  end
end

-- METHODS

----=[ Timer ]=--

local Timer = {}

-- remove the timer
-- (safe to call multiple times)
function Timer:remove()
  if self.index then
    scheduler_heap_delete(self.scheduler, self.index)
  end
end

-- create a timer
-- delay: can be <= 0 for instantaneous timers (numeric type)
-- count: (optional) number of iterations (default: 1, infinite: -1)
-- callback(timer): called when the timer is triggered
-- return timer
function Scheduler:timer(delay, count, callback)
  local timer = setmetatable({
    delay = delay,
    count = callback and count or 1,
    callback = callback or count,
    scheduler = self
  }, { __index = Timer })

  if timer.count ~= 0 then
    scheduler_add(self, timer)
  end

  return timer
end

-- do a scheduler tick
-- time: current time (numeric type)
function Scheduler:tick(time)
  -- update time
  if time > self.time then -- valid
    self.time = time
  else -- invalid
    time = self.time
  end

  -- check timers
  local timers = self.timers
  local triggers = {}

  local timer = timers[1] -- root
  while timer and time >= timer.wake do
    -- mark/remove timer
    table.insert(triggers, timer)
    scheduler_heap_delete(self, 1)
    timer = timers[1] -- next root
  end

  -- repeat timers/trigger callbacks
  for _, timer in ipairs(triggers) do
    if timer.count ~= 0 then -- repeat timer
      scheduler_add(self, timer)
    end
    timer:callback()
  end
end

return setmetatable({}, {
  __call = function(t, time)
    -- create scheduler
    -- time: (optional) init time (numeric type, default: 0)
    return setmetatable({
      timers = {}, -- binary heap (as array)
      time = time or 0
    }, { __index = Scheduler })
  end
})
