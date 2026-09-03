local logic_home_loading = {}
local C_ShowJointPurposeSwitchTipsTime = 1
local C_LoadingAnomalyThreshold = 2
local C_LoadingStuckThreshold = 150
local C_LoadingHealthCheckInterval = 5
local TimeUtil = require("client.common.time_util")
function logic_home_loading:OnInitialize()
  self.bHomeSceneLoadedFinish = false
  self.bWaitingSceneLoaingFinish = false
  self.bHomeLoadingTimeOut = false
  self.lastLoadingFinishTime = nil
  self.lastLoadingState = nil
  self.lastLoadingGameStatus = nil
  self.currentLoadingStartTime = nil
  self.currentLoadingSnapshot = nil
  self.healthCheckTimerHandle = nil
  self.healthCheckCount = 0
  self.hasReportedStuck = false
  self.bReadyToCheckLoadingStuck = false
end
function logic_home_loading:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, self.OnLoadingBegin, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, self.OnLoadingFinish, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ENTER_GAME_BEGIN, self.OnEnterGameBegin, self)
end
function logic_home_loading:ReadyToCheckLoadingStuck()
  log(bWriteLog and "logic_home_loading:ReadyToCheckLoadingStuck")
  self.bReadyToCheckLoadingStuck = true
end
function logic_home_loading:OnEnterGameBegin()
  print(bWriteLog and "logic_home_loading:OnEnterGameBegin")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if not LoadingSystem.IsShowing() then
    print(bWriteLog and "logic_home_loading:OnEnterGameBegin LoadingSystem is not showing")
    self:_StopLoadingHealthCheck()
    return
  end
  if self.currentLoadingSnapshot then
    self.currentLoadingSnapshot.bIsEnterBattle = true
  end
end
function logic_home_loading:OnLoadingBegin(_, _, toLobby, showLoadingSceneType)
  log(bWriteLog and "logic_home_loading:OnLoadingBegin toLobby = " .. tostring(toLobby) .. " showLoadingSceneType = " .. tostring(showLoadingSceneType))
  if self.lastLoadingFinishTime then
    local currentTime = TimeUtil.GetServerTimeInSecWithFraction()
    local interval = currentTime - self.lastLoadingFinishTime
    if interval < C_LoadingAnomalyThreshold then
      self.currentLoadingSnapshot = self:_CaptureLoadingSnapshot(showLoadingSceneType)
      self:_ReportLoadingAnomaly(interval, true)
    end
  end
  self:SetHomeSceneLoadedFinish(false)
  self:SetWaitingSceneLoaingFinish(false)
  self.currentLoadingStartTime = TimeUtil.GetServerTimeInSecWithFraction()
  self.currentLoadingSnapshot = self:_CaptureLoadingSnapshot(showLoadingSceneType)
  self:_StartLoadingHealthCheck()
end
function logic_home_loading:OnLoadingFinish()
  log(bWriteLog and "logic_home_loading:OnLoadingFinish")
  local serverTime = TimeUtil.GetServerTimeInSecWithFraction()
  self.lastLoadingFinishTime = serverTime
  self.lastLoadingGameStatus = GameStatus.GetGameStatus()
  self:SetHomeSceneLoadedFinish(false)
  self:SetWaitingSceneLoaingFinish(false)
  self:_StopLoadingHealthCheck()
  self.currentLoadingStartTime = nil
end
function logic_home_loading:ShowLoading(state, callback, bAutoClose, bShouldShowSwitchTips)
  log(bWriteLog and "logic_home_loading:ShowLoading state = " .. tostring(state) .. " bAutoClose = " .. tostring(bAutoClose))
  if not self:IsShowing() then
    log(bWriteLog and "logic_home_loading:ShowLoading Start")
    UIManager.ShowUI(UIManager.UI_Config_InGame.PlanPH_Edit_Loading_UIBP, state, callback, bAutoClose, bShouldShowSwitchTips)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_HOME_LOADING_BEGIN)
    log(bWriteLog and "Client.EnableIosStuckWork(GameFrontendHUD, false)")
    Client.EnableIosStuckWork(GameFrontendHUD, false)
    return
  end
  log(bWriteLog and "logic_home_loading:ShowLoading is showing")
end
function logic_home_loading:IsShowing()
  log(bWriteLog and "logic_home_loading:IsShowing")
  if UIManager.UI_Config_InGame.PlanPH_Edit_Loading_UIBP then
    return UIManager.IsUIShow(UIManager.UI_Config_InGame.PlanPH_Edit_Loading_UIBP)
  end
  return true
end
function logic_home_loading:OnLoadingTimeout()
  log(bWriteLog and "logic_home_loading:OnLoadingTimeout")
  local ui = UIManager.GetUI(UIManager.UI_Config.loading)
  if ui then
    self:SetHomeLoadingTimeOut(true)
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.RefreshLoadPercent(1)
  self:BackToLobby()
end
function logic_home_loading:BackToLobby()
  log(bWriteLog and "logic_home_loading:BackToLobby")
  local curStatus = GameStatus.GetGameStatus()
  if GameStatus.IsInLobbyOrMainCity() then
    local strTitle = LocUtil.GetLocalizeResStr(101001)
    local strText = LocUtil.GetLocalizeResStr(117060)
    local strOK = LocUtil.GetLocalizeResStr(45133)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, strTitle, strText, nil, nil, strOK, nil)
  else
    local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
    local bIsPlanPHMode = logic_home_entry:IsPlanPHMode()
    log(bWriteLog and "logic_home_loading:BackToLobby bIsPlanPHMode = " .. tostring(bIsPlanPHMode))
    local BackToLobby = function()
      local back_to_lobby_util = require("client.slua.logic.home.back_to_lobby_util")
      back_to_lobby_util.BackToLobby()
    end
    if bIsPlanPHMode and UIManager.UI_Config_InGame.PlanPH_Common_Popups_MediumSmall_UIBP then
      local config = {
        clickOkCallback = BackToLobby,
        notice = LocUtil.GetLocalizeResStr(117060),
        type = 1,
        androidCallback = BackToLobby
      }
      UIManager.ShowUI(UIManager.UI_Config_InGame.PlanPH_Common_Popups_MediumSmall_UIBP, config)
    else
      local strTitle = LocUtil.GetLocalizeResStr(101001)
      local strText = LocUtil.GetLocalizeResStr(117060)
      local strOK = LocUtil.GetLocalizeResStr(45133)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, strTitle, strText, BackToLobby, nil, strOK, nil, {androidCallback = BackToLobby})
    end
  end
end
function logic_home_loading:SetHomeSceneLoadedFinish(bFinish)
  log(bWriteLog and "logic_home_loading:SetHomeSceneLoadedFinish bFinish = " .. tostring(bFinish))
  self.bHomeSceneLoadedFinish = bFinish
end
function logic_home_loading:GetHomeSceneLoadedFinish()
  log(bWriteLog and "logic_home_loading:GetHomeSceneLoadedFinish self.bHomeSceneLoadedFinish = " .. tostring(self.bHomeSceneLoadedFinish))
  return self.bHomeSceneLoadedFinish
end
function logic_home_loading:SetWaitingSceneLoaingFinish(bWaiting)
  log(bWriteLog and "logic_home_loading:SetWaitingSceneLoaingFinish bWaiting = " .. tostring(bWaiting))
  self.bWaitingSceneLoaingFinish = bWaiting
end
function logic_home_loading:GetWaitingSceneLoaingFinish()
  log(bWriteLog and "logic_home_loading:GetWaitingSceneLoaingFinish self.bWaitingSceneLoaingFinish = " .. tostring(self.bWaitingSceneLoaingFinish))
  return self.bWaitingSceneLoaingFinish
end
function logic_home_loading:SetHomeLoadingTimeOut(bHomeLoadingTimeOut)
  log(bWriteLog and "logic_home_loading:SetHomeLoadingTimeOut self.bHomeLoadingTimeOut = " .. tostring(self.bHomeLoadingTimeOut) .. " bHomeLoadingTimeOut = " .. tostring(bHomeLoadingTimeOut))
  self.end
function logic_home_loading:GetHomeLoadingTimeOut()
  log(bWriteLog and "logic_home_loading:GetHomeLoadingTimeOut self.bHomeLoadingTimeOut = " .. tostring(self.bHomeLoadingTimeOut))
  return self.bHomeLoadingTimeOut
end
function logic_home_loading:_CaptureLoadingSnapshot(showLoadingSceneType)
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local snapshot = {
    showLoadingSceneType = showLoadingSceneType,
    timestamp = TimeUtil.GetServerTimeInSecWithFraction(),
    gameStatus = GameStatus.GetGameStatus(),
    isInLobby = GameStatus.IsInLobbyOrMainCity(),
    isPlanPHMode = PlanPH_GamePlay_Tools.IsPHomeMode(),
    bHomeSceneLoadedFinish = self.bHomeSceneLoadedFinish,
    bWaitingSceneLoaingFinish = self.bWaitingSceneLoaingFinish,
    bHomeLoadingTimeOut = self.bHomeLoadingTimeOut,
    bIsEnterBattle = false
  }
  snapshot.bHomeSceneLoadedFinish = self.bHomeSceneLoadedFinish
  snapshot.bWaitingSceneLoaingFinish = self.bWaitingSceneLoaingFinish
  snapshot.bHomeLoadingTimeOut = self.bHomeLoadingTimeOut
  log_tree("logic_home_loading:_CaptureLoadingSnapshot snapshot:", snapshot)
  return snapshot
end
function logic_home_loading:_StartLoadingHealthCheck()
  log(bWriteLog and "logic_home_loading:_StartLoadingHealthCheck")
  if not self.bReadyToCheckLoadingStuck then
    log(bWriteLog and "logic_home_loading:_StartLoadingHealthCheck not ready to check loading stuck")
    return
  end
  self:_StopLoadingHealthCheck()
  self.healthCheckCount = 0
  self.hasReportedStuck = false
  self.healthCheckTimerHandle = self:AddGameTimer(C_LoadingHealthCheckInterval, true, function()
    self:_OnLoadingHealthCheck()
  end)
end
function logic_home_loading:_StopLoadingHealthCheck()
  if self.healthCheckTimerHandle then
    log(bWriteLog and "logic_home_loading:_StopLoadingHealthCheck")
    self:RemoveGameTimer(self.healthCheckTimerHandle)
    self.healthCheckTimerHandle = nil
  end
end
function logic_home_loading:_OnLoadingHealthCheck()
  self.healthCheckCount = self.healthCheckCount + 1
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if not LoadingSystem.IsShowing() then
    log(bWriteLog and "logic_home_loading:_OnLoadingHealthCheck Loading already closed, stop check")
    self:_StopLoadingHealthCheck()
    return
  end
  if not self.currentLoadingStartTime then
    log_warning("logic_home_loading:_OnLoadingHealthCheck No currentLoadingStartTime, stop check")
    self:_StopLoadingHealthCheck()
    return
  end
  local currentTime = TimeUtil.GetServerTimeInSecWithFraction()
  local duration = currentTime - self.currentLoadingStartTime
  log(bWriteLog and string.format("logic_home_loading:_OnLoadingHealthCheck checkCount:%s duration:%.2f", tostring(self.healthCheckCount), duration))
  if duration >= C_LoadingStuckThreshold and not self.hasReportedStuck then
    log_warning_format("logic_home_loading:_OnLoadingHealthCheck. Loading stuck detected! duration:%.2f threshold:%s state:%s", duration, C_LoadingStuckThreshold, tostring(self.currentLoadingState))
    self:_ReportLoadingAnomaly(duration, false)
    self.hasReportedStuck = true
  end
  if duration >= C_LoadingHealthCheckInterval then
    self:_LogCurrentLoadingState(duration)
  end
end
function logic_home_loading:_ReportLoadingAnomaly(duration, bIsRepeatedLoading)
  log(bWriteLog and string.format("logic_home_loading:_ReportLoadingAnomaly duration:%.2f", duration))
  local currentGameStatus = GameStatus.GetGameStatus()
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local currentIsPlanPHMode = logic_home_entry and logic_home_entry:IsPlanPHMode() or false
  local snapshot = self.currentLoadingSnapshot or {}
  local startGameStatus = snapshot.gameStatus or -1
  local startIsPlanPHMode = snapshot.isPlanPHMode or false
  local showLoadingSceneType = snapshot.showLoadingSceneType or -1
  local reportStr = string.format("%.2f|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", duration, tostring(currentGameStatus), tostring(startGameStatus), tostring(currentIsPlanPHMode and "1" or "0"), tostring(startIsPlanPHMode and "1" or "0"), tostring(showLoadingSceneType), tostring(self.healthCheckCount), tostring(bIsRepeatedLoading and "1" or "0"), tostring(self.bHomeSceneLoadedFinish and "1" or "0"), tostring(self.bWaitingSceneLoaingFinish and "1" or "0"), tostring(self.bHomeLoadingTimeOut and "1" or "0"), tostring(self.currentLoadingSnapshot.bIsEnterBattle and "1" or "0"))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Home_Loading_Anomaly, 0, reportStr, true)
end
function logic_home_loading:_LogCurrentLoadingState(duration)
  local snapshot = self.currentLoadingSnapshot or {}
  local currentGameStatus = GameStatus.GetGameStatus()
  log_warning_format("logic_home_loading:_LogCurrentLoadingState. duration:%.2f showLoadingSceneType:%s gameStatus:%s->%s scene:%s waiting:%s timeout:%s", duration, tostring(snapshot.showLoadingSceneType), tostring(snapshot.gameStatus), tostring(currentGameStatus), tostring(self.bHomeSceneLoadedFinish), tostring(self.bWaitingSceneLoaingFinish), tostring(self.bHomeLoadingTimeOut))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_loading = class(CModuleBase, nil, logic_home_loading)
return Clogic_home_loading