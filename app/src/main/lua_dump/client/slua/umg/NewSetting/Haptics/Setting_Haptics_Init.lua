local Setting_Haptics = require("client.slua.umg.NewSetting.Haptics.Setting_Haptics_Config")
function Setting_Haptics:OnInitialize()
  print(bWriteLog and "Setting_Haptics:OnInitialize")
  self.curIndex = 1
  self.UIChild_Audio = nil
  self:InitSettingConfig()
  self.UIRoot.BTN:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  self.UIRoot.TextBlock_Button1_TitleOn:SetText(LocUtil.GetLocalizeResStr(200000454))
  self.UIRoot.TextBlock_Button1_TitleOff:SetText(LocUtil.GetLocalizeResStr(200000454))
  self.UIRoot.TextBlock_Button2_TitleOn:SetText(LocUtil.GetLocalizeResStr(36677))
  self.UIRoot.TextBlock_Button2_TitleOff:SetText(LocUtil.GetLocalizeResStr(36677))
  self:WidgetCollapse(self.UIRoot.TextBlock_Title)
  if IsWoWEditor then
    self:SetWidgetVisible(self.UIRoot.Button1, false)
  end
end
function Setting_Haptics:OnShow()
  print(bWriteLog and "Setting_Haptics:OnShow")
  self:RefreshMainLabel()
  self:UpdateUI()
end
function Setting_Haptics:OnClose()
  print(bWriteLog and "Setting_Haptics:OnClose")
end
function Setting_Haptics:InitSettingConfig()
  if not self.SettingConfig then
    self.SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  end
end
function Setting_Haptics:OnClickButton0()
  log(bWriteLog and "Setting_Haptics:OnClickButton0")
  self:PlayAudio(sound_config.click)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(87894), self.UIRoot.Button_0)
end
function Setting_Haptics:OnClickButton1()
  log(bWriteLog and "Setting_Haptics:OnClickButton1")
  self:PlayAudio(sound_config.click)
  self.curIndex = 2
  self:UpdateUI()
end
function Setting_Haptics:OnClickButton2()
  log(bWriteLog and "Setting_Haptics:OnClickButton2")
  self:PlayAudio(sound_config.click)
  self.curIndex = 1
  self:UpdateUI()
end
function Setting_Haptics:UpdateUI()
  log(bWriteLog and "Setting_Haptics:UpdateUI")
  for i = 1, 2 do
    if self.curIndex == i then
      self.UIRoot["WidgetSwitcher_Button_" .. i]:SetActiveWidgetIndex(1)
    else
      self.UIRoot["WidgetSwitcher_Button_" .. i]:SetActiveWidgetIndex(0)
    end
  end
  self.UIRoot.WidgetSwitcher_CanvasPanelRoot:SetActiveWidgetIndex(self.curIndex - 1)
  if self.UIChild_Audio == nil then
    self.UIChild_Audio = self:CreateChildWindow(self.UIRoot.CanvasPanel_Root, UIManager.UI_Config.Setting_Sound)
  end
end