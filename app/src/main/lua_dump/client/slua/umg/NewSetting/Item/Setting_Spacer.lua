local Setting_Spacer = {}
function Setting_Spacer:OnInitialize()
end
local class = require("class")
local Setting_Item_Base = require("client.slua.umg.NewSetting.Item.Setting_Item_Base")
return class(Setting_Item_Base, nil, Setting_Spacer)