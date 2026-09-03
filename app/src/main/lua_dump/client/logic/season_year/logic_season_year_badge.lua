local logic_season_year_badge = {}
local season_year_config = require("client.logic.season_year.config.season_year_config")
function logic_season_year_badge:DefineAndResetData()
  self.seasonYearBadgeInfo = {}
  self.seasonYearTaskInfo = {}
  self.serverBadgeCfg = {}
  self.serverYearTaskCfg = {}
  self.otherBadgeData = {}
  self.loginDay = 0
end
function logic_season_year_badge:OnInitialize()
  logic_season_year_badge.__super.OnInitialize(self)
  self:send_get_season_year_badge_cfg_req()
end
function logic_season_year_badge:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SEASON_YEAR_BADGE_SLAP, self.ShowLevelUpSlap, self)
end
function logic_season_year_badge:OnLogin(bReLogin)
end
function logic_season_year_badge:OnLogOut()
  log(bWriteLog and "logic_season_year_badge OnLogOut")
  self:_ResetAllCacheData()
end
function logic_season_year_badge:OnPreSwitchGameStatus(preState, nextState)
end
function logic_season_year_badge:OnPostSwitchGameStatus(preState, nextState)
end
function logic_season_year_badge:ShowLevelUpSlap()
  log(bWriteLog and "logic_season_year_badge:ShowLevelUpSlap")
  if UIManager.IsUIShow(UIManager.UI_Config.Lobby_Season_UpgradeBadge_UIBP) or self.upgradeBadge_UIBP_showing then
    EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_SEASON_YEAR_BADGE_UPDATE)
  else
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_UpgradeBadge_UIBP)
    self.upgradeBadge_UIBP_showing = true
  end
  self.slapLevelUpFlag = false
end
function logic_season_year_badge:CheckCanShowLevelUpSlap()
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_season_year_badge:CheckCanShowLevelUpSlap in fight")
    return false
  end
  if not self.slapLevelUpFlag then
    log(bWriteLog and string.format("logic_season_year_badge:CheckCanShowLevelUpSlap, not self.slapLevelUpFlag:%s", self.slapLevelUpFlag))
    return false
  end
  return true
end
function logic_season_year_badge:send_get_season_year_badge_cfg_req()
  local SeasonYearHandler = require("client.network.Protocol.SeasonYearHandler")
  local data_config_marco = require("client.logic.data.data_config_marco")
  SeasonYearHandler.send_get_season_year_cfg_req(data_config_marco.season_year_badge_cfg)
  SeasonYearHandler.send_get_season_year_cfg_req(data_config_marco.year_task_cfg)
end
function logic_season_year_badge:on_get_season_year_badge_cfg_rsp(info)
  log(bWriteLog and "logic_season_year_badge:on_get_season_year_badge_cfg_rsp: serverData = ", info)
  if not info then
    log(bWriteLog and "logic_season_year_badge:on_get_season_year_badge_cfg_rsp, not info")
    return
  end
  self.serverBadgeCfg = {}
  for season_id, taskTable in pairs(info) do
    local season_year_cfg_tb = {}
    for partType, partTaskCfg in pairs(taskTable) do
      local part_type_cfg_tb = {}
      for task_id, task_info in pairs(partTaskCfg) do
        for key, value in pairs(task_info) do
          if type(key) == "number" then
            local item = {
              task_stage_id = key,
              task_id = task_id,
              pre_cond = task_info.pre_cond,
              task_type = task_info.task_type,
              finish_value = task_info.finish_value,
              badge_cfg = value
            }
            table.insert(part_type_cfg_tb, item)
          end
        end
      end
      table.sort(part_type_cfg_tb, function(a, b)
        return a.task_id < b.task_id or a.task_stage_id < b.task_stage_id
      end)
      season_year_cfg_tb[partType] = part_type_cfg_tb
    end
    self.serverBadgeCfg[season_id] = season_year_cfg_tb
  end
end
function logic_season_year_badge:on_get_season_year_task_cfg_rsp(info)
  log(bWriteLog and "logic_season_year_badge:on_get_season_year_task_cfg_rsp: serverData = ", info)
  self.serverYearTaskCfg = info
end
function logic_season_year_badge:on_get_season_year_badge_info_rsp(badge_info)
  log(bWriteLog and "logic_season_year_badge:on_get_season_year_badge_info_rsp: serverData = ", badge_info)
  if not badge_info then
    log(bWriteLog and "logic_season_year_badge:on_get_season_year_badge_info_rsp, not badge_info")
    return
  end
  self.seasonYearBadgeInfo = self.seasonYearBadgeInfo or {}
  for yearId, info in pairs(badge_info) do
    self.seasonYearBadgeInfo[yearId] = info
  end
  EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_SEASON_YEAR_BADGE_UPDATE)
end
function logic_season_year_badge:on_season_year_badge_info_notify(badge_part_id, task_id, progress_id)
  log(bWriteLog and "logic_season_year_badge:on_season_year_badge_info_notify: serverData = ", badge_part_id, task_id, progress_id)
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local season_year_id = season_year_util.GetSeasonYearId()
  local badge_progress = 0
  progress_id = progress_id or 1
  if self.seasonYearBadgeInfo and self.seasonYearBadgeInfo[season_year_id] and self.seasonYearBadgeInfo[season_year_id][badge_part_id] and self.seasonYearBadgeInfo[season_year_id][badge_part_id][task_id] then
    badge_progress = self.seasonYearBadgeInfo[season_year_id][badge_part_id][task_id].finish_count or 0
  end
  self.slapLevelUpFlag = true
  self.slapInfo = self.slapInfo or {}
  self.slapInfo[badge_part_id] = self.slapInfo[badge_part_id] or {}
  local old_progress_id = self.slapInfo[badge_part_id][task_id] and self.slapInfo[badge_part_id][task_id].old_progress_id or badge_progress
  self.slapInfo[badge_part_id][task_id] = self.slapInfo[badge_part_id][task_id] or {task_id = task_id}
  self.slapInfo[badge_part_id][task_id].  self.slapInfo[badge_part_id][task_id].  if self.seasonYearBadgeInfo and self.seasonYearBadgeInfo[season_year_id] and self.seasonYearBadgeInfo[season_year_id][badge_part_id] and self.seasonYearBadgeInfo[season_year_id][badge_part_id][task_id] then
    self.seasonYearBadgeInfo[season_year_id][badge_part_id][task_id].finish_count = progress_id
    if badge_part_id == season_year_config.EBadgePartType.Glow then
      self.seasonYearBadgeInfo[season_year_id][badge_part_id][task_id].status = season_year_config.ERankTaskStatus.Completed
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_YEAR_BADGE_SLAP_POPUP)
end
function logic_season_year_badge:on_get_cur_year_task_info_rsp(info)
  self.seasonYearTaskInfo = info or {}
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.UpdateSeasonYearBadgeRedpoint()
  EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_SEASON_YEAR_TASK_UPDATE)
end
function logic_season_year_badge:on_get_year_task_reward_rsp(id, rewards)
  if self.seasonYearTaskInfo[id] then
    self.seasonYearTaskInfo[id].status = season_year_config.ERankTaskStatus.Completed
  end
  if rewards and 0 < #rewards then
    local list = {}
    for i, v in ipairs(rewards) do
      table.insert(list, {
        res_id = v.resid,
        count = v.count,
        valid_hours = v.valid_hours
      })
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(list)
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.UpdateSeasonYearBadgeRedpoint()
  EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_SEASON_YEAR_TASK_UPDATE)
end
function logic_season_year_badge:on_get_other_season_year_badge_rsp(target_uid, all_badge_info)
  all_badge_info = all_badge_info or {}
  self.otherBadgeData = self.otherBadgeData or {}
  local length = 0
  for _, _ in pairs(self.otherBadgeData) do
    length = length + 1
  end
  if 5 < length then
    self.otherBadgeData = {}
  end
  self.otherBadgeData[tonumber(target_uid)] = all_badge_info
  EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_OTHER_SEASON_YEAR_BADGE_UPDATE)
end
function logic_season_year_badge:send_set_season_year_badge_show_req(showType)
  self.cacheShowType = showType
  local SeasonYearHandler = require("client.network.Protocol.SeasonYearHandler")
  SeasonYearHandler.send_set_season_year_badge_show_req(showType)
end
function logic_season_year_badge:on_send_set_season_year_badge_show_rsp()
  self.badgeShowType = self.cacheShowType
  self.cacheShowType = nil
  ShowNotice(301192)
end
function logic_season_year_badge:on_get_season_year_badge_show_rsp(showType)
  self.badgeShowType = showType or season_year_config.EBadgeShowType.Hide
  EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_SEASON_YEAR_BADGE_SHOW_TYPE_UPDATE)
end
function logic_season_year_badge:on_get_cur_season_login_days_rsp(loginDays)
  self.  EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_SEASON_YEAR_BADGE_LOGIN_DAY_UPDATE)
end
function logic_season_year_badge:ReqSeasonYearBadgeInfo(forceUpdate)
  log(bWriteLog and "logic_season_year_badge:ReqSeasonYearBadgeInfo forceUpdate = " .. tostring(forceUpdate))
  if forceUpdate then
    local SeasonYearHandler = require("client.network.Protocol.SeasonYearHandler")
    SeasonYearHandler.send_get_season_year_badge_req()
  else
    local season_year_util = require("client.logic.season_year.util.season_year_util")
    local season_year_id = season_year_util.GetSeasonYearId()
    if not (self.seasonYearBadgeInfo and self.seasonYearBadgeInfo[season_year_id]) or not self.seasonYearBadgeInfo[season_year_id][season_year_config.EBadgePartType.Gem] then
      local SeasonYearHandler = require("client.network.Protocol.SeasonYearHandler")
      SeasonYearHandler.send_get_season_year_badge_req()
    else
      EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_SEASON_YEAR_BADGE_UPDATE)
    end
  end
end
function logic_season_year_badge:ReqOtherSeasonYearBadgeInfo(target_uid)
  log(bWriteLog and "logic_season_year_badge:ReqOtherSeasonYearBadgeInfo target_uid = " .. tostring(target_uid))
  local uid = tonumber(target_uid) or 0
  if uid == DataMgr.roleData.uid then
    log(bWriteLog and "logic_season_year_badge:ReqOtherSeasonYearBadgeInfo, target_uid is self")
    self:ReqSeasonYearBadgeInfo()
    return
  end
  if not self.otherBadgeData or not self.otherBadgeData[uid] then
    log(bWriteLog and "logic_season_year_badge:ReqOtherSeasonYearBadgeInfo, not otherBadgeData target_uid = " .. tostring(target_uid))
    local SeasonYearHandler = require("client.network.Protocol.SeasonYearHandler")
    SeasonYearHandler.send_get_other_season_year_badge_req(uid)
  else
    EventSystem:postEvent(EVENTTYPE_SEASON_YEAR, EVENTID_OTHER_SEASON_YEAR_BADGE_UPDATE)
  end
end
function logic_season_year_badge:_ResetAllCacheData()
  self.seasonYearBadgeInfo = nil
  self.seasonYearTaskInfo = nil
  self.serverBadgeCfg = nil
  self.serverYearTaskCfg = nil
  self.otherBadgeData = nil
  self.badgeShowType = nil
  self.slapLevelUpFlag = false
  self.slapInfo = nil
end
function logic_season_year_badge:GetCurSeasonYearBadgeInfo()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local season_year_id = season_year_util.GetSeasonYearId()
  return self.seasonYearBadgeInfo and self.seasonYearBadgeInfo[season_year_id] or {}
end
function logic_season_year_badge:GetCurSeasonYearBadgeCfg()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local season_year_id = season_year_util.GetSeasonYearId()
  return self.serverBadgeCfg and self.serverBadgeCfg[season_year_id] or {}
end
function logic_season_year_badge:GetCurSeasonYearTaskCfg()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local season_year_id = season_year_util.GetSeasonYearId()
  return self.serverYearTaskCfg and self.serverYearTaskCfg[season_year_id] or {}
end
function logic_season_year_badge:GetCurSeasonYearTaskInfo()
  return self.seasonYearTaskInfo
end
function logic_season_year_badge:GetSeasonYearLevelUpSlap()
  return self.slapInfo
end
function logic_season_year_badge:ResetSeasonYearSlapInfo()
  self.slapInfo = {}
  self.slapLevelUpFlag = false
  self.upgradeBadge_UIBP_showing = false
end
function logic_season_year_badge:GetOtherSeasonYearBadgeInfo(target_uid)
  target_uid = tonumber(target_uid)
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local season_year_id = season_year_util.GetSeasonYearId()
  if self.otherBadgeData and self.otherBadgeData[target_uid] then
    return self.otherBadgeData[target_uid][season_year_id] or {}
  end
  return {}
end
function logic_season_year_badge:CheckOtherSeasonYearBadge(target_uid)
  target_uid = tonumber(target_uid)
  return self.otherBadgeData and self.otherBadgeData[target_uid]
end
function logic_season_year_badge:GetBadgeShowType()
  if self.badgeShowType == nil then
    local SeasonYearHandler = require("client.network.Protocol.SeasonYearHandler")
    SeasonYearHandler.send_get_season_year_badge_show_req()
    return false
  else
    return self.badgeShowType
  end
end
function logic_season_year_badge:GetCurSeasonYearLoginDays()
  return self.loginDays
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_season_year_badge = class(CModuleBase, nil, logic_season_year_badge)
return Clogic_season_year_badge