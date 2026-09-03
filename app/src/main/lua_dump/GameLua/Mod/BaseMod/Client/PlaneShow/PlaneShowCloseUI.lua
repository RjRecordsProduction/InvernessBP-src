local PlaneShowCloseUI = {}
function PlaneShowCloseUI:OnPostInitialize()
  PlaneShowCloseUI.__super.OnPostInitialize(self)
  self.UIRoot.TextBlock_Back:SetText(LocUtil.GetLocalizeResStr(4142))
  if self.PlaneShowUIType and self.PlaneShowUIType == 2 then
    self:RefreshUI()
    self:AddGameTimer(5, false, function()
      self.UIRoot.CanvasPanelOpen:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end)
    self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_DontShowAgain, self.OnCheckStateChanged, self)
    self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_open, self.OnCheckStateChangedOpen, self)
    self:CheckCheckBoxState()
  else
    self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self.UIRoot.CanvasPanelClose:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanelOpen:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PlaneShowCloseUI:RefreshUI(inv)
  local showVisibility = self:GetInitVisibility()
  self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if showVisibility == UEnums.ESlateVisibility.SelfHitTestInvisible then
    self.UIRoot.CanvasPanelClose:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanelOpen:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanelClose:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanelOpen:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function PlaneShowCloseUI:GetInitVisibility(inv)
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return UEnums.ESlateVisibility.SelfHitTestInvisible
  end
  local PlaneNotShowCabin = SettingSubsystem:GetUserSettings_Bool("PlaneNotShowCabin")
  if PlaneNotShowCabin then
    return UEnums.ESlateVisibility.Collapsed
  end
  return UEnums.ESlateVisibility.SelfHitTestInvisible
end
function PlaneShowCloseUI:RegistEvents()
  PlaneShowCloseUI.__super.RegistEvents(self)
  self:AddOnReleasedEventByControl(self.UIRoot.Button_Close, function()
    print(bWriteLog and "PlaneShowCloseUI:Button_Close")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_VIVEW_CHANGED, "Close")
    self:SwitchView(false)
  end, self)
  self:AddOnReleasedEventByControl(self.UIRoot.ButtonType2, function()
    print(bWriteLog and "PlaneShowCloseUI:ButtonType2")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_VIVEW_CHANGED, "Close")
    self:SwitchView(false)
  end, self)
  self:AddOnReleasedEventByControl(self.UIRoot.ButtonOpen, function()
    print(bWriteLog and "PlaneShowCloseUI:ButtonOpen")
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_VIVEW_CHANGED, "Open")
    self:SwitchView(true)
  end, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PLANE_SHOW, function()
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end, self)
end
function PlaneShowCloseUI:OnSwithButtonClick(_, __, sState)
  if sState == "Open" then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:AddGameTimer(self.CDTime, false, function()
      self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      if self.PlaneShowUIType and self.PlaneShowUIType == 2 then
        self.UIRoot.CanvasPanelClose:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.CanvasPanelOpen:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end)
    self:CheckCheckBoxState()
  end
end
function PlaneShowCloseUI:CheckCheckBoxState()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  self.PlaneShowCabin = SettingSubsystem:GetUserSettings_Bool("PlaneShowCabin")
  if self.PlaneShowCabin then
    self.UIRoot.CheckBox_DontShowAgain:SetCheckedState(1)
  else
    self.UIRoot.CheckBox_DontShowAgain:SetCheckedState(0)
  end
  self:CheckCheckBoxStateOpen()
end
function PlaneShowCloseUI:OnCheckStateChanged(bIsChecked)
  print(bWriteLog and "PlaneShowCloseUI:OnCheckStateChanged" .. tostring(bIsChecked))
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  SettingSubsystem:SetUserSettings_Bool("PlaneShowCabin", bIsChecked)
  if bIsChecked then
    SettingSubsystem:SetUserSettings_Bool("PlaneNotShowCabin", not bIsChecked)
  end
end
function PlaneShowCloseUI:CheckCheckBoxStateOpen()
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  self.PlaneNotShowCabin = SettingSubsystem:GetUserSettings_Bool("PlaneNotShowCabin")
  if self.PlaneNotShowCabin then
    self.UIRoot.CheckBox_open:SetCheckedState(1)
  else
    self.UIRoot.CheckBox_open:SetCheckedState(0)
  end
end
function PlaneShowCloseUI:OnCheckStateChangedOpen(bIsChecked)
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
local CPlaneShowUI = class(CBaseUI, nil, PlaneShowCloseUI)
return CPlaneShowUI