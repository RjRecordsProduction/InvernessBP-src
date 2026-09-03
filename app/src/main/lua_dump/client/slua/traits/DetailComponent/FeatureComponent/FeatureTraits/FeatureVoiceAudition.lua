local FeatureVoiceAudition = {}
local Trait = require("common.trait")
local TFeatureVoiceAudition = Trait(Trait.TraitPrototype, nil, FeatureVoiceAudition)
function FeatureVoiceAudition:InitFeatureVoiceList(featureCfg)
  local StringUtil = require("common.string_util")
  self.HallFeatureVoiceList = {}
  if featureCfg.config.HallFeatureVoiceList ~= "" then
    for i, v in pairs(StringUtil.Split(featureCfg.config.HallFeatureVoiceList, "|")) do
      table.insert(self.HallFeatureVoiceList, tonumber(v))
    end
  end
  self.BattleFeatureVoiceList = {}
  if featureCfg.config.BattleFeatureVoiceList ~= "" then
    for i, v in pairs(StringUtil.Split(featureCfg.config.BattleFeatureVoiceList, "|")) do
      table.insert(self.BattleFeatureVoiceList, tonumber(v))
    end
  end
end
function FeatureVoiceAudition:ShowVoicePackInfoHall()
  UIManager.ShowUI(UIManager.UI_Config.store_voice_pack_panel, self.nItemID, self.HallFeatureVoiceList, self.BattleFeatureVoiceList, 1)
end
function FeatureVoiceAudition:ShowVoicePackInfoBattle()
  UIManager.ShowUI(UIManager.UI_Config.store_voice_pack_panel, self.nItemID, self.HallFeatureVoiceList, self.BattleFeatureVoiceList, 2)
end
function FeatureVoiceAudition:ShowVoicePackInfoDefault()
  UIManager.ShowUI(UIManager.UI_Config.store_voice_pack_panel, self.nItemID, self.HallFeatureVoiceList, self.BattleFeatureVoiceList, 0)
end
return TFeatureVoiceAudition