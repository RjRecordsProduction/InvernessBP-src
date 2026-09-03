local logic_wedding_activity = {}
local ERROR_CODE = {
  [20150001] = 3018,
  [20150005] = 7809,
  [20150008] = 108135,
  [20150009] = 522004
}
function logic_wedding_activity:DefineAndResetData()
  self.guinness_data = {}
end
function logic_wedding_activity:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WEDDING_ACTIVITY, self.OnJumpWeddingActivityMainUI, self)
end
function logic_wedding_activity:OnJumpWeddingActivityMainUI(eventType, eventID, params)
  log(bWriteLog and "logic_wedding_activity:OnJumpWeddingActivityMainUI")
  UIManager.ShowUI(UIManager.UI_Config.Matchmaking_RightTab_UIBP, params)
end
function logic_wedding_activity:ReqWeddingActivityGrayConfig()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.soulmate_gray_table, function(table_name, table_data)
    EventSystem:postEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_ACTIVITY_GRAY_CONFIG_UPDATE)
  end)
end
function logic_wedding_activity:IsWeddingActivityEntryShow()
  local status = self:GetWeddingActivityEntryStatus()
  log(bWriteLog and "logic_wedding_activity:IsWeddingActivityEntryShow status: " .. tostring(status))
  local logic_wedding_system_common = require("GameLua.Mod.MainCity.Client.logic.WeddingSystem.logic_wedding_system_common")
  if status == logic_wedding_system_common.Status.Open then
    return true
  else
    return false
  end
end
function logic_wedding_activity:GetWeddingActivityEntryStatus()
  local logic_wedding_system_common = require("GameLua.Mod.MainCity.Client.logic.WeddingSystem.logic_wedding_system_common")
  if not self.activityStartTime then
    local sMyUid = tostring(DataMgr.roleData.uid)
    if CDataTable.GetTableDataByFilter("WeddingWhiteListCfg", "UID", sMyUid) then
      self.activityStartTime = 0
    else
      local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
      local data_config_marco = require("client.logic.data.data_config_marco")
      local grayConfig = BasicDataServerTable:GetCacheData(data_config_marco.soulmate_gray_table)
      if not grayConfig then
        log(bWriteLog and "logic_wedding_activity:GetWeddingActivityEntryStatus grayConfig is nil")
        return logic_wedding_system_common.Status.NotOpen
      end
      local itop_app_id = tostring(Client.GetITopGameId())
      local cfgList = grayConfig[itop_app_id]
      if not cfgList then
        log_warning(bWriteLog and "logic_wedding_activity:GetWeddingActivityEntryStatus not find cfgList. itop_app_id: %s", itop_app_id)
        return logic_wedding_system_common.Status.NotOpen
      end
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      local ipRegion = login_module.sIpRegion
      local open_time = cfgList[ipRegion] or cfgList.ALL
      if not open_time then
        log_warning(bWriteLog and "logic_wedding_activity:GetWeddingActivityEntryStatus not find open_time. itop_app_id: %s, ipRegion: %s", itop_app_id, ipRegion)
        return logic_wedding_system_common.Status.NotOpen
      end
      self.activityStartTime = open_time - 86400
    end
    log(bWriteLog and "logic_wedding_activity:GetWeddingActivityEntryStatus activityStartTime: " .. tostring(self.activityStartTime))
  end
  if not self.activityEndTime then
    local endTimeStr = CDataTable.GetTableData("WeddingTableCfg", "soulmate_promotion_end_time")
    local TimeUtil = require("client.common.time_util")
    self.activityEndTime = TimeUtil.TimeStringToUnixstamp(endTimeStr.ParamValue)
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime < self.activityStartTime then
    return logic_wedding_system_common.Status.NotOpen
  elseif curTime > self.activityEndTime then
    return logic_wedding_system_common.Status.Close
  else
    return logic_wedding_system_common.Status.Open
  end
end
function logic_wedding_activity:GetWeddingActivityTabConfig()
  local wedding_activity_macros = require("client.slua.logic.home.Wedding.wedding_activity_macros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local tabConfig = {}
  for _, v in ipairs(wedding_activity_macros.ActivityTabs) do
    local bShow = true
    if v.type == wedding_activity_macros.Enum_WeddingActivityTabType.Guinness and not self:GetGuinnessIsOpen() then
      bShow = false
    end
    if bShow then
      table.insert(tabConfig, v)
    end
  end
  return tabConfig
end
function logic_wedding_activity:GetGuinnessShareList()
  return self.guinness_data.share_list or {}
end
function logic_wedding_activity:GetGuinnessShareCount()
  return self.guinness_data.cnt or 0
end
function logic_wedding_activity:GetGuinnessAwardStatus(progress)
  local cnt = self:GetGuinnessShareCount()
  local CommonItem_Const = require("client.slua.component.item.ItemUtils.CommonItem_Const")
  if progress <= cnt then
    if not self.guinness_data.data.award_progress[progress] then
      return CommonItem_Const.Enum_ItemStatus.Done
    else
      return CommonItem_Const.Enum_ItemStatus.Got
    end
  else
    return CommonItem_Const.Enum_ItemStatus.Not
  end
end
function logic_wedding_activity:IsShared()
  if self.guinness_data.data and self.guinness_data.data.share_time and self.guinness_data.data.share_time ~= 0 then
    return true
  end
  return false
end
function logic_wedding_activity:GetMatchData()
  if not self:IsShared() then
    return nil
  end
  local logic_wedding = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wedding)
  local info = logic_wedding:GetSoulmateInfo()
  if not info then
    return nil
  end
  return {
    share_uid = self.guinness_data.data.share_uid,
    share_frd = self.guinness_data.data.share_frd,
    share_time = self.guinness_data.data.share_time
  }
end
function logic_wedding_activity:ShowNoticeError(err_id)
  if ERROR_CODE[err_id] then
    ShowNotice(ERROR_CODE[err_id])
  end
end
function logic_wedding_activity:GetGuinnessIsOpen()
  local version_util = require("client.common.version_util")
  local curVersion = version_util.GetMainFormat(Client.GetAppVersion())
  log("logic_wedding_activity.GetGuinnessIsOpen curVersion: " .. curVersion)
  local actCfgList = CDataTable.GetTableByFilter("GuinnessActivityCfg", "version", curVersion)
  if not actCfgList then
    log("logic_wedding_activity.GetGuinnessIsOpen curVersion has no actCfgList", curVersion)
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local actCfg = {}
  for actID, uConfig in pairs(actCfgList) do
    actCfg = uConfig
  end
  local appId = Client.GetITopGameId()
  log(bWriteLog and "logic_wedding_activity.GetGuinnessIsOpen appId: " .. tostring(appId))
  log_tree("logic_wedding_system_common.CheckGuinnessTime actCfg:", actCfg)
  local StringUtil = require("common.string_util")
  if actCfg and actCfg.APPID then
    local appIdList = StringUtil.Split(actCfg.APPID, "|")
    for k, v in pairs(appIdList) do
      if tonumber(v) == tonumber(appId) then
        return true
      end
    end
  end
  return false
end
function logic_wedding_activity:send_soulmate_guinness_act_info_req()
  local WeddingActivityHandler = require("client.network.Protocol.WeddingActivityHandler")
  WeddingActivityHandler.send_soulmate_guinness_act_info_req()
end
function logic_wedding_activity:on_soulmate_guinness_act_info_rsp(data, cnt, share_list)
  self.guinness_data.  local get_cnt = cnt or 0
  if self.guinness_data.cnt == nil or get_cnt > self.guinness_data.cnt then
    self.guinness_data.  end
  local need_delete = false
  if self:IsShared() then
    local self_uid = tonumber(DataMgr.roleData.uid)
    local have_data = false
    for index, value in ipairs(share_list) do
      if value.share_uid == self_uid or value.frd_uid == self_uid then
        have_data = true
        break
      end
    end
    if not have_data then
      table.insert(share_list, self:GetMatchData())
      if 150 < #share_list then
        need_delete = true
      end
    end
  end
  table.sort(share_list, function(a, b)
    return a.share_time < b.share_time
  end)
  if need_delete then
    table.remove(share_list, #share_list)
  end
  self.guinness_data.  EventSystem:postEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_GUINNESS_ACTIVITY_DATA_UPDATE)
end
function logic_wedding_activity:send_soulmate_guinness_act_share_req(frd_uid)
  local WeddingActivityHandler = require("client.network.Protocol.WeddingActivityHandler")
  WeddingActivityHandler.send_soulmate_guinness_act_share_req(frd_uid)
end
function logic_wedding_activity:on_soulmate_guinness_act_share_rsp(frd_uid, cur_share_cnt, award_list)
  self.guinness_data.cnt = cur_share_cnt
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec()
  self.guinness_data.data.share_uid = tonumber(DataMgr.roleData.uid)
  self.guinness_data.data.share_frd = frd_uid
  self.guinness_data.data.share_  local allData = {}
  for k, v in pairs(award_list) do
    local data = {res_id = k, count = v}
    table.insert(allData, data)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(allData)
  self:send_soulmate_guinness_act_info_req()
end
function logic_wedding_activity:send_soulmate_guinness_act_award_req(progress)
  local WeddingActivityHandler = require("client.network.Protocol.WeddingActivityHandler")
  WeddingActivityHandler.send_soulmate_guinness_act_award_req(progress)
end
function logic_wedding_activity:on_soulmate_guinness_act_award_rsp(progress, award_list)
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec()
  self.guinness_data.data.award_progress[progress] = time
  local allData = {}
  for k, v in pairs(award_list) do
    local data = {res_id = k, count = v}
    table.insert(allData, data)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(allData)
  EventSystem:postEvent(EVENTTYPE_WEDDING_ACTIVITY, EVENTID_WEDDING_GUINNESS_ACTIVITY_AWARD_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_wedding_activity = class(CModuleBase, nil, logic_wedding_activity)
return Clogic_wedding_activity