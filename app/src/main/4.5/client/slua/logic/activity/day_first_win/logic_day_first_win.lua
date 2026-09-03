local logic_day_first_win = {}
local local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function logic_day_first_win.GetActivitySubData()
  local activityData = logic_day_first_win.GetDayFirstWinActivityData()
  if not activityData then
    return
  end
  return {
    nActID = activityData.ID,
    sName = activityData.Title,
    bRedDot = logic_day_first_win.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    Order = activityData.Order,
    DisplayScene = activityData.DisplayScene,
    nStartTime = 0
  }
end
function logic_day_first_win.HasRedDot()
  if logic_day_first_win.HasDayFirstWinTask() and not logic_day_first_win.CheckDayFirstWinTaskFinished() and not logic_day_first_win.IsEnterActicity() then
    return true, ActivityMacros.RedDotType.Normal
  end
  return false, ActivityMacros.RedDotType.None
end
function logic_day_first_win.HasDayFirstWinTask()
  local task = logic_day_first_win.GetDayFirstWinTaskData()
  return task ~= nil
end
function logic_day_first_win.CheckDayFirstWinTaskFinished()
  local task = logic_day_first_win.GetDayFirstWinTaskData()
  if task and task.Progress < task.Total then
    return false
  end
  return true
end
function logic_day_first_win.SaveEnterData()
  local isEnterTab = {isEnter = 1}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(isEnterTab, PlayerPrefsSystem.ePlayerPrefsType.eEnterAddScoreActivity)
  local activityData = logic_day_first_win.GetDayFirstWinActivityData()
  local id = activityData and activityData.ID
  if id then
    local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
    ActivityRedDot.RefreshOneActRedDot(id)
  end
end
function logic_day_first_win.IsEnterActicity()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isEnterTab = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEnterAddScoreActivity)
  if isEnterTab and isEnterTab.isEnter and isEnterTab.isEnter == 1 then
    return true
  end
  return false
end
function logic_day_first_win.GetDayFirstWinActivityData()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  return logic_activity_mgr.GetActivityByType(ActivityType.DAY_FIRST_WIN)
end
function logic_day_first_win.GetDayFirstWinTaskData()
  local activityData = logic_day_first_win.GetDayFirstWinActivityData()
  if activityData and activityData.List then
    return activityData.List[1]
  end
  return nil
end
function logic_day_first_win.GetTaskConditions()
  local task = logic_day_first_win.GetDayFirstWinTaskData()
  local StringUtil = require("common.string_util")
  if task and task.Title and task.Title ~= "" then
    return StringUtil.Split(task.Title, "|")
  end
  return {}
end
function logic_day_first_win.CheckShowDayFirstWinTask()
  return not logic_day_first_win.CheckDayFirstWinTaskFinished()
end
function logic_day_first_win.GetDayFirstWinTaskProgress()
  local task = logic_day_first_win.GetDayFirstWinTaskData()
  if not task then
    return 0, 0
  end
  return task.Progress or 0, task.Total or 0
end
return logic_day_first_win