local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local Enum_iOSAudioFeature = logic_chat_voice_const.Enum_iOSAudioFeature
local logic_background_chat_voice = {}
function logic_background_chat_voice:OnInitialize()
  self.BackgroundVoiceOpenning = false
  self.EnableiOSNewAudioSessionCategory = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableiOSNewAudioSessionCategory", true)
  self.EnableiOSBackgroudAudio = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableiOSBackgroudAudio", true)
  local forceBgChatAsyncDefault = true
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local OSMajorVersion = device_module:GetOSMajorVersion()
  if OSMajorVersion < 17 then
    forceBgChatAsyncDefault = false
  end
  self.FoceBgChatAsync = HDmpveRemote.HDmpveRemoteConfigGetBool("FoceBgChatAsync", forceBgChatAsyncDefault)
end
function logic_background_chat_voice:OnApplicationReactivated()
  log(bWriteLog and "logic_background_chat_voice:OnApplicationReactivated")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.iOS then
    return
  end
  if self.FoceBgChatAsync and self.BackgroundVoiceOpenning then
    local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    uAntsVoiceInterface:EnableVoiceChat(false)
    uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.BackgroundAudio, false)
  end
end
function logic_background_chat_voice:OnApplicationDeactivated()
  log(bWriteLog and "logic_background_chat_voice:OnApplicationDeactivated")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.iOS then
    return
  end
  if self.FoceBgChatAsync and self.BackgroundVoiceOpenning then
    local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if self.EnableiOSNewAudioSessionCategory then
      uAntsVoiceInterface:EnableVoiceChat(true)
    end
    if self.EnableiOSBackgroudAudio then
      uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.BackgroundAudio, true)
    end
  end
end
function logic_background_chat_voice:SetVoiceSDKSupportBackgroundChat(bSupport)
  self.BackgroundVoiceOpenning = bSupport
  if self.FoceBgChatAsync == false then
    local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if self.BackgroundVoiceOpenning then
      uAntsVoiceInterface:EnableVoiceChat(true)
      uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.Playback, true)
      uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.Record, true)
      uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.BackgroundAudio, true)
    else
      uAntsVoiceInterface:EnableVoiceChat(false)
      uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.Playback, false)
      uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.Record, false)
      uAntsVoiceInterface:SetFeature(Enum_iOSAudioFeature.BackgroundAudio, false)
    end
  end
end
return logic_background_chat_voice