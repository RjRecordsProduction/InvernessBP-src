local LogicSeasonCycleMemory = {curSeasonModeOpencfg = nil, isSeasonOpenEntrance = false}
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local EnumTaskType = {TitleTask = 7}
local NewProgressStatusSeasonId = 26
local EnumMemoryItemType = {
  Video = 1,
  Voice = 2,
  Normal = 3
}
LogicSeasonCycleMemory.local ErrorCode_Entrance_Closed = 113000018
local cycle_cfg_client_data, cycle_task_cfg_client_data, memoryDataRes, curSelectYearId, curSelectSeasonId, next_season_start_time
local EnumMemoryDataStatus = {
  NORMAL = 1,
  UNOPENED = 2,
  NODATA = 3
}
LogicSeasonCycleMemory.local voicePakId = 1900344
function LogicSeasonCycleMemory.SetCurSelectYearId(yearId)
  curSelectYearId = yearId
end
function LogicSeasonCycleMemory.GetCurSelectYearId()
  return curSelectYearId
end
function LogicSeasonCycleMemory.SetCurSelectSeasonId(matchId)
  curSelectSeasonId = matchId
end
function LogicSeasonCycleMemory.GetCurSelectSeasonId()
  return curSelectSeasonId
end
function LogicSeasonCycleMemory.GetCurYearId()
  return memoryDataRes.cur_year_id or 0
end
function LogicSeasonCycleMemory.GetTaskIDByMemoryItemID(yearId, seasonId, itemID)
  local TableUtil = require("common.table_util")
  local taskcfg = TableUtil.GetTableValue(memoryDataRes, "task_cfg", yearId, seasonId)
  if taskcfg then
    for taskid, v in pairs(taskcfg) do
      if v.award_list and v.award_list[1] and v.award_list[1].resid == itemID then
        return taskid
      end
    end
  end
end
function LogicSeasonCycleMemory.GetMemoryDataTaskRes()
  return memoryDataRes
end
function LogicSeasonCycleMemory.GetTaskDataByTaskID(yearid, seasonid, taskid)
  if memoryDataRes and memoryDataRes.task_data and memoryDataRes.task_data[yearid] and memoryDataRes.task_data[yearid][seasonid] and memoryDataRes.task_data[yearid][seasonid].task then
    return memoryDataRes.task_data[yearid][seasonid].task[taskid]
  end
end
function LogicSeasonCycleMemory.GetTaskCfgByTaskID(yearId, seasonId, taskId)
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory.GetTaskCfgByTaskID" .. " taskid " .. tostring(taskId))
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(memoryDataRes, "task_cfg", yearId, seasonId, taskId)
end
function LogicSeasonCycleMemory.GetMemoryRewardListByItemID(yearId, seasonId, itemId)
  if memoryDataRes and memoryDataRes.conf and memoryDataRes.conf[yearId] and memoryDataRes.conf[yearId][seasonId] then
    local arr = memoryDataRes.conf[yearId][seasonId]
    for i, v in ipairs(arr) do
      if v.item_id == itemId then
        return v.award_list
      end
    end
  end
end
function LogicSeasonCycleMemory.GetMemoryUniqIdByItemID(yearId, seasonId, itemId)
  if not (yearId and seasonId) or not itemId then
    log(bWriteLog and "LogicSeasonCycleMemory.GetMemoryUniqIdByItemID param is valid")
    return
  end
  if not (memoryDataRes and memoryDataRes.conf and memoryDataRes.conf[yearId]) or not memoryDataRes.conf[yearId][seasonId] then
    log(bWriteLog and "LogicSeasonCycleMemory.GetMemoryUniqIdByItemID data is valid")
    return
  end
  log(bWriteLog and "LogicSeasonCycleMemory.GetMemoryUniqIdByItemID")
  local seasonConf = memoryDataRes.conf[yearId][seasonId]
  for _, v in ipairs(seasonConf) do
    if v.item_id == itemId then
      return v.uniq_id
    end
  end
end
function LogicSeasonCycleMemory.GetRewardListByIndex(yearID, matchID, memoryIndex)
  if memoryDataRes and memoryDataRes.conf and memoryDataRes.conf[yearID] and memoryDataRes.conf[yearID][matchID] and memoryDataRes.conf[yearID][matchID][memoryIndex] then
    local data = memoryDataRes.conf[yearID][matchID][memoryIndex]
    local ret = {}
    if data then
      for k, v in pairs(data.award_list) do
        ret[#ret + 1] = v
      end
    end
    return ret
  end
end
function LogicSeasonCycleMemory.GetCollectionProgress(yearID, matchID)
  local totalCnt = 0
  local hasGetCnt = 0
  if memoryDataRes and memoryDataRes.memorydata and memoryDataRes.memorydata[yearID] and memoryDataRes.memorydata[yearID][matchID] and memoryDataRes.memorydata[yearID][matchID].item then
    local TableUtil = require("common.table_util")
    hasGetCnt = TableUtil.CountTable(memoryDataRes.memorydata[yearID][matchID].item)
  end
  if memoryDataRes and memoryDataRes.conf and memoryDataRes.conf[yearID] and memoryDataRes.conf[yearID][matchID] then
    totalCnt = #memoryDataRes.conf[yearID][matchID]
  end
  return hasGetCnt, totalCnt
end
function LogicSeasonCycleMemory.CheckCollectionComplete(yearID, matchID)
  local hasGetCnt, totalCnt = LogicSeasonCycleMemory.GetCollectionProgress(yearID, matchID)
  if 0 < totalCnt then
    return hasGetCnt == totalCnt
  end
  return false
end
function LogicSeasonCycleMemory.GetStatusByMemoryItemID(yearID, matchID, itemID)
  if memoryDataRes and memoryDataRes.memorydata and memoryDataRes.memorydata[yearID] and memoryDataRes.memorydata[yearID][matchID] and memoryDataRes.memorydata[yearID][matchID][itemID] then
    return memoryDataRes.memorydata[yearID][matchID][itemID].status or 0
  end
  return 0
end
function LogicSeasonCycleMemory.CheckItemHasGotByMemoryItemID(yearID, matchID, itemID)
  if memoryDataRes and memoryDataRes.memorydata and memoryDataRes.memorydata[yearID] and memoryDataRes.memorydata[yearID][matchID] and memoryDataRes.memorydata[yearID][matchID].item and memoryDataRes.memorydata[yearID][matchID].item[itemID] then
    return memoryDataRes.memorydata[yearID][matchID].item[itemID].status ~= nil
  end
  return false
end
function LogicSeasonCycleMemory.CheckGetAwardByMemoryItemID(yearID, matchID, itemID)
  if memoryDataRes and memoryDataRes.memorydata and memoryDataRes.memorydata[yearID] and memoryDataRes.memorydata[yearID][matchID] and memoryDataRes.memorydata[yearID][matchID].item and memoryDataRes.memorydata[yearID][matchID].item[itemID] then
    return memoryDataRes.memorydata[yearID][matchID].item[itemID].status == 1
  end
  return false
end
function LogicSeasonCycleMemory.CheckMemoryTaskOpen(openTimestamp)
  if not openTimestamp or openTimestamp <= 0 then
    log(bWriteLog and "LogicSeasonCycleMemory.CheckMemoryTaskOpen timeStamp is nil or 0")
    return true, 0
  end
  local TimeUtil = require("client.common.time_util")
  local nowTimestamp = TimeUtil.GetServerTimeInSec()
  if openTimestamp <= nowTimestamp then
    return true, 0
  end
  return false, openTimestamp - nowTimestamp
end
function LogicSeasonCycleMemory.GetYearData()
  local yearIdData = {}
  if memoryDataRes and memoryDataRes.conf then
    for k, v in pairs(memoryDataRes.conf) do
      yearIdData[#yearIdData + 1] = k
    end
  end
  table.sort(yearIdData, function(a, b)
    return b < a
  end)
  return yearIdData
end
function LogicSeasonCycleMemory.GetSeasonIdDataByYearID(yearID)
  local matchIdData = {}
  if memoryDataRes and memoryDataRes.conf then
    local curYearData = memoryDataRes.conf[yearID]
    if curYearData then
      for k, v in pairs(curYearData) do
        matchIdData[#matchIdData + 1] = k
      end
    end
  end
  table.sort(matchIdData, function(a, b)
    return b < a
  end)
  return matchIdData
end
function LogicSeasonCycleMemory.GetMemoryItemListConfByYearAndSeason(yearID, matchID)
  if memoryDataRes and memoryDataRes.conf and memoryDataRes.conf[yearID] and memoryDataRes.conf[yearID][matchID] then
    local itemlist = memoryDataRes.conf[yearID][matchID]
    local memoryItemlist = {}
    for i, v in ipairs(itemlist) do
      memoryItemlist[#memoryItemlist + 1] = {
        item_id = v.item_id,
        index = i,
        uniq_id = v.uniq_id
      }
    end
    return memoryItemlist
  end
end
function LogicSeasonCycleMemory.GetCurSeasonMemoryDataStatus()
  local yearID = curSelectYearId or 0
  local seasonID = curSelectSeasonId or 0
  log(bWriteLog and "LogicSeasonCycleMemory.GetCurSeasonMemoryDataStatus yearid is " .. tostring(yearID) .. "season is " .. tostring(seasonID))
  if not (memoryDataRes and memoryDataRes.dataStatus and memoryDataRes.dataStatus[yearID]) or not memoryDataRes.dataStatus[yearID][seasonID] then
    log(bWriteLog and "LogicSeasonCycleMemory.GetCurSeasonMemoryDataStatus data status is invalid")
    return EnumMemoryDataStatus.NORMAL
  end
  local dataStatus = memoryDataRes.dataStatus[yearID][seasonID]
  log(bWriteLog and "LogicSeasonCycleMemory.GetCurSeasonMemoryDataStatus dataStatus is " .. tostring(dataStatus))
  return dataStatus
end
function LogicSeasonCycleMemory.GetTitleAwardStatusByYearAndSeason(yearid, seasonid, progress)
  if not (yearid and seasonid) or not progress then
    log(bWriteLog and "LogicSeasonCycleMemory.GetTitleAwardStatusByYearAndSeason params is invalid")
    return
  end
  local TableUtil = require("common.table_util")
  if seasonid < NewProgressStatusSeasonId then
    return TableUtil.GetTableValue(memoryDataRes, "memorydata", yearid, seasonid, "status")
  end
  return TableUtil.GetTableValue(memoryDataRes, "memorydata", yearid, seasonid, "progress_status", progress)
end
function LogicSeasonCycleMemory.CheckIsMemoryItem(yearID, seasonID, itemId)
  if memoryDataRes and memoryDataRes.conf and memoryDataRes.conf[yearID] and memoryDataRes.conf[yearID][seasonID] then
    local itemlist = memoryDataRes.conf[yearID][seasonID]
    for k, v in ipairs(itemlist) do
      if itemId == v.item_id then
        return true
      end
    end
  end
  return false
end
function LogicSeasonCycleMemory.CheckIsTitleItem(yearID, seasonID, itemId)
  local titleID = LogicSeasonCycleMemory.GetTitleID(yearID, seasonID)
  return itemId == titleID
end
function LogicSeasonCycleMemory.GetTitleID(yearID, seasonID)
  return 0
end
function LogicSeasonCycleMemory.GetTitleRewardList(yearID, seasonID)
  local TableUtil = require("common.table_util")
  local cfg = TableUtil.GetTableValue(memoryDataRes, "titleconf", yearID, seasonID)
  return cfg
end
function LogicSeasonCycleMemory.GetTitleTaskID(yearID, seasonID, progress)
  if memoryDataRes == nil then
    return
  end
  if memoryDataRes.cur_year_id == yearID and memoryDataRes.cur_season_index == seasonID and memoryDataRes.task_cfg and progress then
    local task_cfg = memoryDataRes.task_cfg
    if task_cfg and task_cfg[yearID] and task_cfg[yearID][seasonID] then
      task_cfg = task_cfg[yearID][seasonID]
      for taskid, v in pairs(task_cfg) do
        if v.task_type == EnumTaskType.TitleTask and progress == v.total_progress then
          return taskid
        end
      end
    end
  end
end
function LogicSeasonCycleMemory.CheckHasFinishedProgress(yearid, seasonid, progressNum)
  if not (yearid and seasonid) or not progressNum then
    return false
  end
  local hasGetCnt = LogicSeasonCycleMemory.GetCollectionProgress(yearid, seasonid)
  return progressNum <= hasGetCnt, hasGetCnt
end
function LogicSeasonCycleMemory.CheckHasGetTitleProgressStatus(yearid, seasonid, progressNum)
  if not yearid or not seasonid then
    return false
  end
  local _, totalCnt = LogicSeasonCycleMemory.GetCollectionProgress(yearid, seasonid)
  local progress = progressNum or totalCnt
  local status
  local TableUtil = require("common.table_util")
  if seasonid < NewProgressStatusSeasonId then
    status = TableUtil.GetTableValue(memoryDataRes, "memorydata", yearid, seasonid, "status")
  else
    status = TableUtil.GetTableValue(memoryDataRes, "memorydata", yearid, seasonid, "progress_status", progress)
  end
  return status == 1
end
function LogicSeasonCycleMemory.SetTableValue(tb, key, value, ...)
  local TableUtil = require("common.table_util")
  local tbl = TableUtil.GetTableValue(tb, ...)
  if type(tbl) == "table" then
    tbl[key] = value
  end
end
function LogicSeasonCycleMemory.GetRewardListByMemoryIndex(yearID, seasonID, memoryIdx)
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(memoryDataRes, "conf", yearID, seasonID, memoryIdx)
end
function LogicSeasonCycleMemory.SendGetTitleByYearAndMatch(yearId, seasonId, totalProgress)
  if not (yearId and seasonId) or not totalProgress then
    log(bWriteLog and "LogicSeasonCycleMemory.SendGetTitleByYearAndMatch param is nil")
    return
  end
  if seasonId < NewProgressStatusSeasonId then
    LogicSeasonCycleMemory.send_get_season_year_memory_item_reward_req(yearId, seasonId, 0)
  else
    LogicSeasonCycleMemory.send_get_season_year_memory_progress_reward_req(yearId, seasonId, totalProgress)
  end
end
function LogicSeasonCycleMemory.SyncTitleReward(cur_year_id, cur_season_id)
  local _, totalNum = LogicSeasonCycleMemory.GetCollectionProgress(cur_year_id, cur_season_id)
  if cur_season_id < NewProgressStatusSeasonId then
    LogicSeasonCycleMemory.SetTableValue(memoryDataRes, "status", 1, "memorydata", cur_year_id, cur_season_id)
  else
    LogicSeasonCycleMemory.SetTableValue(memoryDataRes, totalNum, 1, "memorydata", cur_year_id, cur_season_id, "progress_status")
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.CollectOneCycleMemoryRedDot()
end
function LogicSeasonCycleMemory.CheckOpenCycleMemoryData()
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory.CheckOpenCycleMemoryData " .. tostring(next_season_start_time))
  local isOpen = LogicSeasonCycleMemory.isSeasonOpenEntrance or false
  if next_season_start_time then
    local TimeUtil = require("client.common.time_util")
    local curServerTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory.CheckOpenCycleMemoryData curServerTime " .. tostring(curServerTime))
    return isOpen and curServerTime >= next_season_start_time
  end
  return isOpen
end
function LogicSeasonCycleMemory.GetCurYearIndex(yearid)
  local index = 1
  yearid = tonumber(yearid)
  local yearData = LogicSeasonCycleMemory.GetYearData()
  if yearData == nil then
    log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory:GetCurSeasonIndex yearData == nil")
    return index
  end
  for i, v in ipairs(yearData) do
    if v == yearid then
      index = i
      break
    end
  end
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory:GetCurYearIndex" .. " idx " .. tostring(index))
  return index
end
function LogicSeasonCycleMemory.GetCurSeasonIndex(yearid, seasonid)
  yearid = tonumber(yearid)
  seasonid = tonumber(seasonid)
  local seasonData = LogicSeasonCycleMemory.GetSeasonIdDataByYearID(yearid)
  local index = 1
  if seasonData == nil then
    log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory:GetCurSeasonIndex seasonData == nil")
    return index
  end
  for i, v in ipairs(seasonData) do
    if v == seasonid then
      index = i
      break
    end
  end
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory:GetCurSeasonIndex" .. " index " .. tostring(index))
  return index
end
function LogicSeasonCycleMemory.GetCurItemIndex(yearid, seasonid, itemid)
  yearid = tonumber(yearid)
  seasonid = tonumber(seasonid)
  itemid = tonumber(itemid)
  local itemData = LogicSeasonCycleMemory.GetMemoryItemListConfByYearAndSeason(yearid, seasonid)
  local index = 1
  if itemData == nil then
    log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory:GetCurItemIndex itemData == nil")
    return index
  end
  for i, v in ipairs(itemData) do
    if v.item_id == itemid then
      index = i
      break
    end
  end
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory:GetCurItemIndex" .. " index " .. tostring(index))
  return index
end
function LogicSeasonCycleMemory.GetCurCanGetRewardIndex(yearid, seasonid)
  log(bWriteLog and "LogicSeasonCycleMemory.GetCurCanGetRewardIndex")
  yearid = tonumber(yearid)
  seasonid = tonumber(seasonid)
  local itemData = LogicSeasonCycleMemory.GetMemoryItemListConfByYearAndSeason(yearid, seasonid)
  if itemData == nil then
    log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory:GetCurCanGetRewardIndex itemData == nil")
    return
  end
  local index
  for i, v in ipairs(itemData) do
    local bHasGot = LogicSeasonCycleMemory.CheckGetAwardByMemoryItemID(yearid, seasonid, v.item_id)
    local bGet = LogicSeasonCycleMemory.CheckItemHasGotByMemoryItemID(yearid, seasonid, v.item_id)
    if bGet == true and bHasGot == false then
      index = i
      break
    end
  end
  return index
end
function LogicSeasonCycleMemory.PackDataByYearAndSeasonId(todata, packdata, yearId, seasonId)
  if todata == nil then
    todata = {}
  end
  if yearId == nil or seasonId == nil then
    return
  end
  todata[yearId] = todata[yearId] or {}
  todata[yearId][seasonId] = packdata
  return todata
end
function LogicSeasonCycleMemory.ReplaceTaskCfgWithLocalData(taskcfg)
  LogicSeasonCycleMemory.GetCfgTable()
  if taskcfg and type(taskcfg) == "table" then
    for k, v in pairs(taskcfg) do
      v.task_id = k
    end
    for taskid, taskdata in pairs(taskcfg) do
      if cycle_task_cfg_client_data[taskid] then
        taskdata.task_desc = cycle_task_cfg_client_data[taskid].task_desc
        taskdata.task_title = cycle_task_cfg_client_data[taskid].task_title
        taskdata.jump_id = cycle_task_cfg_client_data[taskid].jump_id
      end
    end
  end
  return taskcfg
end
function LogicSeasonCycleMemory.CheckHasData(yearId, seasonId)
  if memoryDataRes and memoryDataRes.task_data[yearId] and memoryDataRes.task_data[yearId][seasonId] and memoryDataRes.conf[yearId] and memoryDataRes.conf[yearId][seasonId] then
    return true
  end
  return false
end
function LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId(todata, memoryTable, yearId, seasonId)
  if memoryTable == nil then
    log_error(bWriteLog and "LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId memoryTable is nil")
    return
  end
  if memoryTable[yearId] == nil or memoryTable[yearId][seasonId] == nil then
    log_error(bWriteLog and "LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId memoryTable's seasonData is nil")
    return
  end
  if todata == nil then
    todata = {}
  end
  if todata[yearId] == nil then
    todata[yearId] = {}
  end
  todata[yearId][seasonId] = memoryTable[yearId][seasonId]
  return todata
end
function LogicSeasonCycleMemory.send_get_season_year_memory_data_req()
  log(bWriteLog and "send_get_season_year_memory_data_req")
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_season_year_memory_data_req()
end
function LogicSeasonCycleMemory.on_get_season_year_memory_data_res(err_code, cur_year_id, cur_season_index, memory_data, conf, title_conf, task_data, task_cfg, start_season_year_id, start_season_id)
  log(bWriteLog and "on_get_season_year_memory_data_res cur_year_id : " .. tostring(cur_year_id) .. " cur_season_index : " .. tostring(cur_season_index))
  if err_code ~= 0 and err_code ~= ErrorCode_Entrance_Closed then
    local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Season_Memory_UIBP)
    if ui and ui:IsShow() then
      ShowNotice(err_code)
    end
  end
  if err_code == 113000000 then
    return
  end
  log_tree("[v_ywuyuan] LogicSeasonCycleMemory.on_get_season_year_memory_data_res", task_cfg)
  log_tree("[v_ywuyuan] LogicSeasonCycleMemory.on_get_season_year_memory_data_res", task_data)
  LogicSeasonCycleMemory.GetCfgTable()
  if memoryDataRes == nil then
    memoryDataRes = {}
  end
  memoryDataRes.cur_year_id = cur_year_id or 0
  memoryDataRes.cur_season_index = cur_season_index or 0
  memoryDataRes.start_season_year_id = start_season_year_id or 0
  memoryDataRes.start_season_id = start_season_id or 0
  if err_code ~= 0 then
    memoryDataRes.memorydata = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.memorydata, {}, cur_year_id, cur_season_index)
    memoryDataRes.conf = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.conf, {}, cur_year_id, cur_season_index)
    memoryDataRes.titleconf = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.titleconf, {}, cur_year_id, cur_season_index)
    memoryDataRes.task_data = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.task_data, {}, cur_year_id, cur_season_index)
    memoryDataRes.dataStatus = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.dataStatus, EnumMemoryDataStatus.UNOPENED, cur_year_id, cur_season_index)
  else
    memoryDataRes.memorydata = LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId(memoryDataRes.memorydata, memory_data, cur_year_id, cur_season_index)
    memoryDataRes.conf = LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId(memoryDataRes.conf, conf, cur_year_id, cur_season_index)
    memoryDataRes.titleconf = LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId(memoryDataRes.titleconf, title_conf, cur_year_id, cur_season_index)
    memoryDataRes.task_data = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.task_data, task_data, cur_year_id, cur_season_index)
    task_cfg = LogicSeasonCycleMemory.ReplaceTaskCfgWithLocalData(task_cfg[cur_year_id][cur_season_index])
    memoryDataRes.task_cfg = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.task_cfg, task_cfg, cur_year_id, cur_season_index)
    memoryDataRes.dataStatus = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.dataStatus, EnumMemoryDataStatus.NORMAL, cur_year_id, cur_season_index)
  end
  LogicSeasonCycleMemory.SetMemoryConfSeasonData()
  local ifOpenUIEntrance = err_code ~= ErrorCode_Entrance_Closed
  LogicSeasonCycleMemory.SetMemoryDataToRedData(memoryDataRes.memorydata, memoryDataRes.conf, cur_year_id, cur_season_index, ifOpenUIEntrance)
  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_MEMORY, EVENTID_SEASON_CYCLE_MEMORY_MAIN_UPDATE)
end
function LogicSeasonCycleMemory.send_get_season_year_memory_item_reward_req(year_id, season_index, item_id)
  log(bWriteLog and "send_get_season_year_memory_item_reward_req year_id : " .. tostring(year_id) .. "season_index: " .. season_index .. " item_id : " .. tostring(item_id))
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_season_year_memory_item_reward_req(year_id, season_index, item_id)
end
function LogicSeasonCycleMemory.on_get_season_year_memory_item_reward_res(cur_year_id, cur_season_id, item_id)
  log(bWriteLog and "on_get_season_year_memory_item_reward_res year_id : " .. tostring(cur_year_id) .. " cur_season_id " .. tostring(cur_season_id) .. " item_id : " .. tostring(item_id))
  local award_list
  if LogicSeasonCycleMemory.CheckIsTitleItem(cur_year_id, cur_season_id, item_id) then
    LogicSeasonCycleMemory.SyncTitleReward(cur_year_id, cur_season_id)
    award_list = LogicSeasonCycleMemory.GetTitleRewardList(cur_year_id, cur_season_id)
  elseif memoryDataRes and memoryDataRes.memorydata then
    memoryDataRes.memorydata[cur_year_id] = memoryDataRes.memorydata[cur_year_id] or {}
    memoryDataRes.memorydata[cur_year_id][cur_season_id] = memoryDataRes.memorydata[cur_year_id][cur_season_id] or {}
    memoryDataRes.memorydata[cur_year_id][cur_season_id].item = memoryDataRes.memorydata[cur_year_id][cur_season_id].item or {}
    local d = memoryDataRes.memorydata[cur_year_id][cur_season_id]
    d.item[item_id] = d.item[item_id] or {}
    d.item[item_id].status = 1
    local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
    season_redpoint_data.CollectOneCycleMemoryRedDot()
    award_list = LogicSeasonCycleMemory.GetMemoryRewardListByItemID(cur_year_id, cur_season_id, item_id)
  end
  if award_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
  end
  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_MEMORY, EVENTID_SEASON_CYCLE_MEMORY_MAIN_UPDATE)
end
function LogicSeasonCycleMemory.send_get_season_year_memory_progress_reward_req(year_id, season_index, progress)
  log(bWriteLog and "send_get_season_year_memory_progress_reward_req year_id : " .. tostring(year_id) .. "season_index: " .. season_index .. " progress : " .. tostring(progress))
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_season_year_memory_progress_reward_req(year_id, season_index, progress)
end
function LogicSeasonCycleMemory.on_get_season_year_memory_progress_reward_rsp(year_id, season_id, progress, award_list)
  if not (year_id and season_id and progress) or not award_list then
    log(bWriteLog and "on_get_season_year_memory_progress_reward_rsp params is nil")
    return
  end
  log_tree("awardlist", award_list)
  log(bWriteLog and "on_get_season_year_memory_progress_reward_rsp year_id : " .. tostring(year_id) .. " season_id " .. tostring(season_id) .. " progress : " .. tostring(progress))
  LogicSeasonCycleMemory.SetTableValue(memoryDataRes, progress, 1, "memorydata", year_id, season_id, "progress_status")
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.CollectOneCycleMemoryRedDot()
  if award_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
  end
  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_MEMORY, EVENTID_SEASON_CYCLE_MEMORY_TAKE_TITLE_PROGRESS_AWARD_RSP, year_id, season_id)
end
function LogicSeasonCycleMemory.on_season_year_memory_event_notify(type, params)
  log(bWriteLog and "on_season_year_memory_event_notify type : " .. tostring(type))
  if type == 1 then
    LogicSeasonCycleMemory.send_get_season_year_memory_data_req()
  elseif type == 2 then
    next_season_start_time = params.next_season_start_time
  elseif type == 3 then
    LogicSeasonCycleMemory.send_get_season_year_memory_data_req()
  elseif type == 6 then
    if params and params == 1 then
      LogicSeasonCycleMemory.isSeasonOpenEntrance = true
      log(bWriteLog and "on_season_year_memory_event_notify open entrance")
    else
      LogicSeasonCycleMemory.isSeasonOpenEntrance = false
      local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
      season_redpoint_data.SetCycleMemoryEntryRedData(false)
      season_redpoint_data.SetCycleMemoryTabRedData(0)
    end
    EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_MEMORY, EVENTID_SEASON_CYCLE_MEMORY_ENTRANCE_STATUS_UPDATE)
  end
end
function LogicSeasonCycleMemory.send_season_year_memory_clear_season_redpoint_req()
  if memoryDataRes == nil then
    log(bWriteLog and "LogicSeasonCycleMemory.send_season_year_memory_clear_season_redpoint_req memoryDataRes is nil")
    return
  end
  if LogicSeasonCycleMemory.CheckNeedShowFirstCycleMemory(memoryDataRes.cur_year_id, memoryDataRes.cur_season_index) then
    local SeasonHandler = require("client.network.Protocol.SeasonHandler")
    log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory.send_season_year_memory_clear_season_redpoint_req")
    SeasonHandler.send_season_year_memory_clear_season_redpoint_req()
    LogicSeasonCycleMemory.SetShowFirstCycleMemory(memoryDataRes.cur_year_id, memoryDataRes.cur_season_index)
  end
end
function LogicSeasonCycleMemory.on_season_year_memory_clear_season_redpoint_rsp()
end
function LogicSeasonCycleMemory.send_get_prev_season_year_memory_data_req(year_id, season_index)
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory.send_get_prev_seaon_year_memory_data_req" .. ":" .. tostring(year_id) .. ":" .. tostring(season_index))
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_prev_season_year_memory_data_req(year_id, season_index)
end
function LogicSeasonCycleMemory.on_get_prev_season_year_memory_data_rsp(err_code, year_id, season_index, task_list, task_cfg, memory_data, memory_item_conf, title_conf)
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory.on_get_prev_seaon_year_memory_data_rsp")
  if year_id == nil or season_index == nil then
    log_error(bWriteLog and "on_get_prev_seaon_year_memory_data_rsp year_id or season_index is nil")
    return
  end
  if memoryDataRes == nil then
    log(bWriteLog and "LogicSeasonCycleMemory.on_season_year_memory_clear_season_redpoint_rsp  no memoryDataRes")
    return
  end
  if err_code ~= 0 then
    memoryDataRes.task_data = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.task_data, {}, year_id, season_index)
    memoryDataRes.conf = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.conf, {}, year_id, season_index)
    memoryDataRes.titleconf = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.titleconf, {}, year_id, season_index)
    memoryDataRes.memorydata = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.memorydata, {}, year_id, season_index)
    if err_code == 113000016 then
      memoryDataRes.dataStatus = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.dataStatus, EnumMemoryDataStatus.NODATA, year_id, season_index)
    else
      memoryDataRes.dataStatus = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.dataStatus, EnumMemoryDataStatus.UNOPENED, year_id, season_index)
    end
    EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_MEMORY, EVENTID_SEASON_CYCLE_MEMORY_MAIN_SEASON_UPDATE, year_id, season_index)
    return
  end
  log_tree("[v_ywuyuan] LogicSeasonCycleMemory.on_get_prev_season_year_memory_data_rsp", task_list)
  log_tree("[v_ywuyuan] LogicSeasonCycleMemory.on_get_prev_season_year_memory_data_rsp", task_cfg)
  task_cfg = LogicSeasonCycleMemory.ReplaceTaskCfgWithLocalData(task_cfg[year_id][season_index])
  memoryDataRes.task_cfg = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.task_cfg, task_cfg, year_id, season_index)
  memoryDataRes.task_data = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.task_data, task_list, year_id, season_index)
  memoryDataRes.memorydata = LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId(memoryDataRes.memorydata, memory_data, year_id, season_index)
  memoryDataRes.conf = LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId(memoryDataRes.conf, memory_item_conf, year_id, season_index)
  memoryDataRes.titleconf = LogicSeasonCycleMemory.SetMemoryTableByYearAndSeasonId(memoryDataRes.titleconf, title_conf, year_id, season_index)
  memoryDataRes.dataStatus = LogicSeasonCycleMemory.PackDataByYearAndSeasonId(memoryDataRes.dataStatus, EnumMemoryDataStatus.NORMAL, year_id, season_index)
  EventSystem:postEvent(EVENTTYPE_SEASON_CYCLE_MEMORY, EVENTID_SEASON_CYCLE_MEMORY_MAIN_SEASON_UPDATE, year_id, season_index)
end
function LogicSeasonCycleMemory.ShowCycleMemoryUI(_, _, params)
  log(bWriteLog and "[v_ywuyuan] LogicSeasonCycleMemory.ShowCycleMemoryUI")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_Memory_UIBP, params)
end
function LogicSeasonCycleMemory.ClearData()
  memoryDataRes = nil
end
function LogicSeasonCycleMemory.GetCfgTable()
  if cycle_cfg_client_data == nil then
    cycle_cfg_client_data = LogicSeasonCycleMemory.ReadCfgTable()
  end
  if cycle_task_cfg_client_data == nil then
    cycle_task_cfg_client_data = LogicSeasonCycleMemory.ReadTaskCfgTable()
  end
end
function LogicSeasonCycleMemory.ClearCfgTable()
  cycle_cfg_client_data = nil
  cycle_task_cfg_client_data = nil
end
function LogicSeasonCycleMemory.ReadCfgTable()
  local cfg = CDataTable.GetTable("CycleMemoryCfg")
  if cfg == nil then
    return
  end
  local keyTbl = {
    "ItemId",
    "ItemName",
    "ItemType",
    "ItemDesc",
    "EffectLink",
    "SoundLength",
    "LockedDescText",
    "LockedDescImage"
  }
  local readTbl = {}
  for _, v in pairs(cfg) do
    local yearId = v.SeasonYearID
    local matchId = v.SeasonMatchID
    local uniqId = v.ID
    readTbl[yearId] = readTbl[yearId] or {}
    readTbl[yearId][matchId] = readTbl[yearId][matchId] or {}
    readTbl[yearId][matchId][uniqId] = readTbl[yearId][matchId][uniqId] or {}
    local tmp = readTbl[yearId][matchId][uniqId]
    for i, k in ipairs(keyTbl) do
      tmp[k] = v[k]
    end
    readTbl[yearId][matchId][uniqId] = tmp
  end
  return readTbl
end
function LogicSeasonCycleMemory.ReadTaskCfgTable()
  local cfg = CDataTable.GetTable("CycleMemoryTaskCfg")
  if cfg == nil then
    return
  end
  local readTbl = {}
  for _, v in pairs(cfg) do
    local taskId = v.TaskID
    readTbl[taskId] = {
      task_title = v.TaskTitle,
      task_desc = v.TaskDesc,
      jump_id = v.JumpID
    }
  end
  return readTbl
end
function LogicSeasonCycleMemory.GetCfgByMemoryUniqID(yearID, seasonID, uniqID)
  if uniqID == nil or yearID == nil or seasonID == nil then
    log(bWriteLog and "LogicSeasonCycleMemory.GetCfgByMemoryUniqID param is invalid")
    return nil
  end
  LogicSeasonCycleMemory.GetCfgTable()
  if cycle_cfg_client_data and cycle_cfg_client_data[yearID] and cycle_cfg_client_data[yearID][seasonID] and cycle_cfg_client_data[yearID][seasonID][uniqID] then
    return cycle_cfg_client_data[yearID][seasonID][uniqID]
  end
end
function LogicSeasonCycleMemory.SetMemoryConfSeasonData()
  if memoryDataRes == nil or memoryDataRes.cur_year_id == nil or memoryDataRes.cur_season_index == nil then
    log(bWriteLog and "LogicSeasonCycleMemory.SetMemoryConfSeasonData CurData is nil")
    return
  end
  if memoryDataRes.start_season_year_id == nil or memoryDataRes.start_season_id == nil then
    log(bWriteLog and "LogicSeasonCycleMemory.SetMemoryConfSeasonData StartData is nil")
    return
  end
  LogicSeasonCycleMemory.GetCfgTable()
  if cycle_cfg_client_data == nil then
    log(bWriteLog and "LogicSeasonCycleMemory.SetMemoryConfSeasonData cycle_cfg_client_data is nil")
    return
  end
  local curYear = memoryDataRes.cur_year_id
  local curSeason = memoryDataRes.cur_season_index
  local startYearId = memoryDataRes.start_season_year_id
  local startSeasonId = memoryDataRes.start_season_id
  for yearid, yearData in pairs(cycle_cfg_client_data) do
    if yearid <= curYear and yearid >= startYearId then
      if memoryDataRes.conf[yearid] == nil then
        memoryDataRes.conf[yearid] = {}
      end
      for seasonid, _ in pairs(yearData) do
        if seasonid <= curSeason and seasonid >= startSeasonId and memoryDataRes.conf[yearid][seasonid] == nil then
          memoryDataRes.conf[yearid][seasonid] = {}
        end
      end
    end
  end
end
local getPlayedKey = function(itemid)
  return itemid + 1000000
end
function LogicSeasonCycleMemory.SetMemoryDataToRedData(memoryData, memoryConf, yearid, seasonid, ifOpenUIEntrance)
  if memoryData == nil or memoryConf == nil or memoryData[yearid] == nil or memoryData[yearid][seasonid] == nil then
    log_error(bWriteLog and "LogicSeasonCycleMemory.SetMemoryDataToRedData data is nil")
    return
  end
  local redpointCount = 0
  local memoryItemCount = 0
  local curSeasonMemoryData = memoryData[yearid][seasonid]
  if type(curSeasonMemoryData) ~= "table" then
    log_error(bWriteLog and "LogicSeasonCycleMemory.SetMemoryDataToRedData data is not table")
    return
  end
  for itemid, itemData in pairs(curSeasonMemoryData.item or {}) do
    memoryItemCount = memoryItemCount + 1
    if itemData and itemData.status == 0 then
      redpointCount = redpointCount + 1
    end
    local itemUniqid = LogicSeasonCycleMemory.GetMemoryUniqIdByItemID(yearid, seasonid, itemid)
    local itemCfg = LogicSeasonCycleMemory.GetCfgByMemoryUniqID(yearid, seasonid, itemUniqid)
    if itemCfg and (itemCfg.ItemType == EnumMemoryItemType.Video or itemCfg.ItemType == EnumMemoryItemType.Voice) and not LogicSeasonCycleMemory.checkMemoryClientData(yearid, seasonid, itemid, "played") then
      redpointCount = redpointCount + 1
    end
  end
  if seasonid < NewProgressStatusSeasonId then
    if curSeasonMemoryData.status == 0 and memoryConf[yearid] and memoryConf[yearid][seasonid] and type(memoryConf[yearid][seasonid]) == "table" then
      local totalCount = #memoryConf[yearid][seasonid]
      if totalCount == memoryItemCount then
        redpointCount = redpointCount + 1
      end
    end
  elseif type(curSeasonMemoryData.progress_status) == "table" and next(curSeasonMemoryData.progress_status) then
    for stageNum, stageStatus in pairs(curSeasonMemoryData.progress_status) do
      if stageStatus == 0 and stageNum <= memoryItemCount then
        redpointCount = redpointCount + 1
      end
    end
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  if ifOpenUIEntrance and LogicSeasonCycleMemory.CheckNeedShowFirstCycleMemory(yearid, seasonid) then
    season_redpoint_data.SetCycleMemoryEntryRedData(true)
  else
    season_redpoint_data.SetCycleMemoryEntryRedData(false)
  end
  season_redpoint_data.SetCycleMemoryTabRedData(redpointCount)
end
local getMemoryKey = function(yearId, seasonId, itemId, key)
  return string.format("%d-%d-%d-%s", yearId, seasonId, itemId, key)
end
function LogicSeasonCycleMemory.checkMemoryClientData(yearId, seasonId, itemId, keyname)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CycleMemoryReward) or {}
  local key = getMemoryKey(yearId, seasonId, itemId, keyname)
  return cfg[key]
end
local storeMemoryClientData = function(yearId, seasonId, itemId, keyname)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local key = getMemoryKey(yearId, seasonId, itemId, keyname)
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CycleMemoryReward) or {}
  cfg[key] = true
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.CycleMemoryReward)
end
function LogicSeasonCycleMemory.SetVoiceOrVideoPlayed(yearId, seasonId, itemId, uniqId)
  if not (yearId and seasonId) or not itemId then
    log(bWriteLog and "LogicSeasonCycleMemory.SetVoiceOrVideoPlayed params is invalid")
    return
  end
  if not LogicSeasonCycleMemory.CheckVoiceOrVideoNotPlayed(yearId, seasonId, itemId, uniqId) then
    log(bWriteLog and "LogicSeasonCycleMemory.SetVoiceOrVideoPlayed item has played")
    return
  end
  storeMemoryClientData(yearId, seasonId, itemId, "played")
  if seasonId == DataMgr.season_id then
    local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
    season_redpoint_data.CollectOneCycleMemoryRedDot()
  end
end
function LogicSeasonCycleMemory.CheckVoiceOrVideoNotPlayed(yearId, seasonId, itemId, uniqId)
  local cfg = LogicSeasonCycleMemory.GetCfgByMemoryUniqID(yearId, seasonId, uniqId)
  if cfg and (cfg.ItemType == EnumMemoryItemType.Video or cfg.ItemType == EnumMemoryItemType.Voice) then
    return not LogicSeasonCycleMemory.checkMemoryClientData(yearId, seasonId, itemId, "played")
  end
  return false
end
local getFirstMemoryKey = function(yearId, seasonId)
  return string.format("%d-%d", yearId, seasonId)
end
function LogicSeasonCycleMemory.CheckNeedShowFirstCycleMemory(yearId, seasonId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CycleFirstMemoryReward) or {}
  local key = getFirstMemoryKey(yearId, seasonId)
  return cfg[key] == nil
end
function LogicSeasonCycleMemory.SetShowFirstCycleMemory(yearId, seasonId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CycleFirstMemoryReward) or {}
  local key = getFirstMemoryKey(yearId, seasonId)
  cfg[key] = true
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.CycleFirstMemoryReward)
  season_redpoint_data.SetCycleMemoryEntryRedData(false)
end
function LogicSeasonCycleMemory.CheckVoiceReady()
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {voicePakId})
  return dowloadState == PufferConst.ENUM_DownloadState.Done
end
function LogicSeasonCycleMemory.StartDownloadVoice()
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {voicePakId})
  if state == PufferConst.ENUM_DownloadState.Not then
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {voicePakId})
  end
end
function LogicSeasonCycleMemory.GetVoicePakId()
  return voicePakId
end
function LogicSeasonCycleMemory.IsOutOfDate()
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  if version_util.CompareVersionFull(ClientVersion, "1.8.0") then
    if curSelectYearId == memoryDataRes.cur_year_id and curSelectSeasonId == memoryDataRes.cur_season_index then
      return false
    end
    return true
  end
  return false
end
function LogicSeasonCycleMemory.IsModeOpen(selectSeasonid)
  if selectSeasonid ~= DataMgr.season_id then
    log(bWriteLog and "LogicSeasonCycleMemory IsModeOpen not in current season")
    return true
  end
  if LogicSeasonCycleMemory.curSeasonModeOpencfg == nil then
    log_error(bWriteLog and "LogicSeasonCycleMemory IsModeOpen ModeOpencfg is nil")
    return false
  end
  local beginTimestamp = LogicSeasonCycleMemory.curSeasonModeOpencfg.mode_start_ts
  if beginTimestamp == nil then
    log_error(bWriteLog and "LogicSeasonCycleMemory IsModeOpen timestamp is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if beginTimestamp > curTime then
    log(bWriteLog and "LogicSeasonCycleMemory IsModeOpen is not open")
    return false
  end
  log(bWriteLog and "LogicSeasonCycleMemory IsModeOpen open")
  return true
end
function LogicSeasonCycleMemory.IsModeOpenNewSelection(viewid)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewid)
  if not viewInfo then
    log(bWriteLog and "LogicSeasonCycleMemory IsModeOpenNewSelection viewInfo is nil")
    return true
  end
  local openLimits = viewInfo.open_limits
  if not viewInfo.open_limits then
    log(bWriteLog and "LogicSeasonCycleMemory IsModeOpenNewSelection limit is nil")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(openLimits) do
    local startTime = v.begin_timestamp
    if curTime >= startTime then
      log(bWriteLog and "LogicSeasonCycleMemory IsModeOpenNewSelection open")
      return true
    end
  end
  log(bWriteLog and "LogicSeasonCycleMemory IsModeOpenNewSelection not open")
  return false
end
function LogicSeasonCycleMemory.IsModeOpenOldSelection(viewid)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local _, startTime = MatchModeMgrSystem.GetViewOpenTime(viewid)
  if not startTime then
    log(bWriteLog and "LogicSeasonCycleMemory IsModeOpen startTime is nil")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if startTime <= curTime then
    log(bWriteLog and "LogicSeasonCycleMemory IsModeOpen open")
    return true
  end
  log(bWriteLog and "LogicSeasonCycleMemory IsModeOpen not open")
  return false
end
return LogicSeasonCycleMemory