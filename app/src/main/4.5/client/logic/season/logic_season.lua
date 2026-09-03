local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local local SeasonSystem = {
  segment = {
    single = {
      rating = 0,
      rankno = 0,
      level = 0
    },
    double = {
      rating = 0,
      rankno = 0,
      level = 0
    },
    team = {
      rating = 0,
      rankno = 0,
      level = 0
    },
    fppsingle = {
      rating = 0,
      rankno = 0,
      level = 0
    },
    fppdouble = {
      rating = 0,
      rankno = 0,
      level = 0
    },
    fppteam = {
      rating = 0,
      rankno = 0,
      level = 0
    }
  },
  cur_season_id = 0,
  season_in_reward = {},
  season_end_reward = {},
  best_segment = 0,
  pre_best_segment = 0,
  check_end_get_one_user_rank_query = {},
  seasonReminderData = nil,
  segment_tasks = {},
  isNewSeason = false,
  challengeTipsInfo = nil,
  isNeedGetState = false,
  ChallengeExchangeTable = {},
  ConquerorMinScore = {},
  segment_adjust_info = {
    [1] = {AdjustId = 50},
    [2] = {AdjustId = 51},
    [3] = {AdjustId = 52},
    [4] = {AdjustId = 53},
    [5] = {AdjustId = 54},
    [6] = {AdjustId = 55},
    [7] = {AdjustId = 56},
    [8] = {AdjustId = 57},
    [9] = {AdjustId = 58},
    [10] = {AdjustId = 59}
  },
  gm_show_seasonSlap = false,
  slap_battle_type = nil,
  pending_battle_type = nil,
  slapInfoMap = {},
  hasImprintSlap = false,
  _showSeasonOnClose = false,
  _pendingImprintBaseId = nil
}
local E_PerspectiveType = ENUM_PerspectiveType
local SeasonSorceInt = function(score)
  return math.floor(score + 0.5)
end
function SeasonSystem.Enter()
  DataMgr.fillMaxSegmentInfo()
  SeasonSystem.segment.single.level = tonumber(DataMgr.maxSegmentSolo.SegmentLevel)
  SeasonSystem.segment.double.level = tonumber(DataMgr.maxSegmentDuo.SegmentLevel)
  SeasonSystem.segment.team.level = tonumber(DataMgr.maxSegmentSquad.SegmentLevel)
  SeasonSystem.segment.fppsingle.level = tonumber(DataMgr.maxSegmentSoloFpp.SegmentLevel)
  SeasonSystem.segment.fppdouble.level = tonumber(DataMgr.maxSegmentDuoFpp.SegmentLevel)
  SeasonSystem.segment.fppteam.level = tonumber(DataMgr.maxSegmentSquadFpp.SegmentLevel)
  SeasonSystem.FetchData(DataMgr.maxSegmentSolo.zoneid)
end
function SeasonSystem.Release()
end
local InvalidSegment = 701
local ConquerorSegment = 801
function SeasonSystem.CurLevel(score, seasonId)
  local data = FuncUtil.GetRankTable(seasonId or 0)
  local tmp = {}
  data = data or {}
  for k, v in pairs(data) do
    local level = v.Level
    if level ~= InvalidSegment and level ~= ConquerorSegment then
      table.insert(tmp, {level, v})
    end
  end
  local curLevel
  table.sort(tmp, function(a, b)
    return a[1] < b[1]
  end)
  if not score then
    return
  end
  for i, v in ipairs(tmp) do
    if v[2].MinIntegral and score < v[2].MinIntegral and curLevel then
      return curLevel
    end
    curLevel = v[2].Level
  end
  return curLevel
end
function SeasonSystem.FetchData()
  log(bWriteLog and "SeasonSystem.FetchData")
  SeasonSystem.segment.single.rating = 0
  SeasonSystem.segment.double.rating = 0
  SeasonSystem.segment.team.rating = 0
  SeasonSystem.segment.fppsingle.rating = 0
  SeasonSystem.segment.fppdouble.rating = 0
  SeasonSystem.segment.fppteam.rating = 0
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_role_battle_max_rank_rating()
end
function SeasonSystem.GetUserRankDataByMaxZoneId(zone_id)
  log(bWriteLog and "SeasonSystem.GetUserRankDataByMaxZoneId zone_id = " .. tostring(zone_id))
  if not zone_id then
    return
  end
  local map_lvl = {
    season_1001 = SeasonSystem.segment.single.level,
    season_2001 = SeasonSystem.segment.double.level,
    season_3001 = SeasonSystem.segment.team.level,
    season_4001 = SeasonSystem.segment.fppsingle.level,
    season_5001 = SeasonSystem.segment.fppdouble.level,
    season_6001 = SeasonSystem.segment.fppteam.level
  }
  local query_rankno = function(client_data, rank_id, zoneid)
    if SeasonSystem.high_segment(map_lvl[client_data]) or map_lvl[client_data] == 605 then
      SeasonSystem.check_end_get_one_user_rank_query[client_data] = 1
      local RankHandler = require("client.network.Protocol.RankHandler")
      RankHandler.send_get_one_user_rank(client_data, zoneid, 0, rank_id)
    end
  end
  SeasonSystem.check_end_get_one_user_rank_query = {}
  query_rankno("season_1001", 1001, zone_id)
  query_rankno("season_2001", 2001, zone_id)
  query_rankno("season_3001", 3001, zone_id)
  query_rankno("season_4001", 4001, zone_id)
  query_rankno("season_5001", 5001, zone_id)
  query_rankno("season_6001", 6001, zone_id)
end
function SeasonSystem.get_role_battle_max_rank_rating_rsp(solo_max_rank_rating, duo_max_rank_rating, squad_max_rank_rating, fpp_solo_max_rank_rating, fpp_duo_max_rank_rating, fpp_squad_max_rank_rating)
  log_tree("get_role_battle_max_rank_rating_rsp", solo_max_rank_rating)
  if type(solo_max_rank_rating) ~= "table" then
    SeasonSystem.segment.single.rating = solo_max_rank_rating
    SeasonSystem.segment.double.rating = duo_max_rank_rating
    SeasonSystem.segment.team.rating = squad_max_rank_rating
    SeasonSystem.segment.fppsingle.rating = fpp_solo_max_rank_rating
    SeasonSystem.segment.fppdouble.rating = fpp_duo_max_rank_rating
    SeasonSystem.segment.fppteam.rating = fpp_squad_max_rank_rating
  else
    SeasonSystem.rating_from_server = solo_max_rank_rating
    SeasonSystem.segment.single.rating = solo_max_rank_rating.solo.rank_rating
    SeasonSystem.segment.double.rating = solo_max_rank_rating.duo.rank_rating
    SeasonSystem.segment.team.rating = solo_max_rank_rating.squad.rank_rating
    SeasonSystem.segment.fppsingle.rating = solo_max_rank_rating.fppsolo.rank_rating
    SeasonSystem.segment.fppdouble.rating = solo_max_rank_rating.fppduo.rank_rating
    SeasonSystem.segment.fppteam.rating = solo_max_rank_rating.fppsquad.rank_rating
    SeasonSystem.segment.single.zone_id = solo_max_rank_rating.solo.zone_id
    SeasonSystem.segment.double.zone_id = solo_max_rank_rating.duo.zone_id
    SeasonSystem.segment.team.zone_id = solo_max_rank_rating.squad.zone_id
    SeasonSystem.segment.fppsingle.zone_id = solo_max_rank_rating.fppsolo.zone_id
    SeasonSystem.segment.fppdouble.zone_id = solo_max_rank_rating.fppduo.zone_id
    SeasonSystem.segment.fppteam.zone_id = solo_max_rank_rating.fppsquad.zone_id
    local logic_season_util = require("client.logic.season.logic_season_util")
    local segmentData = logic_season_util:GetSegmentDataByZoneId(solo_max_rank_rating.solo.zone_id)
    if segmentData and next(segmentData) then
      SeasonSystem.segment.single.level = segmentData[1] or 101
      SeasonSystem.segment.double.level = segmentData[2] or 101
      SeasonSystem.segment.team.level = segmentData[3] or 101
      SeasonSystem.segment.fppsingle.level = segmentData[4] or 101
      SeasonSystem.segment.fppdouble.level = segmentData[5] or 101
      SeasonSystem.segment.fppteam.level = segmentData[6] or 101
    end
    SeasonSystem.GetUserRankDataByMaxZoneId(solo_max_rank_rating.solo.zone_id)
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_task_state_list()
end
function SeasonSystem.check_end_get_one_user_rank(client_data)
  SeasonSystem.check_end_get_one_user_rank_query[client_data] = nil
  if next(SeasonSystem.check_end_get_one_user_rank_query) == nil then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_UPDATE, true)
  end
end
function SeasonSystem.get_one_user_rank_rsp(client_data, ok, zone_id, rank_info)
  log_tree("SeasonSystem.get_one_user_rank_rsp=", {
    client_data,
    ok,
    zone_id,
    rank_info
  })
  if rank_info == nil then
    rank_info = {}
  end
  if client_data == "season_1001" then
    if ok == 0 then
      SeasonSystem.segment.single.      SeasonSystem.segment.single.      if rank_info.rank_no == nil then
        SeasonSystem.segment.single.rankno = 0
      else
        SeasonSystem.segment.single.rankno = rank_info.rank_no
      end
    end
    SeasonSystem.check_end_get_one_user_rank(client_data)
  elseif client_data == "season_2001" then
    if ok == 0 then
      SeasonSystem.segment.double.      SeasonSystem.segment.double.      if rank_info.rank_no == nil then
        SeasonSystem.segment.double.rankno = 0
      else
        SeasonSystem.segment.double.rankno = rank_info.rank_no
      end
    end
    SeasonSystem.check_end_get_one_user_rank(client_data)
  elseif client_data == "season_3001" then
    if ok == 0 then
      SeasonSystem.segment.team.      SeasonSystem.segment.team.      if rank_info.rank_no == nil then
        SeasonSystem.segment.team.rankno = 0
      else
        SeasonSystem.segment.team.rankno = rank_info.rank_no
      end
    end
    SeasonSystem.check_end_get_one_user_rank(client_data)
  elseif client_data == "season_4001" then
    if ok == 0 then
      SeasonSystem.segment.fppsingle.      SeasonSystem.segment.fppsingle.      if rank_info.rank_no == nil then
        SeasonSystem.segment.fppsingle.rankno = 0
      else
        SeasonSystem.segment.fppsingle.rankno = rank_info.rank_no
      end
    end
    SeasonSystem.check_end_get_one_user_rank(client_data)
  elseif client_data == "season_5001" then
    if ok == 0 then
      SeasonSystem.segment.fppdouble.      SeasonSystem.segment.fppdouble.      if rank_info.rank_no == nil then
        SeasonSystem.segment.fppdouble.rankno = 0
      else
        SeasonSystem.segment.fppdouble.rankno = rank_info.rank_no
      end
    end
    SeasonSystem.check_end_get_one_user_rank(client_data)
  elseif client_data == "season_6001" then
    if ok == 0 then
      SeasonSystem.segment.fppteam.      SeasonSystem.segment.fppteam.      if rank_info.rank_no == nil then
        SeasonSystem.segment.fppteam.rankno = 0
      else
        SeasonSystem.segment.fppteam.rankno = rank_info.rank_no
      end
    end
    SeasonSystem.check_end_get_one_user_rank(client_data)
  end
end
function SeasonSystem.get_task_state_list_rsp(ok, season, cur_season_id, is_idle_time, best_segment, pre_best_segment, bseason_newer)
  log_tree("SeasonSystem.get_task_state_list_rsp=", {
    ok,
    season,
    cur_season_id,
    is_idle_time,
    best_segment,
    pre_best_segment,
    bseason_newer
  })
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  SeasonSystem.  local cfg_segment = FuncUtil.GetRankTableData(best_segment)
  if cfg_segment == nil then
    local tmp = {}
    table.insert(tmp, SeasonSystem.segment.single.level)
    table.insert(tmp, SeasonSystem.segment.double.level)
    table.insert(tmp, SeasonSystem.segment.team.level)
    table.insert(tmp, SeasonSystem.segment.fppsingle.level)
    table.insert(tmp, SeasonSystem.segment.fppdouble.level)
    table.insert(tmp, SeasonSystem.segment.fppteam.level)
    table.sort(tmp, function(a, b)
      return b < a
    end)
    SeasonSystem.best_segment = tmp[1]
  else
    SeasonSystem.  end
  cfg_segment = FuncUtil.GetRankTableData(pre_best_segment)
  if cfg_segment == nil then
    SeasonSystem.pre_best_segment = SeasonSystem.best_segment
  else
    SeasonSystem.  end
  SeasonSystem.  SeasonSystem.season_in_reward = {}
  if type(season.task_list) == "table" then
    for k, v in pairs(season.task_list) do
      local cfg = CDataTable.GetTableData("SeasonInReward", k)
      local reword = {
        id = k,
        sort_n = cfg and cfg.SortID or k,
        condition2 = v.condition2,
        prize_status = v.prize_status
      }
      table.insert(SeasonSystem.season_in_reward, reword)
    end
    table.sort(SeasonSystem.season_in_reward, function(a, b)
      return a.sort_n < b.sort_n
    end)
  end
  SeasonSystem.season_end_reward = {}
  if type(season.season_end_prize) == "table" then
    local TableUtil = require("common.table_util")
    SeasonSystem.season_end_reward = TableUtil.CopyTable(season.season_end_prize)
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  local has_reward = false
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  for i, v in ipairs(SeasonSystem.season_in_reward) do
    local cfg = CDataTable.GetTableData("SeasonInReward", v.id)
    if cfg and v.prize_status == 1 and logic_season_award:CheckIsReachCondition1(v.id) and v.condition2 >= cfg.Condition2_Param2 then
      has_reward = true
      break
    end
  end
  season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.reward, has_reward and 1 or 0)
  if season.segment_tasks and type(season.segment_tasks) == "table" then
    SeasonSystem.segment_tasks = season.segment_tasks
  end
  SeasonSystem.isNewSeason = bseason_newer or false
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_UPDATE)
  logic_season_award:get_task_state_list_rsp(season)
end
local ModePriorityTable = {
  [1] = "team",
  [2] = "double",
  [3] = "single",
  [4] = "fppteam",
  [5] = "fppdouble",
  [6] = "fppsingle"
}
function SeasonSystem.GetBestMode()
  local bestMode = "team"
  local bestRating = 0
  local bestLevel = 0
  if not SeasonSystem.segment then
    return bestMode
  end
  for _, modeName in ipairs(ModePriorityTable) do
    local modeRating = SeasonSystem.segment[modeName] and SeasonSystem.segment[modeName].rating or 0
    local modeLevel = SeasonSystem.segment[modeName] and SeasonSystem.segment[modeName].level or 101
    if bestLevel < modeLevel then
      bestRating = modeRating
      bestLevel = modeLevel
      bestMode = modeName
    elseif modeLevel == bestLevel and modeRating > bestRating then
      bestRating = modeRating
      bestLevel = modeLevel
      bestMode = modeName
    end
  end
  return bestMode
end
function SeasonSystem.SetPendingBattleType(battleType)
  log_format(bWriteLog and "SeasonSystem.SetPendingBattleType battleType = %s", tostring(battleType))
  SeasonSystem.pending_battle_type = battleType
end
function SeasonSystem.SetSlapBattleType(battleType)
  log_format(bWriteLog and "SeasonSystem.SetSlapBattleType battleType = %s", tostring(battleType))
  SeasonSystem.slap_battle_type = battleType
end
function SeasonSystem.OnRankSlapInfo(rankInfo)
  log_tree("SeasonSystem.OnRankSlapInfo rankInfo = ", rankInfo)
  if rankInfo == nil or next(rankInfo) == nil or rankInfo.new_segment == nil then
    log_error("SeasonSystem.OnRankSlapInfo get incorrect data!!!")
    return
  end
  log_format(bWriteLog and "SeasonSystem.OnRankSlapInfo SeasonSystem.slap_battle_type = %s", tostring(SeasonSystem.slap_battle_type))
  if rankInfo.mode then
    SeasonSystem.slapInfoMap[rankInfo.mode] = rankInfo
  end
  SeasonSystem.slapInfo = rankInfo
  if rankInfo and rankInfo.rank_no and rankInfo.rank_no > 0 then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "saveConquerorInfo1")
    PlayerPrefsSystem.SaveTableToFile_N(rankInfo, PlayerPrefsSystem.ePlayerPrefsType.eSeasonKing)
  end
  if SeasonSystem.gm_show_seasonSlap then
    log(bWriteLog and "SeasonSystem.OnRankSlapInfo. gm_show_seasonSlap")
    if SeasonSystem.CheckCanShowSeasonSlap() then
      SeasonSystem.ShowSeasonSlap()
    end
    return
  end
  local logic_post_switch_popup = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_post_switch_popup)
  logic_post_switch_popup:TryExecuteOne(BP_ENUM_MODULE_SEASON_SLAP)
end
function SeasonSystem.ShouldKing()
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonKing)
  if type(saveData) ~= "table" or next(saveData) == nil then
    log(bWriteLog and "SeasonSystem.ShouldKing false")
    return false
  else
    log(bWriteLog and "SeasonSystem.ShouldKing true")
    return true
  end
end
function SeasonSystem.OnGameStateChange(eventType, eventID, vars)
end
function SeasonSystem.high_segment(lv)
  return tonumber(lv) > 700
end
function SeasonSystem.on_season_end_reminder(seasonID, bestSegment, maxRating)
  SeasonSystem.seasonReminderData = SeasonSystem.seasonReminderData or {}
  SeasonSystem.seasonReminderData.  SeasonSystem.seasonReminderData.  SeasonSystem.seasonReminderData.  log(bWriteLog and "SeasonSystem.on_season_end_reminder ShowSeasonReminder")
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:ShowFaceSlapByID(BP_ENUM_MODULE_SEASON_REMIND)
end
function SeasonSystem.ShouldRemind()
  log(bWriteLog and "SeasonSystem.ShouldRemind")
  local logic_season_util = require("client.logic.season.logic_season_util")
  if not logic_season_util.IsModReady() then
    log(bWriteLog and "SeasonSystem.ShouldRemind not IsModReady")
    return false
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(10033) then
    log(bWriteLog and "SeasonSystem.ShouldRemind newbie")
    return false
  end
  if SeasonSystem.seasonReminderData then
    log(bWriteLog and "SeasonSystem.ShouldRemind has seasonReminderData")
    return true
  else
    log(bWriteLog and "SeasonSystem.ShouldRemind has not seasonReminderData")
    return false
  end
end
function SeasonSystem.ShowSeasonReminder()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() then
    log(bWriteLog and "SeasonSystem.ShowSeasonReminder newbie")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "SeasonSystem.ShowSeasonReminder IsInXMission")
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and "SeasonSystem.ShowSeasonReminder not FinishAllNewGuide")
    return
  end
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local needUpdateRole = newbieGuideManager.NeedUpdateRole()
  if needUpdateRole then
    log(bWriteLog and "SeasonSystem ShowSeasonReminder needUpdateRole")
    return
  end
  if DataMgr.anchor == 1 then
    log(bWriteLog and "SeasonSystem.ShowSeasonReminder \233\157\158PC OB\230\168\161\229\188\143")
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if logic_player_return.isPlayerReturnOpenNew() then
    log(bWriteLog and "[v_wllwu] SeasonSystem.ShowSeasonReminder isPlayerReturnOpenNew return ")
    return
  end
  if GameStatus.IsInLobbyOrMainCity() then
    if SeasonSystem.seasonReminderData then
      log(bWriteLog and "SeasonSystem.ShowSeasonReminder show ui_season_end_reminder")
      local logic_season_util = require("client.logic.season.logic_season_util")
      if logic_season_util.IsModReady() then
        UIManager.ShowUI(UIManager.UI_Config.ui_season_end_reminder, SeasonSystem.seasonReminderData.seasonID, SeasonSystem.seasonReminderData.bestSegment, SeasonSystem.seasonReminderData.maxRating)
      end
    end
    log(bWriteLog and "SeasonSystem.ShowSeasonReminder clear data")
    SeasonSystem.seasonReminderData = nil
  end
end
function SeasonSystem.SharePhoto(pSegmentId)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  local ScreenshotMaker = import("ScreenshotMaker")
  local sSharePath = ScreenshotMaker.MakePicture(true)
  local timer_ticker = require("common.time_ticker")
  local timer
  timer = timer_ticker.AddTimerLoop(0, function()
    if ScreenshotMaker.HasCaptured(sSharePath) then
      local cfg = {
        sceneType = ShareSceneType.SocialLobby,
        capturePath = sSharePath,
        otherTLog = TLogEventDefine.SocialPhotoShare,
        share_type = ShareBtnTLogShareTypeDefine.UpgradedSharing,
        isOld = true,
        campaign = "season",
        reasonStr = json.encode({
          uid = DataMgr.roleData.uid,
          segmentId = pSegmentId
        })
      }
      local Util = require("client.slua_ui_framework.util")
      local ShareMgr = require("client.logic.share.share_logic")
      ShareMgr.ShareBtnReq(1, ShareBtnTLogShareTypeDefine.UpgradedSharing, nil, nil)
      Util.ShowShare(cfg)
      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_SHARE)
      timer_ticker.RemoveTimer(timer)
    else
      log(bWriteLog and "  : not yet")
    end
  end, TIMER_INFINITE, 0.1)
end
function SeasonSystem.ShowShare()
  local ShareMgr = require("client.logic.share.share_logic")
  local Util = require("client.slua_ui_framework.util")
  local shareCfg = {
    isOld = true,
    campaign = "season_result"
  }
  Util.ShowShare(shareCfg, UIManager.UI_Config.season_result_share, ShareMgr.ShareImageURL)
end
function SeasonSystem.IsNewSeason()
  return SeasonSystem.isNewSeason
end
function SeasonSystem.GetRankRating()
  log(bWriteLog and "[ZH] GetRankRating")
  local SeasonMode = SeasonSystem.GetBestMode()
  local seasonServerInfo = SeasonSystem.segment[SeasonMode]
  local rating = math.floor(seasonServerInfo.rating + FLOAT_NUMBER_TRAIL)
  log(bWriteLog and "[ZH] rating: " .. tostring(rating))
  if rating <= 0 and DataMgr.roleData.segment_rating then
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    if ZoneSystem.nChooseZoneID then
      log(bWriteLog and "[ZH] ZoneSystem.nChooseZoneID: " .. tostring(ZoneSystem.nChooseZoneID))
      local ratingdata = DataMgr.roleData.segment_rating[ZoneSystem.nChooseZoneID]
      if ratingdata ~= nil then
        for key, value in pairs(ratingdata) do
          if value and value > rating then
            rating = value
          end
        end
        rating = math.floor(rating + FLOAT_NUMBER_TRAIL)
      end
    end
  end
  log(bWriteLog and "[ZH] rating: " .. tostring(rating))
  return rating or 0
end
function SeasonSystem.GetBestSegment()
  return SeasonSystem.best_segment or 101
end
function SeasonSystem.GetPreBestSegment()
  return SeasonSystem.pre_best_segment or 101
end
function SeasonSystem.GetMaxSegment()
  local curBest = SeasonSystem.GetBestSegment()
  local preBest = SeasonSystem.GetPreBestSegment()
  return math.max(curBest, preBest)
end
function SeasonSystem.OnChanllengeInfoChange(challenge_info)
  if challenge_info then
    SeasonSystem.ChanllengeScore = challenge_info
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_CHANLLENGE_SCORE)
  end
end
function SeasonSystem.GetChanllengeScoreAndFirstTag(zoneID, modeStr)
  local score = 0
  local tag = true
  if SeasonSystem.ChanllengeScore then
    local cs_data = SeasonSystem.ChanllengeScore[zoneID]
    if cs_data then
      local cs_squad_data = cs_data[modeStr]
      if cs_squad_data then
        score = cs_squad_data.score or 0
        local time_stamp = cs_squad_data.first or 0
        local TimeUtil = require("client.common.time_util")
        tag = TimeUtil.GetServerTimeInSec() - time_stamp > 86400 and true or false
      end
    end
  end
  return score, tag
end
local GetCurrFileterInfo = function(nCurrPlayerNum, nCurrPerspective)
  if nCurrPlayerNum and nCurrPlayerNum ~= 0 and nCurrPerspective and nCurrPerspective ~= 0 then
    return nCurrPlayerNum, nCurrPerspective
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local filterInfo = logic_mode_selection:GetFilterInfo()
  return filterInfo.teamNum, filterInfo.perspective
end
function SeasonSystem.GetChanllengeData(nCurrPlayerNum, nCurrPerspective)
  local num, pspct = GetCurrFileterInfo(nCurrPlayerNum, nCurrPerspective)
  if not num or not pspct then
    return nil, nil, nil, nil
  end
  local modeStr = "solo"
  if pspct == 100054 then
    if num == 1 then
      modeStr = "solo"
    elseif num == 2 then
      modeStr = "duo"
    elseif num == 4 then
      modeStr = "squad"
    end
  elseif pspct == 100053 then
    if num == 1 then
      modeStr = "fppsolo"
    elseif num == 2 then
      modeStr = "fppduo"
    elseif num == 4 then
      modeStr = "fppsquad"
    end
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  if not zoneID or zoneID == 0 then
    return nil, nil, nil, nil
  end
  local score, tag = SeasonSystem.GetChanllengeScoreAndFirstTag(zoneID, modeStr)
  local estimateNum = SeasonSystem.GetChallengeEstimatedNum(zoneID, modeStr)
  log(bWriteLog and "SeasonSystem.GetChanllengeData estimateNum = " .. tostring(estimateNum))
  local cfg = SeasonSystem.GetChallengeConfig(zoneID, modeStr)
  if cfg then
    return score, tag, cfg, estimateNum
  end
  return nil, nil, nil, nil
end
function SeasonSystem.GetCurModeRating(nCurrPlayerNum, nCurrPerspective)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  if zoneID == nil or zoneID == 0 then
    zoneID = 1
  end
  local rankData
  if DataMgr.roleData.segment_rating then
    rankData = DataMgr.roleData.segment_rating[zoneID]
  end
  if not rankData then
    return nil
  end
  local num, pspct = GetCurrFileterInfo(nCurrPlayerNum, nCurrPerspective)
  if pspct == E_PerspectiveType.TPP then
    if num == 1 then
      return rankData[1]
    elseif num == 2 then
      return rankData[2]
    elseif num == 4 then
      return rankData[3]
    end
  elseif pspct == E_PerspectiveType.FPP then
    if num == 1 then
      return rankData[4]
    elseif num == 2 then
      return rankData[5]
    elseif num == 4 then
      return rankData[6]
    end
  end
end
function SeasonSystem.GetCurrentSegment(nCurrPlayerNum, nCurrPerspective)
  local num, pspct = GetCurrFileterInfo(nCurrPlayerNum, nCurrPerspective)
  if not num or not pspct then
    return nil
  end
  local modeStr = "solo"
  if pspct == 100054 then
    if num == 1 then
      modeStr = "solo"
    elseif num == 2 then
      modeStr = "duo"
    elseif num == 4 then
      modeStr = "squad"
    end
  elseif pspct == 100053 then
    if num == 1 then
      modeStr = "fppsolo"
    elseif num == 2 then
      modeStr = "fppduo"
    elseif num == 4 then
      modeStr = "fppsquad"
    end
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  if zoneID == nil or zoneID == 0 then
    zoneID = 1
  end
  local segTable = DataMgr.roleData.allzoneSegment
  local e_mode_to_id = {
    solo = 1,
    duo = 2,
    squad = 3,
    fppsolo = 4,
    fppduo = 5,
    fppsquad = 6
  }
  if segTable and segTable[zoneID] and e_mode_to_id[modeStr] and segTable[zoneID][e_mode_to_id[modeStr]] then
    local segment = segTable[zoneID][e_mode_to_id[modeStr]]
    return segment
  else
    return nil
  end
end
function SeasonSystem.UpdateRating(curRating, battle_type, zoneID)
  if not curRating or curRating <= 0 then
    log(bWriteLog and "[ZH] SeasonSystem.UpdateRating curRating can not use ")
    return
  end
  if BP_STRUCT_BattleResultData.battle_owner ~= 0 then
    log(bWriteLog and "[ZH] SeasonSystem.UpdateRating BP_STRUCT_BattleResultData.battle_owner is 0")
    return
  end
  if 101 == battle_type or 102 == battle_type or 103 == battle_type or 401 == battle_type or 402 == battle_type or 403 == battle_type then
  else
    log(bWriteLog and "[ZH] SeasonSystem.UpdateRating not Ranking matching ")
    return
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  zoneID = zoneID or ZoneSystem.nChooseZoneID
  log(bWriteLog and "SeasonSystem.UpdateRating zoneID is " .. tostring(zoneID) .. " rating:" .. tostring(curRating) .. " battle_type" .. tostring(battle_type))
  local e_mode_to_id = {
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [401] = 4,
    [402] = 5,
    [403] = 6
  }
  if battle_type and zoneID and DataMgr.roleData.segment_rating then
    local ratingData = DataMgr.roleData.segment_rating[zoneID] or {}
    for key, value in pairs(ratingData) do
      if key == e_mode_to_id[battle_type] then
        ratingData[key] = curRating
        break
      end
    end
  end
end
function SeasonSystem.GetProtectTimes(nCurrPlayerNum, nCurrPerspective)
  local mode, zoneID = SeasonSystem.GetModeAndZoneId(nCurrPlayerNum, nCurrPerspective)
  if mode and zoneID and DataMgr and DataMgr.roleData and DataMgr.roleData.all_segment_protect_times and DataMgr.roleData.all_segment_protect_times[mode] and DataMgr.roleData.all_segment_protect_times[mode][zoneID] then
    return DataMgr.roleData.all_segment_protect_times[mode][zoneID].left_times
  end
  return nil
end
function SeasonSystem.UpdateProtectTimes()
  local mode, zoneID = SeasonSystem.GetModeAndZoneId()
  if mode and zoneID and DataMgr and DataMgr.roleData and DataMgr.roleData.all_segment_protect_times and DataMgr.roleData.all_segment_protect_times[mode] and DataMgr.roleData.all_segment_protect_times[mode][zoneID] then
    local times = DataMgr.roleData.all_segment_protect_times[mode][zoneID].left_times
    if 0 < times then
      DataMgr.roleData.all_segment_protect_times[mode][zoneID].left_times = times - 1
    end
  end
end
function SeasonSystem.GetChallengeEstimatedNum(zoneID, modeStr)
  if SeasonSystem.ChanllengeScore then
    local cs_data = SeasonSystem.ChanllengeScore[zoneID]
    if cs_data then
      local cs_squad_data = cs_data[modeStr]
      if cs_squad_data and cs_squad_data.estimated_num and cs_squad_data.estimated_num ~= 0 then
        return cs_squad_data.estimated_num
      end
    end
  end
  local paramTable = CDataTable.GetTable("ParamTable")
  if paramTable and paramTable.Challenge_estimates then
    local estimateNum = paramTable.Challenge_estimates.ParamValue
    if estimateNum then
      local cfg = SeasonSystem.GetChallengeConfig(zoneID, modeStr)
      if cfg then
        estimateNum = math.floor(cfg.AbleScore / estimateNum)
        return estimateNum
      end
    end
  end
  return nil
end
function SeasonSystem.GetChallengeConfig(zoneID, modeStr)
  local segTable = DataMgr.roleData.allzoneSegment
  local e_mode_to_id = {
    solo = 1,
    duo = 2,
    squad = 3,
    fppsolo = 4,
    fppduo = 5,
    fppsquad = 6
  }
  if segTable and segTable[zoneID] and e_mode_to_id[modeStr] and segTable[zoneID][e_mode_to_id[modeStr]] then
    local rank_level = segTable[zoneID][e_mode_to_id[modeStr]]
    local cfg = SeasonSystem.GetChanllengeCfg(rank_level)
    return cfg
  end
  return nil
end
function SeasonSystem.GetModeAndZoneId(nCurrPlayerNum, nCurrPerspective)
  local num, pspct = GetCurrFileterInfo(nCurrPlayerNum, nCurrPerspective)
  if not num or not pspct then
    return nil
  end
  local mode = 101
  if pspct == 100054 then
    if num == 1 then
      mode = 101
    elseif num == 2 then
      mode = 102
    elseif num == 4 then
      mode = 103
    end
  elseif pspct == 100053 then
    if num == 1 then
      mode = 401
    elseif num == 2 then
      mode = 402
    elseif num == 4 then
      mode = 403
    end
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  return mode, ZoneSystem.nChooseZoneID
end
function SeasonSystem.IsScoreValid(nCurrPlayerNum, nCurrPerspective)
  local score, tag, cfg = SeasonSystem.GetChanllengeData(nCurrPlayerNum, nCurrPerspective)
  if score == nil or tag == nil or cfg == nil then
    return nil, nil
  end
  if cfg and score and score >= cfg.AbleScore then
    return true, tag
  else
    return false, tag
  end
end
function SeasonSystem.GetChanllengeCfg(rank_level)
  if not rank_level or type(rank_level) ~= "number" then
    return nil
  end
  local cfg_table = SeasonSystem.ChallengeExchangeTable
  if not cfg_table or not next(cfg_table) then
    return nil
  end
  table.sort(cfg_table, function(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
      return false
    end
    if a.ID == nil or b.ID == nil then
      return false
    end
    return a.ID < b.ID
  end)
  for k, v in pairs(cfg_table) do
    if not cfg_table[k + 1] then
      return v
    end
    if v.RankID and cfg_table[k + 1].RankID and rank_level >= v.RankID and rank_level < cfg_table[k + 1].RankID then
      return v
    end
  end
  return nil
end
function SeasonSystem.CheckShowSeasonGuide()
  if DataMgr.season_id ~= 20 then
    log(bWriteLog and "SeasonSystem.CheckShowSeasonGuide not season 20")
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local bFinish = growthprojectMgrB.IsFinishAllNewGuide()
  if not bFinish then
    log(bWriteLog and "[qintong]: SeasonSystem.CheckShowSeasonGuide new guide")
    return false
  end
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.newSeasonGuideUI)
  if record == nil or record.flag == nil then
    log(bWriteLog and "SeasonSystem.CheckShowSeasonGuide true")
    return true
  end
  log(bWriteLog and "SeasonSystem.CheckShowSeasonGuide false")
  return false
end
function SeasonSystem.ShowSeasonGuide()
  local logic_season_util = require("client.logic.season.logic_season_util")
  logic_season_util.CheckModWithFunc(function()
    UIManager.ShowUI(UIManager.UI_Config.season_new_guide)
    PlayerPrefsSystem.SaveTableToFile_N({flag = true}, PlayerPrefsSystem.ePlayerPrefsType.newSeasonGuideUI)
  end)
end
function SeasonSystem.CheckCanShowSeasonSlap()
  if not SeasonSystem.slapInfo then
    log_warning(bWriteLog and "SeasonSystem.CheckCanShowSeasonSlap slapInfo is nil")
    return false
  end
  return true
end
function SeasonSystem.ShowImprintSlap()
  log_format("SeasonSystem.ShowImprintSlap")
  local aceImprintBaseId = SeasonSystem._pendingImprintBaseId
  if not aceImprintBaseId then
    log_warning("SeasonSystem.ShowImprintSlap no pending imprint base_id, skip")
    return
  end
  local imprintInfo = {aceImprintBaseId = aceImprintBaseId}
  SeasonSystem._pendingImprintBaseId = nil
  SeasonSystem.hasImprintSlap = true
  SeasonSystem._showSeasonOnClose = true
  UIManager.ShowUI(UIManager.UI_Config.ui_season_imprint_slapface_s47, imprintInfo)
end
function SeasonSystem._PostSegmentSlapClose(segTitleSlapData, zoneId, modeType, segment, isHonorRoad)
  log_format("SeasonSystem._PostSegmentSlapClose hasImprintSlap=%s, isHonorRoad=%s", SeasonSystem.hasImprintSlap, isHonorRoad)
  if SeasonSystem.hasImprintSlap then
    return
  end
  if isHonorRoad then
    SeasonSystem.hasImprintSlap = false
    SeasonSystem._showSeasonOnClose = false
    local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
    logic_season_award:OpenHonorRoadPanel()
    return
  end
  if SeasonSystem._showSeasonOnClose then
    SeasonSystem._showSeasonOnClose = false
    GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_SEASON)
    return
  end
  if segTitleSlapData then
    local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
    local modeId = logic_segment_title:GetTitleModeIdbyBattleType(modeType)
    logic_segment_title:ShowSegmentTitleSlapUIBySlapData(segment, zoneId, modeId, segTitleSlapData)
  end
end
function SeasonSystem._PostImprintSlapClose()
  log_format("SeasonSystem._PostImprintSlapClose hasImprintSlap=%s", SeasonSystem.hasImprintSlap)
  SeasonSystem.hasImprintSlap = false
  if SeasonSystem._showSeasonOnClose then
    SeasonSystem._showSeasonOnClose = false
    GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_SEASON)
  end
end
function SeasonSystem.ShowSeasonSlap()
  log(bWriteLog and "SeasonSystem.ShowSeasonSlap")
  local info
  if SeasonSystem.slap_battle_type and SeasonSystem.slapInfoMap[SeasonSystem.slap_battle_type] then
    info = SeasonSystem.slapInfoMap[SeasonSystem.slap_battle_type]
  elseif not SeasonSystem.slap_battle_type then
    info = SeasonSystem.slapInfo
  else
    log(bWriteLog and "SeasonSystem.ShowSeasonSlap SeasonSystem.slapInfoMap has not data")
  end
  if not info then
    log_warning(bWriteLog and "SeasonSystem.ShowSeasonSlap info is nil")
    return
  end
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  local bPromotion = logic_promotion_homepage:IsOpen()
  local bIsImprintSlap = info.is_imprint_slap
  local bIsPromotionLevel = logic_promotion_homepage:IsPromotionLevel(info.new_segment)
  local aceImprintBaseId = info.new_ace_imprint_base_id
  local bIsBest = logic_promotion_homepage:IsBestRank(info.new_segment)
  log_format(bWriteLog and "SeasonSystem.ShowSeasonSlap bPromotion: %s, bIsImprintSlap: %s, bIsPromotionLevel: %s, aceImprintBaseId: %s, bIsBest: %s", bPromotion, bIsImprintSlap, bIsPromotionLevel, aceImprintBaseId, bIsBest)
  if bIsBest then
    return
  end
  log_tree(bWriteLog and "SeasonSystem.ShowSeasonSlap info:", info)
  SeasonSystem._showSeasonOnClose = true
  SeasonSystem.hasImprintSlap = false
  local TableUtil = require("common.table_util")
  UIManager.ShowUI(UIManager.UI_Config.ui_season_slapface_s47, TableUtil.CopyTable(info))
  if bPromotion and not bIsImprintSlap and bIsPromotionLevel and aceImprintBaseId then
    local uid = tonumber(DataMgr.roleData.uid)
    local AceImprintHandler = require("client.network.Protocol.AceImprintHandler")
    AceImprintHandler.send_get_ace_imprint_detail_req(uid)
    SeasonSystem._pendingImprintBaseId = aceImprintBaseId
    SeasonSystem.ShowImprintSlap()
  end
  SeasonSystem.slapInfo = nil
  SeasonSystem.SetSlapBattleType(nil)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.ShowNotSafe(BP_ENUM_SWITCH_ACCOUNT_SAFE_TIP_SEASON)
end
function SeasonSystem.GetNextLevelByLevel(level, offset, seasonId)
  level = level or 101
  offset = offset or 0
  local levelList = FuncUtil.GetRankTable(seasonId)
  local canReturn = false
  local canReduce = false
  for key, value in pairs(levelList) do
    if tonumber(level) == tonumber(key) then
      canReduce = true
    end
    if offset == 0 and canReduce then
      canReturn = true
    end
    if canReduce then
      offset = offset - 1
    end
    if canReturn then
      return tonumber(key)
    end
  end
  return tonumber(level)
end
function SeasonSystem.GetPreLevelByLevel(level, offset, seasonId)
  local levelList = FuncUtil.GetRankTable(seasonId)
  local CurLevelList = {}
  for key, value in pairs(levelList) do
    table.insert(CurLevelList, key)
    if tonumber(level) == tonumber(key) then
      break
    end
  end
  return CurLevelList[#CurLevelList - offset]
end
function SeasonSystem.GetLevelByLevelOffSet(level, offset, seasonId)
  offset = offset or 0
  if offset == 0 then
    return level
  elseif 0 < offset then
    return SeasonSystem.GetNextLevelByLevel(level, offset, seasonId)
  else
    return SeasonSystem.GetPreLevelByLevel(level, offset, seasonId)
  end
end
function SeasonSystem.GetLevelNumbersByLevel(minLevel, maxLevel, seasonId)
  local levelList
  if seasonId then
    levelList = FuncUtil.GetRankTable(seasonId)
  end
  local nums = 0
  local nMaxLevel = tonumber(maxLevel)
  local nMinLevel = tonumber(minLevel)
  if nMaxLevel <= nMinLevel then
    return 0
  end
  if not levelList then
    return 0
  end
  for key, value in pairs(levelList) do
    local nKey = tonumber(key)
    if nMinLevel <= nKey and nMaxLevel > nKey then
      nums = nums + 1
    end
    if nMaxLevel <= nKey then
      break
    end
  end
  return nums
end
function SeasonSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "SeasonSystem.OnModePostSwitch")
  if nextState == GameStatus.Lobby then
    if SeasonSystem.isNeedGetState then
      local SeasonHandler = require("client.network.Protocol.SeasonHandler")
      log(bWriteLog and "[v_ywuyuan] BattleResultHandler.on_battle_end_get_all_reward_rep send_get_task_state_list")
      SeasonHandler.send_get_task_state_list()
      SeasonSystem.isNeedGetState = false
    end
  elseif nextState == GameStatus.Fighting then
    log(bWriteLog and "SeasonSystem.OnModePostSwitch Fighting")
    SeasonSystem.slapInfoMap = {}
    if SeasonSystem.pending_battle_type then
      SeasonSystem.SetSlapBattleType(SeasonSystem.pending_battle_type)
      SeasonSystem.SetPendingBattleType(nil)
    else
      SeasonSystem.SetSlapBattleType(nil)
    end
  end
end
function SeasonSystem.ShowSeason()
  SeasonSystem.ShowSeasonHomepage()
end
function SeasonSystem.CloseSeasonChallengeTips()
  local ui = UIManager.GetUI(UIManager.UI_Config.Season_Challenge_UIBP)
  if ui then
    UIManager.CloseUI(UIManager.UI_Config.Season_Challenge_UIBP)
  end
end
function SeasonSystem.SyncChallengeExchangeTable(cfg_table)
  log(bWriteLog and "[jiantaosu] SeasonSystem.SyncChallengeExchangeTable #cfg_table = " .. tostring(#cfg_table))
  SeasonSystem.ChallengeExchangeTable = cfg_table
end
function SeasonSystem.CalChallengeProgressRate(Score, MaxScore, AbleScore)
  log(bWriteLog and "Score = " .. tostring(Score) .. " MaxScore = " .. tostring(MaxScore) .. " AbleScore = " .. tostring(AbleScore))
  local rate1 = 0.21
  local rate2 = 0.22
  local rate3 = 0.8
  local rate4 = 0.4
  if Score <= AbleScore then
    local resultPos = Score * rate1 / AbleScore
    if resultPos <= 0.0525 then
      return resultPos * 1.56
    elseif resultPos < 0.13 then
      return resultPos * 1.1
    else
      return resultPos
    end
  elseif Score < MaxScore / 2 then
    return (rate4 - rate2) * Score / (MaxScore / 2 - AbleScore) + rate2 - AbleScore * (rate4 - rate2) / (MaxScore / 2 - AbleScore)
  else
    return 1 / (MaxScore / rate3) * Score
  end
end
function SeasonSystem.SyncConquerorMinScore(min_rank_no_score_list)
  log(bWriteLog and "[jiantaosu] SeasonSystem.SyncConquerorMinScore #min_rank_no_score_list = " .. tostring(#min_rank_no_score_list))
  SeasonSystem.ConquerorMinScore = min_rank_no_score_list
end
function SeasonSystem.GetConquerorScore(zone_id, mode)
  if zone_id == nil or type(zone_id) ~= "number" then
    log(bWriteLog and "SeasonSystem.GetConquerorScore zone_id is invalid")
    return nil
  end
  if mode == nil or type(mode) ~= "string" then
    log(bWriteLog and "SeasonSystem.GetConquerorScore mode is invalid")
    return nil
  end
  if SeasonSystem.ConquerorMinScore == nil or not next(SeasonSystem.ConquerorMinScore) then
    log(bWriteLog and "SeasonSystem.GetConquerorScore SeasonSystem.ConquerorMinScore is nil or empty table")
    return nil
  end
  local scoreTab = SeasonSystem.ConquerorMinScore[zone_id]
  if scoreTab == nil or not next(scoreTab) then
    log(bWriteLog and "SeasonSystem.GetConquerorScore scoreTab is nil or empty table")
    return nil
  end
  local score = scoreTab[mode]
  if score == nil then
    log(bWriteLog and "SeasonSystem.GetConquerorScore score is nil")
    return nil
  end
  return score
end
function SeasonSystem.GetConquerorScoreByModeId(zone_id, mode_id)
  local mode_id_2_mode_str = {
    [101] = "solo",
    [102] = "duo",
    [103] = "squad",
    [401] = "fppsolo",
    [402] = "fppduo",
    [403] = "fppsquad"
  }
  return SeasonSystem.GetConquerorScore(zone_id, mode_id_2_mode_str[mode_id])
end
function SeasonSystem.ShowSeasonHomepage()
  if not UIManager.IsUIShow(UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP) then
    log(bWriteLog and "[jiantaosu] SeasonSystem.ShowSeasonHomepage open new seasonHomePage")
    UIManager.ShowUI(UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP)
  end
  local newbieGuideHandler = require("client.network.Protocol.NewbieGuideHandler")
  newbieGuideHandler.send_set_newbie_unlock_level_status_req(DataMgr.roleData.level, 1)
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  logic_season_guide_manager:SetEnterSeason()
end
function SeasonSystem.ShowSeasonRewardPage()
  UIManager.AndroidBackToLobby()
  log(bWriteLog and "[jiantaosu] SeasonSystem.ShowSeasonHomepage open new rewardPage")
  local ui = UIManager.GetUI(UIManager.UI_Config.ui_season_slapface_s47)
  if ui then
    UIManager.CloseUI(UIManager.UI_Config.ui_season_slapface_s47)
  end
  UIManager.ShowUI(UIManager.UI_Config.SeasonAwardMain_UIBP)
end
function SeasonSystem.GetNewbieSmallReward()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local is_jk = GlobalData.IsJapanOrKorea() and 1 or 0
  log(bWriteLog and "SeasonSystem.GetNewbieSmallReward() is_jk = " .. tostring(is_jk))
  local smallRewardConfig = CDataTable.GetTableByFilter("NewbieSmallRankReward", "SeasonID", DataMgr.season_id, "IsJK", is_jk, "Condition1_Param", 101)
  for k, v in pairs(smallRewardConfig) do
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
      log(bWriteLog and "SeasonSystem.GetNewbieSmallReward() the version is BLUEHOLE")
      log(bWriteLog and string.format("SeasonSystem.GetNewbieSmallReward() rewardId:%s, num:%s, url:%s", v.RewardItemID1, v.RewardItem_Num1, v.ImageUrl_blue_1))
      return v.RewardItemID1, v.RewardItem_Num1, v.ImageUrl_blue_1
    else
      log(bWriteLog and string.format("SeasonSystem.GetNewbieSmallReward() rewardId:%s, num:%s, url:%s", v.RewardItemID1, v.RewardItem_Num1, v.ImageUrl_global_1))
      return v.RewardItemID1, v.RewardItem_Num1, v.ImageUrl_global_1
    end
  end
end
function SeasonSystem.ReportAdjustEvent(rankInfo)
  log_tree(bWriteLog and "SeasonSystem.ReportAdjustEvent rankInfo", rankInfo)
  if rankInfo == nil or next(rankInfo) == nil or rankInfo.new_segment == nil then
    log_error("SeasonSystem.ReportAdjustEvent get incorrect data!!!")
    return
  end
  local segCfg = FuncUtil.GetRankTableData(rankInfo.new_segment)
  if segCfg and SeasonSystem.segment_adjust_info[segCfg.IntegralTypeNew] then
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(SeasonSystem.segment_adjust_info[segCfg.IntegralTypeNew].AdjustId, true)
  end
end
function SeasonSystem.ClearSeasonReminderData(_, __, bOnlineTran)
  log(bWriteLog and "SeasonSystem.ClearSeasonReminderData bOnlineTran = " .. tostring(bOnlineTran))
  log_tree("SeasonSystem.ClearSeasonReminderData", SeasonSystem.seasonReminderData)
  if bOnlineTran then
    SeasonSystem.seasonReminderData = nil
  end
end
function SeasonSystem.IsInSeasonIdleTime()
  log(bWriteLog and "SeasonSystem.IsInSeasonIdleTime " .. tostring(SeasonSystem.is_idle_time))
  return SeasonSystem.is_idle_time
end
function SeasonSystem.CheckShowSeasonRecordModuleTips()
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonRecordModuleTips)
  if data and data.hasShow then
    return false
  end
  return true
end
function SeasonSystem.SetSeasonRecordModuleAlreadyShow()
  local data = {hasShow = true}
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eSeasonRecordModuleTips)
end
function SeasonSystem.on_notify_challenge_compensate_score()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_SHOW_CHALLENGE_VALUE_POPUP)
end
function SeasonSystem.ShowChallengeValueTips()
  log(bWriteLog and "UI_Match_Entry:ShowChallengeValueTips")
  if IsWoWEditor then
    return
  end
  if not SeasonSystem.challengeTipsInfo or type(SeasonSystem.challengeTipsInfo) ~= "table" then
    log(bWriteLog and "UI_Match_Entry:ShowChallengeValueTips no challengeTipsInfo")
    return
  end
  local TableUtil = require("common.table_util")
  local tab = TableUtil.CopyTable(SeasonSystem.challengeTipsInfo or {})
  if not tab.score or tab.score == 0 then
    log(bWriteLog and "UI_Match_Entry:ShowChallengeValueTips no score")
    return
  end
  local needUpdateRole = false
  if LobbySystem.CheckUseNewGuide() and LobbySystem.roleData then
    needUpdateRole = LobbySystem.roleData.is_first_login == LobbySystem.NewbieRoleState.UpdateRole
  end
  if needUpdateRole then
    log(bWriteLog and "UI_Match_Entry:ShowChallengeValueTips need update role")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Season_Challenge_UIBP, tab.score)
  SeasonSystem.challengeTipsInfo = nil
end
function SeasonSystem.SetGMShowSeasonSlap(open)
  log(bWriteLog and "SeasonSystem.SetGMShowSeasonSlap. open: " .. tostring(open) .. "")
  SeasonSystem.gm_show_seasonSlap = open
end
return SeasonSystem