local logic_community = require("client.slua.logic.community.logic_community_def")
function logic_community.CheckClubMatchSwitch()
  return logic_community.GetShowEntry() and LobbySystem.CheckOpen(BP_ENUM_CLUB_MACTH)
end
function logic_community.ConvertToGameSubscribeID(club_subscribe_id)
  local id = 0
  local c_id = tonumber(club_subscribe_id)
  if c_id and 0 <= c_id then
    id = 200000000 + c_id
  end
  return id
end
function logic_community.IsLaunchedByClubMatchNotification(notification_id)
  if not logic_community.GetShowEntry() then
    return false
  end
  notification_id = tonumber(notification_id)
  if 200000000 <= notification_id and notification_id < 300000000 then
    return true
  end
  return false
end
function logic_community.GetPushContent(push_tm)
  local TimeUtil = require("client.common.time_util")
  local tm = TimeUtil.FormatTime_MDHM(tonumber(push_tm), true)
  local content = LocUtil.LocalizeResFormat(32835, tm)
  return content
end
function logic_community.SaveSubscribeInfoToFile()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_community.SubscribeInfo, PlayerPrefsSystem.ePlayerPrefsType.eClubMatchSubscribeInfo)
end
function logic_community.LoadSubscribeInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  logic_community.SubscribeInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eClubMatchSubscribeInfo)
end
function logic_community.ReqClubMatchSubscription(bOnlyCurUser)
  local url = logic_community.GetVersionUrl() .. "/esports/schedule/subscribe_list"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  log(bWriteLog and "[janesjiang][Club] ReqClubMatchSubscription bOnlyCurUser " .. tostring(bOnlyCurUser) .. " openid " .. tostring(openid))
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json",
    ["Accept-Encoding"] = "gzip"
  }
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, "", nil, function(success, data)
    log(bWriteLog and "[janesjiang][Club] ReqClubMatchSubscription success " .. tostring(success))
    local tb = json.decode(data)
    log_tree("subscribe_item_tbl", tb)
    local subscribe_item_tbl
    if tb and not tb.error then
      subscribe_item_tbl = tb.subscribeItemList
    end
    logic_community.OnClubMatchSubscriptionRes(bOnlyCurUser, subscribe_item_tbl)
  end)
end
function logic_community.OnClubMatchSubscriptionRes(bOnlyCurUser, subscribeItemTbl)
  log(bWriteLog and "[janesjiang][Club] LocalPushSystem.OnClubMatchSubscriptionRes")
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  logic_community.LoadSubscribeInfo()
  if not logic_community.SubscribeInfo then
    logic_community.SubscribeInfo = {}
  end
  if logic_community.SubscribeInfo and logic_community.SubscribeInfo[openid] then
    for k, v in pairs(logic_community.SubscribeInfo[openid]) do
      Client.CancelLocalNotification(k)
    end
  end
  if subscribeItemTbl then
    logic_community.SubscribeInfo[openid] = {}
    local g_id = 0
    for k, v in pairs(subscribeItemTbl) do
      if v then
        g_id = logic_community.ConvertToGameSubscribeID(v.id)
        if 0 < g_id then
          logic_community.SubscribeInfo[openid][g_id] = tonumber(v.pushTime)
        end
      end
    end
    logic_community.SaveSubscribeInfoToFile()
  else
    log(bWriteLog and "[janesjiang][Club] subscribeItemTbl is nil")
  end
  local title = LocUtil.GetLocalizeResStr(32836)
  local body = ""
  if bOnlyCurUser then
    for push_id, push_tm in pairs(logic_community.SubscribeInfo[openid]) do
      body = logic_community.GetPushContent(push_tm)
      logic_community.SetPush(push_id, push_tm, title, body, true)
    end
  else
    for _, info in pairs(logic_community.SubscribeInfo) do
      if info and type(info) == "table" then
        for push_id, push_tm in pairs(info) do
          body = logic_community.GetPushContent(push_tm)
          logic_community.SetPush(push_id, push_tm, title, body, true)
        end
      end
    end
  end
end
function logic_community.UpdateSubscribeInfo(op_type, club_subscribe_id, push_tm)
  local g_id = logic_community.ConvertToGameSubscribeID(club_subscribe_id)
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  if g_id <= 0 then
    log(bWriteLog and "[janesjiang][Club] UpdateSubscribeInfo invalid club subscribe id " .. tostring(club_subscribe_id))
    return
  end
  log(bWriteLog and string.format("[janesjiang][Club] logic_community.UpdateSubscribeInfo optype[%s] club_subscribe_id[%s] push_tm[%s]", tostring(op_type), tostring(club_subscribe_id), tostring(push_tm)))
  if op_type == 1 then
    logic_community.LoadSubscribeInfo()
    if not logic_community.SubscribeInfo then
      logic_community.SubscribeInfo = {}
    end
    log_tree("Club SubscribeInfo", logic_community.SubscribeInfo)
    if not logic_community.SubscribeInfo[openid] then
      logic_community.SubscribeInfo[openid] = {}
    end
    logic_community.SubscribeInfo[openid][g_id] = tonumber(push_tm)
    logic_community.SaveSubscribeInfoToFile()
    local title = LocUtil.GetLocalizeResStr(32836)
    local body = ""
    body = logic_community.GetPushContent(push_tm)
    logic_community.SetPush(g_id, tonumber(push_tm), title, body, true)
  elseif op_type == 2 then
    logic_community.LoadSubscribeInfo()
    if logic_community.SubscribeInfo and logic_community.SubscribeInfo[openid] and logic_community.SubscribeInfo[openid][g_id] then
      logic_community.SubscribeInfo[openid][g_id] = nil
      logic_community.SaveSubscribeInfoToFile()
      Client.CancelLocalNotification(g_id)
    end
  else
    log(bWriteLog and "[janesjiang][Club] UpdateSubscribeInfo invalid op_type " .. tostring(op_type))
  end
end
function logic_community.OnNotifyUserSubscribeGame(ret, op_type, push_id, push_tm)
  if not logic_community.GetShowEntry() then
    log(bWriteLog and "[janesjiang][Club] OnNotifyUserSubscribeGame entry false")
    return
  end
  if ret == 0 then
    logic_community.UpdateSubscribeInfo(op_type, push_id, push_tm)
  else
    log(bWriteLog and "[janesjiang][Club] OnNotifyUserSubscribeGame error code " .. tostring(ret))
  end
end
function logic_community.CheckPush(push_tm)
  local TimeUtil = require("client.common.time_util")
  local nowClient = TimeUtil.OSTime()
  if nowClient > tonumber(push_tm) then
    return false
  end
  local date = TimeUtil.GetDateByUnixTime(tonumber(push_tm), true)
  local hour = date.hour or 0
  local ConstPush = require("client.slua.logic.push.ConstPush")
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local StartHour = ConstPush.PUSH_START_HOUR
  if strRegion == PublishRegionMacros.KOREA then
    StartHour = ConstPush.PUSH_START_HOUR_KR
  end
  local EndHour = ConstPush.PUSH_END_HOUR
  if strRegion == PublishRegionMacros.KOREA then
    EndHour = ConstPush.PUSH_END_HOUR_KR
  end
  if hour >= StartHour and hour < EndHour then
    return true
  else
    return false
  end
end
function logic_community.SetPush(push_id, push_tm, title, body, bLocalTime)
  local TimeUtil = require("client.common.time_util")
  if push_id and 0 < push_id and logic_community.CheckPush(push_tm) then
    local date = TimeUtil.GetDateByUnixTime(tonumber(push_tm), bLocalTime)
    log(bWriteLog and "[janesjiang][Club] SetPush year:" .. tostring(date.year) .. ",month:" .. tostring(date.month) .. ",day:" .. tostring(date.day) .. ",hour:" .. tostring(date.hour) .. ",minute:" .. tostring(date.min) .. ",second:" .. tostring(date.sec) .. ",title:" .. tostring(title) .. ",body:" .. tostring(body) .. ",id:" .. tostring(push_id))
    Client.ScheduleLocalNotificationAtTime(date.year or 0, date.month or 0, date.day or 0, date.hour or 0, date.min or 0, date.sec or 0, bLocalTime, title or "", body or "", "", push_id)
  else
    log(bWriteLog and "[janesjiang][Club] SetPush push_tm:" .. tostring(push_tm) .. ",id:" .. tostring(push_id))
  end
end