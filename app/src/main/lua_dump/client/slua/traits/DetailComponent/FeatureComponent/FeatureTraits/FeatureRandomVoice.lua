local FeatureRandomVoice = {}
local Trait = require("common.trait")
local TFeatureRandomVoice = Trait(Trait.TraitPrototype, nil, FeatureRandomVoice)
function FeatureRandomVoice:PlayRandomVoice(data)
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_PLAY_RANDOM_VOICE)
end
function FeatureRandomVoice:StopRandomVoice()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_STOP_RANDOM_VOICE)
end
return TFeatureRandomVoice