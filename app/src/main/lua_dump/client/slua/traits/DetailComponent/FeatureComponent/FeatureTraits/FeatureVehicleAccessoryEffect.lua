local FeatureVehicleAccessoryEffect = {}
local Trait = require("common.trait")
local TFeatureVehicleAccessoryEffect = Trait(Trait.TraitPrototype, nil, FeatureVehicleAccessoryEffect)
function FeatureVehicleAccessoryEffect:PlayVehicleAccessoryEffect(data)
  log(bWriteLog and "FeatureVehicleAccessoryEffect:PlayVehicleAccessoryEffect")
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ModuleFrequencyLimit.LobbyVehicleAccessory) then
    return
  end
  self:NotifyOtherFeatureStop(data)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_ACCESSORY_PLAY_ACCESSORY)
  self:PlayVehicleAccessoryEffectInternal(true)
end
function FeatureVehicleAccessoryEffect:StopVehicleAccessoryEffect()
  log(bWriteLog and "FeatureVehicleAccessoryEffect:StopVehicleAccessoryEffect")
  self.bPendingPlayAccessoryEffect = false
  local showActor
  local vehiclePreviewUI = UIManager.GetUI(UIManager.UI_Config.Vehicle_Accessory_Preview_UIBP)
  if vehiclePreviewUI then
    showActor = vehiclePreviewUI:GetCurShowActor()
  else
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    showActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  end
  if not slua.isValid(showActor) or not showActor:GetVehicleActor() then
    log_error("FeatureVehicleAccessoryEffect:StopVehicleAccessoryEffect no valid VehicleActor")
    return
  end
  local vehicleActor = showActor:GetVehicleActor()
  if not slua.isValid(vehicleActor) then
    log_error("FeatureVehicleAccessoryEffect:StopVehicleAccessoryEffect vehicle is nil")
    return
  end
  vehicleActor:StopAccelerateEffect()
  local animInstance = vehicleActor.Mesh:GetAnimInstance()
  if not animInstance then
    log_error("FeatureVehicleAccessoryEffect:StopVehicleAccessoryEffect vehicle not have animInstance")
    return
  end
  if animInstance.LobbyFanSpeedPercent then
    animInstance.LobbyFanSpeedPercent = 0.0
  end
  if animInstance.bUseLobbyFanSpeed ~= nil then
    animInstance.bUseLobbyFanSpeed = false
  end
  local montagePath = animInstance.AccessoryAccelMontage
  if not montagePath then
    log(bWriteLog and "FeatureVehicleAccessoryEffect:StopVehicleAccessoryEffect montagePath is nil")
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local AnimAsset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(montagePath)
  if AnimAsset == nil then
    log(bWriteLog and "FeatureVehicleAccessoryEffect:StopVehicleAccessoryEffect GetAssetByAssetReference AnimAsset is nil:" .. tostring(montagePath))
    return
  end
  local ChildComponents = vehicleActor.Mesh:GetChildrenComponents(false, nil)
  for _, uChildComponent in pairs(ChildComponents) do
    if slua.isValid(uChildComponent) and uChildComponent.GetAnimInstance then
      local childAnimInstance = uChildComponent:GetAnimInstance()
      if childAnimInstance then
        childAnimInstance.ForceUpdateAnimation = true
        animInstance:Montage_Stop(0.0, AnimAsset)
      end
    end
  end
end
function FeatureVehicleAccessoryEffect:OnStoreCarModelLoaded()
  if self.bPendingPlayAccessoryEffect == true then
    self:PlayVehicleAccessoryEffectInternal(false)
  end
end
function FeatureVehicleAccessoryEffect:PlayVehicleAccessoryEffectInternal(bCheckWait)
  local showActor
  local vehiclePreviewUI = UIManager.GetUI(UIManager.UI_Config.Vehicle_Accessory_Preview_UIBP)
  if vehiclePreviewUI then
    showActor = vehiclePreviewUI:GetCurShowActor()
  else
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    showActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  end
  if not slua.isValid(showActor) or not showActor:GetVehicleActor() then
    log_error("FeatureVehicleAccessoryEffect:PlayVehicleAccessoryEffect no valid VehicleActor")
    if bCheckWait then
      self.bPendingPlayAccessoryEffect = true
    end
    return
  end
  local vehicleActor = showActor:GetVehicleActor()
  if not slua.isValid(vehicleActor) then
    log_error("FeatureVehicleAccessoryEffect:PlayVehicleAccessoryEffect no valid VehicleActor")
    if bCheckWait then
      self.bPendingPlayAccessoryEffect = true
    end
    return
  end
  self:AdjustGarageAttachMeshPos()
  self.bPendingPlayAccessoryEffect = false
  local animInstance = vehicleActor.Mesh:GetAnimInstance()
  if not animInstance then
    log_error("StoreDetail PlayVehicleAccessoryEffect vehicle not have animInstance")
    return
  end
  if not animInstance.bDisableLobbyAccelEffect then
    vehicleActor:PlayAccelerateEffect()
  else
    vehicleActor:PlayAccelerateSound()
  end
  animInstance.ForceUpdateAnimation = true
  if animInstance.LobbyFanSpeedPercent then
    animInstance.LobbyFanSpeedPercent = 1.0
  end
  if animInstance.bUseLobbyFanSpeed ~= nil then
    animInstance.bUseLobbyFanSpeed = true
  end
  if self.lobbyFanTimer then
    self:RemoveTimer(self.lobbyFanTimer)
    self.lobbyFanTimer = nil
  end
  local montagePath = animInstance.AccessoryAccelMontage
  if not montagePath then
    log(bWriteLog and "FeatureVehicleAccessoryEffect:PlayVehicleAccessoryEffect montagePath is nil")
    local lobbyFanDuration = animInstance.LobbyFanDuration or -1
    if 0 < lobbyFanDuration then
      self.lobbyFanTimer = self:AddTimer(lobbyFanDuration, function()
        self:StopVehicleAccessoryEffect()
      end)
    end
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local AnimAsset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(montagePath)
  if AnimAsset == nil then
    log(bWriteLog and "FeatureVehicleAccessoryEffect:PlayVehicleAccessoryEffect GetAssetByAssetReference AnimAsset is nil:" .. tostring(montagePath))
    return
  end
  local EMontagePlayReturnType = import("EMontagePlayReturnType")
  local ChildComponents = vehicleActor.Mesh:GetChildrenComponents(false, nil)
  for _, uChildComponent in pairs(ChildComponents) do
    if slua.isValid(uChildComponent) and uChildComponent.GetAnimInstance then
      local childAnimInstance = uChildComponent:GetAnimInstance()
      if childAnimInstance then
        childAnimInstance.ForceUpdateAnimation = true
        childAnimInstance:Montage_Play(AnimAsset, 1, EMontagePlayReturnType.MontageLength, 0)
      end
    end
  end
end
return TFeatureVehicleAccessoryEffect