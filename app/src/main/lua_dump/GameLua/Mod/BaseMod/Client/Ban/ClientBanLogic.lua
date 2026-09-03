local ClientBanLogic = {
  VoiceBanEndTime = 0,
  bEnableVoiceReport = false,
  SuspiciousFlag = 0,
  Reason = "",
  IsTranslated = false
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
function ClientBanLogic.ReqBanInfo()
  print(bWriteLog and "debug Ban:ClientBanLogic:ReqBanInfo")
  ClientBanLogic.VoiceBanEndTime = 0
  local protoc = require("protoc")
  protoc.LoadFile("ds_client/ingame_ban.pb")
  local ds_net = require("ds_net")
  local Msg = {}
  ds_net.SendMessage("req_ingame_ban_info", Msg)
end
function ClientBanLogic.OnVoiceSwitchNotify(Message)
  log_tree("debug Ban:ClientBanLogic:OnVoiceSwitchNotify", Message)
  if Message.voice_ban_switch then
    ClientBanLogic.bEnableVoiceReport = true
    EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_OPEN_VOICE_BAN)
  end
end
function ClientBanLogic.OnVoiceBanNotify(Message)
  log_tree("debug Ban:ClientBanLogic:OnVoiceBanNotify", Message)
  print(bWriteLog and "debug Ban:ClientBanLogic:OnVoiceBanNotify BanEndTime:" .. tostring(Message.voice_ban_end_time))
  print(bWriteLog and "debug Ban:ClientBanLogic:OnVoiceBanNotify is_translated:" .. tostring(Message.reason_is_translated))
  print(bWriteLog and "debug Ban:ClientBanLogic:OnVoiceBanNotify reason:" .. tostring(Message.ban_reason))
  ClientBanLogic.VoiceBanEndTime = Message.voice_ban_end_time
  ClientBanLogic.IsTranslated = Message.reason_is_translated
  ClientBanLogic.Reason = Message.ban_reason
  local TimeUtil = require("client.common.time_util")
  local UTCTime = TimeUtil.GetServerTimeInSec()
  if UTCTime < ClientBanLogic.VoiceBanEndTime then
    EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, true)
  end
end
function ClientBanLogic.OnRealTimeVoiceBanNotify(Uid, Reason, Endtime)
  print(bWriteLog and "debug Ban:ClientBanLogic:OnRealTimeVoiceBanNotify endtime:" .. tostring(Endtime))
  ClientBanLogic.VoiceBanEndTime = Endtime
  local TimeUtil = require("client.common.time_util")
  local UTCTime = TimeUtil.GetServerTimeInSec()
  if UTCTime < ClientBanLogic.VoiceBanEndTime then
    EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, true)
    IngameTipsTools.BattleNormalTipsByTextID(508071)
  end
end
function ClientBanLogic.OnVoiceBanSuccess(Uid, Name, Bantime)
  print(bWriteLog and "debug Ban:ClientBanLogic:OnVoiceBanSuccess Name:" .. tostring(Name))
  local NameStartStr = string.sub(Name, 1, 1)
  IngameTipsTools.BattleNormalTipsByTextID(508076, NameStartStr .. "***")
  local txt = LocUtil.GetLocalizeResStr(64154)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  InGameUITools.DisplayMessageInGame(txt)
end
function ClientBanLogic.TryOpenVoice()
  local TimeUtil = require("client.common.time_util")
  local UTCTime = TimeUtil.GetServerTimeInSec()
  print(bWriteLog and "debug Ban:TryOpenVoice UTCTime:" .. UTCTime .. " BanTIme:" .. ClientBanLogic.VoiceBanEndTime)
  if UTCTime > ClientBanLogic.VoiceBanEndTime then
    EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_FORBID_VOICE, false)
  elseif ClientBanLogic.IsTranslated and ClientBanLogic.Reason ~= "" then
    IngameTipsTools.BattleNormalTips(ClientBanLogic.Reason)
  else
    local startTimeStr = TimeUtil.FormatTime_YMDHMS(ClientBanLogic.VoiceBanEndTime, false)
    IngameTipsTools.BattleNormalTipsByTextID(508072, startTimeStr)
  end
end
function ClientBanLogic.IsVoiceReportEnable()
  print(bWriteLog and "debug Ban: IsVoiceReportEnable() ", ClientBanLogic.bEnableVoiceReport)
  return ClientBanLogic.bEnableVoiceReport
end
function ClientBanLogic.OnSyncMicSuspicious(SuspiciousFlag)
  ClientBanLogic.  print(bWriteLog and "debug Ban: OnSyncMicSuspicious ", SuspiciousFlag, ClientBanLogic.SuspiciousFlag)
  EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_SUSPICIOUS_FLAG, SuspiciousFlag)
end
function ClientBanLogic.OnSyncMicPreFilter(BanID)
  print(bWriteLog and "debug Ban: OnSyncMicPreFilter ", BanID)
  EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_MIC_PREFILTER, BanID)
end
function ClientBanLogic.OnSyncBanInfo(BanID, Flg)
  print(bWriteLog and "debug Ban: OnSyncBanInfo ", BanID, Flg)
  EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_VOICE_UNCONSCIOUS_BAN, BanID, Flg)
end
function ClientBanLogic.OnNotifyWarningTips(TextID, bOffMic)
  print(bWriteLog and "debug Ban: OnNotifyWarningTips " .. tostring(TextID) .. " " .. tostring(bOffMic))
  EventSystem:postEvent(EVENTTYPE_INGAME_BAN, EVENTID_INGAME_BAN_WARNING_TIPS, TextID, bOffMic)
end
return ClientBanLogic