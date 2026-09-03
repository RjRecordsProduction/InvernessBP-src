local GraduallyActSystem = {
  actCfg = {},
  actData = {}
}
local E_local SortActivity = function(tActdata)
  local statusSort = {
    [E_ActivityProgressStatus.Not] = 3,
    [E_ActivityProgressStatus.Done] = 1,
    [E_ActivityProgressStatus.Get] = 4,
    [E_ActivityProgressStatus.Done_Not] = 2,
    [E_ActivityProgressStatus.Expired] = 5
  }
  table.sort(tActdata, function(a, b)
    local sort_a = statusSort[a.Status]
    local sort_b = statusSort[b.Status]
    if sort_a == sort_b then
      return a.actID < b.actID
    else
      return sort_a < sort_b
    end
  end)
  return tActdata
end
local GetRemakeListForCenter = function(tTaskList, nIndex)
  if not (tTaskList and next(tTaskList)) or not GraduallyActSystem.actData.chapter then
    return {}
  end
  local PlotSystem = require("client.slua.logic.plot.logic_plot_activity")
  local List = {}
  local table_util = require("common.table_util")
  for i, v in pairs(tTaskList) do
    local remakeDrop = {}
    for ii, vv in ipairs(v.award) do
      local data = {
        itemId = vv.item_id,
        count = vv.item_num,
        expireTime = vv.item_expire_time
      }
      table.insert(remakeDrop, data)
    end
    local chapterData = table_util.GetTableValue(GraduallyActSystem.actData.chapter, nIndex)
    local taskData = chapterData and chapterData.task_data or {}
    local isunlock = chapterData and chapterData.isunlock or false
    local state = taskData[i] and taskData[i].task_status or 0
    if not isunlock then
      state = E_ActivityProgressStatus.Expired
    end
    local remakeData = {
      Title = v.task_dec,
      Type = 0,
      Progress = math.floor(tonumber(taskData[i] and taskData[i].process or 0)),
      Total = v.cond,
      Status = state,
      Drop = remakeDrop,
      ImgLink = GraduallyActSystem.actCfg[nIndex] and GraduallyActSystem.actCfg[nIndex].jump or "",
      actID = i,
      Index = nIndex,
      mainActID = ActivityFixedID.Gradually_Activity
    }
    table.insert(List, remakeData)
  end
  return SortActivity(List)
end
function GraduallyActSystem.GetActivitySubData()
  if not next(GraduallyActSystem.actCfg) or not next(GraduallyActSystem.actData) then
    return nil
  end
  local imageUrl, title
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local PlotSystem = require("client.slua.logic.plot.logic_plot_activity")
  if nNowTime <= PlotSystem.ActivityStartTime or nNowTime >= PlotSystem.ActivityEndTime then
    return nil
  end
  local remakeData = {}
  for i, v in ipairs(GraduallyActSystem.actCfg) do
    local data = {
      nIndex = i,
      List = GetRemakeListForCenter(v.task_list, i)
    }
    if v.pic ~= "" and not imageUrl then
      imageUrl = v.pic
    end
    if not title and v.title ~= "" then
      title = v.title
    end
    table.insert(remakeData, data)
  end
  local tActdata = {
    nActID = ActivityFixedID.Gradually_Activity,
    bRedDot = GraduallyActSystem.GetRedPointState,
    Title = title or "",
    sName = title or "",
    ImgUrl = imageUrl or "",
    List = remakeData,
    StartTime = PlotSystem.ActivityStartTime,
    EndTime = PlotSystem.ActivityEndTime
  }
  return tActdata
end
function GraduallyActSystem.GetRedPointState()
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  if not GraduallyActSystem.actData.chapter then
    return false, ActivityMacros.RedDotType.None
  end
  for i, v in ipairs(GraduallyActSystem.actData.chapter) do
    if v.task_data then
      for k, vv in pairs(v.task_data) do
        if vv.task_status == E_ActivityProgressStatus.Done then
          return true, ActivityMacros.RedDotType.Reward
        end
      end
    end
  end
  return false, ActivityMacros.RedDotType.None
end
function GraduallyActSystem.GetTitleData()
  if not next(GraduallyActSystem.actData) or not GraduallyActSystem.actData.chapter then
    return {}
  end
  local tTitleData = {}
  for i, v in ipairs(GraduallyActSystem.actData.chapter) do
    local data = {
      bIsUnlock = v.isunlock,
      title = GraduallyActSystem.actCfg[i] and GraduallyActSystem.actCfg[i].description or "",
      rule = GraduallyActSystem.actCfg[i] and GraduallyActSystem.actCfg[i].plot_rules or ""
    }
    table.insert(tTitleData, data)
  end
  return tTitleData
end
function GraduallyActSystem.GetHasDoneRate()
  if not next(GraduallyActSystem.actData) or not GraduallyActSystem.actData.chapter then
    return {}
  end
  local hasDone = 0
  local allTask = 0
  for i, v in ipairs(GraduallyActSystem.actData.chapter) do
    if v.task_data then
      for k, vv in pairs(v.task_data) do
        if vv.task_status == E_ActivityProgressStatus.Get then
          hasDone = hasDone + 1
        end
        allTask = allTask + 1
      end
    end
  end
  local rate = 0
  if 1 <= hasDone / allTask then
    rate = 1
  end
  return rate
end
return GraduallyActSystem