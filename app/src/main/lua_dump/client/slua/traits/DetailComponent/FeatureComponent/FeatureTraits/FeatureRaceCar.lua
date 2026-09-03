local FeatureRaceCar = {}
local Trait = require("common.trait")
local TFeatureRaceCar = Trait(Trait.TraitPrototype, nil, FeatureRaceCar)
function FeatureRaceCar:PlayRaceCarEnterTeamShow(data)
  self:NotifyOtherFeatureStop(data)
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_PLAY_RACE_CAR)
end
function FeatureRaceCar:StopRaceCarEnterTeamShow()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_STOP_RACE_CAR)
end
return TFeatureRaceCar