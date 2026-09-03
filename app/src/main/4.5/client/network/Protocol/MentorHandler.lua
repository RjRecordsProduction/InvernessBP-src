local NetManager = require("client.network.comm.NetManager")
local logic_mentor_record = require("client.slua.logic.mentor.logic_mentor_record")
local MentorHandler = {}
function MentorHandler.send_mentor_history_req()
  NetManager.SendPkg(1575780935)
end
function MentorHandler.on_mentor_history_rsp(res, today_mentor_count, mentor_award_datly_limit, mentor_data_historys)
  logic_mentor_record.mentory_history_rsp(res, today_mentor_count, mentor_award_datly_limit, mentor_data_historys)
end
function MentorHandler.send_mentor_evaluate_req(evaluate, labels)
  NetManager.SendPkg(1076701167, evaluate, labels)
end
function MentorHandler.on_mentor_evaluate_rsp(res)
  logic_mentor_record.on_mentor_evaluate_rsp(res)
end
function MentorHandler.send_mentor_reward_req(battle_id)
  NetManager.SendPkg(294628879, battle_id)
end
function MentorHandler.on_mentor_reward_rsp(res, battle_id, awards)
  logic_mentor_record.on_mentor_reward_rsp(res, battle_id, awards)
end
function MentorHandler.send_mentor_batch_reward_req()
  NetManager.SendPkg(540672267)
end
function MentorHandler.on_mentor_batch_reward_rsp(res, awards)
  logic_mentor_record.on_mentor_batch_reward_rsp(res, awards)
end
function MentorHandler.send_mentor_register_req(sub_mode, is_open_microphone, multi_select_param)
  NetManager.SendPkg(368143079, sub_mode, is_open_microphone, multi_select_param)
end
function MentorHandler.on_mentor_register_rsp(err_code)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_register_rsp(err_code)
end
function MentorHandler.send_get_mentor_status_req()
  NetManager.SendPkg(1817989591)
end
function MentorHandler.on_get_mentor_status_rsp(err_code, mentee_error, mentor_error, ban_notice, leave_ban_time)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.get_mentor_status_rsp(err_code, mentee_error, mentor_error, ban_notice, leave_ban_time)
end
function MentorHandler.on_mentor_status_sync(reason, qualification, identity, waiting_status)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_status_sync(reason, qualification, identity, waiting_status)
end
function MentorHandler.send_set_mentor_identity_req(identity, req_id)
  NetManager.SendPkg(1510783951, identity, req_id)
end
function MentorHandler.on_set_mentor_identity_rsp(err_code, req_id)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.set_mentor_identity_rsp(err_code, req_id)
end
function MentorHandler.send_mentor_recommend_req(count, zone_id, match_id, sub_mode, auto_match, is_open_microphone, is_same_language, client_cb, is_same_ploy)
  NetManager.SendPkg(1120689383, count, zone_id, match_id, sub_mode, auto_match, is_open_microphone, is_same_language, client_cb, is_same_ploy)
end
function MentorHandler.on_mentor_recommend_rsp(err_code, data, client_cb, fill_other_language_notice)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_recommend_rsp(err_code, data, client_cb, fill_other_language_notice)
end
function MentorHandler.send_mentor_team_request(tar_uid_map, netDelay, is_once_again)
  NetManager.SendPkg(2025872446, tar_uid_map, netDelay, is_once_again)
end
function MentorHandler.on_mentor_team_request_rsp(tar_uid_map, err_code, is_again)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_team_request_rsp(tar_uid_map, err_code, is_again)
end
function MentorHandler.send_mentor_team_respond(from_uid, is_accept)
  NetManager.SendPkg(165627880, from_uid, is_accept)
end
function MentorHandler.on_mentor_team_respond_notify(mentor_uid, accept_status)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_team_respond_notify(mentor_uid, accept_status)
end
function MentorHandler.send_mentor_team_request_cancel(tar_uid)
  NetManager.SendPkg(536352194, tar_uid)
end
function MentorHandler.on_mentor_team_request_cancel_notify(from_info)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_team_request_cancel_notify(from_info)
end
function MentorHandler.send_get_mentor_data_req()
  NetManager.SendPkg(407540935)
end
function MentorHandler.on_get_mentor_data_rsp(ret, mentor_data)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.get_mentor_data_rsp(ret, mentor_data)
end
function MentorHandler.on_mentor_task_change_notify(change_tasks)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_task_change_notify(change_tasks)
end
function MentorHandler.send_mentor_task_reward_req(task_id)
  NetManager.SendPkg(780429927, task_id)
end
function MentorHandler.on_mentor_task_reward_rsp(ret, task_id)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_task_reward_rsp(ret, task_id)
end
function MentorHandler.send_mentor_award_stat_req()
  NetManager.SendPkg(832867291)
end
function MentorHandler.on_mentor_award_stat_rsp(award_mentor_status, award_common_status, award_permanent_status, have_level_award)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_award_stat_rsp(award_mentor_status, award_common_status, award_permanent_status, have_level_award)
end
function MentorHandler.on_mentor_team_request_notify(from_info)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_team_request_notify(from_info)
end
function MentorHandler.on_mentor_team_request_notify_others(from_uid)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_team_request_notify_others(from_uid)
end
function MentorHandler.send_mentor_unregister_req()
  NetManager.SendPkg(44767907)
end
function MentorHandler.on_mentor_unregister_rsp()
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_unregister_rsp()
end
function MentorHandler.send_mentor_emotion_report_req(stat)
  NetManager.SendPkg(1280198919, stat)
end
function MentorHandler.send_get_mentor_predictive_wait_time_req()
  NetManager.SendPkg(1000049435)
end
function MentorHandler.on_get_mentor_predictive_wait_time_rsp(predictive_time)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.get_mentor_predictive_wait_time_rsp(predictive_time)
end
function MentorHandler.on_notify_mentee_is_in_team(mentee_id)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.notify_mentee_is_in_team(mentee_id)
end
function MentorHandler.on_mentor_evaluate_notify(battle_id, stat, labels, mentor_exp)
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.mentor_evaluate_notify(battle_id, stat, labels)
end
function MentorHandler.send_mentor_match_req()
  NetManager.SendPkg(1109157906)
end
function MentorHandler.send_mentor_prematch_cancel_req()
  NetManager.SendPkg(1939380758)
end
function MentorHandler.send_mentor_claim_exp_req()
  NetManager.SendPkg(1449343847)
end
function MentorHandler.on_mentor_claim_exp_rsp()
end
function MentorHandler.on_enter_mentor_prematch_state()
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.on_enter_mentor_prematch_state()
end
function MentorHandler.on_quit_mentor_prematch_state()
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.on_quit_mentor_prematch_state()
end
function MentorHandler.on_mentor_level_up_notify(old_level, cur_level, awards_list)
  local MentorLevelAwardSystem = require("client.slua.logic.mentor.logic_mentor_level_award")
  MentorLevelAwardSystem.on_mentor_level_up_notify(old_level, cur_level, awards_list)
end
function MentorHandler.on_mentor_level_info_sync(info)
  local MentorLevelAwardSystem = require("client.slua.logic.mentor.logic_mentor_level_award")
  MentorLevelAwardSystem.on_mentor_level_info_sync(info)
end
function MentorHandler.send_mentee_evaluate_req(evaluate, labels)
  NetManager.SendPkg(1018481843, evaluate, labels)
end
function MentorHandler.on_mentee_evaluate_rsp(res)
  logic_mentor_record.on_mentee_evaluate_rsp(res)
end
function MentorHandler.send_mentor_declaration_set_req(declaration)
  NetManager.SendPkg(1318054247, declaration)
end
function MentorHandler.on_mentor_declaration_set_rsp(err_code, declaration, is_dirty_cn)
  log(bWriteLog and "mentor_declaration_set_rsp err_code: " .. tostring(err_code) .. " declaration: " .. tostring(declaration) .. " is_dirty_cn: " .. tostring(is_dirty_cn))
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.on_mentor_declaration_set_rsp(err_code, declaration, is_dirty_cn)
end
function MentorHandler.send_mentor_level_info_req()
  NetManager.SendPkg(436762895)
end
function MentorHandler.on_mentor_level_info_rsp(err_code, level, level_add_rewardeds)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "MentorHandler.on_mentor_level_info_rsp level = " .. tostring(level))
  log_tree("MentorHandler.on_mentor_level_info_rsp level_add_rewardeds = ", level_add_rewardeds)
  local MentorLevelAwardSystem = require("client.slua.logic.mentor.logic_mentor_level_award")
  MentorLevelAwardSystem.on_mentor_level_info_rsp(level, level_add_rewardeds)
end
function MentorHandler.send_mentor_level_reward_req(level)
  NetManager.SendPkg(197160931, level)
end
function MentorHandler.on_mentor_level_reward_rsp(err_code, level, awards)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "MentorHandler.on_mentor_level_reward_rsp level = " .. tostring(level))
  log_tree("MentorHandler.on_mentor_level_reward_rsp awards = ", awards)
  local MentorLevelAwardSystem = require("client.slua.logic.mentor.logic_mentor_level_award")
  MentorLevelAwardSystem.on_mentor_level_reward_rsp(level, awards)
end
function MentorHandler.send_mentor_level_all_reward_req()
  NetManager.SendPkg(176534523)
end
function MentorHandler.on_mentor_level_all_reward_rsp(err_code, level, all_awards)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "MentorHandler.on_mentor_level_all_reward_rsp level = " .. tostring(level))
  log_tree("MentorHandler.on_mentor_level_all_reward_rsp all_awards = ", all_awards)
  local MentorLevelAwardSystem = require("client.slua.logic.mentor.logic_mentor_level_award")
  MentorLevelAwardSystem.on_mentor_level_all_reward_rsp(level, all_awards)
end
function MentorHandler.on_mentee_register_rsp(err_code)
end
function MentorHandler.on_mentee_unregister_rsp(err_code)
end
function MentorHandler.send_mentor_recommend_mentee_req(count)
  NetManager.SendPkg(514420903, count)
end
function MentorHandler.on_mentor_recommend_mentee_rsp(err_code, search_res)
  local logic_newbie_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_team_recommend)
  logic_newbie_team_recommend:proc_mentor_recommend_mentee_rsp(err_code, search_res)
end
function MentorHandler.send_mentee_register_req(mode_zone, mode_type, sub_mode, fill, is_open_microphone, is_same_language, is_same_match_strategy)
  NetManager.SendPkg(307622059, mode_zone, mode_type, sub_mode, fill, is_open_microphone, is_same_language, is_same_match_strategy)
end
function MentorHandler.send_mentee_unregister_req()
  NetManager.SendPkg(925484575)
end
return MentorHandler