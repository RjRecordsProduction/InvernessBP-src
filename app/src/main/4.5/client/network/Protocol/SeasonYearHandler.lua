local NetManager = require("client.network.comm.NetManager")
local SeasonYearHandler = {}
function SeasonYearHandler.send_get_season_year_streak_challenge_info_req()
  NetManager.SendPkg(1375113163)
end
function SeasonYearHandler.on_get_season_year_streak_challenge_info_rsp(err_code, info)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_rank_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_rank_task)
  logic_season_year_rank_task:on_get_season_year_streak_challenge_info_rsp(info)
end
function SeasonYearHandler.send_get_season_year_streak_challenge_award_req(id)
  NetManager.SendPkg(129127015, id)
end
function SeasonYearHandler.on_get_season_year_streak_challenge_award_rsp(err_code, id, rewards)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_rank_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_rank_task)
  logic_season_year_rank_task:on_get_season_year_streak_challenge_award_rsp(id, rewards)
end
function SeasonYearHandler.send_season_year_remedy_streak_challenge_req(list)
  NetManager.SendPkg(159431927, list)
end
function SeasonYearHandler.on_season_year_remedy_streak_challenge_rsp(errcode, info)
  if errcode and errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  local logic_season_year_rank_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_rank_task)
  logic_season_year_rank_task:on_season_year_remedy_streak_challenge_rsp(info)
end
function SeasonYearHandler.send_get_trial_challenge_progress_req()
  log(bWriteLog and "SeasonYearHandler.send_get_trial_challenge_progress_req")
  NetManager.SendPkg(1158839783)
end
function SeasonYearHandler.on_get_trial_challenge_progress_rsp(err_code, data)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("SeasonYearHandler.on_get_trial_challenge_progress_rsp data:", data)
  local logic_season_year_trial_mission = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_trial_mission)
  logic_season_year_trial_mission:on_get_trial_challenge_progress_rsp(data)
end
function SeasonYearHandler.send_claim_trial_challenge_reward_req()
  log(bWriteLog and "SeasonYearHandler.send_claim_trial_challenge_reward_req")
  NetManager.SendPkg(261223335)
end
function SeasonYearHandler.on_claim_trial_challenge_reward_rsp(err_code, res_list)
  if err_code and err_code ~= 0 then
    local err_msg = {
      [20170001] = 502003,
      [20170002] = 411044,
      [20170003] = 8711,
      [20170004] = 411044
    }
    if err_msg[err_code] then
      ShowNotice(err_msg[err_code])
    else
      ShowNotice(err_code)
    end
    return
  end
  log_tree("SeasonYearHandler.on_claim_trial_challenge_reward_rsp res_list:", res_list)
  local logic_season_year_trial_mission = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_trial_mission)
  logic_season_year_trial_mission:on_claim_trial_challenge_reward_rsp(res_list)
end
function SeasonYearHandler.send_get_trial_challenge_red_point_req()
  log(bWriteLog and "SeasonYearHandler.send_get_trial_challenge_red_point_req")
  NetManager.SendPkg(1752859403)
end
function SeasonYearHandler.on_get_trial_challenge_red_point_rsp(err_code, reddot)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "SeasonYearHandler.on_get_trial_challenge_red_point_rsp reddot: " .. (reddot and "true" or "false"))
  local logic_season_year_trial_mission = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_trial_mission)
  logic_season_year_trial_mission:on_get_trial_challenge_red_point_rsp(reddot)
end
function SeasonYearHandler.send_remove_trial_challenge_red_point_req()
  log(bWriteLog and "SeasonYearHandler.send_remove_trial_challenge_red_point_req")
  NetManager.SendPkg(825676583)
end
function SeasonYearHandler.on_remove_trial_challenge_red_point_rsp(err_code)
  if err_code and err_code ~= 0 then
    log(bWriteLog and "SeasonYearHandler.on_remove_trial_challenge_red_point_rsp err_code: " .. err_code)
  end
end
function SeasonYearHandler.send_get_season_year_cfg_req(table_name)
  NetManager.SendPkg(28810551, table_name)
end
function SeasonYearHandler.on_get_season_year_cfg_rsp(err_code, table_name, cfg)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local data_config_marco = require("client.logic.data.data_config_marco")
  if table_name == data_config_marco.season_year_badge_cfg then
    local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
    logic_season_year_badge:on_get_season_year_badge_cfg_rsp(cfg)
  elseif table_name == data_config_marco.year_task_cfg then
    local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
    logic_season_year_badge:on_get_season_year_task_cfg_rsp(cfg)
  elseif table_name == data_config_marco.season_year_streak_challenge_cfg then
    local logic_season_year_rank_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_rank_task)
    logic_season_year_rank_task:on_get_season_year_cfg_rsp(cfg)
  end
end
function SeasonYearHandler.on_notify_badge_part_finished_progress(badge_part_id, task_id, progress_id)
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_season_year_badge_info_notify(badge_part_id, task_id, progress_id)
end
function SeasonYearHandler.send_get_cur_year_task_info_req()
  NetManager.SendPkg(1895415687)
end
function SeasonYearHandler.on_get_cur_year_task_info_rsp(err_code, info)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_get_cur_year_task_info_rsp(info)
end
function SeasonYearHandler.send_get_year_task_reward_req(task_id)
  NetManager.SendPkg(2035125671, task_id)
end
function SeasonYearHandler.on_get_year_task_reward_rsp(err_code, id, rewards)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_get_year_task_reward_rsp(id, rewards)
end
function SeasonYearHandler.send_get_other_season_year_badge_req(target_uid)
  log(bWriteLog and "SeasonYearHandler.send_get_other_season_year_badge_req target_uid = " .. target_uid)
  NetManager.SendPkg(833482935, target_uid)
end
function SeasonYearHandler.on_get_other_season_year_badge_rsp(err_code, target_uid, all_badge_info)
  log(bWriteLog and "SeasonYearHandler.on_get_other_season_year_badge_rsp err_code = " .. tostring(err_code) .. ", target_uid = " .. tostring(target_uid))
  log_tree("all_badge_info = ", all_badge_info)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_get_other_season_year_badge_rsp(target_uid, all_badge_info)
end
function SeasonYearHandler.send_set_season_year_badge_show_req(show_type)
  NetManager.SendPkg(836280071, show_type)
end
function SeasonYearHandler.on_set_season_year_badge_show_rsp(err_code)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_send_set_season_year_badge_show_rsp()
end
function SeasonYearHandler.send_get_season_year_badge_show_req()
  NetManager.SendPkg(160785543)
end
function SeasonYearHandler.on_get_season_year_badge_show_rsp(err_code, show_type)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_get_season_year_badge_show_rsp(show_type)
end
function SeasonYearHandler.send_get_cur_season_login_days_req()
  NetManager.SendPkg(684221615)
end
function SeasonYearHandler.on_get_cur_season_login_days_rsp(err_code, login_count)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_get_cur_season_login_days_rsp(login_count)
end
function SeasonYearHandler.send_get_season_year_badge_req()
  NetManager.SendPkg(2096256723)
end
function SeasonYearHandler.on_get_season_year_badge_rsp(err_code, data)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_get_season_year_badge_info_rsp(data)
end
function SeasonYearHandler.send_get_all_season_year_streak_challenge_info_req()
  NetManager.SendPkg(2142034195)
end
function SeasonYearHandler.on_get_all_season_year_streak_challenge_info_rsp(err, info)
  if err and err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_season_year_rank_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_rank_task)
  logic_season_year_rank_task:on_get_all_season_year_streak_challenge_info_rsp(info)
end
function SeasonYearHandler.send_get_other_season_year_streak_challenge_info_req(target_uid)
  NetManager.SendPkg(1320751615, target_uid)
end
function SeasonYearHandler.on_get_other_season_year_streak_challenge_info_rsp(err, target_uid, data)
  if err and err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_season_year_rank_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_rank_task)
  logic_season_year_rank_task:on_get_other_season_year_streak_challenge_info_rsp(target_uid, data)
end
function SeasonYearHandler.send_set_season_year_badge_show_scene_req(scene_key, show_value, year_id)
  NetManager.SendPkg(1980666855, scene_key, show_value, year_id)
end
function SeasonYearHandler.on_set_season_year_badge_show_scene_rsp(err, scene_key, show_value, year_id)
  if err and err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_set_season_year_badge_show_scene_rsp(scene_key, show_value, year_id)
end
function SeasonYearHandler.send_get_all_season_trial_data_req(target_uid)
  NetManager.SendPkg(1199949563, target_uid)
end
function SeasonYearHandler.on_get_all_season_trial_data_rsp(err_code, target_uid, all_season_data)
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_season_year_trial_mission = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_trial_mission)
  logic_season_year_trial_mission:on_get_all_season_trial_data_rsp(target_uid, all_season_data)
end
function SeasonYearHandler.send_get_season_year_badge_show_info_req()
  NetManager.SendPkg(2059038959)
end
function SeasonYearHandler.on_get_season_year_badge_show_info_rsp(err, show_info)
  if err and err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
  logic_season_year_badge:on_get_season_year_badge_show_info_rsp(show_info)
end
function SeasonYearHandler.test_send_get_season_year_badge_show_info_req()
  local data = {
    pre_team = {show = 1, year_id = 11},
    social_hall = {show = 0, year_id = 0},
    battle_load = {show = 0, year_id = 0}
  }
  SeasonYearHandler.on_get_season_year_badge_show_info_rsp(0, data)
end
return SeasonYearHandler