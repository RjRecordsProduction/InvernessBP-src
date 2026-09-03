local BattleResultSubSystem = {}
local utility = require("common.utility")
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local BATTLE_RESULT_DATA_LOGIC = "BattleResultDataLogic"
function BattleResultSubSystem:ctor()
  print(bWriteLog and "[BattleResultSubSystem]ctor", self)
end
function BattleResultSubSystem:OnInit()
  print(bWriteLog and "[BattleResultSubSystem]OnInit", self)
  self.ResusltTest = false
  self.ResusltTestPlayerNum = 4
  self.IsReceivedResultPro = false
  self.CurResultProcessIndex = 0
  self.ResultProcessSuspended = false
  self.ResultToSpectate = true
  self.isTeamResult = false
  self.battleType = nil
  self.ProcessLogicMap = {}
  self.ProcessLogic_Sort = {}
  self.ProcessLogicList = {}
  self.CurProcess = nil
  self:_RegisterProcessLogics()
  self.LeaveSpectating = false
  self.StartAtProcess = -1
  self.BackToLobbyShowLoading = true
  self.DefaultData = {}
  self.bHasEnterProtect = false
  if not self.HasInit then
    self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_WATCH_TO_RESULT, self.OnSpectateToResult, self)
    self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_GAMEOVER_TO_RESULT, self.OnGameOverToResult, self)
    self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_LEAVE_SPECTATING, self.HandleOnLeaveSpectating, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_POST_RECONNECTION_UI, self.OnPostReconnection, self)
    self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactived, self)
    self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, self.OnBackLogin, self)
    self:AddCommonEvent(EVENTTYPE_PCOB, EVENTID_PCOB_TERMINATOREND_BEGIN, self.OBTerminatorBegin, self)
    self:AddCommonEvent(EVENTTYPE_PCOB, EVENTID_PCOB_TERMINATOREND_END, self.OBTerminatorEnd, self)
    self:AddCommonEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_END_CURRENT_PROCESS, self.OnCurProcessEnd, self)
  end
  self.HasInit = true
  self:CheckAndProcessBattleResult()
  if self.ResusltTest then
    local TimeTicker = require("common.time_ticker")
    TimeTicker.AddTimer(5, function()
      self:BattleResultTestProcess()
    end)
  end
  self:PrintSelfInfo()
end
function BattleResultSubSystem:HandleOnLeaveSpectating()
  print(bWriteLog and "BattleResultSubSystem:HandleOnLeaveSpectating")
  self.LeaveSpectating = true
end
function BattleResultSubSystem:OnRelease()
  print(bWriteLog and "[BattleResultSubSystem]OnRelease", self)
  self:_UnRegisterProcessLogics()
  self.CurProcess = nil
  self.ProcessLogicMap = {}
  self.ProcessLogic_Sort = {}
  self.ProcessLogicList = {}
  self.HasInit = false
  self.CurResultProcessIndex = 0
  self.IsReceivedResultPro = false
  self.CachedResult = nil
  self.ResultToSpectate = true
  self.ResultProcessSuspended = false
  self.BackToLobbyShowLoading = true
  self.isTeamResult = false
  self.battleType = nil
  BattleResultSubSystem.__super.OnRelease(self)
end
function BattleResultSubSystem:_RegisterProcessLogics()
  print(bWriteLog and "[BattleResultSubSystem]_RegisterProcessLogics")
  local curProcessCfg = self:GetCurBattleResultProcessCfg()
  for _, moduleCfg in pairs(curProcessCfg) do
    local prologic = self.ProcessLogicMap[moduleCfg.ProcessName]
    if not prologic then
      print(bWriteLog and "[BattleResultSubSystem]_Register ProcessName:" .. tostring(moduleCfg.ProcessName))
      local prologicClass = require(moduleCfg.Model)
      prologic = prologicClass()
      self.ProcessLogicMap[moduleCfg.ProcessName] = prologic
      if prologic then
        prologic.ProcessName = moduleCfg.ProcessName
      end
      table.insert(self.ProcessLogic_Sort, prologic)
    end
    table.insert(self.ProcessLogicList, prologic)
  end
  self:_CallAllLifeCycleMethod("OnBaseInit", self)
end
function BattleResultSubSystem:_UnRegisterProcessLogics()
  print(bWriteLog and "[BattleResultSubSystem]_UnRegisterProcessLogics")
  self:_CallAllLifeCycleMethod("OnBaseRelease")
end
function BattleResultSubSystem:_CallAllLifeCycleMethod(LifeCycleMethodName, ...)
  print(bWriteLog and "[BattleResultSubSystem]_CallAllLifeCycleMethod LifeCycleMethodName:" .. LifeCycleMethodName)
  if self.ProcessLogic_Sort then
    for index, module in pairs(self.ProcessLogic_Sort) do
      xpcall(module[LifeCycleMethodName], utility.ErrorMessageHandler, module, ...)
    end
  end
end
function BattleResultSubSystem:OnPostReconnection()
  print(bWriteLog and "BattleResultSubSystem:OnPostReconnection", self:InResultProcess(), self.CurResultProcessIndex, self.ResultProcessSuspended)
  if self:InResultProcess() and not self.ResultProcessSuspended then
    self.CurProcess = self.ProcessLogicList[self.CurResultProcessIndex]
    if self.CurProcess and self.CurProcess.OnPostReconnection then
      self.CurProcess:OnPostReconnection(self.CurResultProcessIndex)
    end
  end
end
function BattleResultSubSystem:OnApplicationReactived()
  print(bWriteLog and "BattleResultSubSystem:OnApplicationReactived", self:InResultProcess(), self.CurResultProcessIndex, self.ResultProcessSuspended)
  if self:InResultProcess() and not self.ResultProcessSuspended then
    self.CurProcess = self.ProcessLogicList[self.CurResultProcessIndex]
    if self.CurProcess and self.CurProcess.OnApplicationReactived then
      self.CurProcess:OnApplicationReactived(self.CurResultProcessIndex)
    end
  end
end
function BattleResultSubSystem:OnBackLogin()
  print(bWriteLog and "BattleResultSubSystem:OnBackLogin")
  self:OnRelease()
end
function BattleResultSubSystem:GetCurBattleResultProcessCfg()
  local BattleResultConfig = GamePlayTools.GetCurrentConfig("BattleResultConfig")
  if not BattleResultConfig then
    log_error("[BattleResultSubSystem] GetCurBattleResultProcessCfg failed: BattleResultConfig is not loaded.")
    return nil
  end
  local isOb = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsObserver and uPlayerController:IsObserver() then
    isOb = true
  end
  print(bWriteLog and "[BattleResultSubSystem]GetCurBattleResultProcessCfg isOb:" .. tostring(isOb))
  local BattleResultProcessConfig = BattleResultConfig.BattleResultProcess
  if isOb then
    if not BattleResultConfig.OBBattleResultProcess then
      log_error("[BattleResultSubSystem] GetCurBattleResultProcessCfg failed: OBBattleResultProcess is not found in config.")
      return nil
    end
    BattleResultProcessConfig = BattleResultConfig.OBBattleResultProcess
  end
  log_tree(bWriteLog and "BattleResultProcessConfig", BattleResultProcessConfig)
  return BattleResultProcessConfig
end
function BattleResultSubSystem:GetResultProcessLogic(processName)
  if self.ProcessLogicMap[processName] then
    return self.ProcessLogicMap[processName]
  end
  return nil
end
function BattleResultSubSystem:GetBattleResultData()
  local curDataLogic = self:GetResultProcessLogic(BATTLE_RESULT_DATA_LOGIC)
  if curDataLogic and curDataLogic.GetBattleResultData then
    local curShareResultData = curDataLogic:GetBattleResultData()
    if curShareResultData then
      return curShareResultData
    end
  end
  return self.DefaultData
end
function BattleResultSubSystem:CheckAndProcessBattleResult()
  print(bWriteLog and "BattleResultSubSystem:CheckAndProcessBattleResult IsReceivedResultPro", self.IsReceivedResultPro, self.CachedResult)
  if not self.IsReceivedResultPro and self.CachedResult and #self.CachedResult > 0 then
    for Idx, ResultData in ipairs(self.CachedResult) do
      print(bWriteLog and "BattleResultSubSystem:CheckAndProcessBattleResult", Idx, ResultData)
      if ResultData then
        self:OnBattleResult(ResultData)
      end
    end
    self.CachedResult = {}
  end
end
function BattleResultSubSystem:OnBattleResult(result)
  print(bWriteLog and "[BattleResultSubSystem]OnBattleResult", self, self.HasInit, g_game_id, result.battle_id, result.is_team_result, self.CachedResult)
  if not self.HasInit then
    if not self.CachedResult then
      self.CachedResult = {}
    end
    table.insert(self.CachedResult, result)
    return
  end
  NetUtil.BBattleResultRecieved = true
  print(bWriteLog and "[BattleResultSubSystem]OnBattleResult Reason:" .. tostring(result.Reason) .. " IsSolo:" .. tostring(result.IsSolo) .. " is_last_survive:" .. tostring(result.is_last_survive) .. " is_team_result:" .. tostring(result.is_team_result))
  xpcall(function()
    local Params = {
      result.is_team_result and 1 or 0,
      result.Reason == "win" and 1 or 0,
      result.is_last_survive and 1 or 0,
      result.IsSolo and 1 or 0
    }
    local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
    if GameReportUtils then
      GameReportUtils.ReplayReportData(2, Params)
    end
  end, utility.ErrorMessageHandler)
  local PlatName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if slua.isValid(GameInstance) then
    if PlatName == DevicePlatformNameMacros.Android then
      KismetSystemLibrary.ExecuteConsoleCommand(GameInstance, "r.AsyncPSO.Pause 1", nil)
    elseif PlatName == DevicePlatformNameMacros.IOS then
      KismetSystemLibrary.ExecuteConsoleCommand(GameInstance, "r.Mobile.IOSAsyncCreatePSO 0", nil)
    end
  end
  Client.CrashLog(NetInterface, 4, "Battle", "BattleResultS")
  if BattleResultUI.UseTXTResultData then
    g_game_id = result.battle_id
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  print(bWriteLog and "g_game_id is " .. g_game_id)
  print(bWriteLog and "result.battle_id is " .. result.battle_id)
  print(bWriteLog and "result.battle_type is " .. tostring(result.battle_type))
  print(bWriteLog and "result.IsKickedFromGame is " .. tostring(result.IsKickedFromGame))
  print(bWriteLog and "ZoneSystem.nChooseZoneID " .. tostring(ZoneSystem.nChooseZoneID))
  if g_game_id ~= result.battle_id then
    return
  end
  log_tree(bWriteLog and "BattleResultSubSystem:OnBattleResult DataMgr", DataMgr)
  if DataMgr == nil or DataMgr.roleData == nil then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.bIgnoreBRBattleResultCheck and result.is_team_result then
    print(bWriteLog and "BattleResultSubSystem:OnBattleResult bIgnoreBRBattleResultCheck is true")
    return
  end
  self.IsReceivedResultPro = true
  self.isTeamResult = result.is_team_result
  self.battleType = result.battle_type
  print(bWriteLog and "TeammateList", #result.TeammateList)
  self:_CallAllLifeCycleMethod("OnBattleResult", result)
  if result.IsSolo or result.is_team_result or result.is_last_survive then
    BattleResult.IgnoreDSError = true
    if self.ResusltTest == false then
      NetUtil.StopCheckDSActive()
    end
  end
  print(bWriteLog and "IgnoreDSError = " .. tostring(BattleResult.IgnoreDSError))
  if result.IsKickedFromGame then
    print(bWriteLog and "result.IsKickedFromGame is true !!!!!!")
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(6276)
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.ShowMsgBox(1, title, content, function()
      print(bWriteLog and "BattleResultSubSystem:OnBattleResult, true kicked from game")
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.ShowLoading(true)
      LobbySystem.ReturnToLobby()
    end, nil)
    return
  end
  Client.CrashLog(NetInterface, 4, "Battle", "BattleResultE")
  self:CheckCanStartResultProcess(result)
  self:PrintSelfInfo()
end
function BattleResultSubSystem:OnOBBattleResult(room_result, room_stat, customize_result)
  print(bWriteLog and "[BattleResultSubSystem]OnOBBattleResult", self.bIsPlayingOBTerminator)
  BattleResult.IgnoreDSError = true
  NetUtil.BBattleResultRecieved = true
  InGameUIManager.HandleUIMessage(observe, "Hide")
  self:_CallAllLifeCycleMethod("OnBattleResult", room_result, room_stat, customize_result)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.GetSpectatorPawn then
    local uSpectatorPawn = uPlayerController:GetSpectatorPawn()
    if slua.isValid(uSpectatorPawn) and uSpectatorPawn.MovementComponent then
      uSpectatorPawn.MovementComponent:SetComponentTickEnabled(false)
      uSpectatorPawn.MovementComponent:Deactivate()
    end
  end
  self:AddGameTimer(1, false, function()
    if not self.bIsPlayingOBTerminator then
      self:StartResultProcess()
    else
      self.bSuspendingInOB = true
    end
  end)
end
function BattleResultSubSystem:OBTerminatorBegin()
  print(bWriteLog and "BattleResultSubSystem:OBTerminatorBegin", self.bIsPlayingOBTerminator, self.bSuspendingInOB)
  self.bIsPlayingOBTerminator = true
end
function BattleResultSubSystem:OBTerminatorEnd()
  print(bWriteLog and "BattleResultSubSystem:OBTerminatorEnd", self.bIsPlayingOBTerminator, self.bSuspendingInOB)
  self.bIsPlayingOBTerminator = false
  if self.bSuspendingInOB then
    self:AddGameTimer(0.1, false, function()
      self:StartResultProcess()
    end)
  end
end
function BattleResultSubSystem:EndResultProcess(processLogic)
  print(bWriteLog and "[BattleResultSubSystem]EndResultProcess proIndx:" .. tostring(processLogic.CurResultProcessIndex) .. " curIndex:" .. tostring(self.CurResultProcessIndex))
  if processLogic.CurResultProcessIndex == self.CurResultProcessIndex then
    self:ExecutionNextResultProcess()
  end
end
function BattleResultSubSystem:StopResultProcess()
  print(bWriteLog and "[BattleResultSubSystem]StopResultProcess curIndex:" .. tostring(self.CurResultProcessIndex) .. " Suspended" .. tostring(self.ResultProcessSuspended))
  if self:InResultProcess() and not self.ResultProcessSuspended then
    self:_CallAllLifeCycleMethod("OnResultProcessStop", self.CurResultProcessIndex)
    self.ResultProcessSuspended = true
    EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_STOP_PROCESS)
  end
end
function BattleResultSubSystem:ContinueResultProcess()
  print(bWriteLog and "[BattleResultSubSystem]ContinueResultProcess curIndex:" .. tostring(self.CurResultProcessIndex) .. " Suspended:" .. tostring(self.ResultProcessSuspended))
  if self:InResultProcess() and self.ResultProcessSuspended then
    BattleResult.IgnoreDSError = true
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      print(bWriteLog and "BattleResultSubSystem:ContinueResultProcess MainControlPanel_HideAllUI", WatchGameUI, ResultToSpectate, ReviveSpectateTips)
      if uPlayerController.CastUIMsg then
        uPlayerController:CastUIMsg("MainControlPanel_HideAllUI", "ingame")
      end
      if WatchGameUI then
        WatchGameUI:HideSpectatingUI()
      end
      if ResultToSpectate then
        ResultToSpectate.HideUI()
      end
      if ReviveSpectateTips then
        ReviveSpectateTips.HideSpectateTipsUI()
      end
    end
    self:_CallAllLifeCycleMethod("OnResultProcessContinue", self.CurResultProcessIndex)
    self.ResultProcessSuspended = false
    EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_CONTINUE_PROCESS)
  end
end
function BattleResultSubSystem:InResultProcess()
  return self.CurResultProcessIndex and self.CurResultProcessIndex ~= 0
end
function BattleResultSubSystem:EnterProtectProcess()
  return self.bHasEnterProtect
end
function BattleResultSubSystem:ForcedFinishResultProcess()
  print(bWriteLog and "[BattleResultSubSystem]ForcedFinishResultProcess curIndex:" .. tostring(self.CurResultProcessIndex))
  if self:InResultProcess() then
    self.CurResultProcessIndex = 0
    xpcall(self.CurProcess.EndResultProcess, utility.ErrorMessageHandler, self.CurProcess)
    self:EndAllResultProcess()
  end
end
function BattleResultSubSystem:SetStartProcess(Name)
  local curProcessCfg = self:GetCurBattleResultProcessCfg()
  for index, moduleCfg in pairs(curProcessCfg) do
    if moduleCfg.ProcessName == Name then
      self.StartAtProcess = index
      break
    end
  end
  print(bWriteLog and "BattleResultSubSystem:SetStartProcess", Name, self.StartAtProcess)
end
function BattleResultSubSystem:CheckCanStartResultProcess(result)
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.UseCustomGameResult() then
    self:StartResultProcess()
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.bIgnoreBRBattleResultCheck then
    if result and not result.is_team_result then
      self:StartResultProcess()
    end
    return
  end
  local IsSolo = true
  if result.max_game_num then
    IsSolo = result.max_game_num < 2
  end
  local isTeamSingle = not IsSolo and result.is_team_result == false
  print(bWriteLog and "[BattleResultSubSystem]CheckCanStartResultProcess", IsSolo, result.is_team_result)
  print(bWriteLog and "[BattleResultSubSystem]CheckCanStartResultProcess", result.Reason, isTeamSingle, result.is_last_survive, isTeamSingle, self.ResultToSpectate, self.LeaveSpectating)
  if result.Reason == "win" and isTeamSingle then
  elseif isTeamSingle and not result.is_last_survive then
    if self.ResultToSpectate and not ResultUtil.IsPVEMode(result.battle_type) then
      if self.LeaveSpectating then
        self:AddGameTimer(0.5, false, function()
          self:StartResultProcess()
        end)
      else
        self.LeaveSpectating = true
        self:OnResultToSpectate()
      end
    else
      self:StartResultProcess()
    end
  else
    self:StartResultProcess()
  end
end
function BattleResultSubSystem:StartResultProcess()
  print(bWriteLog and "[BattleResultSubSystem]StartResultProcess", self.CurResultProcessIndex, self.StartAtProcess)
  if self:InResultProcess() then
    print(bWriteLog and "[BattleResultSubSystem]StartResultProcess CurResultProcessIndex ~= 0")
    return
  end
  FuncUtil.AddCrashContextMainFlow("90")
  EventSystem:postEventSafety(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT)
  if self.StartAtProcess > 0 then
    self.CurResultProcessIndex = self.StartAtProcess - 1
  end
  self:ExecutionNextResultProcess()
end
function BattleResultSubSystem:ExecutionNextResultProcess()
  print(bWriteLog and "[BattleResultSubSystem]ExecutionNextResultProcess CurResultProcessIndex:" .. tostring(self.CurResultProcessIndex))
  self.CurResultProcessIndex = self.CurResultProcessIndex + 1
  if #self.ProcessLogicList < self.CurResultProcessIndex then
    self:EndAllResultProcess()
    return
  end
  self.CurProcess = self.ProcessLogicList[self.CurResultProcessIndex]
  print(bWriteLog and "BattleResultSubSystem:ExecutionNextResultProcess", self.CurResultProcessIndex, self.CurProcess.StartResultProcess)
  local callOb, startSuc = xpcall(self.CurProcess.StartResultProcess, utility.ErrorMessageHandler, self.CurProcess, self.CurResultProcessIndex)
  xpcall(function()
    local Params = {
      self.CurResultProcessIndex or 99,
      startSuc and 1 or 0
    }
    local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
    if GameReportUtils then
      GameReportUtils.ReplayReportData(3, Params)
    end
  end, utility.ErrorMessageHandler)
  if callOb and startSuc then
  else
    print(bWriteLog and "BattleResultSubSystem:ExecutionNextResultProcess", self.CurResultProcessIndex, "\229\144\175\229\138\168\229\164\177\232\180\165,callOb", callOb, "startSuc", startSuc)
    self:ExecutionNextResultProcess()
  end
end
function BattleResultSubSystem:EndAllResultProcess()
  print(bWriteLog and "[BattleResultSubSystem]EndAllResultProcess")
  if self.BackToLobbyShowLoading then
    local setting_util = require("client.slua.logic.setting.setting_util")
    local nMapId = setting_util.GetThemeModeMapId()
    FuncUtil.ShowLoadingToLobby(nMapId)
    self:AddGameTimer(0.5, false, function()
      local audioPath = "/Game/WwiseEvent/UI_hall/UI_hall_Return.UI_hall_Return"
      local BusinessHelper = import("BusinessHelper")
      local akEvent = BusinessHelper.LoadAssetFromPath(audioPath)
      if assert(akEvent ~= nil, string.format("[BattleResultSubSystem]OnBackToLobby Can't load audio from path[%s]", audioPath)) then
        local AkGameplayStatics = import("AkGameplayStatics")
        local UIUtil = require("client.common.ui_util")
        local worldContextObject = UIUtil.GetGameInstance()
        AkGameplayStatics.PostEventAtLocation(akEvent, FVector(0, 0, 0), FRotator(0, 0, 0), "", worldContextObject)
      end
      self:_OnBackToLobby()
    end)
  else
    self:_OnBackToLobby()
  end
end
function BattleResultSubSystem:_OnBackToLobby()
  print(bWriteLog and "[BattleResultSubSystem]_OnBackToLobby")
  BattleResultUI.UseTXTResultData = false
  if not self.isTeamResult then
    local battleType = self.battleType or 0
    if battleType == 102 or battleType == 103 or battleType == 402 or battleType == 403 or battleType == 112 or battleType == 113 or battleType == 412 or battleType == 413 then
      print(bWriteLog and "BattleResultSubSystem:OnBackToLobby exit the battle in advance")
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.BattleResult_QuitBattleInAdvance)
    end
  end
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  import("/Script/UnrealArchExt.UAEUserWidget").ClearOpenedUIStack()
  EventBattleResult_BackToLobby()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.ExitGame then
    uPlayerController:ExitGame()
  end
  self:EventClientExitGame()
  if UIManager.IsUIShow(UIManager.UI_Config.ResultsAddFriendsPopUp) then
    UIManager.CloseUI(UIManager.UI_Config.ResultsAddFriendsPopUp)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Results_Recommended_Friend_UIBP) then
    local logic_recommend_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_recommend_friend)
    logic_recommend_friend:ClearRecommendQueue()
    UIManager.CloseUI(UIManager.UI_Config.Results_Recommended_Friend_UIBP)
  end
end
function BattleResultSubSystem:EventClientExitGame()
  print(bWriteLog and "BattleResultSubSystem:EventClientExitGame")
  BattleResult.IgnoreDSError = true
  NetUtil.StopCheckDSActive()
  local ClientEntryHandler = require("client.network.Protocol.ClientEntryHandler")
  ClientEntryHandler.send_giveup_enter_game()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_exit_result()
end
function BattleResultSubSystem:OnCurProcessEnd()
  print(bWriteLog and "BattleResultSubSystem:OnCurProcessEnd", self.CurResultProcessIndex)
  if self:InResultProcess() then
    local curProcess = self.ProcessLogicList[self.CurResultProcessIndex]
    print(bWriteLog and "BattleResultSubSystem:OnCurProcessEnd", curProcess)
    if curProcess then
      curProcess:EndResultProcess()
    end
  end
end
function BattleResultSubSystem:JumpToPhase(name)
  print(bWriteLog and "BattleResultSubSystem:JumpToPhase", name, self.CurResultProcessIndex)
  if self:InResultProcess() then
    local curProcess = self.ProcessLogicList[self.CurResultProcessIndex]
    local TargetProcess = -1
    local curProcessCfg = self:GetCurBattleResultProcessCfg()
    for index, moduleCfg in pairs(curProcessCfg) do
      if moduleCfg.ProcessName == name then
        TargetProcess = index
        break
      end
    end
    print(bWriteLog and "BattleResultSubSystem:JumpToPhase", TargetProcess, self.CurResultProcessIndex)
    self.CurResultProcessIndex = TargetProcess
    curProcess:EndResultProcess()
    if #self.ProcessLogicList < self.CurResultProcessIndex then
      self:EndAllResultProcess()
      return
    end
    self.CurProcess = self.ProcessLogicList[TargetProcess]
    print(bWriteLog and "BattleResultSubSystem:ExecutionNextResultProcess", self.CurResultProcessIndex, self.CurProcess.StartResultProcess)
    local callOb, startSuc = xpcall(self.CurProcess.StartResultProcess, utility.ErrorMessageHandler, self.CurProcess, self.CurResultProcessIndex)
    if callOb and startSuc then
    else
      print(bWriteLog and "BattleResultSubSystem:ExecutionNextResultProcess", self.CurResultProcessIndex, "\229\144\175\229\138\168\229\164\177\232\180\165")
      self:ExecutionNextResultProcess()
    end
    print(bWriteLog and "BattleResultSubSystem:JumpToPhase end", name, self.CurResultProcessIndex)
  else
    local curProcessCfg = self:GetCurBattleResultProcessCfg()
    for index, moduleCfg in pairs(curProcessCfg) do
      if moduleCfg.ProcessName == name then
        self.StartAtProcess = index
        break
      end
    end
    print(bWriteLog and "BattleResultSubSystem:SetStartProcess", name, self.StartAtProcess)
  end
end
function BattleResultSubSystem:OnSpectateToResult()
  print(bWriteLog and "[BattleResultSubSystem]OnSpectateToResult", self.IsReceivedResultPro, self)
  if self.IsReceivedResultPro then
    if self:InResultProcess() then
      self:ContinueResultProcess()
    else
      self:StartResultProcess()
    end
  else
    self:AddGameTimer(5, false, function()
      print(bWriteLog and "[BattleResultSubSystem]OnSpectateToResult in timer IsReceivedResultPro" .. tostring(self.IsReceivedResultPro))
      if not self.IsReceivedResultPro then
        self:EndAllResultProcess()
      end
    end)
  end
end
function BattleResultSubSystem:OnResultToSpectate()
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  print(bWriteLog and "[BattleResultSubSystem]OnResultToSpectate")
  local isInSpectating = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsInSpectating then
    isInSpectating = uPlayerController:IsInSpectating()
  end
  print(bWriteLog and "[BattleResultSubSystem]CheckCanStartResultProcess ResultToSpectate isInSpectating:" .. tostring(isInSpectating))
  self.ResultToSpectate = false
  if Game:IsEnableUIStateRefreshFlag() and false then
    uPlayerController:BroadcastUIMessage("RequestGotoSpectatingForResultToSpectate", 0, "", "")
  elseif not isInSpectating then
    ResultToSpectate_DynamicCreateUI(false, true)
  else
    EventResultToSpectateEnterSpectating()
  end
end
function BattleResultSubSystem:OnGameOverToResult()
  print(bWriteLog and "[BattleResultSubSystem]OnGameOverToResult")
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if slua.isValid(uGameInstance) then
    local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
    print(bWriteLog and "[BattleResultSubSystem]OnGameOverToResult uWonderfulPlayback", uWonderfulPlayback)
    if slua.isValid(uWonderfulPlayback) and uWonderfulPlayback:IsInPlayState() then
      print(bWriteLog and "[BattleResultSubSystem]OnGameOverToResult playing WonderfulPlayback")
      return
    end
    local uDeathPlayback = uGameInstance:GetDeathPlayback()
    if slua.isValid(uDeathPlayback) and uDeathPlayback:IsInPlayState() then
      print(bWriteLog and "[BattleResultSubSystem]OnGameOverToResult playing DeathPlayback")
      return
    end
  end
  self:ContinueResultProcess()
end
function BattleResultSubSystem:BattleResultTestProcess(ntype)
  print(bWriteLog and "[BattleResultSubSystem]BattleResultTestProcess")
  self.ResusltTest = true
  BattleResult.BattleResultSubSystemSwltch = true
  BattleResultUI.UseTXTResultData = true
  BP_ShowFeedBack = true
  g_game_id = 893163251483017251
  BattleResult.RESULTLEVEL_TEST = true
  local battleResultsTestUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultsTestUtil")
  local result = battleResultsTestUtil.GetTestBattleResult(self.ResusltTestPlayerNum, ntype)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local battleResultsTestUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultsTestUtil")
  local ModeName = GameMainConfig.GetModType()
  if ModeName and ModeName ~= "" and ModeName ~= "BaseMod" then
    local TableUtil = require("common.table_util")
    local tModExtraData = battleResultsTestUtil.GetModExtraData(ModeName)
    result = TableUtil.MergeTable(result, tModExtraData or {})
  end
  print(bWriteLog and "[BattleResultSubSystem]BattleResultTestProcess ModeName:", ModeName)
  self:OnBattleResult(result)
  battleResultsTestUtil.SetTestBattleResultTaskData()
  battleResultsTestUtil.SetTestBattleResultRewardData()
end
function BattleResultSubSystem:PrintSelfInfo()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  local uLocalPlayerCharacter = GameplayData.GetPlayerCharacter()
  local PlayerKey = -1
  local UID = -1
  local PlayerName = ""
  if slua.isValid(uPlayerController) then
    PlayerKey = uPlayerController.PlayerKey
    UID = uPlayerController.UID
  end
  if slua.isValid(uLocalPlayerCharacter) and uLocalPlayerCharacter.GetPlayerNameSafety then
    PlayerName = uLocalPlayerCharacter:GetPlayerNameSafety()
  end
  print(bWriteLog and "BattleResultSubSystem:PrintSelfInfo PlayerName:", PlayerName, " PlayerKey:", PlayerKey, " UID:", UID, "GameID:", g_game_id)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, BattleResultSubSystem)