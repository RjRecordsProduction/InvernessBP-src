local FeatureCollectUnlock = {}
local Trait = require("common.trait")
local TFeatureCollectUnlock = Trait(Trait.TraitPrototype, nil, FeatureCollectUnlock)
local curCfg
function FeatureCollectUnlock:ShowChangeColorWeapon(data, widget)
  self:NotifyOtherFeatureStop(data)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local Avatar = ModelDisplayer.GetShowingAvatar()
  if Avatar then
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    curCfg = StoreUtils.GetChangeColorWeaponCfg(self.curFeaturesItemID, data.config.ID)
    if curCfg then
      local weaponID = curCfg.originEndWeapon
      local actionID = curCfg.originAction
      ModelDisplayer.Display(weaponID, true)
      ModelDisplayer.Display(actionID, true)
      self:AddTimer(0, function()
        EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_DETAIL_REF_ITEM_EQUIPPED)
      end)
      if UIManager.GetUI(UIManager.UI_Config.CollectUnlockComponent) then
        UIManager.CloseUI(UIManager.UI_Config.CollectUnlockComponent)
      end
      UIManager.ShowUI(UIManager.UI_Config.CollectUnlockComponent, self.curFeaturesItemID, data)
    end
  end
end
function FeatureCollectUnlock:StopChangeColorWeapon()
  log(bWriteLog and "[SY]FeatureCollectUnlock:StopChangeColorWeapon.")
  if UIManager.GetUI(UIManager.UI_Config.CollectUnlockComponent) then
    UIManager.CloseUI(UIManager.UI_Config.CollectUnlockComponent)
  end
end
return TFeatureCollectUnlock