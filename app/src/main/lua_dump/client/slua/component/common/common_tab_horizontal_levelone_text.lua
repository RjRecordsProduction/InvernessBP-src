local common_tab_horizontal_levelone_text = {}
function common_tab_horizontal_levelone_text:ctor(_, config)
  common_tab_horizontal_levelone_text.__super.ctor(self, _, config)
  local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
  self.tabIconData = nil
  self.tabBgIcons = nil
  local Style = SettingStyleLibrary.H1Style
  if self.bDarkMode then
    Style = SettingStyleLibrary.H1Style_Dark
  end
  self:_SetStyle(Style)
end
function common_tab_horizontal_levelone_text:_GetTextItemConfig()
  if self.bInGame then
    self.selectColor = FSlateColor(FLinearColor(0.57, 1, 0.92, 1))
    self.unselectColor = FSlateColor(FLinearColor(1, 1, 1, 0.7))
    local inGameConfig = UIManager.UI_Config.Common_Tab_Horizontal_LevelOne_Text_Item_UIBP
    inGameConfig.path = "/Game/UMG/UI_BP/UGC/Common/Tab/Horizontal/LevelOne/Text/Item/Common_Tab_Horizontal_LevelOne_Text_Item_UIBP.Common_Tab_Horizontal_LevelOne_Text_Item_UIBP"
    return inGameConfig
  end
  return UIManager.UI_Config.Common_Tab_Horizontal_LevelOne_Text_Item_UIBP
end
function common_tab_horizontal_levelone_text:AddTabLabelNumCallback(func, funcSelf)
  if not func then
    self.tabLabelNumCb = nil
    return
  end
  function self.tabLabelNumCb(widget, index)
    return func(funcSelf, widget, index)
  end
end
function common_tab_horizontal_levelone_text:_UpdateTabItem(itemUIRoot, index)
  common_tab_horizontal_levelone_text.__super._UpdateTabItem(self, itemUIRoot, index)
  self:_UpdateTabNum(itemUIRoot, index)
  self:_UpdateTabMarkIcon(itemUIRoot, index)
  self:_UpdateSelectedIcon(itemUIRoot)
end
function common_tab_horizontal_levelone_text:_UpdateTabNum(itemUIRoot, index)
  local tabNum
  if self.tabLabelNumCb then
    tabNum = self.tabLabelNumCb(itemUIRoot, index)
  end
  local showTabNum = tabNum and 0 < tabNum
  if itemUIRoot and itemUIRoot.CanvasPanel_Lable then
    self:SetWidgetVisible(itemUIRoot.CanvasPanel_Lable, showTabNum)
    if showTabNum and itemUIRoot.TextBlock_1 then
      local UIUtil = require("client.common.ui_util")
      UIUtil.SetVietnamAutoCapitalizeText(itemUIRoot.TextBlock_1)
      itemUIRoot.TextBlock_1:SetText(tabNum)
    end
  end
end
function common_tab_horizontal_levelone_text:RefreshItemTabNum()
  if not self.childItemList then
    return
  end
  for k, v in pairs(self.childItemList) do
    self:_UpdateTabNum(v.UIRoot, k)
  end
end
function common_tab_horizontal_levelone_text:_UpdateTabMarkIcon(itemUIRoot, index)
  if not itemUIRoot then
    return
  end
  local sel, unSel = "", ""
  if self.tabIconData and self.tabIconData[index] then
    sel, unSel = self.tabIconData[index].select, self.tabIconData[index].unSelect
  end
  if sel ~= "" then
    self:SetTexture(itemUIRoot.Image_Mark, sel)
  end
  if unSel ~= "" then
    self:SetTexture(itemUIRoot.Image_UnMark, unSel)
  end
  self:SetWidgetVisible(itemUIRoot.SizeBox_Select, sel ~= "")
  self:SetWidgetVisible(itemUIRoot.SizeBox_Unselect, unSel ~= "")
end
function common_tab_horizontal_levelone_text:SetTabMarkIcon(icons)
  self.tabIconData = icons or {}
end
function common_tab_horizontal_levelone_text:_UpdateSelectedIcon(itemUIRoot)
  if not itemUIRoot then
    return
  end
  if not self.tabBgIcons then
    return
  end
  local selectedIcon = self.tabBgIcons.selected
  local unSelectedIcon = self.tabBgIcons.unSelected
  if selectedIcon and selectedIcon ~= "" then
    self:SetTexture(itemUIRoot.Image_CustomSelectBG, selectedIcon)
    self:SetWidgetVisible(itemUIRoot.Image_BG, false)
    self:SetWidgetVisible(itemUIRoot.Image_CustomSelectBG, true)
  end
  if unSelectedIcon and unSelectedIcon ~= "" then
    self:SetTexture(itemUIRoot.Image_CustomUnSelectBG, unSelectedIcon)
    self:SetWidgetVisible(itemUIRoot.Image_CustomUnSelectBG, true)
  end
end
function common_tab_horizontal_levelone_text:SetTabBgIcon(icons)
  self.tabBgIcons = icons or {}
end
local class = require("class")
local ui_base = require("client.slua.component.common.common_tab_horizontal_text_base")
local CCommon_Tab_Horizontal_LevelOne_Text = class(ui_base, nil, common_tab_horizontal_levelone_text)
return CCommon_Tab_Horizontal_LevelOne_Text