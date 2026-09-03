local rank_util = require("client.slua.logic.rank.rank_util")
local logic_rank_creativity = {
  activityData = nil,
  tRankRewardCfg = nil,
  selfRankData = nil,
  rankAreaID = nil,
  rankDataList = nil,
  config = {
    ActivityID = ActivityFixedID.CREATIVE_MAIN,
    ReqNumPerPage = 10,
    MaxRewardRank = 100,
    ScoreType = 72038
  },
  downloadIndex = nil
}
function logic_rank_creativity.InitActData()
  log(bWriteLog and "[logic_rank_creativity] InitActData")
  if not logic_rank_creativity.activityData or not next(logic_rank_creativity.activityData) then
    logic_rank_creativity.GetActivitySubData()
  end
  if not logic_rank_creativity.rankDataList then
    logic_rank_creativity.GetRankListReq()
  end
  if not logic_rank_creativity.selfRankData then
    logic_rank_creativity.GetSelfRankReq()
  end
  logic_rank_creativity.InitRankRewardCfg()
end
function logic_rank_creativity.ReqRankData()
  log(bWriteLog and "[logic_rank_creativity] ReqRankData")
  logic_rank_creativity.GetRankListReq()
  logic_rank_creativity.GetSelfRankReq()
end
function logic_rank_creativity.ClearData()
  log(bWriteLog and "[logic_rank_creativity] ClearData")
  logic_rank_creativity.activityData = nil
  logic_rank_creativity.selfRankData = nil
  logic_rank_creativity.rankDataList = nil
  logic_rank_creativity.rankAreaID = nil
end
function logic_rank_creativity.GetActivitySubData()
  log(bWriteLog and "[logic_rank_creativity] GetActivitySubData")
  local activity = logic_rank_creativity.GetActivityBYPoint()
  if not activity then
    log(bWriteLog and "[logic_rank_creativity] nil activityData")
    return nil
  end
  local data = {
    nActID = activity.ID,
    sName = LocUtil.GetLocalizeResStr(68767),
    sBgUrl = "",
    reqID = activity.BackupParam1,
    nStartTime = activity.StartTime,
    nEndTime = activity.EndTime,
    nSwitchType = 10,
    DisplayScene = activity.DisplayScene
  }
  logic_rank_creativity.activityData = activity
  if activity.BackupParam1 then
    logic_rank_creativity.config.ScoreType = tonumber(activity.BackupParam1)
  end
  return data
end
function logic_rank_creativity.GetActivityBYPoint()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local TimeUtil = require("client.common.time_util")
  local activity
  local now = TimeUtil.GetServerTimeInSec()
  local activityList = ActivityNewSystem.GetActivityListByType(13)
  if not next(activityList) then
    log(bWriteLog and "[logic_rank_creativity] GetActivityBYPoint activityList nil ")
    return nil
  end
  for k, v in pairs(activityList) do
    if v.RedPointSwitcher == 17 then
      if v.StartTime and now > v.StartTime and v.EndTime and now < v.EndTime then
        activity = v
        log(bWriteLog and "[logic_rank_creativity] GetActivityBYPoint RedPointSwitcher curractivity = " .. tostring(v.ID))
      else
        log(bWriteLog and "[logic_rank_creativity] GetActivityBYPoint RedPointSwitcher == 17 but timeout " .. tostring(v.ID))
      end
    end
  end
  return activity
end
function logic_rank_creativity.GetRankListReq()
  log(bWriteLog and "[logic_rank_creativity] GetRankListReq")
  local regionGroupID = 1
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig then
    regionGroupID = regionGroupConfig.PopularityGroupID
  end
  log(bWriteLog and "[logic_rank_creativity] GetRankListReq regionGroupID: " .. tostring(regionGroupID))
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(0, logic_rank_creativity.config.ScoreType, 1)
end
function logic_rank_creativity.GetRankListRsp(ok, zone_id, score_type, list, page, extra_data)
  if score_type ~= logic_rank_creativity.config.ScoreType then
    return
  end
  logic_rank_creativity.rankAreaID = zone_id
  logic_rank_creativity.rankDataList = list
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_CREATIVITY_LIST_UPDATE)
  local reqProfileUIDList = {}
  for i = 1, logic_rank_creativity.config.ReqNumPerPage do
    if list[i] and not list[i].req then
      table.insert(reqProfileUIDList, list[i].uid)
      logic_rank_creativity.rankDataList[i].req = true
    end
  end
  logic_rank_creativity.GetRankProfileList(reqProfileUIDList)
end
function logic_rank_creativity.InitRankRewardCfg()
  if logic_rank_creativity.tRankRewardCfg then
    return
  end
  local tAllRankRewardData = {}
  local uObj_rankRewardCfg = rank_util.GetRankRewardCfg(logic_rank_creativity.config.ScoreType, false) or {}
  for _, v in pairs(uObj_rankRewardCfg) do
    local tRankData = {
      rank_max = v.RankFloor,
      rank_min = v.RankCeilling
    }
    for i = 1, 4 do
      if v["RewardItemID" .. i] and v["RewardItemID" .. i] > 0 then
        local tRewardData = {
          ["item_id_" .. i] = v["RewardItemID" .. i],
          ["item_num_" .. i] = v["RewardItemCnt" .. i],
          ["item_valid_hour_" .. i] = v["RewardItemTimeLimit" .. i]
        }
        table.insert(tRankData, tRewardData)
      end
    end
    table.insert(tAllRankRewardData, tRankData)
  end
  logic_rank_creativity.tRankRewardCfg = tAllRankRewardData
end
function logic_rank_creativity.GetRankRewardCfg()
  if not logic_rank_creativity.tRankRewardCfg then
    logic_rank_creativity.InitRankRewardCfg()
  end
  return logic_rank_creativity.tRankRewardCfg
end
function logic_rank_creativity.GetRankProfileList(reqProfileUIDList)
  log(bWriteLog and "[logic_rank_creativity] GetRankProfileList")
  if not reqProfileUIDList or #reqProfileUIDList <= 0 then
    log(bWriteLog and "[logic_rank_creativity] invalid reqProfileUIDList")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(reqProfileUIDList, logic_rank_creativity.GetRankListProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_POP_LIST, nil, true)
end
function logic_rank_creativity.GetRankListProfileRsp(profileList)
  log(bWriteLog and "[logic_rank_creativity] GetRankListProfileRsp")
  if not profileList or not next(profileList) then
    log(bWriteLog and "[logic_rank_creativity] invalid profileList")
    return
  end
  if not logic_rank_creativity.rankDataList then
    log(bWriteLog and "[logic_rank_creativity] invalid rankDataList")
    return
  end
  local profileMap = {}
  for _, profile_data in ipairs(profileList) do
    profileMap[tonumber(profile_data.uid)] = profile_data
  end
  local match_rank_map = {}
  for index, rank_data in pairs(logic_rank_creativity.rankDataList) do
    if tonumber(rank_data.uid) == tonumber(DataMgr.roleData.uid) then
      rank_data.name = DataMgr.roleData.nickName
      if DataMgr.roleData.pround_info then
        rank_data.pround_level = DataMgr.roleData.pround_info.level or 0
      else
        log(bWriteLog and "[logic_rank_creativity] invalid self pround_info: " .. tostring(DataMgr.roleData.uid))
      end
      match_rank_map[index] = rank_data
    else
      local profile_data = profileMap[tonumber(rank_data.uid)]
      if profile_data then
        rank_data.name = profile_data.nickName
        if profile_data.pround_info then
          rank_data.pround_level = profile_data.pround_info.level or 0
        else
          log(bWriteLog and "[logic_rank_creativity] invalid pround_info: " .. tostring(rank_data.uid))
        end
        rank_data.light_board_info = profile_data.light_board_info
        match_rank_map[index] = rank_data
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_CREATIVITY_PROFILE_UPDATE, match_rank_map)
end
function logic_rank_creativity.GetSelfRankReq()
  log(bWriteLog and "[logic_rank_creativity] GetSelfRankReq")
  local regionGroupID = 1
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig then
    regionGroupID = regionGroupConfig.PopularityGroupID
  end
  log(bWriteLog and "[logic_rank_creativity] GetSelfRankReq regionGroupID: " .. tostring(regionGroupID))
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank("rank", 0, tonumber(DataMgr.roleData.uid), logic_rank_creativity.config.ScoreType)
end
function logic_rank_creativity.GetSelfRankRsp(client_data, ok, zoneId, rank_info, extra_data)
  log(bWriteLog and "[logic_rank_creativity] GetSelfRankRsp: ")
  if not client_data or client_data ~= "rank" then
    log(bWriteLog and "[logic_rank_creativity] GetSelfRankRsp:client_data ~= rank ")
    return
  end
  if not rank_info then
    log(bWriteLog and "[logic_rank_creativity] invalid rank_info")
    return
  end
  if rank_info.score_type and rank_info.score_type ~= logic_rank_creativity.config.ScoreType then
    log(bWriteLog and "[logic_rank_creativity] score type not match")
    return
  end
  logic_rank_creativity.rankAreaID = zoneId
  logic_rank_creativity.selfRankData = rank_info
  logic_rank_creativity.selfRankData.name = DataMgr.roleData.nickName
  logic_rank_creativity.selfRankData.uid = DataMgr.roleData.uid
  if DataMgr.roleData.pround_info then
    logic_rank_creativity.selfRankData.pround_level = DataMgr.roleData.pround_info.level or 0
  else
    log(bWriteLog and "[logic_rank_creativity] invalid self pround_info: " .. tostring(DataMgr.roleData.uid))
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_CREATIVITY_SELF_UPDATE)
end
function logic_rank_creativity:_LoadTableCfgs()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.TableCfgs = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTableCfg)
  self.TableCfgs = self.TableCfgs or {}
end
return logic_rank_creativity