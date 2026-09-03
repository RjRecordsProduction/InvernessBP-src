local NetManager = require("client.network.comm.NetManager")
local BattleResultHandler = {}
function BattleResultHandler.on_game_vs_team_result(result, result_union)
  BattleResult.on_game_vs_team_result(result, result_union)
end
function BattleResultHandler.on_game_result(battle_result, result)
  BattleResult.on_game_result(battle_result, result)
end
function BattleResultHandler.on_on_game_over(game_id)
  BattleResult.on_game_over(game_id)
end
function BattleResultHandler.on_game_result_ob(result)
  BattleResult.on_game_result_ob(result)
end
function BattleResultHandler.send_test_gameresult_req()
  NetManager.SendPkg(1388704130)
end
function BattleResultHandler.on_test_gameresult_res(result_gs)
  BattleResult.on_test_game_result(result_gs)
end
function BattleResultHandler.on_cust_room_result(room_result, room_stat, customize_result)
  BattleResult.on_game_finished_ob_result(room_result, room_stat, customize_result)
end
function BattleResultHandler.send_enter_room_battle_watch()
  NetManager.SendPkg(581320958)
end
function BattleResultHandler.on_enter_room_battle_watch_rsp(reason)
  BattleResult.on_enter_room_battle_watch_rsp(reason)
end
function BattleResultHandler.on_game_infection_result(result)
  BattleResult.on_game_infection_result(result)
end
function BattleResultHandler.on_game_vehicle_result(result)
  BattleResult.on_game_vehicle_result(result)
end
function BattleResultHandler.on_cust_room_vs_team_result(result)
  BattleResult.on_ob_result_tdm(result)
end
function BattleResultHandler.on_get_ob_battle_info_rsp(ret, uid, ob_mode, ob_battle_record)
  BattleResult.get_ob_battle_info_rsp(ret, uid, ob_mode, ob_battle_record)
end
function BattleResultHandler.on_upvote_res(uid, name, giftSource)
  BattleResult.on_upvote_res(uid, name, giftSource)
end
function BattleResultHandler.send_upvote_req(nUID, giftSource)
  NetManager.SendPkg(1531385608, nUID, giftSource)
end
function BattleResultHandler.send_report_battle_feedback(g_game_id, BP_FeedBackScore)
  NetManager.SendPkg(2076459873, g_game_id, BP_FeedBackScore)
end
function BattleResultHandler.send_report_video(BP_STRUCT_RecordDataTLogUpload)
  NetManager.SendPkg(657603972, BP_STRUCT_RecordDataTLogUpload)
end
function BattleResultHandler.send_battle_end_get_all_reward_req(submod_id)
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(true)
  NetManager.SendPkg(312211409, submod_id)
end
function BattleResultHandler.on_battle_end_get_all_reward_rep(reason, result)
  log(bWriteLog and "BattleResultHandler.on_battle_end_get_all_reward_rep")
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(false)
  if SubsystemMgr then
    local BattleResultRewardSubsystem = SubsystemMgr:Get("BattleResultRewardSubsystem")
    if BattleResultRewardSubsystem then
      BattleResultRewardSubsystem:BattleResultRewardDataHandle(reason, result)
    end
  end
  if reason ~= 0 then
    return
  end
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  logic_achievement.ReturnToLobbySendMsg(result)
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.isNeedGetState = true
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.SetIsSendMsg(result)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.SetIsSendMsg(result)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.ReturnLobbyMsg = true
end
function BattleResultHandler.on_asian_game_result(result, resultType)
  local AsianGamesGameMode = {
    Person = 1,
    Team = 2,
    Game = 3
  }
  if result then
    log_tree("BattleResultHandler.on_asian_game_result", result)
  end
  if resultType and EVENTTYPE_ASIAN_GAMES then
    print(bWriteLog and "BattleResultHandler.on_asian_game_result resultType", resultType)
    if resultType == AsianGamesGameMode.Team then
      EventSystem:postEvent(EVENTTYPE_ASIAN_GAMES, EVENTID_ASIAN_GAMES_TEAM_COMPLETE, result)
    elseif resultType == AsianGamesGameMode.Game then
      EventSystem:postEvent(EVENTTYPE_ASIAN_GAMES, EVENTID_ASIAN_GAMES_TEAM_RANK_LIST, result)
    end
  end
end
function BattleResultHandler.on_battle_end_get_all_reward_start(err_code)
  if err_code == 0 then
    local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
    rpGift.SetAddFlag(true)
  end
end
function BattleResultHandler.send_report_player_battle_score(param)
  NetManager.SendPkg(1685795158, param)
end
function BattleResultHandler.on_notify_corps_add_active_info(corps_active_type, corps_add_active_type, total_active)
  BattleResult.on_notify_corps_add_active_info(corps_active_type, corps_add_active_type, total_active)
end
function BattleResultHandler.on_battle_end_recommend_friend(recommend_uid, recommend_value, labels, text_id, recommend_type)
  log(bWriteLog and "recommend_uid = " .. tostring(recommend_uid))
  log(bWriteLog and "recommend_value = " .. tostring(recommend_value))
  log(bWriteLog and "recommend_type = " .. tostring(recommend_type))
  log_tree("on_battle_end_recommend_friend labels", labels)
  local logic_recommend_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_recommend_friend)
  logic_recommend_friend:OnNotifyRecommendedFriendInfo(recommend_uid, recommend_value, text_id, labels, recommend_type)
end
function BattleResultHandler.on_pcob_weaponinfo_result(room_id, result_player_id, weapon_result, pcob_item_pickup_data, pcob_item_use_data, custom_room_id)
  BattleResult.on_pcob_playerweaponinfo_result(room_id, result_player_id, weapon_result, pcob_item_pickup_data, pcob_item_use_data, custom_room_id)
end
function BattleResultHandler.send_get_battle_pspace_gift_record_req(battle_id)
  log(bWriteLog and "[BattleResultHandler] send_get_battle_pspace_gift_record_req: " .. tostring(battle_id))
  NetManager.SendPkg(1914290407, battle_id)
end
function BattleResultHandler.on_get_battle_pspace_gift_record_rsp(err_code, battle_id, gift_record_info)
  log(bWriteLog and "[BattleResultHandler] on_get_battle_pspace_gift_record_rsp: " .. tostring(err_code))
  if not SubsystemMgr then
    log(bWriteLog and "[BattleResultHandler] nil SubsystemMgr")
    return
  end
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if not BattleResultSubSystem then
    log(bWriteLog and "[BattleResultHandler] nil BattleResultSubSystem")
    return
  end
  local BattleResultShowAvatarLogic = BattleResultSubSystem:GetResultProcessLogic("BattleResultShowAvatarLogic")
  if not BattleResultShowAvatarLogic then
    log(bWriteLog and "[BattleResultHandler] nil BattleResultShowAvatarLogic")
    return
  end
  if BattleResultShowAvatarLogic.OnGetInGameGiftRecord then
    BattleResultShowAvatarLogic:OnGetInGameGiftRecord(err_code, gift_record_info, battle_id)
  end
end
function BattleResultHandler.send_report_win_dance_req(battle_id, team_id, dance_type)
  print(bWriteLog and "BattleResultHandler.send_report_win_dance_req", battle_id, team_id, dance_type)
  NetManager.SendPkg(2146442154, battle_id, team_id, dance_type)
end
function BattleResultHandler.send_report_battle_evaluation(battle_id, evaluation)
  NetManager.SendPkg(376977114, battle_id, evaluation)
end
function BattleResultHandler.send_highlight_reel_choice_req(battle_id, choice)
  print(bWriteLog and "BattleResultHandler.send_highlight_reel_choice_req", battle_id, choice)
  NetManager.SendPkg(684433447, battle_id, choice)
end
function BattleResultHandler.on_highlight_reel_choice_rsp(err_code, battle_id, choice, daily_remaining, version_remaining)
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_REEL_CHOICE_RSP, err_code, battle_id, choice, daily_remaining, version_remaining)
end
return BattleResultHandler