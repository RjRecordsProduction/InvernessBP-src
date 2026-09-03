local Setting_Title = {}
local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
local GeneralMargin = SettingStyleLibrary.GeneralMargin
function Setting_Title:OnInitialize()
  self.UIRoot.Text:SetText(LocUtil.GetLocalizeResStr(self.Data.Text))
  if self.UIRoot.Slot and self.UIRoot.Slot.SetPadding then
    self.UIRoot.Slot:SetPadding(GeneralMargin)
  end
  self:SetupHelpButton(self.UIRoot.Button_Help)
end
local class = require("class")
local Setting_Item_Base = require("client.slua.umg.NewSetting.Item.Setting_Item_Base")
return class(Setting_Item_Base, nil, Setting_Title)