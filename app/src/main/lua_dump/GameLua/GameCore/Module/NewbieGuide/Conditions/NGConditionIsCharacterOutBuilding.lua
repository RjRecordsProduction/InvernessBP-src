local NGConditionIsCharacterOutBuilding = {}
function NGConditionIsCharacterOutBuilding:ctor(selfType, Params)
end
function NGConditionIsCharacterOutBuilding:CheckConditionOK(...)
  local bSuperOk = NGConditionIsCharacterOutBuilding.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
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
  local uPlayerLoc = uPlayerPawn:K2_GetActorLocation()
  local uEndPoint = FVector(uPlayerLoc.X, uPlayerLoc.Y, uPlayerLoc.Z + 9999)
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local Pawn_C = import("/Script/Engine.Pawn")
  local uHitResult = import("/Script/Engine.HitResult")()
  local uGameWorld = slua_GameFrontendHUD:GetWorld()
  local bHit, uHitResult = KismetSystemLibrary.LineTraceSingle(uGameWorld, uPlayerLoc, uEndPoint, 0, true, slua.Array(UEnums.EPropertyClass.Object, Pawn_C), 0, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
  return not bHit
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionIsCharacterOutBuilding = class(CObject, nil, NGConditionIsCharacterOutBuilding)
return CNGConditionIsCharacterOutBuilding