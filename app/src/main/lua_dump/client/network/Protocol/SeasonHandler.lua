local NetManager = require("client.network.comm.NetManager")
local SeasonHandler = {}
function SeasonHandler.on_season_end_notify(season_info)
  log_tree("on_season_end_notify season_info", season_info)
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.on_season_end_reminder(season_info.season_id, season_info.max_segment, season_info.max_rating)
end
function SeasonHandler.send_get_season_file(uid, seasonId, tabType)
  NetManager.SendPkg(155665366, uid, seasonId, tabType)
end
function SeasonHandler.on_get_season_file_rsp(ret, target_uid, season_id, record_type, record)
  local SeasonReviewSystem = require("client.logic.season.logic_season_review")
  SeasonReviewSystem.OnGetSeasonFileRsp(ret, target_uid, season_id, record_type, record)
end
function SeasonHandler.send_get_season_file_summy(uid)
  NetManager.SendPkg(1182366102, uid)
end
function SeasonHandler.on_get_season_file_summy_rsp(target_uid, season_file_summy_list)
  local SeasonReviewSystem = require("client.logic.season.logic_season_review")
  SeasonReviewSystem.OnGetSeasonFileSummyRsp(target_uid, season_file_summy_list)
end
function SeasonHandler.send_get_task_state_list()
  NetManager.SendPkg(504414182)
end
function SeasonHandler.on_get_task_state_list_rsp(ok, season, cur_season_id, is_idle_time, best_segment, pre_best_segment, bseason_newer)
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.get_task_state_list_rsp(ok, season, cur_season_id, is_idle_time, best_segment, pre_best_segment, bseason_newer)
end
function SeasonHandler.send_take_season_task_prize(id)
  NetManager.SendPkg(1330538444, id)
end
function SeasonHandler.on_take_season_task_prize_rsp(ok, awards)
  log(bWriteLog and "SeasonHandler.on_take_season_task_prize_rsp ok = " .. tostring(ok))
  log_tree("SeasonHandler.on_take_season_task_prize_rsp awards = ", awards)
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  logic_season_award:take_season_task_prize_rsp(ok, awards)
end
function SeasonHandler.send_get_role_battle_max_rank_rating()
  NetManager.SendPkg(1885481092)
end
function SeasonHandler.on_get_role_battle_max_rank_rating_rsp(solo_max_rank_rating, duo_max_rank_rating, squad_max_rank_rating, fpp_solo_max_rank_rating, fpp_duo_max_rank_rating, fpp_squad_max_rank_rating)
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.get_role_battle_max_rank_rating_rsp(solo_max_rank_rating, duo_max_rank_rating, squad_max_rank_rating, fpp_solo_max_rank_rating, fpp_duo_max_rank_rating, fpp_squad_max_rank_rating)
end
function SeasonHandler.on_season_switch_info_summary(new_segment_info)
  local logic_season_switch_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_switch_slap)
  logic_season_switch_slap:on_season_switch_info_summary(new_segment_info)
end
function SeasonHandler.send_task_season_segment_prize(task_id, index)
  NetManager.SendPkg(1800131731, task_id, index)
end
function SeasonHandler.on_task_season_segment_prize_res(res, task_id)
  if res ~= 0 then
    if res == 108303 then
      ShowNotice(19351)
    else
      ShowNotice(res)
    end
    return
  end
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  logic_season_award:on_task_season_segment_prize_res(task_id)
end
function SeasonHandler.send_query_challenge_info_req()
  NetManager.SendPkg(560556391)
end
function SeasonHandler.on_query_challenge_info_rsp(challenge_info)
  log_tree("on_query_challenge_info_rsp", challenge_info)
  challenge_info = challenge_info or {}
  if challenge_info then
    local SeasonSystem = require("client.logic.season.logic_season")
    SeasonSystem.OnChanllengeInfoChange(challenge_info)
  end
end
function SeasonHandler.send_task_season_segment_prize_all_req()
  NetManager.SendPkg(566788931)
end
function SeasonHandler.on_task_season_segment_prize_all_rsp(err_code, awards, invoke_type)
  log(bWriteLog and "SeasonHandler.on_task_season_segment_prize_all_rsp " .. err_code)
  log(bWriteLog and "SeasonHandler.on_task_season_segment_prize_all_rsp invoke_type" .. tostring(invoke_type))
  log_tree("SeasonHandler.on_task_season_segment_prize_all_rsp ", awards)
  if err_code ~= 0 then
    if err_code == 108305 then
      ShowNotice(108301)
      SeasonHandler.send_get_task_state_list()
    else
      ShowNotice(err_code)
    end
    return
  end
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  logic_season_award:on_task_season_segment_prize_all_rsp(awards, invoke_type)
end
function SeasonHandler.send_set_season_reward_head_frame_privacy(cur_value)
  NetManager.SendPkg(1661726028, cur_value)
end
function SeasonHandler.on_set_season_reward_head_frame_privacy_rsp(error_code)
end
function SeasonHandler.on_notify_challenge_compensate_score(id, add_score)
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.challengeTipsInfo = {}
  SeasonSystem.challengeTipsInfo.  SeasonSystem.challengeTipsInfo.score = add_score
  log_tree("[ZH] SeasonSystem.challengeTipsInfo", SeasonSystem.challengeTipsInfo)
  SeasonSystem.on_notify_challenge_compensate_score(id, add_score)
end
function SeasonHandler.on_past_season_rating(rating)
  SeasonHandler.pre_season_max_rating = rating.pre_season_max_rating
  SeasonHandler.pre_season_same_day_rating = rating.pre_season_same_day_rating
  SeasonHandler.rank_rating = rating.rank_rating
end
function SeasonHandler.send_get_season_config_req()
  NetManager.SendPkg(823130568)
end
function SeasonHandler.on_get_season_config_res(err, config)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_season_config = require("client.logic.season.logic_season_config")
  logic_season_config.UpdateSeasonConfig(config)
end
function SeasonHandler.send_get_season_year_memory_data_req()
  NetManager.SendPkg(1189713104)
end
function SeasonHandler.on_get_season_year_memory_data_res(err_code, cur_year_id, cur_match_id, memory_data, memory_item_conf, title_conf, task_data, task_cfg, started_season_year_id, started_season_id)
  log(bWriteLog and "[v_ywuyuan] err_code" .. " err_code " .. tostring(err_code))
  local logic_season_cycle_memory = require("client.logic.season.logic_season_cycle_memory")
  logic_season_cycle_memory.on_get_season_year_memory_data_res(err_code, cur_year_id, cur_match_id, memory_data, memory_item_conf, title_conf, task_data, task_cfg, started_season_year_id, started_season_id)
end
function SeasonHandler.send_get_season_year_memory_item_reward_req(year_id, season_index, item_id)
  NetManager.SendPkg(245896936, year_id, season_index, item_id)
end
function SeasonHandler.on_get_season_year_memory_item_reward_res(err_code, year_id, season_index, item_id)
  if err_code ~= 0 then
    log(bWriteLog and "on_get_season_year_memory_item_reward_res err_code : " .. tostring(err_code))
    ShowNotice(err_code)
    return
  end
  local logic_season_cycle_memory = require("client.logic.season.logic_season_cycle_memory")
  logic_season_cycle_memory.on_get_season_year_memory_item_reward_res(year_id, season_index, item_id)
end
function SeasonHandler.send_get_season_year_memory_progress_reward_req(year_id, season_index, stage)
  NetManager.SendPkg(732709383, year_id, season_index, stage)
end
function SeasonHandler.on_get_season_year_memory_progress_reward_rsp(err_code, year_id, season_index, stage, award_list)
  if err_code ~= 0 then
    log(bWriteLog and "on_get_season_year_memory_progress_reward_rsp err_code : " .. tostring(err_code))
    ShowNotice(err_code)
    return
  end
  local logic_season_cycle_memory = require("client.logic.season.logic_season_cycle_memory")
  logic_season_cycle_memory.on_get_season_year_memory_progress_reward_rsp(year_id, season_index, stage, award_list)
end
function SeasonHandler.on_season_year_memory_event_notify(type, params)
  log(bWriteLog and "[v_ywuyuan] on_season_year_memory_event_notify!!!")
  local logic_season_cycle_memory = require("client.logic.season.logic_season_cycle_memory")
  logic_season_cycle_memory.on_season_year_memory_event_notify(type, params)
end
function SeasonHandler.send_season_year_memory_clear_season_redpoint_req()
  log(bWriteLog and "[v_ywuyuan] send_season_year_memory_clear_season_redpoint_req!!!")
  NetManager.SendPkg(1924240295)
end
function SeasonHandler.on_season_year_memory_clear_season_redpoint_rsp(err_code)
  local logic_season_cycle_memory = require("client.logic.season.logic_season_cycle_memory")
  logic_season_cycle_memory.on_season_year_memory_clear_season_redpoint_rsp()
end
function SeasonHandler.send_get_prev_season_year_memory_data_req(year_id, season_index)
  NetManager.SendPkg(832437287, year_id, season_index)
end
function SeasonHandler.on_get_prev_season_year_memory_data_rsp(err_code, year_id, season_index, task_list, task_cfg, memory_data, memory_item_conf, title_conf)
  if err_code == 113000016 then
    log(bWriteLog and "on_get_prev_season_year_memory_data_rsp err_code : " .. tostring(err_code))
    ShowNotice(37295)
  elseif err_code ~= 0 then
    log(bWriteLog and "on_get_prev_season_year_memory_data_rsp err_code : " .. tostring(err_code))
    ShowNotice(err_code)
  end
  local logic_season_cycle_memory = require("client.logic.season.logic_season_cycle_memory")
  logic_season_cycle_memory.on_get_prev_season_year_memory_data_rsp(err_code, year_id, season_index, task_list, task_cfg, memory_data, memory_item_conf, title_conf)
end
function SeasonHandler.on_notify_challenge_info_cfg(cfg_table)
  if cfg_table and next(cfg_table) then
    local SeasonSystem = require("client.logic.season.logic_season")
    SeasonSystem.SyncChallengeExchangeTable(cfg_table)
  end
end
function SeasonHandler.on_notify_min_rank_no_score_list(min_rank_no_score_list)
  if min_rank_no_score_list and next(min_rank_no_score_list) then
    local SeasonSystem = require("client.logic.season.logic_season")
    SeasonSystem.SyncConquerorMinScore(min_rank_no_score_list)
  end
end
function SeasonHandler.send_set_high_segment_title_pursuit(zone_id, mode_id, title_id)
  NetManager.SendPkg(2112292140, zone_id, mode_id, title_id)
end
function SeasonHandler.on_set_high_segment_title_pursuit_rsp(err_code, zone_id, mode_id, title_id)
  if err_code ~= 0 then
    log(bWriteLog and "on_set_high_segment_title_pursuit_rsp errcode is " .. tostring(err_code))
    return
  end
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  local segTitleId = logic_segment_title:OnSetOneSegmentTitleRsp(title_id, zone_id, mode_id)
end
function SeasonHandler.send_get_high_segment_title_pursuit()
  NetManager.SendPkg(1167119020)
end
function SeasonHandler.on_get_high_segment_title_pursuit_rsp(title_data, archive_data)
  log(bWriteLog and "SeasonHandler.on_get_high_segment_title_pursuit_rsp")
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  local segTitleId = logic_segment_title:on_get_high_segment_title_pursuit_rsp(title_data, archive_data)
end
function SeasonHandler.send_get_other_high_segment_title(target_uid)
  NetManager.SendPkg(865256268, target_uid)
end
function SeasonHandler.on_get_other_high_segment_title_rsp(err_code, target_uid, title_data, archive_data)
  if err_code ~= 0 then
    log(bWriteLog and "SeasonHandler.on_get_other_high_segment_title_rsp err_code = " .. tostring(err_code))
  end
  log(bWriteLog and "SeasonHandler.on_get_other_high_segment_title_rsp target_uid = " .. tostring(target_uid))
  log_tree("SeasonHandler.on_get_other_high_segment_title_rsp, title_data = ", title_data)
  log_tree("SeasonHandler.on_get_other_high_segment_title_rsp, archive_data = ", archive_data)
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  logic_segment_title:OnGetOtherSegmentTitleRsp(target_uid, title_data, archive_data)
end
function SeasonHandler.send_get_season_file_reddot_req()
  NetManager.SendPkg(1782485575)
end
function SeasonHandler.on_get_season_file_reddot_rsp(err_code, if_reddot)
  log(bWriteLog and "SeasonHandler.on_get_season_file_reddot_rsp err_code = " .. tostring(err_code) .. " if_reddot = " .. tostring(if_reddot))
  if err_code == 0 and if_reddot then
    EventSystem:postEvent(EVENTTYPE_SEASON_REVIEW, EVENTID_SEASON_REVIEW_SUMMARY_FILE_REDDOT)
  end
end
function SeasonHandler.send_get_peakgame_season_file_req(target_uid, season_id)
  NetManager.SendPkg(414401191, target_uid, season_id)
end
function SeasonHandler.on_get_peakgame_season_file_rsp(ok, target_uid, season_id, rsp)
  local SeasonReviewSystem = require("client.logic.season.logic_season_review")
  log_tree("SeasonHandler.on_get_peakgame_season_file_rsp ", rsp)
  SeasonReviewSystem.OnGetPeakGameSeasonFileRsp(ok, target_uid, season_id, rsp)
end
function SeasonHandler.send_confirm_show_conqueror_req(season_id)
  NetManager.SendPkg(132376423, season_id)
end
function SeasonHandler.on_confirm_show_conqueror_rsp(err_code)
  log(bWriteLog and "SeasonHandler.on_confirm_show_conqueror_rsp err_code = " .. tostring(err_code))
end
function SeasonHandler.on_conqueror_popup_notify(segment_info)
  log_tree("SeasonHandler.on_conqueror_popup_notify segment_info = ", segment_info)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cached_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonKing)
  log_tree("SeasonHandler.on_conqueror_popup_notify cached_info = ", cached_info)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if cached_info and cached_info.rank_no then
    log(bWriteLog and "SeasonHandler.on_conqueror_popup_notify cache return")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "saveConquerorInfo2_hasCache")
    return
  end
  if UIManager.UI_Config.ui_season_slapface2_s47 and UIManager.IsUIShow(UIManager.UI_Config.ui_season_slapface2_s47) then
    log(bWriteLog and "SeasonHandler.on_conqueror_popup_notify has show")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "saveConquerorInfo2_hasShow")
    return
  end
  if segment_info.rank_no and segment_info.rank_no > 0 then
    log(bWriteLog and "SeasonHandler.on_conqueror_popup_notify cache info")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Conqueror_Video_Play_Report, 0, "saveConquerorInfo2_cache")
    PlayerPrefsSystem.SaveTableToFile_N(segment_info, PlayerPrefsSystem.ePlayerPrefsType.eSeasonKing)
  end
end
function SeasonHandler.send_get_conqueror_info_req(ext_info)
  NetManager.SendPkg(1316843015, ext_info)
end
function SeasonHandler.on_get_conqueror_info_rsp(segment_info, ext_info)
  log(bWriteLog and "SeasonHandler.on_get_conqueror_info_rsp segment_info")
  log_tree("SeasonHandler.on_get_conqueror_info_rsp segment_info = ", segment_info)
  log_tree("SeasonHandler.on_get_conqueror_info_rsp ext_info = ", ext_info)
  local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
  log(bWriteLog and "SeasonHandler.on_get_conqueror_info_rsp IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
  if not IsInLobbyOrMainCity then
    return
  end
  if not (segment_info.rank_no and segment_info.rank_no > 0) or ext_info and ext_info.source == "show" then
  elseif ext_info and ext_info.source == "play" then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(segment_info, PlayerPrefsSystem.ePlayerPrefsType.eSeasonKing)
    local logic_lobby_system_entrance = require("client.slua.logic.lobby.logic_lobby_system_entrance")
    local play_result = logic_lobby_system_entrance.OnSeasonKing()
    log(bWriteLog and "SeasonHandler.on_get_conqueror_info_rsp play_result = " .. tostring(play_result))
    if play_result then
      local logic_season_const = require("client.logic.season.logic_season_const")
      if play_result == logic_season_const.PlayConquerorVideoResult.LowDevice then
        ShowNotice(9891)
      elseif play_result == logic_season_const.PlayConquerorVideoResult.NotDownloadVideo then
        ShowNotice(7421)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_CONQUEROR_INFO, segment_info)
end
local hasSendSelectPromotionLayerNotice = false
function SeasonHandler.send_select_promotion_layer_req(is_open_promotion)
  log(bWriteLog and "SeasonHandler.send_select_promotion_layer_req is_open_promotion = " .. tostring(is_open_promotion))
  hasSendSelectPromotionLayerNotice = true
  NetManager.SendPkg(1308097415, is_open_promotion)
end
function SeasonHandler.on_select_promotion_layer_rsp(err_code, is_open_promotion, uid)
  log(bWriteLog and string.format("SeasonHandler.on_select_promotion_layer_rsp err_code = %s, is_open_promotion = %s", tostring(err_code), tostring(is_open_promotion)))
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  if not logic_promotion_mode then
    return
  end
  if err_code ~= 0 then
    logic_promotion_mode:HandleErrorCode(err_code, uid)
  end
  logic_promotion_mode:proc_select_promotion_layer_rsp(err_code, is_open_promotion)
  if hasSendSelectPromotionLayerNotice and err_code == 0 and is_open_promotion ~= 0 then
    ShowNotice(85380)
    hasSendSelectPromotionLayerNotice = false
  end
end
function SeasonHandler.send_season_task_dropid_content_req(dropids, key)
  NetManager.SendPkg(999755271, dropids, key)
end
function SeasonHandler.on_season_task_dropid_content_rsp(err_code, key, drop_list)
  if err_code ~= NetErrorCode_NONE then
    log_error("on_season_task_dropid_content_rsp error reason : " .. tostring(err_code))
    return
  end
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  logic_season_award:on_season_task_dropid_content_rsp(drop_list)
end
function SeasonHandler.send_take_season_transition_reward_req()
  NetManager.SendPkg(1299672775)
end
function SeasonHandler.on_take_season_transition_reward_rsp(err_code, itemlist)
  local logic_season_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_award)
  logic_season_award:on_take_season_transition_reward_rsp(err_code, itemlist)
end
function SeasonHandler.send_promotion_return_segment_req(accept, battle_id)
  NetManager.SendPkg(507109991, accept, battle_id)
end
function SeasonHandler.on_promotion_return_segment_rsp(err_code, rating_info)
  log(bWriteLog and "SeasonHandler.on_promotion_return_segment_rsp err_code = " .. tostring(err_code))
  log_tree("SeasonHandler.on_promotion_return_segment_rsp rating_info = ", rating_info)
  if err_code ~= 0 then
    if err_code == 100600058 then
      ShowNotice(18010005)
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_PROMOTION_RETURN_SEGMENT, rating_info)
end
return SeasonHandler