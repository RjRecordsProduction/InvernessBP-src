local logic_halloween_vehicle = {
  Trick_Result = {},
  Trick_Count_Awards = {},
  lottery = {},
  Trick_Items = {},
  Lucky_Value = 0,
  VehicleSkinInfo = {},
  VehicleOwnInfo = {},
  VehicleSkinId = {},
  CandyId = 1602054,
  TicketId = 1602055,
  TrickTicket = {1, 5},
  sRule = 0,
  sTitle = 0,
  sDateTime = 0,
  nActivityId = 0,
  nDebrisId = 0,
  nCandyCount = 0,
  nSelectVehicleIndex = 1
}
function logic_halloween_vehicle.GetActivityTime()
  local actType
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    actType = ActivityType.HALLOWEEN_VEHICLE_KR
  else
    actType = ActivityType.HALLOWEEN_VEHICLE
  end
  if LobbySystem.activityDisplayDataList == nil then
    return 0, 0
  end
  for _, activity in ipairs(LobbySystem.activityDisplayDataList) do
    if activity.ActivityType == actType then
      return activity.StartTimeUTC, activity.EndTimeUTC
    end
  end
  return 0, 0
end
function logic_halloween_vehicle.notify_hy_lottery_award(awards)
  log_tree("logic_halloween_vehicle.notify_hy_lottery_award ", awards)
  for i, awardStatus in ipairs(logic_halloween_vehicle.Trick_Count_Awards) do
    awardStatus.status = awards[i]
  end
end
function logic_halloween_vehicle.on_hy_lottery(rs, lottery, item_list)
  log(bWriteLog and "logic_halloween_vehicle.on_hy_lottery,lottery " .. rs)
  log_tree("logic_halloween_vehicle.on_hy_lottery,lottery:", lottery)
  log_tree("logic_halloween_vehicle.on_hy_lottery,item_list:", item_list)
  if rs ~= NetErrorCode_NONE then
    if rs == "not-enough" then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg()
    elseif rs == "not-open" then
      ShowNotice(4002)
    elseif rs == "qrcode_login_limit" then
      local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
      QRcodeRestrictManager:ShowRestrictTips()
    else
      ShowNotice(6148)
    end
    log(bWriteLog and "logic_halloween_vehicle.on_hy_lottery not ok")
    return
  end
  logic_halloween_vehicle.Trick_Result = item_list
  logic_halloween_vehicle.  logic_halloween_vehicle.Lucky_Value = lottery.lucky
  for i, awardStatus in ipairs(logic_halloween_vehicle.Trick_Count_Awards) do
    awardStatus.trickCount = lottery.times
    awardStatus.status = lottery.award[i]
  end
  BP_Halloween_Vehicle_Trick_Count = lottery.times
end
function logic_halloween_vehicle.RefreshVehicleOwnInfo(ownInfoTable)
  for index, ownInfo in pairs(ownInfoTable) do
    for seriesId, itemId in pairs(ownInfo) do
      local VehicleSkin = logic_halloween_vehicle.VehicleSkinId[itemId]
      local targetSkin_Info = seriesId == 1 and logic_halloween_vehicle.GetVehicleSkinInfo1(index) or logic_halloween_vehicle.GetVehicleSkinInfo2(index)
      if VehicleSkin and VehicleSkin.index then
        for _, v in ipairs(targetSkin_Info) do
          if v.index <= VehicleSkin.index then
            v.status = 1
          elseif v.index == VehicleSkin.index + 1 then
            v.status = 2
          else
            v.status = 0
          end
        end
      end
    end
  end
  for _, vehicle in pairs(logic_halloween_vehicle.VehicleSkinInfo) do
    if vehicle[1] and vehicle[1].status == 0 then
      vehicle[1].status = 2
    end
  end
  logic_halloween_vehicle.VehicleOwnInfo = ownInfoTable
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_VEHICLE_SKIN_CHANGE)
end
function logic_halloween_vehicle.InitVehicleSkinInfo(vehicleCfg)
  logic_halloween_vehicle.VehicleSkinInfo = {}
  for i, vehicleTable in pairs(vehicleCfg) do
    local vehicleSkinInfo = {}
    for index, v in pairs(vehicleTable) do
      local Info = {
        skinId = v.upgrade_award_item_id,
        status = 0,
        costCandy = v.consume_item_num,
        fromSkinId = v.need_item_id,
        lineId = v.upgrade_series_id,
        index = #vehicleSkinInfo + 1
      }
      table.insert(vehicleSkinInfo, Info)
      logic_halloween_vehicle.VehicleSkinId[v.upgrade_award_item_id] = Info
    end
    local seriesId = vehicleTable[1].upgrade_series_id
    if seriesId == 1 then
      table.insert(logic_halloween_vehicle.VehicleSkinInfo, vehicleSkinInfo)
    end
  end
  log_tree("logic_halloween_vehicle.InitVehicleSkinInfo-", logic_halloween_vehicle.GetVehicleSkinInfo1())
  log_tree("logic_halloween_vehicle.InitVehicleSkinInfo-", logic_halloween_vehicle.GetVehicleSkinInfo2())
end
function logic_halloween_vehicle.GetVehicleSkinInfo1(index)
  index = index or logic_halloween_vehicle.nSelectVehicleIndex
  return logic_halloween_vehicle.VehicleSkinInfo[index] or {}
end
function logic_halloween_vehicle.GetVehicleSkinInfo2()
  return {}
end
function logic_halloween_vehicle.GetFirstLevelVehicleID(index)
  local vechicleInfo = logic_halloween_vehicle.GetVehicleSkinInfo1(index)
  return vechicleInfo[1] and vechicleInfo[1].skinId
end
function logic_halloween_vehicle.GetCurrentOwnVehicleID(index, seriesId)
  seriesId = seriesId or 1
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(logic_halloween_vehicle.VehicleOwnInfo, index, seriesId)
end
function logic_halloween_vehicle.on_query_lottery_info(rs, lottery_tb)
  log(bWriteLog and "logic_halloween_vehicle.on_query_lottery_info")
  log_tree("logic_halloween_vehicle.on_hy_lottery,on_query_lottery_info:", lottery_tb)
  if rs ~= NetErrorCode_NONE then
    return
  end
  logic_halloween_vehicle.Trick_Items = {}
  for i, v in ipairs(lottery_tb) do
    table.insert(logic_halloween_vehicle.Trick_Items, {
      itemId = v.item_id,
      itemCount = v.item_num,
      index = i
    })
  end
end
function logic_halloween_vehicle.on_take_lottery_award(_, award)
  local GetAwardTb
  for i, awardStatus in ipairs(logic_halloween_vehicle.Trick_Count_Awards) do
    if awardStatus.status == 1 and award[i] == 2 then
      GetAwardTb = awardStatus.BP_ARRAY_Halloween_Vehicle_Items
    end
    awardStatus.status = award[i]
  end
  if GetAwardTb ~= nil then
    local Result = {}
    for i, v in ipairs(GetAwardTb) do
      table.insert(Result, {
        res_id = v.itemId,
        count = v.itemCount,
        valid_hours = v.itemExpireTime
      })
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(Result)
  end
end
function logic_halloween_vehicle.on_query_lottery_award_info(rs, lottery, ha_lottery_extra_reward)
  log(bWriteLog and "logic_halloween_vehicle.on_query_lottery_award_info:" .. rs)
  log_tree("logic_halloween_vehicle.on_query_lottery_award_info,lottery:", lottery)
  log_tree("logic_halloween_vehicle.ha_lottery_extra_reward,lottery:", ha_lottery_extra_reward)
  if rs == NetErrorCode_NONE then
    logic_halloween_vehicle.Lucky_Value = lottery.lucky
    logic_halloween_vehicle.    BP_Halloween_Vehicle_Trick_Count = lottery.times
    logic_halloween_vehicle.Trick_Count_Awards = {}
    for i, reward in ipairs(ha_lottery_extra_reward) do
      local awardStatus = {}
      local _award = {}
      for i, v in ipairs(reward.drop) do
        table.insert(_award, {
          itemId = v.item_id,
          itemCount = v.item_num,
          index = i,
          itemExpireTime = v.item_expire_time
        })
      end
      awardStatus.BP_ARRAY_Halloween_Vehicle_Items = _award
      awardStatus.awardId = i
      awardStatus.trickCount = lottery.times
      awardStatus.status = lottery.award[i]
      awardStatus.lottery_num = reward.lottery_num
      table.insert(logic_halloween_vehicle.Trick_Count_Awards, awardStatus)
    end
  end
end
function logic_halloween_vehicle.hy_lottery_req(times)
  log(bWriteLog and "logic_halloween_vehicle.hy_lottery_req")
  local HalloweenVehicleHandler = require("client.network.Protocol.HalloweenVehicleHandler")
  HalloweenVehicleHandler.send_hy_lottery(times)
end
function logic_halloween_vehicle.query_lottery_info_req()
  local HalloweenVehicleHandler = require("client.network.Protocol.HalloweenVehicleHandler")
  HalloweenVehicleHandler.send_query_lottery_info()
end
function logic_halloween_vehicle.take_lottery_award(award_id)
  log(bWriteLog and "logic_halloween_vehicle.take_lottery_award:" .. award_id)
  local HalloweenVehicleHandler = require("client.network.Protocol.HalloweenVehicleHandler")
  HalloweenVehicleHandler.send_take_lottery_award(award_id)
end
function logic_halloween_vehicle.query_lottery_award_info()
  log(bWriteLog and "logic_halloween_vehicle.query_lottery_award_info")
  local HalloweenVehicleHandler = require("client.network.Protocol.HalloweenVehicleHandler")
  HalloweenVehicleHandler.send_query_lottery_award_info()
end
function logic_halloween_vehicle.get_vst_level_up_info()
  log(bWriteLog and "logic_halloween_vehicle.get_vst_level_up_info")
  local HalloweenVehicleHandler = require("client.network.Protocol.HalloweenVehicleHandler")
  HalloweenVehicleHandler.send_get_vst_level_up_info()
end
function logic_halloween_vehicle.GetCandyCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(logic_halloween_vehicle.CandyId)
  if itemData ~= nil then
    return itemData.count
  end
  return 0
end
function logic_halloween_vehicle.GetTicketCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(logic_halloween_vehicle.TicketId)
  if itemData ~= nil then
    return itemData.count
  end
  return 0
end
function logic_halloween_vehicle.IsShowRedPoint()
  return logic_halloween_vehicle.GetTicketCount() >= logic_halloween_vehicle.TrickTicket[1]
end
function logic_halloween_vehicle.UpdateShowRedPoint()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE, logic_halloween_vehicle.IsShowRedPoint())
end
function logic_halloween_vehicle.OpenUI()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityDataTable = ActivityNewSystem.GetServerData()
  local ActivityId = ActivityNewSystem.CheckActivityIsOpenByType(ActivityType.LUCKY_UPGRADE, 0)
  local data = activityDataTable[ActivityId]
  if data == nil then
    return
  end
  log_tree("logic_halloween_vehicle.OpenUI() activityData = ", data)
  logic_halloween_vehicle.n  logic_halloween_vehicle.sTitle = data.cfg.activity_name or ""
  logic_halloween_vehicle.sRule = data.cfg.activity_desc or ""
  logic_halloween_vehicle.sDateTime = logic_halloween_vehicle.GetTimePeriod(data.cfg.start_time, data.cfg.end_time)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
  UIManager.ShowUI(UIManager.UI_Config.vehicle_halloween_skin)
end
function logic_halloween_vehicle.GetTimePeriod(startTime, endTime)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatTime_timeFrame(startTime, endTime, false, true)
end
function logic_halloween_vehicle.GetDebrisCount()
  log(bWriteLog and "self:GetDebrisCount" .. logic_halloween_vehicle.nDebrisId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(logic_halloween_vehicle.nDebrisId)
  if itemData then
    log(bWriteLog and "self:GetDebrisCount" .. itemData.count)
    return itemData.count
  end
  return 0
end
function logic_halloween_vehicle.get_upgrade_activity_info_req()
  log(bWriteLog and "logic_halloween_vehicle.query_lottery_award_info")
  local HalloweenVehicleHandler = require("client.network.Protocol.HalloweenVehicleHandler")
  HalloweenVehicleHandler.send_get_upgrade_activity_info_req(logic_halloween_vehicle.nActivityId)
end
function logic_halloween_vehicle.get_upgrade_activity_info_rsp(err_code, upgrade_activity_cfg, my_activity_data)
  log(bWriteLog and "get_upgrade_activity_info_rsp" .. err_code)
  log_tree("logic_halloween_vehicle.get_upgrade_activity_info_rsp,upgrade_activity_cfg:", upgrade_activity_cfg)
  log_tree("logic_halloween_vehicle.get_upgrade_activity_info_rsp,my_activity_data:", my_activity_data)
  if err_code ~= 0 then
    return ShowNotice("err_code = " .. err_code)
  end
  local TableUtil = require("common.table_util")
  logic_halloween_vehicle.nDebrisId = TableUtil.GetTableValue(upgrade_activity_cfg, 1, 1, "consume_item_id")
  logic_halloween_vehicle.nCandyCount = logic_halloween_vehicle.GetDebrisCount()
  logic_halloween_vehicle.InitVehicleSkinInfo(upgrade_activity_cfg)
  logic_halloween_vehicle.RefreshVehicleOwnInfo(my_activity_data)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_VEHICLE_SKIN_UPGRADE_INFO)
end
function logic_halloween_vehicle.do_upgrade_by_activity_id_req(lineId, index)
  log(bWriteLog and "LogicHalloweenVehicle.get_vst_level_up_info")
  local HalloweenVehicleHandler = require("client.network.Protocol.HalloweenVehicleHandler")
  HalloweenVehicleHandler.send_do_upgrade_by_activity_id_req(logic_halloween_vehicle.nActivityId, lineId, index)
end
function logic_halloween_vehicle.do_upgrade_by_activity_id_rsp(err_code, ownInfoTable)
  log_tree("LogicHalloweenVehicle.on_hy_lottery,do_upgrade_by_activity_id_rsp:", ownInfoTable)
  if err_code ~= 0 then
    ShowNotice(err_code == "not-open" and 4002 or 6148)
    return
  end
  logic_halloween_vehicle.nCandyCount = logic_halloween_vehicle.GetDebrisCount()
  local Result = {}
  for index, ownInfo in pairs(ownInfoTable) do
    for seriesId, itemId in pairs(ownInfo) do
      local TableUtil = require("common.table_util")
      if itemId and itemId ~= TableUtil.GetTableValue(logic_halloween_vehicle.VehicleOwnInfo, index, seriesId) then
        table.insert(Result, {
          res_id = itemId,
          count = 1,
          valid_hours = 0
        })
      end
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(Result)
  logic_halloween_vehicle.RefreshVehicleOwnInfo(ownInfoTable)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_VEHICLE_SKIN_UPGRADE_ITEM)
end
return logic_halloween_vehicle