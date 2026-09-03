local FeaturePetFeature = {}
local Trait = require("common.trait")
local TFeaturePetFeature = Trait(Trait.TraitPrototype, nil, FeaturePetFeature)
function FeaturePetFeature:PlayPetFeature()
  self:NotifyOtherFeatureStop()
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  StoreUtils.PlayPetFeature(true)
end
return TFeaturePetFeature