local NetManager = require("client.network.comm.NetManager")
local MatchHandler = {}
function MatchHandler.send_set_player_match_strategy_req(id, type)
  NetManager.SendPkg(567197619, id, type)
end
function MatchHandler.on_set_player_match_strategy_rsp(err_code, match_strategy)
  if err_code == 0 then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.OnSetPlayerMatchStrategyRsp(match_strategy)
  else
    ShowNotice(err_code)
  end
end
function MatchHandler.on_sync_segment_protect_shield(shield)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.OnSyncSegmentProtectShield(shield)
end
function MatchHandler.send_on_match_req(matchID, isFill, data_list, device_info, enter_from, metro_worth_check_vote_token, extra_info)
  log(bWriteLog and "MatchHandler.send_on_match_req matchID = " .. tostring(matchID))
  local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
  if logic_account_protect_setting:IsCurSelectModeLimit() then
    logic_account_protect_setting:ShowModeLimitPopup()
    return
  end
  if matchID and type(matchID) == "number" and matchID ~= 1012 then
    local MatchModeTable = CDataTable.GetTableData("MatchModeTable", matchID)
    if MatchModeTable and MatchModeTable.Mode == "UG" then
      if Client.IsDevelopment() then
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(1, "Error(dev-only)", "Keep The Scene ~~~ Call edwardzchen")
      end
      ShowNotice(32550)
      return
    end
  end
  local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
  if logic_mode_asymmertric:GetHasSelectedCamp() then
    extra_info = extra_info or {}
    extra_info.camp_type = logic_mode_asymmertric:GetCampForMatch()
  end
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  if logic_promotion_mode:IsCanSelect() and matchID and type(matchID) == "number" and matchID == 103 then
    extra_info = extra_info or {}
    extra_info.promotion_layer = LobbySystem.roleData.is_open_promotion
  end
  log_tree("MatchHandler.send_on_match_req extra_info = ", extra_info)
  NetManager.SendPkg(820900744, matchID, isFill, data_list, device_info, enter_from, metro_worth_check_vote_token, extra_info)
end
function MatchHandler.on_on_match_res(msg, waitTime, reason, surplustime, estimatetime, matchLang, ban_count, line_pos, line_speed, is_mentor, res_params, match_guide_cfg, is_all_krjp_region, ext_info)
  log(bWriteLog and "MatchHandler.on_on_match_res msg = " .. tostring(msg))
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.on_start_match_rsp()
  LobbySystem.on_start_match_rsp(msg, waitTime, reason, surplustime, estimatetime, matchLang, ban_count, line_pos, line_speed, is_mentor, res_params, match_guide_cfg, is_all_krjp_region, ext_info)
  MentorSystem.on_match_res()
end
function MatchHandler.send_query_player_state_req()
  NetManager.SendPkg(1723747335)
end
function MatchHandler.on_query_player_state_rsp(state_info)
  log(bWriteLog and "MatchHandler.on_query_player_state_rsp")
  log_tree(bWriteLog and "MatchHandler.on_query_player_state_rsp state_info = ", state_info)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.OnQueryPlayerStateRsp(state_info)
  if state_info and state_info.match_info then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    logic_mode_selection:OnSyncMatchInfo(state_info.match_info)
  end
end
function MatchHandler.send_try_re_enter_game()
  NetManager.SendPkg(56652489)
end
function MatchHandler.on_re_enter_game(ip, port, key, packet_key, game_id, res, team_info, antsvoice_url, is_watch, start_to_plane, forced_exit_game_times, ad_conf, dynamic_disabled_levels, team_id, camp_id, sub_mode, eigeninfo, feedback_flag, land_id, waterType, svr_pub_key, svr_packet_key_md5, socialland_info, waterUserID, ext_info, custom_room_id, mode_type, team_antsvoice_url, manor_info, additional_data, grome_info, collect_hall_info)
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  logic_enter_game:on_re_enter_game(ip, port, key, packet_key, game_id, res, team_info, antsvoice_url, is_watch, start_to_plane, forced_exit_game_times, ad_conf, dynamic_disabled_levels, team_id, camp_id, sub_mode, eigeninfo, feedback_flag, land_id, waterType, svr_pub_key, svr_packet_key_md5, socialland_info, waterUserID, ext_info, custom_room_id, mode_type, team_antsvoice_url, manor_info, additional_data, grome_info, collect_hall_info)
end
function MatchHandler.on_low_priority_match_ban_cancel()
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.OnMatchBanCancelNotify()
end
function MatchHandler.send_on_match_across_zone_req(zoneList)
  NetManager.SendPkg(1850754184, zoneList)
end
function MatchHandler.on_on_match_across_zone_res(msg)
  LobbySystem.on_match_across_zone_res(msg)
end
function MatchHandler.send_league_match_req(Mode, flag, SubMode)
  NetManager.SendPkg(823378442, Mode, flag, SubMode)
end
function MatchHandler.on_on_match_success(msg, team_info, antsvoice_url, deathmatch_teams, game_team_size, gameid, team_id, camp_id, sub_mode, feedback_flag, ugc_mod)
  log(bWriteLog and "MatchHandler.on_match_success..submode id " .. tostring(sub_mode) .. " gameid=" .. tostring(gameid))
  LobbySystem.on_match_success(msg, team_info, antsvoice_url, deathmatch_teams, game_team_size, gameid, team_id, camp_id, sub_mode, feedback_flag, ugc_mod)
end
function MatchHandler.send_report_test_battle_ping(receivePingList, showPingList, dns_err_table)
  NetManager.SendPkg(692004049, receivePingList, showPingList, dns_err_table)
end
function MatchHandler.send_new_report_map_download_log(network_status, download_type, map_id, event_id, report_value)
  NetManager.SendPkg(1239942598, network_status, download_type, map_id, event_id, report_value)
end
function MatchHandler.send_report_vedio_show_completed(uid, teamId, modeId)
  NetManager.SendPkg(1534479638, uid, teamId, modeId)
end
function MatchHandler.on_notify_vedio_show(modeId)
end
function MatchHandler.send_on_krjp_rematch_asia_zone_req()
  NetManager.SendPkg(1940292319)
end
function MatchHandler.send_get_long_time_match_mode(modeId, viewId)
  log(bWriteLog and "MatchHandler.send_get_long_time_match_mode modeId = " .. tostring(modeId) .. " viewId = " .. tostring(viewId))
  NetManager.SendPkg(252140246, modeId, viewId)
end
function MatchHandler.on_get_match_guide_mode_rsp(res, modeList)
  log(bWriteLog and "MatchHandler.on_get_match_guide_mode_rsp res = " .. tostring(res))
  log_tree("MatchHandler.on_get_match_guide_mode_rsp modeList", modeList)
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  logic_long_time_match:on_get_long_time_match_mode_rsp(res, modeList)
end
function MatchHandler.send_report_match_guide_window_info(reportInfo)
  log_tree("MatchHandler.send_report_match_guide_window_info reportInfo", reportInfo)
  NetManager.SendPkg(360188889, reportInfo)
end
function MatchHandler.send_report_match_guide_operation_info(IsSwitch, GapTime, IsMatchSuccess, WaitTime)
  log(bWriteLog and "MatchHandler.send_report_match_guide_operation_info IsSwitch = " .. tostring(IsSwitch) .. " GapTime = " .. tostring(GapTime) .. " IsMatchSuccess = " .. tostring(IsMatchSuccess) .. " WaitTime = " .. tostring(WaitTime))
  NetManager.SendPkg(1172162248, IsSwitch, GapTime, IsMatchSuccess, WaitTime)
end
function MatchHandler.on_lang_match_close_notify(wait_time)
  log(bWriteLog and "MatchHandler.on_lang_match_close_notify wait_time:" .. tostring(wait_time))
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.on_lang_match_close_notify(wait_time)
end
function MatchHandler.send_rollback_team_type()
  NetManager.SendPkg(2028536299)
end
function MatchHandler.send_report_epl_thd_ping_data(ping_info_collect)
  log_tree("[DeanJYT] MatchHandler.send_report_epl_thd_ping_data ping_info_collect = ", ping_info_collect)
  NetManager.SendPkg(856298267, ping_info_collect)
end
function MatchHandler.on_on_KRJP_match_to_asia()
  local ui = UIManager.GetUI(UIManager.UI_Config.Cross_Server_Popup)
  if ui then
    ui:CloseSelf()
  end
  ShowNotice(86216)
end
function MatchHandler.send_report_epoll_ping_info(shadow_ping_stat)
  NetManager.SendPkg(1590089593, shadow_ping_stat)
end
function MatchHandler.send_report_grome_link_err(err_info)
  NetManager.SendPkg(1201435516, err_info)
end
function MatchHandler.send_device_not_support_grome_link(reason, extra_info)
  NetManager.SendPkg(1840825462, reason, extra_info)
end
function MatchHandler.on_sync_match_process(sync_interval, cur_player_cnt, max_player_cnt, will_success, teammate_cnt, process_detail)
  local tb = {
    "MatchHandler.on_sync_match_process",
    "sync_interval",
    tostring(sync_interval),
    " cur_player_cnt",
    tostring(cur_player_cnt),
    " max_player_cnt",
    tostring(max_player_cnt),
    " will_success",
    tostring(will_success),
    " teammate_cnt",
    tostring(teammate_cnt)
  }
  local str = table.concat(tb, ", ")
  log(bWriteLog and tostring(str))
  if process_detail and next(process_detail) then
    for k, v in pairs(process_detail) do
      log_format(bWriteLog and "MatchHandler.on_sync_match_process process_detail %s : %s, %s", k, v, process_detail)
    end
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.on_sync_match_process(sync_interval, cur_player_cnt, max_player_cnt, will_success, teammate_cnt, process_detail)
end
function MatchHandler.on_notify_gromelink_open_stat(stat, game_id)
  local LogicGRomeLink = require("client.slua.logic.gromelink.logic_grome_link")
  LogicGRomeLink:OnNotifyGRomelinkOpenStat(stat, game_id)
end
function MatchHandler.send_grome_enter_battle_result(result, extra_info)
  NetManager.SendPkg(1565531910, result, extra_info)
end
function MatchHandler.send_get_data_pass_to_ds_req(id, mod_name, default_key)
  NetManager.SendPkg(102634255, id, mod_name, default_key)
end
function MatchHandler.on_get_data_pass_to_ds_rsp(err_code, id, data, mod_name, default_key)
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  logic_battle_data_transmission:proc_on_get_data_pass_to_ds_rsp(err_code, id, data, mod_name, default_key)
end
function MatchHandler.send_set_data_pass_to_ds_req(id, data, mod_name, default_key)
  NetManager.SendPkg(691071551, id, data, mod_name, default_key)
end
function MatchHandler.on_set_data_pass_to_ds_rsp(err_code, id, mod_name, default_key)
  log(bWriteLog and "MatchHandler.on_set_data_pass_to_ds_rsp err_code = " .. tostring(err_code) .. " id = " .. tostring(id))
  local logic_battle_data_transmission = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_data_transmission)
  logic_battle_data_transmission:proc_on_set_data_pass_to_ds_rsp(err_code, id, mod_name, default_key)
end
function MatchHandler.on_enter_monster_failed()
  local LobbySystem = require("client.slua.logic.lobby.logic_lobby")
  LobbySystem.on_start_match_req()
end
return MatchHandler