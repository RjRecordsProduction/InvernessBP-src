local FeatureBattleDamage = {}
local Trait = require("common.trait")
local TFeatureBattleDamage = Trait(Trait.TraitPrototype, nil, FeatureBattleDamage)
function FeatureBattleDamage:PlayBattleDamage(data)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local curAvatar = ModelDisplayer.GetShowingAvatar()
  if curAvatar == nil or curAvatar:GetModel() == nil then
    return
  end
  local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
  if self.BackTimer then
    return
  end
  EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_APPLY, curAvatar:GetModel(), ECharacterEffectTriggerCondition.LobbyDisplay_LowHealth)
  self.BackTimer = self:AddTimerOnce(3, function()
    self.BackTimer = nil
    if curAvatar == nil or curAvatar:GetModel() == nil then
      return
    end
    EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_APPLY, curAvatar:GetModel(), ECharacterEffectTriggerCondition.LobbyDisplay_HighHealth)
  end)
end
function FeatureBattleDamage:StopBattleDamage()
  if self.BackTimer then
    self:RemoveTimer(self.BackTimer)
    self.BackTimer = nil
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local curAvatar = ModelDisplayer.GetShowingAvatar()
  if curAvatar == nil or curAvatar:GetModel() == nil then
    return
  end
  local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
  EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_APPLY, curAvatar:GetModel(), ECharacterEffectTriggerCondition.LobbyDisplay_HighHealth)
  EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_CLEAR, curAvatar:GetModel(), ECharacterEffectTriggerCondition.LobbyDisplay_LowHealth)
  EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_CLEAR, curAvatar:GetModel(), ECharacterEffectTriggerCondition.LobbyDisplay_HighHealth)
end
return TFeatureBattleDamage