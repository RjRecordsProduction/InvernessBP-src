local FeatureAliasEnterBroadcast = {}
local Trait = require("common.trait")
local TFeatureAliasEnterBroadcast = Trait(Trait.TraitPrototype, nil, FeatureAliasEnterBroadcast)
function FeatureAliasEnterBroadcast:PlayEnterBroadcast(data)
  self:StopAllFeature()
  self.isShowingBroadcast = true
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_ALIAS_ENTER_BROADCAST, self.curFeaturesItemID)
end
function FeatureAliasEnterBroadcast:StopEnterBroadcast()
  self.isShowingBroadcast = false
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_ALIAS_CLEAR_ENTER_BROADCAST)
end
function FeatureAliasEnterBroadcast:IsShowingEnterBroadcastPreview()
  return self.isShowingBroadcast or false
end
return TFeatureAliasEnterBroadcast