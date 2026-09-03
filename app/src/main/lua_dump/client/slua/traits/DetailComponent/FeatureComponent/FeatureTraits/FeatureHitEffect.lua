local FeatureHitEffect = {}
local Trait = require("common.trait")
local TFeatureHitEffect = Trait(Trait.TraitPrototype, nil, FeatureHitEffect)
function FeatureHitEffect:PlayHitEffect(data)
  local hitEffectPath = data.config.HitEffect
  if hitEffectPath == nil or hitEffectPath == "" then
    return
  end
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsPufferDownloadedByPathList({hitEffectPath}, true) then
    log(bWriteLog and "FeatureHitEffect:PlayHitEffect HitEffect is not downloaded")
    return
  end
  self:StopAllFeature()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_HIDE_VIEW_COMPONENT, false)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Hide()
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  local hitEffectLocation = ConstAvatarDislay.GetSpawnLocationByHitEffect(self.curScene)
  local hitEffectRotation = FRotator(0, 0, 0)
  local effectDuration = data.config.EffectDuration
  if effectDuration == nil or effectDuration == 0 then
    effectDuration = 1
  end
  local asset_util = require("common.asset_util")
  self.isPlayingHitEffect = true
  self.hitEffectTimer = self:AddTimerLoop(0, function()
    local hitEffectParticle = asset_util.GetAssetSync(hitEffectPath)
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    STExtraBlueprintFunctionLibrary.SpawnCustomEmitterAtLocation(slua_GameFrontendHUD:GetWorld(), hitEffectParticle, hitEffectLocation, hitEffectRotation, true)
  end, TIMER_INFINITE, effectDuration)
end
function FeatureHitEffect:StopHitEffect(close)
  if self.hitEffectTimer then
    self:RemoveTimer(self.hitEffectTimer)
    self.hitEffectTimer = nil
  end
  if not close and self.isPlayingHitEffect == true and self.curFeaturesItemID and self.curFeaturesItemID > 0 then
    EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_HIDE_VIEW_COMPONENT, true)
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    ModelDisplayer.Show()
    self:SetWeaponAutoRotate()
  end
  self.isPlayingHitEffect = nil
end
return TFeatureHitEffect