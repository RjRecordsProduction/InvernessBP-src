local logic_longterm_sign = {activityID = 0}
local local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function logic_longterm_sign.GetActivitySubData_LongSign()
  local activityData = logic_longterm_sign.GetLongSignActivityData()
  if activityData == nil then
    return
  end
  logic_longterm_sign.activityID = activityData.ID
  return {
    nActID = activityData.ID,
    nSwitchType = activityData.TabType,
    sName = activityData.Title or LocUtil.GetLocalizeResStr(81001),
    bRedDot = logic_longterm_sign.HasRedDot,
    sBgUrl = "",
    ImgUrl = activityData.ImgUrl,
    ImgLink = "",
    nStartTime = activityData.StartTime or 0,
    sItemImage = activityData.EntryImageUrl,
    DisplayScene = activityData.DisplayScene,
    sTabImageUrl = activityData.TabImgUrl
  }
end
function logic_longterm_sign.GetLongSignActivityData()
  local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = logic_activity_mgr.GetActivityByType(ActivityType.LONG_SIGN)
  return activityData
end
function logic_longterm_sign.GetLongSignDataList()
  local activityData = logic_longterm_sign.GetLongSignActivityData()
  if not activityData then
    return nil
  end
  return activityData.List
end
function logic_longterm_sign.HasRedDot()
  local dataList = logic_longterm_sign.GetLongSignDataList()
  if not dataList then
    return false
  end
  local curData = dataList[logic_longterm_sign.GetCurAwardIndex()]
  if curData and curData.Status == 1 then
    return true, ActivityMacros.RedDotType.Reward
  end
  return false, ActivityMacros.RedDotType.None
end
function logic_longterm_sign.GetCurAwardIndex()
  local dataList = logic_longterm_sign.GetLongSignDataList()
  if not dataList then
    return 0
  end
  for k, v in pairs(dataList) do
    if tonumber(v.Status) < 2 then
      return tonumber(k)
    end
  end
  return 0
end
function logic_longterm_sign.ReceiveOne(ID, Index)
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_activity_award_req(ID, Index)
end
function logic_longterm_sign.ReceiveFromRedHot(instanceKey)
  if instanceKey and logic_longterm_sign.activityID and instanceKey == logic_longterm_sign.activityID then
    local activityData = logic_longterm_sign.GetLongSignActivityData()
    if activityData and activityData.List and #activityData.List > 0 then
      local time_ticker = require("common.time_ticker")
      for k, v in pairs(activityData.List) do
        if v.Status == 1 then
          time_ticker.AddTimerOnce(0.2, function()
            logic_longterm_sign.ReceiveOne(v.ID, v.Index)
          end)
        end
      end
    end
  end
end
function logic_longterm_sign.GetCanReceiveAwards(instanceKey)
  local activityData = logic_longterm_sign.GetLongSignActivityData()
  if activityData and activityData.List and #activityData.List > 0 then
    local awardList = {}
    local reddotUtil = require("client.slua.logic.reddot.reddot_util")
    for k, v in pairs(activityData.List) do
      if v.Status == 1 and v.Drop and v.Drop[1] then
        table.insert(awardList, reddotUtil.CreateItem(v.Drop[1].itemId, v.Drop[1].count, v.Drop[1].expireTime))
      end
    end
    return awardList
  end
  return nil
end
return logic_longterm_sign