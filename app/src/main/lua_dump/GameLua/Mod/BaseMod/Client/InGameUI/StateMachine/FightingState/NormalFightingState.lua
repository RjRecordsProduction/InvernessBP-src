local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local NormalFightingState = {}
function NormalFightingState:ctor()
  self.StateName = "NormalFightingState"
end
function NormalFightingState:Enter()
  NormalFightingState.__super.Enter(self)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local ShootingUIPanelLuaClass = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanelLuaClass and ShootingUIPanelLuaClass.UIRoot then
    ShootingUIPanelLuaClass.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    ShootingUIPanelLuaClass.UIRoot.CanvasPanel_BtnGroup:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  PlayerController:ShowTouchInterface(true)
  PlayerController.CharacterTouchMove = true
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton.ShootingLayer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    MainControlPanelTochButton:ShowShooterUIForce()
  end
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_FlyingControl then
    MainControlBaseUI:SetEmoteControlVisibility(MainControlBaseUI.Emote_FlyingControl, true)
  end
  if WatchGameUI then
    WatchGameUI:HideSpectatingUI()
  end
  if MainControlPanelTochButton then
    MainControlPanelTochButton:LeaveSpectatingStatus()
  end
end
function NormalFightingState:Exit()
  NormalFightingState.__super.Exit(self)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, NormalFightingState)