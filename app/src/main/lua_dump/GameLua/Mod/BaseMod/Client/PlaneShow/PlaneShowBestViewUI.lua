local PlaneShowBestViewUI = {}
function PlaneShowBestViewUI:OnInitialize()
  PlaneShowBestViewUI.__super.OnInitialize(self)
  self.UIRoot.TextBlock_BestView:SetText(LocUtil.GetLocalizeResStr(29779))
  if self.PlaneShowUIType and self.PlaneShowUIType == 2 then
    self.UIRoot.Button_SwitchView:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.ButtonType2:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.HorizontalBox_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_DontShowAgain, self.OnCheckStateChanged, self)
    self:CheckCheckBoxState()
  else
    self.UIRoot.Button_SwitchView:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.ButtonType2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.HorizontalBox_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PlaneShowBestViewUI:RegistEvents()
  PlaneShowBestViewUI.__super.RegistEvents(self)
  self:AddOnReleasedEventByControl(self.UIRoot.Button_SwitchView, function()
    print(bWriteLog and "PlaneShowBestViewUI:Button_SwitchView")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_VIVEW_CHANGED, "Open")
    self:SwitchView(true)
  end, self)
  self:AddOnReleasedEventByControl(self.UIRoot.ButtonType2, function()
    print(bWriteLog and "PlaneShowBestViewUI:ButtonType2")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_VIVEW_CHANGED, "Open")
    self:SwitchView(true)
  end, self)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  SettingSubsystem:RegisterUserSettingsDelegate_Bool("PlaneNotShowCabin", function()
    self:CheckCheckBoxState()
  end)
end
function PlaneShowBestViewUI:OnSwithButtonClick(_, __, sState)
  if sState == "Close" then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:AddGameTimer(self.CDTime, false, function()
      self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end)
    self:CheckCheckBoxState()
  end
end
function PlaneShowBestViewUI:CheckCheckBoxState()
  print(bWriteLog and "PlaneShowBestViewUI:CheckCheckBoxState")
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem or not self.UIRoot then
    return
  end
  self.PlaneNotShowCabin = SettingSubsystem:GetUserSettings_Bool("PlaneNotShowCabin")
  if self.PlaneNotShowCabin then
    self.UIRoot.CheckBox_DontShowAgain:SetCheckedState(1)
  else
    self.UIRoot.CheckBox_DontShowAgain:SetCheckedState(0)
  end
end
function PlaneShowBestViewUI:OnCheckStateChanged(bIsChecked)
  print(bWriteLog and "PlaneShowBestViewUI:OnCheckStateChanged" .. tostring(bIsChecked))
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  SettingSubsystem:SetUserSettings_Bool("PlaneNotShowCabin", bIsChecked)
  if bIsChecked then
    SettingSubsystem:SetUserSettings_Bool("PlaneShowCabin", not bIsChecked)
  end
end
local class = require("class")
local CBaseUI = require("GameLua.Mod.BaseMod.Client.PlaneShow.PlaneShowUI")
local CPlaneShowBestViewUI = class(CBaseUI, nil, PlaneShowBestViewUI)
return CPlaneShowBestViewUI