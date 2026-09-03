local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local ParachuteState = {}
function ParachuteState:ctor()
  self.StateName = "ParachuteState"
end
function ParachuteState:Enter()
  ParachuteState.__super.Enter(self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerControllerStateChangedDelegate", self.HandlePlayerControllerStateChanged, self)
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and ShootingUIPanelLuaClass and ShootingUIPanelLuaClass.UIRoot then
    ShootingUIPanelLuaClass.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local HistoricalNewsUI = UIManager.GetUI(UIManager.UI_Config_InGame.HistoricalNewsUI)
    if HistoricalNewsUI then
      HistoricalNewsUI:AttachToPanel(MainControlPanelTochButton.CanvasPanel_IPX)
      HistoricalNewsUI:SetAnchors(0, 0, 1, 1)
      HistoricalNewsUI:SetOffsets(0, 0, 0, 0)
    end
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_FlyingControl then
    MainControlBaseUI:SetEmoteControlVisibility(MainControlBaseUI.Emote_FlyingControl, false)
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.OnTurnplateBtnTouchEnd then
    MainControlBaseUI:OnTurnplateBtnTouchEnd()
  end
  if MainControlPanelTochButton and MainControlPanelTochButton.ParachutingLayer then
    MainControlPanelTochButton.ParachutingLayer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaHideJoystickWidgetWithTag("ParachuteState")
  end
  if WatchGameUI then
    WatchGameUI:HideSpectatingUI()
  end
  self:HandlePlayerControllerStateChanged()
end
function ParachuteState:Exit()
  ParachuteState.__super.Exit(self)
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass and ShootingUIPanelLuaClass.UIRoot then
    ShootingUIPanelLuaClass.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local HistoricalNewsUI = UIManager.GetUI(UIManager.UI_Config_InGame.HistoricalNewsUI)
    if HistoricalNewsUI then
      HistoricalNewsUI:AttachToPanel(ShootingUIPanelLuaClass.UIRoot.HistoricalNewsCanvasPanel)
      HistoricalNewsUI:SetAnchors(0, 0, 1, 1)
      HistoricalNewsUI:SetOffsets(0, 0, 0, 0)
    end
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_FlyingControl then
    MainControlBaseUI:SetEmoteControlVisibility(MainControlBaseUI.Emote_FlyingControl, true)
  end
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton and MainControlPanelTochButton.ParachutingLayer then
    MainControlPanelTochButton.ParachutingLayer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:ShowTouchInterface(true)
  PlayerController:LuaShowJoystickWidgetWithTag("ParachuteState")
  PlayerController.CharacterTouchMove = true
  self.bNeedShowTouchInterface = nil
end
function ParachuteState:HandlePlayerControllerStateChanged()
  print(bWriteLog and "ParachuteState:HandlePlayerControllerStateChanged 0")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  print(bWriteLog and "ParachuteState:HandlePlayerControllerStateChanged 1")
  local bNeedShowTouchInterface = false
  local CurrentStateType = PlayerController:GetCurrentStateType()
  local EStateType = import("EStateType")
  if CurrentStateType == EStateType.State_ParachuteJump or CurrentStateType == EStateType.State_ParachuteOpen or CurrentStateType == EStateType.State_Fight or CurrentStateType == EStateType.State_Launch then
    print(bWriteLog and "ParachuteState:HandlePlayerControllerStateChanged 2")
    bNeedShowTouchInterface = true
  end
  if self.bNeedShowTouchInterface ~= bNeedShowTouchInterface then
    print(bWriteLog and "ParachuteState:HandlePlayerControllerStateChanged 3")
    PlayerController:ShowTouchInterface(bNeedShowTouchInterface)
  end
  self.  if bNeedShowTouchInterface then
    print(bWriteLog and "ParachuteState:HandlePlayerControllerStateChanged 4")
    PlayerController:LuaShowJoystickWidgetWithTag("ParachuteState")
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, ParachuteState)