local FeatureWeaponEmotion = {}
local Trait = require("common.trait")
local TFeatureWeaponEmotion = Trait(Trait.TraitPrototype, nil, FeatureWeaponEmotion)
function FeatureWeaponEmotion:PlayWeaponEmotion(data)
  log(bWriteLog and "[edward][store_feature_component] PlayWeaponEmotion")
  self:NotifyOtherFeatureStop(data)
  self:StopWeaponEmotion()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.SwitchToAvatar()
  if data.config.ExpressionID and data.config.ExpressionID > 0 and ModelDisplayer.GetShowingAvatar() then
    local bEquip = ModelDisplayer.GetShowingAvatar():HasEquiped(self.curFeaturesItemID)
    if bEquip then
      local StoreUtils = require("client.slua.logic.store.utils.store_utils")
      StoreUtils.PlayEmotion(data.config.ExpressionID)
      self.bIsPlayingWeaponEmotion = true
    end
  end
end
function FeatureWeaponEmotion:StopWeaponEmotion()
  if self.bIsPlayingWeaponEmotion then
    self:StopEmotion()
    self.bIsPlayingWeaponEmotion = false
  end
end
return TFeatureWeaponEmotion