local season_year_badge_util = {}
function season_year_badge_util.GetCurSeasonYearBadgeInfo()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  return logic_season_year_badge:GetCurSeasonYearBadgeInfo()
end
function season_year_badge_util.GetCurSeasonYearBadgePartInfo(partType)
  local cur_season_year_badge_info = season_year_badge_util.GetCurSeasonYearBadgeInfo()
  local partInfo = cur_season_year_badge_info and cur_season_year_badge_info[partType] or {}
  return partInfo
end
function season_year_badge_util.GetCurSeasonYearBadgePartCfgInfo(partType)
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  local badgeCfg = logic_season_year_badge:GetCurSeasonYearBadgeCfg()
  return badgeCfg and badgeCfg[partType] or {}
end
function season_year_badge_util.GetCurSeasonYearTaskCfg()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  local cur_season_year_task_cfg = logic_season_year_badge:GetCurSeasonYearTaskCfg()
  if cur_season_year_task_cfg == nil or cur_season_year_task_cfg.task_cfgs == nil then
    return {}
  end
  for task_id, task_info in pairs(cur_season_year_task_cfg.task_cfgs) do
    return task_info
  end
  return {}
end
function season_year_badge_util.GetCurSeasonYearTaskInfo()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  local seasonYearTaskInfo = logic_season_year_badge:GetCurSeasonYearTaskInfo()
  for task_id, task_info in pairs(seasonYearTaskInfo) do
    task_info.    return task_info
  end
  return {}
end
function season_year_badge_util.GetSeasonYearBadge(uid)
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    return logic_season_year_badge:GetCurSeasonYearBadgeInfo()
  else
    return logic_season_year_badge:GetOtherSeasonYearBadgeInfo(uid)
  end
end
function season_year_badge_util.CheckGotBadge(badgeData)
  if not badgeData then
    return false
  end
  for _, partInfo in pairs(badgeData) do
    for _, taskInfo in pairs(partInfo) do
      if taskInfo.finish_count > 0 then
        return true
      end
    end
  end
  return false
end
function season_year_badge_util.GetBadgeShowType()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  return logic_season_year_badge:GetBadgeShowType()
end
function season_year_badge_util.GetBadgeShowLevel(badgeData)
  local season_year_config = require("client.logic.season_year.config.season_year_config")
  local EBadgePartType = season_year_config.EBadgePartType
  if not badgeData or not badgeData[EBadgePartType.Glow] then
    return 1
  end
  local level = 0
  if badgeData[EBadgePartType.Glow] then
    for _, task_info in pairs(badgeData[EBadgePartType.Glow]) do
      level = level + (task_info.status ~= 0 and 1 or 0)
    end
  end
  return 0 < level and level or 1
end
function season_year_badge_util.GetCurSeasonYearLoginDays()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  return logic_season_year_badge:GetCurSeasonYearLoginDays()
end
function season_year_badge_util.GetCurSeasonYearSlapInfo()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  return logic_season_year_badge:GetSeasonYearLevelUpSlap()
end
function season_year_badge_util.ResetSeasonYearSlapInfo()
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  return logic_season_year_badge:ResetSeasonYearSlapInfo()
end
return season_year_badge_util