local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BattleResultState = {}
function BattleResultState:ctor()
  self.StateName = "BattleResultState"
end
function BattleResultState:Enter()
  BattleResultState.__super.Enter(self)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  PlayerController:LuaHideJoystickWidgetWithTag("BattleResultState")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:MainControlPanel_HideAllUI()
  end
  if WatchGameUI then
    WatchGameUI:HideSpectatingUI()
  end
end
function BattleResultState:Exit()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaShowJoystickWidgetWithTag("BattleResultState")
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      MainControlPanelTochButton:MainControlPanel_ShowAllUI()
    end
  end
  BattleResultState.__super.Exit(self)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, BattleResultState)