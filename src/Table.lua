-- Wolfe Labs DU Core Library: Table Utilities
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

-- The Table namespace
local Table = {}

-- Checks if is a valid Table
function Table.valid (t)
  return table and 'table' == type(t)
end

-- Checks if is a valid Table
function Table.validate (t)
  if not Table.valid(t) then
    error('Supplied object is not a valid table: ' .. require('Utils').dumpString(t, 1))
  end
end

-- Creates a shallow copy of an table
function Table.copy (t)
  -- Validates input
  Table.validate(t)

  -- The output table
  local output = {}

  -- Proccess stuff
  for k, v in pairs(t) do
    output[k] = v
  end

  -- Done
  return output
end

-- Returns a subset of the table
function Table.slice (t, start, size)
  -- Validates input
  Table.validate(t)

  -- For negative start index, count from table size
  local index = start
  local length = Table.length(t)
  if start < 0 then
    index = length + start + 1
  end

  -- Store output here
  local output = {}

  -- Process
  for i = index, math.min(length, index + size - 1) do
    table.insert(output, t[i])
  end

  -- Done!
  return output
end

-- Extracts only the keys from a key-value table
function Table.keys (t)
  -- The table we'll use
  local result = {}

  -- Proccess stuff
  for k, v in pairs(t) do
    table.insert(result, k)
  end

  -- Returns the result :)
  return result
end

-- Extracts only the values from a key-value table
function Table.values (t)
  -- The table we'll use
  local result = {}

  -- Proccess stuff
  for k, v in pairs(t) do
    table.insert(result, v)
  end

  -- Returns the result :)
  return result
end

-- Returns the length of an table
function Table.length (t, include_keys)
  -- Validates input
  Table.validate(t)

  local length = 0
  if include_keys then
    -- Counts all elements, including keyed ones
    for _ in pairs(t) do
      length = length + 1
    end
  else
    -- Counts all numeric elements
    for _ in ipairs(t) do
      length = length + 1
    end
  end

  -- Finished, returns count
  return length
end

-- Merges multiple tables
function Table.merge (...)
  -- The table we'll use as buffer
  local result = {}

  -- Proccess stuff
  for _, t in pairs({...}) do
    -- Validates table
    Table.validate(t)
    for k, v in pairs(t) do
      result[k] = v
    end
  end

  -- Returns the result :)
  return result
end

-- Maps a table for processing values
function Table.map (t, fn)
  -- Validates input
  Table.validate(t)

  -- Stores the output
  local output = {}

  -- Processes every element with fn and saves in output
  for k, v in pairs(t) do
    output[k] = fn(v)
  end

  -- Done!
  return output
end

-- Filters a table and leaves only certain elements
function Table.filter (t, fn)
  return Table.map(t, function (v) if fn(v) then return v else return nil end end)
end

-- Reverts a table
function Table.reverse (t)
  -- Validates input
  Table.validate(t)

  -- Stores the output
  local output = {}
  local length = Table.length(t)

  -- Main loop
  for i = 1, length do
    output[length - (i - 1)] = t[i]
  end

  -- Done
  return output
end

-- Returns the namespace
return Table