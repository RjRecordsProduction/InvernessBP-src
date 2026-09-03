local ResultTask_DailyTask_Logic = {}
local summary_before_result, task_before_result, task_summary, finished_task_list, inProgress_task_list
local AdvertiseTaskType = 33
local CleanData = function()
  summary_before_result = nil
  task_before_result = nil
  task_summary = nil
  finished_task_list = nil
  inProgress_task_list = nil
end
local GetTaskPreValue = function(task_id)
  if not task_before_result or not task_before_result[task_id] then
    return 0
  end
  return math.floor(task_before_result[task_id].value)
end
local ShouldFilterTask = function(task_id)
  if not task_before_result or not task_before_result[task_id] then
    return false
  end
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  return task_before_result[task_id].status == ResultTask_Macro.ENUM_TaskStatus.Taken
end
function ResultTask_DailyTask_Logic:OnInit()
end
function ResultTask_DailyTask_Logic:OnUnInit()
  CleanData()
end
function ResultTask_DailyTask_Logic:GetFinishedTaskList()
  return finished_task_list
end
function ResultTask_DailyTask_Logic:GetInProgressTaskList()
  return inProgress_task_list
end
function ResultTask_DailyTask_Logic:GetSummaryInfo()
  return task_summary
end
function ResultTask_DailyTask_Logic:on_task_status_notify(flag, summary, task_status)
  if flag == 0 then
    summary_before_result = summary.daily_task_summary
    task_before_result = task_status.daily_task
  elseif flag == 1 then
    self:GenerateTaskList(task_status.daily_task)
    self:GenerateSummaryInfo(summary.daily_task_summary)
  end
end
function ResultTask_DailyTask_Logic:GenerateTaskList(daily_task)
  finished_task_list = nil
  inProgress_task_list = nil
  if not daily_task or not next(daily_task) then
    return
  end
  local logic_new_day_task = require("client.slua.logic.task.logic_new_day_task")
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  for taskId, task in pairs(daily_task) do
    if type(taskId) == "number" then
      local task_type = logic_new_day_task.GetTaskType(taskId)
      if task_type ~= AdvertiseTaskType then
        local task_data = {
          taskType = ResultTask_Macro.ENUM_TaskType.DailyTask,
          desc = logic_new_day_task.GetDailyTaskDesc(taskId),
          finish_value = task.finish_value,
          cur_value = task.value and math.floor(task.value) or 0,
          pre_value = GetTaskPreValue(taskId),
          reward_id = task.reward_id,
          status = task.status
        }
        if task.status == ResultTask_Macro.ENUM_TaskStatus.Taken then
          if not ShouldFilterTask(taskId) then
            if finished_task_list == nil then
              finished_task_list = {}
            end
            table.insert(finished_task_list, task_data)
          end
        elseif task.status == ResultTask_Macro.ENUM_TaskStatus.InProgress then
          if inProgress_task_list == nil then
            inProgress_task_list = {}
          end
          table.insert(inProgress_task_list, task_data)
        end
      end
    end
  end
end
function ResultTask_DailyTask_Logic:GenerateSummaryInfo(daily_task_summary)
  log(bWriteLog and "430 ResultTask_DailyTask_Logic:GenerateSummaryInfo daily_task_summary = nil")
  task_summary = nil
  if not daily_task_summary or not next(daily_task_summary) then
    return
  end
  return
end
function ResultTask_DailyTask_Logic:GetLevelAndTargetScore(cur_act_id, cur_value)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_week_active_award_cfg = BasicDataServerTable:GetCacheData(data_config_marco.general_week_active_award_cfg)
  if not general_week_active_award_cfg then
    return 0, 0, 0
  end
  local cfg = general_week_active_award_cfg[cur_act_id]
  if not cfg then
    return 0, 0, 0
  end
  local retLevel = 0
  local preAward, curAward
  for level, reward in ipairs(cfg) do
    retLevel = level
    preAward = curAward
    curAward = reward
    if cur_value < reward.value then
      break
    end
  end
  if not curAward then
    return 0, 0, 0
  end
  if preAward then
    return retLevel, preAward.value, curAward.value
  else
    return retLevel, 0, curAward.value
  end
end
return ResultTask_DailyTask_Logic