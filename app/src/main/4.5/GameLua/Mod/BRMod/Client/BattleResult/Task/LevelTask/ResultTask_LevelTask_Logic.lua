local ResultTask_LevelTask_Logic = {}
local summary_before_result, task_before_result, task_after_result, task_summary, finished_task_list, inProgress_task_list, drop_id_list
local EnumLevelDataType = {
  levelTask1 = 1,
  levelTask2 = 2,
  levelAward = 3
}
local maxTaskCount = 5
local CleanData = function()
  summary_before_result = nil
  task_before_result = nil
  task_after_result = nil
  task_summary = nil
  finished_task_list = nil
  inProgress_task_list = nil
end
local ShouldFilterTask = function(level, levelDataType)
  if not task_before_result or not task_before_result[level] then
    return false
  end
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  if levelDataType == EnumLevelDataType.levelTask1 then
    return task_before_result[level].task1_status == ResultTask_Macro.ENUM_TaskStatus.Taken
  elseif levelDataType == EnumLevelDataType.levelTask2 then
    return task_before_result[level].task2_status == ResultTask_Macro.ENUM_TaskStatus.Taken
  elseif levelDataType == EnumLevelDataType.levelAward then
    return task_before_result[level].task_status == ResultTask_Macro.ENUM_TaskStatus.Taken
  end
  return true
end
local GetLevelTaskAwardInfo = function(levelcfg, task_type)
  log(bWriteLog and "[ZH] GetLevelTaskAwardInfo")
  local taskInfo = {}
  if levelcfg.TaskTpye1 == task_type then
    taskInfo.DropId = levelcfg.Task1Award
    taskInfo.Dec = levelcfg.Task1Detail
  elseif levelcfg.TaskTpye2 == task_type then
    taskInfo.DropId = levelcfg.Task2Award
    taskInfo.Dec = levelcfg.Task2Detail
  else
    log(bWriteLog and "GetLevelTaskAwardInfo invalid task_type")
  end
  return taskInfo
end
local GetLevelAwardInfo = function(levelcfg, level)
  log(bWriteLog and "[ZH] GetLevelAwardInfo")
  local taskInfo = {}
  taskInfo.DropId = levelcfg.Award
  taskInfo.Dec = LocUtil.LocalizeResFormat(108100, level)
  return taskInfo
end
local GetLevelCfgData = function(level)
  local levelTaskInfo = CDataTable.GetTableData("NewLevelTask", level)
  if not levelTaskInfo then
    return
  end
  local LevelInfo = {}
  LevelInfo.Award = levelTaskInfo.Award
  LevelInfo.Task1Detail = levelTaskInfo.Task1Detail
  LevelInfo.Task1Award = levelTaskInfo.Task1Award
  LevelInfo.TaskTpye1 = levelTaskInfo.TaskTpye1
  LevelInfo.Task2Detail = levelTaskInfo.Task2Detail
  LevelInfo.Task2Award = levelTaskInfo.Task2Award
  LevelInfo.TaskTpye2 = levelTaskInfo.TaskTpye2
  return LevelInfo
end
function ResultTask_LevelTask_Logic:OnInit()
end
function ResultTask_LevelTask_Logic:OnUnInit()
  CleanData()
end
function ResultTask_LevelTask_Logic:GetFinishedTaskList()
  if finished_task_list == nil or #finished_task_list <= maxTaskCount then
    log(bWriteLog and "ResultTask_LevelTask_Logic:GetFinishedTaskList <= maxTaskCount")
    return finished_task_list
  else
    log(bWriteLog and "ResultTask_LevelTask_Logic:GetFinishedTaskList > maxTaskCount")
    local temp_finished_task_list = {}
    for idx = 1, maxTaskCount do
      table.insert(temp_finished_task_list, finished_task_list[idx])
    end
    return temp_finished_task_list
  end
end
function ResultTask_LevelTask_Logic:GetInProgressTaskList()
  if inProgress_task_list == nil or #inProgress_task_list <= maxTaskCount then
    log(bWriteLog and "ResultTask_LevelTask_Logic:GetInProgressTaskList <= maxTaskCount")
    return inProgress_task_list
  else
    log(bWriteLog and "ResultTask_LevelTask_Logic:GetInProgressTaskList > maxTaskCount")
    local temp_inProgress_task_list = {}
    for idx = 1, maxTaskCount do
      table.insert(temp_inProgress_task_list, inProgress_task_list[idx])
    end
    return temp_inProgress_task_list
  end
end
function ResultTask_LevelTask_Logic:GetSummaryInfo()
  return task_summary
end
function ResultTask_LevelTask_Logic:on_task_status_notify(flag, summary, task_status)
  if flag == 0 then
    summary_before_result = summary.level_task_summary or {}
    task_before_result = task_status.level_task_status or {}
  elseif flag == 1 then
    self:GenerateTaskList(task_status.level_task_status)
    self:GenerateSummaryInfo(summary.level_task_summary)
  end
end
function ResultTask_LevelTask_Logic:GenerateTaskList(level_task_status)
  if not level_task_status or not next(level_task_status) then
    return
  end
  log(bWriteLog and "ResultTask_LevelTask_Logic:GenerateTaskList")
  self:GenerateTaskDataList(level_task_status)
  if drop_id_list and next(drop_id_list) then
    task_after_result = level_task_status
    self:ReqDropInfo()
  end
end
function ResultTask_LevelTask_Logic:GenerateTaskDataList(level_task_status)
  finished_task_list = nil
  inProgress_task_list = nil
  drop_id_list = nil
  if not level_task_status or not next(level_task_status) then
    return
  end
  log(bWriteLog and "ResultTask_LevelTask_Logic:GenerateTaskDataList")
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  for level, Info in pairs(level_task_status) do
    local level_task_cfg = GetLevelCfgData(level)
    if level_task_cfg then
      log(bWriteLog and "ResultTask_LevelTask_Logic:GenerateTaskList level is" .. tostring(level))
      log(bWriteLog and "ResultTask_LevelTask_Logic:GenerateTaskList Infolevel is" .. tostring(Info.level))
      self:ConstructTaskData(level_task_cfg, Info, EnumLevelDataType.levelAward)
      self:ConstructTaskData(level_task_cfg, Info, EnumLevelDataType.levelTask1)
      self:ConstructTaskData(level_task_cfg, Info, EnumLevelDataType.levelTask2)
    end
  end
end
function ResultTask_LevelTask_Logic:GenerateSummaryInfo(level_task_summary)
  task_summary = nil
  if not level_task_summary or not next(level_task_summary) then
    log(bWriteLog and "ResultTask_LevelTask_Logic:GenerateSummaryInfo no segment_summary")
    return
  end
  if not summary_before_result or not next(summary_before_result) then
    log(bWriteLog and "ResultTask_LevelTask_Logic:GenerateSummaryInfo no summary_before_result")
    return
  end
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  local convertAwardList = self:GetLevelRewardInfo(level_task_summary.level_task)
  local rank = CDataTable.GetTableData("MilitaryRankLevel", level_task_summary.level)
  task_summary = {
    taskType = ResultTask_Macro.ENUM_TaskType.LevelTask,
    pre_level = summary_before_result.level,
    pre_score = summary_before_result.level_exp,
    pre_base = 0,
    pre_level_target_score = self:GetNeedExp(summary_before_result.level),
    cur_level = level_task_summary.level,
    cur_score = level_task_summary.level_exp,
    cur_base = 0,
    cur_level_target_score = self:GetNeedExp(level_task_summary.level),
    cur_level_desc = rank and rank.MilitaryRankName or "",
    level_anim_begin_value = 0,
    awardList = convertAwardList,
    showAwardList = 0 < #convertAwardList,
    bPlayProgressBarAnim = level_task_summary.level_exp ~= summary_before_result.level_exp,
    bSkipLastScoreChange = level_task_summary.level == 100
  }
  task_summary.cur_level_score_delta = task_summary.cur_score - task_summary.cur_base
end
function ResultTask_LevelTask_Logic:GetNeedExp(level)
  log(bWriteLog and "ResultTask_LevelTask_Logic:GetNeedExp level = " .. tostring(level))
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  return CorpsMgr.GetLevelExp(level)
end
function ResultTask_LevelTask_Logic:GetLevelInfo(levelcfg, info)
  if not info then
    return {}
  end
  if info.task_type == -1 then
    return GetLevelAwardInfo(levelcfg, info.level)
  end
  return GetLevelTaskAwardInfo(levelcfg, info.task_type)
end
function ResultTask_LevelTask_Logic:GetTaskAwardInfo(DropId)
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  local CurrentDropList = BasicDataDropTable:GetCacheData(DropId)
  return CurrentDropList and CurrentDropList[1]
end
function ResultTask_LevelTask_Logic:ReqDropInfo()
  if drop_id_list == nil or not next(drop_id_list) then
    return
  end
  local onGetDropListRsp = function(drop_list)
    log(bWriteLog and "ResultTask_LevelTask_Logic:onGetDropListRsp")
    if task_after_result then
      self:GenerateTaskDataList(task_after_result)
      EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_RESULT_RANKING_TASK_REFRESH_TASKLIST)
    end
  end
  log_tree("[ZH] ReqDropInfo drop_id_list", drop_id_list)
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  BasicDataDropTable:BatchGetOrReqData(drop_id_list, onGetDropListRsp)
end
function ResultTask_LevelTask_Logic:GetLevelRewardInfo(level_task)
  log(bWriteLog and "[ZH] ResultTask_LevelTask_Logic:GetLevelRewardInfo")
  local resultLevelTasks = {}
  if not level_task or not next(level_task) then
    log(bWriteLog and "[ZH] GetLevelRewardInfo level_task is nil")
    return {}
  end
  for k, v in pairs(level_task) do
    for i, vv in ipairs(v[3] or {}) do
      local Key = self:_CheckIsExist(resultLevelTasks, vv.res_id)
      if Key and resultLevelTasks[Key] then
        resultLevelTasks[Key].res_num = resultLevelTasks[Key].res_num + vv.count
      else
        local tab = {
          res_num = vv.count,
          valid_hours = vv.valid_hours,
          res_id = vv.res_id,
          expire_ts = vv.expire_ts
        }
        table.insert(resultLevelTasks, tab)
      end
    end
  end
  log_tree("[ZH] GetLevelRewardInfo resultLevelTasks", resultLevelTasks)
  return resultLevelTasks
end
function ResultTask_LevelTask_Logic:_CheckIsExist(resultLevelTasks, res_id)
  for k, v in pairs(resultLevelTasks) do
    if res_id == v.res_id then
      return k
    end
  end
  return false
end
function ResultTask_LevelTask_Logic:ConstructTaskData(levelCfg, levelTaskInfo, levelDataType)
  if levelDataType == nil or levelCfg == nil or levelTaskInfo == nil then
    log(bWriteLog and "ResultTask_LevelTask_Logic:ConstructTaskData invalid params!")
    return
  end
  log(bWriteLog and "ResultTask_LevelTask_Logic:ConstructTaskData levelDataType is " .. tostring(levelDataType))
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  local level = levelTaskInfo.level
  local taskInfo
  if levelDataType == EnumLevelDataType.levelTask1 and levelTaskInfo.task1_type then
    taskInfo = GetLevelTaskAwardInfo(levelCfg, levelTaskInfo.task1_type)
    if taskInfo and next(taskInfo) then
      taskInfo.task_progress = levelTaskInfo.task1_progress
      taskInfo.progress = levelTaskInfo.progress1
      taskInfo.pre_value = 0
      if task_before_result and task_before_result[level] and task_before_result[level].progress1 then
        taskInfo.pre_value = task_before_result[level].progress1
      end
      taskInfo.task_status = levelTaskInfo.task1_status
    end
  elseif levelDataType == EnumLevelDataType.levelTask2 and levelTaskInfo.task2_type then
    taskInfo = GetLevelTaskAwardInfo(levelCfg, levelTaskInfo.task2_type)
    if taskInfo and next(taskInfo) then
      taskInfo.task_progress = levelTaskInfo.task2_progress
      taskInfo.progress = levelTaskInfo.progress2
      taskInfo.pre_value = 0
      if task_before_result and task_before_result[level] and task_before_result[level].progress2 then
        taskInfo.pre_value = task_before_result[level].progress2
      end
      taskInfo.task_status = levelTaskInfo.task2_status
    end
  elseif levelDataType == EnumLevelDataType.levelAward and levelTaskInfo.task_status then
    if levelTaskInfo.task_status == ResultTask_Macro.ENUM_TaskStatus.Taken then
      taskInfo = GetLevelAwardInfo(levelCfg, level)
      taskInfo.task_status = levelTaskInfo.task_status
    end
  else
    log(bWriteLog and "ResultTask_LevelTask_Logic:ConstructTaskData data is nil!")
  end
  if taskInfo == nil or not next(taskInfo) then
    log(bWriteLog and "ResultTask_LevelTask_Logic:ConstructTaskData nil taskInfo!")
    return
  end
  local task_data = {
    taskType = ResultTask_Macro.ENUM_TaskType.LevelTask,
    desc = taskInfo.Dec or "",
    finish_value = taskInfo.task_progress or 0,
    pre_value = taskInfo.pre_value or 0,
    cur_value = taskInfo.progress or 0,
    reward_info = self:GetTaskAwardInfo(taskInfo.DropId),
    status = taskInfo.task_status
  }
  if taskInfo.task_status == ResultTask_Macro.ENUM_TaskStatus.Taken then
    if not ShouldFilterTask(level, levelDataType) then
      if finished_task_list == nil then
        finished_task_list = {}
      end
      log(bWriteLog and "ResultTask_LevelTask_Logic:ConstructTaskData insert finished task level is " .. tostring(level))
      log(bWriteLog and "ResultTask_LevelTask_Logic:ConstructTaskData insert finished task type is " .. tostring(levelDataType))
      table.insert(finished_task_list, task_data)
    end
  else
    if inProgress_task_list == nil then
      inProgress_task_list = {}
    end
    table.insert(inProgress_task_list, task_data)
  end
  if (not task_data.reward_info or not next(task_data.reward_info)) and taskInfo.DropId and taskInfo.DropId ~= 0 then
    drop_id_list = drop_id_list or {}
    table.insert(drop_id_list, taskInfo.DropId)
  end
end
return ResultTask_LevelTask_Logic