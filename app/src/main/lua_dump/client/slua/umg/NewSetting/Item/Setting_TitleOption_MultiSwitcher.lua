local Setting_TitleOption_MultiSwitcher = {}
function Setting_TitleOption_MultiSwitcher:OnInitialize()
  Setting_TitleOption_MultiSwitcher.__super.OnInitialize(self)
  local Count = self.UIRoot.Switcher.OptionNum
  local Height = self.Data.Height
  local Width = self.Data.Width
  for Idx = 0, Count - 1 do
    local SwitcherItemUI = self.UIRoot.Switcher:GetOption(Idx)
    if slua.isValid(SwitcherItemUI) then
      if Height then
        SwitcherItemUI.SizeBox:SetHeightOverride(Height)
      else
        SwitcherItemUI.SizeBox:ClearHeightOverride()
      end
      if Width then
        SwitcherItemUI.SizeBox:SetWidthOverride(Width)
      else
        SwitcherItemUI.SizeBox:ClearWidthOverride()
      end
    end
  end
end
function Setting_TitleOption_MultiSwitcher:SetupOptionItemWidget()
  local SwitcherText = self.Data.SwitcherText
  if SwitcherText then
    local OptionCount = #SwitcherText
    local Height = self.Data.Height
    local Width = self.Data.Width
    self.UIRoot.Switcher:CreateOptions(OptionCount)
    for Idx = 0, OptionCount - 1 do
      local SwitcherItemUI = self.UIRoot.Switcher:GetOption(Idx)
      if slua.isValid(SwitcherItemUI) then
        SwitcherItemUI.Text:SetText(LocUtil.GetLocalizeResStr(SwitcherText[Idx + 1]))
        if Height then
          SwitcherItemUI.SizeBox:SetHeightOverride(Height)
        else
          SwitcherItemUI.SizeBox:ClearHeightOverride()
        end
        if Width then
          SwitcherItemUI.SizeBox:SetWidthOverride(Width)
        else
          SwitcherItemUI.SizeBox:ClearWidthOverride()
        end
      end
    end
  end
end
local class = require("class")
local Setting_Option_Switcher = require("client.slua.umg.NewSetting.Item.Setting_Option_Switcher")
return class(Setting_Option_Switcher, nil, Setting_TitleOption_MultiSwitcher)