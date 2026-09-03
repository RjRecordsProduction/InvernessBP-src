local Logic_UGC_ThemePlay_ActivityTemplate = {}
local TimeUtil = require("client.common.time_util")
local config_ugc_theme_play_activity_template
Logic_UGC_ThemePlay_ActivityTemplate.TaskType = {SubTask = 265, MainTask = 247}
function Logic_UGC_ThemePlay_ActivityTemplate:ctor()
  self.DataTimerCD = 300
  self.ActivityData = nil
  self.ActivityDataTimeStamp = nil
  self.MatchHubData = nil
  self.my_match_list = {}
  self.CurrActiveSelsctedActID = nil
end
function Logic_UGC_ThemePlay_ActivityTemplate:OnInitialize()
end
function Logic_UGC_ThemePlay_ActivityTemplate:RegistEvents()
end
function Logic_UGC_ThemePlay_ActivityTemplate:OnLogin()
end
function Logic_UGC_ThemePlay_ActivityTemplate:OnLogOut()
  self.ActivityData = nil
  self.ActivityDataTimeStamp = nil
  self.MatchHubData = nil
  self.my_match_list = {}
end
function Logic_UGC_ThemePlay_ActivityTemplate:ReqSeasonActivityData()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local bWOWOpen = LogicUGC:IsWOWOpen()
  if not bWOWOpen then
    return
  end
  self:ReqMatchHubActivityData()
  if self:CheckActivityDataValid() then
    log(bWriteLog and "Logic_UGC_ThemePlay_ActivityTemplate:ReqSeasonActivityData dataValid no need to req")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_THEMEPLAY_ACTIVITY_TEMPLATE_GETSEASON_CFG)
    return
  end
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_get_ugc_comm_cfg_req(config_ugc_theme_play_activity_template.C_RequestType.gamecenter)
end
function Logic_UGC_ThemePlay_ActivityTemplate:RspSeasonActivityData(set_type, cfgs)
  if set_type ~= config_ugc_theme_play_activity_template.C_RequestType.gamecenter then
    return
  end
  self.ActivityDataTimeStamp = TimeUtil.GetServerTimeInSec()
  self.ActivityData = cfgs
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_THEMEPLAY_ACTIVITY_TEMPLATE_GETSEASON_CFG)
end
function Logic_UGC_ThemePlay_ActivityTemplate:CheckActivityDataValid()
  local TableUtil = require("common.table_util")
  if not self.ActivityData or TableUtil.CountTable(self.ActivityData) <= 0 then
    log(bWriteLog and "Logic_UGC_ThemePlay_ActivityTemplate:CheckActivityDataValid ActivityData is nil")
    return false
  end
  if not self.ActivityDataTimeStamp then
    log(bWriteLog and "Logic_UGC_ThemePlay_ActivityTemplate:CheckActivityDataValid ActivityDataTimeStamp is nil")
    return false
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.ActivityDataTimeStamp + self.DataTimerCD
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetSeasonStep(season_act)
  local serverTime = TimeUtil.GetServerTimeInSec()
  local time_line = season_act and season_act.activity_info and season_act.activity_info.time_line or {}
  for _, k in pairs(time_line) do
    local start_time = k.period[1] or 0
    local end_time = k.period[2] or 0
    if start_time and type(start_time) == "number" and end_time and type(end_time) == "number" and serverTime >= start_time and serverTime <= end_time then
      return k
    end
  end
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetThemeActData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local ActList = ActivityNewSystem.GetActivityListByType(10)
  local currTime = TimeUtil.GetServerTimeInSec()
  local valid_activity
  for _, v in ipairs(ActList or {}) do
    if v.StartTime and v.EndTime and currTime >= v.StartTime and currTime <= v.EndTime and v.back_int_value == 265 then
      local data = {
        nActID = v.ID,
        sName = v.Title,
        nSwitchType = ActivitySwitchType.Welfare,
        startTime = v.StartTime,
        endTime = v.EndTime,
        ImgUrl = v.ImgUrl,
        Order = v.Order,
        Desc = v.Desc,
        Detail = v.Detail,
        DisplayScene = v.DisplayScene,
        bRedDot = function(actId)
          local hasReward = self:CheckMyReward(actId)
          if hasReward then
            return true, ActivityMacros.RedDotType.Reward
          end
          return false, ActivityMacros.RedDotType.None
        end
      }
      valid_activity = valid_activity or {}
      table.insert(valid_activity, data)
    end
  end
  return valid_activity
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetThemePlayCollectionActDataByActID(actID)
  local valid_activity = self:GetThemeActData()
  for _, v in ipairs(valid_activity or {}) do
    if v.nActID == actID then
      return v
    end
  end
end
function Logic_UGC_ThemePlay_ActivityTemplate:ReqMatchHubActivityData()
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_get_ugc_comm_cfg_req(config_ugc_theme_play_activity_template.C_RequestType.match_hub)
end
function Logic_UGC_ThemePlay_ActivityTemplate:RspMatchHubActivityData(set_type, cfgs)
  if set_type ~= config_ugc_theme_play_activity_template.C_RequestType.match_hub then
    return
  end
  self.MatchHubData = cfgs
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_THEMEPLAY_ACTIVITY_TEMPLATE_MATCHHUB_CFG)
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetMatchHubCfg(act_id)
  local match_hub_cfg = {}
  for _, v in pairs(self.MatchHubData or {}) do
    if act_id == tonumber(v.activity_info.game_manage_id) then
      match_hub_cfg = v
      break
    end
  end
  return match_hub_cfg
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetSeasonActListByState(state, match_hub_cfg)
  if not match_hub_cfg or not next(match_hub_cfg) then
    return {}
  end
  local TableUtil = require("common.table_util")
  if not self.ActivityData or not next(self.ActivityData) then
    return {}
  end
  local season_cfgs = {}
  local StringUtil = require("common.string_util")
  local season_act_ids = StringUtil.Split(match_hub_cfg.activity_info.match_id_list, "|")
  local season_act_map = {}
  for _, v in pairs(self.ActivityData) do
    if not season_act_map[v.id] then
      season_act_map[v.id] = v
    end
  end
  for _, id in pairs(season_act_ids) do
    if season_act_map[tonumber(id)] then
      table.insert(season_cfgs, season_act_map[tonumber(id)])
    end
  end
  local list = {}
  local progress_list, over_list = {}, {}
  local cur_time = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(season_cfgs) do
    local activity_info = v.activity_info or {}
    if cur_time >= activity_info.start_time and cur_time <= activity_info.end_time then
      local data = TableUtil.CopyTable(v)
      data.sort = self:GetSortByTimeState(v)
      table.insert(progress_list, data)
    else
      table.insert(over_list, v)
    end
  end
  if state == config_ugc_theme_play_activity_template.C_Enum_CollectionPageTabType.progress then
    table.sort(progress_list, function(a, b)
      return a.sort < b.sort
    end)
    list = progress_list
  elseif state == config_ugc_theme_play_activity_template.C_Enum_CollectionPageTabType.Over then
    list = over_list
  elseif state == config_ugc_theme_play_activity_template.C_Enum_CollectionPageTabType.Joined then
    list = self.my_match_list
  end
  return list
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetSortByTimeState(data)
  local sort = 1
  local cur_time = TimeUtil.GetServerTimeInSec()
  local time_line = data.activity_info and data.activity_info.time_line or {}
  for _, k in pairs(time_line) do
    local start_time = k.period[1] or 0
    local end_time = k.period[2] or 0
    if start_time and type(start_time) == "number" and end_time and type(end_time) == "number" and cur_time >= start_time and cur_time <= end_time then
      sort = k.type
      break
    end
  end
  log(bWriteLog and "Logic_UGC_ThemePlay_ActivityTemplate:GetSortByTimeState data.id = " .. tostring(data.id) .. " sort = " .. tostring(sort))
  return sort
end
function Logic_UGC_ThemePlay_ActivityTemplate:SetMyMatchList(match_ids)
  if not match_ids or not next(match_ids) then
    return
  end
  self.my_match_list = {}
  local season_act_map = {}
  for _, v in pairs(self.ActivityData or {}) do
    if not season_act_map[v.id] then
      season_act_map[v.id] = v
    end
  end
  for _, match_id in pairs(match_ids) do
    if season_act_map[match_id] then
      table.insert(self.my_match_list, season_act_map[match_id])
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_THEMEPLAY_ACTIVITY_TEMPLATE_GET_MY_MATCH_LIST)
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetRealDataByFatherActID(nActID)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tActData = ActivityNewSystem.GetActivityByID(nActID)
  local tSubActData = {
    [1] = {},
    [2] = {},
    [3] = {}
  }
  if tActData and tActData.List then
    for _, v in pairs(tActData.List) do
      if v.Type == Logic_UGC_ThemePlay_ActivityTemplate.TaskType.SubTask then
        if v.Cycle and v.Cycle == 1 then
          table.insert(tSubActData[1], v)
        else
          table.insert(tSubActData[2], v)
        end
      elseif v.Type == Logic_UGC_ThemePlay_ActivityTemplate.TaskType.MainTask then
        table.insert(tSubActData[3], v)
      end
    end
  end
  return tSubActData
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetCurActThemeData(actID)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tSerVerData = ActivityNewSystem.GetServerDataByID(actID)
  if not tSerVerData or not tSerVerData.cfg then
    return {}
  end
  local sTheme = tSerVerData.cfg.back_up_one or ""
  local StringUtil = require("common.string_util")
  local data = StringUtil.Split(sTheme, "|") or {}
  return data
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetCurActModIDList(nActID)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local StringUtil = require("common.string_util")
  local tSubActData = {}
  local tSerVerData = ActivityNewSystem.GetActivityByID(nActID)
  if not tSerVerData then
    return nil
  end
  for _, v in pairs(StringUtil.Split(tSerVerData.BackupParam1, "|")) do
    if tonumber(v) == 0 then
      break
    end
    table.insert(tSubActData, tonumber(v))
  end
  return tSubActData
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetCurActReward(nActID)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tSubActData = {}
  local tSerVerData = ActivityNewSystem.GetActivityByID(nActID)
  if tSerVerData and tSerVerData.List then
    for _, v in pairs(tSerVerData.List) do
      if v.Type == Logic_UGC_ThemePlay_ActivityTemplate.TaskType.MainTask then
        table.insert(tSubActData, v)
      end
    end
  end
  return tSubActData
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetFirstValidActivityID(type)
  type = type and type ~= "" and type or "wow_lobby"
  local Activity = self:GetThemeActData()
  local config = CDataTable.GetTable("UGCThemePlayActivitySlapConfig")
  if not Activity or not config then
    return nil
  end
  local activityMap = {}
  for _, v in ipairs(Activity) do
    if v and v.nActID then
      activityMap[v.nActID] = v
    end
  end
  local validActIDs = {}
  for _, cfg in ipairs(config) do
    local actID = cfg and cfg.ActivityID
    if actID and activityMap[actID] then
      table.insert(validActIDs, actID)
    end
  end
  if not validActIDs or #validActIDs == 0 then
    return nil
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local shownRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCThemePlayActivityTemplateFaceSlapShown) or {}
  local shownParams = shownRecord.shownParams
  local typeShownMap = shownParams and shownParams[type]
  for _, actID in ipairs(validActIDs) do
    local firstShownTime = typeShownMap and typeShownMap[actID]
    if not firstShownTime then
      return actID
    else
      local TimeUtil = require("client.common.time_util")
      local isWithInOneDay = TimeUtil.WithinInNDay(firstShownTime, 3)
      if isWithInOneDay then
        return actID
      end
    end
  end
  return nil
end
function Logic_UGC_ThemePlay_ActivityTemplate:CheckMyReward(nActID)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tSerVerData = ActivityNewSystem.GetActivityByID(nActID)
  if not tSerVerData and not tSerVerData.List then
    return false
  end
  for k, v in pairs(tSerVerData.List) do
    if v.Status == 1 then
      return true
    end
  end
  return false
end
function Logic_UGC_ThemePlay_ActivityTemplate:GetCurrActivetID()
  local actID = self.CurrActiveSelsctedActID
  log(bWriteLog and string.format("Logic_UGC_ThemePlay_ActivityTemplate:GetCurrActivetID - Current Active ID: %s", actID))
  return actID
end
function Logic_UGC_ThemePlay_ActivityTemplate:SetCurrActivetID(nActID)
  log(bWriteLog and string.format("Logic_UGC_ThemePlay_ActivityTemplate:SetCurrActivetID - Setting Active ID to: %s", nActID))
  self.CurrActiveSelsctedActID = nActID
end
function Logic_UGC_ThemePlay_ActivityTemplate:send_batch_take_wow_play_activity_award_req(sub_activity_list)
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_batch_take_wow_play_activity_award_req(sub_activity_list)
end
function Logic_UGC_ThemePlay_ActivityTemplate:batch_take_wow_play_activity_award_rsp(data)
  if not data or not next(data) then
    return
  end
  log_tree(" OneClickRewardSystem.HandleCorpsActiveGoalReward all_award_list", data)
  local arrayItemData = {}
  for _, dropData in ipairs(data) do
    local rewardData = dropData and dropData[3] and dropData[3][1]
    if not rewardData then
      log(bWriteLog and "Logic_UGC_ThemePlay_ActivityTemplate:HandleCorpsActiveGoalReward - Invalid reward data, skip")
    end
    local ele = {
      res_id = rewardData and rewardData.res_id or 0,
      count = rewardData and rewardData.count or 0,
      valid_hours = rewardData and rewardData.valid_hours or 0,
      expire_ts = 0
    }
    if ele.res_id == 0 then
      log(bWriteLog and "Logic_UGC_ThemePlay_ActivityTemplate:HandleCorpsActiveGoalReward - Empty reward, skip")
    end
    ele.extra = {}
    local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
    ActivityUtil.CombineExpireTs(ele.expire_ts, ele.extra)
    table.insert(arrayItemData, ele)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_ThemePlay_ActivityTemplate = class(CModuleBase, nil, Logic_UGC_ThemePlay_ActivityTemplate)
return CLogic_UGC_ThemePlay_ActivityTemplate