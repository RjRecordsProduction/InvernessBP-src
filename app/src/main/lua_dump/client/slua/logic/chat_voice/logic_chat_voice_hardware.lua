local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
local table_pool = require("common.table_pool")
local tablePool = table_pool.Create()
local Enum_AntsVoiceOnlineStatus = logic_chat_voice_const.Enum_AntsVoiceOnlineStatus
local Enum_HDmpveVoiceMicState = logic_chat_voice_const.Enum_HDmpveVoiceMicState
local HDmpveVoiceErrno = logic_chat_voice_const.HDmpveVoiceErrno
local Enum_HDmpveVoiceEvent = logic_chat_voice_const.Enum_HDmpveVoiceEvent
local Enum_OperationErrorCode = logic_chat_voice_const.Enum_OperationErrorCode
local Enum_MemberStateBitDefine = logic_chat_voice_const.Enum_MemberStateBitDefine
local logic_chat_voice_hardware = {}
function logic_chat_voice_hardware:OnInitialize()
  self.sDevicePlatformName = Client.GetDevicePlatformName()
  self.bIsOpenMicHitPermissionErr = nil
  self.iPermissionDenyTimes = 0
  self.AntsVoiceInterface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
end
function logic_chat_voice_hardware:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, self.OnApplicationReactivated, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, self.OnApplicationDeactivated, self)
  local interface = self.AntsVoiceInterface:GetGVoiceInterface()
  self:AddControlEvent(interface, "OpenMicFail", self.OnOpenMicFail, self)
  self:AddControlEvent(interface, "OpenMicSuccess", self.OnOpenMicSuccess, self)
  self:AddControlEvent(interface, "CloseMicFail", self.OnCloseMicFail, self)
  self:AddControlEvent(interface, "CloseMicSuccess", self.OnCloseMicSuccess, self)
  self:AddControlEvent(interface, "OpenSpeakerFail", self.OnOpenSpeakerFail, self)
  self:AddControlEvent(interface, "OpenSpeakerSuccess", self.OnOpenSpeakerSuccess, self)
  self:AddControlEvent(interface, "CloseSpeakerFail", self.OnCloseSpeakerFail, self)
  self:AddControlEvent(interface, "CloseSpeakerSuccess", self.OnCloseSpeakerSuccess, self)
  self:AddControlEvent(interface, "ImSpeakingNotify", self.OnImSpeakingNotify, self)
  self:AddControlEvent(interface, "MemberIsSpeakingNotify", self.OnMemberIsSpeakingNotify, self)
  self:AddControlEvent(interface, "LbsMemberIsSpeakingNotify", self.OnLbsMemberIsSpeakingNotify, self)
  self:AddControlEvent(interface, "TestMicFail", self.OnTestMicFail, self)
  self:AddControlEvent(interface, "TestMicSuccess", self.OnTestMicSuccess, self)
  self:AddControlEvent(interface, "OnVoiceSDKEvent", self.OnAntsVoiceEvent, self)
  self:AddControlEvent(interface, "OnMuteSwitchResult", self.OnMuteSwitchResult, self)
end
function logic_chat_voice_hardware:OnApplicationReactivated()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:OnApplicationReactivated")
  local logic_chat_extra = require("client.slua.logic.lobby_chat.logic_chat_extra")
  logic_chat_extra.RecordVoiceMicTLog()
end
function logic_chat_voice_hardware:OnApplicationDeactivated()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:OnApplicationDeactivated")
  local logic_chat_extra = require("client.slua.logic.lobby_chat.logic_chat_extra")
  logic_chat_extra.RecordVoiceMicTLog(true)
end
function logic_chat_voice_hardware:OnOpenMicFail(error)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnOpenMicFail, error:%s", error))
  if error == HDmpveVoiceErrno.HDMPVE_VOICE_INTERNAL_TVE_ERR or error == HDmpveVoiceErrno.HDMPVE_VOICE_PERMISSION_MIC_ERR then
    if self.bIsOpenMicHitPermissionErr and self.sDevicePlatformName == DevicePlatformNameMacros.IOS then
      ShowNotice(106048)
    end
    self.bIsOpenMicHitPermissionErr = true
  elseif error == Enum_OperationErrorCode.AntsVoiceServiceError then
    ShowNotice(106049)
  else
    ShowNotice(LocUtil.GetLocalizeResStr(106050) .. tostring(error))
  end
  local StringUtil = require("common.string_util")
  local curRole = StringUtil.StrTrim(DataMgr.roleData.uid)
  if logic_chat_voice_utility.CheckIsRoleValid(curRole) then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    local logic_chat_voice_voice_msg_ins = logic_chat_voice:GetLogicChatVoiceVoiceMsgIns()
    if logic_chat_voice_voice_msg_ins:CheckIsAntsVoiceMsgInit() then
      logic_chat_voice_voice_msg_ins:StopRecordVoice(true)
    end
  end
  if self:GetMicState() then
    self:RefreshAntsVoiceMicrophone(false)
  end
end
function logic_chat_voice_hardware:OnOpenMicSuccess()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:OnOpenMicSuccess")
  self.bIsOpenMicHitPermissionErr = false
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_MIC_OPEN_SUC)
end
function logic_chat_voice_hardware:OnCloseMicFail(error)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnCloseMicFail, error:%s", error))
end
function logic_chat_voice_hardware:OnCloseMicSuccess()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:OnCloseMicSuccess")
  local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
  logic_chat_voice_protocol_manager.reportSource = "OnCloseMicSuccess"
  logic_chat_voice_protocol_manager:ReportVoiceRoomState()
end
function logic_chat_voice_hardware:OnOpenSpeakerFail(error)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnOpenSpeakerFail, error:%s", error))
  if self:GetSpeakerState() then
    self:RefreshAntsVoiceSpeaker(false)
  end
end
function logic_chat_voice_hardware:OnOpenSpeakerSuccess()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:OnOpenSpeakerSuccess")
  local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
  logic_chat_voice_protocol_manager.reportSource = "OnOpenSpeakerSuccess"
  logic_chat_voice_protocol_manager:ReportVoiceRoomState()
end
function logic_chat_voice_hardware:OnCloseSpeakerFail(error)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnCloseSpeakerFail, error:%s", error))
end
function logic_chat_voice_hardware:OnCloseSpeakerSuccess()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:OnCloseSpeakerSuccess")
  local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
  logic_chat_voice_protocol_manager.reportSource = "OnCloseSpeakerSuccess"
  logic_chat_voice_protocol_manager:ReportVoiceRoomState()
end
function logic_chat_voice_hardware:IsImSpeakingNotifyEventPost()
  if GameStatus.IsInLobbyOrMainCity() then
    return true
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    return true
  end
  local ECreativeModeGameType = import("ECreativeModeGameType")
  if CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() and CGameState:GetInitializeGameType() == ECreativeModeGameType.CreativeModeGameType_Editor then
    return true
  end
  return false
end
function logic_chat_voice_hardware:OnImSpeakingNotify(status, _, member)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnImSpeakingNotify, status, member:%s, %s", status, member))
  if not self:IsImSpeakingNotifyEventPost() then
    log(bWriteLog and "WARNING: [muidarzhang] logic_chat_voice_hardware:ImSpeakingNotify, Not support mode.")
    return
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local curRoomID = logic_chat_voice_data_manager:GetRoomIDByRoomType(curRoomType)
  local tParam = tablePool:Get()
  tParam.roomType = curRoomType
  tParam.roomID = curRoomID
  tParam.uid = tonumber(DataMgr.roleData.uid)
  tParam.  tParam.state = logic_chat_voice_data_manager:GetSelfStateByRoomID(curRoomID)
  tParam.memberID = member
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_VOICE, tParam)
  tablePool:Recycle(tParam)
end
function logic_chat_voice_hardware:OnMemberIsSpeakingNotify(code, room, member, user_info)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnMemberIsSpeakingNotify, code, room, member:%s, %s, %s, %s", code, room, member, user_info))
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_TEAM_SPEAKING, room, member, code)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local tParam = tablePool:Get()
  tParam.roomType = curRoomType
  tParam.roomID = room
  tParam.uid = logic_chat_voice_data_manager:GetMemberUidByAntsVoiceUid(room, member)
  tParam.status = code
  tParam.state = logic_chat_voice_data_manager:GetMemberStateByRoomID(room, tParam.uid)
  tParam.memberID = member
  tParam.  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_VOICE, tParam)
  tablePool:Recycle(tParam)
end
function logic_chat_voice_hardware:OnLbsMemberIsSpeakingNotify(code, room, member)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnLbsMemberIsSpeakingNotify, code, room, member:%s, %s, %s", code, room, member))
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_LBS_SPEAKING, room, member, code)
end
function logic_chat_voice_hardware:OnMuteSwitchResult(code)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnMuteSwitchResult, code:%s", code))
  if code == 1 and not UIManager.GetUI(UIManager.UI_Config.loading) then
    ShowNotice(6403)
  end
  local deviceIsNotMuted = code
  if code == 0 then
    deviceIsNotMuted = 1
  elseif 1 <= code then
    deviceIsNotMuted = 0
  end
  self.AntsVoiceInterface:TryReportSFXState(deviceIsNotMuted)
end
function logic_chat_voice_hardware:OnTestMicFail(error)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnTestMicFail, error:%s", error))
  self.bIsOpenMicHitPermissionErr = false
  if error == HDmpveVoiceErrno.HDMPVE_VOICE_PERMISSION_MIC_ERR or error == Enum_OperationErrorCode.AndroidTesterPermissionError or HDmpveVoiceErrno.HDMPVE_VOICE_INTERNAL_TVE_ERR or error == Enum_OperationErrorCode.IosTesterPermissionError then
    self.bIsOpenMicHitPermissionErr = true
  end
end
function logic_chat_voice_hardware:OnTestMicSuccess()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:OnTestMicSuccess")
  self.bIsOpenMicHitPermissionErr = false
  if self.requestPrivacyCallback then
    log(bWriteLog and "logic_chat_voice_hardware:TestMicSuccess, self.requestPrivacyCallback. ")
    self.requestPrivacyCallback()
    self.requestPrivacyCallback = nil
  end
end
function logic_chat_voice_hardware:OnAntsVoiceEvent(event)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnAntsVoiceEvent, code: %s", event))
  if event == Enum_HDmpveVoiceEvent.GV_EVENT_MIC_STATE_OPEN_SUCC or event == Enum_HDmpveVoiceEvent.GV_EVENT_MIC_STATE_NO_OPEN or event == Enum_HDmpveVoiceEvent.GV_EVENT_MIC_STATE_OPEN_ERR or event == Enum_HDmpveVoiceEvent.GV_EVENT_MIC_STATE_OCCUPANCY then
    if event == Enum_HDmpveVoiceEvent.GV_EVENT_MIC_STATE_OPEN_SUCC then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_MIC_OPEN_SUC)
    end
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_MICROPHONE)
    local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
    logic_chat_voice_protocol_manager.reportSource = "OnAntsVoiceEvent" .. tostring(event)
    logic_chat_voice_protocol_manager:ReportVoiceRoomState()
  end
end
function logic_chat_voice_hardware:RefreshAntsVoiceSpeaker(switch, openAll)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:RefreshAntsVoiceSpeaker, switch:%s", switch))
  if not logic_chat_voice_utility.CheckIsRoleValid() then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_hardware:RefreshAntsVoiceSpeaker, not logic_chat_voice_utility.CheckIsRoleValid(). ")
    return
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  if logic_chat_voice:CheckIsAntsVoiceMsgInProcess() then
    if self.RefreshSpeakerTimer then
      self:RemoveTimer(self.RefreshSpeakerTimer)
      self.RefreshSpeakerTimer = nil
    end
    self.RefreshSpeakerTimer = self:AddTimerOnce(3, function()
      self:RefreshAntsVoiceSpeaker(switch, openAll)
      return
    end)
    printf("logic_chat_voice_hardware:RefreshAntsVoiceSpeaker in process, delay 3s.")
    return
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local curRoomID = logic_chat_voice_data_manager:GetRoomIDByRoomType(curRoomType)
  if curRoomID == "" then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice:RefreshAntsVoiceSpeaker, self.curRoom == \"\".")
    return
  end
  if switch == nil then
    switch = self:GetSpeakerState()
  end
  if switch then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
    self.AntsVoiceInterface:OpenSpeaker()
    self:ChangeSpeakerFlag(true, openAll)
  else
    self:ChangeSpeakerFlag(false, openAll)
  end
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_SPEAKER)
end
function logic_chat_voice_hardware:ChangeSpeakerFlag(switch, bOpenAll)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:ChangeSpeakerFlag, switch:%s", switch))
  if switch then
    if bOpenAll then
      self.AntsVoiceInterface:OpenAllSpeaker()
    else
      self.AntsVoiceInterface:OpenTeamSpeakerOnly()
    end
  else
    self.AntsVoiceInterface:CloseAllSpeaker()
  end
end
function logic_chat_voice_hardware:RefreshAntsVoiceMicrophone(switch, openAll)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice:RefreshAntsVoiceMicrophone, switch:%s", switch))
  if not logic_chat_voice_utility.CheckIsRoleValid() then
    return
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  if logic_chat_voice:CheckIsAntsVoiceMsgInProcess() then
    if self.RefreshMicTimer then
      self:RemoveTimer(self.RefreshMicTimer)
      self.RefreshMicTimer = nil
    end
    self.RefreshMicTimer = self:AddTimerOnce(3, function()
      self:RefreshAntsVoiceMicrophone(switch, openAll)
    end)
    return
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local curRoomID = logic_chat_voice_data_manager:GetRoomIDByRoomType(curRoomType)
  if curRoomID == "" then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice:RefreshAntsVoiceMicrophone, curRoom == \"\".")
    return
  end
  if switch == nil then
    switch = self:GetMicState()
  end
  if switch then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
    self.AntsVoiceInterface:OpenMic()
    self:ChangeMicrophoneFlag(true, openAll)
  else
    self:ChangeMicrophoneFlag(false, openAll)
  end
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_MICROPHONE)
end
function logic_chat_voice_hardware:ChangeMicrophoneFlag(switch, openAll)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:ChangeMicrophoneFlag, switch:%s", switch))
  if switch then
    local shouldOpenAll = openAll
    if GameStatus.IsInLobbyOrMainCity() then
      local ban_util = require("client.common.ban_util")
      local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
      local bIsBan = ban_util.IsBanned(BanMacro.PLAYER_BAN_GLOBAL_MI)
      shouldOpenAll = openAll and not bIsBan
    end
    if shouldOpenAll then
      self.AntsVoiceInterface:OpenAllMicphone()
    else
      self.AntsVoiceInterface:OpenTeamMicphoneOnly()
    end
  else
    self.AntsVoiceInterface:CloseAllMicphone()
  end
end
function logic_chat_voice_hardware:GetSelfRoomSpeakerState(identifier)
  local state = self:GetSelfRoomState(identifier)
  return state[Enum_MemberStateBitDefine.SpeakerBit]
end
function logic_chat_voice_hardware:GetSelfRoomMicrophoneState(identifier)
  local state = self:GetSelfRoomState(identifier)
  return state[Enum_MemberStateBitDefine.MicBit]
end
function logic_chat_voice_hardware:GetSelfRoomState(identifier)
  local roomState
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  if identifier and type(identifier) == "number" then
    roomState = logic_chat_voice_data_manager:GetSelfStateByRoomType(identifier)
  elseif identifier and type(identifier) == "string" then
    roomState = logic_chat_voice_data_manager:GetSelfStateByRoomID(identifier)
  end
  return roomState or {false, false}
end
function logic_chat_voice_hardware:ChangeRoomSpeakerState(switch, identifier)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:ChangeRoomSpeakerState, switch, identifier:%s, %s", switch, identifier))
  if switch then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:ReenterVoiceRoom(identifier)
  end
  self:RefreshAntsVoiceSpeaker(switch)
end
function logic_chat_voice_hardware:ChangeRoomMicrophoneState(switch, identifier)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:ChangeRoomMicrophoneState, switch, identifier:%s, %s", switch, identifier))
  if switch then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:ReenterVoiceRoom(identifier)
  end
  self:RefreshAntsVoiceMicrophone(switch)
end
function logic_chat_voice_hardware:GetSpeakerState()
  return self.AntsVoiceInterface:TeamSpeakerEnable()
end
function logic_chat_voice_hardware:GetMicState()
  return self.AntsVoiceInterface:TeamMicphoneEnable() and self.AntsVoiceInterface:GetMicphoneState() == Enum_HDmpveVoiceMicState.GV_MIC_STATE_OPENED
end
function logic_chat_voice_hardware:RecoverAntsVoiceRealtime()
  local StringUtil = require("common.string_util")
  local curRole = StringUtil.StrTrim(DataMgr.roleData.uid)
  if logic_chat_voice_utility.CheckIsRoleValid(curRole) then
    return
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local curRoomID = logic_chat_voice_data_manager:GetRoomIDByRoomType(curRoomType)
  if curRoomID ~= "" then
    self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
    self:RefreshAntsVoiceSpeaker()
    self:RefreshAntsVoiceMicrophone()
  end
end
function logic_chat_voice_hardware:RequestPrivacy(callback, content)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:RequestPrivacy")
  if not logic_chat_voice_utility.CheckChatPrivacyAcceptStatus() then
    log(bWriteLog and "logic_chat_voice_hardware:RequestPrivacy, not logic_chat_voice_utility.CheckChatPrivacyAcceptStatus(). ")
    local UIUtil = require("client.common.ui_util")
    local savePrivacyAcceptStatus = function()
      local setting = UIUtil.GetGameFrontendHUD():GetUserSettings()
      setting.ChatPrivacyAcceptedVersion = Client.GetAppVersion()
      UIUtil.GetGameFrontendHUD():FinishModifyUserSettings()
      if self.bIsOpenMicHitPermissionErr == true or self.bIsOpenMicHitPermissionErr == nil then
        log(bWriteLog and "savePrivacyAcceptStatus, self.bIsOpenMicHitPermissionErr == true1. ")
        self.requestPrivacyCallback = callback
        self:CheckMicPermission()
      elseif callback and self.bIsOpenMicHitPermissionErr == false then
        log(bWriteLog and "savePrivacyAcceptStatus, callback1. ")
        callback()
      end
    end
    local params = {
      TitleID = 102012,
      PermissionDes = LocUtil.LocalizeResFormat(44464),
      OkBtnText = LocUtil.LocalizeResFormat(4515),
      IconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Speaking_png.Common_Icon_Speaking_png"
    }
    local logic_permission = require("client.slua.logic.permission.logic_permission")
    logic_permission.ShowWidget(logic_permission.PermissionTypeEnum.Microphone, params, savePrivacyAcceptStatus)
  elseif self.bIsOpenMicHitPermissionErr == true or self.bIsOpenMicHitPermissionErr == nil then
    log(bWriteLog and "logic_chat_voice_hardware:RequestPrivacy, self.bIsOpenMicHitPermissionErr == true2. ")
    self.requestPrivacyCallback = callback
    self:CheckMicPermission()
  elseif callback and self.bIsOpenMicHitPermissionErr == false then
    log(bWriteLog and "logic_chat_voice_hardware:RequestPrivacy, callback2. ")
    callback()
  end
end
function logic_chat_voice_hardware:RequestPrivacyAndOpenMic(callback, content)
  log(bWriteLog and "logic_chat_voice_hardware:RequestPrivacyAndOpenMic")
  local LCallback = function()
    if callback then
      log(bWriteLog and "logic_chat_voice_hardware:RequestPrivacyAndOpenMic, callback. ")
      callback()
      self.AntsVoiceInterface:ResetAntsVoiceMode(Enum_AntsVoiceOnlineStatus.RealTime)
      self:ChangeMicrophoneFlag(true, true)
    end
  end
  self:RequestPrivacy(LCallback, content)
end
function logic_chat_voice_hardware:CheckMicPermission()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_hardware:CheckMicPermission")
  if not logic_chat_voice_utility.CheckChatPrivacyAcceptStatus() then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_hardware:CheckMicPermission, not self:CheckChatPrivacyAcceptStatus(). ")
    return
  end
  Client.EnableIosStuckWork(GameFrontendHUD, false)
  self.AntsVoiceInterface:CommonTestMic()
  if self.sDevicePlatformName == DevicePlatformNameMacros.IOS and self.bIsOpenMicHitPermissionErr then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(102012), LocUtil.GetLocalizeResStr(9408), function()
      Client.EnableIosStuckWork(GameFrontendHUD, true)
    end)
  elseif self.sDevicePlatformName == DevicePlatformNameMacros.Windows then
    self.bIsOpenMicHitPermissionErr = false
  end
  return not self.bIsOpenMicHitPermissionErr
end
function logic_chat_voice_hardware:OnRequestPermissionsResult(code, permission, result)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_hardware:OnRequestPermissionsResult, code, permission, result:%s, %s, %s", code, permission, result))
  if self.sDevicePlatformName == DevicePlatformNameMacros.Android and code == 100 and permission == "[android.permission.RECORD_AUDIO]" and result == "[-1]" and self.bIsOpenMicHitPermissionErr == true then
    if self.iPermissionDenyTimes >= 1 then
      local params = {
        TitleID = 102012,
        PermissionDes = LocUtil.LocalizeResFormat(44464),
        OkBtnText = LocUtil.LocalizeResFormat(4515),
        IconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Speaking_png.Common_Icon_Speaking_png"
      }
      local logic_permission = require("client.slua.logic.permission.logic_permission")
      logic_permission.ShowWidget(logic_permission.PermissionTypeEnum.Microphone, params, function()
        Client.DirectToSetting()
      end)
    else
      self.iPermissionDenyTimes = self.iPermissionDenyTimes + 1
    end
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, logic_chat_voice_hardware)