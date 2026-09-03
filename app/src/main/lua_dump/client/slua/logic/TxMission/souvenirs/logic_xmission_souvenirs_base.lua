local logic_xmission_souvenirs_base = {}
local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
function logic_xmission_souvenirs_base:ctor()
  self.achievementConfig = nil
end
function logic_xmission_souvenirs_base:GetHighestTaskChain(taskId)
  local taskChain = self:GetTaskChain(taskId)
  if not taskChain then
    log(bWriteLog and "logic_xmission_souvenirs_base:GetUpgradeTaskChain no taskChain")
    return
  end
  local highestTaskChain = {}
  for i = #taskChain, 1, -1 do
    local taskId = taskChain[i]
    local status = self:GetTaskStatus(taskId)
    if status == souvenirs_macro.TaskStatus.Rewarded and not self:IsTaskHaveHomeRights(taskId) then
      table.insert(highestTaskChain, taskId)
      break
    end
  end
  local homeTaskId = self:GetHomeTaskId(taskChain[1])
  local status = self:GetTaskStatus(homeTaskId)
  if status == souvenirs_macro.TaskStatus.Rewarded then
    table.insert(highestTaskChain, homeTaskId)
  end
  return highestTaskChain
end
function logic_xmission_souvenirs_base:GetUpgradeTaskChain(taskId)
  local taskChain = self:GetTaskChain(taskId)
  if not taskChain then
    log(bWriteLog and "logic_xmission_souvenirs_base:GetUpgradeTaskChain no taskChain")
    return
  end
  local upgradeTaskChain = {}
  for i = 1, #taskChain do
    local status = self:GetTaskStatus(taskChain[i])
    if status == souvenirs_macro.TaskStatus.NotFinish then
      table.insert(upgradeTaskChain, taskChain[i])
    end
  end
  return upgradeTaskChain
end
function logic_xmission_souvenirs_base:GetTaskChain(taskId)
  log(bWriteLog and "logic_xmission_souvenirs_base:GetTaskChain taskId:" .. tostring(taskId))
  local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", taskId)
  if not XMAchievementConfig or not self.achievementConfig then
    log(bWriteLog and "logic_xmission_souvenirs_base:GetTaskChain no XMAchievementConfig")
    return {}
  end
  local taskList = self.achievementConfig[XMAchievementConfig.start_season_id] and self.achievementConfig[XMAchievementConfig.start_season_id][XMAchievementConfig.position]
  log_tree(bWriteLog and "logic_xmission_souvenirs_base:GetTaskChain taskList:", taskList)
  return taskList
end
function logic_xmission_souvenirs_base:GetPreTaskID(taskId)
  log(bWriteLog and "logic_xmission_souvenirs_base:GetPreTaskID taskId:" .. tostring(taskId))
  local taskList = self:GetTaskChain(taskId)
  for idx, id in ipairs(taskList or {}) do
    if id == taskId then
      local preTaskId = taskList[idx - 1] or 0
      log(bWriteLog and "logic_xmission_souvenirs_base:GetPreTaskID preTaskId:" .. tostring(preTaskId))
      return preTaskId
    end
  end
  log(bWriteLog and "logic_xmission_souvenirs_base:GetPreTaskID no preTaskId")
  return 0
end
function logic_xmission_souvenirs_base:GetNextTaskID(taskId)
  log(bWriteLog and "logic_xmission_souvenirs_base:GetNextTaskID taskId:" .. tostring(taskId))
  local taskList = self:GetTaskChain(taskId)
  for idx, id in ipairs(taskList) do
    if id == taskId then
      local nextTaskId = taskList[idx + 1] or 0
      log(bWriteLog and "logic_xmission_souvenirs_base:GetNextTaskID nextTaskId:" .. tostring(nextTaskId))
      return nextTaskId
    end
  end
  log(bWriteLog and "logic_xmission_souvenirs_base:GetNextTaskID no nextTaskId")
  return 0
end
function logic_xmission_souvenirs_base:IsUpgradeTypeTask(taskId)
  log(bWriteLog and "logic_xmission_souvenirs_base:IsUpgradeTypeTask taskId:" .. tostring(taskId))
  local taskList = self:GetTaskChain(taskId)
  local len = #taskList
  for k, v in pairs(taskList) do
    local XMAchievementConfig = CDataTable.GetTableData("XMAchievement", v)
    local level = XMAchievementConfig.ach_level
    if level == 4 then
      len = len - 1
    end
  end
  local canUpgrade = 1 < len
  log(bWriteLog and "logic_xmission_souvenirs_base:IsUpgradeTypeTask canUpgrade:" .. tostring(canUpgrade))
  return canUpgrade
end
function logic_xmission_souvenirs_base:InitAchievementConfig(uid)
  self.achievementConfig = {}
  local logic_xmission_season = require("client.slua.logic.TxMission.season.logic_xmission_season")
  local endSeasonId = logic_xmission_season.GetCurTXSeasonID()
  local startSeasonID = self:GetInitialSeasonID(uid)
  log(bWriteLog and "logic_xmission_souvenirs_base:InitAchievementConfig startSeasonID:" .. tostring(startSeasonID))
  log(bWriteLog and "logic_xmission_souvenirs_base:InitAchievementConfig endSeasonId:" .. tostring(endSeasonId))
  local XMAchievement = CDataTable.GetTable("XMAchievement")
  for _, cfg in pairs(XMAchievement) do
    if startSeasonID <= cfg.start_season_id and endSeasonId >= cfg.start_season_id then
      log(bWriteLog and "logic_xmission_souvenirs_base:InitAchievementConfig start_season_id:" .. tostring(cfg.start_season_id))
      if not self.achievementConfig[cfg.start_season_id] then
        self.achievementConfig[cfg.start_season_id] = {}
      end
      if not self.achievementConfig[cfg.start_season_id][cfg.position] then
        self.achievementConfig[cfg.start_season_id][cfg.position] = {}
      end
      if cfg.ach_level ~= 5 then
        table.insert(self.achievementConfig[cfg.start_season_id][cfg.position], cfg.Id)
      end
    end
  end
  for _, seasonTaskMap in pairs(self.achievementConfig) do
    for _, taskList in pairs(seasonTaskMap) do
      table.sort(taskList, function(taskIdA, taskIdB)
        local XMAchievementConfigA = CDataTable.GetTableData("XMAchievement", taskIdA)
        local XMAchievementConfigB = CDataTable.GetTableData("XMAchievement", taskIdB)
        return XMAchievementConfigA.ach_level < XMAchievementConfigB.ach_level
      end)
    end
  end
  log(bWriteLog and string.format("logic_xmission_souvenirs_base:InitAchievementConfig, uid:%s", uid))
  log_tree(bWriteLog and "logic_xmission_souvenirs_base:InitAchievementConfig achievementConfig:", self.achievementConfig)
end
function logic_xmission_souvenirs_base:ConvertSeasonTaskMapToList(allSeasonTaskMap)
  local allSeasonTaskList = {}
  for seasonId, taskList in pairs(allSeasonTaskMap) do
    table.insert(allSeasonTaskList, {seasonId = seasonId, taskList = taskList})
  end
  table.sort(allSeasonTaskList, function(a, b)
    return a.seasonId > b.seasonId
  end)
  for _, showTaskMap in pairs(allSeasonTaskList) do
    table.sort(showTaskMap.taskList, function(taskIdA, taskIdB)
      local XMAchievementConfigA = CDataTable.GetTableData("XMAchievement", taskIdA)
      local XMAchievementConfigB = CDataTable.GetTableData("XMAchievement", taskIdB)
      return XMAchievementConfigA.position < XMAchievementConfigB.position
    end)
  end
  return allSeasonTaskList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_xmission_souvenirs_base = class(CModuleBase, nil, logic_xmission_souvenirs_base)
return Clogic_xmission_souvenirs_base