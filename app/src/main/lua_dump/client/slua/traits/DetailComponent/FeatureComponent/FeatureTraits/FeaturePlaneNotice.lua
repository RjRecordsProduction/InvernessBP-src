local FeaturePlaneNotice = {}
local Trait = require("common.trait")
local TFeaturePlaneNotice = Trait(Trait.TraitPrototype, nil, FeaturePlaneNotice)
function FeaturePlaneNotice:PlayPlaneNotice(data)
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_PLANE_NOTICES)
end
function FeaturePlaneNotice:StopPlaneNotice()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_CLEAR_PLANE_NOTICES)
end
return TFeaturePlaneNotice