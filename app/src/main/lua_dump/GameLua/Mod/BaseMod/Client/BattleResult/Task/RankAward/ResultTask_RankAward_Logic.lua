local ResultTask_RankAward_Logic = {}
local MaxRank = 800
local summary_before_result, task_before_result, task_summary, finished_task_list, inProgress_task_list, rank_task_reward_list
local CleanData = function()
  summary_before_result = nil
  task_before_result = nil
  task_summary = nil
  finished_task_list = nil
  inProgress_task_list = nil
  rank_task_reward_list = nil
end
local GetTaskPreValue = function(task_id)
  if not (task_before_result and task_before_result.task_list) or not task_before_result.task_list[task_id] then
    return 0
  end
  return math.floor(task_before_result.task_list[task_id].condition2)
end
local ShouldFilterTask = function(task_id)
  if not (task_before_result and task_before_result.task_list) or not task_before_result.task_list[task_id] then
    return false
  end
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  return task_before_result.task_list[task_id].prize_status == ResultTask_Macro.ENUM_TaskStatus.Taken
end
function ResultTask_RankAward_Logic:OnInit()
end
function ResultTask_RankAward_Logic:OnUnInit()
  CleanData()
end
function ResultTask_RankAward_Logic:GetFinishedTaskList()
  return finished_task_list
end
function ResultTask_RankAward_Logic:GetInProgressTaskList()
  return inProgress_task_list
end
function ResultTask_RankAward_Logic:GetSummaryInfo()
  return task_summary
end
function ResultTask_RankAward_Logic:on_task_status_notify(flag, summary, task_status)
  if flag == 0 then
    summary_before_result = summary.segment_summary
    task_before_result = task_status.rank_task
  elseif flag == 1 then
    rank_task_reward_list = task_status.rank_task_reward_list
    self:GenerateTaskList(task_status.rank_task)
    self:GenerateSummaryInfo(summary.segment_summary)
  end
end
function ResultTask_RankAward_Logic:GenerateTaskList(rank_task)
  finished_task_list = nil
  inProgress_task_list = nil
  if not (rank_task and rank_task.task_list) or not next(rank_task.task_list) then
    return
  end
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  for taskId, task in pairs(rank_task.task_list) do
    if type(taskId) == "number" and logic_season_award:CheckIsReachCondition1(taskId) then
      local seasonInRewardCfg = CDataTable.GetTableData("SeasonInReward", taskId)
      if not seasonInRewardCfg then
        log(bWriteLog and "ResultTask_RankAward_Logic:GenerateTaskList taskId:" .. tostring(taskId))
      end
      local task_data = {
        taskType = ResultTask_Macro.ENUM_TaskType.RankAward,
        desc = seasonInRewardCfg and seasonInRewardCfg.Condition2_Desc or "",
        finish_value = seasonInRewardCfg and seasonInRewardCfg.Condition2_Param2 or 0,
        cur_value = math.floor(task.condition2),
        pre_value = GetTaskPreValue(taskId),
        reward_info = self:GetTaskAwardInfo(taskId),
        status = task.prize_status
      }
      if task.prize_status == ResultTask_Macro.ENUM_TaskStatus.Taken then
        if not ShouldFilterTask(taskId) then
          if finished_task_list == nil then
            finished_task_list = {}
          end
          table.insert(finished_task_list, task_data)
        end
      else
        if inProgress_task_list == nil then
          inProgress_task_list = {}
        end
        table.insert(inProgress_task_list, task_data)
      end
    end
  end
end
function ResultTask_RankAward_Logic:GetTaskAwardInfo(taskId)
  if not rank_task_reward_list or not rank_task_reward_list[taskId] then
    return nil
  end
  return rank_task_reward_list[taskId][1]
end
function ResultTask_RankAward_Logic:GenerateSummaryInfo(segment_summary)
  task_summary = nil
  if not segment_summary or not next(segment_summary) then
    log(bWriteLog and "ResultTask_RankAward_Logic:GenerateSummaryInfo no segment_summary")
    return
  end
  local ratingInfo = BP_STRUCT_BattleResultData.BP_STRUCT_BTRating
  if not ratingInfo then
    log(bWriteLog and "ResultTask_RankAward_Logic:GenerateSummaryInfo no ratingInfo")
    return
  end
  local oldSegmentConfig = FuncUtil.GetRankTableData(ratingInfo.old_segment)
  if not oldSegmentConfig then
    log(bWriteLog and "ResultTask_RankAward_Logic:GenerateSummaryInfo no oldSegmentConfig:" .. tostring(ratingInfo.old_segment))
    return
  end
  local newSegmentConfig = FuncUtil.GetRankTableData(ratingInfo.new_segment)
  if not newSegmentConfig then
    log(bWriteLog and "ResultTask_RankAward_Logic:GenerateSummaryInfo no newSegmentConfig:" .. tostring(ratingInfo.new_segment))
    return
  end
  local old_rank_rating = ratingInfo.rank_rating - ratingInfo.change_rank_rating
  local ResultTask_Macro = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Macro")
  local convertAwardList = self:ConvertRewardList(segment_summary.reward_list)
  task_summary = {
    taskType = ResultTask_Macro.ENUM_TaskType.RankAward,
    pre_score = old_rank_rating,
    pre_base = oldSegmentConfig.MinIntegral,
    pre_level = ratingInfo.old_segment,
    pre_level_target_score = oldSegmentConfig.NextIntegralScore,
    cur_score = ratingInfo.rank_rating,
    cur_base = newSegmentConfig.MinIntegral,
    cur_level = ratingInfo.new_segment,
    cur_level_desc = newSegmentConfig.Name,
    cur_level_score_delta = ratingInfo.rank_rating - newSegmentConfig.MinIntegral,
    level_anim_begin_value = newSegmentConfig.MinIntegral,
    cur_level_target_score = newSegmentConfig.NextIntegralScore,
    awardList = convertAwardList,
    showAwardList = 0 < #convertAwardList,
    bPlayProgressBarAnim = ratingInfo.new_segment < MaxRank and ratingInfo.change_rank_rating > 0
  }
end
function ResultTask_RankAward_Logic:ConvertRewardList(reward_list)
  local ResultTask_Util = require("GameLua.Mod.BaseMod.Client.BattleResult.Task.ResultTask_Util")
  local award_map = {}
  for _, reward in pairs(reward_list) do
    ResultTask_Util:AddOneRewardData(award_map, {
      res_id = reward.resid,
      res_num = reward.count,
      valid_hours = reward.valid_hours
    })
  end
  local convertAwardList = {}
  for _, award in pairs(award_map) do
    table.insert(convertAwardList, award)
  end
  return convertAwardList
end
function ResultTask_RankAward_Logic:IsMaxRank()
  local ratingInfo = BP_STRUCT_BattleResultData.BP_STRUCT_BTRating
  if not ratingInfo then
    log(bWriteLog and "ResultTask_RankAward_Logic:IsMaxRank no ratingInfo")
    return false
  end
  return ratingInfo.new_segment >= MaxRank
end
return ResultTask_RankAward_Logic