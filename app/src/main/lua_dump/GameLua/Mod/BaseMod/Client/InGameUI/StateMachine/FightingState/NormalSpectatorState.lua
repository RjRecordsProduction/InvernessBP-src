local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local NormalSpectatorState = {}
function NormalSpectatorState:ctor()
  self.StateName = "NormalSpectatorState"
  self.CheckLowTickRateInSpectatingInterval = 604800
  self.CheckLowTickRateInSpectatingDelay = 15
end
function NormalSpectatorState:Enter()
  NormalSpectatorState.__super.Enter(self)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if WatchGameUI then
    WatchGameUI:ShowSpectatingUI()
  end
  PlayerController:LuaHideJoystickWidgetWithTag("NormalSpectatorState")
  PlayerController.CharacterTouchMove = false
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_SpectatingControl then
    MainControlBaseUI.Emote_SpectatingControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if MainControlBaseUI and MainControlBaseUI.CanvasPanelForPlayerInfo then
    MainControlBaseUI.CanvasPanelForPlayerInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if MainControlBaseUI and MainControlBaseUI.CanvasPanel_FreeCamera then
    MainControlBaseUI.CanvasPanel_FreeCamera:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and MainControlPanelTochButton.ShootingLayer then
    MainControlPanelTochButton.ShootingLayer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if MainControlPanelTochButton and MainControlPanelTochButton.VehicleControlLayer then
    MainControlPanelTochButton.VehicleControlLayer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if MainControlPanelTochButton then
    MainControlPanelTochButton:ShowSpectatingUI()
  end
  if MainControlPanelTochButton then
    local HistoricalNewsUI = UIManager.GetUI(UIManager.UI_Config_InGame.HistoricalNewsUI)
    if HistoricalNewsUI then
      HistoricalNewsUI:AttachToPanel(MainControlPanelTochButton.CanvasPanel_IPX)
      HistoricalNewsUI:SetAnchors(0, 0, 1, 1)
      HistoricalNewsUI:SetOffsets(0, 0, 0, 0)
    end
  end
  if self.CheckTimer then
    self:RemoveGameTimer(self.CheckTimer)
    self.CheckTimer = nil
  end
  self.CheckTimer = self:AddGameTimer(self.CheckLowTickRateInSpectatingDelay, false, function()
    self:CheckAndShowTickRateLimitTips()
  end)
end
function NormalSpectatorState:Exit()
  NormalSpectatorState.__super.Exit(self)
  if WatchGameUI then
    WatchGameUI:HideSpectatingUI()
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:LuaShowJoystickWidgetWithTag("NormalSpectatorState")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_SpectatingControl then
    MainControlBaseUI.Emote_SpectatingControl:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if MainControlBaseUI and MainControlBaseUI.CanvasPanelForPlayerInfo then
    MainControlBaseUI.CanvasPanelForPlayerInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if MainControlBaseUI and MainControlBaseUI.CanvasPanel_FreeCamera then
    MainControlBaseUI.CanvasPanel_FreeCamera:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and MainControlPanelTochButton.ShootingLayer then
    MainControlPanelTochButton.ShootingLayer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if MainControlPanelTochButton then
    MainControlPanelTochButton:LeaveSpectatingStatus()
  end
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass and ShootingUIPanelLuaClass.UIRoot then
    local HistoricalNewsUI = UIManager.GetUI(UIManager.UI_Config_InGame.HistoricalNewsUI)
    if HistoricalNewsUI then
      HistoricalNewsUI:AttachToPanel(ShootingUIPanelLuaClass.UIRoot.HistoricalNewsCanvasPanel)
      HistoricalNewsUI:SetAnchors(0, 0, 1, 1)
      HistoricalNewsUI:SetOffsets(0, 0, 0, 0)
    end
  end
  if self.bHasLimitedFPS then
    self:EnableFPSLimit(false)
  end
  if self.CheckTimer then
    self:RemoveGameTimer(self.CheckTimer)
    self.CheckTimer = nil
  end
end
function NormalSpectatorState:CheckAndShowTickRateLimitTips()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local MaxFps = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.MaxFPS")
  local OverrideMaxFPS = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.OverrideMaxFPS")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  local LowTickRateInSpectating = SettingSubsystem:GetUserSettings_Bool("LowTickRateInSpectating")
  print(bWriteLog and "NormalSpectatorState:CheckAndShowTickRateLimitTips", MaxFps, OverrideMaxFPS, LowTickRateInSpectating)
  if MaxFps < 90 then
    print(bWriteLog and "NormalSpectatorState:CheckAndShowTickRateLimitTips MaxFps < 90")
    return
  end
  if LowTickRateInSpectating == true then
    self:EnableFPSLimit(true)
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eOBFPSLimit) or {}
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  print(bWriteLog and "NormalSpectatorState:CheckAndShowTickRateLimitTips serverTime", serverTime, record.lastTriggerTime, self.CheckLowTickRateInSpectatingInterval)
  if record.lastTriggerTime and serverTime - record.lastTriggerTime < self.CheckLowTickRateInSpectatingInterval then
    print(bWriteLog and "NormalSpectatorState:CheckAndShowTickRateLimitTips lastTriggerTime", record.lastTriggerTime)
    return
  end
  record.lastTriggerTime = serverTime
  PlayerPrefsSystem.SaveTableToFile_N(record, PlayerPrefsSystem.ePlayerPrefsType.eOBFPSLimit)
  record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eOBFPSLimit) or {}
  print(bWriteLog and "NormalSpectatorState:CheckAndShowTickRateLimitTips Trigger success, record.lastTriggerTime", record.lastTriggerTime)
  local ConfirmInfo = {
    Style = "Simple",
    Content = LocUtil.GetLocalizeResStr(99009928),
    LeftLable = LocUtil.GetLocalizeResStr(99009930),
    RightLable = LocUtil.GetLocalizeResStr(99009929),
    RightCountDownTime = 10,
    CountDownEndTime = 10 + CGameState:GetServerWorldTimeSeconds(),
    RightLableColorAndOpacity = FSlateColor(FLinearColor(1, 0.723055, 0.015209, 1))
  }
  function ConfirmInfo.RightCB()
    SettingSubsystem:SetUserSettings_Bool("LowTickRateInSpectating", true)
    local LowTickRateInSpectating = SettingSubsystem:GetUserSettings_Bool("LowTickRateInSpectating")
    print(bWriteLog and "NormalSpectatorState:CheckAndShowTickRateLimitTips RightCB LowTickRateInSpectating", LowTickRateInSpectating)
    self:EnableFPSLimit(true)
  end
  ConfirmInfo.CountDownOverCB = ConfirmInfo.RightCB
  function ConfirmInfo.CloseCB()
    print(bWriteLog and "NormalSpectatorState:CheckAndShowTickRateLimitTips CloseCB")
  end
  local CommonConfirm = require("GameLua.Mod.BaseMod.Common.Confirm.CommonConfirm")
  if self.CheckTimer then
    self:RemoveGameTimer(self.CheckTimer)
    self.CheckTimer = nil
  end
  CommonConfirm.ShowConfirm(ConfirmInfo)
end
function NormalSpectatorState:EnableFPSLimit(bEnable)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local MaxFps = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.MaxFPS")
  local OverrideMaxFPS = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.OverrideMaxFPS")
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  if not GameInstance then
    return
  end
  print(bWriteLog and "NormalSpectatorState:EnableFPSLimit MaxFps: " .. MaxFps, OverrideMaxFPS, bEnable)
  if bEnable then
    if 60 < MaxFps then
      GameInstance:ExecuteCMD("t.OverrideMaxFPS", 60)
      self.bHasLimitedFPS = true
    end
  else
    GameInstance:ExecuteCMD("t.OverrideMaxFPS", 0)
    self.bHasLimitedFPS = false
  end
  OverrideMaxFPS = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.OverrideMaxFPS")
  print(bWriteLog and "NormalSpectatorState:EnableFPSLimit End MaxFps: " .. MaxFps, OverrideMaxFPS, bEnable)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, NormalSpectatorState)