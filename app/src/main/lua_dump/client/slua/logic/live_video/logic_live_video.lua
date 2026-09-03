local LiveVideoSystem = {}
local TimeIsValid = function(startTime, endTime)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local startTimeHourStr = TimeUtil.OSDate("!%H:%M:%S", startTime)
  local endTimeHourStr = TimeUtil.OSDate("!%H:%M:%S", endTime)
  local curDayStr = TimeUtil.OSDate("!%Y-%m-%d", now)
  local startTimeStr = curDayStr .. " " .. startTimeHourStr
  local endTimeStr = curDayStr .. " " .. endTimeHourStr
  local dailyStartTime = TimeUtil.TimeStringToUnixstamp(startTimeStr)
  local dailyEndTime = TimeUtil.TimeStringToUnixstamp(endTimeStr)
  log_tree("[edward] TimeIsValid", {startTimeStr, endTimeStr})
  if TimeUtil.UnixTimeBetween(dailyStartTime, dailyEndTime) == 0 then
    return true
  end
  return false
end
function LiveVideoSystem.GetActivityData()
  local language = Client.GetCurrentLanguage()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityList = ActivityNewSystem.GetActivityListByType(ActivityType.PURE_CLIENT)
  for _, v in ipairs(activityList) do
    if v.ShowSceneID == ActivitySceneID.LiveVideo and v.EntryImageUrl and v.EntryImageUrl ~= "" then
      local hasAct = false
      if v.DailyStartTime == 0 and v.DailyEndTime == 0 then
        hasAct = true
      elseif v.DailyStartTime > 0 and 0 < v.DailyEndTime then
        hasAct = TimeIsValid(v.DailyStartTime, v.DailyEndTime)
      end
      if hasAct then
        local StringUtil = require("common.string_util")
        local langList = StringUtil.Split(v.EntryImageUrl, "|")
        for _, vv in ipairs(langList) do
          if vv == language then
            return v
          end
        end
      end
    end
  end
  return nil
end
function LiveVideoSystem.ShouldSlap()
  if DataMgr and DataMgr.roleData and DataMgr.roleData.level and DataMgr.roleData.level < 5 then
    log(bWriteLog and "[jonahwei]FaceSlapLimit: roleData.level = " .. DataMgr.roleData.level)
    return false
  end
  if IsEditor then
    return false
  end
  if not LiveVideoSystem.GetActivityData() then
    return false
  end
  return true
end
function LiveVideoSystem.Slap()
  UIManager.ShowUI(UIManager.UI_Config.live_video_slap)
end
return LiveVideoSystem