local ActivityRebate = {
  rebateInfo = nil,
  list = nil,
  rebateAwardInfos = nil,
  slapEntrance = {
    slap = "slap",
    store = "store",
    activity = "activity",
    other = "other"
  },
  activityPhase = {
    discount = 0,
    betweenDiscountAndRebate = 1,
    rebate = 2,
    ending = -1
  }
}
local ParseData = function(activityInfo)
  ActivityRebate.rebateInfo = {
    posterURL = "",
    condItemID = 0,
    condShopID = 0,
    rebateItemID1 = 0,
    rebateItemID2 = 0,
    rebateItemNum1 = 0,
    rebateItemNum2 = 0,
    UCNum = 0,
    condExPrice = 0,
    condNowPrice = 0,
    condDiscountRate = 0,
    rebateRate = 0,
    awardValue = 0,
    activityBegin = 0,
    activityEnd = 0,
    condBegin = 0,
    condEnd = 0,
    rebateBegin = 0,
    rebateEnd = 0,
    rebateInfo = {},
    rebateAwardInfos = {},
    condRemainTime = 0,
    hasBought = false
  }
  ActivityRebate.rebateInfo.posterURL = activityInfo.Detail
  local StringUtil = require("common.string_util")
  local conds = StringUtil.Split(activityInfo.Condition, ",")
  local condShopID = tonumber(conds[1])
  local condNowPrice = conds[4]
  local condExPrice = conds[5]
  local awardValue = conds[6]
  local condItemID = conds[7]
  ActivityRebate.rebateInfo.  ActivityRebate.rebateInfo.  ActivityRebate.rebateInfo.  ActivityRebate.rebateInfo.  ActivityRebate.rebateInfo.condDiscountRate = math.floor((condExPrice - condNowPrice) / condExPrice * 100)
  ActivityRebate.rebateInfo.rebateRate = math.floor(awardValue / condNowPrice * 100)
  ActivityRebate.list = {}
  for _, award in pairs(activityInfo.List) do
    if 0 < #award.Drop and award.Drop[1].itemId ~= 0 then
      table.insert(ActivityRebate.list, award)
    end
  end
  ActivityRebate.rebateInfo.rebateItemID1 = ActivityRebate.list[#ActivityRebate.list].Drop[1].itemId
  ActivityRebate.rebateInfo.rebateItemID2 = ActivityRebate.list[#ActivityRebate.list].Drop[2].itemId
  ActivityRebate.rebateInfo.  ActivityRebate.rebateInfo.activityBegin = activityInfo.StartTime
  ActivityRebate.rebateInfo.activityEnd = activityInfo.EndTime
  local daysToSecFactor = 86400
  ActivityRebate.rebateInfo.condBegin = conds[2] * daysToSecFactor + activityInfo.StartTime
  ActivityRebate.rebateInfo.condEnd = conds[3] * daysToSecFactor + activityInfo.StartTime - 1
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityListMap = ActivityNewSystem.GetSubListMap()
  local rebateFirst = activityListMap[activityInfo.ID .. "_" .. tostring(2)]
  local rebateLast = activityListMap[activityInfo.ID .. "_" .. tostring(#ActivityRebate.list + 1)]
  ActivityRebate.rebateInfo.rebateBegin = activityInfo.StartTime + rebateFirst.Condition[1] * daysToSecFactor
  ActivityRebate.rebateInfo.rebateEnd = activityInfo.StartTime + rebateLast.Condition[2] * daysToSecFactor - 1
  if rebateFirst.Status == ActivityProgressStatus.Not then
    ActivityRebate.hasBought = false
  else
    ActivityRebate.hasBought = true
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  ActivityRebate.rebateInfo.condRemainTime = ActivityRebate.rebateInfo.condEnd - now
  ActivityRebate.rebateAwardInfos = {}
  local itemNum1 = 0
  local itemNum2 = 0
  local UCNum = 0
  local itemID1, itemID2
  for idx = 1, #ActivityRebate.list do
    local svrRebateInfo = activityListMap[activityInfo.ID .. "_" .. tostring(idx + 1)]
    if svrRebateInfo then
      local rebateAwardInfo = {}
      rebateAwardInfo.beginTime = activityInfo.StartTime + svrRebateInfo.Condition[1] * daysToSecFactor
      rebateAwardInfo.endTime = activityInfo.StartTime + svrRebateInfo.Condition[2] * daysToSecFactor - 1
      rebateAwardInfo.itemInfo = {}
      if svrRebateInfo.Drop then
        for _, drop in pairs(svrRebateInfo.Drop) do
          local UCItemID = 1006
          if drop.itemId == UCItemID then
            UCNum = UCNum + drop.count
          end
          local singleAwardInfo = {}
          singleAwardInfo.itemID = drop.itemId
          singleAwardInfo.itemCount = drop.count
          if not itemID1 or drop.itemId == itemID1 then
            itemID1 = drop.itemId
            itemNum1 = itemNum1 + drop.count
          elseif not itemID2 or drop.itemId == itemID2 then
            itemID2 = drop.itemId
            itemNum2 = itemNum2 + drop.count
          end
          table.insert(rebateAwardInfo.itemInfo, singleAwardInfo)
        end
      end
      table.insert(ActivityRebate.rebateAwardInfos, rebateAwardInfo)
    end
  end
  ActivityRebate.rebateInfo.rebateItemNum1 = itemNum1
  ActivityRebate.rebateInfo.rebateItemNum2 = itemNum2
  ActivityRebate.rebateInfo.end
local UpdateInfo = function()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityInfo = ActivityNewSystem.GetActivityByType(ActivityType.ACTIVITY_TYPE_REBATE)
  if activityInfo then
    ParseData(activityInfo)
  end
end
local OnInfoChange = function(eventType, eventID, vars)
  if vars and vars.typeList and vars.typeList[ActivityType.ACTIVITY_TYPE_REBATE] then
    UpdateInfo()
  end
end
local InitData = function()
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, OnInfoChange)
  UpdateInfo()
end
function ActivityRebate.GetRebateAwardInfos()
  if not ActivityRebate.rebateAwardInfos then
    InitData()
  end
  return ActivityRebate.rebateAwardInfos
end
function ActivityRebate.GetRebateInfo()
  if not ActivityRebate.rebateInfo then
    InitData()
  end
  return ActivityRebate.rebateInfo
end
function ActivityRebate.ShouldSlap()
  local info = ActivityRebate.GetRebateInfo()
  if not info then
    return false
  end
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsFileExist(UIManager.UI_Config.activity_rebate_slap.path) then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if info and now > info.condBegin and now < info.condEnd and ActivityRebate.list[1].Status == ActivityProgressStatus.Not then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local lastTimeStamp = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eActivityRebate) or 0
    local currStamp = TimeUtil.GetServerTimeInSec()
    if math.floor(lastTimeStamp / 86400) == math.floor(currStamp / 86400) then
      math.randomseed(TimeUtil.OSTime())
      local randomNum = math.random(1, 3)
      if randomNum == 3 then
        PlayerPrefsSystem.SaveTableToFile_N(currStamp, PlayerPrefsSystem.ePlayerPrefsType.eActivityRebate)
        return true
      end
      log(bWriteLog and "[MHT]ActivityRebate.ShouldSlap() Randomly slap when it is not the first time login today. Random is " .. tostring(randomNum))
      return false
    end
    PlayerPrefsSystem.SaveTableToFile_N(currStamp, PlayerPrefsSystem.ePlayerPrefsType.eActivityRebate)
    return true
  end
  log(bWriteLog and "[MHT]ActivityRebate.ShouldSlap() Don't slap when rebate activity is not begin, or player have bought item")
  return false
end
function ActivityRebate.PopSlap()
  UIManager.ShowUI(UIManager.UI_Config.activity_rebate_slap, ActivityRebate.slapEntrance.slap)
end
function ActivityRebate.IsRebateBuyItem(shopID)
  if shopID then
    local info = ActivityRebate.GetRebateInfo()
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if info and info.condShopID == shopID and now >= info.condBegin and now <= info.condEnd then
      return true
    end
  end
  return false
end
return ActivityRebate