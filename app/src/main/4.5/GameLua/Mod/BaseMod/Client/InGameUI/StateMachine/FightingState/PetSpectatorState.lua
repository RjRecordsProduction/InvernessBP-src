local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PetSpectatorState = {}
function PetSpectatorState:ctor()
  self.StateName = "PetSpectatorState"
end
function PetSpectatorState:Enter()
  PetSpectatorState.__super.Enter(self)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if UIManager.UI_Config_InGame.PetSpectateUI then
    UIManager.ShowUI(UIManager.UI_Config_InGame.PetSpectateUI)
  end
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.Emote_SpectatingControl then
    MainControlBaseUI.Emote_SpectatingControl:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
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
  PlayerController:ShowTouchInterface(true)
  PlayerController.CharacterTouchMove = true
  if MainControlPanelTochButton then
    local HistoricalNewsUI = UIManager.GetUI(UIManager.UI_Config_InGame.HistoricalNewsUI)
    if HistoricalNewsUI then
      HistoricalNewsUI:AttachToPanel(MainControlPanelTochButton.CanvasPanel_IPX)
      HistoricalNewsUI:SetAnchors(0, 0, 1, 1)
      HistoricalNewsUI:SetOffsets(0, 0, 0, 0)
    end
  end
end
function PetSpectatorState:Exit()
  PetSpectatorState.__super.Exit(self)
  if UIManager.UI_Config_InGame.PetSpectateUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.PetSpectateUI)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:ShowTouchInterface(true)
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
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, PetSpectatorState)