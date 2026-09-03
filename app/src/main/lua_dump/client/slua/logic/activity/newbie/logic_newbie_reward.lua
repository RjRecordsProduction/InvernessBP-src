local logic_newbie_reward = {
  Reward_State = {
    Not = 0,
    CanGet = 1,
    HasGot = 2
  }
}
function logic_newbie_reward.LoadConfig(group_id)
  log(bWriteLog and "logic_newbie_reward.LoadConfig group_id is " .. tostring(group_id))
  local NewbieScoreConfig = CDataTable.GetTable("NewbieScoreConfig")
  logic_newbie_reward.NewbieScoreConfig = {}
  for _, data in pairs(NewbieScoreConfig) do
    if data.GroupId == group_id then
      local config = {}
      config.ScoreId = data.Score
      config.TotalScore = data.TotalScore
      config.Reward1 = data.Reward1
      config.Reward1Number = data.Reward1Number
      config.Reward1Time = data.Reward1Time
      config.Reward2 = data.Reward2
      config.Reward2Number = data.Reward2Number
      config.Reward2Time = data.Reward2Time
      config.Reward3 = data.Reward3
      config.Reward3Number = data.Reward3Number
      config.Reward3Time = data.Reward3Time
      config.Select_Res1 = data.Select_Res1
      config.Select_Res2 = data.Select_Res2
      config.Select_Res3 = data.Select_Res3
      config.Icon1 = data.Icon1
      config.Icon2 = data.Icon2
      config.Icon3 = data.Icon3
      config.BigIcon1 = data.BigIcon1
      config.BigIcon2 = data.BigIcon2
      config.BigIcon3 = data.BigIcon3
      table.insert(logic_newbie_reward.NewbieScoreConfig, config)
    end
  end
  local NewbieTaskConfig = CDataTable.GetTable("NewbieTaskConfig")
  logic_newbie_reward.NewbieTaskConfig = {}
  for _, data in pairs(NewbieTaskConfig) do
    if data.GroupId == group_id then
      if not logic_newbie_reward.NewbieTaskConfig[data.Day] then
        logic_newbie_reward.NewbieTaskConfig[data.Day] = {}
      end
      local config = {}
      config.TaskId = data.TaskId
      config.Day = data.Day
      config.Sort = data.Sort
      config.TaskType = data.TaskType
      config.TaskCondition = data.TaskCondition
      config.Reward1 = data.Reward1
      config.Reward1Number = data.Reward1Number
      config.Reward1Time = data.Reward1Time
      config.Reward2 = data.Reward2
      config.Reward2Number = data.Reward2Number
      config.Reward2Time = data.Reward2Time
      config.Reward3 = data.Reward3
      config.Reward3Number = data.Reward3Number
      config.Reward3Time = data.Reward3Time
      table.insert(logic_newbie_reward.NewbieTaskConfig[data.Day], config)
    end
  end
end
function logic_newbie_reward.GetNewbieTaskConfig()
  log_tree(bWriteLog and "logic_newbie_reward.GetNewbieTaskConfig NewbieTaskConfig is ", logic_newbie_reward.NewbieTaskConfig)
  return logic_newbie_reward.NewbieTaskConfig or {}
end
function logic_newbie_reward.GetNewbieScoreConfig()
  log_tree(bWriteLog and "logic_newbie_reward.GetNewbieScoreConfig NewbieScoreConfig is ", logic_newbie_reward.NewbieScoreConfig)
  return logic_newbie_reward.NewbieScoreConfig or {}
end
function logic_newbie_reward.GetOptionsRewardData()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local data = {}
  local point = logic_newbie_new_abtest:GetNewbieNewDataPointData()
  local curScore = logic_newbie_reward.GetCurScore()
  if logic_newbie_reward.NewbieScoreConfig and next(logic_newbie_reward.NewbieScoreConfig) then
    for _, v in pairs(logic_newbie_reward.NewbieScoreConfig) do
      if v.Reward2 ~= 0 and v.Reward3 ~= 0 and curScore >= v.TotalScore and not point[v.ScoreId] then
        table.insert(data, {
          PointsId = v.ScoreId,
          itemId = v.Reward1,
          itemNum = v.Reward1Number,
          itemTime = v.Reward1Time,
          icon = v.BigIcon1
        })
        table.insert(data, {
          PointsId = v.ScoreId,
          itemId = v.Reward2,
          itemNum = v.Reward2Number,
          itemTime = v.Reward2Time,
          icon = v.BigIcon2
        })
        table.insert(data, {
          PointsId = v.ScoreId,
          itemId = v.Reward3,
          itemNum = v.Reward3Number,
          itemTime = v.Reward3Time,
          icon = v.BigIcon3
        })
        break
      end
    end
  end
  return data
end
function logic_newbie_reward.IsOpen()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    log(bWriteLog and "logic_newbie_reward.IsOpen return not in ABTest new Group")
    return false
  end
  local endTime = logic_newbie_reward.GetNewbieEndTime()
  local TimeUtil = require("client.common.time_util")
  if endTime - TimeUtil.GetServerTimeInSec() < 0 then
    log(bWriteLog and "logic_newbie_reward.IsOpen return not in time end")
    return false
  end
  return true
end
function logic_newbie_reward.UpdateRedDotCount(superData)
  if not superData then
    return
  end
  superData.newCount = logic_newbie_reward.CountHaveLevelOrTaskReward(true)
  log(bWriteLog and "==============> newbie activity logic_newbie_reward UpdateRedDotCount: " .. tostring(superData.newCount))
end
function logic_newbie_reward.HasRedDot()
  log(bWriteLog and "logic_newbie_reward.HasRedDot")
  return logic_newbie_reward.CountHaveLevelOrTaskReward(false)
end
function logic_newbie_reward.GetActivitySubData()
  if not logic_newbie_reward.IsOpen() then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_Award,
    sName = LocUtil.GetLocalizeResStr(75497),
    bRedDot = logic_newbie_reward.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function logic_newbie_reward.GetCurScore()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  return logic_newbie_new_abtest:GetNewbieNewDataPoints()
end
function logic_newbie_reward.IsHaveLevelOrTaskRewardOptions()
  local nRewardCount = logic_newbie_reward.CountHaveLevelOrTaskReward(true)
  local nOptionCount = 0
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local point = logic_newbie_new_abtest:GetNewbieNewDataPointData()
  local curScore = logic_newbie_reward.GetCurScore()
  if logic_newbie_reward.NewbieScoreConfig and next(logic_newbie_reward.NewbieScoreConfig) then
    for _, v in pairs(logic_newbie_reward.NewbieScoreConfig) do
      if v.Reward2 ~= 0 and v.Reward3 ~= 0 and curScore >= v.TotalScore and not point[v.ScoreId] then
        nOptionCount = nOptionCount + 1
      end
    end
  end
  if nRewardCount == nOptionCount and nRewardCount ~= 0 then
    return true, true
  else
    return false, 0 < nRewardCount
  end
end
function logic_newbie_reward.CountHaveLevelOrTaskReward(bCountNumber)
  local count = 0
  if not (logic_newbie_reward.NewbieTaskConfig and next(logic_newbie_reward.NewbieTaskConfig) and logic_newbie_reward.NewbieScoreConfig) or not next(logic_newbie_reward.NewbieScoreConfig) then
    if not bCountNumber then
      return false
    end
    return count
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local task = logic_newbie_new_abtest:GetNewbieNewDataTaskData()
  local point = logic_newbie_new_abtest:GetNewbieNewDataPointData()
  for _, v in pairs(logic_newbie_reward.NewbieTaskConfig) do
    for _, vv in pairs(v) do
      local taskAwardInfo = task[vv.TaskId]
      if taskAwardInfo ~= nil and taskAwardInfo.process >= vv.TaskCondition and taskAwardInfo.status == 1 then
        count = count + 1
        if not bCountNumber then
          return true
        end
      end
    end
  end
  local curScore = logic_newbie_reward.GetCurScore()
  for _, v in pairs(logic_newbie_reward.NewbieScoreConfig) do
    if curScore >= v.TotalScore and not point[v.ScoreId] then
      count = count + 1
      if not bCountNumber then
        return true
      end
    end
  end
  if not bCountNumber then
    return false
  end
  return count
end
function logic_newbie_reward.GetTaskProcessByTaskId(taskId)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local task = logic_newbie_new_abtest:GetNewbieNewDataTaskData()
  return task[taskId] and task[taskId].process or 0
end
function logic_newbie_reward.GetTaskStatusByTaskId(taskId)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local task = logic_newbie_new_abtest:GetNewbieNewDataTaskData()
  return task[taskId] and task[taskId].status or 0
end
function logic_newbie_reward.CheckDailyScoreLimitReached()
  if not logic_newbie_reward.NewbieTaskConfig or not next(logic_newbie_reward.NewbieTaskConfig) then
    return false
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local curDay = logic_newbie_new_abtest:GetNewbieNewDataLoginDay()
  local taskConfig = logic_newbie_reward.NewbieTaskConfig[curDay] or {}
  local task = logic_newbie_new_abtest:GetNewbieNewDataTaskData()
  if not taskConfig or not next(taskConfig) then
    return false
  end
  for _, v in pairs(taskConfig) do
    local taskAwardInfo = task[v.TaskId]
    if taskAwardInfo == nil then
      return false
    end
    if taskAwardInfo ~= nil and taskAwardInfo.status ~= 2 then
      return false
    end
  end
  return true
end
function logic_newbie_reward.GetNewbieEndTime()
  local nRegisterTime = DataMgr.registertime or 0
  local TimeUtil = require("client.common.time_util")
  if nRegisterTime == 0 or nRegisterTime > TimeUtil.GetServerTimeInSec() then
    return 0
  end
  log_format(bWriteLog and "logic_newbie_reward.GetNewbieRemainingTime nRegisterTime = %s ", nRegisterTime)
  local totalTime = 1209599
  local tDateTable = TimeUtil.GetDateByUnixTime(nRegisterTime)
  if next(tDateTable) then
    nRegisterTime = nRegisterTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  return totalTime + nRegisterTime
end
function logic_newbie_reward.GetDayTaskTitle(taskType, taskCondition)
  local des = ""
  local taskItem = CDataTable.GetTableData("NewbieTaskTypeConfig", taskType)
  if not taskItem then
    log(bWriteLog and " logic_newbie_reward.GetDayTaskTitle taskItem is nil, taskType = " .. tostring(taskType))
    return des
  end
  des = LocUtil.LocalizeResFormatByStr(taskItem.taskDesc, taskCondition)
  return des
end
function logic_newbie_reward.GetMiddleItemAllData()
  local allData = {}
  if not logic_newbie_reward.NewbieScoreConfig or not next(logic_newbie_reward.NewbieScoreConfig) then
    return allData
  end
  for k, v in ipairs(logic_newbie_reward.NewbieScoreConfig) do
    if v.Select_Res1 ~= 0 and v.Select_Res2 ~= 0 and v.Select_Res3 ~= 0 then
      table.insert(allData, {
        level = k,
        itemId = v.Select_Res1,
        time = v.Reward1Time
      })
      table.insert(allData, {
        level = k,
        itemId = v.Select_Res2,
        time = v.Reward2Time
      })
      table.insert(allData, {
        level = k,
        itemId = v.Select_Res3,
        time = v.Reward3Time
      })
    end
  end
  return allData
end
function logic_newbie_reward.GetMultiSelectData()
  local allData = {}
  if not logic_newbie_reward.NewbieScoreConfig or not next(logic_newbie_reward.NewbieScoreConfig) then
    return allData
  end
  for k, v in ipairs(logic_newbie_reward.NewbieScoreConfig) do
    if v.Select_Res1 ~= 0 and v.Select_Res2 ~= 0 and v.Select_Res3 ~= 0 then
      local data = {}
      table.insert(data, {
        level = k,
        itemId = v.Select_Res1,
        icon = v.Icon1,
        time = v.Reward1Time
      })
      table.insert(data, {
        level = k,
        itemId = v.Select_Res2,
        icon = v.Icon2,
        time = v.Reward2Time
      })
      table.insert(data, {
        level = k,
        itemId = v.Select_Res3,
        icon = v.Icon3,
        time = v.Reward3Time
      })
      table.insert(allData, data)
    end
  end
  return allData
end
return logic_newbie_reward