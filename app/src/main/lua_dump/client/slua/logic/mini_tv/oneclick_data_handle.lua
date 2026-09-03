local OneClickMacro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
local OneClickDataHandle = {}
function OneClickDataHandle.HandleDownLoad(download_award)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if download_award == nil or next(download_award) == nil then
    return
  end
  local rewardList = {}
  for k, v in pairs(download_award) do
    PufferDownloader.DownloadRewardCfg[v[1]].is_got = true
    for kk, vv in pairs(v[2]) do
      vv.res_id = vv.resid
      table.insert(rewardList, vv)
    end
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleDownLoadReward download ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_DOWNLOAD)
end
function OneClickDataHandle.HandleBackUser(return_award)
  log_tree("OneClickDataHandle.HandleBackUserReward", return_award)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if return_award == nil or next(return_award) == nil then
    return
  end
  local rewardList = {}
  for k, v in pairs(return_award) do
    if type(v) == "table" then
      table.insert(rewardList, {
        res_id = v.res_id,
        count = v.count,
        valid_hours = v.valid_hours
      })
    else
      table.insert(rewardList, {res_id = k, count = v})
    end
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleBackUserReward back_user ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_BACKUSER)
end
function OneClickDataHandle.HandlePlot(plot_award)
  log_tree("OneClickDataHandle.HandlePlotReward", plot_award)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if type(plot_award) ~= "table" or next(plot_award) == nil then
    return
  end
  local rewardList = {}
  for _, v in pairs(plot_award) do
    table.insert(rewardList, {
      res_id = v.res_id,
      count = v.count
    })
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandlePlotReward back_user ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_PLOT)
end
function OneClickDataHandle.HandleActivity(activity)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if type(activity) ~= "table" or next(activity) == nil then
    return
  end
  local rewardList = {}
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  for k, v in pairs(activity) do
    for kk, vv in pairs(v[3]) do
      local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
      vv.expire_ts = ActivityUtil.GetReviseExpireTime(vv.extra_str, vv.res_id)
      table.insert(rewardList, vv)
    end
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleActivityReward activity ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_ACTIVITY)
end
function OneClickDataHandle.HandleRPLevel(rp_award)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if type(rp_award) ~= "table" or next(rp_award) == nil then
    return
  end
  local rewardList = {}
  for k, v in pairs(rp_award) do
    table.insert(rewardList, {
      res_id = v.item_id,
      count = v.item_num,
      valid_hours = v.item_expire_time
    })
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleRPLevelReward rplevel ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_RP_LEVEL_REWARD)
end
function OneClickDataHandle.HandleSeason(season_award)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if season_award == nil or next(season_award) == nil then
    return
  end
  local rewardList = {}
  for key, value in pairs(season_award) do
    value.res_id = value.res_id or value.resid
    if not value.valid_hours or value.valid_hours <= 0 then
      local SeasonCardUtil = require("client.logic.season.logic_season_card_util")
      value.valid_hours = SeasonCardUtil.GetItemValidHours(value.res_id) or 0
    end
    table.insert(rewardList, value)
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleSeasonReward season ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_SEASON)
end
function OneClickDataHandle.HandleAchieve(achieve_award)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if achieve_award == nil or next(achieve_award) == nil then
    return
  end
  local achievement_red = require("client.logic.achievement.achievement_red")
  local rewardList = {}
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  AchieveHandler.send_get_achieve_rewards_list_req()
  for key, values in pairs(achieve_award) do
    local cfg = CDataTable.GetTableData("AchievementCfg", values.id)
    achievement_red.ClearRed(cfg.GroupID, achievement_red.Receive, values.id)
    for key, value in pairs(values.itemlist) do
      table.insert(rewardList, value)
    end
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleAchieveReward achievement ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_ACHIEVE)
  local RankHandler = require("client.network.Protocol.RankHandler")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rankID = RankDataMgr.GetAchieveRequireID()
  RankHandler.send_get_topn_rank(0, rankID)
  RankHandler.send_get_one_user_rank("AchievementPK", 0, 0, rankID)
  AchieveHandler.send_get_achievement_summary_req(DataMgr.roleData.uid)
  AchieveHandler.send_get_achieve_hit_list_req()
end
function OneClickDataHandle.HandleAchieveRecord(achieve_record)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if achieve_record == nil or next(achieve_record) == nil then
    return
  end
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  local rewardList = {}
  for key, values in pairs(achieve_record) do
    for _, value in pairs(values.itemlist) do
      table.insert(rewardList, value)
    end
  end
  AchieveHandler.send_get_achieve_record_rewards_list_req()
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleAchieveRecordReward achievement_record ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_ACHIEVE_RECORD)
end
function OneClickDataHandle.HandleLevelTask(level_task)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if level_task == nil or next(level_task) == nil then
    return
  end
  local rewardList = {}
  for key, results in pairs(level_task) do
    for _, result in pairs(results[3]) do
      table.insert(rewardList, result)
    end
    local LevelTaskSystem = require("client.slua.logic.task.logic_level_task")
    if LevelTaskSystem then
      local taskInfo = DataMgr.levelTask.list[results[1]]
      if taskInfo then
        taskInfo[LevelTaskSystem.LevelTaskId[results[2]]] = 2
      end
    end
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleLevelTaskReward leveltask ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_LEVEL_TASK)
end
function OneClickDataHandle.HandleRPTask(taskList)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if taskList == nil or next(taskList) == nil then
    return
  end
  log_tree(" OneClickDataHandle.HandleTaskReward taskList", taskList)
  local rewardList = {}
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  for _, reward_id in ipairs(taskList) do
    local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(reward_id)
    for _, reward in ipairs(rewards) do
      table.insert(rewardList, {
        res_id = reward.res_id,
        count = reward.res_num,
        valid_hours = reward.res_time_limit
      })
    end
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleTaskReward task ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_RP_TASK)
end
function OneClickDataHandle.HandleUGCTask(taskList)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if taskList == nil or next(taskList) == nil then
    return
  end
  log_tree(" OneClickDataHandle.HandleUGCTaskReward taskList", taskList)
  local rewardList = {}
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  for _, reward_id in ipairs(taskList) do
    local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(reward_id)
    for _, reward in ipairs(rewards) do
      table.insert(rewardList, {
        res_id = reward.res_id,
        count = reward.res_num,
        valid_hours = reward.res_time_limit
      })
    end
  end
  print(bWriteLog and "LogicSmartAssistant OneClickDataHandle.HandleUGCTaskReward task ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_UGCTASK)
end
function OneClickDataHandle.HandleUGCCenterTask(taskList)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  if taskList == nil or next(taskList) == nil then
    return
  end
  log_tree(" OneClickDataHandle.HandleUGCCenterTaskReward taskList", taskList)
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  local rewardList = {}
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  for _, reward_id in ipairs(taskList) do
    local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(reward_id)
    for _, reward in ipairs(rewards) do
      table.insert(rewardList, {
        res_id = reward.res_id,
        count = reward.res_num,
        valid_hours = reward.res_time_limit
      })
    end
  end
  print(bWriteLog and "LogicSmartAssistant OneClickDataHandle.HandleUGCTaskReward task ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_UGC_CENTER_TASK)
end
function OneClickDataHandle.HandleWeekSignup(weekResult)
  local OneClickRewardSystem = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  log_tree("zxq weekResult", weekResult)
  if weekResult == nil or next(weekResult) == nil then
    return
  end
  if weekResult.res ~= 0 then
    log(bWriteLog and "zxq weekResult res" .. tostring(weekResult.res))
    return
  end
  local rewardList = {}
  for key, values in pairs(weekResult.itemlist) do
    values.res_id = values.resid
    table.insert(rewardList, values)
  end
  print(bWriteLog and "x LogicSmartAssistant OneClickDataHandle.HandleWeekReward activity_weeksign ids:", require("common.Linq").FromTable(rewardList):Select(function(k, v, i)
    return v.res_id
  end):Distinct():SortConcat(","))
  OneClickRewardSystem.AddListToAllRewardData(rewardList, OneClickMacro.MapNumToSystem.MODE_AWARD_TYPE_WEEK_SIGNUP)
  log_tree("zxq WeekReward ", rewardList)
end
function OneClickDataHandle.RefreshRedPoint(result)
  local OneClickMacro = require("client.slua.logic.mini_tv.logic_oneclick_macro")
  local MapNumToSystem = OneClickMacro.MapNumToSystem
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.send_general_task_sync_all_req()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_TASK, false)
  local LevelTaskRedPointData = require("client.slua.logic.task.level_task_reddot_data")
  LevelTaskRedPointData.UpdateRedDot()
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.reward, 0)
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  ActivityRedDot.SetForceAllUpdateAllDone(false)
  ActivityRedDot.BuildAllSystemAllRedDotOnce()
  local UGCCenterRedDotData = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  UGCCenterRedDotData.UpdateRedDotBySA(result[MapNumToSystem.MODE_AWARD_TYPE_UGC_CENTER_TASK])
end
return OneClickDataHandle