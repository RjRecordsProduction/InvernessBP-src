local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local logic_background_chat_voice = require("client.slua.logic.chat_voice.logic_background_chat_voice")
local Enum_iOSAudioFeature = logic_chat_voice_const.Enum_iOSAudioFeature
local logic_antsvoice_interface = {
  curAntsVoiceMode = -1,
  IosVoiceRestoreTimer = nil,
  voiceSdkInited = false,
  VoiceSDKBinFileList = {
    "dse_v1_1.nn",
    "dse_v1_2.nn",
    "dse_v1_3.nn",
    "dse_v1_4.nn",
    "dse_v1_align.nn",
    "encoder_v4_small.nn",
    "decoder_v4_small.nn",
    "3aba7be2f55d9e760dd36c04c9ffb5e7d69f5125",
    "wave_dafx_data.bin"
  },
  VoiceDataIndexType = {openid = 1, uid = 2},
  ReloadWWisePluginCounter = 0,
  wwisePluginLoaded = false,
  DirectionalCapture = false
}
function logic_antsvoice_interface:OnInitialize()
  logic_antsvoice_interface.__super.OnInitialize(self)
  self.sDevicePlatformName = Client.GetDevicePlatformName()
  self.AntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  logic_background_chat_voice:OnInitialize()
  self:InitVoiceSDKFiles()
end
function logic_antsvoice_interface:RegistEvents()
  self:AddControlEvent(self.AntsVoiceInterface, "BeforeVoiceSDKInitDelegate", self.OnBeforeVoiceSDKInit, self)
  self:AddControlEvent(self.AntsVoiceInterface, "AfterVoiceSDKInitDelegate", self.OnAfterVoiceSDKInit, self)
  self:AddControlEvent(self.AntsVoiceInterface, "AudioRouteChangedAfterSpeakerDelegate", self.OnAudioRouteChangedAfterSpeaker, self)
  self:AddControlEvent(self.AntsVoiceInterface, "AudioSessionInterruptedDelegate", self.OnAudioSessionInterrupted, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactivated, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.OnApplicationDeactivated, self)
  local AkAudioMonitor = import("AkAudioMonitor")
  self.MonitorData = AkAudioMonitor.GetMonitorDataPtr()
  self:AddControlEvent(self.MonitorData, "AkAudioEventTrigger", self.OnAudioEventSatusChanged, self)
  local enbaleAudioRouteChangedNotify = HDmpveRemote.HDmpveRemoteConfigGetBool("EnaleAudioRouteChangedNotify", true)
  self.AntsVoiceInterface:InstallSystemAudioEventListener(enbaleAudioRouteChangedNotify)
end
function logic_antsvoice_interface:OnLogin(bReLogin)
end
function logic_antsvoice_interface:OnLogOut()
  log(bWriteLog and "[muidarzhang] logic_antsvoice_interface:OnLogOut")
  self.AntsVoiceInterface:ResetWhenLogOut()
  local AkGameplayStatics = import("AkGameplayStatics")
  local UIUtil = require("client.common.ui_util")
  AkGameplayStatics.PostEventAtLocation(nil, FVector(0, 0, 0), FRotator(0, 0, 0), "avStop", UIUtil.GetGameInstance())
  logic_antsvoice_interface.wwisePluginLoaded = false
end
function logic_antsvoice_interface:OnPreSwitchGameStatus(preState, nextState)
  if self:IsEnableCivilFile() then
    self:EnableCivilFile(false)
    log(bWriteLog and "logic_antsvoice_interface:OnPreSwitchGameStatus disable CivilFile")
  end
end
function logic_antsvoice_interface:OnPostSwitchGameStatus(preState, nextState)
end
function logic_antsvoice_interface:OnApplicationReactivated()
  logic_background_chat_voice:OnApplicationReactivated()
  if self.sDevicePlatformName == DevicePlatformNameMacros.IOS then
    if self.IosVoiceRestoreTimer ~= nil then
      self:RemoveTimer(self.IosVoiceRestoreTimer)
      self.IosVoiceRestoreTimer = nil
    end
    if logic_antsvoice_interface.MicAndSpeakerWasClosedByAudioSessionInterrupted == true then
      logic_antsvoice_interface.MicAndSpeakerWasClosedByAudioSessionInterrupted = false
      self:RecoverMicAndSpeakerAfterAudioSessionInterrupted()
    end
    self.IosVoiceRestoreTimer = self:AddTimerOnce(4.5, function()
      self.AntsVoiceInterface:OnPause()
      self.AntsVoiceInterface:OnResume()
    end)
  end
end
function logic_antsvoice_interface:OnApplicationDeactivated()
  logic_background_chat_voice:OnApplicationDeactivated()
end
function logic_antsvoice_interface:OnAudioEventSatusChanged(name, status)
  if name == "avPlay" then
    log(bWriteLog and "logic_antsvoice_interface:OnAudioEventSatusChanged: " .. name .. ", " .. status)
    local shouldReloadWWisePlugin = true
    if self.sDevicePlatformName == DevicePlatformNameMacros.Android then
      if logic_antsvoice_interface.ReloadWWisePluginCounter > 5 then
        shouldReloadWWisePlugin = false
      else
        logic_antsvoice_interface.ReloadWWisePluginCounter = logic_antsvoice_interface.ReloadWWisePluginCounter + 1
      end
    end
    if GameStatus.GetGameStatus() == GameStatus.Login then
      shouldReloadWWisePlugin = false
    end
    if status == 1 then
      logic_antsvoice_interface.wwisePluginLoaded = false
    end
    if status == 1 and shouldReloadWWisePlugin then
      self:ReloadWWisePlugin()
    end
  end
end
function logic_antsvoice_interface:GetGVoiceInterface()
  if not self.AntsVoiceInterface then
    self.AntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  end
  return self.AntsVoiceInterface
end
function logic_antsvoice_interface:InitVoiceSDKFiles()
  log(bWriteLog and "logic_antsvoice_interface:InitVoiceSDKFiles")
  if not self:IsVoiceBinInPak() then
    return
  end
  local VoiceSDKBinFileVerKey = "VoiceSDKBinFileVer"
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local VoiceSDKConfig = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVoiceSDKConfig) or {}
  log_tree("WSL", VoiceSDKConfig)
  log(bWriteLog and "logic_antsvoice_interface:InitVoiceSDKFiles VoiceSDKConfig: " .. Client.GetApplicationVersion())
  if VoiceSDKConfig[VoiceSDKBinFileVerKey] and VoiceSDKConfig[VoiceSDKBinFileVerKey] == Client.GetApplicationVersion() then
    log(bWriteLog and "logic_antsvoice_interface:InitVoiceSDKFiles same version")
    return
  end
  VoiceSDKConfig[VoiceSDKBinFileVerKey] = Client.GetApplicationVersion()
  PlayerPrefsSystem.SaveTableToFile_N(VoiceSDKConfig, PlayerPrefsSystem.ePlayerPrefsType.eVoiceSDKConfig)
  for k, toFetchFile in pairs(logic_antsvoice_interface.VoiceSDKBinFileList) do
    local StringUtil = require("common.string_util")
    if not StringUtil.Ends(toFetchFile, ".bin") and not StringUtil.Ends(toFetchFile, ".nn") then
      local encrypt_util = require("client.common.encrypt_util")
      toFetchFile = encrypt_util:CommonXORDecryption(toFetchFile)
    end
    local localFilePath = string.format("%sVoiceBin/%s", Client.ProjectSavedDir(), toFetchFile)
    local pakFilePath = string.format("%sTemplates/Data/VoiceSDK/%s", Client.ProjectContentDir(), toFetchFile)
    local ret = Client.FetchFileFromPAK(pakFilePath, localFilePath, true)
    log(bWriteLog and string.format("logic_antsvoice_interface:InitVoiceSDKFiles copy file: %s ret: %d", toFetchFile, ret))
  end
end
function logic_antsvoice_interface:Invoke(cmd, param1, param2, extraInfo)
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  uAntsVoiceInterface:Invoke(cmd, param1, param2, extraInfo)
end
function logic_antsvoice_interface:StopRecord()
  self.AntsVoiceInterface:StopRecord()
end
function logic_antsvoice_interface:GetVoiceLength()
  return self.AntsVoiceInterface:GetVoiceLength()
end
function logic_antsvoice_interface:UploadRecordFile(permanent, exter_info)
  if permanent == nil then
    permanent = false
  end
  if exter_info ~= nil then
    local BusinessHelper = import("BusinessHelper")
    local TssGameid = BusinessHelper.GetTSSGameId()
    local exter_info_str = string.format("%s%sgame_id=%s", tostring(exter_info), logic_chat_voice_const.ClientCallbackParamSep, tostring(TssGameid))
    local len = string.len(exter_info_str)
    if 0 < len then
      self:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_SET_CALLBACK_DATA, len, 0, exter_info_str)
    end
  end
  self.AntsVoiceInterface:UploadRecordFile(permanent)
end
function logic_antsvoice_interface:UploadFile(filePath, permanent, exter_info)
  if permanent == nil then
    permanent = false
  end
  if exter_info ~= nil then
    local BusinessHelper = import("BusinessHelper")
    local TssGameid = BusinessHelper.GetTSSGameId()
    local exter_info_str = string.format("%s%sgame_id=%s", tostring(exter_info), logic_chat_voice_const.ClientCallbackParamSep, tostring(TssGameid))
    local len = string.len(exter_info_str)
    if 0 < len then
      self:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_SET_CALLBACK_DATA, len, 0, exter_info_str)
    end
  end
  self.AntsVoiceInterface:UploadRecordedFile(filePath, 10000, permanent)
end
function logic_antsvoice_interface:OpenMic()
  self.AntsVoiceInterface:OpenMic()
end
function logic_antsvoice_interface:OpenSpeaker()
  self.AntsVoiceInterface:OpenSpeaker()
end
function logic_antsvoice_interface:EnableReportALLAbroad(val1, val2, val3)
  return self.AntsVoiceInterface:EnableReportALLAbroad(val1, val2, val3)
end
function logic_antsvoice_interface:CloseMic()
  self.AntsVoiceInterface:CloseMic()
end
function logic_antsvoice_interface:CloseSpeaker()
  self.AntsVoiceInterface:CloseSpeaker()
end
function logic_antsvoice_interface:StopPlayRecordFile()
  self.AntsVoiceInterface:StopPlayRecordFile()
end
function logic_antsvoice_interface:SetVoiceMode(mode)
  self.AntsVoiceInterface:SetVoiceMode(mode)
end
function logic_antsvoice_interface:OpenTeamSpeakerOnly()
  self.AntsVoiceInterface:OpenTeamSpeakerOnly(false)
end
function logic_antsvoice_interface:OpenAllSpeaker()
  self.AntsVoiceInterface:OpenAllSpeaker(false)
end
function logic_antsvoice_interface:OpenLbsSpeaker()
  self.AntsVoiceInterface:OpenIngameSpeaker()
end
function logic_antsvoice_interface:CloseLbsSpeaker()
  self.AntsVoiceInterface:CloseIngameSpeaker()
end
function logic_antsvoice_interface:CloseAllSpeaker()
  self.AntsVoiceInterface:CloseAllSpeaker(false)
end
function logic_antsvoice_interface:OpenTeamMicphoneOnly()
  return self.AntsVoiceInterface:OpenTeamMicphoneOnly(false)
end
function logic_antsvoice_interface:OpenLbsMicphone()
  self.AntsVoiceInterface:OpenIngameMicphone()
end
function logic_antsvoice_interface:CloseLbsMicphone()
  self.AntsVoiceInterface:CloseIngameMicphone()
end
function logic_antsvoice_interface:OpenAllMicphone()
  return self.AntsVoiceInterface:OpenAllMicphone(false)
end
function logic_antsvoice_interface:CloseAllMicphone()
  self.AntsVoiceInterface:CloseAllMicphone(false)
end
function logic_antsvoice_interface:StartInterphone()
  self.AntsVoiceInterface:StartInterphone()
end
function logic_antsvoice_interface:StopInterphone()
  self.AntsVoiceInterface:StopInterphone()
end
function logic_antsvoice_interface:OpenTeamInterphone()
  self.AntsVoiceInterface:OpenTeamInterphone()
end
function logic_antsvoice_interface:OpenLbsInterphone()
  self.AntsVoiceInterface:OpenLBSInterphone()
end
function logic_antsvoice_interface:OpenAllInterphone()
  self.AntsVoiceInterface:OpenAllInterphone()
end
function logic_antsvoice_interface:IsInterphoneMode()
  return self.AntsVoiceInterface:IsInterphoneMode()
end
function logic_antsvoice_interface:IsLbsInterphoneOpenned()
  return self.AntsVoiceInterface:IsLbsInterphoneOpenned()
end
function logic_antsvoice_interface:IsTeamInterphoneOpenned()
  return self.AntsVoiceInterface:IsTeamInterphoneOpenned()
end
function logic_antsvoice_interface:InitVoiceSDKComponent(role)
  self.AntsVoiceInterface:InitVoiceSDKComponent(role)
end
function logic_antsvoice_interface:QuitRoom()
  self.AntsVoiceInterface:QuitRoom()
end
function logic_antsvoice_interface:TestMic()
  self.AntsVoiceInterface:TestMic()
end
function logic_antsvoice_interface:JoinRoom(room, role)
  self.AntsVoiceInterface:JoinRoom(room, role)
end
function logic_antsvoice_interface:ApplyMessageKey()
  return self.AntsVoiceInterface:ApplyMessageKey()
end
function logic_antsvoice_interface:QuitLbsRoom()
  self.AntsVoiceInterface:QuitLbsRoom(false)
end
function logic_antsvoice_interface:UpdateVoiceCoordinate(LBSRoomName, x, y, z, radius)
  self.AntsVoiceInterface:UpdateVoiceCoordinate(LBSRoomName, x, y, z, radius)
end
function logic_antsvoice_interface:EnableMagicVoice(magicType, enable)
  self.AntsVoiceInterface:EnableMagicVoice(magicType, enable)
end
function logic_antsvoice_interface:EnableRecvMagicVoice(enable)
  self.AntsVoiceInterface:EnableRecvMagicVoice(enable)
end
function logic_antsvoice_interface:DownloadRecordFileV2(fileid, permanent)
  if permanent == nil then
    permanent = false
  end
  return self.AntsVoiceInterface:DownloadRecordFileV2(fileid, permanent)
end
function logic_antsvoice_interface:PlayRecordFileV2(fileid)
  return self.AntsVoiceInterface:PlayRecordFileV2(fileid)
end
function logic_antsvoice_interface:StartRecord()
  self.AntsVoiceInterface:StartRecord()
end
function logic_antsvoice_interface:TryReportSFXState(deviceIsNotMuted)
  if self.SFXStateHasReported == true then
    log(bWriteLog and "TryReportSFXState Skip by has reported")
    return
  end
  local sfxGameSwitcher = 0
  local deviceAudioVolume = 0
  local sfxState = 0
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig.EffectVolumSwitcher then
    sfxGameSwitcher = 1
  else
    sfxGameSwitcher = 0
  end
  local platName = Client.GetDevicePlatformName()
  if platName == DevicePlatformNameMacros.Android then
    local callVolume = Client.GetVolume(0)
    local musicVolume = Client.GetVolume(3)
    deviceAudioVolume = math.min(callVolume, musicVolume)
  else
    deviceAudioVolume = Client.GetVolume(0)
  end
  if 0 < deviceAudioVolume then
    deviceAudioVolume = 1
  else
    deviceAudioVolume = 0
  end
  if deviceIsNotMuted == -1 and deviceAudioVolume ~= 0 then
    deviceIsNotMuted = 1
  end
  if sfxGameSwitcher ~= 0 and deviceAudioVolume ~= 0 and deviceIsNotMuted ~= 0 then
    sfxState = 1
  end
  log(bWriteLog and "TryReportSFXState : " .. tostring(sfxGameSwitcher) .. ", " .. tostring(deviceAudioVolume) .. ", " .. tostring(deviceIsNotMuted) .. ", " .. tostring(sfxState))
  local eventParam = {}
  table.insert(eventParam, sfxGameSwitcher)
  table.insert(eventParam, deviceAudioVolume)
  table.insert(eventParam, deviceIsNotMuted)
  table.insert(eventParam, sfxState)
  Client.GEMReportSubEvent(GameFrontendHUD, "AudioEvent", "SFXState", eventParam)
  self.SFXStateHasReported = true
end
function logic_antsvoice_interface:DetectSFXState()
  local enableDetectSFXState = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableDetectSFXState", false)
  if enableDetectSFXState ~= true then
    log(bWriteLog and "DetectSFXState Skip by remote config")
    return
  end
  if self.SFXStateHasReported == true then
    log(bWriteLog and "DetectSFXState Skip by has reported")
    return
  end
  local UIUtil = require("client.common.ui_util")
  local platName = Client.GetDevicePlatformName()
  if platName == DevicePlatformNameMacros.Android then
    self:TryReportSFXState(-1)
  elseif platName == DevicePlatformNameMacros.IOS then
    local uAntsVoiceInterface = UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
    uAntsVoiceInterface:InitVoiceSDKComponent(DataMgr.roleData.openID)
    local state = uAntsVoiceInterface:CheckDeviceMuteState()
    if state ~= 0 then
      log(bWriteLog and "DetectSFXState Skip by CheckDeviceMuteState failed")
    end
  end
end
function logic_antsvoice_interface:CommonTestMic()
  self.AntsVoiceInterface:CommonTestMic()
end
function logic_antsvoice_interface:TeamMicphoneEnable()
  return self.AntsVoiceInterface:TeamMicphoneEnable()
end
function logic_antsvoice_interface:GetMicphoneState()
  return self.AntsVoiceInterface:GetMicState()
end
function logic_antsvoice_interface:TeamSpeakerEnable()
  return self.AntsVoiceInterface:TeamSpeakerEnable()
end
function logic_antsvoice_interface:JoinLbsRoom(room, user)
  self.AntsVoiceInterface:JoinLbsRoom(room, user)
end
function logic_antsvoice_interface:CheckAndEnableRoomSpeaker()
  self.AntsVoiceInterface:CheckAndEnableRoomSpeaker()
end
function logic_antsvoice_interface:ForbidLbsMemberVoiceById(member, enable)
  self.AntsVoiceInterface:ForbidLbsMemberVoiceById(member, enable)
end
function logic_antsvoice_interface:EnbleMicAndSpeakerByRoomName(room, enable)
  self.AntsVoiceInterface:EnbleMicAndSpeakerByRoomName(room, enable)
end
function logic_antsvoice_interface:SetLbsRoomEnableStatus(status)
  self.AntsVoiceInterface:SetLbsRoomEnableStatus(status)
end
function logic_antsvoice_interface:InitMicAndSpeakerVolum()
  log(bWriteLog and "[muidarzhang] logic_antsvoice_interface:InitMicAndSpeakerVolum")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  self.AntsVoiceInterface:SetMicphoneStatus(SettingConfig.MicphoneVolumSwitcher)
  self.AntsVoiceInterface:SetMicphoneVolum(SettingConfig.MicphoneVolumValue)
  self.AntsVoiceInterface:SetSpeakerStatus(SettingConfig.SpeakerVolumSwitcher)
  self.AntsVoiceInterface:SetSpeakerVolum(SettingConfig.SpeakerVolumValue)
  self.AntsVoiceInterface:SetLbsRoomEnableStatus(SettingConfig.VoiceChannel == 2)
end
function logic_antsvoice_interface:ResetWhenLogOut()
  self.AntsVoiceInterface:ResetWhenLogOut()
end
function logic_antsvoice_interface:SetVoiceSDKSupportBackgroundChat(IsSupportBGChat)
  self.AntsVoiceInterface:SetVoiceSDKSupportBackgroundChat(IsSupportBGChat)
  logic_background_chat_voice:SetVoiceSDKSupportBackgroundChat(IsSupportBGChat)
  local EnableBGVoiceChatService = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableBackGroundVoiceChatService", true)
  if EnableBGVoiceChatService then
    self.AntsVoiceInterface:SetVoiceSDKChatServiceEnable(IsSupportBGChat)
  end
end
function logic_antsvoice_interface:GetRoomStatus(RoonId)
  return self.AntsVoiceInterface:GetRoomStatus(RoonId)
end
function logic_antsvoice_interface:SetAntsVoiceServerInfo(antsVoiceUrl)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() and self.sDevicePlatformName == DevicePlatformNameMacros.IOS then
    return
  end
  local voiceServerUrl, voiceBKIP = self:GetVoiceServerUrlsAndIP(antsVoiceUrl)
  self.AntsVoiceInterface:SetServerInfo(voiceServerUrl, voiceBKIP)
end
function logic_antsvoice_interface:ResetAntsVoiceMode(mode)
  log(bWriteLog and "[muidarzhang] logic_chat_voice:_ResetAntsVoiceMode, mode: " .. tostring(mode))
  self.curAntsVoiceMode = mode
  self:SetVoiceMode(mode)
end
function logic_antsvoice_interface:GetTeamRoomName()
  return self.AntsVoiceInterface:GetTeamRoomName()
end
function logic_antsvoice_interface:GetLbsRoomName()
  return self.AntsVoiceInterface:GetLbsRoomName()
end
function logic_antsvoice_interface:AlwaysDisableRoomMic(roomName, switch)
  if not roomName then
    log(bWriteLog and "logic_antsvoice_interface:AlwaysDisableRoomMic roomName is nil")
    return
  end
  return self.AntsVoiceInterface:AlwaysDisableRoomMic(roomName, switch == true)
end
function logic_antsvoice_interface:LbsMicphoneEnable()
  return self.AntsVoiceInterface:LbsMicphoneEnable()
end
function logic_antsvoice_interface:LbsSpeakerEnable()
  return self.AntsVoiceInterface:LbsSpeakerEnable()
end
function logic_antsvoice_interface:QuitVoiceRoom(room_id)
  return self.AntsVoiceInterface:QuitVoiceRoom(room_id)
end
function logic_antsvoice_interface:SpeechTranslate(fileID, srcLang, targetLang, transType, timeoutMS)
  if timeoutMS == nil then
    timeoutMS = 10000
  end
  if transType == nil then
    transType = logic_chat_voice_const.SpeechTranslateType.SPEECH_TRANSLATE_STTS
  end
  self.AntsVoiceInterface:SpeechTranslate(fileID, srcLang, targetLang, transType, timeoutMS)
end
function logic_antsvoice_interface:DownloadRecordedFile(fileID, downloadFilePath, timeout, permanent)
  if timeout == nil then
    timeout = 60000
  end
  if permanent == nil then
    permanent = false
  end
  self.AntsVoiceInterface:DownloadRecordedFile(fileID, downloadFilePath, timeout, permanent)
end
function logic_antsvoice_interface:GetLocalRecordFilePath(voice_file_name)
  return self.AntsVoiceInterface:GetLocalRecordFilePath(voice_file_name)
end
function logic_antsvoice_interface:PlayRecordedFile(record_file_path)
  return self.AntsVoiceInterface:PlayRecordedFile(record_file_path)
end
function logic_antsvoice_interface:EnableCivilFile(enable)
  return self.AntsVoiceInterface:EnableCivilFile(enable)
end
function logic_antsvoice_interface:IsEnableCivilFile()
  return self.AntsVoiceInterface:IsEnableCivilFile()
end
function logic_antsvoice_interface:GetRoomMemberVoiceData(openid, index_type, data_type, only_latest)
  if index_type == nil then
    index_type = logic_antsvoice_interface.VoiceDataIndexType.openid
  end
  if data_type == nil then
    data_type = 1
  end
  if only_latest == nil then
    only_latest = false
  end
  return self.AntsVoiceInterface:GetRoomMemberVoiceData(openid, index_type, data_type, only_latest)
end
function logic_antsvoice_interface:IsVoiceRoomHasSpeakDataInLastSeconds(room_type, seconds)
  if seconds == nil then
    seconds = self:GetReportBufferTime()
  end
  return self.AntsVoiceInterface:IsVoiceRoomHasSpeakDataInLastSeconds(room_type, seconds)
end
function logic_antsvoice_interface:FetchOfflineMessageExtraInfo(content)
  local orgin_content, exter_info
  local idx1, idx2, temp_str = string.find(content, "&&", 1, false)
  log(bWriteLog and "logic_antsvoice_interface:FetchOfflineMessageExtraInfo" .. tostring(temp_str))
  if idx1 then
    local content_len = string.len(content)
    orgin_content = string.sub(content, 1, idx1 - 1)
    exter_info = string.sub(content, idx2 + 1, content_len)
    if exter_info == nil or string.len(exter_info) <= 0 then
      exter_info = nil
    else
      local exter_idx1, exter_idx2, exter_temp_str = string.find(exter_info, logic_chat_voice_const.ClientCallbackParamSep, 1, false)
      log(bWriteLog and "logic_antsvoice_interface:FetchOfflineMessageExtraInfo" .. tostring(exter_idx2) .. tostring(exter_temp_str))
      if exter_idx1 then
        exter_info = string.sub(exter_info, 1, exter_idx1 - 1)
      end
    end
  else
    orgin_  end
  return orgin_content, exter_info
end
function logic_antsvoice_interface:RSTSSpeechToText(LangID, SceneID)
  if not self.AntsVoiceInterface then
    log_error("logic_antsvoice_interface:RSTSSpeechToText - AntsVoiceInterface not initialized")
    return
  end
  if not LangID then
    log_error("logic_antsvoice_interface:RSTSSpeechToText - LangID is nil! " .. debug.traceback())
    return
  end
  local sExtraInfo = ""
  if SceneID and SceneID ~= 0 then
    local tExtraInfo = {
      ASRSceneID = tostring(SceneID)
    }
    sExtraInfo = json.encode(tExtraInfo)
    log(bWriteLog and string.format("logic_antsvoice_interface:RSTSSpeechToText - LangID: %s, SceneID: %s, ExtraInfo: %s", tostring(LangID), tostring(SceneID), sExtraInfo))
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    sExtraInfo = base64.encode(sExtraInfo)
    log(bWriteLog and string.format("logic_antsvoice_interface:RSTSSpeechToText(base64) - LangID: %s, SceneID: %s, ExtraInfo: %s", tostring(LangID), tostring(SceneID), sExtraInfo))
  else
    log(bWriteLog and string.format("logic_antsvoice_interface:RSTSSpeechToText - LangID: %s, No SceneID (compatibility mode)", tostring(LangID)))
  end
  local recordFilePath = self.AntsVoiceInterface:GetLocalRecordFilePath("upload.voice")
  self.AntsVoiceInterface:RSTSSpeechToText(LangID, sExtraInfo, recordFilePath)
end
function logic_antsvoice_interface:RSTSStartRecording(LangID, TargetLangID)
  if not self.AntsVoiceInterface then
    log_error("logic_antsvoice_interface:RSTSSpeechToText - AntsVoiceInterface not initialized")
    return
  end
  self.AntsVoiceInterface:RSTSStartRecording(LangID, {TargetLangID}, 1, logic_chat_voice_const.SpeechTranslateType.SPEECH_TRANSLATE_STTS, 10000, "", "")
end
function logic_antsvoice_interface:RSTSStopRecording()
  self.AntsVoiceInterface:RSTSStopRecording()
end
function logic_antsvoice_interface:OnBeforeVoiceSDKInit()
  log(bWriteLog and "[WSL]logic_antsvoice_interface:OnBeforeVoiceSDKInit")
  if self:IsVoiceBinInPak() then
    local BusinessHelper = import("BusinessHelper")
    local localResFileFullPath = BusinessHelper.GetMobileBasePath(string.format("%sVoiceBin", Client.ProjectSavedDir()))
    local AntsVoiceInterface = self:GetGVoiceInterface()
    AntsVoiceInterface:SetResourePath(localResFileFullPath)
  end
end
function logic_antsvoice_interface:OnAfterVoiceSDKInit()
  log(bWriteLog and "[WSL]logic_antsvoice_interface:OnAfterVoiceSDKInit")
  logic_antsvoice_interface.voiceSdkInited = true
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  uAntsVoiceInterface:SetUserInfo(string.format("%s&%s", DataMgr.roleData.openID or "", tostring(DataMgr.roleData.uid or 0)))
  log(bWriteLog and "[WSL]logic_antsvoice_interface:OnAfterVoiceSDKInit EnableLog")
  if not Client.IsShipping() or not globalConfig.IsDirectConnect() then
    uAntsVoiceInterface:EnableLog(true)
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE then
    local EnableDoubleMic = false
    if self.sDevicePlatformName == DevicePlatformNameMacros.IOS then
      EnableDoubleMic = true
    end
    EnableDoubleMic = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableDoubleMic", EnableDoubleMic)
    if EnableDoubleMic then
      uAntsVoiceInterface:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_OPEN_DOUBLE_MIC, 1, 0, "")
    end
  end
  local FixIOS26Bluetooth = HDmpveRemote.HDmpveRemoteConfigGetBool("FixIOS26Bluetooth", false)
  if FixIOS26Bluetooth then
    uAntsVoiceInterface:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_VOICE_FIX_IOS26_BLUETOOTH, 1, 0, "")
  else
    uAntsVoiceInterface:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_VOICE_FIX_IOS26_BLUETOOTH, 0, 0, "")
  end
  local ReportBufferTime = self:GetReportBufferTime()
  uAntsVoiceInterface:SetReportBufferTime(ReportBufferTime)
  self:ReloadWWisePlugin()
  local UserSettingIsEnableDirectionalCapture = self:GetDirectionalCaptureFromUserSetting()
  self:EnableDirectionalCapture(UserSettingIsEnableDirectionalCapture)
end
function logic_antsvoice_interface:ReloadWWisePlugin()
  log(bWriteLog and "[WSL]logic_antsvoice_interface:ReloadWWisePlugin")
  if self:IsWWiseVoicePluginEnable() == true then
    self.AntsVoiceInterface.SpeekerVolumeMUFactor = 149
    local gameInstance = slua.getGameInstance()
    gameInstance:ExecuteCMD("EnableAkDebugEventInfo", 1)
    local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    uAntsVoiceInterface:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_ENABLE_WWISE_PLUGIN, 1, 0, "")
    if logic_antsvoice_interface.wwisePluginLoaded == false then
      log(bWriteLog and "[WSL]Load voice_290.bnk and post avPlay event")
      local AkGameplayStatics = import("AkGameplayStatics")
      AkGameplayStatics.LoadBankByName("Voice_290")
      local TimeTicker = require("common.time_ticker")
      TimeTicker.AddTimerOnce(0.5, function()
        local UIUtil = require("client.common.ui_util")
        AkGameplayStatics.PostEventAtLocation(nil, FVector(0, 0, 0), FRotator(0, 0, 0), "avStop", UIUtil.GetGameInstance())
      end)
      TimeTicker.AddTimerOnce(1, function()
        local UIUtil = require("client.common.ui_util")
        AkGameplayStatics.PostEventAtLocation(nil, FVector(0, 0, 0), FRotator(0, 0, 0), "avPlay", UIUtil.GetGameInstance())
      end)
      logic_antsvoice_interface.wwisePluginLoaded = true
    else
      log(bWriteLog and "[WSL]wwise plugin already loaded")
    end
  end
end
function logic_antsvoice_interface:IsWWiseVoicePluginEnable()
  log(bWriteLog and "[WSL]logic_antsvoice_interface:IsWWiseVoicePluginEnable")
  local WWiseVoicePluginEnable = false
  if self.sDevicePlatformName == DevicePlatformNameMacros.IOS then
    local EnableWWiseVoicePluginOSVers = HDmpveRemote.HDmpveRemoteConfigGetString("EnableWWiseVoicePluginOSVers", "")
    if EnableWWiseVoicePluginOSVers == "*" then
      WWiseVoicePluginEnable = true
    elseif EnableWWiseVoicePluginOSVers == "-" then
      local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
      local OSMajorVersion = device_module:GetOSMajorVersion()
      if 17 <= OSMajorVersion then
        WWiseVoicePluginEnable = true
      end
    elseif EnableWWiseVoicePluginOSVers ~= "" then
      local StringUtil = require("common.string_util")
      local StrArray = StringUtil.Split(EnableWWiseVoicePluginOSVers, ",")
      local osVersion = Client.GetOSVersion()
      for i, v in ipairs(StrArray) do
        if string.sub(osVersion, 1, string.len(v)) == v then
          WWiseVoicePluginEnable = true
          break
        end
      end
    end
  elseif self.sDevicePlatformName == DevicePlatformNameMacros.Android then
    local EnableAOSWWiseVoicePlugin = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableAOSWWiseVoicePlugin", false)
    WWiseVoicePluginEnable = logic_antsvoice_interface.DirectionalCapture or EnableAOSWWiseVoicePlugin
  end
  log(bWriteLog and "[WSL]logic_antsvoice_interface:IsWWiseVoicePluginEnable: " .. tostring(WWiseVoicePluginEnable))
  return WWiseVoicePluginEnable
end
function logic_antsvoice_interface:OnAudioRouteChangedAfterSpeaker()
  log(bWriteLog and "[WSL]logic_antsvoice_interface:OnAudioRouteChangedAfterSpeaker")
end
function logic_antsvoice_interface:OnAudioSessionInterrupted(status)
  log(bWriteLog and "[WSL]logic_antsvoice_interface:OnAudioSessionInterrupted: " .. tostring(status))
  if not logic_antsvoice_interface:IsWWiseVoicePluginEnable() then
    log(bWriteLog and "[WSL]logic_antsvoice_interface:OnAudioSessionInterrupted do nothing by disable wwise voice plugin")
    return
  end
  if status == 0 then
    logic_antsvoice_interface.MicAndSpeakerWasClosedByAudioSessionInterrupted = false
    self:RecoverMicAndSpeakerAfterAudioSessionInterrupted()
  elseif status == 1 then
    logic_antsvoice_interface.MicAndSpeakerWasClosedByAudioSessionInterrupted = true
    local miniInterruptedOSVer = HDmpveRemote.HDmpveRemoteConfigGetInt("MiniInterruptedOSVer", 26)
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    local OSMajorVersion = device_module:GetOSMajorVersion()
    if miniInterruptedOSVer <= OSMajorVersion then
      log(bWriteLog and "logic_antsvoice_interface:OnAudioSessionInterrupted return by bigger os version")
      return
    end
    self.AntsVoiceInterface:CloseVoiceSpeaker()
    self.AntsVoiceInterface:CloseVoiceMic()
  end
end
function logic_antsvoice_interface:OnKwsNotify(retCode, content)
  log(bWriteLog and "[WSL]logic_antsvoice_interface:OnKwsNotify: " .. tostring(retCode) .. " " .. content)
end
function logic_antsvoice_interface:GetVoiceServerUrlsAndIP(voiceServerUrl)
  local serverArea = ""
  local host = voiceServerUrl:match("://([^:/]+)")
  if host then
    serverArea = host:match("^([a-z]+)%.")
  end
  local PrimaryServerUrl = ""
  local BKServerUrl = ""
  local BKServerIPs = ""
  local WSServerUrl = ""
  local cfg = CDataTable.GetTable("VoiceServerList")
  for _, v in pairs(cfg) do
    if v.Area == serverArea then
      PrimaryServerUrl = v.ServerUrl
      BKServerUrl = v.BKServerUrl
      WSServerUrl = v.WSServerUrl
      BKServerIPs = v.VoiceBKIPs
      break
    end
  end
  local BKServerIP = ""
  if 0 < #PrimaryServerUrl and string.find(voiceServerUrl, PrimaryServerUrl) then
    BKServerIP = self:GetVoiceSDKBackupIP(BKServerIPs)
    if not string.find(voiceServerUrl, "bk%-" .. serverArea) then
      if 0 < #BKServerUrl and 0 < #WSServerUrl then
        voiceServerUrl = string.format("%s|%s|%s", voiceServerUrl, BKServerUrl, WSServerUrl)
      elseif 0 < #BKServerUrl and #WSServerUrl <= 0 then
        voiceServerUrl = string.format("%s|%s", voiceServerUrl, BKServerUrl)
      end
    elseif 0 < #WSServerUrl then
      voiceServerUrl = string.format("%s|%s", voiceServerUrl, WSServerUrl)
    end
  end
  return voiceServerUrl, BKServerIP
end
function logic_antsvoice_interface:GetVoiceSDKBackupIP(backupIPStr)
  local backupIP = ""
  if 0 < #backupIPStr then
    local StringUtil = require("common.string_util")
    local backupIPs = StringUtil.Split(backupIPStr, ";")
    local backupIPNum = #backupIPs
    if 0 < backupIPNum then
      local uid = tonumber(DataMgr.roleData.uid) or 1
      local backupIPIndex = uid % backupIPNum + 1
      if 0 < backupIPIndex and backupIPNum >= backupIPIndex then
        backupIP = backupIPs[backupIPIndex]
      end
    end
  end
  if backupIP == nil then
    backupIP = ""
  end
  return backupIP
end
function logic_antsvoice_interface:IsVoiceBinInPak()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and string.format("logic_antsvoice_interface:IsVoiceBinInPak skip by bluehole"))
    return false
  end
  local platName = Client.GetDevicePlatformName()
  if platName ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and string.format("logic_antsvoice_interface:IsVoiceBinInPak skip"))
    return false
  end
  return true
end
function logic_antsvoice_interface:RecoverMicAndSpeakerAfterAudioSessionInterrupted()
  log(bWriteLog and "logic_antsvoice_interface:RecoverMicAndSpeakerAfterAudioSessionInterrupted")
  if self.AntsVoiceInterface:LbsSpeakerEnable() or self.AntsVoiceInterface:TeamSpeakerEnable() then
    local TimeTicker = require("common.time_ticker")
    TimeTicker.AddTimerOnce(0.03, function()
      self.AntsVoiceInterface:OpenVoiceSpeaker()
    end)
  end
  if self.AntsVoiceInterface:LbsMicphoneEnable() or self.AntsVoiceInterface:TeamMicphoneEnable() then
    local TimeTicker = require("common.time_ticker")
    TimeTicker.AddTimerOnce(0.09, function()
      self.AntsVoiceInterface:OpenVoiceMic()
    end)
  end
end
function logic_antsvoice_interface:IsBluetoothModeNeedToGrantPermission()
  local needToGranedPermission = false
  local platName = Client.GetDevicePlatformName()
  if platName == DevicePlatformNameMacros.Android and Client.IsUsingBluetooth() then
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    local OSMajorVersion = device_module:GetOSMajorVersion()
    if 14 <= OSMajorVersion then
      local SystemPermissionHelper = import("SystemPermissionHelper")
      local instance = SystemPermissionHelper.GetInstance()
      local hasBluetoothPermissionGraned = instance:AndroidIsPermissionGranted("android.permission.BLUETOOTH_CONNECT")
      if not hasBluetoothPermissionGraned then
        needToGranedPermission = true
      end
    end
  end
  return needToGranedPermission
end
function logic_antsvoice_interface:IsEqualOrContained(subStr, fullStr)
  if subStr == fullStr then
    return true
  end
  for part in string.gmatch(fullStr, "[^|]+") do
    if subStr == part then
      return true
    end
  end
  return false
end
function logic_antsvoice_interface:EnableDirectionalCapture(enable)
  log(bWriteLog and "[WSL]logic_antsvoice_interface:EnableDirectionalCapture: " .. tostring(enable))
  if self.sDevicePlatformName == DevicePlatformNameMacros.IOS then
    log(bWriteLog and "[WSL]logic_antsvoice_interface:EnableDirectionalCapture skip by ios")
    return
  end
  logic_antsvoice_interface.DirectionalCapture = enable
  if logic_antsvoice_interface.voiceSdkInited == false then
    log(bWriteLog and "[WSL]logic_antsvoice_interface:EnableDirectionalCapture skip by not inited")
    return
  end
  if enable then
    self:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_DIRECTIONAL_CAPTURE, 1, 0, "")
    self:ReloadWWisePlugin()
  else
    self:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_DIRECTIONAL_CAPTURE, 0, 0, "")
  end
end
function logic_antsvoice_interface:ReportPlayers(extraInfo, openidTable)
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  uAntsVoiceInterface:ReportPlayers(extraInfo, openidTable)
end
function logic_antsvoice_interface:GetReportBufferTime()
  local ReportBufferTime = HDmpveRemote.HDmpveRemoteConfigGetInt("GV_ReportBufferTime", 90)
  return ReportBufferTime
end
function logic_antsvoice_interface:GetDirectionalCaptureFromUserSetting()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.CE then
    log(bWriteLog and "[WSL]logic_antsvoice_interface:GetDirectionalCaptureFromUserSetting return true by ce version")
    return true
  end
  if self.sDevicePlatformName ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "[WSL]logic_antsvoice_interface:GetDirectionalCaptureFromUserSetting return false by not aos")
    return false
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if SettingConfig then
      log(bWriteLog and "[WSL]logic_antsvoice_interface:GetDirectionalCaptureFromUserSetting return " .. tostring(SettingConfig.bDirectionalMic))
      return SettingConfig.bDirectionalMic
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_antsvoice_interface = class(CModuleBase, nil, logic_antsvoice_interface)
return Clogic_antsvoice_interface