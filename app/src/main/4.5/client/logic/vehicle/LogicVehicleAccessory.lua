local LogicVehicleAccessory = {}
local EnumOperateType = {PotOn = 0, PotOff = 1}
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
function LogicVehicleAccessory:DefineAndResetData()
  self.car_acc_list = nil
  self.car_install_acc_list = nil
  self.inherit_car_install_acc_list = nil
  self.original_vehicle_accessory_data = nil
end
function LogicVehicleAccessory:OnInitialize()
end
function LogicVehicleAccessory:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "LogicVehicleAccessory:OnPreSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
end
function LogicVehicleAccessory:ClearCacheData()
end
function LogicVehicleAccessory:GetCarAndAccessoryList()
  local VehicleAccessoryUnlockConfig = CDataTable.GetTable("VehicleAccessoryUnlockConfig")
  if not VehicleAccessoryUnlockConfig then
    log(bWriteLog and "LogicVehicleAccessory:GetCarAndAccessoryList VehicleAccessoryUnlockConfig is nil")
    return
  end
  local carList = {}
  local tVehicleIdIndex = {}
  for _, cfg in pairs(VehicleAccessoryUnlockConfig) do
    if cfg.VehicleId and cfg.AccItemId then
      if not carList[cfg.VehicleId] then
        carList[cfg.VehicleId] = {}
      end
      carList[cfg.VehicleId][cfg.AccItemId] = {
        costItemId = cfg.CostItemId,
        costItemCount = cfg.CostItemCount,
        AccessoryTypeId = cfg.AccessoryTypeId,
        AccessoryItemJumpUrl = cfg.AccessoryItemJumpUrl,
        ShowOrder = cfg.ShowOrder,
        bDefaultAccessory = cfg.bDefaultAccessory
      }
    end
  end
  self.original_vehicle_accessory_data = carList
  carList, tVehicleIdIndex = self:GetSortedCarList(carList)
  log_tree(bWriteLog and "LogicVehicleAccessory:GetCarAndAccessoryList carList:", carList)
  log_tree(bWriteLog and "LogicVehicleAccessory:GetCarAndAccessoryList tVehicleIdIndex:", tVehicleIdIndex)
  return carList, tVehicleIdIndex
end
function LogicVehicleAccessory:GetSortedCarList(carList)
  local getMinShowOrder = function(subtable)
    local minShowOrder
    for _, v in pairs(subtable) do
      if v and v.ShowOrder and (minShowOrder == nil or minShowOrder > v.ShowOrder) then
        minShowOrder = v.ShowOrder
      end
    end
    return minShowOrder or math.huge
  end
  local keyOrderList = {}
  for k, v in pairs(carList) do
    table.insert(keyOrderList, {
      key = k,
      order = getMinShowOrder(v)
    })
  end
  table.sort(keyOrderList, function(a, b)
    return a.order < b.order
  end)
  local sortedKeys = {}
  for i, v in pairs(keyOrderList) do
    sortedKeys[i] = v.key
  end
  local sortedData = {}
  for index, key in pairs(sortedKeys) do
    sortedData[index] = carList[key]
  end
  return sortedData, sortedKeys
end
function LogicVehicleAccessory:GetAccessoryListByVehicleId(vehicleId)
  if not vehicleId or not self.original_vehicle_accessory_data then
    log(bWriteLog and "LogicVehicleAccessory:GetAccessoryListByVehicleId vehicleId is nil")
    return {}
  end
  return self.original_vehicle_accessory_data[vehicleId] or {}
end
function LogicVehicleAccessory:CheckHasGetAccessoryItem(accItemId)
  if not accItemId then
    log(bWriteLog and "LogicVehicleAccessory:CheckHasGetAccessoryItem accItemId is nil")
    return false
  end
  local bHasGet = self.car_acc_list and self.car_acc_list[accItemId] ~= nil or false
  log(bWriteLog and "LogicVehicleAccessory:CheckHasGetAccessoryItem bHasGet:" .. tostring(bHasGet))
  return bHasGet
end
function LogicVehicleAccessory:CheckIsEquipAccessoryItem(vehicleId, accItemId, source)
  if not vehicleId or not accItemId then
    log(bWriteLog and "LogicVehicleAccessory:CheckIsEquipAccessoryItem param is nil")
    return false
  end
  if source == EWardrobeDataSource.InheritWardrobe then
    return self.inherit_car_install_acc_list and self.inherit_car_install_acc_list[vehicleId] and self.inherit_car_install_acc_list[vehicleId][accItemId] or false
  end
  return self.car_install_acc_list and self.car_install_acc_list[vehicleId] and self.car_install_acc_list[vehicleId][accItemId] or false
end
function LogicVehicleAccessory:PutOnAccessory(vehicleId, accItemId)
  local opType = EnumOperateType.PotOn
  self:send_car_accessory_op_req(vehicleId, accItemId, opType)
end
function LogicVehicleAccessory:PutOffAccessory(vehicleId, accItemId)
  local opType = EnumOperateType.PotOff
  self:send_car_accessory_op_req(vehicleId, accItemId, opType)
end
function LogicVehicleAccessory:CheckHasEnoughCost(costItemId, count)
  if not costItemId or not count then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local carWarDrobeData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(costItemId)
  return carWarDrobeData and carWarDrobeData.count and count <= carWarDrobeData.count
end
function LogicVehicleAccessory:CheckCanJumpToAct(vehicleID)
  if not vehicleID then
    return false, nil
  end
  local bCanJump = false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local ItemSourceJumpConfig
  if PublishRegionMacros.IsJapanOrKorea() then
    ItemSourceJumpConfig = CDataTable.GetTableData("ItemSourceJumpJKConfig", vehicleID)
  elseif PublishRegionMacros.IsBLUEHOLE() then
    ItemSourceJumpConfig = CDataTable.GetTableData("ItemSourceJumpINConfig", vehicleID)
  else
    ItemSourceJumpConfig = CDataTable.GetTableData("ItemSourceJumpConfig", vehicleID)
  end
  if not (ItemSourceJumpConfig and ItemSourceJumpConfig.JumpType) or ItemSourceJumpConfig.JumpType == "" then
    log(bWriteLog and "LogicVehicleAccessory:CheckCanJumpToAct ItemSourceJumpConfig is nil")
    return false, nil
  end
  local jumpId
  local StringUtil = require("common.string_util")
  local jumpTypeList = StringUtil.Split(ItemSourceJumpConfig.JumpType, "|")
  for i, jType in ipairs(jumpTypeList) do
    local nJumpID = tonumber(jType)
    if GlobalData.CheckCanJumpByTypeID(vehicleID, nJumpID) then
      bCanJump = true
      jumpId = nJumpID
      break
    end
  end
  return bCanJump, jumpId
end
function LogicVehicleAccessory:GetEquipedAccessoryList(vehicleId, source)
  if not vehicleId then
    return nil
  end
  local rawList
  if source == EWardrobeDataSource.InheritWardrobe then
    rawList = self.inherit_car_install_acc_list and self.inherit_car_install_acc_list[vehicleId]
  else
    rawList = self.car_install_acc_list and self.car_install_acc_list[vehicleId]
  end
  if rawList then
    local copy = {}
    for k, v in pairs(rawList) do
      copy[k] = v
    end
    return copy
  end
  return nil
end
function LogicVehicleAccessory:GetVehicleAccessoryList(uid, vehicleId, position, source)
  if not uid or not vehicleId then
    return nil
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) or tonumber(uid) == 0 then
    return self:GetEquipedAccessoryList(vehicleId, source)
  else
    position = position or 1
    local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local car_install_acc
    if GarageThemeSystem:IsInGarageTheme() then
      car_install_acc = TeamUpNewSystem.GetGarageVehicleAccessoryList(uid, position)
    else
      car_install_acc = TeamUpNewSystem.GetTeamShowVehicleAccessoryList(uid)
    end
    return car_install_acc
  end
end
function LogicVehicleAccessory:CheckHasGetVehicle(vehicleId)
  if not vehicleId then
    log(bWriteLog and "LogicVehicleAccessory:CheckHasGetVehicle invalid vehicleId")
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local carWarDrobeData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(vehicleId)
  return carWarDrobeData ~= nil
end
function LogicVehicleAccessory:CheckVehicleCanEquipAccessory(vehicleId)
  if not vehicleId then
    log(bWriteLog and "LogicVehicleAccessory:CheckVehicleCanEquipAccessory invalid vehicleId")
    return false
  end
  log(bWriteLog and "LogicVehicleAccessory:CheckVehicleCanEquipAccessory vehicleId:" .. tostring(vehicleId))
  local AccessoryUnlockConfigs = CDataTable.GetTableDataByFilter("VehicleAccessoryUnlockConfig", "VehicleId", vehicleId)
  if not AccessoryUnlockConfigs then
    log(bWriteLog and "LogicVehicleAccessory:CheckVehicleCanEquipAccessory false")
    return false
  end
  log(bWriteLog and "LogicVehicleAccessory:CheckVehicleCanEquipAccessory true")
  return true
end
function LogicVehicleAccessory:CreateAccessoryVehicle(vehicleId, bCreateSpringArm)
  if not vehicleId then
    return
  end
  local scale = 1.0
  local loc = FVector(15309.0, 5005.0, -21923.0)
  local VehicleShowCfg = CDataTable.GetTableData("AccessoryVehicleShowCfg", vehicleId)
  if VehicleShowCfg then
    if VehicleShowCfg.CarPos_af and VehicleShowCfg.CarPos_af:Num() >= 3 then
      loc = FVector(VehicleShowCfg.CarPos_af:Get(0), VehicleShowCfg.CarPos_af:Get(1), VehicleShowCfg.CarPos_af:Get(2))
    end
    if VehicleShowCfg.CarScale and tonumber(VehicleShowCfg.CarScale) then
      scale = tonumber(VehicleShowCfg.CarScale)
    end
  end
  local world = slua_GameFrontendHUD:GetWorld()
  local SpringArmActor
  if bCreateSpringArm then
    local actorClass = import("/Game/Arts_PlayerBluePrints/Vehicle_Show/Bp_UpgradeCar_Camera.Bp_UpgradeCar_Camera_C")
    if not actorClass then
      log(bWriteLog and "LogicVehicleAccessory:CreateAccessoryVehicle no DefaultSpringArmActorPath")
      return
    end
    SpringArmActor = world:SpawnActor(actorClass, loc + FVector(0, 0, -4), nil, nil)
    if not SpringArmActor then
      log(bWriteLog and "LogicVehicleAccessory:CreateAccessoryVehicle no spring arm")
      return
    end
    SpringArmActor:TryToStopAutoPlay()
    SpringArmActor:SetDefaultAutoPlayDelayTime(Const.DefaultAutoPlayDelayTime)
    SpringArmActor:SetDefaultPitchLimit(Const.DefaultPitchRotateLimit.Min, Const.DefaultPitchRotateLimit.Max)
    SpringArmActor:SetDefaultSpringArmLen(Const.DefaultSpringArmLen)
    SpringArmActor:SetAutoRotateSpeedRate(Const.DefaultAutoRotateSpeedRate)
    SpringArmActor:SetDefaultAutoRotateApproachSpeedRate(Const.DefaultAutoRotateApproachSpeedRate)
    SpringArmActor:SetDefaultTopPitch(Const.DefaultPitch.Top)
    SpringArmActor:SetDefaultTopPitch(Const.DefaultPitch.Mid)
    SpringArmActor:SetDefaultTopPitch(Const.DefaultPitch.Bot)
    SpringArmActor:SetDefaultCamFov(Const.DefaultCameraFov)
    SpringArmActor:SetSpringArmCamOffset(Const.DefaultCameraOffset.X, Const.DefaultCameraOffset.Y, Const.DefaultCameraOffset.Z)
    SpringArmActor:SetDefaultInitRotation(Const.DefaultCameraRotation.Roll, Const.DefaultCameraRotation.Pitch, Const.DefaultCameraRotation.Yaw)
    local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
    LobbyModelPossess:Possess(SpringArmActor)
  end
  local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
  local showActor = ModelFactory.CreateShowActor()
  local equipedAccessory = self:GetEquipedAccessoryList(vehicleId)
  local ExtraTable = {
    AccessoryList = equipedAccessory,
    ignore_download = true,
    CastPhontonShadow = true
  }
  showActor:ShowModelByResID(vehicleId, ExtraTable)
  if not slua.isValid(showActor) or not showActor:GetVehicleActor() then
    log(bWriteLog and "LogicVehicleAccessory:CheckVehicleCanEquipAccessory show actor failed")
    return nil
  end
  showActor:GetVehicleActor():SetActorTickEnabled(true)
  showActor:K2_SetActorLocation(loc, false, nil, false)
  showActor:SetActorScale3D(FVector(scale, scale, scale))
  return showActor, SpringArmActor
end
function LogicVehicleAccessory:CheckCanExchangeVehicleAccessory(accessoryItemId)
  if not accessoryItemId then
    log(bWriteLog and "LogicVehicleAccessory:CheckCanExchangeVehicleAccessory param is nil")
    return false
  end
  local ItemCfg = CDataTable.GetTableData("Item", accessoryItemId)
  if not ItemCfg or ItemCfg.ItemType ~= ENUM_ITEM_TYPE.VehicleAccessory then
    log(bWriteLog and "LogicVehicleAccessory:CheckCanExchangeVehicleAccessory VehicleAccessoryUnlockConfig is nil")
    return true
  end
  local AccessoryUnlockConfig = CDataTable.GetTableByFilter("VehicleAccessoryUnlockConfig", "AccItemId", accessoryItemId)
  if not AccessoryUnlockConfig then
    log(bWriteLog and "LogicVehicleAccessory:CheckCanExchangeVehicleAccessory VehicleAccessoryUnlockConfig is nil")
    return false
  end
  for _, cfg in pairs(AccessoryUnlockConfig) do
    if cfg.VehicleId then
      local hasGet = self:CheckHasGetVehicle(cfg.VehicleId)
      if hasGet then
        log(bWriteLog and "LogicVehicleAccessory:CheckCanExchangeVehicleAccessory has car cfg.VehicleId:" .. tostring(cfg.VehicleId))
        return true
      end
    end
  end
  log(bWriteLog and "LogicVehicleAccessory:CheckCanExchangeVehicleAccessory no car")
  return false
end
function LogicVehicleAccessory:GetPreviewVehicleIdAndYaw(accessoryItemId)
  if not accessoryItemId then
    log(bWriteLog and "LogicVehicleAccessory:GetPreviewVehicleId accessoryItemId is nil")
    return nil, nil
  end
  local AccessoryUnlockConfig = CDataTable.GetTableDataByFilter("VehicleAccessoryUnlockConfig", "AccItemId", accessoryItemId, "IsPreviewEnable", true)
  if not AccessoryUnlockConfig then
    log(bWriteLog and "LogicVehicleAccessory:GetPreviewVehicleId AccessoryUnlockConfig is nil")
    return nil, nil
  end
  local yaw
  if AccessoryUnlockConfig.PreviewVehicleYaw and AccessoryUnlockConfig.PreviewVehicleYaw ~= "" then
    yaw = tonumber(AccessoryUnlockConfig.PreviewVehicleYaw)
  end
  log(bWriteLog and "LogicVehicleAccessory:CheckCanExchangeVehicleAccessory VehicleId:" .. tostring(AccessoryUnlockConfig.VehicleId))
  return AccessoryUnlockConfig.VehicleId, yaw
end
function LogicVehicleAccessory:OnGetCarInfoRsp(car_acc_list, car_install_acc_list, inherit_car_info)
  if not car_acc_list or not car_install_acc_list then
    log(bWriteLog and "LogicVehicleAccessory:OnGetCarInfoRsp param is nil")
    return
  end
  log_tree(bWriteLog and "LogicVehicleAccessory OnGetCarInfoRsp car_acc_list = ", car_acc_list)
  log_tree(bWriteLog and "LogicVehicleAccessory OnGetCarInfoRsp car_install_acc_list = ", car_install_acc_list)
  self.  self.  self.inherit_car_install_acc_list = inherit_car_info and inherit_car_info.inherit_car_install_acc_list
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_ACCESSORY_DATA_UPDATE)
end
function LogicVehicleAccessory:send_car_unlock_accessory_req(car_id, acc_id)
  local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
  VehicleAccessoryHandler.send_car_unlock_accessory_req(car_id, acc_id)
end
function LogicVehicleAccessory:on_car_unlock_accessory_rsp(car_id, acc_id)
  if not car_id or not acc_id then
    log(bWriteLog and "LogicVehicleAccessory:on_car_unlock_accessory_rsp param is nil")
    return
  end
  self.car_acc_list = self.car_acc_list or {}
  self.car_acc_list[acc_id] = 1
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_ACCESSORY_UNLOCK_RSP, car_id, acc_id)
end
function LogicVehicleAccessory:send_car_accessory_op_req(car_id, acc_id, op_type)
  if not car_id or not acc_id then
    log(bWriteLog and "LogicVehicleAccessory:send_car_accessory_op_req param is nil")
    return
  end
  if not self.car_install_acc_list then
    log(bWriteLog and "LogicVehicleAccessory:send_car_accessory_op_req car_install_acc_list is nil")
    return
  end
  if not self.car_acc_list or not self.car_acc_list[acc_id] then
    log(bWriteLog and "LogicVehicleAccessory:send_car_accessory_op_req not has item")
    return
  end
  if not self:CheckHasGetVehicle(car_id) then
    log(bWriteLog and "LogicVehicleAccessory:send_car_accessory_op_req not has vehicle")
    return
  end
  if op_type == EnumOperateType.PotOn then
    if self:CheckIsEquipAccessoryItem(car_id, acc_id) then
      log(bWriteLog and "LogicVehicleAccessory:send_car_accessory_op_req has equiped")
      return
    end
  elseif not self:CheckIsEquipAccessoryItem(car_id, acc_id) then
    log(bWriteLog and "LogicVehicleAccessory:send_car_accessory_op_req has equiped")
    return
  end
  log(bWriteLog and "LogicVehicleAccessory:send_car_accessory_op_req car_id:" .. tostring(car_id) .. " acc_id:" .. tostring(acc_id))
  local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
  VehicleAccessoryHandler.send_car_accessory_op_req(car_id, acc_id, op_type)
end
function LogicVehicleAccessory:on_car_accessory_op_rsp(car_id, acc_id, op_type)
  if not (car_id and acc_id) or not op_type then
    log(bWriteLog and "LogicVehicleAccessory:on_car_accessory_op_rsp param is nil")
    return
  end
  self.car_install_acc_list = self.car_install_acc_list or {}
  self.car_install_acc_list[car_id] = self.car_install_acc_list[car_id] or {}
  if op_type == EnumOperateType.PotOn then
    self.car_install_acc_list[car_id][acc_id] = 1
  else
    self.car_install_acc_list[car_id][acc_id] = nil
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_ACCESSORY_EQUIP_UPDATE, car_id, acc_id, op_type)
end
function LogicVehicleAccessory:on_car_accessory_notify(car_acc_list)
  if not car_acc_list then
    log(bWriteLog and "LogicVehicleAccessory:on_car_accessory_notify car_acc_list is nil")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_ACCESSORY_ITEM_NOTIFY)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicVehicleAccessory)
return CModuleTemplate