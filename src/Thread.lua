-- Wolfe Labs DU Core Library: Thread
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

--[[
  This script is intended to implement a healthy way of working with multiple threads inside Dual Universe, while being inside the CPU time limits as much as possible
]]--

local Class = require('Class')

-- The Thread class
local Thread = {
  maxIterationsBeforeYield = 5000,
  maxCpuTimePerTick = 0.003, -- Limits the max CPU usage per update in seconds, this only works if your loops actually implement the next() function
}

-- This object MUST be a global, it will handle all scheduling of threads
ThreadScheduler = {
  pool = {},
  poolNextId = 0,
}

-- Class constructor, it's main usage is to setup the Thread's coroutine in question
function Thread.__constructor (self, worker, options)
  -- Handles options bla bla bla
  options = options or {}
  self.options = {
    maxIterationsBeforeYield = options.maxIterationsBeforeYield or Thread.maxIterationsBeforeYield,
  }

  -- Gets a nice ID for our thread
  ThreadScheduler.poolNextId = ThreadScheduler.poolNextId + 1
  self.id = ThreadScheduler.poolNextId

  -- Adds to Thread Pool
  ThreadScheduler.pool[self.id] = self

  -- Starts the CPU timer for the first time
  self.cpuLastTimed = nil

  -- The iteration counter
  self.iter = 0

  -- Creates the actual coroutine
  self._coroutine = coroutine.create(function ()
    -- Invokes the actual routine, passing the Thread as argument
    worker(self)
  
    -- Handles when the Thread ends
    ThreadScheduler.pool[self.id] = nil
    collectgarbage('collect')
  end)
end

-- This resumes a Thread and is called by the Scheduler automatically
function Thread:resume ()
  -- Resets the CPU time counter for next tick (only when nil, which means it DID a yield)
  if not self.cpuLastTimed then
    self.cpuLastTimed = system.getTime()
  end

  -- Continues the coroutine
  coroutine.resume(self._coroutine)
end

-- This MUST be called at loops, is possible at start, and will apply coroutine.yield() automatically whenever needed
function Thread:next ()
  -- Updates iteration number
  self.iter = (self.iter + 1) % self.options.maxIterationsBeforeYield

  -- Gets current CPU time and compares it to the maximum per-tick value, yields if needed
  if (self:getCpuTime() >= Thread.maxCpuTimePerTick) or (0 == self.iter) then
    self:cleanup()
  end
end

-- This resets a Thread's counters for timers and also triggers an yield
function Thread:cleanup ()
  self.cpuLastTimed = nil
  coroutine.yield()
end

-- Gets CPU time of current tick in seconds
function Thread:getCpuTime ()
  return system.getTime() - self.cpuLastTimed
end

-- Gets CPU time of current tick as a slice of current frame
function Thread:getCpuTimeSlice ()
  return self:getCpuTime() / system.getActionUpdateDeltaTime()
end

-- Actually ticks the Threads via the Scheduler
function ThreadScheduler.next ()
  if ThreadScheduler.pool[1] then
    ThreadScheduler.pool[1]:resume()
  end
end

-- Returns the Thread class
return Class.new('Thread', Thread)