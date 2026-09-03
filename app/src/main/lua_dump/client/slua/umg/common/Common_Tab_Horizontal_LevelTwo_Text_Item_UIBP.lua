local Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP = {}
function Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP:_InitLockShow()
  self:SetWidgetVisible(self.UIRoot.Image_Lock, false)
end
local class = require("class")
local ui_base = require("client.slua.umg.common.Common_Tab_Horizontal_Text_Item_Base")
local CCommon_Tab_Horizontal_LevelTwo_Text_Item_UIBP = class(ui_base, nil, Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP)
return CCommon_Tab_Horizontal_LevelTwo_Text_Item_UIBP