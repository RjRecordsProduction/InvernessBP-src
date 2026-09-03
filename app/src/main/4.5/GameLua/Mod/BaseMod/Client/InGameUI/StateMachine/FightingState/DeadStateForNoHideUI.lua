local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local DeadStateForNoHideUI = {}
function DeadStateForNoHideUI:ctor()
  self.StateName = "DeadStateForNoHideUI"
end
function DeadStateForNoHideUI:Enter()
  DeadStateForNoHideUI.__super.Enter(self)
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
  if MainControlBaseUI and MainControlBaseUI.CanvasPanelForPlayerInfo then
    MainControlBaseUI.CanvasPanelForPlayerInfo:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:LuaHideJoystickWidgetWithTag("DeadStateForNoHideUI")
  PlayerController.CharacterTouchMove = false
  PlayerController:SetVirtualStickAutoSprintStatus(false)
  if Client and GameFrontendHUD then
    Client.FlushPressedKeys(GameFrontendHUD)
  end
end
function DeadStateForNoHideUI:Exit()
  DeadStateForNoHideUI.__super.Exit(self)
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
  if MainControlBaseUI and MainControlBaseUI.CanvasPanelForPlayerInfo then
    MainControlBaseUI.CanvasPanelForPlayerInfo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:LuaShowJoystickWidgetWithTag("DeadStateForNoHideUI")
  PlayerController.CharacterTouchMove = true
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, DeadStateForNoHideUI)