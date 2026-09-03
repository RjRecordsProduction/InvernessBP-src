local logic_room_match_voice = {
  eMicType = {
    Close = 0,
    Open = 1,
    Inter = 2
  },
  eSpkType = {Close = 0, Open = 1}
}
local data_config_marco = require("client.logic.data.data_config_marco")
local C_ServerConfigName_ESport = data_config_marco.custom_room_privilege_table
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local Enum_OperationCompleteCode = logic_chat_voice_const.HDmpveVoiceCompleteCode
local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
local Room_Match_Report_Type = Enum_AntsVoiceRoomType.LobbyTeam
function logic_room_match_voice:OnLogin()
  log(bWriteLog and "logic_room_match_voice:OnLogin")
end
function logic_room_match_voice:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_room_match_voice:OnPostSwitchGameStatus" .. tostring(nextState))
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_room_match_voice:OnPostSwitchGameStatus back to lobby")
    self.backToLobby = false
  end
end
function logic_room_match_voice:OnInitialize()
  self.team_is_speaking = {}
  self.team_is_mic_open = {}
end
function logic_room_match_voice:RegistEvents()
  log(bWriteLog and "logic_room_match_voice:RegistEvents")
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_VOICE, self.OnMemberVoice, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_LBS_SPEAKING, self.OnLbsSpeaking, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_MEMBER, self.OnRoomInfoChanged, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_MEMBER_UPDATE, self.OnRoomInfoChanged, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO, self.OnRoomInfoChanged, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_JOIN, self.OnMemberInfoChange, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBERINFO_CHANGE, self.OnMemberInfoChange, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_JOIN_TEAM_ROOM_SUCCESS, self.OnJoinTeamRoomSuccess, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_JOIN_LBS_ROOM_SUCCESS, self.OnJoinLbsRoomSuccess, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_WAITING_OPEN, self.OnOpenRoomUI, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_WAITING_CLOSE, self.OnCloseRoomUI, self)
end
function logic_room_match_voice:OnOpenRoomUI()
  log(bWriteLog and "logic_room_match_voice:OnOpenRoomUI")
  if logic_room_match_voice:IsVoiceRoom() then
    self.backToLobby = true
    local room_id = RoomSystem.CurrentRoomInfo.id
    local pos = RoomSystem.GetSelfPos()
    log(bWriteLog and "logic_room_match_voice:OnOpenRoomUI room_id:" .. tostring(room_id) .. " pos:" .. tostring(pos))
    if room_id and pos then
      self:OnJoinMatchRoom(room_id, pos)
    end
  end
end
function logic_room_match_voice:OnCloseRoomUI()
  log(bWriteLog and "logic_room_match_voice:OnCloseRoomUI")
  self:QuitMatchRoomWithJudgement()
end
function logic_room_match_voice:OnJoinMatchRoom(room_id, pos)
  log(bWriteLog and "logic_room_match_voice:OnJoinMatchRoom" .. tostring(room_id) .. " " .. tostring(pos))
  local bInMainCity = GameStatus.IsInMainCity()
  if bInMainCity then
    local logic_main_city_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_voice)
    if logic_main_city_voice and not self.hasQuitMC then
      self.hasQuitMC = true
      logic_main_city_voice:QuitMainCityVoiceRoom()
    end
  end
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  xpcall(function()
    logic_chat_channel_chat_room.QuitVoiceRoom()
  end, require("common.utility").ErrorMessageHandler)
  logic_chat_channel_chat_room.send_exit_channel_req(logic_chat_channel_chat_room.GetMyChatRoomId())
  if not room_id or not pos then
    log(bWriteLog and "logic_room_match_voice:OnJoinMatchRoom param error")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_room_match_voice:OnJoinMatchRoom not in lobby or main city")
    return
  end
  self.team_is_mic_open = {}
  self.team_is_speaking = {}
  self.IsSelfSpeaking = false
  self.room_name = room_id
  self.room_  self:JoinMatchVoiceRoom(room_id)
  self:JoinMatchTeamVoiceRoom(room_id, pos)
end
function logic_room_match_voice:OnQuitMatchRoom()
  log(bWriteLog and "logic_room_match_voice:OnQuitMatchRoom")
  self:QuitMatchVoiceRoom()
  self:QuitMatchTeamVoiceRoom()
  local bInMainCity = GameStatus.IsInMainCity()
  if bInMainCity then
    local logic_main_city_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_voice)
    if logic_main_city_voice then
      self.hasQuitMC = false
      logic_main_city_voice:JoinMainCityVoiceRoom()
    end
  end
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  if logic_chat_channel_manager then
    logic_chat_channel_manager:AddTimerOnce(0.5, function()
      logic_chat_channel_manager:UpdateChannelList()
    end)
  end
end
function logic_room_match_voice:QuitMatchRoomWithJudgement()
  if self.voice_room_id and self.voice_room_id ~= "" then
    self:QuitMatchVoiceRoom()
  end
  if self.team_voice_room_id and self.team_voice_room_id ~= "" then
    self:QuitMatchTeamVoiceRoom()
  end
end
function logic_room_match_voice:OnRoomInfoChanged()
  if not RoomSystem or not RoomSystem.CurrentRoomInfo then
    return
  end
  local bIsRoomStartGame = RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.state == "gaming"
  if bIsRoomStartGame and not self.backToLobby then
    log(bWriteLog and "logic_room_match_voice:OnRoomInfoChanged skip, room is gaming and not back to lobby")
    return
  end
  local room_id = RoomSystem.CurrentRoomInfo.id
  local pos = RoomSystem.GetSelfPos and RoomSystem.GetSelfPos() or nil
  if not room_id or not pos then
    return
  end
  self:OnSyncRoomInfo(room_id, pos)
end
function logic_room_match_voice:OnSyncRoomInfo(room_id, pos)
  log(bWriteLog and "logic_room_match_voice:OnSyncRoomInfo" .. tostring(room_id) .. " " .. tostring(pos))
  if room_id == nil or pos == nil then
    log(bWriteLog and "logic_room_match_voice:OnSyncRoomInfo room_id/pos is nil")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_room_match_voice:OnSyncRoomInfo not in lobby or main city")
    return
  end
  if not self:IsVoiceRoom() then
    log(bWriteLog and "logic_room_match_voice:OnSyncRoomInfo not in voice room or not player pos")
    return
  end
  local new_voice_room_id = self:GetMatchVoiceRoomID(room_id)
  if new_voice_room_id == self.voice_room_id and pos == self.room_pos then
    return
  elseif new_voice_room_id == self.voice_room_id and pos ~= self.room_pos then
    self:OnChangeRoomPos(room_id, pos)
  else
    log(bWriteLog and "logic_room_match_voice:OnSyncRoomInfo change voice room to " .. tostring(new_voice_room_id))
    self:OnJoinMatchRoom(room_id, pos)
  end
end
function logic_room_match_voice:OnChangeRoomPos(room_id, pos)
  log(bWriteLog and "logic_room_match_voice:OnChangeRoomPos" .. tostring(room_id) .. " " .. tostring(pos))
  if not room_id or not pos then
    log(bWriteLog and "logic_room_match_voice:OnChangeRoomPos room_id/pos is nil")
    return
  end
  self.room_  local old_team_id = self.team_id
  local new_team_id = self:GetTeamIdByPos(self.room_pos)
  if old_team_id ~= new_team_id then
    self:ReportExitTeamVoiceRoom()
  end
  self.team_id = new_team_id
  if RoomSystem.IsPlayerPos(pos) then
    self:JoinMatchTeamVoiceRoom(room_id, pos)
  else
    self:QuitMatchTeamVoiceRoom()
    UIManager.CloseUI(UIManager.UI_Config.Room_Microphone_UIBP)
    UIManager.CloseUI(UIManager.UI_Config.Room_Speaker_UIBP)
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
  if ui and ui.UpdateTeamVoiceUI then
    ui:UpdateTeamVoiceUI(tonumber(DataMgr.roleData.uid))
  end
end
function logic_room_match_voice:OnMemberVoice(_, _, tParam)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  log(bWriteLog and "logic_room_match_voice.OnMemberVoice")
  if not tParam or not tParam.roomID then
    return
  end
  if not self:IsMatchRoomOwner() and tParam.memberID == self.voice_room_member_id then
    return
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
  if self:IsMatchVoiceRoom(tParam.roomID) and ui and ui.OnOwnerSpeaking then
    local bSpeaking = tParam.status ~= 0
    ui:OnOwnerSpeaking(bSpeaking)
    self:AdjustTeamVolume(bSpeaking and 20 or 100)
  end
end
function logic_room_match_voice:OnMemberInfoChange(_, _, tParam)
  log(bWriteLog and "logic_room_match_voice:OnMemberInfoChange")
  if not (tParam and tParam.roomID and tParam.uid) or not tParam.state then
    log(bWriteLog and "logic_room_match_voice:OnMemberInfoChange param error")
    return
  end
  if tParam.roomID and self:IsMatchTeamVoiceRoom(tParam.roomID) then
    log(bWriteLog and "logic_room_match_voice:OnMemberInfoChange team voice room")
    local uid = tParam.uid
    if uid and uid ~= 0 then
      local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
      local Enum_MemberStateBitDefine = logic_chat_voice_const.Enum_MemberStateBitDefine
      local bMic = tParam.state[Enum_MemberStateBitDefine.MicBit]
      self.team_is_mic_open[uid] = bMic
      local ui = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
      if ui and ui.UpdateTeamVoiceUI then
        ui:UpdateTeamVoiceUI(uid)
      end
    end
  end
end
function logic_room_match_voice:SetMicState(state)
  log(bWriteLog and "logic_room_match_voice:SetMicState " .. tostring(state))
  if not state then
    return
  end
  if self:IsMatchRoomOwner() then
    self:SetOwnerMicState(state)
  elseif RoomSystem.IsPlayerPos(self.room_pos) then
    self:SetTeamMicStateImpl(state)
    self:UpdateRoomMicrophoneUI()
    local MicState = false
    if self.curMicType == self.eMicType.Open then
      MicState = true
    elseif self.curMicType == self.eMicType.Inter then
      MicState = true
    end
    self:ReportTeamVoiceStateWithRefresh(MicState)
  end
end
function logic_room_match_voice:SetSpkState(state)
  log(bWriteLog and "logic_room_match_voice:SetSpkState state = " .. tostring(state))
  if not state then
    return
  end
  if self:IsMatchRoomOwner() then
    log(bWriteLog and "logic_room_match_voice:SetSpkState RoomOwner")
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    self.curSpkType = self.eSpkType.Close
    logic_antsvoice_interface:CloseAllSpeaker()
  elseif RoomSystem.IsPlayerPos(self.room_pos) then
    log(bWriteLog and "logic_room_match_voice:SetSpkState TeamMember")
    self:SetTeamSpkStateImpl(state)
  end
  self:AddTimerOnce(0.5, function()
    self:RefreshSpkStatus()
  end)
end
function logic_room_match_voice:SetTeamMicStateImpl(state)
  log(bWriteLog and "logic_room_match_voice:SetTeamMicStateImpl state = " .. tostring(state))
  if not self.room_pos or not RoomSystem.IsPlayerPos(self.room_pos) then
    log(bWriteLog and "logic_room_match_voice: not a team member")
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if state == self.eMicType.Close then
    logic_antsvoice_interface:CloseAllMicphone()
    self.curMicType = self.eMicType.Close
    self.team_is_mic_open[tonumber(DataMgr.roleData.uid)] = false
    self.team_is_speaking[tonumber(DataMgr.roleData.uid)] = false
  else
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    local EUChatRestriction = logic_chat_voice:CheckEUChatRestriction()
    if EUChatRestriction then
      ShowNotice(4377)
      return
    end
    logic_chat_voice:RequestPrivacy(function()
      self.team_is_mic_open[tonumber(DataMgr.roleData.uid)] = true
      if state == self.eMicType.Open then
        log(bWriteLog and "logic_room_match_voice:SetTeamMicStateImpl Open")
        logic_antsvoice_interface:OpenAllMicphone()
        self.curMicType = self.eMicType.Open
      elseif state == self.eMicType.Inter then
        log(bWriteLog and "logic_room_match_voice:SetTeamMicStateImpl Inter")
        logic_antsvoice_interface:OpenLbsInterphone()
        self.curMicType = self.eMicType.Inter
      end
    end, 4073)
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
  if ui and ui.UpdateTeamVoiceUI then
    ui:UpdateTeamVoiceUI(tonumber(DataMgr.roleData.uid))
  end
end
function logic_room_match_voice:SetTeamSpkStateImpl(state)
  log(bWriteLog and "logic_room_match_voice:SetTeamSpkStateImpl state = " .. tostring(state))
  if not self.room_pos or not RoomSystem.IsPlayerPos(self.room_pos) then
    log(bWriteLog and "logic_room_match_voice: not a team member")
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  self.curSpkType = state
  if state == self.eSpkType.Close then
    logic_antsvoice_interface:OpenTeamSpeakerOnly()
  elseif state == self.eSpkType.Open then
    logic_antsvoice_interface:OpenAllSpeaker()
  end
end
function logic_room_match_voice:OnLbsSpeaking(eventType, eventID, RoomName, member, status)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  log(bWriteLog and "logic_room_match_voice.OnLbsSpeaking member = " .. member .. ", status = " .. status)
  local uid = self:GetUidByMemberId(member)
  if not uid or uid == 0 then
    log(bWriteLog and "logic_room_match_voice:OnLbsSpeaking return by uid is invalid")
    return
  else
    log(bWriteLog and "logic_room_match_voice:OnLbsSpeaking uid = " .. uid)
    self.member2uid = self.member2uid or {}
    self.member2uid[member] = tonumber(uid)
    local previous_status = self.team_is_speaking[tonumber(uid)]
    self.team_is_speaking[tonumber(uid)] = status
    if previous_status ~= status then
      local ui = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
      if ui and ui.UpdateTeamVoiceUI then
        ui:UpdateTeamVoiceUI(uid)
      end
    end
  end
end
function logic_room_match_voice:IsTeamMemberSpeaking(uid)
  if not uid or uid == 0 then
    return false
  end
  local result = self.team_is_speaking[uid] ~= nil and self.team_is_speaking[uid] ~= false and self.team_is_speaking[uid] ~= 0
  log(bWriteLog and "logic_room_match_voice:IsTeamMemberSpeaking uid = " .. uid .. ", result = " .. tostring(self.team_is_speaking[uid]))
  return result
end
function logic_room_match_voice:IsTeamMemberMicOpen(uid)
  if not uid or uid == 0 then
    return false
  end
  if self.team_is_mic_open[uid] ~= nil then
    return self.team_is_mic_open[uid]
  else
    if not self.team_voice_room_id or not self.team_id then
      return false
    end
    local backend_report_room_id = self:GetBackendReportRoomId(self.team_voice_room_id, self.team_id)
    if not backend_report_room_id then
      return false
    end
    local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
    local Enum_MemberStateBitDefine = logic_chat_voice_const.Enum_MemberStateBitDefine
    return logic_chat_voice_data_manager:GetMemberStateByRoomID(backend_report_room_id, uid)[Enum_MemberStateBitDefine.MicBit]
  end
end
function logic_room_match_voice:GetUidByMemberId(member_id)
  if not member_id then
    return 0
  end
  if self.member2uid and self.member2uid[member_id] then
    return self.member2uid[member_id]
  end
  local backend_report_room_id = self:GetBackendReportRoomId(self.team_voice_room_id, self.team_id)
  if not backend_report_room_id then
    return 0
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  return logic_chat_voice_data_manager:GetMemberUidByAntsVoiceUid(backend_report_room_id, member_id)
end
function logic_room_match_voice:OnJoinTeamRoomSuccess(_, _, room, member)
  log(bWriteLog and string.format("logic_room_match_voice:OnJoinTeamRoomSuccess room:%s member:%s", tostring(room), tostring(member)))
  if not self:IsMatchVoiceRoom(room) then
    return
  end
  self.voice_room_member_id = member
  self:OnJoinRoomNotify(Enum_OperationCompleteCode.JoinRoomSucc, room, member)
end
function logic_room_match_voice:OnJoinLbsRoomSuccess(_, _, room, member)
  log(bWriteLog and string.format("logic_room_match_voice:OnJoinLbsRoomSuccess room:%s member:%s", tostring(room), tostring(member)))
  if self:IsMatchTeamVoiceRoom(room) then
    self:OnJoinTeamRoomNotify(Enum_OperationCompleteCode.JoinRoomSucc, room, member)
  end
end
function logic_room_match_voice:JoinMatchVoiceRoom(room_id)
  log(bWriteLog and "logic_room_match_voice:JoinMatchVoiceRoom room_id:" .. tostring(room_id))
  if not room_id then
    return
  end
  local new_voice_room_id = self:GetMatchVoiceRoomID(room_id)
  if new_voice_room_id == self.voice_room_id then
    log(bWriteLog and "logic_room_match_voice:JoinMatchVoiceRoom repeat")
  end
  if 0 < room_id then
    self:JoinMatchVoiceRoomImpl(room_id)
  else
    log(bWriteLog and "logic_room_match_voice:JoinMatchVoiceRoom room_id is nil or room_id <= 0")
  end
end
function logic_room_match_voice:QuitMatchVoiceRoom()
  log(bWriteLog and "logic_room_match_voice:QuitMathVoiceRoom")
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:QuitAntsVoiceRoom(Enum_AntsVoiceRoomType.LobbyMatchRoom)
  self.voice_room_id = nil
end
function logic_room_match_voice:OnJoinRoomNotify(code, room, member)
  log(bWriteLog and string.format("logic_room_match_voice:OnJoinRoomNotify, 1code, 2room, 3member:%s, %s, %s", tostring(code), room, member))
  if self:IsMatchVoiceRoom(room) then
    log(bWriteLog and "logic_room_match_voice:OnJoinRoomNotify match voice room room:" .. tostring(room))
    if code == Enum_OperationCompleteCode.JoinRoomSucc then
      self.voice_room_id = room
      self:AddTimerOnce(0.1, function()
        local MicState = logic_room_match_voice.eMicType.Close
        self:SetMicState(MicState)
        self:SetSpkState(logic_room_match_voice.eSpkType.Open)
      end)
    end
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    if self.room_pos ~= 999 then
      log(bWriteLog and "logic_room_match_voice:OnJoinRoomNotify disable room:" .. tostring(room))
      logic_antsvoice_interface:AlwaysDisableRoomMic(room, false)
    else
      logic_antsvoice_interface:AlwaysDisableRoomMic(room, true)
    end
  elseif self:IsMatchTeamVoiceRoom(room) then
    log(bWriteLog and "logic_room_match_voice:OnJoinRoomNotify match team voice room room:" .. tostring(room))
    if code == Enum_OperationCompleteCode.JoinRoomSucc then
      self:OnJoinTeamRoomNotify(code, room, member)
    end
  else
    self:QuitMatchVoiceRoom()
    self:QuitMatchTeamVoiceRoom()
    self.hasQuitMC = false
    log(bWriteLog and "logic_room_match_voice:OnJoinRoomNotify not valid room")
    return
  end
end
function logic_room_match_voice:OnJoinTeamRoomNotify(code, room, member)
  log(bWriteLog and string.format("logic_room_match_voice:OnJoinTeamRoomNotify, 1code, 2room, 3member:%s, %s, %s", tostring(code), room, member))
  if self:IsMatchTeamVoiceRoom(room) then
    log(bWriteLog and "logic_room_match_voice:OnJoinTeamRoomNotify match team voice room room:" .. tostring(room))
    self.team_voice_room_id = room
    self.team_voice_member_id = member
    if code == Enum_OperationCompleteCode.JoinRoomSucc then
      self:AddTimerOnce(0.1, function()
        local stateTable = {
          true,
          false,
          false
        }
        self:ReportJoinTeamVoiceRoom(member, stateTable)
        self:SetMicState(logic_room_match_voice.eMicType.Close)
        self:SetSpkState(logic_room_match_voice.eSpkType.Open)
      end)
    end
  else
    log(bWriteLog and "logic_room_match_voice:OnJoinTeamRoomNotify not valid room")
  end
end
function logic_room_match_voice:OnQuitRoomNotify(code, room, member, voiceurl, record_data)
  log(bWriteLog and "logic_room_match_voice:OnQuitRoomNotify")
  if code == Enum_OperationCompleteCode.QuitRoomSucc then
    if self:IsMatchVoiceRoom(room) then
      log(bWriteLog and "logic_room_match_voice:OnQuitRoomNotify match voice room")
    elseif self:IsMatchTeamVoiceRoom(room) then
      log(bWriteLog and "logic_room_match_voice:OnQuitRoomNotify match team voice room")
    end
  end
end
function logic_room_match_voice:GetMatchVoiceRoomID(room_id)
  if not room_id then
    return
  end
  return "match_room_voice_" .. tostring(room_id)
end
function logic_room_match_voice:IsMatchVoiceRoom(voice_room_id)
  return string.find(tostring(voice_room_id), "match_room_voice_")
end
function logic_room_match_voice:SetVoiceRoomID(room_id)
  log(bWriteLog and "logic_room_match_voice:SetRoomID room_id:" .. tostring(room_id))
  self.voice_end
function logic_room_match_voice:JoinMatchVoiceRoomImpl(room_id)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:JoinAntsVoiceRoom(Enum_AntsVoiceRoomType.LobbyMatchRoom, self:GetMatchVoiceRoomID(room_id), "")
end
function logic_room_match_voice:QuitMatchVoiceRoomImpl()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:QuitAntsVoiceRoom(Enum_AntsVoiceRoomType.LobbyMatchRoom)
end
function logic_room_match_voice:JoinMatchTeamVoiceRoom(room_id, pos)
  log(bWriteLog and "logic_room_match_voice:JoinMatchTeamVoiceRoom pos:" .. tostring(pos))
  if RoomSystem.IsPlayerPos(pos) then
    local team_id = self:GetTeamIdByPos(pos)
    self:JoinMatchTeamVoiceRoomImpl(room_id, team_id)
  else
    self.team_id = nil
    log(bWriteLog and "logic_room_match_voice:JoinMatchTeamVoiceRoom not player pos")
  end
end
function logic_room_match_voice:JoinMatchTeamVoiceRoomImpl(room_id, team_id)
  if not room_id or not team_id then
    log(bWriteLog and "logic_room_match_voice:JoinMatchTeamVoiceRoomImpl param error room_id:" .. tostring(room_id) .. " team_id:" .. tostring(team_id))
    return
  end
  self.  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local voice_room_id = self:GetMatchTeamVoiceRoomID(room_id)
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local sdkLbsRoomId = logic_antsvoice_interface:GetLbsRoomName()
  log(bWriteLog and "logic_room_match_voice:JoinMatchTeamVoiceRoomImpl sdkLbsRoomId:" .. tostring(sdkLbsRoomId))
  if sdkLbsRoomId ~= voice_room_id then
    log(bWriteLog and "logic_room_match_voice:JoinMatchTeamVoiceRoomImpl Join room_id:" .. tostring(voice_room_id) .. " old:" .. tostring(self.team_voice_room_id))
    self:SetMicState(logic_room_match_voice.eMicType.Close)
    self:SetSpkState(logic_room_match_voice.eSpkType.Open)
    logic_chat_voice:JoinLbsVoiceRoom(voice_room_id)
    self.team_is_speaking = {}
    self.team_is_mic_open = {}
  else
    log(bWriteLog and "logic_room_match_voice:JoinMatchTeamVoiceRoomImpl repeat room_id:" .. tostring(voice_room_id))
  end
  self:UpdateTeamRoomPos()
  if not self.UpdatePosTimer then
    self.UpdatePosTimer = self:AddTimerLoop(0.5, function()
      self:UpdateTeamRoomPos()
    end, TIMER_INFINITE, 1.0)
  end
end
function logic_room_match_voice:QuitMatchTeamVoiceRoom()
  log(bWriteLog and "logic_room_match_voice:QuitMatchTeamVoiceRoom")
  if self.UpdatePosTimer then
    self:RemoveTimer(self.UpdatePosTimer)
    self.UpdatePosTimer = nil
  end
  self:ReportExitTeamVoiceRoom()
  self.team_voice_room_id = nil
  self.team_voice_member_id = nil
  self.team_id = nil
  self:QuitMatchTeamVoiceRoomImpl()
end
function logic_room_match_voice:GetMatchTeamVoiceRoomID(room_id)
  return "match_room_team_voice_" .. tostring(room_id)
end
function logic_room_match_voice:QuitMatchTeamVoiceRoomImpl()
  log(bWriteLog and "logic_room_match_voice:QuitMatchTeamVoiceRoomImpl")
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local roomID = logic_antsvoice_interface:GetLbsRoomName()
  if self:IsMatchTeamVoiceRoom(roomID) then
    log(bWriteLog and "logic_room_match_voice:QuitMatchTeamVoiceRoomImpl quit lbs room:" .. tostring(roomID))
    logic_antsvoice_interface:QuitLbsRoom()
  else
    log(bWriteLog and "logic_room_match_voice:QuitMatchTeamVoiceRoomImpl not match lbs room:" .. tostring(roomID))
  end
  self.team_is_speaking = {}
  self.team_is_mic_open = {}
end
function logic_room_match_voice:IsMatchTeamVoiceRoom(voice_room_id)
  return string.find(tostring(voice_room_id), "match_room_team_voice_")
end
function logic_room_match_voice:GetMicAndSpk()
  return self.curMicType or 0, self.curSpkType or 0
end
function logic_room_match_voice:SetOwnerMicState(micType, bForce)
  log(bWriteLog and "logic_room_match_voice:SetOwnerMicState micType:" .. tostring(micType))
  if not bForce then
    if self:IsMatchRoomOwner() then
      micType = micType or self.eMicType.Inter
    end
  else
    log(bWriteLog and "logic_room_match_voice:SetOwnerMicState bForce")
    micType = micType or self.eMicType.Close
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if micType == self.eMicType.Close then
    logic_antsvoice_interface:CloseAllMicphone()
    self.curMicType = micType
    self:UpdateRoomMicrophoneUI()
    return
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local EUChatRestriction = logic_chat_voice:CheckEUChatRestriction()
  if EUChatRestriction then
    ShowNotice(4377)
    return
  end
  logic_chat_voice:RequestPrivacy(function()
    self:SetOwnerMicStateImpl(micType)
  end, 4073)
end
function logic_room_match_voice:SetOwnerMicStateImpl(micType)
  log(bWriteLog and "logic_room_match_voice:SetOwnerMicStateImpl" .. tostring(micType))
  local UIUtil = require("client.common.ui_util")
  local uAntsVoiceInterface = UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
  if not uAntsVoiceInterface then
    micType = self.eMicType.Close
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if micType == self.eMicType.Open then
    logic_antsvoice_interface:OpenTeamMicphoneOnly()
  elseif micType == self.eMicType.Inter then
    uAntsVoiceInterface:OpenTeamInterphone()
  end
  self.curMicType = micType
  self:AddTimerOnce(0.5, function()
    self:RefreshMicStatus()
  end)
end
function logic_room_match_voice:RefreshMicStatus()
  log(bWriteLog and "logic_room_match_voice:RefreshMicStatus")
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if logic_antsvoice_interface:IsInterphoneMode() then
    local bIsInterphoneOpen = false
    if self:IsMatchRoomOwner() then
      bIsInterphoneOpen = logic_antsvoice_interface:IsTeamInterphoneOpenned()
    else
      bIsInterphoneOpen = logic_antsvoice_interface:IsLbsInterphoneOpenned()
    end
    if bIsInterphoneOpen then
      self.curMicType = logic_room_match_voice.eMicType.Inter
    else
      self.curMicType = logic_room_match_voice.eMicType.Close
    end
  else
    local bIsMicrophoneOpen = false
    if self:IsMatchRoomOwner() then
      bIsMicrophoneOpen = logic_antsvoice_interface:TeamMicphoneEnable()
    else
      bIsMicrophoneOpen = logic_antsvoice_interface:LbsMicphoneEnable()
    end
    if bIsMicrophoneOpen then
      self.curMicType = logic_room_match_voice.eMicType.Open
    else
      self.curMicType = logic_room_match_voice.eMicType.Close
    end
  end
  log(bWriteLog and "logic_room_match_voice:RefreshMicStatus" .. tostring(self.curMicType))
  local chatUI = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
  if chatUI and chatUI.UpdateRoomVoiceUI then
    chatUI:UpdateRoomVoiceUI()
  end
  self:UpdateRoomMicrophoneUI()
end
function logic_room_match_voice:RefreshSpkStatus()
  if self:IsMatchRoomOwner() then
    self.curSpkType = self.eSpkType.Close
  else
    local GVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if not slua.isValid(GVoiceInterface) then
      return
    end
    local bIsLbsSpeakerEnable = GVoiceInterface:LbsSpeakerEnable()
    if bIsLbsSpeakerEnable then
      self.curSpkType = self.eSpkType.Open
    else
      self.curSpkType = self.eSpkType.Close
    end
    local RoomWaitingUI = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
    if RoomWaitingUI and RoomWaitingUI.UpdateRoomVoiceUI then
      RoomWaitingUI:UpdateRoomVoiceUI()
    end
  end
end
function logic_room_match_voice:UpdateRoomMicrophoneUI()
  local ui = UIManager.GetUI(UIManager.UI_Config.Room_Microphone_UIBP)
  if ui and ui.UpdateUI then
    ui:UpdateUI()
  end
  local RoomWaitingUI = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
  if RoomWaitingUI and RoomWaitingUI.UpdateRoomVoiceUI then
    RoomWaitingUI:UpdateRoomVoiceUI()
  end
end
function logic_room_match_voice:IsMatchRoomOwner(uid)
  if uid == nil then
    uid = DataMgr.roleData.uid
  end
  return RoomSystem.CurrentRoomInfo.owner_id == uid and self:IsVoiceRoom()
end
function logic_room_match_voice:DebugNotice(notice)
end
function logic_room_match_voice:IsVoiceRoom(room_info)
  local roomInfo = room_info or RoomSystem.CurrentRoomInfo
  log_tree(roomInfo)
  local card_id = roomInfo and tonumber(roomInfo.card_id) or 0
  local eRoomCardCfg = CDataTable.GetTableData("EsportsRoomCard", card_id)
  if eRoomCardCfg and eRoomCardCfg.IsVoiceRoom and eRoomCardCfg.IsVoiceRoom == 1 then
    return true
  else
    return false
  end
end
function logic_room_match_voice:GetVoiceRoomOwnerPos()
  return 999
end
function logic_room_match_voice:ReportJoinTeamVoiceRoom(memberId, stateTable)
  log(bWriteLog and "logic_room_match_voice:ReportJoinTeamVoiceRoom memberId:" .. tostring(memberId))
  if not self.team_voice_room_id or not self.team_id then
    log(bWriteLog and "logic_room_match_voice:ReportJoinTeamVoiceRoom not valid team_voice_room_id:" .. tostring(self.team_voice_room_id) .. " team_id:" .. tostring(self.team_id))
    return
  end
  local backend_report_room_id = self:GetBackendReportRoomId(self.team_voice_room_id, self.team_id)
  if not backend_report_room_id then
    log(bWriteLog and "logic_room_match_voice:ReportJoinTeamVoiceRoom not valid backend_report_room_id:" .. tostring(backend_report_room_id))
    return
  end
  local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
  local stateBit = logic_chat_voice_utility.EncodeMemberState(stateTable)
  local ChatVoiceHandler = require("client.network.Protocol.ChatVoiceHandler")
  ChatVoiceHandler.send_join_voice_room_req(Room_Match_Report_Type, backend_report_room_id, memberId, stateBit)
end
function logic_room_match_voice:ReportExitTeamVoiceRoom()
  log(bWriteLog and "logic_room_match_voice:ReportExitTeamVoiceRoom")
  if not self.team_voice_room_id or not self.team_id then
    log(bWriteLog and "logic_room_match_voice:ReportExitTeamVoiceRoom not valid team_voice_room_id:" .. tostring(self.team_voice_room_id) .. " team_id:" .. tostring(self.team_id))
    return
  end
  local backend_report_room_id = self:GetBackendReportRoomId(self.team_voice_room_id, self.team_id)
  if not backend_report_room_id then
    log(bWriteLog and "logic_room_match_voice:ReportExitTeamVoiceRoom not valid backend_report_room_id:" .. tostring(backend_report_room_id))
    return
  end
  local ChatVoiceHandler = require("client.network.Protocol.ChatVoiceHandler")
  ChatVoiceHandler.send_exit_voice_room_req(Room_Match_Report_Type, backend_report_room_id)
end
function logic_room_match_voice:ReportTeamVoiceState(stateTable)
  log(bWriteLog and "logic_room_match_voice:ReportTeamVoiceState")
  if not self.team_voice_room_id or not self.team_id then
    log(bWriteLog and "logic_room_match_voice:ReportTeamVoiceState not valid team_voice_room_id:" .. tostring(self.team_voice_room_id) .. " team_id:" .. tostring(self.team_id))
    return
  end
  local ChatVoiceHandler = require("client.network.Protocol.ChatVoiceHandler")
  local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
  local stateBit = logic_chat_voice_utility.EncodeMemberState(stateTable)
  local backend_report_room_id = self:GetBackendReportRoomId(self.team_voice_room_id, self.team_id)
  if not backend_report_room_id then
    log(bWriteLog and "logic_room_match_voice:ReportTeamVoiceState not valid backend_report_room_id:" .. tostring(backend_report_room_id))
    return
  end
  ChatVoiceHandler.send_report_voice_room_state_req(Room_Match_Report_Type, backend_report_room_id, stateBit)
end
function logic_room_match_voice:ReportTeamVoiceStateWithRefresh(MicState)
  self:ReportTeamVoiceState({
    true,
    MicState,
    false
  })
end
function logic_room_match_voice:GetTeamIdByPos(pos)
  log(bWriteLog and "logic_room_match_voice:GetTeamIdByPos pos:" .. tostring(pos))
  if not pos then
    return nil
  end
  local room_info = RoomSystem.CurrentRoomInfo
  if not room_info then
    return nil
  end
  if room_info.group_type == 1 then
    return nil
  end
  local team_size = room_info.group_type == 2 and 2 or 4
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  if CreateRoomSystem then
    team_size = CreateRoomSystem.GetTeamModeMaxPlayerNum(RoomSystem.CurrentRoomInfo.map_id)
  end
  return math.ceil(pos / team_size)
end
function logic_room_match_voice:UpdateTeamRoomPos()
  local voice_room_id = self.team_voice_room_id
  local room_pos = self.room_pos
  if not (voice_room_id and room_pos) or not RoomSystem.IsPlayerPos(room_pos) then
    return
  end
  local roomSystemPos = RoomSystem.GetSelfPos()
  if not roomSystemPos then
    return
  end
  local team_id = self:GetTeamIdByPos(room_pos)
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local coordinate = self:GetCoordinateFromTeamId(team_id)
  log(bWriteLog and "logic_room_match_voice:UpdateTeamRoomPos coordinate:" .. tostring(coordinate))
  logic_antsvoice_interface:UpdateVoiceCoordinate(voice_room_id, coordinate, coordinate, coordinate, 5)
end
function logic_room_match_voice:GetCoordinateFromTeamId(team_id)
  if not team_id then
    log(bWriteLog and "logic_room_match_voice:GetCoordinateFromTeamId team_id is invalid:" .. tostring(team_id))
    return 0
  end
  return math.floor(team_id + 0.5) * 500
end
function logic_room_match_voice:CanUseVoice()
  if not self:IsVoiceRoom() then
    return false
  end
  if self:IsMatchRoomOwner() then
    return true
  end
  local pos = self.room_pos
  if not pos and RoomSystem.GetSelfPos then
    pos = RoomSystem.GetSelfPos()
  end
  return RoomSystem.IsPlayerPos(pos)
end
function logic_room_match_voice:AdjustTeamVolume(volume)
  log(bWriteLog and "logic_room_match_voice:AdjustTeamVolume volume:" .. tostring(volume))
  local team_member_list = RoomSystem.GetTeamMemberList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local UIUtil = require("client.common.ui_util")
  local GVoiceInterface = UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
  for _, member in ipairs(team_member_list) do
    local uid = tonumber(member.openid)
    if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
      local profile = logic_profile:GetLocalProfile(uid)
      local realOpenId = profile and profile.openid
      if realOpenId then
        GVoiceInterface:SetPlayerVolume(realOpenId, volume)
      end
    end
  end
end
function logic_room_match_voice:GetBackendReportRoomId(team_voice_room_id, team_id)
  if not team_voice_room_id or not team_id then
    return nil
  end
  return tostring(team_voice_room_id) .. "_" .. tostring(team_id)
end
function logic_room_match_voice:GetTeamVoiceRoomState(uid)
  if not uid or uid == 0 then
    return nil
  end
  local backend_report_room_id = self:GetBackendReportRoomId(self.team_voice_room_id, self.team_id)
  if not backend_report_room_id then
    return nil
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  return logic_chat_voice_data_manager:GetMemberStateByRoomID(backend_report_room_id, uid)
end
function logic_room_match_voice:TestReportJoin(bState, room_id)
  local room_id = room_id or self.room_name
  local team_voice_id = self:GetMatchTeamVoiceRoomID(room_id)
  self.team_voice_room_id = team_voice_id
  self.team_id = self:GetTeamIdByPos(self.room_pos)
  self:ReportJoinTeamVoiceRoom(self.room_pos, {
    bState,
    bState,
    bState
  })
end
function logic_room_match_voice:TestReportChangeState(bState, room_id)
  local room_id = room_id or self.room_name
  local team_voice_id = self:GetMatchTeamVoiceRoomID(room_id)
  self.team_voice_room_id = team_voice_id
  self.team_id = self:GetTeamIdByPos(self.room_pos)
  self:ReportTeamVoiceState({
    bState,
    bState,
    bState
  })
end
function logic_room_match_voice:SetIsTalkingInterphone(bIsTalkingInterphone)
  self.end
function logic_room_match_voice:SelfSpeakingCheckTick()
  if not self:CanUseVoice() then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if self.curMicType == logic_room_match_voice.eMicType.Close then
    self:SetSelfSpeaking(false)
    return
  end
  if self.curMicType == logic_room_match_voice.eMicType.Inter and not self.bIsTalkingInterphone then
    self:SetSelfSpeaking(false)
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local interface = logic_antsvoice_interface:GetGVoiceInterface()
  local newSpeaking = interface:IsSpeaking()
  self:SetSelfSpeaking(newSpeaking)
end
function logic_room_match_voice:SetSelfSpeaking(inSpeaking)
  local oldSelfSpeaking = self.IsSelfSpeaking
  if oldSelfSpeaking ~= inSpeaking then
    log(bWriteLog and "logic_room_match_voice:SetSelfSpeaking self speaking " .. tostring(self.IsSelfSpeaking))
    self.IsSelfSpeaking = inSpeaking
    self.team_is_speaking[tonumber(DataMgr.roleData.uid)] = inSpeaking
    local roomUI = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
    if roomUI and roomUI.UpdateTeamVoiceUI then
      roomUI:UpdateTeamVoiceUI(tonumber(DataMgr.roleData.uid))
      if self:IsMatchRoomOwner() then
        roomUI:UpdateRoomVoiceUI()
      end
    end
  end
end
function logic_room_match_voice:GetIsSelfSpeaking()
  return self.IsSelfSpeaking
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_room_match_voice = class(CModuleBase, nil, logic_room_match_voice)
return Clogic_room_match_voice