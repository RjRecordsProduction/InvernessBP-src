BattleResult = BattleResult or {
  resultAvatarPoseNormal = 0,
  resultAvatarPoseAim = 1,
  resultAvatarPoseCrouch = 2,
  BattleResultSubSystemSwltch = true,
  BattleResultTDMSwitch = true,
  BattleResultOBSwitch = true,
  RESULTLEVEL_TEST = false,
  bHandlingResult = false
}
local timer_ticker = require("common.time_ticker")
local utility = require("common.utility")
function BattleResult.on_game_result(battle_result, result)
  print(bWriteLog and "BattleResult.on_game_result", BattleResult.bHandlingResult)
  if Client then
    xpcall(function()
      EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_PRE_BATTLE_RESULT)
    end, utility.ErrorMessageHandler)
  end
  if BattleResult.bHandlingResult then
    timer_ticker.AddTimer(0.1, function()
      BattleResult.on_game_result_impl(battle_result, result)
    end)
  else
    BattleResult.on_game_result_impl(battle_result, result)
    BattleResult.bHandlingResult = true
    timer_ticker.AddTimer(0, function()
      BattleResult.bHandlingResult = false
    end)
  end
  if Client and battle_result ~= nil and battle_result.battle_id ~= nil and battle_result.is_team_result ~= nil and battle_result.is_team_result == true then
    local logic_enter_game
    if ModuleManager then
      logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
    end
    if logic_enter_game ~= nil then
      logic_enter_game.GameOverGameID = battle_result.battle_id
    end
  end
end
function BattleResult.on_game_result_impl(battle_result, result)
  if not _G.IsEditor then
    BattleResult.BattleResultSubSystemSwltch = LobbySystem.CheckOpen(BP_ENUM_RESULT_SUBSYSTEM_SWITH)
  end
  print(bWriteLog and "BattleResult.on_game_result_impl", _G.IsEditor, BattleResult.BattleResultSubSystemSwltch, BattleResult.BattleResultTDMSwitch, battle_result and battle_result.is_team_result or "nil")
  if Client.IsDevelopment() then
    log_tree(bWriteLog and "on_game_result_uid", battle_result)
    log_tree(bWriteLog and "on_game_result", result)
  end
  Client.SyncLoadPackageUpdateCurrentWorldStage("")
  Client.SyncLoadPackageUpdateCurrentWorldName("")
  FuncUtil.UE4ExecuteConsoleCommand("ObjectPoolEnable 0")
  DataMgr.match_union_info = result
  if not battle_result.is_team_result then
    LobbySystem.SetFeedBackFlag(battle_result.need_game_evaluation == 1)
  end
  if battle_result.EvaluationLabels and next(battle_result.EvaluationLabels) then
    BattleResult.TeammateEvaluationLabels = battle_result.EvaluationLabels
  end
  if battle_result.player_evaluation_lower_score then
    BattleResult.CanEvaluateLowScore = battle_result.player_evaluation_lower_score == 1
  end
  BattleResult.HasShowEvaluationTips = false
  BattleResult.EvaluatedUIDList = {}
  ResetResultMonitor()
  NetUtil.BBattleResultRecieved = true
  if battle_result.metro and battle_result.metro.InsureRemainItemID and battle_result.Reason == "dead" then
    local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
    logic_xmission_insurance:SetRemainItemID(battle_result.metro.InsureRemainItemID)
  end
  BP_BattleResultNeedShowAd = false
  if battle_result.push_ad ~= nil and battle_result.push_ad == true then
    log(bWriteLog and "BattleResult push_ad : " .. tostring(battle_result.push_ad))
    LuaClassObj.HandleUIMessage(bp_battleresult, "ShowAdvertiseButton")
    BP_BattleResultNeedShowAd = true
  end
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  print(bWriteLog and "BattleResult BattleResultSubSystemSwltch : ", BattleResult.BattleResultSubSystemSwltch, IngameEntry.UseCustomGameResult(), IngameEntry.UseBattleResultSubSystem())
  if IngameEntry.UseCustomGameResult() then
    if IngameEntry.UseBattleResultSubSystem() then
      local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
      BattleResultSubSystem:OnBattleResult(battle_result)
      GameStatus.SetCombatActiveState(false)
    else
      IngameEntry.OnGameResult(battle_result)
    end
  else
    local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
    if BattleResultSubSystem then
      BattleResultSubSystem:OnBattleResult(battle_result)
    else
      log(bWriteLog and "BattleResultSubSystem is nil")
    end
    BattleResultUI.OnBattleResult(0, battle_result)
    local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    TournamentsManager.SetResultType(battle_result)
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    MentorSystem.SetResultType(battle_result)
    local SeasonSystem = require("client.logic.season.logic_season")
    battle_result.rating = battle_result.rating or {}
    local curRating = battle_result.rating.rank_rating or 0
    SeasonSystem.UpdateRating(curRating, battle_result.battle_type, battle_result.zone_id)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, battle_result)
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  if not slua.isValid(uGameInstance) then
    return
  end
  local uClientInGameReplay = uGameInstance:GetClientInGameReplay()
  if not slua.isValid(uClientInGameReplay) then
    return
  end
  uClientInGameReplay:OnBattleResultStopRecordingNotify()
  DeathReplayLuaInterface:OnReceiveGameResult()
  timer_ticker.AddTimer(2, function()
    Client.OnBattleResultCallBack(GameFrontendHUD, battle_result)
  end)
  if battle_result.Reason == "win" and ENUM_TRIGGER_COND then
    log(bWriteLog and "EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA FIRST_CHICKEN")
    EventSystem:postEvent(EVENTTYPE_MESSAGE_PUSH_TRIGGER, EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA, ENUM_TRIGGER_COND.FIRST_CHICKEN)
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_task_state_list()
  if battle_result.rating then
    local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
    PlayerLabelHandler.change_rank_rating = battle_result.rating.change_rank_rating
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if GamePlayTools.IsBRMode(battle_result.sub_mode) then
    local GuideFlowEventMap = require("client.slua.logic.GuideFlow.Event.GuideFlowEventMap")
    local GuideFlowEvent = require("client.slua.logic.GuideFlow.Event.GuideFlowEvent")
    GuideFlowEventMap.PostEvent(GuideFlowEvent.ClassicalGameResult)
    log(bWriteLog and " Execute the flow ClassicalGameResult ")
  end
  local stats = LobbySystem.roleData.last_rating_stats
  if stats and battle_result.rating and stats.rating_change and stats.person_rank and stats.sub_mode then
    local max_history_len = 20
    local len = #stats.rating_change
    if max_history_len > len then
      stats.rating_change[len + 1] = battle_result.rating.change_rank_rating
      stats.person_rank[len + 1] = battle_result.person_rank
      stats.sub_mode[len + 1] = battle_result.sub_mode
    else
      stats.last_index = (stats.last_index or 0) % max_history_len + 1
      stats.rating_change[stats.last_index] = battle_result.rating.change_rank_rating
      stats.person_rank[stats.last_index] = battle_result.person_rank
      stats.sub_mode[stats.last_index] = battle_result.sub_mode
    end
  end
  if battle_result.rating and battle_result.rating.rank_rating then
    if SeasonHandler.rank_rating == nil then
      SeasonHandler.rank_rating = battle_result.rating.rank_rating
    elseif battle_result.rating.rank_rating > SeasonHandler.rank_rating then
      SeasonHandler.rank_rating = battle_result.rating.rank_rating
    end
  end
  local BattleEvaluationCondition = require("client.slua.logic.GuideFlow.Condition.BattleEvaluationCondition")
  if BattleEvaluationCondition.lastBattleID ~= battle_result.battle_id then
    log(bWriteLog and "battleresult,SetBattleType" .. tostring(battle_result.battle_type))
    log(bWriteLog and "battleresult,SetScore" .. tostring(BattleEvaluationCondition.newScore))
    log(bWriteLog and "battleresult,SetNewScore" .. 0)
    BattleEvaluationCondition.SetLastBattleID(battle_result.battle_id)
    BattleEvaluationCondition.SetBattleType(battle_result.battle_type)
    BattleEvaluationCondition.SetScore(BattleEvaluationCondition.newScore)
    BattleEvaluationCondition.SetNewScore(0)
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  if battle_result.zone_id == 3 and ZoneSystem.nChooseZoneID == 6 and GlobalData.IsJapanOrKorea() then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.bShowCrossNotice = true
  end
  local selfRank = battle_result.IsSolo and battle_result.person_rank or battle_result.team_rank
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.SetCurrentGameResultRank(selfRank)
  local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
  BattleResultHandler.send_report_player_battle_score(BattleEvaluationCondition.GetData())
  local logic_tdm_rating_protect = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_tdm_rating_protect)
  logic_tdm_rating_protect:SetResultType(battle_result)
end
function BattleResult.on_game_over(game_id)
  if Client then
    xpcall(function()
      EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_PRE_BATTLE_RESULT)
    end, utility.ErrorMessageHandler)
  end
  if BattleResult.bHandlingResult then
    timer_ticker.AddTimer(0.1, function()
      BattleResult.on_game_over_impl(game_id)
    end)
  else
    BattleResult.on_game_over_impl(game_id)
  end
  if Client then
    local logic_enter_game
    if ModuleManager then
      logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
    end
    if logic_enter_game ~= nil then
      logic_enter_game.GameOverGameID = game_id
    end
  end
end
function BattleResult.on_game_over_impl(game_id)
  log(bWriteLog and "on_game_over_impl:" .. game_id)
  if g_game_id == game_id then
    BattleResultUI.OnGameOver(game_id)
  end
end
function BattleResult.on_game_result_ob(result)
  if Client then
    xpcall(function()
      EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_PRE_BATTLE_RESULT)
    end, utility.ErrorMessageHandler)
  end
  print(bWriteLog and "BattleResult.on_game_result_ob, ", result)
  result.isobserver = true
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_GAME_RESULT_OB, result)
end
function BattleResult.SendTestGetResult()
  log(bWriteLog and "SendTestGetResult")
  local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
  BattleResultHandler.send_test_gameresult_req()
end
function BattleResult.on_test_game_result(result_gs)
  if result_gs.battle_gid_newyear_ext ~= nil and result_gs.battle_gid_newyear_ext ~= 0 then
    BattleResult.battleNewyearGIDExt = result_gs.battle_gid_newyear_ext
    local leftTime = 2
    if result_gs.newyear_ext_maxnum ~= nil and result_gs.newyear_ext_getnum ~= nil then
      leftTime = result_gs.newyear_ext_maxnum - result_gs.newyear_ext_getnum
    end
    local delaytime = 2
  end
  if result_gs.battle_gid_newyear ~= nil and result_gs.battle_gid_newyear ~= 0 then
    BattleResult.battleNewyearGID = result_gs.battle_gid_newyear
    local leftTime = 2
    if result_gs.newyear_maxnum ~= nil and result_gs.newyear_getnum ~= nil then
      leftTime = result_gs.newyear_maxnum - result_gs.newyear_getnum - 1
    end
  end
  if result_gs.battle_gid ~= nil and result_gs.battle_gid ~= 0 then
    BattleResult.battleGID = result_gs.battle_gid
    log(bWriteLog and "on_test_game_result roomid = " .. result_gs.battle_gid)
    local leftMoney = 0
    local totalMoney = 0
    if result_gs.redpacktype == 2 then
      leftMoney = result_gs.cj_redpack_remainnum
      totalMoney = result_gs.cj_redpack_allnum
    elseif result_gs.redpacktype == 1 then
      leftMoney = result_gs.cj_n_redpack_remainnum
      totalMoney = result_gs.cj_redpack_allnum_normal
    end
  end
end
function BattleResult.on_game_finished_ob_result(room_result, room_stat, customize_result)
  print(bWriteLog and "BattleResult.on_game_finished_ob_result")
  if Client then
    xpcall(function()
      EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_PRE_BATTLE_RESULT)
    end, utility.ErrorMessageHandler)
  end
  local IngameEntry = require("GameLua.GameCore.Main.ClientGameMain")
  if IngameEntry.UseCustomGameResult() and IngameEntry.OnOBBattleResult(room_result, room_stat, customize_result) then
    print(bWriteLog and "BattleResult.on_game_finished_ob_result ShowUseCustomObResult")
  else
    BattleResultUI.ShowOBBattleResult(room_result, room_stat, customize_result)
  end
end
function BattleResult.on_pcob_playerweaponinfo_result(room_id, result_player_id, weapon_result, pcob_item_pickup_data, pcob_item_use_data, custom_room_id)
  local tWeaponInfo = {
    RoomID = room_id,
    PlayerID = result_player_id,
    WeaponResult = weapon_result,
    CustomRoomID = custom_room_id
  }
  local sWeaponInfoContent = json.encode(tWeaponInfo)
  local tPickupAndUseData = {
    RoomID = room_id,
    PlayerID = result_player_id,
    PickUpData = pcob_item_pickup_data,
    UseData = pcob_item_use_data
  }
  local sPickupAndUseData = json.encode(tPickupAndUseData)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
  if slua.isValid(uPlayerController) and Game:IsClassOf(uPlayerController, ASTExtraPlayerController) then
    local uClassOBHttpComponent = import("OBHttpComponent")
    if uClassOBHttpComponent then
      local uOBHttpComponent = uPlayerController:GetComponentByClass(uClassOBHttpComponent)
      if slua.isValid(uOBHttpComponent) then
        uOBHttpComponent:PostTeamWeaponInfo(sWeaponInfoContent)
        uOBHttpComponent:PostPlayersAMInfo(sPickupAndUseData)
      end
    end
  end
end
function BattleResult.on_upvote_res(uid, name, giftSource)
  log(bWriteLog and "BattleResult.on_upvote_res uid:" .. uid .. " name:" .. name)
  if GameStatus.IsInFightingStatus() then
    if giftSource then
      local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
      if RoleInfoPopularitySystem.GiftSourceType.TeamCompetionResult == giftSource then
        EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_TDM_ON_UPVOTE, uid, name)
      end
    end
  else
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.ShowUpvoteTips(uid, name)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_UPVOTE, uid)
end
function BattleResult.enter_room_battle_watch()
  log(bWriteLog and "BattleResult.enter_room_battle_watch")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true)
  local BattleResultHandler = require("client.network.Protocol.BattleResultHandler")
  BattleResultHandler.send_enter_room_battle_watch()
end
function BattleResult.on_enter_room_battle_watch_rsp(reason)
  log(bWriteLog and "BattleResult.on_enter_room_battle_watch_rsp reason:" .. tostring(reason))
  local strTile = DataMgr.GetMsgByID(102012)
  local strMsg = ""
  if reason == "watch_game_over" or reason == "game_over" or reason == "no_ob_game" then
    strMsg = LocUtil.GetLocalizeResStr(301111)
  else
    strMsg = LocUtil.GetLocalizeResStr(501150)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, strTile, strMsg, function()
    if LuaClassObj.GetGameStatus(bp_global) == GameStatus.Fighting then
      log(bWriteLog and "BattleResult.on_enter_room_battle_watch_rsp - deanytjin test should show mail 5")
      Client.ReturnToLobby(GameFrontendHUD)
    elseif LobbySystem.isWaittingEnterBattle then
      LobbySystem.SetWaitingBattleFlag(false)
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.RefreshLoadPercent(1)
      Client.ReturnToLobby(GameFrontendHUD)
    end
  end)
end
function BattleResult.get_ob_battle_info_rsp(ret, uid, ob_mode, ob_battle_record)
  log(bWriteLog and "get_ob_battle_info_rsp [ret:" .. ret .. "][uid:" .. uid .. "][ob_mode:" .. ob_mode .. "]")
  log_tree("ob_battle_record:", ob_battle_record)
  local playerOBBattleInfo = {}
  playerOBBattleInfo.UID = uid
  if ret == NetErrorCode_NONE and ob_battle_record ~= nil and ob_battle_record.game_num ~= nil then
    playerOBBattleInfo.ValidBattleInfo = true
    playerOBBattleInfo.BattleMode = ob_mode
    playerOBBattleInfo.GameCount = ob_battle_record.game_num
    playerOBBattleInfo.WinCount = ob_battle_record.win_num
    playerOBBattleInfo.TopTenCount = ob_battle_record.top10
    playerOBBattleInfo.KillNum = ob_battle_record.kill_num
    playerOBBattleInfo.KDNum = ob_battle_record.kd_v2 or ob_battle_record.kd
  else
    playerOBBattleInfo.ValidBattleInfo = false
    playerOBBattleInfo.BattleMode = 0
    playerOBBattleInfo.GameCount = 0
    playerOBBattleInfo.WinCount = 0
    playerOBBattleInfo.TopTenCount = 0
    playerOBBattleInfo.KillNum = 0
    playerOBBattleInfo.KDNum = 0
  end
  log_tree("playerOBBattleInfo:", playerOBBattleInfo)
  BattleResultUI.OnGetOBPlayerBattleInfo(playerOBBattleInfo)
end
function BattleResult.on_game_vs_team_result(result, result_union)
  print(bWriteLog and "game_vs_team_result", BattleResult.BattleResultTDMSwitch)
  log_tree("DeathMatch Results are --", result)
  if Client then
    xpcall(function()
      EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_PRE_BATTLE_RESULT)
    end, utility.ErrorMessageHandler)
  end
  DataMgr.match_union_info = result_union
  if UIManager.UI_Config_InGame.FirstTimeTipsDeathMatch then
    UIManager.CloseUI(UIManager.UI_Config_InGame.FirstTimeTipsDeathMatch)
  end
  if UIManager.UI_Config_InGame.FirstTimeTipsHardPoint then
    UIManager.CloseUI(UIManager.UI_Config_InGame.FirstTimeTipsHardPoint)
  end
  if UIManager.UI_Config_InGame.FirstTimeTipsArmsRace then
    UIManager.CloseUI(UIManager.UI_Config_InGame.FirstTimeTipsArmsRace)
  end
  DeathMatchResultUI.OnDeathMatchResult(result)
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  TournamentsManager.SetResultType(result)
end
function BattleResult.on_ob_result_tdm(result)
  print(bWriteLog and "game_vs_team_result , ob result", BattleResult.BattleResultTDMSwitch)
  log_tree("DeathMatch ob Results are --", result)
  if Client then
    xpcall(function()
      EventSystem:postEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_PRE_BATTLE_RESULT)
    end, utility.ErrorMessageHandler)
  end
  DeathMatchResultUI.OnDeathMatchResult(result, true)
end
function BattleResult.on_game_infection_result(result)
  log_tree("BattleResult.on_game_infection_result", result)
  BattleResultInfectionUI.OnBattleResult(result)
end
function BattleResult.on_game_vehicle_result(result)
  log_tree("BattleResult.on_game_vehicle_result", result)
  BattleResultVehicleUI.OnBattleResult(result)
end
function BattleResult.on_notify_corps_add_active_info(corps_active_type, corps_add_active_type, total_active)
  log(bWriteLog and "on_notify_corps_add_active_info" .. #corps_add_active_type)
  log_tree("BattleResult.on_notify_corps_add_active_info", corps_add_active_type)
  local logic_corps_energy_mission = require("client.slua.logic.corps.logic_corps_energy_mission")
  logic_corps_energy_mission.  if not logic_corps_energy_mission.corps_add_active_type then
    logic_corps_energy_mission.corps_add_active_type = {}
  end
  for k, v in pairs(corps_add_active_type) do
    if logic_corps_energy_mission.corps_add_active_type[k] then
      logic_corps_energy_mission.corps_add_active_type[k] = logic_corps_energy_mission.corps_add_active_type[k] + v
      log(bWriteLog and "on_notify_corps_add_active_info k" .. k .. "v" .. v .. "corps_add_active_type" .. logic_corps_energy_mission.corps_add_active_type[k])
    else
      logic_corps_energy_mission.corps_add_active_type[k] = v
      log(bWriteLog and "on_notify_corps_add_active_info k" .. k .. "v" .. v)
    end
  end
  log_tree("BattleResult.on_notify_corps_add_active_info logic_corps_energy_mission.corps_add_active_type", logic_corps_energy_mission.corps_add_active_type)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_CORPS_ACTIVE)
end