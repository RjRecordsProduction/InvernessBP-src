local logic_chat_voice = {}
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local VoiceChangerMap = {"ar_f1", "ar_m1"}
function logic_chat_voice:CheckChatPrivacyAcceptStatus()
  local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
  return logic_chat_voice_utility.CheckChatPrivacyAcceptStatus()
end
function logic_chat_voice:CheckEUChatRestriction()
  local status = self:GetEUGDPRVoiceVerifyStatus()
  if status == logic_chat_voice_const.EUGDPRVoiceVerifyStatus.None or status == logic_chat_voice_const.EUGDPRVoiceVerifyStatus.VerifiedAndAgree then
    return false, status
  end
  return true, status
end
function logic_chat_voice:HandleEUChatRestriction(explicitStatus)
  if nil == explicitStatus then
    explicitStatus = self:GetEUGDPRVoiceVerifyStatus()
  end
  ShowNotice(46880036)
  if explicitStatus == logic_chat_voice_const.EUGDPRVoiceVerifyStatus.NotSend then
    UIManager.ShowUI(UIManager.UI_Config.EEAVoiceVerify_Popup_UIBP, explicitStatus)
  elseif explicitStatus == logic_chat_voice_const.EUGDPRVoiceVerifyStatus.NotVerified then
    UIManager.ShowUI(UIManager.UI_Config.EEAVoiceVerify_Popup_2_UIBP, explicitStatus)
  elseif explicitStatus == logic_chat_voice_const.EUGDPRVoiceVerifyStatus.NotAgree then
    UIManager.ShowUI(UIManager.UI_Config.EEAVoiceVerify_Popup_2_UIBP, explicitStatus)
  end
end
function logic_chat_voice:GetEUGDPRVoiceVerifyStatus()
  local logic_gdpr = require("client.slua.logic.gdpr.logic_gdpr")
  if false == logic_gdpr.LessThan16() then
    printf("logic_chat_voice:GetEUGDPRVoiceVerifyStatus not less than 16")
    return logic_chat_voice_const.EUGDPRVoiceVerifyStatus.None
  end
  local status = logic_chat_voice_const.EUGDPRVoiceVerifyStatus.NotSend
  local eea_mail_verify = DataMgr.roleData.eugdpr.eea_mail_verify
  if not eea_mail_verify then
    eea_mail_verify = {mail = ""}
    DataMgr.roleData.eugdpr.  elseif eea_mail_verify.mail == "" then
  elseif eea_mail_verify.voice_verify_status == nil or eea_mail_verify.voice_verify_status == 0 then
    status = logic_chat_voice_const.EUGDPRVoiceVerifyStatus.NotVerified
    eea_mail_verify.voice_verify_  else
    status = eea_mail_verify.voice_verify_status
    if status == 2 then
      status = logic_chat_voice_const.EUGDPRVoiceVerifyStatus.VerifiedAndAgree
    end
  end
  printf("logic_chat_voice:GetEUGDPRVoiceVerifyStatus status:%s, voice_verify_status:%s", status, eea_mail_verify.voice_verify_status)
  return status
end
function logic_chat_voice:RequestPrivacy(callback, content)
  self.logic_chat_voice_hardware_ins:RequestPrivacy(callback, content)
end
function logic_chat_voice:RequestPrivacyAndOpenMic(callback, content)
  self.logic_chat_voice_hardware_ins:RequestPrivacyAndOpenMic(callback, content)
end
function logic_chat_voice:TryStartRecordVoice(immediateUploadWhenStop)
  self.logic_chat_voice_voice_msg_ins:TryStartRecordVoice(immediateUploadWhenStop)
end
function logic_chat_voice:TryStopRecordVoice(immediateUploadWhenStop)
  self.logic_chat_voice_voice_msg_ins:TryStopRecordVoice(immediateUploadWhenStop)
end
function logic_chat_voice:TryCancelRecordVoice()
  self.logic_chat_voice_voice_msg_ins:TryCancelRecordVoice()
end
function logic_chat_voice:PlayVoiceFile(file_id, msg_length, extra_para)
  self.logic_chat_voice_voice_msg_ins:PlayVoiceFile(file_id, msg_length, extra_para)
end
function logic_chat_voice:AddDownloadFile(file_id, msg_length, extra_para)
  self.logic_chat_voice_voice_msg_ins:AddDownloadFile(file_id, msg_length, extra_para)
end
function logic_chat_voice:TryListenVoice(voiceLength)
  self.logic_chat_voice_voice_msg_ins:TryListenVoice(voiceLength)
end
function logic_chat_voice:UploadRecordedVoice(permanent, exter_info)
  self.logic_chat_voice_voice_msg_ins:UploadRecordedVoice(permanent, exter_info)
end
function logic_chat_voice:TryStopPlayRecordVoice()
  self.logic_chat_voice_voice_msg_ins:TryStopPlayRecordVoice()
end
function logic_chat_voice:TryStopListenVoice()
  self.logic_chat_voice_voice_msg_ins:StopListenVoice()
end
function logic_chat_voice:CheckIsAntsVoiceMsgInProcess()
  return self.logic_chat_voice_voice_msg_ins:CheckIsAntsVoiceMsgInProcess()
end
function logic_chat_voice:JoinLobbyVoiceRoom()
  self.logic_chat_voice_voice_room_ins:JoinLobbyVoiceRoom()
end
function logic_chat_voice:JoinLbsVoiceRoom(room)
  self.logic_chat_voice_voice_room_ins:JoinLbsVoiceRoom(room)
end
function logic_chat_voice:JoinAntsVoiceRoom(roomType, roomID, antsVoiceUrl)
  if not roomID or roomID == "" then
    if IsEditor then
      assert(false, "logic_chat_voice:JoinAntsVoiceRoom roomID is nil or empty")
    end
    log_error("logic_chat_voice:JoinAntsVoiceRoom roomID is nil or empty")
    return
  end
  self.logic_chat_voice_voice_room_ins:JoinAntsVoiceRoom(roomType, roomID, antsVoiceUrl)
end
function logic_chat_voice:QuitAntsVoiceRoom(roomType)
  self.logic_chat_voice_voice_room_ins:QuitAntsVoiceRoom(roomType)
end
function logic_chat_voice:ReconnectRoom()
  self.logic_chat_voice_voice_room_ins:ReconnectRoom()
end
function logic_chat_voice:ReenterVoiceRoom(room)
  self.logic_chat_voice_voice_room_ins:ReenterVoiceRoom(room)
end
function logic_chat_voice:CheckIsInAntsVoiceRoom(roomType, roomID)
  if not roomID or roomID == "" then
    log_error("logic_chat_voice:CheckIsInAntsVoiceRoom roomID is nil or empty")
    return false
  end
  return self.logic_chat_voice_voice_room_ins:CheckIsInAntsVoiceRoom(roomType, roomID)
end
function logic_chat_voice:GetAntsVoiceRoomMemberList(identifier)
  return self.logic_chat_voice_voice_room_ins:GetAntsVoiceRoomMemberList(identifier)
end
function logic_chat_voice:RenotifyAntsVoiceRoomMemberInfo(identifier)
  self.logic_chat_voice_voice_room_ins:RenotifyAntsVoiceRoomMemberInfo(identifier)
end
function logic_chat_voice:ForbidLbsMemberVoice(switch)
  self.logic_chat_voice_voice_room_ins:ForbidLbsMemberVoice(switch)
end
function logic_chat_voice:SetAntsVoiceServerInfo(antsVoiceUrl)
  self.logic_chat_voice_voice_room_ins:SetAntsVoiceServerInfo(antsVoiceUrl)
end
function logic_chat_voice:SetBattleAntsVoiceRoomParam(voiceTeamID, gameID, antsVoiceURL)
  local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
  logic_chat_voice_voice_room_param:SetBattleAntsVoiceRoomParam(voiceTeamID, gameID, antsVoiceURL)
end
function logic_chat_voice:GetBattleAntsVoiceRoomParam()
  local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
  return logic_chat_voice_voice_room_param:GetBattleAntsVoiceRoomParam()
end
function logic_chat_voice:SetUGCAntsVoiceUrl(antsVoiceURL)
  local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
  logic_chat_voice_voice_room_param:SetUGCAntsVoiceUrl(antsVoiceURL)
end
function logic_chat_voice:SetUGCRoomID(TeamID, BattleID)
  local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
  logic_chat_voice_voice_room_param:SetUGCRoomID(TeamID, BattleID)
end
function logic_chat_voice:GetUGCAntsVoiceRoomParam()
  local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
  return logic_chat_voice_voice_room_param:GetUGCAntsVoiceRoomParam()
end
function logic_chat_voice:SetGlobalAntsVoiceRoomParam(gameID, antsVoiceURL)
  local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
  logic_chat_voice_voice_room_param:SetGlobalAntsVoiceRoomParam(gameID, antsVoiceURL)
end
function logic_chat_voice:GetGlobalAntsVoiceRoomParam()
  local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
  return logic_chat_voice_voice_room_param:GetGlobalAntsVoiceRoomParam()
end
function logic_chat_voice:RefreshAntsVoiceSpeaker(switch, openAll)
  self.logic_chat_voice_hardware_ins:RefreshAntsVoiceSpeaker(switch, openAll)
end
function logic_chat_voice:RefreshAntsVoiceMicrophone(switch, openAll)
  self.logic_chat_voice_hardware_ins:RefreshAntsVoiceMicrophone(switch, openAll)
end
function logic_chat_voice:GetSelfRoomSpeakerState(identifier)
  return self.logic_chat_voice_hardware_ins:GetSelfRoomSpeakerState(identifier)
end
function logic_chat_voice:GetSelfRoomMicrophoneState(identifier)
  return self.logic_chat_voice_hardware_ins:GetSelfRoomMicrophoneState(identifier)
end
function logic_chat_voice:GetSelfRoomState(identifier)
  return self.logic_chat_voice_hardware_ins:GetSelfRoomState(identifier)
end
function logic_chat_voice:ChangeRoomSpeakerState(switch, identifier)
  self.logic_chat_voice_hardware_ins:ChangeRoomSpeakerState(switch, identifier)
end
function logic_chat_voice:ChangeRoomMicrophoneState(switch, identifier)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictChat() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  self.logic_chat_voice_hardware_ins:ChangeRoomMicrophoneState(switch, identifier)
end
function logic_chat_voice:GetSpeakerState()
  return self.logic_chat_voice_hardware_ins:GetSpeakerState()
end
function logic_chat_voice:GetMicState()
  return self.logic_chat_voice_hardware_ins:GetMicState()
end
function logic_chat_voice:OnRequestPermissionsResult(code, permission, result)
  self.logic_chat_voice_hardware_ins:OnRequestPermissionsResult(code, permission, result)
end
function logic_chat_voice:RecoverAntsVoiceRealtime()
  self.logic_chat_voice_hardware_ins:RecoverAntsVoiceRealtime()
end
function logic_chat_voice:RSTSSpeechToText(LangID, SceneID)
  if not self.logic_chat_voice_rsts_speechtotext_ins then
    log_error("logic_chat_voice:RSTSSpeechToText - rsts_speechtotext_ins not initialized")
    return
  end
  self.logic_chat_voice_rsts_speechtotext_ins:RSTSSpeechToText(LangID, SceneID)
end
function logic_chat_voice:RSTSStopRecording()
  self.logic_chat_voice_rsts_speechtotext_ins:RSTSStopRecording()
end
function logic_chat_voice:SetGMServerUrl()
  self.logic_chat_voice_voice_room_ins:SetGMServerUrl()
end
function logic_chat_voice:ShowAntsVoiceUI()
  if self.logic_chat_voice_voice_room_ins then
    self.logic_chat_voice_voice_room_ins:ShowAntsVoiceUI()
  end
end
function logic_chat_voice:HideAntsVoiceUI()
  if self.logic_chat_voice_voice_room_ins then
    self.logic_chat_voice_voice_room_ins:HideAntsVoiceUI()
  end
end
function logic_chat_voice:SetReportScene(NewVal)
  self.logic_chat_voice_report_ins:SetReportScene(NewVal)
end
function logic_chat_voice:GetLogicChatVoiceVoiceMsgIns()
  return self.logic_chat_voice_voice_msg_ins
end
function logic_chat_voice:EnableVoiceChanger()
  local bMagicVoiceAvailable = Client.IsDevelopment() or LobbySystem.roleData and LobbySystem.roleData.region_info and LobbySystem.roleData.region_info.magic_voice_switch == 1
  print(bWriteLog and "logic_chat_voice:JoinAntsVoiceRoom " .. tostring(bMagicVoiceAvailable))
  if bMagicVoiceAvailable then
    self:AddSettingOptionEvent("bVoiceChanger", logic_chat_voice.UpdateVoiceChanger)
    self:AddSettingOptionEvent("VoiceChangerType", logic_chat_voice.UpdateVoiceChanger)
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:EnableRecvMagicVoice(true)
    logic_chat_voice.UpdateVoiceChanger()
  end
end
function logic_chat_voice:DisableVoiceChanger()
  local bMagicVoiceAvailable = Client.IsDevelopment() or LobbySystem.roleData and LobbySystem.roleData.region_info and LobbySystem.roleData.region_info.magic_voice_switch == 1
  print(bWriteLog and "logic_chat_voice:QuitAntsVoiceRoom " .. tostring(bMagicVoiceAvailable))
  if bMagicVoiceAvailable then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:EnableRecvMagicVoice(false)
    logic_antsvoice_interface:EnableMagicVoice("", false)
    self:RemoveSettingOptionEvent("bVoiceChanger")
    self:RemoveSettingOptionEvent("VoiceChangerType")
  end
end
function logic_chat_voice.UpdateVoiceChanger()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local bVoiceChanger = SettingModule:GetOptionValue("bVoiceChanger")
  local VoiceChangerType = SettingModule:GetOptionValue("VoiceChangerType")
  print(bWriteLog and "logic_chat_voice.UpdateVoiceChanger %s %s", tostring(bVoiceChanger), tostring(VoiceChangerType))
  if 2 < VoiceChangerType then
    VoiceChangerType = 1
  end
  if VoiceChangerMap[VoiceChangerType] then
    logic_antsvoice_interface:EnableMagicVoice(VoiceChangerMap[VoiceChangerType], bVoiceChanger)
  end
end
function logic_chat_voice:OnInitialize()
  local logic_chat_voice_room_operation_manager = require("client.slua.logic.chat_voice.logic_chat_voice_room_operation_manager")
  logic_chat_voice_room_operation_manager:Initialize()
  local logic_antsvoice_init = require("client.slua.logic.chat_voice.logic_antsvoice_init")
  self.logic_antsvoice_init_ins = logic_antsvoice_init()
  self.logic_antsvoice_init_ins:OnInitialize()
  local logic_chat_voice_hardware = require("client.slua.logic.chat_voice.logic_chat_voice_hardware")
  self.logic_chat_voice_hardware_ins = logic_chat_voice_hardware()
  self.logic_chat_voice_hardware_ins:OnInitialize()
  local logic_chat_voice_voice_room = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room")
  self.logic_chat_voice_voice_room_ins = logic_chat_voice_voice_room()
  self.logic_chat_voice_voice_room_ins:OnInitialize()
  local logic_chat_voice_voice_msg = require("client.slua.logic.chat_voice.logic_chat_voice_voice_msg")
  self.logic_chat_voice_voice_msg_ins = logic_chat_voice_voice_msg()
  self.logic_chat_voice_voice_msg_ins:OnInitialize()
  local logic_chat_voice_report = require("client.slua.logic.chat_voice.logic_chat_voice_report")
  self.logic_chat_voice_report_ins = logic_chat_voice_report()
  self.logic_chat_voice_report_ins:OnInitialize()
  local logic_chat_voice_rsts_speechtotext = require("client.slua.logic.chat_voice.logic_chat_voice_rsts_speechtotext")
  self.logic_chat_voice_rsts_speechtotext_ins = logic_chat_voice_rsts_speechtotext()
  self.logic_chat_voice_rsts_speechtotext_ins:OnInitialize()
end
function logic_chat_voice:RegistEvents()
  self.logic_antsvoice_init_ins:RegistEvents()
  self.logic_chat_voice_hardware_ins:RegistEvents()
  self.logic_chat_voice_voice_room_ins:RegistEvents()
  self.logic_chat_voice_voice_msg_ins:RegistEvents()
  self.logic_chat_voice_report_ins:RegistEvents()
  self.logic_chat_voice_rsts_speechtotext_ins:RegistEvents()
end
function logic_chat_voice:OnLogin(bReLogin)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  logic_chat_voice_data_manager:OnLogin(bReLogin)
end
function logic_chat_voice:OnLogOut()
  self.logic_chat_voice_voice_room_ins:OnLogOut()
  self.logic_chat_voice_voice_msg_ins:OnLogOut()
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  logic_chat_voice_data_manager:OnLogOut()
end
function logic_chat_voice:OnPostSwitchGameStatus(preState, nextState)
  self.logic_chat_voice_voice_room_ins:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    log(bWriteLog and "logic_chat_voice:OnPostSwitchGameStatus RegistEvents")
    self.logic_chat_voice_rsts_speechtotext_ins:RegistEvents()
  end
end
function logic_chat_voice:UnRegist()
  log(bWriteLog and "logic_chat_voice:UnRegist")
  logic_chat_voice.__super.UnRegist(self)
  self.logic_antsvoice_init_ins:Dispose()
  self.logic_chat_voice_hardware_ins:Dispose()
  self.logic_chat_voice_voice_room_ins:Dispose()
  self.logic_chat_voice_voice_msg_ins:Dispose()
  self.logic_chat_voice_report_ins:Dispose()
  self.logic_chat_voice_rsts_speechtotext_ins:Dispose()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_chat_voice = class(CModuleBase, nil, logic_chat_voice)
return Clogic_chat_voice