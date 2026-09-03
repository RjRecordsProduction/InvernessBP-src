local VoiceChatSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TableUtil = require("common.table_util")
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local EMicMode = logic_chat_voice_const.Enum_InGameMicMode
local STTSAvailableLangs = {
  logic_chat_voice_const.LangToLangID.en,
  logic_chat_voice_const.LangToLangID.ar,
  logic_chat_voice_const.LangToLangID.zh,
  logic_chat_voice_const.LangToLangID["zh-HK"]
}
local ComplaintConfig = require("client.slua.umg.complaint.complaint_config")
function VoiceChatSubsystem:_DataDefine()
  return {
    TextVoiceID = 49646,
    bIsPreTeamSpeaker = false,
    bOnChatPrivacyAccepted = false,
    bSpeakerSettingPanelOpen = false,
    bMicphoneSettingPanelOpen = false,
    MicMode = 0
  }
end
function VoiceChatSubsystem:_PostConstruct()
  print(bWriteLog and "VoiceChatSubsystem:_PostConstruct")
  self.LastVolumn = {}
  self.SamePreTeam = {}
  self.ID2NameMap = {}
  self.WannaShowVolume = {}
  self.ID2OpenID = {}
  self._STTClipCache = {}
  self._BlockVoice = false
end
function VoiceChatSubsystem:OnRegister()
  print(bWriteLog and "VoiceChatSubsystem:OnRegister")
  self:AddCommonEvent(EVENTTYPE_PLAYER_STATE_INFO, EVENTID_PRETEAM_CHAT_CHANGE, self.OnPreTeamChatChange, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_JOIN_TEAM_ROOM_SUCCESS, self.OnJoinVoiceSuccess, self)
  self:AddCommonEvent(EVENTTYPE_COMPLAINT, EVENTID_SUBMIT_COMPLAINT, self.OnPlayerSubmitComplaint, self)
  GameplayData.AddPlayerControllerEvent(self, nil, "OnRepTeammateChange", self.RefreshTeammateList, self)
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if slua.isValid(uAntsVoiceInterface) then
    self:AddControlEvent(uAntsVoiceInterface, "OnSpeechTranslateCallback", self.OnSTTSMessageCallBack, self)
    self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_UPLOAD_FILE_NOTIFY, self.OnSTTAudioUploadFileNotify, self)
  end
end
function VoiceChatSubsystem:OnInit()
  local SuperData = GameplayData.GetSuperData()
  self:AddDataListener(SuperData, "CharacterDataReady", function()
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) and not PlayerController:IsObserver() and not PlayerController:IsHawkEyeSpectator() then
      self:AddControlEvent(PlayerController, "OnPlayerEnterFlying", self.HandleOnEnterFlaying, self)
      local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
      logic_chat_voice_doctor:AddJoinTeamRoomStep(0)
      self:JoinBattleVoiceRoom()
      self:JoinLbsVoiceRoom()
    end
  end)
end
function VoiceChatSubsystem:HandleOnEnterFlaying()
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:CheckJoinTeamFlow()
end
function VoiceChatSubsystem:JoinBattleVoiceRoom()
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(100)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:QuitAntsVoiceRoom(logic_chat_voice_const.Enum_AntsVoiceRoomType.LobbyTeam)
  local battleAntsVoiceRoomParam = logic_chat_voice:GetBattleAntsVoiceRoomParam()
  log_tree(bWriteLog and "VoiceChatSubsystem:JoinBattleVoiceRoom battleAntsVoiceRoomParam:", battleAntsVoiceRoomParam)
  if battleAntsVoiceRoomParam.voiceRoomId == nil or battleAntsVoiceRoomParam.voiceRoomId == "" then
    logic_chat_voice_doctor:AddJoinTeamRoomStep(104)
    log(bWriteLog and "VoiceChatSubsystem:JoinBattleVoiceRoom voiceRoomId Is Nill")
    return false
  end
  log(bWriteLog and "VoiceChatSubsystem:JoinBattleVoiceRoom new enter room rule")
  logic_chat_voice:JoinAntsVoiceRoom(logic_chat_voice_const.Enum_AntsVoiceRoomType.BattleTeam, battleAntsVoiceRoomParam.voiceRoomId, battleAntsVoiceRoomParam.antsVoiceUrl)
  return true
end
function VoiceChatSubsystem:JoinLbsVoiceRoom()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local globalAntsVoiceRoomParam = logic_chat_voice:GetGlobalAntsVoiceRoomParam()
  log_tree(bWriteLog and " VoiceChatSubsystem:JoinLbsVoiceRoom globalAntsVoiceRoomParam:", globalAntsVoiceRoomParam)
  if globalAntsVoiceRoomParam.voiceRoomId == nil then
    log(bWriteLog and "VoiceChatSubsystem:JoinLbsVoiceRoom voiceRoomId Is Nill")
    return false
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local Enum_VoiceRoomStatus = logic_chat_voice_const.Enum_VoiceRoomStatus
  local LBSRoomName = logic_antsvoice_interface:GetLbsRoomName()
  local LBSStatus = logic_antsvoice_interface:GetRoomStatus(LBSRoomName)
  if LBSStatus == Enum_VoiceRoomStatus.RoomStatus_Joined or LBSStatus == Enum_VoiceRoomStatus.RoomStatus_Joining or LBSStatus == Enum_VoiceRoomStatus.RoomStatus_Quiting then
    print(bWriteLog and "VoiceChatSubsystem:JoinLbsVoiceRoom Is In LBSRoom")
    return false
  end
  log(bWriteLog and "VoiceChatSubsystem:JoinLbsVoiceRoom new enter room rule")
  logic_chat_voice:SetAntsVoiceServerInfo(globalAntsVoiceRoomParam.antsVoiceUrl)
  logic_chat_voice:JoinLbsVoiceRoom(globalAntsVoiceRoomParam.voiceRoomId)
  return true
end
function VoiceChatSubsystem:CheckReJoinTeamRoom()
  print(bWriteLog and "VoiceChatSubsystem:CheckReJoinTeamRoom BEGIN")
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local battleAntsVoiceRoomParam = logic_chat_voice:GetBattleAntsVoiceRoomParam()
  local TeamRoomID = battleAntsVoiceRoomParam.voiceRoomId
  if TeamRoomID == nil or TeamRoomID == "" then
    print(bWriteLog and "VoiceChatSubsystem:CheckReJoinTeamRoom TeamRoomID Empty")
    return
  end
  local bIsInTeamRoom = logic_chat_voice:CheckIsInAntsVoiceRoom(logic_chat_voice_const.Enum_AntsVoiceRoomType.BattleTeam, TeamRoomID)
  if bIsInTeamRoom then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    local Enum_VoiceRoomStatus = logic_chat_voice_const.Enum_VoiceRoomStatus
    local VoiceTeamRoomStatus = logic_antsvoice_interface:GetRoomStatus(TeamRoomID)
    if VoiceTeamRoomStatus == Enum_VoiceRoomStatus.RoomStatus_Joined or VoiceTeamRoomStatus == Enum_VoiceRoomStatus.RoomStatus_Joining or VoiceTeamRoomStatus == Enum_VoiceRoomStatus.RoomStatus_Quiting then
      print(bWriteLog and "VoiceChatSubsystem:CheckReJoinTeamRoom Is In TeamRoom")
      return
    end
  end
  logic_chat_voice:ReconnectRoom()
end
function VoiceChatSubsystem:OnJoinVoiceSuccess()
  self:InitReceiverStatus()
  local SuperData = self:GetSuperData()
  SuperData.MicMode = self:GetCurrentMicMode()
  self:OnPreTeamChatChange()
  self:PopupChatPolicyNotification()
end
function VoiceChatSubsystem:GetCurrentMicMode()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local bLastMicPreTeam = SettingModule:GetOptionValue("bLastMicPreTeam")
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if logic_antsvoice_interface:IsInterphoneMode() then
    local bIsTeamInterphoneOpenned = logic_antsvoice_interface:IsTeamInterphoneOpenned()
    local bIsLbsInterphoneOpenned = logic_antsvoice_interface:IsLbsInterphoneOpenned()
    if bIsTeamInterphoneOpenned and not bIsLbsInterphoneOpenned then
      if bLastMicPreTeam then
        return EMicMode.PTT_PreTeam
      else
        return EMicMode.PTT_Team
      end
    else
      return EMicMode.PTT_ALL
    end
  else
    local bIsTeamMicphoneEnable = logic_antsvoice_interface:TeamMicphoneEnable()
    local bIsLbsMicphoneEnable = logic_antsvoice_interface:LbsMicphoneEnable()
    if not bIsTeamMicphoneEnable and not bIsLbsMicphoneEnable then
      return EMicMode.OFF
    elseif bIsTeamMicphoneEnable and not bIsLbsMicphoneEnable then
      if bLastMicPreTeam then
        return EMicMode.OpenMic_PreTeam
      else
        return EMicMode.OpenMic_Team
      end
    else
      return EMicMode.OpenMic_ALL
    end
  end
end
function VoiceChatSubsystem:SwitchMicMode(MicMode)
  print(bWriteLog and "SetPreTeamState:SetPreTeamState ", MicMode)
  local ChannelMode = EMicMode.GetChannelMode(MicMode)
  if ChannelMode == EMicMode.ALL then
    self:JoinLbsVoiceRoom()
  end
  if ChannelMode == EMicMode.Team or ChannelMode == EMicMode.PreTeam then
    self:CheckReJoinTeamRoom()
  end
  self:SetPreTeamState(ChannelMode == EMicMode.PreTeam)
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if MicMode == EMicMode.OFF then
    logic_antsvoice_interface:CloseAllMicphone()
  elseif MicMode == EMicMode.OpenMic_ALL then
    logic_antsvoice_interface:OpenAllMicphone()
  elseif MicMode == EMicMode.OpenMic_PreTeam or MicMode == EMicMode.OpenMic_Team then
    logic_antsvoice_interface:OpenTeamMicphoneOnly()
  elseif MicMode == EMicMode.PTT_ALL then
    logic_antsvoice_interface:OpenAllInterphone()
  elseif MicMode == EMicMode.PTT_PreTeam or MicMode == EMicMode.PTT_Team then
    logic_antsvoice_interface:OpenTeamInterphone()
  end
  local SuperData = self:GetSuperData()
  SuperData.end
function VoiceChatSubsystem:SetPreTeamState(bIsPreTeam)
  print(bWriteLog and "SetPreTeamState:SetPreTeamState ", bIsPreTeam)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    print(bWriteLog and "SetPreTeamState:SetPreTeamState Failed Case PlayerState")
    return
  end
  local PreTeamChatState = PlayerState.PreTeamChatState
  if bIsPreTeam and PreTeamChatState <= 1 then
    PreTeamChatState = PreTeamChatState + 2
    PlayerState:RPC_ChangeOnlyTeamChat(PreTeamChatState)
  elseif not bIsPreTeam and 2 <= PreTeamChatState then
    PreTeamChatState = PreTeamChatState - 2
    PlayerState:RPC_ChangeOnlyTeamChat(PreTeamChatState)
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  SettingModule:SetOptionValue("bLastMicPreTeam", bIsPreTeam == true)
end
function VoiceChatSubsystem:TempBlockVoice(bClose)
  if bClose then
    self._LastMicMode_TempBlock = self:GetSuperData().MicMode
    self:SwitchMicMode(EMicMode.OFF)
    local AntsVoiceInterface_CPP = slua_GameFrontendHUD:GetVoiceSDKInterface()
    AntsVoiceInterface_CPP:CloseVoiceSpeaker()
  elseif self._LastMicMode_TempBlock then
    self:SwitchMicMode(self._LastMicMode_TempBlock)
    self._LastMicMode_TempBlock = nil
    local AntsVoiceInterface_CPP = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if AntsVoiceInterface_CPP:TeamSpeakerEnable() then
      AntsVoiceInterface_CPP:OpenVoiceSpeaker()
    end
  end
end
function VoiceChatSubsystem:CheckPreTeamChatOpen()
  if not LobbySystem.CheckOpen(BP_ENUM_PRETEAMUP_CHAT) then
    print(bWriteLog and "VoiceChatSubsystem:CheckPreTeamChatOpen False Case LobbyOpen")
    return false
  else
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) and uPlayerState.PreTeamID == 0 then
      print(bWriteLog and "VoiceChatSubsystem:CheckPreTeamChatOpen False Case PreTeamID 0")
      return false
    end
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    local bIsOpen = false
    local preTeamUpChat = SettingModule:GetOptionValue("preTeamUpChat")
    if preTeamUpChat then
      bIsOpen = preTeamUpChat == 1
    else
      bIsOpen = LobbySystem.roleData.social_private_data[4] == 1
    end
    if bIsOpen then
      print(bWriteLog and "VoiceChatSubsystem:CheckPreTeamChatOpen Suc")
      return true
    else
      print(bWriteLog and "VoiceChatSubsystem:CheckPreTeamChatOpen False Case No Open")
      return false
    end
  end
end
function VoiceChatSubsystem:CheckSamePreTeam(PlayerID)
  if self.SamePreTeam[PlayerID] ~= nil then
    return self.SamePreTeam[PlayerID]
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return false
  end
  local MyPreTeamID = uPlayerState.PreTeamID
  if not uPlayerState.GetTeamMatePlayerStateList then
    return
  end
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
  for key, TeammateState in pairs(TeammatePlayerStateList) do
    if slua.isValid(TeammateState) and TeammateState.PlayerId == PlayerID then
      local TeammatePreTeamID = TeammateState.PreTeamID
      if MyPreTeamID ~= 0 and TeammatePreTeamID == MyPreTeamID then
        self.SamePreTeam[PlayerID] = true
        return true
      else
        self.SamePreTeam[PlayerID] = false
        return false
      end
    end
  end
  return false
end
function VoiceChatSubsystem:OnSetPlayerVolume(PlayerID, Volume)
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return
  end
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if not slua.isValid(uAntsVoiceInterface) then
    return
  end
  local MyPreTeamID = uPlayerState.PreTeamID
  local MyPreTeamChatState = uPlayerState.PreTeamChatState
  if not uPlayerState.GetTeamMatePlayerStateList then
    return
  end
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
  for key, TeammateState in pairs(TeammatePlayerStateList) do
    if slua.isValid(TeammateState) and TeammateState.PlayerId == PlayerID then
      local TeammatePreTeamID = TeammateState.PreTeamID
      local TeammateOpenID = TeammateState.OpenID
      local TeammateChatState = TeammateState.PreTeamChatState
      print(bWriteLog and "VoiceChatSubsystem:OnSetPlayerVolume Teammate OPID :", TeammateOpenID, "  MyPreTeamID: ", MyPreTeamID, "   TeammatePreTeamID: ", TeammatePreTeamID)
      if MyPreTeamID == 0 then
        self.SamePreTeam[TeammateState.PlayerId] = false
        if 2 <= TeammateChatState then
          uAntsVoiceInterface:SetPlayerVolume(TeammateOpenID, 0)
          self.WannaShowVolume[PlayerID] = Volume
          break
        end
        uAntsVoiceInterface:SetPlayerVolume(TeammateOpenID, Volume)
        self.LastVolumn[PlayerID] = Volume
        self.WannaShowVolume[PlayerID] = nil
        break
      end
      if TeammatePreTeamID == MyPreTeamID then
        self.SamePreTeam[TeammateState.PlayerId] = true
        uAntsVoiceInterface:SetPlayerVolume(TeammateOpenID, Volume)
        self.WannaShowVolume[PlayerID] = nil
        break
      end
      self.SamePreTeam[TeammateState.PlayerId] = false
      if MyPreTeamChatState == 1 or MyPreTeamChatState == 3 or 2 <= TeammateChatState then
        uAntsVoiceInterface:SetPlayerVolume(TeammateOpenID, 0)
        self.WannaShowVolume[PlayerID] = Volume
      else
        uAntsVoiceInterface:SetPlayerVolume(TeammateOpenID, Volume)
        self.LastVolumn[PlayerID] = Volume
        self.WannaShowVolume[PlayerID] = nil
      end
      print(bWriteLog and "VoiceChatSubsystem:OnSetPlayerVolume MyPreTeamChatState :", MyPreTeamChatState)
      break
    end
  end
end
function VoiceChatSubsystem:OnGetPlayerVolum(PlayerID)
  if self.WannaShowVolume[PlayerID] then
    print(bWriteLog and "VoiceChatSubsystem:OnGetPlayerVolum WannaShowVolume :", self.WannaShowVolume[PlayerID])
    return true, self.WannaShowVolume[PlayerID]
  end
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if not slua.isValid(uAntsVoiceInterface) then
    print(bWriteLog and "VoiceChatSubsystem:OnGetPlayerVolum Failed Case SDK")
    return false, 0
  end
  local OpenID = self:GetID2OpenID(PlayerID)
  if not OpenID then
    print(bWriteLog and "VoiceChatSubsystem:OnGetPlayerVolum Failed Case No OpenID")
    return false, 0
  end
  local Volume = uAntsVoiceInterface:GetPlayerVolume(OpenID)
  print(bWriteLog and "VoiceChatSubsystem:OnGetPlayerVolum OpenID \239\188\154 ", OpenID, " Volume:", Volume)
  return true, Volume
end
function VoiceChatSubsystem:GetID2OpenID(PlayerID)
  if slua.isValid(self.ID2OpenID[PlayerID]) then
    return self.ID2OpenID[PlayerID]
  else
    local uPlayerState = GameplayData.GetPlayerState()
    if not slua.isValid(uPlayerState) then
      return nil
    end
    if not uPlayerState.GetTeamMatePlayerStateList then
      return nil
    end
    local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
    for key, TeammateState in pairs(TeammatePlayerStateList) do
      if slua.isValid(TeammateState) and TeammateState.PlayerId then
        self.ID2OpenID[TeammateState.PlayerId] = TeammateState.OpenID
      end
    end
    return self.ID2OpenID[PlayerID]
  end
end
function VoiceChatSubsystem:OnPreTeamChatChange(_, _, PlayerID)
  local MyPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(MyPlayerState) then
    return
  end
  local bSelf = false
  if MyPlayerState.PlayerId == PlayerID or not PlayerID then
    print(bWriteLog and "VoiceChatSubsystem:OnPreTeamChatChange change Self state")
    EventSystem:postEvent(EVENTTYPE_PLAYER_STATE_INFO, EVENTID_SELF_PRETEAM_CHAT_CHANGE)
    PlayerID = MyPlayerState.PlayerId
    bSelf = true
  end
  local MyPreTeamID = MyPlayerState.PreTeamID
  local MyPreTeamChatState = MyPlayerState.PreTeamChatState
  print(bWriteLog and string.format("VoiceChatSubsystem:OnPreTeamChatChange MyPreTeamID %s, MyPreTeamChatState %s", MyPreTeamID, MyPreTeamChatState))
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  local TeammatePlayerStateList = MyPlayerState:GetTeamMatePlayerStateList({}, true)
  for key, TeammateState in pairs(TeammatePlayerStateList) do
    if slua.isValid(TeammateState) and (TeammateState.PlayerId == PlayerID or bSelf) then
      local TeammatePreTeamID = TeammateState.PreTeamID
      print(bWriteLog and string.format("VoiceChatSubsystem:OnPreTeamChatChange Teammate %s TeammatePreTeamID:%s PreTeamChatState:%s", TeammateState.PlayerName, TeammatePreTeamID, TeammateState.PreTeamChatState))
      if TeammatePreTeamID ~= MyPreTeamID then
        local TeammateOpenID = TeammateState.OpenID
        local TeammateChatState = TeammateState.PreTeamChatState
        if MyPreTeamChatState == 1 or MyPreTeamChatState == 3 or 2 <= TeammateChatState then
          uAntsVoiceInterface:SetPlayerVolume(TeammateOpenID, 0)
          self.WannaShowVolume[PlayerID] = self.LastVolumn[TeammateOpenID] or 100
        else
          local Volume = self.LastVolumn[TeammateOpenID] or 100
          uAntsVoiceInterface:SetPlayerVolume(TeammateOpenID, Volume)
          self.WannaShowVolume[PlayerID] = nil
        end
      end
    end
  end
end
function VoiceChatSubsystem:OnPlayerSubmitComplaint(_, __, Data)
  if not (Data and Data.OpenID) or Data.OpenID == "" then
    return
  end
  if not Data.ComplaintType or Data.ComplaintType & ComplaintConfig.EComplaintReasonType.DIRTYWORD == 0 then
    return
  end
  local sOpenID = Data.OpenID
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if not slua.isValid(uAntsVoiceInterface) then
    return
  end
  print(bWriteLog and string.format("VoiceChatSubsystem:OnPlayerSubmitComplaint - mute OpenID:%s", tostring(sOpenID)))
  uAntsVoiceInterface:SetPlayerVolume(sOpenID, 0)
end
function VoiceChatSubsystem:RefreshTeammateList()
  self:OnPreTeamChatChange()
end
function VoiceChatSubsystem:OnRelease()
  print(bWriteLog and "VoiceChatSubsystem:OnRelease")
  VoiceChatSubsystem.__super.OnRelease(self)
  local TableUtil = require("common.table_util")
  TableUtil.Clear(self.LastVolumn)
  TableUtil.Clear(self.SamePreTeam)
  TableUtil.Clear(self.ID2NameMap)
  TableUtil.Clear(self.WannaShowVolume)
  TableUtil.Clear(self.ID2OpenID)
end
function VoiceChatSubsystem:InitReceiverStatus()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local ReceiverSetting = SettingModule:GetOptionValue("ReceiverSetting")
  print(bWriteLog and "VoiceChatSubsystem:InitReceiverStatus ", ReceiverSetting)
  if ReceiverSetting == 1 then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:OpenTeamSpeakerOnly()
  elseif ReceiverSetting == 2 then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:CloseAllSpeaker()
  end
end
function VoiceChatSubsystem:CheckGlobalChatOpen()
  return false
end
function VoiceChatSubsystem:GetPlayerNameFromID(playerID)
  if self.ID2NameMap[playerID] then
    return self.ID2NameMap[playerID]
  else
    local PlayerState = GameplayData.GetPlayerState()
    if not slua.isValid(PlayerState) then
      return nil
    end
    local PlayerStateList = PlayerState:GetTeamMatePlayerStateList({}, false)
    for Idx = 0, PlayerStateList:Num() - 1 do
      local TeamPlayerState = PlayerStateList:Get(Idx)
      if slua.isValid(TeamPlayerState) then
        self.ID2NameMap[TeamPlayerState.PlayerId] = TeamPlayerState.playerName
      else
        print(bWriteLog and "VoiceChatSubsystem:GetPlayerNameFromID Get Null PlayerState in PlayerStateList")
        return nil
      end
    end
    return self.ID2NameMap[playerID]
  end
end
function VoiceChatSubsystem:IsUploadingSTTClip()
  return self._UploadingSTTClip
end
function VoiceChatSubsystem:UploadSTTClip(Text, STTClipPath)
  print(bWriteLog and string.format("VoiceChatSubsystem:UploadSTTClip - Text:%s STTClipPath:%s", tostring(Text), tostring(STTClipPath)))
  if self._UploadingSTTClip then
    print(bWriteLog and string.format("VoiceChatSubsystem:UploadSTTClip already in uploading, drop newer one"))
    return
  end
  self._UploadingSTTClip = true
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  logic_antsvoice_interface:UploadFile(STTClipPath, false, logic_chat_voice_const.UploadFileSence.SST)
  self._STTClipCache.  self._STTClipCache.Path = STTClipPath
end
function VoiceChatSubsystem:OnSTTAudioUploadFileNotify(_, _, InCode, filePath, fileID)
  print(bWriteLog and string.format("VoiceChatSubsystem:OnSTTAudioUploadFileNotify - Code:%s filePath:%s fileID:%s", tostring(InCode), tostring(filePath), tostring(InCode, filePath, fileID)))
  self._UploadingSTTClip = false
  if filePath ~= self._STTClipCache.Path then
    print(bWriteLog and string.format("VoiceChatSubsystem:OnSTTAudioUploadFileNotify not in current order"))
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local orginal_fileid, exter_info = logic_antsvoice_interface:FetchOfflineMessageExtraInfo(fileID)
  if exter_info ~= logic_chat_voice_const.UploadFileSence.SST then
    log(bWriteLog and "VoiceChatSubsystem:OnSTTAudioUploadFileNotify not in current order")
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local ChatComponent = PlayerController:GetChatComponent()
    if slua.isValid(ChatComponent) then
      local STTClipFileID = VoiceChatSubsystem.GetCurrentLangID() .. ";" .. orginal_fileid
      ChatComponent:SendSTTMsg(self._STTClipCache.Text, 7, STTClipFileID)
    end
  end
  self._STTClipCache.Text = nil
  self._STTClipCache.Path = nil
end
function VoiceChatSubsystem.GetCurrentLangID()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local ChatComponent = PlayerController:GetChatComponent()
    if slua.isValid(ChatComponent) then
      local FirstLangName = ChatComponent:GetFirstLanguage().name
      local LineID = logic_chat_voice_const.LangToLangID[FirstLangName]
      if LineID then
        return LineID
      end
    end
  end
  return 1
end
function VoiceChatSubsystem.IsSTTSLanguage(LangID)
  local bResult = TableUtil.Contains(STTSAvailableLangs, LangID)
  print(bWriteLog and string.format("VoiceChatSubsystem.IsSTTSLanguage - LangID:%s result:%s", tostring(LangID), tostring(bResult)))
  return bResult
end
function VoiceChatSubsystem.IsSTTSRegion()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local region = login_module.sIpRegion
  print(bWriteLog and string.format("VoiceChatSubsystem.IsSTTSRegion - region:%s", region))
  return region == "AE" or region == "KW" or region == "QA" or region == "SA"
end
function VoiceChatSubsystem.IsSTTSAvailable()
  print(bWriteLog and "VoiceChatSubsystem.IsSTTSAvailable")
  local LangID = VoiceChatSubsystem.GetCurrentLangID()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local bEnableSTTS = SettingModule:GetOptionValue("bEnableSTTS")
  return (VoiceChatSubsystem.IsSTTSRegion() or Client.IsDevelopment()) and bEnableSTTS and VoiceChatSubsystem.IsSTTSLanguage(LangID)
end
function VoiceChatSubsystem:SubmitSTTSTranslation(STTClipFileID, Prefix)
  local LangID, FileID = string.match(STTClipFileID, "^(.-);(.+)$")
  print(bWriteLog and string.format("VoiceChatSubsystem:SubmitSTTSTranslation - LangID:%s FileID:%s", LangID, FileID))
  if not LangID or not FileID then
    return false
  end
  LangID = tonumber(LangID)
  if not VoiceChatSubsystem.IsSTTSAvailable(LangID) then
    return false
  end
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if not slua.isValid(uAntsVoiceInterface) then
    return false
  end
  local timeout = 8
  uAntsVoiceInterface:SpeechTranslate(FileID, LangID, VoiceChatSubsystem.GetCurrentLangID(), 2, timeout * 1000)
  self._STTSTranslateTimer = self:AddGameTimer(timeout, false, function()
    print(bWriteLog and "VoiceChatSubsystem:SubmitSTTSTranslation - STTS translate timeout")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local PlayerController = GameplayData.GetPlayerController()
    if slua.isValid(PlayerController) then
      local ChatComponent = PlayerController:GetChatComponent()
      if slua.isValid(ChatComponent) then
        ChatComponent:DequeueSTTSMessage(false)
      end
    end
    self._STTSTranslateTimer = false
  end)
  print(bWriteLog and "VoiceChatSubsystem:SubmitSTTSTranslation - complete")
  return true
end
function VoiceChatSubsystem:OnSTTSMessageCallBack(InCode, InSrcText, InTargetText, InTargetFileID, InSrcFileDuration)
  print(bWriteLog and string.format("VoiceChatSubsystem:OnSTTSMessageCallBack - InCode:%s InTargetFileID:%s InSrcFileDuration:%s", tostring(InCode), tostring(InTargetFileID), tostring(InSrcFileDuration)))
  if self._STTSTranslateTimer then
    self:RemoveGameTimer(self._STTSTranslateTimer)
    self._STTSTranslateTimer = false
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:AddDownloadFile(InTargetFileID)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    local ChatComponent = PlayerController:GetChatComponent()
    if slua.isValid(ChatComponent) then
      ChatComponent:DequeueSTTSMessage(InTargetText)
    end
  end
end
function VoiceChatSubsystem:PopupChatPolicyNotification()
  if self._IsPopupChatPolicyOnce then
    return
  end
  local GameState = GameplayData.GetGameState()
  local EGameModeType = import("EGameModeType")
  if slua.isValid(GameState) and GameState.GameModeType == EGameModeType.ETypicalGameMode then
    self:AddGameTimer(3, false, function()
      ShowNotice(75475, true, 3)
    end)
  end
  self._IsPopupChatPolicyOnce = true
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, VoiceChatSubsystem)