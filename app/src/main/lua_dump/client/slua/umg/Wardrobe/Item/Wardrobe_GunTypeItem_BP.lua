local Wardrobe_GunTypeItem_BP = {}
function Wardrobe_GunTypeItem_BP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Item, self.OnClicked, self)
end
function Wardrobe_GunTypeItem_BP:OnRefresh(data, selectIndex)
  local ParentUI = self:GetLoopScrollBoxParentUI()
  if ParentUI then
    ParentUI:OnRefreshGunListItem(self.UIRoot, self.index, self)
  end
end
function Wardrobe_GunTypeItem_BP:OnClicked()
  local ParentUI = self:GetLoopScrollBoxParentUI()
  if ParentUI then
    ParentUI:OnClickGunListItem(self.UIRoot, self.index, self)
  end
end
local class = require("class")
local scroll_box_child_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CWardrobe_GunTypeItem_BP = class(scroll_box_child_base, nil, Wardrobe_GunTypeItem_BP)
return CWardrobe_GunTypeItem_BP