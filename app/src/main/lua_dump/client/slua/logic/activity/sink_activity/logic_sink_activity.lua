local logic_sink_activity = {}
local local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function logic_sink_activity.GetActivitySubData()
  local activityData = logic_sink_activity.GetSinkActivityData()
  if activityData == nil then
    return
  end
  return {
    nActID = activityData.ID,
    sName = LocUtil.GetLocalizeResStr(27182),
    bRedDot = logic_sink_activity.HasAwardCanTake,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0,
    DisplayScene = activityData.DisplayScene
  }
end
function logic_sink_activity.HasAwardCanTake()
  local activityData = logic_sink_activity.GetSinkActivityData()
  if activityData and activityData.List then
    for _, task in pairs(activityData.List) do
      if task.Status == 1 then
        return true, ActivityMacros.RedDotType.Reward
      end
    end
  end
  return false, ActivityMacros.RedDotType.None
end
function logic_sink_activity.GetSinkActivityData()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  return logic_activity_mgr.GetActivityByType(ActivityType.SINK_ACTIVITY)
end
return logic_sink_activity