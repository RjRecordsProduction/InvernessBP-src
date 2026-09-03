local extended_loop_scroll_box_subItem_base = {}
function extended_loop_scroll_box_subItem_base:OnSubRefresh(data, selectIndex, subSelectIndex)
end
function extended_loop_scroll_box_subItem_base:IsSelected()
  local loop = self:GetLoopScrollBox()
  local selectIndex = loop:GetSelectIndex()
  local subSelectIndex = loop:GetSubSelectIndex()
  return selectIndex == self.index and subSelectIndex == self.subIndex
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CUITemplate = class(ui_base, nil, extended_loop_scroll_box_subItem_base)
return CUITemplate