local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local VehicleConfig = {
  bAlwaysIgnoreRideCheck = true,
  ComponentsAttrModify = {
    VehicleSeats = {
      NetSide = ConfigUtils.ENetSide.Both,
      Attrs = {
        MaxHeightToLeave = 15,
        FailTips_OverMaxHeight = 30169,
        CanEject = true,
        HeightToEject = 15,
        CanOpenParachuteHeight = 100,
        ForceOpenParachuteHeight = 75,
        CloseParachuteHeight = 10
      }
    }
  }
}
return VehicleConfig