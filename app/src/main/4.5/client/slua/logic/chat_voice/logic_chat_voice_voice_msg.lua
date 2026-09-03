local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
local TimeUtil = require("client.common.time_util")
local HDmpveVoiceCompleteCode = logic_chat_voice_const.HDmpveVoiceCompleteCode
local Enum_AntsVoiceOnlineStatus = logic_chat_voice_const.Enum_AntsVoiceOnlineStatus
local Enum_AntsVoiceOperationStatus = logic_chat_voice_const.Enum_AntsVoiceOperationStatus
local Const_MinRecordTime = logic_chat_voice_const.Const_MinRecordTime
local Const_MaxRecordTime = logic_chat_voice_const.Const_MaxRecordTime
local Const_MaxResendTimes = logic_chat_voice_const.Const_MaxResendTimes
local Const_ProcedureResendTime = logic_chat_voice_const.Const_ProcedureResendTime
local Enum_OperationErrorCode = logic_chat_voice_const.Enum_OperationErrorCode
local HDmpveVoiceErrno = logic_chat_voice_const.HDmpveVoiceErrno
local logic_chat_voice_voice_msg = {
  bIsAntsVoiceMsgInit = false,
  arrVoiceOperationStatus = {
    Recording = Enum_AntsVoiceOperationStatus.Available,
    Uploading = Enum_AntsVoiceOperationStatus.Available,
    Downloading = Enum_AntsVoiceOperationStatus.Available
  },
  lstProcedureTimers = {
    PlayResendStop = nil,
    AuthResendStop = nil,
    TextResendStop = nil,
    DownloadResendStop = nil,
    RecordResendStop = nil,
    StopListenVoice = nil
  },
  iRecordStartTime = -1,
  lstDownloadFile = {},
  iAntsVoiceResendCounter = 0
}
function logic_chat_voice_voice_msg:OnInitialize()
  log(bWriteLog and "logic_chat_voice_voice_msg:OnInitialize")
  self:InitVars()
  self:InitVoiceCache()
end
function logic_chat_voice_voice_msg:RegistEvents()
  self.AntsVoiceInterface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local interface = self.AntsVoiceInterface:GetGVoiceInterface()
  self:AddControlEvent(interface, "OnPlayRecordedFileNotify", self.OnPlayRecordedFileNotify, self)
  self:AddControlEvent(interface, "RecordFail", self.RecordFail, self)
  self:AddControlEvent(interface, "RecordSuccess", self.RecordSuccess, self)
  self:AddControlEvent(interface, "UploadSuccess", self.UploadSuccess, self)
  self:AddControlEvent(interface, "UploadFail", self.UploadFail, self)
  self:AddControlEvent(interface, "UploadFileNotify", self.UploadFileNotify, self)
  self:AddControlEvent(interface, "DownLoadFileNotify", self.DownLoadFileNotify, self)
  self:AddControlEvent(interface, "ApplyMessageKeyNotify", self.OnApplyMessageKeyNotify, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.OnApplicationDeactivated, self)
end
function logic_chat_voice_voice_msg:OnApplicationDeactivated()
  self:TryCancelRecordVoice(true)
  self:TryStopPlayRecordVoice(true)
end
function logic_chat_voice_voice_msg:OnLogOut()
  log(bWriteLog and "logic_chat_voice_voice_msg:OnLogOut")
end
function logic_chat_voice_voice_msg:OnApplyMessageKeyNotify(code)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_msg:OnApplyMessageKeyNotify, code:%s", code))
  self.arrVoiceOperationStatus.Auth = Enum_AntsVoiceOperationStatus.Available
  if code == HDmpveVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC then
    self.bIsAntsVoiceMsgInit = true
    self:ClearAuthResend()
    if self.arrVoiceOperationStatus.Recording == Enum_AntsVoiceOperationStatus.InQueue then
      self:StartRecordVoice(self.immediateUploadWhenStop)
    elseif self.arrVoiceOperationStatus.Downloading == Enum_AntsVoiceOperationStatus.InQueue then
      self:RequireAntsVoiceDownload()
    else
      self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Available
      self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.Available
    end
  elseif Client.IsDevelopment() and not _G.IsEditor then
    ShowDevNotice("###(dev only) GVoice\232\175\173\233\159\179\230\142\136\230\157\131\229\164\177\232\180\165\239\188\140\229\166\130\230\158\156\232\167\166\229\143\145\228\186\134\239\188\140\232\175\183\230\138\138\230\151\165\229\191\151\228\184\162\231\187\153muidarzhang\227\128\130OnApplyMessageKeyNotify failed, code: " .. tostring(code))
  end
end
function logic_chat_voice_voice_msg:CheckIsAntsVoiceMsgInit()
  return self.bIsAntsVoiceMsgInit
end
function logic_chat_voice_voice_msg:RequireAntsVoiceAuthEntry()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:RequireAntsVoiceAuthEntry")
  self.iAntsVoiceResendCounter = 0
  self:RequireAntsVoiceAuth()
end
function logic_chat_voice_voice_msg:RequireAntsVoiceAuth()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:RequireAntsVoiceAuth")
  if not self:ProcessVoiceProcedure() then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_voice_msg:RequireAntsVoiceAuth, ProcessVoiceProcedure failed.")
    return
  end
  local code = self.AntsVoiceInterface:ApplyMessageKey()
  printf("logic_chat_voice_voice_msg:RequireAntsVoiceAuth code:%s", code)
  if IsEditor and code == 0 then
    self.bIsAntsVoiceMsgInit = true
  end
  if self.lstProcedureTimers.AuthResendStop then
    self:RemoveTimer(self.lstProcedureTimers.AuthResendStop)
    self.lstProcedureTimers.AuthResendStop = nil
  end
  self.arrVoiceOperationStatus.Auth = Enum_AntsVoiceOperationStatus.InProgress
  self.lstProcedureTimers.AuthResendStop = self:AddTimerOnce(Const_ProcedureResendTime, function()
    self:RequireAntsVoiceAuth()
  end)
end
function logic_chat_voice_voice_msg:ClearAuthResend()
  self.iAntsVoiceResendCounter = 0
  if self.lstProcedureTimers.AuthResendStop then
    self:RemoveTimer(self.lstProcedureTimers.AuthResendStop)
    self.lstProcedureTimers.AuthResendStop = nil
  end
end
function logic_chat_voice_voice_msg:TryStartRecordVoice(immediateUploadWhenStop)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryStartRecordVoice")
  self.  if not logic_chat_voice_utility.CheckChatPrivacyAcceptStatus() then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_voice_msg:TryStartRecordVoice, not self:CheckChatPrivacyAcceptStatus().")
    return
  end
  if self.arrVoiceOperationStatus.Recording == Enum_AntsVoiceOperationStatus.InProgress or self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.InProgress then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryStartRecordVoice, voice operation is in progress.")
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Delay
  elseif not self.bIsAntsVoiceMsgInit then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryStartRecordVoice, not self.bIsAntsVoiceMsgInit. ")
    self:RequireAntsVoiceAuthEntry()
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.InQueue
  else
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryStartRecordVoice, else. ")
    self:StartRecordVoice(immediateUploadWhenStop)
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.InProgress
  end
end
function logic_chat_voice_voice_msg:StartRecordVoice(immediateUploadWhenStop)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:StartRecordVoice")
  if not self:CheckIsAntsVoiceMsgInit() then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_voice_msg:StartRecordVoice, not self.bIsAntsVoiceMsgInit. ")
    ShowNotice(106014)
    return
  end
  self:StopPlayRecordFile()
  self:StopBGM()
  self.iAntsVoiceResendCounter = 0
  self:RetrieveAntsVoiceOffline()
  self.iRecordStartTime = TimeUtil.GetMiliseconds()
  if immediateUploadWhenStop == false and LobbySystem.CheckOpen(BP_ENUM_VOICE_UPLOAD_CHECK_SWITCH) then
    self.AntsVoiceInterface:EnableCivilFile(true)
  end
  local RealRecordVoice = function()
    self.AntsVoiceInterface:StartRecord()
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_ON_START_RECORD)
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.InProgress
    if self.lstProcedureTimers.RecordResendStop then
      self:RemoveTimer(self.lstProcedureTimers.RecordResendStop)
      self.lstProcedureTimers.RecordResendStop = nil
    end
    self.lstProcedureTimers.RecordResendStop = self:AddTimerOnce(Const_MaxRecordTime, function()
      self:TryStopRecordVoice(immediateUploadWhenStop)
    end)
  end
  if immediateUploadWhenStop == false then
    self:ClearStartRecordDelayTimer()
    self.startRecordDelayTimer = self:AddTimerOnce(0.4, function()
      self.iRecordStartTime = TimeUtil.GetMiliseconds()
      RealRecordVoice()
    end)
  else
    RealRecordVoice()
  end
end
function logic_chat_voice_voice_msg:TryStopRecordVoice(immediateUploadWhenStop)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryStopRecordVoice")
  if not self:CheckIsAntsVoiceMsgInit() then
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Available
    return
  end
  if self.bIsAntsVoiceMsgInit then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryStopRecordVoice, self.bIsAntsVoiceMsgInit. ")
    self:StopRecordVoice(false, immediateUploadWhenStop)
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Available
  else
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryStopRecordVoice, not self.bIsAntsVoiceMsgInit. ")
    self:StopRecordVoice(true)
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Available
  end
end
function logic_chat_voice_voice_msg:TryCancelRecordVoice(bFromAppDeactivated)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryCancelRecordVoice")
  if not self:CheckIsAntsVoiceMsgInit() then
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Available
    return
  end
  if not self.bIsAntsVoiceMsgInit then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_voice_msg:TryCancelRecordVoice, not self.bIsAntsVoiceMsgInit. ")
    return
  end
  self:StopRecordVoice(true, nil, bFromAppDeactivated)
  self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Available
end
function logic_chat_voice_voice_msg:StopRecordVoice(cancel, immediateUploadWhenStop, bFromAppDeactivated)
  printf("logic_chat_voice_voice_msg:StopRecordVoice  cancel:%s, immediateUploadWhenStop:%s, bFromAppDeactivated:%s", cancel, immediateUploadWhenStop, bFromAppDeactivated)
  if not self.bIsAntsVoiceMsgInit then
    printf("logic_chat_voice_voice_msg:StopRecordVoice  not self.bIsAntsVoiceMsgInit.")
    return
  end
  self:ClearStartRecordDelayTimer()
  if self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.Available then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
  end
  if bFromAppDeactivated then
    local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
    local myChannel = logic_chat_channel_chat_room.GetMyChannel()
    printf("logic_chat_voice_voice_msg:StopRecordVoice, myChannel:%s", tostring(myChannel))
    if not myChannel then
      self:RestoreBGM()
    end
  else
    self:RestoreBGM()
  end
  if self.lstProcedureTimers.RecordResendStop then
    self:RemoveTimer(self.lstProcedureTimers.RecordResendStop)
  end
  self.lstProcedureTimers.RecordResendStop = nil
  if self.arrVoiceOperationStatus.Recording == Enum_AntsVoiceOperationStatus.InProgress then
    log(bWriteLog and "logic_chat_voice_voice_msg:StopRecordVoice, self.arrVoiceOperationStatus.Recording == Enum_AntsVoiceOperationStatus.InProgress.")
    self.AntsVoiceInterface:StopRecord()
    self.arrVoiceOperationStatus.Recording = Enum_AntsVoiceOperationStatus.Available
    if cancel then
      log(bWriteLog and string.format("logic_chat_voice_voice_msg:StopRecordVoice, cancel:%s", cancel))
      self:RecoverAntsVoiceRealtime()
      return
    end
    local iRecordStopTime = TimeUtil.GetMiliseconds()
    local iRecordTime = iRecordStopTime - self.iRecordStartTime
    log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_msg:StopRecordVoice, iRecordTime:%s", iRecordTime))
    if iRecordTime < Const_MinRecordTime then
      log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_voice_msg:StopRecordVoice, iRecordTime < Const_MinRecordTime.")
      ShowNotice(106015)
      EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_SHORT_RECORD_TIME)
      return
    end
    if self.bRecordSuccess then
      log(bWriteLog and "logic_chat_voice_voice_msg:StopRecordVoice, self.bRecordSuccess. ")
      if immediateUploadWhenStop ~= false then
        self:RequireAntsVoiceUploadEntry()
      end
      self:RecoverAntsVoiceRealtime()
      local uploadTime = math.floor(self.AntsVoiceInterface:GetVoiceLength() + 0.5)
      if uploadTime and uploadTime <= 0 then
        log(bWriteLog and "logic_chat_voice_voice_msg:StopRecordVoice uploadTime is out of range")
        uploadTime = 1
      end
      EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_RECORD_SUCCESS, uploadTime)
    end
  end
end
function logic_chat_voice_voice_msg:RecordSuccess()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:RecordSuccess")
  self.bIsOpenMicHitPermissionErr = false
  self.bRecordSuccess = true
end
function logic_chat_voice_voice_msg:RecordFail(code)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_msg:RecordFail, code:%s", code))
  if code == HDmpveVoiceErrno.HDMPVE_VOICE_PERMISSION_MIC_ERR or code == HDmpveVoiceErrno.HDMPVE_VOICE_INTERNAL_TVE_ERR then
    if self.bIsOpenMicHitPermissionErr == true then
      ShowNotice(106048)
    end
    self.bIsOpenMicHitPermissionErr = true
  elseif code == Enum_OperationErrorCode.HttpBusy or code == Enum_OperationErrorCode.AntsVoiceServiceError then
    ShowNotice(106049)
  else
    ShowNotice(LocUtil.GetLocalizeResStr(106050) .. tostring(code))
  end
  self.bRecordSuccess = false
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_RECORD_FAIL)
end
function logic_chat_voice_voice_msg:TryListenVoice(voiceLength)
  log(bWriteLog and "logic_chat_voice_voice_msg:TryListenVoice voiceLength:" .. tostring(voiceLength))
  if not self:CheckIsAntsVoiceMsgInit() then
    log(bWriteLog and "logic_chat_voice_voice_msg:TryListenVoice, not self.bIsAntsVoiceMsgInit.")
    return
  end
  self:RetrieveAntsVoiceOffline()
  if self.lstProcedureTimers.StopListenVoice then
    self:RemoveTimer(self.lstProcedureTimers.StopListenVoice)
    self.lstProcedureTimers.StopListenVoice = nil
  end
  self.lstProcedureTimers.StopListenVoice = self:AddTimerOnce(voiceLength, function()
    self:StopListenVoice()
  end)
  local filepath = self.AntsVoiceInterface:GetLocalRecordFilePath(logic_chat_voice_const.AntsVoiceLocalRecordFileName.LocalRecord)
  self.AntsVoiceInterface:PlayRecordedFile(filepath)
  self:StopBGM()
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_START_LISTEN_RECORD_FILE)
end
function logic_chat_voice_voice_msg:StopListenVoice()
  log(bWriteLog and "logic_chat_voice_voice_msg:StopListenVoice")
  if not self:CheckIsAntsVoiceMsgInit() then
    log(bWriteLog and "logic_chat_voice_voice_msg:StopListenVoice, not self.bIsAntsVoiceMsgInit.")
    return
  end
  if self.lstProcedureTimers.StopListenVoice then
    self:RemoveTimer(self.lstProcedureTimers.StopListenVoice)
    self.lstProcedureTimers.StopListenVoice = nil
  end
  self.AntsVoiceInterface:StopPlayRecordFile()
  self:RestoreBGM()
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_STOP_LISTEN_RECORD_FILE)
  if self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.Available then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
  end
  self:RecoverAntsVoiceRealtime()
end
function logic_chat_voice_voice_msg:UploadRecordedVoice(permanent, exter_info)
  self:RequireAntsVoiceUploadEntry(permanent, exter_info)
end
function logic_chat_voice_voice_msg:ClearStartRecordDelayTimer()
  if self.startRecordDelayTimer then
    self:RemoveTimer(self.startRecordDelayTimer)
    self.startRecordDelayTimer = nil
  end
end
function logic_chat_voice_voice_msg:RequireAntsVoiceUploadEntry(permanent, exter_info)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:RequireAntsVoiceUploadEntry")
  if self.bIsAntsVoiceMsgInit then
    if self.lstProcedureTimers.RecordResendStop then
      self:RemoveTimer(self.lstProcedureTimers.RecordResendStop)
      self.lstProcedureTimers.RecordResendStop = nil
    end
    self.iAntsVoiceResendCounter = 0
    self:RequireAntsVoiceUpload(permanent, exter_info)
  else
    ShowNotice(106014)
  end
end
function logic_chat_voice_voice_msg:RequireAntsVoiceUpload(permanent, exter_info)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:RequireAntsVoiceUpload")
  if not self:ProcessVoiceProcedure() then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_voice_msg:RequireAntsVoiceUpload, ProcessVoiceProcedure failed.")
    return
  end
  self:RetrieveAntsVoiceOffline()
  if self.AntsVoiceInterface:GetVoiceLength() < 0.1 then
    self.iAntsVoiceResendCounter = 0
    self.arrVoiceOperationStatus.Uploading = Enum_AntsVoiceOperationStatus.Available
    if self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.Available then
      log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:RequireAntsVoiceUpload, logic_chat_voice:RefreshAntsVoiceMicrophone. ")
      self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
    end
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_UPLOAD_FILE_FAIL)
  else
    self.arrVoiceOperationStatus.Uploading = Enum_AntsVoiceOperationStatus.InProgress
    self.AntsVoiceInterface:UploadRecordFile(permanent, exter_info)
    self.iUploadTime = math.floor(self.AntsVoiceInterface:GetVoiceLength() + 0.5)
    if self.iUploadTime and 0 >= self.iUploadTime then
      log(bWriteLog and "logic_chat_voice_voice_msg:RequireAntsVoiceUpload iUploadTime is out of range")
      self.iUploadTime = 1
    end
  end
end
function logic_chat_voice_voice_msg:UploadSuccess()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:UploadSuccess")
end
function logic_chat_voice_voice_msg:UploadFail(code)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_msg:UploadFail, code:%s", code))
  if code == Enum_OperationErrorCode.HttpBusy or code == Enum_OperationErrorCode.AntsVoiceServiceError then
    ShowNotice(106049)
  elseif code == Enum_OperationErrorCode.UploadError then
    ShowNotice(106048)
  elseif code == Enum_OperationErrorCode.ChangeModeError then
  else
    ShowNotice(LocUtil.GetLocalizeResStr(106050) .. tostring(code))
  end
  self:ClearUploadResend()
  self.AntsVoiceInterface:EnableCivilFile(false)
end
function logic_chat_voice_voice_msg:UploadFileNotify(code, filePath, fileID)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_msg:UploadFileNotify, code:%s", code))
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_UPLOAD_FILE_NOTIFY, code, filePath, fileID)
  if code ~= HDmpveVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_voice_msg:UploadFileNotify, code ~= HDmpveVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE")
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_UPLOAD_FILE_FAIL)
    self:ClearUploadResend()
  else
    local orginal_fileid, exter_info = self.AntsVoiceInterface:FetchOfflineMessageExtraInfo(fileID)
    log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_msg:UploadFileNotify, code, filePath, fileID, exter_info:%s, %s, %s, %s", code, filePath, orginal_fileid, tostring(exter_info)))
    if exter_info == logic_chat_voice_const.UploadFileSence.SST then
      log(bWriteLog and "logic_chat_voice_voice_msg:UploadFileNotify, return by exter_info == logic_chat_voice_const.UploadFileSence.SST")
      return
    end
    self:UploadRecordFileComplete()
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_UPLOAD_FILE_SUCCESS, self.iUploadTime, orginal_fileid)
    self:SendVoiceMsg(orginal_fileid, exter_info)
  end
  self.AntsVoiceInterface:EnableCivilFile(false)
end
function logic_chat_voice_voice_msg:UploadRecordFileComplete()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:UploadRecordFileComplete")
  self.iAntsVoiceResendCounter = 0
  self.arrVoiceOperationStatus.Uploading = Enum_AntsVoiceOperationStatus.Available
end
function logic_chat_voice_voice_msg:ClearUploadResend()
  self.iAntsVoiceResendCounter = 0
  self.arrVoiceOperationStatus.Uploading = Enum_AntsVoiceOperationStatus.Available
  if self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.Available then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
  end
end
function logic_chat_voice_voice_msg:AddDownloadFile(file_id, msg_length, extra_para)
  printf("logic_chat_voice_voice_msg:AddDownloadFile, file_id:%s, msg_length:%s, extra_para:%s", file_id, msg_length, extra_para)
  self.lstDownloadFile = self.lstDownloadFile or {}
  local downloadData = {
    fileId = file_id,
    msgLength = msg_length,
    extraPara = extra_para
  }
  table.insert(self.lstDownloadFile, downloadData)
  self:TryDownloadRecordVoice()
end
function logic_chat_voice_voice_msg:TryDownloadRecordVoice()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:TryDownloadRecordVoice")
  if self.bIsAntsVoiceMsgInit then
    self:RequireAntsVoiceDownload()
  else
    self:RequireAntsVoiceAuthEntry()
    self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.InQueue
  end
end
function logic_chat_voice_voice_msg:RequireAntsVoiceDownload()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:RequireAntsVoiceDownload")
  if not self.bIsAntsVoiceMsgInit then
    printf("logic_chat_voice_voice_msg:RequireAntsVoiceDownload, not self.bIsAntsVoiceMsgInit. ")
    ShowNotice(106014)
    return
  end
  if not self.lstDownloadFile or #self.lstDownloadFile <= 0 then
    printf("logic_chat_voice_voice_msg:RequireAntsVoiceDownload, empty lstDownloadFile")
    return
  end
  local file = self.lstDownloadFile[1]
  local fileId = file.fileId
  if fileId == nil or fileId == "" then
    printf("logic_chat_voice_voice_msg:RequireAntsVoiceDownload, fileId is empty")
    return
  end
  self:RetrieveAntsVoiceOffline()
  local isPermanent = false
  if file.extraPara and file.extraPara.permanent then
    isPermanent = true
  end
  local result = self.AntsVoiceInterface:DownloadRecordFileV2(fileId, isPermanent)
  local VoiceMsgStat = require("client.slua.logic.chat_voice.logic_voice_msg_stat")
  VoiceMsgStat:StartDownloadVoiceMsg(fileId)
  printf("logic_chat_voice_voice_msg:RequireAntsVoiceDownload, fileId:%s, result:%s", fileId, result)
  if result ~= 0 then
    self:DownloadFileFail(result, file.extraPara)
  end
  self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.InProgress
  self.lstProcedureTimers.DownloadResendStop = self:AddTimerOnce(5, function()
    if self.lstProcedureTimers and self.lstProcedureTimers.DownloadResendStop then
      self:RemoveTimer(self.lstProcedureTimers.DownloadResendStop)
      self.lstProcedureTimers.DownloadResendStop = nil
    end
    if not file.extraPara or not file.extraPara.bSkipTips then
      ShowNotice(106056)
    else
      printf(bWriteLog and "logic_chat_voice_voice_msg:DownloadResendStop SkipTips")
    end
    self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.Available
  end)
end
function logic_chat_voice_voice_msg:DownLoadFileNotify(code, filePath, fileID)
  printf("logic_chat_voice_voice_msg:DownLoadFileNotify, code:%s, filePath:%s, fileID:%s", code, filePath, fileID)
  if not self.lstDownloadFile or #self.lstDownloadFile <= 0 then
    assert(false, "logic_chat_voice_voice_msg:DownLoadFileNotify, empty lstDownloadFile")
    return
  end
  if self.lstProcedureTimers.DownloadResendStop then
    self:RemoveTimer(self.lstProcedureTimers.DownloadResendStop)
    self.lstProcedureTimers.DownloadResendStop = nil
  end
  if code == HDmpveVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_ERROR then
    log(bWriteLog and "logic_chat_voice_voice_msg:DownLoadFileNotify GV_ON_DOWNLOAD_RECORD_ERROR")
    local file = table.remove(self.lstDownloadFile, 1)
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_FAILED, file.extraPara)
    if not (file and file.extraPara) or not file.extraPara.bSkipTips then
      ShowNotice(48370)
    end
  elseif code == HDmpveVoiceCompleteCode.GV_ON_DOWNLOAD_FILEID_NOT_EXIST then
    log(bWriteLog and "logic_chat_voice_voice_msg:DownLoadFileNotify GV_ON_DOWNLOAD_FILEID_NOT_EXIST")
    local file = table.remove(self.lstDownloadFile, 1)
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_NOT_EXIST, file.extraPara)
  end
  if code ~= HDmpveVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
    log(bWriteLog and "logic_chat_voice_voice_msg:DownLoadFileNotify not GV_ON_DOWNLOAD_RECORD_DONE")
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_END, fileID, 1, 0)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_STOP_PLAY_RECORD_FILE)
    return
  end
  local VoiceMsgStat = require("client.slua.logic.chat_voice.logic_voice_msg_stat")
  local VoiceFileLen = self.AntsVoiceInterface:GetVoiceLength()
  VoiceMsgStat:OnDownloadVoiceMsg(fileID, 2, code, VoiceFileLen)
  self:StopPlayRecordFile()
  self:PlayDownloadFile(fileID)
end
function logic_chat_voice_voice_msg:DownloadFileFail(code, extraPara)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_msg:DownloadFileFail, code:%s", code))
  if not extraPara or not extraPara.bSkipTips then
    if code == Enum_OperationErrorCode.HttpBusy or code == Enum_OperationErrorCode.AntsVoiceServiceError then
      ShowNotice(106049)
    elseif code == Enum_OperationErrorCode.DownloadError then
      ShowNotice(106048)
    elseif code == Enum_OperationErrorCode.ChangeModeError then
    else
      ShowNotice(LocUtil.GetLocalizeResStr(106050) .. tostring(code))
    end
  end
  local downloadFile = self.lstDownloadFile[1]
  if downloadFile then
    local VoiceMsgStat = require("client.slua.logic.chat_voice.logic_voice_msg_stat")
    VoiceMsgStat:OnDownloadVoiceMsg(downloadFile.fileId, 1, code)
  end
  table.remove(self.lstDownloadFile, 1)
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_STOP_PLAY_RECORD_FILE)
end
function logic_chat_voice_voice_msg:SendVoiceMsg(fileID, exter_info)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_msg:SendVoiceMsg")
  self:CheckDelayProcess()
  if exter_info and exter_info == logic_chat_voice_const.UploadFileSence.SocialCard then
    return
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.SendVoiceMsg(self.sToTextResult, self.iUploadTime, fileID)
end
function logic_chat_voice_voice_msg:PlayVoiceFileInternal(fileID, msgLength, payload)
  printf("logic_chat_voice_voice_msg:PlayVoiceFileInternal, fileID:%s, msgLength:%s, payload:%s", fileID, msgLength, payload)
  self:RetrieveAntsVoiceOffline()
  if self.lstProcedureTimers.PlayResendStop then
    self:RemoveTimer(self.lstProcedureTimers.PlayResendStop)
    self.lstProcedureTimers.PlayResendStop = nil
  end
  if payload and payload.bOnlyFightingState == true and GameStatus.GetGameStatus() ~= GameStatus.Fighting then
    log(bWriteLog and "logic_chat_voice_voice_msg:PlayVoiceFileInternal, Not In FightingState")
    return
  end
  if msgLength and 0 < msgLength then
    self.lstProcedureTimers.PlayResendStop = self:AddTimerOnce(msgLength, function()
      self:StopPlayRecordFile()
      if self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.Available then
        self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
      end
      self:RecoverAntsVoiceRealtime()
      self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.Available
    end)
  end
  local code = self.AntsVoiceInterface:PlayRecordFileV2(fileID)
  if code == 0 then
    self:addToCache(fileID)
  end
  self:StopBGM()
  self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.InProgress
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_START_PLAY_RECORD_FILE, payload)
end
function logic_chat_voice_voice_msg:OnPlayRecordedFileNotify()
  self:StopPlayRecordFile(false)
  if self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.Available then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
  end
  self:RecoverAntsVoiceRealtime()
  self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.Available
end
function logic_chat_voice_voice_msg:PlayDownloadFile(fileID)
  printf("logic_chat_voice_voice_msg:PlayDownloadFile, fileID:%s", fileID)
  if not self.bIsAntsVoiceMsgInit then
    assert(false, "logic_chat_voice_voice_msg:PlayDownloadFile, not self.bIsAntsVoiceMsgInit.")
    return
  end
  if not self.lstDownloadFile or #self.lstDownloadFile <= 0 then
    assert(false, "logic_chat_voice_voice_msg:PlayDownloadFile, empty lstDownloadFile")
    return
  end
  local file = table.remove(self.lstDownloadFile, 1)
  self:PlayVoiceFileInternal(fileID, file.msgLength, file.extraPara)
end
function logic_chat_voice_voice_msg:StopPlayRecordFile(bFromAppDeactivated)
  printf("logic_chat_voice_voice_msg:StopPlayRecordFile  bFromAppDeactivated: %s", bFromAppDeactivated)
  if not self:CheckIsAntsVoiceMsgInit() then
    printf("logic_chat_voice_voice_msg:StopPlayRecordFile  not self:CheckIsAntsVoiceMsgInit()")
    return
  end
  if self.lstProcedureTimers.PlayResendStop then
    self:RemoveTimer(self.lstProcedureTimers.PlayResendStop)
    self.lstProcedureTimers.PlayResendStop = nil
  end
  self.AntsVoiceInterface:StopPlayRecordFile()
  if bFromAppDeactivated then
    local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
    local myChannel = logic_chat_channel_chat_room.GetMyChannel()
    printf("logic_chat_voice_voice_msg:StopRecordVoice, myChannel:%s", tostring(myChannel))
    if not myChannel then
      self:RestoreBGM()
    end
  else
    self:RestoreBGM()
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_STOP_PLAY_RECORD_FILE)
end
function logic_chat_voice_voice_msg:TryStopPlayRecordVoice(bFromAppDeactivated)
  printf("logic_chat_voice_voice_msg:TryStopPlayRecordVoice  bFromAppDeactivated: %s", bFromAppDeactivated)
  if not self:CheckIsAntsVoiceMsgInit() then
    printf("logic_chat_voice_voice_msg:TryStopPlayRecordVoice  not self:CheckIsAntsVoiceMsgInit()")
    return
  end
  self:StopPlayRecordFile(bFromAppDeactivated)
  if self.arrVoiceOperationStatus.Uploading == Enum_AntsVoiceOperationStatus.Available then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
  end
  self:RecoverAntsVoiceRealtime()
  self.arrVoiceOperationStatus.Downloading = Enum_AntsVoiceOperationStatus.Available
end
function logic_chat_voice_voice_msg:RestoreBGM()
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local audio_util = require("client.common.audio_util")
  if userSettings.BGMVolumSwitcher then
    audio_util.SetRTPCValue("VolumeControl_Music", userSettings.BGMVolumValue * 100, 200)
    audio_util.SetRTPCValue("MusicPlayer_Volume", userSettings.BGMVolumValue, 200)
  else
    audio_util.SetRTPCValue("VolumeControl_Music", 0, 200)
    audio_util.SetRTPCValue("MusicPlayer_Volume", 0, 200)
  end
end
function logic_chat_voice_voice_msg:StopBGM()
  local audio_util = require("client.common.audio_util")
  audio_util.SetRTPCValue("VolumeControl_Music", 20, 200)
  audio_util.SetRTPCValue("MusicPlayer_Volume", 0.2, 200)
end
function logic_chat_voice_voice_msg:CheckDelayProcess()
  if self.arrVoiceOperationStatus.Recording == Enum_AntsVoiceOperationStatus.Delay then
    self:TryStartRecordVoice(self.immediateUploadWhenStop)
  end
end
function logic_chat_voice_voice_msg:ProcessVoiceProcedure()
  self.iAntsVoiceResendCounter = self.iAntsVoiceResendCounter + 1
  if self.iAntsVoiceResendCounter > Const_MaxResendTimes then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_voice_msg:ProcessVoiceProcedure, self.iAntsVoiceResendCounter > Const_MaxResendProcedure.")
    ShowNotice(106014)
    return false
  end
  return true
end
function logic_chat_voice_voice_msg:RetrieveAntsVoiceOffline()
  self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.OffLine)
end
function logic_chat_voice_voice_msg:RecoverAntsVoiceRealtime()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:RecoverAntsVoiceRealtime()
end
function logic_chat_voice_voice_msg:CheckIsAntsVoiceMsgInProcess()
  for _, v in pairs(self.arrVoiceOperationStatus) do
    if v == Enum_AntsVoiceOperationStatus.InProgress then
      log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice:RefreshAntsVoiceMicrophone: " .. tostring(v) .. "In Progress.")
      return true
    end
  end
  return false
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local MergePatialTool = require("GameLua.Mod.SocialIsland.GamePlay.MergePatialTool")
MergePatialTool.Mixin(CDelegateContainer, logic_chat_voice_voice_msg, require("client.slua.logic.chat_voice.ChatVoiceMsgCachePatial"))
return class(CDelegateContainer, nil, logic_chat_voice_voice_msg)