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

  -- This array indicates which Classes, in order of priority, implement methods for the new class
  class.__implements = {}

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
    class.__constructor = (function (self, ...)
      -- This should call the parent class' constructor instead if the current class has no constructor
      if self.__parent then
        self.__parent:__constructor(Utils.unpack({...}))
      end
    end)
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
  if not childClass.__parent then
    childClass.__parent = parentClass
  end

  -- Adds to the implementation list, this list will be read later to see which implementations we have available
  table.insert(childClass.__implements, parentClass)
  
  -- This is the heart of the inheritance system, if will check for an override on child class and, if not found, search for it on parent class
  childClass.__index = (function (t, k)
    return Class.resolve(childClass, t, k)
  end)
end

-- Resolve inheritance
function Class.resolve (class, metatable, key)
  -- Tries to use existing implementation on current class
  if class[key] then
    return class[key]

  -- Tries to find a matching implementation
  elseif #(class.__implements) > 0 then
    local resolved = false
    for _, impl in ipairs(class.__implements) do
      resolved = Class.resolve (impl, metatable, key)
      if resolved then
        return resolved
      end
    end
  end

  -- If all else fails, returns nil
  return nil
end

-- Returns the Class object for requires
return Class