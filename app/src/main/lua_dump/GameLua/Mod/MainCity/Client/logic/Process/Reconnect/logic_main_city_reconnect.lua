local logic_main_city_reconnect = {}
function logic_main_city_reconnect:ctor()
  self.maincity_dsTimeOutRetryTimes = 0
  self.maincity_timeOutRetryTimes = 5
  self.maincityReEnterCheckCount = 0
  self.maincityReEnterCheckCountLimit = 10
  self.maincityReEnterCheckInterval = 2
  self.bInTrySwitchMainCityState = false
  self.sendTryReEnterGameCount = 0
  self.sendTryReEnterGameCountLimit = 1
  self.EnterGameTimeoutQueryID = 0
end
function logic_main_city_reconnect:RegistEvents()
  log(bWriteLog and "logic_main_city_reconnect:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER_LOADING_FINISHI, self.OnEnterMainCity, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.OnLeaveMainCity, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_NETWORK_EXCEPTION, self.OnMainCityNetworkException, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_DS_CONNECTION_ERROR, self.OnMainCityDSConnectionError, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_REENTER_GAME_ERROR, self.OnMainCityReenterGameError, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_WITH_GAME_INFO, self.OnMainCityWithGameInfo, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_WITHOUT_GAME_INFO, self.OnMainCityWithoutGameInfo, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_ENTER_BATTLE_TIMEOUT, self.OnMainCityEnterBattleTimeout, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_MAIN_CITY_CANCEL_RE_ENTER_BATTLE, self.OnMainCityCancelReEnterBattle, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_POST_CLEAR_ACTOR, self.OnPostClearActor, self)
end
function logic_main_city_reconnect:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_main_city_reconnect:OnPostSwitchGameStatus pre = " .. tostring(preState) .. " nextState = " .. tostring(nextState))
  self:_ClearMainCityReconnectTimer()
end
function logic_main_city_reconnect:OnEnterMainCity()
  log(bWriteLog and "logic_main_city_reconnect:OnEnterMainCity")
  self:StartReEnterMainCityCheck()
end
function logic_main_city_reconnect:OnLeaveMainCity()
  log(bWriteLog and "logic_main_city_reconnect:OnLeaveMainCity")
  self:_ClearMainCityReconnectTimer()
end
function logic_main_city_reconnect:OnMainCityNetworkException(_, __, ExceptionType, SubType, ErrorLog, bShouldWait)
  log(bWriteLog and string.format("logic_main_city_reconnect:OnMainCityNetworkException ExceptionType[%s] SubType[%s] ErrorLog[%s] bShouldWait[%s]", tostring(ExceptionType), tostring(SubType), tostring(ErrorLog), tostring(bShouldWait)))
  self:StartDSReconnectCheck(ExceptionType, SubType, ErrorLog, bShouldWait)
end
function logic_main_city_reconnect:OnMainCityDSConnectionError(_, __, nGameID, sReason)
  log(bWriteLog and string.format("logic_main_city_reconnect:OnMainCityDSConnectionError nGameID[%s] sReason[%s] self.maincity_dsTimeOutRetryTimes[%s] g_game_id[%s]", tostring(nGameID), tostring(sReason), tostring(self.maincity_dsTimeOutRetryTimes), tostring(g_game_id)))
  local ExceptionType = tostring(nGameID) .. "_" .. tostring(g_game_id)
  local ErrorMessage = tostring(sReason)
  log(bWriteLog and string.format("logic_main_city_reconnect:OnMainCityDSConnectionError ExceptionType[%s] ErrorMessage[%s]", ExceptionType, ErrorMessage))
  UnrealNet.HandleNetworkExceptionReport("MainCityDSConnectionError", ExceptionType, ErrorMessage)
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local sub_mode = logic_enter_game.sub_mode
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  if not Lobby_Main_City.IsMainCitySubMode(sub_mode) then
    log(bWriteLog and "logic_main_city_reconnect:OnMainCityDSConnectionError 1")
    return
  end
  if g_game_id and nGameID and g_game_id == nGameID then
    log(bWriteLog and "logic_main_city_reconnect:OnMainCityDSConnectionError 2")
    self.maincity_dsTimeOutRetryTimes = 0
    self:_TryEnterMainCity()
  end
end
function logic_main_city_reconnect:OnMainCityReenterGameError()
  log(bWriteLog and "logic_main_city_reconnect:OnMainCityReenterGameError self.maincity_dsTimeOutRetryTimes = " .. tostring(self.maincity_dsTimeOutRetryTimes))
end
function logic_main_city_reconnect:OnMainCityWithGameInfo()
  log(bWriteLog and "logic_main_city_reconnect:OnMainCityWithGameInfo")
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MainCityQueryPlayerState, false) then
    log(bWriteLog and "logic_main_city_reconnect.OnMainCityWithGameInfo limit")
    return
  end
  local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD)
  log(bWriteLog and "logic_main_city_reconnect:OnMainCityWithGameInfo dsState = " .. tostring(dsState))
  if dsState == "Online" or dsState == "RecoverableLost" then
    return
  end
  log(bWriteLog and "logic_main_city_reconnect:OnMainCityWithGameInfo self.sendTryReEnterGameCount = " .. tostring(self.sendTryReEnterGameCount))
  if self.sendTryReEnterGameCount >= self.sendTryReEnterGameCountLimit then
    log(bWriteLog and "logic_main_city_reconnect:OnMainCityWithGameInfo enter new main city")
    self.maincity_dsTimeOutRetryTimes = 0
    self.sendTryReEnterGameCount = 0
    self:_TryEnterMainCity()
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MainCityTryReEnter, false) then
    log(bWriteLog and "main_city_switch_util.OnMainCityWithGameInfo limit")
    return
  end
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_try_re_enter_game()
  self.sendTryReEnterGameCount = self.sendTryReEnterGameCount + 1
end
function logic_main_city_reconnect:OnMainCityWithoutGameInfo()
  log(bWriteLog and "logic_main_city_reconnect:OnMainCityWithoutGameInfo self.maincity_dsTimeOutRetryTimes = " .. tostring(self.maincity_dsTimeOutRetryTimes))
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MainCityQueryPlayerState, false) then
    log(bWriteLog and "logic_main_city_reconnect.OnMainCityWithoutGameInfo limit")
    return
  end
  self.maincity_dsTimeOutRetryTimes = 0
  self:_TryEnterMainCity()
end
function logic_main_city_reconnect:OnMainCityEnterBattleTimeout()
  log(bWriteLog and "logic_main_city_reconnect:OnMainCityEnterBattleTimeout")
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  if not Lobby_Main_City.IsRecentMainCityGameID(g_game_id) and self.EnterGameTimeoutQueryID ~= g_game_id then
    self.EnterGameTimeoutQueryID = g_game_id
  end
end
function logic_main_city_reconnect:OnMainCityCancelReEnterBattle()
  log(bWriteLog and "logic_main_city_reconnect:OnMainCityCancelReEnterBattle")
  self:_TryEnterMainCity()
end
function logic_main_city_reconnect:OnPostClearActor()
  POManager.SetDSVersionStatus(false)
  log(bWriteLog and "logic_main_city_reconnect:OnPostClearActor lastDSVersion = " .. tostring(self.lastDSVersion))
end
function logic_main_city_reconnect:ReStartMainCityReconnectCheck(bRelogin)
  log(bWriteLog and "logic_main_city_reconnect:ReStartMainCityReconnectCheck bRelogin = " .. tostring(bRelogin))
  if bRelogin then
    self:_ClearMainCityReconnectTimer()
    self:StartReEnterMainCityCheck()
  end
end
function logic_main_city_reconnect:StartReEnterMainCityCheck()
  log(bWriteLog and "logic_main_city_reconnect:StartReEnterMainCityCheck")
  local IsInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_main_city_reconnect:StartReEnterMainCityCheck IsInMainCity = " .. tostring(IsInMainCity))
  if not IsInMainCity then
    return
  end
  if self.maincityReEnterCheckTimer then
    return
  end
  local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
  local logic_main_city_heart = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_heart)
  self.maincityReEnterCheckTimer = self:AddTimerLoop(self.maincityReEnterCheckInterval, function()
    if logic_main_city_enter.gm_enter_standalone_maincity then
      log(bWriteLog and "logic_main_city_reconnect:StartReEnterMainCityCheck gm_enter_standalone_maincity")
      return
    end
    if not logic_main_city_heart:GetEanbleHeartCheck() then
      log(bWriteLog and "logic_main_city_reconnect:StartReEnterMainCityCheck GetEanbleHeartCheck return")
      self.maincityReEnterCheckCount = 0
      return
    end
    if not GameStatus.IsInMainCity() then
      log(bWriteLog and "logic_main_city_reconnect:StartReEnterMainCityCheck not in main city")
      self.maincityReEnterCheckCount = 0
      return
    end
    log(bWriteLog and "logic_main_city_reconnect:StartReEnterMainCityCheck LobbySystem.isWaittingEnterBattle = " .. tostring(LobbySystem.isWaittingEnterBattle))
    if LobbySystem.isWaittingEnterBattle then
      self.maincityReEnterCheckCount = 0
      return
    end
    local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD)
    log(bWriteLog and "logic_main_city_reconnect:StartReEnterMainCityCheck dsState = " .. tostring(dsState))
    if dsState == "Connecting" or dsState == "Online" or dsState == "RecoverableLost" then
      self.maincityReEnterCheckCount = 0
      return
    end
    self.maincityReEnterCheckCount = self.maincityReEnterCheckCount + 1
    if self.maincityReEnterCheckCount >= self.maincityReEnterCheckCountLimit then
      self.maincityReEnterCheckCount = 0
      self:_TryEnterMainCity()
    end
  end, TIMER_INFINITE, self.maincityReEnterCheckInterval)
end
function logic_main_city_reconnect:StartDSReconnectCheck(ExceptionType, SubType, ErrorLog, bShouldWait)
  log(bWriteLog and "logic_main_city_reconnect:CheckReconnect ExceptionType = " .. tostring(ExceptionType) .. " SubType = " .. tostring(SubType) .. " ErrorLog = " .. tostring(ErrorLog) .. " bShouldWait = " .. tostring(bShouldWait))
  local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
  if not Lobby_Main_City.IsRecentMainCityGameID(g_game_id) and self.EnterGameTimeoutQueryID ~= g_game_id and (ExceptionType == UnrealNet.NetworkException.ConnectionLost or ExceptionType == UnrealNet.NetworkException.ConnectionTimeout or ExceptionType == UnrealNet.NetworkException.ConnectingTimeout or ExceptionType == UnrealNet.NetworkException.CriticalSocketError) then
    self.EnterGameTimeoutQueryID = g_game_id
  end
  if GameStatus.GetGameStatus() == GameStatus.Lobby then
    log(bWriteLog and "logic_main_city_reconnect:CheckReconnect return Lobby")
    return
  end
  if ExceptionType == "ConnectingTimeout" then
    log(bWriteLog and "logic_main_city_reconnect:CheckReconnect ConnectingTimeout")
    self:_QueryPlayerStateWithLimit()
    local IsInMainCity = GameStatus.IsInMainCity()
    log(bWriteLog and "logic_main_city_reconnect:CheckReconnect ConnectingTimeout IsInMainCity = " .. tostring(IsInMainCity))
    if IsInMainCity then
      local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
      logic_main_city_connect_state:ShowMainCityConnectingTipsUI(656197, 10)
    end
    return
  end
  if ExceptionType == UnrealNet.NetworkException.FailureReceived or ExceptionType == UnrealNet.NetworkException.PendingConnectionFailure then
    log(bWriteLog and "logic_main_city_reconnect:CheckReconnect reset flag")
    LobbySystem.SetWaitingBattleFlag(false)
  end
  log(bWriteLog and "logic_main_city_reconnect:CheckReconnect LobbySystem.isWaittingEnterBattle = " .. tostring(LobbySystem.isWaittingEnterBattle))
  if LobbySystem.isWaittingEnterBattle then
    return
  end
  log(bWriteLog and "logic_main_city_reconnect:CheckReconnect self.bInTrySwitchMainCityState = " .. tostring(self.bInTrySwitchMainCityState))
  if self.bInTrySwitchMainCityState then
    return
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local pendingReEnterInfo = logic_enter_game.PendingReEnterInfo
  log_tree(bWriteLog and "logic_main_city_reconnect:CheckReconnect pendingReEnterInfo = ", pendingReEnterInfo)
  if pendingReEnterInfo then
    log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity return by has pendingReEnterInfo")
    return
  end
  self.maincityReEnterCheckCount = 0
  log(bWriteLog and "logic_main_city_reconnect:CheckReconnect self.maincity_dsTimeOutRetryTimes = " .. tostring(self.maincity_dsTimeOutRetryTimes) .. " self.maincity_timeOutRetryTimes = " .. tostring(self.maincity_timeOutRetryTimes))
  if bShouldWait == true and self.maincity_dsTimeOutRetryTimes < self.maincity_timeOutRetryTimes then
    self.maincity_dsTimeOutRetryTimes = self.maincity_dsTimeOutRetryTimes + 1
    return
  end
  if ExceptionType == "ConnectionTimeout" or ExceptionType == "ConnectionLost" or ExceptionType == "CriticalSocketError" or ExceptionType == UnrealNet.NetworkException.FailureReceived or ExceptionType == UnrealNet.NetworkException.PendingConnectionFailure then
    log(bWriteLog and "logic_main_city_reconnect:CheckReconnect Show Tips")
    local IsInMainCity = GameStatus.IsInMainCity()
    log(bWriteLog and "logic_main_city_reconnect:CheckReconnect IsInMainCity = " .. tostring(IsInMainCity))
    if IsInMainCity then
      local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
      logic_main_city_connect_state:ShowMainCityConnectingTipsUI(656197, 10)
    end
  end
  local UIUtil = require("client.common.ui_util")
  local CurStage = ""
  local gameFrontendHUD = UIUtil.GetGameFrontendHUD()
  if gameFrontendHUD then
    CurStage = gameFrontendHUD:GetClientEnterBattleStage()
  end
  log(bWriteLog and "logic_main_city_reconnect:CheckReconnect CurStage = " .. tostring(CurStage))
  if CurStage == "EnterBattleSuccess" and (ExceptionType == "ConnectionTimeout" or ExceptionType == "ConnectionLongTimeNoReceived" or ExceptionType == "ConnectionLost" or ExceptionType == "CriticalSocketError") then
    log(bWriteLog and "logic_main_city_reconnect:CheckReconnect 1")
    self:_QueryPlayerStateWithLimit()
    return
  end
  self:_TryEnterMainCity()
end
function logic_main_city_reconnect:SetIsInTrySwitchMainCityState(bInTrySwitchMainCityState)
  log(bWriteLog and "logic_main_city_reconnect:SetIsInTrySwitchMainCityState bInTrySwitchMainCityState = " .. tostring(bInTrySwitchMainCityState) .. " self.bInTrySwitchMainCityState = " .. tostring(self.bInTrySwitchMainCityState))
  self.  if self.switchStateTimeoutTimer then
    self:RemoveTimer(self.switchStateTimeoutTimer)
    self.switchStateTimeoutTimer = nil
  end
  if self.bInTrySwitchMainCityState then
    self.switchStateTimeoutTimer = self:AddTimerOnce(2, function()
      log(bWriteLog and "logic_main_city_reconnect:SetIsInTrySwitchMainCityState timeout clear")
      self.bInTrySwitchMainCityState = false
    end)
  end
end
function logic_main_city_reconnect:CheckDSVersion(newDSVersion)
  log(bWriteLog and "logic_main_city_reconnect:CheckDSVersion newDSVersion = " .. tostring(newDSVersion) .. " lastDSVersion = " .. tostring(self.lastDSVersion))
  if self.lastDSVersion and newDSVersion ~= self.lastDSVersion then
    log(bWriteLog and "logic_main_city_reconnect:CheckDSVersion dsVersion ~= lastDSVersion")
    POManager.DestroyAllPersistentObjects()
    POManager.ClearAll()
  end
  self.lastDSVersion = newDSVersion
  POManager.SetDSVersionStatus(true)
end
function logic_main_city_reconnect:_TryEnterMainCity()
  log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity")
  local logic_main_city_enter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_enter)
  if logic_main_city_enter.gm_enter_standalone_maincity then
    log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity gm_enter_standalone_maincity")
    return
  end
  if not GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity not in main city")
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    local bConnectDS = Lobby_Main_City_Enter.bConnectDS
    log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity bConnectDS = " .. tostring(bConnectDS))
    if bConnectDS then
      Lobby_Main_City_Enter.LeaveMainCity(true, false, true)
    end
    return
  end
  log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity LobbySystem.isWaittingEnterBattle = " .. tostring(LobbySystem.isWaittingEnterBattle))
  if LobbySystem.isWaittingEnterBattle then
    return
  end
  local dsState = Client.GetUnrealNetworkStatus(GameFrontendHUD)
  log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity dsState = " .. tostring(dsState))
  if dsState == "Connecting" or dsState == "Online" or dsState == "RecoverableLost" then
    return
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local pendingReEnterInfo = logic_enter_game.PendingReEnterInfo
  log_tree(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity pendingReEnterInfo = ", pendingReEnterInfo)
  if pendingReEnterInfo then
    log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity return by has pendingReEnterInfo")
    return
  end
  local bShowEnterTips = false
  local main_city_switch_util = require("GameLua.Mod.MainCity.Client.logic.Process.Transfer.main_city_switch_util")
  local topUIName = UIManager.GetTopUIName()
  log(bWriteLog and "logic_main_city_reconnect:_TryEnterMainCity topUIName = " .. tostring(topUIName))
  if UIManager.UI_Config.MainCity_Main_UIBP and topUIName == UIManager.UI_Config.MainCity_Main_UIBP.keyName then
    bShowEnterTips = true
  end
  main_city_switch_util.ReqEnterRandomMainCity(false, bShowEnterTips)
end
function logic_main_city_reconnect:_ClearMainCityReconnectTimer()
  log(bWriteLog and "logic_main_city_reconnect:ClearMainCityReconnectTimer")
  if self.maincityReEnterCheckTimer then
    self:RemoveTimer(self.maincityReEnterCheckTimer)
    self.maincityReEnterCheckTimer = nil
  end
end
function logic_main_city_reconnect:_QueryPlayerStateWithLimit()
  log(bWriteLog and "logic_main_city_reconnect:_QueryPlayerStateWithLimit")
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.QueryPlayerState()
  self.maincityReEnterCheckCount = 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_main_city_reconnect)
return CModuleTemplate