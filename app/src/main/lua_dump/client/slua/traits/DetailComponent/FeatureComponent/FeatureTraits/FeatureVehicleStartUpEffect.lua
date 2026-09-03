local FeatureVehicleStartUpEffect = {}
local Trait = require("common.trait")
local TFeatureVehicleStartUpEffect = Trait(Trait.TraitPrototype, nil, FeatureVehicleStartUpEffect)
function FeatureVehicleStartUpEffect:PlayVehicleStartUpEffect(data)
  self:NotifyOtherFeatureStop(data)
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_VEHICLE_STARTUP_EFFECT, true)
end
function FeatureVehicleStartUpEffect:StopVehicleStartUpEffect()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_VEHICLE_STARTUP_EFFECT, false)
end
return TFeatureVehicleStartUpEffect