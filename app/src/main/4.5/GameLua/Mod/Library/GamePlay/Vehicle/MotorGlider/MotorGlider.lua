local MotorGlider = {}
function MotorGlider:ctor(SelfType)
  self.VehicleOperationMode = 1
end
function MotorGlider:_PostConstruct()
  MotorGlider.__super._PostConstruct(self)
end
local class = require("class")
local CVehicleBase = require("GameLua.GameCore.Module.Vehicle.ALuaVehicleBase")
local CMotorGlider = class(CVehicleBase, nil, MotorGlider)
return require("combine_class").DeclareFeature(CMotorGlider, {
  {
    MotorGliderTLogFeature = "GameLua.Mod.Library.Gameplay.Vehicle.MotorGlider.MotorGliderTLogFeature"
  }
}, "MotorGlider")