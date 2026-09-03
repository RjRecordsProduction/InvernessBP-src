local FeatureSwitchWeaponEffect = {}
local Trait = require("common.trait")
local TFeatureSwitchWeaponEffect = Trait(Trait.TraitPrototype, nil, FeatureSwitchWeaponEffect)
function FeatureSwitchWeaponEffect:PlaySwitchWeaponEffect(data)
  log(bWriteLog and "FeatureSwitchWeaponEffect:PlayWeaponEmotion")
  self:NotifyOtherFeatureStop(data)
  self:StopWeaponEmotion()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.SwitchToAvatar()
  if ModelDisplayer.GetShowingAvatar() then
    local bEquip = ModelDisplayer.GetShowingAvatar():HasEquiped(self.curFeaturesItemID)
    if bEquip then
      local StoreUtils = require("client.slua.logic.store.utils.store_utils")
      StoreUtils.PlayEmotion(12219843)
      self.bIsPlayingWeaponEmotion = true
    end
  end
end
function FeatureSwitchWeaponEffect:StopSwitchWeaponEffect()
  log(bWriteLog and "FeatureSwitchWeaponEffect:StopSwitchWeaponEffect")
  if self.bIsPlayingWeaponEmotion then
    self:StopEmotion()
    self.bIsPlayingWeaponEmotion = false
  end
end
return TFeatureSwitchWeaponEffect