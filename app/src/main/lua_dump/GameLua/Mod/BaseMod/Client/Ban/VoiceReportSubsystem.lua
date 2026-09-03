local VoiceReportSubsystem = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local TimeUtil = require("client.common.time_util")
function VoiceReportSubsystem:ctor()
  print(bWriteLog and "VoiceReportSubsystem:ctor")
  self.SuspiciousFlag = 0
  self.bSuspiciousEnable = false
  self.RelativeSourcePath = nil
  self.UnconsciousBan = false
  self.BanID = 136
  self.bHasMuted = false
  self.LbsMicEnable = nil
  self.bPreFilter = false
  self.GlobalMicBanEndTime = 0
  self.CacheText = {}
  self.bOnGlobalMicReported = false
end
function VoiceReportSubsystem:OnInit()
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.ReceiveBattleResults, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_RETURN_TO_LOBBY, self.HandleOnReturnToLobby, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SYNC_PLAYER_BAN, self.SyncPlayerBan, self)
  self.bSuspiciousEnable = LobbySystem.CheckOpen(BP_ENUM_HIGH_SUSPICIOUS_SWITCH)
  print(bWriteLog and "VoiceReportSubsystem:OnInit HighSusInit LobbySwitch = ", self.bSuspiciousEnable)
  if self.bSuspiciousEnable then
    self:CheckFileAndUpload()
    self:AddCommonEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_MIC_PREFILTER, self.HandlePreFilter, self)
  end
  self:AddCommonEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_SUSPICIOUS_FLAG, self.RealTimeSuspiciousFlag, self)
  self:ReqFlagOnInit()
  local bUnconsEnable = LobbySystem.CheckOpen(BP_ENUM_UNCONSCIOUS_BAN_SWITCH)
  print(bWriteLog and "VoiceReportSubsystem:OnInit UnconsInit LobbySwitch = ", bUnconsEnable)
  if bUnconsEnable then
    self:UnconsInit()
  end
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.HandleSpectatorChange, self)
  GameplayData.AddSelfPlayerCharacterEvent(self, "OnPawnRespawnDelegate", self.HandleOnRespawn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_UNCONSCIOUS_BAN, self.RealTimeUnconsciousBan, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_WARNING_TIPS, self.OnNotifyTips, self)
  self:ShowBlueToothNotice()
  self.bHasReported = false
  if GameStatus.IsInMainCity() then
    local ClientBanLogic = require("GameLua.Mod.BaseMod.Client.Ban.ClientBanLogic")
    ClientBanLogic.ReqBanInfo()
  end
end
function VoiceReportSubsystem:SyncPlayerBan(_, __, BanData)
  print(bWriteLog and "VoiceReportSubsystem:SyncPlayerBan")
  if BanData[BanMacro.PLAYER_BAN_GLOBAL_MI] then
    local BanInfo = BanData[BanMacro.PLAYER_BAN_GLOBAL_MI]
    if BanInfo.end_time and BanInfo.end_time > 0 and BanInfo.end_time > TimeUtil.GetServerTimeInSec() then
      self:GlobalMicBan(true, BanInfo.end_time)
      return
    end
  end
  self:GlobalMicBan(false)
end
function VoiceReportSubsystem:GlobalMicBan(bBan, EndTime)
  print(bWriteLog and "VoiceReportSubsystem:GlobalMicBan " .. tostring(bBan) .. " " .. tostring(EndTime))
  if bBan then
    if EndTime then
      self.GlobalMicBan      local startTimeStr = TimeUtil.FormatTime_YMDHMS(self.GlobalMicBanEndTime, false)
      IngameTipsTools.BattleNormalTipsByTextID(770031, startTimeStr)
    end
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    if logic_antsvoice_interface:IsInterphoneMode() then
      local bIsTeamInterphoneOpenned = logic_antsvoice_interface:IsTeamInterphoneOpenned()
      local bIsLbsInterphoneOpenned = logic_antsvoice_interface:IsLbsInterphoneOpenned()
      print(bWriteLog and "VoiceReportSubsystem:GlobalMicBan Interphone Team " .. tostring(bIsTeamInterphoneOpenned) .. " Lbs " .. tostring(bIsLbsInterphoneOpenned))
      if bIsLbsInterphoneOpenned then
        logic_antsvoice_interface:CloseAllMicphone()
      end
    else
      local bIsTeamMicphoneEnable = logic_antsvoice_interface:TeamMicphoneEnable()
      local bIsLbsMicphoneEnable = logic_antsvoice_interface:LbsMicphoneEnable()
      print(bWriteLog and "VoiceReportSubsystem:GlobalMicBan Micphone Team " .. tostring(bIsTeamMicphoneEnable) .. " Lbs " .. tostring(bIsLbsMicphoneEnable))
      if bIsLbsMicphoneEnable then
        logic_antsvoice_interface:CloseAllMicphone()
      end
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_BAN_GLOBAL_MIC, true)
  else
    self.GlobalMicBanEndTime = 0
    EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_BAN_GLOBAL_MIC, false)
  end
end
function VoiceReportSubsystem:CheckBanEndTime(BanID)
  print(bWriteLog and "VoiceReportSubsystem:CheckBanEndTime " .. tostring(BanID))
  local UTCTime = TimeUtil.GetServerTimeInSec()
  if BanID == BanMacro.PLAYER_BAN_GLOBAL_MI then
    print(bWriteLog and string.format("VoiceReportSubsystem:CheckBanEndTime PLAYER_BAN_GLOBAL_MI BanEnd Time %d, current server time %d", self.GlobalMicBanEndTime, UTCTime))
    if UTCTime > self.GlobalMicBanEndTime then
      self.GlobalMicBanEndTime = 0
      EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_BAN_GLOBAL_MIC, false)
      return 0
    else
      return self.GlobalMicBanEndTime
    end
  end
end
function VoiceReportSubsystem:UnconsInit()
  print(bWriteLog and "VoiceReportSubsystem:UnconsInit")
  self:ReqBanOnInit()
end
function VoiceReportSubsystem:ReqFlagOnInit()
  print(bWriteLog and "VoiceReportSubsystem:ReqFlagOnInit")
  local BattleHandler = require("client.network.Protocol.BattleHander")
  BattleHandler.send_suspicious_flag_req()
end
function VoiceReportSubsystem:ReqBanOnInit()
  local BattleHandler = require("client.network.Protocol.BattleHander")
  BattleHandler.send_get_ban_id_req(self.BanID)
end
function VoiceReportSubsystem:RealTimeSuspiciousFlag(_, _, Flag)
  print(bWriteLog and "VoiceReportSubsystem:RealTimeSuspiciousFlag ", Flag)
  self.Suspicious  if Flag == 2 then
    self:MonitorHighSuspicious(true)
  end
end
function VoiceReportSubsystem:ReceiveBattleResults(_, _)
  if self.bSuspiciousEnable then
    print(bWriteLog and "VoiceReportSubsystem:ReceiveBattleResults ", self.SuspiciousFlag)
    self:MonitorHighSuspicious(false)
  end
  if self.bOnGlobalMicReported then
    self:OnGlobalMicReport()
  end
end
function VoiceReportSubsystem:HandleOnReturnToLobby(_, _)
  if self.bOnGlobalMicReported then
    self:OnGlobalMicReport()
  end
end
function VoiceReportSubsystem:RealTimeUnconsciousBan(_, _, BanID, bBan)
  print(bWriteLog and "VoiceReportSubsystem:RealTimeUnconsciousBan ", BanID, bBan)
  self.UnconsciousBan = bBan
  self:UnconsciousBanLbsRoom(self.UnconsciousBan)
end
function VoiceReportSubsystem:MonitorHighSuspicious(bStart)
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if not slua.isValid(uAntsVoiceInterface) then
    return
  end
  if bStart then
    local filename = Client.ProjectSavedDir()
    local BusinessHelper = import("BusinessHelper")
    local fullpath = BusinessHelper.GetMobileBasePath(filename .. "Voices/") .. "record.ogg"
    self.RelativeSourcePath = filename .. "Voices/record.ogg"
    uAntsVoiceInterface:EnableReportForAbroad(true)
    uAntsVoiceInterface:ReportFileForAbroad(fullpath, false, true, 60)
    print(bWriteLog and "VoiceReportSubsystem:MonitorHighSuspicious report success, fullpath:", fullpath)
  else
    uAntsVoiceInterface:EnableReportForAbroad(false)
    print(bWriteLog and "VoiceReportSubsystem:MonitorHighSuspicious End Monitoring RelativeSourcePath: ", self.RelativeSourcePath)
    self:CheckFileAndUpload()
  end
end
function VoiceReportSubsystem:CheckFileAndUpload()
  local fileName = "record.ogg"
  local savePath = Client.ProjectSavedDir() .. "Voices/" .. fileName
  local isExist = Client.IsFileExistByFileName("Voices/record.ogg")
  print(bWriteLog and "VoiceReportSubsystem:CheckFileAndUpload, isExist", isExist)
  if isExist then
    log(bWriteLog and "CheckFile " .. tostring(savePath))
    local ShareMgr = require("client.logic.share.share_logic")
    ShareMgr.HDmpveUploadFile(savePath, function(isSuccess, voiceUrl)
      print(bWriteLog and "VoiceReportSubsystem:CheckFileAndUpload, Upload", isSuccess, voiceUrl)
      if isSuccess then
        Client.DeleteFile(savePath)
      end
    end, 1, ShareMgr.ShareFileType.Voice)
  end
end
function VoiceReportSubsystem:UnconsciousBanLbsRoom(bBan)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:ForbidLbsMemberVoice(not bBan)
  if true == self.LbsMicEnable then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:OpenAllSpeaker()
  end
  self.LbsMicEnable = nil
end
function VoiceReportSubsystem:HandleSpectatorChange()
  print(bWriteLog and "VoiceReportSubsystem:HandleSpectatorChange has banned", self.bHasMuted)
  if self.bHasMuted then
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if uPlayerController:IsFriendObserver() then
    return
  end
  if uPlayerController:IsInSpectating() then
    self:UnconsciousBanLbsRoom(true)
    self.bHasMuted = true
  end
end
function VoiceReportSubsystem:HandleOnRespawn()
  print(bWriteLog and "Lipz VoiceReportSubsystem respawn")
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if slua.isValid(uAntsVoiceInterface) then
    self.LbsMicEnable = uAntsVoiceInterface:LbsMicphoneEnable()
  end
  self:ReqBanOnInit()
  self.bHasMuted = false
end
function VoiceReportSubsystem:OnNotifyTips(_, _, TextID, bOffMic)
  IngameTipsTools.BattleNormalTipsByTextID(TextID)
  if bOffMic then
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    if logic_antsvoice_interface then
      logic_antsvoice_interface:CloseAllMicphone()
      EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_VOICE_AND_SPEAK_CHANGE)
    end
  end
end
function VoiceReportSubsystem:AddTextToCache(sText)
  if sText then
    table.insert(self.CacheText, sText)
  end
end
function VoiceReportSubsystem:GetTextHistory()
  local sFinalRes = table.concat(self.CacheText, ";")
  print(bWriteLog and "VoiceReportSubsystem:GetTextHistory", sFinalRes)
  return sFinalRes
end
function VoiceReportSubsystem:HandlePreFilter(_, __, ban_id)
  if ban_id == BanMacro.PLAYER_VOICE_PRE_FILTER then
    self:EnablePreFilter(true)
  end
end
function VoiceReportSubsystem:EnablePreFilter(bStart)
  local uAntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
  if not slua.isValid(uAntsVoiceInterface) then
    return
  end
  if bStart and not self.bPreFilter then
    self.bPreFilter = true
    print(bWriteLog and "VoiceReportSubsystem:EnablePreFilter success")
  elseif not bStart and self.bPreFilter then
    self.bPreFilter = false
    print(bWriteLog and "VoiceReportSubsystem:DisablePreFilter success")
  end
end
function VoiceReportSubsystem:ShowBlueToothNotice()
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if not logic_antsvoice_interface then
    return
  end
  local checkLogic = logic_antsvoice_interface:IsBluetoothModeNeedToGrantPermission()
  if not checkLogic then
    return
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  if SettingSubsystem:GetUserSettings_Bool("bHasShowBlueToothNotice") == true then
    return
  end
  SettingSubsystem:SetUserSettings_Bool("bHasShowBlueToothNotice", true)
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(IngameTipsTools.MSGBOX_SHOW_TYPE_ONE, nil, LocUtil.GetLocalizeResStr(75089))
end
function VoiceReportSubsystem:OnGlobalMicReport()
  self.bOnGlobalMicReported = true
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem then
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if not logic_antsvoice_interface then
    return
  end
  local ReceiverSetting = SettingSubsystem:GetUserSettings_Int("ReceiverSetting")
  if ReceiverSetting == 0 and logic_antsvoice_interface:LbsSpeakerEnable() then
    print(bWriteLog and "VoiceReportSubsystem:OnGlobalMicReport Set to TeamOnly for Next Game")
    SettingSubsystem:SetUserSettings_Int("ReceiverSetting", 1)
  end
end
function VoiceReportSubsystem:GetTeammatesTypeStr()
  local PlayerState = GameplayData.GetPlayerState()
  local OpenID_TypeList = {}
  if slua.isValid(PlayerState) then
    local TeamPlayerStateArray = PlayerState:GetTeamMatePlayerStateList({}, false)
    for i, TeammateState in pairs(TeamPlayerStateArray) do
      if slua.isValid(TeammateState) and TeammateState.TeammateTakeOverFeature and TeammateState.TeammateTakeOverFeature.bAITakeOver then
        table.insert(OpenID_TypeList, TeammateState.OpenID .. ":1")
      end
    end
  end
  if next(OpenID_TypeList) then
    local str = "&players_type="
    for i, id in ipairs(OpenID_TypeList) do
      if i == 1 then
        str = str .. id
      else
        str = str .. "+" .. id
      end
    end
    return str
  end
  return ""
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, VoiceReportSubsystem)