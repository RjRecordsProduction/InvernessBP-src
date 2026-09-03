local main_city_process_util = {}
local ignoreGrayTime = false
function main_city_process_util.CheckEnterMainCityFromFighting()
  log(bWriteLog and "main_city_process_util.CheckEnterMainCityFromFighting")
  if IsWoWEditor then
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local IsInXMission = LogicTxMissionMain.IsInXMission()
  log(bWriteLog and "main_city_process_util.CheckEnterMainCityFromFighting IsInXMission = " .. tostring(IsInXMission))
  if IsInXMission then
    log(bWriteLog and "main_city_process_util.CheckEnterMainCityFromFighting return IsInXMission")
    return false
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bEnterGameFromMainCity = Lobby_Main_City_Enter.bEnterGameFromMainCity
  log(bWriteLog and "main_city_process_util.CheckEnterMainCityFromFighting bEnterGameFromMainCity = " .. tostring(bEnterGameFromMainCity))
  if bEnterGameFromMainCity then
    return true
  end
  local switch = main_city_process_util.GetMainCityEnterSwitch()
  log(bWriteLog and "main_city_process_util.CheckEnterMainCityFromFighting switch = " .. tostring(switch))
  if switch then
    return true
  end
  local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  log(bWriteLog and "main_city_process_util.CheckEnterMainCityFromFighting logic_main_city_enter.enterMainCityMode = " .. tostring(logic_main_city_enter.enterMainCityMode))
  if logic_main_city_enter.enterMainCityMode == main_city_enter_config.EMainCityEnterMode.FightingToMainCity then
    return true
  end
  return false
end
function main_city_process_util.GetMainCityEnterSwitch()
  local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
  local switch = logic_main_city_privacy:GetUserSwitch(1)
  if switch and not main_city_process_util.IsMainCityEntryOpen() then
    log(bWriteLog and "main_city_process_util.GetMainCityEnterSwitch IsMainCityEntryOpen is false")
    switch = false
  end
  if Client.GetMemorySize then
    local memopt = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.mem_opt)
    if not memopt:EnableEnterMainCity() then
      switch = false
    end
  end
  if IsWoWEditor then
    switch = false
  end
  return switch
end
function main_city_process_util.CheckIsPendingAutoEnterMainCity()
  log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity")
  if IsWoWEditor then
    return false
  end
  if main_city_process_util.CheckEnterMainCityFromFighting() then
    log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity 1")
    return true
  end
  local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
  local enterMainCityMode = logic_main_city_enter.enterMainCityMode
  log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity enterMainCityMode = " .. tostring(enterMainCityMode))
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  if enterMainCityMode == main_city_enter_config.EMainCityEnterMode.LoginToMainCity then
    log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity 2")
    return true
  end
  local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
  local bPendingReEnterGame = logic_main_city_connect_state.bPendingReEnterGame
  log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity bPendingReEnterGame = " .. tostring(bPendingReEnterGame))
  if bPendingReEnterGame then
    log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity 3")
    return true
  end
  if enterMainCityMode == main_city_enter_config.EMainCityEnterMode.ReconnectToMainCity then
    log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity 4")
    return true
  end
  log(bWriteLog and "main_city_process_util.CheckIsPendingAutoEnterMainCity 5")
  return false
end
function main_city_process_util.IsMainCityEntryOpen(showTips, skipGrayCheck)
  if IsWoWEditor then
    return false
  end
  if Client and Client.IsDevelopment() and Client.IsWindows() and DataMgr.roleData.uid == "" then
    return true
  end
  if not main_city_process_util.IsEntrySystemOpen(showTips) then
    log_warning(bWriteLog and "main_city_process_util.IsMainCityEntryOpen BP_ENUM_MAIN_CITY_ENTER_MAIN_SWITCH is false")
    return false
  end
  local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
  if not main_city_process_util.IsReachEntryLevelLimit(DataMgr.roleData.level, showTips) then
    log_warning_format("main_city_process_util.IsMainCityEntryOpen is Level limit")
    return false
  end
  if main_city_process_util.IsUIDInEntryWhiteList() then
    log(bWriteLog and "main_city_process_util.IsMainCityEntryOpen IsUIDInEntryWhiteList is true")
    return true
  end
  if not skipGrayCheck and not main_city_process_util.IsReachGraySwitchLimit(showTips) then
    log_warning(bWriteLog and "main_city_process_util.IsMainCityEntryOpen not reach gray switch limit")
    return false
  end
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  local isUGCPlayHall = UGCPlayHallRoom and UGCPlayHallRoom:GetRoomInfo()
  if LobbySystem.isInMatch and not isUGCPlayHall then
    log(bWriteLog and "main_city_process_util.IsMainCityEntryOpen isInMatch")
    if showTips then
      ShowNotice(656092)
    end
    return
  end
  return true
end
function main_city_process_util.IsEntrySystemOpen(showTips)
  local isSysOpen = LobbySystem.CheckOpen(BP_ENUM_MAIN_CITY_ENTRY_SWITCH)
  if not isSysOpen and showTips then
    ShowNotice(73172)
  end
  return isSysOpen
end
function main_city_process_util.IsUIDInEntryWhiteList()
  return LobbySystem.roleData and LobbySystem.roleData.main_city_entry_is_in_white_list
end
function main_city_process_util.GetEntryLimitLevel()
  return LobbySystem.roleData and LobbySystem.roleData.main_city_entry_level_limit or 0
end
function main_city_process_util.IsReachEntryLevelLimit(level, showTips)
  level = level or DataMgr.roleData.level
  local limitLevel = main_city_process_util.GetEntryLimitLevel() or 0
  log(bWriteLog and "main_city_process_util.IsReachEntryLevelLimit level = " .. tostring(level) .. ", limitLevel = " .. tostring(limitLevel))
  local isReachLimit = level >= limitLevel
  if not isReachLimit and showTips then
    ShowNotice(LocUtil.LocalizeResFormat(73173, limitLevel))
  end
  return isReachLimit
end
function main_city_process_util.IsReachGraySwitchLimit(showTips)
  if ignoreGrayTime then
    return true
  end
  local openTime = LobbySystem.roleData and LobbySystem.roleData.main_city_entry_gray_open_time
  if openTime then
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "main_city_process_util.IsReachGraySwitchLimit openTime = " .. openTime .. ", nowTime = " .. nowTime)
    local isReachLimit = openTime <= nowTime
    if isReachLimit then
      return true
    end
  end
  if showTips then
    ShowNotice(73174)
  end
  return false
end
function main_city_process_util.SetIgnoreGrayTime(ignore)
  ignoreGrayTime = ignore
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_MAIN_CITY_REFRESH_ENTRY_SHOW)
end
function main_city_process_util.CanShowMainCityDownloadTheme()
  log(bWriteLog and "main_city_process_util.CanShowMainCityDownloadTheme")
  if not PufferDownloader.PufferJsonDownloadReturn then
    log(bWriteLog and "main_city_process_util.CanShowMainCityDownloadTheme 1")
    return false
  end
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  if Main_City_Download_Tool.IsMainCityMapDownloaded() then
    log(bWriteLog and "main_city_process_util.CanShowMainCityDownloadTheme 2")
    return false
  end
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  if not main_city_process_util.IsMainCityEntryOpen() then
    log(bWriteLog and "main_city_process_util.CanShowMainCityDownloadTheme 3")
    return false
  end
  return true
end
function main_city_process_util.ShowMainCityDownloadTheme()
  log(bWriteLog and "main_city_process_util.ShowMainCityDownloadTheme")
  UIManager.ShowUI(UIManager.UI_Config.MainCity_DownloadGuide_ThemePopup_UIBP)
end
function main_city_process_util.ClientHandleSwitchDS(nGameID)
  log(bWriteLog and string.format("main_city_process_util.ClientHandleSwitchDS nGameID[%s] g_game_id[%s]", tostring(nGameID), tostring(g_game_id)))
  if not g_game_id or not nGameID then
    return
  end
  if g_game_id ~= nGameID then
    return
  end
  if not GameStatus.IsInMainCity() then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    log(bWriteLog and "main_city_process_util.ClientHandleSwitchDS not in maincity bConnectDS = " .. tostring(Lobby_Main_City_Enter.bConnectDS))
    if Lobby_Main_City_Enter.bConnectDS then
      Lobby_Main_City_Enter.LeaveMainCity(true, false, false)
    end
  else
    log(bWriteLog and "main_city_process_util.ClientHandleSwitchDS in maincity")
    local title = LocUtil.GetLocalizeResStr(101001)
    local msg = LocUtil.GetLocalizeResStr(656075)
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    local clickOkCallback = function()
      log(bWriteLog and "main_city_process_util.ClientHandleSwitchDS clickOkCallback")
      local main_city_switch_util = require("GameLua.Mod.MainCity.Client.logic.Process.Transfer.main_city_switch_util")
      main_city_switch_util.ReqEnterRandomMainCity(true, true)
      local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
      logic_main_city_connect_state:SetMainCityReadyChange(true)
    end
    IngameTipsTools.ShowMsgBox(1, title, msg, clickOkCallback)
  end
end
function main_city_process_util.CheckNeedShowEnterSequence()
  local newbie_guide_config = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if not DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, newbie_guide_config.EMainCityGuideID.MAINCITY_SEQUENCE_GUIDE_ID) then
    log(bWriteLog and "main_city_process_util.CheckNeedShowEnterSequence Newbie")
    return true
  end
  local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
  local oldEnterMainCityMode = logic_main_city_enter.enterMainCityMode
  local main_city_enter_config = require("GameLua.Mod.MainCity.Client.logic.Process.Enter.main_city_enter_config")
  if oldEnterMainCityMode == main_city_enter_config.EMainCityEnterMode.LobbyToMainCity then
    log(bWriteLog and "main_city_process_util.CheckNeedShowEnterSequence LobbyToMainCity")
    return false
  end
  if oldEnterMainCityMode == main_city_enter_config.EMainCityEnterMode.MainCityToMainCity then
    log(bWriteLog and "main_city_process_util.CheckNeedShowEnterSequence MainCityToMainCity")
    return false
  end
  local logic_main_city_join = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_main_city_join)
  local mainCityInfo = logic_main_city_join:GetTeamTarget()
  if mainCityInfo then
    log(bWriteLog and "main_city_process_util.CheckNeedShowEnterSequence mainCityInfo")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMainCityEnterSequenceTime) or {}
  local nLastPlayTime = tLocalCache.nLastPlayTime or 0
  local TimeUtil = require("client.common.time_util")
  local currTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "main_city_process_util.CheckNeedShowEnterSequence nLastPlayTime = " .. tostring(nLastPlayTime) .. " currTime = " .. tostring(currTime))
  local gm_enter_maincity_force_play_sequence = logic_main_city_enter.gm_enter_maincity_force_play_sequence
  log(bWriteLog and "main_city_process_util.CheckNeedShowEnterSequence gm_enter_maincity_force_play_sequence = " .. tostring(gm_enter_maincity_force_play_sequence))
  if not gm_enter_maincity_force_play_sequence and currTime - nLastPlayTime < 604800 then
    log(bWriteLog and "main_city_process_util.CheckNeedShowEnterSequence is in 7 days")
    return false
  end
  return true
end
return main_city_process_util