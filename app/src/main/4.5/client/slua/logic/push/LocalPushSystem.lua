local LocalPushSystem = {
  cfg = nil,
  data = nil,
  callbackList = nil,
  bSysOpen = false,
  pushTable = {}
}
function LocalPushSystem:OnLogin(bReLogin)
  log(bWriteLog and "LocalPushSystem:OnLogin")
  local ConstPush = require("client.slua.logic.push.ConstPush")
  self:AddTimerOnce(ConstPush.START_REQ_EXTRA_DATA, function()
    self:_ReqExtraData()
  end)
  self:AddTimerOnce(ConstPush.START_LOCAL_PUSH_LATER_SECONDS, function()
    self:GetLocalPushCfgReq()
  end)
end
function LocalPushSystem:GetLocalPushCfgReq(callback)
  if self.cfg then
    if callback then
      callback()
    end
    return
  end
  if callback then
    self.callbackList = self.callbackList or {}
    table.insert(self.callbackList, callback)
  end
  local FCMPushHandler = require("client.network.Protocol.FCMPushHandler")
  FCMPushHandler.send_get_msg_push_cfg_req()
end
function LocalPushSystem:on_get_msg_push_cfg_rsp(cfg, data)
  log(bWriteLog and "LocalPushSystem:on_get_msg_push_cfg_rsp")
  self.  self.  self:SetLocalPush()
  if self.callbackList and #self.callbackList > 0 then
    for _, v in pairs(self.callbackList) do
      if v then
        v()
        v = nil
      end
    end
  end
  self.callbackList = nil
end
function LocalPushSystem:SetLocalPush()
  log(bWriteLog and "LocalPushSystem:SetLocalPush")
  Client.ClearAllLocalNotifications()
  if not self.cfg then
    return
  end
  local IntlHelper = import("IntlHelper")
  self.bSysOpen = IntlHelper.IsRemoteNotificationsEnabled()
  if not self.bSysOpen then
    log(bWriteLog and "LocalPushSystem:SetLocalPush bSysOpen is false")
    return
  end
  self.pushTable = {}
  for i, v in pairs(self.cfg) do
    self:_GetOneLocalPushData(self.pushTable, i)
  end
  self:_SetLocalPushByPushTable(self.pushTable)
end
function LocalPushSystem:SetLocalPushByCfgID(push_id)
  log(bWriteLog and "LocalPushSystem:SetLocalPushByCfgID push_id:" .. tostring(push_id))
  local pushList = {}
  self:_GetOneLocalPushData(pushList, push_id)
  self:_SetLocalPushByPushTable(pushList, true, push_id)
end
function LocalPushSystem:SetLocalPushByConditionID(CondID)
  log(bWriteLog and "LocalPushSystem:SetLocalPushByCfgID CondID:" .. tostring(CondID))
  if not (self.cfg and self.pushTable) or not next(self.pushTable) then
    log(bWriteLog and "LocalPushSystem:SetLocalPushByCfgID cfg or pushTable is nil CondID:" .. tostring(CondID))
    return
  end
  local pushList = {}
  for i, v in pairs(self.pushTable) do
    local cfg = self.cfg[v.push_id]
    if cfg and (cfg.push_cond1 == CondID or cfg.push_cond2 == CondID or cfg.push_cond3 == CondID or cfg.push_cond4 == CondID) then
      self:_GetOneLocalPushData(pushList, v.push_id)
    end
  end
  self:_SetLocalPushByPushTable(pushList, true)
end
function LocalPushSystem:GetPushCfgByID(id)
  if not id or tonumber(id) == 0 then
    return nil
  end
  if not self.cfg or not next(self.cfg) then
    return nil
  end
  local push_id = self:CalculatePushId(id)
  return self.cfg[push_id]
end
function LocalPushSystem:UpdateMarkLabelPush()
  local ConstPush = require("client.slua.logic.push.ConstPush")
  self:SetLocalPushByConditionID(ConstPush.Enum_Condition_Type.Enum_PlayerLabel)
end
function LocalPushSystem:OnApplicationEnterBackground()
  self:_CheckUpdateLocalPush()
end
function LocalPushSystem:OnApplicationEnterForeground()
  self:_CheckUpdateLocalPush()
end
function LocalPushSystem:SetTestPush(id)
  log(bWriteLog and "LocalPushSystem:SetTestPush id:" .. tostring(id))
  local success = false
  local TimeUtil = require("client.common.time_util")
  local cfg = self:GetPushCfgByID(id)
  if cfg then
    log_tree(bWriteLog and "LocalPushSystem:SetTestPush cfg:", cfg)
    local nowClient = TimeUtil.OSTime() + 30
    local date = TimeUtil.GetDateByUnixTime(nowClient, true)
    local data = {}
    data.    data.year = date.year or 0
    data.month = date.month or 0
    data.day = date.day or 0
    data.hour = date.hour or 0
    data.minute = date.min or 0
    data.second = date.sec or 0
    data.title = cfg.push_title_client or ""
    data.body = cfg.push_content_client or ""
    self:SetPush(data)
    Time = TimeUtil.FormatTime_YMDHMS(nowClient, true)
    local string = string.format([[
Id:%s
Title:%s
Content:%s
Time:%s]], tostring(data.id), tostring(data.title), tostring(data.body), tostring(Time))
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, "", string)
    success = true
  end
  return success
end
function LocalPushSystem:SetPushByIdAndTime(id, timeLeft)
  local TimeUtil = require("client.common.time_util")
  local cfg = self:GetPushCfgByID(id)
  if cfg then
    log_tree(bWriteLog and "LocalPushSystem:SetTestPush cfg:", cfg)
    local nowClient = TimeUtil.OSTime() + timeLeft
    local date = TimeUtil.GetDateByUnixTime(nowClient, true)
    local data = {}
    data.    data.year = date.year or 0
    data.month = date.month or 0
    data.day = date.day or 0
    data.hour = date.hour or 0
    data.minute = date.min or 0
    data.second = date.sec or 0
    data.title = cfg.push_title_client or ""
    data.body = cfg.push_content_client or ""
    self:SetPush(data)
  end
end
function LocalPushSystem:SetPush(data)
  if data and data.id and tonumber(data.id) > 0 then
    log(bWriteLog and "LocalPushSystem:SetPush year:" .. tostring(data.year) .. ",month:" .. tostring(data.month) .. ",day:" .. tostring(data.day) .. ",hour:" .. tostring(data.hour) .. ",minute:" .. tostring(data.minute) .. ",second:" .. tostring(data.second) .. ",title:" .. tostring(data.title) .. ",body:" .. tostring(data.body) .. ",id:" .. tostring(data.id))
    Client.ScheduleLocalNotificationAtTime(data.year or 0, data.month or 0, data.day or 0, data.hour or 0, data.minute or 0, data.second or 0, true, data.title or "", data.body or "", "", data.id)
  end
end
function LocalPushSystem:CancelPush(id)
  if id and tonumber(id) > 0 then
    local bExist = self:_HasPushExist(id)
    if bExist then
      log(bWriteLog and "LocalPushSystem:CancelPush id:" .. tostring(id))
      Client.CancelLocalNotification(id)
    end
  end
end
function LocalPushSystem:_ReqExtraData()
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  SocialCardSystem.get_social_card()
  local logic_community = require("client.slua.logic.community.logic_community")
  if not logic_community.SubscribeInfo and logic_community.CheckClubMatchSwitch() then
    logic_community.ReqClubMatchSubscription(false)
  end
end
function LocalPushSystem:_GetOneLocalPushData(pushTable, push_id)
  if not push_id or push_id <= 0 or not self.cfg then
    log(bWriteLog and "LocalPushSystem:_GetOneLocalPushData cfg is nil or push_id is:" .. tostring(push_id))
    return
  end
  local pushCfg = self.cfg[push_id]
  if not pushCfg then
    log(bWriteLog and "LocalPushSystem:_GetOneLocalPushData pushCfg is nil, push_id is:" .. tostring(push_id))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowClient = TimeUtil.OSTime()
  local isValid = self:_CheckPushByID(pushCfg, push_id, nowClient)
  if not isValid then
    return
  end
  pushTable = pushTable or {}
  local id = self:CalculateLocalId(push_id, pushCfg.push_type)
  local LocalPushSetInfo = require("client.slua.logic.push.LocalPushSetInfo")
  LocalPushSetInfo:GetPushSetInfo(id, pushCfg, pushTable)
end
function LocalPushSystem:_SetLocalPushByPushTable(pushTable, bCancelPre, id)
  if not pushTable or not next(pushTable) then
    log(bWriteLog and "LocalPushSystem:_SetLocalPushByPushTable pushTable is nil, id:" .. tostring(id))
    return
  end
  for j, u in pairs(pushTable) do
    if u.id and tonumber(u.id) > 0 then
      if bCancelPre then
        self:CancelPush(u.id)
        pushTable[u.id] = nil
      end
      self:SetPush(u)
    end
    if u.cycleTable and next(u.cycleTable) then
      for jj, uu in pairs(u.cycleTable) do
        if uu.id and uu.id > 0 then
          if bCancelPre then
            self:CancelPush(uu.id)
            u.cycleTable[uu.id] = nil
          end
          self:SetPush(uu)
        end
      end
    end
  end
end
function LocalPushSystem:_CheckPushByID(pushCfg, push_id, nowClient)
  if not pushCfg then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local startTime = TimeUtil.TimeStringToUnixstamp(pushCfg.start_time)
  local endTime = TimeUtil.TimeStringToUnixstamp(pushCfg.end_time)
  if nowClient < startTime or nowClient > endTime then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match ClientTime nowClient:" .. TimeUtil.FormatTime_MDHMS(nowClient) .. " startTime:" .. pushCfg.start_time .. " endTime:" .. pushCfg.end_time .. " push_id:" .. tostring(push_id))
    return false
  end
  local PushUtil = require("client.slua.logic.push.PushUtil")
  local gameID = Client.GetITopGameId()
  if not PushUtil:_IsValidKey(pushCfg.client_gameid, gameID) then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match gameId:" .. pushCfg.client_gameid .. " push_id:" .. tostring(push_id))
    return false
  end
  local version_util = require("client.common.version_util")
  if pushCfg.limit_app_ver and tostring(pushCfg.limit_app_ver) ~= "" and tostring(pushCfg.limit_app_ver) ~= "0" then
    local appVer = version_util.GetClientFormat(Client.GetAppVersion())
    if PushUtil:_IsValidKey(pushCfg.limit_app_ver, appVer) then
      log(bWriteLog and "LocalPushSystem:_CheckPushByID not match limit_app_ver:" .. tostring(pushCfg.limit_app_ver) .. " appVer:" .. tostring(appVer) .. " push_id:" .. tostring(push_id))
      return false
    end
  end
  local regionID = Client.GetIPRegion()
  if pushCfg.limit_country and tostring(pushCfg.limit_country) ~= "" and tostring(pushCfg.limit_country) ~= "0" and PushUtil:_IsValidKey(pushCfg.limit_country, regionID) then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match limit_country:" .. tostring(pushCfg.limit_country) .. " regionID:" .. tostring(regionID) .. " push_id:" .. tostring(push_id))
    return false
  end
  if not PushUtil:_IsValidKey(pushCfg.push_country, regionID) then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match push_country:" .. tostring(pushCfg.push_country) .. " regionID:" .. tostring(regionID) .. " push_id:" .. tostring(push_id))
    return false
  end
  local strLanguage = string.lower(Client.GetCurrentLanguage())
  if not PushUtil:_IsValidKey(pushCfg.push_lang, strLanguage) then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match push_lang:" .. tostring(pushCfg.push_lang) .. " strLanguage:" .. tostring(strLanguage) .. " push_id:" .. tostring(push_id))
    return false
  end
  local level = DataMgr.roleData.level
  if pushCfg.level_limit and tonumber(pushCfg.level_limit) > 0 and level < pushCfg.level_limit then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match level_limit:" .. tostring(pushCfg.level_limit) .. " level:" .. tostring(level) .. " push_id:" .. tostring(push_id))
    return false
  end
  local isCon1 = self:_CheckPushByCondition(pushCfg.push_cond1, pushCfg.push_param1)
  if not isCon1 then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match push_cond1:" .. tostring(pushCfg.push_cond1) .. " push_param1:" .. tostring(pushCfg.push_param1) .. " push_id:" .. tostring(push_id))
    return false
  end
  local isCon2 = self:_CheckPushByCondition(pushCfg.push_cond2, pushCfg.push_param2)
  if not isCon2 then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match push_cond2:" .. tostring(pushCfg.push_cond2) .. " push_param2:" .. tostring(pushCfg.push_param2) .. " push_id:" .. tostring(push_id))
    return false
  end
  local isCon3 = self:_CheckPushByCondition(pushCfg.push_cond3, pushCfg.push_param3)
  if not isCon3 then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match push_cond3:" .. tostring(pushCfg.push_cond3) .. " push_param3:" .. tostring(pushCfg.push_param3) .. " push_id:" .. tostring(push_id))
    return false
  end
  local isCon4 = self:_CheckPushByCondition(pushCfg.push_cond4, pushCfg.push_param4)
  if not isCon4 then
    log(bWriteLog and "LocalPushSystem:_CheckPushByID not match push_cond4:" .. tostring(pushCfg.push_cond4) .. " push_param4:" .. tostring(pushCfg.push_param4) .. " push_id:" .. tostring(push_id))
    return false
  end
  return true
end
function LocalPushSystem:_CheckPushByCondition(condID, condValue)
  if not condID or condID <= 0 or not condValue then
    return true
  end
  local ConstPush = require("client.slua.logic.push.ConstPush")
  if condID == ConstPush.Enum_Condition_Type.Enum_PayUC then
    if self.data and tonumber(self.data.save_amt) >= tonumber(condValue) then
      return true
    end
    return false
  elseif condID == ConstPush.Enum_Condition_Type.Enum_PassLevelArea or condID == ConstPush.Enum_Condition_Type.Enum_PassScoreArea then
    local s, e = string.find(condValue, "-")
    if s == nil then
      return true
    end
    local min = tonumber(string.sub(condValue, 0, s - 1))
    local max = tonumber(string.sub(condValue, s + 1))
    if 0 < min and min <= max then
      if condID == ConstPush.Enum_Condition_Type.Enum_PassLevelArea then
        if min <= UnknowPassSystem.Level and max >= UnknowPassSystem.Level then
          return true
        end
      elseif condID == ConstPush.Enum_Condition_Type.Enum_PassScoreArea and min <= UnknowPassSystem.Score and max >= UnknowPassSystem.Score then
        return true
      end
    else
      return true
    end
    return false
  elseif condID == ConstPush.Enum_Condition_Type.Enum_PlayerLabel then
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    local save = growthprojectMgrB.CheckPlayerLabelByID(condValue)
    return save
  elseif condID == ConstPush.Enum_Condition_Type.Enum_AllStar then
    local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
    local save = ESportAllStarSystem.CheckPushConditionTime(tonumber(condValue))
    return save
  elseif condID == ConstPush.Enum_Condition_Type.Enum_ComeBack_Flag then
    if DataMgr.RejoinTaskData and DataMgr.RejoinTaskData.is_back_user then
      return true
    end
    return false
  elseif condID == ConstPush.Enum_Condition_Type.Enum_PreLoss_LoginReward then
    local logic_prechurn_loginreward = require("client.slua.logic.activity.logic_prechurn_loginreward")
    local time = logic_prechurn_loginreward.GetNextLocalPushTime()
    if time then
      return true
    end
    return false
  elseif condID == ConstPush.Enum_Condition_Type.Enum_User_Label then
    local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
    if PlayerLabelHandler.labelResult[tonumber(condValue)] then
      return true
    end
    if PlayerLabelHandler.markLabelResult[tonumber(condValue)] then
      return true
    end
    return false
  end
  return true
end
function LocalPushSystem:_HasPushExist(id)
  local localPushIDs = Client.GetAllLocalNotificationIDs()
  if localPushIDs and next(localPushIDs) then
    for i, v in pairs(localPushIDs) do
      if tonumber(v) == tonumber(id) then
        return true
      end
    end
  end
  return false
end
function LocalPushSystem:_CheckUpdateLocalPush()
  if not self.cfg then
    return
  end
  local IntlHelper = import("IntlHelper")
  local bCurSysOpen = IntlHelper.IsRemoteNotificationsEnabled()
  if bCurSysOpen ~= self.bSysOpen then
    self:SetLocalPush()
  end
end
function LocalPushSystem:CalculateLocalId(pushId, pushType)
  local id = 0
  if pushId < 1000 then
    id = 100000 * tonumber(pushType) + 100 * tonumber(pushId) + 10 + 1
  else
    id = 100000000 + 100000 * tonumber(pushType) + tonumber(pushId) * 10 + 1
  end
  return id
end
function LocalPushSystem:CalculatePushId(Id)
  local pushId = 0
  if 100000000 <= Id and Id < 200000000 then
    pushId = math.floor((Id - 100000000) % 100000 / 10)
  else
    pushId = math.floor(math.fmod(Id, 100000) / 100)
  end
  return pushId
end
function LocalPushSystem:CalculatePushType(Id)
  local pushType = 0
  if 100000000 <= Id and Id < 200000000 then
    pushType = math.floor((Id - 100000000) / 100000)
  else
    pushType = math.floor(Id / 100000)
  end
  return pushType
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLocalPushSystem = class(CModuleBase, nil, LocalPushSystem)
return CLocalPushSystem