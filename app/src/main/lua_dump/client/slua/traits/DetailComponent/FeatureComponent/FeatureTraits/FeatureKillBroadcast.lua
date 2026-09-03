local FeatureKillBroadcast = {}
local Trait = require("common.trait")
local TFeatureKillBroadcast = Trait(Trait.TraitPrototype, nil, FeatureKillBroadcast)
function FeatureKillBroadcast:PlayKillBroadcast(data)
  self:NotifyOtherFeatureStop(data)
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_KILL_BROADCAST)
  if self.killBroadcastTimer then
    self:RemoveTimer(self.killBroadcastTimer)
  end
  self.killBroadcastTimer = self:AddTimerOnce(4, function()
    self:StopKillBroadcast()
  end)
end
function FeatureKillBroadcast:StopKillBroadcast()
  EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_CLEAR_KILL_BROADCAST)
end
function FeatureKillBroadcast:PlayKillBroadcastFull(data)
  self:NotifyOtherFeatureStop(data)
  if not self.ui_item_upgrade_effect then
    self.ui_item_upgrade_effect = UIManager.ShowUI(UIManager.UI_Config.item_upgrade_effect)
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Hide()
  self.ui_item_upgrade_effect:ShowBroadcastEffectByResId(self.nCurShowModelId)
  if self.killBroadcastTimer then
    self:RemoveTimer(self.killBroadcastTimer)
  end
  self.killBroadcastTimer = self:AddTimerOnce(4, function()
    self:StopKillBroadcastFull()
  end)
end
function FeatureKillBroadcast:StopKillBroadcastFull(bHideModel)
  if self.ui_item_upgrade_effect then
    self.ui_item_upgrade_effect:CloseSelf()
    self.ui_item_upgrade_effect = nil
  end
  if not bHideModel then
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    ModelDisplayer.Show()
  end
end
return TFeatureKillBroadcast