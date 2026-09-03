local SettingConst = require("client.slua.umg.NewSetting.Sound.setting_const")
local UI = require("client.slua.umg.NewSetting.Sound.setting_sound_data")
local ESlateVisibility = UEnums.ESlateVisibility
function UI:InitShow()
  local node_root = self.UIRoot
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  self:InitMainVolume(SettingConfig)
  self:InitEffectVolume(SettingConfig)
  self:InitUIVolume(SettingConfig)
  self:InitBGM(SettingConfig)
  self:InitVoice(SettingConfig)
  self:InitWeaponVolume(SettingConfig)
  self:InitVehicleVolume(SettingConfig)
  self:InitVoiceVolume(SettingConfig)
  self:InitNewBGM(SettingConfig)
  self:InitLobbyBgm(SettingConfig)
  self:InitSocialIslandVolume(SettingConfig)
  self:InitBackgroundChatSwitch()
  self:InitBackgroundChat(SettingConfig)
  self:InitBackgroundChatGuide()
  self:InitPreTeamupChatSwitch()
  self:InitPreTeamupChat()
  self:InitDirectionalMic()
  local nLevel = Client.GetSoundEffectQuality()
  self.nCurSoundQuality = nLevel
  self:InitSoundQuality()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if GameInstance:IsSupportSwitchSoundEffectQuality() or self.nCurSoundQuality == 0 then
    node_root.Setting_Title_Item_UIBP_C_3:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    node_root.SoundQuality:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    node_root.Setting_Title_Item_UIBP_C_3:SetWidgetVisibility(ESlateVisibility.Collapsed)
    node_root.SoundQuality:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  if LobbySystem.CheckOpen(70011) then
    node_root.NewBackMusic:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    SettingConfig.HasOpenedSound = true
  else
    node_root.NewBackMusic:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function UI:InitMainVolume(SettingConfig)
  local node_root = self.UIRoot
  local nProValue = SettingConfig.MainVolumValue
  node_root.mainVolumProgressBar:SetPercent(nProValue)
  local bVolumeSwitcher = SettingConfig.MainVolumSwitcher
  if bVolumeSwitcher then
    node_root.mainVolumCheckBox:SetCheckedState(1)
    node_root.mainVolumSlider:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    node_root.mainVolumSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    node_root.mainVolumCheckBox:SetCheckedState(0)
  end
  node_root.mainVolumSlider:SetValue(nProValue)
end
function UI:InitEffectVolume(SettingConfig)
  local node_root = self.UIRoot
  local nProValue = SettingConfig.EffectVolumValue
  node_root.EffectVolumeProgressBar:SetPercent(nProValue)
  local bEffectVolumeSwitcher = SettingConfig.EffectVolumSwitcher
  if bEffectVolumeSwitcher then
    node_root.EffectVolumCheckBox:SetCheckedState(1)
    node_root.EffectVolumeSlider:SetWidgetVisibility(ESlateVisibility.Visible)
    node_root.SubEffectLine:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    node_root.SubEffectHorizontalBox:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  else
    node_root.EffectVolumCheckBox:SetCheckedState(0)
    node_root.EffectVolumeSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    node_root.SubEffectLine:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    node_root.SubEffectHorizontalBox:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  node_root.EffectVolumeSlider:SetValue(nProValue)
end
function UI:InitUIVolume(SettingConfig)
  local node_root = self.UIRoot
  local nProValue = SettingConfig.UIVolumValue
  node_root.UIVolumeProgressBar:SetPercent(nProValue)
  local bUIVolumSwitcher = SettingConfig.UIVolumSwitcher
  if bUIVolumSwitcher then
    node_root.UIVolumCheckBox:SetCheckedState(1)
    node_root.UIVolumeSlider:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    node_root.UIVolumCheckBox:SetCheckedState(0)
    node_root.UIVolumeSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
  end
  node_root.UIVolumeSlider:SetValue(nProValue)
end
function UI:InitBGM()
  local node_root = self.UIRoot
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local nProValue = SettingConfig.BGMVolumValue
  node_root.BGMProgressbar:SetPercent(nProValue)
  local bBGMVolumSwitcher = SettingConfig.BGMVolumSwitcher
  if bBGMVolumSwitcher then
    node_root.BGMCheckBox:SetCheckedState(1)
    node_root.BGMSlider:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    node_root.BGMCheckBox:SetCheckedState(0)
    node_root.BGMSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
  end
  node_root.BGMSlider:SetValue(nProValue)
end
function UI:InitWeaponVolume(SettingConfig)
  local node_root = self.UIRoot
  local nProValue = SettingConfig.WeaponVolumValue
  node_root.WeaponProgressBar:SetPercent(nProValue)
  node_root.WeaponSlider:SetValue(nProValue)
  node_root.WeaponTitleText:SetText(LocUtil.GetLocalizeResStr(64457))
  node_root.WeaponVolumeText:SetText(LocUtil.LocalizeResFormat(10283, string.format("%.1f", nProValue * 20 + 80)))
end
function UI:InitVehicleVolume(SettingConfig)
  local node_root = self.UIRoot
  local nProValue = SettingConfig.VehicleVolumValue
  node_root.VehicleProgressBar:SetPercent(nProValue)
  node_root.VehicleSlider:SetValue(nProValue)
  node_root.VehicleTitleText:SetText(LocUtil.GetLocalizeResStr(64458))
  node_root.VehicleVolumeText:SetText(LocUtil.LocalizeResFormat(10283, string.format("%.1f", nProValue * 20 + 80)))
end
function UI:InitVoiceVolume(SettingConfig)
  local node_root = self.UIRoot
  local nProValue = SettingConfig.VoiceVolumValue
  node_root.VoiceProgressBar:SetPercent(nProValue)
  node_root.VoiceSlider:SetValue(nProValue)
  node_root.VoiceTitleText:SetText(LocUtil.GetLocalizeResStr(64459))
  node_root.VoiceVolumeText:SetText(LocUtil.LocalizeResFormat(10283, string.format("%.1f", nProValue * 20 + 80)))
end
function UI:InitVoice(SettingConfig)
  local node_root = self.UIRoot
  local nMicphoneVolumPro = SettingConfig.MicphoneVolumValue
  node_root.MicphoneProgressBar:SetPercent(nMicphoneVolumPro)
  local bMicphoneVolumSwitcher = SettingConfig.MicphoneVolumSwitcher
  if bMicphoneVolumSwitcher then
    node_root.MicphoneSlider:SetWidgetVisibility(ESlateVisibility.Visible)
  end
  node_root.MicphoneSlider:SetValue(nMicphoneVolumPro)
  local nSpeakerVolumValue = SettingConfig.SpeakerVolumValue
  node_root.SpeakerProgressbar:SetPercent(nSpeakerVolumValue)
  local bSpeakerVolumSwitcher = SettingConfig.SpeakerVolumSwitcher
  if bSpeakerVolumSwitcher then
    node_root.SpeakerSlider:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    node_root.SpeakerSlider:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
  end
  node_root.SpeakerSlider:SetValue(nSpeakerVolumValue)
  local bVoiceSwitcher = SettingConfig.VoiceSwitcher
  if bVoiceSwitcher then
    node_root.CanHideNode:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    node_root.status_voice_on:SetWidgetVisibility(ESlateVisibility.Visible)
    node_root.status_voice_on:SetWidgetVisibility(ESlateVisibility.Hidden)
  else
    node_root.CanHideNode:SetWidgetVisibility(ESlateVisibility.Hidden)
    node_root.status_voice_on:SetWidgetVisibility(ESlateVisibility.Hidden)
    node_root.status_voice_on:SetWidgetVisibility(ESlateVisibility.Visible)
  end
end
function UI:InitNewBGM(SettingConfig)
  local node_root = self.UIRoot
  local bOpenNewMusic = SettingConfig.openNewMusic
  if bOpenNewMusic then
    node_root.Box_NewMusicClose:SetWidgetVisibility(ESlateVisibility.Hidden)
    node_root.Box_NewMusicOpen:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    node_root.Box_NewMusicClose:SetWidgetVisibility(ESlateVisibility.Visible)
    node_root.Box_NewMusicOpen:SetWidgetVisibility(ESlateVisibility.Hidden)
  end
end
function UI:InitLobbyBgm(SettingConfig)
  local node_root = self.UIRoot
  local bLobbyBgm = SettingConfig.LobbyBgm
  node_root.BGM_Lobby:SetIsChecked(bLobbyBgm)
  local bHallowma = SettingConfig.LobbyHallowma
  node_root.BGM_Hallowmas:SetIsChecked(bHallowma)
end
function UI:InitSoundQuality()
  local nQualityLevel = self.nCurSoundQuality
  local node_root = self.UIRoot
  if self:GetHighAudioDownloadState() == ENUM_DownloadState.Done then
    node_root.Panel_HighAudio_Size:SetWidgetVisibility(ESlateVisibility.Collapsed)
  else
    node_root.Panel_HighAudio_Size:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
  if nQualityLevel == 0 then
    node_root.SoundQuality_Lower:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    node_root.SoundQuality_Higher:SetWidgetVisibility(ESlateVisibility.Collapsed)
    node_root.SoundSuperHigh:SetWidgetVisibility(ESlateVisibility.Collapsed)
  elseif nQualityLevel == 1 then
    node_root.SoundQuality_Lower:SetWidgetVisibility(ESlateVisibility.Collapsed)
    node_root.SoundQuality_Higher:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    node_root.SoundSuperHigh:SetWidgetVisibility(ESlateVisibility.Collapsed)
  elseif nQualityLevel == 2 then
    node_root.SoundQuality_Lower:SetWidgetVisibility(ESlateVisibility.Collapsed)
    node_root.SoundQuality_Higher:SetWidgetVisibility(ESlateVisibility.Collapsed)
    node_root.SoundSuperHigh:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  end
end
function UI:InitSocialIslandVolume(SettingConfig)
  local node_root = self.UIRoot
  local value = SettingConfig.SocialIslandOtherVolume
  if value and node_root.SocialIslandProgressBar and node_root.SocialIslandVolumeSlider then
    node_root.SocialIslandProgressBar:SetPercent(value)
    node_root.SocialIslandVolumeSlider:SetValue(value)
  end
end
function UI:InitBackgroundChatSwitch()
  local node_root = self.UIRoot
  if self:CheckBackgroundChatOpen() then
    node_root.BackgroundChat:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    node_root.BackgroundChat:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function UI:InitBackgroundChat(SettingConfig)
  if not self:CheckBackgroundChatOpen() then
    return
  end
  local node_root = self.UIRoot
  local isBackgroundChat = SettingConfig.backgroundChat
  if isBackgroundChat then
    node_root.Box_BackgroundChatClose:SetWidgetVisibility(ESlateVisibility.Collapsed)
    node_root.Box_BackgroundChatOpen:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    node_root.Box_BackgroundChatClose:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    node_root.Box_BackgroundChatOpen:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function UI:InitBackgroundChatGuide()
  if not self:CheckBackgroundChatOpen() then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.BackgroundChatGuide
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData == nil then
    saveData = {}
    saveData.hasGuide = true
    PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
    self.UIRoot.ScrollBox_Items:SetScrollOffset(300)
  else
    self.UIRoot.ScrollBox_Items:SetScrollOffset(0)
  end
end
function UI:CheckBackgroundChatOpen()
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if platformName == DevicePlatformNameMacros.IOS and (PublishRegionMacros.IsBLUEHOLE() or PublishRegionMacros.IsJapanOrKorea()) then
    return false
  end
  return LobbySystem.CheckOpen(BP_ENUM_BACKGROUND_CHAT)
end
function UI:InitPreTeamupChatSwitch()
  local node_root = self.UIRoot
  if LobbySystem.CheckOpen(BP_ENUM_PRETEAMUP_CHAT) then
    node_root.PreTeamupChat:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    node_root.PreTeamupChat:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function UI:InitPreTeamupChat(value)
  if not LobbySystem.CheckOpen(BP_ENUM_PRETEAMUP_CHAT) then
    return
  end
  if not LobbySystem.roleData.social_private_data or not LobbySystem.roleData.social_private_data[4] then
    return
  end
  local isOn = LobbySystem.roleData.social_private_data[4] == 1 and true or false
  if value then
    isOn = value == 1
  end
  local node_root = self.UIRoot
  if isOn then
    node_root.Box_PreTeamUpChatClose:SetWidgetVisibility(ESlateVisibility.Collapsed)
    node_root.Box_PreTeamUpChatOpen:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
  else
    node_root.Box_PreTeamUpChatClose:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    node_root.Box_PreTeamUpChatOpen:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function UI:InitDirectionalMic()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local bAvailable = Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and not PublishRegionMacros.IsBLUEHOLE()
  self:SetWidgetVisible(self.UIRoot.Switch_DirectionalMic, bAvailable)
  if not bAvailable then
    return
  end
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    local node_root = self.UIRoot
    if SettingConfig.bDirectionalMic then
      node_root.DirectionalMic_Off:SetWidgetVisibility(ESlateVisibility.Collapsed)
      node_root.DirectionalMic_On:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    else
      node_root.DirectionalMic_Off:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
      node_root.DirectionalMic_On:SetWidgetVisibility(ESlateVisibility.Collapsed)
    end
  end
end