local Logic_UGC_SeasonTemplate = {}
local TimeUtil = require("client.common.time_util")
local config_ugc_season_template = require("client.slua.umg.ugc.SeasonTemplate.config_ugc_season_template")
function Logic_UGC_SeasonTemplate:ctor()
  self.m_selectAct_id = nil
  self.ActivityTime = nil
  self.StepTime = nil
  self.Award = nil
  self.RuleTxt = nil
  self.AwardType = nil
  self.curSelectActivityID = nil
  self.DataTimerCD = 300
  self.ActivityData = nil
  self.ActivityDataTimeStamp = nil
  self.SearchModMetaMap = {}
  self.C_SearchInfoReqCD = 300
  self.MatchHubData = nil
  self.bShowEventSelectPopup = false
end
function Logic_UGC_SeasonTemplate:OnInitialize()
  Logic_UGC_SeasonTemplate:ReqSeasonActivityData()
end
function Logic_UGC_SeasonTemplate:RegistEvents()
end
function Logic_UGC_SeasonTemplate:OnLogin()
end
function Logic_UGC_SeasonTemplate:OnLogOut()
  self.ActivityData = nil
  self.SearchModMetaMap = nil
  self.my_match_list = {}
end
function Logic_UGC_SeasonTemplate:ReqSeasonActivityData()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local bWOWOpen = LogicUGC:IsWOWOpen()
  if not bWOWOpen then
    return
  end
  self:ReqMatchHubActivityData()
  if self:CheckActivityDataValid() then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:ReqSeasonActivityData dataValid no need to req")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GETSEASON_CFG)
    return
  end
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_get_ugc_comm_cfg_req(config_ugc_season_template.C_RequestType.gamecenter)
end
function Logic_UGC_SeasonTemplate:RspSeasonActivityData(set_type, cfgs)
  local config_ugc_season_template = require("client.slua.umg.ugc.SeasonTemplate.config_ugc_season_template")
  if set_type ~= config_ugc_season_template.C_RequestType.gamecenter then
    return
  end
  local TimeUtil = require("client.common.time_util")
  self.ActivityDataTimeStamp = TimeUtil.GetServerTimeInSec()
  self.ActivityData = cfgs
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GETSEASON_CFG)
end
function Logic_UGC_SeasonTemplate:CheckActivityDataValid()
  local TableUtil = require("common.table_util")
  if not self.ActivityData or TableUtil.CountTable(self.ActivityData) <= 0 then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckActivityDataValid ActivityData is nil")
    return false
  end
  if not self.ActivityDataTimeStamp then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckActivityDataValid ActivityDataTimeStamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  return curTime <= self.ActivityDataTimeStamp + self.DataTimerCD
end
function Logic_UGC_SeasonTemplate:OnRefreshReuseFall(curTabIndex, activityCfg)
  log(bWriteLog and "Logic_UGC_SeasonTemplate:OnRefreshReuseFall curTabIndex: " .. curTabIndex)
  if not activityCfg then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:OnRefreshReuseFall activityCfg is nil")
    return
  end
  local reuse_data = {}
  local match_type = activityCfg.activity_info and activityCfg.activity_info.match_type or 0
  local award_cfg = CDataTable.GetTableByFilter("WoWRewardCfg", "EventClassification", match_type) or {}
  local t = {}
  for k, v in pairs(award_cfg) do
    t[k] = v
  end
  local awards = {}
  for i, v in pairs(t) do
    if v.RewardClassification == curTabIndex then
      table.insert(awards, v)
    end
  end
  table.sort(awards, function(a, b)
    return a.ID < b.ID
  end)
  for i, v in ipairs(awards) do
    table.insert(reuse_data, {
      SubType = config_ugc_season_template.C_ReuseFullType.Content,
      AwardName = v.RewardName,
      AwardDesc = v.RewardDesc,
      AwardMoney = v.Amount,
      PlayerNum = v.NumOfPlayersReward,
      Item1ID = v.ItemID1,
      Item1Num = v.ItemCnt1,
      Item1Limit_Time = v.ItemLimit1,
      Item2ID = v.ItemID2,
      Item2Num = v.ItemCnt2,
      Item2Limit_Time = v.ItemLimit2,
      Item3ID = v.ItemID3,
      Item3Num = v.ItemCnt3,
      Item3Limit_Time = v.ItemLimit3,
      Item4ID = v.ItemID4,
      Item4Num = v.ItemCnt4,
      Item4Limit_Time = v.ItemLimit4
    })
  end
  local time_line = activityCfg.activity_info and activityCfg.activity_info.time_line or {}
  local steps = {}
  for i, v in pairs(time_line) do
    steps[i] = {
      StepName = v.title,
      StartTime = v.period[1],
      EndTime = v.period[2]
    }
  end
  table.insert(reuse_data, {
    SubType = config_ugc_season_template.C_ReuseFullType.ActivityTime,
    LocKey = 68859,
    Steps = steps
  })
  local rule = {}
  local general_rule_cfg = CDataTable.GetTable("GeneralRuleCfg")
  for i, v in pairs(general_rule_cfg) do
    if v.EventClassification == match_type then
      table.insert(rule, v)
    end
  end
  table.sort(rule, function(a, b)
    return a.Priority < b.Priority
  end)
  table.insert(reuse_data, {
    SubType = config_ugc_season_template.C_ReuseFullType.ParticipationCondition,
    Title = 68971,
    Content = activityCfg.activity_info and activityCfg.activity_info.vr_desc or ""
  })
  for i, v in pairs(rule) do
    table.insert(reuse_data, {
      SubType = config_ugc_season_template.C_ReuseFullType.ParticipationCondition,
      Title = v.TitleKey,
      Content = v.DescKey
    })
  end
  return reuse_data
end
function Logic_UGC_SeasonTemplate:GetValidActivity(includeActHide)
  if includeActHide == nil then
    includeActHide = true
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActList = ActivityNewSystem.GetActivityListByTypeAndLabelAndBackupParam1(ActivityType.ACTIVITY_TYPE_LINK, ActivityBackUpOneType.UGCSeason)
  local TimeUtil = require("client.common.time_util")
  local currTime = TimeUtil.GetServerTimeInSec()
  local valid_activity
  for _, v in ipairs(ActList or {}) do
    if (not self.ActivityData or self:GetActivityCfg(v.ID)) and (includeActHide or v.BackupParam2 ~= "1") and currTime >= v.StartTime and currTime <= v.EndTime then
      local data = {
        nActID = v.ID,
        sName = v.Title,
        nSwitchType = v.TabType or nil,
        startTime = v.StartTime,
        endTime = v.EndTime,
        ImgUrl = v.ImgUrl,
        nType = ActivityType.ACTIVITY_TYPE_LINK,
        Order = v.Order,
        Desc = v.Desc,
        Detail = v.Detail,
        DisplayScene = v.DisplayScene
      }
      valid_activity = valid_activity or {}
      table.insert(valid_activity, data)
    end
  end
  return valid_activity
end
function Logic_UGC_SeasonTemplate:GetActivityValidActivity()
  return self:GetValidActivity(false)
end
function Logic_UGC_SeasonTemplate:GetValidSeasonCfgData(update_post)
  local acts = {}
  local update_posts = {}
  local valid_activities = self:GetValidActivity()
  for _, v in pairs(valid_activities or {}) do
    local activity_cfg = self:GetActivityCfg(v.nActID)
    if activity_cfg and next(activity_cfg) then
      if activity_cfg.activity_info and activity_cfg.activity_info.update_post and activity_cfg.activity_info.update_post == 1 then
        table.insert(update_posts, activity_cfg)
      end
      table.insert(acts, activity_cfg)
    end
  end
  if update_post then
    return update_posts
  end
  return acts
end
function Logic_UGC_SeasonTemplate:GetActivityCfg(activity_id)
  local activity_cfg = {}
  for i, v in pairs(self.ActivityData or {}) do
    if activity_id == tonumber(v.activity_info.game_manage_id) then
      activity_cfg = v
      break
    end
  end
  return activity_cfg
end
function Logic_UGC_SeasonTemplate:GetMatchTypeCount(matchType)
  local count = 0
  for i, v in pairs(self.ActivityData or {}) do
    local cfg_match_type = v.activity_info and v.activity_info.match_type or 0
    if cfg_match_type == matchType then
      count = count + 1
    end
  end
  return count
end
function Logic_UGC_SeasonTemplate:GetMatchTypeCfg(matchType)
  local res = {}
  for i, v in pairs(self.ActivityData or {}) do
    local cfg_match_type = v.activity_info and v.activity_info.match_type or 0
    if cfg_match_type == matchType then
      table.insert(res, v)
    end
  end
  return res
end
function Logic_UGC_SeasonTemplate:ResetSelectActivityID()
  log(bWriteLog and "Logic_UGC_SeasonTemplate:ResetSelectActivityID")
  self.curSelectActivityID = nil
end
function Logic_UGC_SeasonTemplate:SetSelectActivityID(activity_id)
  log(bWriteLog and "Logic_UGC_SeasonTemplate:SetSelectActivityID activity_id: " .. tostring(activity_id))
  self.curSelectActivityID = activity_id
end
function Logic_UGC_SeasonTemplate:ReqContestMods(activity_id, get_type, rank_type, keyword)
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  local TimeUtil = require("client.common.time_util")
  local CacheKey = self:GetCacheKey(activity_id, get_type, rank_type, keyword)
  local CacheMod = self.SearchModMetaMap[CacheKey]
  if not CacheMod then
    UGCSearchHandler.send_ugc_get_events_mod_list_req(activity_id, get_type, rank_type, keyword)
    log(bWriteLog and "Logic_UGC_SeasonTemplate:ReqContestMods no cache")
    return nil
  end
  local NowTime = TimeUtil.GetServerTimeInSec()
  if NowTime > CacheMod.ReqTime + self.C_SearchInfoReqCD then
    self.SearchModMetaMap[CacheKey] = nil
    UGCSearchHandler.send_ugc_get_events_mod_list_req(activity_id, get_type, rank_type, keyword)
    log(bWriteLog and "Logic_UGC_SeasonTemplate:ReqContestMods cache expired, request new data")
    return nil
  end
  log(bWriteLog and "Logic_UGC_SeasonTemplate:ReqContestMods using valid cache")
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GETCONTESTMODS, rank_type, keyword)
  return CacheMod
end
function Logic_UGC_SeasonTemplate:RspContestMods(activity_id, get_type, rank_type, mod_ids, keyword)
  log_tree("Logic_UGC_SeasonTemplate:RspContestMods mod_ids", mod_ids)
  local CacheKey = self:GetCacheKey(activity_id, get_type, rank_type, keyword)
  local TimeUtil = require("client.common.time_util")
  local NowTime = TimeUtil.GetServerTimeInSec()
  local Cache = {
    MetaList = mod_ids or {},
    ReqTime = NowTime
  }
  self.SearchModMetaMap[CacheKey] = Cache
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GETCONTESTMODS, rank_type, keyword)
end
function Logic_UGC_SeasonTemplate:GetCacheKey(activity_id, get_type, rank_type, keyword)
  activity_id = activity_id or ""
  get_type = get_type or ""
  rank_type = rank_type or ""
  keyword = keyword or ""
  local CacheKey = activity_id .. "|-|" .. get_type .. "|-|" .. rank_type .. "|-|" .. keyword
  return CacheKey
end
function Logic_UGC_SeasonTemplate:GetCacheModList(activity_id, get_type, rank_type, keyword)
  local CacheKey = self:GetCacheKey(activity_id, get_type, rank_type, keyword)
  return self.SearchModMetaMap[CacheKey]
end
function Logic_UGC_SeasonTemplate:GetEligibleAct(acts, meta)
  for nActID, v in pairs(acts) do
    local result, reason_str = self:CheckCanSetSeasonLabel(nActID, meta)
    if result then
      log(bWriteLog and "Logic_UGC_SeasonTemplate:GetEligibleAct nActID: " .. nActID .. " is eligible")
      return v
    end
  end
end
local BlockyNumberType = import("EBlockyCurrentGraphBlockyNumberType")
function Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel(activity_id, meta)
  local activity_cfg = self:GetActivityCfg(activity_id)
  local activity_info = activity_cfg and activity_cfg.activity_info or {}
  local rule_list = {}
  local current_list = {}
  local config_ugc_season_template = require("client.slua.umg.ugc.SeasonTemplate.config_ugc_season_template")
  local rule_cfg = CDataTable.GetTable("RuleParametersCfg")
  local GetCurCfg = function(id)
    local cfg
    for i, v in pairs(rule_cfg) do
      if v.ID == id then
        cfg = v
        break
      end
    end
    return cfg
  end
  if meta.base.first_mod_id and not meta.base.mod_id_rela then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel meta.base.first_mod_id: " .. meta.base.first_mod_id)
    local cfg = GetCurCfg(config_ugc_season_template.C_RuleParamID.CopyMod)
    table.insert(rule_list, cfg)
  end
  local lua_code_block_amount = 0
  for i, v in pairs(meta.stat and meta.stat.LuaCodeMultiTlog or {}) do
    for j, k in pairs(v or {}) do
      if j == 2 then
        lua_code_block_amount = lua_code_block_amount + k
      end
    end
  end
  if activity_info.vp_block_amount and activity_info.vp_block_amount ~= "" and lua_code_block_amount < tonumber(activity_info.vp_block_amount) then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel lua_code_block_amount: " .. lua_code_block_amount .. " activity_info.vp_block_amount = " .. activity_info.vp_block_amount)
    local cfg = GetCurCfg(config_ugc_season_template.C_RuleParamID.LuaCodeBlockCnt)
    table.insert(rule_list, cfg)
    current_list[config_ugc_season_template.C_RuleParamID.LuaCodeBlockCnt] = lua_code_block_amount
  end
  if activity_info.vp_trigger_amount and activity_info.vp_trigger_amount ~= "" then
    local LuaCodeTlog = meta.stat and meta.stat.LuaCodeTlog or {}
    local lua_code_trigger_amount = 0
    for i, v in pairs(LuaCodeTlog) do
      if v[1] == 1 then
        lua_code_trigger_amount = lua_code_trigger_amount + (v[2] or 0)
      end
    end
    if lua_code_trigger_amount < tonumber(activity_info.vp_trigger_amount) then
      log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel lua_code_trigger_amount: " .. lua_code_trigger_amount .. " activity_info.vp_trigger_amount = " .. activity_info.vp_trigger_amount)
      local cfg = GetCurCfg(config_ugc_season_template.C_RuleParamID.LuaCodeTriggerCnt)
      table.insert(rule_list, cfg)
      current_list[config_ugc_season_template.C_RuleParamID.LuaCodeTriggerCnt] = lua_code_trigger_amount
    end
  end
  if activity_info.component_id and activity_info.component_id ~= "" then
    local StringUtil = require("common.string_util")
    local component_ids = StringUtil.Split(activity_info.component_id, ",")
    local object_edits = {}
    for i, v in pairs(meta.stat and meta.stat.AllObjectEditInfo or {}) do
      for j, k in pairs(v or {}) do
        if j == 1 then
          table.insert(object_edits, k)
        end
      end
    end
    local hasAll = true
    local notHave, alreadyHave
    for _, comp_id in ipairs(component_ids) do
      local found = false
      for _, obj_id in ipairs(object_edits) do
        if tostring(obj_id) == comp_id then
          found = true
          break
        end
      end
      local comp_name
      local asset_cfg = CDataTable.GetTableData("UGCAssetConfig", tonumber(comp_id))
      if asset_cfg then
        comp_name = asset_cfg.Name
      else
        comp_name = tostring(comp_id)
      end
      if not found then
        hasAll = false
        if notHave == nil then
          notHave = comp_name
        else
          notHave = notHave .. "," .. comp_name
        end
      elseif alreadyHave == nil then
        alreadyHave = comp_name
      else
        alreadyHave = alreadyHave .. "," .. comp_name
      end
    end
    if not hasAll then
      log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel component not match  activity_info.component_id = " .. activity_info.component_id)
      log_tree("Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel object_edits =  ", object_edits)
      local cfg = GetCurCfg(config_ugc_season_template.C_RuleParamID.Components)
      table.insert(rule_list, cfg)
      current_list[config_ugc_season_template.C_RuleParamID.Components] = notHave
    end
  end
  local meta_edit_time = meta.stat and meta.stat.EditTime or 0
  if activity_info.edit_time and activity_info.edit_time ~= "" then
    if meta_edit_time < tonumber(activity_info.edit_time) then
      log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel edit_time: " .. meta_edit_time .. " activity_info.edit_time = " .. activity_info.edit_time)
      local cfg = GetCurCfg(config_ugc_season_template.C_RuleParamID.EditTime)
      table.insert(rule_list, cfg)
    end
    current_list[config_ugc_season_template.C_RuleParamID.EditTime] = math.floor(meta_edit_time / 60)
  end
  local ObjectAmount = 0
  for i, v in pairs(meta.stat and meta.stat.AllObjectEditInfo or {}) do
    for j, k in pairs(v or {}) do
      if j == 3 then
        ObjectAmount = ObjectAmount + k
      end
    end
  end
  if activity_info.object_amount and activity_info.object_amount ~= "" then
    if ObjectAmount < tonumber(activity_info.object_amount) then
      log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckCanSetSeasonLabel object_amount: " .. ObjectAmount .. " activity_info.object_amount = " .. activity_info.object_amount)
      local cfg = GetCurCfg(config_ugc_season_template.C_RuleParamID.ObjCnt)
      table.insert(rule_list, cfg)
    end
    current_list[config_ugc_season_template.C_RuleParamID.ObjCnt] = ObjectAmount
  end
  local TableUtil = require("common.table_util")
  local rule_len = TableUtil.CountTable(rule_list)
  local getRuleParamStr = function(rule, activity_info)
    if rule.ID == config_ugc_season_template.C_RuleParamID.Components then
      local StringUtil = require("common.string_util")
      local component_ids = StringUtil.Split(activity_info.component_id, ",")
      local component_str = ""
      local names = {}
      for _, v in pairs(component_ids) do
        local asset_cfg = CDataTable.GetTableData("UGCAssetConfig", tonumber(v))
        if asset_cfg then
          table.insert(names, asset_cfg.Name)
        end
      end
      component_str = table.concat(names, ",")
      return component_str
    elseif rule.ID == config_ugc_season_template.C_RuleParamID.EditTime then
      return math.floor(activity_info.edit_time / 60)
    elseif rule.ID == config_ugc_season_template.C_RuleParamID.ObjCnt then
      return activity_info.object_amount
    elseif rule.ID == config_ugc_season_template.C_RuleParamID.LuaCodeBlockCnt then
      return activity_info.vp_block_amount
    elseif rule.ID == config_ugc_season_template.C_RuleParamID.LuaCodeTriggerCnt then
      return activity_info.vp_trigger_amount
    end
    return ""
  end
  local reason = ""
  if rule_len == 1 then
    local str = getRuleParamStr(rule_list[1], activity_info)
    local content = LocUtil.LocalizeResFormat(rule_list[1].LocKey, str, current_list[rule_list[1].ID])
    reason = LocUtil.LocalizeResFormat(85032, content)
  elseif rule_len == 2 then
    local str1 = getRuleParamStr(rule_list[1], activity_info)
    local str2 = getRuleParamStr(rule_list[2], activity_info)
    local content1 = LocUtil.LocalizeResFormat(rule_list[1].LocKey, str1, current_list[rule_list[1].ID])
    local content2 = LocUtil.LocalizeResFormat(rule_list[2].LocKey, str2, current_list[rule_list[2].ID])
    reason = LocUtil.LocalizeResFormat(85033, content1, content2)
  elseif rule_len == 3 then
    local str1 = getRuleParamStr(rule_list[1], activity_info)
    local str2 = getRuleParamStr(rule_list[2], activity_info)
    local str3 = getRuleParamStr(rule_list[3], activity_info)
    local content1 = LocUtil.LocalizeResFormat(rule_list[1].LocKey, str1, current_list[rule_list[1].ID])
    local content2 = LocUtil.LocalizeResFormat(rule_list[2].LocKey, str2, current_list[rule_list[2].ID])
    local content3 = LocUtil.LocalizeResFormat(rule_list[3].LocKey, str3, current_list[rule_list[3].ID])
    reason = LocUtil.LocalizeResFormat(85034, content1, content2, content3)
  elseif rule_len == 4 then
    local str1 = getRuleParamStr(rule_list[1], activity_info)
    local str2 = getRuleParamStr(rule_list[2], activity_info)
    local str3 = getRuleParamStr(rule_list[3], activity_info)
    local str4 = getRuleParamStr(rule_list[4], activity_info)
    local content1 = LocUtil.LocalizeResFormat(rule_list[1].LocKey, str1, current_list[rule_list[1].ID])
    local content2 = LocUtil.LocalizeResFormat(rule_list[2].LocKey, str2, current_list[rule_list[2].ID])
    local content3 = LocUtil.LocalizeResFormat(rule_list[3].LocKey, str3, current_list[rule_list[3].ID])
    local content4 = LocUtil.LocalizeResFormat(rule_list[4].LocKey, str4, current_list[rule_list[4].ID])
    reason = LocUtil.LocalizeResFormat(85035, content1, content2, content3, content4)
  elseif rule_len == 5 then
    local str1 = getRuleParamStr(rule_list[1], activity_info)
    local str2 = getRuleParamStr(rule_list[2], activity_info)
    local str3 = getRuleParamStr(rule_list[3], activity_info)
    local str4 = getRuleParamStr(rule_list[4], activity_info)
    local str5 = getRuleParamStr(rule_list[5], activity_info)
    local content1 = LocUtil.LocalizeResFormat(rule_list[1].LocKey, str1, current_list[rule_list[1].ID])
    local content2 = LocUtil.LocalizeResFormat(rule_list[2].LocKey, str2, current_list[rule_list[2].ID])
    local content3 = LocUtil.LocalizeResFormat(rule_list[3].LocKey, str3, current_list[rule_list[3].ID])
    local content4 = LocUtil.LocalizeResFormat(rule_list[4].LocKey, str4, current_list[rule_list[4].ID])
    local content5 = LocUtil.LocalizeResFormat(rule_list[5].LocKey, str5, current_list[rule_list[5].ID])
    reason = LocUtil.LocalizeResFormat(85036, content1, content2, content3, content4, content5)
  elseif rule_len == 6 then
    local str1 = getRuleParamStr(rule_list[1], activity_info)
    local str2 = getRuleParamStr(rule_list[2], activity_info)
    local str3 = getRuleParamStr(rule_list[3], activity_info)
    local str4 = getRuleParamStr(rule_list[4], activity_info)
    local str5 = getRuleParamStr(rule_list[5], activity_info)
    local str6 = getRuleParamStr(rule_list[6], activity_info)
    local content1 = LocUtil.LocalizeResFormat(rule_list[1].LocKey, str1, current_list[rule_list[1].ID])
    local content2 = LocUtil.LocalizeResFormat(rule_list[2].LocKey, str2, current_list[rule_list[2].ID])
    local content3 = LocUtil.LocalizeResFormat(rule_list[3].LocKey, str3, current_list[rule_list[3].ID])
    local content4 = LocUtil.LocalizeResFormat(rule_list[4].LocKey, str4, current_list[rule_list[4].ID])
    local content5 = LocUtil.LocalizeResFormat(rule_list[5].LocKey, str5, current_list[rule_list[5].ID])
    local content6 = LocUtil.LocalizeResFormat(rule_list[6].LocKey, str6, current_list[rule_list[6].ID])
    reason = LocUtil.LocalizeResFormat(85037, content1, content2, content3, content4, content5, content6)
  end
  local match_type = activity_info.match_type or 0
  if rule_len == 0 and match_type ~= 4 and match_type ~= 7 then
    return true, ""
  end
  reason = LocUtil.LocalizeResFormat(1050176, meta.setting.name) .. "\n" .. reason
  if match_type == 1 then
    reason = reason .. "\n" .. LocUtil.LocalizeResFormat(1050177, math.floor(meta_edit_time / 60), ObjectAmount)
  elseif match_type == 2 then
    reason = reason .. "\n" .. LocUtil.LocalizeResFormat(1050178, math.floor(meta_edit_time / 60), ObjectAmount)
  elseif match_type == 3 then
    reason = reason .. "\n" .. LocUtil.LocalizeResFormat(1050179, math.floor(meta_edit_time / 60), lua_code_block_amount)
  elseif match_type == 5 then
    reason = reason .. "\n" .. LocUtil.LocalizeResFormat(1050204, math.floor(meta_edit_time / 60), ObjectAmount)
  elseif match_type == 6 then
    reason = reason .. "\n" .. LocUtil.LocalizeResFormat(1050228, math.floor(meta_edit_time / 60), ObjectAmount)
  elseif rule_len == 0 then
    return true, ""
  end
  return rule_len == 0, reason
end
function Logic_UGC_SeasonTemplate:CheckIsCreateTime(activityID)
  local activity_id = tonumber(activityID)
  local bIsCreateTime = false
  if not activity_id then
    return
  end
  local activityCfg = self:GetActivityCfg(activity_id)
  if not activityCfg then
    return
  end
  local time_line = activityCfg.activity_info and activityCfg.activity_info.time_line or {}
  local CreationPeriod
  local config_ugc_season_template = require("client.slua.umg.ugc.SeasonTemplate.config_ugc_season_template")
  for j, k in pairs(time_line) do
    if k.type == config_ugc_season_template.C_EnumStep.CreationPeriod then
      CreationPeriod = k
      break
    end
  end
  local start_time = CreationPeriod and CreationPeriod.period[1]
  local end_time = CreationPeriod and CreationPeriod.period[2]
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if start_time and type(start_time) == "number" and end_time and type(end_time) == "number" and start_time <= serverTime and end_time >= serverTime then
    bIsCreateTime = true
  end
  return bIsCreateTime
end
function Logic_UGC_SeasonTemplate:CheckIsCreateTimeBySeasonID(season_id)
  local id = tonumber(season_id)
  if not id then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckIsCreateTimeBySeasonID season_id is nil")
    return false
  end
  if not self.ActivityData or not next(self.ActivityData) then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckIsCreateTimeBySeasonID ActivityData is nil")
    return false
  end
  local season_cfg
  for i, v in pairs(self.ActivityData) do
    if v.id == id then
      season_cfg = v
      break
    end
  end
  if not season_cfg then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckIsCreateTimeBySeasonID season_cfg is nil id = " .. id)
    return false
  end
  return self:CheckIsCreateTime(season_cfg.activity_info.game_manage_id), season_cfg
end
function Logic_UGC_SeasonTemplate:GetSeasonStep(season_act)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local time_line = season_act and season_act.activity_info and season_act.activity_info.time_line or {}
  for j, k in pairs(time_line) do
    local start_time = k.period[1] or 0
    local end_time = k.period[2] or 0
    if start_time and type(start_time) == "number" and end_time and type(end_time) == "number" and serverTime >= start_time and serverTime <= end_time then
      return k
    end
  end
end
function Logic_UGC_SeasonTemplate:GetCollectionActData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActList = ActivityNewSystem.GetActivityListByTypeAndLabelAndBackupParam1(ActivityType.ACTIVITY_TYPE_LINK, ActivityBackUpOneType.Match_Hub)
  local currTime = TimeUtil.GetServerTimeInSec()
  local valid_activity
  for _, v in ipairs(ActList or {}) do
    if currTime >= v.StartTime and currTime <= v.EndTime then
      local data = {
        nActID = v.ID,
        sName = v.Title,
        nSwitchType = ActivitySwitchType.Welfare,
        startTime = v.StartTime,
        endTime = v.EndTime,
        ImgUrl = v.ImgUrl,
        nType = ActivityType.ACTIVITY_TYPE_LINK,
        Order = v.Order,
        Desc = v.Desc,
        Detail = v.Detail,
        DisplayScene = v.DisplayScene
      }
      valid_activity = valid_activity or {}
      table.insert(valid_activity, data)
    end
  end
  self:UpdateUGCCenterSubTabList(valid_activity)
  return valid_activity
end
function Logic_UGC_SeasonTemplate:GetCollectionActDataByActID(actID)
  local valid_activity = self:GetCollectionActData()
  for i, v in ipairs(valid_activity or {}) do
    if v.nActID == actID then
      return v
    end
  end
end
function Logic_UGC_SeasonTemplate:ReqMatchHubActivityData()
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_get_ugc_comm_cfg_req(config_ugc_season_template.C_RequestType.match_hub)
end
function Logic_UGC_SeasonTemplate:RspMatchHubActivityData(set_type, cfgs)
  if set_type ~= config_ugc_season_template.C_RequestType.match_hub then
    return
  end
  self.MatchHubData = cfgs
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MATCHHUB_CFG)
end
function Logic_UGC_SeasonTemplate:GetMatchHubCfg(act_id)
  local match_hub_cfg = {}
  for i, v in pairs(self.MatchHubData or {}) do
    if act_id == tonumber(v.activity_info.game_manage_id) then
      match_hub_cfg = v
      break
    end
  end
  return match_hub_cfg
end
function Logic_UGC_SeasonTemplate:GetSeasonActListByState(state, match_hub_cfg)
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
  for i, v in pairs(self.ActivityData) do
    if not season_act_map[v.id] then
      season_act_map[v.id] = v
    end
  end
  for i, id in pairs(season_act_ids) do
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
  if state == config_ugc_season_template.C_Enum_CollectionPageTabType.progress then
    table.sort(progress_list, function(a, b)
      return a.sort < b.sort
    end)
    list = progress_list
  elseif state == config_ugc_season_template.C_Enum_CollectionPageTabType.Over then
    list = over_list
  elseif state == config_ugc_season_template.C_Enum_CollectionPageTabType.Joined then
    list = self.my_match_list
  elseif state == config_ugc_season_template.C_Enum_CollectionPageTabType.All then
    list = self:MergedSeasonList(progress_list, over_list, self.my_match_list)
  end
  return list
end
function Logic_UGC_SeasonTemplate:GetSortByTimeState(data)
  local sort = 1
  local cur_time = TimeUtil.GetServerTimeInSec()
  local time_line = data.activity_info and data.activity_info.time_line or {}
  for j, k in pairs(time_line) do
    local start_time = k.period[1] or 0
    local end_time = k.period[2] or 0
    if start_time and type(start_time) == "number" and end_time and type(end_time) == "number" and cur_time >= start_time and cur_time <= end_time then
      sort = k.type
      break
    end
  end
  log(bWriteLog and "Logic_UGC_SeasonTemplate:GetSortByTimeState data.id = " .. data.id .. " sort = " .. sort)
  return sort
end
function Logic_UGC_SeasonTemplate:MergedSeasonList(progress_list, over_list, my_match_list)
  local seen = {}
  local list = {}
  for _, v in ipairs(progress_list or {}) do
    if v.id and not seen[v.id] then
      seen[v.id] = true
      table.insert(list, v)
    end
  end
  for _, v in ipairs(over_list or {}) do
    if v.id and not seen[v.id] then
      seen[v.id] = true
      table.insert(list, v)
    end
  end
  for _, v in ipairs(my_match_list or {}) do
    if v.id and not seen[v.id] then
      seen[v.id] = true
      table.insert(list, v)
    end
  end
  table.sort(list, function(a, b)
    local tA = a.activity_info and a.activity_info.start_time or 0
    local tB = b.activity_info and b.activity_info.start_time or 0
    return tA < tB
  end)
  return list
end
function Logic_UGC_SeasonTemplate:SetMyMatchList(match_ids)
  if not match_ids or not next(match_ids) then
    return
  end
  self.my_match_list = {}
  local season_act_map = {}
  for i, v in pairs(self.ActivityData) do
    if not season_act_map[v.id] then
      season_act_map[v.id] = v
    end
  end
  for i, match_id in pairs(match_ids) do
    if season_act_map[match_id] then
      table.insert(self.my_match_list, season_act_map[match_id])
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MY_MATCH_LIST)
end
function Logic_UGC_SeasonTemplate:UpdateUGCCenterSubTabList(activities)
  if not activities or not next(activities) then
    return
  end
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.JAPAN or strRegion == PublishRegionMacros.KOREA then
    return
  end
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  LogicUGCCenter:AddIncentiveSubTab(activities)
end
function Logic_UGC_SeasonTemplate:SetMatchOfflineData(data)
  self.meatch_offline_end
function Logic_UGC_SeasonTemplate:GetMatchOfflineData(activity_id)
  return self.meatch_offline_data and self.meatch_offline_data[activity_id] or {}
end
function Logic_UGC_SeasonTemplate:SetEventSelectPopupUIState(state)
  self.bShowEventSelectPopup = state
end
function Logic_UGC_SeasonTemplate:GetEventSelectPopupUIState()
  return self.bShowEventSelectPopup
end
function Logic_UGC_SeasonTemplate:CheckActivityEventIsEnd(activity_id)
  local act_cfg = self:GetActivityCfg(activity_id)
  if not act_cfg or not next(act_cfg) then
    log(bWriteLog and "Logic_UGC_SeasonTemplate:CheckActivityEventIsEnd: act_cfg is nil activity_id = " .. activity_id)
    return true
  end
  local cur_time = TimeUtil.GetServerTimeInSec()
  local end_time = act_cfg.activity_info and act_cfg.activity_info.end_time or 0
  if cur_time > end_time then
    return true
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_SeasonTemplate = class(CModuleBase, nil, Logic_UGC_SeasonTemplate)
return CLogic_UGC_SeasonTemplate