local logic_advertisement_BlueHole = {}
function logic_advertisement_BlueHole:OnLogin(bReLogin)
  log(bWriteLog and string.format("logic_advertisement_BlueHole:OnLogin bReLogin = %s", bReLogin))
  if not self:CheckCanGetAdvertisementData() then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.OnLogin CheckCanGetAdvertisementData is false")
    return
  end
  local BlueHoleAdvertisementHandler = require("client.network.Protocol.BlueHoleAdvertisementHandler")
  BlueHoleAdvertisementHandler.send_get_bh_google_ad_info_req()
end
function logic_advertisement_BlueHole:DefineAndResetData()
  self.advertisement_data = nil
  self.advertisement_weekdata = nil
  self.advertisement_taskdata = nil
  self.is_first_get = nil
  self.G_Id = nil
  self.Scence_Type = nil
end
function logic_advertisement_BlueHole:GetAdvertisementData()
  return self.advertisement_data
end
function logic_advertisement_BlueHole:GetAdvertisementWeekRewardDataByID(id)
  return self.advertisement_data.weekly_data.task_status[id]
end
function logic_advertisement_BlueHole:GetAdvertisementActivtyWeekData()
  return self.advertisement_data.weekly_data
end
function logic_advertisement_BlueHole:GetAdvertisementDataByScenceType(scence_type)
  return self.advertisement_data.scene[scence_type]
end
function logic_advertisement_BlueHole:GetAdvertisementWeekData()
  return self.advertisement_weekdata
end
function logic_advertisement_BlueHole:JumpUrl()
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  local url
  local wheelData = self:GetAdvertisementDataByScenceType(AD_macro.ENUM_SCENCE_TYPE.Wheel)
  if wheelData then
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.Wheel)
    local wheelURL = scence_data.Url
    if wheelURL then
      url = wheelURL
      GlobalData.JumpUrl(url)
      return
    end
  end
  if self:CheckMaxWatchCountByScenceType(AD_macro.ENUM_SCENCE_TYPE.RECHARGE) then
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.RECHARGE)
    url = scence_data.Url
  elseif self:CheckMaxWatchCountByScenceType(AD_macro.ENUM_SCENCE_TYPE.SUPPLY) then
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.SUPPLY)
    local version = Client.GetAppVersion()
    local version_util = require("client.common.version_util")
    local ClientVersion = version_util.GetMainFormat(version)
    local carteddata = CDataTable.GetTableData("ADCartedData", ClientVersion)
    local urlid = carteddata.URL_ID
    url = string.StrReplace(scence_data.Url, "{1}", urlid, 1)
  else
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.SOLDIERS)
    if scence_data.Url then
      url = scence_data.Url
    end
  end
  GlobalData.JumpUrl(url)
end
function logic_advertisement_BlueHole:GetJumpUrl()
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  local url = ""
  local wheelData = self:GetAdvertisementDataByScenceType(AD_macro.ENUM_SCENCE_TYPE.Wheel)
  if wheelData then
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.Wheel)
    local wheelURL = scence_data.Url
    if wheelURL then
      url = wheelURL
      return url
    end
  end
  if self:CheckMaxWatchCountByScenceType(AD_macro.ENUM_SCENCE_TYPE.RECHARGE) then
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.RECHARGE)
    url = scence_data.Url
  elseif self:CheckMaxWatchCountByScenceType(AD_macro.ENUM_SCENCE_TYPE.SUPPLY) then
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.SUPPLY)
    local version = Client.GetAppVersion()
    local version_util = require("client.common.version_util")
    local ClientVersion = version_util.GetMainFormat(version)
    local carteddata = CDataTable.GetTableData("ADCartedData", ClientVersion)
    local urlid = carteddata.URL_ID
    url = string.StrReplace(scence_data.Url, "{1}", urlid, 1)
  else
    local scence_data = CDataTable.GetTableData("ADScenceData", AD_macro.ENUM_SCENCE_TYPE.SOLDIERS)
    if scence_data.Url then
      url = scence_data.Url
    end
  end
  return url
end
function logic_advertisement_BlueHole:CheckCanGetAdvertisementData()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if DataMgr.roleData.can_watch_google_ad and region == PublishRegionMacros.BLUEHOLE then
    return true
  end
  return false
end
function logic_advertisement_BlueHole:CanShowAdWeekAct()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region ~= PublishRegionMacros.BLUEHOLE then
    return
  end
  if DataMgr.roleData.google_ad_weekly_disable == 1 then
    log(bWriteLog and "logic_advertisement_BlueHole:CanShowAdWeekAct.  google_ad_weekly_disable")
    return
  end
  local TimeUtil = require("client.common.time_util")
  return {
    nActID = ActivityFixedID.AD_SIGNUP,
    sName = LocUtil.GetLocalizeResStr(64901),
    bRedDot = nil,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = TimeUtil.GetServerTimeInSec()
  }
end
function logic_advertisement_BlueHole:CheckReGetADTaskData()
  if not self:CheckCanGetAdvertisementData() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowtime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckReGetADTaskData nowtime is " .. tostring(nowtime) .. "and next_daily_reset_ts is " .. tostring(self.advertisement_data.next_daily_reset_ts))
  if self.advertisement_data and nowtime >= self.advertisement_data.next_daily_reset_ts then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    NewDayTaskSystem.send_general_task_sync_all_req()
  end
end
function logic_advertisement_BlueHole:CheckCanResetData(scence_type)
  if not self:CheckCanGetAdvertisementData() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowtime = TimeUtil.GetServerTimeInSec()
  if nowtime >= self.advertisement_data.scene[scence_type].next_daily_reset_ts then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckCanResetData nowtime is " .. tostring(nowtime))
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckCanResetData advertisement_data.next_daily_reset_ts is " .. tostring(self.advertisement_data.scene[scence_type].next_daily_reset_ts))
    local BlueHoleAdvertisementHandler = require("client.network.Protocol.BlueHoleAdvertisementHandler")
    BlueHoleAdvertisementHandler.send_get_bh_google_ad_info_req()
  end
end
function logic_advertisement_BlueHole:CheckCanResetTotalData()
  if not self:CheckCanGetAdvertisementData() then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowtime = TimeUtil.GetServerTimeInSec()
  if self.advertisement_data and nowtime >= self.advertisement_data.next_daily_reset_ts then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckCanResetTotalData nowtime is " .. tostring(nowtime))
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckCanResetTotalData advertisement_data.next_daily_reset_ts is " .. tostring(self.advertisement_data.next_daily_reset_ts))
    return true
  end
  return false
end
function logic_advertisement_BlueHole:GetAdvertisementtTaskData()
  if not self.advertisement_taskdata then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    NewDayTaskSystem.send_general_task_sync_all_req()
  end
  return self.advertisement_taskdata
end
function logic_advertisement_BlueHole:CheckMaxWatchCountByScenceType(scence_type)
  local scence_data = CDataTable.GetTableData("ADScenceData", scence_type)
  if not scence_data or not self.advertisement_data then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckMaxWatchCountByScenceType scence_data is no have")
    return false
  end
  if scence_data.Max_Count and scence_data.Max_Count > self.advertisement_data.scene[scence_type].watch_count then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckMaxWatchCountByScenceType scence_data.Max_Count is " .. tostring(scence_data.Max_Count))
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckMaxWatchCountByScenceType advertisement_data.watch_count is " .. tostring(self.advertisement_data.scene[scence_type].watch_count))
    return true
  end
  return false
end
function logic_advertisement_BlueHole:CheckWatchTimeByScenceType(scence_type)
  if not self.advertisement_data then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  if self.advertisement_data.scene[scence_type].next_watch_time == 0 then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckWatchTimeByScenceType next_watch_time is 0")
    return true
  end
  local nowtime = TimeUtil.GetServerTimeInSec()
  if nowtime >= self.advertisement_data.scene[scence_type].next_watch_time then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckWatchTimeByScenceType nowtime is " .. tostring(nowtime))
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.CheckWatchTimeByScenceType advertisement_data.next_watch_time is " .. tostring(self.advertisement_data.scene[scence_type].next_watch_time))
    return true
  end
  return false
end
function logic_advertisement_BlueHole:SetScenceType(type)
  log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.SetScenceType type is " .. tostring(type))
  self.Scence_Type = type
  self:CheckCanResetData(self.Scence_Type)
end
function logic_advertisement_BlueHole:GetScenceType()
  if self.Scence_Type then
    return self.Scence_Type
  end
  return nil
end
function logic_advertisement_BlueHole:SetAdvertisementtTaskData(data)
  log_tree("logic_advertisement_BlueHole.SetAdvertisementtTaskData data : ", data)
  self.advertisement_task  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  self.advertisement_taskdata.task_id = AD_macro.DALIYTASKID
  EventSystem:postEvent(EVENTTYPE_ADVERTISE, EVENTID_ADVERTISE_SHOW_LOBBY_UPDATE)
end
function logic_advertisement_BlueHole:TryShowAdvertise()
  log(bWriteLog and "logic_advertisement_BlueHole.TryShowAdvertise ")
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:SetUserId(DataMgr.roleData.openID)
  AdvertiseSdk:SetCustomData(self.Scence_Type)
  if AdvertiseSdk:IsAdvertiseLoaded() then
    log(bWriteLog and "EventGlobalUseItem play advertise success")
    local AdvertiseHandler = require("client.network.Protocol.AdvertiseHandler")
    AdvertiseHandler.send_play_google_ad(self.Scence_Type)
    AdvertiseSdk:PlayAdvertise()
  else
    log(bWriteLog and "EventGlobalUseItem play advertise failed")
    AdvertiseSdk:LoadAdvertise(self.G_Id)
    ShowNotice(6506)
  end
end
function logic_advertisement_BlueHole:send_get_bh_google_ad_info_req()
  if not self:CheckCanGetAdvertisementData() then
    return
  end
  if not self.advertisement_data or not self.advertisement_weekdata then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.send_get_bh_google_ad_info_req first")
    local BlueHoleAdvertisementHandler = require("client.network.Protocol.BlueHoleAdvertisementHandler")
    BlueHoleAdvertisementHandler.send_get_bh_google_ad_info_req()
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowtime = TimeUtil.GetServerTimeInSec()
  if self.advertisement_weekdata.end_time and nowtime > self.advertisement_weekdata.end_time then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.send_get_bh_google_ad_info_req refresh")
    local BlueHoleAdvertisementHandler = require("client.network.Protocol.BlueHoleAdvertisementHandler")
    BlueHoleAdvertisementHandler.send_get_bh_google_ad_info_req()
    return
  end
  if self.advertisement_data.next_daily_reset_ts and nowtime > self.advertisement_data.next_daily_reset_ts then
    log(bWriteLog and "[mxiliu]: logic_advertisement_BlueHole.send_get_bh_google_ad_info_req refresh")
    local BlueHoleAdvertisementHandler = require("client.network.Protocol.BlueHoleAdvertisementHandler")
    BlueHoleAdvertisementHandler.send_get_bh_google_ad_info_req()
  end
end
function logic_advertisement_BlueHole:on_get_bh_google_ad_info_rsp(is_first_get, advertisement_data, G_Id, advertisement_weekdata)
  self.  self.  self.  local devicePlatformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local unitId
  if devicePlatformName == DevicePlatformNameMacros.IOS then
    self.G_Id = G_Id.ios_reward_slot_id
    unitId = G_Id.ios_interstitial_slot_id
  elseif devicePlatformName == DevicePlatformNameMacros.Android then
    self.G_Id = G_Id.aos_reward_slot_id
    unitId = G_Id.aos_interstitial_slot_id
  end
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:SetUserId(DataMgr.roleData.openID)
  AdvertiseSdk:SetPrizeUnitId(self.G_Id)
  AdvertiseSdk:SetUnitId(unitId)
  EventSystem:postEvent(EVENTTYPE_ADVERTISE, EVENTID_ADVERTISE_SHOW_LOBBY_UPDATE)
end
function logic_advertisement_BlueHole:on_bh_google_ad_ntf(is_first_get, advertisement_data, G_Id, award_list)
  self.  self.  local devicePlatformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if devicePlatformName == DevicePlatformNameMacros.IOS then
    self.G_Id = G_Id.ios_reward_slot_id
  elseif devicePlatformName == DevicePlatformNameMacros.Android then
    self.G_Id = G_Id.aos_reward_slot_id
  end
  if award_list and 0 < #award_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
  end
  EventSystem:postEvent(EVENTTYPE_ADVERTISE, EVENTID_ADVERTISE_SHOW_LOBBY_UPDATE)
end
function logic_advertisement_BlueHole:send_bh_google_weekly_ad_award_req(id)
  local BlueHoleAdvertisementHandler = require("client.network.Protocol.BlueHoleAdvertisementHandler")
  BlueHoleAdvertisementHandler.send_bh_google_weekly_ad_award_req(id)
end
function logic_advertisement_BlueHole:on_bh_google_weekly_ad_award_rsp(id, task_status)
  self.advertisement_data.weekly_data.task_status[id] = task_status[id]
  local reward_list = {
    [1] = {
      res_id = self.advertisement_weekdata[id].item_id_1,
      count = self.advertisement_weekdata[id].item_num_1
    }
  }
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(reward_list)
  EventSystem:postEvent(EVENTTYPE_ADVERTISE, EVENTID_ADVERTISE_SHOW_LOBBY_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_advertisement_BlueHole = class(CModuleBase, nil, logic_advertisement_BlueHole)
return Clogic_advertisement_BlueHole