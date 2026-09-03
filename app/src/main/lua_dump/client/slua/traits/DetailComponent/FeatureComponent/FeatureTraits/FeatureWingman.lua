local FeatureWingman = {}
local Trait = require("common.trait")
local TFeatureWingman = Trait(Trait.TraitPrototype, nil, FeatureWingman)
function FeatureWingman:PlayWingmanEnterTeamShow(data)
  self:NotifyOtherFeatureStop(data)
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_PLAY_WINGMAN_TEAMUP)
end
function FeatureWingman:StopWingmanEnterTeamShow()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_STOP_WINGMAN_TEAMUP)
end
return TFeatureWingman