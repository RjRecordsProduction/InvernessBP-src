local NGConditionIsInAirAttackZone = {}
function NGConditionIsInAirAttackZone:CheckConditionOK(...)
  log(bWriteLog and "Debug NewbieGuide: NGConditionIsInAirAttackZone CheckConditionOK")
  local bSuperOk = NGConditionIsInAirAttackZone.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not slua.isValid(uGameState) then
    return false
  end
  local ComponentClass = import("AirAttackComponent")
  local AirAttackComponent = uGameState:GetComponentByClass(ComponentClass)
  if not slua.isValid(AirAttackComponent) then
    return false
  end
  local uAirAttackLoc = AirAttackComponent.AirAttackArea
  if not uAirAttackLoc then
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
  local uPawnLoc = uPlayerPawn:K2_GetActorLocation()
  local nDisToAirAttackCenter = FVector.DistXY(uAirAttackLoc, uPawnLoc)
  return nDisToAirAttackCenter < uAirAttackLoc.Z
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionIsInAirAttackZone = class(CObject, nil, NGConditionIsInAirAttackZone)
return CNGConditionIsInAirAttackZone