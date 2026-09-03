local logic_popular_gift_pk = {}
function logic_popular_gift_pk:DefineAndResetData()
  self.resPSMatchStatusMap = {}
  self.resPKConfig = nil
  self.resPKInfoMap = {}
  self.resRewardStatus = nil
  self.resRankDataList = nil
  self.resMyRankInfo = nil
  self.resPKRecord = nil
  self.enroll_time = 0
  self.celebrationRankInfo = nil
  self.psmatch_act_cfg = nil
end
function logic_popular_gift_pk:OnInitialize()
  log(bWriteLog and "logic_popular_gift_pk:OnInitialize")
  local data_config_marco = require("client.logic.data.data_config_marco")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  self.psmatch_act_cfg = BasicDataServerTable:GetCacheData(data_config_marco.psmatch_act_cfg)
  if not self.psmatch_act_cfg then
    log(bWriteLog and "logic_popular_gift_pk:OnInitialize psmatch_act_cfg is nil")
    self.psmatch_act_cfg = BasicDataServerTable:GetOrReqData(data_config_marco.psmatch_act_cfg, function(_, configData)
      log_tree(bWriteLog and "logic_popular_gift_pk:OnInitialize BasicDataServerTable:GetOrReqData psmatch_act_cfg", configData)
      self.psmatch_act_cfg = configData
    end)
  end
end
function logic_popular_gift_pk:RegistEvents()
  log(bWriteLog and "logic_popular_gift_pk:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_POPULARITY_PK_MAIN, self.OnJumpPopularPK, self)
end
function logic_popular_gift_pk:OnLogin(bReLogin)
  log(bWriteLog and "logic_popular_gift_pk:OnLogin bReLogin = " .. tostring(bReLogin))
  local data_config_marco = require("client.logic.data.data_config_marco")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  self.psmatch_act_cfg = BasicDataServerTable:GetCacheData(data_config_marco.psmatch_act_cfg)
  if not self.psmatch_act_cfg then
    log(bWriteLog and "logic_popular_gift_pk:OnLogin psmatch_act_cfg is nil")
    self.psmatch_act_cfg = BasicDataServerTable:GetOrReqData(data_config_marco.psmatch_act_cfg, function(_, configData)
      log_tree(bWriteLog and "logic_popular_gift_pk:OnLogin BasicDataServerTable:GetOrReqData psmatch_act_cfg", configData)
      self.psmatch_act_cfg = configData
    end)
  end
end
function logic_popular_gift_pk:OnLogOut()
  log(bWriteLog and "logic_popular_gift_pk:OnLogOut")
  self:DefineAndResetData()
end
function logic_popular_gift_pk:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_popular_gift_pk:OnPostSwitchGameStatus pre = " .. preState .. ", nextState = " .. nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:DefineAndResetData()
  end
end
function logic_popular_gift_pk:proc_get_psmatch_status_rsp(target_uid, InfoTb, cfgs)
  log_format(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_status_rsp target_uid = %s", target_uid)
  log_tree(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_status_rsp InfoTb:", InfoTb)
  log_tree(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_status_rsp cfgs:", cfgs)
  self.resPSMatchStatusMap[target_uid] = InfoTb
  self.resPKConfig = cfgs
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_STATUS, target_uid)
end
function logic_popular_gift_pk:proc_psmatch_enroll_rsp(season_id, round_id, status, enroll_time)
  log_format(bWriteLog and "logic_popular_gift_pk:proc_psmatch_enroll_rsp season_id = %s, round_id = %s, status = %s, enroll_time = %s", season_id, round_id, status, enroll_time)
  local uid = tonumber(DataMgr.roleData.uid)
  if self.resPSMatchStatusMap[uid] then
    self.resPSMatchStatusMap[uid].season_idx = season_id
    self.resPSMatchStatusMap[uid].    self.resPSMatchStatusMap[uid].  end
  self.  local logic_popular_pk_push = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_push)
  logic_popular_pk_push:UpdatePopularPkMsgWhenEnrolled()
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_STATUS, uid)
end
function logic_popular_gift_pk:proc_get_psmatch_current_pk_info_rsp(target_uid, pk_info)
  log_format(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_current_pk_info_rsp target_uid = %s", target_uid)
  log_tree(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_current_pk_info_rsp pk_info:", pk_info)
  self.resPKInfoMap[target_uid] = pk_info
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_INFO)
end
function logic_popular_gift_pk:proc_get_psmatch_reward_status_rsp(reward_status)
  self.resRewardStatus = reward_status
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_LEVEL_REWARD_STATUS)
  local logic_popular_pk_reddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_reddot)
  if not logic_popular_pk_reddot:IsShowRewardReddot() then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_REDDOT_CHANGE)
  end
end
function logic_popular_gift_pk:proc_get_topn_rank_rsp(res, rank_data_list)
  log(bWriteLog and "logic_popular_gift_pk:proc_get_topn_rank_rsp res = " .. tostring(res))
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_SEASON_RANK)
    return
  end
  log_tree("logic_popular_gift_pk:proc_get_topn_rank_rsp rank_data_list", rank_data_list)
  self.resRankDataList = rank_data_list
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_SEASON_RANK)
end
function logic_popular_gift_pk:proc_get_psmatch_pk_record_rsp(record)
  log(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_pk_record_rsp")
  log_tree(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_pk_record_rsp record:", record)
  self.resPKRecord = record
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_RECORD)
end
function logic_popular_gift_pk:proc_view_pk_switch(switch)
  log(bWriteLog and "[v_wllwu] logic_popular_gift_pk:proc_view_pk_switch\239\188\140switch is:" .. tostring(switch))
  local PopularPkMacros = require("client.slua.logic.person_space.popular_pk_macros")
  self.resViewPKSwitch = switch or PopularPkMacros.ENUM_VIEW_PK_SWITCH.OPEN
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_VIEW_SWITCH)
end
function logic_popular_gift_pk:proc_get_psmatch_reward_rsp(item_list)
  log_tree("logic_popular_gift_pk:proc_get_psmatch_reward_rsp item_list", item_list)
  if item_list and 0 < #item_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_GET_LEVEL_REWARD)
end
function logic_popular_gift_pk:send_get_topn_rank(rankID)
  log(bWriteLog and "logic_popular_gift_pk:send_get_topn_rank rankID = " .. tostring(rankID))
  local PopularityPKHandler = require("client.network.Protocol.PopularityPKHandler")
  if PopularityPKHandler.bGMTest then
    local fakeData = {
      uid = DataMgr.roleData.uid,
      score = 189,
      rank_no = 1
    }
    local GMList = {}
    for i = 1, 10 do
      table.insert(GMList, fakeData)
    end
    self:proc_get_topn_rank_rsp(0, GMList)
    return
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = rankID or RankDataMgr.GetPopularityPKRankID()
  RankHandler.send_get_topn_rank(0, popularityRankID, 1)
end
function logic_popular_gift_pk:send_get_one_user_rank(rankID, uid)
  log_format(bWriteLog and "logic_popular_gift_pk:send_get_one_user_rank rankID = %s, uid = %s", rankID, uid)
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = rankID or RankDataMgr.GetPopularityPKRankID()
  local reqUID = tonumber(uid) or tonumber(DataMgr.roleData.uid)
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank("PopularityPK", 0, reqUID, popularityRankID)
end
function logic_popular_gift_pk:on_get_one_user_rank_rsp(rank_source, res, rank_info)
  if rank_source ~= "PopularityPK" then
    log(bWriteLog and "logic_popular_gift_pk:on_get_one_user_rank_rsp rank_source = " .. tostring(rank_source))
    return
  end
  if res ~= 0 then
    log(bWriteLog and "logic_popular_gift_pk:on_get_one_user_rank_rsp res = " .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_SELF_SEASON_RANK)
    return
  end
  log_tree("logic_popular_gift_pk:on_get_one_user_rank_rsp rank_info", rank_info)
  self.resMyRankInfo = rank_info
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_SELF_SEASON_RANK)
end
function logic_popular_gift_pk:on_psmatch_send_gift_notify(uid, point, enemy_uid, enemy_point)
  local log_content = {
    uid = uid,
    point = point,
    enemy_uid = enemy_uid,
      }
  log_tree(bWriteLog and "logic_popular_gift_pk:on_psmatch_send_gift_notify log_content", log_content)
  local statusInfo = self.resPSMatchStatusMap[uid]
  if statusInfo then
    local TableUtil = require("common.table_util")
    local enemyUid = TableUtil.GetTableValue(statusInfo, "current_pk_info", "enemy_uid")
    if enemyUid == enemy_uid then
      statusInfo.current_pk_info.      statusInfo.current_pk_info.    else
      log_error(bWriteLog and "[v_wllwu] logic_popular_gift_pk:on_psmatch_send_gift_notify, enemyUId not match !!! enemyUid is\239\188\154" .. tostring(enemyUid))
    end
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_SCORE)
end
function logic_popular_gift_pk:on_get_one_user_annual_rank_rsp(err_code, rank_uid, rank, score, rankid)
  log_format(bWriteLog and "logic_popular_gift_pk:on_get_one_user_annual_rank_rsp err_code = %s, rank_uid = %s, rank = %s, score = %s, rankid = %s", err_code, rank_uid, rank, score, rankid)
  if err_code == 0 then
    self.celebrationRankInfo = self.celebrationRankInfo or {}
    self.celebrationRankInfo[rank_uid] = self.celebrationRankInfo[rank_uid] or {}
    self.celebrationRankInfo[rank_uid][rankid] = {rank = rank, score = score}
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_CELEBRATION_SELF_RANK)
end
function logic_popular_gift_pk:IsPopularityPKRank(rankID)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  return rankID == RankConfig.ScoreType.popularity_pk_rating_jk or rankID == RankConfig.ScoreType.popularity_pk_rating
end
function logic_popular_gift_pk:GetPopularityPKRecord()
  if not self.resPKRecord then
    log(bWriteLog and "logic_popular_gift_pk:proc_get_psmatch_pk_record_rsp")
    return {}
  end
  local recordList = {}
  for k, v in pairs(self.resPKRecord) do
    table.insert(recordList, v)
  end
  table.sort(recordList, function(a, b)
    return a.round_id > b.round_id
  end)
  return recordList
end
function logic_popular_gift_pk:ConvertScoreToLevel(score, seasonID)
  local PopularityPKLevelConfig = CDataTable.GetTableByFilter("PopularityPKLevelConfig", "SeasonID", seasonID)
  local level = 0
  for k, v in pairs(PopularityPKLevelConfig) do
    if score >= v.MinScore and score <= v.MaxScore then
      level = v.Level
      break
    elseif score >= v.MinScore then
      level = v.Level
    end
  end
  return level
end
function logic_popular_gift_pk:GetPopularityPKRewardInfo()
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = RankDataMgr.GetPopularityPKRankID()
  local RankRewardTable = CDataTable.GetTable("RankRewardTable")
  local rankAwardData = {}
  for k, v in pairs(RankRewardTable) do
    if v.RankType == popularityRankID then
      local awardInfo = {
        RankCeiling = v.RankCeilling,
        RankFloor = v.RankFloor,
        RankAwardList = {}
      }
      for i = 1, 3 do
        awardInfo.RankAwardList[i] = {
          itemId = v["RewardItemID" .. i],
          itemNum = v["RewardItemCnt" .. i],
          limitTime = RankDataMgr.GetRankRewardItemTime(v["RewardItemLimitType" .. i], v["RewardItemTimeLimit" .. i])
        }
      end
      table.insert(rankAwardData, awardInfo)
    end
  end
  return rankAwardData
end
function logic_popular_gift_pk:GetCurrentPKRewardInfo(rank)
  if not rank then
    log(bWriteLog and "logic_popular_gift_pk:GetCurrentPKRewardInfo not rank")
    return {}
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = RankDataMgr.GetPopularityPKRankID()
  local RankRewardTable = CDataTable.GetTable("RankRewardTable")
  local rankAwardData = {}
  for k, v in pairs(RankRewardTable) do
    if v.RankType == popularityRankID and rank >= v.RankCeilling and rank <= v.RankFloor then
      for i = 1, 3 do
        rankAwardData[i] = {
          itemId = v["RewardItemID" .. i],
          itemNum = v["RewardItemCnt" .. i],
          limitTime = RankDataMgr.GetRankRewardItemTime(v["RewardItemLimitType" .. i], v["RewardItemTimeLimit" .. i])
        }
      end
    end
  end
  return rankAwardData
end
function logic_popular_gift_pk:GetCelebrationSelfRankInfo(uid, rankid)
  log(bWriteLog and "logic_popular_gift_pk:GetCelebrationSelfRankInfo uid = " .. tostring(uid) .. ", rankid = " .. tostring(rankid))
  if not (self.celebrationRankInfo and self.celebrationRankInfo[uid]) or not self.celebrationRankInfo[uid][rankid] then
    log(bWriteLog and "logic_popular_gift_pk:GetCelebrationSelfRankInfo not info")
    return
  end
  return self.celebrationRankInfo[uid][rankid]
end
function logic_popular_gift_pk:IsOpenCelebration(seasonID)
  local config = CDataTable.GetTableData("PopularPKTimeConfig", seasonID)
  if not config then
    log(bWriteLog and "logic_popular_gift_pk:IsOpenCelebration not config, seasonID = " .. tostring(seasonID))
    return false
  end
  return config.CelebrationSwitch
end
function logic_popular_gift_pk:GetCelebrationPKRewardInfo(rankNo, rankID)
  if not rankNo then
    log(bWriteLog and "logic_popular_gift_pk:GetCelebrationPKRewardInfo not rankNo")
    return {}
  end
  if not (self.resPKConfig and self.resPKConfig.annual_reward_cfg) or not self.resPKConfig.annual_reward_cfg[rankID] then
    log(bWriteLog and "logic_popular_gift_pk:GetCelebrationPKRewardInfo not config rankID = " .. tostring(rankID))
    return {}
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rankAwardData = {}
  for k, v in pairs(self.resPKConfig.annual_reward_cfg[rankID]) do
    if rankNo >= v.rankno_up and rankNo <= v.rankno_down then
      local TableUtil = require("common.table_util")
      rankAwardData = TableUtil.CopyTable(v)
      break
    end
  end
  return rankAwardData
end
function logic_popular_gift_pk:GetCelebrationRankStatus(rankNo, rankID)
  local popular_pk_macros = require("client.slua.logic.person_space.popular_pk_macros")
  if not (self.resPKConfig and self.resPKConfig.annual_rank_cfg) or not next(self.resPKConfig.annual_rank_cfg) then
    log_error(bWriteLog and "logic_popular_gift_pk:GetCelebrationRankStatus not config")
    return popular_pk_macros.ENUM_RANK_STATUS.Retention
  end
  if not rankNo or rankNo == 0 then
    local RankConfig = require("client.slua.logic.rank.rank_config")
    if rankID == RankConfig.ScoreType.popularity_pk_rating_jk then
      return popular_pk_macros.ENUM_RANK_STATUS.Retention
    else
      return popular_pk_macros.ENUM_RANK_STATUS.Demotion
    end
  end
  for k, v in pairs(self.resPKConfig.annual_rank_cfg) do
    if v.topnext_rank_id == rankID then
      if rankNo <= v.up_grade_count then
        return popular_pk_macros.ENUM_RANK_STATUS.Promotion
      elseif rankNo > v.rank_user_count - v.dec_grade_count then
        return popular_pk_macros.ENUM_RANK_STATUS.Demotion
      else
        return popular_pk_macros.ENUM_RANK_STATUS.Retention
      end
    end
  end
  local lastIndex = #self.resPKConfig.annual_rank_cfg
  local promotionCountLowest = self.resPKConfig.annual_rank_cfg[lastIndex].dec_grade_count
  if rankNo <= promotionCountLowest then
    return popular_pk_macros.ENUM_RANK_STATUS.Promotion
  else
    return popular_pk_macros.ENUM_RANK_STATUS.Retention
  end
end
function logic_popular_gift_pk:GetCelebrationStatusStr(status)
  local popular_pk_macros = require("client.slua.logic.person_space.popular_pk_macros")
  if status == popular_pk_macros.ENUM_RANK_STATUS.Promotion then
    return LocUtil.GetLocalizeResStr(62284)
  elseif status == popular_pk_macros.ENUM_RANK_STATUS.Retention then
    return LocUtil.GetLocalizeResStr(62285)
  else
    return LocUtil.GetLocalizeResStr(62286)
  end
end
function logic_popular_gift_pk:GetCurrAnnualCelebrationTreasureBoxShowInfo()
  local tShowInfo = {}
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local uid = tonumber(RoleInfoPopularitySystem.CurrUid)
  local resData = self.resPSMatchStatusMap[uid]
  if not resData then
    log(bWriteLog and "logic_popular_gift_pk:GetCurrAnnualCelebrationTreasureBoxShowInfo, not resData")
    return tShowInfo
  end
  local tTemp
  local StringUtil = require("common.string_util")
  log(bWriteLog and "logic_popular_gift_pk:GetCurrAnnualCelebrationTreasureBoxShowInfo, resData: " .. tostring(resData.season_idx))
  local tTreasureBoxPlan = {}
  local tTreasureBoxPlanConfig = CDataTable.GetTableByFilter("PopularityPKCeremonyTreasureBoxPlan", "SeasonID", resData.season_idx)
  for k, v in pairs(tTreasureBoxPlanConfig) do
    local tTreasureBoxLeaderboard = {}
    local tTreasureBoxLeaderboardConfig = CDataTable.GetTableByFilter("PopularityPKCeremonyTreasureBoxLeaderboard", "SeasonID", resData.season_idx, "TreasureBoxPlanID", v.TreasureBoxPlanID)
    for k1, v1 in pairs(tTreasureBoxLeaderboardConfig) do
      local tRoundId = StringUtil.Split(v1.RoundID, ":")
      if #tRoundId < 1 then
        log(bWriteLog and "logic_popular_gift_pk:GetCurrAnnualCelebrationTreasureBoxShowInfo, #tRoundId < 1. TreasureBoxPlanID: " .. tostring(TreasureBoxPlanID) .. ", RoundID: " .. tostring(v1.RoundID))
        return tShowInfo
      end
      local nRoundBegin = tonumber(tRoundId[1])
      local nRoundEnd = tRoundId[2] and tonumber(tRoundId[2]) or tonumber(tRoundId[1])
      if nRoundBegin <= resData.round_id and nRoundEnd >= resData.round_id then
        table.insert(tTreasureBoxLeaderboard, v1)
      elseif resData.round_id == 0 and nRoundBegin == 1 then
        table.insert(tTreasureBoxLeaderboard, v1)
      end
    end
    tTemp = {TreasureBoxPlanConfig = v, tTreasureBoxLeaderboardConfig = tTreasureBoxLeaderboard}
    table.insert(tTreasureBoxPlan, tTemp)
  end
  local tTreasureBoxRewardPoolMatchingConfig = CDataTable.GetTable("PopularityPKCeremonyTreasureBoxRewardPoolMatching")
  for k, v in pairs(tTreasureBoxPlan) do
    local nTreasureBoxItemID = v.tTreasureBoxLeaderboardConfig[1].ItemID1
    local tConfig = tTreasureBoxRewardPoolMatchingConfig[nTreasureBoxItemID]
    if tConfig then
      local tTreasureBoxRewardPoolConfig = CDataTable.GetTableByFilter("PopularityPKCeremonyTreasureBoxRewardPool", "TreasureBoxDropPlanID", tConfig.TreasureBoxDropPlanID)
      local tTreasureBoxRewardPool = {}
      for k1, v1 in pairs(tTreasureBoxRewardPoolConfig) do
        table.insert(tTreasureBoxRewardPool, v1)
      end
      tTemp = {
        nSeasonID = resData.season_idx,
        nTreasureBoxItemID = nTreasureBoxItemID,
        nTreasureBoxDropPlanID = tConfig.TreasureBoxDropPlanID,
        TreasureBoxPlanConfig = v.TreasureBoxPlanConfig,
        tTreasureBoxLeaderboardConfig = v.tTreasureBoxLeaderboardConfig,
              }
      table.insert(tShowInfo, tTemp)
    end
  end
  log_tree(bWriteLog and "logic_popular_gift_pk:GetCurrAnnualCelebrationTreasureBoxShowInfo, tShowInfo: ", tShowInfo)
  return tShowInfo
end
function logic_popular_gift_pk:UpdateStreakReddotFlag(bShow)
  if not self.resPSMatchStatusMap or not self.resPSMatchStatusMap[tonumber(DataMgr.roleData.uid)] then
    log(bWriteLog and "logic_popular_gift_pk:UpdateStreakReddotFlag not data")
    return
  end
  self.resPSMatchStatusMap[tonumber(DataMgr.roleData.uid)].flag_streak_reward = bShow
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_STREAK_REDDOT_UPDATE)
end
function logic_popular_gift_pk:OnJumpPopularPK(_, _, vars)
  log(bWriteLog and "[v_wllwu] logic_popular_gift_pk:OnJumpPopularPK, uid is:" .. tostring(vars and vars.uid))
  if not GameStatus.IsInLobbyOrMainCity() then
    ShowNotice(33631)
    return
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local PopularityMacros = require("client.slua.logic.person_space.popularity_macro")
  RoleInfoPopularitySystem.OpenPopularityUI(vars and vars.uid or tonumber(DataMgr.roleData.uid), PopularityMacros.ENUM_TAB_TYPE.PopularityPK)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_gift_pk = class(CModuleBase, nil, logic_popular_gift_pk)
return Clogic_popular_gift_pk