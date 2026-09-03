local NewbieTaskSystem = {
  newbieTaskInfo = {},
  taskIDToTaskInfoMap = {},
  taskIDToTaskDayMap = {},
  unfinishedDayArray = {},
  awaitGetAwardDayArray = {},
  totalDay = 0,
  beginTime = 0,
  endTime = 0,
  curDay = 0,
  bannerUrl = "",
  lastAwardLockUrl = "",
  lastAwardUnlockUrl = "",
  err_newbie_task_not_exit = 880201,
  err_newbie_task_day_err = 880202,
  err_newbie_task_already_got = 880203,
  err_newbie_task_task_not_finish = 880204
}
function NewbieTaskSystem.ParseData(svrData)
  log_tree("NewbieTaskSystem.ParseData(svrData)", svrData)
  NewbieTaskSystem.curDay = svrData.day
  if NewbieTaskSystem.curDay <= 0 then
    return
  else
    assert(svrData.data, "[MHT]NewbieTaskSystem.ParseData(svrData) svrData.data is nil!")
    NewbieTaskSystem.totalDay = #svrData.data
    if NewbieTaskSystem.curDay > NewbieTaskSystem.totalDay then
      NewbieTaskSystem.curDay = NewbieTaskSystem.totalDay
    end
    NewbieTaskSystem.newbieTaskInfo = {}
    NewbieTaskSystem.unfinishedDayArray = {}
    NewbieTaskSystem.awaitGetAwardDayArray = {}
    NewbieTaskSystem.beginTime = svrData.begin_ts
    NewbieTaskSystem.endTime = svrData.end_ts
    NewbieTaskSystem.bannerUrl = svrData.banner_url
    NewbieTaskSystem.lastAwardLockUrl = svrData.last_award_lock_url
    NewbieTaskSystem.lastAwardUnlockUrl = svrData.last_award_unlock_url
    for day, dailyInfo in pairs(svrData.data) do
      local parsedTaskInfo = {
        taskFinishedNum = 0,
        taskTotalNum = #dailyInfo.task,
        isGotAwards = dailyInfo.is_got,
        tasks = {},
        awards = {},
              }
      for index, singleTask in pairs(dailyInfo.task) do
        local parsedSingleTask = {
          taskID = 0,
          taskType = 0,
          taskTarget = 0,
          taskProgress = 0,
          isFinished = true,
          day = day,
          status = 0,
          taskIndex = index
        }
        parsedSingleTask.taskID = singleTask.taskid
        parsedSingleTask.taskType = singleTask.task_type
        parsedSingleTask.taskTarget = singleTask.target
        parsedSingleTask.taskProgress = singleTask.value
        parsedSingleTask.isFinished = singleTask.is_finish or false
        if singleTask.is_finish then
          if singleTask.is_got then
            parsedSingleTask.status = 2
          else
            parsedSingleTask.status = 1
          end
        else
          parsedSingleTask.status = 0
        end
        parsedSingleTask.is_got = singleTask.is_got
        if parsedSingleTask.isFinished then
          parsedTaskInfo.taskFinishedNum = parsedTaskInfo.taskFinishedNum + 1
        end
        if dailyInfo.subtask_award then
          parsedSingleTask.awards = dailyInfo.subtask_award[index] or {}
        else
          parsedSingleTask.awards = {
            {
              itemid = 1402119,
              cnt = 1,
              valid_hours = 168
            }
          }
        end
        table.insert(parsedTaskInfo.tasks, parsedSingleTask)
        NewbieTaskSystem.taskIDToTaskInfoMap[parsedSingleTask.taskID] = parsedSingleTask
        NewbieTaskSystem.taskIDToTaskDayMap[parsedSingleTask.taskID] = day
      end
      for _, singleAward in pairs(dailyInfo.award) do
        local parsedSingleAward = {
          itemID = 0,
          count = 0,
          validHours = 0
        }
        parsedSingleAward.itemID = singleAward.itemid
        parsedSingleAward.count = singleAward.cnt
        parsedSingleAward.validHours = singleAward.valid_hours
        table.insert(parsedTaskInfo.awards, parsedSingleAward)
      end
      if parsedTaskInfo.taskFinishedNum < parsedTaskInfo.taskTotalNum and day <= NewbieTaskSystem.curDay then
        table.insert(NewbieTaskSystem.unfinishedDayArray, day)
      elseif parsedTaskInfo.taskFinishedNum >= parsedTaskInfo.taskTotalNum and not parsedTaskInfo.isGotAwards and day <= NewbieTaskSystem.curDay then
        table.insert(NewbieTaskSystem.awaitGetAwardDayArray, day)
      end
      NewbieTaskSystem.newbieTaskInfo[day] = parsedTaskInfo
    end
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_LOBBY_ENTRANCE_UPDATE)
end
function NewbieTaskSystem.GetNewbieTaskInfo()
  assert(NewbieTaskSystem.newbieTaskInfo, "[MHT]NewbieTaskSystem.GetNewbieTaskInfo(): No Newbie Task Info!!!")
  return NewbieTaskSystem.newbieTaskInfo
end
function NewbieTaskSystem.GetNewbieDailyTaskInfoByDay(day)
  assert(NewbieTaskSystem.newbieTaskInfo, "[MHT]NewbieTaskSystem.GetNewbieTaskInfo(): No Newbie Task Info!!!")
  return NewbieTaskSystem.newbieTaskInfo[day]
end
function NewbieTaskSystem.GetCurDay()
  return NewbieTaskSystem.curDay
end
function NewbieTaskSystem.IsNewbie()
  if NewbieTaskSystem.curDay > 0 then
    return true
  end
  return false
end
function NewbieTaskSystem.GetBeginTime()
  return NewbieTaskSystem.beginTime
end
function NewbieTaskSystem.GetEndTime()
  return NewbieTaskSystem.endTime
end
function NewbieTaskSystem.GetTotalDay()
  return NewbieTaskSystem.totalDay
end
function NewbieTaskSystem.GetUnfinishedDayArray()
  return NewbieTaskSystem.unfinishedDayArray
end
function NewbieTaskSystem.GetAwaitGetAwardDayArray()
  return NewbieTaskSystem.awaitGetAwardDayArray
end
function NewbieTaskSystem.GetAwardByDay(day, task_index, afterGetAwardCallback)
  local NewbieTaskHandler = require("client.network.Protocol.NewbieTaskHandler")
  NewbieTaskHandler.send_newbie_reward_get_req(day, task_index)
  NewbieTaskSystem.end
function NewbieTaskSystem.ResetAfterGetAwardCallback()
  log(bWriteLog and "NewbieTaskSystem.ResetAfterGetAwardCallback")
  NewbieTaskSystem.afterGetAwardCallback = nil
end
function NewbieTaskSystem.GetFirstShowDay()
  if #NewbieTaskSystem.awaitGetAwardDayArray > 0 then
    log(bWriteLog and "\228\188\152\229\133\136\230\152\190\231\164\186\229\143\175\233\162\134\229\165\150\231\154\132\229\164\169\230\149\176")
    local lastAwaitGetAwardDay = NewbieTaskSystem.awaitGetAwardDayArray[#NewbieTaskSystem.awaitGetAwardDayArray]
    return lastAwaitGetAwardDay
  elseif 0 < #NewbieTaskSystem.unfinishedDayArray then
    log(bWriteLog and "\229\133\182\230\172\161\230\152\190\231\164\186\229\190\133\229\174\140\230\136\144\228\187\187\229\138\161\231\154\132\229\164\169\230\149\176\229\143\138\229\133\182\228\187\187\229\138\161\230\143\143\232\191\176")
    local lastUnfinishedDay = NewbieTaskSystem.unfinishedDayArray[#NewbieTaskSystem.unfinishedDayArray]
    return lastUnfinishedDay
  else
    log(bWriteLog and "\230\137\128\230\156\137\229\183\178\232\167\163\233\148\129\231\154\132\228\187\187\229\138\161\229\183\178\229\174\140\230\136\144\228\184\148\230\137\128\230\156\137\229\165\150\229\138\177\229\183\178\233\162\134\229\143\150\230\151\182 \230\152\190\231\164\186\229\189\147\229\137\141\229\164\169\230\149\176")
    return NewbieTaskSystem.curDay
  end
end
function NewbieTaskSystem.OnGottenAward(day, errCode, task_index)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "OnGottenAward errCode: " .. tostring(errCode))
  if errCode and errCode ~= 0 then
    if errCode == NewbieTaskSystem.err_newbie_task_not_exit then
      log_error("NewbieTaskSystem.OnGottenAward. Newbie task is not open! errCode: " .. errCode)
    end
    if errCode == NewbieTaskSystem.err_newbie_task_day_err then
      log_error("NewbieTaskSystem.OnGottenAward. Day of getting award is wrong! Day: " .. day .. " errCode: " .. errCode)
    end
    if errCode == NewbieTaskSystem.err_newbie_task_already_got then
      log_error("NewbieTaskSystem.OnGottenAward. Award of day" .. day .. " has gotten! errCode: " .. errCode)
    end
    if errCode == NewbieTaskSystem.err_newbie_task_task_not_finish then
      log_error("NewbieTaskSystem.OnGottenAward. Tasks of day" .. day .. " are not finished! errCode: " .. errCode)
    else
      ShowNotice(errCode)
    end
  else
    local items = {}
    if task_index == nil then
      local taskInfo = NewbieTaskSystem.newbieTaskInfo[day]
      assert(taskInfo, "No Such task of day" .. tostring(day))
      taskInfo.isGotAwards = true
      for idx, awaitGetAwardDay in pairs(NewbieTaskSystem.awaitGetAwardDayArray) do
        if day == awaitGetAwardDay then
          table.remove(NewbieTaskSystem.awaitGetAwardDayArray, idx)
          break
        end
      end
      local dailyTaskInfo = NewbieTaskSystem.GetNewbieDailyTaskInfoByDay(day)
      assert(dailyTaskInfo and dailyTaskInfo.awards, "[MHT]NewbieTaskSystem.OnGetAward(day, errCode) taskInfo is nil or awards is nil!")
      for _, award in pairs(dailyTaskInfo.awards) do
        local item = {}
        item.res_id = award.itemID
        item.count = award.count
        item.valid_hours = award.validHours
        table.insert(items, item)
      end
    else
      local taskInfo = NewbieTaskSystem.newbieTaskInfo[day]
      if taskInfo then
        log_tree("taskInfo", taskInfo)
        local TableUtil = require("common.table_util")
        local _, task = TableUtil.FindTable(taskInfo.tasks, function(_, _task)
          return _task.taskIndex == task_index
        end)
        if task then
          task.is_got = true
          task.status = 2
          for i, v in pairs(task.awards) do
            local item = {
              res_id = v.itemid,
              count = v.cnt,
              valid_hours = v.valid_hours
            }
            table.insert(items, item)
          end
        end
      end
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local tExtendData = {
      fCloseCallback = function()
        if NewbieTaskSystem.afterGetAwardCallback then
          NewbieTaskSystem.afterGetAwardCallback()
          NewbieTaskSystem.afterGetAwardCallback = nil
        end
      end
    }
    Logic_CommonItemGet.ShowPanel_DefaultStyle(items, false, true, tExtendData)
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_GET_AWARD, day)
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_LOBBY_ENTRANCE_UPDATE)
    local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
    TaskMgrSystem.RefreshLobbyTaskRedDot()
  end
end
function NewbieTaskSystem.HasDayDot(day)
  local dailyTaskInfo = NewbieTaskSystem.GetNewbieDailyTaskInfoByDay(day)
  if dailyTaskInfo then
    if dailyTaskInfo.taskFinishedNum >= dailyTaskInfo.taskTotalNum and not dailyTaskInfo.isGotAwards then
      return true
    end
    for i, v in pairs(dailyTaskInfo.tasks) do
      if v.status == 1 then
        return true
      end
    end
  end
  return false
end
function NewbieTaskSystem.GetFirstEnterDay()
  log(bWriteLog and "NewbieTaskSystem.GetFirstEnterPage")
  local newbieTaskInfo = NewbieTaskSystem.GetNewbieTaskInfo()
  for day, dailyTaskInfo in pairs(newbieTaskInfo) do
    if dailyTaskInfo.taskFinishedNum >= dailyTaskInfo.taskTotalNum and not dailyTaskInfo.isGotAwards then
      return day
    end
    for i, v in pairs(dailyTaskInfo.tasks) do
      if v.status == 1 then
        return day
      end
    end
  end
  return NewbieTaskSystem.curDay
end
function NewbieTaskSystem.UpdateRedDotCount(superData)
  if not superData then
    return
  end
  local newbieTaskInfo = NewbieTaskSystem.GetNewbieTaskInfo()
  for day, dailyTaskInfo in pairs(newbieTaskInfo) do
    local daySuperData = superData.pages[day]
    if daySuperData then
      local count = 0
      if dailyTaskInfo.taskFinishedNum >= dailyTaskInfo.taskTotalNum and not dailyTaskInfo.isGotAwards then
        count = count + 1
      end
      for i, v in pairs(dailyTaskInfo.tasks) do
        if v.status == 1 then
          count = count + 1
        end
      end
      daySuperData.newCount = count
    end
  end
  log(bWriteLog and "==============> newbie activity NewbieTaskSystem UpdateRedDotCount: " .. superData.newCount)
end
function NewbieTaskSystem.HasRedDot()
  log(bWriteLog and "NewbieTaskSystem.HasRedDot")
  local newbieTaskInfo = NewbieTaskSystem.GetNewbieTaskInfo()
  for _, dailyTaskInfo in pairs(newbieTaskInfo) do
    if dailyTaskInfo.taskFinishedNum >= dailyTaskInfo.taskTotalNum and not dailyTaskInfo.isGotAwards then
      return true
    end
    for i, v in pairs(dailyTaskInfo.tasks) do
      if v.status == 1 then
        return true
      end
    end
  end
  return false
end
function NewbieTaskSystem.OnDayChanged(day)
  log(bWriteLog and "NewbieTaskSystem.OnDayChanged day: " .. day)
  if day > NewbieTaskSystem.totalDay then
    day = NewbieTaskSystem.totalDay
  end
  NewbieTaskSystem.curDay = day
  if 0 < day then
    local dailyTaskInfo = NewbieTaskSystem.newbieTaskInfo[day]
    if dailyTaskInfo.taskFinishedNum < dailyTaskInfo.taskTotalNum then
      table.insert(NewbieTaskSystem.unfinishedDayArray, day)
    elseif dailyTaskInfo.taskFinishedNum >= dailyTaskInfo.taskTotalNum and not dailyTaskInfo.isGotAwards and day <= NewbieTaskSystem.curDay then
      table.insert(NewbieTaskSystem.awaitGetAwardDayArray, day)
    end
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_DAY_CHANGED, day)
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_LOBBY_ENTRANCE_UPDATE)
end
function NewbieTaskSystem.OnTaskInfoSync(taskID, taskProgress, isFinished)
  if not NewbieTaskSystem.taskIDToTaskInfoMap or not NewbieTaskSystem.taskIDToTaskInfoMap[taskID] then
    return
  end
  local TaskInfo = NewbieTaskSystem.taskIDToTaskInfoMap[taskID]
  TaskInfo.  TaskInfo.  if isFinished then
    if TaskInfo.is_got then
      TaskInfo.status = 2
    else
      TaskInfo.status = 1
    end
  else
    TaskInfo.status = 0
  end
  local taskDay = NewbieTaskSystem.taskIDToTaskDayMap[taskID]
  local dailyTaskInfo = NewbieTaskSystem.newbieTaskInfo[taskDay]
  local taskFinishedNum = 0
  for _, singleTask in pairs(dailyTaskInfo.tasks) do
    if singleTask.isFinished then
      taskFinishedNum = taskFinishedNum + 1
    end
  end
  dailyTaskInfo.  if 0 < taskDay and taskDay <= NewbieTaskSystem.curDay then
    local newbieTaskInfo = NewbieTaskSystem.newbieTaskInfo[taskDay]
    if newbieTaskInfo and newbieTaskInfo.taskFinishedNum >= newbieTaskInfo.taskTotalNum then
      for idx, unfinishedTaskDay in pairs(NewbieTaskSystem.unfinishedDayArray) do
        if taskDay == unfinishedTaskDay then
          log_tree("NewbieTaskSystem.unfinishedDayArray", NewbieTaskSystem.unfinishedDayArray)
          table.remove(NewbieTaskSystem.unfinishedDayArray, idx)
          log_tree("NewbieTaskSystem.unfinishedDayArray", NewbieTaskSystem.unfinishedDayArray)
          break
        end
      end
    end
    if newbieTaskInfo and newbieTaskInfo.taskFinishedNum >= newbieTaskInfo.taskTotalNum and not newbieTaskInfo.isGotAwards and taskDay <= NewbieTaskSystem.curDay then
      table.insert(NewbieTaskSystem.awaitGetAwardDayArray, taskDay)
      table.sort(NewbieTaskSystem.awaitGetAwardDayArray)
    end
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_SYNC, taskDay)
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_LOBBY_ENTRANCE_UPDATE)
end
function NewbieTaskSystem.GetLastDayUnlockUrl()
  return NewbieTaskSystem.lastAwardUnlockUrl
end
function NewbieTaskSystem.GetLastDayLockUrl()
  return NewbieTaskSystem.lastAwardLockUrl
end
function NewbieTaskSystem.GetBannerUrl()
  return NewbieTaskSystem.bannerUrl
end
function NewbieTaskSystem.GetActivitySubData()
  if not NewbieTaskSystem.IsNewbie() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() < NewbieTaskSystem.beginTime then
    return
  end
  if TimeUtil.GetServerTimeInSec() > NewbieTaskSystem.endTime then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_Task,
    sName = LocUtil.GetLocalizeResStr(12205),
    bRedDot = NewbieTaskSystem.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function NewbieTaskSystem.ReceiveOne(day, task)
  NewbieTaskSystem.GetAwardByDay(day, task)
end
function NewbieTaskSystem.ReceiveFromRedHot(instanceKey)
  if instanceKey and instanceKey == ActivityFixedID.Newbie_Task then
    local newbieTaskInfo = NewbieTaskSystem.GetNewbieTaskInfo()
    local time_ticker = require("common.time_ticker")
    for k, dailyTaskInfo in pairs(newbieTaskInfo) do
      if dailyTaskInfo.taskFinishedNum >= dailyTaskInfo.taskTotalNum and not dailyTaskInfo.isGotAwards then
        time_ticker.AddTimerOnce(0.2, function()
          NewbieTaskSystem.ReceiveOne(k)
        end)
      end
      for i, v in pairs(dailyTaskInfo.tasks) do
        if v.status == 1 then
          time_ticker.AddTimerOnce(0.2, function()
            NewbieTaskSystem.ReceiveOne(k, i)
          end)
        end
      end
    end
  end
end
function NewbieTaskSystem.GetCanReceiveAwards(instanceKey)
  local awardList = {}
  local newbieTaskInfo = NewbieTaskSystem.GetNewbieTaskInfo()
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  for _, dailyTaskInfo in pairs(newbieTaskInfo) do
    if dailyTaskInfo.taskFinishedNum >= dailyTaskInfo.taskTotalNum and not dailyTaskInfo.isGotAwards and dailyTaskInfo.awards then
      for k, vv in pairs(dailyTaskInfo.awards) do
        table.insert(awardList, reddotUtil.CreateItem(vv.itemID, vv.count))
      end
    end
    for i, v in pairs(dailyTaskInfo.tasks) do
      if v.status == 1 and v.awards then
        for k, vv in pairs(v.awards) do
          table.insert(awardList, reddotUtil.CreateItem(vv.itemid, vv.cnt))
        end
      end
    end
  end
  return awardList
end
return NewbieTaskSystem