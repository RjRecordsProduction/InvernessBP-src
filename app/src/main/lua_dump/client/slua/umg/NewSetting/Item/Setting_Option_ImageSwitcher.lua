local Setting_Option_ImageSwitcher = {}
local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
function Setting_Option_ImageSwitcher:SetupOptionItemWidget()
  local SwitcherText = self.Data.SwitcherText or SettingStyleLibrary.DefaultSwitcherText
  if SwitcherText then
    local OptionCount = #SwitcherText
    self.UIRoot.Switcher:CreateOptions(OptionCount)
    for Idx = 0, OptionCount - 1 do
      local SwitcherItemUI = self.UIRoot.Switcher:GetOption(Idx)
      if slua.isValid(SwitcherItemUI) then
        SwitcherItemUI.Text:SetText(LocUtil.GetLocalizeResStr(SwitcherText[Idx + 1]))
        if assert(self.Data.SwitcherImage and self.Data.SwitcherImage[Idx + 1], string.format("Setting_Option_ImageSwitcher:SetupOptionItemWidget Key %s Insufficient Image", self.Data.Key)) then
          SwitcherItemUI.Image_Content:SetBrushFromPathAsync(self.Data.SwitcherImage[Idx + 1], false)
        end
        self:SetupRecommendItems(SwitcherItemUI, Idx)
      end
    end
  end
end
local class = require("class")
local Setting_Option_Switcher = require("client.slua.umg.NewSetting.Item.Setting_Option_Switcher")
return class(Setting_Option_Switcher, nil, Setting_Option_ImageSwitcher)