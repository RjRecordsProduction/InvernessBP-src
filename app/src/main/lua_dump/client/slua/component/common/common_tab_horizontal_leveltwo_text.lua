local common_tab_horizontal_leveltwo_text = {}
function common_tab_horizontal_leveltwo_text:ctor(_, config)
  common_tab_horizontal_leveltwo_text.__super.ctor(self, _, config)
  local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
  local Style = SettingStyleLibrary.H2Style
  if self.bDarkMode then
    Style = SettingStyleLibrary.H2Style_Dark
  end
  self:_SetStyle(Style)
end
function common_tab_horizontal_leveltwo_text:_GetTextItemConfig()
  return UIManager.UI_Config.Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP
end
local class = require("class")
local ui_base = require("client.slua.component.common.common_tab_horizontal_text_base")
local CCommon_Tab_Horizontal_LevelTwo_Text = class(ui_base, nil, common_tab_horizontal_leveltwo_text)
return CCommon_Tab_Horizontal_LevelTwo_Text