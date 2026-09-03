local Setting_Haptics = require("client.slua.umg.NewSetting.Haptics.Setting_Haptics_Config")
function Setting_Haptics:RefreshMainLabel(HapticSwitch)
  local ShowOrHide = function(bShow)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Voice, bShow)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Character, bShow)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Weapon, bShow)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Vehicle, bShow)
    if bShow then
      for _, ChildSwich in pairs(self.ChildSwitchConfig) do
        self:RefreshChildLabel(nil, ChildSwich)
      end
      self:RefreshAllNormalSwitch()
    end
    if bShow then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Voice, LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_VOICE))
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Character, LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_CHARACTER))
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Weapon, LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_WEAPON))
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Vehicle, LobbySystem.CheckOpen(BP_ENUM_SETTING_HAPTICS_VEHICLE))
    end
  end
  local SupportHaptic = Client.GetTMFPTapDeviceSupportFlag() - 1
  print(bWriteLog and "Setting_Haptics:RefreshMainLabel " .. tostring(HapticSwitch) .. " SupportHaptic = " .. tostring(SupportHaptic))
  if SupportHaptic <= 0 then
    self.UIRoot.High_On:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Low_ON:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Close_ON:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Canvas_Label_High:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Canvas_Label_Low:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Border_Haptics:SetIsEnabled(false)
    ShowOrHide(false)
    return
  else
    self.UIRoot.Border_Haptics:SetIsEnabled(true)
  end
  if SupportHaptic == 0 then
    self.UIRoot.Canvas_Label_High:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Canvas_Label_Low:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif SupportHaptic == 1 then
    self.UIRoot.Canvas_Label_High:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif SupportHaptic == 2 then
    self.UIRoot.Canvas_Label_Low:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  HapticSwitch = HapticSwitch or self.SettingConfig.HapticSwitch
  self.SettingConfig.  if HapticSwitch == 0 then
    ShowOrHide(false)
    self.UIRoot.High_On:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Low_ON:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Close_ON:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif HapticSwitch == 1 then
    ShowOrHide(true)
    self.UIRoot.High_On:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Low_ON:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Close_ON:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif HapticSwitch == 2 then
    ShowOrHide(true)
    self.UIRoot.High_On:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Low_ON:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Close_ON:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Setting_Haptics:RefreshChildLabel(ChildHapticSwitch, ChildSwich)
  ChildHapticSwitch = ChildHapticSwitch or self.SettingConfig[ChildSwich.SettingKey]
  self.SettingConfig[ChildSwich.SettingKey] = ChildHapticSwitch
  local ShowOrHide = function(bShow)
    for _, WidgetName in pairs(ChildSwich.HideWidgetOnClose) do
      self:SetWidgetVisible(self.UIRoot[WidgetName], bShow)
    end
  end
  if ChildHapticSwitch == 0 then
    ShowOrHide(false)
    self.UIRoot[ChildSwich.HighWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.MiddleWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.LowWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.CanvasPanelContent]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.CloseWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  elseif ChildHapticSwitch == 1 then
    ShowOrHide(true)
    self.UIRoot[ChildSwich.HighWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.MiddleWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.LowWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot[ChildSwich.CanvasPanelContent]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot[ChildSwich.CloseWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif ChildHapticSwitch == 2 then
    ShowOrHide(true)
    self.UIRoot[ChildSwich.HighWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.MiddleWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot[ChildSwich.LowWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.CanvasPanelContent]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot[ChildSwich.CloseWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif ChildHapticSwitch == 3 then
    ShowOrHide(true)
    self.UIRoot[ChildSwich.HighWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot[ChildSwich.MiddleWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.LowWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot[ChildSwich.CanvasPanelContent]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot[ChildSwich.CloseWidget]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Setting_Haptics:RefreshAllNormalSwitch()
  for _, NormalSwich in pairs(self.NormalSwitchConfig) do
    self:RefreshNormalSwitch(NormalSwich.SwitchName, NormalSwich.SettingConfigKey)
  end
end
function Setting_Haptics:RefreshNormalSwitch(SwitchName, SettingKey, bClick)
  if bClick then
    self.SettingConfig[SettingKey] = not self.SettingConfig[SettingKey]
  end
  self.UIRoot[SwitchName]:SetSwitcherAnima(self.SettingConfig[SettingKey], false)
end