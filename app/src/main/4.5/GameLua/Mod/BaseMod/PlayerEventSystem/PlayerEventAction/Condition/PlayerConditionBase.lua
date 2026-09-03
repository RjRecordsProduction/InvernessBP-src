local PlayerConditionBase = {}
function PlayerConditionBase:ctor(selfType)
  self.bIsClient = true
end
function PlayerConditionBase:Init(bClient)
  self.bIsClient = bClient
end
function PlayerConditionBase:IsOK(uTarget)
  return true
end
function PlayerConditionBase:Clear()
end
local class = require("class")
local object = require("object")
local CPlayerConditionBase = class(object, nil, PlayerConditionBase)
return CPlayerConditionBase