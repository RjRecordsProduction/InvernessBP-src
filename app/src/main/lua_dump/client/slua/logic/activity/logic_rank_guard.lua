local logic_rank_guard = {
  activityData = nil,
  selfRankData = nil,
  rankAreaID = nil,
  rankDataList = nil,
  config = {
    ActivityID = ActivityFixedID.GUARD_MAIN,
    ReqNumPerPage = 10,
    MaxRewardRank = 100,
    ScoreType = 9503
  },
  downloadIndex = nil
}
function logic_rank_guard.InitActData()
  log(bWriteLog and "[logic_rank_guard] InitActData")
  if not logic_rank_guard.activityData or not next(logic_rank_guard.activityData) then
    logic_rank_guard.GetActivitySubData()
  end
  if not logic_rank_guard.rankDataList then
    logic_rank_guard.GetRankListReq()
  end
  if not logic_rank_guard.selfRankData then
    logic_rank_guard.GetSelfRankReq()
  end
end
function logic_rank_guard.ReqRankData()
  log(bWriteLog and "[logic_rank_pround] ReqRankData")
  logic_rank_guard.GetRankListReq()
  logic_rank_guard.GetSelfRankReq()
end
function logic_rank_guard.ClearData()
  log(bWriteLog and "[logic_rank_guard] ClearData")
  logic_rank_guard.activityData = nil
  logic_rank_guard.selfRankData = nil
  logic_rank_guard.rankDataList = nil
  logic_rank_guard.rankAreaID = nil
end
function logic_rank_guard.GetActivitySubData()
  log(bWriteLog and "[logic_rank_guard] GetActivitySubData")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if not ActivityNewSystem then
    log(bWriteLog and "[logic_rank_guard] nil ActivityNewSystem")
    return nil
  end
  local activity = ActivityNewSystem.GetActivityByID(logic_rank_guard.config.ActivityID)
  if not activity then
    log(bWriteLog and "[logic_rank_guard] nil activityData")
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if activity.StartTime and now > activity.StartTime and activity.EndTime and now < activity.EndTime then
    local data = {
      nActID = logic_rank_guard.config.ActivityID,
      sName = LocUtil.GetLocalizeResStr(44206),
      sBgUrl = "",
      nStartTime = activity.StartTime,
      nSwitchType = 1,
      DisplayScene = activity.DisplayScene
    }
    logic_rank_guard.activityData = activity
    return data
  end
  return nil
end
function logic_rank_guard.GetRankListReq()
  log(bWriteLog and "[logic_rank_guard] GetRankListReq")
  local regionGroupID = 1
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig then
    regionGroupID = regionGroupConfig.PopularityGroupID
  end
  log(bWriteLog and "[logic_rank_guard] GetRankListReq regionGroupID: " .. tostring(regionGroupID))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_gift_activity_rank_req(regionGroupID, logic_rank_guard.config.ScoreType)
end
function logic_rank_guard.GetRankListRsp(area_id, score_type, rank_list)
  log(bWriteLog and "[logic_rank_guard] GetRankListRsp: " .. tostring(area_id) .. " with score_type: " .. tostring(score_type))
  if score_type ~= logic_rank_guard.config.ScoreType then
    log(bWriteLog and "[logic_rank_guard] score type not match")
    return
  end
  logic_rank_guard.rankAreaID = area_id
  logic_rank_guard.rankDataList = rank_list
  logic_rank_guard.ProcessRewardData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_GUARD_LIST_UPDATE)
  local reqProfileUIDList = {}
  for i = 1, logic_rank_guard.config.ReqNumPerPage do
    if rank_list[i] and not rank_list[i].req then
      table.insert(reqProfileUIDList, rank_list[i].uid)
      if rank_list[i].ext_data and rank_list[i].ext_data.receiver_uid then
        table.insert(reqProfileUIDList, rank_list[i].ext_data.receiver_uid)
      end
      logic_rank_guard.rankDataList[i].req = true
    end
  end
  logic_rank_guard.GetRankProfileList(reqProfileUIDList)
end
function logic_rank_guard.ProcessRewardData()
  log(bWriteLog and "[logic_rank_guard] ProcessRewardData")
  if not logic_rank_guard.rankAreaID or not logic_rank_guard.rankDataList then
    log(bWriteLog and "[logic_rank_guard] invalid rank info")
    return
  end
  local TopNextRankRewardTable = CDataTable.GetTable("TopNextRankRewardTable")
  if not TopNextRankRewardTable then
    log(bWriteLog and "[logic_rank_guard] invalid TopNextRankRewardTable")
    return
  end
  local RewardCfg = {}
  for _, v in pairs(TopNextRankRewardTable) do
    if v.RankType == logic_rank_guard.rankAreaID and v.TemplateType == logic_rank_guard.config.ScoreType then
      table.insert(RewardCfg, v)
    end
  end
  for rank, rank_data in ipairs(logic_rank_guard.rankDataList) do
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
function logic_rank_guard.GetRankProfileList(reqProfileUIDList)
  log(bWriteLog and "[logic_rank_guard] GetRankProfileList")
  if not reqProfileUIDList or #reqProfileUIDList <= 0 then
    log(bWriteLog and "[logic_rank_guard] invalid reqProfileUIDList")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(reqProfileUIDList, logic_rank_guard.GetRankListProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_POP_LIST)
end
function logic_rank_guard.GetRankListProfileRsp(profileList)
  log(bWriteLog and "[logic_rank_guard] GetRankListProfileRsp")
  if not profileList or not next(profileList) then
    log(bWriteLog and "[logic_rank_guard] invalid profileList")
    return
  end
  if not logic_rank_guard.rankDataList then
    log(bWriteLog and "[logic_rank_guard] invalid rankDataList")
    return
  end
  local profileMap = {}
  for _, profile_data in ipairs(profileList) do
    profileMap[tonumber(profile_data.uid)] = profile_data
  end
  local match_rank_map = {}
  for index, rank_data in pairs(logic_rank_guard.rankDataList) do
    if tonumber(rank_data.uid) == tonumber(DataMgr.roleData.uid) then
      rank_data.name = DataMgr.roleData.nickName
      rank_data.url = DataMgr.roleData.headIconUrl
      rank_data.gender = DataMgr.roleData.gender
      rank_data.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
      rank_data.level = DataMgr.roleData.level
      match_rank_map[index] = rank_data
    else
      local profile_data = profileMap[tonumber(rank_data.uid)]
      if profile_data then
        rank_data.name = profile_data.nickName
        rank_data.url = profile_data.picUrl
        rank_data.gender = profile_data.sex
        rank_data.cur_avatar_box_id = profile_data.cur_avatar_box_id
        rank_data.level = profile_data.level
        rank_data.light_board_info = profile_data.light_board_info
        match_rank_map[index] = rank_data
      else
        log(bWriteLog and "[logic_rank_guard] invalid profile: " .. tostring(rank_data.uid))
      end
    end
    rank_data.guarded = nil
    if rank_data.ext_data and rank_data.ext_data.receiver_uid then
      if tonumber(rank_data.ext_data.receiver_uid) == tonumber(DataMgr.roleData.uid) then
        rank_data.guarded = {}
        rank_data.guarded.uid = DataMgr.roleData.uid
        rank_data.guarded.name = DataMgr.roleData.nickName
        rank_data.guarded.url = DataMgr.roleData.headIconUrl
        rank_data.guarded.gender = DataMgr.roleData.gender
        rank_data.guarded.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
        rank_data.guarded.level = DataMgr.roleData.level
        rank_data.guarded.friend_nickname_skin = DataMgr.roleData.friend_nickname_skin
        match_rank_map[index] = rank_data
      else
        local guarded_profile_data = profileMap[tonumber(rank_data.ext_data.receiver_uid)]
        if guarded_profile_data then
          rank_data.guarded = {}
          rank_data.guarded.uid = guarded_profile_data.uid
          rank_data.guarded.name = guarded_profile_data.nickName
          rank_data.guarded.url = guarded_profile_data.picUrl
          rank_data.guarded.gender = guarded_profile_data.sex
          rank_data.guarded.cur_avatar_box_id = guarded_profile_data.cur_avatar_box_id
          rank_data.guarded.level = guarded_profile_data.level
          rank_data.guarded.friend_nickname_skin = guarded_profile_data.friend_nickname_skin
          rank_data.guarded.light_board_info = guarded_profile_data.light_board_info
          match_rank_map[index] = rank_data
        else
          log(bWriteLog and "[logic_rank_guard] invalid guarded profile: " .. tostring(rank_data.guardedUID))
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_GUARD_PROFILE_UPDATE, match_rank_map)
end
function logic_rank_guard.GetSelfRankReq()
  log(bWriteLog and "[logic_rank_guard] GetSelfRankReq")
  local regionGroupID = 1
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig then
    regionGroupID = regionGroupConfig.PopularityGroupID
  end
  log(bWriteLog and "[logic_rank_guard] GetSelfRankReq regionGroupID: " .. tostring(regionGroupID))
  local PopularityGiftHandler = require("client.network.Protocol.PopularityGiftHandler")
  PopularityGiftHandler.send_get_personal_gift_activity_rank_req(regionGroupID, logic_rank_guard.config.ScoreType)
end
function logic_rank_guard.GetSelfRankRsp(area_id, score_type, selfRankData)
  log(bWriteLog and "[logic_rank_guard] GetSelfRankRsp: " .. tostring(area_id) .. " with score_type: " .. tostring(score_type))
  if score_type ~= logic_rank_guard.config.ScoreType then
    log(bWriteLog and "[logic_rank_guard] score type not match")
    return
  end
  logic_rank_guard.rankAreaID = area_id
  logic_rank_guard.  logic_rank_guard.selfRankData.name = DataMgr.roleData.nickName
  logic_rank_guard.selfRankData.url = DataMgr.roleData.headIconUrl
  logic_rank_guard.selfRankData.gender = DataMgr.roleData.gender
  logic_rank_guard.selfRankData.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
  logic_rank_guard.selfRankData.level = DataMgr.roleData.level
  logic_rank_guard.selfRankData.guarded = nil
  logic_rank_guard.ProcessSelfRewardData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_GUARD_SELF_UPDATE)
  if not logic_rank_guard.selfRankData.ext_data or not logic_rank_guard.selfRankData.ext_data.receiver_uid then
    return
  end
  log(bWriteLog and "[logic_rank_guard] GetSelfRankProfile")
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({
    logic_rank_guard.selfRankData.ext_data.receiver_uid
  }, logic_rank_guard.GetSelfRankProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_POP_LIST)
end
function logic_rank_guard.ProcessSelfRewardData()
  log(bWriteLog and "[logic_rank_guard] ProcessSelfRewardData")
  if not logic_rank_guard.rankAreaID or not logic_rank_guard.selfRankData then
    log(bWriteLog and "[logic_rank_guard] invalid self data")
    return
  end
  if tonumber(logic_rank_guard.selfRankData.rank) > tonumber(logic_rank_guard.config.MaxRewardRank) then
    log(bWriteLog and "[logic_rank_guard] out of MaxRewardRank: " .. tostring(logic_rank_guard.selfRankData.rank))
    return
  end
  local TopNextRankRewardTable = CDataTable.GetTable("TopNextRankRewardTable")
  if not TopNextRankRewardTable then
    log(bWriteLog and "[logic_rank_guard] invalid TopNextRankRewardTable")
    return
  end
  local RewardCfg = {}
  for _, v in pairs(TopNextRankRewardTable) do
    if v.RankType == logic_rank_guard.rankAreaID and v.TemplateType == logic_rank_guard.config.ScoreType then
      table.insert(RewardCfg, v)
    end
  end
  logic_rank_guard.selfRankData.rewardList = {}
  local selfRank = logic_rank_guard.selfRankData.rank
  for _, CfgItem in ipairs(RewardCfg) do
    if selfRank >= CfgItem.RankCeilling and selfRank <= CfgItem.RankFloor then
      local drops1 = {
        itemId = CfgItem.RewardItemID1,
        count = CfgItem.RewardItemCnt1,
        expireTime = CfgItem.RewardItemLimitTime1
      }
      logic_rank_guard.selfRankData.rewardList[1] = drops1
      if CfgItem.RewardItemID2 > 0 then
        local drops2 = {
          itemId = CfgItem.RewardItemID2,
          count = CfgItem.RewardItemCnt2,
          expireTime = CfgItem.RewardItemLimitTime2
        }
        logic_rank_guard.selfRankData.rewardList[2] = drops2
      end
      if 0 < CfgItem.RewardItemID3 then
        local drops3 = {
          itemId = CfgItem.RewardItemID3,
          count = CfgItem.RewardItemCnt3,
          expireTime = CfgItem.RewardItemLimitTime3
        }
        logic_rank_guard.selfRankData.rewardList[3] = drops3
      end
    end
  end
end
function logic_rank_guard.GetSelfRankProfileRsp(profileList)
  log(bWriteLog and "[logic_rank_guard] GetSelfRankProfileRsp")
  if not profileList or not next(profileList) then
    log(bWriteLog and "[logic_rank_guard] invalid profileList")
    return
  end
  local guardedProfile = profileList[1]
  logic_rank_guard.selfRankData.guarded = {}
  logic_rank_guard.selfRankData.guarded.uid = guardedProfile.uid
  logic_rank_guard.selfRankData.guarded.name = guardedProfile.nickName
  logic_rank_guard.selfRankData.guarded.url = guardedProfile.picUrl
  logic_rank_guard.selfRankData.guarded.gender = guardedProfile.sex
  logic_rank_guard.selfRankData.guarded.cur_avatar_box_id = guardedProfile.cur_avatar_box_id
  logic_rank_guard.selfRankData.guarded.level = guardedProfile.level
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_GUARD_SELF_UPDATE)
end
function logic_rank_guard.LoadBgImage(successCallback)
  log(bWriteLog and "[logic_rank_guard] LoadBgImage")
  if not logic_rank_guard.activityData then
    log(bWriteLog and "[logic_rank_guard] invalid activity data")
    return
  end
  local BgImageUrl = logic_rank_guard.activityData.ImgUrl
  if not BgImageUrl or BgImageUrl == "" then
    log(bWriteLog and "[logic_rank_guard] invalid image url")
    return
  end
  local util = require("client.slua_ui_framework.util")
  BgImageUrl = util.GetUrlByLanguage(BgImageUrl)
  if not util.IsOnlineImageUrl(BgImageUrl) then
    log(bWriteLog and "[logic_rank_guard] not online image url")
    return
  end
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  if logic_rank_guard.downloadIndex and logic_rank_guard.downloadIndex > 0 then
    image_download_mgr:CancelDownloadByIndex(logic_rank_guard.downloadIndex)
    logic_rank_guard.downloadIndex = nil
  end
  local downloadIndex = image_download_mgr:DownloadImageByHttpWrapper(BgImageUrl, function(texture, imgUrl)
    log(bWriteLog and "[logic_rank_guard] download bg image success: " .. tostring(BgImageUrl))
    if successCallback then
      successCallback(texture)
    end
  end, function()
    log(bWriteLog and "[logic_rank_guard] download bg image failed: " .. tostring(BgImageUrl))
  end)
  if downloadIndex and 0 < downloadIndex then
    logic_rank_guard.  end
end
return logic_rank_guard