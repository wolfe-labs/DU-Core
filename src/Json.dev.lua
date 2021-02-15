-- Wolfe Labs DU Core Library: Json
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

--[[
  The code below is intended to be a drop-in replacement for the built-in dkjson.lua library.
  Its biggest improvement is transparent support for coroutines, by calling coroutine.yield() whenever needed.
  This is intended to be a new library build from ground-up, but right now it only works for encoding
]]--

-- Helper to debug shit
function dump (obj, name)
  if not name then name = '' end
  if 'function' == type(obj) then
    print(name .. '()')
  elseif 'table' == type(obj) then
    for k, v in pairs(obj) do
      if v == obj then return nil end
      dump(v, name .. '.' .. k)
    end
  elseif 'boolean' == type(obj) then
    if true == obj then print(name .. ' is true')
    else print(name .. ' is false')
    end
  elseif 'nil' == type(obj) then
    print(name .. ' is nil')
  else
    print(name .. ': ' .. obj)
  end
end

-- Some defaults, this can be changed later
local json = {
  version = '@wolfe-labs/Core:Json 0.1.0',
  options = {
    floatDecimalPrecision = 10,
    maxIterationsBeforeYield = 50,
    maxCharactersBeforeYield = 4096,
  },
}

-- Helper function to detect whether a number is a float or a integer
local function isInteger (number)
  local int = math.floor(number)
  return (int == number) or (math.abs(number - int) < tonumber('1e-' .. json.options.floatDecimalPrecision))
end

-- Helper function to escape strings
local function escape (string)
  return string
end

-- Handles yielding by iteration
local yieldCurrentIteration = 0
function yieldIteration ()
  -- Adds another iteration and apply a modulo
  yieldCurrentIteration = (yieldCurrentIteration + 1) % json.options.maxIterationsBeforeYield

  -- Only does a yield after N loop iterations and if we're inside a coroutine
  if 0 == yieldCurrentIteration and coroutine.isyieldable() then
    coroutine.yield()
  end
end

-- This is what we'll use for decoding JSON into Lua objects, some options are here to work okay in place of dkjson
function json.decode (str, pos, null)
  local currentDepth = 1
  local currentValue = nil
  local currentString = nil
  local lastString = nil
  local stackKey = { '' }
  local stackObject = { {} }

  for _ = 1, #str do
    local char = str:sub(_, _)

    -- Handles string ending
    if '"' == char and currentString then
      local key = stackKey[currentDepth]

      -- Sets last string, cleans current
      lastString = currentString
      currentString = nil
      
      -- If we're currently with an open key, update its value
      if key then currentValue = lastString end

    -- Opens a new string
    elseif '"' == char and (not currentString) then currentString = ''

    -- Adds next character to open string
    elseif currentString then currentString = currentString .. char

    -- Handles object key setting
    elseif ':' == char then
      stackKey[currentDepth] = lastString
      currentValue = ''

    -- Handles value end
    elseif ',' == char then
      if currentValue then
        -- Processes the value
        if 'null' == currentValue then currentValue = nil end

        -- dump(stackKey[currentDepth], 'key')
        -- dump(currentValue, 'value')
        stackObject[currentDepth][stackKey[currentDepth]] = currentValue
        currentValue = nil
      end

    -- Adds a new depth
    elseif '{' == char then
      currentValue = nil
      currentString = nil
      currentDepth = currentDepth + 1
      stackObject[currentDepth] = { }

    -- Goes back one depth
    elseif '}' == char then
      dump(currentDepth, 'currentDepth')
      dump(stackKey[currentDepth], 'pkey')
      dump(stackObject[currentDepth], 'obj')

      -- Goes back to previous depth
      currentDepth = currentDepth - 1
      stackObject[currentDepth][stackKey[currentDepth + 1]] = stackObject[currentDepth + 1]
      stackObject[currentDepth + 1] = nil
      stackKey[currentDepth + 1] = nil

    -- Handles values
    elseif currentValue then
      currentValue = currentValue .. char
    end
  end

  dump('--------------------------')
  dump(stackObject, 'stack')
end

-- This is what we'll use for encoding Lua objects into JSON, same thing as decoding, options are here for compat
function json.encode (value, state)
  -- Handles a 'nil' value
  if nil == value then return 'null'

  -- Handles tables (arrays and objects)
  elseif 'table' == type(value) then
    -- This will contain the resulting JSON code
    local result = '{'

    -- Only detects if this is the first child
    local isFirst = true

    -- Loops through the array processing each value
    for _, v in pairs(value) do
      -- Adds comma when needed
      if isFirst then isFirst = false
      else result = result .. ','
      end

      -- Processes the value's JSON and appends it to the current result tree
      result = result .. '"' .. escape(_) .. '":' .. json.encode(v)
      
      -- Triggers an coroutine.yield() when needed to alleviate the CPU
      yieldIteration()
    end

    -- Adds the closing bracket
    result = result .. '}'

    -- Returns the finished result :)
    return result
  
  -- Handles bool -> true
  elseif 'boolean' == type(value) and value then return 'true'

  -- Handles bool -> false
  elseif 'boolean' == type(value) and not value then return 'false'

  -- Handles numbers
  elseif 'number' == type(value) then
    if isInteger(value) then return tostring(math.floor(value))
    else return tostring(value)
  end

  -- Handles strings
  elseif 'string' == type(value) then return '"' .. escape(value) .. '"'

  -- Anything else (unknwown is nil)
  else error('Unhandled JSON conversion type: ' .. type(value))
  end
end

-- Ready for use!
return json