local Setting_Item_Recommend = {}
function Setting_Item_Recommend:OnPostInitialize()
  if self.UIRoot and self.UIRoot.Slot then
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, Setting_Item_Recommend)