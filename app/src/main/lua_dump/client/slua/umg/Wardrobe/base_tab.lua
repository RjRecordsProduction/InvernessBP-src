local BaseTab = {}
function BaseTab:ctor(selfType, tabConfig)
  self.end
function BaseTab:OnClick()
  log(bWriteLog and "BaseTab:OnClick")
end
function BaseTab:InInheritMode()
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  if eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    return true
  end
  return false
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CBaseTab = class(ui_base, nil, BaseTab)
return CBaseTab