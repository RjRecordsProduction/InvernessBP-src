local LogicVehicleExtendedFeature = {}
local DefaultPlateBgId = 7301000
local EnumOperateType = {PotOn = 0, PotOff = 1}
function LogicVehicleExtendedFeature:DefineAndResetData()
  self.cur_feature_data = nil
  self.equip_plate_background = nil
  self.equip_chassis_light = nil
  self.equip_switch_effect = nil
  self.car_plate_background = nil
  self.car_chassis_light = nil
  self.car_switch_effect = nil
  self.IsInGMChassisLightMTest = false
  self.AsyncPSOTimer = nil
  self.bHasChangedPSOValue = false
  self.OriginIOSAsyncCreatePSO = nil
  self.OriginAsyncPSO = nil
end
function LogicVehicleExtendedFeature:OnInitialize()
end
function LogicVehicleExtendedFeature:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_CHANGE, self.OnWardrobeUpdateItem, self)
end
function LogicVehicleExtendedFeature:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "LogicVehicleExtendedFeature:OnPostSwitchGameStatus preState:" .. tostring(preState) .. " nextState:" .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
    VehicleAccessoryHandler.send_get_car_feature_data_req()
  end
end
function LogicVehicleExtendedFeature:ClearCacheData()
end
function LogicVehicleExtendedFeature:GetVehicleChassisLightList()
  local ChassisLightList = {}
  local VehicleChassisLightCfg = CDataTable.GetTable("VehicleChassisLightCfg")
  if not VehicleChassisLightCfg then
    log(bWriteLog and "LogicVehicleExtendedFeature:GetVehicleChassisLightList VehicleChassisLightCfg is nil")
    return ChassisLightList
  end
  for _, cfg in pairs(VehicleChassisLightCfg) do
    table.insert(ChassisLightList, cfg.ItemID)
  end
  return ChassisLightList
end
function LogicVehicleExtendedFeature:GetPlateBgList()
  local PlateBgList = {}
  table.insert(PlateBgList, {
    ItemID = self:GetDefaultPlateBgId()
  })
  local VehiclePlateBgCfg = CDataTable.GetTable("VehiclePlateBgCfg")
  if not VehiclePlateBgCfg then
    log(bWriteLog and "LogicVehicleExtendedFeature:GetPlateBgList VehiclePlateBgCfg is nil")
    return PlateBgList
  end
  for _, cfg in pairs(VehiclePlateBgCfg) do
    table.insert(PlateBgList, {
      ItemID = cfg.ItemID
    })
  end
  return PlateBgList
end
function LogicVehicleExtendedFeature:GetSwitchEffectList()
  local VehicleSwitchEffectList = {}
  local VehicleSwitchEffectCfg = CDataTable.GetTable("VehicleSwitchEffectCfg")
  if not VehicleSwitchEffectCfg then
    log(bWriteLog and "LogicVehicleExtendedFeature:GetSwitchEffectList VehicleSwitchEffectCfg is nil")
    return VehicleSwitchEffectList
  end
  for _, cfg in pairs(VehicleSwitchEffectCfg) do
    table.insert(VehicleSwitchEffectList, cfg.ItemID)
  end
  return VehicleSwitchEffectList
end
function LogicVehicleExtendedFeature:GetFeatureItemStateFlag(featureId)
  if not featureId then
    log(bWriteLog and "LogicVehicleExtendedFeature:GetFeatureItemStateFlag featureId is nil")
    return -1
  end
  if featureId == self:GetDefaultPlateBgId() then
    log(bWriteLog and "LogicVehicleExtendedFeature:GetFeatureItemStateFlag featureId == DefaultPlateBgId")
    return 0
  end
  local HasFlag = self.car_plate_background and self.car_plate_background[featureId]
  HasFlag = HasFlag or self.car_chassis_light and self.car_chassis_light[featureId]
  HasFlag = HasFlag or self.car_switch_effect and self.car_switch_effect[featureId]
  log(bWriteLog and "LogicVehicleExtendedFeature:GetFeatureItemStateFlag featureId:" .. tostring(featureId) .. " HasGet:" .. tostring(HasFlag))
  return HasFlag or -1
end
function LogicVehicleExtendedFeature:CheckHasGetFeatureItem(featureId)
  local featureStateFlag = self:GetFeatureItemStateFlag(featureId)
  if featureStateFlag and 0 <= featureStateFlag then
    return true
  end
  return false
end
function LogicVehicleExtendedFeature:CheckHasEquippedItem(featureId, vehicleId)
  if not featureId then
    log(bWriteLog and "LogicVehicleExtendedFeature:CheckHasEquippedItem featureId or itemSubType is nil")
    return
  end
  log(bWriteLog and "LogicVehicleExtendedFeature:CheckHasEquippedItem featureId:" .. tostring(featureId) .. " vehicleId:" .. tostring(vehicleId))
  local itemCfg = CDataTable.GetTableData("Item", featureId)
  local itemSubType = itemCfg and itemCfg.ItemSubType
  if itemSubType == ENUM_ITEM_SUBTYPE.VehiclePlateBackground then
    local curPlateBgId = self:GetCurEquippedPlateBg(vehicleId)
    if not curPlateBgId then
      if featureId == self:GetDefaultPlateBgId() then
        return true
      end
      return false
    end
    return curPlateBgId == featureId
  elseif itemSubType == ENUM_ITEM_SUBTYPE.VehicleChassisLight then
    return vehicleId and self.equip_chassis_light and self.equip_chassis_light[vehicleId] and self.equip_chassis_light[vehicleId] == featureId
  elseif itemSubType == ENUM_ITEM_SUBTYPE.VehicleSwitchEffect then
    return self.equip_switch_effect == featureId
  end
  return false
end
function LogicVehicleExtendedFeature:PutOnVehicleFeature(featureId, vehicleId)
  log(bWriteLog and "LogicVehicleExtendedFeature:PutOnVehicleFeature featureId:" .. tostring(featureId) .. " vehicleId:" .. tostring(vehicleId))
  if not featureId then
    log(bWriteLog and "LogicVehicleExtendedFeature:PutOnVehicleFeature featureId or itemSubType is nil")
    return
  end
  if self:CheckHasEquippedItem(featureId, vehicleId) then
    log(bWriteLog and "LogicVehicleExtendedFeature:PutOnVehicleFeature has equiped Item")
    return
  end
  local opType = EnumOperateType.PotOn
  self:send_equip_car_feature_req(vehicleId, featureId, opType)
end
function LogicVehicleExtendedFeature:PutOffVehicleFeature(featureId, vehicleId)
  log(bWriteLog and "LogicVehicleExtendedFeature:PutOffVehicleFeature featureId:" .. tostring(featureId) .. " vehicleId:" .. tostring(vehicleId))
  if not featureId then
    log(bWriteLog and "LogicVehicleExtendedFeature:PutOffVehicleFeature featureId or itemSubType is nil")
    return
  end
  if not self:CheckHasEquippedItem(featureId, vehicleId) then
    log(bWriteLog and "LogicVehicleExtendedFeature:PutOffVehicleFeature has equiped Item")
    return
  end
  local opType = EnumOperateType.PotOff
  self:send_equip_car_feature_req(vehicleId, featureId, opType)
end
function LogicVehicleExtendedFeature:PutOffPlateBgItem(vehicleId)
  log(bWriteLog and "LogicVehicleExtendedFeature:PutOffPlateBgItem vehicleId:" .. tostring(vehicleId))
  if not vehicleId then
    log(bWriteLog and "LogicVehicleExtendedFeature:PutOffPlateBgItem vehicleId is nil")
    return
  end
  local opType = EnumOperateType.PotOff
  self:send_equip_car_feature_req(vehicleId, self:GetCurEquippedPlateBg(vehicleId), opType)
end
function LogicVehicleExtendedFeature:GetCurEquippedPlateBg(vehicleId, source)
  log(bWriteLog and string.format("LogicVehicleExtendedFeature:GetCurEquippedPlateBg vehicleId:%s, source:%s", tostring(vehicleId), tostring(source)))
  if not vehicleId then
    return nil
  end
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(vehicleId)
  if not VehicleType then
    return nil
  end
  if source == EWardrobeDataSource.InheritWardrobe then
    local bgItemID = self.inherit_feature_data and self.inherit_feature_data.equip_plate_background and self.inherit_feature_data.equip_plate_background[VehicleType]
    bgItemID = bgItemID and 0 < bgItemID and bgItemID or nil
    return bgItemID
  end
  if not (self.equip_plate_background and self.equip_plate_background[VehicleType]) or self.equip_plate_background[VehicleType] <= 0 then
    return nil
  end
  return self.equip_plate_background[VehicleType]
end
function LogicVehicleExtendedFeature:CheckHasEnoughCost(costItemId, count)
  if not costItemId or not count then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local carWarDrobeData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(costItemId)
  return carWarDrobeData and carWarDrobeData.count and count <= carWarDrobeData.count
end
function LogicVehicleExtendedFeature:GetEquipedChassisLightData(vehicleId, source)
  if not vehicleId then
    return nil
  end
  if source == EWardrobeDataSource.InheritWardrobe then
    return self.inherit_feature_data and self.inherit_feature_data.equip_chassis_light and self.inherit_feature_data.equip_chassis_light[vehicleId]
  end
  return self.equip_chassis_light and self.equip_chassis_light[vehicleId] or nil
end
function LogicVehicleExtendedFeature:GetVehicleChassisLightData(uid, vehicleId, position, source)
  if not uid or not vehicleId then
    return nil
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) or tonumber(uid) == 0 then
    return self:GetEquipedChassisLightData(vehicleId, source)
  else
    position = position or 1
    local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local chassis_light
    if GarageThemeSystem:IsInGarageTheme() then
      chassis_light = TeamUpNewSystem.GetGarageVehicleChassisLight(uid, position)
    else
      chassis_light = TeamUpNewSystem.GetTeamShowVehicleChassisLight(uid)
    end
    return chassis_light
  end
end
function LogicVehicleExtendedFeature:GetDefaultPlateBgId()
  return DefaultPlateBgId
end
function LogicVehicleExtendedFeature:CheckHasNewItemReddot(extendedFeatureType)
  log(bWriteLog and "LogicVehicleExtendedFeature:CheckHasNewItemReddot extendedFeatureType:" .. tostring(extendedFeatureType))
  local VehicleSystem_Main_Show_Config = require("client.slua.umg.vehicle.config.VehicleSystem_Main_Show_Config")
  local ENUM_Vehicle_ExtendedFeatureType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_ExtendedFeatureType
  if extendedFeatureType == ENUM_Vehicle_ExtendedFeatureType.VEHICLE_DIY then
    local VehicleAppliqueCfg = CDataTable.GetTable("VehicleAppliqueCfg")
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    for _, v in pairs(VehicleAppliqueCfg) do
      local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(v.ID)
      if itemData and itemData.isNew then
        return true
      end
    end
    return false
  end
  local tableData
  if extendedFeatureType == ENUM_Vehicle_ExtendedFeatureType.CHASSIS_LIGHT then
    tableData = self.car_chassis_light
  elseif extendedFeatureType == ENUM_Vehicle_ExtendedFeatureType.VEHICLE_SWITCH_EFFECT then
    tableData = self.car_switch_effect
  elseif extendedFeatureType == ENUM_Vehicle_ExtendedFeatureType.VEHICLE_PLATE_BG then
    tableData = self.car_plate_background
  end
  if not tableData then
    log(bWriteLog and "LogicVehicleExtendedFeature:CheckHasNewItemReddot tableData is nil")
    return false
  end
  for _, isNewFlag in pairs(tableData) do
    if isNewFlag == 1 then
      log(bWriteLog and "LogicVehicleExtendedFeature:CheckHasNewItemReddot has new data")
      return true
    end
  end
  log(bWriteLog and "LogicVehicleExtendedFeature:CheckHasNewItemReddot false")
  return false
end
function LogicVehicleExtendedFeature:CheckHasNewItemReddot_AllType()
  local VehicleSystem_Main_Show_Config = require("client.slua.umg.vehicle.config.VehicleSystem_Main_Show_Config")
  local ENUM_Vehicle_ExtendedFeatureType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_ExtendedFeatureType
  local bHasReddot = self:CheckHasNewItemReddot(ENUM_Vehicle_ExtendedFeatureType.CHASSIS_LIGHT)
  bHasReddot = bHasReddot or self:CheckHasNewItemReddot(ENUM_Vehicle_ExtendedFeatureType.VEHICLE_SWITCH_EFFECT)
  bHasReddot = bHasReddot or self:CheckHasNewItemReddot(ENUM_Vehicle_ExtendedFeatureType.VEHICLE_DIY)
  return bHasReddot
end
function LogicVehicleExtendedFeature:RefreshReddotData()
  local bShowReddot = self:CheckHasNewItemReddot_AllType()
  local reddotNum = 0
  if bShowReddot then
    reddotNum = 1
  end
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  local reddotVehicle = require("client.slua.logic.vehicle.reddot_vehicle")
  local gropData = generalLabReddotData.GetReddotData(reddot_macro.SystemName.Vehicle)
  if not gropData then
    return
  end
  if gropData[reddotVehicle.SubSysID.NewFeatureItem] then
    log(bWriteLog and "LogicVehicleExtendedFeature:RefreshReddotData 1 reddotNum " .. tostring(reddotNum))
    gropData[reddotVehicle.SubSysID.NewFeatureItem].newCount = reddotNum
  end
  local VehicleSystem_Main_Show_Config = require("client.slua.umg.vehicle.config.VehicleSystem_Main_Show_Config")
  local ENUM_Vehicle_ExtendedFeatureType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_ExtendedFeatureType
  local bHasBgReddot = self:CheckHasNewItemReddot(ENUM_Vehicle_ExtendedFeatureType.VEHICLE_PLATE_BG)
  if gropData[reddotVehicle.SubSysID.VehicleCollect] and gropData[reddotVehicle.SubSysID.VehicleCollect][reddotVehicle.SubSysID.NewPlateBG] then
    log(bWriteLog and "LogicVehicleExtendedFeature:RefreshReddotData 2 bHasBgReddot " .. tostring(bHasBgReddot))
    gropData[reddotVehicle.SubSysID.VehicleCollect][reddotVehicle.SubSysID.NewPlateBG].newCount = bHasBgReddot and 1 or 0
  end
  EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_WorkShop)
end
function LogicVehicleExtendedFeature:ClearItemReddot(featureId)
  log(bWriteLog and "LogicVehicleExtendedFeature:ClearItemReddot featureId:" .. tostring(featureId))
  if not featureId then
    log(bWriteLog and "LogicVehicleExtendedFeature:ClearItemReddot featureId or itemSubType is nil")
    return false
  end
  local VehicleAppliqueCfg = CDataTable.GetTableData("VehicleAppliqueCfg", featureId)
  if VehicleAppliqueCfg then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(featureId)
    if itemData then
      itemData.isNew = false
      local RedpointHandler = require("client.network.Protocol.RedpointHandler")
      RedpointHandler.send_select_item_list({
        [tonumber(itemData.insID)] = true
      })
      self:RefreshReddotData()
      return true
    end
    return false
  end
  local hasReddot = self:CheckIsFeatureItemHasReddot(featureId)
  if not hasReddot then
    log(bWriteLog and "LogicVehicleExtendedFeature:ClearItemReddot not get item or has clear reddot")
    return false
  end
  local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
  VehicleAccessoryHandler.send_clear_car_feature_red_point_req(featureId)
  self:ClearItemReddotData(featureId)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_EXTENDED_FEATURE_REDDOT_CHANGE, true)
  return true
end
function LogicVehicleExtendedFeature:ClearItemReddotData(resid)
  if not resid then
    log(bWriteLog and "LogicVehicleExtendedFeature:ClearItemReddotData resid is nil")
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", resid)
  local itemSubType = itemCfg and itemCfg.ItemSubType
  local dataTable
  if itemSubType == ENUM_ITEM_SUBTYPE.VehiclePlateBackground then
    dataTable = self.car_plate_background
  elseif itemSubType == ENUM_ITEM_SUBTYPE.VehicleChassisLight then
    dataTable = self.car_chassis_light
  elseif itemSubType == ENUM_ITEM_SUBTYPE.VehicleSwitchEffect then
    dataTable = self.car_switch_effect
  end
  if not dataTable then
    log(bWriteLog and "LogicVehicleExtendedFeature:on_clear_car_feature_red_point_rsp dataTable is nil")
    return
  end
  dataTable[resid] = 0
  self:RefreshReddotData()
end
function LogicVehicleExtendedFeature:CheckIsFeatureItemHasReddot(featureId)
  local hasGetFlag = self:GetFeatureItemStateFlag(featureId)
  return hasGetFlag == 1
end
function LogicVehicleExtendedFeature:OnWardrobeUpdateItem(_, _, changelist)
  for _, changeData in pairs(changelist) do
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(changeData.instid)
    if itemData then
      local VehicleAppliqueCfg = CDataTable.GetTableData("VehicleAppliqueCfg", changeData.res_id)
      if VehicleAppliqueCfg then
        self:RefreshReddotData()
        return
      end
    end
  end
end
function LogicVehicleExtendedFeature:send_get_car_feature_data_req()
  local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
  VehicleAccessoryHandler.send_get_car_feature_data_req()
end
function LogicVehicleExtendedFeature:on_get_car_feature_data_rsp(feature_data, inherit_feature_data)
  if not feature_data then
    log(bWriteLog and "LogicVehicleExtendedFeature:on_get_car_feature_data_rsp feature_data is nil")
    return
  end
  self:InitServerData(feature_data, inherit_feature_data)
  self:RefreshReddotData()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_EXTENDED_FEATURE_DATA_RSP)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_EXTENDED_FEATURE_REDDOT_CHANGE, false)
end
function LogicVehicleExtendedFeature:send_equip_car_feature_req(car_id, resid, op_type)
  if not resid then
    log(bWriteLog and "LogicVehicleExtendedFeature:send_equip_car_feature_req param is nil")
    return
  end
  if not self:CheckHasGetFeatureItem(resid) then
    log(bWriteLog and "LogicVehicleExtendedFeature:send_equip_car_feature_req CheckHasGetFeatureItem false")
    return
  end
  log(bWriteLog and "LogicVehicleExtendedFeature:send_equip_car_feature_req car_id:" .. tostring(car_id) .. " acc_id:" .. tostring(acc_id))
  local VehicleAccessoryHandler = require("client.network.Protocol.VehicleAccessoryHandler")
  VehicleAccessoryHandler.send_equip_car_feature_req(car_id, resid, op_type)
end
function LogicVehicleExtendedFeature:on_equip_car_feature_rsp(car_id, resid, op_type, feature_data)
  if not (resid and op_type) or not feature_data then
    log(bWriteLog and "LogicVehicleExtendedFeature:on_equip_car_feature_rsp param is nil")
    return
  end
  self:InitServerData(feature_data)
  if car_id then
    local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
    HallThemeUtils.ShowThemeVehicle()
  end
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_EXTENDED_FEATURE_EQUIP_UPDATE, resid, op_type, car_id)
end
function LogicVehicleExtendedFeature:on_notify_car_feature_data(feature_data)
  if not feature_data then
    log(bWriteLog and "LogicVehicleExtendedFeature:on_car_accessory_notify car_acc_list is nil")
    return
  end
  self:InitServerData(feature_data)
  self:RefreshReddotData()
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_EXTENDED_FEATURE_NOTIFY)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_ACCESSORY, EVENTID_VEHICLE_EXTENDED_FEATURE_REDDOT_CHANGE, false)
end
function LogicVehicleExtendedFeature:on_clear_car_feature_red_point_rsp(resid)
  self:ClearItemReddotData(resid)
end
function LogicVehicleExtendedFeature:InitServerData(feature_data, inherit_feature_data)
  if not feature_data then
    log(bWriteLog and "LogicVehicleExtendedFeature:on_get_car_feature_data_rsp feature_data is nil")
    return
  end
  self.cur_  self.equip_plate_background = feature_data.equip_plate_background
  self.equip_chassis_light = feature_data.equip_chassis_light
  self.equip_switch_effect = feature_data.equip_switch_effect
  self.car_plate_background = feature_data.car_plate_background
  self.car_chassis_light = feature_data.car_chassis_light
  self.car_switch_effect = feature_data.car_switch_effect
  self.end
function LogicVehicleExtendedFeature:SetGMChassisLightTest(bInGM)
  if not IsEditor then
    self.IsInGMChassisLightMTest = false
  end
  self.IsInGMChassisLightMTest = bInGM
end
function LogicVehicleExtendedFeature:CloseAsyncPSO()
  log(bWriteLog and "LogicVehicleExtendedFeature:CloseAsyncPSO")
  if self.AsyncPSOTimer then
    self:RemoveTimer(self.AsyncPSOTimer)
    self.AsyncPSOTimer = nil
  end
  if self.bHasChangedPSOValue then
    log(bWriteLog and "LogicVehicleExtendedFeature:CloseAsyncPSO bHasChangedPSOValue true")
    self.AsyncPSOTimer = self:AddTimerOnce(0.1, function()
      self:RecoverAsyncPSOValue()
    end)
    return
  end
  local IOSAsyncCreatePSO = "r.Mobile.IOSAsyncCreatePSO"
  local AsyncCreatePSO = "r.AsyncPSO.Pause"
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local bChange = false
  local IOSOldValue = USTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue(IOSAsyncCreatePSO)
  self.OriginIOSAsyncCreatePSO = IOSOldValue
  log(bWriteLog and "LogicVehicleExtendedFeature:CloseAsyncPSO IOSOldValue:" .. tostring(IOSOldValue))
  if IOSOldValue ~= 0 then
    bChange = true
    GameInstance:ExecuteCMD(IOSAsyncCreatePSO, 0)
  end
  local OldValue = USTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue(AsyncCreatePSO)
  self.OriginAsyncPSO = OldValue
  log(bWriteLog and "LogicVehicleExtendedFeature:CloseAsyncPSO OldValue:" .. tostring(OldValue))
  if OldValue ~= 1 then
    bChange = true
    GameInstance:ExecuteCMD(AsyncCreatePSO, 1)
  end
  self.bHasChangedPSOValue = bChange
  if bChange then
    self.AsyncPSOTimer = self:AddTimerOnce(0.1, function()
      self:RecoverAsyncPSOValue()
    end)
  end
end
function LogicVehicleExtendedFeature:RecoverAsyncPSOValue()
  log(bWriteLog and "LogicVehicleExtendedFeature:RecoverAsyncPSOValue OriginIOSAsyncCreatePSO:" .. tostring(self.OriginIOSAsyncCreatePSO) .. " OriginAsyncPSO:" .. tostring(self.OriginAsyncPSO))
  self.bHasChangedPSOValue = false
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if self.OriginIOSAsyncCreatePSO then
    GameInstance:ExecuteCMD("r.Mobile.IOSAsyncCreatePSO", self.OriginIOSAsyncCreatePSO)
  end
  if self.OriginAsyncPSO then
    GameInstance:ExecuteCMD("r.AsyncPSO.Pause", self.OriginAsyncPSO)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicVehicleExtendedFeature)
return CModuleTemplate