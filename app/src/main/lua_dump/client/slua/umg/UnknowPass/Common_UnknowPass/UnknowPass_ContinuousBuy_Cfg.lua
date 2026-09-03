local UnknowPass_ContinuousBuy_Base_Cfg = {
  Enum_Clickable = 1,
  Enum_Effect = 2,
  Enum_Icon = 3,
  sDefaultRootName = "Canvas_Root"
}
local cfg = UnknowPass_ContinuousBuy_Base_Cfg
local CommonItem_ChildCfg = {
  [cfg.Enum_Clickable] = {
    bIsButton = true,
    sWidgetName = "Button_Item"
  },
  [cfg.Enum_Effect] = {
    sWidgetName = "Effect",
    sBpPath = "/Game/UMG/UI_BP/Common/UnknowPass_ContinuousBuy/UnknowPass_ContinuousBuy_Effect_UIBP.UnknowPass_ContinuousBuy_Effect_UIBP"
  },
  [cfg.Enum_Icon] = {sWidgetName = "Image_Icon"}
}
function UnknowPass_ContinuousBuy_Base_Cfg:GetChildConfig()
  return CommonItem_ChildCfg
end
function UnknowPass_ContinuousBuy_Base_Cfg:GetChildConfigByType(nChildType)
  local cfgs = self:GetChildConfig()
  return cfgs and cfgs[nChildType]
end
local Trait = require("common.trait")
local CUnknowPass_ContinuousBuy_Base_Cfg = Trait(Trait.TraitPrototype, nil, UnknowPass_ContinuousBuy_Base_Cfg)
return CUnknowPass_ContinuousBuy_Base_Cfg