local PassengerState = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function PassengerState:ctor()
  self.StateName = "PassengerState"
  local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
  self.VehiclePassengerLayout = UILayoutConfig.LayoutNameConfig.VehiclePassengerLayout
end
function PassengerState:Enter()
  PassengerState.__super.Enter(self)
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:ApplyLayout(self.VehiclePassengerLayout)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaHideJoystickWidgetWithTag("Passenger")
  end
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    VehicleControlUISubSystem:ShowPassengerUI()
  end
end
function PassengerState:Exit()
  PassengerState.__super.Exit(self)
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:UnApplyLayout(self.VehiclePassengerLayout)
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:LuaShowJoystickWidgetWithTag("Passenger")
  end
end
local class = require("class")
local CStateBase = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CStateBase, nil, PassengerState)