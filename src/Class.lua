-- Wolfe Labs DU Core Library: Class
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

-- We need to load the main script headers here
local Utils = require('Utils')
local unpack = Utils.unpack

-- The Class namespace
local Class = {
  __counter = 0,
}

-- Inicializes a new Class
function Class.new (className, obj, ...)
  -- Creates the base table
  local class = obj or {}

  -- There should be NO new() methods on new classes, they are still called for instancing, but will do all internal metatable stuff
  if not class.__class and class.new then
    error('new() method found on class "' .. className ..'". Please, use __constructor() when defining the desired actions for new() instead')
  end

  -- Setup indexer
  class.__index = class

  -- Setup class name
  class.__class = className

  -- Setup instance counter
  class.getInstanceId = (function (self)
    -- If there's not an __instance value set, then set it
    if not self.__instance then
      -- Increments global instance counter
      Class.__counter = Class.__counter + 1

      -- Uses the class name + new value as the ID
      self.__instance = className .. Class.__counter
    end

    -- Returns instance ID
    return self.__instance
  end)

  -- This is called right after we create a new instance
  if not class.__constructor then
    class.__constructor = function (...) end
  end

  -- Overrides the new() method
  class.new = (function (...)
    -- Returns empty class instance
    self = setmetatable({}, class)

    -- Sets class name
    self.__class = class.__class

    -- Generates the instance ID
    self:getInstanceId()

    -- Calls the constructor
    self:__constructor(Utils.unpack({...}))

    -- Return the instance
    return self
  end)

  -- If there's any parent classes, do it here
  for _, parentClass in pairs({...}) do
    Class.inherits(class, parentClass)
  end

  -- Returns the class definition
  return class
end

-- Setup inheritance
function Class.inherits (childClass, parentClass)
  -- Set the parent class entry
  childClass.__parent = parentClass
  
  -- This is the heart of the inheritance system, if will check for an override on child class and, if not found, search for it on parent class
  childClass.__index = (function (t, k)
    return Class.resolve(childClass, t, k)
  end)
end

-- Resolve inheritance
function Class.resolve (class, metatable, key)
  if class[key] then
    return class[key]
  elseif class.__parent then
    return Class.resolve (class.__parent, metatable, key)
  else
    return nil
  end
end

-- Returns the Class object for requires
return Class