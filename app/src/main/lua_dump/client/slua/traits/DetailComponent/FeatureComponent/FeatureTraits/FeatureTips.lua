local FeatureTips = {}
local Trait = require("common.trait")
local TFeatureTips = Trait(Trait.TraitPrototype, nil, FeatureTips)
function FeatureTips:ShowFeatureTips(data, widget)
  local text = data.config.BtnDesc or ""
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.common_float_tips)
  local TipsParam = {offsetX = 55, offsetY = -30}
  tipsUI:SetTips(widget, text, TipsParam)
end
function FeatureTips:ShowFeatureTipsAndContent(data, widget)
  self:NotifyOtherFeatureStop(data)
  local tipsParam = {
    widget = widget,
    title = data.featureName or "",
    subTitle = nil,
    content = data.featureDes,
    content2 = nil,
    jumpText = nil,
    jumpCallback = nil,
    jumpParams = nil,
    detailText = nil,
    detailCallback = nil,
    detailParams = nil,
    offsetX = nil,
    offsetY = nil
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Other_Tips_UIBP, tipsParam)
end
return TFeatureTips