local upgradeVehicle = {}
local Const = {
  DefaultCameraOffset = {
    X = 20,
    Y = 10,
    Z = 28
  },
  DefaultCameraRotation = {
    Roll = 0,
    Pitch = 1.6633,
    Yaw = 141.45
  },
  DefaultPitch = {
    Top = -40,
    Mid = -20,
    Bot = 0
  },
  DefaultPitchRotateLimit = {Min = -13, Max = 1},
  DefaultAutoPlayDelayTime = 10,
  DefaultCameraFov = 69.57,
  DefaultSpringArmLen = 600,
  DefaultAutoRotateSpeedRate = 1,
  DefaultAutoRotateApproachSpeedRate = 10
}
function upgradeVehicle:RegistEvents()
  upgradeVehicle.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_VEHICLE, self.JumpVehicle, self)
end
function upgradeVehicle:JumpVehicle(_, _, vars)
  log_tree("upgradeVehicle:JumpVehicle vars", vars)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshop) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshop))
    return
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local tab = vars and tonumber(vars.tab)
  local REFIT = VehicleCollectSystem.ENUM_VEHICLE_SYSTEM.REFIT
  if not tab then
    tab = REFIT
  elseif REFIT < tab then
    tab = REFIT
  end
  VehicleCollectSystem:OpenVehicleWorkShop(tab, vars and tonumber(vars.itemId))
end
function upgradeVehicle:Display(vehicleId, bLastRefitVehicle)
  self:Destroy()
  local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
  self.showActor = ModelFactory.CreateShowActor()
  local ExtraTable = {ignore_download = true, CastPhontonShadow = true}
  self.showActor:ShowModelByResID(vehicleId, ExtraTable)
  self.showActor:GetVehicleActor():SetActorTickEnabled(true)
  local cfgCar = CDataTable.GetTableData("VehicleRefitInfo", vehicleId)
  local RefitBPCfg = CDataTable.GetTableData("VehicleRefitBPConfig", cfgCar.vehicle_group_id)
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local SoftObjPath = KismetSystemLibrary.MakeSoftObjectPath(RefitBPCfg.path)
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local RefitVehicleHandleClass = STExtraBlueprintFunctionLibrary.GetClassByAssetReference(SoftObjPath)
  local VehicleHandle = RefitVehicleHandleClass()
  self.showActor:K2_SetActorLocation(VehicleHandle.Location, false, nil, false)
  self.showActor:SetActorScale3D(FVector(VehicleHandle.Scale, VehicleHandle.Scale, VehicleHandle.Scale))
  log(bWriteLog and "  : bLastRefitVehicle" .. tostring(bLastRefitVehicle))
  if bLastRefitVehicle ~= false then
    self:DestroyArm()
    local actorClass = import("/Game/Arts_PlayerBluePrints/Vehicle_Show/Bp_UpgradeCar_Camera.Bp_UpgradeCar_Camera_C")
    if not actorClass then
      log(bWriteLog and "not actorClass DefaultSpringArmActorPath ")
      return
    end
    local world = slua_GameFrontendHUD:GetWorld()
    if not slua.isValid(world) then
      log_error("upgradeVehicle:Display World is null")
      return
    end
    self._SpringArmActor = world:SpawnActor(actorClass, VehicleHandle.Location + FVector(0, 0, -4), nil, nil)
    if not self._SpringArmActor then
      log(bWriteLog and "not logic_SuperCar_200Version. Display")
      return
    end
    self._SpringArmActor:TryToStopAutoPlay()
    self._SpringArmActor:SetDefaultAutoPlayDelayTime(Const.DefaultAutoPlayDelayTime)
    self._SpringArmActor:SetDefaultPitchLimit(Const.DefaultPitchRotateLimit.Min, Const.DefaultPitchRotateLimit.Max)
    self._SpringArmActor:SetDefaultSpringArmLen(Const.DefaultSpringArmLen)
    self._SpringArmActor:SetAutoRotateSpeedRate(Const.DefaultAutoRotateSpeedRate)
    self._SpringArmActor:SetDefaultAutoRotateApproachSpeedRate(Const.DefaultAutoRotateApproachSpeedRate)
    self._SpringArmActor:SetDefaultTopPitch(Const.DefaultPitch.Top)
    self._SpringArmActor:SetDefaultTopPitch(Const.DefaultPitch.Mid)
    self._SpringArmActor:SetDefaultTopPitch(Const.DefaultPitch.Bot)
    self._SpringArmActor:SetDefaultCamFov(Const.DefaultCameraFov)
    self._SpringArmActor:SetSpringArmCamOffset(Const.DefaultCameraOffset.X, Const.DefaultCameraOffset.Y, Const.DefaultCameraOffset.Z)
    self._SpringArmActor:SetDefaultInitRotation(Const.DefaultCameraRotation.Roll, Const.DefaultCameraRotation.Pitch, Const.DefaultCameraRotation.Yaw)
    local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
    LobbyModelPossess:Possess(self._SpringArmActor)
  end
end
function upgradeVehicle:Destroy(all)
  log(bWriteLog and "  : upgradeVehicle Destroy")
  if slua.isValid(self.showActor) then
    self.showActor:Destroy()
  end
  self.showActor = nil
  if all then
    self:DestroyArm()
  end
end
function upgradeVehicle:DestroyArm()
  if slua.isValid(self._SpringArmActor) then
    self._SpringArmActor:K2_DestroyActor()
  end
  self._SpringArmActor = nil
  local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
  LobbyModelPossess:UnPossess()
end
function upgradeVehicle:OnUpgradeSuccess()
  if self._SpringArmActor and slua.isValid(self._SpringArmActor) then
    self._SpringArmActor:OnVehicleUpgradeSuccess()
  end
end
function upgradeVehicle:IsRefitVehicle(car_id)
  local cfgCar = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  return cfgCar.unlock_part_list ~= ""
end
function upgradeVehicle:GetAssociatedCars(car, itemCfg)
  if not self.temp then
    self.temp = {}
  end
  if self.temp[car] then
    return self.temp[car]
  end
  itemCfg = itemCfg or CDataTable.GetTableData("Item", car)
  if not itemCfg or itemCfg.ItemType ~= 9 then
    return
  end
  local data = {}
  local carCfg = CDataTable.GetTableData("VehicleRefitInfo", car)
  if carCfg then
    local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
    local vehicleTable = VehicleRefitHandler.GetUnlockCarCfgTable()
    for _, v in pairs(vehicleTable) do
      if v.vehicle_group_id == carCfg.vehicle_group_id then
        table.insert(data, v.vehicle_id)
      end
    end
  end
  self.temp[car] = data
  return data
end
function upgradeVehicle:GetVehicleUpgradeConfig()
  local vehicle2GroupKey = {}
  local groupKey2Vehicles = {}
  local upgradeCfgs = CDataTable.GetTable("VehicleUpgradeConfig")
  for id, cfg in pairs(upgradeCfgs) do
    local groupKey = cfg.ActivityID .. cfg.Series
    vehicle2GroupKey[cfg.ItemID] = groupKey
    if groupKey2Vehicles[groupKey] == nil then
      groupKey2Vehicles[groupKey] = {}
    end
    table.insert(groupKey2Vehicles[groupKey], cfg.ItemID)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CUpVehicleModule = class(CModuleBase, nil, upgradeVehicle)
return CUpVehicleModule