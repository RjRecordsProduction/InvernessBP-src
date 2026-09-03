local FeaturePetEmotion = {}
local Trait = require("common.trait")
local TFeaturePetEmotion = Trait(Trait.TraitPrototype, nil, FeaturePetEmotion)
function FeaturePetEmotion:PlayPetEmotion(data)
  self:StopAllFeature()
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  StoreUtils.OnClickPetAction(data.config.StoreClickAction)
end
return TFeaturePetEmotion