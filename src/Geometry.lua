-- Wolfe Labs DU Core Library: Geometry
-- Project: DU-Core
-- Author: Matheus Pratta (DU: Wolfram)

-- The Geometry namespace
local Geometry = {}

-- Returns the rotation axis of an Construct from its Core Unit
function Geometry.getConstructWorldRotation (coreUnit)
  return {
    right = vec3(coreUnit.getConstructWorldOrientationRight()),
    forward = vec3(coreUnit.getConstructWorldOrientationForward()),
    up = vec3(coreUnit.getConstructWorldOrientationUp()),
  }
end

-- Converts from a Construct's local space into world space
function Geometry.convertWorldToLocalPosition (coreUnit, pos, axis, posG)
  -- Gets the construct rotation axes in world-space
  axis = axis or Geometry.getConstructWorldRotation(coreUnit)
  posG = posG or vec3(coreUnit.getConstructWorldPos())

  -- Converts pos into a relative position
  pos = vec3(pos) - posG
 
  --[[
    
    Resolves the following matrix multiplication:

    | aRx aFx aUx |   | x |
    | aRy aFy aUy | * | y |
    | aRz aFz aUz |   | z |

    And then adds it to the Construct's position

  ]]--
  return vec3(
    library.systemResolution3(
      { axis.right:unpack() },
      { axis.forward:unpack() },
      { axis.up:unpack() },
      { pos:unpack() }
    )
  )
end

-- Converts from world space into a Construct's local space
function Geometry.convertLocalToWorldPosition (coreUnit, pos, axis, posG)
  -- Converts into relative position
  posG = posG or vec3(coreUnit.getConstructWorldPos())
  
  -- Makes sure pos is a vector
  pos = vec3(pos)

  -- Gets the construct rotation axis and position in world-space
  axis = axis or Geometry.getConstructWorldRotation(coreUnit)

  -- Extract the axes into individual variables
  local rightX, rightY, rightZ = axis.right:unpack()
  local forwardX, forwardY, forwardZ = axis.forward:unpack()
  local upX, upY, upZ = axis.up:unpack()

  -- Extracts the local position into individual coordinates
  local rfuX, rfuY, rfuZ = pos.x, pos.y, pos.z

  -- Apply the rotations to obtain the relative coordinate in world-space
  local relX = rfuX * rightX + rfuY * forwardX + rfuZ * upX
  local relY = rfuX * rightY + rfuY * forwardY + rfuZ * upY
  local relZ = rfuX * rightZ + rfuY * forwardZ + rfuZ * upZ
  
  return posG + vec3(relX, relY, relZ)
end

-- Returns the Geometry namespace
return Geometry