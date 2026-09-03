local ResultTask_RP_Logic = {}
local summary_before_result, week_task_before_result, season_task_before_result, task_summary, finished_task_list, inProgress_task_list
local CleanData = function()
  summary_before_result = nil
  week_task_before_result = nil
  season_task_before_result = nil
  task_summary = nil
  finished_task_list = nil
  inProgress_task_list = nil
end
local GetWeekTaskPreValue = function(week_index, group_id, task_id)
  if not (week_task_before_result and week_task_before_result[week_index] and week_task_before_result[week_index][group_id]) or not week_task_before_result[week_index][group_id][task_id] then
    return 0
  end
  return math.floor(week_task_before_result[week_index][group_id][task_id].value)
end
local GetSeasonTaskPreValue = function()
  if not season_task_before_result then
    return 0
  end
  return season_task_before_result.value or 0
end
local ShouldFilterWeekTask = function(week_index, group_id)
  if not (week_task_before_result and week_task_before_result[week_index]) or not week_task_before_result[week_index][group_id] then
    return false
  end
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  return week_task_before_result[week_index][group_id].status == ResultTask_Macro.ENUM_TaskStatus.Taken
end
local ShouldFilterSeasonTask = function(index)
  if not (season_task_before_result and season_task_before_result.received) or not season_task_before_result.received[index] then
    return false
  end
  return season_task_before_result.received[index]
end
function ResultTask_RP_Logic:OnInit()
end
function ResultTask_RP_Logic:OnUnInit()
  CleanData()
end
function ResultTask_RP_Logic:GetFinishedTaskList()
  return finished_task_list
end
function ResultTask_RP_Logic:GetInProgressTaskList()
  return inProgress_task_list
end
function ResultTask_RP_Logic:GetSummaryInfo()
  return task_summary
end
function ResultTask_RP_Logic:on_task_status_notify(flag, summary, task_status)
  if flag == 0 then
    summary_before_result = summary.rp_summary
    week_task_before_result = task_status.rp_week_task
    season_task_before_result = task_status.rp_season_task
  elseif flag == 1 then
    self:GenerateTaskList(task_status)
    self:GenerateSummaryInfo(summary.rp_summary)
  end
end
function ResultTask_RP_Logic:GenerateTaskList(task_status)
  finished_task_list = nil
  inProgress_task_list = nil
  self:HandleWeekTaskData(task_status.rp_week_task)
  self:HandleActiveData(task_status.rp_season_task)
end
function ResultTask_RP_Logic:HandleWeekTaskData(rp_week_task)
  if not rp_week_task or not next(rp_week_task) then
    return
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local taskContentCfg = BasicDataServerTable:GetCacheData(data_config_marco.general_task_week_content_cfg)
  if not taskContentCfg then
    return
  end
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  local logic_new_day_task = require("client.slua.logic.task.logic_new_day_task")
  for week_index, group_tasks in pairs(rp_week_task) do
    if type(week_index) == "number" then
      for groupId, group in pairs(group_tasks) do
        if type(groupId) == "number" then
          local is_elite = taskContentCfg[group_tasks.cfg_id] and taskContentCfg[group_tasks.cfg_id][groupId] and taskContentCfg[group_tasks.cfg_id][groupId].is_elite
          if is_elite and (is_elite == 0 or is_elite == 1 and UnknowPassSystem.IsBuyElite) then
            if group.status == ResultTask_Macro.ENUM_TaskStatus.Taken then
              if not ShouldFilterWeekTask(week_index, groupId) then
                for taskId, task in pairs(group) do
                  if type(taskId) == "number" then
                    local task_data = {
                      taskType = ResultTask_Macro.ENUM_TaskType.RP,
                      desc = logic_new_day_task.GetDailyTaskDesc(taskId),
                      finish_value = task.finish_value,
                      cur_value = task.finish_value,
                      pre_value = GetWeekTaskPreValue(week_index, groupId, taskId),
                      reward_id = taskContentCfg[group_tasks.cfg_id][groupId].reward_id or 1,
                      status = group.status,
                      share_progress = task.share_progress,
                      is_branch = taskContentCfg[group_tasks.cfg_id][groupId].is_branch or 0
                    }
                    if finished_task_list == nil then
                      finished_task_list = {}
                    end
                    if task_data.is_branch ~= 1 then
                      table.insert(finished_task_list, task_data)
                    end
                    break
                  end
                end
              end
            elseif group.status == ResultTask_Macro.ENUM_TaskStatus.InProgress then
              for taskId, task in pairs(group) do
                if type(taskId) == "number" then
                  local task_data = {
                    taskType = ResultTask_Macro.ENUM_TaskType.RP,
                    desc = logic_new_day_task.GetDailyTaskDesc(taskId),
                    finish_value = task.finish_value,
                    cur_value = math.floor(task.value),
                    pre_value = GetWeekTaskPreValue(week_index, groupId, taskId),
                    reward_id = taskContentCfg[group_tasks.cfg_id][groupId].reward_id or 1,
                    status = group.status,
                    share_progress = task.share_progress,
                    is_branch = taskContentCfg[group_tasks.cfg_id][groupId].is_branch or 0
                  }
                  if inProgress_task_list == nil then
                    inProgress_task_list = {}
                  end
                  if task_data.is_branch ~= 1 then
                    table.insert(inProgress_task_list, task_data)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
function ResultTask_RP_Logic:HandleActiveData(rp_season_task)
end
function ResultTask_RP_Logic:GenerateSummaryInfo(rp_summary)
  task_summary = nil
  if not rp_summary or not next(rp_summary) then
    return
  end
  local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
  local ResultTask_Util = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Util")
  local convertAwardList = ResultTask_Util:ConvertRewardList(rp_summary, ResultTask_Macro.RP_SCORE_ITEM_RES_ID)
  task_summary = {
    taskType = ResultTask_Macro.ENUM_TaskType.RP,
    pre_score = summary_before_result and summary_before_result.upass_score or 0,
    pre_level = summary_before_result and summary_before_result.upass_level or 0,
    pre_level_target_score = summary_before_result and summary_before_result.next_level_score or 0,
    cur_score = rp_summary.upass_score,
    cur_level = rp_summary.upass_level,
    cur_level_desc = tostring(rp_summary.upass_level),
    cur_level_score_delta = rp_summary.upass_score,
    level_anim_begin_value = 0,
    cur_level_target_score = rp_summary.next_level_score,
    awardList = convertAwardList,
    showAwardList = 0 < #convertAwardList,
    bPlayProgressBarAnim = rp_summary.upass_level < UnknowPassSystem.MaxLevel
  }
end
function ResultTask_RP_Logic:GetRPLevelAwardList(RPLevel)
  local awardList = {}
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  local awardLevelList = UnknowPassAwardSystem.GetAwardLevelList(true)
  if not awardLevelList or not awardLevelList[RPLevel] then
    return awardList
  end
  local awardCfg = awardLevelList[RPLevel]
  for _, award in ipairs(awardCfg.OrdinaryAwardList) do
    table.insert(awardList, {
      res_id = award.resId,
      res_num = award.number
    })
  end
  if UnknowPassSystem.IsBuyElite then
    for _, award in ipairs(awardCfg.EliteAwardList) do
      table.insert(awardList, {
        res_id = award.resId,
        res_num = award.number
      })
    end
  end
  return awardList
end
return ResultTask_RP_Logic