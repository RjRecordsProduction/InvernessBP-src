local logic_chat_voice_voice_room_param = {}
local battleAntsVoiceRoomParam = {voiceRoomId = "", antsVoiceUrl = ""}
local ugcAntsVoiceRoomParam = {voiceRoomId = "", antsVoiceUrl = ""}
local globalAntsVoiceRoomParam = {voiceRoomId = "", antsVoiceUrl = ""}
function logic_chat_voice_voice_room_param:SetBattleAntsVoiceRoomParam(voiceTeamID, gameID, antsVoiceURL)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room_param:SetBattleAntsVoiceRoomParam, voiceTeamID, gameID, antsVoiceURL:%s, %s, %s", voiceTeamID, gameID, antsVoiceURL))
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(1000)
  local roomID = ""
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  if logic_enter_game:IsEnterBattleByRoom() then
    logic_chat_voice_doctor:AddJoinTeamRoomStep(1001)
    local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
    roomID = logic_chat_voice_utility:GenerateFightingVoiceRoomID()
  elseif voiceTeamID and voiceTeamID ~= 0 then
    logic_chat_voice_doctor:AddJoinTeamRoomStep(1002)
    local BusinessHelper = import("BusinessHelper")
    roomID = gameID .. "_" .. voiceTeamID .. "_in_game" .. BusinessHelper.GetVoiceSdkGameId() or ""
    log(bWriteLog and "[muidarzhang] logic_chat_voice_voice_room_param:SetBattleAntsVoiceRoomParam, voiceTeamID and voiceTeamID ~= 0, GVoice Join Room Game Voice:" .. roomID)
  end
  logic_chat_voice_doctor:AddJoinTeamRoomStep(roomID)
  battleAntsVoiceRoomParam = {voiceRoomId = roomID, antsVoiceUrl = antsVoiceURL}
end
function logic_chat_voice_voice_room_param:GetBattleAntsVoiceRoomParam()
  return battleAntsVoiceRoomParam
end
function logic_chat_voice_voice_room_param:ClearAntsVoiceRoomParam()
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(1100)
  battleAntsVoiceRoomParam = {voiceRoomId = "", antsVoiceUrl = ""}
  ugcAntsVoiceRoomParam = {voiceRoomId = "", antsVoiceUrl = ""}
end
function logic_chat_voice_voice_room_param:SetUGCAntsVoiceUrl(antsVoiceURL)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_voice_room_param:SetUGCAntsVoiceUrl antsVoiceURL: %s", antsVoiceURL))
  ugcAntsVoiceRoomParam.antsVoiceUrl = antsVoiceURL
end
function logic_chat_voice_voice_room_param:SetUGCRoomID(TeamID, BattleID)
  local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
  local VoiceRoomID = logic_chat_voice_utility:GenerateUGCTeamVoiceRoomID(TeamID, BattleID)
  log(bWriteLog and string.format("logic_chat_voice_voice_room_param:SetUGCRoomID TeamID %d, BattleId %s, VoiceRoomID %s", TeamID, BattleID, VoiceRoomID))
  ugcAntsVoiceRoomParam.voiceRoomId = VoiceRoomID
end
function logic_chat_voice_voice_room_param:GetUGCAntsVoiceRoomParam()
  return ugcAntsVoiceRoomParam
end
function logic_chat_voice_voice_room_param:SetGlobalAntsVoiceRoomParam(gameID, antsVoiceURL)
  log(bWriteLog and string.format("logic_chat_voice_voice_room_param:SetGlobalAntsVoiceRoomParam, gameID, antsVoiceURL:%s, %s", gameID, antsVoiceURL))
  globalAntsVoiceRoomParam = {voiceRoomId = gameID, antsVoiceUrl = antsVoiceURL}
end
function logic_chat_voice_voice_room_param:GetGlobalAntsVoiceRoomParam()
  return globalAntsVoiceRoomParam
end
return logic_chat_voice_voice_room_param