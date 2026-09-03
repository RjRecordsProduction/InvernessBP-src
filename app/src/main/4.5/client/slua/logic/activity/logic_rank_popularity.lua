local logic_rank_popularity = {
  activityData = nil,
  selfRankData = nil,
  rankAreaID = nil,
  rankDataList = nil,
  config = {
    ActivityID = ActivityFixedID.RANK_POPULARITY,
    ReqNumPerPage = 10,
    MaxRewardRank = 100,
    ScoreType = 9501
  },
  downloadIndex = nil
}
function logic_rank_popularity.InitActData()
  log(bWriteLog and "[logic_rank_popularity] InitActData")
  if not logic_rank_popularity.activityData or not next(logic_rank_popularity.activityData) then
    logic_rank_popularity.GetActivitySubData()
  end
  if not logic_rank_popularity.rankDataList then
    logic_rank_popularity.GetRankListReq()
  end
  if not logic_rank_popularity.selfRankData then
    logic_rank_popularity.GetSelfRankReq()
  end
end
function logic_rank_popularity.ReqRankData()
  log(bWriteLog and "[logic_rank_popularity] ReqRankData")
  logic_rank_popularity.GetRankListReq()
  logic_rank_popularity.GetSelfRankReq()
end
function logic_rank_popularity.ClearData()
  log(bWriteLog and "[logic_rank_popularity] ClearData")
  logic_rank_popularity.activityData = nil
  logic_rank_popularity.selfRankData = nil
  logic_rank_popularity.rankDataList = nil
  logic_rank_popularity.rankAreaID = nil
end
function logic_rank_popularity.GetActivitySubData()
  log(bWriteLog and "[logic_rank_popularity] GetActivitySubData")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activity = ActivityNewSystem.GetActivityByID(logic_rank_popularity.config.ActivityID)
  if not activity then
    log(bWriteLog and "[logic_rank_popularity] nil activityData")
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if activity.ID == logic_rank_popularity.config.ActivityID and activity.StartTime and now > activity.StartTime and activity.EndTime and now < activity.EndTime then
    local data = {
      nActID = logic_rank_popularity.config.ActivityID,
      sName = LocUtil.GetLocalizeResStr(44202),
      sBgUrl = "",
      nStartTime = activity.StartTime,
      nSwitchType = 1,
      DisplayScene = activity.DisplayScene
    }
    logic_rank_popularity.activityData = activity
    return data
  end
  return nil
end
function logic_rank_popularity.GetRankListReq()
  log(bWriteLog and "[logic_rank_popularity] GetRankListReq")
  local regionGroupID = 1
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig then
    regionGroupID = regionGroupConfig.PopularityGroupID
  end
  log(bWriteLog and "[logic_rank_popularity] logic_rank_popularity.GetRankList, regionGroupID = " .. regionGroupID)
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_gift_activity_rank_req(regionGroupID, logic_rank_popularity.config.ScoreType)
end
function logic_rank_popularity.GetRankListRsp(area_id, score_type, rank_list)
  log(bWriteLog and "[logic_rank_popularity] logic_rank_popularity.GetRankListRsp, area_id = " .. area_id .. " with score_type: " .. tostring(score_type))
  if score_type ~= logic_rank_popularity.config.ScoreType then
    log(bWriteLog and "[logic_rank_popularity] score type not match")
    return
  end
  logic_rank_popularity.rankAreaID = area_id
  logic_rank_popularity.rankDataList = rank_list
  logic_rank_popularity.ProcessRewardData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_POPULARITY_LIST_UPDATE)
  local reqProfileUIDList = {}
  for i = 1, logic_rank_popularity.config.ReqNumPerPage do
    if rank_list[i] and not rank_list[i].req then
      table.insert(reqProfileUIDList, rank_list[i].uid)
      logic_rank_popularity.rankDataList[i].req = true
    end
  end
  logic_rank_popularity.GetRankProfileList(reqProfileUIDList)
end
function logic_rank_popularity.GetRankProfileList(reqProfileUIDList)
  log(bWriteLog and "[logic_rank_popularity] GetRankProfileList")
  if not reqProfileUIDList or #reqProfileUIDList <= 0 then
    log(bWriteLog and "[logic_rank_popularity] invalid reqProfileUIDList")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(reqProfileUIDList, logic_rank_popularity.GetRankListProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_POP_LIST)
end
function logic_rank_popularity.ProcessRewardData()
  log(bWriteLog and "[logic_rank_popularity] ProcessRewardData")
  if not logic_rank_popularity.rankAreaID or not logic_rank_popularity.rankDataList then
    log(bWriteLog and "[logic_rank_popularity] invalid rank info")
    return
  end
  local TopNextRankRewardTable = CDataTable.GetTable("TopNextRankRewardTable")
  if not TopNextRankRewardTable then
    log(bWriteLog and "[logic_rank_popularity] invalid TopNextRankRewardTable")
    return
  end
  local RewardCfg = {}
  for _, v in pairs(TopNextRankRewardTable) do
    if v.RankType == logic_rank_popularity.rankAreaID and v.TemplateType == logic_rank_popularity.config.ScoreType then
      table.insert(RewardCfg, v)
    end
  end
  for rank, rank_data in ipairs(logic_rank_popularity.rankDataList) do
    rank_data.    rank_data.rewardList = {}
    for _, CfgItem in ipairs(RewardCfg) do
      if rank >= CfgItem.RankCeilling and rank <= CfgItem.RankFloor then
        local drops1 = {
          itemId = CfgItem.RewardItemID1,
          count = CfgItem.RewardItemCnt1,
          expireTime = CfgItem.RewardItemLimitTime1
        }
        rank_data.rewardList[1] = drops1
        if CfgItem.RewardItemID2 > 0 then
          local drops2 = {
            itemId = CfgItem.RewardItemID2,
            count = CfgItem.RewardItemCnt2,
            expireTime = CfgItem.RewardItemLimitTime2
          }
          rank_data.rewardList[2] = drops2
        end
        if 0 < CfgItem.RewardItemID3 then
          local drops3 = {
            itemId = CfgItem.RewardItemID3,
            count = CfgItem.RewardItemCnt3,
            expireTime = CfgItem.RewardItemLimitTime3
          }
          rank_data.rewardList[3] = drops3
        end
      end
    end
  end
end
function logic_rank_popularity.GetRankListProfileRsp(profileList)
  log(bWriteLog and "[logic_rank_popularity] GetRankListProfileRsp")
  if not profileList or not next(profileList) then
    log(bWriteLog and "[logic_rank_popularity] invalid profileList")
    return
  end
  if not logic_rank_popularity.rankDataList then
    log(bWriteLog and "[logic_rank_popularity] invalid rankDataList")
    return
  end
  local profileMap = {}
  for _, profile_data in ipairs(profileList) do
    profileMap[tonumber(profile_data.uid)] = profile_data
  end
  local match_rank_map = {}
  for index, rank_data in pairs(logic_rank_popularity.rankDataList) do
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
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_POPULARITY_PROFILE_UPDATE, match_rank_map)
end
function logic_rank_popularity.GetSelfRankReq()
  log(bWriteLog and "[logic_rank_popularity] GetSelfRankReq")
  local regionGroupID = 1
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig then
    regionGroupID = regionGroupConfig.PopularityGroupID
  end
  log(bWriteLog and "[logic_rank_popularity] logic_rank_popularity.GetSelfRankReq, regionGroupID = " .. regionGroupID)
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_personal_gift_activity_rank_req(regionGroupID, logic_rank_popularity.config.ScoreType)
end
function logic_rank_popularity.GetSelfRankRsp(area_id, score_type, selfRankData)
  log(bWriteLog and "[logic_rank_popularity] GetSelfRankRsp: " .. tostring(area_id) .. " with score_type: " .. tostring(score_type))
  if score_type ~= logic_rank_popularity.config.ScoreType then
    log(bWriteLog and "[logic_rank_popularity] score type not match")
    return
  end
  logic_rank_popularity.rankAreaID = area_id
  logic_rank_popularity.  logic_rank_popularity.ProcessSelfRewardData()
  logic_rank_popularity.selfRankData.uid = DataMgr.roleData.uid
  logic_rank_popularity.selfRankData.name = DataMgr.roleData.nickName
  logic_rank_popularity.selfRankData.total_popularity = DataMgr.roleData.total_devote or -1
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_POPULARITY_SELF_UPDATE)
end
function logic_rank_popularity.ProcessSelfRewardData()
  log(bWriteLog and "[logic_rank_popularity] ProcessSelfRewardData")
  if not logic_rank_popularity.rankAreaID or not logic_rank_popularity.selfRankData then
    log(bWriteLog and "[logic_rank_popularity] invalid self data")
    return
  end
  if tonumber(logic_rank_popularity.selfRankData.rank) > tonumber(logic_rank_popularity.config.MaxRewardRank) then
    log(bWriteLog and "[logic_rank_popularity] out of MaxRewardRank: " .. tostring(logic_rank_popularity.selfRankData.rank))
    return
  end
  local TopNextRankRewardTable = CDataTable.GetTable("TopNextRankRewardTable")
  if not TopNextRankRewardTable then
    log(bWriteLog and "[logic_rank_popularity] invalid TopNextRankRewardTable")
    return
  end
  local RewardCfg = {}
  for _, v in pairs(TopNextRankRewardTable) do
    if v.RankType == logic_rank_popularity.rankAreaID and v.TemplateType == logic_rank_popularity.config.ScoreType then
      table.insert(RewardCfg, v)
    end
  end
  logic_rank_popularity.selfRankData.rewardList = {}
  local selfRank = logic_rank_popularity.selfRankData.rank
  for _, CfgItem in ipairs(RewardCfg) do
    if selfRank >= CfgItem.RankCeilling and selfRank <= CfgItem.RankFloor then
      local drops1 = {
        itemId = CfgItem.RewardItemID1,
        count = CfgItem.RewardItemCnt1,
        expireTime = CfgItem.RewardItemLimitTime1
      }
      logic_rank_popularity.selfRankData.rewardList[1] = drops1
      if CfgItem.RewardItemID2 > 0 then
        local drops2 = {
          itemId = CfgItem.RewardItemID2,
          count = CfgItem.RewardItemCnt2,
          expireTime = CfgItem.RewardItemLimitTime2
        }
        logic_rank_popularity.selfRankData.rewardList[2] = drops2
      end
      if 0 < CfgItem.RewardItemID3 then
        local drops3 = {
          itemId = CfgItem.RewardItemID3,
          count = CfgItem.RewardItemCnt3,
          expireTime = CfgItem.RewardItemLimitTime3
        }
        logic_rank_popularity.selfRankData.rewardList[3] = drops3
      end
    end
  end
end
function logic_rank_popularity.LoadBgImage(successCallback)
  log(bWriteLog and "[logic_rank_popularity] LoadBgImage")
  if not logic_rank_popularity.activityData then
    log(bWriteLog and "[logic_rank_popularity] invalid activity data")
    return
  end
  local BgImageUrl = logic_rank_popularity.activityData.ImgUrl
  if not BgImageUrl or BgImageUrl == "" then
    log(bWriteLog and "[logic_rank_popularity] invalid image url")
    return
  end
  local util = require("client.slua_ui_framework.util")
  BgImageUrl = util.GetUrlByLanguage(BgImageUrl)
  if not util.IsOnlineImageUrl(BgImageUrl) then
    log(bWriteLog and "[logic_rank_popularity] not online image url")
    return
  end
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  if logic_rank_popularity.downloadIndex and logic_rank_popularity.downloadIndex > 0 then
    image_download_mgr:CancelDownloadByIndex(logic_rank_popularity.downloadIndex)
    logic_rank_popularity.downloadIndex = nil
  end
  local downloadIndex = image_download_mgr:DownloadImageByHttpWrapper(BgImageUrl, function(texture, imgUrl)
    log(bWriteLog and "[logic_rank_popularity] download bg image success: " .. tostring(BgImageUrl))
    if successCallback then
      successCallback(texture)
    end
  end, function()
    log(bWriteLog and "[logic_rank_popularity] download bg image failed: " .. tostring(BgImageUrl))
  end)
  if downloadIndex and 0 < downloadIndex then
    logic_rank_popularity.  end
end
return logic_rank_popularity