local LogicLobbyWatching = {
  IsWatchingPanelEnter = false,
  IsWatchingEnterGame = false,
  NeedWatchingInfo = false,
  IsPCOB = false,
  EnterWowBattleWatchHandle = nil,
  EventHandleIndex = nil,
  EventHandleFunc = nil,
  EnterWowBattleWatchTimeoutHandle = nil,
  watchFriend_ModInfo = nil
}
function LogicLobbyWatching.req_enter_watching(watchFriendUID, isWinForceWatch)
  local bForceWatch = false
  if isWinForceWatch then
    bForceWatch = true
  end
  local LobbyWatchingHandler = require("client.network.Protocol.LobbyWatchingHandler")
  LobbyWatchingHandler.send_enter_battle_watch(tonumber(watchFriendUID), bForceWatch)
end
function LogicLobbyWatching.enter_battle_watch(watchFriendUID, isPlatFormStartUp, needSeqModInfo)
  print(bWriteLog and "LogicLobbyWatching.enter_battle_watch watchFriendUID:" .. tostring(watchFriendUID))
  if watchFriendUID == nil then
    return
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if not MatchSystem.CanWatchGameInBan() then
    return
  end
  if not LogicLobbyWatching.IsLoadedEnterBattleWatchRes(watchFriendUID, isPlatFormStartUp, needSeqModInfo) then
    print(bWriteLog and "LogicLobbyWatching.enter_battle_watch not IsLoadedEnterBattleWatchRes watchUID:" .. watchFriendUID)
    return
  end
  if isPlatFormStartUp and not LogicLobbyWatching.IsWatchingEnterGame then
    LogicLobbyWatching.NeedWatchingInfo = false
  end
  logic_connection_waiting:Show(1)
  LogicLobbyWatching.req_enter_watching(tonumber(watchFriendUID), false)
  LogicLobbyWatching.IsWatchingEnterGame = true
end
function LogicLobbyWatching.IsLoadedEnterBattleWatchRes(watchFriendUID, isPlatFormStartUp, needSeqModInfo)
  if watchFriendUID == nil then
    return false
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(watchFriendUID)
  if status then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local isUGCMode = LogicUGCMatch:IsUGCMode(status.game_sub_mode)
    if isUGCMode then
      local mod_id = status.mod_id
      if type(mod_id) == "number" and 0 < mod_id then
        local bIsLoaded = false
        local NeedShowNotice = true
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        local modInfo = LogicUGC:GetModByAllCache(mod_id)
        if modInfo then
          local TableUtil = require("common.table_util")
          LogicLobbyWatching.watchFriend_ModInfo = TableUtil.FastCopyTable(modInfo)
          local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
          local PufferConst = require("client.slua.logic.download.puffer_const")
          if LogicUGCResManager:GetResState(LogicUGCResManager.DownloaderType.ModCopy, modInfo.pub_mod_meta) == PufferConst.ENUM_DownloadState.Done then
            bIsLoaded = true
          end
          print(bWriteLog and "LogicLobbyWatching.IsLoadedEnterBattleWatchRes mod_id:" .. mod_id .. " bIsLoaded:" .. tostring(bIsLoaded))
        else
          print(bWriteLog and "LogicLobbyWatching.IsLoadedEnterBattleWatchRes modinfo is nil")
          if needSeqModInfo ~= false then
            function LogicLobbyWatching.EnterWowBattleWatchHandle()
              LogicLobbyWatching.enter_battle_watch(watchFriendUID, isPlatFormStartUp, false)
            end
            NeedShowNotice = false
            function LogicLobbyWatching.EventHandleFunc(_, _, ListType, bIsDirty, MetaList, Param, FilterOfflineModList)
              print(bWriteLog and "LogicLobbyWatching:OnNotifyReqModInfoSuccess listType:" .. tostring(ListType))
              local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
              if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.UgcMatch) then
                return
              end
              LogicLobbyWatching.CallEnterWowBattleWatchHandle()
            end
            LogicLobbyWatching.EventHandleIndex = EventSystem:registEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, LogicLobbyWatching.EventHandleFunc)
            print(bWriteLog and "LogicLobbyWatching:IsLoadedEnterBattleWatchRes EventHandleIndex:" .. tostring(LogicLobbyWatching.EventHandleIndex) .. " EventHandleFunc:" .. tostring(LogicLobbyWatching.EventHandleFunc))
            local time_ticker = require("common.time_ticker")
            LogicLobbyWatching.EnterWowBattleWatchTimeoutHandle = time_ticker.AddTimerOnce(8.0, function(...)
              print(bWriteLog and "LogicLobbyWatching:BatchGetModInfo timeout")
              LogicLobbyWatching.CallEnterWowBattleWatchHandle()
            end)
            LogicUGC:BatchGetModInfo({mod_id}, LogicUGC.C_ModListTypes.UgcMatch, function(ModInfo, type)
              print(bWriteLog and "LogicLobbyWatching:BatchGetModInfo CallBack type:" .. tostring(type))
              LogicLobbyWatching.CallEnterWowBattleWatchHandle()
            end, {bForce = true})
          end
        end
        if not bIsLoaded and NeedShowNotice then
          ShowNotice(LocUtil.LocalizeResFormat(8502065, mod_id))
        end
        return bIsLoaded
      end
    end
  end
  return true
end
function LogicLobbyWatching.CallEnterWowBattleWatchHandle()
  local TempEnterWowBattleWatchHandle = LogicLobbyWatching.EnterWowBattleWatchHandle
  print(bWriteLog and "LogicLobbyWatching:CallEnterWowBattleWatchHandle TempEnterWowBattleWatchHandle:" .. tostring(TempEnterWowBattleWatchHandle))
  LogicLobbyWatching.ClearEnterWowBattleWatchInfo()
  if TempEnterWowBattleWatchHandle ~= nil then
    TempEnterWowBattleWatchHandle()
  end
end
function LogicLobbyWatching.ClearEnterWowBattleWatchInfo()
  print(bWriteLog and "LogicLobbyWatching:ClearEnterWowBattleWatchInfo EventHandleIndex:" .. tostring(LogicLobbyWatching.EventHandleIndex) .. " EnterWowBattleWatchTimeoutHandle:" .. tostring(LogicLobbyWatching.EnterWowBattleWatchTimeoutHandle))
  if LogicLobbyWatching.EventHandleFunc ~= nil then
    EventSystem:unregistEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, LogicLobbyWatching.EventHandleFunc)
  end
  if LogicLobbyWatching.EnterWowBattleWatchTimeoutHandle ~= nil then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(LogicLobbyWatching.EnterWowBattleWatchTimeoutHandle)
  end
  LogicLobbyWatching.EventHandleIndex = nil
  LogicLobbyWatching.EventHandleFunc = nil
  LogicLobbyWatching.EnterWowBattleWatchHandle = nil
  LogicLobbyWatching.EnterWowBattleWatchTimeoutHandle = nil
end
function LogicLobbyWatching.ResetWatchingInfo()
  if not LogicLobbyWatching.NeedWatchingInfo then
    return
  end
  if LogicLobbyWatching.IsWatchingEnterGame then
    LogicLobbyWatching.leave_battle_watch()
  end
  LogicLobbyWatching.Release()
end
function LogicLobbyWatching.Release()
  LogicLobbyWatching.ClearEnterWowBattleWatchInfo()
  LogicLobbyWatching.IsWatchingEnterGame = false
  LogicLobbyWatching.watchFriend_ModInfo = nil
  logic_connection_waiting:Hide(1)
end
function LogicLobbyWatching.WatchingEnterGameCheck(enterGameFunc)
  if LogicLobbyWatching.IsWatchingEnterGame then
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    device_module:ClearExtendInfo()
    local titleStr = LocUtil.GetLocalizeResStr(101001)
    local tipsContent = LocUtil.GetLocalizeResStr(501124)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, titleStr, tipsContent, function()
      if LogicLobbyWatching.IsWatchingEnterGame then
        LobbySystem.ShowMatchSuccess()
        enterGameFunc()
      end
    end, LogicLobbyWatching.leave_battle_watch)
  else
    enterGameFunc()
  end
end
function LogicLobbyWatching.leave_battle_watch()
  local LobbyWatchingHandler = require("client.network.Protocol.LobbyWatchingHandler")
  LobbyWatchingHandler.send_leave_battle_watch()
  LogicLobbyWatching.Release()
  local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
  if ClientHawkEyePatrolSubsystem then
    ClientHawkEyePatrolSubsystem:ForceNeverCloseBattleEndedTips()
  end
end
function LogicLobbyWatching.enter_battle_watch_failed(reason, watch_uid, min_segment_rating, min_level, watch_name, last_hawkeye_inspect_time)
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  device_module:ClearExtendInfo()
  LogicLobbyWatching.Release()
  if reason == nil then
    log(bWriteLog and "LogicLobbyWatching.enter_battle_watch_failed reason = nil")
    return
  end
  log(bWriteLog and "LogicLobbyWatching.enter_battle_watch_failed " .. reason)
  if reason == "is_in_team" then
    LogicLobbyWatching.PopTips(501111)
  elseif reason == "is_gameing" then
    LogicLobbyWatching.PopTips(501112)
  elseif reason == "is_watching" then
    LogicLobbyWatching.PopTips(501113)
  elseif reason == "is_matching" then
    LogicLobbyWatching.PopTips(501114)
  elseif reason == "not_in_game" then
    LogicLobbyWatching.PopTips(501115)
  elseif reason == "not_online" then
    LogicLobbyWatching.PopTips(501116)
  elseif reason == "game_over" then
    LogicLobbyWatching.PopTips(501117)
  elseif reason == "version_mismatch" then
    LogicLobbyWatching.PopTips(501118)
  elseif reason == "to_much_watcher" then
    LogicLobbyWatching.PopTips(501123)
  elseif reason == "not_watch_mode" then
    LogicLobbyWatching.PopTips(501127)
  elseif reason == "watch_is_close" then
    LogicLobbyWatching.PopTips(501125)
  elseif reason == "level_not_enough" then
    LogicLobbyWatching.PopTips(501126)
  elseif reason == "not_allow_watch" then
    LogicLobbyWatching.PopTips(501131)
  elseif reason == "is_in_room_game" then
    LogicLobbyWatching.PopTips(501132)
  elseif reason == "corps_war_not_allow_watch" then
    LogicLobbyWatching.PopTips(501133)
  elseif reason == "not_download_map" then
    LogicLobbyWatching.PopTips(501134)
  elseif reason == "is_in_room" then
    LogicLobbyWatching.PopTips(7153)
  elseif reason == "is_in_big_event" then
    LogicLobbyWatching.PopTips(501127)
  elseif reason == "not_friend" then
    LogicLobbyWatching.PopTips(501133)
  elseif reason == "function_limit" then
    LogicLobbyWatching.PopTips(501136)
  elseif reason == "cannot_watch" then
    LogicLobbyWatching.PopTips(501137)
  elseif reason == "cannot_watch_myself" then
    LogicLobbyWatching.PopTips(501138)
  elseif reason == "no_inspected_uid" then
    ShowNotice(36657)
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    webModule:BackLobbyAndOpenWeb()
  elseif reason == "level_or_segment_rating_not_enought" then
    log(bWriteLog and "LogicLobbyWatching.enter_battle_watch_failed min_segment_rating = " .. tostring(min_segment_rating) .. " min_level = " .. tostring(min_level))
    if min_segment_rating and min_level then
      local str = LocUtil.LocalizeResFormat("8061", min_segment_rating, min_level)
      ShowNotice(str)
    end
  elseif reason == "match_isolation_label_banned" then
    log(bWriteLog and "LogicLobbyWatching.enter_battle_watch_failed match_isolation_label_banned name = " .. tostring(watch_name))
    local title = LocUtil.GetLocalizeResStr(101001)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, LocUtil.LocalizeResFormat(32626, watch_name))
  elseif reason == "watcher_match_isolation_label_banned" then
    local title = LocUtil.GetLocalizeResStr(101001)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, LocUtil.GetLocalizeResStr(32625))
  elseif reason == "in_battle_next_hawkeye_patrol_failed" then
    local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
    if ClientHawkEyePatrolSubsystem and ClientHawkEyePatrolSubsystem.ReturnLobbyAndOpenH5 then
      ClientHawkEyePatrolSubsystem:ReturnLobbyAndOpenH5()
    end
  elseif reason == "connect_time_out" and last_hawkeye_inspect_time.is_hawkeye_patrol then
    LogicLobbyWatching.PopEagleErrorWindowAndReturnLobby()
  end
end
function LogicLobbyWatching.PopTips(resID)
  ShowNotice(LocUtil.GetLocalizeResStr(resID))
end
function LogicLobbyWatching.PopEagleErrorWindowAndReturnLobby()
  local status = GameStatus.GetGameStatus()
  log(bWriteLog and "[mxiliu]LogicLobbyWatching.PopEagleErrorWindowAndReturnLobby: GameStatus = " .. status)
  if status == GameStatus.Loading then
    local logic_loading = require("client.slua.logic.loading.logic_loading")
    logic_loading.ShowLoading(false)
    LobbySystem.ReturnToLobby()
  end
  local content = LocUtil.GetLocalizeResStr(119600023)
  local btnOK = LocUtil.GetLocalizeResStr(36669)
  local appealcallback = function()
    log(bWriteLog and "[mxiliu]LogicLobbyWatching.PopEagleErrorWindowAndReturnLobby: appealcallback is click ")
    local LobbyWatchingHandler = require("client.network.Protocol.LobbyWatchingHandler")
    LobbyWatchingHandler.send_begin_hawkeye_inspect_req()
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    webModule:BackLobbyAndOpenWeb()
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, nil, content, appealcallback, nil, btnOK)
end
function LogicLobbyWatching.exit_watch_game(reason, delay_time)
  LogicLobbyWatching.Release()
  if reason == nil then
    BP_WatchExitReason = "game_over"
  else
    print(bWriteLog and "LogicLobbyWatching.exit_watch_game reason = " .. reason)
  end
  BP_WatchExitReason = reason
  BP_WatchExit_DelayTime = delay_time or 0
  print(bWriteLog and "LogicLobbyWatching.exit_watch_game", LuaClassObj.GetGameStatus(bp_global), GameStatus.Fighting)
  BattleResult.IgnoreDSError = true
  BattleResult.ShowingExitWatchGame = true
  if LuaClassObj.GetGameStatus(bp_global) == GameStatus.Fighting then
    WatchGameUI:ExitWatchGame(false)
  end
  local ClientHawkEyePatrolSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
  if ClientHawkEyePatrolSubsystem then
    ClientHawkEyePatrolSubsystem:ForceNeverCloseBattleEndedTips()
  end
end
function LogicLobbyWatching.send_show_watching(watchingFlag)
  local LobbyWatchingHandler = require("client.network.Protocol.LobbyWatchingHandler")
  LobbyWatchingHandler.send_set_watch_switch(watchingFlag)
end
function LogicLobbyWatching.send_show_battle_watching_detail(watchingIngameBaseInfoFlag)
  log(bWriteLog and "watching send_show_battle_watching_detail flag:" .. watchingIngameBaseInfoFlag)
  local LobbyWatchingHandler = require("client.network.Protocol.LobbyWatchingHandler")
  LobbyWatchingHandler.send_set_watch_privacy(watchingIngameBaseInfoFlag)
end
function LogicLobbyWatching.IsWatchingOpenWithMsgBox()
  local cfgLevel = tonumber(DataMgr.GetSystemConfig("BattleWatchNeedLevel"))
  if cfgLevel == nil then
    cfgLevel = 5
  end
  local levelEnough = cfgLevel <= DataMgr.roleData.level
  if not levelEnough then
    LogicLobbyWatching.PopTips(501126)
    return levelEnough
  end
  local isopen = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_WATCHING)
  return levelEnough and isopen
end
function LogicLobbyWatching.IsWatchingBattleBaseInfoSettingOpen()
  return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_WATCHING_BATTLE_BASEINFO)
end
function LogicLobbyWatching.IsWatchingPrivacyOpen()
  return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_WATCHING_PRIVACY)
end
function LogicLobbyWatching.IsWatchingInviteOpen()
  return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_WATCHING_INVITE)
end
function LogicLobbyWatching.IsShowWatcherList()
  local cfgLevel = tonumber(DataMgr.GetSystemConfig("BattleShowWatcherListNeedLevel"))
  if cfgLevel == nil then
    cfgLevel = 5
  end
  local levelEnough = cfgLevel <= DataMgr.roleData.level
  if not levelEnough then
    return levelEnough
  end
  return true
end
function LogicLobbyWatching.IsCanWatchEnemy()
  return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_WATCH_CHAIN)
end
function LogicLobbyWatching.IsWatchingOpen()
  local cfgLevel = tonumber(DataMgr.GetSystemConfig("BattleWatchNeedLevel"))
  if cfgLevel == nil then
    cfgLevel = 5
  end
  local levelEnough = cfgLevel <= DataMgr.roleData.level
  local isOpen = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_WATCHING)
  return levelEnough and isOpen
end
return LogicLobbyWatching