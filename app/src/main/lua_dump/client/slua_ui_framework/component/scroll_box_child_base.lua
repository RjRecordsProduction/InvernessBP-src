local scroll_box_child_base = {}
function scroll_box_child_base:ctor()
  self.index = nil
  self.data = nil
end
function scroll_box_child_base:OnRefresh(data, selectIndex)
end
function scroll_box_child_base:GetLoopScrollBox()
  return self:GetParentUI()
end
function scroll_box_child_base:GetLoopScrollBoxParentUI()
  return self:GetLoopScrollBox():GetParentUI()
end
function scroll_box_child_base:IsSelected()
  local selectIndex = self:GetLoopScrollBox():GetSelectIndex()
  return selectIndex == self.index
end
function scroll_box_child_base:GetClassName()
  if not self._className then
    local parentUI = self:GetParentUI()
    if parentUI then
      local classPath = parentUI._itemModuleName
      local base_config_util = require("client.common.uibase.base_config_util")
      self._className = base_config_util.GetClassName(classPath)
    end
  end
  return self._className or ""
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUITemplate = class(ui_base, nil, scroll_box_child_base)
return CUITemplate