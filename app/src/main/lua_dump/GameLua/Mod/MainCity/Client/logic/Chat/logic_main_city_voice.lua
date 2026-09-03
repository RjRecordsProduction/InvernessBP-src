local logic_main_city_voice = {
  eMicType = {
    Close = 0,
    All = 1,
    Team = 2,
    AllInter = 3,
    TeamInter = 4
  },
  eSpkType = {
    Close = 0,
    All = 1,
    Team = 2
  }
}
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local Enum_OperationCompleteCode = logic_chat_voice_const.HDmpveVoiceCompleteCode
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function logic_main_city_voice:DefineAndResetData()
  log(bWriteLog and "logic_main_city_voice:DefineAndResetData")
  self.curMicType = logic_main_city_voice.eMicType.Close
  self.curSpkType = logic_main_city_voice.eSpkType.All
  self.lbsSpeakingStsMap = {}
  self.memberSpeaking = {}
  self.switchCD = 1.1
  self.TLog_MicphoneIns = nil
  self.TLog_MicrophoneTimeStamp = os.time()
  log(bWriteLog and string.format("logic_main_city_voice:DefineAndResetData TLog_MicrophoneTimeStamp[%s]", tostring(self.TLog_MicrophoneTimeStamp)))
  self.TLog_MircophoneIndex = 0
end
function logic_main_city_voice:OnInitialize()
  log(bWriteLog and "logic_main_city_voice:OnInitialize")
end
function logic_main_city_voice:RegistEvents()
  log(bWriteLog and "logic_main_city_voice:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER, self.JoinMainCityVoiceRoom, self, true)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY_PRE, self.QuitMainCityVoiceRoom, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_LBS_SPEAKING, self.OnLbsSpeaking, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_TEAM_SPEAKING, self.OnTeamSpeaking, self)
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local interface = logic_antsvoice_interface:GetGVoiceInterface()
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_JOIN_LBS_ROOM_SUCCESS, self.OnJoinLbsRoomSuccess, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_MICROPHONE, self.RefreshMicStatus, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_SPEAKER, self.RefreshSpkStatus, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_VOICE, self.OnMemberVoice, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, self.SyncSettingFromLobby, self, false, true)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnTeamInfoSync, self)
  if EVENTTYPE_INGAME_BAN then
    self:AddCommonEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_BAN_GLOBAL_MIC, self.OnBanGlobalMic, self)
  else
    log(bWriteLog and "logic_main_city_voice:RegistEvents no ingame event")
  end
end
function logic_main_city_voice:JoinMainCityVoiceRoom(bShowTips)
  log(bWriteLog and "logic_main_city_voice:JoinMainCityVoiceRoom")
  if not self.UpdateMicrophoneTLogTimer then
    self.UpdateMicrophoneTLogTimer = self:AddTimerLoop(30, function()
      self:UpdateVoiceTLogMicrophone()
    end, TIMER_INFINITE, 30)
    log(bWriteLog and "logic_main_city_voice:JoinMainCityVoiceRoom Add UpdateMicrophoneTLogTimer")
  end
  self.TLog_MicrophoneTimeStamp = os.time()
  log(bWriteLog and string.format("logic_main_city_voice:JoinMainCityVoiceRoom TLog_MicrophoneTimeStamp[%s]", tostring(self.TLog_MicrophoneTimeStamp)))
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:JoinLobbyVoiceRoom()
  local game_id = g_game_id
  log(bWriteLog and "logic_main_city_voice:JoinMainCityVoiceRoom game id " .. tostring(game_id))
  self:AddTimerOnce(0.5, function()
    log(bWriteLog and "logic_main_city_voice:JoinMainCityVoiceRoom RefreshStatus")
    self:RefreshMicStatus()
    self:RefreshSpkStatus()
  end)
  if not game_id then
    log(bWriteLog and "logic_main_city_voice:JoinMainCityVoiceRoom: failed due to invalid game_id " .. tostring(game_id))
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local roomID = logic_antsvoice_interface:GetLbsRoomName()
  if tostring(roomID) == tostring(game_id) then
    log(bWriteLog and "logic_main_city_voice:JoinMainCityVoiceRoom duplicate join lbs")
    return
  end
  logic_chat_voice:JoinLbsVoiceRoom(game_id)
  self.lbsRoomID = game_id
  self:SyncSettingFromLobby(bShowTips)
  if self.SelfSpeakingTimer then
    self:RemoveTimer(self.SelfSpeakingTimer)
  end
  self.SelfSpeakingTimer = self:AddTimerLoop(0, function()
    self:SelfSpeakingCheckTick()
  end, TIMER_INFINITE, 0.2)
end
function logic_main_city_voice:JoinWebGameVoiceRoom(eGameType, tableId)
  printf("logic_main_city_voice:JoinWebGameVoiceRoom eGameType:%s, tableId:%s", eGameType, tableId)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id)
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  logic_chat_voice:JoinAntsVoiceRoom(logic_chat_voice_const.Enum_AntsVoiceRoomType.BattleTeam, tableId, self.teamAntsVoiceUrl)
end
function logic_main_city_voice:SetTeamAntsVoiceUrl(antsVoiceUrl)
  log(bWriteLog and "logic_main_city_voice:SetTeamAntsVoiceUrl " .. antsVoiceUrl)
  self.teamAntsVoiceUrl = antsVoiceUrl
end
function logic_main_city_voice:QuitMainCityVoiceRoom()
  log(bWriteLog and "logic_main_city_voice:QuitMainCityVoiceRoom")
  if self.UpdateMicrophoneTLogTimer then
    self:RemoveTimer(self.UpdateMicrophoneTLogTimer)
    self.UpdateMicrophoneTLogTimer = nil
    log(bWriteLog and "logic_main_city_voice:QuitMainCityVoiceRoom Remove UpdateMicrophoneTLogTimer")
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  logic_antsvoice_interface:QuitLbsRoom()
  if self.lbsRoomID then
    local MainCity_VoiceRoomMember_Client = SubsystemMgr:Get("MainCity_VoiceRoomMember_Client")
    if MainCity_VoiceRoomMember_Client then
      MainCity_VoiceRoomMember_Client:Exit_Voice_Room_req(tostring(self.lbsRoomID))
    end
  end
  self.lbsRoomID = nil
  self.bHasSync = nil
  self.lbsSpeakingStsMap = {}
  self.memberSpeaking = {}
  self.IsSelfSpeaking = nil
  if self.SelfSpeakingTimer then
    self:RemoveTimer(self.SelfSpeakingTimer)
  end
  if self:IsInTeam() then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:JoinLobbyVoiceRoom()
  end
  self:RestoreBGM()
end
function logic_main_city_voice:IsInTeam()
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  return logic_team_up.GetTeamNum() > 1
end
function logic_main_city_voice:SyncSettingFromLobby(bShowTips, bForce)
  log(bWriteLog and "logic_main_city_voice:SyncSettingFromLobby")
  if self.bHasSync and not bForce then
    log(bWriteLog and "logic_main_city_voice:SyncSettingFromLobby has sync")
    return
  end
  self.bHasSync = true
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
  local hardwareSwitch1 = logic_chat_voice:GetMicState()
  local softwareSwitch1 = logic_chat_voice:GetSelfRoomMicrophoneState(Enum_AntsVoiceRoomType.LobbyTeam)
  log(bWriteLog and string.format("logic_main_city_voice:SyncSettingFromLobby, hardwareSwitch, softwareSwitch mic:%s, %s", hardwareSwitch1, softwareSwitch1))
  local micSwitch = hardwareSwitch1 and softwareSwitch1
  local hardwareSwitch2 = logic_chat_voice:GetSpeakerState()
  local softwareSwitch2 = logic_chat_voice:GetSelfRoomSpeakerState(Enum_AntsVoiceRoomType.LobbyTeam)
  log(bWriteLog and string.format("logic_main_city_voice:SyncSettingFromLobby, hardwareSwitch, softwareSwitch spk:%s, %s", hardwareSwitch2, softwareSwitch2))
  local spkSwitch = hardwareSwitch2 and softwareSwitch2
  local spkOpenType = self:IsInTeam() and logic_main_city_voice.eSpkType.Team or logic_main_city_voice.eSpkType.All
  local micOpenType = self:IsInTeam() and logic_main_city_voice.eMicType.Team or logic_main_city_voice.eMicType.All
  self:SwitchSpkType(spkSwitch and spkOpenType or logic_main_city_voice.eSpkType.All, false, true)
  self:SwitchMicType(micSwitch and micOpenType or logic_main_city_voice.eMicType.Close, false, true)
  if bShowTips and self:IsInTeam() then
    ShowNotice(656060)
  end
end
function logic_main_city_voice:SyncSettingToLobby()
  log(bWriteLog and "logic_main_city_voice:SyncSettingToLobby")
end
function logic_main_city_voice:OnLbsSpeaking(eventType, eventID, RoomName, member, status)
  log(bWriteLog and "logic_main_city_voice.OnLbsSpeaking member = " .. member .. ", status = " .. status)
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local InMC = Lobby_Main_City_Enter and Lobby_Main_City_Enter.bInMainCity
  if not InMC then
    return
  end
  local uid = self.findUidByMember(member)
  if uid == nil or uid == 0 then
    print(bWriteLog and "logic_main_city_voice.OnLbsSpeaking invalid uid == " .. tostring(uid))
    return
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    self:UpdateBGMSpeaking(uid, status)
  end
  log(bWriteLog and "[dongkaizha] speaking" .. tostring(uid))
  self.lbsSpeakingStsMap[uid] = status
  local ui = UIManager.GetUI(UIManager.UI_Config.MainCity_LobbyPlayer_Popup_UIBP)
  if ui and ui.RefreshAllSpeaking then
    ui:RefreshAllSpeaking()
  end
end
function logic_main_city_voice:OnTeamSpeaking(eventType, eventID, RoomName, member, status)
  log(bWriteLog and "logic_main_city_voice.OnTeamSpeaking member = " .. member .. ", status = " .. status)
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local InMC = Lobby_Main_City_Enter and Lobby_Main_City_Enter.bInMainCity
  if not InMC then
    return
  end
  local uid = self.findUidByMember(member)
  if uid == nil or uid == 0 then
    print(bWriteLog and "logic_main_city_voice.OnTeamSpeaking uid == 0")
    return
  end
  log(bWriteLog and "logic_main_city_voice speaking" .. tostring(uid))
  self.lbsSpeakingStsMap[uid] = status
end
function logic_main_city_voice:OnMemberVoice(_, _, tParam)
  log(bWriteLog and "logic_main_city_voice.OnMemberVoice")
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local InMC = Lobby_Main_City_Enter and Lobby_Main_City_Enter.bInMainCity
  if not InMC then
    return
  end
  if tParam and tParam.uid then
    local uid = tonumber(tParam.uid)
    log(bWriteLog and "logic_main_city_voice.OnMemberVoice uid " .. tostring(uid))
    if uid and uid ~= 0 then
      self.lbsSpeakingStsMap[uid] = tParam.status
    else
      log(bWriteLog and "logic_main_city_voice.OnMemberVoice failed due to nil uid2")
    end
    self:UpdateBGMSpeaking(uid, tParam.status)
    local ui = UIManager.GetUI(UIManager.UI_Config.MainCity_LobbyPlayer_Popup_UIBP)
    if ui and ui.RefreshAllSpeaking then
      ui:RefreshAllSpeaking()
    end
  else
    log(bWriteLog and "logic_main_city_voice.OnMemberVoice failed due to nil uid")
  end
end
function logic_main_city_voice:UpdateBGMSpeaking(uid, status)
  log(bWriteLog and "logic_main_city_voice:UpdateBGMSpeaking uid" .. tostring(uid))
  local bBefore = next(self.memberSpeaking) ~= nil
  uid = tonumber(uid)
  if not uid then
    return
  end
  if status ~= 0 then
    self.memberSpeaking[uid] = status
  else
    self.memberSpeaking[uid] = nil
  end
  local bAfter = next(self.memberSpeaking) ~= nil
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if bBefore ~= bAfter and Lobby_Main_City_Enter.bInMainCity then
    log(bWriteLog and "logic_main_city_voice:OnMemberVoice member voice change bgm " .. tostring(bBefore) .. tostring(bAfter))
    if bAfter then
      self:StopBGM()
    else
      self:RestoreBGM()
    end
  end
end
function logic_main_city_voice:OnJoinLbsRoomSuccess(_, _, room, member)
  log(bWriteLog and string.format("logic_main_city_voice:OnJoinLbsRoomSuccess, room, member:%s, %s", tostring(room), tostring(member)))
  if tostring(room) ~= tostring(self.lbsRoomID) then
    log(bWriteLog and string.format("logic_main_city_voice:OnJoinLbsRoomSuccess skip, room:%s lbsRoomID:%s", tostring(room), tostring(self.lbsRoomID)))
    return
  end
  self:OnJoinLbsRoomNotify(Enum_OperationCompleteCode.JoinRoomSucc, room, member)
end
function logic_main_city_voice:OnJoinLbsRoomNotify(code, room, member)
  log(bWriteLog and string.format("logic_main_city_voice:OnJoinLbsRoomNotify, code, room, member:%s, %s, %s", code, room, member))
  if not GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_main_city_voice:OnJoinLbsRoomNotify skip, not in main city")
    return
  end
  if code == Enum_OperationCompleteCode.JoinRoomSucc then
    local MainCity_VoiceRoomMember_Client = SubsystemMgr:Get("MainCity_VoiceRoomMember_Client")
    if MainCity_VoiceRoomMember_Client then
      MainCity_VoiceRoomMember_Client:Join_Voice_Room_req(tostring(room), member)
    end
    self.lbsJoined = true
    self.lbsMemberID = member
    self:AddTimerOnce(1.5, function()
      self:RefreshMicStatus()
      self:RefreshSpkStatus()
    end)
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:EnableReportALLAbroad(true, true, 20000)
  end
end
function logic_main_city_voice:OnQuitLbsRoomNotify(code, room, member, voiceurl, record_data)
  log(bWriteLog and string.format("logic_main_city_voice:OnQuitLbsRoomNotify, code, room, member, url, records:%s, %s, %s, %s, %s", code, room, member, voiceurl, record_data))
  if code == Enum_OperationCompleteCode.QuitRoomSucc then
    local MainCity_VoiceRoomMember_Client = SubsystemMgr:Get("MainCity_VoiceRoomMember_Client")
    if MainCity_VoiceRoomMember_Client then
      MainCity_VoiceRoomMember_Client:Exit_Voice_Room_req(tostring(room))
    end
    self.lbsSpeakingStsMap = {}
    self.lbsJoined = false
  end
end
function logic_main_city_voice:OnJoinRoomNotify(code, room, member)
  log(bWriteLog and string.format("logic_main_city_voice:OnJoinRoomNotify, code, room, member:%s, %s, %s", tostring(code), room, member))
  if code == Enum_OperationCompleteCode.JoinRoomSucc then
    self:AddTimerOnce(0.5, function()
      self:RefreshMicStatus()
      self:RefreshSpkStatus()
    end)
  end
end
function logic_main_city_voice:OnQuitRoomNotify(code, room, member, voiceurl, record_data)
  log(bWriteLog and "logic_main_city_voice:OnQuitRoomNotify")
  if code == Enum_OperationCompleteCode.QuitRoomSucc then
    self:AddTimerOnce(0.5, function()
      self:RefreshMicStatus()
      self:RefreshSpkStatus()
    end)
  end
end
function logic_main_city_voice:OnBanGlobalMic(_, __, bBan)
  log(bWriteLog and "logic_main_city_voice:OnBanGlobalMic " .. tostring(bBan))
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local InMC = Lobby_Main_City_Enter and Lobby_Main_City_Enter.bInMainCity
  if not InMC then
    return
  end
  if bBan then
    local banTime = self:IsVoiceBan()
    local micType = self.curMicType or 1
    if banTime and (micType == logic_main_city_voice.eMicType.All or micType == logic_main_city_voice.eMicType.AllInter) then
      log(bWriteLog and "logic_main_city_voice:OnBanGlobalMic banned to " .. tostring(banTime))
      local TimeUtil = require("client.common.time_util")
      local endTimeString = TimeUtil.FormatTime_YMDHMS(banTime, false)
      local newMicType = logic_main_city_voice.eMicType.Close
      self:SwitchMicType(newMicType)
      ShowNotice(LocUtil.LocalizeResFormat(508072, endTimeString))
      return
    end
  end
end
function logic_main_city_voice:GetSpeaking(uid)
  if not uid then
    return false
  end
  if self.lbsSpeakingStsMap[uid] ~= nil and self.lbsSpeakingStsMap[uid] ~= 0 then
    return true
  end
  return false
end
function logic_main_city_voice:RefreshSpkStatus()
  log(bWriteLog and "logic_main_city_voice:RefreshSpkStatus")
  local GVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if not slua.isValid(GVoiceInterface) then
    return
  end
  local bIsTeamSpeakerEnable = GVoiceInterface:TeamSpeakerEnable()
  local bIsLbsSpeakerEnable = GVoiceInterface:LbsSpeakerEnable()
  if not bIsTeamSpeakerEnable and not bIsLbsSpeakerEnable then
    self.curSpkType = logic_main_city_voice.eSpkType.Close
  elseif bIsTeamSpeakerEnable and not bIsLbsSpeakerEnable then
    if self:IsInTeam() then
      self.curSpkType = logic_main_city_voice.eSpkType.Team
    else
      self.curSpkType = logic_main_city_voice.eSpkType.Close
    end
    local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
    local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
    local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
    local roomType, roomName = logic_chat_voice_data_manager:GetSDKCurTeamRoomInfo()
    if roomType == Enum_AntsVoiceRoomType.LobbyChatRoom then
      self.curSpkType = logic_main_city_voice.eSpkType.Close
    end
  elseif not bIsTeamSpeakerEnable and bIsLbsSpeakerEnable then
  else
    self.curSpkType = logic_main_city_voice.eSpkType.All
  end
  local chatUI = UIManager.GetUI(UIManager.UI_Config.MainCity_Chat_UIBP)
  if chatUI then
    chatUI:UpdateSpeakerUI()
  end
  log(bWriteLog and "logic_main_city_voice:RefreshSpkStatus " .. tostring(self.curSpkType))
end
function logic_main_city_voice:SwitchSpkType(spkType, syncToLobby, bForce)
  log(bWriteLog and "logic_main_city_voice:SwitchSpkType" .. tostring(spkType))
  if not bForce then
    if spkType == self.curSpkType then
      log(bWriteLog and "logic_main_city_voice:SwitchSpkType skip same")
      return
    end
    if self.bSwitchSpkTimer then
      log(bWriteLog and "logic_main_city_voice:SwitchSpkType skip time")
      ShowNotice(100140005)
      return
    else
      self.bSwitchSpkTimer = self:AddTimerOnce(self.switchCD, function()
        self.bSwitchSpkTimer = nil
      end)
    end
  end
  spkType = spkType or 1
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if spkType == logic_main_city_voice.eSpkType.All then
    logic_antsvoice_interface:OpenAllSpeaker()
  elseif spkType == logic_main_city_voice.eSpkType.Team then
    if self:IsInTeam() == false then
      log(bWriteLog and "logic_main_city_voice:SwitchSpkType warning: team mode without team")
      logic_antsvoice_interface:OpenAllSpeaker()
      spkType = logic_main_city_voice.eSpkType.All
    end
    logic_antsvoice_interface:OpenTeamSpeakerOnly()
  elseif spkType == logic_main_city_voice.eSpkType.Close then
    logic_antsvoice_interface:CloseAllSpeaker()
  end
  self.curSpkType = spkType
  if syncToLobby ~= false then
    self:SyncSettingToLobby()
  end
  self:RefreshSpkStatus()
end
function logic_main_city_voice:IsVoiceBan()
  local TimeUtil = require("client.common.time_util")
  local UTCTime = TimeUtil.GetServerTimeInSec()
  local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
  local banTime = ClientBanLogic.VoiceBanEndTime
  if banTime and UTCTime and UTCTime < banTime then
    return banTime
  end
  local VoiceReportSubsystem = SubsystemMgr:Get("VoiceReportSubsystem")
  if VoiceReportSubsystem then
    local PLAYER_BAN_GLOBAL_MI = require("client.slua.config.ClientMacros.BanMacro").PLAYER_BAN_GLOBAL_MI
    local BanEndTime = VoiceReportSubsystem:CheckBanEndTime(PLAYER_BAN_GLOBAL_MI)
    if BanEndTime and 0 < BanEndTime then
      local TimeUtil = require("client.common.time_util")
      local UTCTime = TimeUtil.GetServerTimeInSec()
      local banTime = VoiceReportSubsystem.GlobalMicBanEndTime
      if banTime and UTCTime and UTCTime < banTime then
        return banTime
      end
    end
  end
end
function logic_main_city_voice:UpdateVoiceTLogMicrophone()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    log(bWriteLog and "logic_main_city_voice:UpdateVoiceTLogMicrophone uPlayerState invalid")
    return
  end
  local CurrentTime = os.time()
  local MicDeltaTime = CurrentTime - self.TLog_MicrophoneTimeStamp
  if MicDeltaTime < 0 then
    MicDeltaTime = 0
  end
  if self.TLog_MircophoneIndex == logic_main_city_voice.eMicType.Team and uPlayerState.TeammateMicrophoneTime then
    uPlayerState.TeammateMicrophoneTime = MicDeltaTime + uPlayerState.TeammateMicrophoneTime
    log(bWriteLog and string.format("logic_main_city_voice:UpdateVoiceTLogMicrophone MicDeltaTime[%s] TeammateMicrophoneTime[%s] update", tostring(MicDeltaTime), tostring(uPlayerState.TeammateMicrophoneTime)))
    self:RecordMicphoneTlogToServer()
  elseif self.TLog_MircophoneIndex == logic_main_city_voice.eMicType.All and uPlayerState.EnemyMicrophoneTime then
    uPlayerState.EnemyMicrophoneTime = MicDeltaTime + uPlayerState.EnemyMicrophoneTime
    log(bWriteLog and string.format("logic_main_city_voice:UpdateVoiceTLogMicrophone MicDeltaTime[%s] EnemyMicrophoneTime[%s] update", tostring(MicDeltaTime), tostring(uPlayerState.EnemyMicrophoneTime)))
    self:RecordMicphoneTlogToServer()
  else
    log(bWriteLog and string.format("logic_main_city_voice:UpdateVoiceTLogMicrophone TLog_MircophoneIndex[%s]", tostring(self.TLog_MircophoneIndex)))
  end
  self.TLog_MicrophoneTimeStamp = CurrentTime
  log(bWriteLog and string.format("logic_main_city_voice:UpdateVoiceTLogMicrophone TLog_MicrophoneTimeStamp[%s] update", tostring(self.TLog_MicrophoneTimeStamp)))
end
function logic_main_city_voice:RecordMicphoneTlogToServer()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    log(bWriteLog and "logic_main_city_voice:RecordMicphoneTlogToServer uPlayerController invalid")
    return
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    log(bWriteLog and "logic_main_city_voice:RecordMicphoneTlogToServer uPlayerState invalid")
    return
  end
  if not uPlayerState.TeammateMicrophoneTime then
    log(bWriteLog and "logic_main_city_voice:RecordMicphoneTlogToServer TeammateMicrophoneTime invalid")
    return
  end
  if not slua.isValid(self.TLog_MicphoneIns) then
    local TLog_Micphone = import("TLog_Micphone")
    self.TLog_MicphoneIns = TLog_Micphone()
  end
  self.TLog_MicphoneIns.TeammateMicrophoneTime = uPlayerState.TeammateMicrophoneTime
  self.TLog_MicphoneIns.EnemyMicrophoneTime = uPlayerState.EnemyMicrophoneTime
  log(bWriteLog and string.format("logic_main_city_voice:RecordMicphoneTlogToServer TeammateMicrophoneTime[%s] EnemyMicrophoneTime[%s]", tostring(self.TLog_MicphoneIns.TeammateMicrophoneTime), tostring(self.TLog_MicphoneIns.EnemyMicrophoneTime)))
  uPlayerController:RPC_Server_SetMicphoneTLogToServer(self.TLog_MicphoneIns)
end
function logic_main_city_voice:SetVoiceTLogMicrophone(SetIndex)
  if SetIndex == self.TLog_MircophoneIndex then
    log(bWriteLog and "logic_main_city_voice:SetVoiceTLogMicrophone same index")
    return
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    log(bWriteLog and "logic_main_city_voice:SetVoiceTLogMicrophone uPlayerState invalid")
    return
  end
  local CurrentTime = os.time()
  local DeltaTime = CurrentTime - self.TLog_MicrophoneTimeStamp
  if DeltaTime < 0 then
    DeltaTime = 0
  end
  if self.TLog_MircophoneIndex == logic_main_city_voice.eMicType.Team and uPlayerState.TeammateMicrophoneTime then
    uPlayerState.TeammateMicrophoneTime = uPlayerState.TeammateMicrophoneTime + DeltaTime
    log(bWriteLog and string.format("logic_main_city_voice:SetVoiceTLogMicrophone DeltaTime[%s] TeammateMicrophoneTime[%s] update", tostring(DeltaTime), tostring(uPlayerState.TeammateMicrophoneTime)))
    self:RecordMicphoneTlogToServer()
  elseif self.TLog_MircophoneIndex == logic_main_city_voice.eMicType.All and uPlayerState.EnemyMicrophoneTime then
    uPlayerState.EnemyMicrophoneTime = uPlayerState.EnemyMicrophoneTime + DeltaTime
    log(bWriteLog and string.format("logic_main_city_voice:SetVoiceTLogMicrophone DeltaTime[%s] EnemyMicrophoneTime[%s] update", tostring(DeltaTime), tostring(uPlayerState.EnemyMicrophoneTime)))
    self:RecordMicphoneTlogToServer()
  end
  self.TLog_MircophoneIndex = SetIndex
  self.TLog_MicrophoneTimeStamp = CurrentTime
  log(bWriteLog and string.format("logic_main_city_voice:SetVoiceTLogMicrophone TLog_MircophoneIndex[%s] TLog_MicrophoneTimeStamp[%s]", tostring(self.TLog_MircophoneIndex), tostring(self.TLog_MicrophoneTimeStamp)))
end
function logic_main_city_voice:RefreshMicStatus()
  log(bWriteLog and "logic_main_city_voice:RefreshMicStatus")
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if logic_antsvoice_interface:IsInterphoneMode() then
    local bIsTeamInterphoneOpenned = logic_antsvoice_interface:IsTeamInterphoneOpenned()
    local bIsLbsInterphoneOpenned = logic_antsvoice_interface:IsLbsInterphoneOpenned()
    if not bIsTeamInterphoneOpenned and not bIsLbsInterphoneOpenned then
    elseif bIsTeamInterphoneOpenned and not bIsLbsInterphoneOpenned then
      self.curMicType = logic_main_city_voice.eMicType.TeamInter
    elseif not bIsTeamInterphoneOpenned and bIsLbsInterphoneOpenned then
    else
      self.curMicType = logic_main_city_voice.eMicType.AllInter
    end
  else
    local bIsTeamMicphoneEnable = logic_antsvoice_interface:TeamMicphoneEnable()
    local bIsLbsMicphoneEnable = logic_antsvoice_interface:LbsMicphoneEnable()
    if not bIsTeamMicphoneEnable and not bIsLbsMicphoneEnable then
      self.curMicType = logic_main_city_voice.eMicType.Close
    elseif bIsTeamMicphoneEnable and not bIsLbsMicphoneEnable then
      if self:IsInTeam() then
        self.curMicType = logic_main_city_voice.eMicType.Team
      else
        self.curMicType = logic_main_city_voice.eMicType.Close
      end
      local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
      local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
      local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
      local roomType, roomName = logic_chat_voice_data_manager:GetSDKCurTeamRoomInfo()
      if roomType == Enum_AntsVoiceRoomType.LobbyChatRoom then
        self.curMicType = logic_main_city_voice.eMicType.Close
      end
    elseif not bIsTeamMicphoneEnable and bIsLbsMicphoneEnable then
      self.curMicType = logic_main_city_voice.eMicType.All
      if self:IsInTeam() then
        log(bWriteLog and "logic_main_city_voice:RefreshMicStatus All mode but not in team voice")
      end
    else
      self.curMicType = logic_main_city_voice.eMicType.All
    end
  end
  local chatUI = UIManager.GetUI(UIManager.UI_Config.MainCity_Chat_UIBP)
  if chatUI then
    chatUI:UpdateMicrophoneUI()
  end
  log(bWriteLog and "logic_main_city_voice:RefreshMicStatus SetVoiceTLogMicrophone")
  self:SetVoiceTLogMicrophone(self.curMicType)
  log(bWriteLog and "logic_main_city_voice:RefreshMicStatus " .. tostring(self.curMicType))
end
function logic_main_city_voice:SwitchMicType(micType, syncToLobby, bForce)
  log(bWriteLog and "logic_main_city_voice:SwitchMicType to " .. tostring(micType))
  if not bForce then
    if micType == self.curMicType then
      log(bWriteLog and "logic_main_city_voice:SwitchMicType skip same")
      return
    end
    if self.bSwitchMicTimer then
      log(bWriteLog and "logic_main_city_voice:SwitchMicType skip time")
      ShowNotice(100140005)
      return
    else
      self.bSwitchMicTimer = self:AddTimerOnce(self.switchCD, function()
        self.bSwitchMicTimer = nil
      end)
    end
  end
  micType = micType or 1
  if micType == logic_main_city_voice.eMicType.All or micType == logic_main_city_voice.eMicType.AllInter then
    local banTime = self:IsVoiceBan()
    if banTime then
      log(bWriteLog and "logic_main_city_voice:SwitchMicType banned to " .. tostring(banTime))
      local TimeUtil = require("client.common.time_util")
      local endTimeString = TimeUtil.FormatTime_YMDHMS(banTime, false)
      ShowNotice(LocUtil.LocalizeResFormat(508072, endTimeString))
      return
    end
  end
  if micType == logic_main_city_voice.eMicType.Close then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:CloseAllMicphone()
    self.curMicType = micType
    log(bWriteLog and "logic_main_city_voice:SwitchMicType SetVoiceTLogMicrophone")
    self:SetVoiceTLogMicrophone(self.curMicType)
    if syncToLobby ~= false then
      self:SyncSettingToLobby()
    end
    return
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local EUChatRestriction = logic_chat_voice:CheckEUChatRestriction()
  if EUChatRestriction then
    ShowNotice(4377)
  end
  logic_chat_voice:RequestPrivacy(function()
    self:SwitchVoiceTypeImpl(micType)
    if syncToLobby ~= false then
      self:SyncSettingToLobby()
    end
  end, 4073)
end
function logic_main_city_voice:SwitchVoiceTypeImpl(micType)
  log(bWriteLog and "logic_main_city_voice:SwitchVoiceTypeImpl" .. tostring(micType))
  local UIUtil = require("client.common.ui_util")
  local uAntsVoiceInterface = UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
  if not uAntsVoiceInterface then
    micType = logic_main_city_voice.eMicType.Close
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if micType == logic_main_city_voice.eMicType.All then
    logic_antsvoice_interface:OpenAllMicphone()
    if not self.lbsJoined then
      log(bWriteLog and "logic_main_city_voice:SwitchVoiceTypeImp warning: lbs not joined")
    end
  elseif micType == logic_main_city_voice.eMicType.Team then
    if self:IsInTeam() == false then
      log(bWriteLog and "logic_main_city_voice:SwitchVoiceTypeImp warning: team mode without team")
      logic_antsvoice_interface:OpenAllMicphone()
      micType = logic_main_city_voice.eMicType.All
    end
    logic_antsvoice_interface:OpenTeamMicphoneOnly()
  elseif micType == logic_main_city_voice.eMicType.AllInter then
    uAntsVoiceInterface:OpenAllInterphone()
  elseif micType == logic_main_city_voice.eMicType.TeamInter then
    if self:IsInTeam() == false then
      log(bWriteLog and "logic_main_city_voice:SwitchVoiceTypeImp warning: team mode without team")
      uAntsVoiceInterface:OpenAllInterphone()
      micType = logic_main_city_voice.eMicType.AllInter
    end
    uAntsVoiceInterface:OpenTeamInterphone()
  end
  self:RefreshMicStatus()
end
function logic_main_city_voice.findUidByMember(lbsMemberId)
  print(bWriteLog and "logic_main_city_voice.findUidByMember lbsMemberId = " .. tostring(lbsMemberId) .. " room " .. tostring(g_game_id))
  local result = 0
  if SubsystemMgr then
    local MainCity_VoiceRoomMember_Client = SubsystemMgr:Get("MainCity_VoiceRoomMember_Client")
    if MainCity_VoiceRoomMember_Client then
      local room_id = g_game_id and tostring(g_game_id) or ""
      result = MainCity_VoiceRoomMember_Client:GetMemberUid(room_id, lbsMemberId, true)
    else
      log(bWriteLog and "logic_main_city_voice.findUidByMember:Failed to get MainCity_VoiceRoomMember_Client")
    end
  else
    log(bWriteLog and "logic_main_city_voice.findUidByMember:Failed to get SubsystemMgr")
  end
  return tonumber(result)
end
function logic_main_city_voice:GetPlayerVolume(uid)
  log(bWriteLog and "logic_main_city_voice:GetPlayerVolume " .. tostring(uid))
  local result = 100
  uid = tonumber(uid)
  local GameState = slua_GameFrontendHUD:GetGameState()
  if not GameState then
    log(bWriteLog and "logic_main_city_voice:SetPlayerVolume no GameState")
    return result
  end
  local PlayerState = slua.isValid(GameState) and GameState:GetPlayerStateByUID(uid)
  if not PlayerState or not slua.isValid(PlayerState) then
    log(bWriteLog and "logic_main_city_voice:SetPlayerVolume no PlayerState for uid" .. tostring(uid))
    return result
  end
  local UIUtil = require("client.common.ui_util")
  local GVoiceInterface = UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
  if not slua.isValid(GVoiceInterface) then
    log(bWriteLog and "PlanPH_PlayerList_Item_UIBP:SetSDKVolume no GVoiceInterface")
    return 100
  end
  result = GVoiceInterface:GetPlayerVolume(PlayerState.OpenID)
  return result
end
function logic_main_city_voice:SetPlayerVolume(uid, volume)
  log(bWriteLog and "logic_main_city_voice:SetPlayerVolume " .. tostring(uid) .. " to" .. tostring(volume))
  uid = tonumber(uid)
  if not uid then
    log(bWriteLog and "logic_main_city_voice:SetPlayerVolume failed due to invalid uid")
    return
  end
  local GameState = slua_GameFrontendHUD:GetGameState()
  local PlayerState = GameState:GetPlayerStateByUID(uid)
  if not slua.isValid(PlayerState) then
    log(bWriteLog and "logic_main_city_voice:SetPlayerVolume no PlayerState for uid" .. tostring(volume))
    return
  end
  local UIUtil = require("client.common.ui_util")
  local GVoiceInterface = UIUtil.GetGameFrontendHUD():GetVoiceSDKInterface()
  if not slua.isValid(GVoiceInterface) then
    log(bWriteLog and "PlanPH_PlayerList_Item_UIBP:SetSDKVolume no GVoiceInterface")
    return
  end
  GVoiceInterface:SetPlayerVolume(PlayerState.OpenID, volume)
end
function logic_main_city_voice:RestoreBGM()
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
function logic_main_city_voice:StopBGM()
  local audio_util = require("client.common.audio_util")
  audio_util.SetRTPCValue("VolumeControl_Music", 20, 200)
  audio_util.SetRTPCValue("MusicPlayer_Volume", 0.2, 200)
end
function logic_main_city_voice:SetIsTalkingInterphone(bIsTalking)
  self.bIsTalkingInterphone = bIsTalking
end
function logic_main_city_voice:OnTeamInfoSync()
  log(bWriteLog and "logic_main_city_voice:OnTeamInfoSync")
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter and Lobby_Main_City_Enter.bInMainCity then
    local bInTeam = self:IsInTeam()
    if not bInTeam and self.curMicType == logic_main_city_voice.eMicType.Team or self.curMicType == logic_main_city_voice.eMicType.TeamInter then
      self:SwitchMicType(0)
    end
    if not bInTeam and self.curSpkType == logic_main_city_voice.eSpkType.Team then
      self:SwitchSpkType(0)
    end
    self:AddTimerOnce(1, function()
      self:RefreshMicStatus()
      self:RefreshSpkStatus()
    end)
  end
end
function logic_main_city_voice:SelfSpeakingCheckTick()
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if not Lobby_Main_City_Enter or not Lobby_Main_City_Enter.bInMainCity then
    return
  end
  if self.curMicType == logic_main_city_voice.eMicType.Close then
    return
  end
  if (self.curMicType == logic_main_city_voice.eMicType.AllInter or self.curMicType == logic_main_city_voice.eMicType.TeamInter) and not self.bIsTalkingInterphone then
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local interface = logic_antsvoice_interface:GetGVoiceInterface()
  local oldSelfSpeaking = self.IsSelfSpeaking
  if interface:IsSpeaking() then
    self.IsSelfSpeaking = true
  else
    self.IsSelfSpeaking = false
  end
  if oldSelfSpeaking ~= self.IsSelfSpeaking then
    log(bWriteLog and "logic_main_city_voice:SelfSpeakingCheckTick self speaking " .. tostring(self.IsSelfSpeaking))
    local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
    local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
    local curRoomID = logic_chat_voice_data_manager:GetRoomIDByRoomType(curRoomType)
    local Enum_AntsVoiceRoomType = require("client.slua.logic.chat_voice.logic_chat_voice_const").Enum_AntsVoiceRoomType
    if curRoomType == Enum_AntsVoiceRoomType.BattleTeam then
      self.IsSelfSpeaking = false
    end
    local tParam = {}
    tParam.roomType = curRoomType
    tParam.roomID = curRoomID
    tParam.uid = tonumber(DataMgr.roleData.uid)
    tParam.status = self.IsSelfSpeaking and 2 or 0
    tParam.state = logic_chat_voice_data_manager:GetSelfStateByRoomID(curRoomID)
    tParam.memberID = self.lbsMemberID or 0
    EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_VOICE, tParam)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_main_city_voice)