-- Wolfe Labs DU Core Library: Utilities
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

-- The Utils namespace
local Utils = {}

-- Returns a character in a string
function Utils.char (str, idx)
  return str:sub(idx, idx)
end

-- Returns all characters in a string as a table
function Utils.chars (str)
  local chars = {}
  for _ = 1, #str do
    table.insert(chars, str, _)
  end
  return chars
end

-- Splits a string
function Utils.split (str, separator)
  local entries = {}
  local buffer = ''
  local test = ''

  -- Handles each character
  for _ = 1, #str do
    -- Gets the slice that might be the separator
    test = str:sub(_, _ + #separator - 1)

    -- Check for separator
    if test == separator then
      -- If found, add buffer to entries then reset buffer
      table.insert(entries, buffer)
      buffer = ''
    else
      -- If not found, add to buffer
      buffer = buffer .. str:sub(_, _)
    end
  end

  -- Adds last entry
  if #buffer > 0 then
    table.insert(entries, buffer)
  end

  -- Done
  return entries
end

-- Prints text in a single line, all concatenated
function Utils.print (...)
  -- Uses default stdout for lua CLI
  local write = print
  local result = ''

  -- Use DU's system.print if available
  if system and system.print then
    write = system.print
  end

  -- Processes extra arguments
  for _, obj in ipairs({...}) do
    local str = ''

    -- Use straight string or number values, returns [type] for other types
    if not obj then str = 'nil'
    else
      if type(obj) == 'string' or type(obj) == 'number' then
        str = obj
      else
        str = '[' .. type(obj) .. ']'
      end
    end

    if _ == 1 then
      result = str
    else
      result = result .. ' ' .. str
    end
  end

  -- Prints taking in consideration lines
  for _, line in pairs(Utils.split(result, '\n')) do
    write(line)
  end
end

-- Dumps random things
function Utils.dump (...)
  Utils.print('===============================================')
  Utils.print('Dumping ' .. require('Table').length({...}) .. ' value(s):')
  Utils.print('-----------------------------------------------')
  for i, v in ipairs({...}) do
    if not i == 1 then Utils.print('-----------------------------------------------') end
    Utils.print(Utils.dumpString(v, 1))
  end
  Utils.print('===============================================')
end

-- Dumps a single value to string
function Utils.dumpString (v, depth)
  if type(v) == 'string' then return '"' .. v .. '"'
  elseif type(v) == 'number' then return v
  elseif type(v) == 'table' and depth > 0 then return Utils.dumpTable(v, depth)
  else return '[' .. type(v) .. ']'
  end
end

-- Dumps a table recursively
function Utils.dumpTable (t, depth)
  -- Opens dump
  local dump = '[table] {\n'

  -- -- Process dump
  for k, v in pairs(t) do
    dump = dump .. '[' .. k .. '] => ' .. Utils.dumpString(v, depth - 1) .. '\n'
  end

  -- Close dump
  dump = dump .. '}'

  -- Return dump
  return dump
end

-- Handle different unpack functions
if unpack then Utils.unpack = unpack
else Utils.unpack = table.unpack
end

-- Returns the Utils namespace
return Utils