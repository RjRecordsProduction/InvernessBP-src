local TableUtil = require("common.table_util")
local EPawnState = import("EPawnState")
local CanvasVisibleConfig = {}
CanvasVisibleConfig.GhostSkillBtnShowConfig = {
  PlayerStateChanged = {
    Hide = {
      EPawnState.DriveVehicle,
      EPawnState.InVehicle,
      EPawnState.Swim
    }
  }
}
CanvasVisibleConfig.FlowerWingControlUIShowConfig = {
  PlayerStateChanged = {
    Hide = {
      EPawnState.DriveVehicle,
      EPawnState.InVehicle,
      EPawnState.Swim,
      EPawnState.GunADS
    }
  }
}
return CanvasVisibleConfig