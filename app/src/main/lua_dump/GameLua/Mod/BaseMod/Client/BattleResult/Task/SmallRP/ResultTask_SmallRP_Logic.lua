local ResultTask_SmallRP_Logic = {}
local _tOldTaskSummary, _tOldTaskData, _tNewTaskSummary, _tFinishedTaskList, _tInProgressTaskList
local _CleanData = function()
  _tOldTaskSummary = nil
  _tOldTaskData = nil
  _tNewTaskSummary = nil
  _tFinishedTaskList = nil
  _tInProgressTaskList = nil
end
local _ShouldFilterTask = function(nTaskId)
  if not _tOldTaskData or not _tOldTaskData[nTaskId] then
    return false
  end
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  return _tOldTaskData[nTaskId].status == ResultTask_Macro.ENUM_TaskStatus.Taken
end
local _GetTaskOldPreValue = function(nTaskId)
  if not _tOldTaskData or not _tOldTaskData[nTaskId] then
    return 0
  end
  return math.floor(_tOldTaskData[nTaskId].value)
end
function ResultTask_SmallRP_Logic:OnInit()
end
function ResultTask_SmallRP_Logic:OnUnInit()
  _CleanData()
end
function ResultTask_SmallRP_Logic:GetFinishedTaskList()
  return _tFinishedTaskList
end
function ResultTask_SmallRP_Logic:GetInProgressTaskList()
  return _tInProgressTaskList
end
function ResultTask_SmallRP_Logic:GetSummaryInfo()
  return _tNewTaskSummary
end
function ResultTask_SmallRP_Logic:on_task_status_notify(flag, summary, task_status)
  if flag == 0 and summary and summary.small_rp_summary then
    _tOldTaskSummary = summary.small_rp_summary
    _tOldTaskData = task_status.small_rp_task
  elseif flag == 1 and summary and summary.small_rp_summary then
    self:GenerateTaskList(task_status, summary.small_rp_summary.score_item_id)
    self:GenerateSummaryInfo(summary.small_rp_summary)
  end
end
function ResultTask_SmallRP_Logic:GenerateTaskList(task_status, nScoreItemId)
  _tFinishedTaskList = {}
  _tInProgressTaskList = {}
  if not task_status or not task_status.small_rp_task then
    return
  end
  local logic_new_day_task = require("client.slua.logic.task.logic_new_day_task")
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  for k, v in pairs(task_status.small_rp_task) do
    local cur_value = v.finish_value
    local ignore = false
    local targetList = _tFinishedTaskList
    if v.status == ResultTask_Macro.ENUM_TaskStatus.InProgress then
      cur_value = math.floor(v.value)
      targetList = _tInProgressTaskList
    elseif v.status == ResultTask_Macro.ENUM_TaskStatus.Taken then
      ignore = _ShouldFilterTask(k)
    end
    if not ignore then
      local task_data = {
        nTaskId = k,
        nScoreItemId = nScoreItemId,
        taskType = ResultTask_Macro.ENUM_TaskType.SmallRP,
        desc = logic_new_day_task.GetDailyTaskDesc(k),
        finish_value = v.finish_value,
        cur_value = cur_value,
        pre_value = _GetTaskOldPreValue(k),
        status = v.status,
        score = v.score
      }
      table.insert(targetList, task_data)
    end
  end
end
function ResultTask_SmallRP_Logic:GenerateSummaryInfo(summary)
  _tNewTaskSummary = nil
  if not (summary and next(summary) and _tOldTaskSummary) or not next(_tOldTaskSummary) then
    return
  end
  summary.reward_score = math.max(0, summary.score - _tOldTaskSummary.score)
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  local ResultTask_Util = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Util")
  local tConvertAwardList = ResultTask_Util:ConvertRewardList(summary, summary.score_item_id)
  local nOldScore = _tOldTaskSummary.score or 0
  local nOldLevel = _tOldTaskSummary.cur_level or 1
  local tLevelCfg = _tOldTaskSummary.level_cfg or {}
  local nOldLevelScore = tLevelCfg[nOldLevel - 1] or 0
  local nOldNextLevelScore = tLevelCfg[nOldLevel + 1] or 0
  local nCurScore = summary.score or 0
  local nCurLevel = summary.cur_level or 1
  local nCurLevelScore = tLevelCfg[nCurLevel] or 0
  local nCurNextLevelScore = tLevelCfg[nCurLevel + 1] or 0
  local nMaxLevel = summary.max_level or 1
  local nDelta = nCurScore - nOldScore
  if nOldLevel ~= nCurLevel then
    nDelta = nOldNextLevelScore - nOldScore + (nCurScore - nCurLevelScore)
  end
  _tNewTaskSummary = {
    taskType = ResultTask_Macro.ENUM_TaskType.SmallRP,
    scoreItemId = summary.score_item_id,
    max_level = nMaxLevel,
    pre_level = nOldLevel or 1,
    pre_score = nOldScore,
    pre_level_target_score = nOldNextLevelScore,
    cur_score = nCurScore,
    cur_level = nCurLevel,
    cur_level_desc = nCurLevel or "",
    cur_base = nOldLevelScore,
    cur_level_target_score = nCurNextLevelScore,
    cur_level_score_delta = nDelta,
    level_anim_begin_value = nOldScore,
    awardList = tConvertAwardList,
    showAwardList = 0 < #tConvertAwardList,
    bPlayProgressBarAnim = nCurLevel < nMaxLevel
  }
end
return ResultTask_SmallRP_Logic