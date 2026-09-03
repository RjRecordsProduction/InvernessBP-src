local LogicRatingProtectActivity = {
  modeGroupMap = {},
  ratingProtectActivityDataList = nil,
  hasSendReqGroupID = {}
}
local ActivityStatus = ActivityProgressStatus
local CheckViewIsRatingProtectMode = function(viewIds, actModeList, modeIdToMutiViewsList, modeIdToSimpleView)
  if viewIds == nil or actModeList == nil or type(actModeList) ~= "table" then
    log(bWriteLog and "CheckViewIsRatingProtectMode param is invalid")
    return false
  end
  local viewIdList = {}
  if type(viewIds) == "number" then
    viewIdList[viewIds] = viewIds
  elseif type(viewIds) == "table" and next(viewIds) then
    for _, view in pairs(viewIds) do
      viewIdList[view] = view
    end
  else
    log(bWriteLog and "CheckViewIsRatingProtectMode viewid is invalid")
    return false
  end
  for id, _ in pairs(actModeList) do
    local viewInfoList = modeIdToMutiViewsList and modeIdToMutiViewsList[tonumber(id)]
    if viewInfoList == nil then
      local simpleViewInfo = modeIdToSimpleView and modeIdToSimpleView[tonumber(id)]
      if simpleViewInfo ~= nil then
        log(bWriteLog and "CheckViewIsRatingProtectMode use simple view info")
        viewInfoList = {simpleViewInfo}
      else
        log(bWriteLog and "CheckViewIsRatingProtectMode no mode view info, modeid is " .. tostring(id))
      end
    end
    if viewInfoList ~= nil and type(viewInfoList) == "table" then
      for _, viewInfo in pairs(viewInfoList) do
        local actViewId = viewInfo and viewInfo.id or nil
        if actViewId and viewIdList[actViewId] then
          log(bWriteLog and "CheckViewIsRatingProtectMode true")
          return true
        end
      end
    end
  end
  log(bWriteLog and "CheckViewIsRatingProtectMode false")
  return false
end
function LogicRatingProtectActivity.send_get_activity_map_by_id_req(modeGroupId)
  log(bWriteLog and "send_get_activity_map_by_id_req modeGroupId is " .. tostring(modeGroupId))
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_activity_map_by_id_req(modeGroupId)
end
function LogicRatingProtectActivity.on_get_activity_map_by_id_res(modeGroupId, modeList)
  if modeGroupId == nil then
    log(bWriteLog and "on_get_activity_map_by_id_res modeGroupId is invalid")
    return
  end
  log(bWriteLog and "on_get_activity_map_by_id_res modeGroupId is " .. tostring(modeGroupId))
  if modeList == nil or type(modeList) ~= "table" then
    LogicRatingProtectActivity.modeGroupMap[modeGroupId] = {}
    log(bWriteLog and "on_get_activity_map_by_id_res modeList is invalid")
    return
  end
  log_tree(bWriteLog and "on_get_activity_map_by_id_res modeList", modeList)
  LogicRatingProtectActivity.modeGroupMap[modeGroupId] = modeList
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_RATING_PROTECT_ACTIVITY_GET_CONFIG)
end
function LogicRatingProtectActivity.send_get_activity_map_by_id_list_req(modeGroupIdList)
  log(bWriteLog and "send_get_activity_map_by_id_list_req")
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_activity_map_by_id_list_req(modeGroupIdList)
end
function LogicRatingProtectActivity.on_get_activity_map_by_id_list_res(mode_group_id_list, mode_group_list)
  log(bWriteLog and "on_get_activity_map_by_id_list_res")
  if mode_group_id_list == nil or type(mode_group_id_list) ~= "table" or mode_group_list == nil or type(mode_group_list) ~= "table" then
    log(bWriteLog and "on_get_activity_map_by_id_res params is invalid")
    return
  end
  for _, modeGroupId in pairs(mode_group_id_list) do
    if LogicRatingProtectActivity.modeGroupMap[modeGroupId] == nil then
      LogicRatingProtectActivity.modeGroupMap[modeGroupId] = {}
    end
  end
  log_tree(bWriteLog and "on_get_activity_map_by_id_res modeList", mode_group_list)
  for modeGroupId, modeList in pairs(mode_group_list) do
    LogicRatingProtectActivity.modeGroupMap[modeGroupId] = modeList
  end
  LogicRatingProtectActivity.hasSendReqGroupID = {}
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_RATING_PROTECT_ACTIVITY_GET_CONFIG)
end
function LogicRatingProtectActivity.GetRatingProtectActivityDataList()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  LogicRatingProtectActivity.ratingProtectActivityDataList = ActivityNewSystem.GetActivityListByType(ActivityType.HAPPY_TO_TEAM)
  table.sort(LogicRatingProtectActivity.ratingProtectActivityDataList, function(a, b)
    if a.BackupParam1 and not b.BackupParam1 then
      return true
    end
    if not a.BackupParam1 and b.BackupParam1 then
      return false
    end
    local aRemainNum = LogicRatingProtectActivity.GetRatingProtectRemainNumber(a.ID)
    local bRemainNum = LogicRatingProtectActivity.GetRatingProtectRemainNumber(b.ID)
    return aRemainNum > bRemainNum
  end)
  return LogicRatingProtectActivity.ratingProtectActivityDataList
end
function LogicRatingProtectActivity.GetRatingProtectCondition(activityData)
  if activityData == nil or activityData.List == nil or activityData.List[1] == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectCondition activity data is nil")
    return nil
  end
  local dataList = activityData.List[1]
  return dataList.Condition
end
function LogicRatingProtectActivity.GetRatingProtectConditionList()
  local activityDataList = LogicRatingProtectActivity.GetRatingProtectActivityDataList()
  if activityDataList == nil or not next(activityDataList) then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectConditionList activity data is nil")
    return nil
  end
  local conditionList = {}
  for _, activityData in pairs(activityDataList) do
    if activityData.List ~= nil and activityData.List[1] then
      local dataList = activityData.List[1]
      if dataList.Condition then
        table.insert(conditionList, dataList.Condition)
      end
    end
  end
  if next(conditionList) then
    return conditionList
  end
  return nil
end
function LogicRatingProtectActivity.GetActModeGroupCfg()
  local activityCondList = LogicRatingProtectActivity.GetRatingProtectConditionList()
  if activityCondList == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetActModeGroupCfg activity data is nil")
    return
  end
  local modeCondNotGet = {}
  for _, activityCond in pairs(activityCondList) do
    local modeGroupId = activityCond[1]
    if modeGroupId and modeGroupId ~= 0 then
      local actModeList = LogicRatingProtectActivity.modeGroupMap[modeGroupId]
      if actModeList == nil then
        table.insert(modeCondNotGet, modeGroupId)
      end
    end
  end
  if next(modeCondNotGet) then
    LogicRatingProtectActivity.send_get_activity_map_by_id_list_req(modeCondNotGet)
  end
end
function LogicRatingProtectActivity.GetPeakActModeGroupCfg(groupModIDs)
  local modeCondNotGet = {}
  LogicRatingProtectActivity.modeGroupMap = LogicRatingProtectActivity.modeGroupMap or {}
  for _, modeGroupId in pairs(groupModIDs) do
    if not LogicRatingProtectActivity.modeGroupMap[modeGroupId] and not LogicRatingProtectActivity.hasSendReqGroupID[modeGroupId] then
      table.insert(modeCondNotGet, modeGroupId)
      LogicRatingProtectActivity.hasSendReqGroupID[modeGroupId] = true
    end
  end
  if next(modeCondNotGet) then
    LogicRatingProtectActivity.send_get_activity_map_by_id_list_req(modeCondNotGet)
  end
end
function LogicRatingProtectActivity.CheckModeHasRatingProtectActivity(viewId)
  if viewId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.CheckModeHasRatingProtectActivity viewId is nil")
    return false, nil
  end
  local activityDataList = LogicRatingProtectActivity.GetRatingProtectActivityDataList()
  if activityDataList == nil or type(activityDataList) ~= "table" then
    log(bWriteLog and "LogicRatingProtectActivity.CheckModeHasRatingProtectActivity activity data is nil")
    return false, nil
  end
  for _, activityData in pairs(activityDataList) do
    local isActivityMode = LogicRatingProtectActivity.CheckRatingActivityHasMode(viewId, activityData)
    if isActivityMode then
      log(bWriteLog and "LogicRatingProtectActivity.CheckModeHasRatingProtectActivity Show")
      return true, activityData.ID
    end
  end
  log(bWriteLog and "LogicRatingProtectActivity.CheckModeHasRatingProtectActivity no activity match")
  return false, nil
end
function LogicRatingProtectActivity.IsReturnRatingProtectAct(activityData)
  if activityData.BackupParam1 == "1" then
    return true
  end
  return false
end
function LogicRatingProtectActivity.CheckReturnRatingProtectAct()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local back_user_data = DataMgr.roleData and DataMgr.roleData.back_user_data
  if back_user_data.rating_protect_expired_tm and TimeUtil.GetServerTimeInSec() >= back_user_data.rating_protect_expired_tm then
    return false
  end
  return true
end
function LogicRatingProtectActivity.CheckRatingActivityHasMode(viewId, activityData)
  if viewId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode viewId is nil")
    return false
  end
  if activityData == nil or activityData.List == nil or activityData.List[1] == nil then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode activity data is nil")
    return false
  end
  if LogicRatingProtectActivity.IsReturnRatingProtectAct(activityData) and not LogicRatingProtectActivity.CheckReturnRatingProtectAct() then
    return false
  end
  local startTime, lastTime = LogicRatingProtectActivity.GetRatingProtectActivityTime(activityData)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if startTime == nil or lastTime == nil or startTime > serverTime or lastTime < serverTime then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode activity not in open time")
    return false
  end
  local dataList = activityData.List[1]
  local totalNum = dataList.Total or 0
  local progressNum = dataList.Progress or 0
  if dataList.Status ~= ActivityStatus.Not then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode activity has done")
    return false
  end
  if totalNum - progressNum <= 0 then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode activity no times")
    return false
  end
  if dataList.Condition == nil then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode activity condition is nil")
    return false
  end
  local modeGroupId = dataList.Condition[1]
  if modeGroupId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode activity mode condition is nil")
    return false
  end
  local actModeList = LogicRatingProtectActivity.modeGroupMap[modeGroupId]
  if actModeList == nil then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode activity mode config is nil")
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeIdToMutiViewsList = logic_mode_selection:GetMutiViewInfoDictionary() or {}
  local modeIdToSimpleView = logic_mode_selection:GetSimpleViewInfoDictionary() or {}
  if CheckViewIsRatingProtectMode(viewId, actModeList, modeIdToMutiViewsList, modeIdToSimpleView) then
    log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode is activity mode")
    return true
  end
  log(bWriteLog and "LogicRatingProtectActivity.CheckRatingActivityHasMode not activity mode")
  return false
end
function LogicRatingProtectActivity.GetActModListByGroupID(modeGroupId)
  if not (LogicRatingProtectActivity.modeGroupMap and modeGroupId) or not LogicRatingProtectActivity.modeGroupMap[modeGroupId] then
    return nil
  end
  return LogicRatingProtectActivity.modeGroupMap[modeGroupId]
end
function LogicRatingProtectActivity.GetRatingProtectActivityTime(activityData)
  if activityData == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectActivityTime activity data is nil")
    return nil, nil
  end
  return activityData.StartTime, activityData.EndTime
end
function LogicRatingProtectActivity.GetRatingProtectActivityTimeById(activityId)
  if activityId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectActivityTimeById activity data is nil")
    return nil, nil
  end
  local activityData = LogicRatingProtectActivity.GetRatingProtectActivityDataById(activityId)
  if activityData == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectActivityTimeById activity data is nil")
    return nil, nil
  end
  local back_user_data = DataMgr.roleData.back_user_data
  if LogicRatingProtectActivity.IsReturnRatingProtectAct(activityData) and back_user_data then
    return back_user_data.rejoin_start_time, math.min(activityData.EndTime, back_user_data.rating_protect_expired_tm)
  end
  return activityData.StartTime, activityData.EndTime
end
function LogicRatingProtectActivity.GetRatingProtectRemainNumber(activityId)
  if activityId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectRemainNumber activityId is nil")
    return 0
  end
  local actData = LogicRatingProtectActivity.GetRatingProtectActivityDataById(activityId)
  if actData == nil or actData.List == nil or actData.List[1] == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectRemainNumber activity data is nil")
    return 0
  end
  local dataList = actData.List[1]
  if LogicRatingProtectActivity.IsReturnRatingProtectAct(actData) then
    local index = next(actData.List)
    local maxCount = 0
    for k, v in pairs(actData.List) do
      if maxCount <= v.Total - v.Progress then
        index = k
        maxCount = v.Total - v.Progress
      end
    end
    dataList = actData.List[index]
  end
  local totalNum = dataList and dataList.Total or 0
  local progressNum = dataList and dataList.Progress or 0
  local remainNumber = totalNum - progressNum
  return remainNumber
end
function LogicRatingProtectActivity.GetRatingProtectedCount(activityId)
  if activityId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectRemainNumber activityId is nil")
    return 0, 0
  end
  local actData = LogicRatingProtectActivity.GetRatingProtectActivityDataById(activityId)
  if actData == nil or actData.List == nil or actData.List[1] == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectRemainNumber activity data is nil")
    return 0, 0
  end
  local dataList = actData.List[1]
  local totalNum = dataList.Total or 0
  local progressNum = dataList.Progress or 0
  return progressNum, totalNum
end
function LogicRatingProtectActivity.GetRatingProtectTitleAndDesc(activityId)
  if activityId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectTitleAndDesc activityId is nil")
    return
  end
  local actData = LogicRatingProtectActivity.GetRatingProtectActivityDataById(activityId)
  if actData == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectTitleAndDesc activity data is nil")
    return
  end
  return actData.Title, actData.Desc
end
function LogicRatingProtectActivity.GetRatingProtectActivityDataById(activityId)
  if activityId == nil then
    log(bWriteLog and "LogicRatingProtectActivity.GetRatingProtectActivityDataById activityId is nil")
    return nil
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  return ActivityNewSystem.GetActivityByID(activityId)
end
function LogicRatingProtectActivity.IsShowRatingProtected()
  LogicRatingProtectActivity.GetActModeGroupCfg()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, viewid, viewids = logic_mode_selection:GetCurSelectInfo()
  if not logic_mode_selection:IsClassicRankMode(matchMode) then
    return false, nil
  end
  local logic_newbie_task_segment_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_task_segment_activity)
  if logic_newbie_task_segment_activity:IsOpen() then
    return true, nil
  end
  local isShow, activityId
  if viewids and 1 < #viewids then
    isShow, activityId = LogicRatingProtectActivity.CheckModeHasRatingProtectActivity(viewids)
  else
    isShow, activityId = LogicRatingProtectActivity.CheckModeHasRatingProtectActivity(viewid)
  end
  return isShow, activityId
end
function LogicRatingProtectActivity.ClearData()
  LogicRatingProtectActivity.ratingProtectActivityDataList = nil
end
return LogicRatingProtectActivity