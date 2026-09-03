local RankDataMgr = {}
local RankConfig = require("client.slua.logic.rank.rank_config")
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
local RankSelectEnum = RankConfig.RankSelectEnum
local MemberEnum = RankConfig.MemberEnum
local PeriodEnum = RankConfig.PeriodEnum
local RegionEnum = RankConfig.RegionEnum
local rankSummaryRspData = {}
local rankSelectZoneId = 1
local rankSelectType = RankSelectEnum.sum
local rankPeriodType = PeriodEnum.total
local rankSelectMember = MemberEnum.single
local rankRegionType = RegionEnum.all
local planPHType = RankConfig.PlanPHEnum.prosperity
local planPHTypeDataFlag = false
local WoWAuthorType = RankConfig.WoWAuthorEnum.level
local weaponRankID = 1
local countryID = 0
local provinceID = 0
local cityID = 0
local lbsMode = false
local _isFpp = function(se)
  if se == RankSelectEnum.fpp_sum then
    return true
  elseif se == RankSelectEnum.fpp_win then
    return true
  elseif se == RankSelectEnum.fpp_beat then
    return true
  elseif se == RankSelectEnum.fpp_total then
    return true
  end
  return false
end
local _isTpp = function(se)
  if se == RankSelectEnum.sum then
    return true
  elseif se == RankSelectEnum.win then
    return true
  elseif se == RankSelectEnum.beat then
    return true
  elseif se == RankSelectEnum.total then
    return true
  end
  return false
end
local _isGift = function(se)
  if se == RankSelectEnum.popularity then
    return true
  elseif se == RankSelectEnum.pround then
    return true
  elseif se == RankSelectEnum.guardian then
    return true
  end
  return false
end
local _isPeakgame = function(rank_type)
  if rank_type == RankSelectEnum.peak then
    return true
  elseif rank_type == RankSelectEnum.peakgame_kd then
    return true
  elseif rank_type == RankSelectEnum.peakgame_win then
    return true
  end
  return false
end
local _isArena = function(rank_type)
  if rank_type == RankSelectEnum.arena then
    return true
  end
  return false
end
local _isWeaponUsageScore = function(rank_type)
  if rank_type == RankSelectEnum.weapon_usage_score then
    return true
  end
  return false
end
function RankDataMgr.GetRankRequireID(rank_type, member_type, period_type, planPH_type)
  local program_type = RankConfig.ProgramVersionEnum.global
  if FuncUtil.IsPlayerJPKR() then
    program_type = RankConfig.ProgramVersionEnum.jpkr
  end
  for id, cfg in pairs(RankConfig.RankRequireConfig) do
    if cfg.rank_type and cfg.rank_type == rank_type then
      local temp = true
      if cfg.member_type and cfg.member_type ~= member_type then
        temp = false
      end
      if cfg.period_type and cfg.period_type ~= period_type then
        temp = false
      end
      if cfg.program_type and cfg.program_type ~= program_type then
        temp = false
      end
      if cfg.planPH_type and cfg.planPH_type ~= planPH_type then
        temp = false
      end
      if temp then
        return id
      end
    end
  end
  return 0
end
function RankDataMgr.GetAchieveRequireID()
  if FuncUtil.IsPlayerJPKR() then
    return RankConfig.ScoreType.achievement_rating_jk
  else
    return RankConfig.ScoreType.achievement_rating
  end
end
function RankDataMgr.GetPopularityPKRankID()
  return RankConfig.ScoreType.popularity_pk_rating
end
function RankDataMgr.GetPopularityTeamPKRankID()
  return RankConfig.ScoreType.popularity_team_pk_rating
end
function RankDataMgr.FilterDifferentPlatforms(uid)
  if rankSelectType ~= RankSelectEnum.upass and rankSelectType ~= RankSelectEnum.achievement then
    return true
  end
  if FuncUtil.IsPlayerJPKR() then
    if FuncUtil.IsUidGlobal(uid) then
      return false
    end
  elseif FuncUtil.IsUidJPKR(uid) then
    return false
  end
  return true
end
function RankDataMgr.ReleaseData()
  local rank_data = require("client.slua.logic.rank.rank_data")
  rank_data.ClearAllData()
  RankDataMgr.SetPlanPHDataFlag(false)
end
function RankDataMgr.GetRankRewardItem(rankType, rankNo, periodType)
  local rewardItemID = 0
  local rewardItemCnt = 0
  local rewardItemLimit = 0
  local scoreType = RankDataMgr.GetRankRequireID(rankType, nil, periodType, nil)
  for _, v in pairs(CDataTable.GetTable("RankRewardTable")) do
    if scoreType == v.RankType and rankNo >= v.RankCeilling and rankNo <= v.RankFloor then
      rewardItemID = v.RewardItemID1
      rewardItemCnt = v.RewardItemCnt1
      rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemTimeLimit1)
    end
  end
  return rewardItemID, rewardItemCnt, rewardItemLimit
end
function RankDataMgr.GetRankRewardItem2(rankType, rankNo, periodType)
  local rewardItemID = 0
  local rewardItemCnt = 0
  local rewardItemLimit = 0
  local scoreType = RankDataMgr.GetRankRequireID(rankType, nil, periodType, nil)
  for _, v in pairs(CDataTable.GetTable("RankRewardTable")) do
    if scoreType == v.RankType and rankNo >= v.RankCeilling and rankNo <= v.RankFloor then
      rewardItemID = v.RewardItemID2
      rewardItemCnt = v.RewardItemCnt2
      rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemTimeLimit2)
    end
  end
  return rewardItemID, rewardItemCnt, rewardItemLimit
end
function RankDataMgr.GetRankRewardItem3(rankType, rankNo, periodType)
  local rewardItemID = 0
  local rewardItemCnt = 0
  local rewardItemLimit = 0
  local scoreType = RankDataMgr.GetRankRequireID(rankType, nil, periodType, nil)
  for _, v in pairs(CDataTable.GetTable("RankRewardTable")) do
    if scoreType == v.RankType and rankNo >= v.RankCeilling and rankNo <= v.RankFloor then
      rewardItemID = v.RewardItemID3
      rewardItemCnt = v.RewardItemCnt3
      rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType3, v.RewardItemTimeLimit3)
    end
  end
  return rewardItemID, rewardItemCnt, rewardItemLimit
end
function RankDataMgr.GetRankRewardItemTime(limit_type, limit_time)
  if not limit_type or limit_type == 0 then
    return limit_time or 0
  end
  if limit_type == 1 then
    return 24
  elseif limit_type == 2 then
    return 168
  elseif limit_type == 3 then
    return 720
  end
  return 0
end
function RankDataMgr.SetSelfRankInfo(rank_No, Score)
  local rank_data = require("client.slua.logic.rank.rank_data")
  rank_data.ChangeSelfRankInfo(rank_No, Score)
end
function RankDataMgr.GetCurrentIntimacyType()
  if rankSelectType == RankSelectEnum.lover then
    return IntimacyConst.EIntimacyType.Lover
  elseif rankSelectType == RankSelectEnum.bestie then
    return IntimacyConst.EIntimacyType.BFF
  elseif rankSelectType == RankSelectEnum.homie then
    return IntimacyConst.EIntimacyType.Bromance
  elseif rankSelectType == RankSelectEnum.bestFriend then
    return IntimacyConst.EIntimacyType.Buddy
  elseif rankSelectType == RankSelectEnum.family then
    return IntimacyConst.EIntimacyType.Family
  end
  log_warning("RankDataMgr.GetCurrentIntimacyType not intimacy rank type")
  return IntimacyConst.EIntimacyType.Lover
end
function RankDataMgr.TxmissionScoreFilter(v, defScore)
  local score = defScore or 0
  if rankSelectType == RankSelectEnum.xmission_raven then
    score = RankDataMgr.GetMetroSummaryScore(v, "cur_profit")
  elseif rankSelectType == RankSelectEnum.xmission_raven_week then
    score = RankDataMgr.GetMetroSummaryScore(v, "week_profit")
  elseif rankSelectType == RankSelectEnum.xmission_military then
    score = RankDataMgr.GetMetroSummaryScore(v, "military")
  elseif rankSelectType == RankSelectEnum.xmission_kill then
    score = RankDataMgr.GetMetroSummaryScore(v, "kill_count")
  elseif rankSelectType == RankSelectEnum.xmission_kill_week then
    score = RankDataMgr.GetMetroSummaryScore(v, "week_kill")
  elseif rankSelectType == RankConfig.RankSelectEnum.xmission_zombie then
    score = RankDataMgr.GetMetroSummaryScore(v, "monster_kill")
  elseif rankSelectType == RankConfig.RankSelectEnum.xmission_zombie_week then
    score = RankDataMgr.GetMetroSummaryScore(v, "week_monster_kill")
  end
  return score
end
function RankDataMgr.GetMetroSummaryScore(v, key)
  local score = 0
  if v.metro_summary and next(v.metro_summary) then
    score = v.metro_summary[key] or -1
  end
  return score
end
function RankDataMgr.IsFpp()
  if _isFpp(rankSelectType) then
    return true
  end
  return false
end
function RankDataMgr.IsTpp()
  if _isTpp(rankSelectType) then
    return true
  end
  return false
end
function RankDataMgr.IsGift()
  if _isGift(rankSelectType) then
    return true
  end
  return false
end
function RankDataMgr.IsIntimacy()
  if rankSelectType == RankSelectEnum.lover then
    return true
  elseif rankSelectType == RankSelectEnum.bestie then
    return true
  elseif rankSelectType == RankSelectEnum.homie then
    return true
  elseif rankSelectType == RankSelectEnum.bestFriend then
    return true
  elseif rankSelectType == RankSelectEnum.family then
    return true
  end
  return false
end
function RankDataMgr.IsXmissionType()
  if rankSelectType == RankSelectEnum.xmission_kill then
    return true
  elseif rankSelectType == RankSelectEnum.xmission_raven then
    return true
  elseif rankSelectType == RankSelectEnum.xmission_military then
    return true
  elseif rankSelectType == RankSelectEnum.xmission_raven_week then
    return true
  elseif rankSelectType == RankSelectEnum.xmission_kill_week then
    return true
  end
  return false
end
function RankDataMgr.IsClassicRanking(rank_type)
  if rank_type then
    if _isTpp(rank_type) or _isFpp(rank_type) then
      return true
    end
  elseif RankDataMgr.IsTpp() or RankDataMgr.IsFpp() then
    return true
  end
  return false
end
function RankDataMgr.IsPeakGameRanking(rank_type)
  if rank_type then
    if _isPeakgame(rank_type) then
      return true
    end
  elseif _isPeakgame(rankSelectType) then
    return true
  end
  return false
end
function RankDataMgr.IsArenaRanking(rank_type)
  if rank_type then
    if _isArena(rank_type) then
      return true
    end
  elseif _isArena(rankSelectType) then
    return true
  end
  return false
end
function RankDataMgr.IsWeaponUsageScoreRanking(rank_type)
  if rank_type then
    if _isWeaponUsageScore(rank_type) then
      return true
    end
  elseif _isWeaponUsageScore(rankSelectType) then
    return true
  end
  return false
end
function RankDataMgr.IsIntimacyRankID(rankID)
  return rankID >= RankConfig.ScoreType.intimacy_lover_total_rating and rankID <= RankConfig.ScoreType.intimacy_bestfriend_weekly_rating_krjp or rankID >= RankConfig.ScoreType.intimacy_family_total_rating and rankID <= RankConfig.ScoreType.intimacy_family_weekly_rating_krjp
end
function RankDataMgr.IsIntimacyRankType(rankType)
  return rankType == RankSelectEnum.intimacy
end
function RankDataMgr.SetRankSelectType(sType)
  rankSelectType = sType or RankSelectEnum.sum
end
function RankDataMgr.GetRankSelectType()
  return rankSelectType
end
function RankDataMgr.SetRankSelectMemberType(sType)
  if sType then
    rankSelectMember = sType
  end
end
function RankDataMgr.GetRankSelectMemberType()
  return rankSelectMember
end
function RankDataMgr.SetRankRegionType(sType)
  rankRegionType = sType
end
function RankDataMgr.GetRankRegionType()
  return rankRegionType
end
function RankDataMgr.SetRankPeriodType(sType)
  rankPeriodType = sType
end
function RankDataMgr.GetRankPeriodType()
  return rankPeriodType
end
function RankDataMgr.GetWeaponRankID()
  return weaponRankID
end
function RankDataMgr.SetWeaponRankID(id)
  weaponRankID = id
end
function RankDataMgr.GetCountryID()
  return countryID
end
function RankDataMgr.SetCountryID(id)
  countryID = id
end
function RankDataMgr.GetProvinceID()
  return provinceID
end
function RankDataMgr.SetProvinceID(id)
  provinceID = id
end
function RankDataMgr.GetCityID()
  return cityID
end
function RankDataMgr.SetCityID(id)
  cityID = id
end
function RankDataMgr.GetLBSMode()
  return lbsMode
end
function RankDataMgr.SetLBSMode(bMode)
  lbsMode = bMode
end
function RankDataMgr.SetPlanPHType(sType)
  if sType then
    planPHType = sType
  end
end
function RankDataMgr.GetPlanPHType()
  return planPHType
end
function RankDataMgr.SetPlanPHDataFlag(flag)
  planPHTypeDataFlag = flag
end
function RankDataMgr.GetPlanPHDataFlag()
  return planPHTypeDataFlag
end
function RankDataMgr.SetWoWAuthorType(Type)
  if Type then
    WoWAuthor  end
end
function RankDataMgr.GetWoWAuthorType()
  return WoWAuthorType
end
function RankDataMgr.GetRankInfoList()
  local rank_data = require("client.slua.logic.rank.rank_data")
  return rank_data.GetRankDataList()
end
function RankDataMgr.IsRankEmpty()
  local rank_data = require("client.slua.logic.rank.rank_data")
  local rank_list = rank_data.GetRankDataList()
  if rank_list and 0 < #rank_list then
    return false
  end
  return true
end
function RankDataMgr.ParseRankViewData()
  local rank_data = require("client.slua.logic.rank.rank_data")
  if not RankDataMgr.IsIntimacy() then
    return rank_data.GetRankDataList()
  end
  local TableUtil = require("common.table_util")
  local rankList = TableUtil.CopyTable(rank_data.GetRankDataList())
  for _, v in pairs(rankList) do
    v.uid = v.ext_data.uid_s
    v.ext_data.other_uid = v.ext_data.uid_l
  end
  return rankList
end
function RankDataMgr.GetRankSummaryRspDataByUID(uid)
  if uid then
    return rankSummaryRspData[tonumber(uid)]
  else
    return nil
  end
end
function RankDataMgr.SetSelfBelow1wDisplay(no)
  local rank_data = require("client.slua.logic.rank.rank_data")
  rank_data.SetSelfBelow1wDisplay(no)
end
function RankDataMgr.GetSelfBelow1wDisplay()
  local rank_data = require("client.slua.logic.rank.rank_data")
  return rank_data.GetSelfBelow1wDisplay()
end
function RankDataMgr.SetRankZoneId(zoneID)
  if zoneID == nil or zoneID <= 0 then
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    zoneID = tonumber(ZoneSystem.nChooseZoneID)
    log(bWriteLog and string.format(" ZoneSystem.nChooseZoneID = %s", ZoneSystem.nChooseZoneID))
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if not PublishRegionMacros.IsCEVersion() and not Client.IsReleaseVersion(NetInterface) and zoneID <= 0 then
      log(bWriteLog and string.format(" Fake a zoneID."))
      zoneID = 1
    end
  end
  rankSelectZoneId = zoneID
  return rankSelectZoneId
end
function RankDataMgr.GetRankSelectZoneId()
  return rankSelectZoneId
end
function RankDataMgr.GetRankInfoSelf()
  local rank_data = require("client.slua.logic.rank.rank_data")
  if not RankDataMgr.IsIntimacy() then
    return rank_data.GetSelfRankData()
  end
  local TableUtil = require("common.table_util")
  local rankInfo = TableUtil.CopyTable(rank_data.GetSelfRankData())
  rankInfo.ext_data.other_uid = rankInfo.ext_data and rankInfo.ext_data.uid_l
  rankInfo.uid = DataMgr.roleData.uid
  return rankInfo
end
return RankDataMgr