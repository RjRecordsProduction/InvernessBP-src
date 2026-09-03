require("client.slua.config.gem_report_config")
local _GEMForbiddenSymbol = "[|&:,-]"
local _GEMSeparatorSymbol1 = "_"
local _GEMSeparatorSymbol2 = "-"
local _GameSeparatorSymbol = "+"
local _IsReciveOneGemInfo = false
local _FirstTimeStamp = {}
local _CachedTime = 60
local _CachedOneLimitNum = 10
local _WorkTimeMap = {}
local _InBattleGemReportCache = {}
local _ReportLobbyEventEnable = false
function gem_report_utils.SetReportLobbyEventEnable(enable)
  _ReportLobbyEventEnable = enable
end
function gem_report_utils.GetReportLobbyEventEnable()
  if gem_report_utils.IsReleaseVersion() then
    return _ReportLobbyEventEnable
  else
    return true
  end
end
local _ClientExceptionReportEnable = false
function gem_report_utils.SetClientExceptionReportEnable(enable)
  _ClientExceptionReportEnable = enable
end
local GetClientExceptionReportEnable = function()
  if gem_report_utils.IsReleaseVersion() then
    return _ClientExceptionReportEnable
  else
    return true
  end
end
function gem_report_utils.IsReleaseVersion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return Client.IsShipping() and globalConfig.IsDirectConnect() and not PublishRegionMacros.IsCEVersion()
end
function gem_report_utils.IsPublishVersion()
  return Client.IsShipping() and globalConfig.IsDirectConnect()
end
local _TableToReportString = function(tab)
  local str = ""
  for k, v in pairs(tab) do
    if string.len(str) ~= 0 then
      str = str .. ","
    end
    str = str .. k .. _GEMSeparatorSymbol2 .. v
  end
  return str
end
local _LuaStringSplitCount = function(str, split_char)
  if not str then
    return 0
  end
  local count = 1
  local pos = 0
  pos = string.find(str, split_char, pos)
  while pos do
    count = count + 1
    pos = string.find(str, split_char, pos + 1)
    goto lbl_26
    do break end
    ::lbl_26::
  end
  return count
end
local _BInBattle = function()
  return GameStatus.InCombatActiveState()
end
function gem_report_utils.CanReport()
  if _BInBattle() then
    return -1
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter.bInMainCity then
    return -2
  end
  return 0
end
local _SendFileGEMReport = function()
  local nRet = gem_report_utils.CanReport()
  if nRet == -1 then
    log(bWriteLog and "_SendFileGEMReport failed because in Battle")
    return true
  elseif nRet == -2 then
    log(bWriteLog and "_SendFileGEMReport failed because in main city")
    return true
  end
  if 0 < #_InBattleGemReportCache then
    for index = 1, #_InBattleGemReportCache do
      local GemReportItem = _InBattleGemReportCache[index]
      xpcall(function()
        gem_report_utils.SaveGemReportInFile(GemReportItem.EventName, GemReportItem.SubEvent, table.unpack(GemReportItem.Params))
      end, require("common.utility").ErrorMessageHandler)
    end
    _InBattleGemReportCache = {}
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGEMReissue)
  if not info then
    return
  end
  for eventName, v in pairs(info) do
    for key, vvalue in pairs(v) do
      info[eventName][key] = tostring(_LuaStringSplitCount(vvalue, _GameSeparatorSymbol)) .. _GEMSeparatorSymbol1 .. vvalue
    end
  end
  for eventName, v in pairs(info) do
    local stringid_json = _TableToReportString(v)
    if stringid_json then
      Client.GEMReportSubEvent(GameFrontendHUD, eventName, stringid_json, {})
      log(bWriteLog and "_SendFileGEMReport success, eventName = " .. tostring(eventName) .. ", subEvent = " .. tostring(stringid_json))
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eGEMReissue)
  return false
end
local _SendCachedGEMReport = function()
  _IsReciveOneGemInfo = _SendFileGEMReport()
end
function gem_report_utils.GetReportParam(id, jumpURL, click)
  local JumpUtils = require("client.logic.store.jump_utils")
  jumpURL = string.gsub(jumpURL, _GEMSeparatorSymbol1, _GameSeparatorSymbol)
  local result = ""
  local module = ""
  if JumpUtils.IsGameJumpUrl(jumpURL) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(jumpURL)
    module = "module" .. _GameSeparatorSymbol .. tostring(params.module) .. _GameSeparatorSymbol .. "activityid" .. _GameSeparatorSymbol .. tostring(params.activityid)
  elseif JumpUtils.IsPanDoraJumpUrl(jumpURL) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(jumpURL)
    module = "pandora" .. _GameSeparatorSymbol .. tostring(params.actid)
  elseif JumpUtils.IsHttpOrHttpsJumpUrl(jumpURL) then
    local last = string.find(jumpURL, "?")
    if last then
      module = string.sub(jumpURL, 1, last - 1)
    else
      module = jumpURL
    end
  else
    module = "None"
  end
  result = tostring(module) .. "_" .. tostring(id) .. "_" .. Client.GetCurrentLanguage()
  if click then
    result = result .. "_1"
  else
    result = result .. "_0"
  end
  return result
end
function gem_report_utils.GetReportParamTable(id, jumpURL, click)
  local JumpUtils = require("client.logic.store.jump_utils")
  local StringUtil = require("common.string_util")
  local table = {}
  if JumpUtils.IsGameJumpUrl(jumpURL) then
    local params = StringUtil.ParseURLParams(jumpURL)
    table.module = tostring(params.module)
    table.activity_id = tonumber(params.activityid)
  elseif JumpUtils.IsPanDoraJumpUrl(jumpURL) then
    local params = StringUtil.ParseURLParams(jumpURL)
    table.module = "pandora"
    table.activity_id = tonumber(params.actid)
  elseif JumpUtils.IsHttpOrHttpsJumpUrl(jumpURL) then
    local last = string.find(jumpURL, "?")
    if last then
      table.module = string.sub(jumpURL, 1, last - 1)
    else
      table.module = jumpURL
    end
  end
  table.language = Client.GetCurrentLanguage()
  table.click = click and "true" or "false"
  table.  return table
end
function gem_report_utils.GetReportModule(jumpUrl)
  local JumpUtils = require("client.logic.store.jump_utils")
  if JumpUtils.IsGameJumpUrl(jumpUrl) then
    return "Game"
  elseif JumpUtils.IsPanDoraJumpUrl(jumpUrl) then
    return "pandora"
  elseif JumpUtils.IsHttpOrHttpsJumpUrl(jumpUrl) then
    return "Http"
  else
    return "None"
  end
end
function GEMReportBtnClickEvent(subEvent, para1, para2)
  gem_report_utils.ReportBtnClickEvent(subEvent, para1, para2)
end
function gem_report_utils.ReportBtnClickEvent(subEvent, para1, para2)
  gem_report_utils.ReportEventDelay(gem_report_utils.EventName_ClickEvent, subEvent, para1, para2)
  local logInfo = subEvent
  if nil ~= para1 and "" ~= para1 then
    logInfo = logInfo .. ":" .. tostring(para1)
  end
  if nil ~= para2 and "" ~= para2 then
    logInfo = logInfo .. ":" .. tostring(para2)
  end
  Client.CrashLog(NetInterface, 4, "Lobby", logInfo)
end
function gem_report_utils.ReportBtnClickEventInBattle(subEvent, para1, para2)
  gem_report_utils.ReportEventDelayInBattle(gem_report_utils.EventName_ClickEvent, subEvent, para1, para2)
  local logInfo = subEvent
  if nil ~= para1 and "" ~= para1 then
    logInfo = logInfo .. ":" .. tostring(para1)
  end
  if nil ~= para2 and "" ~= para2 then
    logInfo = logInfo .. ":" .. tostring(para2)
  end
  Client.CrashLog(NetInterface, 4, "Fighting", logInfo)
end
function gem_report_utils.ReportDownloadEvent(subEvent, para1, para2)
  gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Download, subEvent, para1, para2)
  local logInfo = subEvent
  if nil ~= para1 and "" ~= para1 then
    logInfo = logInfo .. ":" .. tostring(para1)
  end
  if nil ~= para2 and "" ~= para2 then
    logInfo = logInfo .. ":" .. tostring(para2)
  end
  Client.CrashLog(NetInterface, 4, "Lobby", logInfo)
end
function gem_report_utils.ReportLobbyClickEvent(subEvent, para1, para2)
  if gem_report_utils.GetReportLobbyEventEnable() then
    gem_report_utils.ReportEventDelay(gem_report_utils.EventName_LobbyEvent, subEvent, para1, para2)
  end
  local logInfo = subEvent
  if nil ~= para1 and "" ~= para1 then
    logInfo = logInfo .. ":" .. tostring(para1)
  end
  if nil ~= para2 and "" ~= para2 then
    logInfo = logInfo .. ":" .. tostring(para2)
  end
  Client.CrashLog(NetInterface, 4, "Lobby", logInfo)
end
function gem_report_utils.StartWorkTime(subEvent)
  if not gem_report_utils.GetReportLobbyEventEnable() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  _WorkTimeMap[subEvent] = TimeUtil.OSTime()
end
function gem_report_utils.ReportWorkTimeEvent(subEvent)
  if not gem_report_utils.GetReportLobbyEventEnable() then
    return
  end
  local workTime = 0
  if _WorkTimeMap[subEvent] then
    local TimeUtil = require("client.common.time_util")
    workTime = TimeUtil.OSTime() - _WorkTimeMap[subEvent]
    _WorkTimeMap[subEvent] = nil
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_WorkTimeEvent, subEvent, workTime, nil)
  end
end
function gem_report_utils.ClearAllWorkTime()
  _WorkTimeMap = {}
end
function gem_report_utils.ReportEventImmediate(eventName, subEvent, para1, para2, para3, para4)
  local nRet = gem_report_utils.CanReport()
  if nRet == -1 then
    log_error("gem_report_utils.ReportEventImmediate in Battle eventName = " .. eventName .. ", subEvent = " .. subEvent)
    return
  elseif nRet == -2 then
    log(bWriteLog and "gem_report_utils.ReportEventImmediate in main city eventName = " .. eventName .. ", subEvent = " .. subEvent)
    return
  end
  local para = {}
  local id = 1
  if para1 then
    para[id] = string.gsub(tostring(para1), _GEMForbiddenSymbol, _GameSeparatorSymbol)
    id = id + 1
  end
  if para2 then
    para[id] = string.gsub(tostring(para2), _GEMForbiddenSymbol, _GameSeparatorSymbol)
    id = id + 1
  end
  if para3 then
    para[id] = string.gsub(tostring(para3), _GEMForbiddenSymbol, _GameSeparatorSymbol)
    id = id + 1
  end
  if para4 then
    para[id] = string.gsub(tostring(para4), _GEMForbiddenSymbol, _GameSeparatorSymbol)
    id = id + 1
  end
  Client.GEMReportSubEvent(GameFrontendHUD, eventName, subEvent, para)
  local logInfo = subEvent
  if nil ~= para1 and "" ~= para1 then
    logInfo = logInfo .. ":" .. tostring(para1)
  end
  if nil ~= para2 and "" ~= para2 then
    logInfo = logInfo .. ":" .. tostring(para2)
  end
  if nil ~= para3 and "" ~= para3 then
    logInfo = logInfo .. ":" .. tostring(para3)
  end
  if nil ~= para4 and "" ~= para4 then
    logInfo = logInfo .. ":" .. tostring(para4)
  end
  Client.CrashLog(NetInterface, 4, "Lobby", logInfo)
end
function gem_report_utils.ReportEventImmediateForCommon(subEvent, para1, para2)
  log_error("deprecated ReportEventImmediateForCommon")
end
function gem_report_utils.SaveGemReportInFile(eventName, subEvent, ...)
  local TimeUtil = require("client.common.time_util")
  if not _IsReciveOneGemInfo then
    _IsReciveOneGemInfo = true
    _FirstTimeStamp.bFirstIn = true
    _FirstTimeStamp.TimeStamp = TimeUtil.OSTime()
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(_CachedTime, _SendCachedGEMReport)
  else
    _FirstTimeStamp.bFirstIn = false
  end
  local ParamNum = select("#", ...)
  if 9 < ParamNum then
    ParamNum = 9
  end
  for i = 1, ParamNum do
    local Param = select(i, ...)
    local StrParam
    if Param then
      StrParam = string.gsub(tostring(Param), _GEMForbiddenSymbol, _GameSeparatorSymbol)
    end
    if StrParam and string.len(StrParam) > 0 then
      subEvent = subEvent .. _GEMSeparatorSymbol1 .. StrParam
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGEMReissue)
  info = info or {}
  if not info[eventName] then
    info[eventName] = {}
  end
  if not info[eventName][subEvent] then
    if _FirstTimeStamp.bFirstIn then
      info[eventName][subEvent] = tostring(_FirstTimeStamp.TimeStamp)
    else
      info[eventName][subEvent] = tostring(TimeUtil.OSTime() - _FirstTimeStamp.TimeStamp)
    end
  else
    local curCount = _LuaStringSplitCount(info[eventName][subEvent], _GameSeparatorSymbol)
    if curCount >= _CachedOneLimitNum then
      return
    end
    info[eventName][subEvent] = info[eventName][subEvent] .. _GameSeparatorSymbol .. tostring(TimeUtil.OSTime() - _FirstTimeStamp.TimeStamp)
  end
  PlayerPrefsSystem.SaveTableToFile_N(info, PlayerPrefsSystem.ePlayerPrefsType.eGEMReissue)
end
function gem_report_utils.ReportEventDelay(eventName, subEvent, ...)
  local nRet = gem_report_utils.CanReport()
  if nRet == -1 then
    log_error("gem_report_utils.ReportEventDelay in Battle eventName = " .. eventName .. ", subEvent = " .. subEvent)
    return
  elseif nRet == -2 then
    log(bWriteLog and "gem_report_utils.ReportEventDelay in main city eventName = " .. eventName .. ", subEvent = " .. subEvent)
    return
  end
  local Params = table.pack(...)
  xpcall(function()
    gem_report_utils.SaveGemReportInFile(eventName, subEvent, table.unpack(Params))
  end, require("common.utility").ErrorMessageHandler)
end
function gem_report_utils.ReportEventDelayInBattle(eventName, subEvent, ...)
  if gem_report_utils.CanReport() ~= 0 then
    local GemReportItem = {}
    GemReportItem.EventName = eventName
    GemReportItem.SubEvent = subEvent
    GemReportItem.Params = table.pack(...)
    table.insert(_InBattleGemReportCache, #_InBattleGemReportCache + 1, GemReportItem)
  else
    gem_report_utils.ReportEventDelay(eventName, subEvent, ...)
  end
end
function gem_report_utils.ReissueSendCachedGEMReport()
  _IsReciveOneGemInfo = false
  _SendFileGEMReport()
end
return gem_report_utils