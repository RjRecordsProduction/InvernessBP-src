local CommonItem_ChildUIBase = {}
function CommonItem_ChildUIBase:ctor()
end
function CommonItem_ChildUIBase:OnInitialize()
  CommonItem_ChildUIBase.__super.OnInitialize(self)
end
function CommonItem_ChildUIBase:OnPostInitialize()
  CommonItem_ChildUIBase.__super.OnPostInitialize(self)
  self:RestoreUIOperation()
end
function CommonItem_ChildUIBase:OnClose()
  CommonItem_ChildUIBase.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua.component.item.ItemChildren.CommonItem_UIBase")
local CCommonItem_ChildUIBase = class(ui_base, nil, CommonItem_ChildUIBase)
return CCommonItem_ChildUIBase