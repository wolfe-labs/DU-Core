-- Wolfe Labs DU Core Library: Math
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

-- The Math namespace
local Math = {}

-- Implements math.atan2 function because some **really evil** or lazy person didn't do it
function Math.atan2 (x, y)
  -- If by some miracle this gets implemented, this will handle it natively
  if math.atan2 then return math.atan2(x, y) end

  -- Does the calculation by hand
  if x == 0 and y == 0 then return 0 / 0 end
  if x == 0 and y < 0 then return -(math.pi / 2) end
  if x == 0 and y > 0 then return (math.pi / 2) end
  if x < 0 and y < 0 then return math.atan(y / x) - math.pi end
  if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
  if x > 0 then return math.atan(y / x) end

  -- If the above conditions fail, return indefinite
  return 0 / 0
end

-- Returns the Math namespace
return Math