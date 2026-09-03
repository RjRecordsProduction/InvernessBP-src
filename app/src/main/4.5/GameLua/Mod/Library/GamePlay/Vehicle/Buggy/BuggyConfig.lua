local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local UKismetMathLibrary = import("KismetMathLibrary")
local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local VehicleConfig = {
  ComponentsAttrModify = {
    VehicleProtection = {
      NetSide = ConfigUtils.ENetSide.Both,
      Attrs = {bEnablePreventPene = false, bPreventPene = false}
    }
  }
}
return VehicleConfig