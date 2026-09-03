local DriverState = {}
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function DriverState:ctor()
  self.StateName = "DriverState"
end
function DriverState:Enter()
  DriverState.__super.Enter(self)
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    local VehicleUserComponent = VehicleControlUISubSystem:GetVehicleUserComponent()
    if slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Vehicle) then
      local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
      if VehicleUserComponent.Vehicle.bNeedWeaponSlot then
        self._CurrentVehicleDriverLayout = UILayoutConfig.LayoutNameConfig.VehicleDriverLayoutWithWeaponSlot
      else
        self._CurrentVehicleDriverLayout = UILayoutConfig.LayoutNameConfig.VehicleDriverLayout
      end
    end
    local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
    if MainControlPanelTochButton then
      MainControlPanelTochButton:ApplyLayout(self._CurrentVehicleDriverLayout)
    end
    VehicleControlUISubSystem:ShowDriverUI()
  end
end
function DriverState:Exit()
  DriverState.__super.Exit(self)
  local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
  if MainControlPanelTochButton then
    MainControlPanelTochButton:UnApplyLayout(self._CurrentVehicleDriverLayout)
  end
end
local class = require("class")
local CStateBase = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CStateBase, nil, DriverState)