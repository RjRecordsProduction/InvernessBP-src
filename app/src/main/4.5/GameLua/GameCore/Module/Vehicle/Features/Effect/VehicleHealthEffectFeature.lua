local VehicleHealthEffectFeature = {}
function VehicleHealthEffectFeature:_PostConstruct()
  VehicleHealthEffectFeature.__super._PostConstruct(self)
  if Client then
    local eventDelegate = self.Owner.OnVehicleHealthStateChanged
    if eventDelegate then
      self:AddControlEvent(self.Owner, "OnVehicleHealthStateChanged", self.OnHealthStateChange, self)
    end
  end
end
function VehicleHealthEffectFeature:OnHealthStateChange(NewState)
  if not slua.isValid(self.Owner.Object) then
    return
  end
  local ESTExtraVehicleHealthState = import("ESTExtraVehicleHealthState")
  if NewState then
    if NewState == ESTExtraVehicleHealthState.VHS_Good then
      self.Owner:DeactiveEffect("Smoke")
      self.Owner:DeactiveEffect("Fire")
      self.Owner:DeactiveEffect("Destroyed")
    elseif NewState == ESTExtraVehicleHealthState.VHS_Smoking then
      self.Owner:ActiveEffectAsync("Smoke")
      self.Owner:DeactiveEffect("Fire")
      self.Owner:DeactiveEffect("Destroyed")
    elseif NewState == ESTExtraVehicleHealthState.VHS_Burning then
      self.Owner:ActiveEffectAsync("Smoke")
      self.Owner:ActiveEffectAsync("Fire")
      self.Owner:DeactiveEffect("Destroyed")
    elseif NewState == ESTExtraVehicleHealthState.VHS_Destroyed then
      self.Owner:ActiveEffectAsync("Smoke")
      self.Owner:ActiveEffectAsync("Destroyed")
      self.Owner:DeactiveEffect("Fire")
    elseif NewState == ESTExtraVehicleHealthState.VHS_Exploded then
      self.Owner:ActiveEffectAsync("Smoke")
      self.Owner:ActiveEffectAsync("Fire")
      self.Owner:DeactiveEffect("Destroyed")
    end
  end
end
local class = require("class")
local CFeature = require("GameLua.Mod.BaseMod.Gameplay.Feature.Common.FeatureBase")
return class(CFeature, nil, VehicleHealthEffectFeature)