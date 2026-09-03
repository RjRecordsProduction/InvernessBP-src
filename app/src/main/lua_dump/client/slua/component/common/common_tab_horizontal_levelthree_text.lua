local common_tab_horizontal_levelthree_text = {}
function common_tab_horizontal_levelthree_text:ctor(_, config)
  common_tab_horizontal_levelthree_text.__super.ctor(self, _, config)
  local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
  local Style = SettingStyleLibrary.H3Style
  if self.bDarkMode then
    Style = SettingStyleLibrary.H3Style_Dark
  end
  self:_SetStyle(Style)
end
function common_tab_horizontal_levelthree_text:_GetTextItemConfig()
  return UIManager.UI_Config.Common_Tab_Horizontal_LevelThree_Text_Item_UIBP
end
local class = require("class")
local ui_base = require("client.slua.component.common.common_tab_horizontal_text_base")
local Ccommon_tab_horizontal_levelthree_text = class(ui_base, nil, common_tab_horizontal_levelthree_text)
return Ccommon_tab_horizontal_levelthree_text