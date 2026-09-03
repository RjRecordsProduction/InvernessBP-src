local NGConditionReadyTime = {}
function NGConditionReadyTime:ctor(selfType, Params)
  self.LeftTime = Params.LeftTime
end
function NGConditionReadyTime:CheckConditionOK(...)
  if CGameState and self.LeftTime < CGameState.ReadyStateTime then
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
return class(CObject, nil, NGConditionReadyTime)