local UI = require("client.slua.umg.NewSetting.Sound.setting_sound_data")
local ESlateVisibility = UEnums.ESlateVisibility
local sStopMusicPath = "/Game/WwiseEvent/UI/Play_Music_Stop.Play_Music_Stop"
local sHallMusicPath = "/Game/WwiseEvent/Music/Music_Main/Play_Music_Hall.Play_Music_Hall"
function UI:ctor(_, params)
  self.end
function UI:OnInitialize()
  UI.__super.OnInitialize(self)
  self:InitShow()
  self:CreateResDownload()
end
function UI:RegistEvents()
  UI.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.mainVolumSlider, "OnValueChanged", self.OnMainVolumeSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.mainVolumSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "MainVolumValue", "mainVolumSlider")
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.mainVolumCheckBox, self.OnMainVolumeCheckBoxChanged, self)
  self:AddControlEventByControl(self.UIRoot.EffectVolumeSlider, "OnValueChanged", self.OnEffectVolumeSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.EffectVolumeSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "EffectVolumValue", "EffectVolumeSlider")
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.EffectVolumCheckBox, self.OnEffectVolumeCheckBoxChanged, self)
  self:AddControlEventByControl(self.UIRoot.UIVolumeSlider, "OnValueChanged", self.OnUIVolumeSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.UIVolumeSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "UIVolumValue", "UIVolumeSlider")
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.UIVolumCheckBox, self.OnUIVolumeCheckBoxChanged, self)
  self:AddControlEventByControl(self.UIRoot.BGMSlider, "OnValueChanged", self.OnBGMSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.BGMSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "BGMVolumValue", "BGMSlider")
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.BGMCheckBox, self.OnBGMCheckBoxChanged, self)
  self:AddControlEventByControl(self.UIRoot.WeaponSlider, "OnValueChanged", self.OnWeaponSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.WeaponSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "WeaponVolumValue", "WeaponSlider")
  self:AddControlEventByControl(self.UIRoot.VehicleSlider, "OnValueChanged", self.OnVehicleSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.VehicleSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "VehicleVolumValue", "VehicleSlider")
  self:AddControlEventByControl(self.UIRoot.VoiceSlider, "OnValueChanged", self.OnVoiceSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.VoiceSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "VoiceVolumValue", "VoiceSlider")
  self:AddControlEventByControl(self.UIRoot.MicphoneSlider, "OnValueChanged", self.MicphoneSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.MicphoneSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "MicphoneVolumValue", "MicphoneSlider")
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.micphoneCheckBox, self.OnMicphoneCheckBoxChanged, self)
  self:AddControlEventByControl(self.UIRoot.SpeakerSlider, "OnValueChanged", self.SpeakerSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.SpeakerSlider, "OnMouseCaptureEnd", self.OnVolumeSliderEnd, self, "SpeakerVolumValue", "SpeakerSlider")
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.SpeakerCheckBox, self.OnSpeakerCheckBoxChanged, self)
  self:AddOnClickedEventByControl(self.UIRoot.Btn_Voice_Switcher, self.OnBtnVoiceSwitcherClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_NewMusic, self.OnBtnNewMusicClick, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.BGM_Lobby, self.OnBGMLobbyCheckBoxChanged, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.BGM_Hallowmas, self.OnBGMHallowmasCheckBoxChanged, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_lowQuality, self.OnLowQualityBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_highQuality, self.OnHighQualityBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ultrahigh, self.OnUltrahighBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_30, self.OnPressSocialIslandSoundTip, self)
  self:AddControlEventByControl(self.UIRoot.SocialIslandVolumeSlider, "OnValueChanged", self.OnSocialIslandVolumeSliderChanged, self)
  self:AddControlEventByControl(self.UIRoot.SocialIslandVolumeSlider, "OnMouseCaptureEnd", self.OnSocialIslandVolumeSliderEnd, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BackgroundChat, self.OnBtnBackgroundChatClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BackgroundChat_Rule, self.OnBtnBackgroundChatRuleClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_PreTeamUpChat, self.OnBtnPreTeamUpChatClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_PreTeamUpChat_Rule, self.OnBtnDescriptionClick, self, self.UIRoot.Button_PreTeamUpChat_Rule, 49957)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DirectionalMic, self.OnClickButton_DirectionalMic, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DescDirectionalMic, self.OnBtnDescriptionClick, self, self.UIRoot.Button_DescDirectionalMic, 81130)
  self:AddOnClickedEventByControl(self.UIRoot.Button_4, self._ShowHelpTips, self, self.UIRoot.Button_4, 52343679)
  self:AddCommonEvent(EVENTTYPE_SOUND, EVENTID_SOUND_HIGH_AUDIO_DOWNLOAD, self.DownloadHighAudioCompletedCallBack, self)
  self.UIRoot.TextBlock_20:SetText(LocUtil.GetLocalizeResStr(52343578))
  self.UIRoot.Title_Gyro.Title:SetText(LocUtil.GetLocalizeResStr(33611))
  self.UIRoot.Setting_Title_Item_UIBP_C_0.Title:SetText(LocUtil.GetLocalizeResStr(33612))
  self:AddOnClickedEventByControl(self.UIRoot.Button_Sound_1, self.OnDolbySound1, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Sound_2, self.OnDolbySound2, self)
  self:RefreshSocialSetting()
  self:RefreshDoblySetting()
end
function UI:OnPressSocialIslandSoundTip()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  local tipID = 33269
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(tipID), self.UIRoot.Button_30)
end
function UI:_ShowHelpTips(HelpButton, HelpTipsLocID)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(HelpTipsLocID), HelpButton)
end
function UI:OnVolumeSliderEnd(sSettingKey, sNodeName)
  self:RefreshVolumeDataCache(sSettingKey, sNodeName)
end
function UI:OnSocialIslandVolumeSliderChanged(nValue)
  self.UIRoot.SocialIslandProgressBar:SetPercent(nValue)
  self.UIRoot.SocialIslandVolumeSlider:SetValue(nValue)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SOCIAL_ISLAND_SOUND_CHANGE, nValue)
end
function UI:OnSocialIslandVolumeSliderEnd()
  local node = self.UIRoot.SocialIslandVolumeSlider
  if not node then
    return
  end
  local nValue = node:GetValue() or 0
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.SocialIslandOtherVolume = nValue
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function UI:OnMainVolumeSliderChanged(nValue)
  self:RefreshVolumeSliderShow("mainVolumProgressBar", "mainVolumSlider", "VolumeControl", nValue)
end
function UI:OnMainVolumeCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  self:RefreshVolumeCheckBoxDataAndShow("MainVolumSwitcher", bIsCheck, "mainVolumSlider", "VolumeControl", "MainVolumValue")
end
function UI:OnEffectVolumeSliderChanged(nValue)
  self:RefreshVolumeSliderShow("EffectVolumeProgressBar", "EffectVolumeSlider", "VolumeControl_SFX", nValue)
end
function UI:OnEffectVolumeCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  self:RefreshVolumeCheckBoxDataAndShow("EffectVolumSwitcher", bIsCheck, "EffectVolumeSlider", "VolumeControl_SFX", "EffectVolumValue")
  if bIsCheck then
    self.UIRoot.SubEffectLine:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.UIRoot.SubEffectHorizontalBox:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.SubEffectLine:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    self.UIRoot.SubEffectHorizontalBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
end
function UI:OnUIVolumeSliderChanged(nValue)
  self:RefreshVolumeSliderShow("UIVolumeProgressBar", "UIVolumeSlider", "VolumeControl_UI", nValue)
end
function UI:OnUIVolumeCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  self:RefreshVolumeCheckBoxDataAndShow("UIVolumSwitcher", bIsCheck, "UIVolumeSlider", "VolumeControl_UI", "UIVolumValue")
end
function UI:OnBGMSliderChanged(nValue)
  local node_root = self.UIRoot
  node_root.BGMProgressbar:SetPercent(nValue)
  node_root.BGMSlider:SetValue(nValue)
  self:SetAudioValue("VolumeControl_Music", nValue)
  self:SetAudioValue("MusicPlayer_Volume", nValue / 100)
end
function UI:OnWeaponSliderChanged(nValue)
  local node_root = self.UIRoot
  node_root.WeaponProgressBar:SetPercent(nValue)
  node_root.WeaponSlider:SetValue(nValue)
  local Text = LocUtil.LocalizeResFormat(10283, string.format("%.1f", nValue * 20 + 80))
  node_root.WeaponVolumeText:SetText(Text)
  self:SetAudioValue("Weapon_Volume", nValue)
end
function UI:OnVehicleSliderChanged(nValue)
  local node_root = self.UIRoot
  node_root.VehicleProgressBar:SetPercent(nValue)
  node_root.VehicleSlider:SetValue(nValue)
  local Text = LocUtil.LocalizeResFormat(10283, string.format("%.1f", nValue * 20 + 80))
  node_root.VehicleVolumeText:SetText(Text)
  self:SetAudioValue("Vehicle_Volume", nValue)
end
function UI:OnVoiceSliderChanged(nValue)
  local node_root = self.UIRoot
  node_root.VoiceProgressBar:SetPercent(nValue)
  node_root.VoiceSlider:SetValue(nValue)
  local Text = LocUtil.LocalizeResFormat(10283, string.format("%.1f", nValue * 20 + 80))
  node_root.VoiceVolumeText:SetText(Text)
  self:SetAudioValue("Voice_Volume", nValue)
end
function UI:OnBGMCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local node_root = self.UIRoot
  SettingConfig.BGMVolumSwitcher = bIsCheck
  if bIsCheck then
    node_root.BGMSlider:SetWidgetVisibility(ESlateVisibility.Visible)
    local nTempValue = SettingConfig.BGMVolumValue
    self:SetAudioValue("VolumeControl_Music", nTempValue)
    self:SetAudioValue("MusicPlayer_Volume", nTempValue / 100)
  else
    node_root.BGMSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self:SetAudioValue("VolumeControl_Music", 0)
    self:SetAudioValue("MusicPlayer_Volume", 0)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function UI:MicphoneSliderChanged(nValue)
  local node_root = self.UIRoot
  node_root.MicphoneProgressBar:SetPercent(nValue)
  node_root.MicphoneSlider:SetValue(nValue)
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  uAntsVoiceInterface:SetMicphoneVolum(nValue)
end
function UI:OnMicphoneCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local EUChatRestriction = logic_chat_voice:CheckEUChatRestriction()
  if EUChatRestriction then
    ShowNotice(4377)
  else
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
    local bChatPrivacy = logic_chat_voice_utility.CheckChatPrivacyAcceptStatus()
    local node_root = self.UIRoot
    local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if bChatPrivacy then
      slua_GameFrontendHUD:BeginModifyUserSettings()
      if SettingConfig.SpeakerVolumSwitcher then
        SettingConfig.MicphoneVolumSwitcher = bIsCheck
        uAntsVoiceInterface:SetMicphoneStatus(bIsCheck)
        if bIsCheck then
          node_root.MicphoneSlider:SetWidgetVisibility(ESlateVisibility.Visible)
        else
          node_root.MicphoneSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
        end
      else
        uAntsVoiceInterface:ShowOpenSpeakerAtFirstMsg()
      end
      slua_GameFrontendHUD:FinishModifyUserSettings()
    else
      uAntsVoiceInterface:ChatRequestPrivacyInSetting()
    end
  end
end
function UI:SpeakerSliderChanged(nValue)
  local node_root = self.UIRoot
  node_root.SpeakerProgressbar:SetPercent(nValue)
  node_root.SpeakerSlider:SetValue(nValue)
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  uAntsVoiceInterface:SetSpeakerVolum(nValue)
end
function UI:OnSpeakerCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local node_root = self.UIRoot
  SettingConfig.SpeakerVolumSwitcher = bIsCheck
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  uAntsVoiceInterface:SetSpeakerStatus(bIsCheck)
  if bIsCheck then
    node_root.SpeakerSlider:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    node_root.SpeakerSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    SettingConfig.MicphoneVolumSwitcher = false
    uAntsVoiceInterface:SetMicphoneStatus(false)
    node_root.MicphoneSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function UI:OnBtnVoiceSwitcherClick()
  self:PlayAudio(sound_config.click_v1)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local node_root = self.UIRoot
  local bIsOpen = not SettingConfig.VoiceSwitcher
  SettingConfig.VoiceSwitcher = bIsOpen
  if bIsOpen then
    node_root.CanHideNode:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    node_root.status_voice_on:SetWidgetVisibility(ESlateVisibility.Visible)
    node_root.status_voice_off:SetWidgetVisibility(ESlateVisibility.Hidden)
  else
    node_root.CanHideNode:SetWidgetVisibility(ESlateVisibility.Hidden)
    node_root.status_voice_on:SetWidgetVisibility(ESlateVisibility.Hidden)
    node_root.status_voice_off:SetWidgetVisibility(ESlateVisibility.Visible)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function UI:OnBtnNewMusicClick()
  self:PlayAudio(sound_config.click_v1)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local bIsPlayNew = not SettingConfig.openNewMusic
  SettingConfig.openNewMusic = bIsPlayNew
  slua_GameFrontendHUD:FinishModifyUserSettings()
  self:InitNewBGM(SettingConfig)
  if GameStatus.IsInLobbyOrMainCity() then
    self:PlayAudio(sStopMusicPath)
    if bIsPlayNew then
      self:PlayAudio("/Game/WwiseEvent/Music/Music_Main/Play_Music_Fallout.Play_Music_Fallout")
    else
      self:PlayAudio(sHallMusicPath)
    end
  end
end
function UI:OnBGMLobbyCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  local node_root = self.UIRoot
  if bIsCheck then
    node_root.BGM_Hallowmas:SetCheckedState(0)
    self:PlayAudio(sStopMusicPath)
    self:PlayAudio(sHallMusicPath)
    slua_GameFrontendHUD:BeginModifyUserSettings()
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    SettingConfig.LobbyBgm = true
    SettingConfig.LobbyHallowma = false
    slua_GameFrontendHUD:FinishModifyUserSettings()
  else
    node_root.BGM_Lobby:SetCheckedState(1)
  end
end
function UI:OnBGMHallowmasCheckBoxChanged(bIsCheck)
  self:PlayAudio(sound_config.toggle_v1)
  local node_root = self.UIRoot
  if bIsCheck then
    node_root.BGM_Lobby:SetCheckedState(0)
    self:PlayAudio(sStopMusicPath)
    self:PlayAudio("/Game/WwiseEvent/Music/Music_Main/Play_BGM_Hallowmas.Play_BGM_Hallowmas")
    slua_GameFrontendHUD:BeginModifyUserSettings()
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    SettingConfig.LobbyBgm = false
    SettingConfig.LobbyHallowma = true
    slua_GameFrontendHUD:FinishModifyUserSettings()
  else
    node_root.BGM_Hallowmas:SetCheckedState(1)
  end
end
function UI:OnLowQualityBtnClick()
  if self.nCurSoundQuality == 0 then
    log(bWriteLog and "[DeanJYT] UI:OnLowQualityBtnClick is set to low quality already")
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if not GameInstance:IsSupportSwitchSoundEffectQuality() then
    ShowNotice(12030002)
    return
  end
  self:PlayAudio(sound_config.click_v1)
  local bIsLow = self:CanSetLowAudio()
  if bIsLow then
    self.nCurSoundQuality = 0
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    if Client.SetSoundEffectQuality(self.nCurSoundQuality) then
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("116018"))
      self:InitSoundQuality()
    else
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("116006"))
    end
  end
end
function UI:OnHighQualityBtnClick()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if not GameInstance:IsSupportSwitchSoundEffectQuality() then
    ShowNotice(12030002)
    return
  end
  self:PlayAudio(sound_config.click_v1)
  self.nCurSoundQuality = 1
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if Client.SetSoundEffectQuality(self.nCurSoundQuality) then
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("116019"))
    self:InitSoundQuality()
  else
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("116006"))
  end
end
function UI:OnUltrahighBtnClick()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if not GameInstance:IsSupportSwitchSoundEffectQuality() then
    ShowNotice(12030002)
    return
  end
  self:PlayAudio(sound_config.click_v1)
  if self:CanSetHighAudio() then
    self.nCurSoundQuality = 2
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    if Client.SetSoundEffectQuality(self.nCurSoundQuality) then
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("116020"))
      self:InitSoundQuality()
    else
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("116006"))
    end
  end
end
function UI:OnDolbySound1()
  self:PlayAudio(sound_config.click_v1)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.DoblySwitch1 = not SettingConfig.DoblySwitch1
  slua_GameFrontendHUD:FinishModifyUserSettings()
  self:UpdateDoblySetting1(SettingConfig.DoblySwitch1)
  local AkAudioSystem = require("client.slua.logic.audio.logic_ak_audio")
  AkAudioSystem.RefreshDolbyAudioActivation()
end
function UI:OnDolbySound2()
  self:PlayAudio(sound_config.click_v1)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.DoblySwitch2 = not SettingConfig.DoblySwitch2
  slua_GameFrontendHUD:FinishModifyUserSettings()
  self:UpdateDoblySetting2(SettingConfig.DoblySwitch2)
  local AkAudioSystem = require("client.slua.logic.audio.logic_ak_audio")
  AkAudioSystem.RefreshDolbyAudioActivation()
end
function UI:OnBtnBackgroundChatClick()
  self:PlayAudio(sound_config.click_v1)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local isBackgroundChat = not SettingConfig.backgroundChat
  SettingConfig.backgroundChat = isBackgroundChat
  slua_GameFrontendHUD:FinishModifyUserSettings()
  self:InitBackgroundChat(SettingConfig)
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  logic_antsvoice_interface:SetVoiceSDKSupportBackgroundChat(isBackgroundChat)
end
function UI:OnBtnBackgroundChatRuleClick()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(44180), self.UIRoot.Button_BackgroundChat_Rule)
end
function UI:OnBtnPreTeamUpChatClick()
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MomentClick) == false then
    return
  end
  if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[4] then
    return
  end
  local value = LobbySystem.roleData.social_private_data[4] == 0 and 1 or 0
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.preTeamUpChat = value
  slua_GameFrontendHUD:FinishModifyUserSettings()
  self:InitPreTeamupChat(value)
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_social_private_switch_req(4, value)
end
function UI:OnBtnDescriptionClick(ui, Desc_LocID)
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(Desc_LocID), ui)
end
function UI:OnClickButton_DirectionalMic()
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.MomentClick) == false then
    return
  end
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    SettingConfig.bDirectionalMic = not SettingConfig.bDirectionalMic
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:EnableDirectionalCapture(SettingConfig.bDirectionalMic)
    slua_GameFrontendHUD:FinishModifyUserSettings()
    self:InitDirectionalMic()
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local LogStr = string.format("Option=%s,Value=%s", "bDirectionalMic", tostring(SettingConfig.bDirectionalMic))
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.OptionSwitch, 0, LogStr)
  end
end
function UI:DownloadHighAudioCompletedCallBack()
  if not Client.SetSoundEffectQuality(2) then
    log_shipping_client("error SettingSoundUI.DownloadHighAudioCompletedCallBack SetSoundEffectQuality(2) fail")
  end
  local title = LocUtil.GetLocalizeResStr(110115)
  local quality = LocUtil.GetLocalizeResStr(7637)
  local content = LocUtil.LocalizeResFormat("7636", quality)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, content)
  self:InitShow()
end
function UI:RefreshDoblySetting()
  if IsWoWEditor then
    self:SetWidgetVisible(self.UIRoot.Setting_Title_Dolby, false)
    self:SetWidgetVisible(self.UIRoot.GridPanel_Dolby, false)
    return
  end
  self.UIRoot.Setting_Title_Dolby.Title:SetText(LocUtil.GetLocalizeResStr(34176))
  self.UIRoot.TextBlock_56:SetText(LocUtil.GetLocalizeResStr(34177))
  self.UIRoot.TextBlock_62:SetText(LocUtil.GetLocalizeResStr(34178))
  self:SetWidgetVisible(self.UIRoot.Setting_Title_Dolby, true)
  self:SetWidgetVisible(self.UIRoot.GridPanel_Dolby, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_31, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_33, true)
  local AkAudioSystem = require("client.slua.logic.audio.logic_ak_audio")
  if not AkAudioSystem.SupportDolbyAudio() then
    self:SetWidgetVisible(self.UIRoot.Setting_Title_Dolby, false)
    self:SetWidgetVisible(self.UIRoot.GridPanel_Dolby, false)
  else
    if not AkAudioSystem.DolbyAudioDMSwitch() then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_31, false)
    end
    if not AkAudioSystem.DolbyAudioFullOpenSwitch() then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_33, false)
    end
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  self:UpdateDoblySetting1(SettingConfig.DoblySwitch1)
  self:UpdateDoblySetting2(SettingConfig.DoblySwitch2)
end
function UI:UpdateDoblySetting1(status)
  local widget = self.UIRoot.Setting_Switch_Dolby_Sound_1
  if widget then
    widget:SetSwitcherEnable2(status)
  end
end
function UI:UpdateDoblySetting2(status)
  local widget = self.UIRoot.Setting_Switch_Dolby_Sound_2
  if widget then
    widget:SetSwitcherEnable2(status)
  end
end
function UI:RefreshSocialSetting()
  if IsWoWEditor then
    self:SetWidgetVisible(self.UIRoot.Setting_Title_Item_UIBP_C_1, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_22, false)
    return
  end
  self.UIRoot.Setting_Title_Item_UIBP_C_1.Title:SetText(LocUtil.GetLocalizeResStr(33613))
  self.UIRoot.TextBlock_53:SetText(LocUtil.GetLocalizeResStr(33273))
  if self.params and self.params.isSocialIslandSound then
    self.UIRoot.ScrollBox_0:ScrollToEnd()
  end
end