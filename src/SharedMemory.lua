-- Wolfe Labs DU Core Library: Shared Memory
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

-- We need to load the main script headers here
-- local json = require('dkjson')
local Utils = require('Utils')
local Class = require('Class')
local Events = require('Events')

-- The SharedMemory prototype
local SharedMemory = {
  isProcessing = false,
  lastTrigger = 0,
}

function SharedMemory:__constructor (databank, a1)
  -- Sets the databank
  self.db = databank

  -- We need to have a 'memory_storage' slot in place
  if not self.db then
    error('To enable Shared Memory, please include a Databank in a slot called "memory_storage"')
  end

  -- Hooks events
  Events.Global:on('flush', function ()
    local trigger = self.db.getIntValue('__shared_memory_trigger')
    if (not trigger == SharedMemory.lastTrigger) and (SharedMemory.isProcessing == false) then
      -- Debouncing
      SharedMemory.isProcessing = true
      SharedMemory.lastTrigger = trigger

      -- Add some time padding before next detection so we don't lag the server or clients
      unit.setTimer('shared_memory', 0.100)

      -- Triggers memory event
      self:trigger('sharedMemoryChanged')
    end
  end)

  Events.Global:on('tick', function (timer)
    if timer == 'shared_memory' then
      -- Debouncing
      SharedMemory.isProcessing = false

      -- Cleanup timer
      unit.stopTimer('shared_memory')
    end
  end)
end

function SharedMemory:read (key)
  if self.db.hasKey(key) then
    local result = json.decode(self.db.getStringValue(key))
    if type(result) == 'table' then
      return result
    else
      return {}
    end
  else
    return {}
  end
end

function SharedMemory:save (key, value)
  self.db.setStringValue(key, json.encode(value))
  self.db.setFloatValue('__shared_memory_trigger', system.getTime())
  self:trigger('sharedMemoryChanged')
end

-- Returns the proper class
return Class.new('SharedMemory', SharedMemory, Events)