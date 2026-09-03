local Setting_Page_Layout_Character = {
  Mutiplerate = 2,
  Touch3DAvaliableDevices = {
    "iPhone6S",
    "iPhone6SPlus",
    "iPhone7",
    "iPhone7Plus",
    "iPhone8",
    "iPhone8Plus",
    "iPhoneX",
    "IPhoneXS",
    "IPhoneXSMax"
  }
}
local CustomLayoutType = require("client.logic.setting.CustomLayoutType")
local CustomDisplayFlag = require("client.logic.setting.CustomDisplayFlag")
local LayerTag = {Parachuting = 1}
local _LayerList = {
  {
    Tag = LayerTag.Parachuting,
    IconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/ZD_icon_SettingState_png.ZD_icon_SettingState_png"
  }
}
local LayoutTitleList = {
  {
    TitleText = 27327,
    LayoutType = CustomLayoutType.Classic,
    IsFPP = false,
    ShowFlag = CustomDisplayFlag.Classic,
    LayerList = _LayerList,
    bHasLayoutSwitcher = true,
    bHasCopyPaste = true
  },
  {
    TitleText = 27328,
    LayoutType = CustomLayoutType.Classic,
    IsFPP = true,
    ShowFlag = CustomDisplayFlag.Classic,
    LayerList = _LayerList,
    bHasLayoutSwitcher = true,
    bHasCopyPaste = true
  },
  {
    TitleText = 27332,
    LayoutType = CustomLayoutType.TD,
    ShowFlag = CustomDisplayFlag.TD,
    IsFPP = false,
    bHasCopyPaste = true,
    bHasLayoutSwitcher = false
  },
  {
    TitleText = 27333,
    LayoutType = CustomLayoutType.TD,
    ShowFlag = CustomDisplayFlag.TD,
    IsFPP = true,
    bHasCopyPaste = true,
    bHasLayoutSwitcher = false
  },
  {
    TitleText = 8220001,
    LayoutType = CustomLayoutType.UGC,
    ShowFlag = CustomDisplayFlag.UGC,
    LayerList = _LayerList,
    bHasCopyPaste = true,
    bHasLayoutSwitcher = false
  }
}
function Setting_Page_Layout_Character:OnInitialize()
  Setting_Page_Layout_Character.__super.OnInitialize(self)
  self.bTDMode = false
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    self.bTDMode = InGameUITools.IsTDM()
    self.bUGC = InGameUITools.IsUGC()
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local FireMode = SettingModule:GetOptionValue("FireMode")
  self.LastControlMode = FireMode
  self.CurControlMode = FireMode
  self:Refresh3DTouch()
  self:OnSelectCharacterMode(FireMode)
  self.UIRoot.TextBlock_Top1:SetText(LocUtil.GetLocalizeResStr(301361))
  self.UIRoot.TextBlock_Top2:SetText(LocUtil.GetLocalizeResStr(301362))
  self.UIRoot.TextBlock_Top3:SetText(LocUtil.GetLocalizeResStr(301363))
end
function Setting_Page_Layout_Character:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.BtnMode1_Classic, "OnClicked", self.OnClickControlMode, self, 1)
  self:AddControlEventByControl(self.UIRoot.BtnMode2_Classic, "OnClicked", self.OnClickControlMode, self, 2)
  self:AddControlEventByControl(self.UIRoot.BtnMode3_Classic, "OnClicked", self.OnClickControlMode, self, 3)
  self:AddControlEventByControl(self.UIRoot.Button_Custom1_Classic, "OnClicked", self.OnClickEnterElemLayout, self)
  self:AddControlEventByControl(self.UIRoot.Button_Custom2_Classic, "OnClicked", self.OnClickEnterElemLayout, self)
  self:AddControlEventByControl(self.UIRoot.Button_Custom3_Classic, "OnClicked", self.OnClickEnterElemLayout, self)
  self:AddControlEventByControl(self.UIRoot.Button_Perspective, "OnClicked", self.OnClickPerspective, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot["3dTouchCheckBox_Classic"], self.OnCheck3DTouch, self)
  self:AddControlEventByControl(self.UIRoot["btn_3dtouch-_Classic"], "OnClicked", self.OnClickChange3DTouchValue, self, false)
  self:AddControlEventByControl(self.UIRoot["btn_3dtouch-+_Classic"], "OnClicked", self.OnClickChange3DTouchValue, self, true)
  self:AddControlEventByControl(self.UIRoot["3dtouch_slider_Classic"], "OnValueChanged", self.On3DTouchSliderChange, self)
end
function Setting_Page_Layout_Character:OnClose()
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if self.LastControlMode ~= self.CurControlMode then
      if SettingSubsystem then
        SettingSubsystem:BroadcastCustomLayoutChangeBySaveType(SettingSubsystem.CustomLayoutSaveType.Character)
      end
      local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
      local MainControlPanelTochButton = InGameUITools.GetMainControlPanelTochButton()
      if MainControlPanelTochButton then
        MainControlPanelTochButton:ApplyCustomUI()
      end
    end
  end
end
function Setting_Page_Layout_Character:OnClickControlMode(FireMode)
  self:PlayAudio(sound_config.click_v1)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  SettingModule:SetOptionValue("FireMode", FireMode)
  self.CurControlMode = FireMode
  self:OnSelectCharacterMode(FireMode)
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function Setting_Page_Layout_Character:OnClickEnterElemLayout()
  self:PlayAudio(sound_config.click_v1)
  local bFPP = false
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if slua.isValid(uGameState) then
      bFPP = uGameState.IsFPPGameMode
    end
  end
  local TitleIndex = 1
  if self.bTDMode then
    TitleIndex = 3 + (bFPP and 1 or 0)
  elseif self.bUGC then
    TitleIndex = 5
  else
    TitleIndex = bFPP and 2 or 1
  end
  UIManager.ShowUI(UIManager.UI_Config.setting_uielem_layout, {
    ControlMode = self.CurControlMode,
    TitleIndex = TitleIndex,
      })
  self.LastControlMode = nil
end
function Setting_Page_Layout_Character:OnClickPerspective()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.SettingPerspectivePanel)
end
function Setting_Page_Layout_Character:OnCheck3DTouch(bCheck)
  self:PlayAudio(sound_config.toggle_v1)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  SettingModule:SetOptionValue("3DTouchSwitcher", bCheck)
  self:SetWidgetVisible(self.UIRoot.Touch3DForceThresholdHorizontalBox_Classic, bCheck)
end
function Setting_Page_Layout_Character:OnClickChange3DTouchValue(bAdd)
  self:PlayAudio(sound_config.click_v1)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local Value = SettingModule:GetOptionValue("3DTouchValue")
  if bAdd then
    Value = Value + 0.01
    Value = math.min(Value, 2)
  else
    Value = Value - 0.01
    Value = math.max(Value, 0.01)
  end
  SettingModule:SetOptionValue("3DTouchValue", Value)
  self:Refresh3DTouchValue(Value)
end
function Setting_Page_Layout_Character:On3DTouchSliderChange(nValue)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local Value = math.max(self.Mutiplerate * nValue, 0.01)
  SettingModule:SetOptionValue("3DTouchValue", Value)
  self:Refresh3DTouchValue(Value)
end
function Setting_Page_Layout_Character:OnSelectCharacterMode(ModeIndex)
  self:SetWidgetVisible(self.UIRoot.Mode1Selected_Classic, ModeIndex == 1)
  self:SetWidgetVisible(self.UIRoot.Mode2Selected_Classic, ModeIndex == 2)
  self:SetWidgetVisible(self.UIRoot.Mode3Selected_Classic, ModeIndex == 3)
  self:SetWidgetVisible(self.UIRoot.SizeBox_1_Classic, ModeIndex == 1, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_2_Classic, ModeIndex == 2, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_3_Classic, ModeIndex == 3, true)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local b3DTouchSwitcher = SettingModule:GetOptionValue("3DTouchSwitcher")
  self:SetWidgetVisible(self.UIRoot.Touch3DForceThresholdHorizontalBox_Classic, b3DTouchSwitcher and ModeIndex == 2 and self.b3DTouchAvailable)
end
function Setting_Page_Layout_Character:RefreshUGCEditMode()
  self.UIRoot.CharacterCtrlModePanel:SetIsEnabled(true)
  self.UIRoot.UGCEditModeTipsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local BuildSubsystem = SubsystemMgr:Get("CreativeModeEditBuildSubSystem")
  if BuildSubsystem and BuildSubsystem:IsEditorMode() then
    self:SetWidgetVisible(self.UIRoot.Mode1Selected_Classic, false, false)
    self:SetWidgetVisible(self.UIRoot.Mode2Selected_Classic, false, false)
    self:SetWidgetVisible(self.UIRoot.Mode3Selected_Classic, false, false)
    self.UIRoot.CharacterCtrlModePanel:SetIsEnabled(false)
    self.UIRoot.UGCEditModeTipsPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if UIManager.UI_Config_InGame.EditSettingCustomUITipsPanel then
      local TipsPanel = UIManager.GetUI(UIManager.UI_Config_InGame.EditSettingCustomUITipsPanel)
      TipsPanel = TipsPanel or UIManager.ShowUI(UIManager.UI_Config_InGame.EditSettingCustomUITipsPanel)
      if TipsPanel then
        TipsPanel:AttachToPanel(self.UIRoot.UGCEditModeTipsPanel)
        TipsPanel:SetAnchors(0, 0, 1, 1)
        TipsPanel:SetOffsets(0, -600, 0, 0)
      end
    end
  end
end
function Setting_Page_Layout_Character:Refresh3DTouch()
  self.UIRoot["3dTouchCheckBox_Classic"]:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
  self.b3DTouchAvailable = false
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local DeviceName = USTExtraBlueprintFunctionLibrary.GetDeviceName()
    for _, Name in pairs(self.Touch3DAvaliableDevices) do
      if string.find(string.lower(DeviceName), string.lower(Name)) then
        self.b3DTouchAvailable = true
        local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
        local Switcher = SettingModule:GetOptionValue("3DTouchSwitcher")
        local Value = SettingModule:GetOptionValue("3DTouchValue")
        self.UIRoot["3dTouchCheckBox_Classic"]:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot["3dTouchCheckBox_Classic"]:SetCheckedState(Switcher and 1 or 0)
        self.UIRoot["3dtouch_slider_Classic"]:SetValue(Value / self.Mutiplerate)
        self:Refresh3DTouchValue(Value)
        break
      end
    end
  end
end
function Setting_Page_Layout_Character:Refresh3DTouchValue(value)
  self.UIRoot["3dtouch_value"]:SetText(tostring(math.floor(value * 100)) .. "%")
  self.UIRoot["3dtouch_progressbar_Classic"]:SetPercent(value / self.Mutiplerate)
  self.UIRoot["3dtouch_slider_Classic"]:SetValue(value / self.Mutiplerate)
end
local class = require("class")
local Setting_StackContainer = require("client.slua.umg.NewSetting.Page.Setting_StackContainer")
return class(Setting_StackContainer, nil, Setting_Page_Layout_Character)