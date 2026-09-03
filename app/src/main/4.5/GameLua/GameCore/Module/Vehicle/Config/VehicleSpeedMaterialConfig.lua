local VehicleSpeedMaterialConfig = {}
VehicleSpeedMaterialConfig.MaterialConfigMap = {
  [1903220] = {
    {
      MaterialSlotName = "slot",
      ParameterName = "SpeedLerp",
      ParameterType = "Scalar",
      SpeedMin = 0,
      SpeedMax = 70,
      ValueMin = 0.0,
      ValueMax = 1.0,
      UseForwardSpeed = true
    },
    {
      MaterialSlotName = "slot",
      ParameterName = "BiasAccumulate",
      ParameterType = "Scalar",
      SpeedMin = 0,
      SpeedMax = 70,
      ValueMin = 0.2,
      ValueMax = 0.4,
      UseForwardSpeed = true,
      UseAdditive = true,
      AdditiveMod = 60
    },
    {
      MaterialSlotName = "slot1",
      ParameterName = "SpeedLerp",
      ParameterType = "Scalar",
      SpeedMin = 0,
      SpeedMax = 70,
      ValueMin = 0.0,
      ValueMax = 1.0,
      UseForwardSpeed = true
    }
  }
}
function VehicleSpeedMaterialConfig.GetMaterialConfig(ItemID)
  if not ItemID or ItemID <= 0 then
    return nil
  end
  return VehicleSpeedMaterialConfig.MaterialConfigMap[ItemID]
end
return VehicleSpeedMaterialConfig