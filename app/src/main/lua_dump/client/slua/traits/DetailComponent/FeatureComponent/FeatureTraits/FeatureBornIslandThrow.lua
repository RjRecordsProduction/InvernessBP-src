local FeatureBornIslandThrow = {}
local Trait = require("common.trait")
local TFeatureBornIslandThrow = Trait(Trait.TraitPrototype, nil, FeatureBornIslandThrow)
function FeatureBornIslandThrow:DisplayBornIslandThrow(data, widget)
  self:NotifyOtherFeatureStop(data)
  ShowNotice(66016)
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  logic_store_enter_feature:PlayOnceNormalEmotion(data, self.curFeaturesItemID)
end
function FeatureBornIslandThrow:StopBornIslandThrow(_, dontStopAction)
  if dontStopAction then
    return
  end
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  logic_store_enter_feature:StopEmotion()
end
return TFeatureBornIslandThrow