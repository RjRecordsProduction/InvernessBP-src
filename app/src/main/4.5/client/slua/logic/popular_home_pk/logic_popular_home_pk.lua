local logic_popular_home_pk = {}
function logic_popular_home_pk:DefineAndResetData()
  self.actTableConfig = nil
  self.myHomePkData = nil
  self.otherHomePkData = nil
  self.recentSegmentInfo = nil
  self.recordList = nil
  self.reqPkDataTimeRecord = nil
  self.surfaceUrls = nil
  self.surfaceThumbUrls = nil
  self.rankDataList = nil
  self.myRankInfo = nil
  self.myStyleRankInfo = nil
  self.squareRankDataList = nil
  self.styleRankDataList = nil
  self.squareRecommendRankDataList = nil
  self.squareFriendRankDataList = {}
  self.manorSceneData = nil
  self.receiveSceneUIDs = nil
  self.HomeBasicPointConfig = nil
end
local _IsMatchVersionAndAppId = function(actData)
  local version_util = require("client.common.version_util")
  local curVersion = Client.GetAppVersion()
  if not actData.cli_ver_str or not version_util.HigherVersion(curVersion, actData.cli_ver_str) then
    log(bWriteLog and "logic_popular_home_pk:_IsMatchVersionAndAppId, return false and actData.cli_ver_str is:" .. tostring(actData.cli_ver_str) .. ";curVersion is: " .. tostring(curVersion))
    return false
  end
  local gameId = Client.GetITopGameId()
  if actData.game_app_list then
    if actData.game_app_list[gameId] and actData.game_app_list[gameId] == 1 then
      return true
    end
    log_tree(bWriteLog and "_IsMatchVersionAndAppId return false, actData.game_app_list is:", actData.game_app_list)
    return false
  end
  return true
end
local _IsMatchTime = function(actData)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_popular_home_pk:_IsMatchTime, curTime is: " .. tostring(curTime))
  if curTime < actData.act_start_ts or curTime >= actData.act_end_ts then
    log(bWriteLog and "logic_popular_home_pk:_IsMatchTime, return false")
    return false
  end
  return true
end
function logic_popular_home_pk:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_POPULARITY_HOMEPK_MAIN, self.OnJumpPKMainUI, self)
end
function logic_popular_home_pk:OnLogOut()
  self:DefineAndResetData()
end
function logic_popular_home_pk:OnPostSwitchGameStatus(preState, nextState)
  self.receiveSceneUIDs = nil
  self.manorSceneData = nil
end
function logic_popular_home_pk:OnJumpPKMainUI(_, __, params)
  log(bWriteLog and "logic_popular_home_pk:OnJumpPKMainUI params.uid = " .. tostring(params.uid))
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.IsSocialIslandMode() then
    ShowNotice(33631)
    return
  end
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(true) then
    log(bWriteLog and "logic_popular_home_pk:OnJumpPKMainUI home limit")
    return
  end
  local jumpUID = params.uid or DataMgr.roleData.uid
  UIManager.ShowUI(UIManager.UI_Config.HomePK_Main_UIBP, {
    uid = tonumber(jumpUID)
  })
end
function logic_popular_home_pk:GetNetActTableConfig()
  return self.actTableConfig
end
function logic_popular_home_pk:IsNeedRequestActConfig()
  if self.actTableConfig == nil then
    return true
  end
  return false
end
function logic_popular_home_pk.IsCanShowPkResult(uid)
  if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "logic_popular_home_pk.IsCanShowPkResult not self, uid = " .. tostring(uid))
    return false
  end
  return false
end
function logic_popular_home_pk:IsInVoteTaskTime()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local actConfig = self:GetActConfig()
  if not actConfig then
    log(bWriteLog and "logic_popular_home_pk:IsInVoteTaskTime not actConfig")
    return false
  end
  if curTime < actConfig.show_task_start_ts or curTime > actConfig.show_task_end_ts then
    log(bWriteLog and "logic_popular_home_pk:IsInVoteTaskTime not in time, show_task_start_ts = " .. tostring(actConfig.show_task_start_ts) .. ", show_task_end_ts = " .. tostring(actConfig.show_task_end_ts))
    return false
  end
  return true
end
function logic_popular_home_pk:CanShowTipsEntry(uid)
  uid = tonumber(uid)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(false) then
    log(bWriteLog and "logic_popular_home_pk:CanShowTipsEntry home limit")
    return false
  end
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
  local actState = logic_popular_home_pk_util.GetActState()
  if actState == PopularHomePKMacros.ENUM_STATE.CLOSE then
    log(bWriteLog and "logic_popular_home_pk:CanShowTipsEntry, return false actState is:" .. tostring(actState))
    return false
  end
  if uid ~= tonumber(DataMgr.roleData.uid) then
    local logic_popular_home_pk_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk_tab)
    return logic_popular_home_pk_tab:CanViewOtherPk(uid)
  end
  local playerActState = logic_popular_home_pk_util.GetPlayerActState(uid)
  log(bWriteLog and "logic_popular_home_pk:CanShowTipsEntry, playerActState is:" .. tostring(playerActState) .. " actState = " .. tostring(actState))
  if actState == PopularHomePKMacros.ENUM_STATE.SIGN and playerActState == PopularHomePKMacros.ENUM_PLAYER_STATE.SIGN then
    return true
  end
  if not self:IsSelfHasEnemy() then
    log(bWriteLog and "logic_popular_home_pk:CanShowTipsEntry, return false no enemy")
    return false
  end
  if playerActState ~= PopularHomePKMacros.ENUM_PLAYER_STATE.PK then
    log(bWriteLog and "logic_popular_home_pk:CanShowTipsEntry, return false not in pk time")
    return false
  end
  return true
end
function logic_popular_home_pk:GetActConfig()
  if not self.actTableConfig then
    log(bWriteLog and "logic_popular_home_pk:GetActConfig, self.actTableConfig is nil")
    return
  end
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  if PopularityHomePKHandler.bGMTest then
    local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
    return logic_popular_home_pk_util.GetGMPkConfig()
  end
  for _, actCfg in pairs(self.actTableConfig) do
    if _IsMatchVersionAndAppId(actCfg) and _IsMatchTime(actCfg) then
      return actCfg
    end
  end
  log(bWriteLog and "logic_popular_home_pk:GetActConfig, not _IsMatchVersionAndAppId and not _IsMatchTime")
  return nil
end
function logic_popular_home_pk:GetRecentSegmentInfo()
  return self.recentSegmentInfo
end
function logic_popular_home_pk:UpdateMyHomePkData(ret_data)
  if not self.myHomePkData then
    return
  end
  self.myHomePkData = ret_data
end
function logic_popular_home_pk:GetHomePkData(uid)
  log(bWriteLog and "logic_popular_home_pk:GetHomePkData uid:" .. tostring(uid))
  uid = tonumber(uid)
  if uid == tonumber(DataMgr.roleData.uid) then
    return self.myHomePkData
  end
  return self.otherHomePkData and self.otherHomePkData[uid]
end
function logic_popular_home_pk:ClearPKData(uid)
  if self.otherHomePkData then
    self.otherHomePkData[uid] = nil
  end
end
function logic_popular_home_pk:GetCalculateSeasonID()
  local calculateSeasonID = 1
  if not self.actTableConfig then
    log(bWriteLog and "logic_popular_home_pk:GetCalculateSeasonID return no self.actTableConfig")
    return calculateSeasonID
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_popular_home_pk:GetCalculateSeasonID, curTime is: " .. tostring(curTime))
  for seasonIndex, actCfg in pairs(self.actTableConfig) do
    if _IsMatchVersionAndAppId(actCfg) then
      if curTime >= actCfg.act_start_ts and curTime < actCfg.act_end_ts then
        log(bWriteLog and "logic_popular_home_pk:GetCalculateSeasonID\239\188\140 return inAct seasonIndex" .. tostring(seasonIndex))
        return seasonIndex
      elseif curTime > actCfg.act_end_ts and calculateSeasonID < seasonIndex then
        calculateSeasonID = seasonIndex
      end
    end
  end
  log(bWriteLog and "logic_popular_home_pk:GetCalculateSeasonID\239\188\140calculateSeasonID is:" .. tostring(calculateSeasonID))
  return calculateSeasonID
end
function logic_popular_home_pk:IsShowLevelAwardRedDot()
  if not self.myHomePkData then
    return false
  end
  local rewardStatusList = self.myHomePkData.pk_level_awards
  if not rewardStatusList then
    log(bWriteLog and "logic_popular_home_pk:IsShowAwardRedDot not rewardStatusList")
    return false
  end
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  for _, status in pairs(rewardStatusList) do
    if status == PopularHomePKMacros.ENUM_PK_LEVEL_AWARD_STATUS.UNLOCK then
      return true
    end
  end
  return false
end
function logic_popular_home_pk:IsNeedRequestSegmentData()
  local actConfig = self:GetActConfig()
  if not actConfig then
    log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData, return false\239\188\140 actState close")
    return false
  end
  local seasonIndex = 0
  local bHasSigned = true
  if self.myHomePkData then
    seasonIndex = self.myHomePkData.season_idx
    bHasSigned = 0 < self.myHomePkData.enroll_time
  end
  if not bHasSigned then
    log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData unsigned")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData, curTime is:" .. tostring(curTime))
  local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
  local roundId, roundCfg = logic_popular_home_pk_util.GetPKRoundIdAndConfig()
  log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData, roundId is:" .. tostring(roundId))
  if not roundId or roundId <= 0 then
    local lastRoundId = #actConfig.round_list
    local lastRoundCfg = actConfig.round_list[lastRoundId]
    if curTime > lastRoundCfg.end_segment_ts and not self:IsSegmentShowed(seasonIndex, lastRoundId) then
      log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData, lastRoundId is " .. tostring(lastRoundId))
      return true
    else
      log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData, return false no last round")
      return false
    end
  end
  if 1 < roundId and not self:IsSegmentShowed(seasonIndex, roundId - 1) then
    log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData, return true season_index is:" .. tostring(seasonIndex))
    return true
  end
  if curTime > roundCfg.start_segment_ts and not self:IsSegmentShowed(seasonIndex, roundId) then
    log(bWriteLog and "logic_popular_home_pk:IsNeedRequestSegmentData, return true curTime is:" .. tostring(curTime))
    return true
  end
  return false
end
function logic_popular_home_pk:IsSegmentShowed(seasonIndex, roundId)
  if not seasonIndex or not roundId then
    log(bWriteLog and "logic_popular_home_pk:IsSegmentShowed seasonIndex is:" .. tostring(seasonIndex) .. "; roundId is:" .. tostring(roundId))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomePkResultData)
  local TableUtil = require("common.table_util")
  local showResultData = TableUtil.GetTableValue(cacheData, "showPkResult", seasonIndex, roundId)
  if showResultData then
    log_tree(bWriteLog and "logic_popular_home_pk:IsSegmentShowed, cacheData is:", cacheData)
    return true
  end
  return false
end
function logic_popular_home_pk:GetPKRankRewardInfo()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = RankConfig.ScoreType.home_pk_season_rating
  local RankRewardTable = CDataTable.GetTable("RankRewardTable")
  local rankAwardData = {}
  for k, v in pairs(RankRewardTable) do
    if v.RankType == popularityRankID then
      local limitTime1 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemTimeLimit1)
      local limitTime2 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemTimeLimit2)
      local limitTime3 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType3, v.RewardItemTimeLimit3)
      local awardInfo = {
        RankCeiling = v.RankCeilling,
        RankFloor = v.RankFloor,
        RewardItemID1 = v.RewardItemID1,
        RewardItemCnt1 = v.RewardItemCnt1,
        RewardItemLimitTime1 = limitTime1,
        RewardItemID2 = v.RewardItemID2,
        RewardItemCnt2 = v.RewardItemCnt2,
        RewardItemLimitTime2 = limitTime2,
        RewardItemID3 = v.RewardItemID3,
        RewardItemCnt3 = v.RewardItemCnt3,
        RewardItemTimeLimit3 = limitTime3
      }
      table.insert(rankAwardData, awardInfo)
    end
  end
  return rankAwardData
end
function logic_popular_home_pk:GetCurrentPKRewardInfo(rank, rankType)
  if not rank then
    log(bWriteLog and "logic_popular_gift_pk:GetCurrentPKRewardInfo not rank")
    return {}
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local RankRewardTable = CDataTable.GetTable("RankRewardTable")
  local rankAwardData = {}
  for k, v in pairs(RankRewardTable) do
    if v.RankType == rankType and rank >= v.RankCeilling and rank <= v.RankFloor then
      local limitTime1 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemTimeLimit1)
      local limitTime2 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemTimeLimit2)
      local limitTime3 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType3, v.RewardItemTimeLimit3)
      rankAwardData = {
        RewardItemID1 = v.RewardItemID1,
        RewardItemCnt1 = v.RewardItemCnt1,
        RewardItemLimitTime1 = limitTime1,
        RewardItemID2 = v.RewardItemID2,
        RewardItemCnt2 = v.RewardItemCnt2,
        RewardItemLimitTime2 = limitTime2,
        RewardItemID3 = v.RewardItemID3,
        RewardItemCnt3 = v.RewardItemCnt3,
        RewardItemTimeLimit3 = limitTime3
      }
      break
    end
  end
  return rankAwardData
end
function logic_popular_home_pk:GetSceneData(uid)
  if not self.manorSceneData then
    log(bWriteLog and "logic_popular_home_pk:GetSceneData not self.manorSceneData")
    return nil
  end
  return self.manorSceneData[uid]
end
function logic_popular_home_pk:GetTeamBasePointConfig()
  return self.HomeBasicPointConfig
end
function logic_popular_home_pk:GetRecordList()
  return self.recordList or {}
end
function logic_popular_home_pk:ResetRecordList()
  self.recordList = nil
end
function logic_popular_home_pk:GetRankDataList()
  return self.rankDataList or {}
end
function logic_popular_home_pk:GetMyRankData()
  return self.myRankInfo or {}
end
function logic_popular_home_pk:GetMyStyleRankData()
  return self.myStyleRankInfo or {}
end
function logic_popular_home_pk:GetSquareRankDataList()
  return self.squareRankDataList or {}
end
function logic_popular_home_pk:GetStyleRankDataList()
  return self.styleRankDataList or {}
end
function logic_popular_home_pk:GetSquareRecommendRankDataList()
  return self.squareRecommendRankDataList or {}
end
function logic_popular_home_pk:GetSquareFriendRankDataList()
  return self.squareFriendRankDataList or {}
end
function logic_popular_home_pk:ClearSquareFriendRankDataList()
  self.squareFriendRankDataList = {}
end
function logic_popular_home_pk:GetSurfaceUrl(uid)
  if self.surfaceThumbUrls and self.surfaceThumbUrls[uid] then
    return self.surfaceThumbUrls[uid], true
  elseif self.surfaceUrls and self.surfaceUrls[uid] then
    return self.surfaceUrls[uid], false
  end
  return nil, false
end
function logic_popular_home_pk:UpdateSurfaceUrl(ret_data_list, ret_thumbnail_data)
  if not self.surfaceUrls then
    self.surfaceUrls = {}
  end
  if not self.surfaceThumbUrls then
    self.surfaceThumbUrls = {}
  end
  if ret_data_list then
    for k, v in pairs(ret_data_list) do
      self.surfaceUrls[k] = v
    end
  end
  if ret_thumbnail_data then
    for k, v in pairs(ret_thumbnail_data) do
      self.surfaceThumbUrls[k] = v
    end
  end
end
function logic_popular_home_pk:IsReceivedSceneData(uid)
  if self.receiveSceneUIDs and self.receiveSceneUIDs[uid] then
    return true
  end
  return false
end
function logic_popular_home_pk:IsHomePKSeasonRank(rankID)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  return rankID == RankConfig.ScoreType.home_pk_season_rating
end
function logic_popular_home_pk:IsHomePKSquareRank(rankID)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  return rankID == RankConfig.ScoreType.home_pk_square_rating
end
function logic_popular_home_pk:IsHomePKStyleRank(rankID)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  return rankID == RankConfig.ScoreType.manor_style_select_rating
end
function logic_popular_home_pk:IsHomePkDataValid(uid, interval)
  uid = tonumber(uid)
  if not self.reqPkDataTimeRecord or not self.reqPkDataTimeRecord[uid] then
    log(bWriteLog and "logic_popular_home_pk:IsHomePkDataValid return false, no reqPkDataTimeRecord")
    return false
  end
  local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
  return logic_popular_home_pk_util.CheckInValidInterval(self.reqPkDataTimeRecord[uid], interval)
end
function logic_popular_home_pk:IsSelfHasEnemy()
  if not self.myHomePkData then
    log(bWriteLog and "logic_popular_home_pk:IsSelfHasEnemy return false, no myHomePkData")
    return false
  end
  local enemyUID = self.myHomePkData.right and self.myHomePkData.right.uid
  if not enemyUID or enemyUID <= 0 then
    log(bWriteLog and "logic_popular_home_pk:IsSelfHasEnemy return false, no enemyUID")
    return false
  end
  return true
end
function logic_popular_home_pk:IsOtherHasEnemy(uid)
  if not self.otherHomePkData or not self.otherHomePkData[uid] then
    log(bWriteLog and "logic_popular_home_pk:IsOtherHasEnemy return false, no otherHomePkData")
    return false
  end
  local otherEnemyUID = self.otherHomePkData[uid].right and self.otherHomePkData[uid].right.uid
  if not otherEnemyUID or otherEnemyUID <= 0 then
    log(bWriteLog and "logic_popular_home_pk:IsOtherHasEnemy return false, no otherEnemyUID")
    return false
  end
  return true
end
function logic_popular_home_pk:CheckIsNew(uid1, uid2, existedList)
  for _, v in pairs(existedList) do
    if tonumber(uid1) == tonumber(v.uid2) and tonumber(uid2) == tonumber(v.uid1) then
      return false
    end
  end
  return true
end
function logic_popular_home_pk:CheckShowHomePKModuleTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomePkModuleTips)
  if data and data.hasShow then
    return false
  end
  return true
end
function logic_popular_home_pk:SetHomePKModuleAlreadyShow()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = {hasShow = true}
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eHomePkModuleTips)
end
function logic_popular_home_pk:RefreshFriendRankList()
  local HomePK_Selection_UIBP = UIManager.GetUI(UIManager.UI_Config.HomePK_Selection_UIBP)
  if HomePK_Selection_UIBP and HomePK_Selection_UIBP.LoopScrollGrid_Vote then
    HomePK_Selection_UIBP.LoopScrollGrid_Vote:RefreshAllItems()
  end
end
function logic_popular_home_pk:RequestGetHomePKData(uid, interval)
  log_format(bWriteLog and "logic_popular_home_pk:RequestGetHomePKData, uid is %s", tostring(uid))
  if self:IsHomePkDataValid(uid, interval) then
    log(bWriteLog and "logic_popular_home_pk:RequestGetHomePKData, data is valid")
    return
  end
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  local logic_popular_home_pk_util = require("client.slua.logic.popular_home_pk.logic_popular_home_pk_util")
  local actState = logic_popular_home_pk_util.GetActState()
  if actState == PopularHomePKMacros.ENUM_STATE.CLOSE then
    log(bWriteLog and "logic_popular_home_pk:RequestGetHomePKData, act is close")
    return
  end
  uid = tonumber(uid)
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  if uid == tonumber(DataMgr.roleData.uid) then
    PopularityHomePKHandler.send_get_manor_pk_data_req()
  else
    if actState ~= PopularHomePKMacros.ENUM_STATE.PK then
      log(bWriteLog and "logic_popular_home_pk:RequestGetHomePKData, act is not pk")
      return
    end
    PopularityHomePKHandler.send_get_manor_pk_detail_req(uid)
  end
  if not self.reqPkDataTimeRecord then
    self.reqPkDataTimeRecord = {}
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.OSTime()
  self.reqPkDataTimeRecord[uid] = nowTime
  log(bWriteLog and "logic_popular_home_pk:RequestGetHomePKData, nowTime is " .. tostring(nowTime))
end
function logic_popular_home_pk:ReqGetActConfigTable()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.manor_pk_basic_point_cfg, function(_, configData)
    self.HomeBasicPointConfig = configData
  end)
  BasicDataServerTable:GetOrReqData(data_config_marco.manor_pk_act_cfg, function(_, configData)
    log(bWriteLog and "logic_popular_home_pk.ReqGetActConfigTable, configData")
    self.actTableConfig = configData
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_CONFIG_UPDATE)
  end)
end
function logic_popular_home_pk.ReqResultData()
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  if not logic_popular_home_pk:IsNeedRequestSegmentData() then
    return
  end
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  PopularityHomePKHandler.send_get_manor_pk_records_req(PopularHomePKMacros.ENUM_PK_RECORD_SOURCE.RECENT)
end
function logic_popular_home_pk:on_get_manor_pk_records_rsp(source, record_list)
  local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
  if source == PopularHomePKMacros.ENUM_PK_RECORD_SOURCE.ALL then
    self.recordList = record_list
  elseif source == PopularHomePKMacros.ENUM_PK_RECORD_SOURCE.RECENT and record_list then
    for _, v in pairs(record_list) do
      self.recentSegmentInfo = v
    end
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_GET_PK_RECORD_LIST, source)
end
function logic_popular_home_pk:on_get_manor_pk_data_rsp(ret_data)
  if not self.myHomePkData then
    self.myHomePkData = ret_data
  else
    self:UpdateMyHomePkData(ret_data)
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_DATA_UPDATE, tonumber(DataMgr.roleData.uid))
end
function logic_popular_home_pk:on_manor_pk_enroll_rsp(ret_data)
  self:UpdateMyHomePkData(ret_data)
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_ENROLL_STATE_CHANGE)
end
function logic_popular_home_pk:on_get_manor_pk_detail_rsp(target_uid, ret_data)
  if ret_data then
    if not self.otherHomePkData then
      self.otherHomePkData = {}
    end
    self.otherHomePkData[target_uid] = ret_data
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_DATA_UPDATE, target_uid)
  log(bWriteLog and "logic_popular_home_pk:on_get_manor_pk_detail_rsp, target_uid is: " .. tostring(target_uid))
end
function logic_popular_home_pk:on_manor_pk_vote_notify(ntf_info)
  if not ntf_info then
    return
  end
  local TableUtil = require("common.table_util")
  local voteUID = ntf_info.vote_info.uid
  local enemyUID = ntf_info.enemy_info.uid
  local hidenEnemyUID = ntf_info.hiden_enemy_info and ntf_info.hiden_enemy_info.uid
  if self.myHomePkData then
    local leftUID = TableUtil.GetTableValue(self.myHomePkData, "left", "uid")
    local rightUID = TableUtil.GetTableValue(self.myHomePkData, "right", "uid")
    if voteUID == leftUID and enemyUID == rightUID then
      self:UpdateData(self.myHomePkData.left, ntf_info.vote_info)
      self:UpdateData(self.myHomePkData.right, ntf_info.enemy_info)
    elseif enemyUID == leftUID and voteUID == rightUID then
      self:UpdateData(self.myHomePkData.left, ntf_info.enemy_info)
      self:UpdateData(self.myHomePkData.right, ntf_info.vote_info)
    end
    if hidenEnemyUID then
      log(bWriteLog and "logic_popular_home_pk:on_manor_pk_vote_notify update self.myHomePkData, exist hiden enemy")
      if voteUID == leftUID and hidenEnemyUID == rightUID then
        self:UpdateData(self.myHomePkData.left, ntf_info.vote_info)
        self:UpdateData(self.myHomePkData.right, ntf_info.hiden_enemy_info)
      elseif hidenEnemyUID == leftUID and voteUID == rightUID then
        self:UpdateData(self.myHomePkData.left, ntf_info.hiden_enemy_info)
        self:UpdateData(self.myHomePkData.right, ntf_info.vote_info)
      end
    end
  end
  local voteRightUID = TableUtil.GetTableValue(self.otherHomePkData, voteUID, "right", "uid")
  local enemyRightUID = TableUtil.GetTableValue(self.otherHomePkData, enemyUID, "right", "uid")
  local hidenRightUID = TableUtil.GetTableValue(self.otherHomePkData, hidenEnemyUID, "right", "uid")
  if self.otherHomePkData and voteRightUID == enemyUID then
    self:UpdateData(self.otherHomePkData[voteUID].left, ntf_info.vote_info)
    self:UpdateData(self.otherHomePkData[voteUID].right, ntf_info.enemy_info)
  end
  if self.otherHomePkData and enemyRightUID == voteUID then
    self:UpdateData(self.otherHomePkData[enemyUID].left, ntf_info.enemy_info)
    self:UpdateData(self.otherHomePkData[enemyUID].right, ntf_info.vote_info)
  end
  if hidenEnemyUID then
    log(bWriteLog and "logic_popular_home_pk:on_manor_pk_vote_notify update self.otherHomePkData, exist hiden enemy")
    if self.otherHomePkData and voteRightUID == hidenEnemyUID then
      self:UpdateData(self.otherHomePkData[voteUID].left, ntf_info.vote_info)
      self:UpdateData(self.otherHomePkData[voteUID].right, ntf_info.hiden_enemy_info)
    end
    if self.otherHomePkData and hidenRightUID == voteUID then
      self:UpdateData(self.otherHomePkData[hidenEnemyUID].left, ntf_info.hiden_enemy_info)
      self:UpdateData(self.otherHomePkData[hidenEnemyUID].right, ntf_info.vote_info)
    end
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_VOTE_NOTIFY)
end
function logic_popular_home_pk:UpdateData(cacheData, newData)
  if not cacheData or not newData then
    return
  end
  for key, value in pairs(newData) do
    cacheData[key] = value
  end
end
function logic_popular_home_pk:on_manor_pk_receive_awards_rsp(level, awards_list, items_list)
  if self.myHomePkData and self.myHomePkData.pk_level_awards then
    self.myHomePkData.pk_level_awards = awards_list
  end
  local itemList = {}
  for k, v in pairs(items_list) do
    table.insert(itemList, {
      res_id = k,
      count = v.count,
      valid_hours = v.valid_hours
    })
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList)
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_RECEIVE_LEVEL_REWARD)
  if not self:IsShowLevelAwardRedDot() then
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_REMOVE_REDDOT)
  end
end
function logic_popular_home_pk:ReqManorScene(uid)
  log(bWriteLog and "logic_popular_home_pk:ReqManorScene uid = " .. tostring(uid))
  if self:IsReceivedSceneData(uid) then
    log(bWriteLog and "logic_popular_home_pk:ReqManorScene has received data")
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_GET_MANOR_SCENE)
    return
  end
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  PopularityHomePKHandler.send_manor_scene_req(uid)
end
function logic_popular_home_pk:ProcManorSceneRsp(err_code, uid, scene)
  if not self.manorSceneData then
    self.manorSceneData = {}
  end
  if not self.receiveSceneUIDs then
    self.receiveSceneUIDs = {}
  end
  if not uid then
    log_warning("logic_popular_home_pk:ProcManorSceneRsp not uid")
    return
  end
  self.receiveSceneUIDs[uid] = true
  self.manorSceneData[uid] = scene
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_GET_MANOR_SCENE)
end
function logic_popular_home_pk:ReqSeasonRank()
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  if PopularityHomePKHandler.bGMTest then
    local fakeData = {
      uid = DataMgr.roleData.uid,
      score = 189,
      rank_no = 1
    }
    local GMList = {}
    for i = 1, 10 do
      table.insert(GMList, fakeData)
    end
    self:ProcSeasonRankRsp(0, GMList)
    return
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  RankHandler.send_get_topn_rank(0, RankConfig.ScoreType.home_pk_season_rating, 1)
end
function logic_popular_home_pk:ProcSeasonRankRsp(res, rank_data_list)
  log(bWriteLog and "logic_popular_home_pk:ProcSeasonRankRsp res = " .. tostring(res))
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SEASON_RANK)
    return
  end
  log_tree("logic_popular_home_pk:ProcSeasonRankRsp rank_data_list", rank_data_list)
  self.rankDataList = rank_data_list
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SEASON_RANK)
end
function logic_popular_home_pk:ReqSelfSeasonRank()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank("PopularityHomePK", 0, tonumber(DataMgr.roleData.uid), RankConfig.ScoreType.home_pk_season_rating)
end
function logic_popular_home_pk:ProcSelfSeasonRankRsp(rank_source, res, rank_info)
  if rank_source ~= "PopularityHomePK" then
    log(bWriteLog and "logic_popular_home_pk:ProcSelfSeasonRankRsp rank_source = " .. tostring(rank_source))
    return
  end
  if res ~= 0 then
    log(bWriteLog and "logic_popular_home_pk:ProcSelfSeasonRankRsp res = " .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SELF_SEASON_RANK)
    return
  end
  log_tree("logic_popular_home_pk:ProcSelfSeasonRankRsp rank_info", rank_info)
  self.myRankInfo = rank_info
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SELF_SEASON_RANK)
end
function logic_popular_home_pk:ReqSelfStyleRank()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank("PopularityHomePKStyle", 0, tonumber(DataMgr.roleData.uid), RankConfig.ScoreType.manor_style_select_rating)
end
function logic_popular_home_pk:ProcSelfStyleRankRsp(rank_source, res, rank_info)
  if rank_source ~= "PopularityHomePKStyle" then
    log(bWriteLog and "logic_popular_home_pk:ProcSelfStyleRankRsp rank_source = " .. tostring(rank_source))
    return
  end
  if res ~= 0 then
    log(bWriteLog and "logic_popular_home_pk:ProcSelfStyleRankRsp res = " .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SELF_STYLE_RANK)
    return
  end
  log_tree("logic_popular_home_pk:ProcSelfStyleRankRsp rank_info", rank_info)
  self.myStyleRankInfo = rank_info
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SELF_STYLE_RANK)
end
function logic_popular_home_pk:ReqSquareRank()
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  if PopularityHomePKHandler.bGMTest then
    local fakeData = {
      uid = DataMgr.roleData.uid,
      score = 189,
      rank_no = 1,
      ext_data = {
        enemy_uid = DataMgr.roleData.uid,
        enemy_score = 190
      }
    }
    local GMList = {}
    for i = 1, 10 do
      table.insert(GMList, fakeData)
    end
    self:ProcSquareRank(0, GMList)
    return
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  RankHandler.send_get_topn_rank(0, RankConfig.ScoreType.home_pk_square_rating, 1)
end
function logic_popular_home_pk:ProcSquareRank(res, rank_data_list)
  log(bWriteLog and "logic_popular_home_pk:ProcSquareRank res = " .. tostring(res))
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SQUARE_RANK)
    return
  end
  local uidRecordList = {}
  local listRemoveRepeat = {}
  for _, v in pairs(rank_data_list or {}) do
    v.ext_data = slua.LuaArchiverDecode(LuaStateWrapper, v.ext_data)
    if self:CheckIsNew(v.uid, v.ext_data.enemy_uid, uidRecordList) then
      table.insert(listRemoveRepeat, v)
      local record = {
        uid1 = v.uid,
        uid2 = v.ext_data.enemy_uid
      }
      table.insert(uidRecordList, record)
    end
  end
  log_tree("logic_popular_home_pk:ProcSquareRank rank_data_list", rank_data_list)
  self.squareRankDataList = listRemoveRepeat
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_SQUARE_RANK)
end
function logic_popular_home_pk:ReqStyleRank()
  local RankHandler = require("client.network.Protocol.RankHandler")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  RankHandler.send_get_topn_rank(0, RankConfig.ScoreType.manor_style_select_rating, 1)
end
function logic_popular_home_pk:ProcStyleRank(res, rank_data_list)
  log(bWriteLog and "logic_popular_home_pk:ProcStyleRank res = " .. tostring(res))
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_STYLE_RANK)
    return
  end
  log_tree("logic_popular_home_pk:ProcStyleRank rank_data_list", rank_data_list)
  self.styleRankDataList = rank_data_list
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_STYLE_RANK)
end
function logic_popular_home_pk:ProcSurfaceUrlRsp(ret_data_list, ret_thumbnail_data)
  self:UpdateSurfaceUrl(ret_data_list, ret_thumbnail_data)
  local refreshUIDInfo = {}
  for k, _ in pairs(ret_data_list) do
    refreshUIDInfo[k] = true
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_GET_SURFACE_URL, refreshUIDInfo)
end
function logic_popular_home_pk:send_manor_pk_recommend_req()
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  PopularityHomePKHandler.send_manor_pk_recommend_req()
end
function logic_popular_home_pk:on_manor_pk_recommend_rsp(err, data_list)
  if err ~= 0 then
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_RECOMMEND_SQUARE_RANK)
    return
  end
  local uidRecordList = {}
  local listRemoveRepeat = {}
  for _, v in pairs(data_list or {}) do
    if self:CheckIsNew(v.uid, v.ext_data.enemy_uid, uidRecordList) then
      table.insert(listRemoveRepeat, v)
      local record = {
        uid1 = v.uid,
        uid2 = v.ext_data.enemy_uid
      }
      table.insert(uidRecordList, record)
    end
  end
  self.squareRecommendRankDataList = listRemoveRepeat
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_RECOMMEND_SQUARE_RANK)
end
function logic_popular_home_pk:send_get_manor_pk_info_by_uid_list_req(req_uid_list)
  local PopularityHomePKHandler = require("client.network.Protocol.PopularityHomePKHandler")
  PopularityHomePKHandler.send_get_manor_pk_info_by_uid_list_req(req_uid_list)
end
function logic_popular_home_pk:on_get_manor_pk_info_by_uid_list_rsp(err, data_list)
  if err ~= 0 then
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_FRIEND_SQUARE_RANK)
    return
  end
  local flag = false
  if not self.squareFriendRankDataList or #self.squareFriendRankDataList == 0 then
    flag = true
  end
  local uidRecordList = {}
  for _, v in pairs(data_list or {}) do
    if self:CheckIsNew(v.uid, v.ext_data.enemy_uid, uidRecordList) then
      table.insert(self.squareFriendRankDataList, v)
      local record = {
        uid1 = v.uid,
        uid2 = v.ext_data.enemy_uid
      }
      table.insert(uidRecordList, record)
    end
  end
  if flag then
    EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_FRIEND_SQUARE_RANK)
  else
    self:RefreshFriendRankList()
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_home_pk = class(CModuleBase, nil, logic_popular_home_pk)
return Clogic_popular_home_pk