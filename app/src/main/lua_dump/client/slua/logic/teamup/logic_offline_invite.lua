local OfflineInviteSystem = {
  nSettingOpen = nil,
  nMessengerSetting = nil,
  bAllCanInvite = true,
  tInviteRecord = {},
  E_Invite_Type = {Messagener = 1, FCM = 2}
}
function OfflineInviteSystem.SetCurFcmSettingState()
  local OfflineInvite
  local open_index = DataMgr.GetRoleSetting(RoleSettingType.OfflineInvite)
  if not OfflineInviteSystem.nSettingOpen then
    OfflineInviteSystem.nSettingOpen = open_index
  else
    OfflineInviteSystem.nSettingOpen = OfflineInviteSystem.nSettingOpen == 0 and 1 or 0
  end
  if OfflineInviteSystem.nSettingOpen == 1 then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Close_Offline_Invite)
  end
end
function OfflineInviteSystem.SetMessagenerSettingState()
  local open_index = DataMgr.GetRoleSetting(RoleSettingType.GlobalMessagener)
  if not OfflineInviteSystem.nMessengerSetting then
    OfflineInviteSystem.nMessengerSetting = open_index
  else
    OfflineInviteSystem.nMessengerSetting = OfflineInviteSystem.nMessengerSetting == 0 and 1 or 0
  end
end
function OfflineInviteSystem.JudgeUseFcmOrMessagener(bMessagener, uid)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if GlobalData.IsJapanOrKorea() or Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    if OfflineInviteSystem.GetMessengerInviteIsOpen() and bMessagener and OfflineInviteSystem.IsGlobalInviteOpened(uid) then
      return OfflineInviteSystem.E_Invite_Type.Messagener
    end
    if OfflineInviteSystem.GetOfflineInviteIsOpen() then
      return OfflineInviteSystem.E_Invite_Type.FCM
    end
  elseif bMessagener and OfflineInviteSystem.GetMessengerInviteIsOpen() and OfflineInviteSystem.IsGlobalInviteOpened(uid) then
    return OfflineInviteSystem.E_Invite_Type.Messagener
  end
  return false
end
function OfflineInviteSystem.GetCurFcmSettingState()
  if not OfflineInviteSystem.nSettingOpen then
    OfflineInviteSystem.nSettingOpen = DataMgr.GetRoleSetting(RoleSettingType.OfflineInvite)
  end
  return OfflineInviteSystem.nSettingOpen
end
function OfflineInviteSystem.GetCurMesengerSettingValue()
  if not OfflineInviteSystem.nMessengerSetting then
    OfflineInviteSystem.nMessengerSetting = DataMgr.GetRoleSetting(RoleSettingType.GlobalMessagener)
  end
  return OfflineInviteSystem.nMessengerSetting
end
function OfflineInviteSystem.IsKrJpFriend(uid)
  if string.sub(uid, 1, 1) == "6" then
    return true
  end
  return false
end
function OfflineInviteSystem.GetOfflineInviteIsOpen()
  local bOpen = LobbySystem.CheckOpen(BP_ENUM_MOUDLE_OFFLINE_INVITE)
  log(bWriteLog and "[v_vyhhzhang]  OfflineInviteSystem GetOfflineInviteIsOpen= is_open " .. tostring(bOpen))
  return bOpen
end
function OfflineInviteSystem.GetMessengerInviteIsOpen()
  local bOpen = LobbySystem.CheckOpen(BP_ENUM_MOUDLE_MESSENGER_INVITE)
  log(bWriteLog and "[v_zhanggao]  OfflineInviteSystem GetMessengerInviteIsOpen= is_open " .. tostring(bOpen))
  return bOpen
end
function OfflineInviteSystem.GetTokenByOperate()
  local ScriptHelperClient = import("ScriptHelperClient")
  local token = ScriptHelperClient.GetFireBaseFCMToken() or ""
  return token
end
function OfflineInviteSystem.GetSystemPushSwitch()
  local IntlHelper = import("IntlHelper")
  local is_open = IntlHelper.IsRemoteNotificationsEnabled()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if not is_open then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.System_Push_Close, 1, "System_Push_Close")
  else
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.System_Push_Close, 0, "System_Push_Open")
  end
end
local _FindDataByLink = function(link, sValue)
  local idx = string.find(link, sValue)
  local data = 0
  if idx and 0 < tonumber(idx) then
    local beginIdx = idx + string.len(sValue)
    local endIdx = string.find(link, "&")
    if endIdx and 0 < tonumber(endIdx) then
      data = tonumber(string.sub(link, beginIdx, endIdx - 1))
      link = string.sub(link, endIdx + 1)
    else
      data = string.sub(link, beginIdx, string.len(link))
    end
  end
  log(bWriteLog and "[v_vyhhzhang]  OfflineInviteSystem sValue " .. tostring(sValue))
  log(bWriteLog and "[v_vyhhzhang]  OfflineInviteSystem data " .. tostring(data))
  return data, link
end
function OfflineInviteSystem.JoinInFcmTeam(link)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Accpet_Offline_Invite)
  local invite, link1 = _FindDataByLink(link, "inviter=")
  local teamid, link2 = _FindDataByLink(link1, "team_id=")
  local src, link3 = _FindDataByLink(link2, "src=")
  local from, link4 = _FindDataByLink(link3, "from=")
  local version, link5 = _FindDataByLink(link4, "invite_client=")
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamupHandler.send_team_invite_reply(NetErrorCode_NONE, invite, teamid, tonumber(src), tonumber(from), version)
end
function OfflineInviteSystem.RecordInviteTime(uid)
  if not OfflineInviteSystem.tInviteRecord[uid] then
    OfflineInviteSystem.tInviteRecord[uid] = {}
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  OfflineInviteSystem.tInviteRecord[uid].time = serverTime
end
function OfflineInviteSystem.RecordInviteForbid(uid)
  if not OfflineInviteSystem.tInviteRecord[uid] then
    OfflineInviteSystem.tInviteRecord[uid] = {}
  end
  OfflineInviteSystem.tInviteRecord[uid].isLimit = true
end
function OfflineInviteSystem.IsOfflineInviteAwake(str)
  if string.find(str, "inviter=") and string.find(str, "team_id=") then
    return true
  end
  return false
end
function OfflineInviteSystem.IsCanInvite(uid)
  if GlobalData.IsJapanOrKorea() and not OfflineInviteSystem.IsKrJpFriend(uid) then
    log(bWriteLog and "ZYH\228\184\141\230\152\175\230\151\165\233\159\169\229\165\189\229\143\139")
    return false
  end
  if not OfflineInviteSystem.IsOfflineInviteOpened(uid) then
    log(bWriteLog and "ZYH\229\175\185\230\150\185\229\133\179\233\151\173\228\186\134\231\166\187\231\186\191\233\130\128\232\175\183\232\174\190\231\189\174")
    return false
  end
  local intimacyLimit = 0
  local cfg = CDataTable.GetTableData("SettingNotificationParamConfig", "offline_invite_intimacy_min")
  if cfg then
    intimacyLimit = cfg.ParamValue
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendData = LogicFriend.GetFriendData(uid)
  local intimacy = friendData and friendData.intimacy or 0
  if intimacy == 0 then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    intimacy = profile and profile.intimacy or 0
  end
  if intimacyLimit > intimacy then
    return false
  end
  if OfflineInviteSystem.bAllCanInvite then
    if not OfflineInviteSystem.tInviteRecord[uid] then
      log(bWriteLog and "ZYH\229\141\149\228\184\170\229\165\189\229\143\139\233\153\144\229\136\182")
      return true
    else
      local TimeUtil = require("client.common.time_util")
      local serverTime = TimeUtil.GetServerTimeInSec()
      if OfflineInviteSystem.tInviteRecord[uid].isLimit or serverTime - OfflineInviteSystem.tInviteRecord[uid].time <= 300 then
        log(bWriteLog and "ZYH\229\141\149\228\184\170\229\165\189\229\143\139\230\151\182\233\151\180\233\153\144\229\136\182")
        return false
      else
        return true
      end
    end
  else
    log(bWriteLog and "ZYH\233\130\128\232\175\183\230\128\187\233\153\144\229\136\182")
    return false
  end
end
function OfflineInviteSystem.IsOfflineInviteOpened(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile and profile.offline_invite_setting == 1 then
    log(bWriteLog and "[DeanJYT] OfflineInviteSystem.IsOfflineInviteOpened false")
    return false
  end
  log(bWriteLog and "[DeanJYT] OfflineInviteSystem.IsOfflineInviteOpened true")
  return true
end
function OfflineInviteSystem.IsGlobalInviteOpened(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile and profile.Messeger_invite_setting == 1 then
    log(bWriteLog and "[DeanJYT] OfflineInviteSystem.IsOfflineInviteOpened false")
    return false
  end
  log(bWriteLog and "[DeanJYT] OfflineInviteSystem.IsOfflineInviteOpened true")
  return true
end
function OfflineInviteSystem.OnModePostSwitch(_, __, gamestatus)
  if gamestatus.current == GameStatus.Lobby then
    OfflineInviteSystem.GetSystemPushSwitch()
  end
end
return OfflineInviteSystem