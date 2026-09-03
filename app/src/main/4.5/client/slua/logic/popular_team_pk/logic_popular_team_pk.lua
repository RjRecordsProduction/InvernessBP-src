local logic_popular_team_pk = {}
function logic_popular_team_pk:DefineAndResetData()
  self.actTableConfig = nil
  self.teamBasicPointConfig = nil
  self.resRewardStatus = nil
  self.myTeamPkData = nil
  self.otherTeamPkData = nil
  self.familyTeamPkInfo = nil
  self.recentSegmentInfo = nil
  self.recordList = nil
  self.isShowTickOuTips = nil
  self.reqPkDataTimeRecord = nil
  self.lastReqEnterRecommendTime = nil
  self.lastReqRecommendListTime = nil
  self.requestTeamMemberTimeRecord = nil
  self.teamMemberInfo = nil
  self.friendTeamMemberUidList = nil
  self.lastReqTeamMemberTime = nil
  self.recommendTeamMemberUidList = nil
end
local _IsMatchVersionAndAppId = function(actData)
  local version_util = require("client.common.version_util")
  local curVersion = Client.GetAppVersion()
  if not actData.cli_ver_str or not version_util.HigherVersion(curVersion, actData.cli_ver_str) then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:_IsMatchVersionAndAppId, return false and actData.cli_ver_str is:" .. tostring(actData.cli_ver_str) .. ";curVersion is: " .. tostring(curVersion))
    return false
  end
  local gameId = Client.GetITopGameId()
  if actData.game_app_list then
    if actData.game_app_list[gameId] and actData.game_app_list[gameId] == 1 then
      return true
    end
    log_tree(bWriteLog and "[v_wllwu] _IsMatchVersionAndAppId return false, actData.game_app_list is:", actData.game_app_list)
    return false
  end
  return true
end
local _IsMatchTime = function(actData)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] logic_popular_team_pk:_IsMatchTime, curTime is: " .. tostring(curTime))
  if curTime < actData.act_start_ts or curTime >= actData.act_end_ts then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:_IsMatchTime, return false")
    return false
  end
  return true
end
function logic_popular_team_pk:_AddTeamMemberList(uid, memberMap, isFriend)
  if not uid then
    return
  end
  if not memberMap or not next(memberMap) then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:_AddTeamMemberList empty memberData, uid is:" .. tostring(uid) .. ", isFriend:" .. tostring(isFriend))
    if not isFriend then
      return
    end
  end
  local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
  local uidList = logic_popular_team_pk_util.GetTeamMemberUidList(memberMap) or {}
  if isFriend then
    self.friendTeamMemberUidList = self.friendTeamMemberUidList or {}
    if #uidList <= 0 then
      uidList[1] = uid
    end
    self.friendTeamMemberUidList[uid] = uidList
  else
    self.recommendTeamMemberUidList = self.recommendTeamMemberUidList or {}
    self.recommendTeamMemberUidList[uid] = uidList
  end
end
function logic_popular_team_pk:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_POPULARITY_TEAMPK_MAIN, self.OnJumpPKMainUI, self)
end
function logic_popular_team_pk:OnLogOut()
  self:DefineAndResetData()
end
function logic_popular_team_pk:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    self:DefineAndResetData()
  elseif nextState == GameStatus.Lobby then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:OnPostSwitchGameStatus enter lobby")
    self:AutoReqGetActConfigTable()
  end
end
function logic_popular_team_pk:AutoReqGetActConfigTable()
  if self.actTableConfig then
    return
  end
  self:AddTimerOnce(30, function()
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:AutoReqGetActConfigTable timer end")
    if not self.actTableConfig then
      log(bWriteLog and "[v_wllwu] logic_popular_team_pk:AutoReqGetActConfigTable enter lobby send request")
      self:ReqGetActConfigTable()
    end
  end)
end
function logic_popular_team_pk:OnJumpPKMainUI(_, _, vars)
  local uid = vars and vars.uid
  log(bWriteLog and "[v_wllwu] logic_popular_team_pk:OnJumpPKMainUI, uid is:" .. tostring(uid))
  if not GameStatus.IsInLobbyOrMainCity() then
    ShowNotice(33631)
    return
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  local PopularityMacros = require("client.slua.logic.person_space.popularity_macro")
  RoleInfoPopularitySystem.OpenPopularityUI(uid or tonumber(DataMgr.roleData.uid), PopularityMacros.ENUM_TAB_TYPE.PopularityTeamPK)
end
function logic_popular_team_pk:GetNetActTableConfig()
  return self.actTableConfig
end
function logic_popular_team_pk:IsNeedRequestActConfig()
  if self.actTableConfig == nil then
    return true
  end
  return false
end
function logic_popular_team_pk:IsActSwitchOpen()
  return LobbySystem.CheckOpen(BP_ENUM_POPULAR_TEAM_PK_SWITCH)
end
function logic_popular_team_pk:GetActConfig()
  if not self.actTableConfig then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:GetActConfig, self.actTableConfig is nil")
    return
  end
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  if PopularityTeamPKHandler.bGMTest then
    local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
    return logic_popular_team_pk_util.GetGMPkConfig()
  end
  for _, actCfg in pairs(self.actTableConfig) do
    if _IsMatchVersionAndAppId(actCfg) and _IsMatchTime(actCfg) then
      return actCfg
    end
  end
  return nil
end
function logic_popular_team_pk:GetTeamBasePointConfig()
  return self.teamBasicPointConfig
end
function logic_popular_team_pk:GetRecentSegmentInfo()
  return self.recentSegmentInfo
end
function logic_popular_team_pk:GetTeamPkData(uid)
  if uid == tonumber(DataMgr.roleData.uid) then
    return self.myTeamPkData
  end
  return self.otherTeamPkData and self.otherTeamPkData[uid]
end
function logic_popular_team_pk:GetMyTeamPkData()
  return self.myTeamPkData
end
function logic_popular_team_pk:GetTeamPkSeasonID()
  if self.myTeamPkData and self.myTeamPkData.season_index and self.myTeamPkData.season_index > 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:GetTeamPkSeasonID\239\188\140 season_index is:" .. tostring(self.myTeamPkData.season_index))
    return self.myTeamPkData.season_index
  end
  return self:GetCalculateSeasonID()
end
function logic_popular_team_pk:GetCalculateSeasonID()
  local calculateSeasonID = 1
  if not self.actTableConfig then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:GetCalculateSeasonID return no self.actTableConfig")
    return calculateSeasonID
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] logic_popular_team_pk:GetCalculateSeasonID, curTime is: " .. tostring(curTime))
  for seasonIndex, actCfg in pairs(self.actTableConfig) do
    if _IsMatchVersionAndAppId(actCfg) then
      if curTime >= actCfg.act_start_ts and curTime < actCfg.act_end_ts then
        log(bWriteLog and "[v_wllwu] logic_popular_team_pk:GetCalculateSeasonID\239\188\140 return inAct seasonIndex" .. tostring(seasonIndex))
        return seasonIndex
      elseif curTime > actCfg.act_end_ts and calculateSeasonID < seasonIndex then
        calculateSeasonID = seasonIndex
      end
    end
  end
  log(bWriteLog and "[v_wllwu] logic_popular_team_pk:GetCalculateSeasonID\239\188\140calculateSeasonID is:" .. tostring(calculateSeasonID))
  return calculateSeasonID
end
function logic_popular_team_pk:GetPKTeamID()
  local pkTeamID = 0
  if self.myTeamPkData and self.myTeamPkData.belong_team_id then
    pkTeamID = self.myTeamPkData.belong_team_id
  end
  return pkTeamID
end
function logic_popular_team_pk:GetOtherPKTeamID(uid)
  local otherPkTeamID = 0
  local otherTeamPkData = self.otherTeamPkData and self.otherTeamPkData[uid]
  if otherTeamPkData then
    otherPkTeamID = otherTeamPkData.belong_team_id
  end
  return otherPkTeamID
end
function logic_popular_team_pk:GetPKTeamNickName()
  local nickName = ""
  if self.myTeamPkData and self.myTeamPkData.nick_name and self.myTeamPkData.nick_name ~= "" then
    nickName = self.myTeamPkData.nick_name
  end
  return nickName
end
function logic_popular_team_pk:GetOtherPKTeamNickName(uid)
  local otherNickName = ""
  local otherTeamPkData = self.otherTeamPkData and self.otherTeamPkData[uid]
  if otherTeamPkData then
    otherNickName = otherTeamPkData.nick_name
  end
  return otherNickName
end
function logic_popular_team_pk:IsOtherTeamEnrolled(uid)
  local otherTeamPkData = self.otherTeamPkData and self.otherTeamPkData[uid]
  if not otherTeamPkData then
    return false
  end
  if otherTeamPkData.enroll_time <= 0 then
    return false
  end
  return true
end
function logic_popular_team_pk:GetFamilyPkData(pk_team_id)
  return self.familyTeamPkInfo and self.familyTeamPkInfo[pk_team_id]
end
function logic_popular_team_pk:IsActInPKTime()
  if bWriteLog then
    local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
    if PopularityTeamPKHandler.bGMTest then
      local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
      return PopularityTeamPKHandler.GMActTimeState == PopularTeamPKMacros.ENUM_STATE.PK
    end
  end
  local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
  local id, roundCfg = logic_popular_team_pk_util.GetPKRoundIdAndConfig()
  if not roundCfg then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsActInPKTime return no roundCfg")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime < roundCfg.start_duel_ts or curTime >= roundCfg.end_duel_ts then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsActInPKTime return false, curTime is " .. tostring(curTime) .. " start_duel_ts is " .. tostring(roundCfg.start_duel_ts) .. " end_duel_ts is " .. tostring(roundCfg.end_duel_ts) .. " roundId is " .. tostring(id))
    return false
  end
  return true
end
function logic_popular_team_pk:IsShowPKRedDot()
  if not self.myTeamPkData then
    return
  end
  if self.myTeamPkData.enroll_time > 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsShowRedDot false enrolled")
    return
  end
  local TableUtil = require("common.table_util")
  local teamNum = TableUtil.CountTable(self.myTeamPkData.member_list)
  local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
  local totalTeamNum = PopularTeamPKMacros.CONST_TOTAL_TEAM_NUM
  if teamNum >= totalTeamNum then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsShowRedDot false team full")
    return
  end
  local PopularityMacros = require("client.slua.logic.person_space.popularity_macro")
  local logic_popular_team_pk_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk_tab)
  if not logic_popular_team_pk_tab:IsShowSubTabType(PopularityMacros.ENUM_SUB_TAB_TYPE.Popular_Team_PK) then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsShowRedDot false not show pk tab")
    return
  end
  return self.myTeamPkData.invite_msg_tip
end
function logic_popular_team_pk:IsShowLevelAwardRedDot()
  if not self.myTeamPkData then
    return
  end
  local rewardStatusList = self.myTeamPkData.duel_level_awards
  if not rewardStatusList then
    log(bWriteLog and "logic_popular_team_pk:IsShowAwardRedDot, not rewardStatusList:%s", rewardStatusList)
    return
  end
  local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
  for _, status in pairs(rewardStatusList) do
    if status == PopularTeamPKMacros.ENUM_PK_LEVEL_AWARD_STATUS.UNLOCK then
      return true
    end
  end
  return false
end
function logic_popular_team_pk:IsShowRedDot(ispk)
  if not self:IsActSwitchOpen() then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsShowRedDot, return false switch is close")
    return false
  end
  local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
  local actState = logic_popular_team_pk_util.GetActState()
  local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
  if actState == PopularTeamPKMacros.ENUM_STATE.CLOSE then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsShowRedDot, return false  actState close")
    return false
  end
  if self:IsShowPKRedDot() then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsShowRedDot, show pk reddot")
    return true
  end
  if not ispk and self:IsShowLevelAwardRedDot() then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsShowRedDot, show award reddot")
    return true
  end
  return false
end
function logic_popular_team_pk:RemoveRedDot()
end
function logic_popular_team_pk:UpdateInviteTips(invite_msg_tip)
  if not self.myTeamPkData then
    return
  end
  local beforeData = self.myTeamPkData.invite_msg_tip
  self.myTeamPkData.  if beforeData ~= invite_msg_tip then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_REDDOT_CHANGE)
  end
end
function logic_popular_team_pk:IsNeedRequestSegmentData()
  local actConfig = self:GetActConfig()
  if not actConfig then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsNeedRequestSegmentData, return false actState close ")
    return
  end
  local seasonIndex = 0
  if self.myTeamPkData then
    seasonIndex = self.myTeamPkData.season_index
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsNeedRequestSegmentData, curTime is:" .. tostring(curTime))
  local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
  local roundId, roundCfg = logic_popular_team_pk_util.GetPKRoundIdAndConfig()
  log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsNeedRequestSegmentData, roundId is:" .. tostring(roundId))
  if not roundId or roundId <= 0 then
    local lastRoundId = #actConfig.round_list
    local lastRoundCfg = actConfig.round_list[lastRoundId]
    if curTime > lastRoundCfg.end_segment_ts and not self:IsSegmentShowed(seasonIndex, lastRoundId) then
      log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsNeedRequestSegmentData, lastRoundId is " .. tostring(lastRoundId))
      return true
    else
      log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsNeedRequestSegmentData, return false no last round")
      return false
    end
  end
  if 1 < roundId and not self:IsSegmentShowed(seasonIndex, roundId - 1) then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsNeedRequestSegmentData, return true season_index is:" .. tostring(seasonIndex))
    return true
  end
  if curTime > roundCfg.start_segment_ts and not self:IsSegmentShowed(seasonIndex, roundId) then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsNeedRequestSegmentData, return true curTime is:" .. tostring(curTime))
    return true
  end
  return nil
end
function logic_popular_team_pk:IsSegmentShowed(seasonIndex, roundId)
  if not seasonIndex or not roundId then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsSegmentShowed seasonIndex is:" .. tostring(seasonIndex) .. "; roundId is:" .. tostring(roundId))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPkResultData)
  local TableUtil = require("common.table_util")
  local showResultData = TableUtil.GetTableValue(cacheData, "showPkResult", seasonIndex, roundId)
  if showResultData then
    log_tree(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsSegmentShowed, cacheData is:", cacheData)
    return true
  end
  return nil
end
function logic_popular_team_pk:GetPKRankRewardInfo()
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = RankDataMgr.GetPopularityTeamPKRankID()
  local RankRewardTable = CDataTable.GetTable("RankRewardTable")
  local rankAwardData = {}
  for k, v in pairs(RankRewardTable) do
    if v.RankType == popularityRankID then
      local limitTime1 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemTimeLimit1)
      local limitTime2 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemTimeLimit2)
      local awardInfo = {
        RankCeiling = v.RankCeilling,
        RankFloor = v.RankFloor,
        RewardItemID1 = v.RewardItemID1,
        RewardItemCnt1 = v.RewardItemCnt1,
        RewardItemLimitTime1 = limitTime1,
        RewardItemID2 = v.RewardItemID2,
        RewardItemCnt2 = v.RewardItemCnt2,
        RewardItemLimitTime2 = limitTime2
      }
      table.insert(rankAwardData, awardInfo)
    end
  end
  return rankAwardData
end
function logic_popular_team_pk:GetCurrentPKRewardInfo(rank)
  if not rank then
    log(bWriteLog and "logic_popular_gift_pk:GetCurrentPKRewardInfo not rank")
    return {}
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = RankDataMgr.GetPopularityTeamPKRankID()
  local RankRewardTable = CDataTable.GetTable("RankRewardTable")
  local rankAwardData = {}
  for k, v in pairs(RankRewardTable) do
    if v.RankType == popularityRankID and rank >= v.RankCeilling and rank <= v.RankFloor then
      local limitTime1 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemTimeLimit1)
      local limitTime2 = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemTimeLimit2)
      rankAwardData = {
        RewardItemID1 = v.RewardItemID1,
        RewardItemCnt1 = v.RewardItemCnt1,
        RewardItemLimitTime1 = limitTime1,
        RewardItemID2 = v.RewardItemID2,
        RewardItemCnt2 = v.RewardItemCnt2,
        RewardItemLimitTime2 = limitTime2
      }
      break
    end
  end
  return rankAwardData
end
function logic_popular_team_pk:UpdateMyTeamNickName(nick_name)
  if not self.myTeamPkData then
    return
  end
  self.myTeamPkData.end
function logic_popular_team_pk:IsShowTickOutTips()
  if not self.isShowTickOuTips then
    return
  end
  if self:GetPKTeamID() ~= 0 then
    return
  end
  return true
end
function logic_popular_team_pk:ClearTickOutTipsData()
  self.isShowTickOuTips = nil
end
function logic_popular_team_pk:RemoveInviteMsgRedDot()
  if not self.myTeamPkData or not self.myTeamPkData.invite_msg_tip then
    return
  end
  self.myTeamPkData.invite_msg_tip = false
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_REDDOT_CHANGE)
end
function logic_popular_team_pk:GetRecordList()
  return self.recordList or {}
end
function logic_popular_team_pk:GetRankDataList()
  return self.resRankDataList
end
function logic_popular_team_pk:GetMyRankData()
  return self.resMyRankInfo
end
function logic_popular_team_pk:IsPopularityTeamPKRank(rankID)
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityTeamRankID = RankDataMgr.GetPopularityTeamPKRankID()
  return rankID == popularityTeamRankID
end
function logic_popular_team_pk:IsTeamPkDataValid(uid, interval)
  local teamPKData = self:GetTeamPkData(uid)
  if not teamPKData then
    return false
  end
  if not self.reqPkDataTimeRecord or not self.reqPkDataTimeRecord[uid] then
    return false
  end
  local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
  return logic_popular_team_pk_util.CheckInValidInterval(self.reqPkDataTimeRecord[uid], interval)
end
function logic_popular_team_pk:IsInSameTeam(target_uid)
  if not self.otherTeamPkData or not self.otherTeamPkData[target_uid] then
    log(bWriteLog and "[v_wllwu]  logic_popular_team_pk:IsInSameTeam, no data ")
    return true
  end
  if self.otherTeamPkData[target_uid].is_teammate then
    log(bWriteLog and "[v_wllwu]  logic_popular_team_pk:IsInSameTeam, is_teammate")
    return true
  end
  return false
end
function logic_popular_team_pk:IsMyTeamHasEnemy()
  if not self.myTeamPkData then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsMyTeamHasEnemy return false, no myTeamPkData")
    return
  end
  local enemyTeamId = self.myTeamPkData.enemy_info and self.myTeamPkData.enemy_info.enemy_team_id
  if not enemyTeamId or enemyTeamId <= 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsMyTeamHasEnemy return false, no enemyTeamId")
    return
  end
  return true
end
function logic_popular_team_pk:IsOtherTeamHasEnemy(uid)
  if not self.otherTeamPkData or not self.otherTeamPkData[uid] then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsMyTeamHasEnemy return false, no otherTeamPkData")
    return
  end
  local otherEnemyUID = self.otherTeamPkData[uid].enemy_uid
  if not otherEnemyUID or otherEnemyUID <= 0 then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsMyTeamHasEnemy return false, no otherEnemyUID")
    return
  end
  return true
end
function logic_popular_team_pk:IsApplyJoinTeam(uid)
  if not (self.myTeamPkData and self.myTeamPkData.join_together_uids) or not self.myTeamPkData.join_together_uids[uid] then
    return
  end
  local lastInviteTime = self.myTeamPkData.join_together_uids[uid]
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local interval = curTime - lastInviteTime
  local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
  if interval < PopularTeamPKMacros.CONST_INVITED_INTERVAL_HOURS * 3600 then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:IsApplyJoinTeam, curTime is:" .. tostring(curTime) .. "; interval is : " .. tostring(interval))
    return true
  end
  return false
end
function logic_popular_team_pk:ResetTeamRecordData()
  self.requestTeamMemberTimeRecord = nil
  self.teamMemberInfo = nil
  self.friendTeamMemberUidList = nil
  self.lastReqTeamMemberTime = nil
end
function logic_popular_team_pk:RequestGetTeamPKData(uid)
  if not uid then
    return
  end
  if not self.reqPkDataTimeRecord then
    self.reqPkDataTimeRecord = {}
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.OSTime()
  self.reqPkDataTimeRecord[uid] = nowTime
  log(bWriteLog and "[v_wllwu] logic_popular_team_pk:RequestGetTeamPKData, uid is:" .. tostring(uid) .. " nowTime is " .. tostring(nowTime))
  if uid == tonumber(DataMgr.roleData.uid) then
    self:send_get_psmatch_team_data_req()
  else
    self:send_get_other_psmatch_team_simple_req(uid)
  end
end
function logic_popular_team_pk:ReqGetActConfigTable()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.psmatch_team_basic_point_cfg, function(_, configData)
    self.teamBasicPointConfig = configData
  end)
  BasicDataServerTable:GetOrReqData(data_config_marco.psmatch_team_act_cfg, function(_, configData)
    self.actTableConfig = configData
    EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_CONFIG_UPDATE)
  end)
end
function logic_popular_team_pk:send_get_psmatch_team_data_req()
  local version = 0
  if self.myTeamPkData then
    version = self.myTeamPkData.version or 0
  end
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_get_psmatch_team_data_req(version)
end
function logic_popular_team_pk:on_get_psmatch_team_data_rsp(version, ret_data)
  if not self.myTeamPkData then
    self.myTeamPkData = ret_data
  else
    self:UpdateMyTeamPkData(ret_data)
  end
  self.myTeamPkData.  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_DATA_UPDATE, tonumber(DataMgr.roleData.uid))
end
function logic_popular_team_pk:UpdateMyTeamPkData(ret_data)
  if not self.myTeamPkData then
    return
  end
  for k, v in pairs(ret_data) do
    self.myTeamPkData[k] = v
  end
end
function logic_popular_team_pk:send_psmatch_team_enroll_req(pk_team_id)
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_enroll_req(pk_team_id)
end
function logic_popular_team_pk:on_psmatch_team_enroll_rsp(ret_data)
  self:UpdateMyTeamPkData(ret_data)
  local logic_popular_pk_push = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_push)
  logic_popular_pk_push:UpdateTeamPkMsgWhenEnrolled()
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_ENROLL_STATE_CHANGE)
end
function logic_popular_team_pk:send_get_psmatch_team_cur_pkinfo_req(pk_team_id, target_uid)
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_get_psmatch_team_cur_pkinfo_req(pk_team_id, target_uid)
end
function logic_popular_team_pk:on_get_psmatch_team_cur_pkinfo_rsp(pk_team_id, target_uid, ret_pk_info)
  if not self.familyTeamPkInfo then
    self.familyTeamPkInfo = {}
  end
  self.familyTeamPkInfo[pk_team_id] = ret_pk_info
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_FAMILY_PKINFO_UPDATE)
end
function logic_popular_team_pk:send_psmatch_team_exit_req()
  local teamData = self:GetTeamPkData(tonumber(DataMgr.roleData.uid))
  if not teamData then
    return
  end
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_exit_req(teamData.belong_team_id)
end
function logic_popular_team_pk:on_psmatch_team_exit_rsp(ret_data)
  self:UpdateMyTeamPkData(ret_data)
  self:send_psmatch_team_enter_recommend_req()
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_TEAM_MEMBER_CHANGE)
end
function logic_popular_team_pk:send_psmatch_team_kickout_member_req(member_uid)
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_kickout_member_req(member_uid)
end
function logic_popular_team_pk:on_psmatch_team_kickout_member_rsp(ret_data)
  self:UpdateMyTeamPkData(ret_data)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_TEAM_MEMBER_CHANGE)
end
function logic_popular_team_pk:send_get_psmatch_team_pk_records_req(source)
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_get_psmatch_team_pk_records_req(source)
end
function logic_popular_team_pk:on_get_psmatch_team_pk_records_rsp(source, record_list)
  local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
  if source == PopularTeamPKMacros.ENUM_PK_RECORD_SOURCE.ALL then
    self.recordList = record_list
  elseif source == PopularTeamPKMacros.ENUM_PK_RECORD_SOURCE.RECENT then
    self.recentSegmentInfo = record_list
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_GET_PK_RECORD_LIST, source)
end
function logic_popular_team_pk:send_get_other_psmatch_team_simple_req(target_uid)
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_get_other_psmatch_team_simple_req(target_uid)
end
function logic_popular_team_pk:on_get_other_psmatch_team_simple_rsp(target_uid, ret_data)
  if ret_data then
    if not self.otherTeamPkData then
      self.otherTeamPkData = {}
    end
    self.otherTeamPkData[target_uid] = ret_data
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_DATA_UPDATE, target_uid)
end
function logic_popular_team_pk:on_psmatch_team_member_exit_ntf(ntf_info)
  self:UpdateMyTeamPkData(ntf_info)
  local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
  if ntf_info and ntf_info.reason == PopularTeamPKMacros.ENUM_EXIT_REASON.KICKOUT then
    self.isShowTickOuTips = true
  end
  if ntf_info and ntf_info.member_list then
    local TableUtil = require("common.table_util")
    local teamNum = TableUtil.CountTable(ntf_info.member_list)
    if teamNum <= 1 then
      self:send_psmatch_team_enter_recommend_req()
    end
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_TEAM_MEMBER_CHANGE)
end
function logic_popular_team_pk:on_psmatch_team_member_join_ntf(ntf_info)
  self:UpdateMyTeamPkData(ntf_info)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_TEAM_MEMBER_CHANGE)
end
function logic_popular_team_pk:on_psmatch_team_enroll_success_ntf(ntf_info)
  self:UpdateMyTeamPkData(ntf_info)
  local logic_popular_pk_push = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_push)
  logic_popular_pk_push:UpdateTeamPkMsgWhenEnrolled()
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_ENROLL_STATE_CHANGE)
end
function logic_popular_team_pk:on_psmatch_team_send_gift_notify(ntf_info)
  if not ntf_info then
    return
  end
  local uidList = ntf_info.uid_list
  if uidList then
    local selfUid = tonumber(DataMgr.roleData.uid)
    local teamPkId = ntf_info.send_team_id
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:on_psmatch_team_send_gift_notify, teamPkId is:" .. tostring(teamPkId))
    for uid, newData in pairs(uidList) do
      if teamPkId and self.familyTeamPkInfo and self.familyTeamPkInfo[teamPkId] then
        local familyPkInfo = self.familyTeamPkInfo[teamPkId]
        if familyPkInfo.left_member_list[uid] then
          self:UpdateData(familyPkInfo.left_member_list[uid], newData)
        elseif familyPkInfo.right_member_list[uid] then
          self:UpdateData(familyPkInfo.right_member_list[uid], newData)
        end
      end
      if uid == selfUid then
        if self.myTeamPkData then
          if self.myTeamPkData.member_list[uid] then
            self.myTeamPkData.member_list[uid].cur_devote = newData.cur_devote
          elseif self.myTeamPkData.enemy_info.enemy_member_list[uid] then
            self.myTeamPkData.enemy_info.enemy_member_list[uid].cur_devote = newData.cur_devote
          end
          log(bWriteLog and "[v_wllwu] logic_popular_team_pk:on_psmatch_team_send_gift_notify update selfInfo")
        end
      else
        if self.otherTeamPkData and self.otherTeamPkData[uid] then
          self.otherTeamPkData[uid].cur_devote = newData.cur_devote
          local enemyUid = self.otherTeamPkData[uid].enemy_uid or 0
          if uidList[enemyUid] then
            self.otherTeamPkData[uid].enemy_cur_devote = uidList[enemyUid].cur_devote
          end
        end
        log(bWriteLog and "[v_wllwu] logic_popular_team_pk:on_psmatch_team_send_gift_notify update otherInfo")
      end
    end
  end
  local logic_light_board = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_light_board)
  logic_light_board:SetTeamDevote(ntf_info.team_gift)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_SEND_GIFT_NOTIFY)
end
function logic_popular_team_pk:UpdateData(cacheData, newData)
  if not cacheData or not newData then
    return
  end
  for key, value in pairs(newData) do
    cacheData[key] = value
  end
end
function logic_popular_team_pk:send_psmatch_team_receive_awards_req(level)
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_receive_awards_req(level)
end
function logic_popular_team_pk:on_psmatch_team_receive_awards_rsp(level, awards_list, items_list)
  if self.myTeamPkData and self.myTeamPkData.duel_level_awards then
    self.myTeamPkData.duel_level_awards = awards_list
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
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_RECEIVE_LEVEL_REWARD)
  if not self:IsShowLevelAwardRedDot() then
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_REDDOT_CHANGE)
  end
end
function logic_popular_team_pk:send_get_topn_rank()
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
  local popularityRankID = RankDataMgr.GetPopularityTeamPKRankID()
  RankHandler.send_get_topn_rank(0, popularityRankID, 1)
end
function logic_popular_team_pk:proc_get_topn_rank_rsp(res, rank_data_list)
  log(bWriteLog and "logic_popular_team_pk:proc_get_topn_rank_rsp res = " .. tostring(res))
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_SEASON_RANK)
    return
  end
  log_tree("logic_popular_team_pk:proc_get_topn_rank_rsp rank_data_list", rank_data_list)
  self.resRankDataList = rank_data_list
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_SEASON_RANK)
end
function logic_popular_team_pk:send_get_one_user_rank()
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local popularityRankID = RankDataMgr.GetPopularityTeamPKRankID()
  local RankHandler = require("client.network.Protocol.RankHandler")
  local leaderUId = tonumber(DataMgr.roleData.uid)
  local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
  if self.myTeamPkData and self.myTeamPkData.member_list then
    leaderUId = logic_popular_team_pk_util.GetTeamLeaderUid(self.myTeamPkData.member_list)
  end
  RankHandler.send_get_one_user_rank("PopularityTeamPK", 0, leaderUId, popularityRankID)
end
function logic_popular_team_pk:on_get_one_user_rank_rsp(rank_source, res, rank_info)
  if rank_source ~= "PopularityTeamPK" then
    log(bWriteLog and "logic_popular_team_pk:on_get_one_user_rank_rsp rank_source = " .. tostring(rank_source))
    return
  end
  if res ~= 0 then
    log(bWriteLog and "logic_popular_team_pk:on_get_one_user_rank_rsp res = " .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_SELF_SEASON_RANK)
    return
  end
  log_tree("logic_popular_team_pk:on_get_one_user_rank_rsp rank_info", rank_info)
  self.resMyRankInfo = rank_info
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_SELF_SEASON_RANK)
end
function logic_popular_team_pk:send_psmatch_team_set_ready_req()
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_set_ready_req()
end
function logic_popular_team_pk:on_psmatch_team_set_ready_rsp(update_season)
  if not self.myTeamPkData or not self.myTeamPkData.member_list then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:on_psmatch_team_set_ready_rsp return")
    return
  end
  local member_uid = tonumber(DataMgr.roleData.uid)
  self.myTeamPkData.member_list[member_uid].  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_DATA_UPDATE, member_uid)
end
function logic_popular_team_pk:on_psmatch_team_member_ready_ntf(team_id, member_uid, update_season)
  log(bWriteLog and "[v_wllwu] on_psmatch_team_member_ready_ntf, team_id is:" .. tostring(team_id))
  if not (self.myTeamPkData and self.myTeamPkData.member_list) or not self.myTeamPkData.member_list[member_uid] then
    log(bWriteLog and "[v_wllwu] logic_popular_team_pk:on_psmatch_team_member_ready_ntf return")
    return
  end
  self.myTeamPkData.member_list[member_uid].  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_DATA_UPDATE, member_uid)
end
function logic_popular_team_pk:send_psmatch_team_recommend_list_req()
  local TimeUtil = require("client.common.time_util")
  self.lastReqRecommendListTime = TimeUtil.OSTime()
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_recommend_list_req()
end
function logic_popular_team_pk:on_psmatch_team_recommend_list_rsp(ret_list)
  self.team_recommend_list = ret_list
  self.recommendTeamMemberUidList = {}
  for uid, data in pairs(ret_list) do
    self:_AddTeamMemberList(uid, data)
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_RECOMMEND_LIST)
end
function logic_popular_team_pk:send_psmatch_team_enter_recommend_req()
  local TimeUtil = require("client.common.time_util")
  self.lastReqEnterRecommendTime = TimeUtil.OSTime()
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_enter_recommend_req()
end
function logic_popular_team_pk:get_psmatch_team_member_list_req(uid_list, approach)
  local TimeUtil = require("client.common.time_util")
  self.lastReqTeamMemberTime = TimeUtil.OSTime()
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_get_psmatch_team_member_list_req(uid_list, approach)
end
function logic_popular_team_pk:on_get_psmatch_team_member_list_rsp(uid_list, approach, ret_list)
  self.requestTeamMemberTimeRecord = self.requestTeamMemberTimeRecord or {}
  self.teamMemberInfo = self.teamMemberInfo or {}
  local PopularTeamPKMacros = require("client.slua.logic.popular_team_pk.popular_team_pk_macros")
  local isFriend = approach == PopularTeamPKMacros.ENUM_PK_REQUEST_TEAMLIST_APPROACH.FRIEND
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.OSTime()
  for _, uid in ipairs(uid_list) do
    self.requestTeamMemberTimeRecord[uid] = curTime
    if ret_list and ret_list[uid] then
      self.teamMemberInfo[uid] = ret_list[uid]
    end
    self:_AddTeamMemberList(uid, ret_list[uid], isFriend)
  end
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_TEAMMEMBERINFO_UPDATE)
end
function logic_popular_team_pk:send_psmatch_team_join_together_req(uid_list, way)
  local PopularityTeamPKHandler = require("client.network.Protocol.PopularityTeamPKHandler")
  PopularityTeamPKHandler.send_psmatch_team_join_together_req(uid_list, way)
end
function logic_popular_team_pk:on_psmatch_team_join_together_rsp(join_together_uids)
  if not self.myTeamPkData then
    return
  end
  self.myTeamPkData.  ShowNotice(9836)
  EventSystem:postEvent(EVENTTYPE_POPULAR_TEAMPK, EVENTID_POPULAR_TEAM_PK_INVITE_FRIEND_RSP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_team_pk = class(CModuleBase, nil, logic_popular_team_pk)
return Clogic_popular_team_pk