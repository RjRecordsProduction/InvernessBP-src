local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local EVehicleDamageScaleReason = import("EVehicleDamageScaleReason")
local VehicleCommonConfig = {
  Default = {
    DamageScaleMap = {
      [EVehicleDamageScaleReason.OnlyHasTeammate] = 0,
      [EVehicleDamageScaleReason.HasTeammateAndOthers] = 1,
      [EVehicleDamageScaleReason.OnlyHasOther] = 1
    }
  }
}
return VehicleCommonConfig