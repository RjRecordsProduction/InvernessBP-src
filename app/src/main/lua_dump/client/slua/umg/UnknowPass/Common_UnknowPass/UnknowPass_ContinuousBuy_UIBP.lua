local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
local ENUM_BUY_TYPE = UnknowPassMacro.ENUM_BUY_TYPE
local templatePath = "/Game/UMG/Texture/Lobby_NoAtlas/Common/UnknowPass/%s.%s"
local ImagePath = {
  [ENUM_BUY_TYPE.Normal] = "RPA_Record_Icon_LV_None",
  [ENUM_BUY_TYPE.Better] = "RPA_Record_Icon_LV_Better",
  [ENUM_BUY_TYPE.Best] = "RPA_Record_Icon_LV_Better"
}
local UnknowPass_ContinuousBuy_UIBP = {}
function UnknowPass_ContinuousBuy_UIBP:_InitView(param_data)
  local nPassType = param_data.nPassType
  local nShowEffect = param_data.nShowEffect
  local sImagePath = string.format(templatePath, ImagePath[nPassType], ImagePath[nPassType])
  self:SetImage(sImagePath)
  self:SetEffect(nPassType == ENUM_BUY_TYPE.Best and nShowEffect == 1)
end
local class = require("class")
local UnknowPass_ContinuousBuy_Base_UIBP = require("client.slua.umg.UnknowPass.Common_UnknowPass.UnknowPass_ContinuousBuy_Base_UIBP")
return class(UnknowPass_ContinuousBuy_Base_UIBP, nil, UnknowPass_ContinuousBuy_UIBP)