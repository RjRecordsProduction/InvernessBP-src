local rank_util = require("client.slua.logic.rank.rank_util")
local logic_rank_collection = {}
local CONST = {
  score_type = 73003,
  client_data = "CollectionPersonRank",
  activityID = ActivityFixedID.RANK_COLLECTION,
  reqPerPageNum = 10,
  maxRewardRank = 1000,
  reqPerPageRankNum = 100,
  maxReqInterval = 120
}
function logic_rank_collection:DefineAndResetData()
  self.activityData = nil
  self.selfRankData = nil
  self.rankAreaID = nil
  self.rankDataList = nil
end
function logic_rank_collection:OnLogOut()
  self:ClearData()
end
function logic_rank_collection:InitActData()
  if not self.activityData or not next(self.activityData) then
    self:GetActivitySubData()
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  if not self.rankDataList then
    RankHandler.send_get_topn_rank(0, CONST.score_type, 1)
  end
  if not self.selfRankData then
    RankHandler.send_get_one_user_rank(CONST.client_data, 0, tonumber(DataMgr.roleData.uid), CONST.score_type)
  end
end
function logic_rank_collection:ReqRankData()
  self:GetRankListReq()
  self:GetSelfRankReq()
end
function logic_rank_collection:GetActivitySubData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activity = ActivityNewSystem.GetActivityByID(CONST.activityID)
  if not activity then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if activity.StartTime and now > activity.StartTime and activity.EndTime and now < activity.EndTime then
    local data = {
      nActID = CONST.activityID,
      sName = LocUtil.GetLocalizeResStr(65003),
      bRedDot = false,
      sBgUrl = "",
      nStartTime = activity.StartTime,
      nSwitchType = 1,
      DisplayScene = activity.DisplayScene
    }
    self.activityData = activity
    return data
  end
  return nil
end
function logic_rank_collection:IsCharmValueRank(score_type)
  return score_type == CONST.score_type
end
function logic_rank_collection:ClearData()
  self.activityData = nil
  self.selfRankData = nil
  self.rankDataList = nil
  self.rankAreaID = nil
end
function logic_rank_collection:GetRankListReq(page)
  page = page or 1
  local pageIndex = (page - 1) * CONST.reqPerPageRankNum + 1
  local RankHandler = require("client.network.Protocol.RankHandler")
  if page == 1 then
    log(bWriteLog and "[YY]send_get_topn_rank====page==" .. tostring(page))
    RankHandler.send_get_topn_rank(0, CONST.score_type, page)
  else
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    if not self.rankDataList or not self.rankDataList[pageIndex] then
      log(bWriteLog and "[YY]send_get_topn_rank====page==" .. tostring(page))
      RankHandler.send_get_topn_rank(0, CONST.score_type, page)
    elseif self.rankDataList and self.rankDataList[pageIndex] and self.rankDataList[pageIndex].timeStamp and nowTime - self.rankDataList[pageIndex].timeStamp >= CONST.maxReqInterval then
      log(bWriteLog and "[YY]send_get_topn_rank====page==" .. tostring(page))
      RankHandler.send_get_topn_rank(0, CONST.score_type, page)
    end
  end
end
function logic_rank_collection:GetRankListRsp(res, list, page)
  if res ~= 0 then
    return
  end
  local pageIndex = (page - 1) * CONST.reqPerPageRankNum
  log(bWriteLog and "[YY]logic_rank_collection==GetRankListRsp===page" .. tostring(page))
  log_tree("logic_rank_collection==GetRankListRsp===list", list)
  for i, v in pairs(list) do
    if not self.rankDataList then
      self.rankDataList = {}
    end
    self.rankDataList[i + pageIndex] = v
  end
  self:ProcessRewardData(pageIndex)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_COLLECTION_LIST_UPDATE)
  local reqProfileUIDList = {}
  for i = 1, CONST.reqPerPageNum do
    if list[i] and not list[i].req then
      table.insert(reqProfileUIDList, list[i].uid)
      self.rankDataList[i + pageIndex].req = true
    end
  end
  self:GetRankProfileList(reqProfileUIDList)
end
function logic_rank_collection:GetRankProfileList(uidList)
  log_tree("uidList", uidList)
  if not uidList or #uidList <= 0 then
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, function(profileList)
    self:GetRankListProfileRsp(profileList)
  end, Enum_PROFILE_REPORT_CFG.CHARM_VALUE_RANK)
end
function logic_rank_collection:ProcessRewardData(pageIndex)
  if not self.rankDataList then
    log(bWriteLog and "[YY]ProcessRewardData==logic_rank_collection==" .. tostring(111111111))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local MaxNum = #self.rankDataList
  for i = 1 + pageIndex, MaxNum do
    self.rankDataList[i].rank = i
    self.rankDataList[i].rewardList = {}
    self.rankDataList[i].level = 0
    self.rankDataList[i].timeStamp = nowTime
    if tonumber(self.rankDataList[i].uid) == tonumber(DataMgr.roleData.uid) then
      self.rankDataList[i].name = DataMgr.roleData.nickName
    end
    self:InsertRankRewardData(i, self.rankDataList[i])
  end
end
function logic_rank_collection:GetRankListProfileRsp(profileList)
  if not profileList or not next(profileList) then
    log(bWriteLog and "[YY]GetRankListProfileRsp=====" .. tostring(111111111))
    return
  end
  if not self.rankDataList then
    log(bWriteLog and "[YY]GetRankListProfileRsp=====" .. tostring(2222222222))
    return
  end
  local profileMap = {}
  for _, profile_data in ipairs(profileList) do
    profileMap[tonumber(profile_data.uid)] = profile_data
  end
  local match_rank_map = {}
  for index, rank_data in pairs(self.rankDataList) do
    if tonumber(rank_data.uid) == tonumber(DataMgr.roleData.uid) then
      rank_data.name = DataMgr.roleData.nickName
      rank_data.total_popularity = DataMgr.roleData.total_devote or -1
      match_rank_map[index] = rank_data
    else
      local profile_data = profileMap[tonumber(rank_data.uid)]
      if profile_data then
        rank_data.name = profile_data.nickName
        rank_data.total_popularity = profile_data.total_devote or -1
        rank_data.light_board_info = profile_data.light_board_info
        match_rank_map[index] = rank_data
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_COLLECTION_PROFILE_UPDATE, match_rank_map)
end
function logic_rank_collection:GetSelfRankReq()
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank(CONST.client_data, 0, tonumber(DataMgr.roleData.uid), CONST.score_type)
end
function logic_rank_collection:GetSelfRankRsp(client_data, ok, rank_info)
  if client_data ~= "CollectionPersonRank" then
    return
  end
  log(bWriteLog and "[YY]GetSelfRankRsp====logic_rank_collection======" .. tostring(11111111111))
  if ok ~= 0 then
    return
  end
  log(bWriteLog and "[YY]GetSelfRankRsp====logic_rank_collection======" .. tostring(2222222222))
  log_tree("[YY]GetSelfRankRsp====logic_rank_collection======", rank_info)
  if rank_info and next(rank_info) then
    self.selfRankData = {
      rank = rank_info.rank_no or -1,
      rank_no = rank_info.rank_no or -1,
      uid = rank_info.uid or DataMgr.roleData.uid,
      score = rank_info.score or 0,
      name = DataMgr.roleData.nickName
    }
  else
    self.selfRankData = {
      rank = -1,
      rank_no = -1,
      uid = DataMgr.roleData.uid,
      score = 0,
      name = DataMgr.roleData.nickName
    }
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local data = ActivityNewSystem.GetActivityByID(CONST.activityID)
  if self.selfRankData.score == 0 then
    local new_score = data and data.other and data.other.new_score or 0
    local his_score = data and data.other and data.other.his_score or 0
    self.selfRankData.score = new_score + his_score
  end
  self.selfRankData.join_flag = data and data.other and data.other.join_flag
  self:ProcessSelfRewardData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_COLLECTION_SELF_UPDATE)
end
function logic_rank_collection:ProcessSelfRewardData()
  if not self.selfRankData then
    return
  end
  self.selfRankData.level = 0
  local myRank = tonumber(self.selfRankData.rank) or -1
  if myRank > CONST.maxRewardRank or myRank < 0 then
    return
  end
  self.selfRankData.rewardList = {}
  self:InsertRankRewardData(myRank, self.selfRankData)
end
function logic_rank_collection:InsertRankRewardData(nRankNum, tRankData)
  if not nRankNum or not tRankData then
    return
  end
  local uObj_cfg = rank_util.GetRankRewardCfg(CONST.score_type, true) or {}
  for _, v in pairs(uObj_cfg) do
    if nRankNum >= v.RankCeilling and nRankNum <= v.RankFloor then
      tRankData.level = 4 - v.RewardSegment
      for k = 1, 4 do
        if v["RewardItemID" .. k] > 0 then
          local tItemData = {
            itemId = v["RewardItemID" .. k],
            count = v["RewardItemCnt" .. k],
            expireTime = v["RewardItemTimeLimit" .. k]
          }
          tRankData.rewardList[k] = tItemData
        end
      end
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_rank_collection = class(CModuleBase, nil, logic_rank_collection)
return Clogic_rank_collection