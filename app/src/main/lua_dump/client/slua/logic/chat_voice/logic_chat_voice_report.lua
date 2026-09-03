local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local Const_MaxReportTextLength = logic_chat_voice_const.Const_MaxReportTextLength
local HDmpveVoiceCompleteCode = logic_chat_voice_const.HDmpveVoiceCompleteCode
local Enum_AntsVoiceReportType = logic_chat_voice_const.Enum_AntsVoiceReportType
local logic_chat_voice_report = {
  ReportVoiceTempList = {},
  ReportVoiceMsgTimer = nil,
  VoiceReportScene = 0
}
function logic_chat_voice_report:OnInitialize()
  log(bWriteLog and "logic_chat_voice_report:OnInitialize")
end
function logic_chat_voice_report:RegistEvents()
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local interface = logic_antsvoice_interface:GetGVoiceInterface()
  self:AddControlEvent(interface, "OnReportPlayerCallback", self.OnReportPlayer, self)
  self:AddControlEvent(interface, "OnSTTReportCallback", self.OnSTTCallback, self)
end
function logic_chat_voice_report:SetReportScene(NewVal)
  log(bWriteLog and string.format("logic_chat_voice_report:SetReportScene, NewVal %s", tostring(NewVal)))
  self.VoiceReportScene = NewVal
end
function logic_chat_voice_report:GetBattleInfo(OutInfo)
  log(bWriteLog and "logic_chat_voice_report:GetBattleInfo")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local BattleDuration = 0
  local GameModeState = ""
  local TeammateList = {}
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.GetGameModeState then
    BattleDuration = uGameState:GetServerWorldTimeSeconds()
    GameModeState = uGameState:GetGameModeState()
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController:IsSpectator() then
    GameModeState = "SpectatingState"
  elseif slua.isValid(uPlayerController) and uPlayerController:IsInPetSpectator() then
    GameModeState = "PetSpectatingState"
  end
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) then
    local uTeamPlayerStateArray = uPlayerState:GetTeamMatePlayerStateList({}, false)
    for key, value in pairs(uTeamPlayerStateArray) do
      if value and slua.isValid(value) then
        log(bWriteLog and string.format("logic_chat_voice_report:GetBattleInfo Teammate %d  %s", key, tostring(value.UID)))
        table.insert(TeammateList, value.UID)
      end
    end
    OutInfo.  end
  log(bWriteLog and string.format("logic_chat_voice_report:GetBattleInfo %s %s", tostring(BattleDuration), GameModeState))
  OutInfo.  OutInfo.  OutInfo.end
function logic_chat_voice_report:OnReportPlayer(code, reportPlayerInfo)
  log(bWriteLog and string.format("logic_chat_voice_report:OnReportPlayer, code, reportPlayerInfo:%s, %s", code, reportPlayerInfo))
  if code == HDmpveVoiceCompleteCode.GV_ON_REPORT_SUCC then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    local reportInfo = {
      BattleID = g_game_id or 0,
      SubMode = MatchModeMgrSystem.nInGameModeID or 0,
      Payload = reportPlayerInfo,
      Method = Enum_AntsVoiceReportType.VoiceReport
    }
    self:GetBattleInfo(reportInfo)
    ChatHandler.send_report_info_mic(reportInfo)
  elseif code == HDmpveVoiceCompleteCode.GV_ON_REPORT_SUCC_SELF then
    local GVoiceInterface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    local originalReportPlayerInfo, exterInfo = GVoiceInterface:FetchOfflineMessageExtraInfo(reportPlayerInfo)
    if exterInfo and exterInfo == logic_chat_voice_const.SocialCard then
      local ChatHandler = require("client.network.Protocol.ChatHandler")
      local reportInfo = {
        Payload = originalReportPlayerInfo,
        Method = Enum_AntsVoiceReportType.VoiceReport
      }
      log(bWriteLog and "logic_chat_voice_report:OnReportPlayer SocialCard")
      ChatHandler.send_social_voice_audit_callback(reportInfo)
    end
  end
  self.VoiceReportScene = 0
end
function logic_chat_voice_report:OnSTTCallback(code, text, openid, fileID)
  log(bWriteLog and string.format("logic_chat_voice_report:OnSTTCallback, code, text, openid, fileID:%s, %s, %s, %s", code, #text, openid, fileID))
  if code ~= HDmpveVoiceCompleteCode.GV_ON_ST_SUCC then
    log(bWriteLog and "OnSTTCallback Error:" .. tostring(code))
    return
  end
  if Client.IsDevelopment() then
    log(bWriteLog and "========[OnSTTCallback] print text START========")
    local tmpText = text
    while #tmpText > Const_MaxReportTextLength do
      local substring = string.sub(tmpText, 1, Const_MaxReportTextLength)
      tmpText = string.sub(tmpText, Const_MaxReportTextLength + 1)
      log(bWriteLog and string.format("logic_chat_voice_report:OnSTTCallback:%s", substring))
    end
    if 0 < #tmpText and #tmpText <= Const_MaxReportTextLength then
      log(bWriteLog and string.format("logic_chat_voice_report:OnSTTCallback:%s", tmpText))
    end
    log(bWriteLog and "========[OnSTTCallback] print text END========")
  end
  if #text <= 0 then
    log(bWriteLog and "logic_chat_voice:OnSTTCallback, Report text leng too short to report.")
    return
  end
  if #text > Const_MaxReportTextLength then
    log(bWriteLog and "logic_chat_voice:OnSTTCallback, Report text leng too long to report.")
    return
  end
  if openid == DataMgr.roleData.openID then
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    local reportInfo = {
      Payload = text,
      Method = Enum_AntsVoiceReportType.TextReport
    }
    log(bWriteLog and "logic_chat_voice_report:OnSTTCallback SocialCard")
    ChatHandler.send_social_voice_audit_callback(reportInfo)
  else
    self.ReportVoiceTempList = self.ReportVoiceTempList or {}
    table.insert(self.ReportVoiceTempList, text)
    if not self.ReportVoiceMsgTimer then
      self:ReportVoiceMsg(openid)
    end
  end
end
function logic_chat_voice_report:ReportVoiceMsg(openid)
  log(bWriteLog and "logic_chat_voice_report:ReportVoiceMsg")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local player_type = 0
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local MyPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(MyPlayerState) then
    local TeamPlayerStateArray = MyPlayerState:GetTeamMatePlayerStateList({}, false)
    for _, TeammateState in pairs(TeamPlayerStateArray) do
      if slua.isValid(TeammateState) and openid == TeammateState.OpenID and TeammateState.TeammateTakeOverFeature and TeammateState.TeammateTakeOverFeature.bAITakeOver then
        player_type = 1
        break
      end
    end
  end
  self.ReportVoiceMsgTimer = self:AddTimerLoop(0, function()
    if #self.ReportVoiceTempList > 0 then
      local tempPayload = table.remove(self.ReportVoiceTempList, 1)
      local reportInfo = {
        BattleID = g_game_id or 0,
        SubMode = MatchModeMgrSystem.nInGameModeID or 0,
        Payload = tempPayload,
        Method = Enum_AntsVoiceReportType.TextReport,
        ReportScene = self.VoiceReportScene,
        PlayerType = player_type
      }
      self:GetBattleInfo(reportInfo)
      ChatHandler.send_report_info_mic(reportInfo)
      self.VoiceReportScene = 0
    else
      self:RemoveTimer(self.ReportVoiceMsgTimer)
      self.ReportVoiceMsgTimer = nil
    end
  end, TIMER_INFINITE, 1)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, logic_chat_voice_report)