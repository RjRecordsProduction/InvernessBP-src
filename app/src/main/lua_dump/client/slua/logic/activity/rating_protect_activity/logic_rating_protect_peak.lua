local logic_rating_protect_peak = {}
local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
function logic_rating_protect_peak.CheckIsPeakAddOpen(buffID, activityData)
  if not activityData then
    log(bWriteLog and "logic_rating_protect_peak.CheckIsPeakAddOpen no activity")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not activityData.EndTime or nowTime > activityData.EndTime or nowTime < activityData.StartTime then
    log(bWriteLog and "logic_rating_protect_peak.CheckIsPeakAddOpen no time")
    return false
  end
  if not activityData.List or not activityData.List[1] then
    log(bWriteLog and "logic_rating_protect_peak.CheckIsPeakAddOpen data err")
    return false
  end
  if not activityData.List[1].Condition[6] or activityData.List[1].Condition[6] ~= buffID then
    log(bWriteLog and string.format("logic_rating_protect_peak.CheckIsPeakAddOpen type not match %s %s %s", activityData.ID, buffID, activityData.List[1].Condition[6]))
    return false
  end
  local modeGroupId = activityData.List[1].Condition[1]
  if modeGroupId then
    local modList = LogicRatingProtectActivity.GetActModListByGroupID(modeGroupId)
    if not modList then
      log(bWriteLog and "logic_rating_protect_peak.CheckIsPeakAddOpen no modList")
      return false
    end
    local maps = {}
    for k, v in pairs(modList) do
      local BTMode = CDataTable.GetTableData("BTMode", k)
      if BTMode then
        local mapID = BTMode.MapID
        local mapCfg = CDataTable.GetTableData("Map", mapID)
        if mapCfg then
          table.insert(maps, mapCfg.MapKey)
        end
      end
    end
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, maps)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "logic_rating_protect_peak.CheckIsPeakAddOpen type no map")
      return false
    end
  end
  if activityData.List[1].Condition[2] <= activityData.other.day_count then
    log(bWriteLog and "logic_rating_protect_peak.CheckIsPeakAddOpen no count")
    return false
  end
  log(bWriteLog and string.format("logic_rating_protect_peak.CheckIsPeakAddOpen true %s %s", buffID, activityData.ID))
  return true, activityData.ID, activityData.EndTime, activityData.other.day_count or 0, activityData.List[1].Condition[2] or 0, activityData.List[1].Condition[1]
end
function logic_rating_protect_peak.CheckAddActivity(buffID)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isPakegame = logic_mode_selection:IsPeakGameView()
  return logic_rating_protect_peak.CheckIsPeakAddOpen(buffID, logic_activity_mgr.GetActivityByType(ActivityType.Peak_GAME_ADD_SCORE))
end
function logic_rating_protect_peak.GetAddActivityProgress()
  local activityData = logic_activity_mgr.GetActivityByType(ActivityType.Peak_GAME_ADD_SCORE)
  if not activityData then
    return 0, 0
  end
  return activityData.other.day_count or 0, activityData.List[1].Condition[2] or 0
end
function logic_rating_protect_peak.CheckProtectctivity(buffID)
  local activityData = logic_activity_mgr.GetActivityByType(ActivityType.Peak_GAME_NOT_SCORE)
  if not activityData then
    log(bWriteLog and "logic_rating_protect_peak.CheckProtectctivity no activity")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not activityData.EndTime or nowTime > activityData.EndTime or nowTime < activityData.StartTime then
    log(bWriteLog and "logic_rating_protect_peak.CheckProtectctivity no time")
    return false
  end
  return true, activityData.ID, activityData.EndTime, activityData.List[1].Condition[1]
end
function logic_rating_protect_peak.GetProtectActivityProgress()
  local activityData = logic_activity_mgr.GetActivityByType(ActivityType.Peak_GAME_NOT_SCORE)
  if not activityData then
    return 0, 0
  end
  return activityData.other.day_count or 0, activityData.List[1].Condition[2] or 0
end
function logic_rating_protect_peak.checkAndCountListFunc(buffID)
  local result = {}
  local actList = logic_activity_mgr.GetActivityListByType(ActivityType.Peak_GAME_ADD_SCORE)
  log_tree("logic_rating_protect_peak.checkAndCountListFunc", actList)
  local groupModIDs = {}
  for k, v in pairs(actList) do
    local isShow, act_id, _, progressNum, totalNum, groupModID = logic_rating_protect_peak.CheckIsPeakAddOpen(buffID, v)
    if isShow then
      local item = {
        act_id = act_id,
        progressNum = progressNum,
        totalNum = totalNum,
              }
      table.insert(result, item)
    end
    table.insert(groupModIDs, v.List[1].Condition[1])
  end
  LogicRatingProtectActivity.GetPeakActModeGroupCfg(groupModIDs)
  return result
end
function logic_rating_protect_peak.GetAddActivityByMapID(mapID)
  local actList = logic_activity_mgr.GetActivityListByType(ActivityType.Peak_GAME_ADD_SCORE)
  for k, v in pairs(actList) do
    local modeGroupId = v.List[1].Condition[1]
    if modeGroupId then
      local modList = LogicRatingProtectActivity.GetActModListByGroupID(modeGroupId)
      if modList then
        for k1, v1 in pairs(modList) do
          local BTMode = CDataTable.GetTableData("BTMode", k1)
          if BTMode and BTMode.MapID == mapID then
            return v
          end
        end
      end
    end
  end
  return nil
end
function logic_rating_protect_peak.GetPeakMapNameByGroupID(groupID)
  local nameStr = LocUtil.GetLocalizeResStr(500053)
  if not groupID then
    return nameStr
  end
  local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
  local modList = LogicRatingProtectActivity.GetActModListByGroupID(groupID)
  if not modList then
    return nameStr
  end
  for k, v in pairs(modList) do
    local BTMode = CDataTable.GetTableData("BTMode", k)
    if BTMode then
      local mapID = BTMode.MapID
      local mapCfg = CDataTable.GetTableData("Map", mapID)
      if mapCfg then
        return mapCfg.MapName
      end
    end
  end
  return nameStr
end
return logic_rating_protect_peak