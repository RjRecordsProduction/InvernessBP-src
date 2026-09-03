local common_tab_horizontal_small_text = {}
function common_tab_horizontal_small_text:ctor(_, config)
  common_tab_horizontal_small_text.__super.ctor(self, _, config)
  self.itemFixedWidth = 134.0
  self.itemFixedHeight = 40.0
  local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
  local Style = SettingStyleLibrary.H4Style_Dark
  self:_SetStyle(Style)
end
function common_tab_horizontal_small_text:_GetTextItemConfig()
  return UIManager.UI_Config.Common_Tab_Horizontal_Small_Text_Item_UIBP
end
local class = require("class")
local common_tab_horizontal_text_base = require("client.slua.component.common.common_tab_horizontal_text_base")
return class(common_tab_horizontal_text_base, nil, common_tab_horizontal_small_text)