local EWidgetVisible = import("EWidgetVisible")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local JumpShowState = {}
function JumpShowState:ctor()
  self.StateName = "JumpShowState"
end
function JumpShowState:Enter()
  JumpShowState.__super.Enter(self)
  local ESlateVisibility = import("ESlateVisibility")
  print(bWriteLog and "JumpShowState:Enter")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if slua.isValid(ShootingUIPanel) then
    ShootingUIPanel:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  local ParachutingControl = UIManager.GetUI(UIManager.UI_Config_InGame.ParachutingControl)
  if ParachutingControl then
    ParachutingControl:ShowJumpButton(false)
  end
end
function JumpShowState:Exit()
  JumpShowState.__super.Exit(self)
  print(bWriteLog and "JumpShowState:Exit")
  local ESlateVisibility = import("ESlateVisibility")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if slua.isValid(ShootingUIPanel) then
    ShootingUIPanel:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  end
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, JumpShowState)