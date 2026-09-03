local logic_home_collection_rank = {}
function logic_home_collection_rank:DefineAndResetData()
  self.rankDataList = {}
end
function logic_home_collection_rank:JumpCheck(ctorData)
  return true
end
function logic_home_collection_rank:CloseModule()
end
function logic_home_collection_rank:GetDataForJumpBack()
  return {
    uiData = {},
    ctorData = {}
  }
end
function logic_home_collection_rank:JumpBack(uiData)
end
function logic_home_collection_rank:OnClearJump(ctorData, uiData)
end
function logic_home_collection_rank:GetPreLoadUIConfig()
  return nil
end
local ENUM_LEVEL_AWARD_STATUS = {
  LOCK = 0,
  UNLOCK = 1,
  RECEIVED = 2
}
function logic_home_collection_rank:GetMyScore()
  if self.myRankInfo and self.myRankInfo.score then
    return self.myRankInfo.score
  end
  return self.score or 0
end
function logic_home_collection_rank:GetMyScoreDirectly()
  return self.score or 0
end
function logic_home_collection_rank:GetMyRankData()
  return self.myRankInfo
end
function logic_home_collection_rank:GetRankData()
  return self.rankDataList
end
function logic_home_collection_rank:GetCurKey()
  if not self.curKey then
    local RankRewardTable = CDataTable.GetTable("HomeRankRewardTable")
    local maxPeriod = 0
    local key = 0
    self.currentTime = {}
    for k, v in pairs(RankRewardTable) do
      if maxPeriod < v.Period then
        maxPeriod = v.Period
        key = v.Key
      end
    end
    self.curPeriod = maxPeriod
    self.curKey = key
  end
  return self.curKey
end
function logic_home_collection_rank:GetActivityExpired()
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local key = self:GetCurKey()
  local targetData = CDataTable.GetTableData("HomeRankRewardTable", key)
  local timeStr = targetData.ActEndTime
  local timestamp = TimeUtil.TimeStringToUnixstamp(timeStr, false)
  return serverTime > timestamp
end
function logic_home_collection_rank:GetProsperityRewardStatu(period, segment, targetProsperity)
  local self_score = self:GetMyScore()
  if targetProsperity <= self_score then
    local statu = self.rewardStatus and self.rewardStatus[period] and self.rewardStatus[period][segment] or 0
    if statu == 0 then
      return ENUM_LEVEL_AWARD_STATUS.UNLOCK
    else
      return ENUM_LEVEL_AWARD_STATUS.RECEIVED
    end
  else
    return ENUM_LEVEL_AWARD_STATUS.LOCK
  end
end
function logic_home_collection_rank:GetCurrentRewardInfo(rank)
  local rankRewardDataList = {}
  if not rank then
    return rankRewardDataList
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local rankID = RankConfig.ScoreType.planph_style_score
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local RankRewardTable = CDataTable.GetTableByFilter("RankRewardTable", "RankType", rankID)
  for k, v in pairs(RankRewardTable) do
    if rank >= v.RankCeilling and rank <= v.RankFloor then
      local limitTime1 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemTimeLimit1)
      local limitTime2 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemTimeLimit2)
      local limitTime3 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType3, v.RewardItemTimeLimit3)
      rankRewardDataList = {
        RewardItemID1 = v.RewardItemID1,
        RewardItemCnt1 = v.RewardItemCnt1,
        RewardItemLimitTime1 = limitTime1,
        RewardItemID2 = v.RewardItemID2,
        RewardItemCnt2 = v.RewardItemCnt2,
        RewardItemLimitTime2 = limitTime2,
        RewardItemID3 = v.RewardItemID3,
        RewardItemCnt3 = v.RewardItemCnt3,
        RewardItemLimitTime3 = limitTime3
      }
      break
    end
  end
  return rankRewardDataList
end
function logic_home_collection_rank:GetProsperityRewardInfo()
  local isMatchAppID = function(appIDStr)
    local appID = Client.GetITopGameId()
    local StringUtil = require("common.string_util")
    local appIDList = StringUtil.Split(appIDStr, ";")
    for k, v in pairs(appIDList) do
      if appID == v then
        return true
      end
    end
    return false
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local curPeriod = self:GetCurPeriod()
  local isExpired = self:GetActivityExpired()
  local RankRewardTable = CDataTable.GetTableByFilter("HomeRankRewardTable", "Period", curPeriod)
  self.prosperityRewardDataList = {}
  for k, v in pairs(RankRewardTable) do
    if isMatchAppID(v.AppID) then
      local rewardData = {
        period = v.Period,
        prosperity = v.Prosperity,
        rewardSegment = v.RewardSegment,
        rewardStatu = self:GetProsperityRewardStatu(v.Period, v.RewardSegment, v.Prosperity),
        RewardItemID1 = v.RewardItemID1,
        RewardItemCnt1 = v.RewardItemCnt1,
        RewardItemID2 = v.RewardItemID2,
        RewardItemCnt2 = v.RewardItemCnt2,
        RewardItemID3 = v.RewardItemID3,
        RewardItemCnt3 = v.RewardItemCnt3
      }
      if isExpired then
        rewardData.rewardStatu = ENUM_LEVEL_AWARD_STATUS.LOCK
      end
      table.insert(self.prosperityRewardDataList, rewardData)
    end
  end
  log_tree("logic_home_collection_rank:GetProsperityRewardInfo prosperityRewardDataList = ", self.prosperityRewardDataList)
  log_tree("logic_home_collection_rank:GetProsperityRewardInfo rewardStatus = ", self.rewardStatus)
  return self.prosperityRewardDataList
end
function logic_home_collection_rank:GetCurPeriod()
  if self.curPeriod then
    return self.curPeriod
  end
  local RankRewardTable = CDataTable.GetTable("HomeRankRewardTable")
  local maxPeriod = 0
  local key = 0
  self.currentTime = {}
  for k, v in pairs(RankRewardTable) do
    if maxPeriod < v.Period then
      maxPeriod = v.Period
      key = v.Key
    end
  end
  self.curPeriod = maxPeriod
  self.curKey = key
  return self.curPeriod
end
function logic_home_collection_rank:send_get_one_user_rank()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local rankID = RankConfig.ScoreType.planph_style_score
  local RankHandler = require("client.network.Protocol.RankHandler")
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local uid = tonumber(DataMgr.roleData.uid)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(tonumber(DataMgr.roleData.uid))
  if homeProfile and homeProfile.joint_id then
    uid = homeProfile.joint_id
  end
  RankHandler.send_get_one_user_rank("homeCollectionRank", 0, uid, rankID)
end
function logic_home_collection_rank:on_get_one_user_rank_rsp(rank_source, res, rank_info)
  if rank_source ~= "homeCollectionRank" then
    log(bWriteLog and "logic_home_collection_rank:on_get_one_user_rank_rsp rank_source = " .. tostring(rank_source))
    return
  end
  if res ~= 0 then
    log(bWriteLog and "logic_home_collection_rank:on_get_one_user_rank_rsp res = " .. tostring(res))
    ShowNotice(511029)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_MY_RANK_RSP)
    return
  end
  log_tree("logic_home_collection_rank:on_get_one_user_rank_rsp rank_info", rank_info)
  self.myRankInfo = rank_info
  if rank_info.ext_data and type(rank_info.ext_data) == "string" then
    self.myRankInfo.ext_data = slua.LuaArchiverDecode(LuaStateWrapper, rank_info.ext_data) or {}
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_MY_RANK_RSP)
end
function logic_home_collection_rank:send_get_style_score_rank_act_score_req()
  local PHomeCollectionRankHandler = require("client.network.Protocol.PHomeCollectionRankHandler")
  PHomeCollectionRankHandler.send_get_style_score_rank_act_score_req()
end
function logic_home_collection_rank:on_get_style_score_rank_act_score_rsp(score)
  self.  if self.rewardStatus then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_RANK_STATUS_UPDATE)
  end
end
function logic_home_collection_rank:send_get_topn_rank()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local rankID = RankConfig.ScoreType.planph_style_score
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(0, rankID, 1, {
    reqFromType = RankConfig.ReqFromType.homeCollectionRank
  })
end
function logic_home_collection_rank:proc_get_topn_rank_rsp(res, rankID, rank_data_list)
  log(bWriteLog and string.format("logic_home_collection_rank:proc_get_topn_rank_rsp, res:%s", res))
  log(bWriteLog and string.format("logic_home_collection_rank:proc_get_topn_rank_rsp, rankID:%s", rankID))
  log_tree(bWriteLog and "logic_home_collection_rank:proc_get_topn_rank_rsp rank_data_list", rank_data_list)
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_RANK_RSP)
    ShowNotice(511029)
    return
  end
  self.rankDataList = rank_data_list
  local uids = {}
  for _, rankData in ipairs(rank_data_list) do
    table.insert(uids, rankData.uid)
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_RANK_RSP)
end
function logic_home_collection_rank:send_get_style_score_rank_data_req()
  if self.rewardStatus then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_RANK_STATUS_UPDATE)
    return
  end
  local PHomeCollectionRankHandler = require("client.network.Protocol.PHomeCollectionRankHandler")
  PHomeCollectionRankHandler.send_get_style_score_rank_data_req()
end
function logic_home_collection_rank:on_get_style_score_rank_data_rsp(status)
  self.rewardStatus = status
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_RANK_STATUS_UPDATE)
end
function logic_home_collection_rank:send_get_style_score_rank_award_req(seg_id)
  local PHomeCollectionRankHandler = require("client.network.Protocol.PHomeCollectionRankHandler")
  PHomeCollectionRankHandler.send_get_style_score_rank_award_req(seg_id)
end
function logic_home_collection_rank:on_get_style_score_rank_award_rsp(seg_id)
  local rewardList = self:GetProsperityRewardInfo()
  local rewardInfo = rewardList[seg_id]
  if not rewardInfo then
    log(bWriteLog and string.format("logic_home_collection_rank:on_get_style_score_rank_award_rsp, wrong seg_id:%s", seg_id))
    return
  end
  local list = {}
  for i = 1, 3 do
    local itemID = rewardInfo["RewardItemID" .. i]
    if itemID ~= 0 then
      local data = {
        res_id = rewardInfo["RewardItemID" .. i],
        count = rewardInfo["RewardItemCnt" .. i]
      }
      table.insert(list, data)
    end
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(list)
  local curPeriod = self:GetCurPeriod()
  log(bWriteLog and string.format("logic_home_collection_rank:on_get_style_score_rank_award_rsp, curPeriod:%s", curPeriod))
  if not self.rewardStatus[curPeriod] then
    self.rewardStatus[curPeriod] = {}
  end
  self.rewardStatus[curPeriod][seg_id] = 1
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_COLLECTION_RANK_STATUS_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.JumpModuleBase")
local Clogic_home_collection_rank = class(CModuleBase, nil, logic_home_collection_rank)
return Clogic_home_collection_rank