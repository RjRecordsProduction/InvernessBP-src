local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local SkillUtils_C = import("SkillUtils")
local SkillUtils = {
  DynamicSkillInstData = {},
  DynamicSkillConfigData = {}
}
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
function SkillUtils.GetSkillTemplateID(SkillID)
  local SkillCfg = CDataTable.GetTableData("SkillTable", SkillID)
  return SkillCfg and SkillCfg.TemplateID or 0
end
function SkillUtils.GetSkillConfig(SkillID)
  local tOneSkillConfig = SkillUtils.DynamicSkillConfigData[SkillID]
  if tOneSkillConfig then
    return tOneSkillConfig
  end
  local SkillTemplateID = SkillUtils.GetSkillTemplateID(SkillID)
  local tAllSkillConfig = GamePlayTools.GetCurrentConfig("SkillConfig")
  if tAllSkillConfig then
    if 0 < SkillTemplateID and tAllSkillConfig.SkillTemplateConfig and tAllSkillConfig.SkillTemplateConfig[SkillTemplateID] then
      tOneSkillConfig = tAllSkillConfig.SkillTemplateConfig[SkillTemplateID]
    end
    if 0 < SkillID then
      if tOneSkillConfig == nil then
        tOneSkillConfig = tAllSkillConfig[SkillID]
      else
        local SpecificSkillConfig = tAllSkillConfig[SkillID]
        if SpecificSkillConfig ~= nil then
          for k, v in pairs(SpecificSkillConfig) do
            tOneSkillConfig[k] = v
          end
        end
      end
    end
  end
  return tOneSkillConfig
end
function SkillUtils.ShowActorOutline(uTargetActor, bShow, OutlineColor, fThickness, bNewTranslucentDepthWrite)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetExactDeviceLevel()
  if Client and nDeviceLevel < 2 then
    return
  end
  if Client and slua.isValid(uTargetActor) then
    local CMeshComponent = import("/Script/Engine.MeshComponent")
    local MeshComponentsArrays = uTargetActor:GetComponentsByClass(CMeshComponent)
    for _, uMeshComp in pairs(MeshComponentsArrays) do
      if slua.isValid(uMeshComp) then
        uMeshComp:SetDrawIdeaOutline(bShow)
        uMeshComp:SetIdeaOutlineNew(bShow)
        uMeshComp:OverrideIdeaOutlineColor(bShow, OutlineColor)
        uMeshComp:OverrideIdeaOutlineThickness(bShow, fThickness)
        if bNewTranslucentDepthWrite ~= nil then
          uMeshComp.bEnableTransparentZWrite = bNewTranslucentDepthWrite
        end
      end
    end
  end
end
function SkillUtils.GetHitPointFromCharacterView(uCharacter, tIgnoreActos)
  if not slua.isValid(uCharacter) then
    return FVector.ZeroVector, nil
  end
  local uPlayer = uCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uPlayer) then
    return FVector.ZeroVector, nil
  end
  local uCameraMgr = uPlayer.PlayerCameraManager
  if not slua.isValid(uCameraMgr) then
    return FVector.ZeroVector, nil
  end
  local StartLoc = uCameraMgr:GetCameraLocation()
  local uVehicle = uCharacter:GetCurrentVehicle()
  local Rotation = uCharacter:GetControlRotation()
  if slua.isValid(uVehicle) then
    Rotation = uCameraMgr:GetCameraRotation()
  end
  local Actor_C = import("/Script/Engine.Actor")
  local HitResult = import("/Script/Engine.HitResult")()
  local Direction = USTExtraBlueprintFunctionLibrary.GetDirectionFromRotator(Rotation)
  local EndLoc = StartLoc + FVector(40000 * Direction.X, 40000 * Direction.Y, 40000 * Direction.Z)
  local uIgnoreActorArray = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  uIgnoreActorArray:Add(uCharacter)
  if slua.isValid(uVehicle) then
    uIgnoreActorArray:Add(uVehicle)
    local uVehicleSeat = uVehicle:GetSeatComponent()
    if slua.isValid(uVehicleSeat) then
      for Index, OtherCharacter in pairs(uVehicleSeat.SeatOccupiers) do
        if slua.isValid(OtherCharacter) and OtherCharacter ~= uCharacter then
          uIgnoreActorArray:Add(OtherCharacter)
        end
      end
    end
  end
  local uWeapon = uCharacter:GetCurrentWeapon()
  if slua.isValid(uWeapon) then
    uIgnoreActorArray:Add(uWeapon)
  end
  if tIgnoreActos then
    for i, IgnoreActor in ipairs(tIgnoreActos) do
      if slua.isValid(IgnoreActor) then
        uIgnoreActorArray:Add(IgnoreActor)
      end
    end
  end
  local Success = false
  Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceBlock(uCharacter, StartLoc, EndLoc, HitResult, uIgnoreActorArray, false)
  if HitResult.bBlockingHit then
    return FVector(HitResult.ImpactPoint.X, HitResult.ImpactPoint.Y, HitResult.ImpactPoint.Z), HitResult.Actor
  end
  return FVector.ZeroVector, nil
end
function SkillUtils.GetCharactorViewRotation(Character, SourcePoint, tIgnoreActos)
  local Rotation = Character:GetViewRotation()
  local HitPointVec = SkillUtils.GetHitPointFromCharacterView(Character, tIgnoreActos)
  local HitPointSizeSq = HitPointVec:SizeSquared2D()
  if 1.0E-5 < HitPointSizeSq then
    local Direction = HitPointVec - SourcePoint
    Rotation = USTExtraBlueprintFunctionLibrary.GetRotatorFromDirection(Direction)
  else
    local uVehicle = Character:GetCurrentVehicle()
    if slua.isValid(uVehicle) then
      Rotation = uVehicle:GetPlayerLookAtRotation()
    end
  end
  return Rotation
end
function SkillUtils.GetOverrideSkillInstData(SkillID)
  return SkillUtils.DynamicSkillInstData[SkillID]
end
function SkillUtils.SetOverrideSkillInstData(WorldContect, SkillID, InstData, ConfigData)
  print(bWriteLog and string.format("SkillUtils:SetOverrideSkillInstData:%d", SkillID))
  SkillUtils.DynamicSkillInstData[SkillID] = InstData
  SkillUtils.DynamicSkillConfigData[SkillID] = ConfigData
  SkillUtils_C.DynamicAddSkill(WorldContect, SkillID)
end
function SkillUtils.SetOverrideSkillUIData(SkillID, ConfigData)
  print(bWriteLog and string.format("SkillUtils:SetOverrideSkillUIData:%d", SkillID))
  SkillUtils.DynamicSkillConfigData[SkillID] = ConfigData
end
function SkillUtils.RemoveOverrideSkillInstData(WorldContect, SkillID)
  print(bWriteLog and string.format("SkillUtils:RemoveOverrideSkillInstData:%d", SkillID))
  SkillUtils.DynamicSkillInstData[SkillID] = nil
  SkillUtils.DynamicSkillConfigData[SkillID] = nil
  SkillUtils_C.DynamicRemoveSkill(WorldContect, SkillID)
end
function SkillUtils.ClearAllSkillInstData(WorldContect)
  print(bWriteLog and "SkillUtils.ClearAllSkillInstData")
  SkillUtils.DynamicSkillInstData = {}
  SkillUtils.DynamicSkillConfigData = {}
  SkillUtils_C.ClearAllDynamicSkill(WorldContect)
end
return SkillUtils