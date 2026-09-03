local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
local AreaGroupSystem = {
  tAllActData = {}
}
function AreaGroupSystem.GetActivitySubData()
  local nActType = ActivityType.ACTIVITY_TYPE_AREA_GROUP
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local tFinalActData = {}
  local list = ActivityNewSystem.GetActivityListByType(nActType)
  if next(list) then
    for _, v in ipairs(list) do
      if v.StartTime and nNowTime > v.StartTime and v.EndTime and nNowTime < v.EndTime then
        local tRealSubData = AreaGroupSystem.GetRealDataByFatherActID(v.ID)
        local data = {
          nActID = v.ID,
          sName = v.Title,
          bRedDot = AreaGroupSystem.MainActHasRedDot,
          nSwitchType = v.TabType or nil,
          startTime = v.StartTime,
          endTime = v.EndTime,
          Title = v.Title,
          ImgUrl = v.ImgUrl,
          nType = nActType,
          subData = tRealSubData,
          DisplayScene = v.DisplayScene,
          sTabImageUrl = v.TabImgUrl,
          Order = v.Order
        }
        if next(tRealSubData) then
          table.insert(tFinalActData, data)
        end
      end
    end
  end
  if next(tFinalActData) then
    AreaGroupSystem.tAllActData = tFinalActData
    return tFinalActData
  end
  AreaGroupSystem.tAllActData = {}
  return nil
end
function AreaGroupSystem.GetRealDataByFatherActID(nActID)
  local tActData = ActivityNewSystem.GetActivityByID(nActID)
  local tSubActData = {}
  local StringUtil = require("common.string_util")
  if tActData then
    if tActData.Condition then
      for _, v in pairs(StringUtil.Split(tActData.Condition, ",")) do
        if tonumber(v) == 0 then
          break
        end
        local tTempData = ActivityNewSystem.GetActivityByID(tonumber(v))
        if tTempData and next(tTempData) then
          table.insert(tSubActData, tTempData)
        end
      end
    end
    if tActData.ExtraCondition then
      for _, v in pairs(StringUtil.Split(tActData.ExtraCondition, ",")) do
        if tonumber(v) == 0 then
          break
        end
        local tTempData = ActivityNewSystem.GetActivityByID(tonumber(v))
        if tTempData and next(tTempData) then
          table.insert(tSubActData, tTempData)
        end
      end
    end
  end
  return tSubActData
end
function AreaGroupSystem.MainActHasRedDot(mainID)
  log_warning(bWriteLog and "  AreaGroupSystem.MainActHasRedDot. id: " .. tostring(mainID))
  local activity = ActivityNewSystem.GetActivityByID(mainID)
  if not activity then
    return false, ActivityMacros.RedDotType.None
  end
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  if not ActivityRedDot.CheckRedDotSwitcher(mainID) then
    return false, ActivityMacros.RedDotType.None
  end
  local actIdTable = AreaGroupSystem.GetSubActIdList(activity)
  local Red = false
  local RedDotType = ActivityMacros.RedDotType.None
  for _, id in ipairs(actIdTable) do
    if id ~= 0 then
      Red, RedDotType = AreaGroupSystem.HasAwardRedDot(id)
      if Red then
        return Red, RedDotType
      end
    end
  end
  for _, id in ipairs(actIdTable) do
    if id ~= 0 then
      Red, RedDotType = AreaGroupSystem.HasNewAndNearingRedDot(id)
      if Red then
        return Red, RedDotType
      end
    end
  end
  return Red, RedDotType
end
function AreaGroupSystem.HasAwardRedDot(ID)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(ID)
  if not actData then
    return false, ActivityMacros.RedDotType.None
  end
  local TimeUtil = require("client.common.time_util")
  if not actData.StartTime or not actData.EndTime then
    return false, ActivityMacros.RedDotType.None
  end
  if TimeUtil.UnixTimeBetween(actData.StartTime, actData.EndTime) ~= 0 then
    return false, ActivityMacros.RedDotType.None
  end
  for _, subData in ipairs(actData.List) do
    if subData.Type == ActivityType.ITEM_EXCHANGE then
      ActivityUtil.ResetExchangeParams(subData)
      if subData.IsCheckNotice == 1 and subData.Status ~= ActivityProgressStatus.Get then
        for _, costData in ipairs(subData.CostList) do
          if costData.have_count >= costData.count then
            return true, ActivityMacros.RedDotType.Reward
          end
        end
      end
    elseif subData.Status == ActivityProgressStatus.Done then
      local UIUtil = require("client.common.ui_util")
      for _, dropData in ipairs(subData.Drop) do
        if not UIUtil.IsEncryptionItem(dropData.itemId) then
          return true, ActivityMacros.RedDotType.Reward
        end
      end
    end
  end
  return false, ActivityMacros.RedDotType.None
end
function AreaGroupSystem.HasNewAndNearingRedDot(id)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(id)
  if not actData then
    return false, ActivityMacros.RedDotType.None
  end
  local TimeUtil = require("client.common.time_util")
  if not actData.StartTime or not actData.EndTime then
    return false, ActivityMacros.RedDotType.None
  end
  if TimeUtil.UnixTimeBetween(actData.StartTime, actData.EndTime) ~= 0 then
    return false, ActivityMacros.RedDotType.None
  end
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  if ActivityRedDot.CheckNewRedDot(id) then
    return true, ActivityMacros.RedDotType.New
  end
  if ActivityRedDot.CheckEndRedDot(actData.ID, actData) then
    return true, ActivityMacros.RedDotType.End
  end
  return false, ActivityMacros.RedDotType.None
end
function AreaGroupSystem.GetCurActHasDoneRate(nActID)
  local tCurActData = AreaGroupSystem.GetRealDataByFatherActID(nActID)
  local nAllTaskNum = 0
  local nCurDoneNum = 0
  for i, v in ipairs(tCurActData) do
    local nCurSum, nAllSum = ActivityUtil.GetCurActTaskData(v)
    nAllTaskNum = nAllTaskNum + nAllSum
    nCurDoneNum = nCurDoneNum + nCurSum
  end
  return nCurDoneNum / nAllTaskNum
end
function AreaGroupSystem.GetCurActThemeData(actID)
  local tSerVerData = ActivityNewSystem.GetServerDataByID(actID)
  if not tSerVerData or not tSerVerData.cfg then
    return {}
  end
  local sTheme = tSerVerData.cfg.back_up_one or ""
  local StringUtil = require("common.string_util")
  local data = StringUtil.Split(sTheme, "|") or {}
  if #data == 5 then
    return data
  end
  return {}
end
function AreaGroupSystem.GetFatherIDBySubID(nActID)
  if AreaGroupSystem.tAllActData and next(AreaGroupSystem.tAllActData) then
    for i, v in ipairs(AreaGroupSystem.tAllActData) do
      for ii, vv in ipairs(v.subData) do
        if nActID == vv.ID then
          return v.nActID
        end
      end
    end
  end
  return false
end
function AreaGroupSystem.IsActAllDone(nActId)
  if not nActId then
    return
  end
  local ratio = AreaGroupSystem.GetCurActHasDoneRate(nActId)
  return ratio == 1
end
function AreaGroupSystem.GetActAwards(actId)
  if not actId or actId == 0 then
    log(bWriteLog and "AreaGroupSystem.GetActAwards. actId is nil")
    return {}
  end
  local result = {}
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(actId)
  if not actData then
    log(bWriteLog and "AreaGroupSystem.GetActAwards. actData is nil")
    return result
  end
  local actIdTable = AreaGroupSystem.GetSubActIdList(actData)
  local TimeUtil = require("client.common.time_util")
  for _, subActId in ipairs(actIdTable) do
    if subActId ~= 0 then
      local subActData = ActivityNewSystem.GetActivityByID(subActId)
      if subActData then
        if TimeUtil.UnixTimeBetween(subActData.StartTime, subActData.EndTime) ~= 0 then
          break
        end
        for _, v in ipairs(subActData.List) do
          if v.Status == ActivityProgressStatus.Done then
            for _, dropInfo in ipairs(v.Drop) do
              table.insert(result, {
                resid = dropInfo.itemId,
                count = dropInfo.count,
                valid_hours = dropInfo.valid_hours
              })
              if #result == 3 then
                return result
              end
            end
          end
        end
      end
    end
  end
  return result
end
function AreaGroupSystem.GetSubActIdList(actData)
  local actIdTable = {}
  local string_util = require("common.string_util")
  if actData.Condition then
    local conditions = string_util.SplitToNum(actData.Condition, ",")
    if conditions and next(conditions) then
      table.move(conditions, 1, #conditions, #actIdTable + 1, actIdTable)
    end
  end
  if actData.ExtraCondition then
    local extraConditions = string_util.SplitToNum(actData.ExtraCondition, ",")
    if extraConditions and next(extraConditions) then
      table.move(extraConditions, 1, #extraConditions, #actIdTable + 1, actIdTable)
    end
  end
  return actIdTable
end
return AreaGroupSystem