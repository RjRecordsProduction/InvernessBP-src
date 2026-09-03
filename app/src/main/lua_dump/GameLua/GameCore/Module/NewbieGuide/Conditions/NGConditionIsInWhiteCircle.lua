local NGConditionIsInWhiteCircle = {}
function NGConditionIsInWhiteCircle:ctor(selfType, Params)
  self.bNeedInWhiteCircle = Params.bNeedInCircle
end
function NGConditionIsInWhiteCircle:CheckConditionOK(...)
  log(bWriteLog and "Debug NewbieGuide: NGConditionIsInWhiteCircle CheckConditionOK, bNeedInWhiteCircle:" .. tostring(self.bNeedInWhiteCircle))
  local bSuperOk = NGConditionIsInWhiteCircle.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uGamestate = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGamestate) then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return false
  end
  local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return false
  end
  local DistanceToWhiteCircle = FVector.DistXY(uPlayerPawn:K2_GetActorLocation(), uGamestate.WhiteCircle)
  if self.bNeedInWhiteCircle and DistanceToWhiteCircle <= uGamestate.WhiteCircle.Z then
    log(bWriteLog and "Debug NewbieGuide: NGConditionIsInWhiteCircle CheckConditionOK, true")
    return true
  end
  if not self.bNeedInWhiteCircle and DistanceToWhiteCircle > uGamestate.WhiteCircle.Z then
    log(bWriteLog and "Debug NewbieGuide: NGConditionIsInWhiteCircle CheckConditionOK, true")
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionIsInWhiteCircle = class(CObject, nil, NGConditionIsInWhiteCircle)
return CNGConditionIsInWhiteCircle