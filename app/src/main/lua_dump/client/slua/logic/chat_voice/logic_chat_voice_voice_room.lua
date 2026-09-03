local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
local logic_chat_voice_room_operation_manager = require("client.slua.logic.chat_voice.logic_chat_voice_room_operation_manager")
local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
local BusinessHelper = import("BusinessHelper")
local table_pool = require("common.table_pool")
local tablePool = table_pool.Create()
local Enum_RoomCode = logic_chat_voice_const.Enum_RoomCode
local Enum_OperationCompleteCode = logic_chat_voice_const.HDmpveVoiceCompleteCode
local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
local Enum_MemberStateBitDefine = logic_chat_voice_const.Enum_MemberStateBitDefine
local Enum_VoiceRoomStatus = logic_chat_voice_const.Enum_VoiceRoomStatus
local Enum_AntsVoiceRoomOpera = logic_chat_voice_const.Enum_AntsVoiceRoomOpera
local logic_chat_voice_voice_room = {}
function logic_chat_voice_voice_room:OnInitialize()
  self.bGMServerUrl = false
  self.logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
end
function logic_chat_voice_voice_room:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnTeamUpInfoChange, self)
  local interface = self.logic_antsvoice_interface:GetGVoiceInterface()
  self:AddControlEvent(interface, "JoinRoomFail", self.OnJoinRoomFail, self)
  self:AddControlEvent(interface, "QuitRoomFail", self.OnQuitRoomFail, self)
  self:AddControlEvent(interface, "JoinRoomNotify", self.OnJoinRoomNotify, self)
  self:AddControlEvent(interface, "QuitRoomNotify", self.OnQuitRoomNotify, self)
  self:AddControlEvent(interface, "JoinLbsRoomNotify", self.OnJoinLbsRoomNotify, self)
  self:AddControlEvent(interface, "QuitLbsRoomNotify", self.OnQuitLbsRoomNotify, self)
  self:AddControlEvent(interface, "RoomStatusUpdatedNotify", self.OnRoomStatusUpdatedNotify, self)
  self:AddControlEvent(interface, "ReportVoiceTimeToServer", self.OnReportVoiceTimeToServer, self)
end
function logic_chat_voice_voice_room:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:OnPostSwitchGameStatus")
  if nextState == GameStatus.Lobby then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:OnPostSwitchGameStatus, Lobby.")
    self:QuitAntsVoiceRoom(Enum_AntsVoiceRoomType.BattleTeam)
    self:JoinLobbyVoiceRoom()
    local logic_chat_voice_voice_room_param = require("client.slua.logic.chat_voice.logic_chat_voice_voice_room_param")
    logic_chat_voice_voice_room_param:ClearAntsVoiceRoomParam()
  end
end
function logic_chat_voice_voice_room:OnLogOut()
  self:sdkQuitVoiceRoom()
end
function logic_chat_voice_voice_room:OnTeamUpInfoChange(_, _, type)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:OnTeamUpInfoChange")
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(670)
  local bIsTeam = logic_team_up.GetTeamNum() > 1
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnTeamUpInfoChange, type:%s", type))
  if type == ENUM_TeamInfoSyncType.Compatible or type == ENUM_TeamInfoSyncType.All or type == ENUM_TeamInfoSyncType.Base then
    if not GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
      if bIsTeam then
        EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_OR_HIDE_PANEL, true, "Border_MidChatVoice", UIManager.UI_Config.ChatVoice_UIBP)
        EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH, true)
        EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_SIMPLEUI_REFRESH, true)
      else
        EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH, false)
        EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_SIMPLEUI_REFRESH, false)
      end
      if not Client.IsShipping() then
        local logic_team_up_test = require("client.slua.logic.teamup.logic_team_up_test")
        if logic_team_up_test.HasTeamBot() then
          bIsTeam = false
        end
      end
      if bIsTeam then
        logic_chat_voice_doctor:AddJoinTeamRoomStep(671)
        self:JoinLobbyVoiceRoom()
      else
        logic_chat_voice_doctor:AddJoinTeamRoomStep(672)
        self:QuitAntsVoiceRoom(Enum_AntsVoiceRoomType.LobbyTeam)
      end
    else
      logic_chat_voice_doctor:AddJoinTeamRoomStep(673)
    end
  else
    logic_chat_voice_doctor:AddJoinTeamRoomStep(674)
  end
end
function logic_chat_voice_voice_room:OnJoinRoomFail(error, room_id)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnJoinRoomFail, error:%s", error))
  logic_chat_voice_room_operation_manager:OnRoomOperationReturn(Enum_AntsVoiceRoomOpera.Join, error, room_id)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:JoinRoomFailed(error, room_id)
end
function logic_chat_voice_voice_room:OnQuitRoomFail(error, room_id)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnQuitRoomFail, error:%s", error))
  logic_chat_voice_room_operation_manager:OnRoomOperationReturn(Enum_AntsVoiceRoomOpera.Quit, error, room_id)
  if error == Enum_RoomCode.ServerError or error == Enum_RoomCode.QuitRoomSuccess then
    local StringUtil = require("common.string_util")
    local curRole = StringUtil.StrTrim(DataMgr.roleData.uid)
    if logic_chat_voice_utility.CheckIsRoleValid(curRole) then
      self.logic_antsvoice_interface:CloseMic()
      self.logic_antsvoice_interface:CloseSpeaker()
    end
  end
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:QuitRoomFailed(error, room_id)
end
function logic_chat_voice_voice_room:OnJoinRoomNotify(code, room, member)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnJoinRoomNotify, code, room, member:%s, %s, %s", tostring(code), room, member))
  logic_chat_voice_room_operation_manager:OnRoomOperationCompleteCallback(Enum_AntsVoiceRoomOpera.Join, code, room, member)
  if code == Enum_OperationCompleteCode.JoinRoomSucc then
    self:OnJoinRoomSuccess(room, member)
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:EnableVoiceChanger()
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_JOIN_TEAM_ROOM_SUCCESS, room, member)
  end
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:OnJoinRoom(code, room, member)
end
function logic_chat_voice_voice_room:OnQuitRoomNotify(code, room, member, voiceurl, record_data)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:OnQuitRoomNotify, code, room, member, url, records:%s, %s, %s, %s, %s", code, room, member, voiceurl, record_data))
  logic_chat_voice_room_operation_manager:OnRoomOperationCompleteCallback(Enum_AntsVoiceRoomOpera.Quit, code, room, _)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:OnQuitRoom(code, room, member, voiceurl, record_data)
end
function logic_chat_voice_voice_room:OnJoinLbsRoomNotify(code, room, member)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnJoinLbsRoomNotify, code, room, member:%s, %s, %s", code, room, member))
  if code == Enum_OperationCompleteCode.JoinSuccess then
    self:OnJoinRoomSuccess(room, member)
  end
  if code == Enum_OperationCompleteCode.JoinRoomSucc then
    if self:ForceMediaChannelOutput() then
      local AntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
      AntsVoiceInterface:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_ENABLE_MEDIA_CHANNEL_OUTPUT, 1, 0, "")
    end
    self.logic_antsvoice_interface:EnableReportALLAbroad(true, true, 20000)
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_JOIN_LBS_ROOM_SUCCESS, room, member)
  end
  self.logic_antsvoice_interface:DetectSFXState()
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:OnJoinLbsRoom(code, room, member)
end
function logic_chat_voice_voice_room:OnQuitLbsRoomNotify(code, room, member, voiceurl, record_data)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:OnQuitLbsRoomNotify, code, room, member, url, records:%s, %s, %s, %s, %s", code, room, member, voiceurl, record_data))
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:OnQuitLbsRoom(code, room, member, voiceurl, record_data)
  if code == Enum_OperationCompleteCode.QuitRoomSucc then
    local logic_main_city_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_voice)
    logic_main_city_voice:OnQuitLbsRoomNotify(Enum_OperationCompleteCode.QuitRoomSucc, room, member)
  end
end
function logic_chat_voice_voice_room:OnRoomStatusUpdatedNotify(code, room, member)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnRoomStatusUpdatedNotify, code, room, member:%s, %s, %s", code, room, member))
  local curStatus = GameStatus.GetGameStatus()
  local TimeUtil = require("client.common.time_util")
  if curStatus == GameStatus.Lobby then
    log(bWriteLog and string.format("[[muidarzhang] logic_chat_voice_voice_room:OnRoomStatusUpdatedNotify, Lobby, OSTime:%s", TimeUtil.OSTime()))
  elseif curStatus == GameStatus.Fighting then
    log(bWriteLog and string.format("[[[muidarzhang] logic_chat_voice_voice_room:OnRoomStatusUpdatedNotify, Fighting, OSTime:%s", TimeUtil.OSTime()))
  end
  self:ReconnectRoom(true)
end
function logic_chat_voice_voice_room:OnJoinRoomSuccess(room, member)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnJoinRoomSuccess, room, member:%s, %s", room, member))
  if self:ForceMediaChannelOutput() then
    local AntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    AntsVoiceInterface:Invoke(logic_chat_voice_const.Enum_InvokeCmd.GV_ENABLE_MEDIA_CHANNEL_OUTPUT, 1, 0, "")
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  logic_chat_voice_data_manager:SetCurRoomInfoByRoomID(room, {roomID = room, antsVoiceUID = member})
  local stateTable = logic_chat_voice_data_manager:GetSelfStateByRoomID(room)
  local roomType = logic_chat_voice_data_manager:GetRoomTypeByRoomID(room)
  local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
  logic_chat_voice_protocol_manager:JoinVoiceRoom(roomType, room, member, stateTable)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:RefreshAntsVoiceSpeaker(true, self.logic_antsvoice_interface:LbsSpeakerEnable())
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if room == logic_chat_channel_chat_room.GetVoiceRoomID() then
    local LogicChatRoomMember = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicChatRoomMember)
    if LogicChatRoomMember:IsRoomOwnerAndOnMic() then
      log(bWriteLog and "logic_chat_voice_voice_room:OnJoinRoomSuccess, open master microphone")
      LogicChatRoomMember:OpenRoomMicrophone()
    else
      log(bWriteLog and "logic_chat_voice_voice_room:OnJoinRoomSuccess, close microphone")
      logic_chat_voice:RefreshAntsVoiceMicrophone(false)
    end
  else
    log(bWriteLog and "logic_chat_voice_voice_room:OnJoinRoomSuccess, continue opening microphone = true.")
    local stateTableRoomType = logic_chat_voice_data_manager:GetSelfStateByRoomType(roomType)
    if stateTableRoomType and stateTableRoomType[Enum_MemberStateBitDefine.MicBit] then
      logic_chat_voice:RefreshAntsVoiceMicrophone(true, self.logic_antsvoice_interface:LbsMicphoneEnable())
    end
  end
  self.logic_antsvoice_interface:EnableReportALLAbroad(true, true, 20000)
end
function logic_chat_voice_voice_room:OnReportVoiceTimeToServer(totalTalkingTime, totalGamingTime)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnReportVoiceTimeToServer, totalTalkingTime, totalGamingTime:%s, %s", totalTalkingTime, totalGamingTime))
  local GlobalChatHandler = require("client.network.Protocol.GlobalChatHandler")
  local USTExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = USTExtraGameInstance.GetInstance()
  if slua.isValid(uGameInstance) then
    local MainModeID = uGameInstance:GetMainModeID()
    log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnReportVoiceTimeToServer, GameID, ModeID:%s, %s", tostring(MainModeID), tostring(_G.ModeID)))
    GlobalChatHandler.send_report_game_activity(totalTalkingTime, totalGamingTime, MainModeID, _G.ModeID)
  else
    log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:OnReportVoiceTimeToServer, InValid Instance"))
  end
end
function logic_chat_voice_voice_room:JoinLobbyVoiceRoom()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:JoinLobbyVoiceRoom")
  if logic_team_up.GetTeamNum() <= 1 then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_voice_room:JoinLobbyVoiceRoom, logic_team_up.GetTeamNum() <= 1. ")
    return
  end
  local leaderUid = logic_team_up.teamInfo.leader
  if not leaderUid then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_voice_room:JoinLobbyVoiceRoom, not leaderUid . ")
    return
  end
  local roomId = ""
  local leaderId = tostring(math.floor(logic_team_up.teamInfo.leader or 0))
  roomId = logic_chat_voice_utility.GenerateLobbyVoiceRoomID(leaderId, BusinessHelper.GetVoiceSdkGameId() or "")
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:JoinLobbyVoiceRoom, roomId:%s", roomId))
  assert(roomId ~= "", "logic_chat_voice_voice_room:JoinLobbyVoiceRoom roomId is empty.")
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  if logic_chat_voice_data_manager:GetCurRoomType() == Enum_AntsVoiceRoomType.LobbyTeam and logic_chat_voice_data_manager:GetRoomIDByRoomType(Enum_AntsVoiceRoomType.LobbyTeam) == roomId then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_voice_room:JoinLobbyVoiceRoom, logic_chat_voice_data_manager:GetCurRoomType() == Enum_AntsVoiceRoomType.LobbyTeam and logic_chat_voice_data_manager:GetRoomIDByRoomType(Enum_AntsVoiceRoomType.LobbyTeam) == roomId. ")
    return
  end
  local svrInfo = logic_team_up.GetTeamAntsVoiceURL()
  if not GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    self:JoinAntsVoiceRoom(Enum_AntsVoiceRoomType.LobbyTeam, roomId, svrInfo)
  end
end
function logic_chat_voice_voice_room:JoinLbsVoiceRoom(room)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:JoinLbsVoiceRoom, room, user:%s, %s", room, DataMgr.roleData.openID))
  self.logic_antsvoice_interface:JoinLbsRoom(room, DataMgr.roleData.openID)
  self.logic_antsvoice_interface:CheckAndEnableRoomSpeaker()
end
function logic_chat_voice_voice_room:JoinAntsVoiceRoom(roomType, roomID, antsVoiceUrl)
  printf("logic_chat_voice_voice_room:JoinAntsVoiceRoom roomType:%s, roomID:%s, antsVoiceUrl:%s", roomType, roomID, antsVoiceUrl)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(200)
  if not roomID or roomID == "" then
    assert(false, "logic_chat_voice_voice_room:JoinAntsVoiceRoom, roomID is nil or empty.")
  elseif tostring(roomID) == "0" then
    assert(false, "logic_chat_voice_voice_room:JoinAntsVoiceRoom, roomID is 0.")
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  if self:CheckIsInAntsVoiceRoom(roomType, roomID) then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_voice_room:JoinAntsVoiceRoom, self:CheckIsInAntsVoiceRoom(roomType, roomID). ")
    local tParam = tablePool:Get()
    tParam.    tParam.    tParam.uid = tonumber(DataMgr.roleData.uid)
    tParam.state = logic_chat_voice_data_manager:GetSelfStateByRoomID(roomID)
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_JOIN, tParam)
    tablePool:Recycle(tParam)
    logic_chat_voice_doctor:AddJoinTeamRoomStep(203)
    return
  end
  self:QuitVoiceRoomByConflict(roomType, roomID)
  if logic_chat_voice_data_manager:GetCurRoomType() == roomType then
    log(bWriteLog and "logic_chat_voice_voice_room:JoinAntsVoiceRoom, logic_chat_voice_data_manager:GetCurRoomType() == roomType. ")
    local curRoomId = logic_chat_voice_data_manager:GetCurRoomID()
    local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
    logic_chat_voice_protocol_manager:QuitVoiceRoom(roomType, curRoomId)
    logic_chat_voice_data_manager:ClearAllMembersInfo(curRoomId)
  end
  antsVoiceUrl = antsVoiceUrl or logic_chat_voice_data_manager:GetAntsVoiceUrlByRoomType(roomType)
  self:SetAntsVoiceServerInfo(antsVoiceUrl)
  logic_chat_voice_data_manager:SetCurRoomInfoByRoomType(roomType, {roomID = roomID, antsVoiceUrl = antsVoiceUrl})
  self:JoinVoiceRoom(roomType, roomID, antsVoiceUrl)
end
function logic_chat_voice_voice_room:SetAntsVoiceServerInfo(antsVoiceUrl)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:SetAntsVoiceServerInfo, antsVoiceUrl:%s", antsVoiceUrl))
  if not antsVoiceUrl or antsVoiceUrl == "" or self.bGMServerUrl then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:SetAntsVoiceServerInfo, not antsVoiceUrl. ")
    local defaultAntsVoiceUrl = CDataTable.GetTableData("ZoneConfig", 1).VoiceServer
    antsVoiceUrl = HDmpveRemote.HDmpveRemoteConfigGetString("GVoiceDefaultSvrAddr", defaultAntsVoiceUrl)
    if antsVoiceUrl == "" then
      antsVoiceUrl = defaultAntsVoiceUrl
    end
    if _G.IsEditor then
      antsVoiceUrl = FuncUtil.GetDomainByID(3366180)
    end
  end
  if antsVoiceUrl and antsVoiceUrl ~= "" then
    self.logic_antsvoice_interface:SetAntsVoiceServerInfo(antsVoiceUrl)
  end
end
function logic_chat_voice_voice_room:JoinVoiceRoom(roomType, room, voice_url)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(300)
  assert(room and room ~= "", "logic_chat_voice_voice_room:JoinVoiceRoom, room is nil or empty.")
  local StringUtil = require("common.string_util")
  room = StringUtil.StrTrim(tostring(room))
  local room_info = {
    room_id = room,
    room_type = roomType,
      }
  printf("logic_chat_voice_voice_room:JoinVoiceRoom AddRoomOperation Join by JoinVoiceRoom. roomType:%s, room:%s, voice_url:%s", roomType, room, voice_url)
  logic_chat_voice_room_operation_manager:AddRoomOperation(Enum_AntsVoiceRoomOpera.Join, function(data)
    self:DoJoinRoomTaskAction(data)
  end, room_info)
end
function logic_chat_voice_voice_room:QuitVoiceRoomByConflict(newRoomType, newRoomID)
  printf("logic_chat_voice_voice_room:QuitVoiceRoomByConflict newRoomType:%s, newRoomID:%s", newRoomType, newRoomID)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType, curRoomID = logic_chat_voice_data_manager:GetSDKCurTeamRoomInfo()
  if curRoomType == nil then
    printf("logic_chat_voice_voice_room:QuitVoiceRoomByConflict, curRoomType == nil")
    return
  end
  if curRoomType < 0 then
    printf("logic_chat_voice_voice_room:QuitVoiceRoomByConflict, not in any room.")
    return
  end
  local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
  if curRoomType ~= newRoomType then
    if curRoomType == Enum_AntsVoiceRoomType.LobbyChatRoom then
      local stateTable = {
        false,
        false,
        true
      }
      logic_chat_voice_protocol_manager.reportSource = "QuitVoiceRoomByConflict"
      logic_chat_voice_protocol_manager:ReportVoiceRoomState(curRoomType, curRoomID, stateTable)
    else
      logic_chat_voice_protocol_manager:QuitVoiceRoom(curRoomType, curRoomID)
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(1, function()
      ShowNotice(38766)
    end)
  end
  self:sdkQuitVoiceRoom()
end
function logic_chat_voice_voice_room:ReconnectRoom(bForce)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(660)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:ReconnectRoom")
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomID = logic_chat_voice_data_manager:GetCurRoomID()
  if curRoomID and curRoomID ~= "" then
    logic_chat_voice_doctor:AddJoinTeamRoomStep(661)
    self:ReenterVoiceRoom(curRoomID, bForce)
  else
    logic_chat_voice_doctor:AddJoinTeamRoomStep(662)
    printf("logic_chat_voice_voice_room:ReconnectRoom AddRoomOperation Quit By ReconnectRoom")
    logic_chat_voice_room_operation_manager:AddRoomOperation(Enum_AntsVoiceRoomOpera.Quit, function(data)
      self:DoQuitRoomTaskAction(data)
    end, {})
  end
end
function logic_chat_voice_voice_room:ReenterVoiceRoom(roomIdOrRoomType, bForce)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:ReenterVoiceRoom1, roomIdOrRoomType:%s", roomIdOrRoomType))
  if roomIdOrRoomType == nil or roomIdOrRoomType == "" or roomIdOrRoomType == logic_chat_voice_const.NO_TEAM_ROOM_ROOM_NAME then
    log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:ReenterVoiceRoom1 return by room null"))
    return
  end
  local voice_url = ""
  if type(roomIdOrRoomType) == "number" then
    local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
    voice_url = logic_chat_voice_data_manager:GetAntsVoiceUrlByRoomType(roomIdOrRoomType)
    roomIdOrRoomType = logic_chat_voice_data_manager:GetRoomIDByRoomType(roomIdOrRoomType)
  end
  local CheckRoomNameForReEnter = HDmpveRemote.HDmpveRemoteConfigGetBool("CheckRoomNameForReEnter", true)
  if CheckRoomNameForReEnter == true and (roomIdOrRoomType == nil or roomIdOrRoomType == "" or roomIdOrRoomType == logic_chat_voice_const.NO_TEAM_ROOM_ROOM_NAME) then
    log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:ReenterVoiceRoom1 return by room null"))
    return
  end
  local room = roomIdOrRoomType
  local StringUtil = require("common.string_util")
  room = StringUtil.StrTrim(tostring(room))
  local need_to_quit_room_before_join = false
  local need_to_rejoin_room = false
  if logic_chat_voice_room_operation_manager:IsAllTaskFinished() ~= true then
    if logic_chat_voice_room_operation_manager:IsJoinOperaInLast(room) ~= true then
      log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:ReenterVoiceRoom #2"))
      if logic_chat_voice_room_operation_manager:IsJoinOperaInLast() == true then
        need_to_quit_room_before_join = true
      end
      need_to_rejoin_room = true
    end
  else
    local curRoomID = self.logic_antsvoice_interface:GetTeamRoomName()
    log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:ReenterVoiceRoom #3 %s", curRoomID))
    if curRoomID == nil or curRoomID == "" or curRoomID == logic_chat_voice_const.NO_TEAM_ROOM_ROOM_NAME then
      need_to_rejoin_room = true
    elseif curRoomID == room then
      local curRoomStatus = self.logic_antsvoice_interface:GetRoomStatus(curRoomID)
      log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:ReenterVoiceRoom #5  %d", curRoomStatus))
      if curRoomStatus == Enum_VoiceRoomStatus.RoomStatus_OffLine or curRoomStatus == Enum_VoiceRoomStatus.RoomStatus_JoiningWithErr or curRoomStatus == Enum_VoiceRoomStatus.RoomStatus_Quited then
        log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:ReenterVoiceRoom #6"))
        if curRoomStatus == Enum_VoiceRoomStatus.RoomStatus_OffLine then
          need_to_quit_room_before_join = true
        end
        need_to_rejoin_room = true
      end
    else
      log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:ReenterVoiceRoom #7"))
      need_to_quit_room_before_join = true
      need_to_rejoin_room = true
    end
  end
  if need_to_quit_room_before_join then
    self:sdkQuitVoiceRoom()
  end
  if need_to_rejoin_room then
    local room_info = {
      room_id = room,
      room_type = "",
          }
    printf("logic_chat_voice_voice_room:ReenterVoiceRoom AddRoomOperation Join by ReenterVoiceRoom. %s", room)
    logic_chat_voice_room_operation_manager:AddRoomOperation(Enum_AntsVoiceRoomOpera.Join, function(data)
      self:DoJoinRoomTaskAction(data)
    end, room_info)
  end
end
function logic_chat_voice_voice_room:QuitAntsVoiceRoom(roomType)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(640)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType, curRoomName = logic_chat_voice_data_manager:GetSDKCurTeamRoomInfo()
  local soft_roomType = logic_chat_voice_data_manager:GetCurRoomType()
  local soft_roomID = logic_chat_voice_data_manager:GetCurRoomID()
  printf("logic_chat_voice_voice_room:QuitAntsVoiceRoom roomType:%s, soft_roomType:%s, soft_roomID:%s, curRoomType:%s, curRoomName:%s", roomType, soft_roomType, soft_roomID, curRoomType, curRoomName)
  if roomType and curRoomType ~= roomType and roomType ~= soft_roomType then
    logic_chat_voice_doctor:AddJoinTeamRoomStep(642)
    printf("logic_chat_voice_voice_room:QuitAntsVoiceRoom return by roomType not equal. curRoomType:%s", curRoomType)
    return
  end
  local roomID
  if 0 <= curRoomType then
    roomType = curRoomType
    roomID = curRoomName
  else
    roomType = soft_roomType
    roomID = soft_roomID
  end
  logic_chat_voice_data_manager:ClearRoomInfoByRoomType(roomType)
  logic_chat_voice_data_manager:ClearAllMembersInfo(roomID, nil)
  local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
  logic_chat_voice_protocol_manager:QuitVoiceRoom(roomType, roomID)
  self:sdkQuitVoiceRoom()
end
function logic_chat_voice_voice_room:sdkQuitVoiceRoom()
  printf("logic_chat_voice_voice_room:sdkQuitVoiceRoom AddRoomOperation Quit By sdkQuitVoiceRoom")
  logic_chat_voice_room_operation_manager:AddRoomOperation(Enum_AntsVoiceRoomOpera.Quit, function(data)
    self:DoQuitRoomTaskAction(data)
  end, {})
end
function logic_chat_voice_voice_room:DoJoinRoomTaskAction(data)
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(500)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:DoJoinRoomAction %s", data.room_id))
  local room_id = data.room_id
  local voice_url = data.voice_url
  if voice_url ~= nil and voice_url ~= "" then
    self.logic_antsvoice_interface:SetAntsVoiceServerInfo(voice_url)
  end
  logic_chat_voice_doctor:AddJoinTeamRoomStep(room_id)
  self.logic_antsvoice_interface:JoinRoom(room_id, "")
end
function logic_chat_voice_voice_room:DoQuitRoomTaskAction(data)
  log(bWriteLog and string.format("[WSL] logic_chat_voice_voice_room:DoQuitRoomAction"))
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(600)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:DisableVoiceChanger()
  self.logic_antsvoice_interface:QuitRoom()
end
function logic_chat_voice_voice_room:CheckIsInAntsVoiceRoom(roomType, roomID)
  printf("logic_chat_voice_voice_room:CheckIsInAntsVoiceRoom roomType:%s, roomID:%s", roomType, roomID)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType, curRoomName = logic_chat_voice_data_manager:GetSDKCurTeamRoomInfo()
  if curRoomType == nil then
    printf("logic_chat_voice_voice_room:CheckIsInAntsVoiceRoom return by roomType is nil")
    return false
  end
  if curRoomType < 0 then
    printf("logic_chat_voice_voice_room:CheckIsInAntsVoiceRoom return by no room")
    return false
  end
  if curRoomName ~= roomID then
    printf("logic_chat_voice_voice_room:CheckIsInAntsVoiceRoom return by roomName not equal")
    return false
  end
  if curRoomType ~= roomType then
    printf("logic_chat_voice_voice_room:CheckIsInAntsVoiceRoom return by roomType not equal")
    return false
  end
  return true
end
function logic_chat_voice_voice_room:GetAntsVoiceRoomMemberList(identifier)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:GetAntsVoiceRoomMemberList, identifier:%s", tostring(identifier)))
  local allMembersInfo = {}
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  if identifier and type(identifier) == "number" then
    allMembersInfo = logic_chat_voice_data_manager:GetAllMembersInfoListByRoomType(identifier)
  elseif identifier and type(identifier) == "string" then
    allMembersInfo = logic_chat_voice_data_manager:GetAllMembersInfoListByRoomID(identifier)
  end
  log_tree("[muidarzhang] logic_chat_voice_voice_room:GetAntsVoiceRoomMemberList allMembersInfo:", allMembersInfo)
  return allMembersInfo or {}
end
function logic_chat_voice_voice_room:RenotifyAntsVoiceRoomMemberInfo(identifier)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room:RenotifyAntsVoiceRoomMemberInfo, identifier:%s", identifier))
  local allMembersInfo = self:GetAntsVoiceRoomMemberList(identifier)
  log_tree("[muidarzhang] logic_chat_voice_voice_room:RenotifyAntsVoiceRoomMemberInfo identifier:", allMembersInfo)
  for k, tParam in ipairs(allMembersInfo) do
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBERINFO_CHANGE, tParam)
  end
end
function logic_chat_voice_voice_room:SetGMServerUrl()
  self.bGMServerUrl = true
end
function logic_chat_voice_voice_room:ForbidLbsMemberVoice(switch)
  local roomID = self.logic_antsvoice_interface:GetLbsRoomName()
  self:ForbidMemberVoiceByID(roomID, switch)
  log(bWriteLog and string.format("logic_chat_voice_voice_room:ForbidLbsMemberVoiceById, error:%s", tostring(switch)))
end
function logic_chat_voice_voice_room:ForbidMemberVoiceByID(roomID, switch)
  local error = self.logic_antsvoice_interface:AlwaysDisableRoomMic(roomID, switch)
  log(bWriteLog and string.format("logic_chat_voice_voice_room:ForbidLbsMemberVoiceById, error:%s", tostring(error)))
end
function logic_chat_voice_voice_room:ShowAntsVoiceUI()
  log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:ShowAntsVoiceUI")
  if logic_team_up.GetTeamNum() <= 1 then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room:ShowAntsVoiceUI, logic_team_up.GetTeamNum() <= 1. ")
    return
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_OR_HIDE_PANEL, true, "Border_MidChatVoice", UIManager.UI_Config.ChatVoice_UIBP)
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH, true)
end
function logic_chat_voice_voice_room:HideAntsVoiceUI()
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH, false)
end
function logic_chat_voice_voice_room:ForceMediaChannelOutput()
  local found = false
  if logic_chat_voice_voice_room.ForceMediaChannelOutpuOSVersion == nil then
    local mediaOutputOSVer = HDmpveRemote.HDmpveRemoteConfigGetString("ForceMediaChannelOutpuOSVersion", "")
    if mediaOutputOSVer == "" then
      logic_chat_voice_voice_room.ForceMediaChannelOutpuOSVersion = {}
    else
      local StringUtil = require("common.string_util")
      logic_chat_voice_voice_room.ForceMediaChannelOutpuOSVersion = StringUtil.Split(mediaOutputOSVer, ",")
    end
  end
  local osVersion = Client.GetOSVersion()
  for i, v in ipairs(logic_chat_voice_voice_room.ForceMediaChannelOutpuOSVersion) do
    if string.sub(osVersion, 1, string.len(v)) == v then
      found = true
      break
    end
  end
  log(bWriteLog and "logic_chat_voice_voice_room:ForceMediaChannelOutput: " .. tostring(found))
  return found
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, logic_chat_voice_voice_room)