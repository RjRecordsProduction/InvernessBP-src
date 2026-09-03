local logic_periodic_crate = {
  lastCheckCrate = 1,
  crateToReduceTime = 0,
  isKeepBoxStatus = false
}
local local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function logic_periodic_crate.GetActivitySubData_PeriodicCrate()
  local activityData = logic_periodic_crate.GetPeriodicCrateActivityData()
  if not activityData then
    return
  end
  local TimeUtil = require("client.common.time_util")
  if type(activityData.EndTime) == "number" and activityData.EndTime < TimeUtil.GetServerTimeInSec() then
    return
  end
  return {
    nActID = activityData.ID,
    sName = LocUtil.GetLocalizeResStr(81101),
    bRedDot = logic_periodic_crate.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = activityData.StartTime or 0,
    nSwitchType = activityData.TabType,
    DisplayScene = activityData.DisplayScene
  }
end
function logic_periodic_crate.OnGetPeriodicCrateAward(err_code, itemlist)
  if err_code ~= 0 or not itemlist then
    return
  end
  local parsedList = {}
  for k, v in pairs(itemlist) do
    parsedList[k] = {
      res_id = v.item_id,
      count = v.item_num,
      expire_ts = v.item_expire_time
    }
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(parsedList)
end
function logic_periodic_crate.GetPeriodicCrateActivityData()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  return logic_activity_mgr.GetActivityByType(ActivityType.PERIODIC_CRATE)
end
function logic_periodic_crate.GetCrateSubActivity(crateID)
  local crateData = logic_periodic_crate.GetCrateInfoList()
  if not crateData or not crateData[crateID] then
    return
  end
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  return logic_activity_mgr.GetActivityByID(crateData[crateID].sub_activity_id)
end
function logic_periodic_crate.GetCrateSubActivityTasks(crateID)
  local subActivityData = logic_periodic_crate.GetCrateSubActivity(crateID)
  if not subActivityData or not subActivityData.List then
    return
  end
  local taskList = {}
  for k, v in pairs(subActivityData.List) do
    local TableUtil = require("common.table_util")
    taskList[k] = TableUtil.CopyTable(v)
    taskList[k].timeReduction = 0
  end
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local activityRawData = logic_activity_mgr.GetServerData()
  for k, v in pairs(taskList) do
    local rawTaskData = activityRawData[v.ID]
    local TableUtil = require("common.table_util")
    local dropInfo = TableUtil.GetTableValue(rawTaskData, "cfg", "award", 1, "drop", 1)
    if dropInfo then
      v.timeReduction = dropInfo.item_num or 0
    end
  end
  table.sort(taskList, function(a, b)
    local aID = a.ID or 0
    local bID = b.ID or 0
    return aID < bID
  end)
  return taskList
end
function logic_periodic_crate.GetCrateIDFromSubActivity(subID)
  local crateInfoList = logic_periodic_crate.GetCrateInfoList()
  for crateID, _ in pairs(crateInfoList) do
    local crateTasks = logic_periodic_crate.GetCrateSubActivityTasks(crateID)
    if crateTasks then
      for k, v in pairs(crateTasks) do
        if v.ID == subID then
          return crateID, v
        end
      end
    end
  end
end
function logic_periodic_crate.GetCrateInfoList()
  local activityData = logic_periodic_crate.GetPeriodicCrateActivityData()
  if not activityData or not activityData.other then
    return nil
  end
  return activityData.other.cycle_chests
end
function logic_periodic_crate.GetCrateAwardItems(crateID)
  local activityData = logic_periodic_crate.GetPeriodicCrateActivityData()
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(activityData, "List", crateID, "Drop")
end
function logic_periodic_crate.GetDesiredCrateCountDownList()
  local activityData = logic_periodic_crate.GetPeriodicCrateActivityData()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local serverCountDown = {}
  local crateInfoList = logic_periodic_crate.GetCrateInfoList()
  if not crateInfoList then
    return serverCountDown
  end
  for k, v in pairs(crateInfoList) do
    serverCountDown[k] = v.award_ts - curTime
  end
  return serverCountDown
end
function logic_periodic_crate.HasRedDot()
  local HasRedDot = false
  local RedDotType = ActivityMacros.RedDotType.None
  local crateInfoList = logic_periodic_crate.GetCrateInfoList()
  if crateInfoList then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    for k, v in pairs(crateInfoList) do
      if v.award_ts and curTime >= v.award_ts then
        return true, ActivityMacros.RedDotType.Reward
      end
      local crateTasks = logic_periodic_crate.GetCrateSubActivityTasks(k)
      if crateTasks then
        log_tree("  logic_periodic_crate.HasRedDot. crateTasks ", crateTasks)
        for k, v in pairs(crateTasks) do
          if v.Status == 1 then
            return true, ActivityMacros.RedDotType.Reward
          end
        end
      end
    end
  end
  return HasRedDot, RedDotType
end
return logic_periodic_crate