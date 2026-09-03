local MatchSystem = {
  bShowNewGuide = false,
  nMatchStatus = 2,
  nMatchingTime = 0,
  nEstimateTime = 0,
  matchingTimer = nil,
  matchingFightTimer = nil,
  nLastMiliseconds = 0,
  nMatchBeginTime = 0,
  nTryReEnterGameTime = 0,
  matchLanguageData = nil,
  waitLine = {},
  nMinLineSpeed = 0,
  nMaxLineSpeed = 0,
  nCrossMaxPing = 500,
  matchZoneList = nil,
  nSwitchServerTime = 0,
  bIsSwitchServerShowed = false,
  bSwitchServerSuccess = false,
  bShowMatchTimeoutNotice = false,
  bShowPromotionTimeoutNotice = false,
  dsVersionInfo = nil,
  clientVersionInfo = nil,
  nMatchBanStatus = 0,
  bIsQueryPlayState = false,
  bShowGuideMatchTips = false,
  bKrJpRematch = false,
  bShowCrossNotice = false,
  bJRForceMatch = true,
  sameLanguageMatchTimeOut = false,
  ShowProgress = false,
  is_sync_match_process = false,
  nCurrentProgress = 0,
  nTotalProgress = 0,
  sync_interval = 0,
  will_success = false,
  teammate_cnt = 0,
  process_detail = {},
  team_rating = 0
}
local E_MatchStatus = ENUM_MatchStatus
local E_MatchBanStatus = {
  None = 0,
  Ban = 1,
  LeftTheBan = 2
}
local C_MatchTimeoutSecond = 120
local C_MatchPromotionTimeoutSecond = 60
local C_TryReEnterGameTimeout = 5
local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
function MatchSystem.OnLogin(bReLogin)
  log(bWriteLog and "MatchSystem.OnLogin bReLogin = " .. tostring(bReLogin))
  if bReLogin then
    MatchSystem.QueryPlayerState(true)
  end
  MatchSystem.GetDsVersion()
  MatchSystem.isConnecting = true
end
function MatchSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "[logic_match] MatchSystem.OnModePostSwitch, nextState = " .. tostring(nextState))
  if not GameStatus.IsInLobbyOrMainCity() then
    if nextState == GameStatus.Login then
      MatchSystem.ResetData()
      MatchSystem.ClearDsVersionInfo()
    end
  else
    if MatchSystem.bShowCrossNotice then
      MatchSystem.bShowCrossNotice = false
      ShowNotice(42938)
    end
    MatchSystem.bKrJpRematch = false
  end
end
function MatchSystem.InitOnlyOne()
  EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, MatchSystem.OnApplicationReactivated)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, MatchSystem.HandleAfterLoadingFinish)
end
function MatchSystem.InitData()
  MatchSystem.bShowWeakGuide = DataMgr.roleData.level <= 3 and not DataMgr.team_up_has_weak_guide
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.Init()
end
function MatchSystem.ResetData()
  MatchSystem.nMatchStatus = E_MatchStatus.Not
  MatchSystem.matchLanguageData = nil
  MatchSystem.waitLine = {}
  MatchSystem.bIsSwitchServerShowed = MatchSystem.nSwitchServerTime and MatchSystem.nSwitchServerTime <= 0 or false
  MatchSystem.bSwitchServerSuccess = false
  MatchSystem.nMinLineSpeed = 0
  MatchSystem.nMaxLineSpeed = 0
  if MatchSystem.nMatchingTime ~= 0 then
    MatchSystem.nLastTimeMatchingTime = MatchSystem.nMatchingTime
  end
  MatchSystem.nMatchingTime = 0
  MatchSystem.bShowMatchTimeoutNotice = false
  MatchSystem.bShowPromotionTimeoutNotice = false
  MatchSystem.StopMatchingTimer()
  MatchSystem.SetSameLanguageMatchTimeOut(false)
end
function MatchSystem.QueryPlayerState(isRightNow)
  log(bWriteLog and "MatchSystem.QueryPlayerState isRightNow = " .. tostring(isRightNow))
  if isRightNow then
    MatchSystem.nTryReEnterGameTime = 0
  end
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_query_player_state_req()
end
function MatchSystem.OnQueryPlayerStateRsp(state_info)
  log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp")
  if state_info then
    local game_info = state_info.game_info
    local watch_info = state_info.watch_info
    if game_info or watch_info then
      if game_info then
        log_warning("[logic_match] MatchSystem.OnQueryPlayerStateRsp, in gaming, reEnter?!")
      end
      if watch_info then
        log_warning("[logic_match] MatchSystem.OnQueryPlayerStateRsp, in watching game, reEnter?!")
      end
      local bMaincityGameInfo = false
      if game_info and game_info.sub_mode == 26000 then
        bMaincityGameInfo = true
      else
        LobbySystem.ResetMatchInfo()
        MatchSystem.MatchCancel()
      end
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      local IsInXmission = LogicTxMissionMain.IsInXMission()
      log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp IsInXmission = " .. tostring(IsInXmission) .. " bMaincityGameInfo = " .. tostring(bMaincityGameInfo))
      if GameStatus.GetGameStatus() == GameStatus.Lobby or not bMaincityGameInfo then
        log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp is in lobby state with game_info")
        local TimeUtil = require("client.common.time_util")
        local now = TimeUtil.GetServerTimeInSec()
        if now - MatchSystem.nTryReEnterGameTime > C_TryReEnterGameTimeout then
          log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp, try re enter game")
          MatchSystem.nTryReEnterGameTime = now
          local MatchHandler = require("client.network.Protocol.MatchHandler")
          MatchHandler.send_try_re_enter_game()
        else
          log(bWriteLog and "[logic_match] MatchSystem.OnQueryPlayerStateRsp, is too Frequency try re enter game")
        end
      elseif GameStatus.IsInLobbyOrMainCity() then
        log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp is IsInLobbyOrMainCity with game_info")
        if bMaincityGameInfo then
          EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_WITH_GAME_INFO)
        end
      end
      return
    else
      local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
      logic_enter_game.PendingReEnterInfo = nil
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      if GameStatus.GetGameStatus() == GameStatus.Lobby then
        log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp is in lobby state with no game_info")
      elseif LogicTxMissionMain.IsInXMission() then
        log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp is in tplan with no game_info")
      elseif GameStatus.IsInLobbyOrMainCity() then
        log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp is in main city state with no game_info")
        if slua_GameFrontendHUD and slua_GameFrontendHUD.UnrealNetworkStatus then
          log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp 1 UnrealNetworkStatus = " .. tostring(slua_GameFrontendHUD.UnrealNetworkStatus))
          slua_GameFrontendHUD.UnrealNetworkStatus = "Offline"
          log(bWriteLog and "MatchSystem.OnQueryPlayerStateRsp 2 UnrealNetworkStatus = " .. tostring(slua_GameFrontendHUD.UnrealNetworkStatus))
        end
        LobbySystem.SetWaitingBattleFlag(false)
        EventSystem:postEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_WITHOUT_GAME_INFO)
      end
    end
    local match_info = state_info.match_info
    if match_info then
      log(bWriteLog and "[logic_match] MatchSystem.OnQueryPlayerStateRsp, ----receive reconnect match info ----")
      LobbySystem.isInMatch = true
      local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
      if match_info.match_mode and match_info.match_mode ~= 26000 then
        MatchModeMgrSystem.nSelectMatchID = match_info.match_mode
      end
      MatchModeMgrSystem.bAutoMatch = match_info.fill and match_info.fill == 1 or false
      MatchSystem.nMatchBeginTime = match_info.begin_time
      MatchSystem.CheckWaitingState(match_info.predictive_time, match_info.match_langs, match_info.line_pos, match_info.line_speed)
      MatchSystem.ResetWhenReconnected(true)
      EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_SYNC_MATCH_INFO)
      return
    end
  end
  log(bWriteLog and "[logic_match] MatchSystem.OnQueryPlayerStateRsp, ----player does not have match nextState----")
  LobbySystem.ResetMatchInfo()
  MatchSystem.MatchCancel()
end
function MatchSystem.StartMatch(estimateTime, matchLang, linePos, lineSpeed, ext_info)
  log(bWriteLog and "MatchSystem.StartMatch")
  MatchSystem.nMatchStatus = E_MatchStatus.Matching
  MatchSystem.nMatchingTime = 0
  ext_info = ext_info or {}
  MatchSystem.is_sync_match_process = ext_info.is_sync_match_process
  MatchSystem.team_rating = ext_info.team_rating or 0
  if Client.IsDevelopment() then
    log(bWriteLog and "[logic_match] MatchSystem.CheckWaitingState, IsDevelopment")
    if MatchSystem.isTest then
      estimateTime = MatchSystem.nEstimateTime
      MatchSystem.is_sync_match_process = true
      log_format(bWriteLog and "[logic_match] MatchSystem.CheckWaitingState, IsDevelopment estimateTime = %s", estimateTime)
    end
  end
  MatchSystem.CheckWaitingState(estimateTime, matchLang, linePos, lineSpeed)
  MatchSystem.StartMatchingTimer()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS)
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, E_MatchStatus.Matching)
end
function MatchSystem.CheckWaitingState(estimateTime, matchLang, linePos, lineSpeed)
  log(bWriteLog and "[logic_match] MatchSystem.CheckWaitingState, linePos =" .. tostring(linePos) .. ", lineSpeed = " .. tostring(lineSpeed))
  MatchSystem.nEstimateTime = estimateTime or 0
  log(bWriteLog and "[logic_match] MatchSystem.CheckWaitingState, estimateTime = " .. MatchSystem.nEstimateTime)
  if matchLang and next(matchLang) then
    MatchSystem.matchLanguageData = matchLang
  end
  MatchSystem.waitLine.nPos = linePos or 0
  MatchSystem.waitLine.nSpeed = lineSpeed or 0
  if linePos and 0 < linePos and lineSpeed then
    local range = math.ceil(lineSpeed / 10)
    MatchSystem.nMinLineSpeed = lineSpeed - range < 0 and 0 or lineSpeed - range
    MatchSystem.nMaxLineSpeed = lineSpeed + range < 0 and 0 or lineSpeed + range
  end
end
function MatchSystem.StartMatchingTimer()
  log(bWriteLog and "MatchSystem.StartMatchingTimer")
  local LogicMatchEntry = require("client.slua.logic.lobby.Mid.logic_match_entry")
  MatchSystem.StopMatchingTimer()
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  local matchTimeTick = function()
    MatchSystem.nMatchingTime = MatchSystem.nMatchingTime + 1
    if MatchSystem.waitLine.nPos and MatchSystem.waitLine.nPos >= 0 then
      MatchSystem.waitLine.nPos = MatchSystem.waitLine.nPos - math.random(MatchSystem.nMinLineSpeed, MatchSystem.nMaxLineSpeed)
    end
    LogicMatchEntry.DummyTeammateMatchNum()
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_TIME)
    if logic_promotion_mode:IsOpenPromotion() and not MatchSystem.bShowPromotionTimeoutNotice and MatchSystem.nMatchingTime > C_MatchPromotionTimeoutSecond then
      MatchSystem.bShowPromotionTimeoutNotice = true
      ShowNotice(85372)
    end
  end
  local TimeUtil = require("client.common.time_util")
  local time_ticker = require("common.time_ticker")
  if GameStatus.IsInLobbyOrMainCity() then
    if MatchSystem.matchingTimer then
      time_ticker.RemoveTimer(MatchSystem.matchingTimer)
    end
    MatchSystem.matchingTimer = time_ticker.AddTimerLoop(1, function()
      matchTimeTick()
    end, TIMER_INFINITE, 1)
  else
    MatchSystem.nLastMiliseconds = 0
    if MatchSystem.matchingFightTimer then
      time_ticker.RemoveTimer(MatchSystem.matchingFightTimer)
    end
    MatchSystem.matchingFightTimer = time_ticker.AddTimerLoop(1, function()
      local now = TimeUtil.GetMiliseconds()
      if now - MatchSystem.nLastMiliseconds >= 900 then
        MatchSystem.nLastMiliseconds = now
        matchTimeTick()
      end
    end, TIMER_INFINITE, 1)
  end
end
function MatchSystem.StopMatchingTimer()
  log(bWriteLog and "MatchSystem.StopMatchingTimer")
  if MatchSystem.matchingTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(MatchSystem.matchingTimer)
  end
  if MatchSystem.matchingFightTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(MatchSystem.matchingFightTimer)
  end
  MatchSystem.matchingTimer = nil
  MatchSystem.matchingFightTimer = nil
end
function MatchSystem.MatchSuccess()
  MatchSystem.ResetData()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS)
  if MatchSystem.bShowMatchTimeoutNotice then
    MatchSystem.bShowMatchTimeoutNotice = false
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.HidePanel()
  end
  if MatchSystem.bShowPromotionTimeoutNotice then
    MatchSystem.bShowPromotionTimeoutNotice = false
  end
end
function MatchSystem.MatchSocialIslandSuccess()
  MatchSystem.ResetData()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS)
end
function MatchSystem.MatchCancel()
  MatchSystem.ResetData()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS)
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, E_MatchStatus.Not)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.bIsMatchingSocialIsland = false
end
function MatchSystem.SetCrossMatchParam(cross_time, cross_max_ping, zoneList, jpkrTable)
  log(bWriteLog and "[logic_match] MatchSystem.SetMatchParam, cross_time:" .. tostring(cross_time) .. " cross_max_ping:" .. tostring(cross_max_ping))
  if cross_max_ping and 0 < cross_max_ping then
    MatchSystem.nCrossMaxPing = cross_max_ping
  end
  MatchSystem.matchZoneList = zoneList
  local isJapanOrKorea = GlobalData.IsJapanOrKorea()
  if isJapanOrKorea then
    MatchSystem.SetCrossMatchParamByJPKR(jpkrTable)
  else
    MatchSystem.SetCrossMatchParamByZoneList()
  end
  MatchSystem.bIsSwitchServerShowed = not jpkrTable or not jpkrTable.cross_time_to_asia or 0 >= jpkrTable.cross_time_to_asia
end
function MatchSystem.SetCrossMatchParamByZoneList()
  local isJapanOrKorea = GlobalData.IsJapanOrKorea()
  if not isJapanOrKorea then
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    if MatchSystem.matchZoneList and MatchSystem.matchZoneList[ZoneSystem.nChooseZoneID] then
      local zone = MatchSystem.matchZoneList[ZoneSystem.nChooseZoneID]
      MatchSystem.nCrossMaxPing = zone.cross_zone_max_ping
      MatchSystem.nSwitchServerTime = zone.cross_zone_time_s
      log(bWriteLog and "[logic_match] MatchSystem.SetMatchParamByZoneList, ChooseZoneId = " .. ZoneSystem.nChooseZoneID)
    end
  end
end
function MatchSystem.SetCrossMatchParamByJPKR(jpkrTable)
  if jpkrTable then
    MatchSystem.nSwitchServerTime = jpkrTable.cross_time_to_asia
  else
    MatchSystem.nSwitchServerTime = 0
  end
  log(bWriteLog and "[logic_match] MatchSystem.SetMatchParamByJPKR, self.nSwitchServerTime = " .. MatchSystem.nSwitchServerTime)
end
function MatchSystem.GetCrossMatchState()
  if MatchSystem.nSwitchServerTime <= 0 then
    return 0
  end
  if not DataMgr.JPKRMatchServerOn then
    return 0
  end
  local isJapanOrKorea = GlobalData.IsJapanOrKorea()
  if isJapanOrKorea then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      return 1
    else
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      local matchMode = logic_mode_selection:GetCurSelectInfo()
      local history_combat_util = require("client.logic.combat.history.history_combat_util")
      if not history_combat_util.IsClassicRankMode(matchMode) and not history_combat_util.IsMatchMode(matchMode) and not history_combat_util.IsTeamMode(matchMode) and not history_combat_util.IsEntertainmentMode(matchMode) and not history_combat_util.IsPeakGameMode(matchMode) and not history_combat_util.IsUGCMatchMode(matchMode) then
        return 0
      end
      return 1
    end
  else
    return 2
  end
end
function MatchSystem.JPKRMatchServer(isSwitch, isClick)
  log(bWriteLog and "[logic_match] MatchSystem.JPKRMatchServer, isSwitch = " .. tostring(isSwitch) .. ", isClick = " .. tostring(isClick))
  if isSwitch then
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_on_krjp_match_across_zone_req()
  end
  if isClick then
    local TimeUtil = require("client.common.time_util")
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eJPKRMatchServer)
    local isTodayMatched = false
    if saveData and saveData.last_match_time then
      local last_match_time = tonumber(saveData.last_match_time) or 0
      local current_time = TimeUtil.GetServerTimeInSec()
      isTodayMatched = TimeUtil.IsSameDay(last_match_time, current_time)
    end
    if not isTodayMatched then
      local matchInfo = {}
      local current_time = TimeUtil.GetServerTimeInSec()
      matchInfo.last_match_time = current_time
      PlayerPrefsSystem.SaveTableToFile_N(matchInfo, PlayerPrefsSystem.ePlayerPrefsType.eJPKRMatchServer)
    end
  end
end
function MatchSystem.StartCrossMatch()
  local state = MatchSystem.GetCrossMatchState()
  if state == 1 then
    MatchSystem.JPKRMatchServer(true, true)
  elseif state == 2 then
    local zoneList = {}
    local delayList = {}
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    for _, v in pairs(ZoneSystem.chooseZoneList) do
      local delay = Client.GetServerDelay(v.tpingsvr_ip)
      log(bWriteLog and "[logic_match] MatchSystem.StartCrossMatch, zoneid:" .. v.zone_id .. ", delay:" .. delay)
      if delay <= MatchSystem.nCrossMaxPing then
        local minIndex = #delayList + 1
        for index, zoneDelay in pairs(delayList) do
          if zoneDelay > delay then
            minIndex = index
            break
          end
        end
        table.insert(zoneList, minIndex, v.zone_id)
        table.insert(delayList, minIndex, delay)
      end
    end
    local MatchHandler = require("client.network.Protocol.MatchHandler")
    MatchHandler.send_on_match_across_zone_req(zoneList)
  end
  MatchSystem.bSwitchServerSuccess = false
end
function MatchSystem.CancelCrossMatch()
  local state = MatchSystem.GetCrossMatchState()
  if state == 1 then
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_switch_krjp_match_cross(false)
    MatchSystem.JPKRMatchServer(false, true)
  end
end
function MatchSystem.CrossMatchSuccess()
  MatchSystem.bSwitchServerSuccess = true
end
function MatchSystem.ResetWhenReconnected(isInMatch)
  log("[logic_match] MatchSystem.ResetWhenReconnected")
  if isInMatch or LobbySystem.isInMatch then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if LobbySystem.isInMatch and UGCPlayHallRoom:GetRoomInfo() then
      return
    end
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    MatchSystem.nMatchStatus = E_MatchStatus.Matching
    local beginTime = MatchSystem.nMatchBeginTime or 0
    MatchSystem.nMatchingTime = now - beginTime
    log(bWriteLog and "[logic_match] MatchSystem.ResetWhenReconnected, --reset match waiting time when reactive-- now = " .. now .. ", beginTime = " .. beginTime)
    if 0 > MatchSystem.nMatchingTime then
      MatchSystem.nMatchingTime = 0
      log_error("[logic_match] MatchSystem.ResetWhenReconnected time is error!")
      ShowNotice("match error: time is changed by other")
    end
    MatchSystem.StartMatchingTimer()
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS)
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, E_MatchStatus.Matching)
  end
  MatchSystem.isConnecting = true
end
function MatchSystem.OnApplicationReactivated()
  log(bWriteLog and "MatchSystem.OnApplicationReactivated")
  MatchSystem.ResetWhenReconnected()
  if GameStatus.IsInLobbyOrMainCity() then
    MatchSystem.QueryPlayerState()
  end
end
function MatchSystem.IsMatchStrategyOpen()
  return LobbySystem.CheckOpen(94002) and not Client.IsEmulator()
end
function MatchSystem.SendSetPlayerMatchStrategyReq(id, match_type)
  if not MatchSystem.IsMatchStrategyOpen() then
    return
  end
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_set_player_match_strategy_req(id, match_type)
end
function MatchSystem.OnSetPlayerMatchStrategyRsp(match_strategy)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
    LogicTxMissionMatch.SetMatchStrategy(match_strategy)
  else
    DataMgr.MatchStrategy = match_strategy
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SET_MATCH_STRATEGY_RSP)
end
function MatchSystem.ShowMatchTimeoutNotice()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.BLUEHOLE then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local content
  local openSameLangMatch = DataMgr.MatchLanguage and DataMgr.MatchLanguage.only_match or false
  if openSameLangMatch and not MatchSystem.IsSameLanguageMatchTimeOut() then
    content = LocUtil.GetLocalizeResStr(301169)
  else
    content = LocUtil.GetLocalizeResStr(64159)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, content, function()
    log(bWriteLog and "[logic_match] MatchSystem.ShowMatchTimeoutNotice, \231\187\167\231\187\173\231\173\137\229\190\133\229\140\185\233\133\141")
  end, function()
    log(bWriteLog and "[logic_match] MatchSystem.ShowMatchTimeoutNotice, \232\182\133\230\151\182\229\143\150\230\182\136\229\140\185\233\133\141")
    LobbySystem.on_match_cancel_req()
  end)
  MatchSystem.bShowMatchTimeoutNotice = true
end
function MatchSystem.HandleAfterLoadingFinish()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if GameStatus.IsInLobbyOrMainCity() then
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    if XMissionSystem.IsInXMission() then
      MatchSystem.CheckQueryPlayerFlag()
      return
    end
    if MatchModeMgrSystem.IsSocialIslandMode(true) then
      MatchSystem.ResetWhenReconnected()
    end
    MatchSystem.CheckQueryPlayerFlag()
  elseif GameStatus.IsInFightingStatus() then
    if MatchModeMgrSystem.IsSocialIslandMode(true) then
      MatchSystem.ResetWhenReconnected()
    end
    local logic_main_city_reconnect = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_reconnect)
    if logic_main_city_reconnect.EnterGameTimeoutQueryID ~= 0 then
      MatchSystem.CheckQueryPlayerFlag()
    end
  end
end
function MatchSystem.SetQueryPlayerFlag(flag)
  MatchSystem.bIsQueryPlayState = flag
end
function MatchSystem.CheckQueryPlayerFlag()
  log(bWriteLog and "MatchSystem.CheckQueryPlayerFlag")
  if MatchSystem.bIsQueryPlayState then
    MatchSystem.QueryPlayerState()
    MatchSystem.bIsQueryPlayState = false
  end
end
function MatchSystem.GetDsVersion()
  if Client.IsShipping() or globalConfig.IsDirectConnect() then
    return
  end
  local MailHandler = require("client.network.Protocol.MailHandler")
  MailHandler.send_exec("gm_version()")
end
function MatchSystem.SetDsVersion(msg)
  if MatchSystem.dsVersionInfo and MatchSystem.dsVersionInfo.version then
    return
  end
  if not msg or not msg.version then
    return
  end
  MatchSystem.dsVersionInfo = msg
end
function MatchSystem.GetClientVersionInfo(file)
  if not MatchSystem.clientVersionInfo then
    MatchSystem.clientVersionInfo = {}
    local C_VersionInfoKey = {
      ["Mfg. Date : "] = "timeinfo",
      ["Version : "] = "version",
      ["P4 Revision : "] = "p4_revision",
      ["SVN ProjectRevision : "] = "svn_project",
      ["SVN EngineRevision : "] = "svn_engine",
      ["Patch Version : "] = "version"
    }
    local FindStr = function(str)
      local idx
      for k, v in pairs(C_VersionInfoKey) do
        idx = string.find(str, k)
        if idx then
          return idx + string.len(k), v
        end
      end
      return -1, nil
    end
    local StringUtil = require("common.string_util")
    local versionInfoList = StringUtil.Split(file, "\n")
    for _, v in ipairs(versionInfoList) do
      local startIdx, key = FindStr(v)
      if 0 < startIdx then
        MatchSystem.clientVersionInfo[key] = string.sub(v, startIdx)
      end
    end
  end
end
function MatchSystem.CheckDsVersion(callback)
  if IsEditor then
    return true
  end
  if Client.IsShipping() or globalConfig.IsDirectConnect() then
    return true
  end
  if not MatchSystem.dsVersionInfo then
    return true
  end
  require("client.config.pubgm_package")
  require("client.config.pubgm_patch")
  local file = global_patch_make_time
  if string.find(file, "Patch Version : N/A") then
    file = global_package_make_time
  end
  if file == "" then
    return true
  end
  MatchSystem.GetClientVersionInfo(file)
  local title = LocUtil.GetLocalizeResStr(101001)
  local errorStr
  local strList = {}
  for k, v in pairs(MatchSystem.clientVersionInfo) do
    local dsVal = MatchSystem.dsVersionInfo[k]
    if dsVal then
      if k == "p4_revision" then
        if not tonumber(v) then
          errorStr = "\232\142\183\229\143\150\228\184\141\229\136\176\229\174\162\230\136\183\231\171\175P4\231\137\136\230\156\172\229\143\183"
          break
        end
        if not tonumber(dsVal) then
          errorStr = "\232\142\183\229\143\150\228\184\141\229\136\176DS P4\231\137\136\230\156\172\229\143\183"
          break
        end
        if tonumber(dsVal) < tonumber(v) then
          table.insert(strList, string.format("P4\229\143\183\230\152\175%s\n", dsVal))
        end
      elseif k == "svn_project" then
        if not tonumber(v) then
          errorStr = "\232\142\183\229\143\150\228\184\141\229\136\176\229\174\162\230\136\183\231\171\175SVN\231\137\136\230\156\172\229\143\183"
          break
        end
        if not tonumber(dsVal) then
          errorStr = "\232\142\183\229\143\150\228\184\141\229\136\176DS SVN\231\137\136\230\156\172\229\143\183"
          break
        end
        if tonumber(dsVal) < tonumber(v) then
          table.insert(strList, string.format("SVN_Project\229\143\183\230\152\175%s\n", dsVal))
          table.insert(strList, string.format("SVN_Engine\229\143\183\230\152\175%s\n", MatchSystem.dsVersionInfo.svn_engine or ""))
        end
      end
    end
  end
  if errorStr then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, errorStr, function()
      if callback then
        callback()
      end
    end)
    return false
  end
  if 0 < #strList then
    table.insert(strList, 1, "DS\231\137\136\230\156\172\232\191\135\230\151\167\239\188\140\232\175\183\230\179\168\230\132\143\230\155\180\230\150\176\239\188\129\n")
    local val = MatchSystem.dsVersionInfo.version
    if val then
      table.insert(strList, string.format("DS\231\137\136\230\156\172\229\143\183\230\152\175%s\n", val))
    end
    val = MatchSystem.dsVersionInfo.timeinfo
    if val then
      table.insert(strList, string.format("\230\158\132\229\187\186\230\151\182\233\151\180\230\152\175%s\n", val))
    end
    local tip = table.concat(strList)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, tip, function()
      if callback then
        callback()
      end
    end)
    return false
  end
  return true
end
function MatchSystem.RecordDsVersion()
  if globalConfig.IsDirectConnect() then
    return
  end
  if not MatchSystem.dsVersionInfo then
    return
  end
  local DSVersion = MatchSystem.dsVersionInfo.version or ""
  local DSBuildUrl = MatchSystem.dsVersionInfo.build_url or ""
  local DSBuildNo = MatchSystem.dsVersionInfo.buildno or ""
  Client.AddCrashContextData(1001, DSVersion, false, 1200)
  Client.AddCrashContextData(1002, DSBuildUrl, false, 1200)
  Client.AddCrashContextData(1003, DSBuildNo, false, 1200)
end
function MatchSystem.ClearDsVersionInfo()
  MatchSystem.dsVersionInfo = nil
  MatchSystem.clientVersionInfo = nil
end
function MatchSystem.GetBanInfo()
  if not DataMgr.ban then
    return nil
  end
  if type(DataMgr.ban) ~= "table" then
    return nil
  end
  return DataMgr.ban[BanMacro.PLAYER_BAN_LOW_PRIORITY_MATCH]
end
function MatchSystem.IsMatchInBanList()
  local banInfo = MatchSystem.GetBanInfo()
  if not banInfo then
    return false
  end
  local expireTime = banInfo.end_time
  if not expireTime then
    log(bWriteLog and "[logic_match] MatchSystem.IsMatchInBlackList no ban expireTime")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if expireTime > now then
    log(bWriteLog and "[logic_match] MatchSystem.IsMatchInBlackList ban expireTime = " .. expireTime)
    return true
  end
  return false
end
function MatchSystem.GetBanTime()
  local banInfo = MatchSystem.GetBanInfo()
  if not banInfo then
    log(bWriteLog and "[logic_match] MatchSystem.GetBanTime no ban info")
    return nil
  end
  local expireTime = banInfo.end_time
  if not expireTime then
    log(bWriteLog and "[logic_match] MatchSystem.GetBanTime no ban expireTime")
    return nil
  end
  return expireTime
end
local C_OnlyCanMatchIDInBan = 101
function MatchSystem.CanMatchInBan(matchID)
  if MatchSystem.IsMatchInBanList() and matchID ~= C_OnlyCanMatchIDInBan then
    MatchSystem.ShowBanTip(MatchSystem.GetSelectModeBanTip())
    return false
  end
  return true
end
function MatchSystem.CanInviteInBan()
  if MatchSystem.IsMatchInBanList() then
    MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
    return false
  end
  return true
end
function MatchSystem.CanWatchGameInBan()
  if MatchSystem.IsMatchInBanList() then
    local title = LocUtil.GetLocalizeResStr(101001)
    local tip = LocUtil.GetLocalizeResStr(501119)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, tip)
    return false
  end
  return true
end
function MatchSystem.ShowBanTip(banTipStr, okCallback)
  local title = LocUtil.GetLocalizeResStr(101001)
  local urlText = LocUtil.GetLocalizeResStr(10062)
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, banTipStr, okCallback, nil, nil, nil, false, nil, false, nil, false, urlText, LogicCustomerService.HelpshiftShowFAQsWithInfo)
end
function MatchSystem.ShowObserveTips(banTipStr)
  log(bWriteLog and "MatchSystem.ShowObserveTips")
  local title = LocUtil.GetLocalizeResStr(101001)
  local cancalText = LocUtil.GetLocalizeResStr(4004)
  local ShowObserveText = LocUtil.GetLocalizeResStr(31000)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local OpenCustomerService = function()
    local TableUtil = require("common.table_util")
    local text = TableUtil.GetTableValue(31001)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Confirm_Click)
    ShowNotice(text)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(2, function()
      local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
      local str = ""
      if LobbySystem.CheckOpen(BP_ENUM_LOBBY_MATCH_ISOLATE_HELP_SHITE_SWITCH) then
        str = "account_limit_ban_milpunish"
      end
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      local strRegion = Client.GetPublishRegion()
      if strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.FIT then
        LogicCustomerService.HelpshiftShowSingleFAQ("382", str)
      else
        LogicCustomerService.HelpshiftShowFAQsWithInfo(str)
      end
    end)
  end
  local callback = function()
    local extraData = {canOkTime = 5}
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Appeal_Click)
    CommonMsgBoxMgr.Show(2, title, ShowObserveText, OpenCustomerService, nil, nil, nil, extraData)
  end
  CommonMsgBoxMgr.Show(2, title, banTipStr, nil, callback, nil, cancalText)
end
function MatchSystem.ShowNewObserveTips(banTipStr)
  log(bWriteLog and "MatchSystem.ShowNewObserveTips")
  local title = LocUtil.GetLocalizeResStr(101001)
  local cancalText = LocUtil.GetLocalizeResStr(4004)
  local ShowObserveText = LocUtil.GetLocalizeResStr(31000)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local clickAppeallCallback = function()
    local logic_security = require("client.slua.logic.security.logic_security")
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() then
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_BLUEHOLE_Confirm_Click)
      local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
      LogicCustomerService.HelpshiftShowConversionWithInfo()
    else
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Confirm_Click)
      logic_security.JumpAppealURL()
    end
  end
  local callback = function()
    if GameStatus.IsInFightingNotMainCity() then
      UnrealNet.RetrunToLobbyFromDisconnect(false)
    end
    local extraData = {canOkTime = 5}
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Appeal_Click)
    CommonMsgBoxMgr.Show(2, title, ShowObserveText, clickAppeallCallback, nil, nil, nil, extraData)
  end
  CommonMsgBoxMgr.Show(2, title, banTipStr, function()
    if GameStatus.IsInFightingNotMainCity() then
      UnrealNet.RetrunToLobbyFromDisconnect(false)
    end
  end, callback, nil, cancalText)
end
function MatchSystem.ShowVSBanTip(msg, unBanTime, ext_info)
  log(bWriteLog and string.format("MatchSystem.ShowVSBanTip, unBanTime:%s", unBanTime))
  if unBanTime <= 0 then
    log(bWriteLog and string.format("MatchSystem.ShowVSBanTip unBanTime <=  0, unBanTime:%s", unBanTime))
    ShowNotice(msg)
    return
  end
  local strCode = 38850
  if msg == "mode_banned" then
    local TableUtil = require("common.table_util")
    log_tree(bWriteLog and "MatchSystem.ShowVSBanTip DataMgr.ban", DataMgr.ban)
    local configKey = TableUtil.GetTableValue(DataMgr.ban[BanMacro.PLAYER_BAN_VS_TEAM_RANK_PLAY], "reason")
    if configKey then
      strCode = tonumber(configKey)
    end
    if strCode < 10000 then
      strCode = 38850
    end
  end
  log(bWriteLog and string.format("MatchSystem.ShowVSBanTip, strCode:%s", strCode))
  local localResCfg = LocUtil.GetLocalizeResStr(strCode)
  if strCode < 10000 or localResCfg == "" then
    ShowNotice(msg)
    return
  end
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_DHMS(unBanTime - TimeUtil.GetServerTimeInSec())
  local userName = DataMgr.roleData.nickName or ""
  local userUid = DataMgr.roleData.uid or ""
  local banTipStr = LocUtil.LocalizeFormatConcatenation(strCode, userName, userUid, timeStr)
  if banTipStr == "" then
    log(bWriteLog and string.format("MatchSystem.ShowVSBanTip banTipStr is empty, banTipStr:%s", banTipStr))
    ShowNotice(msg)
    return
  end
  local tlog_id
  if msg == "mode_banned" then
    tlog_id = TLogEventDefine.Ban_VS_BusinessSecurity_Click
  elseif msg == "match_isolation_label_vs_rank_banned" then
    tlog_id = TLogEventDefine.Ban_VS_ProjectSecurity_Click
  end
  MatchSystem.ShowBanTipsCommonMsgBox(msg, ext_info, banTipStr, tlog_id)
end
function MatchSystem.ShowBanTipsCommonMsgBox(msg, ext_info, banTipStr, tlog_id)
  local title = LocUtil.GetLocalizeResStr(101001)
  local cancalText = LocUtil.GetLocalizeResStr(4004)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if ext_info and ext_info.appeal_link_switch then
    CommonMsgBoxMgr.Show(3, title, banTipStr, function()
      MatchSystem.ClickAppealLink(tlog_id)
    end, nil, cancalText)
  else
    CommonMsgBoxMgr.Show(4, title, banTipStr, nil, function()
      MatchSystem.OpenCustomerService(msg, tlog_id)
    end, nil, cancalText)
  end
end
function MatchSystem.OpenCustomerService(msg, tlog_id)
  local helpShiftStr = ""
  if msg == "mode_banned" then
    log(bWriteLog and "OpenCustomerService, mode_banned")
    helpShiftStr = "account_limit_ban_vsidip"
  elseif msg == "match_isolation_label_vs_rank_banned" then
    log(bWriteLog and "OpenCustomerService, match_isolation_label_vs_rank_banned")
    helpShiftStr = "account_limit_ban_vsmil"
  end
  MatchSystem.ReportTlogImmediate(tlog_id)
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.FIT then
    LogicCustomerService.HelpshiftShowSingleFAQ("413", helpShiftStr)
  else
    LogicCustomerService.HelpshiftShowFAQsWithInfo(helpShiftStr)
  end
end
function MatchSystem.ClickAppealLink(tlog_id)
  MatchSystem.ReportTlogImmediate(tlog_id)
  local logic_security = require("client.slua.logic.security.logic_security")
  logic_security.JumpAppealURL()
end
function MatchSystem.ReportTlogImmediate(tlog_id)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(tlog_id)
end
function MatchSystem.ShowDragonBallBanTip(msg, reason, unBanTime, ext_info)
  if not (unBanTime and not (unBanTime <= 0) and reason) or reason == "" then
    ShowNotice(msg)
    return
  end
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_DHMS(unBanTime - TimeUtil.GetServerTimeInSec())
  local tips = string.gsub(reason, "{%d}", timeStr)
  local tlog_id = TLogEventDefine.Ban_DragonBall_Click
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  if logic_ugc_mode:IsSelectUgcMode() then
    tlog_id = TLogEventDefine.UGC_Click_BanAppeal
  end
  MatchSystem.ShowBanTipsCommonMsgBox(msg, ext_info, tips, tlog_id)
end
function MatchSystem.SetMatchBanStatus()
  MatchSystem.nMatchBanStatus = E_MatchBanStatus.Ban
end
function MatchSystem.SetMatchBanCancelStatus()
  MatchSystem.nMatchBanStatus = E_MatchBanStatus.LeftTheBan
end
function MatchSystem.ShouldSlapBanTip()
  if MatchSystem.nMatchBanStatus == E_MatchBanStatus.Ban then
    return true
  end
  if MatchSystem.nMatchBanStatus == E_MatchBanStatus.LeftTheBan then
    return true
  end
  return false
end
function MatchSystem.ShowFaceSlapBanTip()
  if MatchSystem.nMatchBanStatus == E_MatchBanStatus.Ban then
    MatchSystem.nMatchBanStatus = E_MatchStatus.None
    MatchSystem.ShowBanTip(MatchSystem.GetMatchBanTip())
  elseif MatchSystem.nMatchBanStatus == E_MatchBanStatus.LeftTheBan then
    MatchSystem.nMatchBanStatus = E_MatchStatus.None
    local title = LocUtil.GetLocalizeResStr(101001)
    local tip = LocUtil.GetLocalizeResStr(10053)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, tip)
  end
end
function MatchSystem.OnMatchBanCancelNotify()
  if MatchSystem.IsMatchInBanList() then
    local title = LocUtil.GetLocalizeResStr(101001)
    local tip = LocUtil.GetLocalizeResStr(10053)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, tip)
    DataMgr.ban[BanMacro.PLAYER_BAN_LOW_PRIORITY_MATCH] = nil
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS)
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, E_MatchStatus.Not)
  else
    MatchSystem.SetMatchBanCancelStatus()
  end
end
function MatchSystem.GetBanTip(localizeID)
  local TimeUtil = require("client.common.time_util")
  local timeStr = ""
  local banTime = MatchSystem.GetBanTime()
  if banTime then
    timeStr = TimeUtil.FormatTime_YMDHMS(banTime, true)
    timeStr = LocUtil.LocalizeResFormat(localizeID, timeStr)
  else
    timeStr = LocUtil.LocalizeResFormat(localizeID, timeStr)
  end
  return timeStr
end
function MatchSystem.GetMatchBanTip()
  return MatchSystem.GetBanTip(10051)
end
function MatchSystem.GetTeamUpBanTip()
  return MatchSystem.GetBanTip(10054)
end
function MatchSystem.GetSelectModeBanTip()
  return MatchSystem.GetBanTip(10052)
end
function MatchSystem.GotoServerSetting()
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  SettingUtil.Enter("Account")
end
function MatchSystem.OpenServerChooseUI()
  UIManager.ShowUI(UIManager.UI_Config.Setting_ChangeServer)
end
function MatchSystem.GetRemainChangeServerCdTime()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  if ZoneSystem.nNextChooseZoneTime > 0 then
    local TimeUtil = require("client.common.time_util")
    return ZoneSystem.nNextChooseZoneTime - TimeUtil.GetServerTimeInSec()
  else
    return 0
  end
end
function MatchSystem.ShowMatchOptionView(from)
  UIManager.ShowUI(UIManager.UI_Config.match_mode_option_t_plan, from)
end
function MatchSystem.on_lang_match_close_notify(wait_time)
  MatchSystem.SetSameLanguageMatchTimeOut(true)
  local cfg = CDataTable.GetTableData("IntlSystemConfig", "DynamicLanguageMatchTime")
  local sameLanguageMatchTime = cfg and cfg.ConfigValue or 0
  ShowNotice(LocUtil.LocalizeResFormat(64163, sameLanguageMatchTime))
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_SAME_LANGUAGE_MATCH_TIMEOUT)
end
function MatchSystem.SetSameLanguageMatchTimeOut(isTimeOut)
  MatchSystem.sameLanguageMatchTimeOut = isTimeOut
end
function MatchSystem.IsSameLanguageMatchTimeOut()
  return MatchSystem.sameLanguageMatchTimeOut
end
function MatchSystem.SetJRForceMatch(ext_info)
  log_tree(bWriteLog and "MatchSystem.SetJRForceMatch ext_info", ext_info)
  if ext_info and ext_info.krjp_close_force_rematch and ext_info.krjp_close_force_rematch == 1 then
    MatchSystem.bJRForceMatch = false
  else
    MatchSystem.bJRForceMatch = true
  end
end
function MatchSystem.on_sync_match_process(sync_interval, cur_player_cnt, max_player_cnt, will_success, teammate_cnt, process_detail)
  log(bWriteLog and string.format("MatchSystem.on_sync_match_process1  MatchSystem.isTest = %s", MatchSystem.isTest))
  if Client.IsDevelopment() and MatchSystem.isTest then
    return
  end
  if process_detail and next(process_detail) then
    MatchSystem.  end
  log(bWriteLog and "MatchSystem.on_sync_match_process2 set data")
  MatchSystem.nCurrentProgress = cur_player_cnt or 0
  MatchSystem.nTotalProgress = max_player_cnt or 0
  MatchSystem.sync_interval = sync_interval or 0
  MatchSystem.  MatchSystem.teammate_cnt = teammate_cnt or 0
  MatchSystem.ShowProgress = true
end
function MatchSystem.ClearSyncMatchInfo()
  log(bWriteLog and "MatchSystem.ClearSyncMatchInfo")
  if Client.IsDevelopment() and MatchSystem.isTest then
    return
  end
  MatchSystem.ShowProgress = false
  MatchSystem.is_sync_match_process = false
  MatchSystem.will_success = false
  MatchSystem.nCurrentProgress = 0
  MatchSystem.nTotalProgress = 0
  MatchSystem.sync_interval = 0
  MatchSystem.teammate_cnt = 0
  MatchSystem.process_detail = {}
end
function MatchSystem.OnServerError()
  log(bWriteLog and "MatchSystem.OnServerError")
  MatchSystem.isConnecting = false
end
return MatchSystem