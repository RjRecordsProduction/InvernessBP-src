local logic_prechurn_loginreward = {}
local C_OneDayTime = 86400
local C_OneHourTime = 3600
local C_SeasonLimitType = 1
local actOpenTime
function logic_prechurn_loginreward.GetRedDotNum()
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = ActivityMacros.RedDotType.None
  local activityData = logic_prechurn_loginreward.GetActData()
  if not activityData then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetRedDotNum return, activityData is nil ")
    return 0, RedDotType
  end
  local num = 0
  local taskList = activityData.List
  if taskList then
    for _, taskData in ipairs(taskList) do
      if taskData.Status == ActivityProgressStatus.Done then
        num = num + 1
        RedDotType = ActivityMacros.RedDotType.Reward
      end
    end
  end
  return num, RedDotType
end
function logic_prechurn_loginreward.GetDisplayActivityTaskData()
  local activityData = logic_prechurn_loginreward.GetActData()
  if not activityData then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetDisplayActivityTaskData return, activityData is nil ")
    return nil
  end
  local taskList = activityData.List
  if not taskList then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetDisplayActivityTaskData return, taskList is nil ")
    return
  end
  local displayActivityTaskData = {}
  for index, oneTaskData in ipairs(taskList) do
    local Temp = {
      ID = activityData.ID,
      Type = activityData.Type,
      TaskID = index,
      StartTime = activityData.StartTime,
      Drop = oneTaskData.Drop,
      Title = LocUtil.LocalizeResFormat(18323, oneTaskData.Index),
      Progress = oneTaskData.Progress,
      Total = oneTaskData.Total,
      Status = oneTaskData.Status,
      Index = index
    }
    table.insert(displayActivityTaskData, Temp)
  end
  return displayActivityTaskData
end
function logic_prechurn_loginreward.GetActivitySubData()
  local activityData = logic_prechurn_loginreward.GetActData()
  if not activityData then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetActivitySubData return, activityData is nil ")
    return nil
  end
  local tActdata = {
    nActID = activityData.ID,
    nRedDotNum = logic_prechurn_loginreward.GetRedDotNum,
    Title = activityData.Title or "",
    sName = activityData.Title or "",
    Desc = activityData.Desc or "",
    ImgUrl = activityData.ImgUrl or "",
    ImgLink = activityData.ImgLink or "",
    List = logic_prechurn_loginreward.GetDisplayActivityTaskData() or {},
    StartTime = activityData.StartTime,
    EndTime = activityData.EndTime,
    DisplayScene = activityData.DisplayScene
  }
  return tActdata
end
local _GetActData = function()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByType(ActivityType.PreventLose_LoginReward)
  if not activityData then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward._GetActData return, activityData is nil ")
    return nil
  end
  return activityData
end
function logic_prechurn_loginreward.GetActData()
  local activityData = _GetActData()
  if not activityData then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime >= activityData.StartTime and nowTime < activityData.EndTime then
    return activityData
  end
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetActData return, activityData is ended, StartTime = " .. tostring(activityData.StartTime) .. " EndTime = " .. tostring(activityData.EndTime))
  return nil
end
function logic_prechurn_loginreward.GetActivityStartTime(actStartTime)
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetActivityStartTime, startTime" .. tostring(actStartTime))
  local todayUTCZeroTime = actStartTime or 0
  local TimeUtil = require("client.common.time_util")
  local tDateTable = TimeUtil.GetDateByUnixTime(actStartTime)
  if next(tDateTable) then
    todayUTCZeroTime = todayUTCZeroTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetActivityStartTime\239\188\140 todayUTCZeroTime = " .. tostring(todayUTCZeroTime))
  end
  return todayUTCZeroTime
end
function logic_prechurn_loginreward.GetActivityEndTime(startTime)
  startTime = startTime or 0
  if startTime <= 0 then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetActivityEndTime return, startTime is zero ")
    return 0
  end
  local endTime = startTime + 3 * C_OneDayTime - 1
  return endTime
end
function logic_prechurn_loginreward.UpdateOpenActTime(time)
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.UpdateOpenActTime is time" .. tostring(time))
  actOpenTime = time
end
function logic_prechurn_loginreward.ShouldSlap()
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.CanShowSlap ")
  local nRedDotNum = logic_prechurn_loginreward.GetRedDotNum()
  if nRedDotNum <= 0 then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.CanShowSlap false, nRedDotNum is zero ")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePreChurnLoginRewardRecord)
  if saveData and saveData.lastSlapTime then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if TimeUtil.IsSameDay(curTime, saveData.lastSlapTime) then
      log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.CanShowSlap false, have pop ui, dayIndex = " .. tostring(curTime) .. " lastSlapTime = " .. tostring(saveData.lastSlapTime))
      return
    end
  end
  return true
end
function logic_prechurn_loginreward.OnJumpByUrl()
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.OpenActUIBySlap ")
  UIManager.ShowUI(UIManager.UI_Config.PreChurn_LoginReward_UIBP)
  local TimeUtil = require("client.common.time_util")
  local data = {
    lastSlapTime = TimeUtil.GetServerTimeInSec()
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.ePreChurnLoginRewardRecord)
end
function logic_prechurn_loginreward.GetNextRewardDayIndex()
  local nextRewardDayIndex = 0
  local activityData = logic_prechurn_loginreward.GetActData()
  local taskList = activityData and activityData.List
  if not taskList then
    return nextRewardDayIndex
  end
  local curRewardDayIndex = 0
  for _, taskData in ipairs(taskList) do
    if taskData.Status > ActivityProgressStatus.Not then
      curRewardDayIndex = taskData.Index
    elseif curRewardDayIndex < taskData.Index then
      nextRewardDayIndex = taskData.Index
    end
  end
  return nextRewardDayIndex
end
function logic_prechurn_loginreward.GetNextLocalPushTime()
  local activityData = logic_prechurn_loginreward.GetActData()
  if not activityData then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetNextLocalPushTime false, activityData is nil ")
    return
  end
  local nextRewardDayIndex = logic_prechurn_loginreward.GetNextRewardDayIndex()
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetNextLocalPushTime, nextRewardDayIndex = " .. tostring(nextRewardDayIndex))
  if nextRewardDayIndex <= 0 then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetNextLocalPushTime false, nextRewardDayIndex is zero ")
    return
  end
  local actStartTime = actOpenTime or 0
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetNextLocalPushTime\239\188\140 actStartTime = " .. tostring(actStartTime))
  local todayUTCZeroTime = activityData.StartTime or 0
  local nextDayEndTime = todayUTCZeroTime + C_OneDayTime * 2
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetNextLocalPushTime\239\188\140 nextDayEndTime = " .. tostring(nextDayEndTime))
  local nextPushTime = actStartTime + C_OneDayTime
  if nextDayEndTime - nextPushTime < C_OneHourTime then
    nextPushTime = nextDayEndTime - C_OneHourTime
  end
  local actEndTime = activityData.EndTime or 0
  if nextPushTime >= actEndTime then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetNextLocalPushTime false\239\188\140 nextPushTime = " .. tostring(nextPushTime) .. " actEndTime = " .. tostring(actEndTime))
    return
  end
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetNextLocalPushTime\239\188\140 nextPushTime = " .. tostring(nextPushTime))
  return nextPushTime
end
function logic_prechurn_loginreward.GetSeasonEndTime(seasonID)
  local seasonCfg = CDataTable.GetTableData("SeasonInfo", seasonID)
  if not seasonCfg then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetSeasonEndTime return, seasonCfg is nil, seasonID = " .. tostring(seasonID))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local curSeasonEndTime = TimeUtil.TimeStringToUnixstamp(seasonCfg.EndTime, false)
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetSeasonEndTime, seasonID = " .. tostring(seasonID) .. " curSeasonEndTime = " .. tostring(curSeasonEndTime))
  return curSeasonEndTime
end
function logic_prechurn_loginreward.GetExTime(itemId)
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetExTime, itemId =  " .. tostring(itemId))
  if not itemId then
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(itemId)
  if itemData and itemData.expireTS then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetExTime, return itemData.expireTS = " .. tostring(itemData.expireTS))
    return itemData.expireTS
  end
  local itemCfg = CDataTable.GetTableData("SeasonCardsConfig", itemId)
  if not itemCfg or itemCfg.TimeLimitType ~= C_SeasonLimitType then
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetExTime, TimeLimitType not match  ")
    return
  end
  local seasonID = DataMgr.season_id
  local seasonEndTime = logic_prechurn_loginreward.GetSeasonEndTime(seasonID) or 0
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if seasonEndTime <= curTime then
    seasonEndTime = logic_prechurn_loginreward.GetSeasonEndTime(seasonID + 1) or 0
    log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetExTime, is in nextSeason blank time\239\188\155return time\239\188\154 " .. tostring(seasonEndTime))
  end
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetExTime, return curSeasonEndTime = " .. tostring(seasonEndTime))
  return seasonEndTime
end
function logic_prechurn_loginreward.GetValidHours(itemId)
  local expireTS = logic_prechurn_loginreward.GetExTime(itemId)
  if not expireTS or expireTS <= 0 then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local remainTime = expireTS - curTime
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetValidHours,  remainTime = " .. tostring(remainTime))
  local validHours = math.modf(remainTime / 3600)
  log(bWriteLog and "[v_wllwu] logic_prechurn_loginreward.GetValidHours,  itemId = " .. tostring(itemId) .. " ValidHours = " .. tostring(validHours))
  return validHours
end
return logic_prechurn_loginreward