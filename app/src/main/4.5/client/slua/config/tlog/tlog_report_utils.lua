local tlog_report_utils = {}
local _isCanReportMarketStay = false
local _isInitConfig = false
local _extraTlogReportEnableCfg
local _BusinessReportEnable = false
local _InitExtraReportConfig = function()
  if _isInitConfig then
    return
  end
  _extraTlogReportEnableCfg = {
    [TLogEventDefine.StoreItem_Preview] = tlog_report_utils.GetMarketStayUpdateEnable,
    [TLogEventDefine.AccountBindingChangedPopup] = true,
    [TLogEventDefine.RecommendedFriend_ClickCancel] = true,
    [TLogEventDefine.RecommendedFriend_ClickEnter] = true,
    [TLogEventDefine.RecommendedFriend_RecommendFinish] = true,
    [TLogEventDefine.RecommendedFriend_BackUser_ClickCancel] = true,
    [TLogEventDefine.RecommendedFriend_BackUser_ClickEnter] = true,
    [TLogEventDefine.RecommendedFriend_BackUser_TimeOver] = true,
    [TLogEventDefine.RecommendedFriend_ApplyClickCancel] = true,
    [TLogEventDefine.RecommendedFriend_ApplyClickReceive] = true,
    [TLogEventDefine.RecommendedFriend_ApplyFinish] = true,
    [TLogEventDefine.RecommendedFriend_T_ClickCancel] = true,
    [TLogEventDefine.RecommendedFriend_T_ClickEnter] = true,
    [TLogEventDefine.RecommendedFriend_T_ClickTimeOver] = true,
    [TLogEventDefine.Conqueror_Video_Play_Report] = true,
    [TLogEventDefine.Screen_Capture_Report] = true,
    [TLogEventDefine.BattleResult_ClickInviteTeam] = true,
    [TLogEventDefine.ClickWonderfulRePlayWindow] = true,
    [TLogEventDefine.SpawnActorCounter_Character] = true,
    [TLogEventDefine.MainCity_dance_lead] = true,
    [TLogEventDefine.MainCity_dance_follow] = true,
    [TLogEventDefine.MainCity_Skill_Action_Success] = true,
    [TLogEventDefine.MainCity_Emote_Action_Success] = true,
    [TLogEventDefine.MainCity_Interactive_Action_Success] = true,
    [TLogEventDefine.EnterBattleFromMainCityClickStart] = true,
    [TLogEventDefine.ActionInMainCity] = true,
    [TLogEventDefine.MainCity_Leave] = true,
    [TLogEventDefine.MainCity_Load_Map_Failed] = true,
    [TLogEventDefine.Agegate_Slide_Age_Report] = true,
    [TLogEventDefine.Security_Station_ClickGo] = true,
    [TLogEventDefine.LobbyMain_Scroll_To_UGC_Hall] = true,
    [TLogEventDefine.LobbyMain_Click_To_UGC_Hall] = true,
    [TLogEventDefine.ModeSelect_Click_To_UGC_Hall] = true,
    [TLogEventDefine.Module_Jump_To_UGC_Hall] = true,
    [TLogEventDefine.UGC_Hall_Top_Click_Head] = true,
    [TLogEventDefine.UGC_Hall_Top_Click_Search] = true,
    [TLogEventDefine.UGC_Hall_Top_Click_Club] = true,
    [TLogEventDefine.UGC_Hall_Top_Click_Home_Entry] = true,
    [TLogEventDefine.UGC_Hall_Top_Click_Appreciation] = true,
    [TLogEventDefine.UGC_Hall_Top_Click_UGCWarehouse] = true,
    [TLogEventDefine.UGC_Hall_Top_Click_Settings] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_WoWPass] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_Banner] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_PlayTogether] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_Team] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_Friend] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_PlayOften] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_Creation] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Click_More] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Click_Invite_Friend] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Click_Download] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Item_RecruitmentClick] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Item_FindTeammatesClick] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Item_ChatClick] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Item_MicOnClick] = true,
    [TLogEventDefine.UGC_Hall_Map_Info_Item_SoundOnClick] = true,
    [TLogEventDefine.UGC_Hall_Map_Chat_Item_ChatClick] = true,
    [TLogEventDefine.UGC_Hall_Enter_Social_Status] = true,
    [TLogEventDefine.UGC_Hall_Left_Click_Pass] = true,
    [TLogEventDefine.UGC_Hall_Mod_Exposure_Main] = true,
    [TLogEventDefine.LobbyDownloadBtn] = true,
    [TLogEventDefine.DownloadMainUIPageChanged] = true,
    [TLogEventDefine.DownloadMainUIWowCache] = true
  }
  _isInitConfig = true
end
function tlog_report_utils.IsCanReportLobbyEvent(buttton_type)
  _InitExtraReportConfig()
  if buttton_type ~= nil and _extraTlogReportEnableCfg ~= nil and _extraTlogReportEnableCfg[buttton_type] ~= nil then
    local define = _extraTlogReportEnableCfg[buttton_type]
    if type(define) == "function" then
      return define()
    elseif type(define) == "boolean" then
      return define
    end
  end
  if tlog_report_utils.IsBusinessReport(buttton_type) then
    return true
  end
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  return gem_report_utils.GetReportLobbyEventEnable()
end
function tlog_report_utils.SetMarketStayUpdateEnable(marketStayUpdateEnable)
  log(bWriteLog and "[v_wllwu] tlog_report_utils.SetMarketStayUpdateEnable = " .. tostring(marketStayUpdateEnable))
  _isCanReportMarketStay = marketStayUpdateEnable
end
function tlog_report_utils.GetMarketStayUpdateEnable()
  return _isCanReportMarketStay
end
function tlog_report_utils.SetBusinessReportEnable(enable)
  _BusinessReportEnable = enable
end
function tlog_report_utils.IsBusinessReport(button_type)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local bSwitchOpen = _BusinessReportEnable or gem_report_utils.GetReportLobbyEventEnable()
  local tlog_report_config_spin = require("client.slua.config.tlog.config.tlog_report_config_spin")
  if bSwitchOpen and tlog_report_config_spin[button_type] then
    return true
  end
  return false
end
local SendTLogReportImmediate = function(buttton_type, reason, reason_str, IsImmediateReport)
  if tlog_report_utils.IsCanReportLobbyEvent(buttton_type) then
    local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
    if IsImmediateReport then
      BasicDataTLogReport:ReportImmediate(buttton_type, reason or 0, reason_str)
    else
      BasicDataTLogReport:ReportDelay(buttton_type, reason or 0, reason_str)
    end
  end
end
function tlog_report_utils.ReportTLogEvent(buttton_type, reason, reason_str, IsImmediateReport)
  log(bWriteLog and "[YY]tlog_report_utils.ReportTLogEvent buttton_type " .. tostring(buttton_type) .. " reasonStr" .. tostring(reason_str))
  if buttton_type == nil or type(buttton_type) ~= "number" then
    log_error(bWriteLog and "tlog_report_utils.ReportTLogEvent buttton_type error!!! buttton_type is " .. tostring(buttton_type))
  end
  if reason ~= nil and type(reason) ~= "number" then
    log_error(bWriteLog and "tlog_report_utils.ReportTLogEvent reason error!!! reason is " .. tostring(reason))
  end
  SendTLogReportImmediate(buttton_type, reason, reason_str, IsImmediateReport)
end
local start_timestamp_map = {}
function tlog_report_utils.SetTlogBeginType(tlogType, timestamp)
  start_timestamp_map[tlogType] = timestamp
  log(bWriteLog and "tlog_report_utils.SetTlogBeginType " .. tostring(tlogType) .. "  " .. tostring(timestamp))
end
function tlog_report_utils.SetTlogEndType(tlogType, timestamp)
  local time = timestamp - (start_timestamp_map[tlogType] or 0)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:send_report_event_duration_log(tlogType, time)
end
local _wowDownloadKeyCache
local _InitWoWDownloadKeyCache = function()
  if _wowDownloadKeyCache then
    return
  end
  _wowDownloadKeyCache = {}
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local bundleID = PufferConst.UGC_BUNDLE_ID or 100011
  local cfg = CDataTable.GetTableDataByFilter("DownloaderNewTable", "BundleID", bundleID)
  if not (cfg and cfg.BundleContent) or cfg.BundleContent == "" then
    return
  end
  local StringUtil = require("common.string_util")
  local contentList = StringUtil.Split(cfg.BundleContent, "|")
  for _, contentKey in ipairs(contentList) do
    _wowDownloadKeyCache[contentKey] = true
    local pakCfg = CDataTable.GetTableData("DownloaderPakCfg", contentKey)
    if pakCfg and pakCfg.PakContent and pakCfg.PakContent ~= "" then
      local subKeys = StringUtil.Split(pakCfg.PakContent, "|")
      for _, subKey in ipairs(subKeys) do
        _wowDownloadKeyCache[subKey] = true
      end
    end
  end
end
function tlog_report_utils.IsWoWDownloadKey(key)
  if not key then
    return false
  end
  _InitWoWDownloadKeyCache()
  return _wowDownloadKeyCache[tostring(key)] == true
end
return tlog_report_utils