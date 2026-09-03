local RoleInfoHistorySystem = {
  uid = "",
  history_record_summary = {
    battle_id = 0,
    battle_type = 0,
    time = 0,
    person_rank = 0,
    team_rank = 0,
    kill = 0,
    segment = 0,
    rating = 0,
    change_rating = 0,
    final_level = "",
    title_id = 0
  },
  role_history_record = {},
  record_summary_list = {},
  show_record_battle_id = 0,
  privacy = true,
  cachedUid = "",
  showReplayGlowEffect = nil
}
local RoleInfoCanShowHistory = true
local RoleInfoHistoryEmptyType = 1
local AIMatchModeID = 32103
local isSinkMatchMode = function(modeID)
  return modeID == 40201 or modeID == 40202 or modeID == 40203 or modeID == 40204 or modeID == 40205 or modeID == 40206
end
local AIModeDifficultyLQA = {
  [32001] = 13730,
  [32002] = 13731,
  [32003] = 13732,
  [32004] = 13730,
  [32005] = 13731,
  [32006] = 13732
}
function RoleInfoHistorySystem.GetSummaryInfo(battle_id)
  for i, v in ipairs(RoleInfoHistorySystem.record_summary_list) do
    if battle_id == v.battle_id then
      return v
    end
  end
end
function RoleInfoHistorySystem.TestShowRecord(data)
  local roleinfo_history_data_mgr = require("client.logic.roleinfo.roleinfo_history_data_mgr")
  local testData = data or roleinfo_history_data_mgr.GetInitRecordData()
  RoleInfoHistorySystem.ShowRecord(testData, true)
end
function RoleInfoHistorySystem.ReqRecord(id)
  RoleInfoHistorySystem.show_record_battle_  local data = RoleInfoHistorySystem.role_history_record[RoleInfoHistorySystem.show_record_battle_id]
  if not data then
    local cache_num = 2
    local find_id = function()
      for i, v in ipairs(RoleInfoHistorySystem.record_summary_list) do
        if RoleInfoHistorySystem.show_record_battle_id == v.battle_id then
          return i
        end
      end
    end
    local nCurID = find_id()
    if nCurID then
      local tmp = {}
      for i = nCurID - cache_num, nCurID + cache_num do
        local s = RoleInfoHistorySystem.record_summary_list[i]
        if s then
          local tCurData = RoleInfoHistorySystem.role_history_record[s.battle_id]
          if tCurData == nil then
            table.insert(tmp, s.battle_id)
          end
        end
      end
      if 0 < #tmp then
        RoleInfoHistorySystem.bath_get_history_record(tmp)
      end
    end
  end
end
function RoleInfoHistorySystem.get_history_record_summary_rsp(uid, list)
  RoleInfoHistorySystem.cachedUid = uid
  RoleInfoHistorySystem.SetRecordSummarylist(uid, list)
  log_tree("RoleInfoHistorySystem.record_summary_list", RoleInfoHistorySystem.record_summary_list)
  RoleInfoHistorySystem.SetHistoryList()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_HISTORY_LIST_UI, uid)
end
function RoleInfoHistorySystem.send_show_history(showHistory)
  local privacyValue = true
  if showHistory ~= nil then
    privacyValue = showHistory
  end
  RoleInfoHistorySystem.privacy = showHistory
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_modify_role_privacy(privacyValue, nil)
end
function RoleInfoHistorySystem.SetCanShowHistory(canShow)
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    if canShow == true then
      canShow = 1
    else
      canShow = canShow ~= false and canShow or 0
    end
  end
  RoleInfoHistorySystem.privacy = canShow
  RoleInfoHistorySystem.UpdateCanShowHistory(canShow)
end
function RoleInfoHistorySystem.bath_get_history_record(battle_ids)
  if tonumber(RoleInfoHistorySystem.uid) == nil then
    log_error("bath_get_history_record RoleInfoHistorySystem.uid = nil:")
    return
  end
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.send_bath_get_history_record(tonumber(RoleInfoHistorySystem.uid), battle_ids)
  CharacterHandler.send_batch_get_peakgame_history_req(tonumber(RoleInfoHistorySystem.uid), battle_ids)
end
function RoleInfoHistorySystem.bath_get_history_record_rsp(uid, history_record_list)
  for i, v in ipairs(history_record_list) do
    RoleInfoHistorySystem.CorrectionTeammateListScore(v.TeammateList)
    v.    RoleInfoHistorySystem.role_history_record[v.battle_id] = v
  end
  local data = RoleInfoHistorySystem.role_history_record[RoleInfoHistorySystem.show_record_battle_id]
  local logic_xmission_history_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_history_record)
  local tData = logic_xmission_history_record:GetHistoryRecordDetailInfo(uid, RoleInfoHistorySystem.show_record_battle_id)
  if tData then
    log_tree("RoleInfoHistorySystem.bath_get_history_record_rsp has tData", tData)
    if data then
      data.TeamResultDatas = tData.TeamResultDatas
    else
      data = tData
    end
  end
  if data then
    RoleInfoHistorySystem.ShowRecord(data)
  end
end
function RoleInfoHistorySystem.CorrectionTeammateListScore(teammateList)
  if not teammateList then
    return
  end
  local maxScore = 100
  for k, tTeammateInfo in pairs(teammateList) do
    if tTeammateInfo.NewSurviveScore and maxScore < tTeammateInfo.NewSurviveScore then
      tTeammateInfo.NewSurviveScore = maxScore
    end
    if tTeammateInfo.NewAssistScore and maxScore < tTeammateInfo.NewAssistScore then
      tTeammateInfo.NewAssistScore = maxScore
    end
    if tTeammateInfo.NewEquipScore and maxScore < tTeammateInfo.NewEquipScore then
      tTeammateInfo.NewEquipScore = maxScore
    end
    if tTeammateInfo.NewBattleScore and maxScore < tTeammateInfo.NewBattleScore then
      tTeammateInfo.NewBattleScore = maxScore
    end
  end
end
function RoleInfoHistorySystem.notify_first_history_record(is_first_record)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local spData = RoleInfoMainSystem.GetSuperData()
  spData.historyRed = true
end
function RoleInfoHistorySystem.IsClassicMatchMode(battle_type)
  return battle_type == 111 or battle_type == 112 or battle_type == 113 or battle_type == 411 or battle_type == 412 or battle_type == 413
end
function RoleInfoHistorySystem.IsClassicRankMode(battle_type)
  return battle_type == 101 or battle_type == 102 or battle_type == 103 or battle_type == 401 or battle_type == 402 or battle_type == 403
end
function RoleInfoHistorySystem.IsDragonMode(battle_type)
  return battle_type == 64101 or battle_type == 64102 or battle_type == 64103
end
function RoleInfoHistorySystem.IsCanShowHistory()
  return RoleInfoCanShowHistory
end
function RoleInfoHistorySystem.UpdateCanShowHistory(is_show)
  local show = false
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
    show = is_show
  elseif is_show == nil then
    show = true
  else
    show = is_show
  end
  RoleInfoCanShowHistory = show
end
function RoleInfoHistorySystem.SetHistoryEmtyType(type)
  RoleInfoHistoryEmptyType = type or 1
end
function RoleInfoHistorySystem.GetHistoryEmtyType()
  return RoleInfoHistoryEmptyType or 1
end
function RoleInfoHistorySystem.SetRecordBattleId(id)
  RoleInfoHistorySystem.show_record_battle_id = id or ""
end
local getIsTMissionType = function(tConfig, nBattleType)
  local pIsTMode = false
  local mapKey
  if not tConfig then
    if nBattleType then
      tConfig = CDataTable.GetTableData("MatchModeTable", nBattleType)
    else
      return pIsTMode
    end
  end
  if tConfig and tConfig.ModeGroupID then
    local pModeGroupIds = load("return" .. tConfig.ModeGroupID)()
    local modeID = pModeGroupIds[1]
    if modeID then
      local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
      pIsTMode = LogicTxMissionMatch.IsXMissionMode(modeID)
      local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
      mapKey = LogicTxMissionDownload.GetMapKeyByModeID(modeID)
    end
  end
  return pIsTMode, mapKey
end
local FormatTime = function(tm)
  local TimeUtil = require("client.common.time_util")
  if type(tm) == "number" and 0 <= tm then
    local dt = TimeUtil.FormatTime_MDHM(tm, true)
    return tostring(dt)
  end
  return ""
end
local localText = function(id)
  return LocUtil.GetLocalizeResStr(id)
end
function RoleInfoHistorySystem.SetHistoryList()
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  logic_history_combat:DefineAndResetData()
  local isCanShow = RoleInfoHistorySystem.IsCanShowHistory()
  if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and RoleInfoHistorySystem.uid ~= DataMgr.roleData.uid then
    if isCanShow == 0 then
      RoleInfoHistorySystem.UpdateHistoryEmptyType(false)
      return
    elseif isCanShow == 1 then
    elseif isCanShow == 2 then
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      if not LogicFriend.IsMyFriend(RoleInfoHistorySystem.uid) then
        RoleInfoHistorySystem.UpdateHistoryEmptyType(false)
        return
      end
    end
  elseif not LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) and RoleInfoHistorySystem.uid ~= DataMgr.roleData.uid and not isCanShow then
    RoleInfoHistorySystem.UpdateHistoryEmptyType(false)
    return
  end
  local ListCount = 0
  local utility = require("common.utility")
  for _, v in ipairs(RoleInfoHistorySystem.record_summary_list) do
    local bSuccess, bAddCount = xpcall(RoleInfoHistorySystem.AddHistoryOneItem, utility.ErrorMessageHandler, v)
    if bSuccess and bAddCount then
      ListCount = ListCount + 1
    end
  end
  RoleInfoHistorySystem.UpdateHistoryEmptyType(0 < ListCount)
  if RoleInfoHistorySystem.uid == DataMgr.roleData.uid then
    local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
    logic_history_combat:ClearNewRecordEffectTag()
  end
end
function RoleInfoHistorySystem.AddHistoryOneItem(v)
  log_tree("[cw] v ", v)
  local tmp = {
    battle_id = tostring(v.battle_id),
    raw_battle_type = v.battle_type,
    battle_type = "",
    time = FormatTime(v.time),
    rank = 0,
    kill = tostring(v.kill),
    segment = 0,
    rating = "",
    change_rating = "",
    final_level = "",
    title_id = -1,
    show_score = true,
    is_blackroom = false,
    is_resource_battle = false,
    is_resource_win = false,
    is_txMission = false,
    txMissionEscaped = false,
    is_team_athletics = false,
    is_team_athletics_win = false,
    is_team_athletics_draw = false,
    is_team_athletics_mvp = false,
    team_athletics_hits = "",
    season_status_for_display = v.season_status_for_display or false,
    is_invalid = v.is_invalid or false,
    new_title_id = v.new_title_id or 0,
    cross_zone_flag = v.cross_zone_flag or false,
    is_ai_mode = v.battle_type == AIMatchModeID,
    is_sink_mode = isSinkMatchMode(v.battle_type),
    season_id = v.season_id or 23,
    worth_change = v.worth_change,
    compatibility_flag = v.compatibility_flag,
    is_escape = v.is_escape or 0,
    offline_time = v.offline_time or 0,
    camp_type = v.camp_type,
    behavior_score = v.behavior_score,
    sub_mode = v.sub_mode
  }
  local cfg = CDataTable.GetTableData("MatchModeTable", v.battle_type)
  local pIsTMode = getIsTMissionType(cfg)
  if cfg then
    local get_bt = function(sub_mode)
      if sub_mode then
        local cfg_sub_mode = CDataTable.GetTableData("BTMode", sub_mode)
        if cfg_sub_mode then
          local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
          return MatchModeMgrSystem.GetClassicModeWord(v.battle_type, sub_mode), string.format("%s-%s", localText(cfg_sub_mode.NumberShowId), localText(cfg_sub_mode.MapShowId))
        end
      end
      return "", ""
    end
    if type(v.sub_mode) == "number" then
      if tmp.is_ai_mode then
        tmp.battle_mode, tmp.battle_type = RoleInfoHistorySystem.GetAIModeTypeName(v.battle_type, v.sub_mode)
        tmp.show_score = false
      else
        tmp.battle_mode, tmp.battle_type = get_bt(v.sub_mode)
        if cfg.ModeType == 2 or cfg.ModeType == 4 then
          tmp.show_score = false
        end
      end
    else
      local tmp2 = {
        [101] = 1001,
        [102] = 1002,
        [103] = 1003
      }
      tmp.battle_mode, tmp.battle_type = get_bt(tmp2[v.battle_type])
    end
    tmp.person_rank = v.person_rank or 0
    tmp.team_rank = v.team_rank or 0
  end
  if tmp.battle_type ~= "" then
    tmp.time = FormatTime(v.time)
    tmp.timestamp = v.time
    tmp.kill = tostring(v.kill)
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    tmp.zone_name = logic_multiple_area:GetDisplayNameByZoneID(v.zone_id)
    local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
    tmp.is_peakgame = LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch(v.battle_type)
    if FuncUtil.IsTeamMode(v.battle_type) or FuncUtil.IsXmissionTeamMode(v.battle_type) then
      RoleInfoHistorySystem.SetHistoryListBranch1(tmp, v)
    elseif pIsTMode then
      log(bWriteLog and "[cw] is TxMission Mode ")
      tmp.is_txMission = true
      if type(v.Reason) == "string" and string.lower(v.Reason) == "win" and v.comments_id ~= -1 then
        tmp.txMissionEscaped = true
        local result = CDataTable.GetTableData("XMResultComment", v.comments_id)
        if result then
          tmp.final_level = LocUtil.GetLocalizeResStr(result.Comment)
        end
      else
        tmp.txMissionEscaped = false
        tmp.final_level = LocUtil.GetLocalizeResStr(11606)
      end
      tmp.show_score = false
    elseif tmp.is_peakgame then
      log(bWriteLog and "RoleInfoHistorySystem.AddHistoryOneItem is_peakgame true")
      RoleInfoHistorySystem.SetPeakGameHistoryItemData(tmp, v)
    elseif tmp.camp_type then
      RoleInfoHistorySystem.SetHistoryListBranch3(tmp, v)
    else
      RoleInfoHistorySystem.SetHistoryListBranch2(tmp, v)
    end
    local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
    logic_history_combat:AddHistoryItem(tmp)
    return true
  end
end
function RoleInfoHistorySystem.IsOffline(offline_time)
  if not offline_time then
    return false
  end
  if not tonumber(offline_time) then
    return false
  end
  return tonumber(offline_time) > 30
end
function RoleInfoHistorySystem.SetHistoryListBranch1(tmp, v)
  tmp.show_score = false
  tmp.is_team_athletics = true
  tmp.is_team_athletics_win = true
  tmp.is_team_athletics_draw = false
  if type(v.Result) == "string" and string.lower(v.Result) == "fail" then
    tmp.is_team_athletics_win = false
  elseif type(v.Result) == "string" and string.lower(v.Result) == "draw" then
    tmp.is_team_athletics_win = false
    tmp.is_team_athletics_draw = true
  end
  if type(v.mvp) == "number" and v.mvp == 1 then
    tmp.is_team_athletics_mvp = true
  end
  if type(v.MaxContinuouKills) == "number" and v.MaxContinuouKills >= 3 then
    tmp.team_athletics_hits = LocUtil.LocalizeResFormat(7220, v.MaxContinuouKills)
  end
  log_tree("summary", v)
  if FuncUtil.IsRankTeamMode(v.battle_type) then
    tmp.show_score = true
    tmp.segment = v.segment or 0
    local ratingScore = v.rating or 0
    log(bWriteLog and "RoleInfoHistorySystem.SetHistoryListBranch1 rating = " .. tostring(ratingScore))
    tmp.rating = tostring(math.floor(ratingScore))
    tmp.change_rating = ""
    local change_rating = v.change_rating or 0
    log(bWriteLog and "RoleInfoHistorySystem.SetHistoryListBranch1 change_rating = " .. tostring(change_rating))
    if change_rating < 0 then
      tmp.change_rating = string.format("(-%d)", -math.floor(v.change_rating))
    elseif 0 < change_rating then
      tmp.change_rating = string.format("(+%d)", math.floor(v.change_rating))
    elseif type(v.rating_protect) == "boolean" and v.rating_protect then
      tmp.change_rating = "(+0)"
    end
  end
end
function RoleInfoHistorySystem.SetHistoryListBranch2(tmp, v)
  log(bWriteLog and "RoleInfoHistorySystem.SetHistoryListBranch2")
  tmp.praise_medal_data = v.praise_medal_data
  tmp.praise_title_data = v.praise_title_data
  tmp.rating_protect = v.rating_protect
  tmp.segment_protect = v.segment_protect or false
  tmp.score_consume = v.score_consume
  tmp.season_add_score_card_add_rating = v.season_add_score_card_add_rating
  tmp.world_cup_daily_win_score = v.world_cup_daily_win_score
  tmp.newbie_adtnl_score = v.newbie_adtnl_score
  tmp.act_personal_exp_times = v.act_personal_exp_times
  if v.challenge then
    tmp.challenge.world_cup_times_challenge = v.challenge.world_cup_times_challenge
  end
  if v.is_world_cup_battle_id ~= nil then
    tmp.is_world_cup_battle_id = v.is_world_cup_battle_id
  end
  tmp.fu_xing_win_score = v.fu_xing_win_score
  tmp.naruto_super_win_bonus_score = v.naruto_super_win_bonus_score
  tmp.general_rating_card = v.general_rating_card
  log_tree("general_rating_card", v.general_rating_card)
  tmp.general_rating_protect = v.general_rating_protect
  log_tree("general_rating_protect", v.general_rating_protect)
  tmp.segment = v.segment
  tmp.rating = tostring(v.rating)
  tmp.change_rating = ""
  local change_rating = v.change_rating or 0
  if change_rating < 0 then
    tmp.change_rating = string.format("(-%d)", -math.floor(v.change_rating))
  elseif 0 < change_rating then
    tmp.change_rating = string.format("(+%d)", math.floor(v.change_rating))
  elseif v.rating_protect and 0 < string.len(v.rating_protect) or v.segment_protect or v.score_consume and v.score_consume > 0 then
    tmp.change_rating = "(+0)"
  end
  tmp.final_level = v.final_level or ""
  tmp.BP_ARRAY_RoleInfoHistoryTitleId = {}
  tmp.title_id = -1
  if type(v.title_id) == "table" and v.title_id[1] then
    tmp.title_id = v.title_id[1]
  end
  if RoleInfoHistorySystem.IsClassicMatchMode(v.battle_type) or RoleInfoHistorySystem.IsDragonMode(v.battle_type) then
    tmp.show_score = false
  end
  tmp.is_team_athletics = false
  tmp.is_promotion_win = v.is_promotion_win
  tmp.cur_lock_index = v.cur_lock_index
  tmp.promotion_progress = v.promotion_progress
  tmp.target_promo_progress = v.target_promo_progress
  tmp.promotion_protect = v.promotion_protect
  tmp.unlocked_mode_promo_rating = v.unlocked_mode_promo_rating
  tmp.is_unlocked_promo_mode = v.is_unlocked_promo_mode
  tmp.normal_add_promo_rating = v.normal_add_promo_rating
  tmp.is_classic_mode = true
  tmp.unlocked_mode_total_rating = v.unlocked_mode_total_rating
  tmp.cur_unlocked_mode = v.cur_unlocked_mode
  tmp.max_rating_mode_change_rating = v.max_rating_mode_change_rating
  tmp.promo_result_max_rating_zone_id = v.promo_result_max_rating_zone_id
  tmp.promo_result_max_rating_mode = v.promo_result_max_rating_mode
  tmp.max_rating_mode_new_rank_rating = v.max_rating_mode_new_rank_rating
  tmp.promo_unlock_mode_new_segment_lv = v.promo_unlock_mode_new_segment_lv
  if tmp.is_promotion_win then
    local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
    local IsNoPromoRating = logic_promotion_homepage.IsNoPromoRating(tmp.season_id or v.season_id)
    if IsNoPromoRating and tmp.is_unlocked_promo_mode == 0 then
      tmp.rating = tostring(v.max_rating_mode_new_rank_rating or v.rating)
      tmp.segment = v.promo_unlock_mode_new_segment_lv or v.segment
    end
  end
end
function RoleInfoHistorySystem.SetHistoryListBranch3(tmp, v)
  local change_rating = 0
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  if v.camp_type == history_combat_cfg.EHvHCampType.Hunter then
    change_rating = v.hunter_change_rating
    tmp.rating = v.hunter_rating
    tmp.kill = v.hunter_kill_num or 0
    tmp.person_state = v.hunter_kill_num or 0
  else
    change_rating = v.hunted_change_rating
    tmp.rating = v.hunted_rating
    tmp.is_survivor_escaped = v.is_survivor_escaped
    tmp.person_state = v.is_survivor_escaped and -1 or -2
  end
  tmp.is_mvp = type(v.mvp) == "number" and v.mvp == 1
  log(bWriteLog and "RoleInfoHistorySystem.SetHistoryListBranch3 change_rating = " .. tostring(change_rating))
  if 0 <= change_rating then
    tmp.change_rating = string.format("(+%d)", math.floor(change_rating))
  else
    tmp.change_rating = string.format("(%d)", math.floor(change_rating))
  end
  tmp.change_rating_num = change_rating
  log(bWriteLog and "RoleInfoHistorySystem.SetHistoryListBranch3 Reason = " .. tostring(v.Reason))
  if v.Reason == "win" then
    tmp.win_state = 0
  elseif v.Reason == "lose" then
    tmp.win_state = 1
  else
    tmp.win_state = 2
  end
end
function RoleInfoHistorySystem.SetPeakGameHistoryItemData(tmp, v)
  log(bWriteLog and "RoleInfoHistorySystem.SetPeakGameHistoryItemData peak_game")
  log_tree(bWriteLog and "RoleInfoHistorySystem.SetPeakGameHistoryItemData peak_game peakgame_rating_info:", v.peakgame_rating_info)
  tmp.praise_medal_data = v.praise_medal_data
  tmp.praise_title_data = v.praise_title_data
  tmp.change_rating = ""
  local change_rating = 0
  if v.peakgame_rating_info then
    tmp.segment = v.peakgame_rating_info.new_segment or nil
    tmp.rating = tostring(v.peakgame_rating_info.rank_rating)
    change_rating = v.peakgame_rating_info.change_rank_rating or 0
    tmp.peakgame_rating_info = {}
    tmp.peakgame_rating_info.activity_add_score = v.peakgame_rating_info.activity_add_score or nil
    tmp.peakgame_rating_info.activity_id = v.peakgame_rating_info.activity_id or nil
    tmp.peakgame_rating_info.card_add_score = v.peakgame_rating_info.card_add_score or nil
    tmp.peakgame_rating_info.card_res_id = v.peakgame_rating_info.card_res_id or nil
  end
  tmp.rating_protect = v.rating_protect
  if change_rating < 0 then
    tmp.change_rating = string.format("(-%d)", -math.floor(change_rating))
  elseif 0 < change_rating then
    tmp.change_rating = string.format("(+%d)", math.floor(change_rating))
  elseif tmp.rating_protect ~= nil then
    tmp.change_rating = "(+0)"
  end
  tmp.peakgame_team_rank = v.peakgame_rating_info.peakgame_team_rank or 0
  tmp.peakgame_cross_zone_team_limit = v.peakgame_rating_info.peakgame_cross_zone_team_limit
  tmp.final_level = v.final_level or ""
  tmp.title_id = -1
  if type(v.title_id) == "table" and v.title_id[1] then
    tmp.title_id = v.title_id[1]
  end
  tmp.is_team_athletics = false
end
function RoleInfoHistorySystem.GetAIModeTypeName(battle_type, sub_mode)
  local AIModeCfg = CDataTable.GetTableData("MatchModeTable", battle_type)
  local cfg_sub_mode = CDataTable.GetTableData("BTMode", sub_mode)
  if not AIModeCfg or not cfg_sub_mode then
    return "", ""
  end
  local modeName = LocUtil.GetLocalizeResStr(AIModeCfg.WordsToShowID)
  if AIModeDifficultyLQA[sub_mode] then
    local modeDifficulty = AIModeDifficultyLQA[sub_mode]
    return modeName, string.format("%s-%s-%s", localText(modeDifficulty), localText(cfg_sub_mode.NumberShowId), localText(cfg_sub_mode.MapShowId))
  end
end
function RoleInfoHistorySystem.UpdateHistoryEmptyType(is_my_history)
  local historyEmptyType = 1
  if is_my_history then
    RoleInfoHistorySystem.SetHistoryEmtyType(historyEmptyType)
    return
  end
  if RoleInfoHistorySystem.uid == DataMgr.roleData.uid then
    historyEmptyType = 1
  else
    local isCanShow = RoleInfoHistorySystem.IsCanShowHistory()
    if LobbySystem.CheckOpen(BP_ENUM_ONLY_FRIENFRIEND_PRIVACY) then
      if isCanShow == 0 then
        historyEmptyType = 3
      elseif isCanShow == 1 then
        historyEmptyType = 2
      elseif isCanShow == 2 then
        local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
        if not LogicFriend.IsMyFriend(RoleInfoHistorySystem.uid) then
          historyEmptyType = 3
        else
          historyEmptyType = 2
        end
      end
    elseif isCanShow then
      historyEmptyType = 2
    else
      historyEmptyType = 3
    end
  end
  RoleInfoHistorySystem.SetHistoryEmtyType(historyEmptyType)
end
function RoleInfoHistorySystem.SetRecordSummarylist(uid, list)
  log_tree("SetRecordSummarylist", {
    uid,
    list and #list or nil
  })
  RoleInfoHistorySystem.cachedUid = uid
  local tmp = {}
  local summary_list = list or RoleInfoHistorySystem.record_summary_list
  for _, v in ipairs(summary_list) do
    if v and v.time then
      table.insert(tmp, v)
    end
  end
  for tmpk, tmpv in pairs(tmp) do
    local isAdd = true
    for k, v in pairs(RoleInfoHistorySystem.record_summary_list) do
      local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
      if tmpv.battle_id == v.battle_id then
        isAdd = false
      end
    end
    if isAdd then
      table.insert(RoleInfoHistorySystem.record_summary_list, tmpv)
    end
  end
  table.sort(RoleInfoHistorySystem.record_summary_list, function(a, b)
    return a.time > b.time
  end)
  local limit = 50
  local num = #RoleInfoHistorySystem.record_summary_list
  for i = num, limit + 1, -1 do
    table.remove(RoleInfoHistorySystem.record_summary_list)
  end
end
local E_TipsType = {
  ScorePortected = 1,
  ReturnPrivilege = 2,
  RatingShieldExpireTime = 3,
  RatingShieldCard = 4,
  SegmentProtected = 5,
  ChanllengeScore = 6,
  SeasonAddScoreCard10 = 14,
  SeasonAddScoreCard20 = 15,
  WorldCupScorePortect = 16,
  WorldCupTeamUpAddRating = 17,
  TeamUpDoubleChallenge = 18,
  TeamUpDoublePopularity = 19,
  TeamAddScoreCard5 = 21,
  TeamAddScoreCard10 = 22,
  TeamAddScoreCard20 = 23,
  TeamProtectedCard = 24,
  LuckyStar = 25,
  TeamUpDoubleExp = 36,
  NewbieProtected = 37,
  NewbieAddScore = 38
}
function RoleInfoHistorySystem.GetTotalRating(data)
  local total_rating = 0
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local isPeakGame = LogicPeakGameUtil.IsPeakGameMode(data.sub_mode)
  if data.is_peakgame or isPeakGame then
    local segmentProtectData = CDataTable.GetTable("SegmentProtected")
    local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
    if data.peakgame_rating_info.card_add_score then
      return data.peakgame_rating_info.card_add_score
    end
    if data.peakgame_rating_info.activity_add_score and data.peakgame_rating_info.activity_id == PeakGameConfig.ActivityType.AddScoreActivity then
      return data.peakgame_rating_info.activity_add_score
    end
  end
  if data.season_add_score_card_add_rating then
    total_rating = total_rating + data.season_add_score_card_add_rating or 0
  end
  if data.world_cup_daily_win_score and 0 < data.world_cup_daily_win_score then
    total_rating = total_rating + data.world_cup_daily_win_score or 0
  end
  if data.newbie_adtnl_score and 0 < data.newbie_adtnl_score then
    total_rating = total_rating + data.newbie_adtnl_score or 0
  end
  if data.fu_xing_win_score and 0 < data.fu_xing_win_score then
    total_rating = total_rating + data.fu_xing_win_score or 0
  end
  if data.naruto_super_win_bonus_score and 0 < data.naruto_super_win_bonus_score then
    total_rating = total_rating + data.naruto_super_win_bonus_score
  end
  if data.general_rating_card and next(data.general_rating_card) then
    local cardMacros = require("client.logic.double_card.card_macros")
    local rating_data = data.general_rating_card[cardMacros.Card_Type.TeamAddScoreCard]
    if rating_data and next(rating_data) then
      total_rating = total_rating + rating_data.add_score or 0
    end
  end
  return total_rating
end
function RoleInfoHistorySystem.GetRatingIconPath(data, battleType)
  local segmentProtectData = CDataTable.GetTable("SegmentProtected")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local isPeakGame = LogicPeakGameUtil.IsPeakGameMode(data.sub_mode)
  if data.is_peakgame or isPeakGame then
    local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
    if data.rating_protect == "peakgame_activity" then
      return segmentProtectData[PeakGameConfig.E_AddScoreTipsType.PeakGameScoreProtected].IconPath
    elseif data.rating_protect == "peakgame_times_card" then
      return segmentProtectData[PeakGameConfig.E_AddScoreTipsType.PeakGameRatingShieldCard].IconPath
    end
  end
  if data.season_add_score_card_add_rating then
    if data.season_add_score_card_add_rating == 10 then
      return segmentProtectData[E_TipsType.SeasonAddScoreCard10].IconPath
    elseif data.season_add_score_card_add_rating == 20 then
      return segmentProtectData[E_TipsType.SeasonAddScoreCard20].IconPath
    end
  end
  if data.rating_protect and string.len(data.rating_protect) > 0 then
    if data.rating_protect == "activity" then
      return segmentProtectData[E_TipsType.ScorePortected].IconPath
    end
    if data.rating_protect == "back_user_privilege" then
      return segmentProtectData[E_TipsType.ReturnPrivilege].IconPath
    end
    if data.rating_protect == "time_card" then
      return segmentProtectData[E_TipsType.RatingShieldExpireTime].IconPath
    end
    if data.rating_protect == "times_card" then
      return segmentProtectData[E_TipsType.RatingShieldCard].IconPath
    end
    if data.rating_protect == "world_cup" then
      return segmentProtectData[E_TipsType.WorldCupScorePortect].IconPath
    end
    if data.rating_protect == "newbie_rating_protect" then
      return segmentProtectData[E_TipsType.NewbieProtected].IconPath
    end
  end
  if data.general_rating_protect and data.general_rating_protect.card_type then
    local protect_card_type = data.general_rating_protect.card_type
    local cardMacros = require("client.logic.double_card.card_macros")
    if protect_card_type == cardMacros.Card_Type.TeamProtectedCard then
      return segmentProtectData[E_TipsType.TeamProtectedCard].IconPath
    end
  end
  if data.segment_protect then
    return segmentProtectData[E_TipsType.SegmentProtected].IconPath
  end
  if data.score_consume and 0 < data.score_consume then
    return segmentProtectData[E_TipsType.ChanllengeScore].IconPath
  end
  if data.world_cup_daily_win_score and 0 < data.world_cup_daily_win_score then
    return segmentProtectData[E_TipsType.WorldCupTeamUpAddRating].IconPath
  end
  if data.newbie_adtnl_score and 0 < data.newbie_adtnl_score then
    return segmentProtectData[E_TipsType.NewbieAddScore].IconPath
  end
  if data.fu_xing_win_score and 0 < data.fu_xing_win_score then
    if data.fu_xing_win_score == 10 then
      return segmentProtectData[E_TipsType.LuckyStar].IconPath
    elseif data.fu_xing_win_score == 20 then
      return segmentProtectData[E_TipsType.LuckyStar].IconPath
    end
  end
  if data.general_rating_card and next(data.general_rating_card) then
    local cardMacros = require("client.logic.double_card.card_macros")
    local rating_data = data.general_rating_card[cardMacros.Card_Type.TeamAddScoreCard]
    if rating_data and next(rating_data) then
      local teamAddScore = rating_data.add_score
      if teamAddScore then
        if teamAddScore == 5 then
          return segmentProtectData[E_TipsType.TeamAddScoreCard5].IconPath
        elseif teamAddScore == 10 then
          return segmentProtectData[E_TipsType.TeamAddScoreCard10].IconPath
        elseif teamAddScore == 20 then
          return segmentProtectData[E_TipsType.TeamAddScoreCard20].IconPath
        end
      end
    end
  end
end
function RoleInfoHistorySystem.GetRatingIconText(data, battleType)
  log_tree("RoleInfoHistorySystem.GetRatingIconText", data)
  local segmentProtectData = CDataTable.GetTable("SegmentProtected")
  local iconText = ""
  local hasText = false
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local isPeakGame = LogicPeakGameUtil.IsPeakGameMode(data.sub_mode)
  if data.is_peakgame or isPeakGame then
    local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
    if data.peakgame_rating_info and data.peakgame_rating_info.card_res_id and data.peakgame_rating_info.card_add_score then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      if data.peakgame_rating_info.card_res_id == PeakGameConfig.ProtectCard.PeakGame20AddCardLast or data.peakgame_rating_info.card_res_id == PeakGameConfig.ProtectCard.PeakGame20AddCard then
        iconText = iconText .. LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.AddScore20)
      else
        iconText = iconText .. LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.AddScore10)
      end
    end
    if data.peakgame_rating_info and data.peakgame_rating_info.activity_add_score and data.peakgame_rating_info.activity_id and data.peakgame_rating_info.activity_id == PeakGameConfig.ActivityType.AddScoreActivity then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      local a = LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.AddScoreActivity)
      iconText = iconText .. LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.AddScoreActivity)
    end
    if data.rating_protect == "peakgame_activity" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.NotLostActivity)
    end
    if data.rating_protect == "peakgame_times_card" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.NotLostScore)
    end
    return iconText
  end
  if data.season_add_score_card_add_rating then
    if data.season_add_score_card_add_rating == 10 then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(2000021)
    elseif data.season_add_score_card_add_rating == 20 then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(2000022)
    end
  end
  if data.rating_protect and string.len(data.rating_protect) > 0 then
    if data.rating_protect == "activity" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(2000001)
    end
    if data.rating_protect == "back_user_privilege" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(2000002)
    end
    if data.rating_protect == "time_card" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(2000003)
    end
    if data.rating_protect == "times_card" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(2000004)
    end
    if data.rating_protect == "world_cup" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(44271)
    end
    if data.rating_protect == "newbie_rating_protect" then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(75393)
    end
  end
  if data.general_rating_protect and data.general_rating_protect.card_type then
    local protect_card_type = data.general_rating_protect.card_type
    local cardMacros = require("client.logic.double_card.card_macros")
    if protect_card_type == cardMacros.Card_Type.TeamProtectedCard then
      if hasText then
        iconText = iconText .. "\n"
      end
      hasText = true
      iconText = iconText .. LocUtil.GetLocalizeResStr(20220917)
    end
  end
  if data.segment_protect then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    iconText = iconText .. LocUtil.GetLocalizeResStr(2000005)
  end
  if data.score_consume and 0 < data.score_consume then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    iconText = iconText .. LocUtil.GetLocalizeResStr(2000006)
  end
  if data.season_status_for_display then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    iconText = iconText .. LocUtil.GetLocalizeResStr(46134)
  end
  if data.world_cup_daily_win_score and 0 < data.world_cup_daily_win_score then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    iconText = iconText .. LocUtil.GetLocalizeResStr(44272)
  end
  if data.newbie_adtnl_score and 0 < data.newbie_adtnl_score then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    iconText = iconText .. LocUtil.GetLocalizeResStr(75394)
  end
  if data.is_world_cup_battle_id then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    local text = segmentProtectData[E_TipsType.TeamUpDoublePopularity].Title
    iconText = iconText .. text
  end
  if data.world_cup_times_challenge then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    local text = segmentProtectData[E_TipsType.TeamUpDoubleChallenge].Title
    iconText = iconText .. text
  end
  if data.act_personal_exp_times and 0 < data.act_personal_exp_times then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    local text = segmentProtectData[E_TipsType.TeamUpDoubleExp].Title
    iconText = iconText .. text
  end
  if data.fu_xing_win_score and 0 < data.fu_xing_win_score then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    if data.fu_xing_win_score == 10 then
      iconText = iconText .. LocUtil.LocalizeResFormat(47073, data.fu_xing_win_score)
    elseif data.fu_xing_win_score == 20 then
      iconText = iconText .. LocUtil.LocalizeResFormat(47074, data.fu_xing_win_score)
    end
  end
  if data.naruto_super_win_bonus_score and 0 < data.naruto_super_win_bonus_score then
    if hasText then
      iconText = iconText .. "\n"
    end
    hasText = true
    iconText = iconText .. LocUtil.GetLocalizeResStr(85506)
  end
  if data.general_rating_card and next(data.general_rating_card) then
    local cardMacros = require("client.logic.double_card.card_macros")
    local rating_data = data.general_rating_card[cardMacros.Card_Type.TeamAddScoreCard]
    if rating_data and next(rating_data) then
      local teamAddScore = rating_data.add_score
      if teamAddScore then
        if teamAddScore == 5 then
          if hasText then
            iconText = iconText .. "\n"
          end
          hasText = true
          iconText = iconText .. LocUtil.GetLocalizeResStr(20220918)
        elseif teamAddScore == 10 then
          if hasText then
            iconText = iconText .. "\n"
          end
          hasText = true
          iconText = iconText .. LocUtil.GetLocalizeResStr(20220915)
        elseif teamAddScore == 20 then
          if hasText then
            iconText = iconText .. "\n"
          end
          hasText = true
          iconText = iconText .. LocUtil.GetLocalizeResStr(20220916)
        end
      end
    end
  end
  return iconText
end
function RoleInfoHistorySystem.ShowRecord(data, isHideRankBtn)
  local history_combat_util = require("client.logic.combat.history.history_combat_util")
  if history_combat_util.IsHVHMode(data.battle_type) then
    log(bWriteLog and "RoleInfoHistorySystem.ShowRecord show Escape_Settlement_02_UIBP")
    UIManager.ShowUI(UIManager.UI_Config.Escape_Settlement_02_UIBP, data, RoleInfoHistorySystem.uid)
    return
  end
  if FuncUtil.IsTeamMode(data.battle_type) or FuncUtil.IsXmissionTeamMode(data.battle_type) then
    local TableUtil = require("common.table_util")
    local result = TableUtil.CopyTable(data)
    local roleinfo_history_data_mgr = require("client.logic.roleinfo.roleinfo_history_data_mgr")
    roleinfo_history_data_mgr.SetTDMMyInfo(result.my_result or {})
    local teamResult = result.TeamResultDatas or {}
    for k, v in pairs(teamResult) do
      if result.time then
        v.time = result.time
      end
    end
    roleinfo_history_data_mgr.SetTeamResult(teamResult)
    local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
    logic_friend_apply_battle:ResetResultAddFriendReq(result.battle_id, {})
    RoleInfoHistorySystem.SetHistoryDeamatchUIData(result.TeamResultDatas)
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    local isFriend = false
    if LogicTxMissionMain.IsInXMission() then
      isFriend = false
    else
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      isFriend = not RoleInfoSystem.IsSelf()
    end
    if FuncUtil.IsXmissionTeamMode(data.battle_type) or false then
      log(bWriteLog and "RoleInfoHistorySystem.ShowRecord show xmt history")
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      if not LogicTxMissionMain.MountXMissionPak() then
        ShowNotice(32557)
        return
      end
      UIManager.ShowUI(UIManager.UI_Config.Xmission_TeamCompetitionHistory_UIBP, isFriend)
    else
      UIManager.ShowUI(UIManager.UI_Config.roleinfo_history_deathmatch, isFriend)
    end
  else
    local pIsTMode, mapKey = getIsTMissionType(nil, data.battle_type)
    if pIsTMode then
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      if LogicTxMissionMain.MountXMissionPak(mapKey) then
        local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
        UIManager.ShowUI(UIManager.UI_Config.xmission_match_history_detail, data, RoleInfoSystem.IsSelf())
      else
        ShowNotice(32557)
      end
    else
      RoleInfoHistorySystem.season_status_for_display = data.season_status_for_display
      local logic_roleinfo_historydetail = require("client.logic.roleinfo.logic_roleinfo_historydetail")
      logic_roleinfo_historydetail.Release()
      logic_roleinfo_historydetail.SetHistoryDetailData(data)
      logic_roleinfo_historydetail.UnifyAllData()
      log_tree("RoleInfoHistorySystem.ShowRecord data = ", data)
      UIManager.ShowUI(UIManager.UI_Config.roleinfo_history_detail, isHideRankBtn, RoleInfoHistorySystem.GetRatingIconText(data, data.battle_type), RoleInfoHistorySystem.GetRatingIconPath(data, data.battle_type), RoleInfoHistorySystem.GetTotalRating(data), {
        exp_times = data.act_personal_exp_times
      })
    end
  end
end
function RoleInfoHistorySystem.SetHistoryDeamatchUIData(TeamResultDatas)
  if not TeamResultDatas or not next(TeamResultDatas) then
    return
  end
  local roleinfo_history_data_mgr = require("client.logic.roleinfo.roleinfo_history_data_mgr")
  roleinfo_history_data_mgr.ClearUidList_NotRobot()
  roleinfo_history_data_mgr.ClearHeadUidList()
  local GetRemarkNameByGID = function(gid)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local nickName = logic_profile:GetFriendNickNameInGame(tonumber(gid))
    if nickName ~= nil then
      return nickName
    end
    return ""
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
  for idx, val in pairs(TeamResultDatas) do
    if val.TeamPlayerResultDatas and next(val.TeamPlayerResultDatas) then
      logic_friend_apply_battle:ResultAddFriendReq(val.TeamPlayerResultDatas)
      for i, v in pairs(val.TeamPlayerResultDatas) do
        if v ~= nil and v.UID ~= nil then
          if not v.is_robot then
            roleinfo_history_data_mgr.AddUidList_NotRobot(v.UID)
          end
          log(bWriteLog and "HeadInfoValue insert to table")
          do
            local HeadInfoValue = {}
            HeadInfoValue.uid = v.UID
            HeadInfoValue.is_robot = v.is_robot
            HeadInfoValue.player_level = v.player_level
            HeadInfoValue.segment_level = v.segment_level
            HeadInfoValue.cur_avatar_box_id = v.cur_avatar_box_id
            if v.is_robot == true then
              HeadInfoValue.pic_url = v.pic_url or v.pic_url_num
            end
            roleinfo_history_data_mgr.AddHeadDataList(HeadInfoValue)
          end
          local remark_name = GetRemarkNameByGID(v.UID)
          if remark_name ~= "" and remark_name ~= nil then
            log(bWriteLog and "remark_name=" .. remark_name)
            v.PlayerName = remark_name
          end
          v.UID = "" .. v.UID
          v.AddFriendBtnState = 0
          if LogicFriend.IsInnerFriend("" .. v.UID) ~= true and tonumber(DataMgr.roleData.uid) ~= tonumber(v.UID) then
            v.AddFriendBtnState = 1
            log(bWriteLog and "BattleResultUI name " .. v.PlayerName .. " can be invited " .. v.AddFriendBtnState .. " with id " .. v.UID)
          end
        end
      end
    end
  end
end
function RoleInfoHistorySystem.SetNeedRefershHeadDataList()
  local roleinfo_history_data_mgr = require("client.logic.roleinfo.roleinfo_history_data_mgr")
  local ImageCallBack = function(list)
    roleinfo_history_data_mgr.ClearTDM_HeadUrlInfo()
    local got_list = {}
    if list and next(list) then
      for i, v in pairs(list) do
        table.insert(got_list, {
          uid = list[i].uid,
          picUrl = list[i].picUrl,
          player_level = list[i].level,
          segment_level = list[i].cur_max_segment_level,
          cur_avatar_box_id = list[i].cur_avatar_box_id
        })
      end
    end
    local teamArray = got_list
    local headDataList = roleinfo_history_data_mgr.GetHeadDataList()
    for i, headData in pairs(headDataList) do
      if headData.is_robot == false then
        for j = 1, #teamArray do
          if tonumber(headData.uid) == tonumber(teamArray[j].uid) then
            roleinfo_history_data_mgr.SetTDM_HeadUrlInfoItem(headData.uid, teamArray[j])
            break
          end
        end
      else
        local HeadInfoValue = {}
        HeadInfoValue.uid = headData.uid
        HeadInfoValue.picUrl = headData.pic_url
        HeadInfoValue.player_level = headData.player_level
        HeadInfoValue.segment_level = headData.segment_level
        HeadInfoValue.cur_avatar_box_id = headData.cur_avatar_box_id
        local TableUtil = require("common.table_util")
        local data = TableUtil.CopyTable(HeadInfoValue)
        roleinfo_history_data_mgr.SetTDM_HeadUrlInfoItem(headData.uid, data)
      end
    end
    EventSystem:postEvent(EVENTTYPE_SHARECOMPONENT, EVENTID_ROLEINFO_HISTORY_DEATH_MATCH_DETAIL_UPDATE_AVATAR)
  end
  local uidListNotRobot = roleinfo_history_data_mgr.GetUidList_NotRobot()
  if uidListNotRobot and next(uidListNotRobot) then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidListNotRobot, ImageCallBack, Enum_PROFILE_REPORT_CFG.DEATHMATCH_HIS, 0, true)
    roleinfo_history_data_mgr.ClearUidList_NotRobot()
  end
end
function RoleInfoHistorySystem.SetUID(uid)
  RoleInfoHistorySystem.end
function RoleInfoHistorySystem.GetUID()
  return RoleInfoHistorySystem.uid
end
function RoleInfoHistorySystem.InitShowGlowSaveData()
  if RoleInfoHistorySystem.showReplayGlowEffect ~= nil then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHistoryReplayEffect)
  RoleInfoHistorySystem.showReplayGlowEffect = cacheInfo or {}
end
function RoleInfoHistorySystem.CheckIsShowGlowEffect(battle_id, timestamp)
  RoleInfoHistorySystem.InitShowGlowSaveData()
  local str = timestamp .. "_" .. battle_id
  if RoleInfoHistorySystem.showReplayGlowEffect[str] then
    return true
  end
  return false
end
function RoleInfoHistorySystem.UpdateShowGlowSaveData(battle_id, timestamp)
  RoleInfoHistorySystem.InitShowGlowSaveData()
  local str = timestamp .. "_" .. battle_id
  if not RoleInfoHistorySystem.showReplayGlowEffect[str] then
    RoleInfoHistorySystem.showReplayGlowEffect[str] = true
  end
end
function RoleInfoHistorySystem.SaveShowGlowData()
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  local history_combat_cfg = require("client.logic.combat.history.history_combat_cfg")
  local historyData = logic_history_combat:GetHistoryList(history_combat_cfg.EBattleType.All)
  if #historyData <= 0 then
    return
  end
  local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
  for _, v in pairs(historyData) do
    if not RoleInfoHistorySystem.CheckIsShowGlowEffect(v.battle_id, v.timestamp) then
      local has_replay = logic_share_replay.CheckHasBattleReplay(v.battle_id)
      if has_replay then
        RoleInfoHistorySystem.UpdateShowGlowSaveData(v.battle_id, v.timestamp)
      end
    end
  end
  if not RoleInfoHistorySystem.showReplayGlowEffect then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(RoleInfoHistorySystem.showReplayGlowEffect, PlayerPrefsSystem.ePlayerPrefsType.eHistoryReplayEffect)
end
function RoleInfoHistorySystem.OnLogout()
  RoleInfoHistorySystem.showReplayGlowEffect = nil
end
function RoleInfoHistorySystem.ClearRecordCache()
  log(bWriteLog and "RoleInfoHistorySystem.ClearRecordCache")
  RoleInfoHistorySystem.record_summary_list = {}
  RoleInfoHistorySystem.cachedUid = ""
end
return RoleInfoHistorySystem