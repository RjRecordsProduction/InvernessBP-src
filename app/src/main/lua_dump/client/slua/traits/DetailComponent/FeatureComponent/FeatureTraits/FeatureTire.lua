local FeatureTire = {}
local Trait = require("common.trait")
local TFeatureTire = Trait(Trait.TraitPrototype, nil, FeatureTire)
function FeatureTire:PlayTireEffect(data)
  log(bWriteLog and "StoreDetail PlayTireEffect")
  if self.PlayTire then
    log(bWriteLog and "StoreDetail PlayTireEffect is Playing")
    return
  end
  if not self.TireFeatureData then
    log_error("StoreDetail StopTireEffect not self.TireFeatureData")
    return
  end
  if not self.TireFeatureData.config.TireMontagePath then
    log_error("StoreDetail PlayTireEffect not self.TireFeatureData.TireMontagePath")
    return
  end
  local animInstance = self:GetVehicleAnimIns()
  if not animInstance then
    log_error("StoreDetail PlayTireEffect vehicle not have animInstance")
    return
  end
  local model_util = require("client.common.model_util")
  local AnimAsset = model_util.GetAssetObjByPath(self.TireFeatureData.config.TireMontagePath)
  if not AnimAsset then
    log_error("StoreDetail PlayTireEffect AnimAsset is nil " .. tostring(self.TireFeatureData.config.TireMontagePath))
    return
  end
  self:NotifyOtherFeatureStop(data)
  animInstance.ForceUpdateAnimation = true
  local EMontagePlayReturnType = import("EMontagePlayReturnType")
  local AnimLen = animInstance:Montage_Play(AnimAsset, 1, EMontagePlayReturnType.MontageLength, 0)
  log(bWriteLog and "StoreDetail PlayTireEffect music " .. tostring(self.TireFeatureData.config.TireVideo))
  self:StopMusic(self.TireFeatureData.config.TireVideo)
  self:PlayMusic(self.TireFeatureData.config.TireVideo, true)
  self:AdjustTirePos()
  self:PlayCameraShake("/Game/Res/IG1000/Arts_PlayerBluePrints/HighQQQuality/DS/RefitVehicle/CS_Motai.CS_Motai_C", AnimLen)
  self.PlayTire = true
  if self.PlayingTimer then
    self:RemoveTimer(self.PlayingTimer)
    self.PlayingTimer = nil
  end
  self.PlayingTimer = self:AddTimerOnce(AnimLen, function()
    EventSystem:postEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_PLAYTIRE_ANIM_END)
    self.PlayTire = false
    self.PlayingTimer = nil
  end)
  EventSystem:postEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_PLAYTIRE_ANIM, true)
end
function FeatureTire:StopTireEffect()
  log(bWriteLog and "StoreDetail StopTireEffect ")
  if not self.TireFeatureData then
    log(bWriteLog and "StoreDetail StopTireEffect not self.TireFeatureData")
    return
  end
  if self.TireFeatureData.config.TireVideo then
    self:StopMusic(self.TireFeatureData.config.TireVideo)
  end
  if self.TireShakeTimer then
    self:RemoveTimer(self.TireShakeTimer)
    self.TireShakeTimer = nil
  end
  self.PlayTire = false
  if self.PlayingTimer then
    EventSystem:postEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_PLAYTIRE_ANIM_END)
    self:RemoveTimer(self.PlayingTimer)
    self.PlayingTimer = nil
  end
  local animInstance = self:GetVehicleAnimIns()
  if not animInstance then
    log(bWriteLog and "StoreDetail StopTireEffect vehicle not have animInstance")
    return
  end
  local model_util = require("client.common.model_util")
  local AnimAsset = model_util.GetAssetObjByPath(self.TireFeatureData.config.TireMontagePath)
  if not AnimAsset then
    log(bWriteLog and "StoreDetail StopTireEffect AnimAsset is nil " .. tostring(self.TireFeatureData.config.TireMontagePath))
    return
  end
  animInstance:Montage_Stop(0.0, AnimAsset)
end
function FeatureTire:AdjustTirePos()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("StoreDetail GetVehicleAnimIns not VehicleActor")
    return
  end
  local ItemID = actor:GetCurrentItemId()
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  if ItemCfg.ItemSubType == 901 then
    self:AdjustGarageMeshPos()
  else
    self:AdjustCameraPos()
  end
end
function FeatureTire:AdjustGarageMeshPos()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("StoreDetail AdjustGarageMeshPos not VehicleActor")
    return
  end
  local Garage_mesh = actor.DefaultSceneRoot:GetAttachParent()
  if not slua.isValid(Garage_mesh) then
    log_error("StoreDetail AdjustGarageMeshPos not Garage_mesh")
    return
  end
  Garage_mesh:K2_SetRelativeRotation(FRotator(0, -81, 0), false, nil, false)
end
function FeatureTire:AdjustCameraPos()
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.ChangeCameraToTireRotate()
end
function FeatureTire:GetVehicleAnimIns()
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not slua.isValid(actor) or not actor:GetVehicleActor() then
    log_error("StoreDetail GetVehicleAnimIns not VehicleActor")
    return
  end
  local vehicle = actor:GetVehicleActor()
  if not slua.isValid(vehicle) then
    log_error("StoreDetail GetVehicleAnimIns vehicle is not Valid")
    return
  end
  local animInstance = vehicle.Mesh:GetAnimInstance()
  if not animInstance then
    log(bWriteLog and "StoreDetail GetVehicleAnimIns vehicle not have animInstance")
    return
  end
  return animInstance
end
function FeatureTire:PlayCameraShake(path, length)
  local ShakeTime = 0.2
  if self.TireShakeTimer then
    self:RemoveTimer(self.TireShakeTimer)
    self.TireShakeTimer = nil
  end
  local AllowTireCameraTable = {
    [10133] = true,
    [10131] = true,
    [10132] = true,
    [10180] = true
  }
  self.TireShakeTimer = self:AddTimerLoop(0, function()
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    local CameraID = Lobby_camera_manager_module:GetCurrentCameraID()
    if AllowTireCameraTable[CameraID] then
      local GameplayStatics = import("GameplayStatics")
      local world = slua_GameFrontendHUD:GetWorld()
      local playerCameraManager = GameplayStatics.GetPlayerCameraManager(world, 0)
      local CameraShakeClass = import(path)
      local ECameraAnimPlaySpace = import("ECameraAnimPlaySpace")
      if slua.isValid(playerCameraManager) and slua.isValid(CameraShakeClass) then
        playerCameraManager:PlayCameraShake(CameraShakeClass, 1.0, ECameraAnimPlaySpace.CameraLocal, FRotator(0, 0, 0))
      end
    end
  end, length / ShakeTime, ShakeTime)
end
return TFeatureTire