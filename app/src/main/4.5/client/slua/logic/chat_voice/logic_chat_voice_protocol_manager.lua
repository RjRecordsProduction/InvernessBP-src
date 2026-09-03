local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
local table_pool = require("common.table_pool")
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local BusinessHelper = import("BusinessHelper")
local tablePool = table_pool.Create()
local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
local logic_chat_voice_protocol_manager = {}
function logic_chat_voice_protocol_manager:JoinVoiceRoom(roomType, roomID, antsVoiceUID, state)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:JoinVoiceRoom2Server, roomType, roomID, antsVoiceUID, state:%s, %s, %s", tostring(roomType), tostring(roomID), tostring(antsVoiceUID)))
  if roomType == nil then
    local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
    local leaderId = tostring(math.floor(logic_team_up.teamInfo.leader or 0))
    local lobbyRoomID = logic_chat_voice_utility.GenerateLobbyVoiceRoomID(leaderId, BusinessHelper.GetVoiceSdkGameId() or "")
    if roomID == lobbyRoomID then
      roomType = Enum_AntsVoiceRoomType.LobbyTeam
    end
    local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
    local chatVoiceRoomID = logic_chat_channel_chat_room.GetVoiceRoomID()
    if roomID == chatVoiceRoomID then
      roomType = Enum_AntsVoiceRoomType.LobbyChatRoom
    end
  end
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_SELE_MEMBER_JOIN_IN_BATTLE, roomID, antsVoiceUID)
  if SubsystemMgr then
    local PlanPH_VoiceRoomMember_Client = SubsystemMgr:Get("PlanPH_VoiceRoomMember_Client")
    if PlanPH_VoiceRoomMember_Client then
      PlanPH_VoiceRoomMember_Client:Join_Voice_Room_req(roomID, antsVoiceUID)
    end
  end
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:JoinVoiceRoom2Server, roomType, roomID, antsVoiceUID, state:%s, %s, %s", tostring(roomType), tostring(roomID), tostring(antsVoiceUID)))
  if roomType ~= Enum_AntsVoiceRoomType.LobbyTeam and roomType ~= Enum_AntsVoiceRoomType.LobbyChatRoom then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_protocol_manager:JoinVoiceRoom, roomType ~= Enum_AntsVoiceRoomType.LobbyTeam and roomType ~= Enum_AntsVoiceRoomType.LobbyChatRoom. ")
    return
  end
  local ChatVoiceHandler = require("client.network.Protocol.ChatVoiceHandler")
  local stateBit = logic_chat_voice_utility.EncodeMemberState(state)
  ChatVoiceHandler.send_join_voice_room_req(roomType, roomID, antsVoiceUID, stateBit)
end
function logic_chat_voice_protocol_manager:OnJoinRoom(roomType, roomID, allMembersInfo)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:OnJoinRoom, roomType, roomID:%s, %s", tostring(roomType), tostring(roomID)))
  log_tree("[muidarzhang] logic_chat_voice_protocol_manager:OnJoinRoom allMembersInfo:", allMembersInfo)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  logic_chat_voice_data_manager:SetAllMembersInfo(roomType, roomID, allMembersInfo)
  local tParam = tablePool:Get()
  tParam.  tParam.  tParam.uid = tonumber(DataMgr.roleData.uid)
  tParam.state = logic_chat_voice_data_manager:GetSelfStateByRoomID(roomID)
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_JOIN, tParam)
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_SELE_MEMBER_JOIN, tParam)
  tablePool:Recycle(tParam)
  self:ReportVoiceRoomState()
end
function logic_chat_voice_protocol_manager:QuitVoiceRoom(roomType, roomID)
  printf("logic_chat_voice_protocol_manager:QuitVoiceRoom2Server, roomType:%s, roomID:%s", roomType, roomID)
  assert(roomType, "roomType is nil")
  if roomID == nil or roomID == "" then
    log_error("logic_chat_voice_protocol_manager:QuitVoiceRoom2Server, roomID is nil or empty")
    return
  end
  if SubsystemMgr then
    local PlanPH_VoiceRoomMember_Client = SubsystemMgr:Get("PlanPH_VoiceRoomMember_Client")
    if PlanPH_VoiceRoomMember_Client then
      PlanPH_VoiceRoomMember_Client:Exit_Voice_Room_req(roomID)
    end
    local MainCity_VoiceRoomMember_Client = SubsystemMgr:Get("PlanPH_VoiceRoomMember_Client")
    if MainCity_VoiceRoomMember_Client then
      MainCity_VoiceRoomMember_Client:Exit_Voice_Room_req(tostring(roomID))
    end
  end
  if roomType == Enum_AntsVoiceRoomType.LobbyTeam or roomType == Enum_AntsVoiceRoomType.LobbyChatRoom then
    local ChatVoiceHandler = require("client.network.Protocol.ChatVoiceHandler")
    ChatVoiceHandler.send_exit_voice_room_req(roomType, roomID)
  end
end
function logic_chat_voice_protocol_manager:OnQuitRoom(roomType, roomID)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:OnQuitRoom, roomType, roomID:%s, %s", tostring(roomType), roomID))
  local tParam = tablePool:Get()
  tParam.  tParam.  tParam.uid = tonumber(DataMgr.roleData.uid)
  tParam.state = {
    false,
    false,
    false
  }
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_QUIT, tParam)
  tablePool:Recycle(tParam)
end
function logic_chat_voice_protocol_manager:ReportVoiceRoomState(roomType, roomID, stateTable)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:ReportVoiceRoomState, roomType, roomID:%s, %s", roomType, roomID))
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  if not roomType and not roomID then
    roomType = logic_chat_voice_data_manager:GetCurRoomType()
    roomID = logic_chat_voice_data_manager:GetCurRoomID()
  elseif not roomID then
    roomID = logic_chat_voice_data_manager:GetRoomIDByRoomType(roomType)
  else
    roomType = roomType or logic_chat_voice_data_manager:GetRoomTypeByRoomID(roomID)
  end
  if roomType == nil then
    local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
    local leaderId = tostring(math.floor(logic_team_up.teamInfo.leader or 0))
    local lobbyRoomID = logic_chat_voice_utility.GenerateLobbyVoiceRoomID(leaderId, BusinessHelper.GetVoiceSdkGameId() or "")
    if roomID == lobbyRoomID then
      roomType = Enum_AntsVoiceRoomType.LobbyTeam
    end
    local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
    local chatVoiceRoomID = logic_chat_channel_chat_room.GetVoiceRoomID()
    if roomID == chatVoiceRoomID then
      roomType = Enum_AntsVoiceRoomType.LobbyChatRoom
    end
  end
  if roomID == "" then
    if roomType == Enum_AntsVoiceRoomType.LobbyTeam then
      roomID = logic_chat_voice_utility.GenerateLobbyVoiceRoomID(DataMgr.roleData.uid, BusinessHelper.GetVoiceSdkGameId() or "")
    elseif roomType == Enum_AntsVoiceRoomType.LobbyChatRoom then
      local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
      roomID = logic_chat_channel_chat_room.GetVoiceRoomID()
    end
  end
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:ReportVoiceRoomState, roomType, roomID:%s, %s", roomType, roomID))
  if roomType ~= Enum_AntsVoiceRoomType.LobbyTeam and roomType ~= Enum_AntsVoiceRoomType.LobbyChatRoom then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_protocol_manager:ReportVoiceRoomState, roomType ~= Enum_AntsVoiceRoomType.LobbyTeam and roomType ~= Enum_AntsVoiceRoomType.LobbyChatRoom. ")
    return
  end
  if not roomID or roomID == "" then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_protocol_manager:ReportVoiceRoomState, not roomID or roomID == \"\". ")
    return
  end
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:ReportVoiceRoomState, roomType, roomID:%s, %s", roomType, roomID))
  local allMembersInfo = logic_chat_voice_data_manager:GetAllMembersInfoByRoomID(roomID)
  if not allMembersInfo then
    log(bWriteLog and "[muidarzhang] WARNING: logic_chat_voice_protocol_manager:ReportVoiceRoomState, not allMembersInfo. \229\144\142\229\143\176\232\191\152\230\178\161\230\156\137\232\191\155\229\133\165\232\175\165\230\136\191\233\151\180\239\188\140\228\184\141\228\184\138\230\138\165\232\175\165\233\186\166\229\133\139\233\163\142\231\138\182\230\128\129\227\128\130")
    return
  end
  stateTable = stateTable or logic_chat_voice_data_manager:GetSelfStateByRoomType(roomType)
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local curRoomID = logic_chat_voice_data_manager:GetCurRoomID()
  if curRoomType == roomType and curRoomID == roomID then
    self.stateTableToSend = stateTable
    self.RoomTypeToReport = roomType
    self.RoomIDToReport = roomID
  end
  local stateBit = logic_chat_voice_utility.EncodeMemberState(stateTable)
  self.lastReportTime = self.lastReportTime or 0
  local TimeUtil = require("client.common.time_util")
  if math.abs(TimeUtil.GetServerTimeInSec() - self.lastReportTime) > 2 then
    log_tree("[muidarzhang] logic_chat_voice_protocol_manager:ReportVoiceRoomState stateTable:", stateTable)
    local ChatVoiceHandler = require("client.network.Protocol.ChatVoiceHandler")
    local stateBit = logic_chat_voice_utility.EncodeMemberState(stateTable)
    ChatVoiceHandler.send_report_voice_room_state_req(roomType, roomID, stateBit)
    self.lastReportTime = TimeUtil.GetServerTimeInSec()
  elseif not self.sendTimer then
    log(bWriteLog and "logic_chat_voice_protocol_manager:ReportVoiceRoomState, sendTimer is nil, add timer. ")
    local time_ticker = require("common.time_ticker")
    self.sendTimer = time_ticker.AddTimerOnce(1, function()
      log_tree("logic_chat_voice_protocol_manager:ReportVoiceRoomState stateTable:", self.stateTableToSend)
      log(bWriteLog and "logic_chat_voice_protocol_manager:ReportVoiceRoomState, real send stateTable")
      self:ReportVoiceRoomStateImpl()
      self.cachedTime = 0
      time_ticker.RemoveTimer(self.sendTimer)
      self.sendTimer = nil
    end)
  else
    self.cachedTime = (self.cachedTime or 0) + 1
    log(bWriteLog and "logic_chat_voice_protocol_manager:ReportVoiceRoomState, cache triggered, skip. cached " .. self.cachedTime)
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  end
  logic_chat_voice_data_manager:UpdateSelfMemberInfo(roomType, roomID, stateBit)
  local tParam = tablePool:Get()
  tParam.  tParam.  tParam.uid = tonumber(DataMgr.roleData.uid)
  tParam.state = stateTable
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBERINFO_CHANGE, tParam)
  tablePool:Recycle(tParam)
end
function logic_chat_voice_protocol_manager:ReportVoiceRoomStateImpl(roomType, roomID, stateTable)
  log(bWriteLog and string.format("logic_chat_voice_protocol_manager:ReportVoiceRoomStateImpl, roomType, roomID:%s, %s", roomType, roomID))
  local TimeUtil = require("client.common.time_util")
  local roomType = roomType or self.RoomTypeToReport
  local roomID = roomID or self.RoomIDToReport
  local stateTable = stateTable or self.StateTableToSend
  if stateTable == nil then
    log(bWriteLog and "logic_chat_voice_protocol_manager:ReportVoiceRoomStateImpl, stateTable is nil. ")
    return
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local ChatVoiceHandler = require("client.network.Protocol.ChatVoiceHandler")
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local curRoomID = logic_chat_voice_data_manager:GetCurRoomID()
  if curRoomType == roomType and curRoomID == roomID and stateTable then
    local stateBit = logic_chat_voice_utility.EncodeMemberState(stateTable)
    ChatVoiceHandler.send_report_voice_room_state_req(roomType, roomID, stateBit)
    self.lastReportTime = TimeUtil.GetServerTimeInSec()
  end
end
function logic_chat_voice_protocol_manager:OnMemberJoinRoom(roomType, roomID, updateInfo)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:OnMemberJoinRoom, roomType, roomID:%s, %s", tostring(roomType), roomID))
  log_tree("[muidarzhang] logic_chat_voice_protocol_manager:OnMemberJoinRoom updateInfo:", updateInfo)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  logic_chat_voice_data_manager:UpdateMemberInfo(roomType, roomID, updateInfo)
  local tParam = tablePool:Get()
  tParam.  tParam.  tParam.uid = updateInfo.update_uid
  tParam.state = logic_chat_voice_utility.DecodeMemberState(updateInfo.state)
  tParam.memberID = updateInfo.AntsVoice_uid
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_JOIN, tParam)
  tablePool:Recycle(tParam)
end
function logic_chat_voice_protocol_manager:OnMemberQuitRoom(roomType, roomID, updateInfo)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:OnMemberExitRoom, roomType, roomID:%s, %s", tostring(roomType), roomID))
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  logic_chat_voice_data_manager:UpdateMemberInfo(roomType, roomID, updateInfo)
  local tParam = tablePool:Get()
  tParam.  tParam.  tParam.uid = updateInfo.update_uid
  tParam.state = logic_chat_voice_utility.DecodeMemberState(0)
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_QUIT, tParam)
  tablePool:Recycle(tParam)
end
function logic_chat_voice_protocol_manager:OnMemberInfoChange(roomType, roomID, updateInfo)
  log(bWriteLog and "[muidarzhang] logic_chat_voice_protocol_manager:OnMemberInfoChange")
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_protocol_manager:OnMemberInfoChange, roomType, roomID:%s, %s", tostring(roomType), roomID))
  log_tree("[muidarzhang] logic_chat_voice_protocol_manager:OnMemberInfoChange updateInfo:", updateInfo)
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  logic_chat_voice_data_manager:UpdateMemberInfo(roomType, roomID, updateInfo)
  local tParam = tablePool:Get()
  tParam.  tParam.  tParam.uid = updateInfo.update_uid
  tParam.state = logic_chat_voice_utility.DecodeMemberState(updateInfo.state)
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBERINFO_CHANGE, tParam)
  tablePool:Recycle(tParam)
end
function logic_chat_voice_protocol_manager:TestReportVoiceRoomState()
  local time = 0
  local Enum_AntsVoiceRoomType = require("client.slua.logic.chat_voice.logic_chat_voice_const").Enum_AntsVoiceRoomType
  time_ticker.AddTimerLoop(1, function()
    time = time + 1
    log("ReportVoiceRoomState   ### time is " .. time .. " ### ReportVoiceRoomState")
    local state1 = time % 2 == 0 and true or false
    local state2 = time % 3 == 0 and true or false
    local state3 = time % 5 == 0 and true or false
    log("   state1 is " .. tostring(state1) .. " state2 is " .. tostring(state2) .. " state3 is " .. tostring(state3))
    logic_chat_voice_protocol_manager.reportSource = "TestReportVoiceRoomState"
    logic_chat_voice_protocol_manager:ReportVoiceRoomState(Enum_AntsVoiceRoomType.LobbyTeam, "1234567890", {
      state1,
      state2,
      state3
    })
  end, 10, 0.3)
end
return logic_chat_voice_protocol_manager