local VehicleSeatComponentMotorcycle = {}
local KismetSystemLibrary = import("KismetSystemLibrary")
function VehicleSeatComponentMotorcycle:_PostConstruct()
  VehicleSeatComponentMotorcycle.__super._PostConstruct(self)
end
function VehicleSeatComponentMotorcycle:IsLeavePositionValid(Character, EnterPos, LeavePos, ForceUseLineTrace, IgnoreVehicle)
  if self.LeaveBikeFeature then
    return self.LeaveBikeFeature:IsLeavePositionValid(Character, EnterPos, LeavePos, ForceUseLineTrace, IgnoreVehicle)
  end
  return true
end
local class = require("class")
local CDelegateContainer = require("GameLua.GameCore.Module.Vehicle.Component.VehicleSeatComponent")
local ComponentClass = class(CDelegateContainer, nil, VehicleSeatComponentMotorcycle)
return require("combine_class").DeclareFeature(ComponentClass, {
  {
    LeaveBikeFeature = "GameLua.GameCore.Module.Vehicle.Features.Seat.LeaveBikeFeature"
  }
}, "VehicleSeatComponentMotorcycle")