local ResultTask_BP_Logic = {}
local summary_before_result, task_before_result, task_summary, finished_task_list, inProgress_task_list
local CleanData = function()
  summary_before_result = nil
  task_before_result = nil
  task_summary = nil
  finished_task_list = nil
  inProgress_task_list = nil
end
local GetWeekTaskPreValue = function(task_id)
  if not task_before_result or not task_before_result[task_id] then
    return 0
  end
  return math.floor(task_before_result[task_id].value)
end
local GetWeekTaskPreStatus = function(task_id)
  if not task_before_result or not task_before_result[task_id] then
    return 0
  end
  return task_before_result[task_id].status
end
local ShouldFilterTask = function(task_id)
  if not task_before_result or not task_before_result[task_id] then
    return false
  end
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  return task_before_result[task_id].status == ResultTask_Macro.ENUM_TaskStatus.Taken
end
function ResultTask_BP_Logic:OnInit()
end
function ResultTask_BP_Logic:OnUnInit()
  CleanData()
end
function ResultTask_BP_Logic:GetFinishedTaskList()
  return finished_task_list
end
function ResultTask_BP_Logic:GetInProgressTaskList()
  return inProgress_task_list
end
function ResultTask_BP_Logic:GetSummaryInfo()
  return task_summary
end
function ResultTask_BP_Logic:on_task_status_notify(flag, summary, task_status)
  if flag == 0 and summary and summary.bp_summary then
    summary_before_result = summary.bp_summary
    summary_before_result.score = (summary_before_result.score or 0) % (summary_before_result.next_level_score or 100)
    task_before_result = task_status.bp_task and task_status.bp_task.tasks
  elseif flag == 1 then
    self:GenerateTaskList(task_status)
    self:GenerateSummaryInfo(summary.bp_summary)
  end
end
function ResultTask_BP_Logic:GenerateTaskList(task_status)
  finished_task_list = {}
  inProgress_task_list = {}
  if not (task_status and task_status.bp_task) or not task_status.bp_task.tasks then
    return
  end
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  local logic_new_day_task = require("client.slua.logic.task.logic_new_day_task")
  local shown_task_ids = {}
  local tTasks = task_status.bp_task.tasks
  for taskId, task in pairs(tTasks) do
    if type(taskId) == "number" then
      local pre_value = GetWeekTaskPreValue(taskId)
      local cur_value = task.finish_value
      local ignore = false
      local targetList = finished_task_list
      if task.status == ResultTask_Macro.ENUM_TaskStatus.InProgress then
        cur_value = math.floor(task.value)
        targetList = inProgress_task_list
      elseif task.status == ResultTask_Macro.ENUM_TaskStatus.Taken then
        ignore = ShouldFilterTask(taskId)
      end
      local nTaskId = taskId
      if task.task_id and taskId ~= task.task_id and not ignore then
        ignore = true
        nTaskId = task.task_id
        local bIsHasShown = false
        for _, taskid in pairs(shown_task_ids) do
          if nTaskId == taskid then
            bIsHasShown = true
            break
          end
        end
        if not bIsHasShown then
          if task_before_result and task_before_result[nTaskId] then
            if task_before_result[nTaskId].status == ResultTask_Macro.ENUM_TaskStatus.Taken then
              ignore = false
            end
          else
            ignore = false
          end
        end
        if not ignore then
          local nCurShowTaskId = 0
          local nCurTaskValue = 0
          local tTaskIdMap = task_status.bp_task.daily_task_map
          if tTaskIdMap and tTaskIdMap[nTaskId] then
            for _, id in pairs(tTaskIdMap[nTaskId]) do
              local nCurTaskStatus = tTasks[id].status
              local nPreTaskStatus = GetWeekTaskPreStatus(id)
              if nPreTaskStatus ~= nCurTaskStatus then
                nCurShowTaskId = id
                nCurTaskValue = tTasks[nCurShowTaskId].value
                break
              end
            end
            if nCurShowTaskId == 0 then
              for _, id in pairs(tTaskIdMap[nTaskId]) do
                local nPreTaskStatus = GetWeekTaskPreStatus(id)
                if nPreTaskStatus ~= ResultTask_Macro.ENUM_TaskStatus.Taken and nCurTaskValue <= tTasks[id].value then
                  nCurShowTaskId = id
                  nCurTaskValue = tTasks[nCurShowTaskId].value
                end
              end
            end
          end
          if nCurShowTaskId == 0 then
            tTaskIdMap = task_status.bp_task.weekly_task_map
            if tTaskIdMap and tTaskIdMap[nTaskId] then
              for _, id in pairs(tTaskIdMap[nTaskId]) do
                if tTasks[id] then
                  local nCurTaskStatus = tTasks[id].status
                  local nPreTaskStatus = GetWeekTaskPreStatus(id)
                  if nPreTaskStatus ~= nCurTaskStatus then
                    nCurShowTaskId = id
                    nCurTaskValue = tTasks[nCurShowTaskId].value
                    break
                  end
                else
                  log(bWriteLog and "ResultTask_BP_Logic:GenerateTaskList tTasks[id] is nil " .. tostring(id))
                end
              end
              if nCurShowTaskId == 0 then
                for _, id in pairs(tTaskIdMap[nTaskId]) do
                  local nPreTaskStatus = GetWeekTaskPreStatus(id)
                  if nPreTaskStatus ~= ResultTask_Macro.ENUM_TaskStatus.Taken and tTasks[id] and nCurTaskValue <= tTasks[id].value then
                    nCurShowTaskId = id
                    nCurTaskValue = tTasks[nCurShowTaskId].value
                  end
                end
              end
            end
          end
          if 0 < nCurShowTaskId then
            cur_value = nCurTaskValue
            pre_value = GetWeekTaskPreValue(nCurShowTaskId)
            task.finish_value = tTasks[nCurShowTaskId].finish_value
            task.status = tTasks[nCurShowTaskId].status
            task.score = tTasks[nCurShowTaskId].score
          end
          table.insert(shown_task_ids, nTaskId)
        end
      end
      if not ignore then
        local task_data = {
          taskType = ResultTask_Macro.ENUM_TaskType.BP,
          desc = logic_new_day_task.GetDailyTaskDesc(nTaskId),
          finish_value = task.finish_value,
          cur_value = cur_value,
          pre_value = pre_value,
          status = task.status,
          score = task.score
        }
        table.insert(targetList, task_data)
      end
    end
  end
end
function ResultTask_BP_Logic:GenerateSummaryInfo(bp_summary)
  task_summary = nil
  if not (bp_summary and next(bp_summary) and summary_before_result) or not summary_before_result.score then
    log(bWriteLog and "ResultTask_BP_Logic:GenerateSummaryInfo bp_summary is nil")
    return
  end
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  local ResultTask_Util = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Util")
  local convertAwardList = ResultTask_Util:ConvertRewardList(bp_summary, ResultTask_Macro.BP_SCORE_ITEM_RES_ID)
  bp_summary.score = (bp_summary.score or 0) % (bp_summary.next_level_score or 100)
  summary_before_result.score = (summary_before_result.score or 0) % (summary_before_result.next_level_score or 100)
  print(bWriteLog and "ResultTask_BP_Logic:GenerateSummaryInfo", bp_summary.score, bp_summary.next_level_score, summary_before_result.score, summary_before_result.next_level_score)
  task_summary = {
    taskType = ResultTask_Macro.ENUM_TaskType.BP,
    pre_score = summary_before_result and summary_before_result.score or 0,
    pre_level = summary_before_result and summary_before_result.cur_level or 0,
    pre_level_target_score = summary_before_result and summary_before_result.next_level_score or 100,
    cur_score = bp_summary.score or 0,
    cur_level = bp_summary.cur_level or 0,
    cur_level_desc = tostring(bp_summary.cur_level or 0),
    cur_level_score_delta = bp_summary.score or 0,
    level_anim_begin_value = 0,
    cur_level_target_score = bp_summary.next_level_score or 100,
    awardList = convertAwardList,
    showAwardList = 0 < #convertAwardList,
    bPlayProgressBarAnim = (bp_summary.cur_level or 0) < (bp_summary.max_level or 20)
  }
end
return ResultTask_BP_Logic