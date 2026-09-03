local style_factory = {}
style_factory.StylePathMapping = {
  [1] = "/Game/UMG/UI_BP/Common/Common_Item_Style1_UIBP.Common_Item_Style1_UIBP",
  [2] = "/Game/UMG/UI_BP/Common/Common_Item_Style2_UIBP.Common_Item_Style2_UIBP",
  [3] = "/Game/UMG/UI_BP/Wardrobe/Expression_BigItem_UIBP.Expression_BigItem_UIBP",
  [4] = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_GunDetailItem_UIBP.Wardrobe_GunDetailItem_UIBP",
  [5] = "/Game/UMG/UI_BP/Common/Common_Item_Style3_UIBP.Common_Item_Style3_UIBP",
  [6] = "/Game/UMG/UI_BP/Common/Common_Item_Style5_UIBP.Common_Item_Style5_UIBP",
  [7] = "/Game/UMG/UI_BP/Common/Common_Item_Style6_UIBP.Common_Item_Style6_UIBP",
  [8] = "/Game/UMG/UI_BP/Common/Common_Item_Style4_UIBP.Common_Item_Style4_UIBP",
  [9] = "/Game/Mod/TPlan/XMission/UMG/Item/Common_Item_Wardrobe_Xmission_UIBP.Common_Item_Wardrobe_Xmission_UIBP",
  [10] = "/Game/UMG/UI_BP/Common/Common_Item_Style_Adaptive_UIBP.Common_Item_Style_Adaptive_UIBP"
}
local CStyleOne = require("client.slua.component.item.style_one")
local CStyleTwo = require("client.slua.component.item.style_two")
local CStyleExpression = require("client.slua.component.item.style_expression")
local CStyleWeapon = require("client.slua.component.item.style_weapon")
local CStyleThree = require("client.slua.component.item.style_three")
local CStyleTickets = require("client.slua.component.item.style_tickets")
local CStyleSix = require("client.slua.component.item.style_six")
local CStyleFour = require("client.slua.component.item.style_four")
local CXMissionWardrobeItem = require("client.slua.component.item.base_style")
local CStyleAdaptive = require("client.slua.component.item.style_two")
local CStylePHome = require("client.slua.component.item.style_phome")
local StyleOperatorMapping = {
  [1] = CStyleOne(),
  [2] = CStyleTwo(),
  [3] = CStyleExpression(),
  [4] = CStyleWeapon(),
  [5] = CStyleThree(),
  [6] = CStyleTickets(),
  [7] = CStyleSix(),
  [8] = CStyleFour(),
  [9] = CXMissionWardrobeItem(),
  [10] = CStyleAdaptive(),
  [11] = CStylePHome()
}
function style_factory.GetStyleOperator(style)
  return StyleOperatorMapping[style]
end
return style_factory