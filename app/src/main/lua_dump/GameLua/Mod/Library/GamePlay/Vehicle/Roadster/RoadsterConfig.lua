local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local UKismetMathLibrary = import("KismetMathLibrary")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local EEffectType = ConfigUtils.EEffectType
local VehicleConfig = {
  VehicleFeatures = {
    TLog = {
      "GameLua.GameCore.Module.Vehicle.VehicleFeatures.TLog.VehicleTLogFeature",
      ConfigUtils.ENetSide.Server,
      {TLogID_Enter = 2193}
    }
  }
}
return VehicleConfig