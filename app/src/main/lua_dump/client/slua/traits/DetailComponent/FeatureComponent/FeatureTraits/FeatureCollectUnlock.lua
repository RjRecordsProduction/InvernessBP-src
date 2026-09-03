local FeatureCollectUnlock = {}
local Trait = require("common.trait")
local TFeatureCollectUnlock = Trait(Trait.TraitPrototype, nil, FeatureCollectUnlock)
function FeatureCollectUnlock:ShowCollectUnlockTips(data, widget)
  self:NotifyOtherFeatureStop(data)
  if UIManager.GetUI(UIManager.UI_Config.CollectUnlockComponent) then
    UIManager.CloseUI(UIManager.UI_Config.CollectUnlockComponent)
  end
  UIManager.ShowUI(UIManager.UI_Config.CollectUnlockComponent, self.curFeaturesItemID, data)
end
function FeatureCollectUnlock:StopCollectUnlockTips()
  if UIManager.GetUI(UIManager.UI_Config.CollectUnlockComponent) then
    UIManager.CloseUI(UIManager.UI_Config.CollectUnlockComponent)
  end
end
return TFeatureCollectUnlock