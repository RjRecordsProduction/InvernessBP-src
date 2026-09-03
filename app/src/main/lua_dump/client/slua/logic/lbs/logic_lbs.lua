local LogicLbs = {
  LABEL_SWITCH_NEAR_ID = 20151,
  LABEL_SWITCH_CHAT_ID = 20152,
  LABEL_SWITCH_WWARZONE = 20156,
  SETTING_CFG_MAIN_ID = 0,
  SETTING_CFG_NEAR_ID = 1,
  SETTING_CFG_WARZONE_ID = 2,
  SETTING_CFG_CHAT_ID = 3,
  RegionGlobal = 0,
  RegionCountry = 1,
  RegionProvince = 2,
  RegionCity = 3,
  RegionStreet = 4,
  myCountry = nil,
  myWarzoneCountry = nil,
  myZoneInfo = {},
  lbs_variable_table = {},
  tableReady = false,
  summaryReady = false,
  titleInfo = {},
  gpsInfo = {
    zone_for_gps = nil,
    query_ts = nil,
    total_count_gps = nil
  }
}
local lbs_zone_table = require("client.slua.logic.lbs.lbs_zone_table")
local regionDefMap = {
  [10] = LogicLbs.RegionGlobal,
  [20] = LogicLbs.RegionCountry,
  [30] = LogicLbs.RegionProvince,
  [40] = LogicLbs.RegionCity,
  [50] = LogicLbs.RegionStreet
}
function LogicLbs.Init()
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, LogicLbs.UpdateSwitch)
  EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, LogicLbs.UpdateWarZoneRedPoint)
  EventSystem:unregistEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LBS_WARZONE, LogicLbs.OpenUI)
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ACCEPT_INVITE, LogicLbs.OnTeamupAcceptInvite)
  EventSystem:unregistEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ON_ENTERTPLAN_NOTIFY, LogicLbs.OnEnterXmission)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, LogicLbs.UpdateSwitch)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, LogicLbs.UpdateWarZoneRedPoint)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LBS_WARZONE, LogicLbs.OpenUI)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ACCEPT_INVITE, LogicLbs.OnTeamupAcceptInvite)
  EventSystem:registEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ON_ENTERTPLAN_NOTIFY, LogicLbs.OnEnterXmission)
end
function LogicLbs.OnLogin()
  log(bWriteLog and "LogicLbs.OnLogin")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.lbs_table, LogicLbs.OnSyncLbsTable)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.get_role_lbs_battle_info_req(DataMgr.roleData.uid)
end
function LogicLbs.UpdateSwitch()
  LogicLbs.bGetNewbieData = true
  LogicLbs.UpdateWarZoneRedPoint()
end
function LogicLbs.OpenUI()
  local bOpen = LogicLbs.IsOpenNewVersionRank()
  if bOpen then
    UIManager.ShowUI(UIManager.UI_Config.ui_warzone_rank)
  else
    local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
    if AccessRestrictionSystem.IsTourist() then
      ShowNotice(32709)
    end
  end
end
function LogicLbs.OnTeamupAcceptInvite()
  local uiList = {
    "ui_warzone_guide",
    "ui_lbs_gps_reset",
    "ui_warzone_my_title2"
  }
  for i, name in pairs(uiList) do
    local cfg = UIManager.UI_Config[name]
    local ui = UIManager.GetUI(cfg)
    if ui then
      UIManager.CloseUI(cfg)
    end
  end
end
function LogicLbs.OnEnterXmission(_, _, benter)
  log(bWriteLog and "[qintong] LbsMgr.OnEnterXmission" .. tostring(benter))
  if benter then
    local ui_warzone_rank = UIManager.GetUI(UIManager.UI_Config.ui_warzone_rank)
    if ui_warzone_rank then
      ui_warzone_rank:OnBtnCloseClick(true)
    end
    local uiList = {
      "Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP",
      "ui_warzone_guide",
      "ui_lbs_gps_reset",
      "ui_warzone_my_title2",
      "ui_lbs_select_region"
    }
    for i, name in pairs(uiList) do
      local cfg = UIManager.UI_Config[name]
      local ui = UIManager.GetUI(cfg)
      if ui then
        UIManager.CloseUI(cfg)
      end
    end
  end
end
function LogicLbs.OnSyncLbsTable(tableName, data)
  log(bWriteLog and "LogicLbs.OnSyncLbsTable")
  if type(data) == "string" then
    log(bWriteLog and "LbsMgr.OnReceZoneData  size = " .. #data)
    data = slua.LuaArchiverDecode(LuaStateWrapper, data) or {}
  end
  if not data then
    log_error(bWriteLog and "On syncLbsTable data is nil")
    return
  end
  if not data.zone then
    log(bWriteLog and "On syncLbsTable data.zone is nil")
    return
  end
  log_tree("LogicLbs.OnSyncLbsTable data", data)
  lbs_zone_table.ProcGetZoneData(data.zone)
  LogicLbs.lbs_variable_table = data.lbs_variable_table
  LogicLbs.lbs_switch_table = data.lbs_switch_table
  LogicLbs.lbs_switch_table_all = data.lbs_switch_table_all
  LogicLbs.  LogicLbs.continents = {}
  for id, name in pairs(data.warzone_continent_table_new) do
    LogicLbs.continents[#LogicLbs.continents + 1] = {ID = id, name = name}
  end
  LogicLbs.moment = data.moment
  LogicLbs.UpdateWarZoneRedPoint()
  local moment_reddot_data = require("client.slua.logic.moment.moment_reddot_data")
  moment_reddot_data.InitSquareGuideInfo()
  LogicLbs.tableReady = true
  LogicLbs.myLbsNameCache = nil
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(13, function()
    local myLbsName = LogicLbs._CreateMyLbsName(false)
    if myLbsName then
      LogicLbs.ModifySocialCardLBS()
    end
  end)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARD)
end
function LogicLbs.UpdateLBSSummary(summaryInfo)
  log(bWriteLog and "LogicLbs.UpdateLBSSummary")
  log_tree(" LogicLbs.UpdateLBSSummary summaryInfo", summaryInfo)
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  settingConfig.bLbsMain = summaryInfo.privacy[LogicLbs.SETTING_CFG_MAIN_ID] == 1 and true or false
  settingConfig.bLbsNear = summaryInfo.privacy[LogicLbs.SETTING_CFG_NEAR_ID] == 1 and true or false
  settingConfig.bLbsWarZone = summaryInfo.privacy[LogicLbs.SETTING_CFG_WARZONE_ID] == 1 and true or false
  settingConfig.bLbsChat = summaryInfo.privacy[LogicLbs.SETTING_CFG_CHAT_ID] == 1 and true or false
  slua_GameFrontendHUD:FinishModifyUserSettings()
  LogicLbs.count = summaryInfo.count
  LogicLbs.lastChangeGPSTimeStamp = summaryInfo.update_ts
  LogicLbs.myZoneInfo = summaryInfo.zone
  LogicLbs.currentLbsWarzone = summaryInfo.lbs_zone
  if LogicLbs.currentLbsWarzone then
    LogicLbs.myWarzoneInfo = {}
    for k, v in pairs(LogicLbs.currentLbsWarzone) do
      local index = math.floor(k / 10 - 1)
      LogicLbs.myWarzoneInfo[index] = v
    end
  else
    LogicLbs.myWarzoneInfo = summaryInfo.zone
  end
  if summaryInfo.zone and summaryInfo.zone[1] ~= LogicLbs.myCountry then
    LogicLbs.myCountry = summaryInfo.zone[1]
  end
  if not LogicLbs.myCountry then
    LogicLbs.myCountry = 60000000
  end
  if LogicLbs.myWarzoneInfo then
    LogicLbs.myWarzoneCountry = LogicLbs.myWarzoneInfo[1]
  end
  if not LogicLbs.myWarzoneCountry then
    LogicLbs.myWarzoneCountry = 60000000
  end
  if LogicLbs.myCountry then
    local countryData = lbs_zone_table.GetZoneCfg(LogicLbs.myCountry)
    if countryData and LogicLbs.lbs_switch_table_all then
      local countryCode = countryData.country
      local switch_table = LogicLbs.lbs_switch_table_all[countryCode]
      if switch_table then
        LogicLbs.lbs_        log_tree("LogicLbs.UpdateLBSSummary LogicLbs.lbs_switch_table", LogicLbs.lbs_switch_table)
      end
    end
  end
  local moment_reddot_data = require("client.slua.logic.moment.moment_reddot_data")
  moment_reddot_data.InitSquareGuideInfo()
  LogicLbs.UpdateWarZoneRedPoint()
  LogicLbs.summaryReady = true
  LogicLbs.myLbsNameCache = nil
  LogicLbs.gpsInfo.zone_for_gps = summaryInfo.zone_for_gps
  LogicLbs.gpsInfo.query_ts = summaryInfo.query_ts
  LogicLbs.gpsInfo.total_count_gps = summaryInfo.total_count_gps
  EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_MY_ZONE)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARD)
end
function LogicLbs.ModifySocialCardLBS()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local zoneName = LbsMgr.GetMySetZoneConcatName("-")
  log(bWriteLog and "LogicLbs.ModifySocialCardLBS zoneName = " .. tostring(zoneName))
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  log_tree("LogicLbs.ModifySocialCardLBS SocialCardSystem.MySocialCard = ", SocialCardSystem.MySocialCard)
  if next(SocialCardSystem.MySocialCard) then
    local lbs = SocialCardSystem.MySocialCard.lbs
    log(bWriteLog and "LogicLbs.ModifySocialCardLBS lbs = " .. tostring(lbs))
    if lbs and lbs == zoneName then
      log(bWriteLog and "LogicLbs.ModifySocialCardLBS same value")
      return
    end
    log(bWriteLog and "LogicLbs.ModifySocialCardLBS diff value")
    SocialCardSystem.SocialCard = SocialCardSystem.MySocialCard
    SocialCardSystem.SocialCard.lbs = zoneName
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    RoleInfoSystem.modify_social_card()
  end
end
function LogicLbs.UpdateWarZoneInfo()
end
function LogicLbs.UpdateWarZoneRedPoint()
  local bRed = LogicLbs.GetLobbyWarZoneRedPoit()
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  if bRed then
    logic_lobby_reddot.ProcModuleReddot(BP_ENUM_MODULE_LBS_WARZONE, true)
  else
    logic_lobby_reddot.ProcModuleReddot(BP_ENUM_MODULE_LBS_WARZONE, false)
  end
end
function LogicLbs.UpdateMyZone(zone_list, time)
  LogicLbs.lastChangeGPSTimeStamp = time
  LogicLbs.count = LogicLbs.count + 1
  LogicLbs.myZoneInfo = zone_list
  ShowNotice(410004)
  LogicLbs.myLbsNameCache = nil
end
function LogicLbs.proc_get_lbs_potential_title_rsp(ret, title_map)
  if ret == 1 then
    for zoneID, info in pairs(title_map or {}) do
      local rankType = info.rank_type
      if not LogicLbs.titleInfo[zoneID] then
        LogicLbs.titleInfo[zoneID] = {}
      end
      if not LogicLbs.titleInfo[zoneID][rankType] then
        LogicLbs.titleInfo[zoneID][rankType] = {}
      end
      LogicLbs.titleInfo[zoneID][rankType] = info
      LogicLbs.titleInfo[zoneID].area_type = info.area_type
    end
  elseif ret == 0 then
    LogicLbs.titleInfo = {}
    for rankType, info in pairs(title_map or {}) do
      for zoneID, data in pairs(info) do
        if not LogicLbs.titleInfo[zoneID] then
          LogicLbs.titleInfo[zoneID] = {}
        end
        if not LogicLbs.titleInfo[zoneID][rankType] then
          LogicLbs.titleInfo[zoneID][rankType] = {}
        end
        LogicLbs.titleInfo[zoneID][rankType] = data
        LogicLbs.titleInfo[zoneID].area_type = data.area_type
      end
    end
  end
  LogicLbs.UpdateWarZoneRedPoint()
  EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_GET_TITLE_RSP)
end
function LogicLbs.UpdateJoin(id, join)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local LogType
  if id == LogicLbs.SETTING_CFG_NEAR_ID then
    SettingConfig.bLbsNear = join == 1
    LogType = TLogEventDefine.LBS_JOIN_NEAR
  elseif id == LogicLbs.SETTING_CFG_WARZONE_ID then
    SettingConfig.bLbsWarZone = join == 1
    LogType = TLogEventDefine.LBS_JOIN_WARZONE
  elseif id == LogicLbs.SETTING_CFG_MAIN_ID then
    SettingConfig.bLbsMain = join == 1
    LogType = TLogEventDefine.LBS_JOIN_MAIN
    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_JOIN_MAIN)
  elseif id == LogicLbs.SETTING_CFG_CHAT_ID then
    SettingConfig.bLbsChat = join == 1
    LogType = TLogEventDefine.LBS_JOIN_CHAT
  end
  log(bWriteLog and "[qintong] LbsMgr.UpdateJoin id =" .. id .. " join=" .. join)
  tlog_report_utils.ReportTLogEvent(LogType, join)
  slua_GameFrontendHUD:FinishModifyUserSettings()
  EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_JOIN_LBS)
end
function LogicLbs.GetZoneDataByID(zoneID)
  return lbs_zone_table.GetZoneCfg(zoneID)
end
function LogicLbs.GetMyZoneInfo()
  return LogicLbs.myZoneInfo
end
function LogicLbs.GetMyWarzoneInfo()
  return LogicLbs.myWarzoneInfo
end
function LogicLbs.RegionHide(id)
  if not id then
    return false
  end
  local zoneData = LogicLbs.GetZoneDataByID(id)
  if not zoneData then
    return false
  end
  return tonumber(zoneData.hide) == 1
end
function LogicLbs.RegionBlock(id)
  if not id then
    return false
  end
  local zoneData = LogicLbs.GetZoneDataByID(id)
  if not zoneData then
    return false
  end
  return tonumber(zoneData.RewardsBlock) == 1
end
function LogicLbs.GetMyMinZoneID()
  for i = LogicLbs.RegionStreet, LogicLbs.RegionCountry, -1 do
    local ZoneID = LogicLbs.myZoneInfo[i]
    if ZoneID and 0 < ZoneID then
      local data = lbs_zone_table.GetZoneCfg(ZoneID)
      if data and tonumber(data.hide) ~= 1 then
        return ZoneID
      end
    end
  end
  return nil
end
function LogicLbs.GetMoment()
  return LogicLbs.moment
end
function LogicLbs.GetMyCountry()
  return LogicLbs.myCountry
end
function LogicLbs.GetMyWarzoneCountry()
  return LogicLbs.myWarzoneCountry
end
function LogicLbs.GetSetLeftTime()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local setCD = LogicLbs.lbs_variable_table.SetSubRegionCD or 30
  local CDTime = setCD * 24 * 60 * 60
  local leftTime = LogicLbs.lastChangeGPSTimeStamp + CDTime - now
  return leftTime
end
function LogicLbs.GetSetGPSLeftTime()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local setCD = LogicLbs.lbs_variable_table.ModifyRegionCD or 15
  local CDTime = setCD * 24 * 60 * 60
  local leftTime = LogicLbs.lastChangeGPSTimeStamp + CDTime - now
  return leftTime
end
function LogicLbs.GetLastGPSZoneLeftTime()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local setCD = LogicLbs.lbs_variable_table.QueryRegionCD or 1
  local CDTime = setCD * 24 * 60 * 60
  local lastGetTime = LogicLbs.gpsInfo and LogicLbs.gpsInfo.query_ts or 0
  local leftTime = lastGetTime + CDTime - now
  log_format(bWriteLog and "LogicLbs:GetLastGPSZoneLeftTime. now:%s setCD:%s CDTime:%s lastGetTime:%s leftTime:%s", now, setCD, CDTime, lastGetTime, leftTime)
  return leftTime
end
function LogicLbs.GetSubRegionCD()
  return LogicLbs.lbs_variable_table.SetSubRegionCD
end
function LogicLbs.GetCountryLbsSwitch(countryID)
  if LogicLbs.lbs_switch_table_all then
    return LogicLbs.lbs_switch_table_all[countryID]
  end
  return nil
end
function LogicLbs.GetContinents()
  return LogicLbs.continents
end
function LogicLbs.GetTitleInfo()
  return LogicLbs.titleInfo
end
function LogicLbs.GetRegionCode()
  local data = DataMgr.RegionData
  local regionConfig = CDataTable.GetTableData("RegionConfig", data.region)
  local regionCode = ""
  if regionConfig then
    regionCode = regionConfig.regionCode
  end
  return regionCode
end
function LogicLbs.GetLBSShowZoneName(moduleID)
  local name = LocUtil.GetLocalizeResStr(24583)
  if not LogicLbs.IsReady() then
    return name
  end
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  local bTourist = AccessRestrictionSystem.IsTourist()
  if bTourist then
    return name
  end
  local bSet = LogicLbs.IsSetMyProvince()
  if not bSet then
    return name
  end
  local lbs_switch_table = LogicLbs.lbs_switch_table or {}
  moduleID = moduleID or LogicLbs.SETTING_CFG_NEAR_ID
  local level
  if moduleID == LogicLbs.SETTING_CFG_NEAR_ID then
    level = lbs_switch_table.friend
  elseif moduleID == LogicLbs.SETTING_CFG_WARZONE_ID then
    level = lbs_switch_table.zone
  elseif moduleID == LogicLbs.SETTING_CFG_CHAT_ID then
    level = lbs_switch_table.chat
  else
    level = lbs_switch_table.friend
  end
  for i = LogicLbs.RegionStreet, LogicLbs.RegionCountry, -1 do
    local ZoneID = LogicLbs.myZoneInfo[i]
    local dData = lbs_zone_table.GetZoneCfg(ZoneID)
    if dData and dData.level == level and tonumber(dData.hide) ~= 1 then
      return lbs_zone_table.GetZoneName(dData)
    end
  end
  return name
end
function LogicLbs.GetMySetZoneConcatName(key)
  local myLbsName = LogicLbs._CreateMyLbsName(true)
  if myLbsName == nil then
    return ""
  end
  return table.concat(myLbsName, key)
end
function LogicLbs.GetLobbyWarZoneRedPoit()
  local red = LogicLbs.GetWarZoneTitleNewRed()
  local bOpen = LogicLbs.IsOpenNewVersionRank()
  local bSelect = LogicLbs.CanSelectProvinceMyCountry(LogicLbs.SETTING_CFG_WARZONE_ID)
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  local bTourist = AccessRestrictionSystem.IsTourist()
  local bSet = LogicLbs.IsSetMyProvince()
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  local isOpenGPS1 = logic_lbs_warzone:CheackIsOpenZoneGPS()
  if isOpenGPS1 then
    local isFinishFirst = logic_lbs_warzone:CheackHasFinishFirstSet()
    if isFinishFirst then
      log(bWriteLog and "LogicLbs.GetLobbyWarZoneRedPoit has set")
      bSet = true
    end
  end
  if not bTourist and bOpen and bSelect then
    return red or not bSet
  else
    return red
  end
end
function LogicLbs.GetWarZoneTitleNewRed()
  local red = false
  for i, info in pairs(LogicLbs.titleInfo) do
    for _, iInfo in pairs(info or {}) do
      if type(iInfo) == "table" and iInfo.new and iInfo.new == 1 then
        red = true
        break
      end
    end
  end
  return red
end
function LogicLbs.IsReady()
  return LogicLbs.summaryReady and LogicLbs.tableReady
end
function LogicLbs.IsLbsAllSwitchOpen()
  local bOpen = LogicLbs.CanSelectProvinceMyCountry(LogicLbs.SETTING_CFG_NEAR_ID)
  log(bWriteLog and "LogicLbs.IsLbsAllSwitchOpen bOpen1 = " .. tostring(bOpen))
  if not bOpen then
    bOpen = LogicLbs.CanSelectProvinceMyCountry(LogicLbs.SETTING_CFG_WARZONE_ID)
    log(bWriteLog and "LogicLbs.IsLbsAllSwitchOpen bOpen2 = " .. tostring(bOpen))
  end
  if not bOpen then
    bOpen = LogicLbs.CanSelectProvinceMyCountry(LogicLbs.SETTING_CFG_CHAT_ID)
    log(bWriteLog and "LogicLbs.IsLbsAllSwitchOpen bOpen3 = " .. tostring(bOpen))
  end
  log(bWriteLog and "LogicLbs.IsLbsAllSwitchOpen bOpen4 = " .. tostring(bOpen))
  return bOpen
end
function LogicLbs.CanSelectProvinceMyCountry(moduleID)
  log(bWriteLog and "LogicLbs.CanSelectProvinceMyCountry moduleID = " .. tostring(moduleID))
  if not LogicLbs.IsLbsOpen() then
    log(bWriteLog and "LogicLbs.CanSelectProvinceMyCountry bOpen = false")
    return false
  end
  if LogicLbs.lbs_switch_table_all == nil then
    log(bWriteLog and "LogicLbs.CanSelectProvinceMyCountry lbs_switch_table_all == nil")
    return false
  end
  local countryID = LogicLbs.myCountry
  local countryInfo = lbs_zone_table.GetZoneCfg(countryID)
  local key = countryInfo and countryInfo.country
  local zoneInfo = {}
  if key and LogicLbs.lbs_switch_table_all[key] then
    zoneInfo = LogicLbs.lbs_switch_table_all[key]
  end
  local level, menuSwitch
  if moduleID == LogicLbs.SETTING_CFG_NEAR_ID then
    menuSwitch = LogicLbs.LABEL_SWITCH_NEAR_ID
    level = zoneInfo.friend
  elseif moduleID == LogicLbs.SETTING_CFG_CHAT_ID then
    menuSwitch = LogicLbs.LABEL_SWITCH_CHAT_ID
    level = zoneInfo.chat
  elseif moduleID == LogicLbs.SETTING_CFG_WARZONE_ID then
    menuSwitch = LogicLbs.LABEL_SWITCH_WWARZONE
    level = zoneInfo.zone
  end
  log(bWriteLog and "LogicLbs.CanSelectProvinceMyCountry menuSwitch = " .. tostring(menuSwitch) .. " level = " .. tostring(level))
  if not (LobbySystem.CheckOpen(menuSwitch) and level) or level == 0 then
    log(bWriteLog and "LogicLbs.CanSelectProvinceMyCountry bOpen = false")
    return false
  end
  return true
end
function LogicLbs.IsMyLbsModuleZoneReady(moduleID)
  local switchTable = LogicLbs.lbs_switch_table
  local level
  if moduleID == LogicLbs.SETTING_CFG_NEAR_ID then
    level = switchTable.friend
  elseif moduleID == LogicLbs.SETTING_CFG_CHAT_ID then
    level = switchTable.chat
  elseif moduleID == LogicLbs.SETTING_CFG_WARZONE_ID then
    level = switchTable.zone
  end
  if level and 0 < level then
    local zoneID = LogicLbs.GetMyMinZoneID()
    if zoneID then
      local zoneData = lbs_zone_table.GetZoneCfg(zoneID)
      if zoneData and switchTable and level <= zoneData.level then
        return true
      end
    end
  end
  return false
end
function LogicLbs.IsLbsSettingOpen(moduleID)
  if not LogicLbs.IsLbsOpen() then
    return false
  end
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  if not settingConfig.bLbsMain then
    return false
  end
  if moduleID == LogicLbs.SETTING_CFG_NEAR_ID then
    if not LobbySystem.CheckOpen(LogicLbs.LABEL_SWITCH_NEAR_ID) then
      return false
    end
    return settingConfig.bLbsNear
  elseif moduleID == LogicLbs.SETTING_CFG_CHAT_ID then
    if not LobbySystem.CheckOpen(LogicLbs.LABEL_SWITCH_CHAT_ID) then
      return false
    end
    return settingConfig.bLbsChat
  elseif moduleID == LogicLbs.SETTING_CFG_WARZONE_ID then
    if not LobbySystem.CheckOpen(LogicLbs.LABEL_SWITCH_WWARZONE) then
      return false
    end
    return settingConfig.bLbsWarZone
  end
  return false
end
function LogicLbs.IsLbsOpen()
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  local bTourist = AccessRestrictionSystem.IsTourist()
  if bTourist then
    log(bWriteLog and "LogicLbs.IsLbsOpen bTourist = true")
    return false
  end
  if LogicLbs.myCountry == nil then
    log(bWriteLog and "LogicLbs.IsLbsOpen myCountry == nil")
    return false
  end
  return lbs_zone_table.CheckCountryHasProvince(LogicLbs.myCountry)
end
function LogicLbs.IsSetMyProvince()
  for i = LogicLbs.RegionStreet, LogicLbs.RegionProvince, -1 do
    local zoneID = LogicLbs.myZoneInfo[i]
    if zoneID then
      local info = lbs_zone_table.GetZoneCfg(zoneID)
      if info and tonumber(info.hide) ~= 1 then
        return true
      end
    end
  end
  log(bWriteLog and "LogicLbs:IsSetMyProvince false")
  log_tree("LogicLbs:IsSetMyProvince myzoneinfo: ", LogicLbs.myZoneInfo)
  return false
end
function LogicLbs.CheckAeguild()
  return LogicLbs.lbs_switch_table and LogicLbs.lbs_switch_table.aeguild == 1
end
function LogicLbs.IsOpenNewVersionRank()
  local AccessRestrictionSystem = require("client.logic.common.logic_access_restriction")
  local bTourist = AccessRestrictionSystem.IsTourist()
  if bTourist then
    return false
  end
  local bLabel = LobbySystem.CheckOpen(LogicLbs.LABEL_SWITCH_WWARZONE)
  if not bLabel then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local bOpen = tonumber(LogicLbs.lbs_variable_table.NewLbsRankOpen) == 1
  if bOpen then
    local now = TimeUtil.GetServerTimeInSec()
    local openTime = LogicLbs.lbs_variable_table.NewLbsRankEffectBeginTime
    if now >= TimeUtil.TimeStringToUnixstamp(openTime) then
      return true
    else
      return false
    end
  else
    return false
  end
end
function LogicLbs.GetZoneName(rank_id)
  local cfg = lbs_zone_table.GetZoneCfg(rank_id)
  if not cfg then
    return ""
  end
  return lbs_zone_table.GetZoneName(cfg)
end
function LogicLbs.ConvertFrom(zoneLevel)
  return regionDefMap[zoneLevel]
end
function LogicLbs.ClearLBSWarZoneReddot()
  if LogicLbs.IsSetMyProvince() then
    local red = false
    for _, info in pairs(LogicLbs.titleInfo) do
      for _, iInfo in pairs(info or {}) do
        if type(iInfo) == "table" and iInfo.new and iInfo.new == 1 then
          red = true
          break
        end
      end
    end
    local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
    if red == false then
      logic_lobby_reddot.ProcModuleReddot(BP_ENUM_MODULE_LBS_WARZONE, false)
    else
      logic_lobby_reddot.ProcModuleReddot(BP_ENUM_MODULE_LBS_WARZONE, true)
    end
  end
end
function LogicLbs.ClearTitleRedPoint()
  for _, list in pairs(LogicLbs.titleInfo or {}) do
    if type(list) == "table" then
      for _, info in pairs(list) do
        if type(info) == "table" and info.new == 1 then
          info.new = 0
        end
      end
    end
  end
  LogicLbs.UpdateWarZoneRedPoint()
  EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_MY_TITLE_REDPOINT)
end
function LogicLbs.OnGameStateChange(eventType, eventID, gameState)
end
function LogicLbs._CreateMyLbsName(bUseCache)
  log(bWriteLog and "LogicLbs._CreateMyLbsName")
  if not LogicLbs.IsReady() then
    return nil
  end
  if bUseCache and LogicLbs.myLbsNameCache then
    return LogicLbs.myLbsNameCache
  end
  local nameTable = {}
  for i = LogicLbs.RegionCountry, LogicLbs.RegionStreet do
    local zoneID = LogicLbs.myZoneInfo[i]
    if zoneID then
      local data = lbs_zone_table.GetZoneCfg(zoneID)
      if data and data.hide and tonumber(data.hide) ~= 1 then
        local zoneName = lbs_zone_table.GetZoneName(data)
        if zoneName and zoneName ~= "" then
          nameTable[#nameTable + 1] = zoneName
        end
      end
    end
  end
  LogicLbs.myLbsNameCache = nameTable
  return nameTable
end
function LogicLbs.SetZoneForGps(zone_id_list, query_ts)
  log(bWriteLog and "LogicLbs.SetZoneForGps query_ts " .. tostring(query_ts))
  log_tree("LogicLbs.SetZoneForGps zone_id_list", zone_id_list)
  if zone_id_list and next(zone_id_list) then
    LogicLbs.gpsInfo.zone_for_gps = zone_id_list
  end
  query_ts = tonumber(query_ts)
  if query_ts then
    LogicLbs.gpsInfo.  end
end
return LogicLbs