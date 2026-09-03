local FeaturePerformanceSwitch = {}
local Trait = require("common.trait")
local TFeaturePerformanceSwitch = Trait(Trait.TraitPrototype, nil, FeaturePerformanceSwitch)
function FeaturePerformanceSwitch:OnClickBtnPerform()
  self:PlayAudio(sound_config.click_v1)
  local titleText = LocUtil.GetLocalizeResStr(774797)
  local itemInfo = CDataTable.GetTableData("Item", self.curFeaturesItemID)
  local descText = LocUtil.LocalizeResFormat(774793, itemInfo.ItemName or "")
  local PlayAnimationFeatureInGameGuide = require("client.slua.umg.newbie_guide.PlayAnimationFeatureInGameGuide")
  local tTipsParams = {
    widget = self.UIRoot.LoopScrollGrid_Feature,
    title = titleText,
    content = descText,
    performance_switch = PlayAnimationFeatureInGameGuide.performance_switch,
    offsetX = self.UIRoot.LoopScrollGrid_Feature.Slot:GetSize().X,
    offsetY = self.UIRoot.LoopScrollGrid_Feature.Slot:GetSize().Y,
    bBottomToTop = true
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tTipsParams)
end
return TFeaturePerformanceSwitch