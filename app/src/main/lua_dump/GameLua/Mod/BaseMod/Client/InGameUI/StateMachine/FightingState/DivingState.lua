local EPawnState = import("EPawnState")
local EWidgetVisible = import("EWidgetVisible")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local DivingState = {}
function DivingState:ctor()
  self.StateName = "DivingState"
end
function DivingState:Enter()
  DivingState.__super.Enter(self)
  UIManager.ShowUI(UIManager.UI_Config_InGame.DivingUI)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:ShowTouchInterface(true)
  end
  print(bWriteLog and "owen=>>>DivingState:Enter")
end
function DivingState:Exit()
  DivingState.__super.Exit(self)
  UIManager.CloseUI(UIManager.UI_Config_InGame.DivingUI)
  print(bWriteLog and "owen=>>>DivingState:Exit")
end
function DivingState:ShowSwimPanel()
  UIManager.ShowUI(UIManager.UI_Config_InGame.DivingSwimPanel)
end
function DivingState:CloseSwimPanel()
  UIManager.CloseUI(UIManager.UI_Config_InGame.DivingSwimPanel)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.FightingState.SwimState")
return class(CDelegateContainer, nil, DivingState)