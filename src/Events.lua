-- Wolfe Labs DU Core Library: Events
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

-- We need to load the main script headers here
local Class = require('Class')
local Utils = require('Utils')
local unpack = Utils.unpack

-- Placeholder, will become a proper Class later
local Events = {}

-- Class constructor
function Events.__constructor (self)
  -- Add events table
  self.__events = {}
end

-- Default event handler
function Events.trigger (self, event, ...)
  -- If no event handler is found, skip
  if not self.__events or not self.__events[event] then return end

  -- Loops through the event handler
  for _, fn in pairs(self.__events[event]) do
    fn(unpack({...}))
  end
end

-- Attach event handler
function Events.on (self, event, fn)
  -- Add the __events list if not there
  if not self.__events then
    self.__events = {}
  end

  -- Registers unknown event
  if not self.__events[event] then
    self.__events[event] = {}
  end

  -- Inserts event handler
  table.insert(self.__events[event], fn)
end

-- Throws error if there's already an script global
if script then
  error('The global "script" was already defined. Please, use Events.on() instead to hook into events. Exiting...')
end

-- Now we truly make it a proper Class
Class.new('Events', Events)

-- Create a new script object for wrap.lua
script = {}

-- Global event bus
Events.Global = Events.new()

----------------------------------------------------
-- Setup the script handlers from wrap.lua
----------------------------------------------------

-- onStart()
function script.onStart (...)
  Events.Global:trigger('start', unpack({...}))
end

-- onStop()
function script.onStop (...)
  Events.Global:trigger('stop', unpack({...}))
end

-- onMouseDown()
function script.onMouseDown (...)
  Events.Global:trigger('mouseDown', unpack({...}))
end

-- onMouseUp()
function script.onMouseUp (...)
  Events.Global:trigger('mouseUp', unpack({...}))
end

-- onEnter()
function script.onEnter (...)
  Events.Global:trigger('enter', unpack({...}))
end

-- onLeave()
function script.onLeave (...)
  Events.Global:trigger('leave', unpack({...}))
end

-- onActionStart()
function script.onActionStart (...)
  Events.Global:trigger('actionStart', unpack({...}))
end

-- onActionLoop()
function script.onActionLoop (...)
  Events.Global:trigger('actionLoop', unpack({...}))
end

-- onActionStop()
function script.onActionStop (...)
  Events.Global:trigger('actionStop', unpack({...}))
end

-- onUpdate()
function script.onUpdate (...)
  Events.Global:trigger('update', unpack({...}))
end

-- onFlush()
function script.onFlush (...)
  Events.Global:trigger('flush', unpack({...}))
end

-- onTick()
function script.onTick (...)
  Events.Global:trigger('tick', unpack({...}))
end

-- onLaserHit()
function script.onLaserHit (...)
  Events.Global:trigger('laserHit', unpack({...}))
end

-- onLaserRelease()
function script.onLaserRelease (...)
  Events.Global:trigger('laserRelease', unpack({...}))
end

-- onReceive()
function script.onReceive (...)
  Events.Global:trigger('receive', unpack({...}))
end

-- onStatusChanged()
function script.onStatusChanged (...)
  Events.Global:trigger('statusChanged', unpack({...}))
end

-- onCompleted()
function script.onCompleted (...)
  Events.Global:trigger('completed', unpack({...}))
end

-- onPressed()
function script.onPressed (...)
  Events.Global:trigger('pressed', unpack({...}))
end

-- onReleased()
function script.onReleased (...)
  Events.Global:trigger('released', unpack({...}))
end

-- Returns the Events class
return Events