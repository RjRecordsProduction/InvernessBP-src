local subtab_props_all = {}
function subtab_props_all:ctor()
end
function subtab_props_all:CheckCurrentPage(v, serverTime)
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
  local subTabGroup = {
    [macroTabString.ENUM_WardrobeSubTabString_items] = true,
    [macroTabString.ENUM_WardrobeSubTabString_voucher] = true,
    [macroTabString.Enum_WardrobeSubTabString_Materials] = true,
    [macroTabString.Enum_WardrobeSubTabString_SpaceGift] = true,
    [macroTabString.Enum_WardrobeSubTabString_Packages] = true
  }
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if WardrobeLogicManager:IsValidCurrentPageItemBySubTabGroup(self.subTabConfig.pageId, subTabGroup, v, serverTime) then
    return true
  end
  return false
end
local class = require("class")
local ui_subtab_item_list_base = require("client.slua.umg.Wardrobe.subtab_props")
local CWardrobeProps = class(ui_subtab_item_list_base, nil, subtab_props_all)
return CWardrobeProps