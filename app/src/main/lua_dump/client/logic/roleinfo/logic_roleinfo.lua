local RoleInfoSystem = {
  curseasonid = 0,
  AllSeasonIDList = {},
  PlatID = "",
  IsMaxLevel = false,
  IsFriend = false,
  ShowBirthdaySwitch = false,
  bLBSPlace = false,
  bLBIsMainSwitch = true,
  RoleCombatInfoGet = {},
  RoleMatchCombatInfoGet = {},
  RoleBasicInfoGet = 0,
  RoleHistorySeasonBattleGet = false,
  AchievementSummaryGet = 0,
  RoleBasicInfoHasRefresh = {},
  PersonalBasicInfo = {},
  CurrSeasonTPPTotalScore = {},
  CurrSeasonTPPTotalRank = {},
  CurrSeasonFPPTotalScore = {},
  CurrSeasonFPPTotalRank = {},
  PersonalTotalRankInfo = {},
  PersonalTotalScoreInfo = {},
  CombatTotalInfoList = {},
  CombatGradeInfoList = {},
  FPPPersonalTotalRankInfo = {},
  FPPPersonalTotalScoreInfo = {},
  FPPCombatTotalInfoList = {},
  FPPCombatGradeInfoList = {},
  MatchCombatTotalInfoList = {},
  MatchCombatGradeInfoList = {},
  FPPMCombatTotalInfoList = {},
  FPPMCombatGradeInfoList = {},
  CareerCombatTotalInfoList = {},
  FPPCCombatTotalInfoList = {},
  IntimateInfoList = {},
  SocialCard = {},
  HonorWallInfoList = {},
  isOldSeason = false,
  CombatTotalInfo = {
    role_allmatchnum = 0,
    role_winnum = 0,
    role_toptennum = 0,
    role_killnum = 0,
    role_kd = 0,
    role_kd_v2 = 0,
    role_critrate = 0,
    role_allgamenum = 0
  },
  CombatSDTInfo = {
    role_totalHurt = 0,
    role_allmatchnum = 0,
    role_winnum = 0,
    role_toptennum = 0,
    role_killnum = 0,
    role_kd = 0,
    role_kd_v2 = 0,
    role_critrate = 0,
    role_maxsurvivetime = 0,
    role_avesurvivetime = 0,
    role_maxdistance = 0,
    role_avedistance = 0,
    role_aveheal = 0,
    role_aidcount = 0,
    role_score = 0,
    role_killscore = 0,
    role_rankscore = 0,
    role_hitrate = 0,
    role_critcount = 0,
    role_maxkill = 0,
    role_maxdamage = 0,
    role_avedamage = 0,
    role_winrate = 0,
    role_toptenrate = 0,
    role_assist = 0
  },
  CombatGradeInfo = {
    survive_score = 0,
    top1_score = 0,
    rating_score = 0,
    fight_score = 0,
    assist_score = 0,
    sum_score = 0,
    grade = 0
  },
  SegmentTitleRecord = {},
  CurShowPlayerInfoUid = 0,
  GetDataMaxTimes = 5,
  default_role_totalscore = 1200,
  social_card_cb = nil,
  bCanShowGameDay = false
}
local TableUtil = require("common.table_util")
local score_type = {
  total_rating = 1000,
  solo_total_rating = 1001,
  solo_win_rating = 1002,
  solo_kill_rating = 1003,
  duo_total_rating = 2001,
  duo_win_rating = 2002,
  duo_kill_rating = 2003,
  squad_total_rating = 3001,
  squad_win_rating = 3002,
  squad_kill_rating = 3003,
  fpp_total_rating = 4000
}
local model_type = {
  solo_model = 1,
  double_model = 2,
  team_model = 3,
  all_model = 4
}
local segment_type = {
  solo = 1,
  double = 2,
  team = 3,
  fpp_solo = 4,
  fpp_double = 5,
  fpp_team = 6
}
local E_ValueofLevel = {
  Zero = 0,
  OneOrOdd = 1,
  Even = 2
}
local IsInitZoneList = false
function RoleInfoSystem.OnLogin()
  log(bWriteLog and "RoleInfoSystem.OnLogin")
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local needUpdateRole = newbieGuideManager.NeedUpdateRole()
  if needUpdateRole then
    log(bWriteLog and "close CreateRoleUI is not allowed when update role")
    return
  end
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  if logicCreateRole.CheckCanClosePanel() then
    logicCreateRole.ClosePanel()
  end
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.bHasStateData = false
end
function RoleInfoSystem.Enter(uid)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  uid = tostring(uid)
  log(bWriteLog and "RoleInfoSystem Enter")
  RoleInfoSystem.CurShowPlayerInfoUid = uid
  RoleInfoMainSystem.UpdateRoleinfoSeasonListID(1)
  RoleInfoSystem.RoleCombatInfoGet = {}
  RoleInfoSystem.RoleMatchCombatInfoGet = {}
  RoleInfoSystem.RoleBasicInfoGet = 0
  RoleInfoSystem.RoleHistorySeasonBattleGet = false
  RoleInfoSystem.AchievementSummaryGet = 0
  RoleInfoSystem.curseasonid = 0
  RoleInfoSystem.AllSeasonIDList = {}
  RoleInfoSystem.PlatID = ""
  RoleInfoSystem.IsMaxLevel = false
  RoleInfoSystem.IsFriend = false
  RoleInfoSystem.IsMaxPveLevel = false
  RoleInfoSystem.SetEmpty()
  RoleInfoSystem.IsRoleFriend(uid)
  RoleInfoSystem.RequestRoleInfo()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.Enter()
  if uid ~= DataMgr.roleData.uid then
    local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
    local zone_id = RoleInfoSystem.GetMaxSegmentInfoZone(DataMgr.roleData.allzoneSegment)
    SocialLobbyHandler.send_get_role_battle_info(tonumber(DataMgr.roleData.uid), "Compare", BP_COMBAT_MSG_TYPE_ROLEINFO, zone_id)
  else
    local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
    SocialLobbyHandler.send_client_in_depot()
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.enter(RoleInfoSystem.CurShowPlayerInfoUid)
end
function RoleInfoSystem.IsSelf()
  return tonumber(RoleInfoSystem.CurShowPlayerInfoUid) == tonumber(DataMgr.roleData.uid)
end
function RoleInfoSystem.GetCurShowUserId()
  return RoleInfoSystem.CurShowPlayerInfoUid
end
function RoleInfoSystem.GetHistorySegmentTitle(shootType, teamNum)
  local segTitleID
  if shootType == 1 then
    if teamNum == 1 then
      segTitleID = RoleInfoSystem.SegmentTitleRecord.solo
    elseif teamNum == 2 then
      segTitleID = RoleInfoSystem.SegmentTitleRecord.duo
    else
      segTitleID = RoleInfoSystem.SegmentTitleRecord.squad
    end
  elseif teamNum == 1 then
    segTitleID = RoleInfoSystem.SegmentTitleRecord.fppsolo
  elseif teamNum == 2 then
    segTitleID = RoleInfoSystem.SegmentTitleRecord.fppduo
  else
    segTitleID = RoleInfoSystem.SegmentTitleRecord.fppsquad
  end
  return segTitleID
end
function RoleInfoSystem.GetMaxSegmentInfoZone(allzoneSegment)
  local zoneid = DataMgr.GetMaxSegmentInfo(allzoneSegment).zoneid
  local getZone = false
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  for i, v in ipairs(ZoneSystem.chooseZoneList) do
    if zoneid == v.zone_id then
      getZone = true
    end
  end
  if not getZone then
    zoneid = ZoneSystem.GetFirstZone()
  end
  local season_id = tonumber(DataMgr.season_id)
  if 16 <= season_id and ZoneSystem.nChooseZoneID and ZoneSystem.nChooseZoneID > 0 and ZoneSystem.nChooseZoneID < 10 then
    zoneid = ZoneSystem.nChooseZoneID
  end
  return zoneid
end
function RoleInfoSystem.UpdateShowRoleInfoOfZoneId()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zoneId
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  if logic_multiple_area:IsConnectToRussiaArea() then
    zoneId = 2
  elseif RoleInfoSystem.IsSelf() then
    zoneId = RoleInfoSystem.GetMaxSegmentInfoZone(DataMgr.roleData.allzoneSegment)
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local currProfileInfo = logic_profile:GetLocalProfile(RoleInfoSystem.CurShowPlayerInfoUid)
    if currProfileInfo then
      zoneId = RoleInfoSystem.GetMaxSegmentInfoZone(currProfileInfo.segment_info)
    else
      zoneId = RoleInfoSystem.GetMaxSegmentInfoZone(DataMgr.roleData.allzoneSegment)
    end
  end
  RoleInfoMainSystem.UpdateShowRoleinfoOfZoneID(zoneId)
end
function RoleInfoSystem.RequestRoleInfo()
  RoleInfoSystem.UpdateShowRoleInfoOfZoneId()
  RoleInfoSystem.get_profile_info_req(RoleInfoSystem.CurShowPlayerInfoUid)
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  if RoleInfoSystem.AchievementSummaryGet ~= RoleInfoSystem.CurShowPlayerInfoUid then
    AchieveHandler.send_get_achievement_summary_req(RoleInfoSystem.CurShowPlayerInfoUid)
  else
  end
end
function RoleInfoSystem.RequestCurrSeasonBattleInfo(zoneId)
  RoleInfoSystem.UpdateShowRoleInfoOfZoneId()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if zoneId then
    RoleInfoMainSystem.UpdateShowRoleinfoOfZoneID(zoneId)
  end
  local season_id = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  if RoleInfoSystem.RoleCombatInfoGet.ZoneId ~= zoneId or RoleInfoSystem.RoleCombatInfoGet.SeasonId ~= season_id then
    RoleInfoSystem.get_role_battle_info_req(RoleInfoSystem.CurShowPlayerInfoUid, zoneId)
    RoleInfoSystem.RoleCombatInfoGet.ZoneId = zoneId
    RoleInfoSystem.RoleCombatInfoGet.SeasonId = season_id
    RoleInfoSystem.get_role_rank_info_req(RoleInfoSystem.CurShowPlayerInfoUid, zoneId)
  end
  RoleInfoSystem.get_profile_info_req(RoleInfoSystem.CurShowPlayerInfoUid)
end
function RoleInfoSystem.get_role_battle_info_req(uid, zoneId)
  log(bWriteLog and "get_role_battle_info_req, zoneId = " .. zoneId)
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_role_battle_info(tonumber(uid), nil, BP_COMBAT_MSG_TYPE_ROLEINFO, zoneId)
end
function RoleInfoSystem.get_role_combat_info_rsp(res, callback, optype, role_combat_info, getZoneid, curseasonid, allseasonlist, battle_info_no_rank, battle_info_career, peakgame_info)
  log(bWriteLog and "get_role_combat_info_rsp curseasonid:" .. tostring(curseasonid))
  if optype ~= BP_COMBAT_MSG_TYPE_ROLEINFO then
    return
  end
  RoleInfoSystem.  if res ~= 0 then
    log_error("Error: " .. res)
    RoleInfoSystem.RoleCombatInfoGet.ZoneId = -1
    RoleInfoSystem.RoleCombatInfoGet.SeasonId = -1
    RoleInfoSystem.ProcessCombatInfoError(curseasonid, allseasonlist)
    return
  end
  RoleInfoSystem.RoleCombatInfoGet.SeasonId = curseasonid
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local currZone = ZoneSystem.nChooseZoneID or 1
  if currZone == 0 then
    currZone = 1
  end
  log(bWriteLog and "get_role_combat_info_rsp currZone = " .. tostring(currZone))
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  log(bWriteLog and "get_role_combat_info_rsp zoneId = " .. tostring(zoneId))
  RoleInfoSystem.CombatTotalInfoList = {}
  RoleInfoSystem.CombatGradeInfoList = {}
  RoleInfoSystem.FPPCombatTotalInfoList = {}
  RoleInfoSystem.FPPCombatGradeInfoList = {}
  if role_combat_info.warall and role_combat_info.warall.rank_rating ~= nil then
    RoleInfoSystem.PersonalTotalScoreInfo[zoneId] = {
      role_totalscore = role_combat_info.warall.rank_rating
    }
    RoleInfoSystem.CurrSeasonTPPTotalScore[zoneId] = role_combat_info.warall.rank_rating
  else
    RoleInfoSystem.PersonalTotalScoreInfo[zoneId] = {
      role_totalscore = RoleInfoSystem.default_role_totalscore
    }
    RoleInfoSystem.CurrSeasonTPPTotalScore[zoneId] = RoleInfoSystem.default_role_totalscore
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalScoreInfo)
  if role_combat_info.warall and role_combat_info.warall.fpp_rank_rating ~= nil then
    RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId] = {
      role_totalscore = role_combat_info.warall.fpp_rank_rating
    }
    RoleInfoSystem.CurrSeasonFPPTotalScore[zoneId] = role_combat_info.warall.fpp_rank_rating
  else
    RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId] = {
      role_totalscore = RoleInfoSystem.default_role_totalscore
    }
    RoleInfoSystem.CurrSeasonFPPTotalScore[zoneId] = RoleInfoSystem.default_role_totalscore
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalScoreInfo)
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  RoleInfoHistorySystem.SetCanShowHistory(role_combat_info.privacy)
  RoleInfoSystem.bCanShowGameDay = role_combat_info.privacy_season_info
  local role_info, fpp_role_info
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    if i == model_type.solo_model then
      role_info = role_combat_info.warsolo
      fpp_role_info = role_combat_info.fppsolo
    elseif i == model_type.double_model then
      role_info = role_combat_info.warduo
      fpp_role_info = role_combat_info.fppduo
    elseif i == model_type.team_model then
      role_info = role_combat_info.warsquad
      fpp_role_info = role_combat_info.fppsquad
    elseif i == model_type.all_model then
      role_info = role_combat_info.warall
      fpp_role_info = role_combat_info.warall
    end
    if role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.CombatTotalInfoList[i] = {
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.CombatTotalInfoList[i] = {
          role_totalHurt = role_info.total_hurt,
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio,
          role_maxsurvivetime = role_info.max_live_time,
          role_avesurvivetime = role_info.avg_live_time,
          role_maxdistance = role_info.max_move,
          role_avedistance = role_info.avg_move,
          role_aveheal = role_info.avg_cure,
          role_aidcount = role_info.rescue_teammates,
          role_score = role_info.rank_rating,
          role_killscore = role_info.kill_rating,
          role_rankscore = role_info.win_rating,
          role_hitrate = role_info.avg_shot_hit_ratio,
          role_critcount = role_info.head_shot_num,
          role_maxkill = role_info.max_kill,
          role_maxdamage = role_info.max_hurt,
          role_avedamage = role_info.avg_hurt,
          role_assist = role_info.total_assist,
          promo_rank_rating = role_info.promo_rank_rating,
          promo_kill_rating = role_info.promo_kill_rating,
          promo_win_rating = role_info.promo_win_rating
        }
        if type(role_info.game_num) == "number" and role_info.game_num ~= 0 then
          RoleInfoSystem.CombatTotalInfoList[i].role_winrate = role_info.win_num / role_info.game_num * 100
          RoleInfoSystem.CombatTotalInfoList[i].role_toptenrate = role_info.top10_count / role_info.game_num * 100
        else
          RoleInfoSystem.CombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.CombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.CombatGradeInfoList[i] = {
          survive_score = role_info.survive_score,
          top1_score = role_info.top1_score,
          rating_score = role_info.rating_score,
          fight_score = role_info.fight_score,
          assist_score = role_info.assist_score,
          sum_score = role_info.sum_score,
          grade = role_info.grade
        }
        local sgrade = role_info.grade
        RoleInfoSystem.CombatGradeInfoList[i].grade = ConvertGrade(sgrade)
      end
    end
    if fpp_role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.FPPCombatTotalInfoList[i] = {
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.FPPCombatTotalInfoList[i] = {
          role_totalHurt = fpp_role_info.total_hurt,
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio,
          role_maxsurvivetime = fpp_role_info.max_live_time,
          role_avesurvivetime = fpp_role_info.avg_live_time,
          role_maxdistance = fpp_role_info.max_move,
          role_avedistance = fpp_role_info.avg_move,
          role_aveheal = fpp_role_info.avg_cure,
          role_aidcount = fpp_role_info.rescue_teammates,
          role_score = fpp_role_info.rank_rating,
          role_killscore = fpp_role_info.kill_rating,
          role_rankscore = fpp_role_info.win_rating,
          role_hitrate = fpp_role_info.avg_shot_hit_ratio,
          role_critcount = fpp_role_info.head_shot_num,
          role_maxkill = fpp_role_info.max_kill,
          role_maxdamage = fpp_role_info.max_hurt,
          role_avedamage = fpp_role_info.avg_hurt,
          role_assist = fpp_role_info.total_assist,
          promo_rank_rating = fpp_role_info.promo_rank_rating,
          promo_kill_rating = fpp_role_info.promo_kill_rating,
          promo_win_rating = fpp_role_info.promo_win_rating
        }
        if type(fpp_role_info.game_num) == "number" and fpp_role_info.game_num ~= 0 then
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_winrate = fpp_role_info.win_num / fpp_role_info.game_num * 100
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_toptenrate = fpp_role_info.top10_count / fpp_role_info.game_num * 100
        else
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.FPPCombatGradeInfoList[i] = {
          survive_score = fpp_role_info.survive_score,
          top1_score = fpp_role_info.top1_score,
          rating_score = fpp_role_info.rating_score,
          fight_score = fpp_role_info.fight_score,
          assist_score = fpp_role_info.assist_score,
          sum_score = fpp_role_info.sum_score,
          grade = fpp_role_info.grade
        }
        local sfppgrade = fpp_role_info.grade
        RoleInfoSystem.FPPCombatGradeInfoList[i].grade = ConvertGrade(sfppgrade)
      end
    elseif i == model_type.all_model then
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
    end
  end
  RoleInfoSystem.FormatCombatInfo()
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList)
  RoleInfoSystem.AllSeasonIDList = {}
  table.insert(RoleInfoSystem.AllSeasonIDList, curseasonid)
  if allseasonlist ~= nil and type(allseasonlist) == "table" then
    table.sort(allseasonlist, function(a, b)
      return b < a
    end)
    for k, v in ipairs(allseasonlist) do
      if curseasonid > v then
        table.insert(RoleInfoSystem.AllSeasonIDList, v)
      end
    end
  end
  if currZone and zoneId and currZone == zoneId then
    log(bWriteLog and "get_role_combat_info_rsp refresh match and career data")
    local RoleInfoMatchSystem = require("client.logic.roleinfo.logic_roleinfo_match")
    RoleInfoMatchSystem.get_role_match_info_rsp(battle_info_no_rank, battle_info_career)
  end
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  logic_peakgame_combat:OnGetPeakGameInfoRsp(getZoneid, peakgame_info)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoSystem.ProcessCombatInfoError(curseasonid, allseasonlist)
  log(bWriteLog and "RoleInfoSystem.ProcessCombatInfoError")
  RoleInfoSystem.PersonalTotalScoreInfo = {}
  RoleInfoSystem.CombatTotalInfoList = {}
  RoleInfoSystem.CombatGradeInfoList = {}
  RoleInfoSystem.FPPPersonalTotalScoreInfo = {}
  RoleInfoSystem.FPPCombatTotalInfoList = {}
  RoleInfoSystem.FPPCombatGradeInfoList = {}
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  RoleInfoSystem.CurrSeasonTPPTotalScore[zoneId] = RoleInfoSystem.default_role_totalscore
  RoleInfoSystem.CurrSeasonFPPTotalScore[zoneId] = RoleInfoSystem.default_role_totalscore
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    if i == model_type.all_model then
      RoleInfoSystem.CombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.CombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.CombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
    end
  end
  RoleInfoSystem.FormatCombatInfo()
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList)
  RoleInfoSystem.AllSeasonIDList = {}
  table.insert(RoleInfoSystem.AllSeasonIDList, curseasonid)
  if allseasonlist ~= nil and type(allseasonlist) == "table" then
    table.sort(allseasonlist, function(a, b)
      return a < b
    end)
    for k, v in pairs(allseasonlist) do
      if curseasonid > v then
        table.insert(RoleInfoSystem.AllSeasonIDList, v)
      end
    end
  end
  local RoleInfoMatchSystem = require("client.logic.roleinfo.logic_roleinfo_match")
  RoleInfoMatchSystem.ProcessMatchInfoError()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoSystem.get_role_rank_info_req(uid, zoneId)
  log(bWriteLog and "get_role_rank_info_req, zoneId = " .. zoneId)
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank("roleinfo_tpp", zoneId, tonumber(uid), score_type.total_rating)
  RankHandler.send_get_one_user_rank("roleinfo_fpp", zoneId, tonumber(uid), score_type.fpp_total_rating)
end
function RoleInfoSystem.get_role_rank_info_rsp(client_data, res, zone_id, role_rank_info)
  if RoleInfoSystem.CurShowPlayerInfoUid == 0 then
    return
  end
  if client_data ~= "roleinfo_tpp" and client_data ~= "roleinfo_fpp" then
    return
  end
  if res ~= 0 then
    log(bWriteLog and "get_role_rank_info_rsp1")
    log_error("Error: " .. res)
    RoleInfoSystem.ProcessRankInfoError()
    return
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  log(bWriteLog and "get_role_rank_info_rsp zoneId = " .. tostring(zoneId))
  log(bWriteLog and "get_role_rank_info_rsp refresh rank data")
  local rank_util = require("client.slua.logic.rank.rank_util")
  if client_data == "roleinfo_tpp" then
    local role_totalscore = 0
    if RoleInfoSystem.PersonalTotalScoreInfo[zoneId] and RoleInfoSystem.PersonalTotalScoreInfo[zoneId].role_totalscore then
      role_totalscore = tonumber(RoleInfoSystem.PersonalTotalScoreInfo[zoneId].role_totalscore)
    end
    local text = rank_util.calc_topn_percentage(role_totalscore, role_rank_info.top1w, "total", role_rank_info.rank_no)
    RoleInfoSystem.PersonalTotalRankInfo[zoneId] = {role_totalrank = text}
    RoleInfoSystem.CurrSeasonTPPTotalRank[zoneId] = RoleInfoSystem.PersonalTotalRankInfo[zoneId].role_totalrank
    RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalRankInfo)
  end
  if client_data == "roleinfo_fpp" then
    local role_totalscore = 0
    if RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId] and RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId].role_totalscore then
      role_totalscore = tonumber(RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId].role_totalscore)
    end
    local text = rank_util.calc_topn_percentage(role_totalscore, role_rank_info.top1w, "total", role_rank_info.rank_no)
    RoleInfoSystem.FPPPersonalTotalRankInfo[zoneId] = {role_totalrank = text}
    RoleInfoSystem.CurrSeasonFPPTotalRank[zoneId] = RoleInfoSystem.FPPPersonalTotalRankInfo[zoneId].role_totalrank
    RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalRankInfo)
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoSystem.ProcessRankInfoError()
  RoleInfoSystem.PersonalTotalRankInfo = {}
  RoleInfoSystem.FPPPersonalTotalRankInfo = {}
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoSystem.get_profile_info_req(uid)
  log(bWriteLog and "get_profile_info_req:" .. tostring(uid))
  local ace_util = require("client.logic.season.ace.ace_util")
  ace_util.GetPlayerAllImprintInfo(uid)
  if RoleInfoSystem.CurShowPlayerInfoUid == uid then
    RoleInfoSystem.PersonalBasicInfo.role_id = uid
  end
  local needRefresh = true
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if RoleInfoSystem.RoleBasicInfoHasRefresh[tonumber(uid)] then
    if tostring(uid) == DataMgr.roleData.uid and DataMgr.roleData.rankdata then
      needRefresh = false
      BP_RoleInfo_HasGetPersonalBasicInfo = true
      RoleInfoSystem.GetSelfBasicInfo()
    end
    if tostring(uid) ~= DataMgr.roleData.uid then
      local profile = logic_profile:GetLocalProfile(uid)
      if profile and profile.rankdata then
        needRefresh = false
        BP_RoleInfo_HasGetPersonalBasicInfo = true
        RoleInfoSystem.get_role_basic_info_rsp({profile})
      end
    end
  end
  log(bWriteLog and "get_profile_info_req needRefresh:" .. tostring(needRefresh))
  if needRefresh then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.ROLE_INFO, {
      tonumber(uid)
    }, function(listInfo)
      BP_RoleInfo_HasGetPersonalBasicInfo = true
      RoleInfoSystem.RoleBasicInfoHasRefresh[tonumber(uid)] = true
      local profile = logic_profile:GetLocalProfile(uid)
      if profile and listInfo[1] then
        profile.rankdata = listInfo[1].rankdata
      end
      if tostring(uid) ~= DataMgr.roleData.uid then
        RoleInfoSystem.get_role_basic_info_rsp(listInfo)
      else
        RoleInfoSystem.GetSelfBasicInfo()
      end
    end)
  end
end
function RoleInfoSystem.GetSelfBasicInfo()
  RoleInfoSystem.PersonalBasicInfo = {}
  local corpsID = 0
  if DataMgr.corpsInfo.id ~= nil then
    corpsID = DataMgr.corpsInfo.id
  end
  log(bWriteLog and "GetSelfBasicInfo corpsid:" .. tostring(DataMgr.corpsInfo.id))
  RoleInfoSystem.PersonalBasicInfo = {
    role_name = DataMgr.roleData.nickName,
    role_id = DataMgr.roleData.uid,
    role_sex = DataMgr.roleData.gender - 1,
    role_nation = DataMgr.roleData.nation,
    role_image = DataMgr.roleData.headIconUrl,
    role_upvote = DataMgr.roleData.upvote or 0,
    role_charisma = DataMgr.roleData.charisma or 0,
    role_curlevel = "",
    role_nextlevel = "",
    role_curexpnum = DataMgr.roleData.roleExp,
    role_needexpnum = "",
    role_sign = DataMgr.roleData.signature,
    role_startup_type = BP_StartUpType,
    role_credit = DataMgr.roleData.credit,
    role_corpsid = corpsID,
    role_upassIsBuy = DataMgr.roleData.upass.is_buy,
    role_upassUiShow = DataMgr.roleData.upass.switch and DataMgr.roleData.upass.switch.ui == true and 1 or 0,
    role_upassLevel = DataMgr.roleData.upass.level,
    role_upassKeepBuy = DataMgr.roleData.upass.keep_buy,
    role_aliasId = DataMgr.roleData.alias.id,
    role_aliasTitle = DataMgr.roleData.alias.title,
    role_aliasReceiveTime = DataMgr.roleData.alias.receive_time,
    role_aliasExpireTime = DataMgr.roleData.alias.expire_ts,
    role_aliasNation = DataMgr.roleData.alias.nation,
    role_corpAliasId = DataMgr.roleData.corps_alias_data.cur_corps_alias_id,
    role_carteamId = DataMgr.roleData.carteamId or 0,
    role_pve_expnum = DataMgr.roleData.pve_exp,
    role_pve_levelnum = DataMgr.roleData.pve_level,
    role_pve_levelname = "",
    role_pve_nextlevelname = "",
    role_pve_needexpnum = 0,
    hsegment_title_det = DataMgr.roleData.allzoneSegmentTitle
  }
  if corpsID ~= nil and 0 < tonumber(corpsID) then
    RoleInfoSystem.get_corps_summary_req(corpsID, tonumber(DataMgr.roleData.uid))
  else
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.RefreshCorpsSummary({})
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalBasicInfo)
  RoleInfoSystem.PersonalBasicInfo.role_curlevelnum = tonumber(DataMgr.roleData.level)
  RoleInfoSystem.PersonalBasicInfo.role_nextlevelnum = tonumber(DataMgr.roleData.level) + 1
  RoleInfoSystem.RoleSegmentInfo()
  local curlevel = tonumber(DataMgr.roleData.level)
  if 100 <= curlevel then
    local curmilitarylevel = CDataTable.GetTableData("MilitaryRankLevel", 100)
    RoleInfoSystem.PersonalBasicInfo.role_curlevel = tostring(curmilitarylevel.MilitaryRankName)
    RoleInfoSystem.PersonalBasicInfo.role_curexpnum = ""
    RoleInfoSystem.PersonalBasicInfo.role_needexpnum = ""
    RoleInfoSystem.PersonalBasicInfo.role_nextlevel = ""
    RoleInfoSystem.PersonalBasicInfo.role_curlevelnum = 100
    RoleInfoSystem.PersonalBasicInfo.role_avatar_frame = tonumber(DataMgr.roleData.cur_avatar_box_id)
    RoleInfoSystem.IsMaxLevel = true
  elseif 0 < curlevel then
    local curmilitarylevel = CDataTable.GetTableData("MilitaryRankLevel", curlevel)
    local nextmilitarylevel = CDataTable.GetTableData("MilitaryRankLevel", curlevel + 1)
    RoleInfoSystem.PersonalBasicInfo.role_curlevel = tostring(curmilitarylevel.MilitaryRankName)
    RoleInfoSystem.PersonalBasicInfo.role_needexpnum = tostring(curmilitarylevel.Exp)
    RoleInfoSystem.PersonalBasicInfo.role_nextlevel = tostring(nextmilitarylevel.MilitaryRankName)
    RoleInfoSystem.PersonalBasicInfo.role_avatar_frame = tonumber(DataMgr.roleData.cur_avatar_box_id)
    RoleInfoSystem.IsMaxLevel = false
  end
  local curPveLevel = tonumber(DataMgr.roleData.pve_level)
  if 100 <= curPveLevel then
    local curPveLevelItem = CDataTable.GetTableData("PveLevel", 100)
    local PveLevelItem99 = CDataTable.GetTableData("PveLevel", 99)
    RoleInfoSystem.PersonalBasicInfo.role_pve_levelname = tostring(curPveLevelItem.name)
    RoleInfoSystem.PersonalBasicInfo.role_pve_expnum = PveLevelItem99.Exp
    RoleInfoSystem.PersonalBasicInfo.role_pve_needexpnum = PveLevelItem99.Exp
    RoleInfoSystem.PersonalBasicInfo.role_pve_nextlevelname = ""
    RoleInfoSystem.PersonalBasicInfo.role_pve_levelnum = 100
    RoleInfoSystem.IsMaxPveLevel = true
  elseif 0 < curPveLevel then
    local curPveLevelItem = CDataTable.GetTableData("PveLevel", curPveLevel)
    local nextPveLevelItem = CDataTable.GetTableData("PveLevel", curPveLevel + 1)
    RoleInfoSystem.PersonalBasicInfo.role_pve_levelname = tostring(curPveLevelItem.name)
    RoleInfoSystem.PersonalBasicInfo.role_pve_needexpnum = tostring(curPveLevelItem.Exp)
    RoleInfoSystem.PersonalBasicInfo.role_pve_nextlevelname = tostring(nextPveLevelItem.name)
    RoleInfoSystem.IsMaxPveLevel = false
  end
  RoleInfoSystem.PersonalBasicInfo.is_del = false
  RoleInfoSystem.PersonalBasicInfo.ace_imprint_show_id = DataMgr.ace_imprint_show_id
  RoleInfoSystem.PersonalBasicInfo.ace_imprint_base_id = DataMgr.ace_imprint_base_id
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  SocialCardSystem.get_social_card()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoSystem.get_corps_summary_req(corpsID, uid)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "get_corps_summary_req corpsID:" .. tostring(corpsID) .. ", uid:" .. tostring(uid))
  CorpsMgr.get_corps_summary_req(corpsID, uid, nil)
end
function RoleInfoSystem.get_corps_summary_rsp(corps_id, corps_summary)
  log(bWriteLog and "get_corps_summary_rsp receive:" .. corps_id)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.RefreshCorpsSummary(corps_summary)
end
function RoleInfoSystem.RoleSegmentInfo()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  DataMgr.SetCurSegment(RoleInfoMainSystem.GetShowRoleinfoOfZoneID())
  RoleInfoSystem.PersonalBasicInfo.role_segment_solo = tonumber(DataMgr.roleData.segment.solo)
  RoleInfoSystem.PersonalBasicInfo.role_segment_double = tonumber(DataMgr.roleData.segment.double)
  RoleInfoSystem.PersonalBasicInfo.role_segment_team = tonumber(DataMgr.roleData.segment.team)
  RoleInfoSystem.PersonalBasicInfo.role_avatar_frame = tonumber(DataMgr.roleData.cur_avatar_box_id)
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_solo = tonumber(DataMgr.roleData.segment.fpp_solo)
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_double = tonumber(DataMgr.roleData.segment.fpp_double)
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_team = tonumber(DataMgr.roleData.segment.fpp_team)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local currZone = ZoneSystem.nChooseZoneID or 1
  if currZone == 0 then
    currZone = 1
  end
  log(bWriteLog and "RoleSegmentInfo currZone = " .. tostring(currZone))
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  log(bWriteLog and "RoleSegmentInfo zoneId = " .. tostring(zoneId))
  if currZone and zoneId and currZone == zoneId then
    log(bWriteLog and "RoleSegmentInfo refresh segment data")
    RoleInfoSystem.PersonalBasicInfo.curr_role_segment_solo = tonumber(DataMgr.roleData.segment.solo)
    RoleInfoSystem.PersonalBasicInfo.curr_role_segment_double = tonumber(DataMgr.roleData.segment.double)
    RoleInfoSystem.PersonalBasicInfo.curr_role_segment_team = tonumber(DataMgr.roleData.segment.team)
    RoleInfoSystem.PersonalBasicInfo.curr_role_avatar_frame = tonumber(DataMgr.roleData.cur_avatar_box_id)
    RoleInfoSystem.PersonalBasicInfo.curr_role_segmentFPP_solo = tonumber(DataMgr.roleData.segment.fpp_solo)
    RoleInfoSystem.PersonalBasicInfo.curr_role_segmentFPP_double = tonumber(DataMgr.roleData.segment.fpp_double)
    RoleInfoSystem.PersonalBasicInfo.curr_role_segmentFPP_team = tonumber(DataMgr.roleData.segment.fpp_team)
  end
  RoleInfoSystem.PersonalBasicInfo.role_all_zone_segment_max = DataMgr.GetMaxRankLevel()
end
function RoleInfoSystem.get_role_basic_info_rsp(role_basic_info_list)
  log_tree("get_role_basic_info_rsp ret=", role_basic_info_list)
  RoleInfoSystem.PersonalBasicInfo = {}
  local _, currProfileInfo = next(role_basic_info_list)
  if currProfileInfo == nil then
    log(bWriteLog and "get_role_basic_info_rsp:nil")
    return
  end
  local creditValue = 100
  if currProfileInfo.credit ~= nil then
    creditValue = currProfileInfo.credit
  end
  local corpsID = 0
  if currProfileInfo.corps_id ~= nil then
    corpsID = currProfileInfo.corps_id
  end
  RoleInfoSystem.PersonalBasicInfo = {
    role_name = currProfileInfo.nickName,
    role_id = currProfileInfo.uid,
    role_sex = currProfileInfo.sex - 1,
    role_nation = currProfileInfo.nation,
    role_image = currProfileInfo.picUrl,
    role_upvote = currProfileInfo.upvote or 0,
    role_curlevel = "",
    role_nextlevel = "",
    role_curexpnum = currProfileInfo.exp,
    role_needexpnum = "",
    role_sign = currProfileInfo.signature,
    role_startup_type = GetSafeNumber(currProfileInfo.startup_type),
    role_credit = GetSafeNumber(creditValue),
    role_corpsid = corpsID,
    role_upassIsBuy = currProfileInfo.upass.is_buy,
    role_upassKeepBuy = currProfileInfo.upass.keep_buy or 0,
    role_upassUiShow = currProfileInfo.upass.switch.ui == true and 1 or 0,
    role_upassLevel = currProfileInfo.upass.level,
    role_aliasId = currProfileInfo.alias.id,
    role_aliasTitle = currProfileInfo.alias.title,
    role_aliasNation = currProfileInfo.alias.nation,
    role_aliasReceiveTime = 0,
    role_aliasExpireTime = 0,
    role_corpAliasId = currProfileInfo.corp_alias_id,
    role_carteamId = currProfileInfo.carteam_id or 0,
    role_pve_expnum = currProfileInfo.pve_exp or 0,
    role_pve_levelnum = currProfileInfo.pve_level or 1,
    role_pve_levelname = "",
    role_pve_nextlevelname = "",
    role_pve_needexpnum = 0
  }
  if corpsID ~= nil and 0 < tonumber(corpsID) then
    RoleInfoSystem.get_corps_summary_req(corpsID, tonumber(currProfileInfo.uid))
  else
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.RefreshCorpsSummary({})
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalBasicInfo)
  RoleInfoSystem.PersonalBasicInfo.role_curlevelnum = tonumber(currProfileInfo.level)
  RoleInfoSystem.PersonalBasicInfo.role_nextlevelnum = tonumber(currProfileInfo.level) + 1
  RoleInfoSystem.PersonalBasicInfo.all_segment_info = currProfileInfo.segment_info
  RoleInfoSystem.PersonalBasicInfo.hsegment_title_det = currProfileInfo.hsegment_title_det
  RoleInfoSystem.PersonalBasicInfo.role_segment_solo = 101
  RoleInfoSystem.PersonalBasicInfo.role_segment_double = 101
  RoleInfoSystem.PersonalBasicInfo.role_segment_team = 101
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_solo = 101
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_double = 101
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_team = 101
  local _RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zoneId = _RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  if zoneId and RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId] ~= nil then
    RoleInfoSystem.PersonalBasicInfo.role_segment_solo = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.solo])
    RoleInfoSystem.PersonalBasicInfo.role_segment_double = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.double])
    RoleInfoSystem.PersonalBasicInfo.role_segment_team = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.team])
    RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_solo = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.fpp_solo])
    RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_double = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.fpp_double])
    RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_team = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.fpp_team])
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    local currZone = ZoneSystem.nChooseZoneID or 1
    if currZone == 0 then
      currZone = 1
    end
    log(bWriteLog and "get_role_basic_info_rsp currZone = " .. tostring(currZone))
    log(bWriteLog and "get_role_basic_info_rsp zoneId = " .. tostring(zoneId))
    if currZone and zoneId and currZone == zoneId then
      log(bWriteLog and "get_role_basic_info_rsp refresh segment data")
      RoleInfoSystem.PersonalBasicInfo.curr_role_segment_solo = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.solo])
      RoleInfoSystem.PersonalBasicInfo.curr_role_segment_double = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.double])
      RoleInfoSystem.PersonalBasicInfo.curr_role_segment_team = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.team])
      RoleInfoSystem.PersonalBasicInfo.curr_role_segmentFPP_solo = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.fpp_solo])
      RoleInfoSystem.PersonalBasicInfo.curr_role_segmentFPP_double = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.fpp_double])
      RoleInfoSystem.PersonalBasicInfo.curr_role_segmentFPP_team = tonumber(RoleInfoSystem.PersonalBasicInfo.all_segment_info[zoneId][segment_type.fpp_team])
    end
  end
  RoleInfoSystem.PersonalBasicInfo.role_all_zone_segment_max = 0
  for _, v in pairs(RoleInfoSystem.PersonalBasicInfo.all_segment_info) do
    for _, SegmentLevel in pairs(v) do
      RoleInfoSystem.PersonalBasicInfo.role_all_zone_segment_max = math.max(RoleInfoSystem.PersonalBasicInfo.role_all_zone_segment_max, SegmentLevel)
    end
  end
  local curlevel = tonumber(currProfileInfo.level)
  if 100 <= curlevel then
    local curmilitarylevel = CDataTable.GetTableData("MilitaryRankLevel", 100)
    RoleInfoSystem.PersonalBasicInfo.role_curlevel = tostring(curmilitarylevel.MilitaryRankName)
    RoleInfoSystem.PersonalBasicInfo.role_curexpnum = ""
    RoleInfoSystem.PersonalBasicInfo.role_needexpnum = ""
    RoleInfoSystem.PersonalBasicInfo.role_nextlevel = ""
    RoleInfoSystem.PersonalBasicInfo.role_curlevelnum = 100
    RoleInfoSystem.IsMaxLevel = true
  elseif 0 < curlevel then
    local curmilitarylevel = CDataTable.GetTableData("MilitaryRankLevel", curlevel)
    local nextmilitarylevel = CDataTable.GetTableData("MilitaryRankLevel", curlevel + 1)
    RoleInfoSystem.PersonalBasicInfo.role_curlevel = tostring(curmilitarylevel.MilitaryRankName)
    RoleInfoSystem.PersonalBasicInfo.role_needexpnum = tostring(curmilitarylevel.Exp)
    RoleInfoSystem.PersonalBasicInfo.role_nextlevel = tostring(nextmilitarylevel.MilitaryRankName)
    RoleInfoSystem.IsMaxLevel = false
  end
  local curPveLevel = tonumber(currProfileInfo.pve_level) or 1
  if 100 <= curPveLevel then
    local curPveLevelItem = CDataTable.GetTableData("PveLevel", 100)
    local PveLevelItem99 = CDataTable.GetTableData("PveLevel", 99)
    RoleInfoSystem.PersonalBasicInfo.role_pve_levelname = tostring(curPveLevelItem.name)
    RoleInfoSystem.PersonalBasicInfo.role_pve_expnum = PveLevelItem99.pve_exp
    RoleInfoSystem.PersonalBasicInfo.role_pve_needexpnum = PveLevelItem99.pve_exp
    RoleInfoSystem.PersonalBasicInfo.role_pve_nextlevelname = ""
    RoleInfoSystem.PersonalBasicInfo.role_pve_levelnum = 100
    RoleInfoSystem.IsMaxPveLevel = true
  elseif 0 < curPveLevel then
    local curPveLevelItem = CDataTable.GetTableData("PveLevel", curPveLevel)
    local nextPveLevelItem = CDataTable.GetTableData("PveLevel", curPveLevel + 1)
    RoleInfoSystem.PersonalBasicInfo.role_pve_levelname = tostring(curPveLevelItem.name)
    RoleInfoSystem.PersonalBasicInfo.role_pve_needexpnum = tostring(curPveLevelItem.Exp or 0)
    RoleInfoSystem.PersonalBasicInfo.role_pve_nextlevelname = tostring(nextPveLevelItem.name)
    RoleInfoSystem.IsMaxPveLevel = false
  end
  RoleInfoSystem.PersonalBasicInfo.role_avatar_frame = tonumber(currProfileInfo.cur_avatar_box_id)
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  SocialCardSystem.SocialCard = currProfileInfo.social_card
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  RoleInfoSystem.PersonalBasicInfo.is_del = logic_profile:IsPlayerDelete(currProfileInfo)
  RoleInfoSystem.PersonalBasicInfo.ace_imprint_show_id = currProfileInfo.ace_imprint_show_id
  RoleInfoSystem.PersonalBasicInfo.ace_imprint_base_id = currProfileInfo.ace_imprint_base_id
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoSystem.RequestHistorySeasonBattleInfo(setZoneId)
  RoleInfoSystem.UpdateShowRoleInfoOfZoneId()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  if setZoneId then
    RoleInfoMainSystem.UpdateShowRoleinfoOfZoneID(setZoneId)
  end
  local season_id = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  log(bWriteLog and "RequestHistorySeasonBattleInfo" .. tostring(zoneId) .. ",season_id:" .. tostring(season_id))
  if RoleInfoSystem.RoleCombatInfoGet.ZoneId ~= zoneId or RoleInfoSystem.RoleCombatInfoGet.SeasonId ~= season_id then
    RoleInfoSystem.RoleCombatInfoGet.ZoneId = zoneId
    RoleInfoSystem.RoleCombatInfoGet.SeasonId = season_id
    RoleInfoSystem.get_role_history_season_battle(RoleInfoMainSystem.GetPersonInfo().role_id, season_id, zoneId)
  end
end
function RoleInfoSystem.get_role_history_season_battle(uid, season_id, zoneId)
  log(bWriteLog and "get_role_history_season_battle uid:" .. tostring(uid) .. ",season_id:" .. tostring(season_id) .. ",zoneId:" .. zoneId)
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_role_history_season_battle(tonumber(uid), season_id, zoneId)
end
function RoleInfoSystem.get_role_history_season_battle_rsp(res, battle_info)
  log(bWriteLog and "RoleInfoSystem get_role_history_season_battle_rsp res = " .. tostring(res))
  log_tree("battle_info", battle_info)
  if res ~= 0 then
    log_error("Error: " .. res)
    RoleInfoSystem.RoleCombatInfoGet.ZoneId = -1
    RoleInfoSystem.RoleCombatInfoGet.SeasonId = -1
    RoleInfoSystem.ProcessSeasonCombatInfoError()
    return
  end
  RoleInfoSystem.RoleHistorySeasonBattleGet = true
  RoleInfoSystem.CombatTotalInfoList = {}
  RoleInfoSystem.CombatGradeInfoList = {}
  RoleInfoSystem.FPPCombatTotalInfoList = {}
  RoleInfoSystem.FPPCombatGradeInfoList = {}
  local role_info, fpp_role_info
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    if i == model_type.solo_model then
      role_info = battle_info.warsolo
      fpp_role_info = battle_info.fppsolo
    elseif i == model_type.double_model then
      role_info = battle_info.warduo
      fpp_role_info = battle_info.fppduo
    elseif i == model_type.team_model then
      role_info = battle_info.warsquad
      fpp_role_info = battle_info.fppsquad
    elseif i == model_type.all_model then
      role_info = battle_info.warall
      fpp_role_info = battle_info.warall
    end
    if role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.CombatTotalInfoList[i] = {
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.CombatTotalInfoList[i] = {
          role_totalHurt = role_info.total_hurt,
          role_allmatchnum = role_info.game_num,
          role_winnum = role_info.win_num,
          role_toptennum = role_info.top10_count,
          role_killnum = role_info.kill_num,
          role_kd = role_info.kd,
          role_kd_v2 = role_info.kd_v2,
          role_critrate = role_info.head_shot_ratio,
          role_maxsurvivetime = role_info.max_live_time,
          role_avesurvivetime = role_info.avg_live_time,
          role_maxdistance = role_info.max_move,
          role_avedistance = role_info.avg_move,
          role_aveheal = role_info.avg_cure,
          role_aidcount = role_info.rescue_teammates,
          role_score = role_info.rank_rating,
          role_killscore = role_info.kill_rating,
          role_rankscore = role_info.win_rating,
          role_hitrate = role_info.avg_shot_hit_ratio,
          role_critcount = role_info.head_shot_num,
          role_maxkill = role_info.max_kill,
          role_maxdamage = role_info.max_hurt,
          role_avedamage = role_info.avg_hurt,
          role_assist = role_info.total_assist,
          promo_rank_rating = role_info.promo_rank_rating,
          promo_kill_rating = role_info.promo_kill_rating,
          promo_win_rating = role_info.promo_win_rating
        }
        if type(role_info.game_num) == "number" and role_info.game_num ~= 0 then
          RoleInfoSystem.CombatTotalInfoList[i].role_winrate = role_info.win_num / role_info.game_num * 100
          RoleInfoSystem.CombatTotalInfoList[i].role_toptenrate = role_info.top10_count / role_info.game_num * 100
        else
          RoleInfoSystem.CombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.CombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.CombatGradeInfoList[i] = {
          survive_score = role_info.survive_score,
          top1_score = role_info.top1_score,
          rating_score = role_info.rating_score,
          fight_score = role_info.fight_score,
          assist_score = role_info.assist_score,
          sum_score = role_info.sum_score,
          grade = role_info.grade
        }
        local sgrade = role_info.grade
        RoleInfoSystem.CombatGradeInfoList[i].grade = ConvertGrade(sgrade)
      end
    elseif i == model_type.all_model then
      RoleInfoSystem.CombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.CombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      RoleInfoSystem.CombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
    end
    if fpp_role_info ~= nil then
      if i == model_type.all_model then
        RoleInfoSystem.FPPCombatTotalInfoList[i] = {
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio
        }
      else
        RoleInfoSystem.FPPCombatTotalInfoList[i] = {
          role_totalHurt = fpp_role_info.total_hurt,
          role_allmatchnum = fpp_role_info.game_num,
          role_winnum = fpp_role_info.win_num,
          role_toptennum = fpp_role_info.top10_count,
          role_killnum = fpp_role_info.kill_num,
          role_kd = fpp_role_info.kd,
          role_kd_v2 = fpp_role_info.kd_v2,
          role_critrate = fpp_role_info.head_shot_ratio,
          role_maxsurvivetime = fpp_role_info.max_live_time,
          role_avesurvivetime = fpp_role_info.avg_live_time,
          role_maxdistance = fpp_role_info.max_move,
          role_avedistance = fpp_role_info.avg_move,
          role_aveheal = fpp_role_info.avg_cure,
          role_aidcount = fpp_role_info.rescue_teammates,
          role_score = fpp_role_info.rank_rating,
          role_killscore = fpp_role_info.kill_rating,
          role_rankscore = fpp_role_info.win_rating,
          role_hitrate = fpp_role_info.avg_shot_hit_ratio,
          role_critcount = fpp_role_info.head_shot_num,
          role_maxkill = fpp_role_info.max_kill,
          role_maxdamage = fpp_role_info.max_hurt,
          role_avedamage = fpp_role_info.avg_hurt,
          role_assist = fpp_role_info.total_assist,
          promo_rank_rating = fpp_role_info.promo_rank_rating,
          promo_kill_rating = fpp_role_info.promo_kill_rating,
          promo_win_rating = fpp_role_info.promo_win_rating
        }
        if type(fpp_role_info.game_num) == "number" and fpp_role_info.game_num ~= 0 then
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_winrate = fpp_role_info.win_num / fpp_role_info.game_num * 100
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_toptenrate = fpp_role_info.top10_count / fpp_role_info.game_num * 100
        else
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_winrate = 0
          RoleInfoSystem.FPPCombatTotalInfoList[i].role_toptenrate = 0
        end
        RoleInfoSystem.FPPCombatGradeInfoList[i] = {
          survive_score = fpp_role_info.survive_score,
          top1_score = fpp_role_info.top1_score,
          rating_score = fpp_role_info.rating_score,
          fight_score = fpp_role_info.fight_score,
          assist_score = fpp_role_info.assist_score,
          sum_score = fpp_role_info.sum_score,
          grade = fpp_role_info.grade
        }
        local sfppgrade = fpp_role_info.grade
        RoleInfoSystem.FPPCombatGradeInfoList[i].grade = ConvertGrade(sfppgrade)
      end
    elseif i == model_type.all_model then
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
    end
  end
  RoleInfoSystem.FormatCombatInfo()
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList)
  if battle_info.segment_info then
    log_tree("battle_info.segment_info", battle_info.segment_info)
    RoleInfoSystem.PersonalBasicInfo.role_segment_solo = tonumber(battle_info.segment_info[segment_type.solo])
    RoleInfoSystem.PersonalBasicInfo.role_segment_double = tonumber(battle_info.segment_info[segment_type.double])
    RoleInfoSystem.PersonalBasicInfo.role_segment_team = tonumber(battle_info.segment_info[segment_type.team])
    RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_solo = tonumber(battle_info.segment_info[segment_type.fpp_solo])
    RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_double = tonumber(battle_info.segment_info[segment_type.fpp_double])
    RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_team = tonumber(battle_info.segment_info[segment_type.fpp_team])
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local zoneId = RoleInfoMainSystem.GetShowRoleinfoOfZoneID()
  if battle_info.warall and battle_info.warall.rank_rating ~= nil then
    RoleInfoSystem.PersonalTotalScoreInfo[zoneId] = {
      role_totalscore = battle_info.warall.rank_rating
    }
  else
    RoleInfoSystem.PersonalTotalScoreInfo[zoneId] = {
      role_totalscore = RoleInfoSystem.default_role_totalscore
    }
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalScoreInfo)
  if battle_info.warall and battle_info.warall.fpp_rank_rating ~= nil then
    RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId] = {
      role_totalscore = battle_info.warall.fpp_rank_rating
    }
  else
    RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId] = {
      role_totalscore = RoleInfoSystem.default_role_totalscore
    }
  end
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalScoreInfo)
  RoleInfoSystem.SetBrokenLineData(battle_info, true)
  local rank_util = require("client.slua.logic.rank.rank_util")
  local role_totalscore = 0
  if RoleInfoSystem.PersonalTotalScoreInfo[zoneId] and RoleInfoSystem.PersonalTotalScoreInfo[zoneId].role_totalscore then
    role_totalscore = tonumber(RoleInfoSystem.PersonalTotalScoreInfo[zoneId].role_totalscore)
  end
  local text = rank_util.calc_topn_percentage(role_totalscore, battle_info.tpp_refer_rating, "total", battle_info.tpp_rank)
  RoleInfoSystem.PersonalTotalRankInfo[zoneId] = {role_totalrank = text}
  RoleInfoSystem.SetElementToString(RoleInfoSystem.PersonalTotalRankInfo)
  role_totalscore = 0
  if RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId] and RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId].role_totalscore then
    role_totalscore = tonumber(RoleInfoSystem.FPPPersonalTotalScoreInfo[zoneId].role_totalscore)
  end
  text = rank_util.calc_topn_percentage(role_totalscore, battle_info.fpp_refer_rating, "total", battle_info.fpp_rank)
  RoleInfoSystem.FPPPersonalTotalRankInfo[zoneId] = {role_totalrank = text}
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPPersonalTotalRankInfo)
  RoleInfoSystem.SegmentTitleRecord = battle_info.segment_title_id_list or {}
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_HISBATTLE_CHANGE, battle_info)
end
function RoleInfoSystem.ProcessSeasonCombatInfoError()
  log(bWriteLog and "RoleInfoSystem ProcessSeasonCombatInfoError")
  RoleInfoSystem.CombatTotalInfoList = {}
  RoleInfoSystem.CombatGradeInfoList = {}
  RoleInfoSystem.FPPCombatTotalInfoList = {}
  RoleInfoSystem.FPPCombatGradeInfoList = {}
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    if i == model_type.all_model then
      RoleInfoSystem.CombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatTotalInfo)
    else
      RoleInfoSystem.CombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.CombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      RoleInfoSystem.FPPCombatTotalInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatSDTInfo)
      RoleInfoSystem.FPPCombatGradeInfoList[i] = TableUtil.CopyTable(RoleInfoSystem.CombatGradeInfo)
      RoleInfoSystem.CombatTotalInfoList[i].role_score = 1500
      RoleInfoSystem.FPPCombatTotalInfoList[i].role_score = 1500
    end
  end
  RoleInfoSystem.PersonalTotalRankInfo = {}
  RoleInfoSystem.FPPPersonalTotalRankInfo = {}
  RoleInfoSystem.PersonalTotalScoreInfo = {}
  RoleInfoSystem.FPPPersonalTotalScoreInfo = {}
  RoleInfoSystem.FormatCombatInfo()
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.CombatGradeInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatTotalInfoList)
  RoleInfoSystem.SetElementToString(RoleInfoSystem.FPPCombatGradeInfoList)
  RoleInfoSystem.PersonalBasicInfo.role_segment_solo = 101
  RoleInfoSystem.PersonalBasicInfo.role_segment_double = 101
  RoleInfoSystem.PersonalBasicInfo.role_segment_team = 101
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_solo = 101
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_double = 101
  RoleInfoSystem.PersonalBasicInfo.role_segmentFPP_team = 101
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLEINFO)
end
function RoleInfoSystem.InitZonelist()
  local isInit = RoleInfoSystem.GetIsInitZoneList()
  if isInit then
    return
  end
  RoleInfoSystem.SetIsInitZoneList(true)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.InitZoneData()
end
function RoleInfoSystem.SetIsInitZoneList(is_init)
  IsInitZoneList = is_init or false
end
function RoleInfoSystem.GetIsInitZoneList()
  return IsInitZoneList or false
end
function RoleInfoSystem.Release()
  log(bWriteLog and "RoleInfoSystem Release")
  RoleInfoSystem.CurShowPlayerInfoUid = 0
  RoleInfoSystem.curseasonid = 0
  RoleInfoSystem.PlatID = ""
  RoleInfoSystem.IsMaxLevel = false
  RoleInfoSystem.IsFriend = false
  RoleInfoSystem.IsMaxPveLevel = false
  RoleInfoSystem.bCanShowGameDay = false
  RoleInfoSystem.PersonalBasicInfo = {}
  RoleInfoSystem.PersonalTotalRankInfo = {}
  RoleInfoSystem.PersonalTotalScoreInfo = {}
  RoleInfoSystem.CombatTotalInfoList = {}
  RoleInfoSystem.CombatGradeInfoList = {}
  RoleInfoSystem.FPPPersonalTotalRankInfo = {}
  RoleInfoSystem.FPPPersonalTotalScoreInfo = {}
  RoleInfoSystem.FPPCombatTotalInfoList = {}
  RoleInfoSystem.FPPCombatGradeInfoList = {}
  RoleInfoSystem.CurrSeasonTPPTotalScore = {}
  RoleInfoSystem.CurrSeasonTPPTotalRank = {}
  RoleInfoSystem.CurrSeasonFPPTotalScore = {}
  RoleInfoSystem.CurrSeasonFPPTotalRank = {}
  local RoleInfoMatchSystem = require("client.logic.roleinfo.logic_roleinfo_match")
  RoleInfoMatchSystem.Release()
  RoleInfoSystem.IntimateInfoList = {}
  RoleInfoSystem.HonorWallInfoList = {}
  RoleInfoSystem.AllSeasonIDList = {}
end
function RoleInfoSystem.SetEmpty()
  log(bWriteLog and "RoleInfoSystem SetEmpty")
  RoleInfoSystem.PersonalBasicInfo = {}
  RoleInfoSystem.PersonalTotalRankInfo = {}
  RoleInfoSystem.PersonalTotalScoreInfo = {}
  RoleInfoSystem.CombatTotalInfoList = {}
  RoleInfoSystem.CombatGradeInfoList = {}
  RoleInfoSystem.FPPPersonalTotalRankInfo = {}
  RoleInfoSystem.FPPPersonalTotalScoreInfo = {}
  RoleInfoSystem.FPPCombatTotalInfoList = {}
  RoleInfoSystem.FPPCombatGradeInfoList = {}
  RoleInfoSystem.HonorWallInfoList = {}
  local RoleInfoMatchSystem = require("client.logic.roleinfo.logic_roleinfo_match")
  RoleInfoMatchSystem.SetEmpty()
  RoleInfoSystem.PersonalBasicInfo = {
    role_name = "",
    role_id = "",
    role_sex = "",
    role_nation = "",
    role_image = "",
    role_upvote = 0,
    role_charisma = 0,
    role_curlevel = "",
    role_nextlevel = "",
    role_curexpnum = "",
    role_needexpnum = "",
    role_sign = "",
    role_curlevelnum = 0,
    role_nextlevelnum = 0,
    role_segment_solo = 0,
    role_segment_double = 0,
    role_segment_team = 0,
    role_segment_max = 0,
    role_all_zone_segment_max = 0,
    role_startup_type = 0,
    role_avatar_frame = 0,
    all_segment_info = {},
    role_segmentFPP_solo = 0,
    role_segmentFPP_double = 0,
    role_segmentFPP_team = 0,
    role_segmentFPP_max = 0,
    role_upassIsBuy = 0,
    role_upassUiShow = 0,
    role_upassLevel = 0,
    role_upassKeepBuy = 0,
    curr_role_segment_solo = 0,
    curr_role_segment_double = 0,
    curr_role_segment_team = 0,
    curr_role_segmentFPP_solo = 0,
    curr_role_segmentFPP_double = 0,
    curr_role_segmentFPP_team = 0,
    role_pve_expnum = 0,
    role_pve_levelnum = 0,
    role_pve_levelname = "",
    role_pve_nextlevelname = "",
    role_pve_needexpnum = 0
  }
  RoleInfoSystem.PersonalTotalRankInfo = {}
  RoleInfoSystem.FPPPersonalTotalRankInfo = {}
  for i = 1, 4 do
    if i ~= 4 then
      RoleInfoSystem.CombatTotalInfoList[i] = {
        role_totalHurt = "",
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_maxsurvivetime = "",
        role_avesurvivetime = "",
        role_maxdistance = "",
        role_avedistance = "",
        role_aveheal = "",
        role_aidcount = "",
        role_winrate = 0,
        role_toptenrate = 0,
        role_score = "",
        role_killscore = "",
        role_rankscore = "",
        role_hitrate = "",
        role_critcount = "",
        role_maxkill = "",
        role_maxdamage = "",
        role_avedamage = "",
        role_assist = ""
      }
      RoleInfoSystem.FPPCombatTotalInfoList[i] = {
        role_totalHurt = "",
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = "",
        role_maxsurvivetime = "",
        role_avesurvivetime = "",
        role_maxdistance = "",
        role_avedistance = "",
        role_aveheal = "",
        role_aidcount = "",
        role_winrate = 0,
        role_toptenrate = 0,
        role_score = "",
        role_killscore = "",
        role_rankscore = "",
        role_hitrate = "",
        role_critcount = "",
        role_maxkill = "",
        role_maxdamage = "",
        role_avedamage = "",
        role_assist = ""
      }
    end
    if i == 4 then
      RoleInfoSystem.CombatTotalInfoList[i] = {
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = ""
      }
      RoleInfoSystem.FPPCombatTotalInfoList[i] = {
        role_allmatchnum = "",
        role_winnum = "",
        role_toptennum = "",
        role_killnum = "",
        role_kd = "",
        role_kd_v2 = "",
        role_critrate = ""
      }
    end
  end
  for i = 1, 3 do
    RoleInfoSystem.CombatGradeInfoList[i] = {
      survive_score = "",
      top1_score = "",
      rating_score = "",
      fight_score = "",
      assist_score = "",
      sum_score = "",
      grade = "0"
    }
    RoleInfoSystem.FPPCombatGradeInfoList[i] = {
      survive_score = "",
      top1_score = "",
      rating_score = "",
      fight_score = "",
      assist_score = "",
      sum_score = "",
      grade = "0"
    }
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.SetEmptyData()
end
function RoleInfoSystem.IsNeedRequestBattleInfo()
  if not RoleInfoSystem.CombatScoreInfoList or not next(RoleInfoSystem.CombatScoreInfoList) then
    return true
  end
  if not RoleInfoSystem.FPPCombatScoreInfoList or not next(RoleInfoSystem.FPPCombatScoreInfoList) then
    return true
  end
  for i, v in pairs(RoleInfoSystem.CombatScoreInfoList) do
    if not v.role_score or tostring(v.role_score) == "" then
      return true
    end
    if not v.role_killscore or tostring(v.role_killscore) == "" then
      return true
    end
    if not v.role_rankscore or tostring(v.role_rankscore) == "" then
      return true
    end
  end
  for i, v in pairs(RoleInfoSystem.FPPCombatScoreInfoList) do
    if not v.role_score or tostring(v.role_score) == "" then
      return true
    end
    if not v.role_killscore or tostring(v.role_killscore) == "" then
      return true
    end
    if not v.role_rankscore or tostring(v.role_rankscore) == "" then
      return true
    end
  end
  return false
end
function RoleInfoSystem.IsRoleFriend(uid)
  log(bWriteLog and "RoleInfoSystem IsRoleFriend")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local list = LogicFriend.GetAllFriendList()
  for _, v in pairs(list) do
    if tostring(v) == tostring(uid) then
      RoleInfoSystem.IsFriend = true
      return
    end
  end
end
function RoleInfoSystem.GetTableLength(tab)
  if type(tab) ~= "table" then
    log(bWriteLog and "tab is not a table!")
    return 0
  end
  local count = 0
  for k, v in pairs(tab) do
    count = count + 1
  end
  return count
end
function RoleInfoSystem.SetElementToString(tab)
  for k, v in pairs(tab or {}) do
    if type(v) ~= "table" then
      tab[k] = tostring(v)
    else
      RoleInfoSystem.SetElementToString(v)
    end
  end
end
function RoleInfoSystem.FormatCombatInfo()
  log(bWriteLog and "RoleInfoSystem FormatCombatInfo")
  local length = RoleInfoSystem.GetTableLength(model_type)
  for i = 1, length do
    local totalinfo = RoleInfoSystem.CombatTotalInfoList[i]
    totalinfo.role_kd = string.format("%.2f", totalinfo.role_kd)
    if totalinfo.role_kd_v2 then
      totalinfo.role_kd_v2 = string.format("%.2f", totalinfo.role_kd_v2)
    end
    totalinfo.role_critrate = string.format("%.1f", totalinfo.role_critrate * 100)
    if i ~= 4 then
      totalinfo.role_totalHurt = string.format("%.1f", totalinfo.role_totalHurt)
      totalinfo.role_maxsurvivetime = string.format("%.1f", totalinfo.role_maxsurvivetime / 60)
      totalinfo.role_avesurvivetime = string.format("%.1f", totalinfo.role_avesurvivetime / 60)
      totalinfo.role_maxdistance = string.format("%.2f", totalinfo.role_maxdistance / 1000)
      totalinfo.role_avedistance = string.format("%.2f", totalinfo.role_avedistance / 1000)
      totalinfo.role_aveheal = string.format("%.1f", totalinfo.role_aveheal)
      totalinfo.role_winrate = string.format("%.1f", totalinfo.role_winrate)
      totalinfo.role_toptenrate = string.format("%.1f", totalinfo.role_toptenrate)
      totalinfo.role_hitrate = string.format("%.1f", totalinfo.role_hitrate * 100)
      totalinfo.role_avedamage = string.format("%.1f", totalinfo.role_avedamage)
      totalinfo.role_maxdamage = string.format("%.0f", totalinfo.role_maxdamage)
    end
    local fpptotalinfo = RoleInfoSystem.FPPCombatTotalInfoList[i]
    fpptotalinfo.role_kd = string.format("%.2f", fpptotalinfo.role_kd)
    if fpptotalinfo.role_kd_v2 then
      fpptotalinfo.role_kd_v2 = string.format("%.2f", fpptotalinfo.role_kd_v2)
    end
    fpptotalinfo.role_critrate = string.format("%.1f", fpptotalinfo.role_critrate * 100)
    if i ~= 4 then
      fpptotalinfo.role_totalHurt = string.format("%.1f", fpptotalinfo.role_totalHurt)
      fpptotalinfo.role_maxsurvivetime = string.format("%.1f", fpptotalinfo.role_maxsurvivetime / 60)
      fpptotalinfo.role_avesurvivetime = string.format("%.1f", fpptotalinfo.role_avesurvivetime / 60)
      fpptotalinfo.role_maxdistance = string.format("%.2f", fpptotalinfo.role_maxdistance / 1000)
      fpptotalinfo.role_avedistance = string.format("%.2f", fpptotalinfo.role_avedistance / 1000)
      fpptotalinfo.role_aveheal = string.format("%.1f", fpptotalinfo.role_aveheal)
      fpptotalinfo.role_winrate = string.format("%.1f", fpptotalinfo.role_winrate)
      fpptotalinfo.role_toptenrate = string.format("%.1f", fpptotalinfo.role_toptenrate)
      fpptotalinfo.role_hitrate = string.format("%.1f", fpptotalinfo.role_hitrate * 100)
      fpptotalinfo.role_avedamage = string.format("%.1f", fpptotalinfo.role_avedamage)
      fpptotalinfo.role_maxdamage = string.format("%.0f", fpptotalinfo.role_maxdamage)
    end
  end
  for i = 1, length - 1 do
    local gradeinfo = RoleInfoSystem.CombatGradeInfoList[i]
    gradeinfo.survive_score = string.format("%.1f", gradeinfo.survive_score)
    gradeinfo.top1_score = string.format("%.1f", gradeinfo.top1_score)
    gradeinfo.rating_score = string.format("%.1f", gradeinfo.rating_score)
    gradeinfo.fight_score = string.format("%.1f", gradeinfo.fight_score)
    gradeinfo.assist_score = string.format("%.1f", gradeinfo.assist_score)
    gradeinfo.sum_score = string.format("%.1f", gradeinfo.sum_score)
    local fppgradeinfo = RoleInfoSystem.FPPCombatGradeInfoList[i]
    fppgradeinfo.survive_score = string.format("%.1f", fppgradeinfo.survive_score)
    fppgradeinfo.top1_score = string.format("%.1f", fppgradeinfo.top1_score)
    fppgradeinfo.rating_score = string.format("%.1f", fppgradeinfo.rating_score)
    fppgradeinfo.fight_score = string.format("%.1f", fppgradeinfo.fight_score)
    fppgradeinfo.assist_score = string.format("%.1f", fppgradeinfo.assist_score)
    fppgradeinfo.sum_score = string.format("%.1f", fppgradeinfo.sum_score)
  end
end
function ConvertGrade(sgrade)
  local grade = 0
  if sgrade == "B" then
    grade = 0
  elseif sgrade == "B+" then
    grade = 1
  elseif sgrade == "A" then
    grade = 2
  elseif sgrade == "A+" then
    grade = 3
  elseif sgrade == "S" then
    grade = 4
  elseif sgrade == "S+" then
    grade = 5
  elseif sgrade == "SS" then
    grade = 6
  elseif sgrade == "SS+" then
    grade = 7
  elseif sgrade == "SSS" then
    grade = 8
  else
    grade = 0
  end
  return grade
end
function RoleInfoSystem.get_role_lbs_battle_info_req(uid)
  log(bWriteLog and "get_role_lbs_battle_info_req")
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_role_lbs_battle_info(tonumber(uid), nil)
end
function RoleInfoSystem.get_role_lbs_battle_info_rsp(ok, callback, battle_info, curr_season_index)
  if battle_info then
    DataMgr.lbs_warzone_info.lbs_warzone_record = battle_info.lbs_warzone_info
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_WARZONE_BATTLE_INFO)
end
function RoleInfoSystem.modify_role_signature_respond(res, unlock_time)
  local TimeUtil = require("client.common.time_util")
  if res == NetErrorCode_NONE then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_MODIFY_SIGNINFO)
  elseif res == "signature-too-long" then
    log_error("Error: " .. res)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_TOOLONG_SIGNINFO)
    ShowNotice(LocUtil.GetLocalizeResStr(45943))
  elseif res == "is_dirty" or res == " have-dirty-in-signature" then
    log_error("Error: " .. res)
    local tips = LocUtil.GetLocalizeResStr(45981)
    ShowNotice(tips)
  elseif res == "is_banned" then
    local startTimeStr = TimeUtil.FormatTime_YMD(unlock_time)
    ShowNotice(LocUtil.LocalizeResFormat(22201, startTimeStr))
  end
end
function RoleInfoSystem.modify_social_card()
  log(bWriteLog and "RoleInfoSystem.modify_social_card")
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  SocialLobbyHandler.send_modify_social_card(SocialCardSystem.SocialCard, DataMgr.roleData.signature or "")
end
function RoleInfoSystem.modify_social_card_rsp(ok, social_card, signature)
  log(bWriteLog and "modify_social_card_rsp=" .. tostring(ok))
  if ok == 0 or ok == 105008 or ok == 105009 then
    local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
    SocialCardSystem.MySocialCard = social_card
    SocialCardSystem.SocialCard = social_card
    RoleInfoSystem.PersonalBasicInfo.role_sign = signature
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
    if profile then
      profile.    end
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_CARD_UPDATE, social_card, ok)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_CARDINFO)
    if ok == 105008 then
      ShowNotice(46033)
    end
    local status = GameStatus.GetGameStatus()
    log(bWriteLog and "modify_social_card_rsp status" .. tostring(status))
    if ok == 105009 and GameStatus.IsInLobbyOrMainCity() then
      ShowNotice(46035)
    end
  elseif ok == 105002 then
    RoleInfoSystem.PersonalBasicInfo.role_sign = ""
    DataMgr.ShowMessageBoxByID(ok)
    return
  elseif ok == 105005 then
    RoleInfoSystem.PersonalBasicInfo.role_sign = ""
    local tips = LocUtil.GetLocalizeResStr(45981)
    ShowNotice(tips)
    return
  end
end
function RoleInfoSystem.ModifySocialTag(selectedTagList)
  local list = {}
  for k, _ in pairs(selectedTagList or {}) do
    table.insert(list, k)
  end
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  SocialCardSystem.SocialCard.label = 0 < #list and list or nil
  RoleInfoSystem.modify_social_card()
end
function RoleInfoSystem.SendModifyRoleName(strName, itemid, instid)
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_modify_role_name(strName, itemid, instid)
end
function RoleInfoSystem.modify_role_name_rsp(ok, unlock_time, new_name)
  local time_util = require("client.common.time_util")
  if ok ~= NetErrorCode_NONE then
    if ok == "can not use last name" then
      ShowNotice(660019)
    elseif ok == "name-too-long" then
      ShowNotice(990002)
    elseif ok == "name-too-short" then
      ShowNotice(990003)
    elseif ok == "have-dirty-in-name" then
      ShowNotice(990004)
    elseif ok == "name-exist" then
      ShowNotice(990005)
    elseif ok == "no enough gold or item" then
      ShowNotice(660020)
    elseif ok == "one time per day" then
      ShowNotice(660021)
    elseif ok == "is_banned" then
      local startTimeStr = time_util.FormatTime_YMD(unlock_time)
      ShowNotice(LocUtil.LocalizeResFormat(22200, startTimeStr))
    elseif ok == "name-in-invalid-range" then
      ShowNotice(29920)
    else
      ShowNotice(ok)
    end
    return
  end
  if new_name then
    DataMgr.UpdateNickName(new_name)
  else
    ShowNotice(660022)
  end
  local isPCOB = false
  local reviseNameUI = UIManager.GetUI(UIManager.UI_Config.revise_name)
  if reviseNameUI then
    isPCOB = reviseNameUI:GetIsPCOB()
    reviseNameUI:ModifyNameOk(new_name)
    UIManager.CloseUI(UIManager.UI_Config.revise_name)
  end
  if isPCOB then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_OB_ROLENAME)
  else
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_ITEM_LIST)
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLENAME)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.team_info_request()
end
function RoleInfoSystem.SetRoleInfoSettingSwitch(setting_type)
  log(bWriteLog and "RoleInfoSystem.SetRoleInfoSettingSwitch setting_type = " .. tostring(setting_type))
  if setting_type == RoleSettingType.ForbidParachuteFollow then
    log(bWriteLog and "RoleInfoSystem.SetRoleInfoSettingSwitch AutoParachuteFollowSetting.SetAutoFollowSwitch")
    DataMgr.SendSettingReq_Bool(false, setting_type, DataMgr.GetRoleSetting(RoleSettingType.ForbidParachuteFollow) ~= 0)
  end
end
local MyRadarData = {}
local MyMatchRadarData = {}
function RoleInfoSystem.SetMyRadarData(role_combat_info, battle_info_no_rank)
  for key, value in pairs(role_combat_info) do
    if type(value) == "table" then
      local tab = {
        survive_score = value.survive_score or 0,
        top1_score = value.top1_score or 0,
        rating_score = value.rating_score or 0,
        fight_score = value.fight_score or 0,
        assist_score = value.assist_score or 0,
        sum_score = value.sum_score or 0,
        grade = value.grade or 0
      }
      MyRadarData[key] = tab
    end
  end
  log_tree("[ZH] MyRadarData", MyRadarData)
  for key, value in pairs(battle_info_no_rank) do
    if type(value) == "table" then
      local tab = {
        survive_score = value.survive_score or 0,
        top1_score = value.top1_score or 0,
        rating_score = value.rating_score or 0,
        fight_score = value.fight_score or 0,
        assist_score = value.assist_score or 0,
        sum_score = value.sum_score or 0,
        grade = value.grade or 0
      }
      MyMatchRadarData[key] = tab
    end
  end
  log_tree("[ZH] MyRadarData", MyMatchRadarData)
end
function RoleInfoSystem.GetMyRadarData()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local currModeIndex = RoleInfoMainSystem.GetCombatMode()
  local model = RoleInfoSystem.GetCurModelName()
  local logic_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_combat)
  local EnumModType = logic_combat:GetEnumModeType()
  if currModeIndex == EnumModType.Rank then
    return MyRadarData[model] or {}
  elseif currModeIndex == EnumModType.Match then
    return MyMatchRadarData[model] or {}
  end
  return {}
end
function RoleInfoSystem.GetCurModelName()
  local model = ""
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local type = RoleInfoMainSystem.GetCombatShootTypeID()
  local BP_CombatModelType = RoleInfoMainSystem.GetCombatModelType()
  if type == ShootType.TPPType then
    if BP_CombatModelType == 1 then
      model = "warsolo"
    elseif BP_CombatModelType == 2 then
      model = "warduo"
    elseif BP_CombatModelType == 3 then
      model = "warsquad"
    end
  elseif type == ShootType.FPPType then
    if BP_CombatModelType == 1 then
      model = "fppsolo"
    elseif BP_CombatModelType == 2 then
      model = "fppduo"
    elseif BP_CombatModelType == 3 then
      model = "fppsquad"
    end
  end
  return model
end
local BrokenLineList = {}
local lineDataTable = {}
function RoleInfoSystem.SetBrokenLineData(role_combat_info, isOldSeason)
  if not role_combat_info or not next(role_combat_info) then
    return
  end
  for key, value in pairs(role_combat_info) do
    if type(value) == "table" then
      if value.day_segment_rating and value.day_segment_rating.rating and value.day_segment_rating.rating < 1200 then
        value.day_segment_rating.rating = 1200
      end
      BrokenLineList[key] = value.day_segment_rating or {}
    end
  end
  RoleInfoSystem.isOldSeason = isOldSeason or false
end
function RoleInfoSystem.GetCurBrokenLineData()
  log_tree("[ZH] BrokenLineList", BrokenLineList)
  local model = RoleInfoSystem.GetCurModelName()
  log(bWriteLog and "[ZH] TypeModel: " .. tostring(model))
  return BrokenLineList[model] or {}
end
function RoleInfoSystem.GetMaxAndMinLevelInList(List)
  log(bWriteLog and "RoleInfoSystem.GetMaxAndMinLevelInList")
  log_tree("RoleInfoSystem.GetMaxAndMinLevelInList List", List)
  local minLevel = RoleInfoSystem.GetCurLevel()
  local SeasonSystem = require("client.logic.season.logic_season")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local seasonId = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()]
  local maxLevel = SeasonSystem.GetLevelByLevelOffSet(minLevel, 1, seasonId)
  local isSetValue = false
  for key, value in pairs(List) do
    if value.segment then
      if not isSetValue then
        isSetValue = true
        maxLevel = value.segment
        minLevel = value.segment
      end
      if maxLevel < tonumber(value.segment) then
        maxLevel = value.segment
      end
      if minLevel > tonumber(value.segment) then
        minLevel = value.segment
      end
    end
  end
  return maxLevel, minLevel
end
function RoleInfoSystem.GetStartTimeAndEndTime()
  local List = RoleInfoSystem.GetCurBrokenLineData()
  local lineTimeList = {}
  for k, v in pairs(List) do
    table.insert(lineTimeList, k)
  end
  table.sort(lineTimeList, function(a, b)
    return b < a
  end)
  return lineTimeList[1], lineTimeList[#lineTimeList]
end
function RoleInfoSystem.GetMaxRatingAndMinRating(List)
  local RatingList = {}
  for k, v in pairs(List) do
    table.insert(RatingList, tonumber(v.rating))
  end
  table.sort(RatingList, function(a, b)
    return b < a
  end)
  local maxrating = math.floor((RatingList[1] or 0) + 0.5)
  local minrating = math.floor((RatingList[#RatingList] or 0) + 0.5)
  return maxrating, minrating
end
function RoleInfoSystem.GetCurLevel()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local basicData = RoleInfoMainSystem.GetPersonInfo()
  if not basicData or not next(basicData) then
    return 101
  end
  local BP_CombatModelType = RoleInfoMainSystem.GetCombatModelType()
  local curLevel = 101
  if RoleInfoMainSystem.GetRoleInfoBaseShootTypeID() == 1 then
    if BP_CombatModelType == 1 then
      curLevel = basicData.role_segment_solo
    elseif BP_CombatModelType == 2 then
      curLevel = basicData.role_segment_double
    elseif BP_CombatModelType == 3 then
      curLevel = basicData.role_segment_team
    end
  elseif BP_CombatModelType == 1 then
    curLevel = basicData.role_segmentFPP_solo
  elseif BP_CombatModelType == 2 then
    curLevel = basicData.role_segmentFPP_double
  elseif BP_CombatModelType == 3 then
    curLevel = basicData.role_segmentFPP_team
  end
  return curLevel
end
function RoleInfoSystem.CalculateLineData()
  lineDataTable = {}
  local List = RoleInfoSystem.GetCurBrokenLineData()
  local maxLevel, minLevel = RoleInfoSystem.GetMaxAndMinLevelInList(List)
  local maxRating, minRating = RoleInfoSystem.GetMaxRatingAndMinRating(List)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local seasonId = RoleInfoSystem.AllSeasonIDList[RoleInfoMainSystem.GetRoleinfoSeasonListID()] or 0
  log(bWriteLog and "[liz] CalculateLineData seasonid: " .. tostring(seasonId))
  log(bWriteLog and "[ZH] maxLevel: " .. tostring(maxLevel))
  log(bWriteLog and "[ZH] minLevel: " .. tostring(minLevel))
  log(bWriteLog and "[ZH] maxRating: " .. tostring(maxRating))
  log(bWriteLog and "[ZH] minRating: " .. tostring(minRating))
  local SeasonSystem = require("client.logic.season.logic_season")
  local curLevel = RoleInfoSystem.GetCurLevel()
  if RoleInfoSystem.isOldSeason then
    curLevel = maxLevel
  end
  log(bWriteLog and "[ZH] \229\189\147\229\137\141\230\174\181\228\189\141 curLevel: " .. tostring(curLevel))
  local tab = {}
  if curLevel and 800 < curLevel then
    if 4200 <= minRating then
      minLevel = 801
    else
      minLevel = SeasonSystem.CurLevel(minRating, seasonId) or minLevel
      log(bWriteLog and "CalculateLineData NEW minLevel" .. tostring(minLevel))
    end
    if 4200 <= maxRating then
      maxLevel = 801
    end
    local hightLevelNum = math.floor((maxRating - 4200) / 100)
    local lowLevelNum = math.floor((4200 - (minRating - minRating % 100)) / 100)
    log(bWriteLog and "[ZH] hightLevelNum: " .. tostring(hightLevelNum))
    local DValueofLevel = lowLevelNum + hightLevelNum
    log(bWriteLog and "[ZH] DValueofLevel: " .. tostring(DValueofLevel))
    local DValueLevelsofLines = math.floor(DValueofLevel / 2) + 1
    log(bWriteLog and "[ZH] DValueLevelsofLines: " .. tostring(DValueLevelsofLines))
    maxRating = maxRating + 100
    if DValueofLevel == E_ValueofLevel.Zero then
    elseif DValueofLevel == E_ValueofLevel.OneOrOdd then
    elseif DValueofLevel % 2 == E_ValueofLevel.OneOrOdd then
    else
      maxRating = maxRating + 100
    end
    if 800 > tonumber(minLevel) then
      tab = {}
      tab.level = minLevel
      local rankCfg = FuncUtil.GetRankTableData(minLevel, seasonId)
      tab.rating = rankCfg and rankCfg.MinIntegral or 0
      table.insert(lineDataTable, tab)
      tab = {}
      local maxLevelRating = maxRating - maxRating % 100
      local minLevelRating = minRating - minRating % 100
      if 200 <= maxLevelRating - minLevelRating then
        tab.rating = maxLevelRating - (maxLevelRating - minLevelRating) / 2
        if 4200 <= tab.rating then
          tab.level = 801
        else
          tab.level = SeasonSystem.GetLevelByLevelOffSet(minLevel, (4200 - tab.rating) / 100, seasonId)
        end
        table.insert(lineDataTable, tab)
      end
    else
      if minRating == 0 then
        minRating = 4200
      end
      if maxRating == 100 then
        maxRating = 4300
      end
      tab = {}
      tab.level = minLevel
      tab.rating = minRating - minRating % 100
      table.insert(lineDataTable, tab)
      minRating = minRating - minRating % 100
      if tonumber(maxRating) - tonumber(minRating) > 200 then
        tab = {}
        tab.level = 801
        local maxLevelRating = maxRating - maxRating % 100
        local minLevelRating = minRating - minRating % 100
        tab.rating = maxLevelRating - (maxLevelRating - minLevelRating) / 2
        table.insert(lineDataTable, tab)
      end
    end
    tab = {}
    tab.level = maxLevel
    tab.rating = maxRating - maxRating % 100
    table.insert(lineDataTable, tab)
    log_tree("[ZH] lineDataTable", lineDataTable)
    return
  end
  local isSpecialLevel = false
  if 4200 <= maxRating then
    maxLevel = SeasonSystem.CurLevel(maxRating, seasonId)
    minLevel = SeasonSystem.CurLevel(minRating, seasonId)
    if minRating < 4200 then
      isSpecialLevel = true
    end
    if maxRating < 4300 then
      maxLevel = 710
    end
  end
  if minLevel == 701 then
    isSpecialLevel = true
    minLevel = 710
  end
  if maxLevel == 701 then
    isSpecialLevel = true
    maxLevel = 710
  end
  log(bWriteLog and "[ZH] minLevel: " .. tostring(minLevel))
  local DValueofSeg = SeasonSystem.GetLevelNumbersByLevel(minLevel, maxLevel, seasonId) or 0
  if isSpecialLevel then
    DValueofSeg = DValueofSeg - 1
    DValueofSeg = 0 < DValueofSeg and DValueofSeg or 0
  end
  log(bWriteLog and "[ZH] DValueofSeg: " .. tostring(DValueofSeg))
  local HasMidLine = true
  local maxSegCfg = FuncUtil.GetRankTableData(maxLevel, seasonId)
  local maxSegRating = maxSegCfg and maxSegCfg.MinIntegral or 0
  local addRating = 0
  if DValueofSeg == E_ValueofLevel.Zero then
    addRating = 100
    HasMidLine = false
  elseif DValueofSeg == E_ValueofLevel.OneOrOdd then
    addRating = 100
  elseif DValueofSeg % 2 == E_ValueofLevel.OneOrOdd then
    addRating = 100
  else
    addRating = 200
  end
  local maxShowRating = addRating + maxSegRating
  maxLevel = SeasonSystem.CurLevel(maxShowRating, seasonId) or maxLevel
  tab = {}
  tab.level = minLevel
  local minSegCfg = FuncUtil.GetRankTableData(minLevel, seasonId)
  local minSegRating = minSegCfg and minSegCfg.MinIntegral or 0
  tab.rating = minSegRating
  if minLevel == 101 then
    local firstRankCfg = FuncUtil.GetRankTableData(minLevel, seasonId)
    if firstRankCfg then
      local minScore = firstRankCfg.NextSeasonIntegralScore
      tab.rating = minScore
      minSegRating = minScore
    end
    if 25 <= seasonId then
      tab.rating = 1500
      minSegRating = 1500
    end
  end
  table.insert(lineDataTable, tab)
  if HasMidLine then
    tab = {}
    tab.rating = maxShowRating - (maxShowRating - minSegRating) / 2
    tab.level = SeasonSystem.CurLevel(tab.rating, seasonId) or 101
    table.insert(lineDataTable, tab)
  end
  tab = {}
  tab.level = maxLevel
  tab.rating = maxShowRating
  table.insert(lineDataTable, tab)
  log_tree("[ZH] lineDataTable", lineDataTable)
end
function RoleInfoSystem.GetLineTable()
  return lineDataTable or {}
end
function RoleInfoSystem.GetPositionAray(List)
  local BrokenLineArray = {}
  List = List or {}
  for key, value in pairs(List) do
    local tab = {
      time = key,
      segment = value.segment,
      rating = value.rating
    }
    table.insert(BrokenLineArray, tab)
  end
  table.sort(BrokenLineArray, function(a, b)
    return a.time < b.time
  end)
  log_tree("[ZH] BrokenLineArray", BrokenLineArray)
  return BrokenLineArray or {}
end
function RoleInfoSystem.GetUnitizationProportion(rating)
  local SeasonSystem = require("client.logic.season.logic_season")
  local MinRating = lineDataTable[1].rating
  local MaxRating = lineDataTable[#lineDataTable].rating
  local proportion = (rating - MinRating) / (MaxRating - MinRating)
  return proportion or 0
end
function RoleInfoSystem.GetUnitizationPositionList(List)
  local BrokenLineArray = RoleInfoSystem.GetPositionAray(List)
  local XAxisLen = (#BrokenLineArray or 1) - 1
  if XAxisLen <= 0 then
    XAxisLen = 1
  end
  local UnitPositionList = {}
  for index, value in ipairs(BrokenLineArray) do
    if value and value.time then
      local level = value.segment
      local unitTab = {
        X = (index - 1) / XAxisLen or 0,
        Y = RoleInfoSystem.GetUnitizationProportion(value.rating) or 0
      }
      table.insert(UnitPositionList, unitTab)
    end
  end
  table.sort(UnitPositionList, function(a, b)
    return a.X < b.X
  end)
  if 0 < #UnitPositionList then
    UnitPositionList[1].isShowPoint = 1
    UnitPositionList[#UnitPositionList].isShowPoint = 1
  end
  log_tree("[ZH] UnitPositionList", UnitPositionList)
  return UnitPositionList
end
return RoleInfoSystem