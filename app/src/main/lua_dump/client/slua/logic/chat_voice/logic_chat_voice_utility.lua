local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local StringUtil = require("common.string_util")
local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
local Enum_MemberStateBitDefine = logic_chat_voice_const.Enum_MemberStateBitDefine
local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
local logic_chat_voice_utility = {bIngameChatRoomOpenGM = nil}
function logic_chat_voice_utility.CheckIsRoleValid(role)
  log(bWriteLog and string.format(" logic_chat_voice_utility.CheckIsRoleValid, role:%s", role))
  if IsEditor then
    return true
  end
  role = role or StringUtil.StrTrim(DataMgr.roleData.uid)
  if role == "" then
    log(bWriteLog and " ERROR: logic_chat_voice_utility.CheckRoleValid, not self.bIsRoleValid. ")
    return false
  end
  return true
end
function logic_chat_voice_utility:GenerateFightingVoiceRoomID()
  local memberList = RoomSystem.GetSelfTeamIds()
  local checkSum = 0
  for _, v in ipairs(memberList) do
    checkSum = v + checkSum
  end
  table.sort(memberList, function(a, b)
    return b < a
  end)
  local room_id = ""
  if 1 < #memberList then
    room_id = tostring(checkSum)
    for i = 1, #memberList do
      room_id = room_id .. string.sub(tostring(memberList[i]), -4)
    end
  end
  if room_id == "" then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_utility:GenerateFightingVoiceRoomID, room_id == \"\" ")
    log_tree("[muidarzhang] logic_chat_voice_utility:GenerateFightingVoiceRoomID memberList:", memberList)
    return ""
  end
  local BusinessHelper = import("BusinessHelper")
  local gameID = BusinessHelper.GetVoiceSdkGameId() or ""
  local voiceGameRoomId = room_id .. "_in_game" .. gameID
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_utility:GenerateFightingVoiceRoomID, voiceGameRoomId:%s", voiceGameRoomId))
  return voiceGameRoomId
end
function logic_chat_voice_utility.GenerateLobbyVoiceRoomID(sUid, gameID)
  printf("logic_chat_voice_utility:GenerateLobbyVoiceID, sUid:%s, gameID:%s", sUid, gameID)
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  local leaderName = logic_team_up.GetMemberName(sUid)
  if leaderName == "" then
    log_error("logic_chat_voice_utility:GenerateLobbyVoiceID leaderName is nil. sUid:" .. sUid)
  end
  local leaderNameHash = Client.MD5HashAnsiString(leaderName) .. "_"
  local BusinessHelper = import("BusinessHelper")
  gameID = gameID or BusinessHelper.GetVoiceSdkGameId()
  local lobbyVoiceRoomId = leaderNameHash .. sUid .. gameID
  printf("logic_chat_voice_utility:GenerateLobbyVoiceID, sUid:%s, leaderName:%s , lobbyVoiceRoomId:%s", sUid, leaderName, lobbyVoiceRoomId)
  return lobbyVoiceRoomId
end
function logic_chat_voice_utility:GenerateUGCTeamVoiceRoomID(TeamID, BattleID)
  if not TeamID or TeamID <= 0 then
    return ""
  end
  local BusinessHelper = import("BusinessHelper")
  local GameID = BusinessHelper.GetVoiceSdkGameId() or ""
  local VoiceGameRoomId = string.format("%s_%d_in_ugc_game_%s", BattleID, TeamID, GameID)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_utility:GenerateUGCTeamVoiceRoomID, voiceGameRoomId:%s", VoiceGameRoomId))
  return VoiceGameRoomId
end
function logic_chat_voice_utility.CheckChatPrivacyAcceptStatus()
  local acceptStatus = true
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local ShouldRequestChatPrivacy = true
  if DataMgr.roleData.eugdpr ~= nil and login_module.commonSwitch and login_module.commonSwitch.FirstVoicePopupSwitch == false then
    ShouldRequestChatPrivacy = false
  end
  if ShouldRequestChatPrivacy then
    local GameBackendHUD = import("GameBackendHUD")
    local backendHudObject = GameBackendHUD.GetInstance()
    local frontHudObject = backendHudObject:GetFirstGameFrontendHUD()
    local settingConfig = frontHudObject:GetUserSettings()
    if settingConfig ~= nil then
      local BusinessHelper = import("BusinessHelper")
      local appVersion = BusinessHelper.GetAppVersion()
      acceptStatus = appVersion == settingConfig.ChatPrivacyAcceptedVersion
    else
      log(bWriteLog and "global_ui_function_library:CheckChatPrivacyAcceptStatus, settingConfig = nil")
    end
  end
  log(bWriteLog and "global_ui_function_library:CheckChatPrivacyAcceptStatus, ShouldRequestChatPrivacy = " .. tostring(ShouldRequestChatPrivacy) .. ", acceptStatus = " .. tostring(acceptStatus))
  return acceptStatus
end
function logic_chat_voice_utility.EncodeMemberState(stateTable)
  log_tree("[muidarzhang] logic_chat_voice_utility.EncodeMemberState stateTable:", stateTable)
  local stateBit = 0
  for _, bit in pairs(Enum_MemberStateBitDefine) do
    if stateTable[bit] == true then
      stateBit = stateBit | 1 << bit - 1
    end
  end
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_utility.EncodeMemberState, stateBit:%s", stateBit))
  return stateBit
end
function logic_chat_voice_utility.DecodeMemberState(stateBit)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_utility.DecodeMemberState, stateBit:%s", tostring(stateBit)))
  if stateBit == nil or type(stateBit) ~= "number" then
    log(bWriteLog and string.format("ERROR: logic_chat_voice_utility.DecodeMemberState, stateBit is invalid, type:%s", type(stateBit)))
    return {
      false,
      false,
      false
    }
  end
  local stateTable = {}
  for _, bit in pairs(Enum_MemberStateBitDefine) do
    local temp = stateBit >> bit - 1
    stateTable[bit] = temp & 1 == 1
  end
  log_tree("[muidarzhang] logic_chat_voice_utility.DecodeMemberState stateTable:", stateTable)
  return stateTable
end
function logic_chat_voice_utility.IsIngameChatRoomOpen()
  if logic_chat_voice_utility.bIngameChatRoomOpenGM ~= nil then
    return logic_chat_voice_utility.bIngameChatRoomOpenGM
  end
  if LobbySystem.CheckOpen(BP_SWITCH_INGAME_CHATROOM) then
    return true
  else
    return false
  end
end
function logic_chat_voice_utility.GetLobbyTeamSpeakerStateForUI()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local hardwareSwitch = logic_chat_voice:GetSpeakerState()
  local softwareSwitch = logic_chat_voice:GetSelfRoomSpeakerState(Enum_AntsVoiceRoomType.LobbyTeam)
  printf("logic_chat_voice_utility.GetLobbyTeamSpeakerStateForUI  hardwareSwitch:%s, softwareSwitch:%s", hardwareSwitch, softwareSwitch)
  local switch = hardwareSwitch and softwareSwitch
  return switch
end
function logic_chat_voice_utility.GetLobbyTeamMicStateForUI()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local hardwareSwitch = logic_chat_voice:GetMicState()
  local softwareSwitch = logic_chat_voice:GetSelfRoomMicrophoneState(Enum_AntsVoiceRoomType.LobbyTeam)
  printf("logic_chat_voice_utility.GetLobbyTeamMicStateForUI  hardwareSwitch:%s, softwareSwitch:%s", hardwareSwitch, softwareSwitch)
  local switch = hardwareSwitch and softwareSwitch
  return switch
end
return logic_chat_voice_utility