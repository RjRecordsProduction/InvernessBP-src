local FeatureCombineFeature = {}
local Trait = require("common.trait")
local TFeatureCombineFeature = Trait(Trait.TraitPrototype, nil, FeatureCombineFeature)
local StoreUtils = require("client.slua.logic.store.utils.store_utils")
function FeatureCombineFeature:ShowCombineFeature(data, widget)
  local FeatureIDList = {}
  local config = CDataTable.GetTableData("CombineFeature", data.config.ID)
  if config then
    FeatureIDList = config.SubFeatureList_a or {}
  end
  local SubFeatureList = {}
  for _, featureID in pairs(FeatureIDList) do
    local featureCfg = CDataTable.GetTableData("FeaturesConfig", featureID)
    if featureCfg then
      local featureData = StoreUtils.GetFeatureData(featureCfg, data.itemType, data.itemSubType, data.enableCameraAnim, data.minLv)
      if featureData then
        featureData.        featureData.curFeaturesItemID = self.curFeaturesItemID
        featureData.featureComponentHost = self
        SubFeatureList[#SubFeatureList + 1] = featureData
      end
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.FeatureItem_Name_Bp, SubFeatureList, widget, config.type, self)
end
function FeatureCombineFeature:HideCombineFeature(close, dontStopAction)
  UIManager.CloseUI(UIManager.UI_Config.FeatureItem_Name_Bp)
end
return TFeatureCombineFeature