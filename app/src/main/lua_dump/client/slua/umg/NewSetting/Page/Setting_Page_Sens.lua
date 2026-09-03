local Setting_Page_Sens = {}
local SettingSharedUtils = require("client.logic.NewSetting.SettingSharedUtils")
local LogicCustomSensitivity = require("client.logic.setting.logic_setting_custom_sensitivity")
local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
local Control_Index_Touch = 1
local Control_Index_Gyro = 2
function Setting_Page_Sens:OnInitialize()
  Setting_Page_Sens.__super.OnInitialize(self)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  self.bShoulderEnable = SettingConfig.ShoulderEnable
  local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
  local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
  BP_Setting_UploadType = 0
  self.MultiSwitcher_Preset = self:InitItemWithWidget(self.UIRoot.Setting_TitleOption_MultiSwitcher_Preset, {
    Key = "CameraLensSensibility",
    UI = AliasMap.TitleMultiSwitcher,
    Text = 87566,
    SwitcherText = {
      87567,
      87568,
      87569,
      27292,
      27294,
      87570
    },
    SwitcherValue = {
      1,
      2,
      3,
      5,
      6,
      4
    },
    Width = 129,
    Height = 40,
    SetFunc = function(key, NewValue)
      FuncLib.SetValue("CameraLensSensibility", NewValue)
      LogicGlobalSensitivity.ApplyPresetToConfig(NewValue)
      self:RefreshAllScrollBox()
      return true
    end
  })
  self:InitItemWithWidget(self.UIRoot.Setting_Title_FreeCam, {
    UI = AliasMap.Title,
    Text = 87575
  })
  self.NormalTitleData = {
    UI = AliasMap.Title,
    Text = 87571,
    Help = 87572
  }
  self.FireSensTitleData = {
    Key = "bFireCamSenUseCam",
    UI = AliasMap.TitleSwitcher,
    Text = 87573,
    Help = 87574,
    ExpandIndex = 0,
    SwitcherValue = FuncLib.BOOL_FT
  }
  self.GyroTitleData = {
    UI = AliasMap.Title,
    Text = 87623,
    Help = 87624
  }
  self.GyroSwitchData = {
    Key = "Gyroscope",
    UI = AliasMap.Switcher,
    Text = 10971,
    Help = 87586,
    SwitcherText = {
      33210,
      33223,
      39267
    },
    SwitcherValue = FuncLib.SEQ120,
    ExpandIndex = {0, 1},
    SuggestionText = 66315,
    VisibilityFunc = FuncLib.BShow_IsNotWoWEditor,
    FixedFunc = function(key)
      if not Client.IsDeviceSupportGyrSensor() then
        FuncLib.SetValue("Gyroscope", 0)
        return 0, LocUtil.GetLocalizeResStr(12030002)
      else
        return nil
      end
    end
  }
  self.GyroFireSensTitleData = {
    Key = "bFireGyroSenUseGryo",
    UI = AliasMap.TitleSwitcher,
    Text = 87625,
    Help = 87626,
    ExpandIndex = 0,
    SwitcherValue = FuncLib.BOOL_FT
  }
  self.Setting_Title = self:InitItemWithWidget(self.UIRoot.Setting_Title, self.NormalTitleData)
  self.Setting_TitleOption_Switcher_FireSens = self:InitItemWithWidget(self.UIRoot.Setting_TitleOption_Switcher_FireSens, self.GyroFireSensTitleData)
  local itemLuaPath = "client.slua.umg.setting.Sensitivity.SensibilityBtnItem"
  self.LoopScrollBox_Sens = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Sens, itemLuaPath)
  self.LoopScrollBox_FireSens = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_FireSens, itemLuaPath)
  self.LoopScrollBox_FreeCam = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_FreeCam, itemLuaPath)
  self.CommonTab_Control = self:InitHorizontalLevelTwoTextTab(self.UIRoot.CommonTab_Control, {bDarkMode = true})
  self.CommonTab_Control:AddOnSelectedCallback(self.OnTabSelected, self)
  self:SetWidgetVisible(self.UIRoot.Button_GoToPlayground, GameStatus.IsInLobbyOrMainCity() and not IsWoWEditor, true)
end
function Setting_Page_Sens:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SWITCHER_EXPAND, self.OnSwitcherExpand, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_ON_APPLY_CLOUD_DATA, self.OnCloudDataApplied, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Cloud, self.OnButtonCloudClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.BUtton_Search, self.OnButtonSearchClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_GoToPlayground, self.OnButtonGoToPlayground, self)
end
function Setting_Page_Sens:OnPostInitialize()
  Setting_Page_Sens.__super.OnPostInitialize(self)
  if IsWoWEditor then
    self.CommonTab_Control:SetTabs({
      LocUtil.GetLocalizeResStr(10965)
    })
  else
    self.CommonTab_Control:SetTabs({
      LocUtil.GetLocalizeResStr(10965),
      LocUtil.GetLocalizeResStr(10971)
    })
  end
end
function Setting_Page_Sens:OnTabSelected(lastIndex, index, bIsFromClick)
  if lastIndex == index then
    return
  end
  local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
  self:SetWidgetVisible(self.UIRoot.Setting_Option_Switcher_Gyro, index == Control_Index_Gyro)
  self:SetWidgetVisible(self.UIRoot.Setting_Title_FreeCam, index == Control_Index_Touch)
  self:SetWidgetVisible(self.UIRoot.LoopScrollBox_FreeCam, index == Control_Index_Touch)
  self:SetWidgetVisible(self.UIRoot.LoopScrollBox_FireSens, true)
  self:SetWidgetVisible(self.UIRoot.LoopScrollBox_Sens, true)
  if index == Control_Index_Touch then
    if self.Setting_Title.Data ~= self.NormalTitleData then
      self.Setting_Title:SetData(self.NormalTitleData)
    end
    if self.Setting_TitleOption_Switcher_FireSens.Data ~= self.FireSensTitleData then
      self.Setting_TitleOption_Switcher_FireSens:SetData(self.FireSensTitleData)
    end
    self.UIRoot.LoopScrollBox_Sens.Slot:SetPadding(SettingStyleLibrary.GeneralMargin)
  elseif index == Control_Index_Gyro then
    if not self.Setting_Option_Switcher_Gyro then
      self.Setting_Option_Switcher_Gyro = self:InitItemWithWidget(self.UIRoot.Setting_Option_Switcher_Gyro, self.GyroSwitchData)
    end
    if self.Setting_Title.Data ~= self.GyroTitleData then
      self.Setting_Title:SetData(self.GyroTitleData)
    end
    if self.Setting_TitleOption_Switcher_FireSens.Data ~= self.GyroFireSensTitleData then
      self.Setting_TitleOption_Switcher_FireSens:SetData(self.GyroFireSensTitleData)
    end
    self.UIRoot.LoopScrollBox_Sens.Slot:SetPadding(SettingStyleLibrary.ExpandedMargin)
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    self:SetWidgetVisible(self.UIRoot.LoopScrollBox_Sens, SettingConfig.Gyroscope > 0)
    self:SetWidgetVisible(self.UIRoot.Setting_TitleOption_Switcher_FireSens, SettingConfig.Gyroscope > 0)
    self:SetWidgetVisible(self.UIRoot.LoopScrollBox_FireSens, SettingConfig.Gyroscope > 0)
  end
  self:RefreshAllScrollBox()
end
function Setting_Page_Sens:OnSwitcherExpand(_, __, key, bExpand)
  print(bWriteLog and string.format("Setting_Page_Sens:OnSwitcherExpand - key=%s, bExpand=%s", tostring(key), tostring(bExpand)))
  if key == "bFireCamSenUseCam" or key == "bFireGyroSenUseGryo" then
    self:SetWidgetVisible(self.UIRoot.LoopScrollBox_FireSens, bExpand)
    if bExpand then
      LogicGlobalSensitivity.SyncSensToFireSens(key == "bFireGyroSenUseGryo")
      self:RefreshFireSensBox()
    else
      LogicGlobalSensitivity.SyncSensToFireSens(key == "bFireGyroSenUseGryo")
    end
  elseif key == "Gyroscope" then
    self:SetWidgetVisible(self.UIRoot.LoopScrollBox_Sens, bExpand)
    self:SetWidgetVisible(self.UIRoot.Setting_TitleOption_Switcher_FireSens, bExpand)
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    self:SetWidgetVisible(self.UIRoot.LoopScrollBox_FireSens, bExpand and not SettingConfig.bFireGyroSenUseGryo)
    if bExpand then
      self:RefreshAllScrollBox()
    end
  end
end
function Setting_Page_Sens:RefreshAllScrollBox()
  self:RefreshSensBox()
  self:RefreshFireSensBox()
  self.LoopScrollBox_FreeCam:SetData(LogicGlobalSensitivity.FreeCamKeyList)
end
function Setting_Page_Sens:RefreshSensBox()
  local Index = self.CommonTab_Control:GetSelectedIndex()
  if Index == Control_Index_Touch then
    self.LoopScrollBox_Sens:SetData(LogicGlobalSensitivity.GetFilteredKeyList("SensKeyList"))
  elseif Index == Control_Index_Gyro then
    self.LoopScrollBox_Sens:SetData(LogicGlobalSensitivity.GetFilteredKeyList("GyroSensKeyList"))
  end
end
function Setting_Page_Sens:RefreshFireSensBox()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local Index = self.CommonTab_Control:GetSelectedIndex()
  local bEnableFireSens = not SettingConfig.bFireCamSenUseCam
  local KeyListName = "FireSensKeyList"
  if Index == Control_Index_Gyro then
    bEnableFireSens = not SettingConfig.bFireGyroSenUseGryo
    KeyListName = "GyroFireSensKeyList"
  end
  if bEnableFireSens then
    local Index = self.CommonTab_Control:GetSelectedIndex()
    if Index == Control_Index_Gyro then
      self.LoopScrollBox_FireSens:SetData(LogicGlobalSensitivity.GetFilteredKeyList(KeyListName))
    else
      self.LoopScrollBox_FireSens:SetData(LogicGlobalSensitivity.GetFilteredKeyList(KeyListName))
    end
  else
    self.LoopScrollBox_FireSens:SetData()
  end
end
function Setting_Page_Sens:OnValueChanged(key, num)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig.CameraLensSensibility ~= LogicGlobalSensitivity.CustomPresetIndex then
    SettingConfig.CameraLensSensibility = LogicGlobalSensitivity.CustomPresetIndex
    self.MultiSwitcher_Preset:RefreshSelection()
    LogicGlobalSensitivity.BackupToCustomKeys(SettingConfig)
  end
  SettingConfig[key] = num
  SettingConfig[key .. LogicGlobalSensitivity.CustomKeySuffix] = num
end
function Setting_Page_Sens:OnButtonCloudClick()
  local SettingCloudHelper = require("client.logic.setting.SettingCloudHelper")
  SettingCloudHelper.RequestGlobalSensCloudData(Setting_Page_Sens.EnterCloudManager)
end
function Setting_Page_Sens.EnterCloudManager(CloudData)
  local SettingCloudSensitivityShare = require("client.slua.logic.setting.logic_cloud_sensitivity_share")
  UIManager.ShowUI(UIManager.UI_Config.Setting_Cloud_Manage_Popups_UIBP, {
    CloudData = CloudData,
    bSameAsCloud = LogicGlobalSensitivity.CompareGlobalSensitivityWithLocal(CloudData),
    UploadText = LocUtil.GetLocalizeResStr(14034),
    UploadFunc = LogicGlobalSensitivity.UploadCloudSetting,
    ApplyText = LocUtil.GetLocalizeResStr(9901),
    ApplyFunc = LogicGlobalSensitivity.UseCloudSetting,
    ShareFunc = function()
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_gen_sensitive_share_req()
    end,
    ShowDiffFunc = SettingCloudSensitivityShare.ShowGlobalSensitivityDiff,
    CloudUploadTime = LogicGlobalSensitivity.last_save_custom_sensitive_tm
  })
end
function Setting_Page_Sens:OnButtonSearchClick()
  local SettingCloudSensitivityShare = require("client.slua.logic.setting.logic_cloud_sensitivity_share")
  SettingCloudSensitivityShare.ShowCloudSearchPopPanel()
end
function Setting_Page_Sens:OnButtonGoToPlayground()
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.TryEnterTrain()
  Setting_EnterSingleTraining = true
end
function Setting_Page_Sens:OnCloudDataApplied()
  self.MultiSwitcher_Preset:RefreshSelection()
  self:RefreshAllScrollBox()
end
local class = require("class")
local Setting_StackContainer = require("client.slua.umg.NewSetting.Page.Setting_StackContainer")
return class(Setting_StackContainer, nil, Setting_Page_Sens)