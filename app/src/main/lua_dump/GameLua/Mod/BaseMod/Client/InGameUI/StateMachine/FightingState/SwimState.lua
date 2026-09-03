local EPawnState = import("EPawnState")
local EWidgetVisible = import("EWidgetVisible")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local SwimState = {}
function SwimState:ctor()
  self.StateName = "SwimState"
end
function SwimState:Enter()
  SwimState.__super.Enter(self)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:ShowTouchInterface(true)
  end
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
    MainControlPanelTochButton:ApplyLayout(UILayoutConfig.LayoutNameConfig.SwimLayout)
  end
  self:ShowSwimPanel()
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    if PlayerCharacter:HasState(EPawnState.HoldGrenade) and PlayerCharacter:IsGrenadeEmpty() then
      PlayerCharacter:DestroyGrenadeAndSwitchBackToPreviousWeaponOnServer()
    else
      print(bWriteLog and "SwimState:Enter TriggerCustomEvent")
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_NEWBIE_GUIDE_SWIM_PANEL, true)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOOTINGUI_SHOWORHIDE_SWIMUI, true)
end
function SwimState:Exit()
  SwimState.__super.Exit(self)
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
    MainControlPanelTochButton:UnApplyLayout(UILayoutConfig.LayoutNameConfig.SwimLayout)
  end
  self:CloseSwimPanel()
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_NEWBIE_GUIDE_SWIM_PANEL, false)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_SHOOTINGUI_SHOWORHIDE_SWIMUI, false)
end
function SwimState:ShowSwimPanel()
  UIManager.ShowUI(UIManager.UI_Config_InGame.SwimPanel)
end
function SwimState:CloseSwimPanel()
  if UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.SwimPanel then
    UIManager.CloseUI(UIManager.UI_Config_InGame.SwimPanel)
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, SwimState)