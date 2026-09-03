local UI = require("client.slua.umg.NewSetting.Sound.setting_sound_data")
local ESlateVisibility = UEnums.ESlateVisibility
function UI:SetAudioValue(sNameStr, nValue)
  nValue = nValue * 100
  local audio_util = require("client.common.audio_util")
  audio_util.SetRTPCValue(sNameStr, nValue, 0)
end
function UI:RefreshVolumeSliderShow(sNodeName, sSliderName, sAudioName, nValue)
  local node_root = self.UIRoot
  node_root[sNodeName]:SetPercent(nValue)
  node_root[sSliderName]:SetValue(nValue)
  self:SetAudioValue(sAudioName, nValue)
end
function UI:RefreshVolumeDataCache(sSettingKey, sNodeName)
  local node_root = self.UIRoot
  local node_pro = node_root[sNodeName]
  local nValue = node_pro and node_pro:GetValue() or 0
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig[sSettingKey] = nValue
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function UI:RefreshVolumeCheckBoxDataAndShow(sSettingKey, bIsCheck, sSliderName, sAudioName, sVolumeKey)
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local node_root = self.UIRoot
  SettingConfig[sSettingKey] = bIsCheck
  if bIsCheck then
    node_root[sSliderName]:SetWidgetVisibility(ESlateVisibility.Visible)
    self:SetAudioValue(sAudioName, SettingConfig[sVolumeKey])
  else
    node_root[sSliderName]:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    self:SetAudioValue(sAudioName, 0)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
end