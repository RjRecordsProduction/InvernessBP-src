local config_arena = require("client.slua.logic.arena.config_arena")
local SeasonState = config_arena.SeasonState
local ArenaSystem = {
  recordData = nil,
  awardData = nil,
  rankData = nil,
  seasonID = nil
}
local _segmentData
function ArenaSystem.SendGetArenaSeasonPrizeReq()
  local ArenaHandler = require("client.network.Protocol.ArenaHandler")
  ArenaHandler.send_get_arena_season_prize_req()
end
function ArenaSystem.OnGetArenaSeasonPrizeRsp(taskData)
  if not taskData or not next(taskData) then
    log(bWriteLog and "ArenaSystem.OnGetArenaSeasonPrizeRsp is nil")
    return
  end
  log(bWriteLog and "ArenaSystem.OnGetArenaSeasonPrizeRsp taskData.season_id = " .. tostring(taskData.season_id))
  ArenaSystem.awardData = taskData.task_list
  EventSystem:postEvent(EVENTTYPE_ARENA, EVENTID_ARENA_GET_AWARD_RSP)
end
function ArenaSystem.SendGetArenaSeasonRecordReq(zone_id)
  local ArenaHandler = require("client.network.Protocol.ArenaHandler")
  ArenaHandler.send_get_arena_season_record_req(zone_id)
end
function ArenaSystem.OnGetArenaSeasonRecordRsp(recordData)
  ArenaSystem.UpdateSeasonID(recordData and recordData.vs_team and recordData.vs_team.season_id)
  ArenaSystem.UpdateRecord(recordData and recordData.vs_team)
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  RankDataMgr.SetSelfRankInfo(nil, recordData and recordData.vs_team and recordData.vs_team.rank_rating or 0)
  ArenaSystem.UpdateSegment(ArenaSystem.recordData and ArenaSystem.recordData.rank_rating)
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF)
  EventSystem:postEvent(EVENTTYPE_ARENA, EVENTID_ARENA_GET_SEASON_RECORD_ARENA_RSP)
end
function ArenaSystem.SendReceiveArenaSeasonPrizeReq(task_id)
  local ArenaHandler = require("client.network.Protocol.ArenaHandler")
  ArenaHandler.send_receive_arena_season_prize_req(task_id)
end
function ArenaSystem.OnReceiveArenaSeasonPrizeRsp(awardData, taskData)
  if not awardData then
    return
  end
  if 0 < #awardData then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(awardData)
  end
  ArenaSystem.OnGetArenaSeasonPrizeRsp(taskData)
end
function ArenaSystem.OnGetOneUserRankRsp(client_data, ok, zoneId, rank_info)
  log(bWriteLog and "[edward][logic_arena] ArenaSystem.OnGetOneUserRankRsp, client_data = " .. client_data)
  log(bWriteLog and "[edward][logic_arena] ArenaSystem.OnGetOneUserRankRsp, ok = " .. ok)
  log_tree(bWriteLog and "[edward][logic_arena] ArenaSystem.OnGetOneUserRankRsp, rank_info = ", rank_info)
  if not string.find(client_data, "arena") then
    return
  end
  if ok ~= 0 then
    log_error("[edward][logic_arena] ArenaSystem.OnGetOneUserRankRsp error, error code = " .. ok)
    return
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rank_util = require("client.slua.logic.rank.rank_util")
  local originScore = ArenaSystem.GetSegmentData().score
  if not rank_info or not next(rank_info) then
    RankDataMgr.SetSelfRankInfo(0, originScore)
    RankDataMgr.SetSelfBelow1wDisplay("")
  else
    RankDataMgr.SetSelfRankInfo(rank_info.rank_no or 0, originScore)
    if not rank_info.top1w then
      if rank_info.rank_no and 0 < rank_info.rank_no then
        RankDataMgr.SetSelfBelow1wDisplay(rank_info.rank_no)
      end
    else
      local segmentData = DataMgr.roleData.arena_rating_and_segment[zoneId].vs_team
      local Score = segmentData and segmentData.rank_rating or 0
      local rankStr = rank_util.calc_topn_percentage(Score, rank_info.top1w, "arena", rank_info.rank_no)
      RankDataMgr.SetSelfBelow1wDisplay(rankStr)
    end
  end
  ArenaSystem.rankData = {nZoneID = zoneId, rankInfo = rank_info}
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF)
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_ARENA_GET_RANK_RSP)
end
function ArenaSystem.UpdateRecord(vs_team)
  log_tree("ArenaSystem.UpdateRecord", vs_team)
  if not vs_team then
    return
  end
  ArenaSystem.recordData = vs_team
  local showSeason = ArenaSystem.GetShowSeason(true)
  local isNextSeason = showSeason > vs_team.season_id
  log(bWriteLog and "ArenaSystem.UpdateRecord isNextSeason = " .. tostring(isNextSeason))
  if isNextSeason then
    local TableUtil = require("common.table_util")
    ArenaSystem.recordServerData = TableUtil.CopyTable(vs_team)
    ArenaSystem.recordData.dead_num = 0
    ArenaSystem.recordData.game_num = 0
    ArenaSystem.recordData.head_shot_num = 0
    ArenaSystem.recordData.kill_num = 0
    ArenaSystem.recordData.win_num = 0
    ArenaSystem.recordData.season_id = showSeason
  end
end
function ArenaSystem.UpdateSegment(score)
  log(bWriteLog and "ArenaSystem.UpdateSegment, score = " .. tostring(score))
  local currentScore = score or ArenaSystem.recordData and ArenaSystem.recordData.rank_rating
  local currentConfig = config_arena.GetCurrentSegmentWithCurrentScore(currentScore)
  if not currentConfig then
    log_warning(bWriteLog and "ArenaSystem.UpdateSegment config is nil")
    return
  end
  local isNextSeason = ArenaSystem.GetShowSeason(true) > ArenaSystem.GetSeasonID()
  if isNextSeason then
    currentConfig = config_arena.GetCurrentSegmentWithCurrentScore(currentConfig.SegmentBackScore)
    currentScore = currentConfig.SegmentMinScore
    if ArenaSystem.recordData then
      ArenaSystem.recordData.rank_rating = currentScore
    end
  end
  local seData = ArenaSystem.GetSegmentData()
  seData.config = currentConfig
  seData.score = currentScore
  _segmentData = seData
end
function ArenaSystem.GetSeasonID()
  return ArenaSystem.seasonID or DataMgr.roleData.arena_season_id
end
function ArenaSystem.UpdateSeasonID(id)
  ArenaSystem.seasonID = id or ArenaSystem.GetSeasonID()
end
function ArenaSystem.GetSegmentData()
  if not _segmentData then
    local defaultConfig = CDataTable.GetTableData("ArenaSegmentConfig", config_arena.DefaultSegmentID)
    _segmentData = {
      config = defaultConfig,
      score = defaultConfig.SegmentMinScore
    }
  end
  return _segmentData
end
function ArenaSystem.ShowArenaUI()
  if not ArenaSystem.IsInTargetSeasonShow() then
    ShowNotice(9896)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.arena_main)
end
function ArenaSystem.HaveAwardToGet()
  local TimeUtil = require("client.common.time_util")
  if not ArenaSystem.awardData then
    return false
  end
  local currentSeason = ArenaSystem.GetSeasonID()
  local ArenaConfig = CDataTable.GetTableData("ArenaConfig", currentSeason)
  if ArenaConfig then
    local startTime = tonumber(TimeUtil.TimeStringToUnixstamp(ArenaConfig.StartTime))
    local endTime = tonumber(TimeUtil.TimeStringToUnixstamp(ArenaConfig.EndTime))
    local nNow = TimeUtil.GetServerTimeInSec()
    if startTime > nNow or endTime < nNow then
      return false
    end
  end
  local E_  for k, v in pairs(ArenaSystem.awardData) do
    if v.status == E_ActivityProgressStatus.Done then
      return true
    end
  end
  return false
end
function ArenaSystem.IsInArenaSeason()
  log(bWriteLog and "ArenaSystem.IsInArenaSeason")
  local TimeUtil = require("client.common.time_util")
  local currentSeason = ArenaSystem.GetSeasonID()
  local ArenaConfig = CDataTable.GetTableData("ArenaConfig", currentSeason)
  if ArenaConfig then
    local startTime = tonumber(TimeUtil.TimeStringToUnixstamp(ArenaConfig.StartTime))
    local endTime = tonumber(TimeUtil.TimeStringToUnixstamp(ArenaConfig.EndTime))
    local nNow = TimeUtil.GetServerTimeInSec()
    if startTime <= nNow and endTime >= nNow then
      return true
    end
  end
  return false
end
function ArenaSystem.GetAwardData(nSeasonID, needTitle)
  local result = {}
  if needTitle then
    local titleInfo1 = {
      nID = 0,
      sDesc = LocUtil.GetLocalizeResStr(9129)
    }
    table.insert(result, titleInfo1)
  end
  local list = {}
  local ArenaAwardConfig = CDataTable.GetTable("ArenaAwardConfig")
  for _, v in pairs(ArenaAwardConfig) do
    if v.SeasonID == nSeasonID then
      local item = {
        nID = v.TaskID,
        nSort = v.Sort,
        sDesc = v.Condition1,
        nIconID = v.ShowAward1,
        nState = 0,
        nCount = v.ShowCount1
      }
      if GlobalData.IsJapanOrKorea() then
        item.nIconID = v.JKShowAward1
      end
      table.insert(list, item)
    end
  end
  if 1 < #list then
    table.sort(list, function(a, b)
      return a.nSort < b.nSort
    end)
  end
  for _, v in ipairs(list) do
    table.insert(result, v)
  end
  if needTitle then
    local titleInfo2 = {
      nID = 0,
      sDesc = LocUtil.GetLocalizeResStr(9130)
    }
    table.insert(result, titleInfo2)
  end
  list = {}
  local ArenaSeasonAwardConfig = CDataTable.GetTable("ArenaSeasonAwardConfig")
  for _, v in pairs(ArenaSeasonAwardConfig) do
    if v.SeasonID == nSeasonID then
      local item = {
        nID = v.TaskID + 10000,
        sDesc = v.Condition,
        nIconID = v.ShowAward,
        nState = -1,
        nCount = v.ShowCount
      }
      table.insert(result, item)
    end
  end
  if 1 < #list then
    table.sort(list, function(a, b)
      return a.nID < b.nID
    end)
  end
  for _, v in ipairs(list) do
    table.insert(result, v)
  end
  return result
end
local _GetShowTime = function(showTime)
  local StringUtil = require("common.string_util")
  local TimeUtil = require("client.common.time_util")
  local showTimeArr = StringUtil.Split(showTime, "-")
  showTimeArr[1] = StringUtil.StrReplace(showTimeArr[1], "/", "-", 2)
  showTimeArr[2] = StringUtil.StrReplace(showTimeArr[2], "/", "-", 2)
  local startTime = TimeUtil.TimeStringToUnixstamp(showTimeArr[1] .. config_arena.ShowStartHMS)
  local endTime = TimeUtil.TimeStringToUnixstamp(showTimeArr[2] .. config_arena.ShowEndHMS)
  return startTime, endTime
end
function ArenaSystem.GetShowSeason(getID)
  local ArenaAwardConfig = CDataTable.GetTable("ArenaConfig")
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(ArenaAwardConfig) do
    local startTime, endTime = _GetShowTime(v.ShowTime)
    if nowTime >= startTime and nowTime <= endTime then
      return getID and v.SeasonID or v
    end
  end
  if getID then
    return 0
  end
  return nil
end
function ArenaSystem.IsInTargetSeasonShow(seasonID, getState)
  local seasonConfig
  if seasonID then
    seasonConfig = CDataTable.GetTableData("ArenaConfig", seasonID)
  else
    seasonConfig = ArenaSystem.GetShowSeason()
  end
  if not seasonConfig then
    log_warning(bWriteLog and "ArenaSystem.IsInTargetSeasonShow seasonID = " .. tostring(seasonID) .. " seasonConfig is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local showStartTime, showEndTime = _GetShowTime(seasonConfig.ShowTime)
  showStartTime = math.floor(showStartTime)
  showEndTime = math.floor(showEndTime)
  local realStartTime = TimeUtil.TimeStringToUnixstamp(seasonConfig.StartTime)
  realStartTime = math.floor(realStartTime)
  local realEndTime = TimeUtil.TimeStringToUnixstamp(seasonConfig.EndTime)
  realEndTime = math.floor(realEndTime)
  log(bWriteLog and "ArenaSystem.IsInTargetSeasonShow nowTime = " .. nowTime)
  log(bWriteLog and "ArenaSystem.IsInTargetSeasonShow showStartTime = " .. showStartTime)
  log(bWriteLog and "ArenaSystem.IsInTargetSeasonShow showEndTime = " .. showEndTime)
  log(bWriteLog and "ArenaSystem.IsInTargetSeasonShow realStartTime = " .. realStartTime)
  log(bWriteLog and "ArenaSystem.IsInTargetSeasonShow realEndTime = " .. realEndTime)
  local isIn = false
  local state
  if nowTime >= showStartTime and nowTime < realStartTime then
    state = SeasonState.NotStart
    isIn = true
  elseif nowTime >= realStartTime and nowTime < realEndTime then
    state = SeasonState.InProgress
    isIn = true
  elseif nowTime >= realEndTime and nowTime <= showEndTime then
    state = SeasonState.End
    isIn = true
  end
  if getState then
    return state
  end
  return isIn
end
function ArenaSystem.MapCustomGetSizeFunc(downloadType, mapKeyList, bSkipDepend)
  log(bWriteLog and "LogicPeakGame:MapCustomGetSizeFunc downloadType" .. downloadType)
  log_tree("LogicPeakGame:MapCustomGetSizeFunc mapKeyList = ", mapKeyList)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if not ArenaSystem.MapBaseSize then
    local _, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {"map_desert"})
    ArenaSystem.MapBaseSize = totalSize
    log(bWriteLog and "LogicPeakGame:MapCustomGetSizeFunc self.MapBaseSize" .. totalSize)
  end
  local downloadSize, totalSize = PufferManager.GetSize(downloadType, mapKeyList, bSkipDepend)
  if downloadSize >= ArenaSystem.MapBaseSize then
    downloadSize = downloadSize - ArenaSystem.MapBaseSize
    totalSize = totalSize - ArenaSystem.MapBaseSize
  end
  return downloadSize, totalSize
end
return ArenaSystem