local FeatureVehicleSwift = {}
local Trait = require("common.trait")
local TFeatureVehicleSwift = Trait(Trait.TraitPrototype, nil, FeatureVehicleSwift)
function FeatureVehicleSwift:PlaySwiftEffect(data)
  log(bWriteLog and "FeatureVehicleSwift:PlaySwiftEffect")
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("FeatureVehicleSwift:PlaySwiftEffect no valid VehicleActor")
    return
  end
  local ItemID = actor:GetCurrentItemId()
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if ItemCfg.ItemSubType == 901 then
    self:AdjustGarageAttachMeshPos()
  else
    local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
    logic_SuperCar_200Version.ChangeCameraRotation(FRotator(-20, 10, 0))
  end
  self:NotifyOtherFeatureStop(data)
  local animInstance = self:GetVehicleSwiftAnimIns()
  if not animInstance then
    log_error("StoreDetail PlaySwiftEffect vehicle not have animInstance")
    return
  end
  local montagePath = animInstance.SwiftMontage
  if not montagePath then
    log(bWriteLog and "FeatureVehicleSwift:PlaySwiftEffect montagePath is nil")
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local AnimAsset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(montagePath)
  if AnimAsset == nil then
    log(bWriteLog and "FeatureVehicleSwift:PlaySwiftEffect GetAssetByAssetReference AnimAsset is nil:" .. tostring(montagePath))
    return
  end
  self:NotifyOtherFeatureStop(data)
  animInstance.ForceUpdateAnimation = true
  local EMontagePlayReturnType = import("EMontagePlayReturnType")
  local AnimLen = animInstance:Montage_Play(AnimAsset, 1, EMontagePlayReturnType.MontageLength, 0)
  EventSystem:postEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_PLAY_SWIFT_EFFECT, true, AnimLen)
end
function FeatureVehicleSwift:StopSwiftEffect()
  local animInstance = self:GetVehicleSwiftAnimIns()
  if not animInstance then
    log_error("StoreDetail StopSwiftEffect vehicle not have animInstance")
    return
  end
  local montagePath = animInstance.SwiftMontage
  if not montagePath then
    log(bWriteLog and "FeatureVehicleSwift:StopSwiftEffect montagePath is nil")
    return
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local AnimAsset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(montagePath)
  if AnimAsset == nil then
    log(bWriteLog and "FeatureVehicleSwift:StopSwiftEffect GetAssetByAssetReference AnimAsset is nil:" .. tostring(montagePath))
    return
  end
  animInstance:Montage_Stop(0.0, AnimAsset)
  EventSystem:postEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_PLAY_SWIFT_EFFECT, false)
end
function FeatureVehicleSwift:AdjustGarageAttachMeshPos()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("StoreDetail AdjustGarageAttachMeshPos not VehicleActor")
    return
  end
  local Garage_mesh = actor.DefaultSceneRoot:GetAttachParent()
  if not slua.isValid(Garage_mesh) then
    log_error("StoreDetail AdjustGarageAttachMeshPos not Garage_mesh")
    return
  end
  Garage_mesh:K2_SetRelativeRotation(FRotator(0, -81, 0), false, nil, false)
end
function FeatureVehicleSwift:GetVehicleSwiftAnimIns()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("FeatureVehicleSwift:GetVehicleSwiftAnimIns not VehicleActor")
    return
  end
  local vehicle = actor:GetVehicleActor()
  if not slua.isValid(vehicle) then
    log_error("FeatureVehicleSwift:GetVehicleSwiftAnimIns vehicle is not Valid")
    return
  end
  local animInstance = vehicle.Mesh:GetAnimInstance()
  if not animInstance then
    log(bWriteLog and "FeatureVehicleSwift:GetVehicleSwiftAnimIns vehicle not have animInstance")
    return
  end
  return animInstance
end
return TFeatureVehicleSwift