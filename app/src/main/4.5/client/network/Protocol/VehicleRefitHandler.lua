local NetManager = require("client.network.comm.NetManager")
local StringUtil = require("common.string_util")
local VehicleRefitHandler = {
  resCarInfoList = {},
  bMaskPutTipsInLevelUp = false,
  unlock_car_cfgtb = {},
  carWithTime = {},
  OwnCarInfoMap = {},
  car_opt_status_default = 0,
  car_opt_status_modifi = 1,
  car_opt_status_level = 2,
  ClickGoToStore = false,
  car_refit_cost_state_pay = 0,
  car_refit_cost_state_free = 1,
  car_refit_cost_state_owned = 2
}
function VehicleRefitHandler.GetUnlockCarCfgTable()
  return VehicleRefitHandler.unlock_car_cfgtb
end
function VehicleRefitHandler.ShowAbleCars()
  return VehicleRefitHandler.carWithTime
end
function VehicleRefitHandler.CreateUnlockCarCfgTable()
  local TimeUtil = require("client.common.time_util")
  VehicleRefitHandler.unlock_car_cfgtb = {}
  VehicleRefitHandler.carWithTime = {}
  local cfgtb = VehicleRefitHandler.res_unlock_car_cfgtb
  if not cfgtb then
    return
  end
  for k, v in pairs(cfgtb) do
    cfgtb[k] = TimeUtil.TimeStringToUnixstamp(v)
  end
  local tNow = TimeUtil.GetServerTimeInSec()
  local vehicletable = CDataTable.GetTable("VehicleRefitInfo")
  for k, v in pairs(vehicletable) do
    VehicleRefitHandler.unlock_car_cfgtb[k] = v
    local tUnlock = cfgtb[v.vehicle_group_id]
    if tUnlock and tNow > tUnlock then
      VehicleRefitHandler.carWithTime[k] = v
    end
  end
end
function VehicleRefitHandler.GetCarDefaultStyleList(car_id)
  local list = {}
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if cfg == nil then
    return list
  end
  local defaultList = StringUtil.Split(cfg.DefaultStyleList, "|")
  if defaultList == nil then
    return list
  end
  for k, v in pairs(defaultList) do
    table.insert(list, tonumber(v))
  end
  return list
end
function VehicleRefitHandler.IsInDefaultStyleList(car_id, StyleID)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if cfg == nil then
    return false
  end
  local defaultList = StringUtil.Split(cfg.DefaultStyleList, "|")
  if defaultList == nil then
    return false
  end
  for k, v in pairs(defaultList) do
    if tonumber(v) == tonumber(StyleID) then
      return true
    end
  end
  return false
end
function VehicleRefitHandler.IsInList(list, item)
  if list == nil or item == nil then
    return false
  end
  for k, v in pairs(list) do
    if v == item then
      return true
    end
  end
  return false
end
function VehicleRefitHandler.HasStyle(car_id, style_id, source)
  local car_list
  if source == EWardrobeDataSource.eWardrobeDataSource_Local then
    car_list = VehicleRefitHandler.inheritCarInfoList.car_list
  else
    car_list = VehicleRefitHandler.resCarInfoList.car_list
  end
  if car_list == nil then
    return false
  end
  for k, v in pairs(car_list) do
    if car_id == k then
      for kk, vv in pairs(v) do
        if vv == style_id then
          return true
        end
      end
      return false
    end
  end
  return false
end
function VehicleRefitHandler.GetCarLevel(car_id)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if cfg == nil then
    return 1
  end
  return cfg.level
end
function VehicleRefitHandler.CanLevelUp(car_id)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if cfg == nil then
    return false
  end
  local maxLevel = 1
  local tb = VehicleRefitHandler.GetUnlockCarCfgTable()
  for k, v in pairs(tb) do
    if v.vehicle_group_id == cfg.vehicle_group_id and maxLevel < v.level then
      maxLevel = v.level
    end
  end
  if maxLevel <= cfg.level then
    return false
  end
  return true
end
function VehicleRefitHandler.GetShowAttrList(car_id)
  local cfg = VehicleRefitHandler.GetCartLevelCfg(car_id, 1)
  if not cfg then
    return {}
  end
  local list = {}
  local tb = CDataTable.GetTable("VehicleAttrShow")
  for k, v in pairs(tb) do
    if v.vehicle_id == cfg.vehicle_id then
      local attr = {}
      attr.key = v.des
      attr.val = v.val
      attr.max = v.upper
      table.insert(list, attr)
    end
  end
  return list
end
function VehicleRefitHandler.GetCarGroupId(car_id)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if cfg == nil then
    return 0
  end
  return cfg.vehicle_group_id
end
function VehicleRefitHandler.GetCarUnlockPartList(car_id)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if not cfg then
    return nil
  end
  local partList = StringUtil.Split(cfg.unlock_part_list, ";")
  for i = 1, #partList do
    partList[i] = tonumber(partList[i])
  end
  return partList
end
function VehicleRefitHandler.GetCarUnlockPartLevel(vehicleGroupId, partGroupId)
  local tb = CDataTable.GetTable("VehicleRefitInfo")
  for k, v in pairs(tb) do
    if v.vehicle_group_id == vehicleGroupId then
      local partList = StringUtil.Split(v.unlock_part_list, ";")
      for i = 1, #partList do
        partList[i] = tonumber(partList[i])
      end
      if VehicleRefitHandler.IsInList(partList, partGroupId) then
        return v.level
      end
    end
  end
  return 0
end
function VehicleRefitHandler.GetMaxLevelUpCfg(car_id)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if cfg == nil then
    return nil
  end
  local maxLevel = 1
  local maxLevelCfg = cfg
  local tb = VehicleRefitHandler.GetUnlockCarCfgTable()
  for k, v in pairs(tb) do
    if v.vehicle_group_id == cfg.vehicle_group_id and maxLevel < v.level then
      maxLevel = v.level
      maxLevelCfg = v
    end
  end
  return maxLevelCfg
end
function VehicleRefitHandler.GetCarPartGroupList(car_id)
  local vehicleGroupId = VehicleRefitHandler.GetCarGroupId(car_id)
  if vehicleGroupId == 0 then
    return nil
  end
  local partGroupMap = {}
  local tb = CDataTable.GetTable("VehicleRefitStyle")
  local unlockPartList = VehicleRefitHandler.GetCarUnlockPartList(car_id)
  for k, v in pairs(tb) do
    if v.can_fit == 1 and v.vehicle_group_id == vehicleGroupId and partGroupMap[v.part_group_id] == nil then
      local info = {}
      info.cfg = v
      info.bLocked = not VehicleRefitHandler.IsInList(unlockPartList, v.part_group_id)
      info.unLockLevel = VehicleRefitHandler.GetCarUnlockPartLevel(vehicleGroupId, v.part_group_id)
      if 0 < info.unLockLevel then
        partGroupMap[v.part_group_id] = info
      end
    end
  end
  local partGroupList = {}
  for k, v in pairs(partGroupMap) do
    table.insert(partGroupList, v)
  end
  table.sort(partGroupList, function(a, b)
    if a.unLockLevel == b.unLockLevel then
      return a.cfg.part_group_id < b.cfg.part_group_id
    else
      return a.unLockLevel < b.unLockLevel
    end
  end)
  return partGroupList
end
function VehicleRefitHandler.GetLevelUpCfgList(carId)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", carId)
  if cfg == nil then
    return {}
  end
  local list = {}
  local tb = VehicleRefitHandler.GetUnlockCarCfgTable()
  for k, v in pairs(tb) do
    if v.vehicle_group_id == cfg.vehicle_group_id then
      local item = {}
      item.cfg = v
      item.bLocked = cfg.level < v.level
      item.strLv = LocUtil.LocalizeResFormat(6417, v.level)
      item.vehicle_id = v.vehicle_id
      table.insert(list, item)
    end
  end
  table.sort(list, function(left, right)
    if left.cfg.level < right.cfg.level then
      return true
    else
      return false
    end
  end)
  return list
end
function VehicleRefitHandler.GetCartLevelCfg(car_id, level)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  if cfg == nil then
    return nil
  end
  if cfg.level == level then
    return cfg
  end
  local tb = VehicleRefitHandler.GetUnlockCarCfgTable()
  for k, v in pairs(tb) do
    if v.vehicle_group_id == cfg.vehicle_group_id and v.level == level then
      return v
    end
  end
  return nil
end
function VehicleRefitHandler.GetLevelUnlockPartGroupId(car_id, level)
  local cfg1 = VehicleRefitHandler.GetCartLevelCfg(car_id, level)
  if not cfg1 then
    return 0
  end
  local partGroupId = 0
  if level == 1 then
    partGroupId = tonumber(StringUtil.Split(cfg1.unlock_part_list, ";")[1])
  else
    local cfg2 = VehicleRefitHandler.GetCartLevelCfg(car_id, level - 1)
    if not cfg2 then
      return 0
    end
    local list1 = StringUtil.Split(cfg1.unlock_part_list, ";")
    local list2 = StringUtil.Split(cfg2.unlock_part_list, ";")
    for k, v in pairs(list1) do
      if not VehicleRefitHandler.IsInList(list2, v) then
        partGroupId = tonumber(v)
        break
      end
    end
  end
  return partGroupId
end
function VehicleRefitHandler.GetLevelUnlockPartGroupIcon(car_id, level)
  local partGroupId = VehicleRefitHandler.GetLevelUnlockPartGroupId(car_id, level)
  if partGroupId == 0 then
    local cfg = VehicleRefitHandler.GetCartLevelCfg(car_id, level)
    if cfg then
      return cfg.levelIcon
    end
    return ""
  end
  local cfg1 = VehicleRefitHandler.GetCartLevelCfg(car_id, level)
  if cfg1 == nil then
    return ""
  end
  local tb = CDataTable.GetTable("VehicleRefitStyle")
  for k, v in pairs(tb) do
    if v.vehicle_group_id == cfg1.vehicle_group_id and v.part_group_id == partGroupId then
      return v.part_group_icon
    end
  end
  return ""
end
function VehicleRefitHandler.GetLevelUnlockPartGroupStyleList(car_id, level)
  local partGroupId = VehicleRefitHandler.GetLevelUnlockPartGroupId(car_id, level)
  if partGroupId == 0 then
    return {}
  end
  local list = {}
  local cfg1 = VehicleRefitHandler.GetCartLevelCfg(car_id, level)
  if cfg1 == nil then
    return {}
  end
  local tb = CDataTable.GetTable("VehicleRefitStyle")
  for k, v in pairs(tb) do
    if v.vehicle_group_id == cfg1.vehicle_group_id and v.part_group_id == partGroupId then
      table.insert(list, v.style_id)
    end
  end
  return list
end
function VehicleRefitHandler.GetNextLevelCfg(carId)
  local cfg = CDataTable.GetTableData("VehicleRefitInfo", carId)
  if cfg == nil then
    return nil
  end
  local nextLevel = cfg.level + 1
  local tb = VehicleRefitHandler.GetUnlockCarCfgTable()
  for k, v in pairs(tb) do
    if v.vehicle_group_id == cfg.vehicle_group_id and v.level == nextLevel then
      return v
    end
  end
  return nil
end
function VehicleRefitHandler.GetRefitPartCfgList(carId)
  local maxLevelCfg = VehicleRefitHandler.GetMaxLevelUpCfg(carId)
  if maxLevelCfg == nil then
    return nil
  end
  local list = {}
  local tb = CDataTable.GetTable("VehicleRefitStyle")
  local partList = StringUtil.Split(maxLevelCfg.unlock_part_list, ";")
  local partMap = {}
  for k, v in pairs(tb) do
    if v.vehicle_group_id == maxLevelCfg.vehicle_group_id then
      for kk, vv in pairs(partList) do
        if tonumber(v.part_group_id) == tonumber(vv) and partMap[vv] == nil then
          table.insert(list, v)
          partMap[vv] = 1
        end
      end
    end
  end
  return list
end
function VehicleRefitHandler.CheckLevelUpItem(carId)
  local cfg = VehicleRefitHandler.GetNextLevelCfg(carId)
  if cfg == nil then
    log(bWriteLog and "xx 3, " .. carId)
    return false
  end
  local UnknowPassTreasureBoxSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_treasurebox")
  local num1 = UnknowPassTreasureBoxSystem.GetItemCount(cfg.cost_id1)
  if num1 < cfg.cost_num1 then
    log(bWriteLog and "xx 1," .. num1 .. "," .. cfg.cost_num1)
    return false
  end
  local num2 = UnknowPassTreasureBoxSystem.GetItemCount(cfg.cost_id2)
  if num2 < cfg.cost_num2 then
    log(bWriteLog and "xx 2," .. num2 .. "," .. cfg.cost_num2)
    return false
  end
  return true
end
function VehicleRefitHandler.GetCoseItemList(itemId1, itemNum1, itemId2, itemNum2)
  local cost_list = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo1 = wardrobe_data:GetHallDepotItemDataByResID(itemId1)
  local itemInfo2 = wardrobe_data:GetHallDepotItemDataByResID(itemId2)
  if itemInfo1 then
    cost_list[itemInfo1.insID] = itemNum1
  end
  if itemInfo2 then
    cost_list[itemInfo2.insID] = itemNum2
  end
  return cost_list
end
function VehicleRefitHandler.GetCarStyleList(car_id, previewCarLevel, previewStyleMap, dbStyleList, source)
  local cfgLv
  if previewCarLevel == nil then
    cfgLv = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  else
    cfgLv = VehicleRefitHandler.GetCartLevelCfg(car_id, previewCarLevel)
  end
  if not cfgLv then
    return {}
  end
  local defaultList = StringUtil.Split(cfgLv.DefaultStyleList, "|")
  if defaultList == nil then
    return {}
  end
  for i = 1, #defaultList do
    defaultList[i] = tonumber(defaultList[i])
  end
  if dbStyleList then
    for k, v in pairs(dbStyleList) do
      table.insert(defaultList, v)
    end
  else
    local car_list
    if source == EWardrobeDataSource.InheritWardrobe then
      car_list = VehicleRefitHandler.inheritCarInfoList and VehicleRefitHandler.inheritCarInfoList.car_list
    else
      car_list = VehicleRefitHandler.resCarInfoList and VehicleRefitHandler.resCarInfoList.car_list
    end
    if car_list then
      local carStyleList = car_list[car_id]
      if carStyleList then
        for k, v in pairs(carStyleList) do
          table.insert(defaultList, v)
        end
      end
    end
  end
  if previewStyleMap then
    for k, v in pairs(previewStyleMap) do
      for kk, vv in pairs(v) do
        table.insert(defaultList, vv)
      end
    end
  end
  local styleMap = {}
  for k, v in pairs(defaultList) do
    local cfg = CDataTable.GetTableData("VehicleRefitStyle", v)
    if not cfg then
      return {}
    end
    if styleMap[cfg.part_group_id] == nil then
      styleMap[cfg.part_group_id] = {}
    end
    styleMap[cfg.part_group_id][cfg.part_id] = tonumber(v)
  end
  local list = {}
  for k, v in pairs(styleMap) do
    for kk, vv in pairs(v) do
      table.insert(list, tonumber(vv))
    end
  end
  log(bWriteLog and "GetCarStyleList carId=" .. car_id)
  log_tree("list=", list)
  return list
end
function VehicleRefitHandler.GetPutOnCarId()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tb = VehicleRefitHandler.GetUnlockCarCfgTable()
  for k, v in pairs(tb) do
    local itemData = wardrobe_data:GetHallDepotItemDataByResID(v.vehicle_id)
    if itemData then
      local bEquiped = DataMgr.HasEquipVehicleSkin(itemData.insID)
      if bEquiped then
        return v.vehicle_id
      end
    end
  end
  return 0
end
function VehicleRefitHandler.OnLogin(isRelogin)
  log(bWriteLog and "VehicleRefitHandler.OnLogin isRelogin = " .. tostring(isRelogin))
  if not isRelogin then
    VehicleRefitHandler.send_get_car_info_req()
    local VehicleCollectHandler = require("client.network.Protocol.VehicleCollectHandler")
    VehicleCollectHandler.send_get_car_collection_info_req()
  end
end
function VehicleRefitHandler.CheckAndOpenMainUI()
  local isOpen = LobbySystem.CheckOpen(BP_ENUM_VEHICLE_REFIT_SWITCH)
  if not isOpen then
    ShowNotice(120001)
    return
  end
  local logic_lobby = require("client.slua.logic.lobby.logic_lobby_main")
  logic_lobby.HideLobbyUI()
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:OpenVehicleWorkShop(VehicleCollectSystem.ENUM_VEHICLE_SYSTEM.REFIT)
end
function VehicleRefitHandler.JumpToStore(car_id)
  GlobalData.JumpByTypeID(car_id, 1, BP_ENUM_MODULE_VEHICLE)
end
function VehicleRefitHandler.HaveStyleItem(StyleID)
  return VehicleRefitHandler.OwnCarInfoMap[StyleID]
end
function VehicleRefitHandler.ConvertUnLockListToMap()
  VehicleRefitHandler.OwnCarInfoMap = {}
  if not VehicleRefitHandler.resCarInfoList.unlocked_car_list then
    log(bWriteLog and "VehicleRefitHandler ConvertUnLockListToMap not unlocked_car_list")
    return
  end
  for _, list in pairs(VehicleRefitHandler.resCarInfoList.unlocked_car_list) do
    for group_id, style in pairs(list) do
      for styleId, state in pairs(style) do
        VehicleRefitHandler.OwnCarInfoMap[styleId] = state
      end
    end
  end
end
function VehicleRefitHandler.send_get_car_info_req()
  NetManager.SendPkg(1179138151)
end
function VehicleRefitHandler.on_get_car_info_rsp(car_info, unlock_car_cfgtb, car_acc_list, car_install_acc_list, inheirt_car_info)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  VehicleRefitHandler.resCarInfoList = car_info
  VehicleRefitHandler.res_  log_tree("xxx car_info = ", car_info)
  log_tree("xxx unlock_car_cfgtb = ", unlock_car_cfgtb)
  VehicleRefitHandler.inheritCarInfoList = inheirt_car_info and inheirt_car_info.inherit_car
  VehicleRefitHandler.CreateUnlockCarCfgTable()
  VehicleRefitHandler.ConvertUnLockListToMap()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not LogicTxMissionMain.IsInXMission() then
    HallThemeUtils.ShowThemeVehicle()
  end
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  LogicVehicleAccessory:OnGetCarInfoRsp(car_acc_list, car_install_acc_list, inheirt_car_info)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_REFIT, EVENTID_VEHICLE_REFIT_INFO)
end
function VehicleRefitHandler.send_car_modification_req(car_instid, car_info, cost_list)
  log_tree("car_instid", car_instid)
  log_tree("car_info", car_info)
  log_tree("cost_list", cost_list)
  NetManager.SendPkg(530662695, car_instid, car_info, cost_list)
end
function VehicleRefitHandler.on_car_modification_rsp(error_code, params)
  log(bWriteLog and "on_car_modification_rsp error_code = " .. error_code)
  log_tree("on_car_modification_rsp params = ", params)
  if error_code ~= 0 then
    ShowNotice(7034)
    return
  end
  local car_id = params.car_id
  local curCar = VehicleRefitHandler.resCarInfoList.car_list[car_id]
  if not curCar then
    VehicleRefitHandler.resCarInfoList.car_list[car_id] = params.car_info
  else
    for k, v in pairs(params.car_info) do
      curCar[k] = v
    end
  end
  for k, v in pairs(params.car_info) do
    VehicleRefitHandler.OwnCarInfoMap[v] = 1
  end
  EventSystem:postEvent(EVENTTYPE_VEHICLE_REFIT, EVENTID_VEHICLE_REFIT_MODIFY)
  if DataMgr and DataMgr.roleData and DataMgr.roleData.uid then
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
    end, {bForceReq = true}, Enum_AvatarShowSource.VehicleRefitHandler)
  end
end
function VehicleRefitHandler.send_car_level_up_req(car_instid, cost_list)
  log_tree("VehicleRefitHandler.send_car_level_up_req car_instid", car_instid)
  log_tree("VehicleRefitHandler.send_car_level_up_req cost_list", cost_list)
  VehicleRefitHandler.bMaskPutTipsInLevelUp = true
  NetManager.SendPkg(873979367, car_instid, cost_list)
end
function VehicleRefitHandler.on_car_level_up_rsp(error_code, params)
  log_tree("error_code=", error_code)
  log_tree("params=", params)
  if error_code ~= 0 then
    VehicleRefitHandler.bMaskPutTipsInLevelUp = false
    ShowNotice(8082)
    return
  end
  EventSystem:postEvent(EVENTTYPE_VEHICLE_REFIT, EVENTID_VEHICLE_REFIT_LEVEL_UP)
end
function VehicleRefitHandler.send_car_setting_req(params)
  log_tree("params=", params)
  NetManager.SendPkg(507847879, params)
end
function VehicleRefitHandler.on_car_setting_rsp(error_code, setting_info)
  log_tree("error_code=", error_code)
  log_tree("setting_info=", setting_info)
  VehicleRefitHandler.resCarInfoList.home_car_inst = setting_info.home_car_inst
  VehicleRefitHandler.resCarInfoList.island_car_inst = setting_info.island_car_inst
  EventSystem:postEvent(EVENTTYPE_VEHICLE_REFIT, EVENTID_VEHICLE_REFIT_SETTING)
end
function VehicleRefitHandler.send_buy_car_modification_cost(params)
  log_tree("VehicleRefitHandler.send_buy_car_modification_cost params", params)
  NetManager.SendPkg(1798838304, params)
end
function VehicleRefitHandler.on_buy_car_modification_rsp(error_code, params)
  log(bWriteLog and "on_buy_car_modification_rsp error_code" .. error_code)
  log_tree("params=", params)
  if error_code ~= 0 then
    ShowNotice(7034)
    return
  end
  EventSystem:postEvent(EVENTTYPE_VEHICLE_REFIT, EVENTID_VEHICLE_REFIT_MODIFY_COST)
end
function VehicleRefitHandler.send_car_last_opt_req()
  NetManager.SendPkg(1179811431)
end
function VehicleRefitHandler.on_car_last_opt_rsp(status)
end
function VehicleRefitHandler.JumpToVideo(id)
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:OpenVehicleWorkShop(VehicleCollectSystem.ENUM_VEHICLE_SYSTEM.REFIT, id)
end
return VehicleRefitHandler