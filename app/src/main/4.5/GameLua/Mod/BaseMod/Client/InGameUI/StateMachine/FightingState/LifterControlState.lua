local ESlateVisibility = import("ESlateVisibility")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local LifterControlState = {}
function LifterControlState:ctor()
  self.StateName = "LifterControlState"
end
function LifterControlState:Enter()
  LifterControlState.__super.Enter(self)
  self:CheckSetLifterControlPanelActive(true)
  self:SetBattleUIActive(true)
  EventSystem:postEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL, false)
end
function LifterControlState:Exit()
  LifterControlState.__super.Exit(self)
  self:CheckSetLifterControlPanelActive(false)
  self:SetBattleUIActive(false)
end
function LifterControlState:SetBattleUIActive(IsEnter)
  local bHide = IsEnter
  local Visibility = bHide and ESlateVisibility.Collapsed or ESlateVisibility.SelfHitTestInvisible
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if slua.isValid(ShootingUIPanel) then
    ShootingUIPanel:SetWidgetVisibility(Visibility)
  end
  if bHide then
    local BasicSkillMenuUI = InGameUITools.GetBasicSkillsMenuUI()
    if BasicSkillMenuUI then
      BasicSkillMenuUI:HideEnterVehicleButtons()
    end
  end
  if bHide then
    local uPlayerController = GameplayData.GetPlayerController()
    uPlayerController:JoystickTriggerSprint(false)
  end
end
function LifterControlState:CheckSetLifterControlPanelActive(IsActive)
  if not UIManager.UI_Config_InGame.LifterControlPanel then
    return
  end
  print(bWriteLog and string.format("LifterControlState:CheckSetLifterControlPanelActive %s", IsActive))
  if IsActive then
    print(bWriteLog and string.format("LifterControlState:CheckSetLifterControlPanelActive %s SHOW", IsActive))
    UIManager.ShowUI(UIManager.UI_Config_InGame.LifterControlPanel)
  else
    print(bWriteLog and string.format("LifterControlState:CheckSetLifterControlPanelActive %s HIDE", IsActive))
    UIManager.HideUI(UIManager.UI_Config_InGame.LifterControlPanel)
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController:ShowTouchInterface(not IsActive)
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, LifterControlState)