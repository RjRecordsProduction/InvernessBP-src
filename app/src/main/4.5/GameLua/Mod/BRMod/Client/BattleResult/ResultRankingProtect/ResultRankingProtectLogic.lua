local ResultRankingProtectLogic = {}
local ResultUtil = require("GameLua.Mod.BaseMod.Client.BattleResult.BattleResultUtil")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function ResultRankingProtectLogic:OnInit()
  print(bWriteLog and "ResultRankingProtectLogic:OnInit")
  self.ProtectResultData = {showRankUI = true}
  self.bIsContinue = false
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_RANK_PROTECT_CLOSE, self.EndResultProcess, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_WONDERFUL, self.BattleResultSubSystem.StopResultProcess, self.BattleResultSubSystem)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_BATTLE_REPLAY, self.BattleResultSubSystem.StopResultProcess, self.BattleResultSubSystem)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_ENTER_SPECTATING_CHAIN, self.BattleResultSubSystem.StopResultProcess, self.BattleResultSubSystem)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_DEATH_REPLAY_PLAYBACK_ENDED, self.BattleResultSubSystem.ContinueResultProcess, self.BattleResultSubSystem)
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_RETURN_TO_BATTLERESULT, self.BattleResultSubSystem.ContinueResultProcess, self.BattleResultSubSystem)
  local BornIslandMusicConfig = GamePlayTools.GetCurrentConfig("BornIslandMusicConfig")
  self.MusicConfig = BornIslandMusicConfig.Global
  if PublishRegionMacros.IsJapanOrKorea() then
    print(bWriteLog and "ResultRankingProtectLogic:OnInit JapanOrKorea")
    self.MusicConfig = BornIslandMusicConfig.JapanOrKorea
  elseif PublishRegionMacros.IsBLUEHOLE() then
    print(bWriteLog and "ResultRankingProtectLogic:OnInit BlueHole")
    self.MusicConfig = BornIslandMusicConfig.BlueHole
  end
end
function ResultRankingProtectLogic:OnRelease()
  print(bWriteLog and "ResultRankingProtectLogic:OnRelease")
  self.ProtectResultData = {}
  if UIManager and UIManager.UI_Config_InGame.ResultsRanking_Protect_UIBPNew and UIManager.IsUIShow(UIManager.UI_Config_InGame.ResultsRanking_Protect_UIBPNew) then
    print(bWriteLog and "ResultRankingProtectLogic:OnRelease HideUI")
    UIManager.HideUI(UIManager.UI_Config_InGame.ResultsRanking_Protect_UIBPNew)
  end
  self.UIAsset = nil
end
function ResultRankingProtectLogic:OnBattleResult(result)
  log_tree("ResultRankingProtectLogic:OnBattleResult", result)
  print(bWriteLog and "ResultRankingProtectLogic:OnBattleResult sub_mode:" .. tostring(result.sub_mode) .. " battle_owner:" .. tostring(result.battle_owner))
  self.ProtectResultData.battle_id = result.battle_id
  self.ProtectResultData.promotion_return_data = result.promotion_return_data
  self.ProtectResultData.battle_owner = result.battle_owner
  self.ProtectResultData.sub_mode = result.sub_mode
  self.ProtectResultData.battle_type = result.battle_type
  self.ProtectResultData.TotalTeamCount = result.TotalTeamCount
  self.ProtectResultData.peakgame_team_rank = result.peakgame_team_rank
  print(bWriteLog and "ResultRankingProtectLogic:OnBattleResult ", result.carteam_id, result.tournament_id, result.league_seq, result.is_pug_result)
  local carteam_id = result.carteam_id or 0
  local tournament_id = result.tournament_id or 0
  local league_seq = result.league_seq or 0
  local is_pug_result = result.is_pug_result or false
  self.ProtectResultData.NotEventMode = carteam_id <= 0 and tournament_id <= 0 and league_seq <= 0 and not is_pug_result
  self.ProtectResultData.Reason = result.Reason
  self.ProtectResultData.IsSolo = result.IsSolo
  self.ProtectResultData.is_team_result = result.is_team_result
  self.ProtectResultData.person_rank = result.person_rank
  self.ProtectResultData.TotalPlayerCount = result.TotalPlayerCount
  self.ProtectResultData.team_rank = result.team_rank
  self.ProtectResultData.double_rating = result.double_rating or false
  local commonResultData = self:GetBattleResultData()
  self.ProtectResultData.BP_mykill = commonResultData.BP_mykill
  self.ProtectResultData.BP_TeamModeName = commonResultData.BP_TeamModeName
  self.ProtectResultData.BP_STRUCT_BTRating = result.rating
  if result.rating ~= nil and result.rating.new_segment ~= nil and result.rating.new_segment > 700 then
    local RankHandler = require("client.network.Protocol.RankHandler")
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    if RankHandler then
      log(bWriteLog and "Battleresult send_get_one_user_rank zoneID " .. tostring(ZoneSystem.nChooseZoneID) .. " rating_type " .. tostring(result.rating.rating_type))
      RankHandler.send_get_one_user_rank("result", ZoneSystem.nChooseZoneID, 0, result.rating.rating_type)
    end
  end
  self:InitDailyWinActivity(result)
  self.ProtectResultData.ChallengeScore = result.challenge
  self.ProtectResultData.is_activity_protect = result.is_activity_protect or false
  if result.rating_protect_type and result.rating_protect_type == "back_user_privilege" then
    self.ProtectResultData.is_player_return_protect = true
    self.ProtectResultData.player_return_protect_times = result.back_user_protect_left or 0
    self.ProtectResultData.player_return_protect_count = result.back_user_protect_count or 0
    if DataMgr.roleData.back_user_data then
      DataMgr.roleData.back_user_data.seg_protect_times = self.ProtectResultData.player_return_protect_times
    end
  else
    self.ProtectResultData.is_player_return_protect = false
  end
  if result.rating_protect_type and result.rating_protect_type == "rating_protect_mark" then
    self.ProtectResultData.is_rank_protect = true
  else
    self.ProtectResultData.is_rank_protect = false
  end
  if result.rating_protect_type and result.rating_protect_type == "time_card" then
    self.ProtectResultData.is_time_card_protect = true
  else
    self.ProtectResultData.is_time_card_protect = false
  end
  if result.rating_protect_type and result.rating_protect_type == "times_card" then
    self.ProtectResultData.is_times_card_protect = true
  else
    self.ProtectResultData.is_times_card_protect = false
  end
  if result.rating_protect_type and result.rating_protect_type == "world_cup" then
    self.ProtectResultData.is_world_cup_protect = true
  else
    self.ProtectResultData.is_world_cup_protect = false
  end
  if result.rating_protect_type and result.rating_protect_type == "newbie_rating_protect" then
    self.ProtectResultData.is_newbie_protect = true
  else
    self.ProtectResultData.is_newbie_protect = false
  end
  if not result.is_team_result then
    if result.rating_protect_type and result.rating_protect_type == "peakgame_activity" then
      self.ProtectResultData.is_peakgame_activity_protect = true
    else
      self.ProtectResultData.is_peakgame_activity_protect = false
    end
    if result.rating_protect_type and result.rating_protect_type == "peakgame_times_card" then
      self.ProtectResultData.is_peakgame_times_card_protect = true
    else
      self.ProtectResultData.is_peakgame_times_card_protect = false
    end
  end
  if result.season_status_for_display then
    log(bWriteLog and "result.season_status_for_display ")
    self.ProtectResultData.season_status_for_display = true
  else
    log_tree("MMMX result:", result)
    log(bWriteLog and "result.season_status_for_display is not ")
    self.ProtectResultData.season_status_for_display = false
  end
  self.ProtectResultData.segment_protect = result.segment_protect or false
  local SeasonSystem = require("client.logic.season.logic_season")
  if result.segment_protect then
    SeasonSystem.UpdateProtectTimes()
  end
  self.ProtectResultData.general_rating_protect = result.general_rating_protect
  self.ProtectResultData.general_rating_card = result.general_rating_card
  self.ProtectResultData.guest_rating_reduced = result.guest_rating_reduced
  self.ProtectResultData.guest_rating_lock = result.guest_rating_lock
  self.ProtectResultData.NewBattleScore = {
    real_battle_rank_rating = result.real_battle_rank_rating,
    real_battle_kill_rating = result.real_battle_kill_rating,
    real_battle_win_rating = result.real_battle_win_rating
  }
  self.ProtectResultData.real_cancel_rating = result.real_cancel_rating
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult real_cancel_rating = " .. tostring(result.real_cancel_rating))
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult real_battle_rank_rating = " .. tostring(result.real_battle_rank_rating))
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult real_battle_kill_rating = " .. tostring(result.real_battle_kill_rating))
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult real_battle_win_rating = " .. tostring(result.real_battle_win_rating))
  self.ProtectResultData.season_add_score_card_add_rating = result.season_add_score_card_add_rating
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult  season_add_score_card_add_rating = " .. tostring(result.season_add_score_card_add_rating))
  self.ProtectResultData.zone_id = result.zone_id
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult zone_id = " .. tostring(result.zone_id))
  self.ProtectResultData.pre_team_rating_max_gap = result.pre_team_rating_max_gap
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult pre_team_rating_max_gap = " .. tostring(result.pre_team_rating_max_gap))
  self.ProtectResultData.pre_team_rating_gap_cancel_rank_rating = result.pre_team_rating_gap_cancel_rank_rating
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult pre_team_rating_gap_cancel_rank_rating = " .. tostring(result.pre_team_rating_gap_cancel_rank_rating))
  if result.is_world_cup_battle_id ~= nil then
    self.ProtectResultData.is_world_cup_battle_id = result.is_world_cup_battle_id
  end
  self:InitReturnDailyWinActivity(result)
  self:InitWorldCupAddRatingActivity(result)
  self:UpdateNewbieRatingActivityCount(result)
  self:InitNewbieAddRatingActivity(result)
  self:InitLuckyStarActivity(result)
  self.ProtectResultData.hasWorldCupActivity = self:CheckHasWorldCupActivity(result)
  self.ProtectResultData.hasNewBieActivity = self:CheckHasNewbieActivity(result)
  self.ProtectResultData.USE_TEST = self.USE_TEST
  self.ProtectResultData.survive_time = 0
  self.ProtectResultData.revival_num = result.RevivalNum or 0
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult revival_num = " .. tostring(result.RevivalNum))
  self.ProtectResultData.assist_num = 0
  self.ProtectResultData.kill_num = 0
  for k, v in pairs(result.TeammateList) do
    if tonumber(v.UID) == tonumber(DataMgr.roleData.uid) then
      self.ProtectResultData.survive_time = v.surviveTime
      self.ProtectResultData.assist_num = v.AssistNum
      self.ProtectResultData.kill_num = v.Kill
    end
  end
  self.ProtectResultData.peakgame_rating_info = result.peakgame_rating_info
  self:InitModExtraActivity(result)
  self.ProtectResultData.peakgame_cross_zone_team_limit = result.peakgame_cross_zone_team_limit
  self.ProtectResultData.WeaponDamageRecordList = result.WeaponDamageRecordList
  log(bWriteLog and "ResultRankingProtectLogic:OnBattleResult promotion_result_info is not team result")
  self.ProtectResultData.promotion_result_info = result.promotion_result_info
  self.ProtectResultData.promotion_layer = result.promotion_layer
  self.ProtectResultData.naruto_super_win_bonus_score = result.naruto_super_win_bonus_score
  self:AsyncLoadAsset("/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Protect_UIBPNew.ResultsRanking_Protect_UIBPNew", function(UIAsset)
    self.  end)
end
function ResultRankingProtectLogic:InitDailyWinActivity(InResult)
  print(bWriteLog and "ResultRankingProtectLogic:InitDailyWinActivity daily_win_score: " .. tostring(InResult.daily_win_score))
  self.ProtectResultData.BP_STRUCT_DailyWinActivity = {}
  if InResult.daily_win_score and InResult.daily_win_score > 0 then
    self.ProtectResultData.BP_STRUCT_DailyWinActivity.ExtraScore = InResult.daily_win_score
    if InResult.extra_daily_win_rating then
      self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating - InResult.extra_daily_win_rating
      self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating - InResult.extra_daily_win_rating
    end
    if self.USE_TEST then
      self.ProtectResultData.BP_STRUCT_DailyWinActivity.CurrentNum = 1
      self.ProtectResultData.BP_STRUCT_DailyWinActivity.MaxNum = 10
      self.ProtectResultData.BP_STRUCT_DailyWinActivity.Desc1 = DataMgr.GetFormatMsgByIDForBattleText(34982, 5)
      self.ProtectResultData.BP_STRUCT_DailyWinActivity.Desc2 = DataMgr.GetFormatMsgByIDForBattleText(34983, InResult.daily_win_score)
      self.ProtectResultData.BP_STRUCT_DailyWinActivity.Desc3 = DataMgr.GetFormatMsgByIDForBattleText(34985, 10)
    else
      local LogicDayFirst = require("client.slua.logic.activity.day_first_win.logic_day_first_win")
      if LogicDayFirst then
        local CurrentTask = LogicDayFirst.GetDayFirstWinTaskData()
        if CurrentTask then
          log(bWriteLog and "daily win activity progress:" .. tostring(CurrentTask.Progress) .. ",total:" .. tostring(CurrentTask.Total))
          self.ProtectResultData.BP_STRUCT_DailyWinActivity.CurrentNum = CurrentTask.Progress
          self.ProtectResultData.BP_STRUCT_DailyWinActivity.MaxNum = CurrentTask.Total
        end
        local Conditions = LogicDayFirst.GetTaskConditions()
        log_tree("daily win task conditions:", Conditions)
        for ConditionIndex = 1, #Conditions do
          self.ProtectResultData.BP_STRUCT_DailyWinActivity["Desc" .. tostring(ConditionIndex)] = Conditions[ConditionIndex]
        end
        if #Conditions < 3 then
          for ConditionIndex = #Conditions, 3 do
            self.ProtectResultData.BP_STRUCT_DailyWinActivity["Desc" .. tostring(ConditionIndex)] = ""
          end
        end
      end
    end
  else
    self.ProtectResultData.BP_STRUCT_DailyWinActivity.ExtraScore = 0
  end
end
function ResultRankingProtectLogic:InitReturnDailyWinActivity(InResult)
  log(bWriteLog and "[v_wllwu] ResultRankingProtectLogic.InitReturnDailyWinActivity back_user_daily_win_score: " .. tostring(InResult.back_user_daily_win_score))
  self.ProtectResultData.BP_STRUCT_ReturnDailyWinActivity = {}
  if InResult.back_user_daily_win_score and InResult.back_user_daily_win_score > 0 then
    self.ProtectResultData.BP_STRUCT_ReturnDailyWinActivity.back_user_daily_win_score = InResult.back_user_daily_win_score
    if InResult.back_user_extra_daily_win_rating then
      self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating - InResult.back_user_extra_daily_win_rating
      self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating - InResult.back_user_extra_daily_win_rating
    end
    local TableUtil = require("common.table_util")
    local winScoreCount = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "back_user_day_win_score_cnt")
    if winScoreCount then
      DataMgr.roleData.back_user_data.back_user_day_win_score_cnt = 1
    end
  else
    self.ProtectResultData.BP_STRUCT_ReturnDailyWinActivity.back_user_daily_win_score = 0
  end
end
function ResultRankingProtectLogic:InitModExtraActivity(result)
end
function ResultRankingProtectLogic:InitWorldCupAddRatingActivity(result)
  log(bWriteLog and "ResultRankingProtectLogic:InitWorldCupAddRatingActivity world_cup_daily_win_score: " .. tostring(result.world_cup_daily_win_score))
  self.ProtectResultData.WorldCupAddRatingActivity = {}
  if result.world_cup_daily_win_score and result.world_cup_daily_win_score > 0 then
    self.ProtectResultData.WorldCupAddRatingActivity.world_cup_daily_win_score = result.world_cup_daily_win_score
    if result.extra_world_cup_daily_win_rating then
      self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating - result.extra_world_cup_daily_win_rating
      self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating - result.extra_world_cup_daily_win_rating
    end
    local logic_rating_protect_for_umg = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_for_umg")
    local totalNum, progressNum = logic_rating_protect_for_umg.CallFuc("GetProgressByType", ActivityType.WORLDCUP_TEAMUP_ADD_RATING)
    self.ProtectResultData.WorldCupAddRatingActivity.progress = progressNum
    self.ProtectResultData.WorldCupAddRatingActivity.total = totalNum
  else
    self.ProtectResultData.WorldCupAddRatingActivity.world_cup_daily_win_score = 0
  end
end
function ResultRankingProtectLogic:InitNewbieAddRatingActivity(result)
  self.ProtectResultData.NewbieAddRatingActivity = {}
  if result.newbie_adtnl_score and result.newbie_adtnl_score > 0 then
    self.ProtectResultData.NewbieAddRatingActivity.newbie_adtnl_score = result.newbie_adtnl_score
    if result.newbie_adtnl_rating then
      self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating - result.newbie_adtnl_rating
      self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating - result.newbie_adtnl_rating
    end
    local logic_newbie_task_segment_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_task_segment_activity)
    local data = logic_newbie_task_segment_activity:GetSegmentActivityShowData()
    self.ProtectResultData.NewbieAddRatingActivity.progress = data.asTimes
    self.ProtectResultData.NewbieAddRatingActivity.total = tonumber(data.asConfig.Value)
  else
    self.ProtectResultData.NewbieAddRatingActivity.newbie_adtnl_score = 0
  end
end
function ResultRankingProtectLogic:UpdateNewbieRatingActivityCount(result)
  local logic_newbie_task_segment_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_task_segment_activity)
  logic_newbie_task_segment_activity:UpdateActivityCount(result.newbie_rating_protect_cnt, result.newbie_rating_adtnl_cnt)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateActivityCount(result.newbie_rating_protect_cnt, result.newbie_rating_adtnl_cnt)
end
function ResultRankingProtectLogic:InitLuckyStarActivity(result)
  log(bWriteLog and "ResultRankingProtectLogic:InitLuckyStarActivity : " .. tostring(result.fu_xing_win_score))
  self.ProtectResultData.BP_STRUCT_LuckyStarActivity = {}
  if result.fu_xing_win_score and result.fu_xing_win_score > 0 then
    self.ProtectResultData.BP_STRUCT_LuckyStarActivity.ExtraScore = result.fu_xing_win_score
    if result.extra_fu_xing_win_rating then
      self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_kill_rating - result.extra_fu_xing_win_rating
      self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating = self.ProtectResultData.BP_STRUCT_BTRating.change_win_rating - result.extra_fu_xing_win_rating
    end
  end
end
function ResultRankingProtectLogic:CheckHasWorldCupActivity(result)
  if result.rating_protect_type and result.rating_protect_type == "world_cup" then
    log(bWriteLog and "ResultRankingProtectLogic:CheckHasWorldCupActivity true rating_protect")
    return true
  end
  if result.world_cup_daily_win_score and result.world_cup_daily_win_score > 0 then
    log(bWriteLog and "ResultRankingProtectLogic:CheckHasWorldCupActivity true addscore")
    return true
  end
  if result.challenge and result.challenge.world_cup_times_challenge and type(result.challenge.world_cup_times_challenge) == "number" then
    log(bWriteLog and "ResultRankingProtectLogic:CheckHasWorldCupActivity true challenge")
    return true
  end
  if self.ProtectResultData.is_world_cup_battle_id then
    log(bWriteLog and "ResultRankingProtectLogic:CheckHasWorldCupActivity true upvote")
    return true
  end
  if result.act_personal_exp_times and type(result.act_personal_exp_times) == "number" then
    log(bWriteLog and "ResultRankingProtectLogic:act_personal_exp_times true")
    return true
  end
  log(bWriteLog and "ResultRankingProtectLogic:CheckHasWorldCupActivity false")
  return false
end
function ResultRankingProtectLogic:CheckHasNewbieActivity(result)
  if result.rating_protect_type and result.rating_protect_type == "newbie_rating_protect" then
    log(bWriteLog and "ResultRankingProtectLogic:CheckHasNewbieActivity true rating_protect")
    return true
  end
  if result.newbie_adtnl_score and result.newbie_adtnl_score > 0 then
    log(bWriteLog and "ResultRankingProtectLogic:CheckHasNewbieActivity true addscore")
    return true
  end
  log(bWriteLog and "ResultRankingProtectLogic:CheckHasNewbieActivity false")
  return false
end
function ResultRankingProtectLogic:OnSwitchCheck()
  print(bWriteLog and "ResultRankingProtectLogic:OnSwitchCheck")
  self.ProtectResultData.showRankUI = true
  self.BattleResultSubSystem.bHasEnterProtect = true
  if not self:CheckShowRankUI() then
    if self:NeedShowReplayButton() then
      self.ProtectResultData.showRankUI = false
    else
      EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT)
      self:StartToPlayResultMusic()
      return false
    end
  end
  return true
end
function ResultRankingProtectLogic:CheckShowRankUI()
  print(bWriteLog and "ResultRankingProtectLogic:CheckShowRankUI")
  local data = self.ProtectResultData
  if data.battle_owner ~= 0 then
    print(bWriteLog and "ResultRankingProtectLogic:CheckShowRankUI RoomMode")
    return false
  end
  if data.sub_mode and not ResultUtil.CheckResultProSwitch(data.sub_mode, ResultUtil.SwitchKey.RankingSettlementSwitch) then
    print(bWriteLog and "ResultRankingProtectLogic:CheckShowRankUI RankingSettlement Close modeId:" .. tostring(data.sub_mode))
    return false
  end
  print(bWriteLog and "ResultRankingProtectLogic:CheckShowRankUI battle_type", data.battle_type, data.NotEventMode)
  if data.NotEventMode and data.battle_type ~= 111 and data.battle_type ~= 112 and data.battle_type ~= 113 and data.battle_type ~= 411 and data.battle_type ~= 412 and data.battle_type ~= 413 and data.battle_type ~= 18103 and data.battle_type ~= 25103 then
    local EGameModeCPPType = import("EGameModeType")
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if slua.isValid(uGameState) then
      print(bWriteLog and "ResultRankingProtectLogic:CheckShowRankUI GameModeType:", uGameState.GameModeType)
      if (uGameState.GameModeType == EGameModeCPPType.ETypicalGameMode or uGameState.GameModeType == EGameModeCPPType.EFourInOneGameMode) and not self.IsInAvatarBriefDetail then
        return true
      end
    end
  end
  return false
end
function ResultRankingProtectLogic:NeedShowReplayButton()
  log(bWriteLog and "ResultRankingProtectLogic.NeedShowReplayButton")
  local bNeed = false
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsCanViewEnemy and uPlayerController:IsCanViewEnemy() then
    bNeed = true
  else
    log(bWriteLog and "ResultRankingProtectLogic:NeedShowReplayButton IsCanViewEnemy is false")
  end
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if slua.isValid(uGameInstance) then
    local uClientInGameReplay = uGameInstance:GetClientInGameReplay()
    if slua.isValid(uClientInGameReplay) then
      if uClientInGameReplay.bDeathPlaybackEnable then
        local have = uClientInGameReplay:HaveDeathPlaybackData()
        if have then
          if self.ProtectResultData.Reason ~= "win" then
            bNeed = true
          end
        else
          log(bWriteLog and "ResultRankingProtectLogic:NeedShowReplayButton HaveDeathPlaybackData false")
        end
      else
        log(bWriteLog and "ResultRankingProtectLogic:NeedShowReplayButton DeathPlayback disable")
      end
      if uClientInGameReplay.bGWonderfulPlaybackSwitch then
        local have = uClientInGameReplay:HaveWonderfulPlaybackData()
        if have then
          if self.ProtectResultData.IsSolo or self.ProtectResultData.is_team_result then
            bNeed = true
          end
        else
          log(bWriteLog and "ResultRankingProtectLogic:NeedShowReplayButton HaveWonderfulPlaybackData false")
        end
      else
        log(bWriteLog and "ResultRankingProtectLogic:NeedShowReplayButton GWonderfulPlaybackSwitch disable")
      end
    else
      log(bWriteLog and "ResultRankingProtectLogic:NeedShowReplayButton uClientInGameReplay Is Null")
    end
  else
    log(bWriteLog and "ResultRankingProtectLogic:NeedShowReplayButton uGameInstance Is Null")
  end
  return bNeed
end
function ResultRankingProtectLogic:OnResultProcessStart()
  print(bWriteLog and "ResultRankingProtectLogic:OnResultProcessStart")
  EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and ScriptHelperEngine.IsLowMemoryDevice() then
    print(bWriteLog and "ResultRankingProtectLogic:OnResultProcessStart unload level")
    local UIUtil = require("client.common.ui_util")
    local WorldContextObject = UIUtil.GetGameInstance()
    local UGameplayStatics = import("GameplayStatics")
    UGameplayStatics.UnloadAllStreamLevel(WorldContextObject)
    local KismetSystemLibrary = import("KismetSystemLibrary")
    KismetSystemLibrary.CollectGarbage()
  end
  self:ShowResultRankingProtectUI()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController.CharacterTouchMove = false
    uPlayerController:CastUIMsg("MainControlPanel_HideAllUI", "ingame")
  end
  return true
end
function ResultRankingProtectLogic:OnResultProcessStop(curProcessIndex)
  print(bWriteLog and "ResultRankingProtectLogic:OnResultProcessStop curProcessIndex:", tostring(curProcessIndex), self.CurResultProcessIndex)
  if curProcessIndex == self.CurResultProcessIndex then
  end
  self.UIAsset = nil
end
function ResultRankingProtectLogic:StartToPlayResultMusic()
  local bWin = false
  local MusicPath = self.MusicConfig.RankingProtect.DeadMusic
  if self.ProtectResultData and self.ProtectResultData.Reason == "win" then
    bWin = true
    MusicPath = self.MusicConfig.RankingProtect.WinMusic
  end
  print(bWriteLog and "ResultRankingProtectLogic:StartToPlayResultMusic bWin", bWin, MusicPath)
  local audio_util = require("client.common.audio_util")
  if MusicPath then
    audio_util.PlayAudio(MusicPath)
  end
end
function ResultRankingProtectLogic:OnResultProcessContinue(curProcessIndex)
  print(bWriteLog and "ResultRankingProtectLogic:OnResultProcessContinue curProcessIndex:" .. tostring(curProcessIndex))
  if curProcessIndex == self.CurResultProcessIndex then
    self.bIsContinue = true
    self:ShowResultRankingProtectUI()
    if DeathReplayLuaInterface then
      DeathReplayLuaInterface:Hide()
    end
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    uPlayerController.CharacterTouchMove = false
  end
  EventSystem:postEventSafety(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ENTER_PROTECT)
end
function ResultRankingProtectLogic:OnResultProcessEnd()
  print(bWriteLog and "ResultRankingProtectLogic:OnResultProcessEnd")
  if UIManager then
    print(bWriteLog and "ResultRankingProtectLogic:OnResultProcessEnd HideUI")
    UIManager.HideUI(UIManager.UI_Config_InGame.ResultsRanking_Protect_UIBPNew)
  end
  if WatchGameUI then
    WatchGameUI:HideSpectatingUI()
  end
  if ResultToSpectate then
    ResultToSpectate.HideUI()
  end
  if ReviveSpectateTips then
    ReviveSpectateTips.HideSpectateTipsUI()
  end
  local EGameReplayType = import("EGameReplayType")
  EventSystem:postEventSafety(EVENTTYPE_INGAME_REPLAY, EVENTID_SHOWHIDE_REPLAYUI, EGameReplayType.EGameReplayType_WonderfulPlayback, false)
  if DeathReplayLuaInterface then
    DeathReplayLuaInterface:Hide()
  end
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if slua.isValid(uGameInstance) then
    local uWonderfulPlayback = uGameInstance:GetWonderfulPlayback()
    if slua.isValid(uWonderfulPlayback) then
      uWonderfulPlayback:StopPlay()
    end
    local DeathPlaybackInstance = uGameInstance:GetDeathPlayback()
    if slua.isValid(DeathPlaybackInstance) then
      DeathPlaybackInstance:StopPlay()
    end
  end
  self:StartToPlayResultMusic()
end
function ResultRankingProtectLogic:ShowResultRankingProtectUI()
  print(bWriteLog and "ResultRankingProtectLogic:ShowResultRankingProtectUI")
  if UIManager then
    local battle_type = self.ProtectResultData.battle_type
    local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
    if battle_type and LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch(battle_type) then
      print(bWriteLog and "ResultRankingProtectLogic:ShowResultRankingProtectUI show peakgame ui")
      UIManager.ShowUI(UIManager.UI_Config_InGame.PeakGame_ResultsRanking_Protect_UIBPNew, self.ProtectResultData)
    else
      UIManager.ShowUI(UIManager.UI_Config_InGame.ResultsRanking_Protect_UIBPNew, self.ProtectResultData)
    end
  end
end
local class = require("class")
local BattleResultProcessBaseLogic = require("GameLua.Mod.BaseMod.Client.BattleResult.ProcessBase.BattleResultProcessBaseLogic")
local CResultRankingProtectLogic = class(BattleResultProcessBaseLogic, nil, ResultRankingProtectLogic)
return CResultRankingProtectLogic