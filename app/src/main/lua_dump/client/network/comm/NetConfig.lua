local NetConfig = {
  msgMap = {},
  reconnectMsgMap = {}
}
function NetConfig.Init()
  NetConfig.msgMap = {
    [169082903] = {
      req = "aos_del_account_req",
      res = "aos_del_account_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "AOSDeleteHandler"
    },
    [1149773831] = {
      req = "aos_cancle_del_account_req",
      res = "aos_cancle_del_account_rsp",
      inGameOper = 0,
      handler = "AOSDeleteHandler"
    },
    [1220103] = {
      req = "dpa_exchange_point_req",
      res = "dpa_exchange_point_rsp",
      handler = "APlanExploreHandler"
    },
    [22016999] = {
      req = "dpa_unlock_item_level_req",
      res = "dpa_unlock_item_level_rsp",
      handler = "APlanExploreHandler"
    },
    [281346215] = {
      req = "dpa_receive_one_node_req",
      res = "dpa_receive_one_node_rsp",
      handler = "APlanExploreHandler"
    },
    [1054875566] = {
      res = "dpa_discovery_point_change_notify",
      handler = "APlanExploreHandler"
    },
    [1174655095] = {
      req = "dpa_get_activity_data_req",
      res = "dpa_get_activity_data_rsp",
      handler = "APlanExploreHandler"
    },
    [1921170727] = {
      req = "dpa_open_point_chest_req",
      res = "dpa_open_point_chest_rsp",
      isLock = 1,
      handler = "APlanExploreHandler"
    },
    [2010739879] = {
      req = "dpa_unlock_item_single_req",
      res = "dpa_unlock_item_single_rsp",
      handler = "APlanExploreHandler"
    },
    [1384479327] = {
      res = "player_cheat_state_notify",
      inGameOper = 0,
      handler = "AccessRestrictionHandler"
    },
    [417420711] = {
      req = "account_operate_get_serialno_req",
      res = "account_operate_get_serialno_rsp",
      timeInterval = 1,
      handler = "AccountBindHandler"
    },
    [488365651] = {
      req = "bind_social_email_req",
      res = "bind_social_email_rsp",
      handler = "AccountBindHandler"
    },
    [546734695] = {
      req = "account_operate_use_code_req",
      res = "account_operate_use_code_rsp",
      timeInterval = 1,
      handler = "AccountBindHandler"
    },
    [693740448] = {
      res = "only_social_bind_notify",
      inGameOper = 0,
      handler = "AccountBindHandler"
    },
    [826252839] = {
      req = "account_operate_start_req",
      res = "account_operate_start_rsp",
      timeInterval = 1,
      handler = "AccountBindHandler"
    },
    [835334847] = {
      req = "account_operate_check_req",
      res = "account_operate_check_rsp",
      timeInterval = 1,
      handler = "AccountBindHandler"
    },
    [1987031019] = {
      req = "account_operate_newcode_req",
      res = "account_operate_newcode_rsp",
      timeInterval = 1,
      handler = "AccountBindHandler"
    },
    [85433625] = {
      res = "general_redpoint_res",
      handler = "AccountHandler"
    },
    [368644341] = {
      req = "send_heart_beat_table",
      handler = "AccountHandler"
    },
    [1190949811] = {
      req = "get_account_link_info_req",
      res = "get_account_link_info_rsp",
      handler = "AccountHandler"
    },
    [1610157551] = {
      res = "openid_delete_notify",
      handler = "AccountHandler"
    },
    [1911922302] = {
      res = "notify_account_status",
      handler = "AccountHandler"
    },
    [2118399495] = {
      req = "new_account_direct_del_req",
      res = "new_account_direct_del_rsp",
      isLock = 1,
      timeInterval = 1,
      handler = "AccountHandler"
    },
    [536618631] = {
      req = "get_ace_imprint_detail_req",
      res = "get_ace_imprint_detail_rsp",
      timeout = 5,
      inGameOper = 0,
      handler = "AceImprintHandler"
    },
    [700464743] = {
      req = "ace_imprint_light_up_req",
      res = "ace_imprint_light_up_rsp",
      inGameOper = 0,
      handler = "AceImprintHandler"
    },
    [973341139] = {
      req = "make_up_ace_imprint_req",
      res = "make_up_ace_imprint_rsp",
      inGameOper = 0,
      handler = "AceImprintHandler"
    },
    [1010368423] = {
      req = "set_show_ace_imprint_req",
      res = "set_show_ace_imprint_rsp",
      handler = "AceImprintHandler"
    },
    [19458692] = {
      res = "googleplay_achiev_notify",
      handler = "AchieveHandler"
    },
    [53849962] = {
      res = "achievement_event_limit_notify",
      handler = "AchieveHandler"
    },
    [226995336] = {
      req = "get_achieve_rewards_list_req",
      res = "get_achieve_rewards_list_res",
      isLock = 1,
      handler = "AchieveHandler"
    },
    [608884203] = {
      req = "get_achieve_hit_req",
      handler = "AchieveHandler"
    },
    [709298722] = {
      req = "get_achieve_record_rewards_list_req",
      res = "get_achieve_record_rewards_list_res",
      handler = "AchieveHandler"
    },
    [841720992] = {
      req = "get_achievement_rewards_req",
      res = "get_achievement_rewards_res",
      isLock = 1,
      handler = "AchieveHandler"
    },
    [861501402] = {
      req = "report_achievement_finish",
      handler = "AchieveHandler"
    },
    [943513800] = {
      req = "report_achievement_condition_complete",
      handler = "AchieveHandler"
    },
    [1009908272] = {
      req = "get_achievement_summary_req",
      res = "get_achievement_summary_res",
      handler = "AchieveHandler"
    },
    [1238022686] = {
      res = "gamecenter_achiev_notify",
      handler = "AchieveHandler"
    },
    [1351824772] = {
      res = "achievement_event_limit_rsp",
      handler = "AchieveHandler"
    },
    [1523407560] = {
      req = "get_achievement_data_req",
      res = "get_achievement_data_res",
      isLock = 1,
      timeout = 60,
      handler = "AchieveHandler"
    },
    [1683340488] = {
      req = "get_achieve_record_rewards_req",
      res = "get_achieve_record_rewards_res",
      handler = "AchieveHandler"
    },
    [1781076488] = {
      req = "get_achieve_hit_list_req",
      res = "get_achieve_hit_list_res",
      handler = "AchieveHandler"
    },
    [1834431495] = {
      req = "get_achieve_assist_req",
      res = "get_achieve_assist_rsp",
      timeInterval = 15,
      handler = "AchieveHandler"
    },
    [1906194579] = {
      req = "get_achieve_extinct_req",
      res = "get_achieve_extinct_rsp",
      handler = "AchieveHandler"
    },
    [2058966464] = {
      req = "batch_get_achieve_hit_req",
      res = "batch_get_achieve_hit_res",
      handler = "AchieveHandler"
    },
    [2136020587] = {
      req = "set_achievement_show_req",
      handler = "AchieveHandler"
    },
    [217833063] = {
      req = "act_cycle_chest_take_award_req",
      res = "act_cycle_chest_take_award_rsp",
      handler = "ActivityHandler"
    },
    [228123815] = {
      req = "get_season_recharge_info_req",
      res = "get_season_recharge_info_rsp",
      isLock = 1,
      handler = "ActivityHandler"
    },
    [280855320] = {
      res = "week_signup_chg_notify",
      handler = "ActivityHandler"
    },
    [295438885] = {
      req = "report_last_open_act_center_ts",
      handler = "ActivityHandler"
    },
    [357550459] = {
      req = "get_activity_reward_req",
      res = "get_activity_reward_rsp",
      inGameOper = 0,
      handler = "ActivityHandler"
    },
    [361721564] = {
      req = "get_active_cycle_roll",
      res = "notify_cycleroll_msgs",
      handler = "ActivityHandler"
    },
    [435905529] = {
      res = "ams_lucky_draw_unback_egg_ntf",
      handler = "ActivityHandler"
    },
    [462371205] = {
      res = "sync_growup_duration_acts_rsp",
      handler = "ActivityHandler"
    },
    [522882794] = {
      req = "click_activity_report_req",
      handler = "ActivityHandler"
    },
    [526929351] = {
      req = "take_ams_lucky_draw_unback_egg_req",
      res = "take_ams_lucky_draw_unback_egg_rsp",
      isLock = 1,
      handler = "ActivityHandler"
    },
    [558712157] = {
      res = "notify_activity_and_display_changed",
      handler = "ActivityHandler"
    },
    [609534450] = {
      req = "get_act_gather_list_req",
      res = "get_act_gather_list_res",
      handler = "ActivityHandler"
    },
    [621215191] = {
      req = "get_ams_lucky_draw_unback_req",
      res = "get_ams_lucky_draw_unback_rsp",
      handler = "ActivityHandler"
    },
    [641640175] = {
      req = "get_refund_black_act_list_req",
      res = "get_refund_black_act_list_rsp",
      handler = "ActivityHandler"
    },
    [774533762] = {
      req = "deal_activity_req",
      res = "deal_activity_res",
      handler = "ActivityHandler"
    },
    [786712170] = {
      req = "get_activity_map_by_id_list_req",
      res = "get_activity_map_by_id_list_res",
      isUnique = 1,
      handler = "ActivityHandler"
    },
    [862896968] = {
      req = "get_activity_map_by_id_req",
      res = "get_activity_map_by_id_res",
      handler = "ActivityHandler"
    },
    [961641986] = {
      req = "week_batch_signup_award_req",
      res = "week_batch_signup_award_res",
      isLock = 1,
      handler = "ActivityHandler"
    },
    [1072929576] = {
      req = "get_activity_list_req",
      res = "get_activity_list_res",
      timeout = 5,
      inGameOper = 0,
      handler = "ActivityHandler"
    },
    [1081868023] = {
      req = "get_ab_testing_groupids_req",
      res = "get_ab_testing_groupids_rsp",
      handler = "ActivityHandler"
    },
    [1094253875] = {
      req = "eliminate_exchage_act_red_point_req",
      res = "eliminate_exchage_act_red_point_rsp",
      handler = "ActivityHandler"
    },
    [1155447928] = {
      req = "take_activity_award_req",
      res = "take_activity_award_res",
      isLock = 1,
      handler = "ActivityHandler"
    },
    [1168079725] = {
      req = "activity_goslar_score_report_req",
      handler = "ActivityHandler"
    },
    [1205555177] = {
      res = "draw_lucky_surprising_item_ntf",
      handler = "ActivityHandler"
    },
    [1255938877] = {
      res = "account_bind_activity_notify",
      inGameOper = 0,
      handler = "ActivityHandler"
    },
    [1262484459] = {
      req = "get_biochemical_activity_data_req",
      res = "get_biochemical_activity_data_rsp",
      handler = "ActivityHandler"
    },
    [1275382055] = {
      req = "get_tag_icon_cfg_req",
      res = "get_tag_icon_cfg_rsp",
      handler = "ActivityHandler"
    },
    [1318111942] = {
      res = "exchange_new_conf_ntf",
      inGameOper = 0,
      handler = "ActivityHandler"
    },
    [1362675525] = {
      res = "notify_display_new_table_src",
      handler = "ActivityHandler"
    },
    [1444818816] = {
      req = "week_signup_award_req",
      res = "week_signup_award_res",
      isLock = 1,
      handler = "ActivityHandler"
    },
    [1446661547] = {
      req = "batch_take_activity_award_req",
      res = "batch_take_activity_award_rsp",
      isLock = 1,
      timeout = 5,
      handler = "ActivityHandler"
    },
    [1448556455] = {
      req = "get_item_choice_list_req",
      res = "get_item_choice_list_rsp",
      handler = "ActivityHandler"
    },
    [1528814154] = {
      req = "update_activity_anim_flag",
      handler = "ActivityHandler"
    },
    [1539034742] = {
      res = "season_recharge_progress_changed_notify",
      handler = "ActivityHandler"
    },
    [1543249480] = {
      req = "get_activity_batch_req",
      res = "get_activity_batch_res",
      inGameOper = 0,
      handler = "ActivityHandler"
    },
    [1550200104] = {
      req = "take_special_activity_award_req",
      res = "take_special_activity_award_res",
      timeout = 5,
      handler = "ActivityHandler"
    },
    [1772492775] = {
      req = "take_season_recharge_award_req",
      res = "take_season_recharge_award_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ActivityHandler"
    },
    [1938459308] = {
      req = "pre_buy_rp",
      res = "pre_buy_rp_rsp",
      isLock = 1,
      handler = "ActivityHandler"
    },
    [1987047048] = {
      req = "get_activity_display_req",
      res = "get_activity_display_res",
      handler = "ActivityHandler"
    },
    [2034843251] = {
      req = "season_recharge_buy_req",
      res = "season_recharge_buy_rsp",
      handler = "ActivityHandler"
    },
    [2080606155] = {
      req = "report_add_desktop_tool_req",
      inGameOper = 0,
      handler = "ActivityHandler"
    },
    [2111139400] = {
      req = "get_activity_one_req",
      res = "get_activity_one_res",
      timeout = 5,
      inGameOper = 0,
      handler = "ActivityHandler"
    },
    [279637771] = {
      res = "voice_changed_notify",
      timeout = 5,
      handler = "ActorVoiceHandler"
    },
    [501679559] = {
      req = "get_voice_msg_info_req",
      res = "get_voice_msg_info_rsp",
      handler = "ActorVoiceHandler"
    },
    [812072487] = {
      req = "change_dubber_collect_data_req",
      res = "change_dubber_collect_data_rsp",
      handler = "ActorVoiceHandler"
    },
    [991958070] = {
      req = "update_voice_msgs_req",
      handler = "ActorVoiceHandler"
    },
    [1167693648] = {
      req = "select_voice_plan_change",
      handler = "ActorVoiceHandler"
    },
    [1251554127] = {
      res = "voice_dubber_first_get_notify",
      timeout = 5,
      handler = "ActorVoiceHandler"
    },
    [1447245243] = {
      req = "voice_msg_audition_req",
      handler = "ActorVoiceHandler"
    },
    [1674925854] = {
      res = "voice_decompose_notify",
      timeout = 5,
      handler = "ActorVoiceHandler"
    },
    [1930584262] = {
      res = "voice_dubber_changed_notify",
      timeout = 5,
      handler = "ActorVoiceHandler"
    },
    [2090114506] = {
      req = "select_voice_enter_play_change",
      handler = "ActorVoiceHandler"
    },
    [38560679] = {
      req = "show_google_task_req",
      res = "show_google_task_rsp",
      handler = "AdvertiseHandler"
    },
    [583672091] = {
      req = "set_google_ad_notice_req",
      res = "get_google_ad_notice_rsp",
      handler = "AdvertiseHandler"
    },
    [907737736] = {
      res = "google_ad_info",
      handler = "AdvertiseHandler"
    },
    [1419272678] = {
      req = "play_google_ad",
      res = "update_google_ad_info",
      handler = "AdvertiseHandler"
    },
    [1837068551] = {
      req = "google_ad_info_req",
      res = "google_ad_info_rsp",
      handler = "AdvertiseHandler"
    },
    [2066732934] = {
      res = "notice_google_ad_award",
      handler = "AdvertiseHandler"
    },
    [66172447] = {
      res = "sync_allstar_shop_info",
      handler = "AllStarHandler"
    },
    [91163527] = {
      req = "get_allstar_can_join_game_info_req",
      res = "get_allstar_can_join_game_info_rsp",
      handler = "AllStarHandler"
    },
    [244040359] = {
      req = "get_allstar_promote_reward_req",
      res = "get_allstar_promote_reward_rsp",
      handler = "AllStarHandler"
    },
    [246876487] = {
      req = "allstar_match_req",
      res = "allstar_match_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 3,
      handler = "AllStarHandler"
    },
    [258236551] = {
      req = "get_allstar_join_reward_req",
      res = "get_allstar_join_reward_rsp",
      handler = "AllStarHandler"
    },
    [329116519] = {
      req = "get_allstar_segment_rank_award_req",
      res = "get_allstar_segment_rank_award_rsp",
      handler = "AllStarHandler"
    },
    [441251921] = {
      res = "allstar_score_notify_chg",
      handler = "AllStarHandler"
    },
    [489568480] = {
      req = "compete_room_invite_request",
      res = "compete_room_invite_respond",
      handler = "AllStarHandler"
    },
    [561217639] = {
      req = "allstar_info_req",
      res = "allstar_info_rsp",
      handler = "AllStarHandler"
    },
    [618013046] = {
      req = "compete_room_invite_reply",
      handler = "AllStarHandler"
    },
    [637019027] = {
      req = "allstar_shop_get_accumulate_award_req",
      res = "allstar_shop_get_accumulate_award_rsp",
      handler = "AllStarHandler"
    },
    [788717295] = {
      res = "compete_room_invite_notify",
      handler = "AllStarHandler"
    },
    [789716483] = {
      req = "participate_competition_req",
      res = "participate_competition_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 3,
      handler = "AllStarHandler"
    },
    [790376231] = {
      req = "allstar_appointment_req",
      res = "allstar_appointment_rsp",
      handler = "AllStarHandler"
    },
    [827065983] = {
      req = "get_allstar_gray_info_req",
      res = "get_allstar_gray_info_rsp",
      handler = "AllStarHandler"
    },
    [1101654267] = {
      req = "enter_allstar_room_ob_req",
      res = "enter_allstar_room_ob_rsp",
      handler = "AllStarHandler"
    },
    [1142351527] = {
      req = "allstar_final_winner_req",
      res = "allstar_final_winner_rsp",
      handler = "AllStarHandler"
    },
    [1224274407] = {
      req = "allstar_shop_exchange_list_req",
      res = "allstar_shop_exchange_list_rsp",
      handler = "AllStarHandler"
    },
    [1390531719] = {
      req = "carteam_enroll_allstar_req",
      res = "carteam_enroll_allstar_rsp",
      handler = "AllStarHandler"
    },
    [1451350471] = {
      req = "enter_allstar_room_req",
      res = "enter_allstar_room_rsp",
      handler = "AllStarHandler"
    },
    [1502148263] = {
      req = "get_allstar_promote_stat_req",
      res = "get_allstar_promote_stat_rsp",
      handler = "AllStarHandler"
    },
    [1520388919] = {
      req = "allstar_segment_rank_info_req",
      res = "allstar_segment_rank_info_rsp",
      handler = "AllStarHandler"
    },
    [1522691367] = {
      req = "get_friend_carteam_segment_rank_info_req",
      res = "get_friend_carteam_segment_rank_info_rsp",
      handler = "AllStarHandler"
    },
    [1660790119] = {
      req = "get_carteam_allstar_segment_rank_no_req",
      res = "get_carteam_allstar_segment_rank_no_rsp",
      handler = "AllStarHandler"
    },
    [1728313559] = {
      req = "allstar_rank_info_req",
      res = "allstar_rank_info_rsp",
      handler = "AllStarHandler"
    },
    [1742467315] = {
      req = "allstar_shop_exchange_req",
      res = "allstar_shop_exchange_rsp",
      handler = "AllStarHandler"
    },
    [1837427890] = {
      res = "compete_room_invite_reply_notify",
      handler = "AllStarHandler"
    },
    [1848566583] = {
      req = "get_allstar_cfg_req",
      res = "get_allstar_cfg_rsp",
      handler = "AllStarHandler"
    },
    [1978476903] = {
      req = "get_allstar_active_award_req",
      res = "get_allstar_active_award_rsp",
      handler = "AllStarHandler"
    },
    [2094267279] = {
      req = "get_allstar_stage_req",
      res = "get_allstar_stage_rsp",
      handler = "AllStarHandler"
    },
    [2127086187] = {
      req = "carteam_select_allstar_area_req",
      res = "carteam_select_allstar_area_rsp",
      handler = "AllStarHandler"
    },
    [83299751] = {
      req = "unbind_carteam_group_req",
      res = "unbind_carteam_group_rsp",
      handler = "AllianceHandler"
    },
    [129603655] = {
      req = "create_carteam_req",
      res = "create_carteam_rsp",
      handler = "AllianceHandler"
    },
    [461463463] = {
      req = "allstar_battle_history_req",
      res = "allstar_battle_history_rsp",
      handler = "AllianceHandler"
    },
    [641149543] = {
      req = "imm_join_carteam_req",
      res = "imm_join_carteam_rsp",
      handler = "AllianceHandler"
    },
    [679044391] = {
      req = "find_carteam_by_name_req",
      res = "find_carteam_by_name_rsp",
      handler = "AllianceHandler"
    },
    [710511783] = {
      req = "get_carteam_group_relation_req",
      res = "get_carteam_group_relation_rsp",
      handler = "AllianceHandler"
    },
    [808239959] = {
      req = "carteam_coin_exchange_req",
      res = "carteam_coin_exchange_rsp",
      handler = "AllianceHandler"
    },
    [817412827] = {
      req = "set_car_team_flag_req",
      res = "set_car_team_flag_rsp",
      handler = "AllianceHandler"
    },
    [826625503] = {
      req = "accept_join_carteam_req",
      res = "accept_join_carteam_rsp",
      handler = "AllianceHandler"
    },
    [864535284] = {
      res = "notify_receive_offmsg",
      handler = "AllianceHandler"
    },
    [904289095] = {
      req = "get_carteam_apply_list_req",
      res = "get_carteam_apply_list_rsp",
      handler = "AllianceHandler"
    },
    [934765899] = {
      req = "query_carteam_req",
      res = "query_carteam_rsp",
      handler = "AllianceHandler"
    },
    [973471687] = {
      req = "change_carteam_req",
      res = "change_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1042736263] = {
      req = "carteam_coin_exchange_list_req",
      res = "carteam_coin_exchange_list_rsp",
      handler = "AllianceHandler"
    },
    [1080217895] = {
      req = "query_others_carteam_req",
      res = "query_others_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1121370535] = {
      req = "set_car_team_nation_flag_req",
      res = "set_car_team_nation_flag_rsp",
      handler = "AllianceHandler"
    },
    [1374816199] = {
      req = "pre_create_carteam_req",
      res = "pre_create_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1376539559] = {
      req = "join_carteam_req",
      res = "join_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1437417447] = {
      req = "get_carteam_allstar_rank_no_req",
      res = "get_carteam_allstar_rank_no_rsp",
      handler = "AllianceHandler"
    },
    [1536182951] = {
      req = "exit_carteam_req",
      res = "exit_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1591938863] = {
      req = "league_battle_history_req",
      res = "league_battle_history_rsp",
      handler = "AllianceHandler"
    },
    [1602500819] = {
      req = "invite_join_carteam_req",
      res = "invite_join_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1676601775] = {
      req = "set_carteam_fillopt_req",
      res = "set_carteam_fillopt_rsp",
      handler = "AllianceHandler"
    },
    [1729790903] = {
      req = "transfer_carteam_leader_req",
      res = "transfer_carteam_leader_rsp",
      handler = "AllianceHandler"
    },
    [1905122194] = {
      res = "notify_join_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1906117400] = {
      res = "notify_join_carteam",
      handler = "AllianceHandler"
    },
    [1910712292] = {
      res = "notify_update_carteam_member",
      handler = "AllianceHandler"
    },
    [1945730471] = {
      req = "approve_join_carteam_req",
      res = "approve_join_carteam_rsp",
      handler = "AllianceHandler"
    },
    [1954121735] = {
      req = "join_carteam_group_req",
      res = "join_carteam_group_rsp",
      handler = "AllianceHandler"
    },
    [1964864927] = {
      req = "carteam_suggestion_list_req",
      res = "carteam_suggestion_list_rsp",
      handler = "AllianceHandler"
    },
    [1989392758] = {
      res = "notify_update_carteam_info",
      handler = "AllianceHandler"
    },
    [1995637479] = {
      req = "carteam_fill_req",
      res = "carteam_fill_rsp",
      handler = "AllianceHandler"
    },
    [1996825447] = {
      req = "bind_carteam_group_req",
      res = "bind_carteam_group_rsp",
      handler = "AllianceHandler"
    },
    [2134893587] = {
      req = "kickout_carteam_req",
      res = "kickout_carteam_rsp",
      handler = "AllianceHandler"
    },
    [145129748] = {
      res = "get_nonage_data_rsp",
      inGameOper = 0,
      handler = "AntiaddctionHandler"
    },
    [392640667] = {
      req = "report_pakistan_minors_info_req",
      res = "report_pakistan_minors_info_rsp",
      handler = "AntiaddctionHandler"
    },
    [434669799] = {
      req = "set_nonage_req",
      res = "set_nonage_rsp",
      inGameOper = 0,
      handler = "AntiaddctionHandler"
    },
    [1525458422] = {
      res = "check_nonage_anti_work",
      inGameOper = 0,
      handler = "AntiaddctionHandler"
    },
    [391906323] = {
      res = "scene_trigger_notify",
      handler = "AppraiseHandler"
    },
    [1349360642] = {
      res = "guild_review_notify",
      inGameOper = 0,
      handler = "AppraiseHandler"
    },
    [839069351] = {
      req = "get_arena_season_prize_req",
      res = "get_arena_season_prize_rsp",
      handler = "ArenaHandler"
    },
    [1591929223] = {
      req = "receive_arena_season_prize_req",
      res = "receive_arena_season_prize_rsp",
      isLock = 1,
      handler = "ArenaHandler"
    },
    [1798603307] = {
      req = "get_arena_season_record_req",
      res = "get_arena_season_record_rsp",
      handler = "ArenaHandler"
    },
    [1204190222] = {
      req = "uninstall_weapon_skin",
      res = "uninstall_weapon_skin_rsp",
      isLock = 1,
      handler = "ArmoryHandler"
    },
    [1548448124] = {
      req = "install_weapon_skin",
      res = "install_weapon_skin_rsp",
      isLock = 1,
      handler = "ArmoryHandler"
    },
    [1865564387] = {
      res = "get_all_skin_list_rsp",
      handler = "ArmoryHandler"
    },
    [3886003] = {
      req = "del_cadge_req",
      res = "del_cadge_rsp",
      handler = "AskForHandler"
    },
    [129108505] = {
      res = "handsel_notify",
      handler = "AskForHandler"
    },
    [479510823] = {
      req = "batch_load_cadge_profile_req",
      res = "batch_load_cadge_profile_rsp",
      handler = "AskForHandler"
    },
    [506816491] = {
      req = "cadge_item_is_got_req",
      res = "cadge_item_is_got_rsp",
      handler = "AskForHandler"
    },
    [910260199] = {
      req = "refuse_cadge_req",
      res = "refuse_cadge_rsp",
      handler = "AskForHandler"
    },
    [948084810] = {
      res = "cadge_notify",
      handler = "AskForHandler"
    },
    [1427812907] = {
      req = "cadge_req",
      res = "cadge_rsp",
      handler = "AskForHandler"
    },
    [1467421991] = {
      req = "cadge_info_req",
      res = "cadge_info_rsp",
      handler = "AskForHandler"
    },
    [1658787143] = {
      req = "cadge_set_read_req",
      res = "cadge_set_read_rsp",
      handler = "AskForHandler"
    },
    [1664190887] = {
      req = "handsel_req",
      res = "handsel_rsp",
      handler = "AskForHandler"
    },
    [1696369325] = {
      res = "update_cadge_status_notify",
      handler = "AskForHandler"
    },
    [1865800999] = {
      req = "cadge_list_req",
      res = "cadge_list_rsp",
      handler = "AskForHandler"
    },
    [1870259175] = {
      req = "del_all_read_cadge_req",
      res = "del_all_read_cadge_rsp",
      handler = "AskForHandler"
    },
    [1889525003] = {
      req = "refuse_cadge_switch_req",
      res = "refuse_cadge_switch_rsp",
      handler = "AskForHandler"
    },
    [192190348] = {
      req = "take_full_action_award",
      res = "take_full_action_award_rsp",
      isLock = 1,
      handler = "AssemblyHandler"
    },
    [496228198] = {
      req = "take_assemb_award",
      res = "take_assemb_award_rsp",
      isLock = 1,
      handler = "AssemblyHandler"
    },
    [742092236] = {
      req = "assemb_invite_friend",
      res = "assemb_invite_friend_rsp",
      handler = "AssemblyHandler"
    },
    [743023432] = {
      req = "trigger_assemb_gold_tips_req",
      res = "trigger_assemb_gold_tips_res",
      inGameOper = 0,
      handler = "AssemblyHandler"
    },
    [826985675] = {
      req = "on_jpkr_assemb_reply",
      res = "on_jpkr_assemb_rsp",
      handler = "AssemblyHandler"
    },
    [907406599] = {
      res = "on_jpkr_assemb_bind_notify",
      handler = "AssemblyHandler"
    },
    [1093276195] = {
      req = "assemb_update_invite_list",
      res = "assemb_update_invite_list_res",
      inGameOper = 0,
      handler = "AssemblyHandler"
    },
    [1144753435] = {
      res = "assemb_notify",
      handler = "AssemblyHandler"
    },
    [1370946556] = {
      res = "rejoiner_task_notify",
      handler = "AssemblyHandler"
    },
    [1596942382] = {
      req = "take_task_award",
      res = "take_task_award_rsp",
      isLock = 1,
      handler = "AssemblyHandler"
    },
    [1658802720] = {
      req = "assemb_get_back_user_list_req",
      res = "assemb_get_back_user_list_res",
      handler = "AssemblyHandler"
    },
    [2056775557] = {
      req = "assemb_task_query_req",
      needRsp = 3,
      handler = "AssemblyHandler"
    },
    [2101562063] = {
      res = "on_jpkr_assemb_award_notify",
      handler = "AssemblyHandler"
    },
    [514649511] = {
      req = "brcard_collection_states_req",
      res = "brcard_collection_states_rsp",
      handler = "BRCardCollectionHandler"
    },
    [854242343] = {
      req = "brcard_collection_activate_req",
      res = "brcard_collection_activate_rsp",
      handler = "BRCardCollectionHandler"
    },
    [538016871] = {
      req = "brcard_get_ladder_reward_req",
      res = "brcard_get_ladder_reward_rsp",
      handler = "BRCardLadderHandler"
    },
    [1990350503] = {
      req = "brcard_get_ladder_info_req",
      res = "brcard_get_ladder_info_rsp",
      handler = "BRCardLadderHandler"
    },
    [381161055] = {
      res = "sync_mic_suspicious",
      inGameOper = 0,
      handler = "BattleHander"
    },
    [446448067] = {
      req = "get_ban_id_req",
      res = "ban_info_notify",
      inGameOper = 0,
      handler = "BattleHander"
    },
    [448674447] = {
      req = "popularity_showcase_lottery_req",
      res = "popularity_showcase_lottery_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "BattleHander"
    },
    [896738332] = {
      res = "notify_tips_to_client",
      inGameOper = 0,
      handler = "BattleHander"
    },
    [1147232130] = {
      res = "voice_ban_notify",
      inGameOper = 0,
      handler = "BattleHander"
    },
    [1193165930] = {
      res = "sync_mic_pre_filter",
      handler = "BattleHander"
    },
    [1839634710] = {
      res = "voice_ban_success",
      inGameOper = 0,
      handler = "BattleHander"
    },
    [1892132977] = {
      req = "suspicious_flag_req",
      inGameOper = 0,
      handler = "BattleHander"
    },
    [282093223] = {
      req = "batch_get_bin_battle_profile_req",
      res = "batch_get_bin_battle_profile_rsp",
      inGameOper = 0,
      handler = "BattleProfileHandler"
    },
    [198099026] = {
      res = "sync_microvision_report_switch",
      inGameOper = 0,
      handler = "BattleReportHandler"
    },
    [881710055] = {
      req = "get_game_report_by_uid_req",
      res = "get_game_report_by_uid_rsp",
      inGameOper = 0,
      handler = "BattleReportHandler"
    },
    [896517099] = {
      res = "notify_vod_game_report_state_update",
      inGameOper = 0,
      handler = "BattleReportHandler"
    },
    [1504171095] = {
      req = "vod_game_report_req",
      res = "vod_game_report_rsp",
      timeInterval = 2,
      inGameOper = 0,
      handler = "BattleReportHandler"
    },
    [1600762259] = {
      req = "get_game_report_req",
      res = "get_game_report_rsp",
      inGameOper = 0,
      handler = "BattleReportHandler"
    },
    [1850176647] = {
      req = "batch_get_vod_info_req",
      res = "batch_get_vod_info_rsp",
      inGameOper = 0,
      handler = "BattleReportHandler"
    },
    [1911420135] = {
      req = "batch_get_game_report_req",
      res = "batch_get_game_report_rsp",
      inGameOper = 0,
      handler = "BattleReportHandler"
    },
    [16484087] = {
      res = "asian_game_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [39810397] = {
      res = "on_game_over",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [61649746] = {
      res = "battle_end_get_all_reward_start",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [134086908] = {
      res = "get_ob_battle_info_rsp",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [285835068] = {
      res = "battle_end_recommend_friend",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [312211409] = {
      req = "battle_end_get_all_reward_req",
      res = "battle_end_get_all_reward_rep",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [376977114] = {
      req = "report_battle_evaluation",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [438361341] = {
      res = "notify_corps_add_active_info",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [581320958] = {
      req = "enter_room_battle_watch",
      res = "enter_room_battle_watch_rsp",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [657603972] = {
      req = "report_video",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [713467371] = {
      res = "cust_room_vs_team_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [788911215] = {
      res = "cust_room_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [894753136] = {
      res = "game_result_ob",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1112941182] = {
      res = "game_infection_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1388704130] = {
      req = "test_gameresult_req",
      res = "test_gameresult_res",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1443087199] = {
      res = "pcob_weaponinfo_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1531385608] = {
      req = "upvote_req",
      res = "upvote_res",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1685795158] = {
      req = "report_player_battle_score",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1803868240] = {
      res = "game_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1869691247] = {
      res = "game_vehicle_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [1914290407] = {
      req = "get_battle_pspace_gift_record_req",
      res = "get_battle_pspace_gift_record_rsp",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [2076459873] = {
      req = "report_battle_feedback",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [2139092302] = {
      res = "game_vs_team_result",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [2146442154] = {
      req = "report_win_dance_req",
      inGameOper = 0,
      handler = "BattleResultHandler"
    },
    [180170259] = {
      req = "batch_get_team_info_req",
      res = "batch_get_team_info_rsp",
      handler = "BestPartnerHandler"
    },
    [234838895] = {
      req = "receive_invite_for_activity_req",
      res = "receive_invite_for_activity_rsp",
      handler = "BestPartnerHandler"
    },
    [327402615] = {
      res = "notify_activity_team_invite_invited",
      handler = "BestPartnerHandler"
    },
    [1070177255] = {
      req = "invite_team_for_activity_req",
      res = "invite_team_for_activity_rsp",
      handler = "BestPartnerHandler"
    },
    [1080157287] = {
      req = "bat_invite_team_for_activity_req",
      res = "bat_invite_team_for_activity_rsp",
      handler = "BestPartnerHandler"
    },
    [1273260937] = {
      res = "update_beinvite_list",
      handler = "BestPartnerHandler"
    },
    [1585599228] = {
      res = "notify_activity_teams",
      handler = "BestPartnerHandler"
    },
    [1589138266] = {
      res = "update_invite_list",
      handler = "BestPartnerHandler"
    },
    [584652355] = {
      req = "receive_birthday_gift_req",
      res = "receive_birthday_gift_rsp",
      inGameOper = 0,
      handler = "BirthDayHandler"
    },
    [1079281901] = {
      res = "notify_player_birthday",
      inGameOper = 0,
      handler = "BirthDayHandler"
    },
    [1367229947] = {
      req = "get_birthday_group_page_req",
      res = "get_birthday_group_page_rsp",
      handler = "BirthDayHandler"
    },
    [43231143] = {
      req = "black_friday_invite_rp_group_req",
      res = "black_friday_invite_rp_group_rsp",
      handler = "BlackFridayHandler"
    },
    [139722923] = {
      req = "get_black_friday_active_item_info_req",
      res = "get_black_friday_active_item_info_rsp",
      handler = "BlackFridayHandler"
    },
    [174315773] = {
      req = "black_friday_get_pass_score_reward_req",
      res = "black_friday_get_score_reward_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [195113319] = {
      req = "get_black_friday_activity_list_req",
      res = "get_black_friday_activity_list_rsp",
      handler = "BlackFridayHandler"
    },
    [253315832] = {
      res = "black_friday_rp_group_notify",
      handler = "BlackFridayHandler"
    },
    [364240963] = {
      req = "buy_black_friday_group_item_req",
      res = "buy_black_friday_group_item_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [373080231] = {
      req = "black_friday_create_rp_group_req",
      res = "black_friday_create_rp_group_rsp",
      handler = "BlackFridayHandler"
    },
    [529200295] = {
      req = "get_black_friday_discount_reward_req",
      res = "get_black_friday_discount_reward_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [664383291] = {
      req = "black_friday_get_rp_group_send_invitation_req",
      res = "black_friday_get_rp_group_send_invitation_rsp",
      handler = "BlackFridayHandler"
    },
    [760517207] = {
      req = "black_friday_rp_group_delete_member_req",
      res = "black_friday_rp_group_delete_member_rsp",
      handler = "BlackFridayHandler"
    },
    [825589499] = {
      req = "get_black_friday_group_buy_info_req",
      res = "get_black_friday_group_buy_info_rsp",
      handler = "BlackFridayHandler"
    },
    [829124262] = {
      res = "week_signup_cfg_notify",
      handler = "BlackFridayHandler"
    },
    [922669095] = {
      req = "buy_black_friday_active_item_req",
      res = "buy_black_friday_active_item_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [954329447] = {
      req = "get_black_friday_discount_list_req",
      res = "get_black_friday_discount_list_rsp",
      handler = "BlackFridayHandler"
    },
    [1017090407] = {
      req = "get_black_friday_early_bird_item_req",
      res = "get_black_friday_early_bird_item_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [1019868384] = {
      res = "black_friday_group_buy_global_notify",
      handler = "BlackFridayHandler"
    },
    [1120385080] = {
      res = "week_signup_info_notify",
      handler = "BlackFridayHandler"
    },
    [1200231911] = {
      req = "black_friday_onekey_send_rp_group_invitation_req",
      res = "black_friday_onekey_send_rp_group_invitation_rsp",
      handler = "BlackFridayHandler"
    },
    [1246927775] = {
      req = "black_friday_get_rp_discount_buy_info_req",
      res = "black_friday_get_rp_discount_buy_info_rsp",
      handler = "BlackFridayHandler"
    },
    [1272765607] = {
      req = "black_friday_get_pass_info_req",
      res = "black_friday_get_pass_info_rsp",
      handler = "BlackFridayHandler"
    },
    [1289118951] = {
      req = "black_friday_join_rp_group_req",
      res = "black_friday_join_rp_group_rsp",
      timeInterval = 1,
      handler = "BlackFridayHandler"
    },
    [1412663335] = {
      req = "black_friday_get_rp_group_reward_req",
      res = "black_friday_get_rp_group_reward_rsp",
      isLock = 1,
      timeInterval = 0.5,
      handler = "BlackFridayHandler"
    },
    [1426322247] = {
      req = "black_friday_vote_exchange_req",
      res = "black_friday_vote_exchange_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [1431606791] = {
      req = "buy_black_friday_active_item_score_req",
      res = "buy_black_friday_active_item_score_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [1472174087] = {
      req = "black_friday_get_rp_promotion_info_req",
      res = "black_friday_get_rp_promotion_info_rsp",
      handler = "BlackFridayHandler"
    },
    [1527679679] = {
      req = "black_friday_get_rp_group_received_invitation_req",
      res = "black_friday_get_rp_group_received_invitation_rsp",
      handler = "BlackFridayHandler"
    },
    [1635316935] = {
      req = "black_friday_send_rp_group_invitation_req",
      res = "black_friday_send_rp_group_invitation_rsp",
      handler = "BlackFridayHandler"
    },
    [1703047551] = {
      req = "black_friday_open_custom_weapon_req",
      res = "black_friday_open_custom_weapon_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [1810994839] = {
      req = "black_friday_buy_rp_discount_item_req",
      res = "black_friday_buy_rp_discount_item_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [2035133095] = {
      req = "buy_friday_discount_item_req",
      res = "buy_friday_discount_item_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [2039374247] = {
      req = "get_black_friday_goods_req",
      res = "get_black_friday_goods_rsp",
      handler = "BlackFridayHandler"
    },
    [2105666827] = {
      req = "commit_black_friday_goods_req",
      res = "commit_black_friday_goods_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [2115073175] = {
      req = "black_friday_get_pass_extra_chest_req",
      res = "black_friday_get_pass_extra_chest_rsp",
      isLock = 1,
      handler = "BlackFridayHandler"
    },
    [405498343] = {
      req = "black_friday_prime_friend_list_req",
      res = "black_friday_prime_friend_list_rsp",
      handler = "BlackFridaySubHandler"
    },
    [412955907] = {
      req = "black_friday_prime_create_group_req",
      res = "black_friday_prime_create_group_rsp",
      isLock = 1,
      handler = "BlackFridaySubHandler"
    },
    [614022479] = {
      req = "black_friday_prime_promotion_invitation_req",
      res = "black_friday_prime_promotion_invitation_rsp",
      handler = "BlackFridaySubHandler"
    },
    [677873575] = {
      req = "black_friday_prime_take_group_reward_req",
      res = "black_friday_prime_take_group_reward_rsp",
      isLock = 1,
      handler = "BlackFridaySubHandler"
    },
    [846181739] = {
      req = "black_friday_prime_promotion_info_req",
      res = "black_friday_prime_promotion_info_rsp",
      handler = "BlackFridaySubHandler"
    },
    [1197339271] = {
      req = "black_friday_prime_buy_req",
      res = "black_friday_prime_buy_rsp",
      handler = "BlackFridaySubHandler"
    },
    [1279806247] = {
      req = "black_friday_prime_get_relate_reward_req",
      res = "black_friday_prime_get_relate_reward_rsp",
      handler = "BlackFridaySubHandler"
    },
    [1584366055] = {
      req = "black_friday_send_prime_group_invitation_req",
      res = "black_friday_send_prime_group_invitation_rsp",
      handler = "BlackFridaySubHandler"
    },
    [1625151223] = {
      req = "black_friday_prime_take_relate_reward_req",
      res = "black_friday_prime_take_relate_reward_rsp",
      isLock = 1,
      handler = "BlackFridaySubHandler"
    },
    [1719396543] = {
      req = "black_friday_invite_all_friends_req",
      res = "black_friday_invite_all_friends_rsp",
      handler = "BlackFridaySubHandler"
    },
    [2005730087] = {
      req = "black_friday_prime_promotion_add_group_req",
      res = "black_friday_prime_promotion_add_group_rsp",
      handler = "BlackFridaySubHandler"
    },
    [2133066852] = {
      res = "black_friday_prime_current_group_info_notify",
      handler = "BlackFridaySubHandler"
    },
    [176353057] = {
      res = "bh_google_ad_ntf",
      handler = "BlueHoleAdvertisementHandler"
    },
    [737608803] = {
      req = "bh_google_weekly_ad_award_req",
      res = "bh_google_weekly_ad_award_rsp",
      handler = "BlueHoleAdvertisementHandler"
    },
    [1664206723] = {
      req = "get_bh_google_ad_info_req",
      res = "get_bh_google_ad_info_rsp",
      handler = "BlueHoleAdvertisementHandler"
    },
    [389812064] = {
      res = "cancle_auto_quiz_notify",
      handler = "BonusHandler"
    },
    [401699030] = {
      res = "quiz_finished_notify",
      handler = "BonusHandler"
    },
    [838758550] = {
      req = "report_bug_info",
      handler = "BugHandler"
    },
    [245319682] = {
      req = "tournament_ticket_price_req",
      res = "tournament_ticket_price_res",
      handler = "BuyTournamentTicketHandler"
    },
    [599623104] = {
      req = "buy_tournament_ticket_req",
      res = "buy_tournament_ticket_res",
      handler = "BuyTournamentTicketHandler"
    },
    [289677408] = {
      res = "ce_bind_openid_notify",
      handler = "CEHandler"
    },
    [648438780] = {
      res = "cdkey_verify",
      handler = "CEHandler"
    },
    [688734127] = {
      req = "active_by_cdkey_req",
      res = "active_by_cdkey_rsp",
      isLock = 1,
      handler = "CEHandler"
    },
    [995970495] = {
      req = "gen_cdkey_req",
      res = "gen_cdkey_rsp",
      handler = "CEHandler"
    },
    [1964258319] = {
      req = "ce_new_channel_bind_req",
      res = "ce_new_channel_bind_rsp",
      handler = "CEHandler"
    },
    [2019774696] = {
      res = "ce_bind_required_notify",
      handler = "CEHandler"
    },
    [1328069623] = {
      req = "set_action_card_version_req",
      res = "set_action_card_version_rsp",
      handler = "CardCollectionHandler"
    },
    [1433011777] = {
      req = "clear_be_gave_new_req",
      handler = "CardCollectionHandler"
    },
    [1707887231] = {
      req = "get_card_collect_data_req",
      res = "get_card_collect_data_rsp",
      inGameOper = 0,
      handler = "CardCollectionHandler"
    },
    [1812063748] = {
      res = "notify_card_collect_data",
      handler = "CardCollectionHandler"
    },
    [1899779055] = {
      req = "give_collect_card_req",
      res = "give_collect_card_rsp",
      handler = "CardCollectionHandler"
    },
    [1998945542] = {
      res = "notify_new_card_accept",
      handler = "CardCollectionHandler"
    },
    [2013076615] = {
      req = "set_show_card_req",
      res = "set_show_card_rsp",
      handler = "CardCollectionHandler"
    },
    [2107515751] = {
      req = "clear_card_new_req",
      res = "clear_card_new_rsp",
      handler = "CardCollectionHandler"
    },
    [46924519] = {
      req = "card_collect_compose_card_pack_req",
      res = "card_collect_compose_card_pack_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [120822247] = {
      req = "card_collect_query_season_data_req",
      res = "card_collect_query_season_data_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "CardCollectionSeasonHandler"
    },
    [143967583] = {
      req = "card_collect_share_exchange_req",
      res = "card_collect_share_exchange_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [354826535] = {
      req = "card_collect_cancel_exchange_req",
      res = "card_collect_cancel_exchange_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [541097031] = {
      req = "card_collect_deal_exchange_req",
      res = "card_collect_deal_exchange_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [545183156] = {
      res = "add_card_pack_result_notify",
      inGameOper = 0,
      handler = "CardCollectionSeasonHandler"
    },
    [671729191] = {
      req = "card_collect_send_bottle_req",
      res = "card_collect_send_bottle_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [682290855] = {
      req = "card_collect_batch_decompose_req",
      res = "card_collect_batch_decompose_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [743967207] = {
      req = "card_collect_get_score_award_req",
      res = "card_collect_get_score_award_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [748034499] = {
      req = "card_collect_gen_exchange_req",
      res = "card_collect_gen_exchange_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [781713191] = {
      req = "card_collect_get_exchange_list_req",
      res = "card_collect_get_exchange_list_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [789137615] = {
      req = "card_collect_get_bottle_req",
      res = "card_collect_get_bottle_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1005174055] = {
      req = "card_collect_get_collect_award_req",
      res = "card_collect_get_collect_award_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1023499047] = {
      req = "card_collect_claim_award_req",
      res = "card_collect_claim_award_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1059249831] = {
      req = "card_collect_query_series_data_req",
      res = "card_collect_query_series_data_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1072418243] = {
      req = "card_collect_set_show_series_id_req",
      res = "card_collect_set_show_series_id_rsp",
      inGameOper = 0,
      handler = "CardCollectionSeasonHandler"
    },
    [1102648679] = {
      req = "card_collect_query_finish_series_req",
      res = "card_collect_query_finish_series_rsp",
      inGameOper = 0,
      handler = "CardCollectionSeasonHandler"
    },
    [1180703531] = {
      req = "card_collect_batch_query_card_req",
      res = "card_collect_batch_query_card_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1217152199] = {
      req = "card_collect_set_show_order_req",
      res = "card_collect_set_show_order_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1273575015] = {
      req = "card_collect_query_show_info_req",
      res = "card_collect_query_show_info_rsp",
      inGameOper = 0,
      handler = "CardCollectionSeasonHandler"
    },
    [1322672712] = {
      res = "card_collect_season_finish_ntf",
      handler = "CardCollectionSeasonHandler"
    },
    [1389997275] = {
      req = "card_collect_query_summary_data_req",
      res = "card_collect_query_summary_data_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "CardCollectionSeasonHandler"
    },
    [1676289959] = {
      req = "card_collect_history_click_req",
      res = "card_collect_history_click_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1678756903] = {
      req = "card_collect_gift_card_req",
      res = "card_collect_gift_card_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [1834349428] = {
      res = "card_collect_series_finish_ntf",
      handler = "CardCollectionSeasonHandler"
    },
    [1966099495] = {
      req = "card_collect_get_newbie_card_req",
      res = "card_collect_get_newbie_card_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [2105441995] = {
      req = "card_collect_get_exchange_req",
      res = "card_collect_get_exchange_rsp",
      handler = "CardCollectionSeasonHandler"
    },
    [189268839] = {
      req = "career_clear_red_dot_req",
      res = "career_clear_red_dot_rsp",
      handler = "CareerHandler"
    },
    [227779135] = {
      req = "career_all_data_req",
      res = "career_all_data_rsp",
      handler = "CareerHandler"
    },
    [505245895] = {
      req = "career_is_open_req",
      res = "career_is_open_rsp",
      handler = "CareerHandler"
    },
    [506091367] = {
      req = "career_banner_get_data_req",
      res = "career_banner_get_data_rsp",
      handler = "CareerHandler"
    },
    [589644551] = {
      req = "career_banner_change_medal_req",
      res = "career_banner_change_medal_rsp",
      handler = "CareerHandler"
    },
    [719302791] = {
      req = "career_is_show_public_req",
      res = "career_is_show_public_rsp",
      handler = "CareerHandler"
    },
    [813132007] = {
      req = "career_set_show_public_req",
      res = "career_set_show_public_rsp",
      handler = "CareerHandler"
    },
    [1038937511] = {
      req = "career_others_data_req",
      res = "career_others_data_rsp",
      handler = "CareerHandler"
    },
    [1292052911] = {
      req = "career_banner_change_banner_req",
      res = "career_banner_change_banner_rsp",
      handler = "CareerHandler"
    },
    [1435457503] = {
      res = "career_change_notify",
      handler = "CareerHandler"
    },
    [1579613928] = {
      res = "career_banner_unlock_notify",
      handler = "CareerHandler"
    },
    [1720704063] = {
      req = "career_banner_clear_red_dot_req",
      res = "career_banner_clear_red_dot_rsp",
      handler = "CareerHandler"
    },
    [1713396748] = {
      req = "report_reject_charge",
      res = "report_reject_charge_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "CentauriHandler"
    },
    [1892549758] = {
      req = "imobile_notify_client_charge",
      handler = "CentauriHandler"
    },
    [138452727] = {
      req = "compete_team_invite_req",
      res = "compete_team_invite_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [165295079] = {
      req = "get_personal_pug_rank_req",
      res = "get_personal_pug_rank_rsp",
      inGameOper = 2,
      handler = "ChampionshipSponsorHandler"
    },
    [168700567] = {
      req = "compete_team_quit_req",
      res = "compete_team_quit_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [255305134] = {
      req = "get_pug_game_cfg_info",
      handler = "ChampionshipSponsorHandler"
    },
    [277800551] = {
      req = "get_pug_signup_cfg_req",
      res = "get_pug_signup_cfg_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [282248807] = {
      req = "get_one_pug_info_req",
      res = "get_one_pug_info_rsp",
      inGameOper = 2,
      handler = "ChampionshipSponsorHandler"
    },
    [498071243] = {
      res = "compete_team_invite_ntfy",
      handler = "ChampionshipSponsorHandler"
    },
    [655027111] = {
      req = "get_pug_info_req",
      res = "get_pug_info_rsp",
      inGameOper = 2,
      handler = "ChampionshipSponsorHandler"
    },
    [703944315] = {
      req = "compete_create_team_req",
      res = "compete_create_team_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [716573607] = {
      req = "get_pug_rank_req",
      res = "get_pug_rank_rsp",
      inGameOper = 2,
      handler = "ChampionshipSponsorHandler"
    },
    [899747020] = {
      res = "notify_pug_promote_info",
      handler = "ChampionshipSponsorHandler"
    },
    [901521358] = {
      res = "notify_update_team_member",
      handler = "ChampionshipSponsorHandler"
    },
    [972805703] = {
      req = "query_compete_team_req",
      res = "query_compete_team_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [1059439747] = {
      req = "compete_team_enroll_req",
      res = "compete_team_enroll_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [1268647271] = {
      req = "get_pug_teaminfo_req",
      res = "get_pug_teaminfo_rsp",
      inGameOper = 2,
      handler = "ChampionshipSponsorHandler"
    },
    [1301041543] = {
      req = "kickout_team_member_req",
      res = "kickout_team_member_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [1402323743] = {
      res = "notify_pug_white_list",
      inGameOper = 2,
      handler = "ChampionshipSponsorHandler"
    },
    [1598906736] = {
      res = "compete_team_join_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [1660349459] = {
      req = "get_my_gac_info_req",
      res = "get_my_gac_info_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [1708976571] = {
      req = "get_pug_system_info_req",
      res = "get_pug_system_info_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [1826310495] = {
      req = "report_pug_promote_tips_req",
      res = "report_pug_promote_tips_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [1878891675] = {
      req = "compete_team_invite_reply_req",
      res = "compete_team_invite_reply_rsp",
      handler = "ChampionshipSponsorHandler"
    },
    [961729447] = {
      req = "participate_pug_req",
      res = "participate_pug_rsp",
      timeInterval = 3,
      inGameOper = 2,
      handler = "ChampionshipTeamUpHandler"
    },
    [1282442599] = {
      res = "pug_team_enter",
      inGameOper = 2,
      handler = "ChampionshipTeamUpHandler"
    },
    [1518046851] = {
      req = "pug_match_req",
      res = "pug_match_rsp",
      inGameOper = 2,
      handler = "ChampionshipTeamUpHandler"
    },
    [1675267284] = {
      res = "notify_pugteam_member_group_status_chg",
      inGameOper = 2,
      handler = "ChampionshipTeamUpHandler"
    },
    [6009982] = {
      res = "notify_del_cycleroll_msgs",
      handler = "CharacterHandler"
    },
    [77804453] = {
      res = "update_user_avatar_url",
      handler = "CharacterHandler"
    },
    [79387875] = {
      req = "set_hunter_vs_hunted_clear_time_req",
      res = "set_hunter_vs_hunted_clear_time_rsp",
      handler = "CharacterHandler"
    },
    [177603748] = {
      req = "modify_role_privacy",
      res = "modify_role_privacy_rsp",
      handler = "CharacterHandler"
    },
    [291552115] = {
      req = "clear_hunter_vs_hunted_history_record_req",
      res = "clear_hunter_vs_hunted_history_record_rsp",
      handler = "CharacterHandler"
    },
    [340367301] = {
      res = "hunter_vs_hunted_result",
      handler = "CharacterHandler"
    },
    [446953383] = {
      req = "get_friendly_points_data_req",
      res = "get_friendly_points_data_rsp",
      handler = "CharacterHandler"
    },
    [492043873] = {
      res = "notify_first_history_record",
      handler = "CharacterHandler"
    },
    [510203909] = {
      req = "click_alias_batch_report",
      handler = "CharacterHandler"
    },
    [546230311] = {
      req = "get_show_alias_req",
      res = "get_show_alias_rsp",
      handler = "CharacterHandler"
    },
    [688346654] = {
      res = "room_recruit_rsp",
      handler = "CharacterHandler"
    },
    [693785255] = {
      req = "set_show_alias_req",
      res = "set_show_alias_rsp",
      handler = "CharacterHandler"
    },
    [839255709] = {
      res = "notify_unlock_new_avatar",
      handler = "CharacterHandler"
    },
    [879185723] = {
      req = "set_is_show_enter_broadcast_req",
      res = "set_is_show_enter_broadcast_rsp",
      handler = "CharacterHandler"
    },
    [1067381139] = {
      req = "get_hunter_vs_hunted_clear_time_req",
      res = "get_hunter_vs_hunted_clear_time_rsp",
      handler = "CharacterHandler"
    },
    [1105161186] = {
      req = "get_alias_list",
      res = "alias_list_res",
      handler = "CharacterHandler"
    },
    [1200785583] = {
      req = "get_unlock_progress_req",
      res = "get_unlock_progress_rsp",
      isLock = 1,
      handler = "CharacterHandler"
    },
    [1230921831] = {
      req = "get_peakgame_history_summary_req",
      res = "get_peakgame_history_summary_rsp",
      handler = "CharacterHandler"
    },
    [1244580047] = {
      res = "character_update_hairid",
      inGameOper = 0,
      handler = "CharacterHandler"
    },
    [1323568327] = {
      req = "character_info_req",
      res = "character_info_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "CharacterHandler"
    },
    [1540769991] = {
      req = "batch_get_peakgame_history_req",
      res = "batch_get_peakgame_history_rsp",
      handler = "CharacterHandler"
    },
    [1560193412] = {
      req = "change_avatar_box",
      res = "change_avatar_box_rsp",
      isLock = 1,
      handler = "CharacterHandler"
    },
    [1572287037] = {
      res = "get_new_avatar_box_notify",
      handler = "CharacterHandler"
    },
    [1623137540] = {
      res = "notify_add_alias",
      handler = "CharacterHandler"
    },
    [1723553215] = {
      req = "get_show_weapon_alias_req",
      res = "get_weapon_show_alias_rsp",
      handler = "CharacterHandler"
    },
    [1779363404] = {
      req = "change_user_avatar",
      res = "change_user_avatar_rsp",
      isLock = 1,
      handler = "CharacterHandler"
    },
    [1795220455] = {
      req = "change_alias_req",
      res = "change_alias_rsp",
      handler = "CharacterHandler"
    },
    [1812981382] = {
      req = "bath_get_history_record",
      res = "bath_get_history_record_rsp",
      inGameOper = 0,
      handler = "CharacterHandler"
    },
    [2011674892] = {
      req = "get_history_record_summary",
      res = "get_history_record_summary_rsp",
      handler = "CharacterHandler"
    },
    [2121269011] = {
      req = "set_show_weapon_alias_req",
      res = "set_show_weapon_alias_rsp",
      handler = "CharacterHandler"
    },
    [1030622439] = {
      req = "club_subscribe_req",
      res = "club_subscribe_rsp",
      handler = "ChatClubHandler"
    },
    [1564311815] = {
      req = "do_op_club_req",
      res = "do_op_club_rsp",
      handler = "ChatClubHandler"
    },
    [1918177543] = {
      res = "notify_user_club_list",
      handler = "ChatClubHandler"
    },
    [2089462695] = {
      req = "club_list_req",
      res = "club_list_rsp",
      handler = "ChatClubHandler"
    },
    [2122671207] = {
      req = "sync_auth_ticket_req",
      res = "sync_auth_ticket_rsp",
      handler = "ChatClubHandler"
    },
    [46715584] = {
      res = "chat_notify",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [95962645] = {
      res = "chat_merge_notify",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [114745291] = {
      req = "topic_fetch_lang_list_req",
      res = "topic_fetch_lang_list_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [228783202] = {
      res = "metro_chat_shield_expired_ntfy",
      handler = "ChatHandler"
    },
    [262889379] = {
      req = "open_world_and_team_recruit_req",
      res = "open_world_and_team_recruit_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [394493459] = {
      req = "daily_poke_list_req",
      res = "daily_poke_list_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [398701877] = {
      req = "chat_tog_report_req",
      handler = "ChatHandler"
    },
    [410222403] = {
      req = "filter_text_req",
      res = "filter_text_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [456765867] = {
      req = "get_interact_score_reward_req",
      res = "get_interact_score_reward_rsp",
      handler = "ChatHandler"
    },
    [523590044] = {
      req = "report_info",
      res = "report_info",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [622042252] = {
      req = "report_info_mic",
      res = "report_info_mic",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [837066931] = {
      req = "get_interact_info_req",
      res = "get_interact_info_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [850674375] = {
      req = "get_frd_interact_info_req",
      res = "get_frd_interact_info_rsp",
      handler = "ChatHandler"
    },
    [861164787] = {
      req = "topic_subscribe_req",
      res = "topic_subscribe_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [878657371] = {
      req = "topic_flat_list_req",
      res = "topic_flat_list_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [889104076] = {
      req = "open_chat_ui",
      res = "open_chat_ui_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1004987879] = {
      req = "chat_translate_req",
      res = "chat_translate_rsp",
      handler = "ChatHandler"
    },
    [1128809271] = {
      req = "search_team_recruit_req",
      res = "search_team_recruit_rsp",
      handler = "ChatHandler"
    },
    [1133008551] = {
      req = "get_all_offmsg_req",
      res = "get_all_offmsg_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1201228654] = {
      req = "social_voice_audit_callback",
      handler = "ChatHandler"
    },
    [1271970727] = {
      req = "get_offline_chat_msg_req",
      res = "get_offline_chat_msg_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1336167673] = {
      res = "interact_key_event_notify",
      handler = "ChatHandler"
    },
    [1344172647] = {
      req = "set_player_recruit_langs_req",
      res = "set_player_recruit_langs_rsp",
      handler = "ChatHandler"
    },
    [1345216445] = {
      req = "ReportHawkeyeBanFlow",
      handler = "ChatHandler"
    },
    [1367583975] = {
      req = "no_fri_poke_list_req",
      res = "no_fri_poke_list_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1411111260] = {
      res = "chat_clear_msg",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1477285570] = {
      req = "report_translate_ping",
      handler = "ChatHandler"
    },
    [1499415138] = {
      req = "arabic_switch_channel_report",
      handler = "ChatHandler"
    },
    [1534226459] = {
      req = "subscribe_world_cup_req",
      res = "subscribe_world_cup_rsp",
      handler = "ChatHandler"
    },
    [1683847787] = {
      req = "share_pre_filter_text_req",
      res = "share_pre_filter_text_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1735709991] = {
      req = "chat_req",
      res = "chat_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1746708531] = {
      req = "get_chat_manor_list_req",
      res = "get_chat_manor_list_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1753800026] = {
      req = "report_player_voice_status_in_team",
      handler = "ChatHandler"
    },
    [1765595559] = {
      res = "metro_chat_shield_expired_list_ntfy",
      handler = "ChatHandler"
    },
    [1802516967] = {
      req = "chat_translate_with_filter_req",
      res = "chat_translate_with_filter_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1915097504] = {
      req = "leave_world_cup_act_page",
      handler = "ChatHandler"
    },
    [1946301623] = {
      req = "topic_unsubscribe_req",
      res = "topic_unsubscribe_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [1964083284] = {
      res = "topic_send_at_notify",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [2067855355] = {
      req = "poke_friend_req",
      res = "poke_friend_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [2117014375] = {
      req = "get_offline_chat_msg_count_req",
      res = "get_offline_chat_msg_count_rsp",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [2146609010] = {
      res = "frd_poke_notify",
      inGameOper = 0,
      handler = "ChatHandler"
    },
    [193216163] = {
      req = "get_corp_redpacket_list_req",
      res = "get_corp_redpacket_list_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ChatRedpacketHandler"
    },
    [564062919] = {
      req = "query_redpacket_record_req",
      res = "query_redpacket_record_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ChatRedpacketHandler"
    },
    [645194343] = {
      req = "today_redpacket_info_req",
      res = "today_redpacket_info_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ChatRedpacketHandler"
    },
    [783864135] = {
      req = "send_redpacket_req",
      res = "send_redpacket_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ChatRedpacketHandler"
    },
    [1915514411] = {
      req = "get_pspace_redpacket_list_req",
      res = "get_pspace_redpacket_list_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ChatRedpacketHandler"
    },
    [2009073503] = {
      req = "receive_redpacket_req",
      res = "receive_redpacket_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ChatRedpacketHandler"
    },
    [2027410323] = {
      req = "get_person_redpacket_record_req",
      res = "get_person_redpacket_record_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "ChatRedpacketHandler"
    },
    [220340775] = {
      req = "set_chat_background_new_flag_req",
      res = "set_chat_background_new_flag_rsp",
      handler = "ChatRoomBGHandler"
    },
    [558707379] = {
      req = "get_chat_background_req",
      res = "get_chat_background_rsp",
      handler = "ChatRoomBGHandler"
    },
    [776649005] = {
      res = "notify_chat_background_update",
      handler = "ChatRoomBGHandler"
    },
    [1462789251] = {
      req = "set_chat_background_req",
      res = "set_chat_background_rsp",
      handler = "ChatRoomBGHandler"
    },
    [183853818] = {
      res = "dismiss_channel_notify",
      handler = "ChatRoomHandler"
    },
    [222391975] = {
      req = "channel_apply_open_voice_req",
      res = "channel_apply_open_voice_rsp",
      inGameOper = 0,
      handler = "ChatRoomHandler"
    },
    [226418543] = {
      req = "channel_invite_open_voice_req",
      res = "channel_invite_open_voice_rsp",
      handler = "ChatRoomHandler"
    },
    [234158884] = {
      res = "channel_inner_op_notify",
      handler = "ChatRoomHandler"
    },
    [457293031] = {
      req = "cancel_collect_channel_req",
      res = "cancel_collect_channel_rsp",
      handler = "ChatRoomHandler"
    },
    [518371879] = {
      req = "get_chat_question_stat_req",
      res = "get_chat_question_stat_rsp",
      handler = "ChatRoomHandler"
    },
    [640711946] = {
      res = "channel_merge_notify",
      handler = "ChatRoomHandler"
    },
    [651584711] = {
      req = "chat_question_vote_req",
      res = "chat_question_vote_rsp",
      handler = "ChatRoomHandler"
    },
    [688544427] = {
      req = "channel_recommend_req",
      res = "channel_recommend_rsp",
      handler = "ChatRoomHandler"
    },
    [705156647] = {
      req = "channel_kick_out_req",
      res = "channel_kick_out_rsp",
      handler = "ChatRoomHandler"
    },
    [778036775] = {
      req = "channel_set_question_req",
      res = "channel_set_question_rsp",
      handler = "ChatRoomHandler"
    },
    [818382151] = {
      req = "create_channel_req",
      res = "create_channel_rsp",
      handler = "ChatRoomHandler"
    },
    [863896863] = {
      req = "channel_close_voice_req",
      res = "channel_close_voice_rsp",
      inGameOper = 0,
      handler = "ChatRoomHandler"
    },
    [943642167] = {
      req = "channel_force_close_voice_req",
      res = "channel_force_close_voice_rsp",
      handler = "ChatRoomHandler"
    },
    [1264552871] = {
      req = "set_chat_channel_status_switch_req",
      res = "set_chat_channel_status_switch_rsp",
      handler = "ChatRoomHandler"
    },
    [1293075367] = {
      req = "join_channel_req",
      res = "join_channel_rsp",
      handler = "ChatRoomHandler"
    },
    [1490878023] = {
      req = "change_channel_req",
      res = "change_channel_rsp",
      inGameOper = 0,
      handler = "ChatRoomHandler"
    },
    [1559488679] = {
      req = "delete_channel_req",
      res = "delete_channel_rsp",
      handler = "ChatRoomHandler"
    },
    [1629649255] = {
      req = "exit_channel_req",
      res = "exit_channel_rsp",
      handler = "ChatRoomHandler"
    },
    [1640275486] = {
      res = "notify_update_channel_member_state",
      handler = "ChatRoomHandler"
    },
    [1737077063] = {
      req = "channel_deal_open_voice_apply_req",
      res = "channel_deal_open_voice_apply_rsp",
      handler = "ChatRoomHandler"
    },
    [1771275495] = {
      req = "get_channel_list_req",
      res = "get_channel_list_rsp",
      handler = "ChatRoomHandler"
    },
    [1780487847] = {
      req = "get_all_chat_question_vote_count_req",
      res = "get_all_chat_question_vote_count_rsp",
      handler = "ChatRoomHandler"
    },
    [1844287891] = {
      req = "channel_invite_open_voice_reply_req",
      res = "channel_invite_open_voice_reply_rsp",
      handler = "ChatRoomHandler"
    },
    [1868882787] = {
      req = "collect_channel_req",
      res = "collect_channel_rsp",
      handler = "ChatRoomHandler"
    },
    [2039973159] = {
      req = "channel_get_open_voice_apply_req",
      res = "channel_get_open_voice_apply_rsp",
      handler = "ChatRoomHandler"
    },
    [670670447] = {
      req = "join_voice_room_req",
      res = "join_voice_room_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "ChatVoiceHandler"
    },
    [1047390855] = {
      req = "exit_voice_room_req",
      res = "exit_voice_room_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "ChatVoiceHandler"
    },
    [1436509919] = {
      req = "report_voice_room_state_req",
      res = "report_voice_room_state_rsp",
      inGameOper = 0,
      handler = "ChatVoiceHandler"
    },
    [1966970169] = {
      res = "voice_room_merge_notify",
      inGameOper = 0,
      handler = "ChatVoiceHandler"
    },
    [1208159811] = {
      req = "report_change_client_frame",
      handler = "ClientEVOConfigHandler"
    },
    [346290403] = {
      res = "on_send_client_data",
      inGameOper = 0,
      handler = "ClientEntryHandler"
    },
    [347409151] = {
      req = "report_unrealnet_exception",
      handler = "ClientEntryHandler"
    },
    [359597473] = {
      res = "please_relogin",
      inGameOper = 0,
      handler = "ClientEntryHandler"
    },
    [932092249] = {
      req = "report_player_bind_info",
      handler = "ClientEntryHandler"
    },
    [1067754569] = {
      res = "sync_time",
      inGameOper = 0,
      handler = "ClientEntryHandler"
    },
    [1178215802] = {
      res = "game_unusual_end",
      inGameOper = 0,
      handler = "ClientEntryHandler"
    },
    [1597155612] = {
      req = "refresh_wx_atk",
      handler = "ClientEntryHandler"
    },
    [1846350206] = {
      req = "giveup_enter_game",
      handler = "ClientEntryHandler"
    },
    [1999351726] = {
      req = "report_unrealnet_event",
      handler = "ClientEntryHandler"
    },
    [224943158] = {
      req = "client_tools_batch_report_req",
      timeInterval = 5,
      handler = "ClientErrorReportHandler"
    },
    [310752652] = {
      req = "report_lobby_common_tlog",
      handler = "ClientTlogHandler"
    },
    [794770567] = {
      req = "set_taluo_change_wear_info_req",
      res = "set_taluo_change_wear_info_rsp",
      handler = "ClothFusionHandler"
    },
    [1539441159] = {
      req = "get_taluo_change_wear_info_req",
      res = "get_taluo_change_wear_info_rsp",
      handler = "ClothFusionHandler"
    },
    [1586989244] = {
      res = "taluo_change_wear_info_ntf",
      handler = "ClothFusionHandler"
    },
    [71387815] = {
      req = "build_inherit_relation_op_req",
      res = "build_inherit_relation_op_rsp",
      handler = "CollectHandler"
    },
    [272454958] = {
      req = "report_collect_detail_tlog",
      isLock = 1,
      needRsp = 999,
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [297205283] = {
      res = "notify_collect_sys_data",
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [371367955] = {
      req = "get_collect_sys_main_data_req",
      res = "get_collect_sys_main_data_rsp",
      isUnique = 1,
      needRsp = 999,
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [379168064] = {
      res = "del_inherit_relation_notify",
      handler = "CollectHandler"
    },
    [665949741] = {
      res = "build_inherit_relation_notify",
      handler = "CollectHandler"
    },
    [804358059] = {
      req = "get_collect_sys_privacy_req",
      res = "get_collect_sys_privacy_rsp",
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [873633767] = {
      req = "get_collect_award_privilege_req",
      res = "get_collect_award_privilege_rsp",
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [897033405] = {
      res = "notify_collect_privilege_data",
      handler = "CollectHandler"
    },
    [1027105141] = {
      res = "build_inherit_relation_op_notify",
      handler = "CollectHandler"
    },
    [1121297703] = {
      req = "get_collect_detail_req",
      res = "get_collect_detail_rsp",
      isLock = 1,
      needRsp = 999,
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [1164988723] = {
      req = "set_elimination_king_effect_req",
      res = "set_elimination_king_effect_rsp",
      handler = "CollectHandler"
    },
    [1434691367] = {
      req = "get_inherit_relation_req",
      res = "get_inherit_relation_rsp",
      handler = "CollectHandler"
    },
    [1532097831] = {
      req = "del_inherit_relation_req",
      res = "del_inherit_relation_rsp",
      handler = "CollectHandler"
    },
    [1551383643] = {
      req = "set_collect_sys_privacy_req",
      res = "set_collect_sys_privacy_rsp",
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [1666426860] = {
      res = "notify_collect_score_change",
      inGameOper = 2,
      handler = "CollectHandler"
    },
    [1885336543] = {
      req = "set_collect_privilege_req",
      res = "set_collect_privilege_rsp",
      inGameOper = 0,
      handler = "CollectHandler"
    },
    [2032147175] = {
      req = "build_inherit_relation_req",
      res = "build_inherit_relation_rsp",
      handler = "CollectHandler"
    },
    [2576163] = {
      req = "set_collect_hall_common_equipment_req",
      res = "set_collect_hall_common_equipment_rsp",
      inGameOper = 0,
      handler = "CollectionHallEditHandler"
    },
    [830069423] = {
      req = "edit_collect_hall_req",
      res = "edit_collect_hall_rsp",
      inGameOper = 0,
      handler = "CollectionHallEditHandler"
    },
    [1282860615] = {
      req = "reset_all_collect_hall_req",
      res = "reset_all_collect_hall_rsp",
      inGameOper = 0,
      handler = "CollectionHallEditHandler"
    },
    [1466187943] = {
      req = "change_collect_hall_skin_req",
      res = "change_collect_hall_skin_rsp",
      inGameOper = 0,
      handler = "CollectionHallEditHandler"
    },
    [1761587015] = {
      req = "reset_collect_hall_req",
      res = "reset_collect_hall_rsp",
      inGameOper = 0,
      handler = "CollectionHallEditHandler"
    },
    [2007569447] = {
      req = "edit_all_collect_hall_req",
      res = "edit_all_collect_hall_rsp",
      inGameOper = 0,
      handler = "CollectionHallEditHandler"
    },
    [1030846611] = {
      res = "notify_enter_collect_hall_failed",
      inGameOper = 0,
      handler = "CollectionHallLoadingHandler"
    },
    [1429909191] = {
      req = "visit_collect_hall_req",
      res = "visit_collect_hall_rsp",
      inGameOper = 0,
      handler = "CollectionHallVisitHandler"
    },
    [1976419367] = {
      req = "custom_chest_get_items_req",
      res = "custom_chest_get_items_rsp",
      handler = "CommonChestModeHandler"
    },
    [1639184711] = {
      req = "get_growup_common_data_req",
      res = "get_growup_common_data_rsp",
      handler = "CommonDataHandler"
    },
    [875178304] = {
      res = "hybrid_chest_ext_rsp",
      handler = "CommonItemGetHandler"
    },
    [913955367] = {
      req = "get_mod_task_award_req",
      res = "get_mod_task_award_rsp",
      handler = "CommonTaskHandler"
    },
    [1009363751] = {
      req = "get_mod_task_cfg_req",
      res = "get_mod_task_cfg_rsp",
      handler = "CommonTaskHandler"
    },
    [1325424022] = {
      res = "all_mod_task_notify",
      handler = "CommonTaskHandler"
    },
    [1459652118] = {
      res = "mod_all_task_notify",
      handler = "CommonTaskHandler"
    },
    [1925566887] = {
      req = "get_mod_task_req",
      res = "get_mod_task_rsp",
      handler = "CommonTaskHandler"
    },
    [104705270] = {
      req = "shequn_clear_reddot_req",
      isUnique = 1,
      queueType = 1,
      handler = "CommunityHandler"
    },
    [366456209] = {
      res = "notify_clubs_game_start",
      handler = "CommunityHandler"
    },
    [393229770] = {
      res = "idip_notify_reddot_info",
      handler = "CommunityHandler"
    },
    [569888633] = {
      res = "update_svip_user_info",
      handler = "CommunityHandler"
    },
    [1469325853] = {
      req = "jump_to_club",
      handler = "CommunityHandler"
    },
    [1642755237] = {
      res = "update_rich_user_info",
      handler = "CommunityHandler"
    },
    [1792321387] = {
      res = "notify_user_subscribe_game",
      handler = "CommunityHandler"
    },
    [109215127] = {
      req = "unlock_cond_page_by_group_req",
      res = "unlock_cond_page_by_group_rsp",
      isLock = 1,
      timeout = 5,
      handler = "ConditionGiftHandler"
    },
    [697384539] = {
      req = "get_cond_page_active_days_req",
      res = "get_cond_page_active_days_rsp",
      handler = "ConditionGiftHandler"
    },
    [1162609637] = {
      res = "notify_cond_page_unlock_success",
      handler = "ConditionGiftHandler"
    },
    [1531097949] = {
      res = "notify_active_days_change",
      handler = "ConditionGiftHandler"
    },
    [341766624] = {
      res = "team_conscribe_sync",
      handler = "ConscribeHandler"
    },
    [516535063] = {
      req = "voice_feedback_report_req",
      res = "voice_feedback_report_rsp",
      inGameOper = 0,
      handler = "ConscribeHandler"
    },
    [637400706] = {
      res = "voice_feedback_notify",
      inGameOper = 0,
      handler = "ConscribeHandler"
    },
    [697296992] = {
      req = "quick_join_team_conscribe_req",
      res = "quick_join_team_conscribe_res",
      handler = "ConscribeHandler"
    },
    [713077256] = {
      req = "search_idle_player_req",
      res = "search_idle_player_res",
      handler = "ConscribeHandler"
    },
    [996502688] = {
      req = "get_team_conscribe_entry_status_req",
      res = "get_team_conscribe_entry_status_res",
      handler = "ConscribeHandler"
    },
    [997178144] = {
      req = "cancel_team_conscribe_req",
      res = "cancel_team_conscribe_res",
      handler = "ConscribeHandler"
    },
    [1161472384] = {
      req = "batch_get_team_conscribes_req",
      res = "batch_get_team_conscribes_res",
      handler = "ConscribeHandler"
    },
    [1321300744] = {
      req = "unregister_idle_player_req",
      res = "unregister_idle_player_res",
      inGameOper = 0,
      handler = "ConscribeHandler"
    },
    [1556741250] = {
      res = "voice_feedback_update_notify",
      inGameOper = 0,
      handler = "ConscribeHandler"
    },
    [1583769344] = {
      req = "team_conscribe_info_req",
      handler = "ConscribeHandler"
    },
    [1589435080] = {
      req = "register_idle_player_req",
      res = "register_idle_player_res",
      inGameOper = 0,
      handler = "ConscribeHandler"
    },
    [1606367143] = {
      req = "broadcast_team_conscribe_req",
      res = "broadcast_team_conscribe_rsp",
      queueType = 1,
      handler = "ConscribeHandler"
    },
    [1815455760] = {
      req = "search_team_conscribe_req",
      res = "search_team_conscribe_res",
      handler = "ConscribeHandler"
    },
    [2098039431] = {
      req = "voice_feedback_req",
      res = "voice_feedback_rsp",
      inGameOper = 0,
      handler = "ConscribeHandler"
    },
    [2118431400] = {
      req = "publish_team_conscribe_req",
      res = "publish_team_conscribe_res",
      handler = "ConscribeHandler"
    },
    [50548135] = {
      req = "corps_do_exchange_coin_req",
      res = "corps_do_exchange_coin_rsp",
      handler = "CorpsGiftExchangeHandler"
    },
    [249088975] = {
      req = "commit_corps_exchange_req",
      res = "commit_corps_exchange_rsp",
      handler = "CorpsGiftExchangeHandler"
    },
    [451417718] = {
      req = "corps_exchange_success_tips_op",
      handler = "CorpsGiftExchangeHandler"
    },
    [554744039] = {
      req = "corps_exchange_personal_list_req",
      res = "corps_exchange_personal_list_rsp",
      handler = "CorpsGiftExchangeHandler"
    },
    [714667019] = {
      req = "get_corps_invitee_list_req",
      handler = "CorpsGiftExchangeHandler"
    },
    [873133763] = {
      req = "create_corps_exchange_req",
      res = "create_corps_exchange_rsp",
      handler = "CorpsGiftExchangeHandler"
    },
    [884638591] = {
      req = "delete_corps_exchange_req",
      res = "delete_corps_exchange_rsp",
      handler = "CorpsGiftExchangeHandler"
    },
    [1153964079] = {
      res = "commit_corps_exchange_notify",
      handler = "CorpsGiftExchangeHandler"
    },
    [1875541603] = {
      req = "corps_exchange_market_req",
      res = "corps_exchange_market_rsp",
      handler = "CorpsGiftExchangeHandler"
    },
    [1908186848] = {
      res = "corps_exchange_item_return_notify",
      handler = "CorpsGiftExchangeHandler"
    },
    [1931587583] = {
      req = "get_corps_exchange_data_req",
      res = "get_corps_exchange_data_rsp",
      timeInterval = 3,
      handler = "CorpsGiftExchangeHandler"
    },
    [1966539623] = {
      req = "corps_do_exchange_item_req",
      res = "corps_do_exchange_item_rsp",
      handler = "CorpsGiftExchangeHandler"
    },
    [100362114] = {
      req = "get_corps_shopitem_limitbuy_req",
      res = "get_corps_shopitem_limitbuy_res",
      handler = "CorpsHandler"
    },
    [147977143] = {
      req = "corps_members_req",
      res = "corps_members_rsp",
      handler = "CorpsHandler"
    },
    [156516647] = {
      req = "get_corps_group_relation_req",
      res = "get_corps_group_relation_rsp",
      handler = "CorpsHandler"
    },
    [195208295] = {
      req = "get_is_low_corps_req",
      res = "get_is_low_corps_rsp",
      handler = "CorpsHandler"
    },
    [210136911] = {
      res = "notify_member_share_ticket_respond",
      handler = "CorpsHandler"
    },
    [213059768] = {
      res = "notify_someone_apply_join",
      handler = "CorpsHandler"
    },
    [227996424] = {
      req = "corps_training_award_req",
      res = "corps_training_award_res",
      handler = "CorpsHandler"
    },
    [294810988] = {
      req = "query_corps_rank_award",
      res = "query_corps_rank_award_rsp",
      handler = "CorpsHandler"
    },
    [302754662] = {
      res = "sync_goal_task_status",
      handler = "CorpsHandler"
    },
    [310590883] = {
      res = "sync_corps_invitee_list",
      handler = "CorpsHandler"
    },
    [322518247] = {
      req = "set_corps_star_req",
      res = "set_corps_star_rsp",
      inGameOper = 0,
      handler = "CorpsHandler"
    },
    [357558148] = {
      req = "is_corps_rank_award_exist",
      res = "is_corps_rank_award_exist",
      handler = "CorpsHandler"
    },
    [388372295] = {
      req = "get_corps_task_req",
      res = "get_corps_task_rsp",
      handler = "CorpsHandler"
    },
    [415237678] = {
      res = "add_corps_active_achievement",
      handler = "CorpsHandler"
    },
    [423317224] = {
      req = "get_corps_active_goal_info_req",
      res = "get_corps_active_goal_info_res",
      handler = "CorpsHandler"
    },
    [451506119] = {
      req = "unbind_corps_group_req",
      res = "unbind_corps_group_rsp",
      handler = "CorpsHandler"
    },
    [510228223] = {
      res = "corps_race_act_battle_notify",
      handler = "CorpsHandler"
    },
    [550556263] = {
      req = "get_corps_active_goal_reward_req",
      res = "get_corps_active_goal_reward_rsp",
      handler = "CorpsHandler"
    },
    [561663310] = {
      res = "notify_corps_target_appoint_info",
      handler = "CorpsHandler"
    },
    [604934895] = {
      req = "deal_player_apply_req",
      res = "deal_player_apply_rsp",
      handler = "CorpsHandler"
    },
    [653072488] = {
      req = "buy_corps_shopitem_req",
      res = "buy_corps_shopitem_res",
      handler = "CorpsHandler"
    },
    [672318887] = {
      req = "get_corps_active_award_req",
      res = "get_corps_active_award_rsp",
      handler = "CorpsHandler"
    },
    [684538663] = {
      req = "get_corps_data_req",
      res = "get_corps_data_rsp",
      handler = "CorpsHandler"
    },
    [706635367] = {
      req = "get_corps_task_award_req",
      res = "get_corps_task_award_rsp",
      handler = "CorpsHandler"
    },
    [722370947] = {
      req = "change_invitee_status_req",
      res = "change_invitee_status_rsp",
      handler = "CorpsHandler"
    },
    [729417047] = {
      res = "recommend_corps_popup",
      handler = "CorpsHandler"
    },
    [747702799] = {
      req = "get_corps_summary_req",
      res = "get_corps_summary_rsp",
      handler = "CorpsHandler"
    },
    [751558382] = {
      req = "receive_corps_share_ticket_request",
      res = "receive_corps_share_ticket_respond",
      handler = "CorpsHandler"
    },
    [780617962] = {
      req = "corps_suggestion_list_req",
      handler = "CorpsHandler"
    },
    [807504599] = {
      req = "corps_setup_active_type_req",
      res = "corps_setup_active_type_rsp",
      handler = "CorpsHandler"
    },
    [846011678] = {
      res = "notify_update_corps_member",
      handler = "CorpsHandler"
    },
    [867805787] = {
      res = "sync_player_corps_id",
      handler = "CorpsHandler"
    },
    [897774028] = {
      req = "get_corps_event_list",
      res = "get_corps_event_list_rsp",
      handler = "CorpsHandler"
    },
    [926782265] = {
      res = "corps_training_all_award_res",
      handler = "CorpsHandler"
    },
    [931383659] = {
      req = "corps_accept_invite_req",
      res = "corps_accept_invite_rsp",
      handler = "CorpsHandler"
    },
    [961597243] = {
      req = "corps_change_name_req",
      res = "corps_change_name_rsp",
      handler = "CorpsHandler"
    },
    [971896707] = {
      req = "batch_get_bin_corps_summary_req",
      res = "batch_get_bin_corps_summary_rsp",
      inGameOper = 0,
      handler = "CorpsHandler"
    },
    [973929019] = {
      req = "corps_change_city_req",
      res = "corps_change_city_rsp",
      handler = "CorpsHandler"
    },
    [987089815] = {
      res = "sync_corps_trainning_red_point",
      handler = "CorpsHandler"
    },
    [991945938] = {
      res = "corps_news_status_notify",
      handler = "CorpsHandler"
    },
    [1034715784] = {
      req = "corps_race_act_info_req",
      res = "corps_race_act_info_res",
      handler = "CorpsHandler"
    },
    [1044720551] = {
      req = "join_corps_group_req",
      res = "join_corps_group_rsp",
      handler = "CorpsHandler"
    },
    [1051106311] = {
      req = "exit_corps_req",
      res = "exit_corps_rsp",
      handler = "CorpsHandler"
    },
    [1064173667] = {
      req = "corps_setup_apply_param_req",
      res = "corps_setup_apply_param_rsp",
      handler = "CorpsHandler"
    },
    [1070894510] = {
      req = "corps_kick_member",
      res = "corps_kick_member_rsp",
      handler = "CorpsHandler"
    },
    [1074819890] = {
      req = "corps_race_act_reward_req",
      res = "corps_race_act_reward_res",
      handler = "CorpsHandler"
    },
    [1085086247] = {
      req = "corps_invite_req",
      res = "corps_invite_rsp",
      handler = "CorpsHandler"
    },
    [1090381143] = {
      req = "fuzzy_query_corps_by_name_req",
      res = "fuzzy_query_corps_by_name_rsp",
      handler = "CorpsHandler"
    },
    [1097436815] = {
      req = "corps_auto_invite_req",
      res = "corps_auto_invite_rsp",
      handler = "CorpsHandler"
    },
    [1118525191] = {
      req = "get_corps_news_list_req",
      res = "get_corps_news_list_rsp",
      handler = "CorpsHandler"
    },
    [1138972936] = {
      req = "get_corps_shoplist_req",
      res = "get_corps_shoplist_res",
      handler = "CorpsHandler"
    },
    [1167611463] = {
      req = "corps_chat_message_top_req",
      res = "corps_chat_message_top_rsp",
      handler = "CorpsHandler"
    },
    [1276542695] = {
      req = "get_auto_invite_list_req",
      res = "get_auto_invite_list_rsp",
      handler = "CorpsHandler"
    },
    [1314076718] = {
      req = "get_corps_alias_list_request",
      res = "get_corps_alias_list_respond",
      handler = "CorpsHandler"
    },
    [1323722344] = {
      req = "corps_suggestion_list_req_v2",
      res = "corps_suggestion_list_rsp",
      handler = "CorpsHandler"
    },
    [1386671022] = {
      req = "corps_appoint",
      res = "corps_appoint_rsp",
      handler = "CorpsHandler"
    },
    [1419725354] = {
      req = "have_can_recevie_share_ticket_request",
      res = "have_can_recevie_share_ticket_respond",
      handler = "CorpsHandler"
    },
    [1443280562] = {
      req = "get_corps_share_ticket_list_request",
      res = "get_corps_share_ticket_list_respond",
      handler = "CorpsHandler"
    },
    [1443730769] = {
      res = "notify_corps_notice_change",
      handler = "CorpsHandler"
    },
    [1447628517] = {
      res = "notify_if_agent_leader",
      handler = "CorpsHandler"
    },
    [1461794763] = {
      req = "query_corps_info_for_rank_req",
      res = "query_corps_info_for_rank_rsp",
      handler = "CorpsHandler"
    },
    [1469869542] = {
      res = "add_corps_alias_respond",
      handler = "CorpsHandler"
    },
    [1492786919] = {
      req = "get_corps_member_online_info_req",
      res = "get_corps_member_online_info_rsp",
      timeInterval = 5,
      handler = "CorpsHandler"
    },
    [1524303283] = {
      req = "corps_change_announcement_req",
      res = "corps_change_announcement_rsp",
      handler = "CorpsHandler"
    },
    [1540784728] = {
      req = "corps_race_act_enroll_req",
      res = "corps_race_act_enroll_res",
      handler = "CorpsHandler"
    },
    [1544504363] = {
      req = "batch_get_corps_summary_req",
      res = "batch_get_corps_summary_rsp",
      handler = "CorpsHandler"
    },
    [1611197186] = {
      req = "corps_race_act_set_switch_req",
      res = "corps_race_act_set_switch_res",
      handler = "CorpsHandler"
    },
    [1656933614] = {
      req = "receive_corps_share_ticket_batch_request",
      res = "receive_corps_share_ticket_batch_respond",
      handler = "CorpsHandler"
    },
    [1714505627] = {
      req = "corps_change_icon_req",
      res = "corps_change_icon_rsp",
      handler = "CorpsHandler"
    },
    [1716949020] = {
      req = "report_corps_info_req",
      res = "report_corps_info_rsq",
      handler = "CorpsHandler"
    },
    [1720808807] = {
      req = "create_corps_req",
      res = "create_corps_rsp",
      handler = "CorpsHandler"
    },
    [1728064039] = {
      req = "corps_get_daily_invited_list_req",
      res = "corps_get_daily_invited_list_rsp",
      handler = "CorpsHandler"
    },
    [1765224935] = {
      req = "corps_recommend_uid_list_req",
      res = "corps_recommend_uid_list_rsp",
      handler = "CorpsHandler"
    },
    [1775238555] = {
      res = "notify_is_low_corps",
      handler = "CorpsHandler"
    },
    [1800330125] = {
      res = "trigger_corps_share_ticket_respond",
      handler = "CorpsHandler"
    },
    [1816642535] = {
      req = "get_corps_apply_list_req",
      res = "get_corps_apply_list_rsp",
      handler = "CorpsHandler"
    },
    [1823760487] = {
      req = "apply_join_corps_req",
      res = "apply_join_corps_rsp",
      handler = "CorpsHandler"
    },
    [1864448551] = {
      req = "find_corps_by_name_req",
      res = "find_corps_by_name_rsp",
      handler = "CorpsHandler"
    },
    [1902811687] = {
      req = "set_agent_leader_req",
      res = "set_agent_leader_rsp",
      handler = "CorpsHandler"
    },
    [1907659669] = {
      res = "corps_race_daily_occupy_notify",
      handler = "CorpsHandler"
    },
    [1945212311] = {
      req = "corps_change_notice_req",
      res = "corps_change_notice_rsp",
      handler = "CorpsHandler"
    },
    [1946724078] = {
      req = "corps_share_ticket_request",
      res = "corps_share_ticket_respond",
      handler = "CorpsHandler"
    },
    [1964139687] = {
      req = "bind_corps_group_req",
      res = "bind_corps_group_rsp",
      handler = "CorpsHandler"
    },
    [2004705038] = {
      req = "change_corps_alias_request",
      res = "change_corps_alias_respond",
      handler = "CorpsHandler"
    },
    [2020544434] = {
      req = "corps_race_act_member_score_req",
      res = "corps_race_act_member_score_res",
      handler = "CorpsHandler"
    },
    [2032870729] = {
      res = "notify_update_corps_star_info",
      inGameOper = 0,
      handler = "CorpsHandler"
    },
    [2045186312] = {
      req = "get_corps_training_req",
      res = "get_corps_training_res",
      handler = "CorpsHandler"
    },
    [2071474259] = {
      req = "corps_apply_join_list_req",
      res = "corps_apply_join_list_rsp",
      handler = "CorpsHandler"
    },
    [2090262963] = {
      req = "easy_apply_join_corps_req",
      res = "easy_apply_join_corps_rsp",
      handler = "CorpsHandler"
    },
    [2118646713] = {
      res = "corps_top_message_notify",
      handler = "CorpsHandler"
    },
    [108489930] = {
      req = "modify_nation_req",
      res = "modify_nation_res",
      handler = "CountryAreaHandler"
    },
    [695164583] = {
      req = "get_happy_weekend_ticket_req",
      res = "get_happy_weekend_ticket_rsp",
      handler = "CrazyWeekendHandler"
    },
    [724990099] = {
      req = "get_happy_weekend_award_records_req",
      res = "get_happy_weekend_award_records_rsp",
      handler = "CrazyWeekendHandler"
    },
    [1905220515] = {
      req = "get_happy_weekend_all_winners_req",
      res = "get_happy_weekend_all_winners_rsp",
      handler = "CrazyWeekendHandler"
    },
    [2006313639] = {
      res = "new_happy_weekend_ticket_ntf",
      handler = "CrazyWeekendHandler"
    },
    [29864591] = {
      req = "join_asian_games_room_req",
      res = "join_asian_games_room_rsp",
      handler = "CreateRoomHandler"
    },
    [134603882] = {
      req = "create_room_request",
      res = "create_room_respond",
      isUnique = 1,
      isLock = 1,
      timeout = 5,
      timeInterval = 5,
      handler = "CreateRoomHandler"
    },
    [362499991] = {
      req = "create_asian_games_room_req",
      res = "create_asian_games_room_rsp",
      handler = "CreateRoomHandler"
    },
    [1135382983] = {
      req = "check_is_asian_games_white_req",
      res = "check_is_asian_games_white_rsp",
      inGameOper = 0,
      handler = "CreateRoomHandler"
    },
    [1307502971] = {
      req = "set_asian_games_room_nickname_req",
      res = "set_asian_games_room_nickname_rsp",
      handler = "CreateRoomHandler"
    },
    [1355360653] = {
      res = "room_member_nickname_ntfy",
      handler = "CreateRoomHandler"
    },
    [1680773895] = {
      req = "change_asian_games_map_req",
      res = "change_asian_games_map_rsp",
      handler = "CreateRoomHandler"
    },
    [1845558695] = {
      req = "third_party_uid_validation_req",
      res = "third_party_uid_validation_rsp",
      handler = "CreateRoomHandler"
    },
    [799892647] = {
      req = "cwow_invitee_confirm_req",
      res = "cwow_invitee_confirm_rsp",
      inGameOper = 0,
      handler = "CreativeWoWHandler"
    },
    [839630759] = {
      req = "cwow_apply_req",
      res = "cwow_apply_rsp",
      inGameOper = 0,
      handler = "CreativeWoWHandler"
    },
    [905718093] = {
      res = "cwow_friend_notify",
      inGameOper = 0,
      handler = "CreativeWoWHandler"
    },
    [1392971667] = {
      req = "cwow_invite_req",
      res = "cwow_invite_rsp",
      inGameOper = 0,
      handler = "CreativeWoWHandler"
    },
    [237440931] = {
      req = "get_carteam_auth_info_req",
      res = "get_carteam_auth_info_rsp",
      handler = "CrewHandler"
    },
    [245914183] = {
      req = "get_pug_client_auth_check_info_req",
      res = "get_pug_client_auth_check_info_rsp",
      handler = "CrewHandler"
    },
    [357772151] = {
      req = "get_ban_name_list_req",
      res = "get_ban_name_list_rsp",
      handler = "CrewHandler"
    },
    [378330319] = {
      req = "get_carteam_auth_reward_req",
      res = "get_carteam_auth_reward_rsp",
      handler = "CrewHandler"
    },
    [515184167] = {
      req = "sync_auth_check_result_req",
      res = "sync_auth_check_result_rsp",
      handler = "CrewHandler"
    },
    [712059230] = {
      req = "test_client_umix",
      handler = "CrewHandler"
    },
    [774545383] = {
      req = "get_carteam_auth_count_req",
      res = "get_carteam_auth_count_rsp",
      handler = "CrewHandler"
    },
    [941689015] = {
      req = "get_tournament_client_auth_check_info_req",
      res = "get_tournament_client_auth_check_info_rsp",
      inGameOper = 0,
      handler = "CrewHandler"
    },
    [1227648679] = {
      req = "get_allstar_client_auth_check_info_req",
      res = "get_allstar_client_auth_check_info_rsp",
      handler = "CrewHandler"
    },
    [1393301299] = {
      req = "pug_auth_check_result_req",
      res = "pug_auth_check_result_rsp",
      handler = "CrewHandler"
    },
    [1600499559] = {
      req = "tournament_auth_check_result_req",
      res = "tournament_auth_check_result_rsp",
      inGameOper = 0,
      handler = "CrewHandler"
    },
    [1696643815] = {
      req = "get_client_auth_check_info_req",
      res = "get_client_auth_check_info_rsp",
      handler = "CrewHandler"
    },
    [1819855031] = {
      req = "get_carteam_auth_detail_req",
      res = "get_carteam_auth_detail_rsp",
      handler = "CrewHandler"
    },
    [1916739850] = {
      req = "accn_rp_req",
      res = "accn_rp_res",
      handler = "CrewHandler"
    },
    [1977702119] = {
      req = "sync_allstar_auth_check_result_req",
      res = "sync_allstar_auth_check_result_rsp",
      handler = "CrewHandler"
    },
    [697680039] = {
      req = "custom_chest_credit_exchange_req",
      res = "custom_chest_credit_exchange_rsp",
      isLock = 1,
      timeout = 5,
      handler = "CustomCrateHandler"
    },
    [732244519] = {
      req = "custom_chest_jpkr_ban_item_req",
      res = "custom_chest_jpkr_ban_item_rsp",
      isLock = 1,
      timeout = 5,
      handler = "CustomCrateHandler"
    },
    [1140463847] = {
      req = "custom_chest_kr_ban_item_req",
      res = "custom_chest_kr_ban_item_rsp",
      handler = "CustomCrateHandler"
    },
    [1332005655] = {
      req = "custom_chest_ban_item_req",
      res = "custom_chest_ban_item_rsp",
      isLock = 1,
      timeout = 5,
      handler = "CustomCrateHandler"
    },
    [1367891199] = {
      req = "custom_chest_get_data_req",
      res = "custom_chest_get_data_rsp",
      handler = "CustomCrateHandler"
    },
    [1397092519] = {
      req = "custom_chest_jp_ban_item_req",
      res = "custom_chest_jp_ban_item_rsp",
      handler = "CustomCrateHandler"
    },
    [1855330224] = {
      req = "custom_chest_credit_exchange_req_v1",
      handler = "CustomCrateHandler"
    },
    [2059750051] = {
      req = "custom_chest_get_credit_req",
      res = "custom_chest_get_credit_rsp",
      handler = "CustomCrateHandler"
    },
    [1452577309] = {
      req = "customer_service_clear_reddot_req",
      res = "idip_notify_customer_service_reddot_info",
      handler = "CustomerHandler"
    },
    [1362975183] = {
      req = "customer_service_info_req",
      res = "customer_service_info_rsp",
      inGameOper = 0,
      handler = "CustomerServiceHandler"
    },
    [101076285] = {
      req = "sync_motion_info_req",
      res = "sync_motion_info",
      handler = "DataMgrHandler"
    },
    [671270664] = {
      req = "set_wxsubscribe_list_req",
      res = "set_wxsubscribe_list_res",
      handler = "DataMgrHandler"
    },
    [1016064240] = {
      res = "notify_roleattr_change",
      inGameOper = 0,
      handler = "DataMgrHandler"
    },
    [1034995583] = {
      res = "sync_match_param",
      inGameOper = 0,
      handler = "DataMgrHandler"
    },
    [1053026414] = {
      res = "bulletin_get_hashlist_res",
      handler = "DataMgrHandler"
    },
    [1056081422] = {
      res = "corps_task_chg",
      handler = "DataMgrHandler"
    },
    [1057183161] = {
      res = "sync_room_adv_card_info",
      handler = "DataMgrHandler"
    },
    [1175804864] = {
      res = "share_notify_chg",
      handler = "DataMgrHandler"
    },
    [1435572327] = {
      req = "set_newbie_guide_req",
      res = "set_newbie_guide_rsp",
      inGameOper = 0,
      handler = "DataMgrHandler"
    },
    [1442094813] = {
      res = "sync_room_card_info",
      handler = "DataMgrHandler"
    },
    [1559120139] = {
      res = "notify_recharge_record",
      inGameOper = 0,
      handler = "DataMgrHandler"
    },
    [1611062055] = {
      req = "save_convenient_mode_req",
      res = "save_convenient_mode_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "DataMgrHandler"
    },
    [1712334903] = {
      res = "level_task_notify_chg",
      handler = "DataMgrHandler"
    },
    [1910915790] = {
      res = "bulletin_get_list_res",
      handler = "DataMgrHandler"
    },
    [1955317437] = {
      res = "corp_member_notify",
      handler = "DataMgrHandler"
    },
    [2004526247] = {
      req = "set_role_setting_req",
      res = "set_role_setting_rsp",
      inGameOper = 0,
      handler = "DataMgrHandler"
    },
    [2032738442] = {
      res = "carteam_coin_count_notify_chg",
      handler = "DataMgrHandler"
    },
    [2124948026] = {
      res = "task_notify_chg",
      handler = "DataMgrHandler"
    },
    [378471207] = {
      req = "get_migrate_status_req",
      res = "get_migrate_status_rsp",
      inGameOper = 0,
      handler = "DataMigrationHandler"
    },
    [917819815] = {
      req = "set_migrate_status_req",
      res = "set_migrate_status_rsp",
      inGameOper = 0,
      handler = "DataMigrationHandler"
    },
    [1525328003] = {
      req = "start_migrate_req",
      res = "start_migrate_rsp",
      timeout = 5,
      inGameOper = 0,
      handler = "DataMigrationHandler"
    },
    [386372323] = {
      req = "on_batch_item_decompose_req",
      res = "on_batch_item_decompose_rsp",
      isLock = 1,
      handler = "DecomposeHandler"
    },
    [976344342] = {
      req = "on_item_decompose",
      res = "on_item_decompose_rsp",
      isLock = 1,
      handler = "DecomposeHandler"
    },
    [1247592903] = {
      req = "search_optional_chest_decompose_status_req",
      res = "search_optional_chest_decompose_status_rsp",
      handler = "DecomposeHandler"
    },
    [1771309811] = {
      res = "notify_item_decompose_table_changed",
      handler = "DecomposeHandler"
    },
    [73146346] = {
      req = "statis_visibility_widget",
      handler = "DevHandler"
    },
    [223901519] = {
      req = "get_rating_protect_list_req",
      res = "get_rating_protect_list_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "DoubleCardHandler"
    },
    [266584019] = {
      res = "sync_double_card_info",
      handler = "DoubleCardHandler"
    },
    [683069942] = {
      res = "notify_add_rating_list",
      inGameOper = 0,
      handler = "DoubleCardHandler"
    },
    [772431735] = {
      req = "get_add_rating_list_req",
      res = "get_add_rating_list_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "DoubleCardHandler"
    },
    [1357369099] = {
      req = "get_tdm_rank_protect_info_req",
      res = "get_tdm_rank_protect_info_rsp",
      inGameOper = 0,
      handler = "DoubleCardHandler"
    },
    [1838810937] = {
      res = "rating_card_change_notify",
      inGameOper = 0,
      handler = "DoubleCardHandler"
    },
    [1889024042] = {
      res = "notify_rating_protect_list",
      inGameOper = 0,
      handler = "DoubleCardHandler"
    },
    [1525781415] = {
      req = "unlock_dragon_ball_items_req",
      res = "unlock_dragon_ball_items_rsp",
      inGameOper = 0,
      handler = "DragonHandler"
    },
    [1816482283] = {
      req = "dragon_ball_animation_req",
      res = "dragon_ball_animation_rsp",
      handler = "DragonHandler"
    },
    [81103527] = {
      req = "get_realtime_probability_req",
      res = "get_realtime_probability_rsp",
      inGameOper = 0,
      handler = "DropBoxHandler"
    },
    [297731772] = {
      req = "get_content_by_chestids",
      res = "get_content_by_chestids_rsp",
      inGameOper = 0,
      handler = "DropBoxHandler"
    },
    [541713612] = {
      req = "get_content_by_dropids",
      res = "get_content_by_dropids_rsp",
      inGameOper = 0,
      handler = "DropBoxHandler"
    },
    [111844693] = {
      res = "esports_subscribe_ntfy",
      handler = "ESportsHandler"
    },
    [328309557] = {
      res = "esports_subscribe_update",
      handler = "ESportsHandler"
    },
    [1631173283] = {
      req = "set_esports_subscribe_state_req",
      res = "set_esports_subscribe_state_rsp",
      handler = "ESportsHandler"
    },
    [55809799] = {
      req = "eugdpr_update_type_req",
      res = "eugdpr_update_type_rsp",
      handler = "EUGDPRHandler"
    },
    [75184499] = {
      req = "krjp_cancel_del_account_req",
      res = "krjp_cancel_del_account_rsp",
      handler = "EUGDPRHandler"
    },
    [365879481] = {
      res = "eugdpr_notify",
      handler = "EUGDPRHandler"
    },
    [450498471] = {
      req = "minor_cert_report_req",
      res = "minor_cert_report_rsp",
      inGameOper = 0,
      handler = "EUGDPRHandler"
    },
    [531325468] = {
      req = "eugdpr_report_tlog_req",
      handler = "EUGDPRHandler"
    },
    [636585759] = {
      req = "set_minor_req",
      handler = "EUGDPRHandler"
    },
    [767377227] = {
      req = "eugdpr_update_agegate_req",
      res = "eugdpr_update_agegate_rsp",
      handler = "EUGDPRHandler"
    },
    [955959207] = {
      req = "report_eea_voice_verify_mail_req",
      res = "report_eea_voice_verify_mail_rsp",
      handler = "EUGDPRHandler"
    },
    [1240092071] = {
      req = "eugdpr_del_account_req",
      res = "eugdpr_del_account_rsp",
      handler = "EUGDPRHandler"
    },
    [1356186471] = {
      req = "eugdpr_update_policy_req",
      res = "eugdpr_update_policy_rsp",
      handler = "EUGDPRHandler"
    },
    [1486967743] = {
      req = "report_user_compliance_info_req",
      res = "report_user_compliance_info_rsp",
      handler = "EUGDPRHandler"
    },
    [1536865603] = {
      req = "report_minor_compliance_auth_flow_req",
      res = "report_minor_compliance_auth_flow_rsp",
      handler = "EUGDPRHandler"
    },
    [1547155647] = {
      req = "eugdpr_direct_del_account_req",
      res = "eugdpr_direct_del_account_rsp",
      handler = "EUGDPRHandler"
    },
    [1603863463] = {
      req = "krjp_del_account_req",
      res = "krjp_del_account_rsp",
      handler = "EUGDPRHandler"
    },
    [1763868075] = {
      req = "eugdpr_cancel_del_account_req",
      res = "eugdpr_cancel_del_account_rsp",
      handler = "EUGDPRHandler"
    },
    [459922536] = {
      req = "easy_buy_exchanges_req",
      res = "easy_buy_exchanges_res",
      isLock = 1,
      needRsp = 1,
      handler = "EasyBuyHandler"
    },
    [1051634286] = {
      res = "update_easy_buy_limits",
      inGameOper = 0,
      handler = "EasyBuyHandler"
    },
    [1830484680] = {
      req = "easy_buy_req",
      res = "easy_buy_res",
      inGameOper = 0,
      handler = "EasyBuyHandler"
    },
    [312885799] = {
      req = "get_egame_entry_info_req",
      res = "get_egame_entry_info_rsp",
      handler = "EgameHandler"
    },
    [543314631] = {
      req = "get_all_milestone_data_req",
      res = "get_all_milestone_data_rsp",
      inGameOper = 0,
      handler = "EmoteHandler"
    },
    [1416023907] = {
      res = "notify_new_milestone_rsp",
      inGameOper = 0,
      handler = "EmoteHandler"
    },
    [1520190695] = {
      req = "save_milestone_slot_info_req",
      res = "save_milestone_slot_info_rsp",
      inGameOper = 0,
      handler = "EmoteHandler"
    },
    [242463958] = {
      req = "report_simulator_check",
      handler = "EmulatorHandler"
    },
    [811142308] = {
      res = "notify_kick_out_game",
      inGameOper = 0,
      handler = "EmulatorHandler"
    },
    [1162992962] = {
      req = "get_emulators_cfg_req",
      res = "get_emulators_cfg_res",
      handler = "EmulatorHandler"
    },
    [176588334] = {
      res = "daily_direct_buy_success",
      handler = "EveryDayPackHandler"
    },
    [461521191] = {
      req = "daily_direct_buy_pre_req",
      res = "daily_direct_buy_pre_rsp",
      handler = "EveryDayPackHandler"
    },
    [845167183] = {
      req = "daily_direct_buy_get_little_prize_req",
      res = "daily_direct_buy_get_little_prize_rsp",
      isLock = 1,
      handler = "EveryDayPackHandler"
    },
    [1096734311] = {
      req = "daily_direct_buy_get_big_prize_req",
      res = "daily_direct_buy_get_big_prize_rsp",
      isLock = 1,
      handler = "EveryDayPackHandler"
    },
    [1691926392] = {
      req = "daily_direct_buy_get_cfg",
      res = "sync_daily_direct_buy",
      handler = "EveryDayPackHandler"
    },
    [1623736191] = {
      req = "daily_direct_buy_v2_can_buy_req",
      res = "daily_direct_buy_v2_can_buy_rsp",
      handler = "EverydayV2PackHandler"
    },
    [1729890199] = {
      req = "daily_direct_buy_v2_exchange_reward_req",
      res = "daily_direct_buy_v2_exchange_reward_rsp",
      handler = "EverydayV2PackHandler"
    },
    [1747444167] = {
      req = "daily_direct_buy_v2_get_cfg_req",
      res = "daily_direct_buy_v2_get_cfg_rsp",
      handler = "EverydayV2PackHandler"
    },
    [1834480677] = {
      req = "daily_direct_buy_v2_buy_success_req",
      handler = "EverydayV2PackHandler"
    },
    [1928589010] = {
      res = "daily_direct_buy_v2_buy_success_rsp",
      handler = "EverydayV2PackHandler"
    },
    [1543130663] = {
      req = "act_journey_move_req",
      res = "act_journey_move_rsp",
      timeInterval = 1,
      handler = "ExcitingTourHandler"
    },
    [533033135] = {
      req = "get_glb_explore_cfg_req",
      res = "get_glb_explore_cfg_rsp",
      timeInterval = 10,
      handler = "ExploreHandler"
    },
    [767457181] = {
      res = "activity_explore_point_change_notify",
      inGameOper = 0,
      handler = "ExploreHandler"
    },
    [1176358851] = {
      req = "explore_buy_chest_req",
      res = "explore_buy_chest_rsp",
      handler = "ExploreHandler"
    },
    [1315788587] = {
      req = "explore_buy_req",
      res = "explore_buy_rsp",
      isLock = 1,
      handler = "ExploreHandler"
    },
    [1385843051] = {
      req = "get_glb_explore_award_req",
      res = "get_glb_explore_award_rsp",
      isLock = 1,
      handler = "ExploreHandler"
    },
    [1389600259] = {
      req = "explore_get_award_req",
      res = "explore_get_award_rsp",
      isLock = 1,
      handler = "ExploreHandler"
    },
    [1511333799] = {
      req = "get_glb_explore_progress_req",
      res = "get_glb_explore_progress_rsp",
      timeInterval = 10,
      handler = "ExploreHandler"
    },
    [1679166183] = {
      req = "get_glb_explore_award_status_req",
      res = "get_glb_explore_award_status_rsp",
      handler = "ExploreHandler"
    },
    [1850168311] = {
      req = "explore_get_activity_data_req",
      res = "explore_get_activity_data_rsp",
      timeInterval = 2,
      handler = "ExploreHandler"
    },
    [1908525703] = {
      req = "explore_exchange_point_req",
      res = "explore_exchange_point_rsp",
      isLock = 1,
      handler = "ExploreHandler"
    },
    [535043239] = {
      req = "get_fcm_info_req",
      res = "get_fcm_info_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "FCMPushHandler"
    },
    [713922727] = {
      req = "set_fcm_info_req",
      res = "set_fcm_info_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "FCMPushHandler"
    },
    [836538664] = {
      req = "set_fcm_switch_req",
      res = "set_fcm_switch_res",
      isUnique = 1,
      inGameOper = 0,
      handler = "FCMPushHandler"
    },
    [1344653352] = {
      req = "trigger_fcm_msg_req",
      res = "trigger_fcm_msg_res",
      isUnique = 1,
      inGameOper = 0,
      handler = "FCMPushHandler"
    },
    [1850918064] = {
      req = "get_fcm_switch_info_req",
      res = "get_fcm_switch_info_res",
      isUnique = 1,
      inGameOper = 0,
      handler = "FCMPushHandler"
    },
    [1949481639] = {
      req = "get_msg_push_cfg_req",
      res = "get_msg_push_cfg_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "FCMPushHandler"
    },
    [17664051] = {
      req = "batch_get_uid_from_openid_for_frd_req",
      res = "batch_get_uid_from_openid_for_frd_rsp",
      handler = "FacebookHandler"
    },
    [531407154] = {
      res = "cheat_warn_notify",
      inGameOper = 0,
      handler = "FairGameHandler"
    },
    [1044336743] = {
      req = "cheat_warn_reply",
      handler = "FairGameHandler"
    },
    [1523687602] = {
      res = "show_fair_play_agreement",
      inGameOper = 0,
      handler = "FairGameHandler"
    },
    [1949686563] = {
      req = "fair_play_agreement_req",
      res = "fair_play_agreement_rsp",
      inGameOper = 0,
      handler = "FairGameHandler"
    },
    [355818679] = {
      req = "apply_rolewear_template_req",
      res = "apply_rolewear_template_rsp",
      handler = "FashionBagHandler"
    },
    [364954823] = {
      req = "save_rolewear_template_req",
      res = "save_rolewear_template_rsp",
      handler = "FashionBagHandler"
    },
    [1529247271] = {
      req = "edit_rolewear_template_req",
      res = "edit_rolewear_template_rsp",
      handler = "FashionBagHandler"
    },
    [779362919] = {
      req = "get_classical_record_req",
      res = "get_classical_record_rsp",
      handler = "FightRecordHandler"
    },
    [955295303] = {
      req = "get_classical_alive_record_req",
      res = "get_classical_alive_record_rsp",
      inGameOper = 0,
      handler = "FightRecordHandler"
    },
    [1073914079] = {
      req = "get_classical_kill_record_req",
      res = "get_classical_kill_record_rsp",
      handler = "FightRecordHandler"
    },
    [1556191079] = {
      req = "get_classical_gang_up_record_req",
      res = "get_classical_gang_up_record_rsp",
      inGameOper = 0,
      handler = "FightRecordHandler"
    },
    [10968170] = {
      req = "trigger_iap_final_offer_req",
      handler = "FinalOfferHandler"
    },
    [85757863] = {
      req = "get_make_money_plan_multiple_task_reward_req",
      res = "get_make_money_plan_multiple_task_reward_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "FinancialHandler"
    },
    [682386187] = {
      req = "get_make_money_plan_req",
      res = "get_make_money_plan_rsp",
      handler = "FinancialHandler"
    },
    [1337178151] = {
      req = "buy_make_money_plan_gift_req",
      res = "buy_make_money_plan_gift_rsp",
      handler = "FinancialHandler"
    },
    [1339436646] = {
      res = "sync_make_money_plan_task_ntf",
      handler = "FinancialHandler"
    },
    [2013841411] = {
      req = "get_make_money_plan_task_reward_req",
      res = "get_make_money_plan_task_reward_rsp",
      handler = "FinancialHandler"
    },
    [90141039] = {
      req = "new_user_fission_info_req",
      res = "new_user_fission_info_rsp",
      handler = "FissionHandler"
    },
    [221665383] = {
      req = "new_user_fission_take_task_award_req",
      res = "new_user_fission_take_task_award_rsp",
      handler = "FissionHandler"
    },
    [389413219] = {
      req = "new_user_fission_exchange_req",
      res = "new_user_fission_exchange_rsp",
      handler = "FissionHandler"
    },
    [446217044] = {
      res = "new_user_fission_score_ntf",
      handler = "FissionHandler"
    },
    [1880903079] = {
      req = "new_user_fission_shared_join_req",
      res = "new_user_fission_shared_join_rsp",
      handler = "FissionHandler"
    },
    [56229607] = {
      req = "get_flash_squad_info_req",
      res = "get_flash_squad_info_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [371107711] = {
      req = "get_flash_squad_apply_count_req",
      res = "get_flash_squad_apply_count_rsp",
      handler = "FlashTeamHandler"
    },
    [475237095] = {
      req = "transfer_flash_squad_req",
      res = "transfer_flash_squad_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [507021575] = {
      req = "get_all_flash_squad_apply_list_req",
      res = "get_all_flash_squad_apply_list_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [656704487] = {
      res = "flash_squad_invite_notify",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [696331367] = {
      req = "clear_squad_perk_red_dot_req",
      res = "clear_squad_perk_red_dot_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [710332583] = {
      req = "get_flash_squad_data_req",
      res = "get_flash_squad_data_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [747097511] = {
      req = "update_flash_squad_msg_req",
      res = "update_flash_squad_msg_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [793228644] = {
      res = "notify_flash_squad_change",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [919055711] = {
      req = "get_flash_squad_invite_list_req",
      res = "get_flash_squad_invite_list_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [988388199] = {
      req = "claim_rapport_reward_req",
      res = "claim_rapport_reward_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1031386731] = {
      req = "batch_get_flash_squad_summary_req",
      res = "batch_get_flash_squad_summary_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1049658311] = {
      req = "pin_flash_squad_req",
      res = "pin_flash_squad_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1112355719] = {
      req = "update_flash_squad_setting_req",
      res = "update_flash_squad_setting_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1181710403] = {
      req = "batch_get_flash_squad_members_brief_req",
      res = "batch_get_flash_squad_members_brief_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1364165351] = {
      req = "get_prefer_modes_for_flash_squad_req",
      res = "get_prefer_modes_for_flash_squad_rsp",
      handler = "FlashTeamHandler"
    },
    [1436867623] = {
      req = "join_flash_squad_req",
      res = "join_flash_squad_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1479256327] = {
      req = "create_flash_squad_req",
      res = "create_flash_squad_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1644624715] = {
      req = "report_flash_squad_name_req",
      res = "report_flash_squad_name_rsp",
      handler = "FlashTeamHandler"
    },
    [1706865831] = {
      req = "get_flash_squad_chat_history_req",
      res = "get_flash_squad_chat_history_rsp",
      handler = "FlashTeamHandler"
    },
    [1734808527] = {
      req = "get_rapport_claimed_req",
      res = "get_rapport_claimed_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1787334007] = {
      req = "delete_flash_squad_invite_req",
      res = "delete_flash_squad_invite_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1828581135] = {
      req = "kick_flash_squad_member_req",
      res = "kick_flash_squad_member_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1901055263] = {
      req = "get_flash_squad_recommend_req",
      res = "get_flash_squad_recommend_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [1944001363] = {
      req = "invite_join_flash_squad_req",
      res = "invite_join_flash_squad_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [2033474407] = {
      req = "handle_flash_squad_apply_req",
      res = "handle_flash_squad_apply_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [2056588647] = {
      req = "quit_flash_squad_req",
      res = "quit_flash_squad_rsp",
      inGameOper = 0,
      handler = "FlashTeamHandler"
    },
    [253683063] = {
      req = "update_personal_flash_squad_setting_req",
      res = "update_personal_flash_squad_setting_rsp",
      inGameOper = 0,
      handler = "FlashTeamSettingHandler"
    },
    [1109207350] = {
      req = "will_add_you_as_friend_req",
      res = "add_inner_friend_op_rsp",
      inGameOper = 0,
      handler = "FriendApplyBattleHandler"
    },
    [1124912776] = {
      req = "please_add_me_as_friend_req",
      res = "please_add_me_as_friend_resp",
      inGameOper = 0,
      handler = "FriendApplyBattleHandler"
    },
    [128198055] = {
      req = "add_inner_friend_req",
      res = "add_inner_friend_rsp",
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [129236373] = {
      res = "auto_add_inner_friend_notify",
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [243707085] = {
      res = "add_inner_friend_notify",
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [383952899] = {
      req = "batch_add_inner_friend_op_req",
      res = "batch_add_inner_friend_op_rsp",
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [1028934551] = {
      req = "get_addfriend_reqlist_req",
      res = "get_addfriend_reqlist_rsp",
      timeInterval = 10,
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [1093976068] = {
      res = "del_addfriend_req_notify",
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [1382179111] = {
      req = "batch_add_friend_req",
      res = "batch_add_friend_rsp",
      queueType = 1,
      timeInterval = 3,
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [1543030903] = {
      req = "add_inner_friend_op_req",
      res = "add_inner_friend_op_rsp",
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [1689468661] = {
      res = "add_inner_friend_op_notify",
      inGameOper = 0,
      handler = "FriendApplyHandler"
    },
    [127121698] = {
      res = "add_black_change_notify",
      inGameOper = 0,
      handler = "FriendBlacklistHandler"
    },
    [582743719] = {
      req = "get_black_list_req",
      res = "get_black_list_rsp",
      timeInterval = 10,
      inGameOper = 0,
      handler = "FriendBlacklistHandler"
    },
    [950204071] = {
      req = "del_match_black_list_req",
      res = "del_match_black_list_rsp",
      handler = "FriendBlacklistHandler"
    },
    [1276567015] = {
      req = "get_match_black_list_req",
      res = "get_match_black_list_rsp",
      inGameOper = 0,
      handler = "FriendBlacklistHandler"
    },
    [1307257607] = {
      req = "del_black_list_req",
      res = "del_black_list_rsp",
      inGameOper = 0,
      handler = "FriendBlacklistHandler"
    },
    [1492423783] = {
      req = "add_match_black_list_req",
      res = "add_match_black_list_rsp",
      handler = "FriendBlacklistHandler"
    },
    [2023865351] = {
      req = "add_black_list_req",
      res = "add_black_list_rsp",
      inGameOper = 0,
      handler = "FriendBlacklistHandler"
    },
    [1902464615] = {
      req = "present_friend_gold_req",
      res = "present_friend_gold_rsp",
      inGameOper = 0,
      handler = "FriendGiftHandler"
    },
    [38132935] = {
      req = "do_friend_status_like_req",
      res = "do_friend_status_like_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [56079783] = {
      req = "delete_intimacy_relation_req",
      res = "delete_intimacy_relation_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [91891879] = {
      req = "get_appointment_friend_req",
      res = "get_appointment_friend_rsp",
      timeInterval = 10,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [114926849] = {
      res = "notify_appointment_friends",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [157476303] = {
      req = "set_friend_status_new_req",
      res = "set_friend_status_new_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [281412907] = {
      req = "reply_intimacy_relation_req",
      res = "reply_intimacy_relation_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [342807655] = {
      req = "update_friend_remark_req",
      res = "update_friend_remark_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [359945440] = {
      res = "notify_intimacy_relation_chg",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [397073191] = {
      req = "check_and_update_invite_plat_req",
      res = "check_and_update_invite_plat_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [485636135] = {
      req = "get_all_friendlist_req",
      res = "get_all_friendlist_rsp",
      timeout = 10,
      needRsp = 3,
      timeInterval = 10,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [506495507] = {
      req = "invite_offline_friend_req",
      res = "invite_offline_friend_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [547460039] = {
      req = "friend_interact_milestone_like_req",
      res = "friend_interact_milestone_like_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [557014886] = {
      req = "appointment_game_friend_answer",
      handler = "FriendHandler"
    },
    [562827003] = {
      res = "notify_appointment_friend_list",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [591822567] = {
      req = "report_interaction_req",
      res = "report_interaction_rsp",
      handler = "FriendHandler"
    },
    [610315015] = {
      req = "report_friend_info_req",
      res = "report_friend_info_rsp",
      handler = "FriendHandler"
    },
    [615096143] = {
      req = "get_not_fir_interaction_req",
      res = "get_not_fir_interaction_rsp",
      timeInterval = 6,
      handler = "FriendHandler"
    },
    [864561683] = {
      req = "get_all_friendlist_interact_req",
      res = "get_all_friendlist_interact_rsp",
      handler = "FriendHandler"
    },
    [908840547] = {
      res = "friend_gang_up_chat_ntfy",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [929726659] = {
      res = "appointment_game_friend_notify",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [962962911] = {
      res = "friend_gang_up_week_refresh_ntfy",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [996838631] = {
      req = "get_friend_status_detail_req",
      res = "get_friend_status_detail_rsp",
      timeInterval = 2,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1019574960] = {
      req = "appointment_game_friend_req",
      res = "appointment_game_friend_res",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1091248545] = {
      res = "cancel_build_intimacy_relation_notify",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1107434471] = {
      req = "del_inner_friend_req",
      res = "del_inner_friend_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1124666919] = {
      req = "get_friend_misc_info_req",
      res = "get_friend_misc_info_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1178102375] = {
      req = "send_friend_item_req",
      res = "send_friend_item_rsp",
      handler = "FriendHandler"
    },
    [1221534975] = {
      req = "appointment_friend_auto_reply_req",
      res = "appointment_friend_auto_reply_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1231491684] = {
      res = "notify_change_intimacy_relation_update",
      handler = "FriendHandler"
    },
    [1295818535] = {
      req = "change_intimacy_relation_req",
      res = "change_intimacy_relation_rsp",
      handler = "FriendHandler"
    },
    [1308907275] = {
      req = "modify_friend_appointment_privacy_req",
      res = "modify_friend_appointment_privacy_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1401805203] = {
      req = "intimacy_friend_recommend_req",
      res = "intimacy_friend_recommend_rsp",
      isUnique = 1,
      queueType = 1,
      timeInterval = 1,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1421148358] = {
      res = "notify_topn_plat_friend_chg_info",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1484021403] = {
      req = "get_upvote_recent_req",
      res = "get_upvote_recent_rsp",
      timeInterval = 10,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1512165387] = {
      res = "notify_rela_need_login",
      handler = "FriendHandler"
    },
    [1512350823] = {
      req = "do_friend_top_op_req",
      res = "do_friend_top_op_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1530862471] = {
      req = "cancel_change_intimacy_relation_req",
      res = "cancel_change_intimacy_relation_rsp",
      handler = "FriendHandler"
    },
    [1623896061] = {
      req = "set_friend_banned_tips_time",
      handler = "FriendHandler"
    },
    [1639063835] = {
      req = "build_intimacy_relation_req",
      res = "build_intimacy_relation_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1650196844] = {
      res = "notify_friend_intimacy_chg",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1713343981] = {
      res = "add_frd_status_like_notify",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1716088527] = {
      req = "get_friend_interact_milestone_req",
      res = "get_friend_interact_milestone_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1729784470] = {
      res = "frd_status_change_notify",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1734064071] = {
      req = "del_inner_friend_batch_req",
      res = "del_inner_friend_batch_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1745184407] = {
      req = "get_recent_teammate_req",
      res = "get_recent_teammate_rsp",
      timeInterval = 10,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1849735255] = {
      res = "notify_intimacy_level_up",
      handler = "FriendHandler"
    },
    [1857718907] = {
      req = "get_intimacy_relation_req",
      res = "get_intimacy_relation_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1857937715] = {
      req = "take_intimacy_award_req",
      res = "take_intimacy_award_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "FriendHandler"
    },
    [1907215202] = {
      res = "notify_team_result_finished",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1918849255] = {
      req = "get_interact_records_req",
      res = "get_interact_records_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1931538023] = {
      req = "cancel_build_intimacy_relation_req",
      res = "cancel_build_intimacy_relation_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1958943335] = {
      req = "get_openid_by_nickname_req",
      res = "get_openid_by_nickname_rsp",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [2011157389] = {
      res = "del_inner_friend_notify",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [2037330051] = {
      res = "appointment_friend_game_end",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [2076858151] = {
      req = "spk_grant_success_req",
      res = "spk_grant_success_rsp",
      handler = "FriendHandler"
    },
    [2104529339] = {
      req = "get_season_interact_records_req",
      res = "get_season_interact_records_rsp",
      handler = "FriendHandler"
    },
    [2112290343] = {
      req = "reply_change_intimacy_relation_req",
      res = "reply_change_intimacy_relation_rsp",
      handler = "FriendHandler"
    },
    [2117674982] = {
      res = "friend_gang_up_count_ntfy",
      inGameOper = 0,
      handler = "FriendHandler"
    },
    [1150469415] = {
      req = "set_friend_list_show_switchs_req",
      res = "set_friend_list_show_switchs_rsp",
      handler = "FriendListItemCustomHandler"
    },
    [844580903] = {
      req = "find_uid_by_name_req",
      res = "find_uid_by_name_rsp",
      inGameOper = 0,
      handler = "FriendSearchHandler"
    },
    [1200839463] = {
      req = "social_search_role_req",
      res = "social_search_role_rsp",
      inGameOper = 0,
      handler = "FriendSearchHandler"
    },
    [707527138] = {
      req = "game_battle_evaluation",
      handler = "GameEvaluationHandler"
    },
    [1149996348] = {
      req = "game_teammate_evaluation",
      handler = "GameEvaluationHandler"
    },
    [1507006755] = {
      req = "update_battle_evaluation_mark",
      handler = "GameEvaluationHandler"
    },
    [1357150584] = {
      req = "report_gamemaster_info_req",
      res = "report_gamemaster_info_resp",
      inGameOper = 0,
      handler = "GameMasterHandler"
    },
    [272436611] = {
      req = "popularity_trade_get_filter_req",
      res = "popularity_trade_get_filter_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [577325163] = {
      req = "popularity_trade_op_req",
      res = "popularity_trade_op_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [892455040] = {
      req = "popularity_trade_setting_req",
      res = "popularity_trade_filter_setting_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [1316988775] = {
      req = "popularity_trade_recommend_req",
      res = "popularity_trade_recommend_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [1615147431] = {
      req = "popularity_trade_apply_req",
      res = "popularity_trade_apply_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [1680741575] = {
      req = "popularity_trade_list_req",
      res = "popularity_trade_list_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [1901637223] = {
      req = "popularity_trade_agree_req",
      res = "popularity_trade_agree_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [1939911975] = {
      req = "popularity_trade_valid_req",
      res = "popularity_trade_valid_rsp",
      inGameOper = 0,
      handler = "GiftExchangeHandler"
    },
    [686687933] = {
      req = "report_game_activity",
      handler = "GlobalChatHandler"
    },
    [174189159] = {
      req = "get_global_limit_info_req",
      res = "get_global_limit_info_rsp",
      handler = "GlobalHandler"
    },
    [1705516758] = {
      req = "nonstandard_url_parameter",
      handler = "GlobalHandler"
    },
    [34683699] = {
      req = "res_download_report_req",
      isUnique = 1,
      queueType = 1,
      handler = "GlobalNetHandler"
    },
    [277052152] = {
      req = "video_play_report_req",
      isUnique = 1,
      queueType = 1,
      handler = "GlobalNetHandler"
    },
    [324592742] = {
      res = "notify_client_tips",
      inGameOper = 0,
      handler = "GlobalNetHandler"
    },
    [559153996] = {
      req = "report_age_gate_voice_flow",
      handler = "GlobalNetHandler"
    },
    [607533496] = {
      req = "ip_region_check_req",
      res = "ip_region_check_res",
      inGameOper = 0,
      handler = "GlobalNetHandler"
    },
    [1109334369] = {
      req = "button_push_click_log",
      isUnique = 1,
      queueType = 1,
      handler = "GlobalNetHandler"
    },
    [1148755527] = {
      req = "video_skip_ctrl_req",
      res = "video_skip_ctrl_rsp",
      handler = "GlobalNetHandler"
    },
    [1169364147] = {
      req = "batch_button_click_log",
      handler = "GlobalNetHandler"
    },
    [1213367246] = {
      req = "get_loading_pic_cfg",
      res = "get_loading_pic_cfg_rsp",
      inGameOper = 0,
      handler = "GlobalNetHandler"
    },
    [1317958927] = {
      req = "report_event_duration_log",
      handler = "GlobalNetHandler"
    },
    [1326535638] = {
      req = "report_general_illegal_click_req",
      handler = "GlobalNetHandler"
    },
    [1332748751] = {
      res = "client_req_limited_notify",
      inGameOper = 0,
      handler = "GlobalNetHandler"
    },
    [1363316455] = {
      req = "get_loading_show_cfg_req",
      res = "get_loading_show_cfg_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "GlobalNetHandler"
    },
    [1705770239] = {
      req = "get_load_background_cfg_req",
      res = "get_load_background_cfg_rsp",
      inGameOper = 0,
      handler = "GlobalNetHandler"
    },
    [1767781323] = {
      req = "get_new_loading_pic_cfg_req",
      res = "get_new_loading_pic_cfg_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "GlobalNetHandler"
    },
    [167315856] = {
      res = "notify_game_level_info",
      handler = "GodzillaAttackHandler"
    },
    [512004395] = {
      req = "activity_gzl_attack_req",
      res = "activity_gzl_attack_rsp",
      handler = "GodzillaAttackHandler"
    },
    [848685191] = {
      req = "activity_gzl_consume_bullet_req",
      res = "activity_gzl_consume_bullet_rsp",
      handler = "GodzillaAttackHandler"
    },
    [1836788383] = {
      req = "get_lucky_award_req",
      res = "get_lucky_award_rsp",
      handler = "GodzillaAttackHandler"
    },
    [1867009962] = {
      res = "notify_lucky_award",
      handler = "GodzillaAttackHandler"
    },
    [1894536999] = {
      req = "get_activity_gzl_attack_info_req",
      res = "get_activity_gzl_attack_info_rsp",
      handler = "GodzillaAttackHandler"
    },
    [1925029599] = {
      res = "notify_pass_award",
      handler = "GodzillaAttackHandler"
    },
    [302002279] = {
      req = "goslar_ban_draw_req",
      res = "goslar_ban_draw_rsp",
      isLock = 1,
      handler = "GodzillaBanHandler"
    },
    [536494191] = {
      req = "get_goslar_acc_reward_req",
      res = "get_goslar_acc_reward_rsp",
      handler = "GodzillaBanHandler"
    },
    [809715303] = {
      req = "goslar_ban_confirm_req",
      res = "goslar_ban_confirm_rsp",
      isLock = 1,
      handler = "GodzillaBanHandler"
    },
    [1637274787] = {
      req = "get_goslar_ban_info_req",
      res = "get_goslar_ban_info_rsp",
      isLock = 1,
      needRsp = 4,
      handler = "GodzillaBanHandler"
    },
    [374653183] = {
      req = "guest_account_pwd_set_req",
      res = "guest_account_pwd_set_rsp",
      inGameOper = 0,
      handler = "GuestBindHandler"
    },
    [385886562] = {
      res = "guest_account_bind_ntfy",
      inGameOper = 0,
      handler = "GuestBindHandler"
    },
    [1315763581] = {
      req = "guest_account_retrieve_done_req",
      handler = "GuestBindHandler"
    },
    [1919543527] = {
      req = "guest_account_retrieve_req",
      res = "guest_account_retrieve_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "GuestBindHandler"
    },
    [89945457] = {
      res = "get_all_care_task_date_rsp",
      handler = "GuideFlowHandler"
    },
    [292657148] = {
      req = "set_click_task_req",
      handler = "GuideFlowHandler"
    },
    [320985399] = {
      req = "set_guide_flow_block_rule_req",
      res = "set_guide_flow_block_rule_rsp",
      handler = "GuideFlowHandler"
    },
    [618341891] = {
      req = "update_node_count_req",
      res = "update_node_count_rsp",
      handler = "GuideFlowHandler"
    },
    [774982247] = {
      req = "get_node_count_req",
      res = "get_node_count_rsp",
      handler = "GuideFlowHandler"
    },
    [848139239] = {
      req = "get_care_task_date_req",
      res = "get_care_task_date_rsp",
      handler = "GuideFlowHandler"
    },
    [916195697] = {
      req = "report_grow_up_tlog",
      handler = "GuideFlowHandler"
    },
    [1366368999] = {
      req = "get_guide_flow_cfg_req",
      res = "get_guide_flow_cfg_rsp",
      timeInterval = 6,
      handler = "GuideFlowHandler"
    },
    [1624932711] = {
      req = "guide_flow_change_tree_req",
      res = "guide_flow_change_tree_rsp",
      handler = "GuideFlowHandler"
    },
    [1698240935] = {
      req = "guide_flow_get_all_tree_req",
      res = "guide_flow_get_all_tree_rsp",
      handler = "GuideFlowHandler"
    },
    [2057671559] = {
      req = "get_guide_flow_block_rule_req",
      res = "get_guide_flow_block_rule_rsp",
      handler = "GuideFlowHandler"
    },
    [63554220] = {
      req = "query_lottery_info",
      res = "query_lottery_info_rsp",
      handler = "HalloweenVehicleHandler"
    },
    [516326732] = {
      req = "query_lottery_award_info",
      res = "query_lottery_award_info_rsp",
      handler = "HalloweenVehicleHandler"
    },
    [577874075] = {
      req = "do_upgrade_by_activity_id_req",
      res = "do_upgrade_by_activity_id_rsp",
      handler = "HalloweenVehicleHandler"
    },
    [603109572] = {
      req = "get_vst_level_up_info",
      res = "get_vst_level_up_info_rsp",
      handler = "HalloweenVehicleHandler"
    },
    [633984467] = {
      req = "get_upgrade_activity_info_req",
      res = "get_upgrade_activity_info_rsp",
      handler = "HalloweenVehicleHandler"
    },
    [1055378860] = {
      req = "take_lottery_award",
      res = "take_lottery_award_rsp",
      handler = "HalloweenVehicleHandler"
    },
    [1548272533] = {
      res = "notify_hy_lottery_award",
      handler = "HalloweenVehicleHandler"
    },
    [1838863340] = {
      req = "hy_lottery",
      res = "hy_lottery_rsp",
      handler = "HalloweenVehicleHandler"
    },
    [327744679] = {
      req = "manor_style_select_recommend_req",
      res = "manor_style_select_recommend_rsp",
      timeInterval = 3,
      handler = "HomeStylePKHandler"
    },
    [431681323] = {
      req = "manor_style_select_nominate_req",
      res = "manor_style_select_nominate_rsp",
      timeInterval = 1,
      handler = "HomeStylePKHandler"
    },
    [801670119] = {
      req = "manor_style_select_award_req",
      res = "manor_style_select_award_rsp",
      timeInterval = 1,
      handler = "HomeStylePKHandler"
    },
    [962776543] = {
      req = "manor_style_select_data_req",
      res = "manor_style_select_data_rsp",
      timeInterval = 2,
      handler = "HomeStylePKHandler"
    },
    [1528032403] = {
      req = "manor_style_select_cash_req",
      res = "manor_style_select_cash_rsp",
      timeInterval = 1,
      handler = "HomeStylePKHandler"
    },
    [292672423] = {
      req = "honour_cert_set_hide_req",
      res = "honour_cert_set_hide_rsp",
      handler = "HonourCertificateHandler"
    },
    [797985287] = {
      req = "honour_cert_get_cert_list_req",
      res = "honour_cert_get_cert_list_rsp",
      handler = "HonourCertificateHandler"
    },
    [1855571331] = {
      req = "honour_cert_get_version_req",
      res = "honour_cert_get_version_rsp",
      handler = "HonourCertificateHandler"
    },
    [1041557767] = {
      req = "ios_cancle_del_account_req",
      res = "ios_cancle_del_account_rsp",
      inGameOper = 0,
      handler = "IOSDeleteHandler"
    },
    [1344131559] = {
      req = "ios_del_account_req",
      res = "ios_del_account_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "IOSDeleteHandler"
    },
    [22203783] = {
      req = "act_ice_drink_take_first_award_req",
      res = "act_ice_drink_take_first_award_rsp",
      timeout = 5,
      handler = "IceDrinkHandler"
    },
    [136529127] = {
      req = "act_ice_drink_compound_req",
      res = "act_ice_drink_compound_rsp",
      timeout = 5,
      handler = "IceDrinkHandler"
    },
    [1529600355] = {
      req = "act_ice_drink_collect_ice_req",
      res = "act_ice_drink_collect_ice_rsp",
      timeout = 5,
      handler = "IceDrinkHandler"
    },
    [1563559655] = {
      req = "act_ice_drink_take_collect_award_req",
      res = "act_ice_drink_take_collect_award_rsp",
      timeout = 5,
      handler = "IceDrinkHandler"
    },
    [1721272783] = {
      req = "act_ice_drink_carry_req",
      res = "act_ice_drink_carry_rsp",
      timeout = 5,
      handler = "IceDrinkHandler"
    },
    [889866882] = {
      res = "sync_inherit_data",
      handler = "InheritHandle"
    },
    [1720583527] = {
      req = "get_inherit_data_req",
      res = "get_inherit_data_rsp",
      handler = "InheritHandle"
    },
    [2085650334] = {
      res = "notify_clear_inherit_items",
      handler = "InheritHandle"
    },
    [55849819] = {
      req = "get_lobby_intimacy_partner_info_req",
      res = "get_lobby_intimacy_partner_info_rsp",
      handler = "IntimacyRewardHandler"
    },
    [180539621] = {
      res = "notify_new_partner_reward",
      handler = "IntimacyRewardHandler"
    },
    [496449054] = {
      res = "notify_interact_avatar_posture_chg",
      handler = "IntimacyRewardHandler"
    },
    [660533031] = {
      req = "get_partner_reward_req",
      res = "get_partner_reward_rsp",
      handler = "IntimacyRewardHandler"
    },
    [1068175769] = {
      res = "notify_posture_chg",
      handler = "IntimacyRewardHandler"
    },
    [1459551791] = {
      req = "set_posture_req",
      res = "set_posture_rsp",
      handler = "IntimacyRewardHandler"
    },
    [1911018855] = {
      req = "get_posture_info_req",
      res = "get_posture_info_rsp",
      handler = "IntimacyRewardHandler"
    },
    [104623399] = {
      req = "upgrade_item_req",
      res = "upgrade_item_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "ItemUpGradeHandler"
    },
    [403929247] = {
      req = "taluo_get_dress_change_gun_flag_req",
      res = "taluo_get_dress_change_gun_flag_rsp",
      handler = "ItemUpGradeHandler"
    },
    [445952103] = {
      req = "set_item_upgrade_switch_info_req",
      res = "set_item_upgrade_switch_info_rsp",
      handler = "ItemUpGradeHandler"
    },
    [698978159] = {
      req = "taluo_set_dress_change_gun_flag_req",
      res = "taluo_set_dress_change_gun_flag_rsp",
      handler = "ItemUpGradeHandler"
    },
    [702130559] = {
      req = "upgrade_refit_req",
      res = "upgrade_refit_rsp",
      inGameOper = 0,
      handler = "ItemUpGradeHandler"
    },
    [789363799] = {
      req = "set_weapon_audio_volume_req",
      res = "set_weapon_audio_volume_rsp",
      handler = "ItemUpGradeHandler"
    },
    [843168295] = {
      req = "upgrade_unlock_accessory_req",
      res = "upgrade_unlock_accessory_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "ItemUpGradeHandler"
    },
    [1073047439] = {
      res = "upgrade_accessory_notify",
      inGameOper = 0,
      handler = "ItemUpGradeHandler"
    },
    [1227310835] = {
      req = "upgrade_query_refit_req",
      res = "upgrade_query_refit_rsp",
      inGameOper = 0,
      handler = "ItemUpGradeHandler"
    },
    [1232171623] = {
      req = "upgrade_unlock_refit_req",
      res = "upgrade_unlock_refit_rsp",
      inGameOper = 0,
      handler = "ItemUpGradeHandler"
    },
    [1303324775] = {
      req = "set_gun_upgrade_parts_switch_req",
      res = "set_gun_upgrade_parts_switch_rsp",
      handler = "ItemUpGradeHandler"
    },
    [1475477299] = {
      req = "upgrade_query_accessory_req",
      res = "upgrade_query_accessory_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "ItemUpGradeHandler"
    },
    [1687811883] = {
      req = "taluo_change_gun_with_dress_req",
      res = "taluo_change_gun_with_dress_rsp",
      handler = "ItemUpGradeHandler"
    },
    [625357543] = {
      req = "jp_set_birthtime_req",
      res = "jp_set_birthtime_rsp",
      handler = "JPAgeHandler"
    },
    [723553767] = {
      req = "upvote_item_design_point_req",
      res = "upvote_item_design_point_rsp",
      handler = "KDPHandler"
    },
    [876667047] = {
      req = "get_item_design_point_info_req",
      res = "get_item_design_point_info_rsp",
      handler = "KDPHandler"
    },
    [2086360487] = {
      req = "get_design_point_upvote_status_req",
      res = "get_design_point_upvote_status_rsp",
      handler = "KDPHandler"
    },
    [1692587559] = {
      req = "last_kill_special_effects_oper_req",
      res = "last_kill_special_effects_oper_rsp",
      isUnique = 1,
      handler = "KillFeatureHandler"
    },
    [1968179343] = {
      req = "get_last_kill_special_effects_req",
      res = "get_last_kill_special_effects_rsp",
      timeInterval = 1,
      handler = "KillFeatureHandler"
    },
    [1982414663] = {
      req = "get_accumulation_kill_info_req",
      res = "get_accumulation_kill_info_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "KillFeatureHandler"
    },
    [2114581831] = {
      req = "arm_accumulate_feature_req",
      res = "arm_accumulate_feature_rsp",
      isUnique = 1,
      handler = "KillFeatureHandler"
    },
    [133420351] = {
      res = "lbs_nearly_notify_online_status_chg",
      handler = "LBSHandler"
    },
    [209999267] = {
      req = "lbs_set_zone_by_gps_req",
      res = "lbs_set_zone_by_gps_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "LBSHandler"
    },
    [284810791] = {
      req = "lbs_get_gps_zone_req",
      res = "lbs_get_gps_zone_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "LBSHandler"
    },
    [375970475] = {
      res = "lbs_sync_rsp",
      handler = "LBSHandler"
    },
    [553156071] = {
      req = "lbs_set_privacy_req",
      res = "lbs_set_privacy_rsp",
      inGameOper = 0,
      handler = "LBSHandler"
    },
    [646478972] = {
      req = "set_title_not_new",
      res = "set_title_not_new_rsp",
      handler = "LBSHandler"
    },
    [903838259] = {
      res = "lbs_nearly_notify_group_status_chg",
      handler = "LBSHandler"
    },
    [1187166795] = {
      req = "get_lbs_potential_title_req",
      res = "get_lbs_potential_title_rsp",
      inGameOper = 0,
      handler = "LBSHandler"
    },
    [1230680703] = {
      req = "lbs_nearly_player_req",
      res = "lbs_nearly_player_rsp",
      handler = "LBSHandler"
    },
    [1893135271] = {
      req = "lbs_set_zone_req",
      res = "lbs_set_zone_rsp",
      inGameOper = 0,
      handler = "LBSHandler"
    },
    [59987411] = {
      req = "ugc_llm_chat_clear_sessions_req",
      res = "ugc_llm_chat_clear_sessions_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [391563235] = {
      req = "ugc_llm_one_chat_v2_req",
      res = "ugc_llm_one_chat_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [447748967] = {
      req = "ugc_llm_client_code_result_req",
      res = "ugc_llm_client_code_result_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [627297821] = {
      res = "ugc_llm_agent_res_finish_ntf",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [699113383] = {
      req = "ugc_llm_get_recommend_v2_req",
      res = "ugc_llm_get_recommend_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [943877799] = {
      req = "ugc_llm_chat_stop_v2_req",
      res = "ugc_llm_chat_stop_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [970055367] = {
      req = "ugc_llm_report_v2_req",
      res = "ugc_llm_report_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1055887615] = {
      req = "ugc_llm_client_result_req",
      res = "ugc_llm_client_result_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1122577031] = {
      req = "ugc_llm_chat_op_result_req",
      res = "ugc_llm_chat_op_result_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1203510071] = {
      req = "ugc_llm_chat_message_v2_req",
      res = "ugc_llm_chat_message_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1228218795] = {
      req = "ugc_get_llm_agent_data_v2_req",
      res = "ugc_get_llm_agent_data_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1321099783] = {
      req = "ugc_llm_client_interact_result_req",
      res = "ugc_llm_client_interact_result_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1429595143] = {
      req = "ugc_llm_chat_switch_v2_req",
      res = "ugc_llm_chat_switch_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1500954212] = {
      res = "ugc_llm_edit_auto_eva_ntf",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1727247847] = {
      req = "ugc_llm_chat_rating_v2_req",
      res = "ugc_llm_chat_rating_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1882725247] = {
      req = "ugc_llm_get_sessions_v2_req",
      res = "ugc_llm_get_sessions_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [1934726431] = {
      req = "ugc_use_llm_card_v2_req",
      res = "ugc_use_llm_card_v2_rsp",
      inGameOper = 0,
      handler = "LLMHandler"
    },
    [395563623] = {
      req = "random_award_req",
      res = "random_award_rsp",
      handler = "LadderDrawHandler"
    },
    [788426151] = {
      req = "rotate_req",
      res = "rotate_rsp",
      isLock = 1,
      handler = "LadderDrawHandler"
    },
    [1347091527] = {
      req = "recv_award_req",
      res = "recv_award_rsp",
      isLock = 1,
      handler = "LadderDrawHandler"
    },
    [512934919] = {
      req = "set_player_match_langs_req",
      res = "set_player_match_langs_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "LanguageHandler"
    },
    [728609639] = {
      req = "set_player_langs_req",
      res = "set_player_langs_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "LanguageHandler"
    },
    [1863627591] = {
      req = "set_player_ugc_match_langs_req",
      res = "set_player_ugc_match_langs_rsp",
      handler = "LanguageHandler"
    },
    [592944380] = {
      req = "set_lgd_wpn",
      res = "set_lgd_wpn_rsp",
      handler = "LegendWeaponHandler"
    },
    [52057255] = {
      req = "get_casual_segment_reward_data_req",
      res = "get_casual_segment_reward_data_rsp",
      handler = "LeisureSeasonHandler"
    },
    [223168437] = {
      res = "notify_casual_shop_exchange_data",
      handler = "LeisureSeasonHandler"
    },
    [349245371] = {
      req = "batch_take_casual_segment_award_req",
      res = "batch_take_casual_segment_award_rsp",
      timeInterval = 1,
      handler = "LeisureSeasonHandler"
    },
    [535856615] = {
      req = "batch_take_casual_task_award_req",
      res = "batch_take_casual_task_award_rsp",
      timeInterval = 1,
      handler = "LeisureSeasonHandler"
    },
    [571949415] = {
      req = "take_casual_task_award_req",
      res = "take_casual_task_award_rsp",
      timeInterval = 1,
      handler = "LeisureSeasonHandler"
    },
    [695466583] = {
      req = "get_casual_segment_integral_req",
      res = "get_casual_segment_integral_rsp",
      handler = "LeisureSeasonHandler"
    },
    [826277956] = {
      res = "notify_casual_segment_award_flag",
      inGameOper = 0,
      handler = "LeisureSeasonHandler"
    },
    [1214189479] = {
      req = "get_history_casual_season_record_req",
      res = "get_history_casual_season_record_rsp",
      handler = "LeisureSeasonHandler"
    },
    [1330744927] = {
      req = "take_casual_segment_award_req",
      res = "take_casual_segment_award_rsp",
      timeInterval = 1,
      handler = "LeisureSeasonHandler"
    },
    [1524709095] = {
      req = "casual_shop_exchange_req",
      res = "casual_shop_exchange_rsp",
      handler = "LeisureSeasonHandler"
    },
    [1579105575] = {
      req = "get_casual_task_status_req",
      res = "get_casual_task_status_rsp",
      handler = "LeisureSeasonHandler"
    },
    [1592624488] = {
      res = "notify_casual_task_award_flag",
      inGameOper = 0,
      handler = "LeisureSeasonHandler"
    },
    [2026156752] = {
      res = "notify_casual_segment_info",
      inGameOper = 0,
      handler = "LeisureSeasonHandler"
    },
    [779697351] = {
      req = "psmatch_team_modify_light_board_req",
      res = "psmatch_team_modify_light_board_rsp",
      handler = "LightBoardHander"
    },
    [951144600] = {
      res = "psmatch_team_mod_nick_name_ntf",
      handler = "LightBoardHander"
    },
    [1042744551] = {
      req = "read_new_light_board_req",
      res = "read_new_light_board_rsp",
      handler = "LightBoardHander"
    },
    [1069279649] = {
      res = "psmatch_team_level_change_ntf",
      handler = "LightBoardHander"
    },
    [1271528079] = {
      req = "psmatch_team_light_board_list_req",
      res = "psmatch_team_light_board_list_rsp",
      handler = "LightBoardHander"
    },
    [1350445991] = {
      req = "psmatch_team_equip_light_board_req",
      res = "psmatch_team_equip_light_board_rsp",
      handler = "LightBoardHander"
    },
    [1475654848] = {
      res = "new_get_light_board_ntf",
      handler = "LightBoardHander"
    },
    [1429665767] = {
      req = "get_keep_stay_bubble_req",
      res = "get_keep_stay_bubble_rsp",
      handler = "LobbyBubbleHandler"
    },
    [746503] = {
      req = "get_nick_name_for_register_req",
      res = "get_nick_name_for_register_rsp",
      timeInterval = 6,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [159427895] = {
      req = "close_top_red_point_req",
      res = "close_top_red_point_rsp",
      handler = "LobbyHandler"
    },
    [187819879] = {
      req = "agree_new_privacy_policy_req",
      res = "agree_new_privacy_policy_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [266639550] = {
      res = "notify_get_pgs_info",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [302308398] = {
      req = "query_gm_request",
      res = "query_gm_respond",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [304197294] = {
      res = "avatar_feature_notify",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [316784120] = {
      req = "check_account_bind_info_req",
      res = "check_account_bind_info_res",
      isUnique = 1,
      isLock = 1,
      timeout = 10,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [351654655] = {
      res = "need_vietnam_user_extry_info",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [355550859] = {
      req = "report_pgs_info_req",
      res = "report_pgs_info_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [393538193] = {
      res = "sync_social_avatar",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [405316045] = {
      req = "on_zeus_update_rsp",
      res = "on_zeus_update_ntf",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [445021096] = {
      res = "remind_window_pop",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [462070059] = {
      res = "re_match_sync",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [485858647] = {
      res = "social_unbind_tips_notify",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [509964007] = {
      req = "commerce_entrance_info_req",
      res = "commerce_entrance_info_rsp",
      handler = "LobbyHandler"
    },
    [543434562] = {
      res = "sync_my_plat_name",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [577982243] = {
      req = "report_system_entrance_info_req",
      res = "report_system_entrance_info_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [594069509] = {
      req = "get_championship_info",
      res = "championship_info_notify",
      handler = "LobbyHandler"
    },
    [597734332] = {
      req = "get_release_notes",
      res = "get_release_notes_rsp",
      handler = "LobbyHandler"
    },
    [604304808] = {
      req = "cutscenes_report",
      res = "get_cutscenes_award_rsp",
      handler = "LobbyHandler"
    },
    [672028479] = {
      res = "pet_module_close_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [701875991] = {
      res = "privacy_policy_pop_up",
      handler = "LobbyHandler"
    },
    [707957290] = {
      res = "add_battle_item_notify",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [790892615] = {
      req = "get_replay_downstream_urls_req",
      res = "get_replay_downstream_urls_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [819929282] = {
      res = "team_change_type_mil_ban_notify",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [832403234] = {
      res = "notice_some_no_map",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [852691120] = {
      req = "fetch_nation_switch_req",
      res = "fetch_nation_switch_res",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [963296518] = {
      res = "please_create_role",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [975101514] = {
      req = "refresh_account_bind_req",
      handler = "LobbyHandler"
    },
    [975544812] = {
      res = "unbind_social_acc_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [981008725] = {
      res = "sync_player_ban",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1006932955] = {
      res = "gm_version",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1041006383] = {
      req = "batch_buy_avatar_features_req",
      res = "batch_buy_avatar_features_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1049156263] = {
      req = "room_kick_no_map_req",
      res = "room_kick_no_map_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1071989376] = {
      req = "report_net_trace_infos",
      handler = "LobbyHandler"
    },
    [1072186713] = {
      req = "on_hades_update_rsp",
      res = "on_hades_update_ntf",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1142862887] = {
      req = "depot_get_default_ware_req",
      res = "depot_get_default_ware_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1153077852] = {
      res = "sync_base_info",
      inGameOper = 2,
      handler = "LobbyHandler"
    },
    [1242115143] = {
      req = "get_valid_nickname_list_req",
      res = "get_valid_nickname_list_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1259197824] = {
      res = "notify_mil_label_changed",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1286431279] = {
      req = "set_custom_presentation_req",
      res = "set_custom_presentation_rsp",
      handler = "LobbyHandler"
    },
    [1307483133] = {
      res = "dalay_ban_text",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1337107063] = {
      req = "get_backup_ip_req",
      res = "get_backup_ip_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1338657196] = {
      req = "get_official_media",
      res = "get_official_media_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1344772556] = {
      res = "anchor_white_cfg_notify",
      handler = "LobbyHandler"
    },
    [1358366683] = {
      req = "unbind_social_account_req",
      res = "unbind_social_account_rsp",
      isUnique = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1368962459] = {
      req = "client_timeout_report_req",
      res = "client_timeout_report_rsp",
      handler = "LobbyHandler"
    },
    [1435945011] = {
      req = "get_bubble_info_req",
      res = "get_bubble_info_rsp",
      timeInterval = 5,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1474252032] = {
      req = "get_client_basic_cfg",
      handler = "LobbyHandler"
    },
    [1489611839] = {
      res = "loadpic_cfg_refresh",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1521143914] = {
      req = "set_knapsack_pos_show_req",
      res = "set_knapsack_show_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1527736167] = {
      res = "modify_role_face_respond",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1619279154] = {
      req = "enter_big_event",
      handler = "LobbyHandler"
    },
    [1639504053] = {
      req = "gm_mtr_begin",
      res = "mtr_begin",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1641273799] = {
      req = "get_unbind_social_info_req",
      res = "get_unbind_social_info_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1652131277] = {
      res = "posidon_update_ntf",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1700303217] = {
      res = "notify_get_rela_err",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1844810238] = {
      req = "lobby_stay_time_report_req",
      handler = "LobbyHandler"
    },
    [1900475179] = {
      req = "report_loading_pic_req",
      handler = "LobbyHandler"
    },
    [1905734597] = {
      res = "sync_depot_item_info",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1924849987] = {
      res = "sync_depot_info",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1941756295] = {
      req = "update_buy_avatar_features_req",
      res = "update_buy_avatar_features_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1945622690] = {
      req = "get_top_red_point_req",
      res = "top_red_point_notify",
      handler = "LobbyHandler"
    },
    [1951187399] = {
      req = "modify_newbie_info_req",
      res = "modify_newbie_info_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [2017227285] = {
      req = "quit_big_event",
      handler = "LobbyHandler"
    },
    [2025474135] = {
      req = "validate_nickname_req",
      res = "validate_nickname_rsp",
      timeInterval = 6,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [2033295399] = {
      req = "get_account_bind_req",
      res = "get_account_bind_rsp",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [2073891688] = {
      req = "create_role_request",
      res = "create_role_respond",
      isLock = 1,
      timeInterval = 6,
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [2088473431] = {
      res = "client_trace",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [2092791295] = {
      req = "newbie_createrole_get_rewards_req",
      res = "newbie_createrole_get_rewards_rsp",
      handler = "LobbyHandler"
    },
    [2101584442] = {
      req = "mtr_report",
      handler = "LobbyHandler"
    },
    [2142824954] = {
      req = "on_match_cancel_req",
      res = "on_match_cancel_res",
      inGameOper = 0,
      handler = "LobbyHandler"
    },
    [1082261001] = {
      res = "manor_tree_active_notify",
      handler = "LobbyHomeEntryItemHandler"
    },
    [1285217309] = {
      res = "manor_tree_active_off_notify",
      handler = "LobbyHomeEntryItemHandler"
    },
    [1301098499] = {
      res = "manor_visit_owner_off_notify",
      handler = "LobbyHomeEntryItemHandler"
    },
    [1584448163] = {
      res = "manor_leave_message_off_notify",
      handler = "LobbyHomeEntryItemHandler"
    },
    [1587592871] = {
      res = "manor_visit_owner_notify",
      handler = "LobbyHomeEntryItemHandler"
    },
    [1610966962] = {
      res = "manor_mystery_man_notify",
      handler = "LobbyHomeEntryItemHandler"
    },
    [1797877927] = {
      res = "manor_leave_message_notify",
      handler = "LobbyHomeEntryItemHandler"
    },
    [516985564] = {
      req = "report_lobby_ping",
      res = "report_lobby_ping_rsp",
      inGameOper = 0,
      handler = "LobbyPingReportHandler"
    },
    [25431509] = {
      res = "notify_popup_collection_sys",
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [138379813] = {
      res = "notify_pre_collection_status",
      handler = "LobbySouvenirsHandler"
    },
    [184756839] = {
      req = "set_collection_in_show_req",
      res = "set_collection_in_show_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [385000947] = {
      req = "get_collection_sys_data_req",
      res = "get_collection_sys_data_rsp",
      handler = "LobbySouvenirsHandler"
    },
    [538365270] = {
      res = "notify_collection_unfreeze_event",
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [689330279] = {
      req = "buy_collection_req",
      res = "buy_collection_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [733153415] = {
      req = "unfreeze_collection_req",
      res = "unfreeze_collection_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [1161704591] = {
      res = "notify_collection_currency_change",
      handler = "LobbySouvenirsHandler"
    },
    [1264834151] = {
      req = "unlock_collection_extra_item_req",
      res = "unlock_collection_extra_item_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [1429943559] = {
      req = "set_progressed_collection_seen_req",
      res = "set_progressed_collection_seen_rsp",
      handler = "LobbySouvenirsHandler"
    },
    [1567700169] = {
      res = "notify_add_collection_motion",
      handler = "LobbySouvenirsHandler"
    },
    [1607721271] = {
      res = "notify_collection_status_update",
      handler = "LobbySouvenirsHandler"
    },
    [1898879719] = {
      req = "share_collection_req",
      res = "share_collection_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [2134033191] = {
      req = "exchange_collection_currency_req",
      res = "exchange_collection_currency_rsp",
      inGameOper = 0,
      handler = "LobbySouvenirsHandler"
    },
    [14417437] = {
      req = "set_watch_switch",
      handler = "LobbyWatchingHandler"
    },
    [308836260] = {
      req = "leave_battle_watch",
      handler = "LobbyWatchingHandler"
    },
    [369103987] = {
      req = "enter_battle_watch",
      handler = "LobbyWatchingHandler"
    },
    [1149962314] = {
      req = "begin_hawkeye_inspect_req",
      handler = "LobbyWatchingHandler"
    },
    [1212422347] = {
      req = "set_player_pcob_api_req",
      res = "set_player_pcob_api_rsp",
      inGameOper = 0,
      handler = "LobbyWatchingHandler"
    },
    [1441749377] = {
      req = "set_watch_privacy",
      handler = "LobbyWatchingHandler"
    },
    [518110759] = {
      req = "report_popui_show_info_req",
      res = "report_popui_show_info_rsp",
      handler = "LogicLobbyPopuiHandler"
    },
    [960434343] = {
      req = "get_popui_show_count_req",
      res = "get_popui_show_count_rsp",
      handler = "LogicLobbyPopuiHandler"
    },
    [1592193003] = {
      res = "cloud_game_event_notify",
      handler = "LoginAndWinTlogHandler"
    },
    [55694759] = {
      req = "get_web_login_code_req",
      res = "get_web_login_code_rsp",
      handler = "LoginHandler"
    },
    [200953959] = {
      req = "check_online_req",
      res = "check_online_rsp",
      isLock = 1,
      handler = "LoginHandler"
    },
    [205207404] = {
      req = "set_fresher_info_req",
      handler = "LoginHandler"
    },
    [237135783] = {
      req = "set_vietnam_user_req",
      res = "set_vietnam_user_rsp",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [240135207] = {
      req = "get_fresher_info_req",
      res = "get_fresher_info_rsp",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [423912716] = {
      req = "logout",
      res = "logout_rsp",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [464934988] = {
      res = "notify_game_aas_ban",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [506486974] = {
      res = "get_client_basic_cfg_rsp",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [695547322] = {
      res = "redirect",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [766648687] = {
      req = "query_qrcode_grant_list_req",
      res = "query_qrcode_grant_list_rsp",
      handler = "LoginHandler"
    },
    [902068567] = {
      req = "start_scan_qrcode_req",
      res = "start_scan_qrcode_rsp",
      handler = "LoginHandler"
    },
    [909295372] = {
      res = "send_last_logout_time",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1096641623] = {
      req = "competition_login",
      res = "competition_login_res",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1177822163] = {
      res = "login_failed",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1354347451] = {
      res = "notify_game_rest_force",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1384586736] = {
      res = "need_show_first_in_vietnam",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1405487677] = {
      req = "query_lobby_info",
      res = "sync_lobby_info",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1493160183] = {
      res = "login_next",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1506006923] = {
      req = "get_qrcode_login_data_req",
      res = "get_qrcode_login_data_rsp",
      handler = "LoginHandler"
    },
    [1588674303] = {
      res = "notify_game_rest_remind",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1662221415] = {
      req = "qrcode_login_func_limit_req",
      res = "qrcode_login_func_limit_rsp",
      handler = "LoginHandler"
    },
    [1821316883] = {
      res = "account_bind_info_change_notify",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1828975710] = {
      req = "login",
      res = "login_rsp",
      timeInterval = 6,
      inGameOper = 0,
      isLock = 1,
      handler = "LoginHandler"
    },
    [1874944336] = {
      res = "kickout",
      inGameOper = 0,
      handler = "LoginHandler"
    },
    [1955303451] = {
      req = "delete_qrcode_token_req",
      res = "delete_qrcode_token_rsp",
      handler = "LoginHandler"
    },
    [2100647160] = {
      req = "get_two_step_download_reward_req",
      handler = "LoginHandler"
    },
    [101927898] = {
      req = "delete_trusted_device_req",
      res = "delete_trusted_device_res",
      isLock = 1,
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [182535346] = {
      res = "verify_code_check_notify",
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [246157490] = {
      req = "verify_code_check_login_req",
      res = "verify_code_check_login_res",
      isLock = 1,
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [252851343] = {
      req = "account_social_bind_req",
      res = "account_social_bind_rsp",
      handler = "LoginVerifyHandler"
    },
    [319686823] = {
      req = "verify_code_send_check_req",
      res = "verify_code_send_check_rsp",
      handler = "LoginVerifyHandler"
    },
    [325987943] = {
      req = "batch_get_user_names_req",
      res = "batch_get_user_names_rsp",
      handler = "LoginVerifyHandler"
    },
    [408918815] = {
      req = "account_modify_sacc_req",
      res = "account_modify_sacc_rsp",
      handler = "LoginVerifyHandler"
    },
    [697910472] = {
      req = "gen_new_spare_code_req",
      res = "gen_new_spare_code_res",
      isLock = 1,
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [872233800] = {
      req = "send_imobile_verify_code_req",
      res = "send_imobile_verify_code_res",
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [1143172248] = {
      req = "verify_code_switch_change_req",
      res = "verify_code_switch_change_res",
      isLock = 1,
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [1276863877] = {
      res = "busi_security_info_notify",
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [1500725021] = {
      res = "notify_account_security_change",
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [1504638562] = {
      res = "account_group_info_notify",
      handler = "LoginVerifyHandler"
    },
    [1642126064] = {
      req = "account_security_open_req",
      res = "account_security_open_res",
      isLock = 1,
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [1818380232] = {
      req = "get_account_security_req",
      res = "get_account_security_res",
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [1821687207] = {
      req = "report_notice_readed_req",
      res = "report_notice_readed_rsp",
      handler = "LoginVerifyHandler"
    },
    [1823044419] = {
      req = "account_bind_sacc_req",
      res = "account_bind_sacc_rsp",
      handler = "LoginVerifyHandler"
    },
    [1900615237] = {
      req = "report_account_bind_log",
      handler = "LoginVerifyHandler"
    },
    [1932904031] = {
      req = "get_security_op_list_req",
      handler = "LoginVerifyHandler"
    },
    [1966995016] = {
      req = "account_security_close_req",
      res = "account_security_close_res",
      isLock = 1,
      inGameOper = 0,
      handler = "LoginVerifyHandler"
    },
    [2127406935] = {
      req = "report_account_group_log",
      handler = "LoginVerifyHandler"
    },
    [480057639] = {
      req = "buy_luck_airdrop_req",
      res = "buy_luck_airdrop_rsp",
      isLock = 1,
      handler = "LuckAirDropHandler"
    },
    [549813956] = {
      req = "report_luck_airdrop_statistics",
      handler = "LuckAirDropHandler"
    },
    [857286632] = {
      req = "target_airdrop_trigger_req",
      res = "target_airdrop_trigger_res",
      handler = "LuckAirDropHandler"
    },
    [1077644359] = {
      req = "target_airdrop_buy_req",
      res = "target_airdrop_buy_rsp",
      handler = "LuckAirDropHandler"
    },
    [1164937833] = {
      res = "sync_luck_airdrop",
      handler = "LuckAirDropHandler"
    },
    [1629629772] = {
      req = "get_luck_airdrop_info_after_ad",
      res = "get_luck_airdrop_info_after_ad_rsp",
      handler = "LuckAirDropHandler"
    },
    [1908553094] = {
      res = "target_airdrop_info_notify",
      handler = "LuckAirDropHandler"
    },
    [2140118583] = {
      req = "set_luck_airdrop_item_score_req",
      res = "set_luck_airdrop_item_score_rsp",
      handler = "LuckAirDropHandler"
    },
    [146119271] = {
      req = "get_double_draw_activity_req",
      res = "get_double_draw_activity_rsp",
      handler = "LuckyDoubleHandler"
    },
    [414385575] = {
      req = "double_draw_discount_by_activity_req",
      res = "double_draw_discount_by_activity_rsp",
      isLock = 1,
      handler = "LuckyDoubleHandler"
    },
    [1018293095] = {
      req = "double_draw_activity_req",
      res = "double_draw_activity_rsp",
      isUnique = 1,
      isLock = 1,
      handler = "LuckyDoubleHandler"
    },
    [1699809135] = {
      req = "double_draw_on_shot_req",
      res = "double_draw_on_shot_rsp",
      isUnique = 1,
      isLock = 1,
      handler = "LuckyDoubleHandler"
    },
    [620217751] = {
      req = "do_draw_act_req",
      res = "do_draw_act_rsp",
      queueType = 1,
      isLock = 1,
      timeInterval = 1,
      handler = "LuckySpecialHandler"
    },
    [1106171367] = {
      req = "get_collected_reward_req",
      res = "get_collected_reward_rsp",
      handler = "LuckySpecialHandler"
    },
    [1568979703] = {
      req = "get_draw_act_info_req",
      res = "get_draw_act_info_rsp",
      queueType = 1,
      isLock = 1,
      timeInterval = 1,
      handler = "LuckySpecialHandler"
    },
    [1630625127] = {
      req = "get_extra_reward_req",
      res = "get_extra_reward_rsp",
      queueType = 1,
      isLock = 1,
      timeInterval = 1,
      handler = "LuckySpecialHandler"
    },
    [1747972263] = {
      req = "do_draw_discount_req",
      res = "do_draw_discount_rsp",
      handler = "LuckySpecialHandler"
    },
    [1824978567] = {
      req = "get_draw_sum_reward_req",
      res = "get_draw_sum_reward_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "LuckySpecialHandler"
    },
    [504285378] = {
      res = "fu_xing_online_notify",
      handler = "LuckyStarHandler"
    },
    [1736084647] = {
      req = "team_fu_xing_req",
      res = "team_fu_xing_rsp",
      handler = "LuckyStarHandler"
    },
    [581313127] = {
      req = "get_exchange_activity_info_req",
      res = "get_exchange_activity_info_rsp",
      isLock = 1,
      timeout = 10,
      handler = "LuckybackHandler"
    },
    [695104167] = {
      req = "get_lucky_draw_back_activity_req",
      res = "get_lucky_draw_back_activity_rsp",
      isUnique = 1,
      isLock = 1,
      timeout = 5,
      needRsp = 3,
      handler = "LuckybackHandler"
    },
    [745299879] = {
      req = "do_exchange_by_activity_id_req",
      res = "do_exchange_by_activity_id_rsp",
      isLock = 1,
      handler = "LuckybackHandler"
    },
    [1020051431] = {
      req = "get_lucky_draw_back_voucher_req",
      res = "get_lucky_draw_back_voucher_rsp",
      handler = "LuckybackHandler"
    },
    [1183033974] = {
      res = "get_lucky_draw_back_redpoint_rsp",
      inGameOper = 0,
      handler = "LuckybackHandler"
    },
    [1355510887] = {
      req = "get_sum_draw_award_by_activity_req",
      res = "get_sum_draw_award_by_activity_rsp",
      handler = "LuckybackHandler"
    },
    [1478162855] = {
      req = "do_one_draw_back_by_activity_req",
      res = "do_one_draw_back_by_activity_rsp",
      isUnique = 1,
      isLock = 1,
      timeInterval = 0.5,
      handler = "LuckybackHandler"
    },
    [1494187987] = {
      req = "draw_exchange_discount_by_actid_req",
      res = "draw_exchange_discount_by_actid_rsp",
      handler = "LuckybackHandler"
    },
    [1890567399] = {
      req = "get_lucky_draw_collect_award_req",
      res = "get_lucky_draw_collect_award_rsp",
      isLock = 1,
      handler = "LuckybackHandler"
    },
    [2011924111] = {
      req = "car_compose_req",
      res = "car_compose_rsp",
      inGameOper = 0,
      handler = "LuckybackHandler"
    },
    [2029256911] = {
      req = "do_one_to_batch_exchange_by_activity_id_req",
      res = "do_one_to_batch_exchange_by_activity_id_rsp",
      handler = "LuckybackHandler"
    },
    [86742451] = {
      req = "settl_motion_info_req",
      res = "settl_motion_info_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "MVPMotionHander"
    },
    [891304463] = {
      req = "put_on_settl_motion_req",
      res = "put_on_settl_motion_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "MVPMotionHander"
    },
    [472158123] = {
      req = "batch_fetch_friend_mail_req",
      res = "batch_fetch_friend_mail_rsp",
      handler = "MailHandler"
    },
    [629923815] = {
      req = "delete_account_bind_req",
      res = "delete_account_bind_rsp",
      handler = "MailHandler"
    },
    [653577495] = {
      req = "on_query_mail_summary",
      res = "on_query_mail_summary_res",
      queueType = 1,
      handler = "MailHandler"
    },
    [801897474] = {
      req = "exec",
      res = "echo",
      inGameOper = 0,
      handler = "MailHandler"
    },
    [959584716] = {
      res = "on_new_mail_notify",
      handler = "MailHandler"
    },
    [1372154611] = {
      req = "on_query_mail_summary_v2",
      res = "on_query_mail_summary_v2_res",
      handler = "MailHandler"
    },
    [1613255579] = {
      req = "on_delete_mail_list",
      res = "on_delete_mail_list_res",
      handler = "MailHandler"
    },
    [1626423949] = {
      req = "on_fetch_mail_attach",
      res = "on_fetch_attach_res",
      isUnique = 1,
      handler = "MailHandler"
    },
    [1876302299] = {
      req = "on_read_mail_list",
      handler = "MailHandler"
    },
    [1934347914] = {
      req = "batch_fetch_all_mail_req",
      res = "batch_fetch_all_attach_res",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "MailHandler"
    },
    [2001664738] = {
      res = "report_result_mail_notify",
      inGameOper = 0,
      handler = "MailHandler"
    },
    [2135051847] = {
      req = "on_set_mail_readflag",
      handler = "MailHandler"
    },
    [885028359] = {
      req = "h5_platform_task_reward_all_req",
      res = "h5_platform_task_reward_all_rsp",
      inGameOper = 0,
      handler = "MainCityCharmHandler"
    },
    [1248107239] = {
      req = "mc_get_charm_value_req",
      res = "mc_get_charm_value_rsp",
      inGameOper = 0,
      handler = "MainCityCharmHandler"
    },
    [1546796559] = {
      req = "h5_platform_task_reward_req",
      res = "h5_platform_task_reward_rsp",
      inGameOper = 0,
      handler = "MainCityCharmHandler"
    },
    [1776666423] = {
      req = "mc_report_charm_value_req",
      res = "mc_report_charm_value_rsp",
      inGameOper = 0,
      handler = "MainCityCharmHandler"
    },
    [1882839079] = {
      req = "h5_platform_task_req",
      res = "h5_platform_task_rsp",
      inGameOper = 0,
      handler = "MainCityCharmHandler"
    },
    [216468327] = {
      req = "mc_follow_player_req",
      res = "mc_follow_player_rsp",
      handler = "MainCityHandler"
    },
    [484615463] = {
      req = "mc_common_set_switch_req",
      res = "mc_common_set_switch_rsp",
      inGameOper = 0,
      handler = "MainCityHandler"
    },
    [507851275] = {
      req = "enter_main_city_req",
      res = "enter_main_city_rsp",
      inGameOper = 0,
      handler = "MainCityHandler"
    },
    [569557174] = {
      res = "trigger_cli_switch_main_city",
      inGameOper = 0,
      handler = "MainCityHandler"
    },
    [601681175] = {
      req = "get_main_city_explore_cfg_req",
      res = "get_main_city_explore_cfg_rsp",
      inGameOper = 0,
      handler = "MainCityHandler"
    },
    [746932115] = {
      req = "get_main_city_seesaw_battle_req",
      res = "get_main_city_seesaw_battle_rsp",
      inGameOper = 0,
      handler = "MainCityHandler"
    },
    [995736561] = {
      res = "main_city_invite_notify",
      handler = "MainCityHandler"
    },
    [1188945822] = {
      res = "notify_be_used_magic_wand",
      handler = "MainCityHandler"
    },
    [1222534031] = {
      req = "mc_get_bubble_cfg_req",
      res = "mc_get_bubble_cfg_rsp",
      handler = "MainCityHandler"
    },
    [1480608999] = {
      req = "get_main_city_info_req",
      res = "get_main_city_info_rsp",
      inGameOper = 0,
      handler = "MainCityHandler"
    },
    [1493780903] = {
      req = "main_city_invite_req",
      res = "main_city_invite_rsp",
      handler = "MainCityHandler"
    },
    [1534019111] = {
      req = "bride_npc_interact_req",
      res = "bride_npc_interact_rsp",
      inGameOper = 0,
      handler = "MainCityHandler"
    },
    [1793488894] = {
      req = "mc_batch_get_game_online_num",
      res = "mc_batch_get_game_online_num",
      handler = "MainCityHandler"
    },
    [1877640703] = {
      req = "mc_use_magic_wand_req",
      res = "mc_use_magic_wand_rsp",
      handler = "MainCityHandler"
    },
    [66585148] = {
      res = "imobile_market_get_2rdVer_page_list_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [713572517] = {
      req = "activity_buy_req",
      handler = "MallHandler"
    },
    [748782191] = {
      req = "imobile_market_direct_buy_content_req",
      res = "imobile_market_direct_buy_content_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [860835687] = {
      req = "imobile_market_batch_buy_req",
      res = "imobile_market_batch_buy_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [928879520] = {
      res = "activity_after_shop_buy_present_notify",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [1007941001] = {
      req = "get_imobile_market_buy_info_req",
      res = "get_market_buy_info_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [1109892044] = {
      req = "query_direct_buy_info",
      res = "query_direct_buy_info_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [1226380068] = {
      req = "imobile_get_direct_buy_info",
      res = "imobile_get_direct_buy_info_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [1655710282] = {
      res = "imobile_direct_buy_result_notify",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [1882216366] = {
      req = "take_month_card_daily_award",
      res = "take_month_card_daily_award_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [2018750014] = {
      req = "get_month_card_info",
      res = "get_month_card_info_rsp",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [2048316830] = {
      res = "notify_month_card_info",
      inGameOper = 0,
      handler = "MallHandler"
    },
    [1516487340] = {
      req = "take_share_activity_rewards",
      res = "take_share_activity_rewards_rsp",
      handler = "ManorRiskHandle"
    },
    [9690814] = {
      res = "open_chest_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [211022439] = {
      req = "market_msg_all_setread_req",
      res = "market_msg_all_setread_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [294984359] = {
      req = "market_gift_give_count_req",
      res = "market_gift_give_count_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [358173031] = {
      req = "market_get_giftmsg_req",
      res = "market_get_giftmsg_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [406699215] = {
      req = "market_refuse_ask_for_req",
      res = "market_refuse_ask_for_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [507735259] = {
      req = "shop_itemlist_req",
      res = "shop_itemlist_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [636379120] = {
      res = "shop_rounds_update_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [686861451] = {
      req = "shop_item_content_req",
      res = "shop_item_content_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [701193127] = {
      req = "market_msg_setread_req",
      res = "market_msg_setread_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [715748756] = {
      req = "get_shop_limit_info",
      res = "get_shop_limit_info_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [731531611] = {
      res = "open_chest_ten_times_nofity",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [788881511] = {
      req = "market_gift_all_take_req",
      res = "market_gift_all_take_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [953225714] = {
      res = "notify_give_open",
      handler = "MarketHandler"
    },
    [955911815] = {
      req = "market_del_all_giftmsg_req",
      res = "market_del_all_giftmsg_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [961206279] = {
      req = "market_del_giftmsg_req",
      res = "market_del_giftmsg_rsp",
      handler = "MarketHandler"
    },
    [1048044603] = {
      res = "shop_buy_item_notify",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1095687655] = {
      req = "shop_buy_req",
      res = "shop_buy_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1198132401] = {
      res = "market_give_gift_notify",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1243468263] = {
      req = "market_give_gift_req",
      res = "market_give_gift_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1330087271] = {
      req = "market_gift_take_req",
      res = "market_gift_take_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1408480832] = {
      res = "market_ask_for_notify",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1780795911] = {
      req = "market_ask_for_req",
      res = "market_ask_for_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1790950294] = {
      req = "get_single_shopitem",
      res = "get_single_shopitem_rsp",
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1888045055] = {
      req = "get_h5_market_req",
      res = "get_h5_market_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [2130403323] = {
      req = "market_send_thank_req",
      res = "market_send_thank_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MarketHandler"
    },
    [1456190924] = {
      req = "report_marketing_agreement",
      res = "report_marketing_agreement_rsp",
      inGameOper = 0,
      handler = "MarketingAgreementHandler"
    },
    [2062167404] = {
      req = "query_marketing_agreement",
      res = "query_marketing_agreement_rsp",
      handler = "MarketingAgreementHandler"
    },
    [56652489] = {
      req = "try_re_enter_game",
      handler = "MatchHandler"
    },
    [102634255] = {
      req = "get_data_pass_to_ds_req",
      res = "get_data_pass_to_ds_rsp",
      handler = "MatchHandler"
    },
    [252140246] = {
      req = "get_long_time_match_mode",
      res = "get_match_guide_mode_rsp",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [290905706] = {
      res = "on_KRJP_match_to_asia",
      handler = "MatchHandler"
    },
    [360188889] = {
      req = "report_match_guide_window_info",
      handler = "MatchHandler"
    },
    [380409343] = {
      res = "enter_monster_failed",
      handler = "MatchHandler"
    },
    [567197619] = {
      req = "set_player_match_strategy_req",
      res = "set_player_match_strategy_rsp",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [691071551] = {
      req = "set_data_pass_to_ds_req",
      res = "set_data_pass_to_ds_rsp",
      handler = "MatchHandler"
    },
    [692004049] = {
      req = "report_test_battle_ping",
      handler = "MatchHandler"
    },
    [732292061] = {
      res = "lang_match_close_notify",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [751957777] = {
      res = "notify_vedio_show",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [820900744] = {
      req = "on_match_req",
      res = "on_match_res",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [823378442] = {
      req = "league_match_req",
      handler = "MatchHandler"
    },
    [856298267] = {
      req = "report_epl_thd_ping_data",
      handler = "MatchHandler"
    },
    [888301465] = {
      res = "on_match_success",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [1172162248] = {
      req = "report_match_guide_operation_info",
      handler = "MatchHandler"
    },
    [1201435516] = {
      req = "report_grome_link_err",
      handler = "MatchHandler"
    },
    [1239942598] = {
      req = "new_report_map_download_log",
      handler = "MatchHandler"
    },
    [1326507063] = {
      res = "sync_segment_protect_shield",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [1534479638] = {
      req = "report_vedio_show_completed",
      handler = "MatchHandler"
    },
    [1565531910] = {
      req = "grome_enter_battle_result",
      handler = "MatchHandler"
    },
    [1566932500] = {
      res = "low_priority_match_ban_cancel",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [1590089593] = {
      req = "report_epoll_ping_info",
      handler = "MatchHandler"
    },
    [1674352965] = {
      res = "re_enter_game",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [1722324219] = {
      res = "sync_match_process",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [1723747335] = {
      req = "query_player_state_req",
      res = "query_player_state_rsp",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [1840825462] = {
      req = "device_not_support_grome_link",
      handler = "MatchHandler"
    },
    [1850754184] = {
      req = "on_match_across_zone_req",
      res = "on_match_across_zone_res",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [1916400552] = {
      res = "notify_gromelink_open_stat",
      handler = "MatchHandler"
    },
    [1940292319] = {
      req = "on_krjp_rematch_asia_zone_req",
      handler = "MatchHandler"
    },
    [2028536299] = {
      req = "rollback_team_type",
      inGameOper = 0,
      handler = "MatchHandler"
    },
    [17370755] = {
      res = "mentor_evaluate_notify",
      handler = "MentorHandler"
    },
    [44767907] = {
      req = "mentor_unregister_req",
      res = "mentor_unregister_rsp",
      handler = "MentorHandler"
    },
    [111413879] = {
      res = "mentor_level_info_sync",
      handler = "MentorHandler"
    },
    [165627880] = {
      req = "mentor_team_respond",
      res = "mentor_team_respond_notify",
      handler = "MentorHandler"
    },
    [176534523] = {
      req = "mentor_level_all_reward_req",
      res = "mentor_level_all_reward_rsp",
      handler = "MentorHandler"
    },
    [197160931] = {
      req = "mentor_level_reward_req",
      res = "mentor_level_reward_rsp",
      handler = "MentorHandler"
    },
    [294628879] = {
      req = "mentor_reward_req",
      res = "mentor_reward_rsp",
      handler = "MentorHandler"
    },
    [307622059] = {
      req = "mentee_register_req",
      res = "mentee_register_rsp",
      handler = "MentorHandler"
    },
    [335284731] = {
      res = "mentor_team_request_notify",
      handler = "MentorHandler"
    },
    [368143079] = {
      req = "mentor_register_req",
      res = "mentor_register_rsp",
      handler = "MentorHandler"
    },
    [407540935] = {
      req = "get_mentor_data_req",
      res = "get_mentor_data_rsp",
      handler = "MentorHandler"
    },
    [436762895] = {
      req = "mentor_level_info_req",
      res = "mentor_level_info_rsp",
      handler = "MentorHandler"
    },
    [504522680] = {
      res = "quit_mentor_prematch_state",
      handler = "MentorHandler"
    },
    [514420903] = {
      req = "mentor_recommend_mentee_req",
      res = "mentor_recommend_mentee_rsp",
      handler = "MentorHandler"
    },
    [536352194] = {
      req = "mentor_team_request_cancel",
      res = "mentor_team_request_cancel_notify",
      handler = "MentorHandler"
    },
    [540672267] = {
      req = "mentor_batch_reward_req",
      res = "mentor_batch_reward_rsp",
      handler = "MentorHandler"
    },
    [780429927] = {
      req = "mentor_task_reward_req",
      res = "mentor_task_reward_rsp",
      handler = "MentorHandler"
    },
    [832867291] = {
      req = "mentor_award_stat_req",
      res = "mentor_award_stat_rsp",
      handler = "MentorHandler"
    },
    [925484575] = {
      req = "mentee_unregister_req",
      res = "mentee_unregister_rsp",
      handler = "MentorHandler"
    },
    [1000049435] = {
      req = "get_mentor_predictive_wait_time_req",
      res = "get_mentor_predictive_wait_time_rsp",
      handler = "MentorHandler"
    },
    [1018481843] = {
      req = "mentee_evaluate_req",
      res = "mentee_evaluate_rsp",
      handler = "MentorHandler"
    },
    [1076701167] = {
      req = "mentor_evaluate_req",
      res = "mentor_evaluate_rsp",
      handler = "MentorHandler"
    },
    [1109157906] = {
      req = "mentor_match_req",
      handler = "MentorHandler"
    },
    [1120689383] = {
      req = "mentor_recommend_req",
      res = "mentor_recommend_rsp",
      queueType = 1,
      handler = "MentorHandler"
    },
    [1280198919] = {
      req = "mentor_emotion_report_req",
      handler = "MentorHandler"
    },
    [1318054247] = {
      req = "mentor_declaration_set_req",
      res = "mentor_declaration_set_rsp",
      handler = "MentorHandler"
    },
    [1325097502] = {
      res = "mentor_task_change_notify",
      handler = "MentorHandler"
    },
    [1399622703] = {
      res = "mentor_team_request_notify_others",
      handler = "MentorHandler"
    },
    [1446866444] = {
      res = "mentor_status_sync",
      handler = "MentorHandler"
    },
    [1449343847] = {
      req = "mentor_claim_exp_req",
      res = "mentor_claim_exp_rsp",
      handler = "MentorHandler"
    },
    [1510783951] = {
      req = "set_mentor_identity_req",
      res = "set_mentor_identity_rsp",
      handler = "MentorHandler"
    },
    [1575780935] = {
      req = "mentor_history_req",
      res = "mentor_history_rsp",
      handler = "MentorHandler"
    },
    [1747969315] = {
      res = "enter_mentor_prematch_state",
      handler = "MentorHandler"
    },
    [1817989591] = {
      req = "get_mentor_status_req",
      res = "get_mentor_status_rsp",
      handler = "MentorHandler"
    },
    [1913957726] = {
      res = "mentor_level_up_notify",
      handler = "MentorHandler"
    },
    [1939380758] = {
      req = "mentor_prematch_cancel_req",
      handler = "MentorHandler"
    },
    [2025872446] = {
      req = "mentor_team_request",
      res = "mentor_team_request_rsp",
      handler = "MentorHandler"
    },
    [2046036069] = {
      res = "notify_mentee_is_in_team",
      handler = "MentorHandler"
    },
    [1144819747] = {
      req = "set_push_msg_pop_up_confirm_req",
      res = "set_push_msg_pop_up_confirm_rsp",
      handler = "MessagePushTriggerHandler"
    },
    [1543727827] = {
      req = "get_push_msg_pop_up_confirm_req",
      res = "get_push_msg_pop_up_confirm_rsp",
      handler = "MessagePushTriggerHandler"
    },
    [1227404245] = {
      res = "get_all_corps_active_goal_reward_rsp",
      handler = "MiniTvRewardHandler"
    },
    [1372365415] = {
      req = "mini_tv_get_all_reward_req",
      res = "mini_tv_get_all_reward_rsp",
      handler = "MiniTvRewardHandler"
    },
    [109393462] = {
      req = "change_minor_flag",
      res = "change_minor_flag_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MinorVerificationHandler"
    },
    [515794476] = {
      req = "set_minor_flag",
      res = "set_minor_flag_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MinorVerificationHandler"
    },
    [669737229] = {
      res = "notify_minor_online_time",
      inGameOper = 0,
      handler = "MinorVerificationHandler"
    },
    [1550974950] = {
      req = "set_approve_phone",
      res = "set_approve_phone_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MinorVerificationHandler"
    },
    [1618335044] = {
      req = "get_verification_code",
      res = "get_verification_code_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MinorVerificationHandler"
    },
    [1870877708] = {
      req = "send_verification_code",
      res = "send_verification_code_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MinorVerificationHandler"
    },
    [1959380782] = {
      req = "cancel_change",
      res = "cancel_change_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "MinorVerificationHandler"
    },
    [9863207] = {
      req = "exchange_million_uc_item_req",
      res = "exchange_million_uc_item_rsp",
      isLock = 1,
      handler = "MixItemHandler"
    },
    [71200782] = {
      res = "notify_404_not_found_unlock",
      handler = "MixItemHandler"
    },
    [209942219] = {
      req = "get_easter_egg_data_req",
      res = "get_easter_egg_data_rsp",
      handler = "MixItemHandler"
    },
    [945394087] = {
      req = "get_smelt_plan_cfg_req",
      res = "get_smelt_plan_cfg_rsp",
      handler = "MixItemHandler"
    },
    [1200096587] = {
      req = "exchange_mix_item_chest_req",
      res = "exchange_mix_item_chest_rsp",
      isLock = 1,
      handler = "MixItemHandler"
    },
    [1216077919] = {
      req = "get_hint_easter_egg_req",
      res = "get_hint_easter_egg_rsp",
      handler = "MixItemHandler"
    },
    [1486547687] = {
      req = "resolve_easter_egg_req",
      res = "resolve_easter_egg_rsp",
      handler = "MixItemHandler"
    },
    [1687192199] = {
      req = "mix_item_smelt_req",
      res = "mix_item_smelt_rsp",
      isLock = 1,
      handler = "MixItemHandler"
    },
    [1740311731] = {
      req = "exchange_easter_egg_req",
      res = "exchange_easter_egg_rsp",
      isLock = 1,
      handler = "MixItemHandler"
    },
    [1871008231] = {
      req = "choose_million_uc_item_req",
      res = "choose_million_uc_item_rsp",
      isLock = 1,
      handler = "MixItemHandler"
    },
    [1877360781] = {
      res = "notify_easter_clue_change",
      handler = "MixItemHandler"
    },
    [1926860443] = {
      req = "mix_item_use_item_req",
      res = "mix_item_use_item_rsp",
      handler = "MixItemHandler"
    },
    [2112244903] = {
      res = "kick_easter_egg_notify",
      handler = "MixItemHandler"
    },
    [537160487] = {
      req = "character_exchange_req",
      res = "character_exchange_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [552616615] = {
      req = "switch_character_req",
      res = "switch_character_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [823844180] = {
      res = "character_skill_upgrade_notify",
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [1075128807] = {
      res = "decompose_character_notify",
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [1285247590] = {
      res = "create_character_notify",
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [1314954951] = {
      req = "character_open_box_req",
      res = "character_open_box_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [1348345881] = {
      res = "character_box_exp_notify",
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [1376575455] = {
      res = "character_exp_notify",
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [1805337351] = {
      req = "character_use_exp_card_req",
      res = "character_use_exp_card_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [2056692099] = {
      res = "character_del_notify",
      inGameOper = 0,
      modName = "NewCharacter",
      handler = "ModCharacterHandler"
    },
    [145518951] = {
      req = "take_collect_level_award_req",
      res = "take_collect_level_award_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [174831495] = {
      req = "batch_take_collect_level_award_req",
      res = "batch_take_collect_level_award_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [187107263] = {
      req = "cancel_collect_sys_upvote_req",
      res = "cancel_collect_sys_upvote_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [319897559] = {
      req = "clear_sticker_security_detection_flag_req",
      res = "clear_sticker_security_detection_flag_rsp",
      needRsp = 999,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [336950843] = {
      req = "set_show_milestone_data_req",
      res = "set_show_milestone_data_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [559711399] = {
      req = "batch_take_collect_sys_theme_award_req",
      res = "batch_take_collect_sys_theme_award_rsp",
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [624662371] = {
      req = "get_collect_sys_upvote_info_req",
      res = "get_collect_sys_upvote_info_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [1038185283] = {
      req = "set_sticker_frame_req",
      res = "set_sticker_frame_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [1269222375] = {
      req = "set_sticker_background_req",
      res = "set_sticker_background_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [1317444263] = {
      req = "cancel_collect_sys_show_info_req",
      res = "cancel_collect_sys_show_info_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [1358346663] = {
      req = "report_collec_sys_theme_progress_req",
      res = "report_collec_sys_theme_progress_rsp",
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [1361600423] = {
      req = "take_collect_sys_theme_award_req",
      res = "take_collect_sys_theme_award_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [1862326131] = {
      req = "batch_take_all_sub_page_level_award_req",
      res = "batch_take_all_sub_page_level_award_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [2101796871] = {
      req = "paste_collect_sys_show_info_req",
      res = "paste_collect_sys_show_info_rsp",
      isLock = 1,
      inGameOper = 0,
      modName = "Collect",
      handler = "ModCollectHandler"
    },
    [169440098] = {
      req = "del_moment_req",
      res = "del_one_moment_rsp",
      handler = "MomentHandler"
    },
    [251336519] = {
      res = "notify_moments_message",
      handler = "MomentHandler"
    },
    [253321703] = {
      req = "get_moment_reply_req",
      res = "get_moment_reply_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "MomentHandler"
    },
    [312452467] = {
      req = "get_user_moments_id_req",
      res = "get_user_moments_id_rsp",
      handler = "MomentHandler"
    },
    [324593511] = {
      req = "del_moment_reply_req",
      res = "del_moment_reply_rsp",
      isLock = 1,
      timeout = 5,
      handler = "MomentHandler"
    },
    [337536723] = {
      req = "batch_get_moments_summary_req",
      res = "batch_get_moments_summary_rsp",
      handler = "MomentHandler"
    },
    [354649307] = {
      req = "report_view_moments_req",
      res = "report_view_moments_rsp",
      handler = "MomentHandler"
    },
    [418789025] = {
      res = "notify_new_moment_background_red_point",
      handler = "MomentHandler"
    },
    [430991495] = {
      req = "do_moment_emoji_unlike_req",
      res = "do_moment_emoji_unlike_rsp",
      queueType = 1,
      handler = "MomentHandler"
    },
    [458976083] = {
      req = "update_moments_messages_req",
      res = "update_moments_messages_rsp",
      handler = "MomentHandler"
    },
    [573640699] = {
      req = "set_moment_bubble_req",
      res = "set_moment_bubble_rsp",
      handler = "MomentHandler"
    },
    [595803687] = {
      req = "moment_reply_req",
      res = "moment_reply_rsp",
      isLock = 1,
      timeout = 5,
      handler = "MomentHandler"
    },
    [723225063] = {
      req = "set_all_moments_remind_info_read_req",
      res = "set_all_moments_remind_info_read_rsp",
      handler = "MomentHandler"
    },
    [801817543] = {
      req = "get_moments_red_point_req",
      res = "get_moments_red_point_rsp",
      handler = "MomentHandler"
    },
    [806579431] = {
      req = "get_all_moments_messages_req",
      res = "get_all_moments_messages_rsp",
      inGameOper = 0,
      handler = "MomentHandler"
    },
    [810253339] = {
      req = "set_moment_switch_req",
      res = "set_moment_switch_rsp",
      handler = "MomentHandler"
    },
    [811291431] = {
      req = "do_moment_unlike_req",
      res = "do_moment_unlike_rsp",
      handler = "MomentHandler"
    },
    [854327975] = {
      req = "do_moment_emoji_like_req",
      res = "do_moment_emoji_like_rsp",
      queueType = 1,
      handler = "MomentHandler"
    },
    [1136689991] = {
      req = "do_moment_like_req",
      res = "do_moment_like_rsp",
      handler = "MomentHandler"
    },
    [1140030315] = {
      req = "get_fri_hot_moments_req",
      res = "get_fri_hot_moments_rsp",
      handler = "MomentHandler"
    },
    [1248752487] = {
      req = "square_moment_list_req",
      res = "square_moment_list_rsp",
      handler = "MomentHandler"
    },
    [1345605415] = {
      req = "get_moment_background_data_req",
      res = "get_moment_background_data_rsp",
      inGameOper = 0,
      handler = "MomentHandler"
    },
    [1381563799] = {
      req = "set_moments_red_point_req",
      res = "set_moments_red_point_rsp",
      handler = "MomentHandler"
    },
    [1437711943] = {
      req = "get_new_square_moments_num_req",
      res = "get_new_square_moments_num_rsp",
      handler = "MomentHandler"
    },
    [1455058919] = {
      req = "set_moments_remind_info_read_req",
      res = "set_moments_remind_info_read_rsp",
      handler = "MomentHandler"
    },
    [1490826816] = {
      res = "wow_notify_publish_moment",
      handler = "MomentHandler"
    },
    [1493246055] = {
      req = "set_moment_background_flag_req",
      res = "set_moment_background_flag_rsp",
      handler = "MomentHandler"
    },
    [1530791151] = {
      req = "get_moment_detail_req",
      res = "get_moment_detail_rsp",
      handler = "MomentHandler"
    },
    [1657947051] = {
      req = "get_self_moments_info_req",
      res = "get_self_moments_info_rsp",
      handler = "MomentHandler"
    },
    [1845428499] = {
      req = "get_wow_hot_moments_req",
      res = "get_wow_hot_moments_rsp",
      handler = "MomentHandler"
    },
    [1859983943] = {
      req = "get_fri_recent_moments_req",
      res = "get_fri_recent_moments_rsp",
      handler = "MomentHandler"
    },
    [2038382627] = {
      req = "delete_moments_messages_req",
      res = "delete_moments_messages_rsp",
      handler = "MomentHandler"
    },
    [2118378671] = {
      req = "post_moment_req",
      res = "post_moment_rsp",
      inGameOper = 0,
      handler = "MomentHandler"
    },
    [86293658] = {
      res = "nation_esports_auth_ntf",
      handler = "NationEsportHandler"
    },
    [1834087111] = {
      req = "sync_nation_esports_auth_check_req",
      res = "sync_nation_esports_auth_check_rsp",
      handler = "NationEsportHandler"
    },
    [718633438] = {
      req = "heart_beat",
      res = "heart_beat",
      timeout = 30,
      inGameOper = 0,
      handler = "NetHeartBeatHandler"
    },
    [587134668] = {
      req = "get_market_jump_info",
      res = "get_market_jump_info_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 5,
      needRsp = 2,
      handler = "NetJumpHandler"
    },
    [667811244] = {
      req = "get_shop_jump_info",
      res = "get_shop_jump_info_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 5,
      needRsp = 2,
      handler = "NetJumpHandler"
    },
    [541883047] = {
      req = "coupon_pay_new_group_buy_req",
      res = "coupon_pay_new_group_buy_rsp",
      handler = "NewGroupBuyHandler"
    },
    [809516143] = {
      req = "refund_new_group_buy_entrance_req",
      res = "refund_new_group_buy_entrance_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1025847527] = {
      req = "direct_pay_new_group_buy_req",
      res = "direct_pay_new_group_buy_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1055530855] = {
      req = "batch_get_new_group_buy_info_req",
      res = "batch_get_new_group_buy_info_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1184648551] = {
      req = "invite_all_new_group_buy_friend_list_req",
      res = "invite_all_new_group_buy_friend_list_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1199556363] = {
      req = "get_new_group_buy_simple_info_req",
      res = "get_new_group_buy_simple_info_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1215999559] = {
      req = "join_new_group_buy_req",
      res = "join_new_group_buy_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1293134823] = {
      req = "get_new_group_buy_info_req",
      res = "get_new_group_buy_info_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1380200351] = {
      res = "on_new_group_buy_full_notify",
      handler = "NewGroupBuyHandler"
    },
    [1542818343] = {
      req = "create_new_group_buy_req",
      res = "create_new_group_buy_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1880562467] = {
      req = "exchange_new_group_buy_entrance_req",
      res = "exchange_new_group_buy_entrance_rsp",
      handler = "NewGroupBuyHandler"
    },
    [1907179827] = {
      req = "pay_new_group_buy_req",
      res = "pay_new_group_buy_rsp",
      handler = "NewGroupBuyHandler"
    },
    [2002538013] = {
      res = "notify_invite_new_group_buy_result",
      handler = "NewGroupBuyHandler"
    },
    [851945063] = {
      req = "get_hunter_vs_hunted_career_data_req",
      res = "get_hunter_vs_hunted_career_data_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "NewModeHandler"
    },
    [1221327655] = {
      req = "get_mode_shield_v2_req",
      res = "get_mode_shield_v2_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "NewModeHandler"
    },
    [39102823] = {
      req = "get_newbie_all_social_task_req",
      res = "get_newbie_all_social_task_rsp",
      timeInterval = 1,
      handler = "NewbieActivityHandle"
    },
    [139466019] = {
      req = "newbie_activity_get_gift_reward_req",
      res = "newbie_activity_get_gift_reward_rsp",
      handler = "NewbieActivityHandle"
    },
    [230794680] = {
      res = "newbie_social_task_sync",
      handler = "NewbieActivityHandle"
    },
    [353512491] = {
      req = "newbie_celebration_get_drop_points_reward_req",
      res = "newbie_celebration_get_drop_points_reward_rsp",
      handler = "NewbieActivityHandle"
    },
    [475296335] = {
      req = "newbie_celebration_lucky_draw_req",
      res = "newbie_celebration_lucky_draw_rsp",
      handler = "NewbieActivityHandle"
    },
    [499444583] = {
      req = "dont_show_friend_recommend_req",
      res = "dont_show_friend_recommend_rsp",
      inGameOper = 0,
      handler = "NewbieActivityHandle"
    },
    [810901335] = {
      req = "newbie_activity_get_sign_reward_req",
      res = "newbie_activity_get_sign_reward_rsp",
      handler = "NewbieActivityHandle"
    },
    [816728279] = {
      req = "newbie_celebration_get_mission_reward_req",
      res = "newbie_celebration_get_mission_reward_rsp",
      handler = "NewbieActivityHandle"
    },
    [932715161] = {
      res = "newbie_activity_init",
      handler = "NewbieActivityHandle"
    },
    [978855938] = {
      res = "newbie_celebration_init",
      handler = "NewbieActivityHandle"
    },
    [1023688478] = {
      res = "newbie_celebration_points_notify_chg",
      handler = "NewbieActivityHandle"
    },
    [1075421875] = {
      req = "batch_newbie_cel_get_mission_reward_req",
      res = "batch_newbie_cel_get_mission_reward_rsp",
      handler = "NewbieActivityHandle"
    },
    [1280438283] = {
      req = "newbie_activity_get_rank_reward_req",
      res = "newbie_activity_get_rank_reward_rsp",
      handler = "NewbieActivityHandle"
    },
    [1369764690] = {
      res = "newbie_celebration_sync_status",
      handler = "NewbieActivityHandle"
    },
    [1951334697] = {
      res = "newbie_mission_sync",
      handler = "NewbieActivityHandle"
    },
    [2096471963] = {
      res = "newbie_activity_sync_status",
      handler = "NewbieActivityHandle"
    },
    [1181343347] = {
      res = "get_total_match_cnt_rsp",
      handler = "NewbieAssistantHandler"
    },
    [252936679] = {
      req = "newbie_level_unlock_get_reward_req",
      res = "newbie_level_unlock_get_reward_rsp",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [613882689] = {
      res = "region_play_video",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [684584519] = {
      req = "set_newbie_unlock_level_status_req",
      res = "set_newbie_unlock_level_status_rsp",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [923480075] = {
      req = "newbie_tutorial_level_req",
      res = "newbie_tutorial_level_rsp",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [1052619901] = {
      req = "newbie_guide_log_report",
      handler = "NewbieGuideHandler"
    },
    [1572571295] = {
      res = "sync_newbie_level_unlock_data",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [1589417424] = {
      res = "newbie_activity_cfg_init",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [1704388699] = {
      req = "new_newbie_perfect_excessive_level_up_req",
      res = "new_newbie_perfect_excessive_level_up_rsp",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [1741785275] = {
      req = "save_weak_guidance_conditions_req",
      res = "save_weak_guidance_conditions_rsp",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [2009574631] = {
      req = "get_weak_guidance_conditions_req",
      res = "get_weak_guidance_conditions_rsp",
      inGameOper = 0,
      handler = "NewbieGuideHandler"
    },
    [39266095] = {
      req = "get_newbie_upgrade_data_req",
      res = "get_newbie_upgrade_data_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "NewbieModeHandler"
    },
    [45680075] = {
      req = "newbie_upgrade_total_reward_req",
      res = "newbie_upgrade_total_reward_rsp",
      inGameOper = 0,
      handler = "NewbieModeHandler"
    },
    [581908060] = {
      res = "newbie_upgrade_train_recommand_ntf",
      inGameOper = 0,
      handler = "NewbieModeHandler"
    },
    [1139286327] = {
      req = "newbie_upgrade_view_award_req",
      res = "newbie_upgrade_view_award_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "NewbieModeHandler"
    },
    [1277905819] = {
      req = "newbie_upgrade_train_detail_req",
      res = "newbie_upgrade_train_detail_rsp",
      timeout = 5,
      needRsp = 10,
      inGameOper = 0,
      handler = "NewbieModeHandler"
    },
    [1357350872] = {
      res = "newbie_upgrade_sync_data",
      inGameOper = 0,
      handler = "NewbieModeHandler"
    },
    [1601382047] = {
      req = "newbie_upgrade_award_show_req",
      res = "newbie_upgrade_award_show_rsp",
      inGameOper = 0,
      handler = "NewbieModeHandler"
    },
    [53821459] = {
      req = "newbie_login_reward_req",
      res = "newbie_login_reward_rsp",
      handler = "NewbieNewLogicHandle"
    },
    [271299778] = {
      res = "newbie_new_info_notify",
      handler = "NewbieNewLogicHandle"
    },
    [398184995] = {
      req = "newbie_reward_all_task_and_points_req",
      res = "newbie_reward_all_task_and_points_rsp",
      handler = "NewbieNewLogicHandle"
    },
    [482362119] = {
      req = "newbie_task_reward_req",
      res = "newbie_task_reward_rsp",
      handler = "NewbieNewLogicHandle"
    },
    [697350887] = {
      req = "newbie_points_reward_req",
      res = "newbie_points_reward_rsp",
      handler = "NewbieNewLogicHandle"
    },
    [1000750119] = {
      req = "newbie_upgrade_reward_req",
      res = "newbie_upgrade_reward_rsp",
      handler = "NewbieNewLogicHandle"
    },
    [1002557537] = {
      res = "newbie_login_day_notify",
      handler = "NewbieNewLogicHandle"
    },
    [1067437083] = {
      req = "newbie_new_info_req",
      res = "newbie_new_info_rsp",
      handler = "NewbieNewLogicHandle"
    },
    [556183539] = {
      req = "get_newbie_yg_req",
      res = "get_newbie_yg_rsp",
      handler = "NewbieOptHandle"
    },
    [637592231] = {
      req = "claim_newbie_task_reward_req",
      res = "claim_newbie_task_reward_rsp",
      handler = "NewbieOptHandle"
    },
    [1175433090] = {
      res = "common_task_data_notify",
      handler = "NewbieOptHandle"
    },
    [584688871] = {
      req = "newbie_rating_protect_info_req",
      res = "newbie_rating_protect_info_rsp",
      timeInterval = 3,
      handler = "NewbieTaskHandler"
    },
    [630272374] = {
      res = "newbie_task_sync",
      handler = "NewbieTaskHandler"
    },
    [812294143] = {
      req = "newbie_reward_get_req",
      res = "newbie_reward_get_rsp",
      handler = "NewbieTaskHandler"
    },
    [1845154707] = {
      res = "newbie_task_day",
      handler = "NewbieTaskHandler"
    },
    [2095599545] = {
      res = "newbie_task_init",
      handler = "NewbieTaskHandler"
    },
    [549094984] = {
      req = "sync_newer_guide_data_req",
      res = "sync_newer_guide_data_res",
      inGameOper = 0,
      handler = "NewerGuideHandler"
    },
    [838225132] = {
      req = "set_fresher_type_req",
      handler = "NewerGuideHandler"
    },
    [119052711] = {
      req = "read_urgent_notice",
      handler = "NewsHandler"
    },
    [66711623] = {
      req = "get_bulletin_list_req",
      res = "get_bulletin_list_rsp",
      handler = "NoticeHandler"
    },
    [1713852655] = {
      req = "take_bulletin_award_req",
      res = "take_bulletin_award_rsp",
      handler = "NoticeHandler"
    },
    [734597493] = {
      res = "pmd_broadcast_notify",
      handler = "NotificationSystemHandler"
    },
    [1198983494] = {
      req = "query_ban_cycle_req",
      res = "ban_cycle_notify",
      handler = "NotifyMsgHandler"
    },
    [1542125338] = {
      res = "notify_pre_loss_wait_rule",
      inGameOper = 0,
      handler = "NotifyPreHandler"
    },
    [101724537] = {
      req = "offical_media_click_log",
      handler = "OfficialInfoHandler"
    },
    [377705368] = {
      res = "notify_rejoiner_score_change",
      handler = "OldfriendCareHandle"
    },
    [541001255] = {
      req = "get_rejoiner_assemb_info_req",
      res = "get_rejoiner_assemb_info_rsp",
      handler = "OldfriendCareHandle"
    },
    [627727756] = {
      req = "rejoiner_exchange_item",
      res = "rejoiner_exchange_item_rsp",
      handler = "OldfriendCareHandle"
    },
    [1783150871] = {
      req = "get_rejoiner_score_flow_req",
      res = "get_rejoiner_score_flow_rsp",
      handler = "OldfriendCareHandle"
    },
    [1800526891] = {
      req = "set_rejoiner_status_req",
      res = "set_rejoiner_status_rsp",
      handler = "OldfriendCareHandle"
    },
    [445366279] = {
      req = "batch_option_chest_req",
      res = "batch_option_chest_rsp",
      handler = "OptionalChestHandler"
    },
    [1157665907] = {
      req = "open_optional_chest_req",
      res = "optional_chest_show_panel",
      isUnique = 1,
      inGameOper = 0,
      handler = "OptionalChestHandler"
    },
    [1185002507] = {
      req = "make_option_chest_req",
      res = "make_option_chest_rsp",
      handler = "OptionalChestHandler"
    },
    [1401584431] = {
      res = "optional_chest_sync_buy_cnt",
      inGameOper = 0,
      handler = "OptionalChestHandler"
    },
    [2071278783] = {
      req = "optional_chest_select_req",
      res = "optional_chest_select_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "OptionalChestHandler"
    },
    [1104632183] = {
      req = "confirm_custom_draw_req",
      res = "confirm_custom_draw_rsp",
      isLock = 1,
      timeout = 10,
      handler = "OptionalTurntableHandler"
    },
    [1725883495] = {
      req = "reset_custom_draw_pool_req",
      res = "reset_custom_draw_pool_rsp",
      handler = "OptionalTurntableHandler"
    },
    [1808808495] = {
      req = "confirm_custom_draw_progress_reward_req",
      res = "confirm_custom_draw_progress_reward_rsp",
      isLock = 1,
      timeout = 10,
      handler = "OptionalTurntableHandler"
    },
    [143976487] = {
      req = "get_outfit_filter_tags_req",
      res = "get_outfit_filter_tags_rsp",
      handler = "OutfitCombinationHandler"
    },
    [560552391] = {
      req = "put_on_outfit_combinations_req",
      res = "put_on_outfit_combinations_rsp",
      handler = "OutfitCombinationHandler"
    },
    [1653800411] = {
      req = "get_outfit_combinations_use_times_req",
      res = "get_outfit_combinations_use_times_rsp",
      handler = "OutfitCombinationHandler"
    },
    [1667835303] = {
      req = "set_outfit_filter_tags_req",
      res = "set_outfit_filter_tags_rsp",
      handler = "OutfitCombinationHandler"
    },
    [1702933735] = {
      req = "open_combinations_daily_random_req",
      res = "open_combinations_daily_random_rsp",
      handler = "OutfitCombinationHandler"
    },
    [1115703446] = {
      req = "check_overload_recovery",
      res = "check_overload_recovery_rsp",
      handler = "OverloadHandler"
    },
    [1386697610] = {
      res = "overload_common_reject",
      handler = "OverloadHandler"
    },
    [1612723923] = {
      req = "manor_butler_dialogue_setting_req",
      res = "manor_butler_dialogue_setting_rsp",
      inGameOper = 0,
      handler = "PHomButlerChatSettingHandler"
    },
    [282855499] = {
      req = "check_manor_extra_rewards_req",
      res = "check_manor_extra_rewards_rsp",
      handler = "PHomeAnniversaryHandler"
    },
    [540384167] = {
      req = "manor_discount_shop_info_req",
      res = "manor_discount_shop_info_rsp",
      handler = "PHomeAnniversaryHandler"
    },
    [769118124] = {
      res = "manor_avs_login_reward_notify",
      handler = "PHomeAnniversaryHandler"
    },
    [778158601] = {
      req = "anniversary_login_act_take_award_req",
      res = "anniversary_login_act_take_rsp",
      handler = "PHomeAnniversaryHandler"
    },
    [1324905351] = {
      req = "anniversary_login_act_info_req",
      res = "anniversary_login_act_info_rsp",
      handler = "PHomeAnniversaryHandler"
    },
    [1329317219] = {
      req = "manor_open_time_req",
      res = "manor_open_time_rsp",
      handler = "PHomeAnniversaryHandler"
    },
    [1611229931] = {
      req = "take_manor_enter_reward_req",
      res = "take_manor_enter_reward_rsp",
      handler = "PHomeAnniversaryHandler"
    },
    [1989536164] = {
      res = "manor_extra_reward_notify",
      handler = "PHomeAnniversaryHandler"
    },
    [1513460926] = {
      res = "manor_scene_draft_state_notify",
      inGameOper = 0,
      handler = "PHomeAuditHandler"
    },
    [2128785307] = {
      req = "manor_scene_draft_state_req",
      res = "manor_scene_draft_state_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "PHomeAuditHandler"
    },
    [62071539] = {
      req = "manor_parking_gift_info_req",
      res = "manor_parking_gift_info_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [118826279] = {
      req = "manor_parking_park_req",
      res = "manor_parking_park_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [211342919] = {
      req = "manor_parking_currency_req",
      res = "manor_parking_currency_rsp",
      isUnique = 1,
      timeout = 4,
      needRsp = 3,
      handler = "PHomeCarParkingHandler"
    },
    [279441118] = {
      res = "manor_parking_currency_notify",
      handler = "PHomeCarParkingHandler"
    },
    [315808143] = {
      req = "manor_parking_upgrade_req",
      res = "manor_parking_upgrade_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [478268455] = {
      req = "manor_parking_invite_req",
      res = "manor_parking_invite_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [500025663] = {
      req = "manor_parking_expel_req",
      res = "manor_parking_expel_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [541349287] = {
      req = "manor_parking_owner_vehicles_req",
      res = "manor_parking_owner_vehicles_rsp",
      isUnique = 1,
      timeout = 4,
      needRsp = 3,
      handler = "PHomeCarParkingHandler"
    },
    [638173059] = {
      req = "manor_parking_shop_info_req",
      res = "manor_parking_shop_info_rsp",
      isUnique = 1,
      timeout = 4,
      needRsp = 3,
      inGameOper = 0,
      handler = "PHomeCarParkingHandler"
    },
    [683035555] = {
      res = "manor_park_vehicle_unpark_notify",
      handler = "PHomeCarParkingHandler"
    },
    [702113275] = {
      req = "manor_parking_set_owner_vehicle_req",
      res = "manor_parking_set_owner_vehicle_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [857175655] = {
      req = "manor_parking_inviters_req",
      res = "manor_parking_inviters_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [901257639] = {
      req = "manor_parking_info_req",
      res = "manor_parking_info_rsp",
      isUnique = 1,
      timeout = 4,
      needRsp = 3,
      handler = "PHomeCarParkingHandler"
    },
    [901646803] = {
      req = "get_recommend_manor_parking_req",
      res = "get_recommend_manor_parking_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [952611255] = {
      req = "manor_park_profit_req",
      res = "manor_park_profit_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [1065498247] = {
      req = "manor_parking_shop_buy_req",
      res = "manor_parking_shop_buy_rsp",
      inGameOper = 0,
      handler = "PHomeCarParkingHandler"
    },
    [1159974141] = {
      res = "manor_park_profit_notify",
      handler = "PHomeCarParkingHandler"
    },
    [1196766855] = {
      req = "manor_parking_vehicle_show_set_req",
      res = "manor_parking_vehicle_show_set_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [1215795519] = {
      res = "manor_parking_gift_notify",
      handler = "PHomeCarParkingHandler"
    },
    [1260765627] = {
      req = "manor_parking_leave_req",
      res = "manor_parking_leave_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [1595707831] = {
      req = "manor_parking_using_req",
      res = "manor_parking_using_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [1658404367] = {
      req = "manor_parking_remove_invite_req",
      res = "manor_parking_remove_invite_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [1664816431] = {
      req = "manor_parking_reset_owner_vehicle_req",
      res = "manor_parking_reset_owner_vehicle_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [1808343015] = {
      res = "manor_parking_vehicle_notify",
      handler = "PHomeCarParkingHandler"
    },
    [1858788947] = {
      req = "manor_parking_gift_read_req",
      res = "manor_parking_gift_read_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [1951020908] = {
      res = "manor_parking_gift_change_notify",
      handler = "PHomeCarParkingHandler"
    },
    [1954265399] = {
      req = "manor_parked_vehicles_req",
      res = "manor_parked_vehicles_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [2016752391] = {
      req = "manor_parking_gift_get_req",
      res = "manor_parking_gift_get_rsp",
      handler = "PHomeCarParkingHandler"
    },
    [321407335] = {
      req = "get_manor_group_page_actlist_req",
      res = "get_manor_group_page_actlist_rsp",
      inGameOper = 0,
      handler = "PHomeCollectionHandler"
    },
    [1737482838] = {
      res = "manor_group_page_status_notify",
      inGameOper = 0,
      handler = "PHomeCollectionHandler"
    },
    [265464903] = {
      req = "get_style_score_rank_act_score_req",
      res = "get_style_score_rank_act_score_rsp",
      handler = "PHomeCollectionRankHandler"
    },
    [1024021887] = {
      req = "get_style_score_rank_data_req",
      res = "get_style_score_rank_data_rsp",
      handler = "PHomeCollectionRankHandler"
    },
    [1205672423] = {
      req = "get_prosperity_rank_data_req",
      res = "get_prosperity_rank_data_rsp",
      inGameOper = 0,
      handler = "PHomeCollectionRankHandler"
    },
    [1719645855] = {
      req = "get_prosperity_rank_award_req",
      res = "get_prosperity_rank_award_rsp",
      inGameOper = 0,
      handler = "PHomeCollectionRankHandler"
    },
    [1840654855] = {
      req = "get_style_score_rank_award_req",
      res = "get_style_score_rank_award_rsp",
      handler = "PHomeCollectionRankHandler"
    },
    [148404510] = {
      res = "notify_manor_new_sky",
      inGameOper = 0,
      handler = "PHomeConsoleHandler"
    },
    [345998784] = {
      res = "manor_joint_sky_data_ntf",
      inGameOper = 0,
      handler = "PHomeConsoleHandler"
    },
    [404975836] = {
      res = "notify_manor_new_music",
      inGameOper = 0,
      handler = "PHomeConsoleHandler"
    },
    [431286727] = {
      req = "manor_level_up_req",
      res = "manor_level_up_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "PHomeConsoleHandler"
    },
    [645379399] = {
      req = "manor_intelli_level_up_req",
      res = "manor_intelli_level_up_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "PHomeConsoleHandler"
    },
    [1246935719] = {
      req = "manor_music_list_req",
      res = "manor_music_list_rsp",
      inGameOper = 0,
      handler = "PHomeConsoleHandler"
    },
    [1872504151] = {
      req = "manor_backrd_op_req",
      res = "manor_backrd_op_rsp",
      inGameOper = 0,
      handler = "PHomeConsoleHandler"
    },
    [69222619] = {
      req = "manor_tacit_level_award_req",
      res = "manor_tacit_level_award_rsp",
      handler = "PHomeCrystalHandler"
    },
    [381459963] = {
      req = "manor_do_event_like_req",
      res = "manor_do_event_like_rsp",
      handler = "PHomeCrystalHandler"
    },
    [991472728] = {
      res = "manor_interact_tacit_notify",
      handler = "PHomeCrystalHandler"
    },
    [1329755743] = {
      req = "manor_interact_info_req",
      res = "manor_interact_info_rsp",
      timeout = 2,
      needRsp = 5,
      handler = "PHomeCrystalHandler"
    },
    [1640741347] = {
      req = "manor_get_mood_text_req",
      res = "manor_get_mood_text_rsp",
      timeout = 5,
      needRsp = 3,
      handler = "PHomeCrystalHandler"
    },
    [1676346151] = {
      req = "manor_set_daily_mood_req",
      res = "manor_set_daily_mood_rsp",
      handler = "PHomeCrystalHandler"
    },
    [19321639] = {
      req = "manor_detail_req",
      res = "manor_detail_rsp",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [73650967] = {
      req = "manor_draft_use_item_detail_req",
      res = "manor_draft_use_item_detail_rsp",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [109880090] = {
      res = "manor_mate_item_in_scene_notify",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [308386631] = {
      req = "manor_detail_extra_tip_req",
      res = "manor_detail_extra_tip_rsp",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [487537223] = {
      req = "set_manor_name_req",
      res = "set_manor_name_rsp",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [897096415] = {
      req = "exchange_manor_coin_req",
      res = "exchange_manor_coin_rsp",
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [959319707] = {
      res = "manor_entrance_pic_ntfy",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [1167750087] = {
      req = "set_manor_entrance_pic_req",
      res = "set_manor_entrance_pic_rsp",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [1654149499] = {
      req = "manor_item_in_scene_req",
      res = "manor_item_in_scene_rsp",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [1669794607] = {
      req = "manor_use_item_detail_req",
      res = "manor_use_item_detail_rsp",
      inGameOper = 0,
      handler = "PHomeDetailHandler"
    },
    [2081125419] = {
      req = "manor_coins_req",
      res = "manor_coins_rsp",
      handler = "PHomeDetailHandler"
    },
    [1475811463] = {
      req = "set_manor_show_mod_id_req",
      res = "set_manor_show_mod_id_rsp",
      timeInterval = 1,
      handler = "PHomeDeviceHandler"
    },
    [849572906] = {
      res = "new_manor_skin_notify",
      inGameOper = 0,
      handler = "PHomeDoorPlateHandler"
    },
    [1010883431] = {
      req = "get_manor_skin_data_req",
      res = "get_manor_skin_data_rsp",
      inGameOper = 0,
      handler = "PHomeDoorPlateHandler"
    },
    [1710796147] = {
      req = "change_manor_skin_req",
      res = "change_manor_skin_rsp",
      inGameOper = 0,
      handler = "PHomeDoorPlateHandler"
    },
    [8288432] = {
      res = "manor_draw_reward_notify",
      inGameOper = 0,
      handler = "PHomeDrawRewardHandler"
    },
    [375393383] = {
      req = "manor_draw_reward_record_req",
      res = "manor_draw_reward_record_rsp",
      inGameOper = 0,
      handler = "PHomeDrawRewardHandler"
    },
    [492119975] = {
      req = "manor_draw_reward_info_req",
      res = "manor_draw_reward_info_rsp",
      inGameOper = 0,
      handler = "PHomeDrawRewardHandler"
    },
    [215179383] = {
      req = "manor_launch_model_summarys_req",
      res = "manor_launch_model_summarys_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [256080299] = {
      res = "manor_model_surface_ntfy",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [324937255] = {
      req = "clean_model_slot_req",
      res = "clean_model_slot_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [353770335] = {
      req = "manor_launch_model_detail_req",
      res = "manor_launch_model_detail_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [541088807] = {
      req = "buy_model_lack_items_req",
      res = "buy_model_lack_items_rsp",
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [670084675] = {
      req = "buy_model_req",
      res = "buy_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [679516839] = {
      req = "set_manor_model_name_req",
      res = "set_manor_model_name_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [791465391] = {
      req = "manor_model_creator_rewards_req",
      res = "manor_model_creator_rewards_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [806154415] = {
      req = "favorite_models_req",
      res = "favorite_models_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [853941035] = {
      req = "editable_model_detail_req",
      res = "editable_model_detail_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [899713893] = {
      req = "unlock_model_slot_req",
      res = "unlock_slot_id_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [928478935] = {
      req = "get_model_recommend_req",
      res = "get_model_recommend_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [981032135] = {
      req = "add_favorite_model_req",
      res = "add_favorite_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1033532743] = {
      req = "get_official_model_list_req",
      res = "get_official_model_list_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1092336967] = {
      req = "launch_depot_model_req",
      res = "launch_depot_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1109395111] = {
      req = "depot_models_req",
      res = "depot_models_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1312672983] = {
      req = "del_model_req",
      res = "del_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1380012499] = {
      req = "editable_model_summarys_req",
      res = "editable_model_summarys_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1401660239] = {
      req = "manor_selfmade_model_pull_req",
      res = "manor_selfmade_model_pull_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1445273543] = {
      req = "launch_model_to_manor_req",
      res = "launch_model_to_manor_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1464200487] = {
      req = "manor_to_model_req",
      res = "manor_to_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1535689639] = {
      req = "set_model_expect_level_req",
      res = "set_model_expect_level_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1609386183] = {
      req = "del_favorite_model_req",
      res = "del_favorite_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1675614843] = {
      req = "set_model_surface_url_req",
      res = "set_model_surface_url_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1699612583] = {
      req = "drop_model_req",
      res = "drop_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1719772327] = {
      req = "manor_model_creator_progress_req",
      res = "manor_model_creator_progress_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1803671931] = {
      req = "launch_depot_model_to_manor_req",
      res = "launch_depot_model_to_manor_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1840466479] = {
      req = "recycle_manor_req",
      res = "recycle_manor_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1896850535] = {
      req = "launch_model_req",
      res = "launch_model_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [1963605095] = {
      req = "owned_model_slot_ids_req",
      res = "owned_model_slot_ids_rsp",
      inGameOper = 0,
      handler = "PHomeDrawingHandler"
    },
    [650536254] = {
      res = "manor_dynamic_data_notify",
      inGameOper = 0,
      handler = "PHomeDynamicDataHandler"
    },
    [1717865799] = {
      req = "manor_dynamic_data_req",
      res = "manor_dynamic_data_rsp",
      inGameOper = 0,
      handler = "PHomeDynamicDataHandler"
    },
    [1052941991] = {
      req = "manor_visit_purpose_switch_req",
      res = "manor_visit_purpose_switch_rsp",
      handler = "PHomeEditHomeHandler"
    },
    [1068977831] = {
      req = "manor_edit_mode_self_sigle_heartbeat_req",
      res = "manor_edit_mode_self_sigle_heartbeat_rsp",
      inGameOper = 0,
      handler = "PHomeEditPlanHandler"
    },
    [1159894769] = {
      res = "manor_invite_notify",
      inGameOper = 0,
      handler = "PHomeEditPlanInviteHandler"
    },
    [1287242023] = {
      req = "manor_invite_req",
      res = "manor_invite_rsp",
      inGameOper = 0,
      handler = "PHomeEditPlanInviteHandler"
    },
    [1541381063] = {
      req = "manor_invite_reply_req",
      res = "manor_invite_reply_rsp",
      inGameOper = 0,
      handler = "PHomeEditPlanInviteHandler"
    },
    [1264211251] = {
      req = "manor_place_slot_item_req",
      res = "manor_place_slot_item_rsp",
      inGameOper = 0,
      handler = "PHomeEditSlotHandler"
    },
    [1678565499] = {
      req = "manor_place_vehicle_req",
      res = "manor_place_vehicle_rsp",
      isUnique = 1,
      inGameOper = 2,
      handler = "PHomeEditVehicleHandler"
    },
    [17601903] = {
      res = "manor_personal_encrypt_data_notify",
      handler = "PHomeEncryptDataHandler"
    },
    [1827863455] = {
      req = "manor_personal_encrypt_data_req",
      res = "manor_personal_encrypt_data_rsp",
      isUnique = 1,
      timeout = 4,
      needRsp = 3,
      handler = "PHomeEncryptDataHandler"
    },
    [360128391] = {
      req = "manor_mystery_man_exchange_req",
      res = "manor_mystery_man_exchange_rsp",
      handler = "PHomeExchangeDealerHandler"
    },
    [1762838695] = {
      req = "manor_mystery_man_info_req",
      res = "manor_mystery_man_info_rsp",
      handler = "PHomeExchangeDealerHandler"
    },
    [451014033] = {
      res = "manor_redpacket_grab_ntf",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [707234215] = {
      req = "manor_redpacket_grab_req",
      res = "manor_redpacket_grab_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [818184487] = {
      req = "read_manor_personal_redpoint_req",
      res = "read_manor_personal_redpoint_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [992489095] = {
      req = "equip_manor_personal_item_req",
      res = "equip_manor_personal_item_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [1064154707] = {
      req = "manor_redpacket_records_req",
      res = "manor_redpacket_records_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [1196054759] = {
      req = "manor_redpacket_prepare_req",
      res = "manor_redpacket_prepare_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [1226558398] = {
      res = "manor_personal_new_ntf",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [1324477151] = {
      req = "manor_redpacket_place_req",
      res = "manor_redpacket_place_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [1416415747] = {
      req = "manor_redpacket_build_req",
      res = "manor_redpacket_build_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [1456829905] = {
      res = "manor_redpacket_change_ntf",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [1898349891] = {
      req = "get_manor_personal_data_req",
      res = "get_manor_personal_data_rsp",
      inGameOper = 0,
      handler = "PHomeGiftBoxHandler"
    },
    [53084464] = {
      res = "notify_manor_tree_level_change",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [138851145] = {
      res = "notify_manor_new_tree",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [214356626] = {
      res = "notify_plant_tree",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [936439071] = {
      req = "place_plant_req",
      res = "place_plant_rsp",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1089238627] = {
      req = "get_recent_manor_assist_req",
      res = "get_recent_manor_assist_rsp",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1366752199] = {
      req = "plant_tree_req",
      res = "plant_tree_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1421271911] = {
      req = "manor_tree_water_req",
      res = "manor_tree_water_rsp",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1610046751] = {
      req = "joint_collect_offmsg_read_req",
      res = "joint_collect_offmsg_read_rsp",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1658363151] = {
      req = "manor_tree_feed_req",
      res = "manor_tree_feed_rsp",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1726721511] = {
      req = "get_collect_record_req",
      res = "get_collect_record_rsp",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1915476626] = {
      res = "mate_collect_notify",
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1958410151] = {
      req = "collect_tree_req",
      res = "collect_tree_rsp",
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [2108375823] = {
      req = "manor_tree_list_req",
      res = "manor_tree_list_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "PHomeGoldenTreeHandler"
    },
    [1119087747] = {
      req = "manor_hide_seek_state_set_req",
      res = "manor_hide_seek_state_set_rsp",
      handler = "PHomeHalloweenHandler"
    },
    [1532640531] = {
      req = "manor_spray_drawing_req",
      res = "manor_spray_drawing_rsp",
      handler = "PHomeHalloweenHandler"
    },
    [1646761999] = {
      res = "manor_spray_item_count_notify",
      handler = "PHomeHalloweenHandler"
    },
    [1667066939] = {
      req = "manor_spray_drawer_list_req",
      res = "manor_spray_drawer_list_rsp",
      handler = "PHomeHalloweenHandler"
    },
    [1842472667] = {
      res = "manor_hide_seek_notify",
      handler = "PHomeHalloweenHandler"
    },
    [2128141671] = {
      req = "manor_hide_seek_info_req",
      res = "manor_hide_seek_info_rsp",
      handler = "PHomeHalloweenHandler"
    },
    [1346261623] = {
      req = "manor_encrypt_module_data_req",
      res = "manor_encrypt_module_data_rsp",
      inGameOper = 0,
      handler = "PHomeHandler"
    },
    [1828043943] = {
      req = "manor_on_client_call_req",
      res = "manor_on_client_call_rsp",
      inGameOper = 0,
      handler = "PHomeHandler"
    },
    [85455051] = {
      req = "manor_butler_switch_outward_req",
      res = "manor_butler_switch_outward_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [322242742] = {
      res = "manor_butler_gift_ntf",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [396055143] = {
      req = "manor_butler_memmory_req",
      res = "manor_butler_memmory_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [462803751] = {
      req = "manor_butler_dialogue_report_req",
      res = "manor_butler_dialogue_report_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [852271215] = {
      res = "manor_joint_butler_change_ntf",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [956718659] = {
      req = "manor_butler_history_dialogue_req",
      res = "manor_butler_history_dialogue_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1060849267] = {
      req = "manor_butler_read_action_id_req",
      res = "manor_butler_read_action_id_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1238598759] = {
      req = "manor_butler_switch_req",
      res = "manor_butler_switch_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1259676839] = {
      req = "manor_butler_save_dialogue_req",
      res = "manor_butler_save_dialogue_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1403831459] = {
      req = "manor_butler_init_action_id_req",
      res = "manor_butler_init_action_id_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1566146262] = {
      res = "manor_new_butler_ntf",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1578003815] = {
      req = "manor_butler_req",
      res = "manor_butler_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1755276879] = {
      res = "manor_butler_switch_outward_ntf",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1763028871] = {
      req = "manor_butler_send_gift_req",
      res = "manor_butler_send_gift_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1918531103] = {
      req = "manor_party_butler_item_req",
      res = "manor_party_butler_item_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeHousekeeperHandler"
    },
    [1152438355] = {
      req = "manor_batch_buy_stage_req",
      res = "manor_batch_buy_stage_rsp",
      inGameOper = 0,
      handler = "PHomeInstallmentHandler"
    },
    [1203817487] = {
      req = "manor_stage_pre_pay_req",
      res = "manor_stage_pre_pay_rsp",
      inGameOper = 0,
      handler = "PHomeInstallmentHandler"
    },
    [1247511207] = {
      req = "manor_stage_deduct_items_req",
      res = "manor_stage_deduct_items_rsp",
      inGameOper = 0,
      handler = "PHomeInstallmentHandler"
    },
    [1816035719] = {
      req = "get_manor_batch_buy_stage_info_req",
      res = "get_manor_batch_buy_stage_info_rsp",
      inGameOper = 0,
      handler = "PHomeInstallmentHandler"
    },
    [17235407] = {
      req = "last_joint_manor_to_model_req",
      res = "last_joint_manor_to_model_rsp",
      handler = "PHomeJointHandler"
    },
    [23174023] = {
      req = "manor_joint_invite_req",
      res = "manor_joint_invite_rsp",
      handler = "PHomeJointHandler"
    },
    [110351727] = {
      req = "manor_joint_terminate_apply_req",
      res = "manor_joint_terminate_apply_rsp",
      handler = "PHomeJointHandler"
    },
    [364247340] = {
      res = "manor_joint_invite_notify",
      handler = "PHomeJointHandler"
    },
    [420247413] = {
      res = "manor_joint_terminate_reply_notify",
      handler = "PHomeJointHandler"
    },
    [457222695] = {
      req = "manor_joint_info_req",
      res = "manor_joint_info_rsp",
      isUnique = 1,
      timeout = 4,
      needRsp = 3,
      handler = "PHomeJointHandler"
    },
    [615927863] = {
      req = "manor_joint_terminate_reply_req",
      res = "manor_joint_terminate_reply_rsp",
      handler = "PHomeJointHandler"
    },
    [855551534] = {
      res = "manor_joint_finish_notify",
      handler = "PHomeJointHandler"
    },
    [898920687] = {
      req = "manor_joint_reply_req",
      res = "manor_joint_reply_rsp",
      handler = "PHomeJointHandler"
    },
    [1277922403] = {
      res = "manor_joint_terminate_apply_notify",
      handler = "PHomeJointHandler"
    },
    [1462275541] = {
      res = "manor_joint_start_notify",
      handler = "PHomeJointHandler"
    },
    [609987499] = {
      req = "manor_butler_ai_enter_req",
      res = "manor_butler_ai_enter_rsp",
      isUnique = 1,
      queueType = 1,
      timeInterval = 10,
      handler = "PHomeKeeperAIHandler"
    },
    [828274407] = {
      req = "manor_butler_ai_dialogue_req",
      res = "manor_butler_ai_dialogue_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "PHomeKeeperAIHandler"
    },
    [1052665831] = {
      req = "manor_aigc_translate_req",
      res = "manor_aigc_translate_rsp",
      handler = "PHomeKeeperAIHandler"
    },
    [1166562495] = {
      req = "manor_butler_ai_count_req",
      res = "manor_butler_ai_count_rsp",
      isUnique = 1,
      queueType = 1,
      timeInterval = 10,
      handler = "PHomeKeeperAIHandler"
    },
    [1285739079] = {
      req = "manor_butler_ai_report_req",
      res = "manor_butler_ai_report_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "PHomeKeeperAIHandler"
    },
    [1548365331] = {
      req = "manor_butler_ai_close_req",
      res = "manor_butler_ai_close_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "PHomeKeeperAIHandler"
    },
    [1599258759] = {
      req = "manor_butler_ai_clear_abstract_req",
      res = "manor_butler_ai_clear_abstract_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "PHomeKeeperAIHandler"
    },
    [1007682527] = {
      res = "notify_manor_level_extra_reward",
      handler = "PHomeLevelExtraRewardHandler"
    },
    [1208694687] = {
      req = "take_manor_level_extra_reward_req",
      res = "take_manor_level_extra_reward_rsp",
      handler = "PHomeLevelExtraRewardHandler"
    },
    [1277667103] = {
      req = "get_manor_level_extra_reward_list_req",
      res = "get_manor_level_extra_reward_list_rsp",
      handler = "PHomeLevelExtraRewardHandler"
    },
    [99574203] = {
      req = "manor_add_collect_req",
      res = "manor_add_collect_rsp",
      inGameOper = 0,
      handler = "PHomeListViewHandler"
    },
    [261217967] = {
      req = "get_manor_collect_req",
      res = "get_manor_collect_rsp",
      inGameOper = 0,
      handler = "PHomeListViewHandler"
    },
    [779947687] = {
      req = "not_open_manor_be_visit_info_req",
      res = "not_open_manor_be_visit_info_rsp",
      inGameOper = 0,
      handler = "PHomeListViewHandler"
    },
    [1072096663] = {
      req = "get_manor_recommend_req",
      res = "get_manor_recommend_rsp",
      inGameOper = 0,
      handler = "PHomeListViewHandler"
    },
    [1092196967] = {
      req = "get_manor_visit_history_req",
      res = "get_manor_visit_history_rsp",
      inGameOper = 0,
      handler = "PHomeListViewHandler"
    },
    [1139950503] = {
      req = "manor_visitor_counts_req",
      res = "manor_visitor_counts_rsp",
      inGameOper = 0,
      handler = "PHomeListViewHandler"
    },
    [1263683453] = {
      res = "notify_enter_manor_faild",
      inGameOper = 0,
      handler = "PHomeLoadingHandler"
    },
    [67806951] = {
      req = "manor_message_delete_req",
      res = "manor_message_delete_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [67890591] = {
      req = "manor_leave_message_req",
      res = "manor_leave_message_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [358540179] = {
      req = "manor_message_reply_req",
      res = "manor_message_reply_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [444702367] = {
      req = "manor_message_top_req",
      res = "manor_message_top_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [596550599] = {
      req = "manor_message_reply_delete_req",
      res = "manor_message_reply_delete_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [691885105] = {
      res = "delete_all_message_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [1039654687] = {
      res = "manor_message_redpoint_notify",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [1172908467] = {
      req = "manor_visit_base_info_req",
      res = "manor_visit_base_info_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [1176087455] = {
      req = "manor_visited_record_list_req",
      res = "manor_visited_record_list_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [1318439815] = {
      req = "manor_message_list_req",
      res = "manor_message_list_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [1358189507] = {
      req = "manor_click_redpoint_req",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [1775823963] = {
      req = "manor_message_base_info_req",
      res = "manor_message_base_info_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [1839600487] = {
      req = "set_manor_welcome_text_req",
      res = "set_manor_welcome_text_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [2052207143] = {
      req = "manor_message_reply_list_req",
      res = "manor_message_reply_list_rsp",
      inGameOper = 0,
      handler = "PHomeMessageBoardHandler"
    },
    [246545575] = {
      req = "manor_party_cancel_req",
      res = "manor_party_cancel_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [257364327] = {
      req = "manor_party_modify_req",
      res = "manor_party_modify_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [315055159] = {
      req = "manor_party_start_count_req",
      res = "manor_party_start_count_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 10,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [349080711] = {
      req = "soulmate_ceremony_info_req",
      res = "soulmate_ceremony_info_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [452842343] = {
      req = "manor_party_history_list_req",
      res = "manor_party_history_list_rsp",
      handler = "PHomePartyHandler"
    },
    [616326490] = {
      res = "soulmate_ceremony_create_notify",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [776998853] = {
      req = "manor_party_comm_action_req",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [778037095] = {
      req = "manor_party_type_start_count_req",
      res = "manor_party_type_start_count_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 10,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [1081463943] = {
      req = "manor_party_gift_items_req",
      res = "manor_party_gift_items_rsp",
      handler = "PHomePartyHandler"
    },
    [1145281959] = {
      req = "manor_party_list_req",
      res = "manor_party_list_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 10,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [1333573051] = {
      req = "manor_free_gift_party_cnt_req",
      res = "manor_free_gift_party_cnt_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [1385456039] = {
      req = "soulmate_ceremony_create_req",
      res = "soulmate_ceremony_create_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [1559430007] = {
      req = "manor_party_start_req",
      res = "manor_party_start_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "PHomePartyHandler"
    },
    [456969807] = {
      req = "manor_upass_batch_take_reward_req",
      res = "manor_upass_batch_take_reward_rsp",
      handler = "PHomePassHandler"
    },
    [1191841703] = {
      req = "manor_upass_info_req",
      res = "manor_upass_info_rsp",
      handler = "PHomePassHandler"
    },
    [1693398699] = {
      req = "manor_upass_take_reward_req",
      res = "manor_upass_take_reward_rsp",
      handler = "PHomePassHandler"
    },
    [1758314447] = {
      req = "manor_upass_buy_elite_req",
      res = "manor_upass_buy_elite_rsp",
      handler = "PHomePassHandler"
    },
    [2072082555] = {
      req = "manor_upass_joint_wow_buy_req",
      res = "manor_upass_joint_wow_buy_rsp",
      inGameOper = 0,
      handler = "PHomePassHandler"
    },
    [601175279] = {
      req = "save_manor_photo_wall_req",
      res = "save_manor_photo_wall_rsp",
      inGameOper = 0,
      handler = "PHomePhotoWallHandler"
    },
    [735580391] = {
      req = "get_unlocked_photo_frame_req",
      res = "get_unlocked_photo_frame_rsp",
      handler = "PHomePhotoWallHandler"
    },
    [784657027] = {
      res = "save_manor_photo_wall_notify",
      inGameOper = 0,
      handler = "PHomePhotoWallHandler"
    },
    [929373186] = {
      res = "manor_photo_frame_notify",
      inGameOper = 0,
      handler = "PHomePhotoWallHandler"
    },
    [1156792231] = {
      req = "get_manor_photo_wall_req",
      res = "get_manor_photo_wall_rsp",
      inGameOper = 0,
      handler = "PHomePhotoWallHandler"
    },
    [17733515] = {
      res = "joint_pigeon_base_change_ntf",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [44397459] = {
      req = "get_pigeon_reply_center_req",
      res = "get_pigeon_reply_center_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [189665703] = {
      req = "pigeon_reply_req",
      res = "pigeon_reply_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [340336711] = {
      req = "manor_pigeon_fly_award_req",
      res = "manor_pigeon_fly_award_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [349921767] = {
      req = "get_pigeon_access_record_req",
      res = "get_pigeon_access_record_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [504494687] = {
      req = "change_pigeon_model_req",
      res = "change_pigeon_model_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [534520959] = {
      req = "user_pigeon_base_info_req",
      res = "user_pigeon_base_info_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [604187960] = {
      res = "joint_pigeon_fly_ntf",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [615499047] = {
      req = "look_access_pigeon_req",
      res = "look_access_pigeon_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [692233607] = {
      req = "fly_pigeon_req",
      res = "fly_pigeon_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [761261367] = {
      req = "pigeon_sub_reply_list_req",
      res = "pigeon_sub_reply_list_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [857549651] = {
      req = "pigeon_reply_list_req",
      res = "pigeon_reply_list_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [943225879] = {
      req = "get_pigeon_fly_record_req",
      res = "get_pigeon_fly_record_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [1270238245] = {
      res = "delete_pigeon_all_reply_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [1849028198] = {
      res = "pigeon_redpoint_notify",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [1917390839] = {
      req = "delete_pigeon_reply_req",
      res = "delete_pigeon_reply_rsp",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [1962667545] = {
      res = "pigeon_access_notify",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [2055836721] = {
      res = "access_pigeon_leave_notify",
      inGameOper = 0,
      handler = "PHomePigeonHandler"
    },
    [124474611] = {
      req = "manor_summary_by_manor_id_req",
      res = "manor_summary_by_manor_id_rsp",
      inGameOper = 0,
      handler = "PHomeProfileHandler"
    },
    [199457895] = {
      req = "manor_summarys_req",
      res = "manor_summarys_rsp",
      inGameOper = 0,
      handler = "PHomeProfileHandler"
    },
    [2045283559] = {
      req = "manor_report_req",
      res = "manor_report_rsp",
      inGameOper = 0,
      handler = "PHomeReportHandler"
    },
    [817316375] = {
      req = "get_manor_instacne_list_req",
      res = "get_manor_instacne_list_rsp",
      inGameOper = 0,
      handler = "PHomeRoomHandler"
    },
    [1146355943] = {
      req = "get_manor_attributes_req",
      res = "get_manor_attributes_rsp",
      inGameOper = 0,
      handler = "PHomeRoomHandler"
    },
    [1729312103] = {
      req = "launch_manor_req",
      res = "launch_manor_rsp",
      inGameOper = 0,
      handler = "PHomeSingleHandler"
    },
    [783704911] = {
      res = "manor_snow_points_change_ntf",
      handler = "PHomeSnowPartyHandler"
    },
    [1232808743] = {
      req = "manor_snowball_game_result_req",
      res = "manor_snowball_game_result_rsp",
      handler = "PHomeSnowPartyHandler"
    },
    [1410962335] = {
      req = "manor_snow_shop_buy_req",
      res = "manor_snow_shop_buy_rsp",
      handler = "PHomeSnowPartyHandler"
    },
    [1630923691] = {
      req = "manor_snow_info_req",
      res = "manor_snow_info_rsp",
      handler = "PHomeSnowPartyHandler"
    },
    [1874516455] = {
      req = "manor_snowball_start_req",
      res = "manor_snowball_start_rsp",
      handler = "PHomeSnowPartyHandler"
    },
    [1920691815] = {
      req = "get_snowman_make_records_req",
      res = "get_snowman_make_records_rsp",
      handler = "PHomeSnowPartyHandler"
    },
    [47209739] = {
      req = "manor_draw_exchange_req",
      res = "manor_draw_exchange_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [188578983] = {
      req = "get_manor_mate_depot_req",
      res = "get_manor_mate_depot_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [409671287] = {
      req = "manor_draw_info_req",
      res = "manor_draw_info_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [421909151] = {
      req = "manor_shop_box_info_req",
      res = "manor_shop_box_info_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeInterval = 0.5,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [582203919] = {
      req = "get_manor_shop_recommend_list_req",
      res = "get_manor_shop_recommend_list_rsp",
      handler = "PHomeStoreHandler"
    },
    [704024679] = {
      req = "manor_shop_chest_req",
      res = "manor_shop_chest_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeInterval = 0.5,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [758250874] = {
      res = "manor_mate_item_change_notify",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [790828158] = {
      res = "activity_manor_style_score_notify",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [894464679] = {
      req = "manor_batch_buy_item_req",
      res = "manor_batch_buy_item_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1108423655] = {
      req = "manor_shop_energe_exchange_req",
      res = "manor_shop_energe_exchange_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeInterval = 0.5,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1158003997] = {
      res = "notify_manor_coins_change",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1167140863] = {
      req = "get_manor_depot_req",
      res = "get_manor_depot_rsp",
      isUnique = 1,
      queueType = 1,
      needRsp = 3,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1233296327] = {
      req = "manor_draw_req",
      res = "manor_draw_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeInterval = 0.5,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1244981991] = {
      res = "notify_manor_items_change",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1416189215] = {
      req = "take_draw_guarantee_award_req",
      res = "take_draw_guarantee_award_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1778131720] = {
      res = "manor_exchange_coin_ntf",
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [1836955523] = {
      req = "manor_buy_req",
      res = "manor_buy_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeInterval = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [2125122671] = {
      req = "manor_shop_buy_record_req",
      res = "manor_shop_buy_record_rsp",
      isUnique = 1,
      queueType = 1,
      inGameOper = 0,
      handler = "PHomeStoreHandler"
    },
    [263354574] = {
      req = "report_manor_butler_interaction",
      inGameOper = 0,
      handler = "PHomeTaskHandler"
    },
    [542006347] = {
      res = "manor_task_update_notify",
      inGameOper = 0,
      handler = "PHomeTaskHandler"
    },
    [663150055] = {
      req = "get_manor_task_list_req",
      res = "get_manor_task_list_rsp",
      inGameOper = 0,
      handler = "PHomeTaskHandler"
    },
    [1200190699] = {
      req = "batch_take_manor_task_award_req",
      res = "batch_take_manor_task_award_rsp",
      inGameOper = 0,
      handler = "PHomeTaskHandler"
    },
    [1944483215] = {
      req = "take_manor_task_award_req",
      res = "take_manor_task_award_rsp",
      inGameOper = 0,
      handler = "PHomeTaskHandler"
    },
    [1053585399] = {
      req = "visit_manor_req",
      res = "visit_manor_rsp",
      inGameOper = 0,
      handler = "PHomeVisitHandler"
    },
    [1628733283] = {
      res = "visit_manor_award_notify",
      inGameOper = 0,
      handler = "PHomeVisitHandler"
    },
    [2143624691] = {
      req = "get_friend_manor_info_req",
      res = "get_friend_manor_info_rsp",
      timeInterval = 1,
      handler = "PHomeVisitHandler"
    },
    [526082508] = {
      req = "record_pmgc_team_support_info",
      res = "record_pmgc_team_support_info_rsp",
      handler = "PandoraHandler"
    },
    [847557031] = {
      req = "get_pmgc_team_support_info_req",
      res = "get_pmgc_team_support_info_rsp",
      handler = "PandoraHandler"
    },
    [1421710503] = {
      req = "set_element_war_activation_req",
      res = "set_element_war_activation_rsp",
      timeInterval = 1,
      handler = "PandoraHandler"
    },
    [1600441511] = {
      req = "get_element_data_req",
      res = "get_element_data_rsp",
      timeInterval = 1,
      handler = "PandoraHandler"
    },
    [132721783] = {
      req = "upass_history_top_req",
      res = "upass_history_top_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      handler = "PassHander"
    },
    [184271155] = {
      res = "upass_score_auto_exchanged_notify",
      handler = "PassHander"
    },
    [245953639] = {
      req = "upass_open_check_req",
      res = "upass_open_check_rsp",
      handler = "PassHander"
    },
    [435164327] = {
      req = "upass_get_weekly_box_req",
      res = "upass_get_weekly_box_rsp",
      handler = "PassHander"
    },
    [714661715] = {
      req = "upass_get_season_info_req",
      res = "upass_get_season_info_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "PassHander"
    },
    [871393159] = {
      req = "upass_buy_play_card_req",
      res = "upass_buy_play_card_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "PassHander"
    },
    [1178721647] = {
      req = "recommend_rp_groupbuy_req",
      res = "recommend_rp_groupbuy_rsp",
      timeInterval = 6,
      handler = "PassHander"
    },
    [1286160807] = {
      req = "upass_top_reward_req",
      res = "upass_top_reward_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      handler = "PassHander"
    },
    [1432175273] = {
      req = "report_rp_groupbuy",
      handler = "PassHander"
    },
    [1675004019] = {
      req = "upass_play_card_weekly_reward_req",
      res = "upass_play_card_weekly_reward_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "PassHander"
    },
    [1692617684] = {
      req = "report_upass_banner",
      handler = "PassHander"
    },
    [107213063] = {
      req = "take_password_red_envelope_req",
      res = "take_password_red_envelope_rsp",
      isUnique = 1,
      handler = "PassworRedEnvelopeHandler"
    },
    [660025071] = {
      req = "get_password_red_envelope_req",
      res = "get_password_red_envelope_rsp",
      handler = "PassworRedEnvelopeHandler"
    },
    [224639039] = {
      req = "query_patroller_privilege_level_req",
      res = "query_patroller_privilege_level_rsp",
      handler = "PatrollerHandler"
    },
    [816081779] = {
      req = "query_patroller_stat_info_req",
      res = "query_patroller_stat_info_rsp",
      handler = "PatrollerHandler"
    },
    [6840479] = {
      res = "peakgame_time_notify",
      handler = "PeakGameHandler"
    },
    [68299484] = {
      res = "peakgame_info_notify",
      handler = "PeakGameHandler"
    },
    [379448067] = {
      req = "get_peakgame_prize_info_req",
      res = "get_peakgame_prize_info_rsp",
      handler = "PeakGameHandler"
    },
    [402197843] = {
      req = "get_peak_week_rank_time_req",
      res = "get_peak_week_rank_time_rsp",
      timeInterval = 1,
      handler = "PeakGameHandler"
    },
    [496494887] = {
      req = "get_peakgame_all_rating_info_req",
      res = "get_peakgame_all_rating_info_rsp",
      timeInterval = 1,
      handler = "PeakGameHandler"
    },
    [615546823] = {
      req = "set_segment_show_type_req",
      res = "set_segment_show_type_rsp",
      handler = "PeakGameHandler"
    },
    [681527194] = {
      res = "peakgame_rating_info_notify",
      handler = "PeakGameHandler"
    },
    [728559843] = {
      req = "get_peakgame_time_req",
      res = "get_peakgame_time_rsp",
      timeInterval = 1,
      handler = "PeakGameHandler"
    },
    [748257420] = {
      req = "get_friend_peakgame_rank",
      res = "get_friend_peakgame_rank_rsp",
      handler = "PeakGameHandler"
    },
    [842791975] = {
      req = "get_peakgame_fame_rank_req",
      res = "get_peakgame_fame_rank_rsp",
      handler = "PeakGameHandler"
    },
    [1004860711] = {
      req = "get_peakgame_segment_all_req",
      res = "get_peakgame_segment_all_rsp",
      handler = "PeakGameHandler"
    },
    [1221623552] = {
      req = "sync_peak_game_auth_check_result_req",
      res = "sync_peak_game_check_result_rsp",
      handler = "PeakGameHandler"
    },
    [1301838502] = {
      res = "peakgame_season_info_notify",
      handler = "PeakGameHandler"
    },
    [1317990119] = {
      req = "peakgame_result_reward_req",
      res = "peakgame_result_reward_rsp",
      handler = "PeakGameHandler"
    },
    [1353852827] = {
      req = "take_peakgame_segment_prize_all_req",
      res = "take_peakgame_segment_prize_all_rsp",
      handler = "PeakGameHandler"
    },
    [1531535171] = {
      req = "take_peakgame_segment_prize_req",
      res = "take_peakgame_segment_prize_rsp",
      handler = "PeakGameHandler"
    },
    [1738124615] = {
      req = "get_peakgame_info_req",
      res = "get_peakgame_info_rsp",
      timeInterval = 1,
      handler = "PeakGameHandler"
    },
    [1768532135] = {
      req = "get_peakgame_rating_info_req",
      res = "get_peakgame_rating_info_rsp",
      timeInterval = 1,
      handler = "PeakGameHandler"
    },
    [1814853479] = {
      req = "get_peakgame_season_info_req",
      res = "get_peakgame_season_info_rsp",
      timeInterval = 1,
      handler = "PeakGameHandler"
    },
    [1968512487] = {
      req = "query_peak_game_change_day_req",
      res = "query_peak_game_change_day_rsp",
      handler = "PeakGameHandler"
    },
    [1975412135] = {
      req = "batch_peakgame_result_reward_req",
      res = "batch_peakgame_result_reward_rsp",
      handler = "PeakGameHandler"
    },
    [2076919456] = {
      res = "peakgame_ace_reissue_notify",
      handler = "PeakGameHandler"
    },
    [376772255] = {
      req = "penguins_wash_req",
      res = "penguins_wash_rsp",
      handler = "PenguinHandler"
    },
    [87973068] = {
      req = "get_intimacy_relation_prior_show",
      res = "get_intimacy_relation_prior_show_rsp",
      handler = "PersonSpaceHandler"
    },
    [383579175] = {
      req = "get_interact_avatar_req",
      res = "get_interact_avatar_rsp",
      handler = "PersonSpaceHandler"
    },
    [411250807] = {
      req = "set_interact_avatar_req",
      res = "set_interact_avatar_rsp",
      handler = "PersonSpaceHandler"
    },
    [757391055] = {
      req = "agree_make_intimacy_partner_req",
      res = "agree_make_intimacy_partner_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [785122215] = {
      req = "refuse_make_intimacy_partner_req",
      res = "refuse_make_intimacy_partner_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [823584179] = {
      req = "batch_get_frd_interact_info_req",
      res = "batch_get_frd_interact_info_rsp",
      handler = "PersonSpaceHandler"
    },
    [940551655] = {
      req = "release_intimacy_partner_req",
      res = "release_intimacy_partner_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [996111764] = {
      req = "remove_intimacy_reddot",
      handler = "PersonSpaceHandler"
    },
    [999680891] = {
      req = "make_intimacy_partner_req",
      res = "make_intimacy_partner_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [1094925516] = {
      req = "set_intimacy_relation_prior_show",
      res = "set_intimacy_relation_prior_show_rsp",
      handler = "PersonSpaceHandler"
    },
    [1424525863] = {
      req = "cancle_make_intimacy_partner_req",
      res = "cancle_make_intimacy_partner_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [1475471803] = {
      req = "soulmate_keepsake_show_switch_set_req",
      res = "soulmate_keepsake_show_switch_set_rsp",
      handler = "PersonSpaceHandler"
    },
    [1492744711] = {
      req = "set_intimacy_relation_visible_req",
      res = "set_intimacy_relation_visible_rsp",
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [1525003024] = {
      res = "notify_client_intimacy_data_chg",
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [1759661095] = {
      req = "set_interact_crystal_req",
      res = "set_interact_crystal_rsp",
      handler = "PersonSpaceHandler"
    },
    [1799379383] = {
      req = "get_intimacy_relation_visible_req",
      res = "get_intimacy_relation_visible_rsp",
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [1862470287] = {
      req = "get_other_intimacy_relation_req",
      res = "get_other_intimacy_relation_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "PersonSpaceHandler"
    },
    [159544259] = {
      req = "set_pet_color_req",
      res = "set_pet_color_rsp",
      timeInterval = 3,
      handler = "PetHandler"
    },
    [302736675] = {
      req = "query_pet_dress_shop_info_req",
      res = "query_pet_dress_shop_info_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [361861303] = {
      req = "get_pet_switch_effect_req",
      res = "get_pet_switch_effect_rsp",
      handler = "PetHandler"
    },
    [665310606] = {
      res = "notice_pet_event_res",
      handler = "PetHandler"
    },
    [845172199] = {
      req = "pet_unload_dress_req",
      res = "pet_unload_dress_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1000635059] = {
      req = "equip_pet_req",
      res = "equip_pet_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1086415527] = {
      req = "change_pet_model_req",
      res = "change_pet_model_rsp",
      inGameOper = 0,
      handler = "PetHandler"
    },
    [1116577431] = {
      req = "unequip_pet_req",
      res = "unequip_pet_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1172477159] = {
      req = "pet_used_dress_req",
      res = "pet_used_dress_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1210617335] = {
      req = "pet_add_exp_req",
      res = "pet_add_exp_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1260473351] = {
      req = "pet_reanme_req",
      res = "pet_reanme_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1304529709] = {
      res = "notify_pet_show",
      inGameOper = 0,
      handler = "PetHandler"
    },
    [1308045127] = {
      req = "pet_decompose_list_req",
      res = "pet_decompose_list_rsp",
      handler = "PetHandler"
    },
    [1309574951] = {
      req = "pet_show_req",
      res = "pet_show_rsp",
      inGameOper = 0,
      handler = "PetHandler"
    },
    [1407533223] = {
      req = "carry_pet_req",
      res = "carry_pet_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1408598919] = {
      req = "pet_action_req",
      res = "pet_action_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [1630498851] = {
      req = "set_equip_pet_switch_effect_req",
      res = "set_equip_pet_switch_effect_rsp",
      handler = "PetHandler"
    },
    [1800414131] = {
      res = "notice_dress_change",
      handler = "PetHandler"
    },
    [1908689575] = {
      req = "get_pet_tab_info_req",
      res = "get_pet_tab_info_rsp",
      handler = "PetHandler"
    },
    [1955470147] = {
      req = "shared_pet_config_req",
      res = "shared_pet_config_rsp",
      handler = "PetHandler"
    },
    [1984253053] = {
      res = "notice_pet_change",
      handler = "PetHandler"
    },
    [2075341224] = {
      req = "get_pet_data_req",
      res = "sync_pet_data",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      handler = "PetHandler"
    },
    [45978471] = {
      req = "get_update_mail_info_req",
      res = "get_update_mail_info_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [398127576] = {
      res = "account_steal_popup_notify",
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [751360871] = {
      req = "query_social_email_req",
      res = "query_social_email_rsp",
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [894743668] = {
      res = "can_use_self_build_account",
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [948436738] = {
      res = "push_social_bind_notify",
      handler = "PhoneMailLoginHandler"
    },
    [1552916647] = {
      req = "get_self_build_account_award_req",
      res = "get_self_build_account_award_rsp",
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [1712374083] = {
      req = "send_account_verify_code_req",
      res = "get_self_build_account_verify_code_rsp",
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [1803350663] = {
      req = "verify_check_cur_bind_account_req",
      res = "verify_check_cur_bind_account_rsp",
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [1848641607] = {
      req = "get_self_build_account_req",
      res = "get_self_build_account_rsp",
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [2135566435] = {
      req = "modify_self_build_account_req",
      res = "update_self_build_account_res",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "PhoneMailLoginHandler"
    },
    [2003376539] = {
      req = "report_lobby_ping_bad_req",
      res = "report_lobby_ping_bad_rsp",
      inGameOper = 0,
      handler = "PingHander"
    },
    [804617802] = {
      res = "collect_hall_invite_notify",
      inGameOper = 0,
      handler = "PlanCHInviteHandler"
    },
    [1358846911] = {
      req = "collect_hall_invite_reply_req",
      res = "collect_hall_invite_reply_rsp",
      handler = "PlanCHInviteHandler"
    },
    [1394710787] = {
      req = "collect_hall_invite_req",
      res = "collect_hall_invite_rsp",
      handler = "PlanCHInviteHandler"
    },
    [582733991] = {
      req = "get_collect_hall_level_award_req",
      res = "get_collect_hall_level_award_rsp",
      inGameOper = 0,
      handler = "PlanCHLevelRewardHandler"
    },
    [1888442895] = {
      req = "take_collect_hall_level_award_req",
      res = "take_collect_hall_level_award_rsp",
      inGameOper = 0,
      handler = "PlanCHLevelRewardHandler"
    },
    [126606207] = {
      req = "get_collect_hall_detail_req",
      res = "get_collect_hall_detail_rsp",
      handler = "PlanCH_Friend_Visit_Client_Handler"
    },
    [265486951] = {
      req = "get_friend_collect_hall_info_req",
      res = "get_friend_collect_hall_info_rsp",
      handler = "PlanCH_Friend_Visit_Client_Handler"
    },
    [1139337367] = {
      req = "get_collect_hall_summarys_req",
      res = "get_collect_hall_summarys_rsp",
      handler = "PlanCH_Friend_Visit_Client_Handler"
    },
    [113107551] = {
      req = "stereo_select_music_req",
      res = "stereo_select_music_rsp",
      inGameOper = 0,
      handler = "PlanPHMusicHandler"
    },
    [596836583] = {
      req = "manor_guide_progress_report_req",
      res = "manor_guide_progress_report_rsp",
      handler = "PlanPHNewbieGuideHandler"
    },
    [611150735] = {
      req = "finish_manor_newbie_guide_req",
      res = "finish_manor_newbie_guide_rsp",
      inGameOper = 0,
      handler = "PlanPHNewbieGuideHandler"
    },
    [680390055] = {
      req = "manor_get_guide_progress_req",
      res = "manor_get_guide_progress_rsp",
      handler = "PlanPHNewbieGuideHandler"
    },
    [783757831] = {
      req = "get_manor_newbie_guide_req",
      res = "get_manor_newbie_guide_rsp",
      inGameOper = 0,
      handler = "PlanPHNewbieGuideHandler"
    },
    [321476455] = {
      req = "manor_ambient_module_set_req",
      res = "manor_ambient_module_set_rsp",
      inGameOper = 0,
      handler = "PlanPHThemeSetHandler"
    },
    [1775934247] = {
      req = "manor_buy_ambient_module_req",
      res = "manor_buy_ambient_module_rsp",
      inGameOper = 0,
      handler = "PlanPHThemeSetHandler"
    },
    [1741973643] = {
      req = "rescission_of_authorization_req",
      res = "rescission_of_authorization_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "PlatformHandler"
    },
    [2076148327] = {
      req = "authorize_platform_req",
      res = "authorize_platform_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "PlatformHandler"
    },
    [80545835] = {
      req = "system_entrance_show_guide",
      handler = "PlayerLabelHandler"
    },
    [113444711] = {
      req = "update_care_mentor_label_req",
      res = "update_care_mentor_label_rsp",
      handler = "PlayerLabelHandler"
    },
    [160488186] = {
      req = "more_entrance_show",
      handler = "PlayerLabelHandler"
    },
    [167385932] = {
      req = "get_sales_high_quality_items",
      res = "get_sales_high_quality_items_rsp",
      handler = "PlayerLabelHandler"
    },
    [216577296] = {
      req = "report_has_high_quality_items_res",
      handler = "PlayerLabelHandler"
    },
    [371179236] = {
      req = "is_choose_novice_level",
      handler = "PlayerLabelHandler"
    },
    [486112535] = {
      res = "notify_match_client_type_history",
      inGameOper = 0,
      handler = "PlayerLabelHandler"
    },
    [529342313] = {
      req = "sync_guide_season_cond_req",
      res = "sync_guide_cond_rsp",
      handler = "PlayerLabelHandler"
    },
    [977580131] = {
      req = "get_growup_mark_label_req",
      res = "get_growup_mark_label_rsp",
      handler = "PlayerLabelHandler"
    },
    [1023059607] = {
      req = "set_ai_alloc_mark_req",
      res = "set_ai_alloc_mark_rsp",
      handler = "PlayerLabelHandler"
    },
    [1027084125] = {
      req = "set_rating_protect_mark",
      res = "set_growup_rating_protect_mark_rsp",
      inGameOper = 0,
      handler = "PlayerLabelHandler"
    },
    [1086918631] = {
      req = "update_growup_mark_label_req",
      res = "update_growup_mark_label_rsp",
      handler = "PlayerLabelHandler"
    },
    [1580503291] = {
      req = "set_warm_game_label_req",
      res = "set_warm_game_label_rsp",
      inGameOper = 0,
      handler = "PlayerLabelHandler"
    },
    [1771113387] = {
      req = "get_personas_labels_req",
      res = "get_personas_labels_rsp",
      handler = "PlayerLabelHandler"
    },
    [2056572575] = {
      req = "get_match_num_req",
      res = "get_match_num_rsp",
      inGameOper = 0,
      handler = "PlayerLabelHandler"
    },
    [2063944151] = {
      req = "newbie_fight_guide_get_reward_req",
      res = "newbie_fight_guide_get_reward_rsp",
      handler = "PlayerLabelHandler"
    },
    [2140257127] = {
      req = "set_warm_game_mark_req",
      res = "set_warm_game_mark_rsp",
      inGameOper = 0,
      handler = "PlayerLabelHandler"
    },
    [96733295] = {
      req = "backuser_claim_mode_first_battle_reward_req",
      res = "backuser_claim_mode_first_battle_reward_rsp",
      handler = "PlayerReturnHandler"
    },
    [127275688] = {
      req = "backuser_get_task_list_req",
      res = "backuser_get_task_list_res",
      handler = "PlayerReturnHandler"
    },
    [138833858] = {
      req = "backuser_get_user_guide_req",
      res = "backuser_get_user_guide_res",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [171389472] = {
      req = "backuser_longline_task_reward_req",
      res = "backuser_longline_task_reward_res",
      handler = "PlayerReturnHandler"
    },
    [212286032] = {
      req = "backuser_get_daily_reward_req",
      res = "backuser_get_daily_reward_res",
      handler = "PlayerReturnHandler"
    },
    [216425666] = {
      req = "backuser_get_guide_reward_req",
      res = "backuser_get_guide_reward_res",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [216573252] = {
      res = "backuser_data_change_notify",
      handler = "PlayerReturnHandler"
    },
    [252265336] = {
      req = "backuser_get_login_reward_req",
      res = "backuser_get_login_reward_res",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [280219496] = {
      req = "get_back_user_welcome_gift_req",
      res = "get_back_user_welcome_gift_res",
      inGameOper = 0,
      handler = "PlayerReturnHandler"
    },
    [307905659] = {
      res = "backuser_info_notify",
      handler = "PlayerReturnHandler"
    },
    [380976008] = {
      req = "back_user_notify_friends_gifts_req",
      res = "back_user_notify_friends_gifts_res",
      handler = "PlayerReturnHandler"
    },
    [514035208] = {
      req = "backuser_get_topup_rebate_info_req",
      res = "backuser_get_topup_rebate_info_res",
      handler = "PlayerReturnHandler"
    },
    [537136816] = {
      res = "back_user_daily_battle_award_notify",
      inGameOper = 0,
      handler = "PlayerReturnHandler"
    },
    [565436160] = {
      req = "backuser_get_segment_goal_req",
      res = "backuser_get_segment_goal_res",
      handler = "PlayerReturnHandler"
    },
    [586049281] = {
      req = "backuser_get_login_reward_info_req",
      res = "backuser_get_login_reward_info_notify",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [616869992] = {
      req = "backuser_frd_active_reward_req",
      res = "backuser_frd_active_reward_res",
      handler = "PlayerReturnHandler"
    },
    [757123980] = {
      res = "back_user_guide_profile_notify",
      handler = "PlayerReturnHandler"
    },
    [806168712] = {
      req = "backuser_get_new_content_req",
      res = "backuser_get_new_content_res",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [850888104] = {
      res = "client_guide_abtest_notify",
      inGameOper = 0,
      handler = "PlayerReturnHandler"
    },
    [958743374] = {
      req = "backuser_start_req",
      handler = "PlayerReturnHandler"
    },
    [1082702571] = {
      res = "backuser_longline_task_notify",
      handler = "PlayerReturnHandler"
    },
    [1202334890] = {
      req = "backuser_get_privilege_data_req",
      res = "backuser_get_privilege_data_res",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [1244575368] = {
      req = "backuser_active_frd_sync_req",
      res = "backuser_active_frd_sync_res",
      handler = "PlayerReturnHandler"
    },
    [1260263176] = {
      req = "backuser_segment_goal_reward_req",
      res = "backuser_segment_goal_reward_res",
      handler = "PlayerReturnHandler"
    },
    [1463215475] = {
      req = "backuser_get_new_content_task_award_req",
      res = "backuser_get_new_content_task_award_rsp",
      handler = "PlayerReturnHandler"
    },
    [1524487050] = {
      req = "backuser_select_all_index_req",
      res = "backuser_select_all_index_res",
      handler = "PlayerReturnHandler"
    },
    [1547294056] = {
      req = "backuser_get_user_gift_req",
      res = "backuser_get_user_gift_res",
      handler = "PlayerReturnHandler"
    },
    [1639256104] = {
      req = "backuser_set_guide_finished_req",
      res = "backuser_set_guide_finished_res",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [1658099008] = {
      req = "backuser_get_friend_recommend_req",
      res = "backuser_get_friend_recommend_res",
      handler = "PlayerReturnHandler"
    },
    [1658179357] = {
      res = "backuser_mode_first_battle_status_notify",
      inGameOper = 0,
      handler = "PlayerReturnHandler"
    },
    [1825788121] = {
      res = "warm_statistic_info_notify",
      inGameOper = 0,
      handler = "PlayerReturnHandler"
    },
    [1850967552] = {
      req = "get_topup_rebate_reward_req",
      res = "get_topup_rebate_reward_res",
      handler = "PlayerReturnHandler"
    },
    [1896194688] = {
      req = "backuser_battle_task_reward_req",
      res = "backuser_battle_task_reward_res",
      isLock = 1,
      handler = "PlayerReturnHandler"
    },
    [1897663115] = {
      req = "backuser_client_recommend_frd_req",
      res = "backuser_client_recommend_frd_rsp",
      inGameOper = 0,
      handler = "PlayerReturnHandler"
    },
    [1960103643] = {
      res = "back_user_score_change_notify",
      handler = "PlayerReturnHandler"
    },
    [1994427484] = {
      res = "notify_seg_protect_times",
      handler = "PlayerReturnHandler"
    },
    [2013579678] = {
      req = "back_user_client_recommend_frd_report",
      handler = "PlayerReturnHandler"
    },
    [2146336677] = {
      res = "share_card_info_notity",
      handler = "PlayerReturnHandler"
    },
    [1346591224] = {
      res = "notify_plot_info",
      handler = "PlotHandler"
    },
    [1506612268] = {
      req = "take_chapter_award",
      res = "take_chapter_award_rsp",
      handler = "PlotHandler"
    },
    [1892492334] = {
      req = "get_plot_info",
      res = "get_plot_info_rsp",
      handler = "PlotHandler"
    },
    [99351995] = {
      req = "mini_psmatch_get_rank_req",
      res = "mini_psmatch_get_rank_rsp",
      handler = "PopularTSLHandler"
    },
    [102110711] = {
      req = "mini_psmatch_get_lottery_result_req",
      res = "mini_psmatch_get_lottery_result_rsp",
      handler = "PopularTSLHandler"
    },
    [190618663] = {
      req = "mini_psmatch_get_devote_data_req",
      res = "mini_psmatch_get_devote_data_rsp",
      handler = "PopularTSLHandler"
    },
    [764615143] = {
      req = "mini_psmatch_get_pk_info_req",
      res = "mini_psmatch_get_pk_info_rsp",
      handler = "PopularTSLHandler"
    },
    [1216484295] = {
      req = "mini_psmatch_send_gift_req",
      res = "mini_psmatch_send_gift_rsp",
      handler = "PopularTSLHandler"
    },
    [1335116359] = {
      req = "mini_psmatch_get_match_cfg_req",
      res = "mini_psmatch_get_match_cfg_rsp",
      handler = "PopularTSLHandler"
    },
    [1430982790] = {
      res = "notify_mini_pspatch_valid_match",
      handler = "PopularTSLHandler"
    },
    [1701745339] = {
      res = "notify_mini_psmatch_total_devote",
      handler = "PopularTSLHandler"
    },
    [37292839] = {
      req = "delete_pspace_rank_record_req",
      res = "delete_pspace_rank_record_rsp",
      handler = "PopularityGiftHandler"
    },
    [48329775] = {
      req = "close_popularity_reddot_req",
      res = "close_popularity_reddot_rsp",
      handler = "PopularityGiftHandler"
    },
    [167986907] = {
      req = "get_self_daily_pop_gift_req",
      res = "get_self_daily_pop_gift_rsp",
      handler = "PopularityGiftHandler"
    },
    [179310343] = {
      req = "friends_quick_gift_req",
      res = "friends_quick_gift_rsp",
      handler = "PopularityGiftHandler"
    },
    [250503175] = {
      req = "get_gift_activity_rank_req",
      res = "get_gift_activity_rank_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "PopularityGiftHandler"
    },
    [255784167] = {
      req = "pspace_send_gift_req",
      res = "pspace_send_gift_rsp",
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [258766220] = {
      res = "show_msg_reddot",
      handler = "PopularityGiftHandler"
    },
    [273318306] = {
      res = "send_upvote_notify_rsp",
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [302760263] = {
      req = "delete_gift_record_req",
      res = "delete_gift_record_rsp",
      handler = "PopularityGiftHandler"
    },
    [317784615] = {
      req = "set_last_trend_top_req",
      res = "set_last_trend_top_rsp",
      handler = "PopularityGiftHandler"
    },
    [343229063] = {
      req = "pspace_gift_config_req",
      res = "pspace_gift_config_rsp",
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [386081479] = {
      req = "get_popularity_last_high_value_req",
      res = "get_popularity_last_high_value_rsp",
      handler = "PopularityGiftHandler"
    },
    [407329452] = {
      res = "pspace_send_gift_limit_rsp",
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [418622087] = {
      req = "get_personal_pop_activity_rank_req",
      res = "get_personal_pop_activity_rank_rsp",
      handler = "PopularityGiftHandler"
    },
    [439446522] = {
      res = "pspace_send_gift_ban_rsp",
      handler = "PopularityGiftHandler"
    },
    [510272427] = {
      req = "set_popularity_pround_visable_req",
      res = "set_popularity_pround_visable_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "PopularityGiftHandler"
    },
    [793110759] = {
      req = "query_quick_gift_friends_req",
      res = "query_quick_gift_friends_rsp",
      timeInterval = 2,
      handler = "PopularityGiftHandler"
    },
    [796250253] = {
      res = "send_gift_notify_rsp",
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [832391102] = {
      res = "manor_gift_notify",
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [913837199] = {
      req = "delete_gift_reply_req",
      res = "delete_gift_reply_rsp",
      handler = "PopularityGiftHandler"
    },
    [1132836839] = {
      req = "set_guardian_visable_req",
      res = "set_guardian_visable_rsp",
      isUnique = 1,
      queueType = 1,
      timeInterval = 1,
      handler = "PopularityGiftHandler"
    },
    [1222288335] = {
      req = "get_pop_gift_record_req",
      res = "get_pop_gift_record_rsp",
      queueType = 1,
      timeout = 10,
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [1513337671] = {
      req = "get_popularity_simple_req",
      res = "get_popularity_simple_rsp",
      handler = "PopularityGiftHandler"
    },
    [1589085351] = {
      req = "reply_gift_msg_req",
      res = "reply_gift_msg_rsp",
      handler = "PopularityGiftHandler"
    },
    [1641772519] = {
      req = "get_personal_gift_activity_rank_req",
      res = "get_personal_gift_activity_rank_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "PopularityGiftHandler"
    },
    [1731456327] = {
      req = "get_pspace_colletc_rank_req",
      res = "get_pspace_colletc_rank_rsp",
      handler = "PopularityGiftHandler"
    },
    [1818599335] = {
      req = "delete_last_trend_record_req",
      res = "delete_last_trend_record_rsp",
      handler = "PopularityGiftHandler"
    },
    [1933117319] = {
      req = "get_popularity_req",
      res = "get_popularity_rsp",
      handler = "PopularityGiftHandler"
    },
    [1964062423] = {
      req = "get_pop_activity_rank_req",
      res = "get_pop_activity_rank_rsp",
      handler = "PopularityGiftHandler"
    },
    [2014485863] = {
      req = "show_popularity_detail_req",
      res = "show_popularity_detail_rsp",
      inGameOper = 0,
      handler = "PopularityGiftHandler"
    },
    [103721763] = {
      req = "manor_scene_req",
      res = "manor_scene_rsp",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [494817687] = {
      req = "get_manor_pk_data_req",
      res = "get_manor_pk_data_rsp",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [973174279] = {
      req = "manor_pk_recommend_req",
      res = "manor_pk_recommend_rsp",
      handler = "PopularityHomePKHandler"
    },
    [1060186814] = {
      res = "manor_pk_vote_notify",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [1155254647] = {
      req = "get_manor_pk_info_by_uid_list_req",
      res = "get_manor_pk_info_by_uid_list_rsp",
      timeInterval = 1,
      handler = "PopularityHomePKHandler"
    },
    [1196713159] = {
      req = "get_manor_pk_push_info_req",
      res = "get_manor_pk_push_info_rsp",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [1433838311] = {
      req = "get_manor_pk_records_req",
      res = "get_manor_pk_records_rsp",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [1600015291] = {
      req = "get_manor_pk_detail_req",
      res = "get_manor_pk_detail_rsp",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [1609021443] = {
      req = "manor_pk_receive_awards_req",
      res = "manor_pk_receive_awards_rsp",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [1994583783] = {
      req = "batch_get_manor_pk_surface_url_req",
      res = "batch_get_manor_pk_surface_url_rsp",
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [2024609411] = {
      req = "manor_pk_enroll_req",
      res = "manor_pk_enroll_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "PopularityHomePKHandler"
    },
    [40668531] = {
      req = "get_psmatch_reward_status_req",
      res = "get_psmatch_reward_status_rsp",
      queueType = 1,
      handler = "PopularityPKHandler"
    },
    [206053003] = {
      req = "get_psmatch_recent_battle_segment_req",
      res = "get_psmatch_recent_battle_segment_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "PopularityPKHandler"
    },
    [252187815] = {
      req = "get_one_user_annual_rank_req",
      res = "get_one_user_annual_rank_rsp",
      timeInterval = 0.5,
      handler = "PopularityPKHandler"
    },
    [260677159] = {
      req = "get_annual_assist_award_list_req",
      res = "get_annual_assist_award_list_rsp",
      handler = "PopularityPKHandler"
    },
    [271108542] = {
      res = "psmatch_send_gift_notify",
      inGameOper = 0,
      handler = "PopularityPKHandler"
    },
    [407201639] = {
      req = "psmatch_enroll_req",
      res = "psmatch_enroll_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "PopularityPKHandler"
    },
    [479202535] = {
      req = "get_annual_target_round_rank_req",
      res = "get_annual_target_round_rank_rsp",
      timeInterval = 1,
      handler = "PopularityPKHandler"
    },
    [620324583] = {
      req = "psmatch_reward_upgrade_req",
      res = "psmatch_reward_upgrade_rsp",
      handler = "PopularityPKHandler"
    },
    [660959543] = {
      req = "get_annual_assist_records_req",
      res = "get_annual_assist_records_rsp",
      handler = "PopularityPKHandler"
    },
    [717895027] = {
      req = "get_psmatch_annual_rank_req",
      res = "get_psmatch_annual_rank_rsp",
      handler = "PopularityPKHandler"
    },
    [735353247] = {
      req = "get_psmatch_pk_record_req",
      res = "get_psmatch_pk_record_rsp",
      queueType = 1,
      handler = "PopularityPKHandler"
    },
    [1134059261] = {
      req = "psmatch_report",
      timeInterval = 5,
      handler = "PopularityPKHandler"
    },
    [1203083719] = {
      req = "get_psmatch_status_req",
      res = "get_psmatch_status_rsp",
      queueType = 1,
      timeout = 5,
      handler = "PopularityPKHandler"
    },
    [1456758055] = {
      req = "take_annual_assist_award_req",
      res = "take_annual_assist_award_rsp",
      handler = "PopularityPKHandler"
    },
    [1503196455] = {
      req = "batch_get_annual_assist_rank_req",
      res = "batch_get_annual_assist_rank_rsp",
      handler = "PopularityPKHandler"
    },
    [1752450355] = {
      req = "get_psmatch_current_pk_info_req",
      res = "get_psmatch_current_pk_info_rsp",
      queueType = 1,
      handler = "PopularityPKHandler"
    },
    [1941190311] = {
      req = "get_psmatch_reward_req",
      res = "get_psmatch_reward_rsp",
      handler = "PopularityPKHandler"
    },
    [2083439271] = {
      req = "get_psmatch_system_push_info_req",
      res = "get_psmatch_system_push_info_rsp",
      handler = "PopularityPKHandler"
    },
    [556748559] = {
      req = "get_psmatch_shop_config_req",
      res = "get_psmatch_shop_config_rsp",
      handler = "PopularityStoreHandler"
    },
    [627480173] = {
      res = "psmatch_coin_exchange_info_notify",
      handler = "PopularityStoreHandler"
    },
    [847898395] = {
      req = "psmatch_coin_exchange_req",
      res = "psmatch_coin_exchange_rsp",
      handler = "PopularityStoreHandler"
    },
    [1241214567] = {
      req = "get_psmatch_pk_level_req",
      res = "get_psmatch_pk_level_rsp",
      handler = "PopularityStoreHandler"
    },
    [1370628579] = {
      req = "psmatch_win_streak_reward_req",
      res = "psmatch_win_streak_reward_rsp",
      timeInterval = 1,
      handler = "PopularityStreakHandler"
    },
    [1642213775] = {
      req = "psmatch_win_streak_info_req",
      res = "psmatch_win_streak_info_rsp",
      handler = "PopularityStreakHandler"
    },
    [248156600] = {
      res = "psmatch_team_member_ready_ntf",
      handler = "PopularityTeamPKHandler"
    },
    [291066979] = {
      res = "psmatch_team_member_join_ntf",
      handler = "PopularityTeamPKHandler"
    },
    [407420877] = {
      res = "psmatch_team_member_exit_ntf",
      handler = "PopularityTeamPKHandler"
    },
    [452416622] = {
      res = "psmatch_team_send_gift_notify",
      handler = "PopularityTeamPKHandler"
    },
    [461629527] = {
      req = "get_other_psmatch_team_simple_req",
      res = "get_other_psmatch_team_simple_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [516413011] = {
      req = "psmatch_team_kickout_member_req",
      res = "psmatch_team_kickout_member_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [654129337] = {
      res = "psmatch_team_invite_new_msg_notify",
      handler = "PopularityTeamPKHandler"
    },
    [740576730] = {
      res = "psmatch_team_enroll_success_ntf",
      handler = "PopularityTeamPKHandler"
    },
    [845116775] = {
      req = "get_psmatch_team_member_list_req",
      res = "get_psmatch_team_member_list_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1128061451] = {
      req = "psmatch_team_report_read_invite_req",
      res = "psmatch_team_report_read_invite_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1140568011] = {
      req = "psmatch_team_recommend_list_req",
      res = "psmatch_team_recommend_list_rsp",
      queueType = 1,
      timeInterval = 1,
      handler = "PopularityTeamPKHandler"
    },
    [1196312563] = {
      req = "get_psmatch_team_cur_pkinfo_req",
      res = "get_psmatch_team_cur_pkinfo_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1224582615] = {
      req = "psmatch_team_exit_req",
      res = "psmatch_team_exit_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1345731975] = {
      req = "psmatch_team_join_together_req",
      res = "psmatch_team_join_together_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1474336363] = {
      req = "psmatch_team_msg_op_req",
      res = "psmatch_team_msg_op_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1523823495] = {
      req = "psmatch_team_msg_list_req",
      res = "psmatch_team_msg_list_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1636019971] = {
      req = "get_psmatch_team_pk_records_req",
      res = "get_psmatch_team_pk_records_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1916691051] = {
      req = "get_psmatch_team_data_req",
      res = "get_psmatch_team_data_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [1982538319] = {
      req = "psmatch_team_enroll_req",
      res = "psmatch_team_enroll_rsp",
      timeInterval = 1,
      handler = "PopularityTeamPKHandler"
    },
    [2055331663] = {
      req = "psmatch_team_receive_awards_req",
      res = "psmatch_team_receive_awards_rsp",
      handler = "PopularityTeamPKHandler"
    },
    [2125612327] = {
      req = "psmatch_team_set_ready_req",
      res = "psmatch_team_set_ready_rsp",
      timeInterval = 1,
      handler = "PopularityTeamPKHandler"
    },
    [2131369383] = {
      req = "psmatch_team_enter_recommend_req",
      res = "psmatch_team_enter_recommend_rsp",
      queueType = 1,
      timeInterval = 2,
      handler = "PopularityTeamPKHandler"
    },
    [1214395674] = {
      res = "notify_pre_loss_trigger",
      handler = "PreLossHandler"
    },
    [682259391] = {
      req = "get_part_unlock_weapons_req",
      res = "get_part_unlock_weapons_rsp",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [689512415] = {
      req = "weapon_info_req",
      res = "weapon_info_rsp",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [1163447063] = {
      req = "vs_prepare_scheme_req",
      res = "vs_prepare_scheme_rsp",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [1640483127] = {
      req = "vs_prepare_set_slot_req",
      res = "vs_prepare_set_slot_rsp",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [1661879991] = {
      req = "unlock_weapon_req",
      res = "unlock_weapon_rsp",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [1679085543] = {
      req = "vs_feature_set_slots_req",
      res = "vs_feature_set_slots_rsp",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [2046604839] = {
      req = "get_casual_shop_virtual_item_req",
      res = "get_casual_shop_virtual_item_rsp",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [2112213198] = {
      res = "weapon_exp_notify",
      inGameOper = 0,
      handler = "PrepareSchemeHandler"
    },
    [387112940] = {
      req = "buy_esports_reward",
      res = "buy_esports_reward_rsp",
      handler = "PrivilegeHandler"
    },
    [516831948] = {
      req = "buy_esports_ticket",
      res = "buy_esports_ticket_rsp",
      handler = "PrivilegeHandler"
    },
    [763799572] = {
      req = "uc_exchange_esports_money",
      res = "uc_exchange_esports_money_rsp",
      handler = "PrivilegeHandler"
    },
    [934006988] = {
      req = "bet_esports_champion",
      res = "bet_esports_champion_rsp",
      handler = "PrivilegeHandler"
    },
    [1637246284] = {
      req = "unlock_esports_privilege",
      res = "unlock_esports_privilege_rsp",
      handler = "PrivilegeHandler"
    },
    [1923390860] = {
      req = "signup_esports_privilege",
      res = "signup_esports_privilege_rsp",
      handler = "PrivilegeHandler"
    },
    [1982274468] = {
      req = "give_esports_bet_reward",
      res = "give_esports_bet_reward_rsp",
      handler = "PrivilegeHandler"
    },
    [2135980116] = {
      req = "get_esports_activity_info",
      res = "get_esports_activity_info_rsp",
      isLock = 1,
      handler = "PrivilegeHandler"
    },
    [498733479] = {
      req = "get_evaluation_req",
      res = "get_evaluation_rsp",
      handler = "ProfileHander"
    },
    [619845007] = {
      req = "batch_get_bin_profile_req",
      res = "batch_get_bin_profile_rsp",
      queueType = 1,
      timeout = 30,
      inGameOper = 0,
      handler = "ProfileHander"
    },
    [638055551] = {
      req = "set_evaluation_privacy",
      res = "evaluation_privacy_rsp",
      inGameOper = 0,
      handler = "ProfileHander"
    },
    [1481802315] = {
      req = "get_avatar_show_req",
      res = "get_avatar_show_rsp",
      inGameOper = 0,
      handler = "ProfileHander"
    },
    [2005102823] = {
      req = "chg_avatar_show_switch_req",
      res = "chg_avatar_show_switch_rsp",
      inGameOper = 0,
      handler = "ProfileHander"
    },
    [2022436831] = {
      req = "finish_evaluation_guide_req",
      res = "finish_evaluation_guide_rsp",
      handler = "ProfileHander"
    },
    [2010177935] = {
      req = "set_promotion_privacy_req",
      res = "set_promotion_privacy_rsp",
      handler = "PromotionHandler"
    },
    [238603399] = {
      req = "music_box_data_req",
      res = "music_box_data_rsp",
      handler = "PubgmMusicHandler"
    },
    [354479751] = {
      req = "music_box_get_friend_bgm_music_req",
      res = "music_box_get_friend_bgm_music_rsp",
      handler = "PubgmMusicHandler"
    },
    [836965079] = {
      req = "set_scene_music_req",
      res = "set_scene_music_rsp",
      inGameOper = 0,
      handler = "PubgmMusicHandler"
    },
    [1353998007] = {
      req = "music_box_receive_newbie_gift_req",
      res = "music_box_receive_newbie_gift_rsp",
      isLock = 1,
      handler = "PubgmMusicHandler"
    },
    [1372929127] = {
      req = "music_box_check_gift_req",
      res = "music_box_check_gift_rsp",
      handler = "PubgmMusicHandler"
    },
    [1712509119] = {
      req = "music_box_set_bgm_music_req",
      res = "music_box_set_bgm_music_rsp",
      handler = "PubgmMusicHandler"
    },
    [1810927471] = {
      req = "music_box_set_car_music_req",
      res = "music_box_set_car_music_rsp",
      handler = "PubgmMusicHandler"
    },
    [1845205519] = {
      req = "music_box_send_gift_req",
      res = "music_box_send_gift_rsp",
      isLock = 1,
      handler = "PubgmMusicHandler"
    },
    [2034104295] = {
      req = "music_box_clear_expire_req",
      res = "music_box_clear_expire_rsp",
      handler = "PubgmMusicHandler"
    },
    [2035169831] = {
      req = "music_box_check_open_req",
      res = "music_box_check_open_rsp",
      handler = "PubgmMusicHandler"
    },
    [465058184] = {
      req = "mini_client_reward_cfg_get_req",
      res = "mini_client_reward_cfg_get_res",
      inGameOper = 0,
      handler = "PufferDownloadHandler"
    },
    [713385013] = {
      req = "report_res_download_log",
      handler = "PufferDownloadHandler"
    },
    [772226931] = {
      req = "reserve_download",
      res = "reserve_download_res",
      inGameOper = 0,
      handler = "PufferDownloadHandler"
    },
    [843715389] = {
      req = "client_pak_report",
      handler = "PufferDownloadHandler"
    },
    [1047370536] = {
      req = "mini_client_reward_get_req",
      res = "mini_client_reward_get_res",
      inGameOper = 0,
      handler = "PufferDownloadHandler"
    },
    [1212171871] = {
      req = "save_download_setting_req",
      res = "save_download_setting_rsp",
      handler = "PufferDownloadHandler"
    },
    [1689090855] = {
      req = "get_download_setting_req",
      res = "get_download_setting_rsp",
      handler = "PufferDownloadHandler"
    },
    [1807671272] = {
      req = "mini_client_reward_cfg_req",
      res = "mini_client_reward_cfg_res",
      inGameOper = 0,
      handler = "PufferDownloadHandler"
    },
    [1953522048] = {
      req = "paks_batch_download_log",
      handler = "PufferDownloadHandler"
    },
    [297264383] = {
      req = "questionnaire_finished_report_req",
      res = "questionnaire_finished_report_rsp",
      isUnique = 1,
      queueType = 1,
      timeout = 30,
      needRsp = 9999,
      inGameOper = 0,
      handler = "QuestionnaireHander"
    },
    [1101989955] = {
      req = "get_team_recommend_friend_req",
      res = "get_team_recommend_friend_rsp",
      handler = "QuickTeamUpHandler"
    },
    [684740812] = {
      req = "submit_tournament_unions_winner_info",
      res = "submit_tournament_unions_winner_info_rsp",
      handler = "QuilifyHandler"
    },
    [1018970944] = {
      res = "tournament_return_notify",
      handler = "QuilifyHandler"
    },
    [1401033071] = {
      req = "get_tournament_unions_req",
      res = "get_tournament_unions_rsp",
      handler = "QuilifyHandler"
    },
    [1568244647] = {
      req = "get_tournament_unions_winner_req",
      res = "get_tournament_unions_winner_rsp",
      handler = "QuilifyHandler"
    },
    [1858267190] = {
      res = "tournament_scrollview",
      handler = "QuilifyHandler"
    },
    [1997759351] = {
      req = "get_tournament_rank_req",
      res = "get_tournament_rank_rsp",
      handler = "QuilifyHandler"
    },
    [183471079] = {
      req = "get_rp_crt_score_data_req",
      res = "get_rp_crt_score_data_rsp",
      handler = "RPCrtScoreHandler"
    },
    [401944767] = {
      req = "rp_crt_score_task_award_req",
      res = "rp_crt_score_task_award_rsp",
      handler = "RPCrtScoreHandler"
    },
    [1304857191] = {
      req = "rp_crt_score_req",
      res = "rp_crt_score_rsp",
      handler = "RPCrtScoreHandler"
    },
    [1429447533] = {
      res = "crt_score_task_sync_change",
      handler = "RPCrtScoreHandler"
    },
    [1470638375] = {
      req = "rp_crt_score_total_award_req",
      res = "rp_crt_score_total_award_rsp",
      handler = "RPCrtScoreHandler"
    },
    [2086993011] = {
      req = "rp_crt_init_score_req",
      res = "rp_crt_init_score_rsp",
      handler = "RPCrtScoreHandler"
    },
    [42195118] = {
      req = "get_special_user_rank",
      res = "get_special_user_rank_rsp",
      inGameOper = 0,
      handler = "RankHandler"
    },
    [286918582] = {
      req = "get_topn_rank",
      res = "get_topn_rank_rsp",
      handler = "RankHandler"
    },
    [324360450] = {
      res = "get_topn_1w_score_rsp",
      handler = "RankHandler"
    },
    [445841892] = {
      req = "get_one_user_rank",
      res = "get_one_user_rank_rsp",
      isLock = 1,
      handler = "RankHandler"
    },
    [753941712] = {
      res = "rank_replay_choice_notify",
      handler = "RankHandler"
    },
    [1037082820] = {
      req = "get_friend_rank",
      res = "get_friend_rank_rsp",
      handler = "RankHandler"
    },
    [1963995031] = {
      req = "batch_get_popularit_summary_req",
      res = "batch_get_popularit_summary_rsp",
      handler = "RankHandler"
    },
    [2007034056] = {
      req = "rank_replay_switch_req",
      res = "rank_replay_switch_res",
      handler = "RankHandler"
    },
    [179199783] = {
      req = "draw_gas_station_req",
      res = "draw_gas_station_rsp",
      isLock = 1,
      handler = "RechargeGasStationHandler"
    },
    [261638759] = {
      res = "notify_gas_station_add_uc",
      handler = "RechargeGasStationHandler"
    },
    [358092963] = {
      req = "refresh_gas_station_req",
      res = "refresh_gas_station_rsp",
      isLock = 1,
      handler = "RechargeGasStationHandler"
    },
    [1300102759] = {
      req = "drop_gas_station_req",
      res = "drop_gas_station_rsp",
      isLock = 1,
      handler = "RechargeGasStationHandler"
    },
    [1656501095] = {
      req = "get_gas_station_info_req",
      res = "get_gas_station_info_rsp",
      handler = "RechargeGasStationHandler"
    },
    [998072919] = {
      req = "buy_limited_special_chest_req",
      res = "buy_limited_special_chest_rsp",
      timeInterval = 1,
      handler = "RechargePurchaseHandler"
    },
    [1239325150] = {
      req = "batch_query_direct_buy_info",
      res = "batch_query_direct_buy_info_rsp",
      inGameOper = 0,
      handler = "RechargePurchaseHandler"
    },
    [1243901004] = {
      req = "unified_purchase",
      res = "unified_purchase_rsp",
      inGameOper = 0,
      handler = "RechargePurchaseHandler"
    },
    [1277969927] = {
      req = "get_limited_special_chest_req",
      res = "get_limited_special_chest_rsp",
      handler = "RechargePurchaseHandler"
    },
    [1809102668] = {
      req = "direct_buy_pre_check",
      res = "direct_buy_pre_check_rsp",
      inGameOper = 0,
      handler = "RechargePurchaseHandler"
    },
    [465646251] = {
      req = "get_invite_reward_req",
      res = "get_invite_reward_rsp",
      handler = "RecruitHandler"
    },
    [2016437543] = {
      req = "fill_invite_code_req",
      res = "fill_invite_code_rsp",
      handler = "RecruitHandler"
    },
    [2026400887] = {
      req = "get_invite_info_req",
      res = "get_invite_info_rsp",
      handler = "RecruitHandler"
    },
    [75827194] = {
      req = "log_dismiss_gs_reddot_list",
      handler = "RedDotHandler"
    },
    [82929915] = {
      req = "log_week_online_gs_reddot",
      handler = "RedDotHandler"
    },
    [649181582] = {
      res = "sync_reddots_label_rsp",
      handler = "RedDotHandler"
    },
    [718891448] = {
      req = "log_week_online_gs_reddot_list",
      handler = "RedDotHandler"
    },
    [876650190] = {
      res = "sync_reddots_info",
      handler = "RedDotHandler"
    },
    [899232804] = {
      req = "log_expired_gs_reddot",
      handler = "RedDotHandler"
    },
    [946768187] = {
      req = "log_reddot_dynamic_wgt_list",
      handler = "RedDotHandler"
    },
    [949081610] = {
      req = "dismiss_reddot_ntf",
      handler = "RedDotHandler"
    },
    [1076219472] = {
      res = "display_reddot_ntf",
      handler = "RedDotHandler"
    },
    [1617626816] = {
      req = "log_create_gs_reddot_list",
      handler = "RedDotHandler"
    },
    [1697297047] = {
      req = "reddot_list_req",
      res = "reddot_list_rsp",
      handler = "RedDotHandler"
    },
    [1794124751] = {
      req = "log_create_gs_reddot",
      handler = "RedDotHandler"
    },
    [1850561517] = {
      req = "log_expired_gs_reddot_list",
      handler = "RedDotHandler"
    },
    [1905360961] = {
      req = "log_dismiss_gs_reddot",
      handler = "RedDotHandler"
    },
    [939014055] = {
      req = "soulmate_redpacket_rain_take_req",
      res = "soulmate_redpacket_rain_take_rsp",
      handler = "RedEnVelopeHandler"
    },
    [964335527] = {
      req = "soulmate_redpacket_rain_play_req",
      res = "soulmate_redpacket_rain_play_rsp",
      handler = "RedEnVelopeHandler"
    },
    [1634254275] = {
      req = "get_lucky_money_req",
      res = "get_lucky_money_rsp",
      timeInterval = 2,
      handler = "RedEnVelopeHandler"
    },
    [2049410572] = {
      req = "get_lucky_money_notify",
      res = "notify_lucky_money_act",
      handler = "RedEnVelopeHandler"
    },
    [1707998310] = {
      req = "select_avatar",
      handler = "RedpointHandler"
    },
    [2140608219] = {
      req = "select_item_list",
      handler = "RedpointHandler"
    },
    [623605923] = {
      req = "set_shop_region_req",
      res = "set_shop_region_rsp",
      inGameOper = 0,
      handler = "RegionHandler"
    },
    [1157820513] = {
      res = "sync_player_region_info",
      inGameOper = 0,
      handler = "RegionHandler"
    },
    [1227306343] = {
      req = "set_account_region_req",
      res = "set_account_region_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      inGameOper = 0,
      handler = "RegionHandler"
    },
    [137611527] = {
      req = "get_credit_conf_v2_req",
      res = "get_credit_conf_v2_rsp",
      inGameOper = 0,
      handler = "ReputationHandler"
    },
    [339520983] = {
      res = "notify_credit_info_v2",
      inGameOper = 0,
      handler = "ReputationHandler"
    },
    [542226375] = {
      req = "get_credit_info_v2_req",
      res = "get_credit_info_v2_rsp",
      inGameOper = 0,
      handler = "ReputationHandler"
    },
    [1073118914] = {
      res = "notify_show_notice",
      inGameOper = 0,
      handler = "ReputationHandler"
    },
    [1301638670] = {
      res = "notify_credit_punish_type_is_open",
      inGameOper = 0,
      handler = "ReputationHandler"
    },
    [1304599091] = {
      req = "accept_credit_pact",
      handler = "ReputationHandler"
    },
    [2065322091] = {
      req = "credit_punish_return_lobby_user_reaction",
      handler = "ReputationHandler"
    },
    [1995328890] = {
      res = "task_status_notify",
      inGameOper = 0,
      handler = "ResultTaskHandler"
    },
    [605003559] = {
      req = "set_social_info_bg_req",
      res = "set_social_info_bg_rsp",
      handler = "RoleInfoBGHandler"
    },
    [1812988526] = {
      res = "notify_social_info_bg",
      handler = "RoleInfoBGHandler"
    },
    [135275115] = {
      req = "set_profile_frame_req",
      res = "set_profile_frame_rsp",
      handler = "RoleInfoHandler"
    },
    [143015436] = {
      req = "get_user_avatar_list",
      res = "get_user_avatar_list_rsp",
      inGameOper = 0,
      handler = "RoleInfoHandler"
    },
    [157294139] = {
      req = "get_profile_frame_req",
      res = "get_profile_frame_rsp",
      handler = "RoleInfoHandler"
    },
    [214745093] = {
      res = "notify_carte_frame_update",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "RoleInfoHandler"
    },
    [248116844] = {
      req = "select_use_pspace_rolewear",
      res = "select_use_pspace_rolewear_rsp",
      inGameOper = 0,
      handler = "RoleInfoHandler"
    },
    [484035478] = {
      req = "get_team_notify_skin_list",
      res = "get_team_notify_skin_list_rsp",
      inGameOper = 0,
      handler = "RoleInfoHandler"
    },
    [528789675] = {
      req = "equip_carte_frame_req",
      res = "equip_carte_frame_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "RoleInfoHandler"
    },
    [534541852] = {
      res = "unlock_friend_nickname_skin_notify",
      handler = "RoleInfoHandler"
    },
    [537298663] = {
      req = "set_friend_nickname_skin_req",
      res = "set_friend_nickname_skin_rsp",
      handler = "RoleInfoHandler"
    },
    [677059495] = {
      req = "get_carte_frame_list_req",
      res = "get_carte_frame_list_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "RoleInfoHandler"
    },
    [787356227] = {
      res = "del_profile_frame_notify",
      handler = "RoleInfoHandler"
    },
    [904570303] = {
      req = "set_social_card_frame_req",
      res = "set_social_card_frame_rsp",
      handler = "RoleInfoHandler"
    },
    [1024446223] = {
      req = "get_social_card_frame_req",
      res = "get_social_card_frame_rsp",
      handler = "RoleInfoHandler"
    },
    [1026825811] = {
      req = "get_chat_bubble_req",
      res = "get_chat_bubble_rsp",
      handler = "RoleInfoHandler"
    },
    [1076067372] = {
      res = "del_social_card_frame_notify",
      handler = "RoleInfoHandler"
    },
    [1077891235] = {
      req = "set_chat_bubble_req",
      res = "set_chat_bubble_rsp",
      handler = "RoleInfoHandler"
    },
    [1372593228] = {
      req = "change_team_notify_skin",
      res = "change_team_notify_skin_rsp",
      inGameOper = 0,
      handler = "RoleInfoHandler"
    },
    [1615193820] = {
      res = "unlock_chat_bubble_notify",
      handler = "RoleInfoHandler"
    },
    [1675969614] = {
      req = "use_brand",
      res = "use_brand_rsp",
      inGameOper = 0,
      handler = "RoleInfoHandler"
    },
    [1677356633] = {
      res = "notify_add_brand",
      inGameOper = 0,
      handler = "RoleInfoHandler"
    },
    [1798821556] = {
      res = "new_team_notify_skin_notify",
      inGameOper = 0,
      handler = "RoleInfoHandler"
    },
    [1864315367] = {
      req = "get_friend_nickname_skin_req",
      res = "get_friend_nickname_skin_rsp",
      handler = "RoleInfoHandler"
    },
    [1906163869] = {
      res = "unlock_social_card_frame_notify",
      handler = "RoleInfoHandler"
    },
    [2011697442] = {
      res = "unlock_profile_frame_notify",
      handler = "RoleInfoHandler"
    },
    [503262631] = {
      req = "role_select_hero_req",
      res = "role_select_hero_rsp",
      inGameOper = 0,
      handler = "RoleSkillSystemHandler"
    },
    [1989100067] = {
      req = "role_get_hero_req",
      res = "role_get_hero_rsp",
      inGameOper = 0,
      handler = "RoleSkillSystemHandler"
    },
    [72854980] = {
      req = "change_room_map_request",
      res = "change_room_map_respond",
      handler = "RoomHandler"
    },
    [218606950] = {
      req = "unlock_team_request",
      res = "unlock_team_respond",
      handler = "RoomHandler"
    },
    [269955459] = {
      res = "sync_room_state",
      handler = "RoomHandler"
    },
    [318890035] = {
      req = "match_room_kick_req",
      res = "match_room_kick_rsp",
      handler = "RoomHandler"
    },
    [334226582] = {
      res = "sync_room_change",
      handler = "RoomHandler"
    },
    [368230222] = {
      req = "change_room_group_type_request",
      res = "change_room_group_type_respond",
      handler = "RoomHandler"
    },
    [383694500] = {
      res = "room_invite_reply_notify",
      timeInterval = 3,
      handler = "RoomHandler"
    },
    [415675542] = {
      req = "room_kick_request",
      res = "room_kick_respond",
      handler = "RoomHandler"
    },
    [437761628] = {
      req = "lock_team_request",
      res = "lock_team_respond",
      handler = "RoomHandler"
    },
    [446225790] = {
      req = "change_room_request",
      res = "change_room_respond",
      handler = "RoomHandler"
    },
    [455191030] = {
      req = "ugc_room_member_reject_download",
      res = "ugc_room_member_reject_download_rsp",
      handler = "RoomHandler"
    },
    [481125475] = {
      req = "query_room_password_state_req",
      res = "query_room_password_state_rsp",
      handler = "RoomHandler"
    },
    [554906831] = {
      req = "set_member_prepared_req",
      res = "set_member_prepared_rsp",
      handler = "RoomHandler"
    },
    [575825941] = {
      res = "enter_game",
      inGameOper = 0,
      handler = "RoomHandler"
    },
    [583810535] = {
      req = "kickout_simulator_user_req",
      res = "kickout_simulator_user_rsp",
      handler = "RoomHandler"
    },
    [589459310] = {
      req = "query_room_request",
      res = "query_room_respond",
      handler = "RoomHandler"
    },
    [652119782] = {
      req = "join_room_request",
      res = "join_room_respond",
      needRsp = 999,
      timeInterval = 3,
      handler = "RoomHandler"
    },
    [716848715] = {
      res = "room_disband",
      handler = "RoomHandler"
    },
    [772152587] = {
      req = "enter_league_room_req",
      res = "enter_league_room_rsp",
      handler = "RoomHandler"
    },
    [789852135] = {
      req = "set_room_prepared_second_confirm_req",
      res = "set_room_prepared_second_confirm_rsp",
      queueType = 1,
      handler = "RoomHandler"
    },
    [816763214] = {
      req = "start_game_request",
      res = "start_game_respond",
      handler = "RoomHandler"
    },
    [882583534] = {
      req = "cancel_pos_arranging_request",
      res = "cancel_pos_arranging_respond",
      handler = "RoomHandler"
    },
    [949201725] = {
      res = "room_start_game_notify",
      handler = "RoomHandler"
    },
    [962424597] = {
      res = "notify_enter_game",
      handler = "RoomHandler"
    },
    [998339304] = {
      res = "sync_room_member",
      handler = "RoomHandler"
    },
    [1034902063] = {
      req = "enter_league_ob_req",
      handler = "RoomHandler"
    },
    [1057587295] = {
      req = "set_room_passwd_req",
      res = "set_room_passwd_rsp",
      handler = "RoomHandler"
    },
    [1092946030] = {
      req = "change_other_pos_request",
      res = "change_other_pos_respond",
      handler = "RoomHandler"
    },
    [1148930855] = {
      res = "sync_room_lock",
      handler = "RoomHandler"
    },
    [1160666701] = {
      req = "query_room_list",
      res = "sync_room_list",
      handler = "RoomHandler"
    },
    [1180663463] = {
      req = "query_rooms_req",
      res = "query_rooms_rsp",
      handler = "RoomHandler"
    },
    [1216104536] = {
      req = "set_pos_arranging_request",
      res = "set_pos_arranging_respond",
      handler = "RoomHandler"
    },
    [1252352850] = {
      res = "notify_team_member_enter_hvh_room",
      handler = "RoomHandler"
    },
    [1269746343] = {
      req = "room_recruit_req",
      handler = "RoomHandler"
    },
    [1316815416] = {
      res = "get_game_info_rsp",
      handler = "RoomHandler"
    },
    [1394003236] = {
      req = "change_room_pos_request",
      res = "change_room_pos_respond",
      timeInterval = 3,
      handler = "RoomHandler"
    },
    [1414309922] = {
      req = "enter_next_match",
      handler = "RoomHandler"
    },
    [1461389313] = {
      res = "ugc_room_member_reject_download_notify",
      handler = "RoomHandler"
    },
    [1488575984] = {
      req = "leave_room_battle_watch",
      handler = "RoomHandler"
    },
    [1489767980] = {
      res = "change_room_name_respond",
      handler = "RoomHandler"
    },
    [1501251394] = {
      res = "room_info_notify",
      handler = "RoomHandler"
    },
    [1601425410] = {
      res = "notify_room_member",
      handler = "RoomHandler"
    },
    [1642609127] = {
      req = "cancel_room_prepared_req",
      res = "cancel_room_prepared_rsp",
      handler = "RoomHandler"
    },
    [1648719194] = {
      res = "team_match_shadow_notify",
      inGameOper = 0,
      handler = "RoomHandler"
    },
    [1659625980] = {
      req = "room_invite_request",
      res = "room_invite_respond",
      handler = "RoomHandler"
    },
    [1765320619] = {
      res = "room_next_match_ready_notify",
      handler = "RoomHandler"
    },
    [1780292359] = {
      req = "get_room_battle_watch_info_req",
      res = "get_room_battle_watch_info_rsp",
      handler = "RoomHandler"
    },
    [1856290595] = {
      res = "kickout_simulator_user_notify",
      handler = "RoomHandler"
    },
    [1868323700] = {
      req = "room_info_request",
      res = "sync_room_info",
      handler = "RoomHandler"
    },
    [1891397099] = {
      req = "set_room_prepared_req",
      res = "set_room_prepared_rsp",
      handler = "RoomHandler"
    },
    [1916922963] = {
      req = "change_room_adv_param_req",
      res = "change_room_adv_param_rsp",
      handler = "RoomHandler"
    },
    [2012026112] = {
      req = "unlock_room_pos_request",
      res = "unlock_room_pos_respond",
      handler = "RoomHandler"
    },
    [2037010220] = {
      req = "exit_room",
      res = "exit_room_rsp",
      timeout = 5,
      needRsp = 5,
      handler = "RoomHandler"
    },
    [2088098978] = {
      req = "lock_room_pos_request",
      res = "lock_room_pos_respond",
      handler = "RoomHandler"
    },
    [66080968] = {
      req = "get_single_icon_reward_req",
      res = "get_single_icon_reward_res",
      timeInterval = 1,
      handler = "SeasonCycleAwardHandler"
    },
    [205229308] = {
      res = "ace_imprint_icon_got_notify",
      handler = "SeasonCycleAwardHandler"
    },
    [340018433] = {
      res = "ace_imprint_status_chg_notify",
      handler = "SeasonCycleAwardHandler"
    },
    [696037015] = {
      req = "get_all_season_prize_reward_req",
      res = "get_all_season_prize_reward_rsp",
      handler = "SeasonCycleAwardHandler"
    },
    [890365279] = {
      req = "get_season_year_reward_redpot_req",
      res = "get_season_year_reward_redpot_rsp",
      handler = "SeasonCycleAwardHandler"
    },
    [1016661319] = {
      req = "get_season_year_reward_req",
      res = "get_season_year_reward_rsp",
      handler = "SeasonCycleAwardHandler"
    },
    [1731057543] = {
      req = "get_season_year_reward_info_req",
      res = "get_season_year_reward_info_rsp",
      handler = "SeasonCycleAwardHandler"
    },
    [1918348279] = {
      res = "season_year_makeup_task_notify",
      handler = "SeasonCycleAwardHandler"
    },
    [132376423] = {
      req = "confirm_show_conqueror_req",
      res = "confirm_show_conqueror_rsp",
      handler = "SeasonHandler"
    },
    [136003290] = {
      res = "past_season_rating",
      handler = "SeasonHandler"
    },
    [155665366] = {
      req = "get_season_file",
      res = "get_season_file_rsp",
      handler = "SeasonHandler"
    },
    [203226965] = {
      res = "conqueror_popup_notify",
      handler = "SeasonHandler"
    },
    [245896936] = {
      req = "get_season_year_memory_item_reward_req",
      res = "get_season_year_memory_item_reward_res",
      handler = "SeasonHandler"
    },
    [414401191] = {
      req = "get_peakgame_season_file_req",
      res = "get_peakgame_season_file_rsp",
      handler = "SeasonHandler"
    },
    [416683460] = {
      res = "notify_challenge_compensate_score",
      handler = "SeasonHandler"
    },
    [504414182] = {
      req = "get_task_state_list",
      res = "get_task_state_list_rsp",
      isLock = 1,
      handler = "SeasonHandler"
    },
    [507109991] = {
      req = "promotion_return_segment_req",
      res = "promotion_return_segment_rsp",
      inGameOper = 0,
      handler = "SeasonHandler"
    },
    [560556391] = {
      req = "query_challenge_info_req",
      res = "query_challenge_info_rsp",
      handler = "SeasonHandler"
    },
    [566788931] = {
      req = "task_season_segment_prize_all_req",
      res = "task_season_segment_prize_all_rsp",
      timeInterval = 1,
      handler = "SeasonHandler"
    },
    [732709383] = {
      req = "get_season_year_memory_progress_reward_req",
      res = "get_season_year_memory_progress_reward_rsp",
      handler = "SeasonHandler"
    },
    [823130568] = {
      req = "get_season_config_req",
      res = "get_season_config_res",
      handler = "SeasonHandler"
    },
    [832437287] = {
      req = "get_prev_season_year_memory_data_req",
      res = "get_prev_season_year_memory_data_rsp",
      inGameOper = 0,
      handler = "SeasonHandler"
    },
    [865256268] = {
      req = "get_other_high_segment_title",
      res = "get_other_high_segment_title_rsp",
      inGameOper = 0,
      handler = "SeasonHandler"
    },
    [999755271] = {
      req = "season_task_dropid_content_req",
      res = "season_task_dropid_content_rsp",
      handler = "SeasonHandler"
    },
    [1057489961] = {
      res = "season_end_notify",
      handler = "SeasonHandler"
    },
    [1167119020] = {
      req = "get_high_segment_title_pursuit",
      res = "get_high_segment_title_pursuit_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "SeasonHandler"
    },
    [1182366102] = {
      req = "get_season_file_summy",
      res = "get_season_file_summy_rsp",
      handler = "SeasonHandler"
    },
    [1189713104] = {
      req = "get_season_year_memory_data_req",
      res = "get_season_year_memory_data_res",
      handler = "SeasonHandler"
    },
    [1299672775] = {
      req = "take_season_transition_reward_req",
      res = "take_season_transition_reward_rsp",
      handler = "SeasonHandler"
    },
    [1308097415] = {
      req = "select_promotion_layer_req",
      res = "select_promotion_layer_rsp",
      timeInterval = 2,
      handler = "SeasonHandler"
    },
    [1316843015] = {
      req = "get_conqueror_info_req",
      res = "get_conqueror_info_rsp",
      handler = "SeasonHandler"
    },
    [1330538444] = {
      req = "take_season_task_prize",
      res = "take_season_task_prize_rsp",
      isLock = 1,
      handler = "SeasonHandler"
    },
    [1499699847] = {
      res = "notify_challenge_info_cfg",
      inGameOper = 0,
      handler = "SeasonHandler"
    },
    [1661726028] = {
      req = "set_season_reward_head_frame_privacy",
      res = "set_season_reward_head_frame_privacy_rsp",
      handler = "SeasonHandler"
    },
    [1746056386] = {
      res = "season_switch_info_summary",
      handler = "SeasonHandler"
    },
    [1782485575] = {
      req = "get_season_file_reddot_req",
      res = "get_season_file_reddot_rsp",
      handler = "SeasonHandler"
    },
    [1800131731] = {
      req = "task_season_segment_prize",
      res = "task_season_segment_prize_res",
      isLock = 1,
      handler = "SeasonHandler"
    },
    [1885481092] = {
      req = "get_role_battle_max_rank_rating",
      res = "get_role_battle_max_rank_rating_rsp",
      handler = "SeasonHandler"
    },
    [1924240295] = {
      req = "season_year_memory_clear_season_redpoint_req",
      res = "season_year_memory_clear_season_redpoint_rsp",
      handler = "SeasonHandler"
    },
    [2058490327] = {
      res = "notify_min_rank_no_score_list",
      inGameOper = 0,
      handler = "SeasonHandler"
    },
    [2089905098] = {
      res = "season_year_memory_event_notify",
      handler = "SeasonHandler"
    },
    [2112292140] = {
      req = "set_high_segment_title_pursuit",
      res = "set_high_segment_title_pursuit_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "SeasonHandler"
    },
    [329129827] = {
      req = "set_season_lookback_privacy_req",
      res = "set_season_lookback_privacy_rsp",
      handler = "SeasonLookbackHandler"
    },
    [571083455] = {
      req = "set_season_lookback_reddot_status_req",
      res = "set_season_lookback_reddot_status_rsp",
      isUnique = 1,
      timeInterval = 1,
      handler = "SeasonLookbackHandler"
    },
    [901347367] = {
      req = "get_season_lookback_data_req",
      res = "get_season_lookback_data_rsp",
      timeInterval = 1,
      handler = "SeasonLookbackHandler"
    },
    [1019109523] = {
      req = "get_season_lookback_privacy_req",
      res = "get_season_lookback_privacy_rsp",
      timeInterval = 1,
      handler = "SeasonLookbackHandler"
    },
    [1252337015] = {
      req = "get_season_lookback_gift_info_req",
      res = "get_season_lookback_gift_info_rsp",
      timeInterval = 1,
      handler = "SeasonLookbackHandler"
    },
    [271754663] = {
      req = "report_segment_target_pop_up_req",
      res = "report_segment_target_pop_up_rsp",
      handler = "SeasonSegmentTargetHandler"
    },
    [1466830471] = {
      req = "get_segment_target_info_req",
      res = "get_segment_target_info_rsp",
      handler = "SeasonSegmentTargetHandler"
    },
    [1527680647] = {
      req = "set_segment_target_rank_req",
      res = "set_segment_target_rank_rsp",
      handler = "SeasonSegmentTargetHandler"
    },
    [1861001479] = {
      req = "get_segment_progress_award_req",
      res = "get_segment_progress_award_rsp",
      handler = "SeasonSegmentTargetHandler"
    },
    [2002389223] = {
      req = "get_segment_target_award_req",
      res = "get_segment_target_award_rsp",
      handler = "SeasonSegmentTargetHandler"
    },
    [521295784] = {
      req = "coin_exchange_req",
      res = "coin_exchange_res",
      handler = "SeasonShopHandler"
    },
    [934375945] = {
      res = "season_coin_exchange_shop_conf",
      inGameOper = 0,
      handler = "SeasonShopHandler"
    },
    [1310117824] = {
      res = "notify_coin_exchange_info",
      handler = "SeasonShopHandler"
    },
    [1521969151] = {
      req = "get_season_shop_config_req",
      inGameOper = 0,
      handler = "SeasonShopHandler"
    },
    [28810551] = {
      req = "get_season_year_cfg_req",
      res = "get_season_year_cfg_rsp",
      handler = "SeasonYearHandler"
    },
    [129127015] = {
      req = "get_season_year_streak_challenge_award_req",
      res = "get_season_year_streak_challenge_award_rsp",
      handler = "SeasonYearHandler"
    },
    [159431927] = {
      req = "season_year_remedy_streak_challenge_req",
      res = "season_year_remedy_streak_challenge_rsp",
      handler = "SeasonYearHandler"
    },
    [160785543] = {
      req = "get_season_year_badge_show_req",
      res = "get_season_year_badge_show_rsp",
      handler = "SeasonYearHandler"
    },
    [261223335] = {
      req = "claim_trial_challenge_reward_req",
      res = "claim_trial_challenge_reward_rsp",
      handler = "SeasonYearHandler"
    },
    [684221615] = {
      req = "get_cur_season_login_days_req",
      res = "get_cur_season_login_days_rsp",
      handler = "SeasonYearHandler"
    },
    [825676583] = {
      req = "remove_trial_challenge_red_point_req",
      res = "remove_trial_challenge_red_point_rsp",
      handler = "SeasonYearHandler"
    },
    [833482935] = {
      req = "get_other_season_year_badge_req",
      res = "get_other_season_year_badge_rsp",
      handler = "SeasonYearHandler"
    },
    [836280071] = {
      req = "set_season_year_badge_show_req",
      res = "set_season_year_badge_show_rsp",
      handler = "SeasonYearHandler"
    },
    [1158839783] = {
      req = "get_trial_challenge_progress_req",
      res = "get_trial_challenge_progress_rsp",
      handler = "SeasonYearHandler"
    },
    [1207000342] = {
      res = "notify_badge_part_finished_progress",
      handler = "SeasonYearHandler"
    },
    [1375113163] = {
      req = "get_season_year_streak_challenge_info_req",
      res = "get_season_year_streak_challenge_info_rsp",
      handler = "SeasonYearHandler"
    },
    [1752859403] = {
      req = "get_trial_challenge_red_point_req",
      res = "get_trial_challenge_red_point_rsp",
      handler = "SeasonYearHandler"
    },
    [1895415687] = {
      req = "get_cur_year_task_info_req",
      res = "get_cur_year_task_info_rsp",
      handler = "SeasonYearHandler"
    },
    [2035125671] = {
      req = "get_year_task_reward_req",
      res = "get_year_task_reward_rsp",
      handler = "SeasonYearHandler"
    },
    [2096256723] = {
      req = "get_season_year_badge_req",
      res = "get_season_year_badge_rsp",
      handler = "SeasonYearHandler"
    },
    [798041853] = {
      req = "set_rating_sync_info_flag_req",
      handler = "SegmentSyncHandler"
    },
    [1240204903] = {
      req = "get_rating_sync_info_req",
      res = "get_rating_sync_info_rsp",
      inGameOper = 0,
      handler = "SegmentSyncHandler"
    },
    [37174119] = {
      req = "set_birthday_privacy_req",
      res = "set_birthday_privacy_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [57864280] = {
      req = "log_status_flow",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [99414999] = {
      req = "query_weapon_settings_req",
      res = "query_weapon_settings_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [108749319] = {
      req = "set_recommend_open_req",
      res = "set_recommend_open_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [139830783] = {
      req = "get_custom_settings_new_req",
      res = "get_custom_settings_new_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [160921204] = {
      req = "save_custom_sensitive",
      res = "save_custom_sensitive_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [212481527] = {
      req = "reset_all_custom_settings_req",
      res = "reset_all_custom_settings_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [229597639] = {
      req = "confirm_csetting_share_req",
      res = "confirm_csetting_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [229685959] = {
      req = "confirm_weapon_sens_share_req",
      res = "confirm_weapon_sens_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [295732190] = {
      req = "switch_krjp_match_cross",
      res = "switch_krjp_match_cross_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [323623372] = {
      req = "set_psmatch_view_pk_switch",
      res = "set_psmatch_view_pk_switch_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [325582127] = {
      req = "gen_weapon_part_share_req",
      res = "gen_weapon_part_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [442742375] = {
      req = "query_other_csetting_req",
      res = "query_other_csetting_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [496271699] = {
      req = "gun_sensitivity_setting",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [499384367] = {
      res = "notify_ally_ai_takeover_zones",
      handler = "SettingHandler"
    },
    [527056391] = {
      req = "log_keys_setting_flow",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [552127012] = {
      req = "set_avatar_privacy_policy",
      res = "set_avatar_privacy_policy_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [567095570] = {
      req = "on_krjp_match_across_zone_req",
      res = "on_krjp_match_across_zone_res",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [597918855] = {
      req = "set_collect_hall_visit_privacy_req",
      res = "set_collect_hall_visit_privacy_rsp",
      handler = "SettingHandler"
    },
    [604717447] = {
      req = "confirm_weapon_part_share_req",
      res = "confirm_weapon_part_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [723609191] = {
      req = "get_grome_link_fec_req",
      res = "get_grome_link_fec_rsp",
      handler = "SettingHandler"
    },
    [734116072] = {
      req = "log_sensitivity_settings",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [734904350] = {
      req = "delete_custom_setting",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [734985703] = {
      req = "save_weapon_settings_req",
      res = "save_weapon_settings_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [737477748] = {
      req = "get_pspace_hidden_visitor_track",
      res = "get_pspace_hidden_visitor_track",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [746488363] = {
      req = "query_other_weapon_part_req",
      res = "query_other_weapon_part_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [782548364] = {
      req = "get_anchor_random_name",
      res = "get_anchor_random_name_rsp",
      handler = "SettingHandler"
    },
    [824944743] = {
      req = "get_all_screen_resolutions_req",
      res = "get_all_screen_resolutions_rsp",
      handler = "SettingHandler"
    },
    [899346076] = {
      req = "set_lang_req",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [955037187] = {
      req = "query_other_sensitive_req",
      res = "query_other_sensitive_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [992897153] = {
      req = "query_custom_setting",
      res = "sync_custom_setting",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [997078655] = {
      req = "set_peakgame_anchor_setting_req",
      res = "set_peakgame_anchor_setting_rsp",
      handler = "SettingHandler"
    },
    [1006464495] = {
      req = "gen_weapon_sens_share_req",
      res = "gen_weapon_sens_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1016209482] = {
      res = "sync_custom_sensitive",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1040410178] = {
      req = "gun_accessories_setting",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1043127241] = {
      req = "query_custom_sensitive",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1057492478] = {
      req = "get_guide_pic_cfg",
      res = "get_guide_pic_cfg_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1151408017] = {
      req = "set_grome_link_fec_req",
      res = "sync_grome_link_fec_stat",
      handler = "SettingHandler"
    },
    [1154350895] = {
      req = "get_peakgame_anchor_setting_req",
      res = "get_peakgame_anchor_setting_rsp",
      handler = "SettingHandler"
    },
    [1182963687] = {
      req = "set_lbs_privacy_req",
      res = "set_lbs_privacy_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1185075431] = {
      req = "save_custom_settings_new_req",
      res = "save_custom_settings_new_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1422830343] = {
      req = "gen_csetting_share_req",
      res = "gen_csetting_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1445492083] = {
      req = "get_setting_label_req",
      res = "get_setting_label_rsp",
      needRsp = 3,
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1453125911] = {
      req = "get_lbs_privacy_req",
      res = "get_lbs_privacy_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1480651175] = {
      req = "set_social_private_switch_req",
      res = "set_social_private_switch_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1505454215] = {
      req = "get_recommend_open_req",
      res = "get_recommend_open_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1555227899] = {
      req = "set_screen_resolution_req",
      res = "set_screen_resolution_rsp",
      handler = "SettingHandler"
    },
    [1558596799] = {
      req = "confirm_sensitive_share_req",
      res = "confirm_sensitive_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1621364577] = {
      req = "set_grome_link_open_req",
      res = "sync_grome_link_open_stat",
      handler = "SettingHandler"
    },
    [1647835495] = {
      req = "get_birthday_privacy_req",
      res = "get_birthday_privacy_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1712925799] = {
      req = "dirty_name_check_req",
      res = "dirty_name_check_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1745228327] = {
      req = "update_setting_label_req",
      res = "update_setting_label_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1844297994] = {
      req = "notify_click_gun_setting",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1893124447] = {
      req = "get_grome_link_open_req",
      res = "get_grome_link_open_rsp",
      handler = "SettingHandler"
    },
    [1910573356] = {
      req = "gen_new_anchor_random_name",
      res = "gen_new_anchor_random_name_rsp",
      handler = "SettingHandler"
    },
    [1939980124] = {
      req = "save_custom_setting",
      res = "save_custom_setting_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [1956204651] = {
      req = "query_other_weapon_sens_req",
      res = "query_other_weapon_sens_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [2062949111] = {
      req = "gen_sensitive_share_req",
      res = "gen_sensitive_share_rsp",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [2080782622] = {
      req = "save_player_custom_data_to_battle_req",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [2089198524] = {
      req = "set_pspace_hidden_visitor_track",
      res = "set_pspace_hidden_visitor_track",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [2143938000] = {
      req = "common_setting_status_flow",
      inGameOper = 0,
      handler = "SettingHandler"
    },
    [71920605] = {
      req = "highlight_replay_click",
      handler = "ShareHandler"
    },
    [160701223] = {
      req = "share_replay_req",
      res = "share_replay_rsp",
      inGameOper = 0,
      handler = "ShareHandler"
    },
    [579081806] = {
      req = "get_share_info_request",
      res = "get_share_info_respond",
      inGameOper = 0,
      handler = "ShareHandler"
    },
    [897114704] = {
      req = "share_replay_report",
      handler = "ShareHandler"
    },
    [1198365351] = {
      req = "client_sponsor_award_req",
      res = "client_sponsor_award_rsp",
      handler = "ShareHandler"
    },
    [1578100929] = {
      req = "share_actions_request",
      handler = "ShareHandler"
    },
    [1751217394] = {
      req = "share_succ_request",
      handler = "ShareHandler"
    },
    [1807298277] = {
      req = "manor_share_report_req",
      timeInterval = 1,
      handler = "ShareHandler"
    },
    [1851701498] = {
      req = "share_get_award_req",
      res = "share_get_award_res",
      inGameOper = 0,
      handler = "ShareHandler"
    },
    [11048127] = {
      res = "without_acception_to_inviter_notify",
      handler = "ShareSuitHandler"
    },
    [66548935] = {
      req = "tenquiry_posture_qualification_req",
      res = "tenquiry_posture_qualification_rsp",
      handler = "ShareSuitHandler"
    },
    [225275992] = {
      res = "change_taluo_share_dress_notify",
      handler = "ShareSuitHandler"
    },
    [552686247] = {
      req = "invite_share_taluo_dress_req",
      res = "invite_share_taluo_dress_rsp",
      handler = "ShareSuitHandler"
    },
    [860533367] = {
      res = "taluo_dress_share_qualification_notify",
      handler = "ShareSuitHandler"
    },
    [916834539] = {
      req = "auto_unlock_partner_posture_req",
      res = "auto_unlock_partner_posture_rsp",
      handler = "ShareSuitHandler"
    },
    [1129476517] = {
      res = "share_taluo_dress_broadcast_notify",
      handler = "ShareSuitHandler"
    },
    [1579350471] = {
      req = "invitee_response_share_req",
      res = "invitee_response_share_rsp",
      handler = "ShareSuitHandler"
    },
    [1801216933] = {
      res = "receive_share_taluo_dress_notify",
      handler = "ShareSuitHandler"
    },
    [1624384239] = {
      req = "set_chat_ban_labels_req",
      res = "set_chat_ban_labels_rsp",
      handler = "ShieldHandler"
    },
    [2082694400] = {
      res = "chat_ban_labels_notify",
      handler = "ShieldHandler"
    },
    [1784137086] = {
      res = "market_send_thank_notify",
      handler = "ShopGiftPacketHandler"
    },
    [293481587] = {
      req = "query_player_partner_info_req",
      res = "query_player_partner_info_rsp",
      handler = "ShowBrandHandler"
    },
    [1059049799] = {
      req = "query_common_brand_req",
      res = "query_common_brand_rsp",
      inGameOper = 0,
      handler = "ShowBrandHandler"
    },
    [1145380047] = {
      req = "save_common_brand_req",
      res = "save_common_brand_rsp",
      handler = "ShowBrandHandler"
    },
    [1500198759] = {
      req = "set_active_brand_req",
      res = "set_active_brand_rsp",
      handler = "ShowBrandHandler"
    },
    [841755367] = {
      req = "single_training_invite_req",
      res = "single_training_invite_rsp",
      inGameOper = 0,
      handler = "SingleTrainingHandler"
    },
    [929960003] = {
      req = "single_training_enter_req",
      res = "single_training_enter_rsp",
      inGameOper = 0,
      handler = "SingleTrainingHandler"
    },
    [1491098711] = {
      res = "single_training_invite_notify",
      inGameOper = 0,
      handler = "SingleTrainingHandler"
    },
    [1581758243] = {
      req = "single_training_apply_req",
      res = "single_training_apply_rsp",
      inGameOper = 0,
      handler = "SingleTrainingHandler"
    },
    [704442407] = {
      req = "query_challenge_subside_info_req",
      res = "query_challenge_subside_info_rsp",
      handler = "SinkHandler"
    },
    [902404857] = {
      res = "notify_subside_data_zone",
      handler = "SinkHandler"
    },
    [1085985700] = {
      res = "notify_challenge_subside_info",
      handler = "SinkHandler"
    },
    [1485369959] = {
      req = "query_subside_data_req",
      res = "query_subside_data_rsp",
      handler = "SinkHandler"
    },
    [26236202] = {
      res = "sync_skill_task_change",
      inGameOper = 0,
      handler = "SkillSystemHandler"
    },
    [246806503] = {
      req = "get_skill_trial_task_req",
      res = "get_skill_trial_task_rsp",
      inGameOper = 0,
      handler = "SkillSystemHandler"
    },
    [447388323] = {
      req = "receive_skill_trial_task_reward_req",
      res = "receive_skill_trial_task_reward_rsp",
      inGameOper = 0,
      handler = "SkillSystemHandler"
    },
    [1505511695] = {
      req = "skill_trial_get_skill_req",
      res = "skill_trial_get_skill_rsp",
      inGameOper = 0,
      handler = "SkillSystemHandler"
    },
    [2003434407] = {
      req = "skill_trial_select_skill_req",
      res = "skill_trial_select_skill_rsp",
      inGameOper = 0,
      handler = "SkillSystemHandler"
    },
    [764880291] = {
      res = "sync_noble_coupon_lucky_info",
      handler = "SmallPaymentHandler"
    },
    [931480382] = {
      res = "sync_noble_coupon_activity_task_ntf",
      handler = "SmallPaymentHandler"
    },
    [1413099699] = {
      req = "get_noble_coupon_activity_req",
      res = "get_noble_coupon_activity_rsp",
      isUnique = 1,
      handler = "SmallPaymentHandler"
    },
    [680571279] = {
      req = "small_rp_get_task_award_req",
      res = "small_rp_get_task_award_rsp",
      isLock = 1,
      handler = "SmallRPHandler"
    },
    [945117863] = {
      req = "small_rp_player_data_req",
      res = "small_rp_player_data_rsp",
      handler = "SmallRPHandler"
    },
    [1249812956] = {
      res = "small_rp_score_notify_change",
      handler = "SmallRPHandler"
    },
    [1383652999] = {
      req = "small_rp_buy_score_req",
      res = "small_rp_buy_score_rsp",
      isLock = 1,
      handler = "SmallRPHandler"
    },
    [1613165458] = {
      req = "sync_small_rp_task_data_req",
      res = "sync_small_rp_task_data_info",
      handler = "SmallRPHandler"
    },
    [1652991127] = {
      req = "small_rp_unlock_req",
      res = "small_rp_unlock_rsp",
      isLock = 1,
      handler = "SmallRPHandler"
    },
    [1676253863] = {
      req = "small_rp_batch_get_level_award_req",
      res = "small_rp_batch_get_level_award_rsp",
      isLock = 1,
      handler = "SmallRPHandler"
    },
    [1711653415] = {
      req = "small_rp_batch_get_stage_award_req",
      res = "small_rp_batch_get_stage_award_rsp",
      isLock = 1,
      handler = "SmallRPHandler"
    },
    [1717829223] = {
      req = "small_rp_get_level_award_req",
      res = "small_rp_get_level_award_rsp",
      isLock = 1,
      handler = "SmallRPHandler"
    },
    [1862359467] = {
      req = "small_rp_batch_get_task_award_req",
      res = "small_rp_batch_get_task_award_rsp",
      isLock = 1,
      handler = "SmallRPHandler"
    },
    [1974357735] = {
      req = "small_rp_level_award_cfg_req",
      res = "small_rp_level_award_cfg_rsp",
      handler = "SmallRPHandler"
    },
    [320480793] = {
      req = "report_minitv_raw_event_req",
      handler = "SmartAssistantHandler"
    },
    [625376024] = {
      res = "notify_minitv_action",
      handler = "SmartAssistantHandler"
    },
    [657057767] = {
      req = "get_minitv_user_info_req",
      res = "get_minitv_user_info_rsp",
      handler = "SmartAssistantHandler"
    },
    [802992287] = {
      req = "load_auto_equipment_req",
      res = "load_auto_equipment_rsp",
      handler = "SmartAssistantHandler"
    },
    [865422343] = {
      req = "robot_assistant_report_ai_req",
      res = "robot_assistant_report_ai_rsp",
      handler = "SmartAssistantHandler"
    },
    [982471719] = {
      req = "robot_assistant_get_soul_recommend_topic_req",
      res = "robot_assistant_get_soul_recommend_topic_rsp",
      handler = "SmartAssistantHandler"
    },
    [991574623] = {
      req = "robot_assistant_notice_module_change_req",
      handler = "SmartAssistantHandler"
    },
    [1133170875] = {
      res = "robot_assistant_safe_operation_notify",
      handler = "SmartAssistantHandler"
    },
    [1252649575] = {
      req = "robot_assistant_llm_chat_req",
      res = "robot_assistant_llm_chat_rsp",
      handler = "SmartAssistantHandler"
    },
    [1281041139] = {
      req = "minitv_daily_lottery_draw_req",
      res = "minitv_daily_lottery_draw_rsp",
      handler = "SmartAssistantHandler"
    },
    [1413388615] = {
      req = "robot_assistant_reward_task_report_req",
      res = "robot_assistant_reward_task_report_rsp",
      handler = "SmartAssistantHandler"
    },
    [1635409435] = {
      req = "assistant_get_cfg_req",
      res = "assistant_get_cfg_rsp",
      handler = "SmartAssistantHandler"
    },
    [1637865383] = {
      req = "robot_assistant_llm_cancel_chat_req",
      res = "robot_assistant_llm_cancel_chat_rsp",
      handler = "SmartAssistantHandler"
    },
    [1726040191] = {
      req = "report_minitv_user_action_req",
      res = "report_minitv_user_action_rsp",
      handler = "SmartAssistantHandler"
    },
    [1777356839] = {
      req = "get_robot_assistant_reward_task_notice_req",
      res = "get_robot_assistant_reward_task_notice_rsp",
      handler = "SmartAssistantHandler"
    },
    [1820907207] = {
      req = "robot_assistant_get_reward_req",
      res = "robot_assistant_get_reward_rsp",
      handler = "SmartAssistantHandler"
    },
    [1934474747] = {
      req = "robot_assistant_response_answer_req",
      res = "robot_assistant_response_answer_rsp",
      handler = "SmartAssistantHandler"
    },
    [58053023] = {
      res = "notify_collect_hall_data",
      inGameOper = 0,
      handler = "SocialAndCollection_LobbyHandler"
    },
    [599963687] = {
      req = "unlock_collect_hall_slot_req",
      res = "unlock_collect_hall_slot_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "SocialAndCollection_LobbyHandler"
    },
    [783260775] = {
      req = "set_social_main_page_milestone_req",
      res = "set_social_main_page_milestone_rsp",
      inGameOper = 0,
      handler = "SocialAndCollection_LobbyHandler"
    },
    [1269555111] = {
      req = "get_vst_item_feature_req",
      res = "get_vst_item_feature_rsp",
      inGameOper = 0,
      handler = "SocialAndCollection_LobbyHandler"
    },
    [1300222787] = {
      req = "get_collect_hall_data_req",
      res = "get_collect_hall_data_rsp",
      inGameOper = 0,
      handler = "SocialAndCollection_LobbyHandler"
    },
    [1522489779] = {
      req = "get_other_mixed_hall_data_req",
      res = "get_other_mixed_hall_data_rsp",
      handler = "SocialAndCollection_LobbyHandler"
    },
    [1727953351] = {
      req = "edit_honor_display_req",
      res = "edit_honor_display_rsp",
      handler = "SocialAndCollection_LobbyHandler"
    },
    [1374335443] = {
      res = "notify_social_card_floor",
      handler = "SocialCardBGHandler"
    },
    [1512236467] = {
      req = "set_social_card_floor_req",
      res = "set_social_card_floor_rsp",
      handler = "SocialCardBGHandler"
    },
    [11681703] = {
      req = "get_socialland_weaponry_plan_req",
      res = "get_socialland_weaponry_plan_rsp",
      handler = "SocialIslandHandler"
    },
    [165014355] = {
      req = "socialland_invite_req",
      res = "socialland_invite_rsp",
      timeInterval = 3,
      handler = "SocialIslandHandler"
    },
    [217783820] = {
      res = "pvt_socialland_info_notify",
      handler = "SocialIslandHandler"
    },
    [246980235] = {
      req = "set_apply_onoff_req",
      res = "set_apply_onoff_rsp",
      handler = "SocialIslandHandler"
    },
    [250873767] = {
      req = "socialland_apply_req",
      res = "socialland_apply_rsp",
      timeInterval = 0.5,
      handler = "SocialIslandHandler"
    },
    [275398881] = {
      res = "pvt_socialland_invite_rsp",
      handler = "SocialIslandHandler"
    },
    [275952316] = {
      res = "socialland_invite_notify",
      handler = "SocialIslandHandler"
    },
    [331390867] = {
      req = "get_racing_history_record_req",
      res = "get_racing_history_record_rsp",
      handler = "SocialIslandHandler"
    },
    [336249575] = {
      req = "pvt_socialland_process_applyer_req",
      res = "pvt_socialland_process_applyer_rsp",
      handler = "SocialIslandHandler"
    },
    [517515175] = {
      req = "set_socialland_weaponry_plan_req",
      res = "set_socialland_weaponry_plan_rsp",
      handler = "SocialIslandHandler"
    },
    [551737091] = {
      req = "get_duel_history_record_req",
      res = "get_duel_history_record_rsp",
      handler = "SocialIslandHandler"
    },
    [612547011] = {
      req = "get_socialland_status_req",
      res = "get_socialland_status_rsp",
      handler = "SocialIslandHandler"
    },
    [687045191] = {
      req = "get_racing_best_record_req",
      res = "get_racing_best_record_rsp",
      handler = "SocialIslandHandler"
    },
    [850730727] = {
      req = "set_pvt_socialland_authority_req",
      res = "set_pvt_socialland_authority_rsp",
      handler = "SocialIslandHandler"
    },
    [934296399] = {
      req = "get_target_history_record_req",
      res = "get_target_history_record_rsp",
      handler = "SocialIslandHandler"
    },
    [987100419] = {
      req = "get_socialland_banner_req",
      res = "get_socialland_banner_rsp",
      handler = "SocialIslandHandler"
    },
    [1068349863] = {
      req = "sociallland_kickout_player_req",
      res = "sociallland_kickout_player_rsp",
      handler = "SocialIslandHandler"
    },
    [1077760103] = {
      req = "get_pvt_socialland_list_info_req",
      res = "get_pvt_socialland_list_info_rsp",
      handler = "SocialIslandHandler"
    },
    [1078715146] = {
      res = "notify_pvt_socialland_data",
      handler = "SocialIslandHandler"
    },
    [1207829322] = {
      res = "pvt_socialland_apply_rsp",
      handler = "SocialIslandHandler"
    },
    [1215265863] = {
      req = "socialland_invitee_confirm_req",
      res = "socialland_invitee_confirm_rsp",
      timeInterval = 3,
      handler = "SocialIslandHandler"
    },
    [1314850099] = {
      req = "create_pvt_socialland_req",
      res = "create_pvt_socialland_rsp",
      handler = "SocialIslandHandler"
    },
    [1416341031] = {
      req = "del_socialland_weaponry_plan_req",
      res = "del_socialland_weaponry_plan_rsp",
      handler = "SocialIslandHandler"
    },
    [1618295829] = {
      res = "notify_socialland_owner_apply",
      handler = "SocialIslandHandler"
    },
    [1667434087] = {
      req = "socialland_enter_req",
      res = "socialland_enter_rsp",
      timeInterval = 3,
      handler = "SocialIslandHandler"
    },
    [1702022727] = {
      req = "pvt_socialland_process_invitee_req",
      res = "pvt_socialland_process_invitee_rsp",
      handler = "SocialIslandHandler"
    },
    [1866301129] = {
      res = "notify_socialland_loading",
      handler = "SocialIslandHandler"
    },
    [2140041147] = {
      req = "get_apply_onoff_req",
      res = "get_apply_onoff_rsp",
      handler = "SocialIslandHandler"
    },
    [89089484] = {
      req = "get_role_privacy",
      res = "get_role_privacy_rsp",
      handler = "SocialLobbyHandler"
    },
    [300057964] = {
      req = "modify_role_signature",
      res = "modify_role_signature_respond",
      isLock = 1,
      handler = "SocialLobbyHandler"
    },
    [333060327] = {
      req = "publish_intimacy_conscribe_req",
      res = "publish_intimacy_conscribe_rsp",
      isUnique = 1,
      queueType = 1,
      timeInterval = 6,
      handler = "SocialLobbyHandler"
    },
    [441552679] = {
      req = "get_last_battle_type_req",
      res = "get_last_battle_type_rsp",
      handler = "SocialLobbyHandler"
    },
    [527447724] = {
      req = "get_role_history_season_battle",
      res = "get_role_history_season_battle_rsp",
      handler = "SocialLobbyHandler"
    },
    [582500332] = {
      req = "modify_social_card",
      res = "modify_social_card_rsp",
      handler = "SocialLobbyHandler"
    },
    [865429597] = {
      res = "notify_collect_hall_data_to_client",
      handler = "SocialLobbyHandler"
    },
    [872016551] = {
      req = "get_intimacy_conscribe_state_req",
      res = "get_intimacy_conscribe_state_rsp",
      isUnique = 1,
      queueType = 1,
      timeInterval = 2,
      handler = "SocialLobbyHandler"
    },
    [1187026892] = {
      req = "get_role_history_season_battle_no_rank",
      res = "get_role_history_season_battle_no_rank_rsp",
      handler = "SocialLobbyHandler"
    },
    [1303985484] = {
      req = "modify_role_name",
      res = "modify_role_name_rsp",
      isLock = 1,
      handler = "SocialLobbyHandler"
    },
    [1549217228] = {
      req = "get_role_battle_info",
      res = "get_role_battle_info_rsp",
      handler = "SocialLobbyHandler"
    },
    [1700159783] = {
      req = "get_role_history_season_peakgame_req",
      res = "get_role_history_season_peakgame_rsp",
      handler = "SocialLobbyHandler"
    },
    [1778875044] = {
      req = "client_in_depot",
      handler = "SocialLobbyHandler"
    },
    [1822290252] = {
      req = "get_role_lbs_battle_info",
      res = "get_role_lbs_battle_info_rsp",
      handler = "SocialLobbyHandler"
    },
    [1969842170] = {
      req = "set_battleinfo_show_options_req",
      res = "set_battleinfo_show_options_res",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "SocialLobbyHandler"
    },
    [2019377638] = {
      req = "get_social_card",
      res = "get_social_card_rsp",
      handler = "SocialLobbyHandler"
    },
    [33564146] = {
      res = "notify_solo_cancel",
      handler = "SoloMatchHandler"
    },
    [876300382] = {
      req = "cancel_solo_request",
      res = "cancel_solo_respond",
      handler = "SoloMatchHandler"
    },
    [992310561] = {
      res = "solo_invite_notify",
      timeInterval = 2,
      handler = "SoloMatchHandler"
    },
    [1673944263] = {
      res = "start_solo_game_respond",
      handler = "SoloMatchHandler"
    },
    [1738547007] = {
      res = "notify_solo_invite_result",
      handler = "SoloMatchHandler"
    },
    [1907884014] = {
      req = "start_solo_request",
      res = "start_solo_respond",
      isUnique = 1,
      queueType = 1,
      timeout = 30,
      timeInterval = 2,
      handler = "SoloMatchHandler"
    },
    [2041944511] = {
      req = "ugc_get_sole_battle_mod_cfg_req",
      res = "ugc_get_sole_battle_mod_cfg_rsp",
      handler = "SoloMatchHandler"
    },
    [2130022556] = {
      req = "solo_invite_reply",
      res = "solo_invite_reply_rsp",
      timeout = 5,
      handler = "SoloMatchHandler"
    },
    [973573383] = {
      req = "get_pspace_coupon_plan_req",
      res = "get_pspace_coupon_plan_rsp",
      timeInterval = 1,
      handler = "SpaceGiftDiscountHandler"
    },
    [1119132871] = {
      req = "buy_pspace_coupon_plan_req",
      res = "buy_pspace_coupon_plan_rsp",
      timeInterval = 1,
      handler = "SpaceGiftDiscountHandler"
    },
    [734050522] = {
      req = "get_commercial_showpage_req",
      res = "notify_commercial_showpage_rsp",
      handler = "SpecialOfferHandler"
    },
    [1597748729] = {
      res = "notify_commercial_showpage_info_one",
      handler = "SpecialOfferHandler"
    },
    [361528775] = {
      req = "get_receiver_own_item_info_req",
      res = "get_receiver_own_item_info_rsp",
      handler = "SportscarHandler"
    },
    [1894921047] = {
      req = "unlock_car_page_award_req",
      res = "unlock_car_page_award_rsp",
      isLock = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "SportscarHandler"
    },
    [319060859] = {
      req = "trigger_starter_pack_final_offer_req",
      handler = "StarterPackHandler"
    },
    [450387983] = {
      res = "notify_online_status_chg",
      inGameOper = 0,
      handler = "StatusHandler"
    },
    [1235300118] = {
      res = "notify_friend_play_hall_room_stat",
      inGameOper = 0,
      handler = "StatusHandler"
    },
    [1530925416] = {
      req = "set_online_status_req",
      res = "set_online_status_res",
      inGameOper = 0,
      handler = "StatusHandler"
    },
    [1694671820] = {
      req = "query_friend_room_id",
      res = "query_friend_room_id_rsp",
      inGameOper = 0,
      handler = "StatusHandler"
    },
    [1756432487] = {
      req = "batch_get_group_and_online_req",
      res = "batch_get_group_and_online_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "StatusHandler"
    },
    [1915552044] = {
      req = "get_friend_play_hall_room_stat",
      res = "get_friend_play_hall_room_stat_rsp",
      inGameOper = 0,
      handler = "StatusHandler"
    },
    [2134279619] = {
      res = "notify_group_status_chg",
      isUnique = 1,
      inGameOper = 0,
      handler = "StatusHandler"
    },
    [63273841] = {
      req = "set_performance_switch_req",
      handler = "StoreHandler"
    },
    [66498475] = {
      req = "subscribe_commodity_req",
      res = "subscribe_commodity_rsp",
      handler = "StoreHandler"
    },
    [101239873] = {
      res = "market_buy_chest_item_notify",
      handler = "StoreHandler"
    },
    [143353639] = {
      req = "get_shop_newest_info_req",
      res = "get_shop_newest_info_rsp",
      handler = "StoreHandler"
    },
    [150985639] = {
      req = "get_lucky_draw_unback_activity_req",
      res = "get_lucky_draw_unback_activity_rsp",
      handler = "StoreHandler"
    },
    [443291433] = {
      res = "sync_market_version",
      handler = "StoreHandler"
    },
    [480951099] = {
      req = "get_global_collect_data_by_itemlist_req",
      res = "get_global_collect_data_by_itemlist_rsp",
      inGameOper = 0,
      handler = "StoreHandler"
    },
    [551999099] = {
      req = "get_reopen_box_full_req",
      res = "get_reopen_box_full_rsp",
      handler = "StoreHandler"
    },
    [571956532] = {
      req = "get_stage_chest_cfg",
      res = "get_stage_chest_cfg_rsp",
      handler = "StoreHandler"
    },
    [746322023] = {
      req = "get_market_gift_limit_info_req",
      res = "get_market_gift_limit_info_rsp",
      handler = "StoreHandler"
    },
    [768423139] = {
      req = "get_self_global_mcollect_data_req",
      res = "get_self_global_mcollect_data_rsp",
      isLock = 1,
      timeout = 5,
      timeInterval = 1,
      handler = "StoreHandler"
    },
    [772305758] = {
      res = "box_energy_receive_award_rsp",
      handler = "StoreHandler"
    },
    [785709972] = {
      req = "activity_market_buy_req",
      handler = "StoreHandler"
    },
    [800915276] = {
      req = "newbie_chest_buy",
      res = "newbie_chest_buy_rsp",
      handler = "StoreHandler"
    },
    [800935847] = {
      req = "get_shop_limit_req",
      res = "get_shop_limit_rsp",
      handler = "StoreHandler"
    },
    [805926587] = {
      req = "get_market_info_req",
      res = "get_market_info_rsp",
      isLock = 1,
      timeout = 15,
      handler = "StoreHandler"
    },
    [832225426] = {
      res = "get_subscribe_commodity_info_rsp",
      handler = "StoreHandler"
    },
    [836149903] = {
      req = "get_market_recommend_info_req",
      res = "get_market_recommend_info_rsp",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [865297031] = {
      req = "new_props_list_req",
      res = "new_props_list_rsp",
      handler = "StoreHandler"
    },
    [883803187] = {
      req = "get_market_chest_info_req",
      res = "get_market_chest_info_rsp",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [900798814] = {
      req = "buy_stage_chest",
      res = "buy_stage_chest_rsp",
      handler = "StoreHandler"
    },
    [955603559] = {
      req = "get_market_support_currency_req",
      res = "get_market_support_currency_rsp",
      handler = "StoreHandler"
    },
    [964425315] = {
      req = "get_all_cond_gift_req",
      res = "get_all_cond_gift_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "StoreHandler"
    },
    [983732495] = {
      req = "get_item_send_rule_config_req",
      res = "get_item_send_rule_config_rsp",
      handler = "StoreHandler"
    },
    [1056088219] = {
      req = "get_shop_info_req",
      res = "get_shop_info_rsp",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [1079258312] = {
      res = "notice_shop_guarantee_reward",
      handler = "StoreHandler"
    },
    [1100459299] = {
      req = "give_gift_from_market_req_v3",
      res = "give_gift_from_market_rsp_v3",
      handler = "StoreHandler"
    },
    [1117896135] = {
      req = "get_shop_flowlight_req",
      res = "get_shop_flowlight_rsp",
      handler = "StoreHandler"
    },
    [1118532007] = {
      req = "get_market_collect_red_point_req",
      res = "get_market_collect_red_point_rsp",
      handler = "StoreHandler"
    },
    [1128985420] = {
      res = "update_shop_limit",
      handler = "StoreHandler"
    },
    [1129178855] = {
      req = "add_market_collect_by_item_req",
      res = "add_market_collect_by_item_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "StoreHandler"
    },
    [1261842727] = {
      req = "do_draw_discount_by_activity_req",
      res = "do_draw_discount_by_activity_rsp",
      handler = "StoreHandler"
    },
    [1332186942] = {
      res = "update_shop_price_rsp_v3",
      handler = "StoreHandler"
    },
    [1333833931] = {
      req = "get_market_tab_list_req",
      res = "get_market_tab_list_rsp",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [1344591655] = {
      req = "do_biochemical_activity_one_draw_req",
      res = "do_biochemical_activity_one_draw_rsp",
      handler = "StoreHandler"
    },
    [1353850343] = {
      req = "receive_guarantee_reward_req",
      res = "receive_guarantee_reward_rsp",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [1361055513] = {
      res = "please_direct_buy",
      handler = "StoreHandler"
    },
    [1367989132] = {
      req = "limited_discount_buy",
      res = "limited_discount_buy_rsp",
      handler = "StoreHandler"
    },
    [1369077667] = {
      req = "cancel_market_collect_by_item_req",
      res = "cancel_market_collect_by_item_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "StoreHandler"
    },
    [1428642807] = {
      req = "get_market_collect_tips_jump_info_req",
      res = "get_market_collect_tips_jump_info_rsp",
      inGameOper = 0,
      handler = "StoreHandler"
    },
    [1453876871] = {
      req = "do_one_draw_by_activity_req",
      res = "do_one_draw_by_activity_rsp",
      isLock = 1,
      handler = "StoreHandler"
    },
    [1512379751] = {
      req = "market_get_askinfo_req",
      res = "market_get_askinfo_rsp",
      handler = "StoreHandler"
    },
    [1595012615] = {
      req = "fetch_chest_result_req",
      res = "fetch_chest_result_rsp",
      timeout = 5,
      handler = "StoreHandler"
    },
    [1684522119] = {
      req = "get_all_collect_chest_data_req",
      res = "get_all_collect_chest_data_rsp",
      handler = "StoreHandler"
    },
    [1689138763] = {
      req = "chest_collect_req",
      res = "chest_collect_rsp",
      handler = "StoreHandler"
    },
    [1704182995] = {
      res = "notify_rc_task",
      handler = "StoreHandler"
    },
    [1762886877] = {
      res = "market_dynamic_price_change_notify",
      handler = "StoreHandler"
    },
    [1785414199] = {
      req = "update_shop_wish_info_req",
      res = "update_shop_wish_info_rsp",
      handler = "StoreHandler"
    },
    [1808111143] = {
      req = "get_global_mcollect_data_by_page_req",
      res = "get_global_mcollect_data_by_page_rsp",
      isLock = 1,
      timeout = 5,
      timeInterval = 1,
      handler = "StoreHandler"
    },
    [1841957895] = {
      res = "get_chest_bubble_notify_rsp",
      handler = "StoreHandler"
    },
    [1893412707] = {
      req = "get_market_buy_info_req_v3",
      res = "get_market_buy_info_rsp_v3",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [1927275691] = {
      req = "get_shop_tab_list_req",
      res = "get_shop_tab_list_rsp",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [1945058054] = {
      res = "get_all_cond_gift_notify",
      handler = "StoreHandler"
    },
    [1951163943] = {
      req = "get_market_collect_jump_info_req",
      res = "get_market_collect_jump_info_rsp",
      isLock = 1,
      timeout = 5,
      handler = "StoreHandler"
    },
    [1989951463] = {
      req = "buy_market_by_id_req",
      res = "buy_market_by_id_rsp",
      isLock = 1,
      timeout = 10,
      handler = "StoreHandler"
    },
    [1998051364] = {
      res = "buy_shop_by_id_ntf",
      handler = "StoreHandler"
    },
    [2123020243] = {
      req = "direct_buy_result_req",
      res = "direct_buy_result_rsp",
      handler = "StoreHandler"
    },
    [2136611687] = {
      req = "buy_shop_by_id_req",
      res = "buy_shop_by_id_rsp",
      isLock = 1,
      timeout = 10,
      handler = "StoreHandler"
    },
    [203567104] = {
      res = "get_subscribe_gift",
      handler = "SubscribeCarnivalHandler"
    },
    [1139257292] = {
      req = "prime_direct_buy",
      res = "prime_direct_buy_rsp",
      handler = "SubscribeCarnivalHandler"
    },
    [1377528086] = {
      req = "take_daily_reward",
      res = "take_daily_reward_rsp",
      isLock = 1,
      handler = "SubscribeCarnivalHandler"
    },
    [2119330714] = {
      req = "carnival_query_req",
      res = "carnival_notify",
      handler = "SubscribeCarnivalHandler"
    },
    [76102583] = {
      res = "notify_instant_reward",
      handler = "SubscribeHandler"
    },
    [132059468] = {
      req = "jpkr_take_daily_uc",
      res = "jpkr_take_daily_uc_rsp",
      handler = "SubscribeHandler"
    },
    [322631692] = {
      req = "take_daily_uc_priv",
      res = "take_daily_uc_priv_rsp",
      handler = "SubscribeHandler"
    },
    [354120044] = {
      req = "jpkr_discount_buy",
      res = "jpkr_discount_buy_rsp",
      handler = "SubscribeHandler"
    },
    [454039692] = {
      req = "take_daily_rp_priv",
      res = "take_daily_rp_priv_rsp",
      handler = "SubscribeHandler"
    },
    [513625471] = {
      req = "report_finish_upgrade_260_guide_req",
      res = "report_finish_upgrade_260_guide_rsp",
      handler = "SubscribeHandler"
    },
    [527806782] = {
      req = "set_prime_badge_no_show_flag",
      res = "set_prime_badge_no_show_flag",
      handler = "SubscribeHandler"
    },
    [531976780] = {
      req = "buy_discount_sale_item",
      res = "buy_discount_sale_item_rsp",
      handler = "SubscribeHandler"
    },
    [538443340] = {
      req = "jpkr_take_daily_fp",
      res = "jpkr_take_daily_fp_rsp",
      handler = "SubscribeHandler"
    },
    [822717543] = {
      req = "take_prime_privilege_award_req",
      res = "take_prime_privilege_award_rsp",
      isLock = 1,
      handler = "SubscribeHandler"
    },
    [838042028] = {
      req = "get_primeshop_info",
      res = "get_primeshop_info_rsp",
      handler = "SubscribeHandler"
    },
    [1112185612] = {
      req = "take_coupons",
      res = "take_coupons_rsp",
      isLock = 1,
      handler = "SubscribeHandler"
    },
    [1142848278] = {
      res = "prime_notify_valid_activity",
      handler = "SubscribeHandler"
    },
    [1510025356] = {
      req = "query_prime_info",
      res = "query_prime_info_rsp",
      handler = "SubscribeHandler"
    },
    [1574048524] = {
      req = "take_first_award",
      res = "take_first_award_rsp",
      handler = "SubscribeHandler"
    },
    [1671296844] = {
      req = "take_primer_item",
      res = "take_primer_item_rsp",
      timeout = 5,
      handler = "SubscribeHandler"
    },
    [1772059060] = {
      res = "notify_prime_change",
      handler = "SubscribeHandler"
    },
    [1828308335] = {
      res = "primeshop_reward_notify",
      handler = "SubscribeHandler"
    },
    [1990927072] = {
      res = "notify_primeshop_change",
      inGameOper = 0,
      handler = "SubscribeHandler"
    },
    [972133351] = {
      req = "upgrade_recolor_suit_req",
      res = "upgrade_recolor_suit_rsp",
      handler = "SuitDyeHandler"
    },
    [994494151] = {
      req = "set_recolor_suit_plan_data_req",
      res = "set_recolor_suit_plan_data_rsp",
      handler = "SuitDyeHandler"
    },
    [1255202471] = {
      req = "set_recolor_suit_plan_id_req",
      res = "set_recolor_suit_plan_id_rsp",
      handler = "SuitDyeHandler"
    },
    [1481054279] = {
      req = "get_recolor_suit_plan_data_req",
      res = "get_recolor_suit_plan_data_rsp",
      handler = "SuitDyeHandler"
    },
    [135000599] = {
      res = "make_festival_notify",
      handler = "SuperAirdropHandler"
    },
    [471125170] = {
      res = "super_airdrop_process_change_notify",
      handler = "SuperAirdropHandler"
    },
    [656357687] = {
      req = "airdrop_first_time_info_req",
      res = "airdrop_first_time_info_rsp",
      handler = "SuperAirdropHandler"
    },
    [1206922963] = {
      req = "choose_and_get_super_airdrop_reward_req",
      res = "choose_and_get_super_airdrop_reward_rsp",
      handler = "SuperAirdropHandler"
    },
    [1775577543] = {
      req = "get_super_airdrop_progress_req",
      res = "get_super_airdrop_progress_rsp",
      handler = "SuperAirdropHandler"
    },
    [2016710775] = {
      req = "get_make_festival_activity_list_req",
      res = "get_make_festival_activity_list_rsp",
      handler = "SuperAirdropHandler"
    },
    [795703999] = {
      req = "role_chest_custom_buy_req",
      res = "role_chest_custom_buy_rsp",
      handler = "SupplyOptionalHandler"
    },
    [816971439] = {
      req = "role_chest_custom_set_must_reward_req",
      res = "role_chest_custom_set_must_reward_rsp",
      handler = "SupplyOptionalHandler"
    },
    [992182951] = {
      req = "get_role_exchange_history_info_req",
      res = "get_role_exchange_history_info_rsp",
      handler = "SupplyOptionalHandler"
    },
    [1429324679] = {
      req = "get_role_custom_chest_info_req",
      res = "get_role_custom_chest_info_rsp",
      handler = "SupplyOptionalHandler"
    },
    [1943224863] = {
      req = "role_chest_exchange_temp_item_req",
      res = "role_chest_exchange_temp_item_rsp",
      handler = "SupplyOptionalHandler"
    },
    [56541547] = {
      req = "start_temu_task_phase_req",
      res = "start_temu_task_phase_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [165305639] = {
      req = "get_temu_red_point_req",
      res = "get_temu_red_point_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [208742775] = {
      req = "invite_all_temu_group_friend_list_req",
      res = "invite_all_temu_group_friend_list_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [400182071] = {
      req = "get_temu_group_info_req",
      res = "get_temu_group_info_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [453306723] = {
      req = "get_temu_group_progress_req",
      res = "get_temu_group_progress_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [457604839] = {
      req = "temu_group_kick_member_req",
      res = "temu_group_kick_member_rsp",
      timeInterval = 2,
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [468472403] = {
      req = "get_temu_group_friend_invite_list_req",
      res = "get_temu_group_friend_invite_list_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [501558365] = {
      res = "leave_temu_group_notify",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [551461085] = {
      res = "notify_temu_group_unlock_pkg",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [855274247] = {
      req = "dismiss_temu_group_req",
      res = "dismiss_temu_group_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [870421927] = {
      req = "remind_teammate_purchase_package_req",
      res = "remind_teammate_purchase_package_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [982977816] = {
      res = "notify_temu_new_invite",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1021376039] = {
      req = "take_temu_friendship_req",
      res = "take_temu_friendship_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1042283837] = {
      res = "notify_temu_basic_info",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1100339187] = {
      req = "get_temu_stage_info_req",
      res = "get_temu_stage_info_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1216033831] = {
      req = "leave_temu_group_req",
      res = "leave_temu_group_rsp",
      timeInterval = 2,
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1297265995] = {
      req = "join_temu_group_req",
      res = "join_temu_group_rsp",
      timeInterval = 5,
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1319067043] = {
      req = "create_temu_group_req",
      res = "create_temu_group_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1328072639] = {
      req = "remove_temu_be_kicked_red_point_req",
      res = "remove_temu_be_kicked_red_point_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1340034267] = {
      req = "buy_temu_group_pkg_for_gift_req",
      res = "buy_temu_group_pkg_for_gift_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1372723579] = {
      res = "notify_invite_temu_groupbuy_result",
      timeInterval = 1,
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1436339355] = {
      req = "get_temu_recommend_list_from_pool_req",
      res = "get_temu_recommend_list_from_pool_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1662620791] = {
      res = "notify_temu_group_sub_stage_up",
      timeInterval = 1,
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1969328423] = {
      req = "get_temu_group_invite_list_req",
      res = "get_temu_group_invite_list_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [1969790247] = {
      req = "remove_temu_invite_red_point_req",
      res = "remove_temu_invite_red_point_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [2073603879] = {
      req = "buy_temu_group_pkg_req",
      res = "buy_temu_group_pkg_rsp",
      inGameOper = 0,
      handler = "TEMUHandler"
    },
    [125504855] = {
      req = "metro_affix_upgrade_req",
      res = "metro_affix_upgrade_rsp",
      handler = "TResearchHandler"
    },
    [126960679] = {
      req = "get_pve_affix_guide_task_reveive_req",
      res = "get_pve_affix_guide_task_reveive_rsp",
      inGameOper = 0,
      handler = "TResearchHandler"
    },
    [145818892] = {
      req = "put_chest_on_console",
      res = "put_chest_on_console_rsp",
      handler = "TResearchHandler"
    },
    [330748711] = {
      req = "metro_decompose_item_req",
      res = "metro_decompose_item_rsp",
      handler = "TResearchHandler"
    },
    [703687636] = {
      req = "get_chest_countdown",
      res = "get_chest_countdown_rsp",
      handler = "TResearchHandler"
    },
    [882279855] = {
      req = "receive_affix_guide_task_reward_req",
      res = "receive_affix_guide_task_reward_rsp",
      handler = "TResearchHandler"
    },
    [1117376588] = {
      req = "receive_sys_gift",
      res = "receive_sys_gift_rsp",
      handler = "TResearchHandler"
    },
    [1173408417] = {
      req = "use_chest_accelerate",
      handler = "TResearchHandler"
    },
    [1398566447] = {
      req = "receive_pve_affix_guide_task_reward_req",
      res = "receive_pve_affix_guide_task_reward_rsp",
      inGameOper = 0,
      handler = "TResearchHandler"
    },
    [199494139] = {
      req = "service_table_req",
      res = "service_table_rsp",
      inGameOper = 0,
      handler = "TableDataHandler"
    },
    [254751271] = {
      req = "client_table_batch_req",
      res = "client_table_batch_rsp",
      inGameOper = 0,
      handler = "TableDataHandler"
    },
    [538224935] = {
      req = "get_first_event_card_req",
      res = "get_first_event_card_rsp",
      handler = "TarotCardHandler"
    },
    [643180771] = {
      req = "get_tarotcard_collect_award_req",
      res = "get_tarotcard_collect_award_rsp",
      handler = "TarotCardHandler"
    },
    [1001194203] = {
      req = "get_progress_reward_req",
      res = "get_progress_reward_rsp",
      isUnique = 1,
      handler = "TarotCardHandler"
    },
    [1014671679] = {
      req = "get_event_card_info_req",
      res = "get_event_card_info_rsp",
      handler = "TarotCardHandler"
    },
    [1078575271] = {
      req = "see_event_card_req",
      res = "see_event_card_rsp",
      handler = "TarotCardHandler"
    },
    [1354092503] = {
      req = "delete_event_card_req",
      res = "delete_event_card_rsp",
      handler = "TarotCardHandler"
    },
    [1392805927] = {
      req = "resort_event_card_req",
      res = "resort_event_card_rsp",
      handler = "TarotCardHandler"
    },
    [1607288039] = {
      req = "draw_tarot_req",
      res = "draw_tarot_rsp",
      isUnique = 1,
      isLock = 1,
      handler = "TarotCardHandler"
    },
    [1668098535] = {
      req = "get_taluo_attract_reward_req",
      res = "get_taluo_attract_reward_rsp",
      handler = "TarotCardHandler"
    },
    [1819699495] = {
      req = "get_new_event_card_req",
      res = "get_new_event_card_rsp",
      isUnique = 1,
      handler = "TarotCardHandler"
    },
    [1896271847] = {
      req = "accelerate_cd_time_req",
      res = "accelerate_cd_time_rsp",
      handler = "TarotCardHandler"
    },
    [2065530803] = {
      req = "get_left_cd_req",
      res = "get_left_cd_rsp",
      handler = "TarotCardHandler"
    },
    [2121501835] = {
      req = "get_tarot_draw_activity_req",
      res = "get_tarot_draw_activity_rsp",
      handler = "TarotCardHandler"
    },
    [190082146] = {
      res = "sync_task_info_rsp",
      handler = "TaskDailyHandler"
    },
    [241445567] = {
      req = "get_daily_task_active_award_req",
      res = "get_daily_task_active_award_rsp",
      isLock = 1,
      handler = "TaskDailyHandler"
    },
    [492780775] = {
      req = "reset_daily_task_req",
      res = "reset_daily_task_rsp",
      handler = "TaskDailyHandler"
    },
    [1086133415] = {
      req = "daily_task_receive_award_req",
      res = "daily_task_receive_award_rsp",
      isLock = 1,
      handler = "TaskDailyHandler"
    },
    [2005324612] = {
      req = "get_daily_task_data_req",
      res = "sync_daily_task_data_rsp",
      handler = "TaskDailyHandler"
    },
    [2048328] = {
      req = "activeness_get_award_req",
      res = "activeness_get_award_res",
      timeout = 5,
      handler = "TaskHandler"
    },
    [157235280] = {
      req = "activeness_get_week_req",
      res = "activeness_get_week_res",
      timeout = 5,
      handler = "TaskHandler"
    },
    [451062376] = {
      req = "task_get_award_req",
      res = "task_get_award_res",
      timeout = 5,
      handler = "TaskHandler"
    },
    [573843528] = {
      req = "level_task_get_award_req",
      res = "level_task_get_award_res",
      timeout = 5,
      handler = "TaskHandler"
    },
    [943209755] = {
      req = "task_get_weekly_award_req",
      res = "task_get_weekly_award_rsp",
      timeout = 5,
      handler = "TaskHandler"
    },
    [1212242841] = {
      req = "report_task_info",
      handler = "TaskHandler"
    },
    [1658655080] = {
      req = "task_get_all_award_req",
      res = "task_get_all_award_res",
      timeout = 5,
      handler = "TaskHandler"
    },
    [1720921659] = {
      req = "take_all_awards_of_task_req",
      res = "take_all_awards_of_task_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TaskHandler"
    },
    [2108458696] = {
      req = "level_task_get_all_award_req",
      res = "level_task_get_all_award_res",
      timeout = 5,
      handler = "TaskHandler"
    },
    [1249397563] = {
      req = "get_vs_skin_req",
      res = "get_vs_skin_rsp",
      handler = "TeamVsSkinHandler"
    },
    [1595838827] = {
      req = "buy_vs_skin_req",
      res = "buy_vs_skin_rsp",
      handler = "TeamVsSkinHandler"
    },
    [1679550951] = {
      req = "use_vs_skin_item_req",
      res = "use_vs_skin_item_rsp",
      handler = "TeamVsSkinHandler"
    },
    [102927911] = {
      req = "zone_select_ping_display_details_req",
      res = "zone_select_ping_display_details_rsp",
      handler = "TeamupHandler"
    },
    [115132066] = {
      req = "team_recruit_for_plat_req",
      res = "team_recruit_for_plat_res",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [196362813] = {
      res = "team_invite_reply_res_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [273709911] = {
      req = "update_car_main_page_slot_req",
      res = "update_car_main_page_slot_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [299146019] = {
      req = "team_send_quick_msg_req",
      res = "team_send_quick_msg_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [324315751] = {
      req = "get_recommend_team_req",
      res = "get_recommend_team_rsp",
      timeInterval = 60,
      handler = "TeamupHandler"
    },
    [350079406] = {
      res = "one_more_battle_info_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [377808392] = {
      req = "on_select_zone_req",
      res = "on_select_zone_res",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [388762394] = {
      res = "change_cross_shadow_notify",
      handler = "TeamupHandler"
    },
    [433317190] = {
      req = "team_invite_reply",
      handler = "TeamupHandler"
    },
    [488320684] = {
      req = "get_horse_lamp",
      res = "get_horse_lamp_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [514225423] = {
      res = "ntf_teamate_motion_levelup",
      handler = "TeamupHandler"
    },
    [514902248] = {
      req = "team_code_join_req",
      res = "team_code_join_res",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [576799152] = {
      req = "team_invite_request",
      res = "team_invite_respond",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [613117908] = {
      req = "team_report_voice_info",
      handler = "TeamupHandler"
    },
    [617885431] = {
      req = "together_dance_action_req",
      res = "together_dance_action_rsp",
      handler = "TeamupHandler"
    },
    [679522670] = {
      req = "team_change_leader_request",
      res = "team_change_leader_respond",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [690542060] = {
      req = "update_client_map_info",
      res = "update_client_map_info_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [725992677] = {
      res = "update_match_zone_list",
      handler = "TeamupHandler"
    },
    [728437255] = {
      req = "get_pre_team_limit_req",
      res = "get_pre_team_limit_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [745491788] = {
      req = "team_recruit",
      res = "team_recruit_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [755986875] = {
      req = "team_apply_reply",
      handler = "TeamupHandler"
    },
    [767104166] = {
      res = "sync_team_follow_leader_motion",
      handler = "TeamupHandler"
    },
    [797675047] = {
      req = "team_query_quick_msg_req",
      res = "team_query_quick_msg_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [812635815] = {
      req = "team_kick_no_map_req",
      res = "team_kick_no_map_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [843110527] = {
      res = "notify_invite_reply_accept",
      handler = "TeamupHandler"
    },
    [889351184] = {
      req = "team_quit_request",
      res = "team_quit_respond",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [891211559] = {
      req = "follow_leader_motion_setting_req",
      res = "follow_leader_motion_setting_rsp",
      handler = "TeamupHandler"
    },
    [920340237] = {
      req = "query_match_zone_list",
      res = "sync_match_zone_list",
      timeout = 5,
      needRsp = 3,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [946725927] = {
      req = "together_dance_action_replay_req",
      res = "together_dance_action_replay_rsp",
      timeInterval = 5,
      handler = "TeamupHandler"
    },
    [964516143] = {
      req = "get_pre_team_limit_info_req",
      res = "get_pre_team_limit_info_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [972847490] = {
      req = "team_change_member_status_request",
      res = "team_change_member_status_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [975142279] = {
      req = "batch_put_on_sportscar_req",
      res = "batch_put_on_sportscar_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [979864327] = {
      res = "only_leader_ping_notify",
      handler = "TeamupHandler"
    },
    [983471559] = {
      req = "get_car_main_page_data_req",
      res = "get_car_main_page_data_rsp",
      needRsp = 1,
      timeInterval = 1,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [990452299] = {
      res = "team_code_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1002280730] = {
      res = "team_change_wear",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1015576047] = {
      req = "notify_team_member_map_download_req",
      handler = "TeamupHandler"
    },
    [1026289556] = {
      res = "team_member_map_download_notify",
      handler = "TeamupHandler"
    },
    [1042030816] = {
      res = "select_zone_sync_krjp_asia",
      handler = "TeamupHandler"
    },
    [1076286664] = {
      req = "join_anchor_team_req",
      res = "join_anchor_team_res",
      needRsp = 999,
      timeInterval = 1,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1085802481] = {
      res = "team_change_type_respond",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1085822427] = {
      res = "team_change_type_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1105679368] = {
      req = "team_code_create_req",
      res = "team_code_create_res",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1121261184] = {
      req = "team_player_action",
      res = "sync_player_action",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1128956135] = {
      req = "use_fun_prop_req",
      res = "use_fun_prop_rsp",
      isUnique = 1,
      timeInterval = 1,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1135765008] = {
      res = "team_change_avatar",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1142732831] = {
      req = "report_play_zone_ping",
      handler = "TeamupHandler"
    },
    [1145084527] = {
      res = "notify_player_use_fun_prop",
      isUnique = 1,
      timeInterval = 1,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1152783123] = {
      req = "one_more_battle_reply_req",
      res = "one_more_battle_reply_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1167237447] = {
      req = "depot_cloth_feature_trigger_req",
      res = "depot_cloth_feature_trigger_rsp",
      handler = "TeamupHandler"
    },
    [1204342161] = {
      req = "team_change_type_request",
      handler = "TeamupHandler"
    },
    [1227703733] = {
      res = "room_invite_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1228794275] = {
      req = "get_single_squad_pre_team_limit_req",
      res = "get_single_squad_pre_team_limit_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1281339091] = {
      res = "notify_recommend_team_info",
      handler = "TeamupHandler"
    },
    [1313535034] = {
      req = "team_change_fill_request",
      handler = "TeamupHandler"
    },
    [1326944552] = {
      res = "view_id_conflict_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1329731932] = {
      res = "team_info_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1348199884] = {
      req = "user_finish_download_map",
      res = "user_finish_download_map_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1387513870] = {
      res = "cross_zone_change_leader_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1416320443] = {
      req = "one_more_battle_apply_req",
      res = "one_more_battle_apply_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1420305171] = {
      req = "change_only_leader_ping_req",
      res = "change_only_leader_ping_rsp",
      handler = "TeamupHandler"
    },
    [1451149485] = {
      res = "sync_ping_factors",
      handler = "TeamupHandler"
    },
    [1457760519] = {
      req = "get_all_pre_team_limit_req",
      res = "get_all_pre_team_limit_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1487720496] = {
      res = "team_apply_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1498057166] = {
      res = "team_apply_reply_res_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1526730587] = {
      req = "record_net_anomaly_date_req",
      res = "record_net_anomaly_date_rsp",
      handler = "TeamupHandler"
    },
    [1529784815] = {
      req = "end_one_more_battle_req",
      res = "end_one_more_battle_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1584545158] = {
      req = "team_info_request",
      res = "team_info_sync",
      timeout = 10,
      needRsp = 10,
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1617451143] = {
      req = "share_team_invite_link_req",
      res = "share_team_invite_link_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1619087110] = {
      req = "get_recommend_team_info",
      handler = "TeamupHandler"
    },
    [1628645250] = {
      res = "team_apply_respond",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1637483551] = {
      res = "ntf_teamate_motion_show_effect",
      handler = "TeamupHandler"
    },
    [1640999660] = {
      res = "team_match_zone_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1649956144] = {
      req = "cross_zone_allow_change_leader",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1695662147] = {
      req = "change_cross_shadow_req",
      res = "change_cross_shadow_rsp",
      handler = "TeamupHandler"
    },
    [1695890268] = {
      res = "tmode_room_team_info_notify",
      handler = "TeamupHandler"
    },
    [1806151948] = {
      req = "get_label_status",
      res = "get_label_status_rsp",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1817633027] = {
      req = "on_check_team_match_state",
      res = "on_check_team_match_state_res",
      handler = "TeamupHandler"
    },
    [1823664264] = {
      req = "team_code_delete_req",
      res = "team_code_delete_res",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1861768079] = {
      res = "team_invite_notify",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1863046274] = {
      req = "team_apply_request",
      handler = "TeamupHandler"
    },
    [1905989654] = {
      res = "team_join_respond",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1912817755] = {
      req = "main_city_change_3d_req",
      handler = "TeamupHandler"
    },
    [1931582242] = {
      req = "team_kick_request",
      res = "team_kick_respond",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1957946560] = {
      req = "room_invite_reply",
      timeInterval = 1,
      handler = "TeamupHandler"
    },
    [1959957416] = {
      req = "modify_anchor_subscription_req",
      res = "modify_anchor_subscription_res",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [1970559249] = {
      res = "sync_team_play_action_invite",
      inGameOper = 2,
      handler = "TeamupHandler"
    },
    [1996893257] = {
      res = "notify_teamup_sex_show",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "TeamupHandler"
    },
    [2023876173] = {
      res = "team_update_wear",
      inGameOper = 0,
      handler = "TeamupHandler"
    },
    [2038445622] = {
      req = "set_receive_nonfriend_team_request",
      handler = "TeamupHandler"
    },
    [2124236967] = {
      req = "depot_common_puton_sync_team_req",
      res = "depot_common_puton_sync_team_rsp",
      handler = "TeamupHandler"
    },
    [2145138136] = {
      res = "notify_pre_team_rating_gap_unreasonable",
      handler = "TeamupHandler"
    },
    [846049287] = {
      req = "multi_pool_draw_req",
      res = "multi_pool_draw_rsp",
      isLock = 1,
      timeout = 15,
      handler = "TeddyBearMonsterHandler"
    },
    [1357937991] = {
      req = "get_multi_pool_acc_reward_req",
      res = "get_multi_pool_acc_reward_rsp",
      handler = "TeddyBearMonsterHandler"
    },
    [1713562791] = {
      req = "get_multi_pool_draw_info_req",
      res = "get_multi_pool_draw_info_rsp",
      isLock = 1,
      timeout = 15,
      handler = "TeddyBearMonsterHandler"
    },
    [18972067] = {
      req = "query_offline_chest_req",
      res = "query_offline_chest_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "ThemeSystemHandler"
    },
    [35104807] = {
      req = "get_offline_chest_v2_req",
      res = "get_offline_chest_v2_rsp",
      isLock = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "ThemeSystemHandler"
    },
    [539116635] = {
      req = "get_magic_tree_stat_req",
      res = "get_magic_tree_stat_rsp",
      handler = "ThemeSystemHandler"
    },
    [819094383] = {
      req = "open_offline_chest_v2_req",
      res = "open_offline_chest_v2_rsp",
      isLock = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "ThemeSystemHandler"
    },
    [961152999] = {
      req = "unpack_offline_chest_req",
      res = "unpack_offline_chest_rsp",
      isLock = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "ThemeSystemHandler"
    },
    [1573390235] = {
      req = "watering_tree_req",
      res = "watering_tree_rsp",
      handler = "ThemeSystemHandler"
    },
    [1806285623] = {
      req = "get_global_magic_tree_percent_req",
      res = "get_global_magic_tree_percent_rsp",
      handler = "ThemeSystemHandler"
    },
    [1880653703] = {
      req = "open_offline_chest_req",
      res = "open_offline_chest_rsp",
      isLock = 1,
      timeout = 10,
      timeInterval = 1,
      inGameOper = 0,
      handler = "ThemeSystemHandler"
    },
    [867243450] = {
      res = "notify_theme_task_sys_award_flag",
      handler = "ThemeTaskHandler"
    },
    [1573398792] = {
      req = "take_theme_task_raward_req",
      res = "take_theme_task_raward_res",
      handler = "ThemeTaskHandler"
    },
    [2142129887] = {
      req = "get_theme_sys_task_data_req",
      res = "get_theme_sys_task_data_rsp",
      handler = "ThemeTaskHandler"
    },
    [584713448] = {
      req = "tournament_create_team_req",
      res = "tournament_create_team_res",
      handler = "TournamentCreateTeamHandler"
    },
    [1135653642] = {
      res = "tournament_team_enter",
      handler = "TournamentCreateTeamHandler"
    },
    [46654503] = {
      req = "tournament_room_id_req",
      res = "tournament_room_id_rsp",
      handler = "TournamentHandler"
    },
    [244147531] = {
      req = "create_privilege_room_req",
      res = "create_privilege_room_rsp",
      isUnique = 1,
      isLock = 1,
      timeout = 5,
      handler = "TournamentHandler"
    },
    [666170459] = {
      req = "tournament_info_req",
      res = "tournament_info_rsp",
      handler = "TournamentHandler"
    },
    [685724271] = {
      req = "tournament_get_filter_req",
      res = "tournament_get_filter_rsp",
      timeInterval = 1,
      handler = "TournamentHandler"
    },
    [781914959] = {
      req = "tournament_free_room_join_req",
      res = "tournament_free_room_join_rsp",
      handler = "TournamentHandler"
    },
    [812021870] = {
      res = "notify_tournament_new",
      handler = "TournamentHandler"
    },
    [905819087] = {
      req = "get_tournament_newbie_award_req",
      res = "get_tournament_newbie_award_rsp",
      handler = "TournamentHandler"
    },
    [990136856] = {
      res = "notify_tournament_has",
      handler = "TournamentHandler"
    },
    [1011010153] = {
      req = "game_operation_notice_readed",
      handler = "TournamentHandler"
    },
    [1022736359] = {
      req = "get_tournament_score_req",
      res = "get_tournament_score_rsp",
      handler = "TournamentHandler"
    },
    [1027230155] = {
      req = "tournament_enroll_req",
      res = "tournament_enroll_rsp",
      handler = "TournamentHandler"
    },
    [1430171802] = {
      res = "game_operation_notice_res",
      handler = "TournamentHandler"
    },
    [1686695615] = {
      req = "tournament_set_filter_req",
      res = "tournament_set_filter_rsp",
      handler = "TournamentHandler"
    },
    [1875066487] = {
      req = "tournament_free_room_create_req",
      res = "tournament_free_room_create_rsp",
      handler = "TournamentHandler"
    },
    [1897077134] = {
      res = "tournament_match_status",
      handler = "TournamentHandler"
    },
    [1898346291] = {
      req = "enter_tournament_room_req",
      res = "enter_tournament_room_rsp",
      handler = "TournamentHandler"
    },
    [1920001295] = {
      req = "get_tournaments_req",
      res = "get_tournaments_rsp",
      handler = "TournamentHandler"
    },
    [2006397067] = {
      res = "notify_tournament_score_change",
      handler = "TournamentHandler"
    },
    [1431956199] = {
      req = "tournament_match_req",
      res = "tournament_match_rsp",
      handler = "TournamentMatchHandler"
    },
    [89029447] = {
      req = "metro_buy_ext_bag_capacity_req",
      res = "metro_buy_ext_bag_capacity_rsp",
      handler = "TxMissionBagExtendHandler"
    },
    [6133691] = {
      req = "metro_wipe_insure_req",
      res = "metro_wipe_insure_rsp",
      handler = "TxMissionHandler"
    },
    [8735533] = {
      req = "report_exit_metro_scence",
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [30460487] = {
      req = "metro_npc_gift_req",
      res = "metro_npc_gift_rsp",
      isLock = 1,
      handler = "TxMissionHandler"
    },
    [40828463] = {
      req = "metro_shop_query_label_list_req",
      res = "metro_shop_query_label_list_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [44759998] = {
      res = "sync_metro_shop_ver",
      queueType = 1,
      handler = "TxMissionHandler"
    },
    [58567112] = {
      req = "get_metro_insurance_guide",
      handler = "TxMissionHandler"
    },
    [90858279] = {
      req = "metro_shop_get_label_red_point_req",
      res = "metro_shop_get_label_red_point_rsp",
      handler = "TxMissionHandler"
    },
    [115856086] = {
      res = "metro_shop_ver_notify",
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [139262823] = {
      req = "refine_pve_affix_req",
      res = "refine_pve_affix_rsp",
      handler = "TxMissionHandler"
    },
    [159015463] = {
      req = "metro_affix_read_req",
      res = "metro_affix_read_rsp",
      handler = "TxMissionHandler"
    },
    [169913351] = {
      req = "insure_req",
      res = "insure_rsp",
      handler = "TxMissionHandler"
    },
    [189644851] = {
      res = "notify_prestige_level_change",
      handler = "TxMissionHandler"
    },
    [203743367] = {
      req = "metro_sell_req",
      res = "metro_sell_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [220569188] = {
      req = "report_metro_worth_check_vote_req",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [233278599] = {
      req = "metro_get_season_award_req",
      res = "metro_get_season_award_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [252203815] = {
      req = "metro_collection_receive_achievement_req",
      res = "metro_collection_receive_achievement_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [297791559] = {
      req = "metro_wipe_new_req",
      res = "metro_wipe_new_rsp",
      handler = "TxMissionHandler"
    },
    [305796778] = {
      res = "metro_money_ntfy",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [329773250] = {
      res = "metro_team_guide_unfinished_notify",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [334692882] = {
      res = "metro_task_sync_one",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [341326503] = {
      req = "query_tmode_room_battle_historys_req",
      res = "query_tmode_room_battle_historys_rsp",
      handler = "TxMissionHandler"
    },
    [355231047] = {
      req = "metro_shop_refresh_mystery_req",
      res = "metro_shop_refresh_mystery_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [355636551] = {
      req = "metro_shop_query_user_data_req",
      res = "metro_shop_query_user_data_rsp",
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [431970887] = {
      req = "metro_npc_talk_req",
      res = "metro_npc_talk_rsp",
      isLock = 1,
      handler = "TxMissionHandler"
    },
    [465900767] = {
      req = "uninstall_unbag_items_req",
      res = "uninstall_unbag_items_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [470370095] = {
      res = "metro_affix_new_ntfy",
      handler = "TxMissionHandler"
    },
    [517761287] = {
      res = "metro_collection_notify_new_story",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [565379468] = {
      req = "get_insurance_status",
      res = "get_insurance_status_rsp",
      handler = "TxMissionHandler"
    },
    [602640975] = {
      req = "metro_shop_unlock_mystery_req",
      res = "metro_shop_unlock_mystery_rsp",
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [615540795] = {
      req = "trigger_task_by_cli",
      handler = "TxMissionHandler"
    },
    [618213398] = {
      res = "metro_npc_trigger_plot_notify",
      handler = "TxMissionHandler"
    },
    [667371511] = {
      req = "set_streamer_recommand_suit_req",
      res = "set_streamer_recommand_suit_rsp",
      handler = "TxMissionHandler"
    },
    [737936463] = {
      req = "metro_shop_query_label_info_req",
      res = "metro_shop_query_label_info_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [750752551] = {
      req = "metro_shop_buy_box_req",
      res = "metro_shop_buy_box_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [756639687] = {
      req = "metro_mastery_info_req",
      res = "metro_mastery_info_rsp",
      handler = "TxMissionHandler"
    },
    [810119047] = {
      req = "enter_metro_scence_req",
      res = "enter_metro_scence_rsp",
      isUnique = 1,
      queueType = 1,
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [813559546] = {
      req = "metro_task_npc_gift_req_new",
      handler = "TxMissionHandler"
    },
    [824881835] = {
      req = "uninstall_bag_items_req",
      res = "uninstall_bag_items_rsp",
      handler = "TxMissionHandler"
    },
    [833165399] = {
      req = "metro_mastery_reset_req",
      res = "metro_mastery_reset_rsp",
      handler = "TxMissionHandler"
    },
    [833420855] = {
      req = "metro_take_profit_award_batch_req",
      res = "metro_take_profit_award_batch_rsp",
      handler = "TxMissionHandler"
    },
    [842924151] = {
      req = "metro_trans_team_type_req",
      res = "metro_trans_team_type_rsp",
      timeout = 5,
      timeInterval = 1,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [909326759] = {
      req = "metro_shop_buy_mystery_req",
      res = "metro_shop_buy_mystery_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [919231547] = {
      req = "metro_shop_query_mystery_info_req",
      res = "metro_shop_query_mystery_info_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [937116366] = {
      res = "notify_prestige_change",
      handler = "TxMissionHandler"
    },
    [937825703] = {
      req = "metro_collection_get_achievement_req",
      res = "metro_collection_get_achievement_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1007488551] = {
      req = "metro_mastery_select_req",
      res = "metro_mastery_select_rsp",
      handler = "TxMissionHandler"
    },
    [1015914737] = {
      res = "metro_mastery_ntfy",
      handler = "TxMissionHandler"
    },
    [1020956103] = {
      req = "metro_guide_set_status_req",
      res = "metro_guide_set_status_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1021780967] = {
      req = "metro_shop_get_red_point_req",
      res = "metro_shop_get_red_point_rsp",
      handler = "TxMissionHandler"
    },
    [1109184842] = {
      res = "metro_enter_notify",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1139986344] = {
      req = "get_pve_affix_wait_confirm_req",
      res = "get_pve_affix_wait_confirm_res",
      handler = "TxMissionHandler"
    },
    [1147363975] = {
      req = "metro_collection_get_red_point_req",
      res = "metro_collection_get_red_point_rsp",
      timeInterval = 2,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1208749607] = {
      req = "get_insure_price_req",
      res = "get_insure_price_rsp",
      handler = "TxMissionHandler"
    },
    [1221040448] = {
      res = "metro_npc_effects_sync",
      handler = "TxMissionHandler"
    },
    [1230278727] = {
      req = "metro_shop_receive_mystery_daily_chest_req",
      res = "metro_shop_receive_mystery_daily_chest_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [1231201895] = {
      req = "metro_npc_daily_info_req",
      res = "metro_npc_daily_info_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1235702695] = {
      req = "metro_guide_set_progress_req",
      res = "metro_guide_set_progress_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1253147972] = {
      req = "metro_get_content_by_chestids",
      res = "metro_get_content_by_chestids_rsp",
      handler = "TxMissionHandler"
    },
    [1279350971] = {
      req = "metro_shop_buy_shop_req",
      res = "metro_shop_buy_shop_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1293431335] = {
      req = "metro_open_chest_req",
      res = "metro_open_chest_rsp",
      handler = "TxMissionHandler"
    },
    [1294272964] = {
      res = "on_metro_season_switch_notify",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1325147015] = {
      req = "metro_shop_get_rp_item_req",
      res = "metro_shop_get_rp_item_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [1349418586] = {
      res = "metro_item_change_ntfy",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1370531797] = {
      req = "refine_pve_affix_result_confirm_req",
      res = "refine_pve_affix_confirm_rsp",
      handler = "TxMissionHandler"
    },
    [1376855698] = {
      res = "metro_npc_level_up_notify",
      handler = "TxMissionHandler"
    },
    [1391640995] = {
      res = "notify_military_level_change",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1405606055] = {
      req = "metro_mastery_deploy_req",
      res = "metro_mastery_deploy_rsp",
      handler = "TxMissionHandler"
    },
    [1467198811] = {
      res = "metro_depot_capacity_notify",
      handler = "TxMissionHandler"
    },
    [1477300514] = {
      req = "set_rating_zone_id",
      res = "set_rating_zone_id_notify",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1478913907] = {
      req = "metro_repaire_req",
      res = "metro_repaire_rsp",
      handler = "TxMissionHandler"
    },
    [1518821879] = {
      req = "metro_guide_query_req",
      res = "metro_guide_query_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1530860591] = {
      req = "metro_task_npc_gift_req",
      handler = "TxMissionHandler"
    },
    [1536687259] = {
      req = "exit_metro_scence_req",
      res = "exit_metro_scence_rsp",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1554422279] = {
      req = "get_metro_vs_slots_req",
      res = "get_metro_vs_slots_rsp",
      handler = "TxMissionHandler"
    },
    [1556595111] = {
      req = "set_mastery_tag_id_req",
      res = "set_mastery_tag_id_rsp",
      handler = "TxMissionHandler"
    },
    [1569425701] = {
      req = "report_enter_metro_scence",
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [1604307418] = {
      res = "metro_profit_notify",
      handler = "TxMissionHandler"
    },
    [1604937991] = {
      req = "metro_move_item_req",
      res = "metro_move_item_rsp",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1655826949] = {
      req = "metro_task_sync_all_req",
      res = "metro_task_sync_all",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1722289351] = {
      req = "metro_lbs_rank_req",
      res = "metro_lbs_rank_rsp",
      handler = "TxMissionHandler"
    },
    [1749604762] = {
      res = "notify_metro_activity_banner",
      handler = "TxMissionHandler"
    },
    [1755074343] = {
      req = "metro_collection_get_story_req",
      res = "metro_collection_get_story_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1781807203] = {
      req = "metro_take_profit_award_req",
      res = "metro_take_profit_award_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [1799130663] = {
      req = "metro_batch_repaire_req",
      res = "metro_batch_repaire_rsp",
      handler = "TxMissionHandler"
    },
    [1799655175] = {
      req = "metro_collection_read_story_req",
      res = "metro_collection_read_story_rsp",
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1810231111] = {
      req = "metro_info_req",
      res = "metro_info_rsp",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1815768295] = {
      req = "metro_shop_get_entry_red_point_req",
      res = "metro_shop_get_entry_red_point_rsp",
      handler = "TxMissionHandler"
    },
    [1818320970] = {
      req = "metro_match_req",
      handler = "TxMissionHandler"
    },
    [1893156159] = {
      res = "query_client_metro_scence_status",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1906576482] = {
      req = "metro_shop_remove_label_red_point_req",
      handler = "TxMissionHandler"
    },
    [1925550375] = {
      req = "metro_select_confirm_req",
      res = "metro_select_confirm_rsp",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1938117303] = {
      res = "metro_bag_capacity_ntfy",
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [1940758988] = {
      res = "metro_npc_sync_one",
      handler = "TxMissionHandler"
    },
    [1998753575] = {
      req = "metro_batch_sell_req",
      res = "metro_batch_sell_rsp",
      isLock = 1,
      timeout = 5,
      handler = "TxMissionHandler"
    },
    [2000781447] = {
      req = "build_pve_affix_req",
      res = "build_pve_affix_rsp",
      handler = "TxMissionHandler"
    },
    [2104098439] = {
      req = "metro_task_take_award_req",
      res = "metro_task_take_award_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "TxMissionHandler"
    },
    [2141709743] = {
      req = "report_temporary_mastery_open_req",
      res = "report_temporary_mastery_open_rsp",
      handler = "TxMissionHandler"
    },
    [1174470311] = {
      req = "metro_heirloom_weapon_set_req",
      res = "metro_heirloom_weapon_set_rsp",
      inGameOper = 0,
      handler = "TxMissionHeirloomHandler"
    },
    [1286127307] = {
      req = "gift_metro_item_req",
      res = "gift_metro_item_rsp",
      timeInterval = 1,
      handler = "TxMissionHeirloomHandler"
    },
    [877426343] = {
      req = "get_metro_bag_plan_req",
      res = "get_metro_bag_plan_rsp",
      handler = "TxMissionPresetWarItemHandler"
    },
    [1038941143] = {
      req = "create_metro_bag_plan_req",
      res = "create_metro_bag_plan_rsp",
      handler = "TxMissionPresetWarItemHandler"
    },
    [1971239719] = {
      req = "change_metro_bag_plan_name_req",
      res = "change_metro_bag_plan_name_rsp",
      handler = "TxMissionPresetWarItemHandler"
    },
    [1999101703] = {
      req = "modify_metro_bag_plan_req",
      res = "modify_metro_bag_plan_rsp",
      handler = "TxMissionPresetWarItemHandler"
    },
    [2115867339] = {
      req = "update_bag_of_planx_req",
      res = "update_bag_of_planx_rsp",
      handler = "TxMissionPresetWarItemHandler"
    },
    [260212649] = {
      res = "metro_ach_souvenirs_ntfy",
      handler = "TxMissionSouvenirsHandler"
    },
    [407078044] = {
      res = "metro_achi_task_change_ntfy",
      handler = "TxMissionSouvenirsHandler"
    },
    [435560231] = {
      req = "metro_set_souvenir_invisible_req",
      res = "metro_set_souvenir_invisible_rsp",
      handler = "TxMissionSouvenirsHandler"
    },
    [729176167] = {
      req = "set_t_souvenir_order_req",
      res = "set_t_souvenir_order_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "TxMissionSouvenirsHandler"
    },
    [1808355239] = {
      req = "metro_ach_reward_req",
      res = "metro_ach_reward_rsp",
      handler = "TxMissionSouvenirsHandler"
    },
    [1848064821] = {
      res = "gm_metro_achi_task_change_ntfy",
      handler = "TxMissionSouvenirsHandler"
    },
    [1955237014] = {
      req = "get_t_mode_history_record_summary",
      res = "get_t_mode_history_record_summary_rsp",
      timeInterval = 3,
      handler = "TxmissionHistoryHandler"
    },
    [2001074838] = {
      req = "batch_get_t_mode_history_record",
      res = "batch_get_t_mode_history_record_rsp",
      handler = "TxmissionHistoryHandler"
    },
    [109991] = {
      req = "ugc_llm_chat_stop_req",
      res = "ugc_llm_chat_stop_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [84410131] = {
      req = "ugc_llm_chat_rating_req",
      res = "ugc_llm_chat_rating_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [102513495] = {
      req = "ugc_llm_get_recommend_req",
      res = "ugc_llm_get_recommend_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [330118087] = {
      req = "ugc_llm_report_req",
      res = "ugc_llm_report_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [364292135] = {
      req = "ugc_get_llm_agent_data_req",
      res = "ugc_get_llm_agent_data_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [741294663] = {
      req = "ugc_pass_gencover_get_task_req",
      res = "ugc_pass_gencover_get_task_rsp",
      handler = "UGCAIHandler"
    },
    [753638183] = {
      req = "ugc_llm_get_sessions_req",
      res = "ugc_llm_get_sessions_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [866029667] = {
      req = "ugc_pass_gencover_del_history_req",
      res = "ugc_pass_gencover_del_history_rsp",
      handler = "UGCAIHandler"
    },
    [933364327] = {
      req = "ugc_pass_gencover_set_select_req",
      res = "ugc_pass_gencover_set_select_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [936007527] = {
      req = "ugc_use_llm_card_req",
      res = "ugc_use_llm_card_rsp",
      handler = "UGCAIHandler"
    },
    [1140902951] = {
      req = "llm_generate_image_req",
      res = "llm_generate_image_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [1380469095] = {
      req = "ugc_pass_gencover_add_task_req",
      res = "ugc_pass_gencover_add_task_rsp",
      handler = "UGCAIHandler"
    },
    [1560206887] = {
      req = "ugc_pass_gencover_get_history_req",
      res = "ugc_pass_gencover_get_history_rsp",
      handler = "UGCAIHandler"
    },
    [1667813647] = {
      req = "ugc_pass_gencover_get_user_info_req",
      res = "ugc_pass_gencover_get_user_info_rsp",
      handler = "UGCAIHandler"
    },
    [1843502375] = {
      req = "ugc_llm_one_chat_req",
      res = "ugc_llm_one_chat_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [2108056167] = {
      req = "ugc_llm_chat_message_req",
      res = "ugc_llm_chat_message_rsp",
      inGameOper = 0,
      handler = "UGCAIHandler"
    },
    [74129639] = {
      req = "ugc_crystal_withdraw_req",
      res = "ugc_crystal_withdraw_rsp",
      handler = "UGCAuthorHandler"
    },
    [154125639] = {
      req = "ugc_get_other_user_pub_mod_req",
      res = "ugc_get_other_user_pub_mod_rsp",
      handler = "UGCAuthorHandler"
    },
    [162264635] = {
      req = "ugc_player_update_follow_list_req",
      res = "ugc_player_update_follow_list_rsp",
      inGameOper = 0,
      handler = "UGCAuthorHandler"
    },
    [185937331] = {
      req = "wow_support_author_homepage_req",
      res = "wow_support_author_homepage_rsp",
      handler = "UGCAuthorHandler"
    },
    [236270663] = {
      req = "ugc_crystal_benefit_details_req",
      res = "ugc_crystal_benefit_details_rsp",
      handler = "UGCAuthorHandler"
    },
    [335043481] = {
      res = "ugc_frd_game_result_notify",
      handler = "UGCAuthorHandler"
    },
    [338224767] = {
      req = "wow_get_author_homepage_support_count_req",
      res = "wow_get_author_homepage_support_count_rsp",
      handler = "UGCAuthorHandler"
    },
    [372711143] = {
      req = "ugc_get_other_all_meta_key_req",
      res = "ugc_get_other_all_meta_key_rsp",
      handler = "UGCAuthorHandler"
    },
    [392041067] = {
      req = "ugc_author_level_get_award_info_req",
      res = "ugc_author_level_get_award_info_rsp",
      handler = "UGCAuthorHandler"
    },
    [526629651] = {
      req = "wow_author_push_audit_req",
      res = "wow_author_push_audit_rsp",
      handler = "UGCAuthorHandler"
    },
    [565403367] = {
      req = "ugc_play_level_get_award_info_req",
      res = "ugc_play_level_get_award_info_rsp",
      handler = "UGCAuthorHandler"
    },
    [687533127] = {
      req = "ugc_author_summary_req",
      res = "ugc_author_summary_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCAuthorHandler"
    },
    [724056423] = {
      req = "ugc_friend_v2_realtime_req",
      res = "ugc_friend_v2_realtime_rsp",
      handler = "UGCAuthorHandler"
    },
    [766079527] = {
      req = "ugc_get_friend_author_meta_key_req",
      res = "ugc_get_friend_author_meta_key_rsp",
      handler = "UGCAuthorHandler"
    },
    [816980223] = {
      req = "wow_get_author_homepage_req",
      res = "wow_get_author_homepage_rsp",
      handler = "UGCAuthorHandler"
    },
    [977707047] = {
      req = "ugc_play_level_award_req",
      res = "ugc_play_level_award_rsp",
      handler = "UGCAuthorHandler"
    },
    [1032014503] = {
      req = "ugc_clear_author_progress_notify_req",
      res = "ugc_clear_author_progress_notify_rsp",
      inGameOper = 0,
      handler = "UGCAuthorHandler"
    },
    [1101744411] = {
      req = "ugc_crystal_get_balance_req",
      res = "ugc_crystal_get_balance_rsp",
      handler = "UGCAuthorHandler"
    },
    [1160579843] = {
      req = "ugc_author_level_ex_award_req",
      res = "ugc_author_level_ex_award_rsp",
      isLock = 1,
      timeout = 10,
      handler = "UGCAuthorHandler"
    },
    [1192823047] = {
      req = "ugc_author_level_award_req",
      res = "ugc_author_level_award_rsp",
      isLock = 1,
      timeout = 10,
      handler = "UGCAuthorHandler"
    },
    [1200406823] = {
      req = "ugc_get_other_follow_author_list_req",
      res = "ugc_get_other_follow_author_list_rsp",
      handler = "UGCAuthorHandler"
    },
    [1241712967] = {
      req = "ugc_get_general_button_switch_req",
      res = "ugc_get_general_button_switch_rsp",
      inGameOper = 0,
      handler = "UGCAuthorHandler"
    },
    [1245918695] = {
      req = "wow_modify_author_homepage_req",
      res = "wow_modify_author_homepage_rsp",
      handler = "UGCAuthorHandler"
    },
    [1311515271] = {
      req = "ugc_author_level_get_ex_award_info_req",
      res = "ugc_author_level_get_ex_award_info_rsp",
      handler = "UGCAuthorHandler"
    },
    [1311918951] = {
      req = "ugc_crystal_benefit_overview_req",
      res = "ugc_crystal_benefit_overview_rsp",
      handler = "UGCAuthorHandler"
    },
    [1406584519] = {
      req = "ugc_get_author_req",
      res = "ugc_get_author_rsp",
      timeInterval = 0.7,
      inGameOper = 0,
      handler = "UGCAuthorHandler"
    },
    [1436180919] = {
      req = "ugc_get_player_follow_author_list_req",
      res = "ugc_get_player_follow_author_list_rsp",
      handler = "UGCAuthorHandler"
    },
    [1441983495] = {
      req = "ugc_apply_crystal_incentive_req",
      res = "ugc_apply_crystal_incentive_rsp",
      handler = "UGCAuthorHandler"
    },
    [1593270567] = {
      req = "ugc_crystal_exchange_req",
      res = "ugc_crystal_exchange_rsp",
      handler = "UGCAuthorHandler"
    },
    [1688205415] = {
      req = "wow_get_author_homepage_support_info_req",
      res = "wow_get_author_homepage_support_info_rsp",
      handler = "UGCAuthorHandler"
    },
    [1723471623] = {
      req = "ugc_get_follow_author_meta_key_req",
      res = "ugc_get_follow_author_meta_key_rsp",
      handler = "UGCAuthorHandler"
    },
    [1815520379] = {
      req = "ugc_get_author_progress_req",
      res = "ugc_get_author_progress_rsp",
      inGameOper = 0,
      handler = "UGCAuthorHandler"
    },
    [1938026340] = {
      res = "ugc_play_level_ntf",
      handler = "UGCAuthorHandler"
    },
    [1959391815] = {
      res = "notify_author_data_change",
      handler = "UGCAuthorHandler"
    },
    [2011588967] = {
      req = "ugc_display_friend_req",
      res = "ugc_display_friend_rsp",
      handler = "UGCAuthorHandler"
    },
    [2098475287] = {
      req = "ugc_mod_crystal_benefit_req",
      res = "ugc_mod_crystal_benefit_rsp",
      handler = "UGCAuthorHandler"
    },
    [9064699] = {
      req = "load_pub_prefab_id_list_req",
      res = "load_pub_prefab_id_list_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [47036071] = {
      req = "ugc_buy_mod_item_req",
      res = "ugc_buy_mod_item_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [59409627] = {
      req = "ugc_join_review_panel_req",
      res = "ugc_join_review_panel_rsp",
      handler = "UGCHandler"
    },
    [80555559] = {
      req = "ugc_review_panel_del_comment_req",
      res = "ugc_review_panel_del_comment_rsp",
      handler = "UGCHandler"
    },
    [119965647] = {
      req = "ugc_take_review_panel_award_req",
      res = "ugc_take_review_panel_award_rsp",
      handler = "UGCHandler"
    },
    [120914695] = {
      req = "ugc_review_panel_del_reply_comment_req",
      res = "ugc_review_panel_del_reply_comment_rsp",
      handler = "UGCHandler"
    },
    [128588251] = {
      req = "ugc_get_auto_translate_switch_req",
      res = "ugc_get_auto_translate_switch_rsp",
      handler = "UGCHandler"
    },
    [179695783] = {
      req = "ugc_get_mod_item_req",
      res = "ugc_get_mod_item_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [182263927] = {
      req = "batch_load_pub_prefab_meta_data_req",
      res = "batch_load_pub_prefab_meta_data_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [183877293] = {
      res = "notify_update_private_prefab_status",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [196574535] = {
      req = "wow_get_upload_file_limits_req",
      res = "wow_get_upload_file_limits_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [228817335] = {
      req = "ugc_take_season_award_req",
      res = "ugc_take_season_award_rsp",
      handler = "UGCHandler"
    },
    [287063563] = {
      req = "wow_get_my_private_prefab_bin_req",
      res = "wow_get_my_private_prefab_bin_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [326027047] = {
      req = "wow_good_mod_of_template_req",
      res = "wow_good_mod_of_template_rsp",
      handler = "UGCHandler"
    },
    [378185479] = {
      req = "ugc_review_panel_reply_comment_req",
      res = "ugc_review_panel_reply_comment_rsp",
      handler = "UGCHandler"
    },
    [390085955] = {
      req = "ugc_exit_review_panel_req",
      res = "ugc_exit_review_panel_rsp",
      handler = "UGCHandler"
    },
    [447813991] = {
      req = "free_inout_enter_req",
      res = "free_inout_enter_rsp",
      handler = "UGCHandler"
    },
    [477134279] = {
      req = "ugc_get_review_panel_info_req",
      res = "ugc_get_review_panel_info_rsp",
      handler = "UGCHandler"
    },
    [501174483] = {
      req = "wow_is_upload_local_file_open_req",
      res = "wow_is_upload_local_file_open_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [552070151] = {
      req = "ugc_get_review_panel_comment_info_req",
      res = "ugc_get_review_panel_comment_info_rsp",
      handler = "UGCHandler"
    },
    [565092775] = {
      req = "load_pub_prefab_bin_data_req",
      res = "load_pub_prefab_bin_data_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [569326183] = {
      req = "wow_batch_delete_private_prefab_req",
      res = "wow_batch_delete_private_prefab_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [601019623] = {
      req = "get_ugc_comm_cfg_req",
      res = "get_ugc_comm_cfg_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [678266499] = {
      req = "ugc_share_pub_mod_req",
      res = "ugc_share_pub_mod_rsp",
      handler = "UGCHandler"
    },
    [736049579] = {
      req = "ugc_set_auto_translate_switch_req",
      res = "ugc_set_auto_translate_switch_rsp",
      handler = "UGCHandler"
    },
    [776183079] = {
      req = "ugc_review_panel_support_comment_req",
      res = "ugc_review_panel_support_comment_rsp",
      handler = "UGCHandler"
    },
    [798144107] = {
      req = "free_inout_invite_req",
      res = "free_inout_invite_rsp",
      handler = "UGCHandler"
    },
    [809462259] = {
      req = "ugc_get_is_open_req",
      res = "ugc_get_is_open_rsp",
      timeInterval = 1,
      handler = "UGCHandler"
    },
    [823928423] = {
      req = "ugc_lobby_text_filter_req",
      res = "ugc_lobby_text_filter_rsp",
      handler = "UGCHandler"
    },
    [849734095] = {
      req = "ugc_translate_batch_req",
      res = "ugc_translate_batch_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [865743795] = {
      req = "wow_delete_private_prefab_req",
      res = "wow_delete_private_prefab_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [868466455] = {
      req = "wow_get_my_private_prefab_meta_list_req",
      res = "wow_get_my_private_prefab_meta_list_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [893843047] = {
      req = "ugc_share_task_receive_award_req",
      res = "ugc_share_task_receive_award_rsp",
      handler = "UGCHandler"
    },
    [912227943] = {
      req = "ugc_set_privacy_req",
      res = "ugc_set_privacy_rsp",
      handler = "UGCHandler"
    },
    [914772027] = {
      req = "ugc_report_rec_mod_view_req",
      res = "ugc_report_rec_mod_view_rsp",
      handler = "UGCHandler"
    },
    [921688835] = {
      req = "ugc_report_promotion_view_req",
      res = "ugc_report_promotion_view_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [926609383] = {
      req = "ugc_author_line_chart_req",
      res = "ugc_author_line_chart_rsp",
      timeInterval = 1,
      handler = "UGCHandler"
    },
    [933714919] = {
      req = "ugc_review_panel_comment_req",
      res = "ugc_review_panel_comment_rsp",
      handler = "UGCHandler"
    },
    [935380667] = {
      req = "wow_upload_private_prefab_req",
      res = "wow_upload_private_prefab_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [974559207] = {
      req = "ugc_play_hall_filter_req",
      res = "ugc_play_hall_filter_rsp",
      handler = "UGCHandler"
    },
    [986636327] = {
      req = "ugc_general_report_req",
      res = "ugc_general_report_rsp",
      handler = "UGCHandler"
    },
    [1016077927] = {
      req = "ugc_report_map_comment_video_req",
      res = "ugc_report_map_comment_video_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1056367879] = {
      req = "update_old_private_prefab_meta_req",
      res = "update_old_private_prefab_meta_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1091417287] = {
      req = "mark_recommend_ugc_req",
      res = "mark_recommend_ugc_rsp",
      handler = "UGCHandler"
    },
    [1091503271] = {
      req = "wow_modify_private_prefab_meta_req",
      res = "wow_modify_private_prefab_meta_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1178576819] = {
      req = "ugc_share_task_get_progress_req",
      res = "ugc_share_task_get_progress_rsp",
      handler = "UGCHandler"
    },
    [1206305895] = {
      req = "ugc_play_hall_quick_join_req",
      res = "ugc_play_hall_quick_join_rsp",
      handler = "UGCHandler"
    },
    [1257838439] = {
      req = "ugc_promotion_record_req",
      res = "ugc_promotion_record_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1271528295] = {
      req = "free_inout_apply_req",
      res = "free_inout_apply_rsp",
      handler = "UGCHandler"
    },
    [1285545127] = {
      req = "ugc_get_match_history_req",
      res = "ugc_get_match_history_rsp",
      handler = "UGCHandler"
    },
    [1411922151] = {
      req = "batch_get_play_hall_info_req",
      res = "batch_get_play_hall_info_rsp",
      handler = "UGCHandler"
    },
    [1420766819] = {
      req = "ugc_get_my_match_list_req",
      res = "ugc_get_my_match_list_rsp",
      handler = "UGCHandler"
    },
    [1423455159] = {
      req = "ugc_get_season_award_list_req",
      res = "ugc_get_season_award_list_rsp",
      handler = "UGCHandler"
    },
    [1446367719] = {
      req = "batch_take_wow_play_activity_award_req",
      res = "batch_take_wow_play_activity_award_rsp",
      handler = "UGCHandler"
    },
    [1449236263] = {
      req = "ugc_use_mod_item_req",
      res = "ugc_use_mod_item_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1451955623] = {
      req = "ugc_debug_id_cfg_req",
      res = "ugc_debug_id_cfg_rsp",
      needRsp = 3,
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1508814714] = {
      res = "free_inout_invite_notify",
      handler = "UGCHandler"
    },
    [1547639207] = {
      req = "ugc_promotion_use_item_req",
      res = "ugc_promotion_use_item_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1570371687] = {
      req = "ugc_get_random_rec_req",
      res = "ugc_get_random_rec_rsp",
      inGameOper = 2,
      handler = "UGCHandler"
    },
    [1592357831] = {
      req = "ugc_get_review_history_req",
      res = "ugc_get_review_history_rsp",
      handler = "UGCHandler"
    },
    [1594233271] = {
      req = "wow_query_newbie_guide_data_req",
      res = "wow_query_newbie_guide_data_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1670355315] = {
      req = "ugc_aws_presigned_url_batch_req",
      res = "ugc_aws_presigned_url_batch_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1786144039] = {
      req = "ugc_get_match_offline_data_req",
      res = "ugc_get_match_offline_data_rsp",
      handler = "UGCHandler"
    },
    [1800651559] = {
      req = "ugc_review_panel_top_comment_req",
      res = "ugc_review_panel_top_comment_rsp",
      handler = "UGCHandler"
    },
    [1827106347] = {
      req = "ugc_exchange_advanced_crystal_by_uc_req",
      res = "ugc_exchange_advanced_crystal_by_uc_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [1980359179] = {
      req = "ugc_translate_req",
      res = "ugc_translate_rsp",
      handler = "UGCHandler"
    },
    [2034706663] = {
      req = "ugc_llm_chat_save_report_req",
      res = "ugc_llm_chat_save_report_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [2038486335] = {
      req = "ugc_query_map_comment_video_report_status_req",
      res = "ugc_query_map_comment_video_report_status_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [2090017651] = {
      req = "ugc_report_item_req",
      res = "ugc_report_item_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [2112830347] = {
      req = "wow_upload_local_file_req",
      res = "wow_upload_local_file_rsp",
      inGameOper = 0,
      handler = "UGCHandler"
    },
    [2122233299] = {
      req = "ugc_get_template_list_req",
      res = "ugc_get_template_list_rsp",
      timeInterval = 2,
      inGameOper = 2,
      handler = "UGCHandler"
    },
    [88287751] = {
      req = "ugc_team_download_captain_slot_req",
      res = "ugc_team_download_captain_slot_rsp",
      handler = "UGCMatchHandler"
    },
    [472114203] = {
      res = "ugc_choose_mod_no_map_uids_notify",
      handler = "UGCMatchHandler"
    },
    [474395895] = {
      req = "ugc_join_play_hall_room_req",
      res = "ugc_join_play_hall_room_rsp",
      handler = "UGCMatchHandler"
    },
    [616905722] = {
      req = "ugc_ph_room_quick_chat_req",
      handler = "UGCMatchHandler"
    },
    [671148455] = {
      req = "ugc_ph_recruit_req",
      res = "ugc_ph_recruit_rsp",
      handler = "UGCMatchHandler"
    },
    [681194095] = {
      req = "ugc_member_reply_download_asset_req",
      res = "ugc_member_reply_download_asset_rsp",
      handler = "UGCMatchHandler"
    },
    [856087091] = {
      req = "ugc_play_hall_room_invite_req",
      res = "ugc_play_hall_room_invite_rsp",
      handler = "UGCMatchHandler"
    },
    [975186635] = {
      req = "start_ugc_novice_game_req",
      res = "start_ugc_novice_game_rsp",
      isUnique = 1,
      timeInterval = 1,
      handler = "UGCMatchHandler"
    },
    [1515154983] = {
      req = "ugc_nofity_custom_asset_info_req",
      res = "ugc_nofity_custom_asset_info_rsp",
      handler = "UGCMatchHandler"
    },
    [1564778638] = {
      res = "ugc_play_hall_room_invite_notify",
      handler = "UGCMatchHandler"
    },
    [1658747495] = {
      res = "notify_play_hall_room_info",
      handler = "UGCMatchHandler"
    },
    [1832412223] = {
      req = "ugc_ph_room_quick_start_req",
      res = "ugc_ph_room_quick_start_rsp",
      handler = "UGCMatchHandler"
    },
    [1991148319] = {
      req = "ugc_exit_play_hall_room_req",
      res = "ugc_exit_play_hall_room_rsp",
      handler = "UGCMatchHandler"
    },
    [2063618543] = {
      req = "ugc_my_play_hall_room_req",
      res = "ugc_my_play_hall_room_rsp",
      handler = "UGCMatchHandler"
    },
    [53549095] = {
      req = "ugc_collect_mod_req",
      res = "ugc_collect_mod_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [92058279] = {
      req = "ugc_report_uni_mod_interactive_req",
      res = "ugc_report_uni_mod_interactive_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [196317671] = {
      req = "ugc_choose_mod_for_match_req",
      res = "ugc_choose_mod_for_match_rsp",
      handler = "UGCModHandler"
    },
    [386466759] = {
      req = "ugc_delete_mod_req",
      res = "ugc_delete_mod_rsp",
      queueType = 1,
      handler = "UGCModHandler"
    },
    [398902919] = {
      req = "set_ugc_mod_bundle_req",
      res = "set_ugc_mod_bundle_rsp",
      timeInterval = 2,
      handler = "UGCModHandler"
    },
    [513936455] = {
      req = "ugc_cancel_like_mod_collection_req",
      res = "ugc_cancel_like_mod_collection_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [523930375] = {
      req = "get_ugc_mod_bundle_req",
      res = "get_ugc_mod_bundle_rsp",
      timeInterval = 2,
      handler = "UGCModHandler"
    },
    [616595271] = {
      req = "ugc_pub_mod_info_batch_req",
      res = "ugc_pub_mod_info_batch_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [727376551] = {
      req = "ugc_pub_mod_vote_req",
      res = "ugc_pub_mod_vote_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [767853243] = {
      req = "ugc_duplicate_mod_req",
      res = "ugc_duplicate_mod_rsp",
      queueType = 1,
      timeInterval = 10,
      handler = "UGCModHandler"
    },
    [781656039] = {
      req = "ugc_collect_look_req",
      res = "ugc_collect_look_rsp",
      handler = "UGCModHandler"
    },
    [807776652] = {
      req = "ugc_report_map_req",
      res = "ugc_report_map_req_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [809468199] = {
      req = "ugc_cancel_publish_mod_req",
      res = "ugc_cancel_publish_mod_rsp",
      queueType = 1,
      handler = "UGCModHandler"
    },
    [826845879] = {
      req = "ugc_query_map_report_status_req",
      res = "ugc_query_map_report_status_rsp",
      handler = "UGCModHandler"
    },
    [913065987] = {
      req = "ugc_create_pub_mod_collection_req",
      res = "ugc_create_pub_mod_collection_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [965725968] = {
      req = "ugc_refresh_mod_collection_picurl_req",
      isUnique = 1,
      timeInterval = 60,
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [973232987] = {
      req = "ugc_get_last_game_req",
      res = "ugc_get_last_game_rsp",
      handler = "UGCModHandler"
    },
    [982888423] = {
      req = "ugc_insert_map_into_mod_collection_req",
      res = "ugc_insert_map_into_mod_collection_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1003146535] = {
      req = "ugc_modify_mod_meta_req",
      res = "ugc_modify_mod_meta_rsp",
      queueType = 1,
      handler = "UGCModHandler"
    },
    [1034915967] = {
      req = "ugc_delete_pub_mod_collection_req",
      res = "ugc_delete_pub_mod_collection_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1142855559] = {
      req = "ugc_delete_pub_mod_req",
      res = "ugc_delete_pub_mod_rsp",
      queueType = 1,
      handler = "UGCModHandler"
    },
    [1234447547] = {
      req = "start_ugc_edit_game_req",
      res = "start_ugc_edit_game_rsp",
      isUnique = 1,
      timeInterval = 4,
      handler = "UGCModHandler"
    },
    [1234627847] = {
      req = "ugc_match_stat_req",
      res = "ugc_match_stat_rsp",
      queueType = 1,
      timeout = 10,
      handler = "UGCModHandler"
    },
    [1248666655] = {
      req = "ugc_get_modlist_req",
      res = "ugc_get_modlist_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1270451175] = {
      req = "ugc_report_mod_collection_statistics_req",
      res = "ugc_report_mod_collection_statistics_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1293001039] = {
      req = "ugc_set_share_mod_req",
      res = "ugc_set_share_mod_rsp",
      handler = "UGCModHandler"
    },
    [1321607079] = {
      req = "ugc_mod_collection_report_data_req",
      res = "ugc_mod_collection_report_data_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1423048743] = {
      req = "ugc_cancel_like_mod_req",
      res = "ugc_cancel_like_mod_rsp",
      handler = "UGCModHandler"
    },
    [1449418727] = {
      req = "ugc_create_mod_req",
      res = "ugc_create_mod_rsp",
      isUnique = 1,
      timeInterval = 8,
      handler = "UGCModHandler"
    },
    [1473101735] = {
      req = "ugc_like_mod_req",
      res = "ugc_like_mod_rsp",
      handler = "UGCModHandler"
    },
    [1496680583] = {
      req = "ugc_query_mod_vote_req",
      res = "ugc_query_mod_vote_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1516011083] = {
      req = "ugc_duplicate_pub_mod_req",
      res = "ugc_duplicate_pub_mod_rsp",
      queueType = 1,
      timeInterval = 10,
      handler = "UGCModHandler"
    },
    [1528212295] = {
      req = "ugc_get_mod_collection_list_req",
      res = "ugc_get_mod_collection_list_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1556411751] = {
      req = "ugc_delete_map_from_mod_collection_req",
      res = "ugc_delete_map_from_mod_collection_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1641100527] = {
      req = "ugc_multi_match_req",
      res = "ugc_multi_match_rsp",
      timeInterval = 2,
      inGameOper = 2,
      handler = "UGCModHandler"
    },
    [1733399335] = {
      req = "ugc_author_stick_mod_req",
      res = "ugc_author_stick_mod_rsp",
      handler = "UGCModHandler"
    },
    [1826627299] = {
      req = "ugc_publish_mod_req",
      res = "ugc_publish_mod_rsp",
      queueType = 1,
      timeInterval = 5,
      handler = "UGCModHandler"
    },
    [1842020231] = {
      req = "ugc_cancel_collect_mod_req",
      res = "ugc_cancel_collect_mod_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1854741255] = {
      req = "ugc_mod_template_recommend_req",
      res = "ugc_mod_template_recommend_rsp",
      handler = "UGCModHandler"
    },
    [1859379903] = {
      req = "ugc_report_uni_mod_expose_req",
      res = "ugc_report_uni_mod_expose_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1863140715] = {
      req = "ugc_batch_get_mod_collection_data_req",
      res = "ugc_batch_get_mod_collection_data_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1864711084] = {
      req = "update_client_mod_info",
      res = "update_client_mod_info_rsp",
      handler = "UGCModHandler"
    },
    [1900656871] = {
      req = "ugc_mod_version_rollback_req",
      res = "ugc_mod_version_rollback_rsp",
      timeInterval = 1,
      handler = "UGCModHandler"
    },
    [1976187943] = {
      req = "ugc_get_pub_meta_req",
      res = "ugc_get_pub_meta_rsp",
      handler = "UGCModHandler"
    },
    [1983531911] = {
      req = "ugc_modify_mod_collection_meta_req",
      res = "ugc_modify_mod_collection_meta_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [1993366951] = {
      req = "ugc_mod_hot_stat_req",
      res = "ugc_mod_hot_stat_rsp",
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [2038622279] = {
      req = "ugc_like_mod_collection_req",
      res = "ugc_like_mod_collection_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCModHandler"
    },
    [2061137127] = {
      req = "ugc_toggle_publish_state_req",
      res = "ugc_toggle_publish_state_rsp",
      handler = "UGCModHandler"
    },
    [14145895] = {
      req = "ugc_self_creative_info_req",
      res = "ugc_self_creative_info_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [26867471] = {
      req = "ugc_pass_get_info_req",
      res = "ugc_pass_get_info_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [57727083] = {
      req = "ugc_pass_enter_redpoint_req",
      res = "ugc_pass_enter_redpoint_rsp",
      handler = "UGCPassHandler"
    },
    [61730013] = {
      res = "ugc_pass_score_change_notify",
      handler = "UGCPassHandler"
    },
    [94512871] = {
      req = "ugc_task_receive_all_rewards_req",
      res = "ugc_task_receive_all_rewards_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [110665575] = {
      res = "ugc_pass_task_status_change_notify",
      handler = "UGCPassHandler"
    },
    [211358442] = {
      req = "ugc_wowpass_task_rsperror_tlog_req",
      handler = "UGCPassHandler"
    },
    [252121387] = {
      res = "notify_update_wow_incentive_program_data",
      handler = "UGCPassHandler"
    },
    [274534131] = {
      req = "ugc_take_one_season_award_req",
      res = "ugc_take_one_season_award_rsp",
      handler = "UGCPassHandler"
    },
    [307181991] = {
      req = "ugc_season_take_exchange_by_id_req",
      res = "ugc_season_take_exchange_by_id_rsp",
      handler = "UGCPassHandler"
    },
    [314091815] = {
      req = "ugc_pass_get_level_award_req",
      res = "ugc_pass_get_level_award_rsp",
      handler = "UGCPassHandler"
    },
    [349029223] = {
      req = "ugc_personal_setting_set_req",
      res = "ugc_personal_setting_set_rsp",
      handler = "UGCPassHandler"
    },
    [364438643] = {
      req = "wow_get_incentive_program_revenue_req",
      res = "wow_get_incentive_program_revenue_rsp",
      handler = "UGCPassHandler"
    },
    [369808167] = {
      req = "ugc_pass_get_all_level_award_req",
      res = "ugc_pass_get_all_level_award_rsp",
      handler = "UGCPassHandler"
    },
    [427308157] = {
      res = "ugc_daily_task_sync",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [436423959] = {
      req = "ugc_pass_open_check_req",
      res = "ugc_pass_open_check_rsp",
      handler = "UGCPassHandler"
    },
    [475107651] = {
      req = "wow_get_IPR_des_cfg_req",
      res = "wow_get_IPR_des_cfg_rsp",
      handler = "UGCPassHandler"
    },
    [536411303] = {
      req = "ugc_pass_buy_guide_req",
      res = "ugc_pass_buy_guide_rsp",
      handler = "UGCPassHandler"
    },
    [540681575] = {
      req = "ugc_pass_buy_level_req",
      res = "ugc_pass_buy_level_rsp",
      handler = "UGCPassHandler"
    },
    [575013847] = {
      req = "wow_get_incentive_program_award_req",
      res = "wow_get_incentive_program_award_rsp",
      handler = "UGCPassHandler"
    },
    [664176583] = {
      req = "wow_query_incentive_program_join_state_req",
      res = "wow_query_incentive_program_join_state_rsp",
      handler = "UGCPassHandler"
    },
    [667407911] = {
      req = "ugc_buy_pass_req",
      res = "ugc_buy_pass_rsp",
      handler = "UGCPassHandler"
    },
    [715938471] = {
      req = "ugc_daily_task_get_award_req",
      res = "ugc_daily_task_get_award_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [732330855] = {
      req = "ugc_personal_setting_get_req",
      res = "ugc_personal_setting_get_rsp",
      handler = "UGCPassHandler"
    },
    [773102695] = {
      req = "ugc_season_get_exchange_list_req",
      res = "ugc_season_get_exchange_list_rsp",
      timeInterval = 1,
      handler = "UGCPassHandler"
    },
    [813288487] = {
      req = "ugc_creative_level_award_req",
      res = "ugc_creative_level_award_rsp",
      handler = "UGCPassHandler"
    },
    [870428199] = {
      req = "ugc_wallet_withdrawal_req",
      res = "ugc_wallet_withdrawal_rsp",
      handler = "UGCPassHandler"
    },
    [906321963] = {
      req = "ugc_wallet_get_benefit_overview_req",
      res = "ugc_wallet_get_benefit_overview_rsp",
      handler = "UGCPassHandler"
    },
    [989985959] = {
      req = "ugc_pass_get_all_task_reward_req",
      res = "ugc_pass_get_all_task_reward_rsp",
      handler = "UGCPassHandler"
    },
    [999566055] = {
      req = "wow_get_author_revenue_req",
      res = "wow_get_author_revenue_rsp",
      handler = "UGCPassHandler"
    },
    [1132089843] = {
      req = "ugc_pass_get_static_season_info_req",
      res = "ugc_pass_get_static_season_info_rsp",
      handler = "UGCPassHandler"
    },
    [1216788967] = {
      req = "ugc_daily_task_refresh_req",
      res = "ugc_daily_task_refresh_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [1302344423] = {
      req = "ugc_pass_get_current_task_status_req",
      res = "ugc_pass_get_current_task_status_rsp",
      handler = "UGCPassHandler"
    },
    [1321236775] = {
      req = "ugc_pass_record_info_req",
      res = "ugc_pass_record_info_rsp",
      handler = "UGCPassHandler"
    },
    [1348849101] = {
      res = "ugc_pass_level_reward_status_notify",
      handler = "UGCPassHandler"
    },
    [1366949991] = {
      req = "wow_apply_join_incentive_program_req",
      res = "wow_apply_join_incentive_program_rsp",
      handler = "UGCPassHandler"
    },
    [1376407539] = {
      req = "ugc_weekly_active_award_req",
      res = "ugc_weekly_active_award_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [1376775751] = {
      req = "ugc_daily_task_complete_imm_req",
      res = "ugc_daily_task_complete_imm_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [1380228359] = {
      req = "wow_get_new_author_inspire_req",
      res = "wow_get_new_author_inspire_rsp",
      handler = "UGCPassHandler"
    },
    [1405594407] = {
      req = "ugc_pass_get_task_reward_req",
      res = "ugc_pass_get_task_reward_rsp",
      handler = "UGCPassHandler"
    },
    [1442905447] = {
      req = "ugc_wallet_get_benefit_details_req",
      res = "ugc_wallet_get_benefit_details_rsp",
      handler = "UGCPassHandler"
    },
    [1497643167] = {
      req = "ugc_other_creative_info_req",
      res = "ugc_other_creative_info_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [1579653671] = {
      req = "wow_get_IPR_rank_history_req",
      res = "wow_get_IPR_rank_history_rsp",
      handler = "UGCPassHandler"
    },
    [1650262695] = {
      req = "ugc_daily_task_get_task_data_req",
      res = "ugc_daily_task_get_task_data_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [1677009767] = {
      req = "ugc_pass_finish_task_by_card_req",
      res = "ugc_pass_finish_task_by_card_rsp",
      handler = "UGCPassHandler"
    },
    [1694086780] = {
      res = "ugc_weekly_active_sync",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [1704913123] = {
      req = "wow_query_incentive_program_task_data_req",
      res = "wow_query_incentive_program_task_data_rsp",
      handler = "UGCPassHandler"
    },
    [1705726535] = {
      req = "ugc_get_season_rating_add_records_req",
      res = "ugc_get_season_rating_add_records_rsp",
      timeInterval = 1,
      handler = "UGCPassHandler"
    },
    [1737259111] = {
      req = "ugc_wallet_get_balance_req",
      res = "ugc_wallet_get_balance_rsp",
      handler = "UGCPassHandler"
    },
    [1937943868] = {
      res = "ugc_pass_has_reward_notify",
      handler = "UGCPassHandler"
    },
    [2024847375] = {
      req = "ugc_daily_task_batch_get_reward_req",
      res = "ugc_daily_task_batch_get_reward_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [2045402599] = {
      req = "wow_get_revenue_rank_req",
      res = "wow_get_revenue_rank_rsp",
      handler = "UGCPassHandler"
    },
    [2070218343] = {
      req = "wow_get_IPR_rank_req",
      res = "wow_get_IPR_rank_rsp",
      handler = "UGCPassHandler"
    },
    [2118417171] = {
      req = "ugc_pass_get_buy_info_req",
      res = "ugc_pass_get_buy_info_rsp",
      inGameOper = 0,
      handler = "UGCPassHandler"
    },
    [1934535] = {
      req = "save_cwow_mission_data_req",
      res = "save_cwow_mission_data_rsp",
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [63161707] = {
      req = "ugc_exchange_mall_exchange_item_req",
      res = "ugc_exchange_mall_exchange_item_rsp",
      isLock = 1,
      timeout = 10,
      handler = "UGCPublishHandler"
    },
    [84044263] = {
      req = "ugc_creator_refresh_task_req",
      res = "ugc_creator_refresh_task_rsp",
      handler = "UGCPublishHandler"
    },
    [173640999] = {
      req = "ugc_get_tutorial_extra_award_req",
      res = "ugc_get_tutorial_extra_award_rsp",
      handler = "UGCPublishHandler"
    },
    [174744859] = {
      req = "ugc_tutorial_version_select_req",
      res = "ugc_tutorial_version_select_rsp",
      handler = "UGCPublishHandler"
    },
    [495644903] = {
      req = "wow_collect_pub_prefab_req",
      res = "wow_collect_pub_prefab_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [514025003] = {
      req = "ugc_upload_custom_pic_req",
      res = "ugc_upload_custom_pic_rsp",
      handler = "UGCPublishHandler"
    },
    [515271271] = {
      req = "ugc_delete_mod_album_req",
      res = "ugc_delete_mod_album_rsp",
      handler = "UGCPublishHandler"
    },
    [597737735] = {
      req = "wow_offline_pub_prefab_req",
      res = "wow_offline_pub_prefab_rsp",
      timeInterval = 3,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [666661595] = {
      req = "ugc_get_mod_offline_bm_data_req",
      res = "ugc_get_mod_offline_bm_data_rsp",
      timeInterval = 1,
      handler = "UGCPublishHandler"
    },
    [681695847] = {
      req = "wow_get_user_prefab_summary_data_req",
      res = "wow_get_user_prefab_summary_data_rsp",
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [685169351] = {
      req = "ugc_creator_receive_task_award_req",
      res = "ugc_creator_receive_task_award_rsp",
      handler = "UGCPublishHandler"
    },
    [686232135] = {
      req = "get_cwow_mission_data_req",
      res = "get_cwow_mission_data_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [928282067] = {
      req = "wow_prefab_tab_show_req",
      res = "wow_prefab_tab_show_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [967124743] = {
      req = "ugc_creator_receive_tab_task_award_req",
      res = "ugc_creator_receive_tab_task_award_rsp",
      handler = "UGCPublishHandler"
    },
    [1023743399] = {
      req = "wow_delete_pub_custom_prefab_req",
      res = "wow_delete_pub_custom_prefab_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1028434859] = {
      req = "wow_publish_custom_prefab_req",
      res = "wow_publish_custom_prefab_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1032058599] = {
      req = "wow_get_user_gallery_pub_prefab_list_req",
      res = "wow_get_user_gallery_pub_prefab_list_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1039736807] = {
      req = "ugc_get_tutorial_level_award_req",
      res = "ugc_get_tutorial_level_award_rsp",
      handler = "UGCPublishHandler"
    },
    [1120061767] = {
      req = "wow_support_pub_prefab_req",
      res = "wow_support_pub_prefab_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1259072537] = {
      req = "ugc_clear_caring_notify_req",
      handler = "UGCPublishHandler"
    },
    [1295778467] = {
      req = "ugc_watch_learn_video_req",
      res = "ugc_watch_learn_video_rsp",
      handler = "UGCPublishHandler"
    },
    [1303005322] = {
      res = "ugc_update_edit_meta_notify",
      handler = "UGCPublishHandler"
    },
    [1512607735] = {
      req = "ugc_get_tutorial_level_data_req",
      res = "ugc_get_tutorial_level_data_rsp",
      handler = "UGCPublishHandler"
    },
    [1518350503] = {
      req = "wow_cancel_publish_custom_prefab_req",
      res = "wow_cancel_publish_custom_prefab_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1603937767] = {
      req = "ugc_learn_video_list_req",
      res = "ugc_learn_video_list_rsp",
      handler = "UGCPublishHandler"
    },
    [1619872415] = {
      req = "ugc_get_learn_video_award_req",
      res = "ugc_get_learn_video_award_rsp",
      handler = "UGCPublishHandler"
    },
    [1647074087] = {
      req = "ugc_exchange_mall_get_item_req",
      res = "ugc_exchange_mall_get_item_rsp",
      handler = "UGCPublishHandler"
    },
    [1751357855] = {
      req = "wow_report_prefab_req",
      res = "wow_report_prefab_rsp",
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1832441447] = {
      req = "wow_get_user_pub_prefab_list_req",
      res = "wow_get_user_pub_prefab_list_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1901297191] = {
      req = "wow_query_prefab_report_status_req",
      res = "wow_query_prefab_report_status_rsp",
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1914096235] = {
      req = "ugc_creator_get_task_list_req",
      res = "ugc_creator_get_task_list_rsp",
      timeInterval = 1,
      handler = "UGCPublishHandler"
    },
    [1916514359] = {
      req = "ugc_search_prefab_req",
      res = "ugc_search_prefab_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "UGCPublishHandler"
    },
    [1958271943] = {
      req = "ugc_finish_learn_video_req",
      res = "ugc_finish_learn_video_rsp",
      handler = "UGCPublishHandler"
    },
    [60264871] = {
      req = "ugc_combined_search_collection_req",
      res = "ugc_combined_search_collection_rsp",
      handler = "UGCSearchHandler"
    },
    [129806955] = {
      req = "ugc_gallery_feeds_req",
      res = "ugc_gallery_feeds_rsp",
      handler = "UGCSearchHandler"
    },
    [130235303] = {
      req = "ugc_get_all_meta_key_req",
      res = "ugc_get_all_meta_key_rsp",
      handler = "UGCSearchHandler"
    },
    [204105323] = {
      req = "ugc_get_search_info_req",
      res = "ugc_get_search_info_rsp",
      handler = "UGCSearchHandler"
    },
    [272748107] = {
      req = "get_recommend_setting_req",
      res = "get_recommend_setting_rsp",
      timeInterval = 1,
      handler = "UGCSearchHandler"
    },
    [284867847] = {
      req = "ugc_get_single_pub_mod_rank_req",
      res = "ugc_get_single_pub_mod_rank_rsp",
      handler = "UGCSearchHandler"
    },
    [302555879] = {
      req = "ugc_admin_recommend_mods_req",
      res = "ugc_admin_recommend_mods_rsp",
      handler = "UGCSearchHandler"
    },
    [421139775] = {
      req = "ugc_get_all_spec_theme_list_req",
      res = "ugc_get_all_spec_theme_list_rsp",
      inGameOper = 0,
      handler = "UGCSearchHandler"
    },
    [425552871] = {
      req = "ugc_search_collection_filter_req",
      res = "ugc_search_collection_filter_rsp",
      queueType = 1,
      handler = "UGCSearchHandler"
    },
    [527316499] = {
      req = "ugc_promotion_game_result_req",
      res = "ugc_promotion_game_result_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCSearchHandler"
    },
    [560570175] = {
      req = "ugc_get_single_mod_share_rank_req",
      res = "ugc_get_single_mod_share_rank_rsp",
      handler = "UGCSearchHandler"
    },
    [609738599] = {
      req = "spec_theme_task_receive_reward_req",
      res = "spec_theme_task_receive_reward_rsp",
      handler = "UGCSearchHandler"
    },
    [663742639] = {
      req = "get_ugc_top_author_list_req",
      res = "get_ugc_top_author_list_rsp",
      handler = "UGCSearchHandler"
    },
    [665665599] = {
      req = "ugc_new_mod_tab_req",
      res = "ugc_new_mod_tab_rsp",
      handler = "UGCSearchHandler"
    },
    [827762527] = {
      req = "ugc_get_guess_search_text_req",
      res = "ugc_get_guess_search_text_rsp",
      handler = "UGCSearchHandler"
    },
    [888765287] = {
      req = "ugc_mod_itemcf_req",
      res = "ugc_mod_itemcf_rsp",
      queueType = 1,
      inGameOper = 0,
      handler = "UGCSearchHandler"
    },
    [915374567] = {
      req = "spec_theme_task_receive_all_reward_req",
      res = "spec_theme_task_receive_all_reward_rsp",
      handler = "UGCSearchHandler"
    },
    [984965151] = {
      req = "ugc_combined_search_mod_req",
      res = "ugc_combined_search_mod_rsp",
      handler = "UGCSearchHandler"
    },
    [1134166203] = {
      req = "ugc_get_events_mod_list_req",
      res = "ugc_get_events_mod_list_rsp",
      handler = "UGCSearchHandler"
    },
    [1246208519] = {
      req = "ugc_gallery_new_mod_validation_req",
      res = "ugc_gallery_new_mod_validation_rsp",
      handler = "UGCSearchHandler"
    },
    [1280978655] = {
      req = "ugc_gallery_explore_mix_req",
      res = "ugc_gallery_explore_mix_rsp",
      handler = "UGCSearchHandler"
    },
    [1291385415] = {
      req = "ugc_hot_theme_ext_req",
      res = "ugc_hot_theme_ext_rsp",
      handler = "UGCSearchHandler"
    },
    [1331806887] = {
      req = "spec_theme_task_get_progress_req",
      res = "spec_theme_task_get_progress_rsp",
      handler = "UGCSearchHandler"
    },
    [1489709863] = {
      req = "ugc_gallery_new_mod_incubation_req",
      res = "ugc_gallery_new_mod_incubation_rsp",
      handler = "UGCSearchHandler"
    },
    [1501206043] = {
      req = "set_recommend_setting_req",
      res = "set_recommend_setting_rsp",
      handler = "UGCSearchHandler"
    },
    [1565205255] = {
      req = "ugc_match_tab_req",
      res = "ugc_match_tab_rsp",
      handler = "UGCSearchHandler"
    },
    [1585714279] = {
      req = "ugc_search_word_comp_req",
      res = "ugc_search_word_comp_rsp",
      handler = "UGCSearchHandler"
    },
    [1585810599] = {
      req = "ugc_personal_recommond_req",
      res = "ugc_personal_recommond_rsp",
      handler = "UGCSearchHandler"
    },
    [1620217575] = {
      req = "ugc_get_single_pub_mod_play_info_req",
      res = "ugc_get_single_pub_mod_play_info_rsp",
      handler = "UGCSearchHandler"
    },
    [1798347367] = {
      req = "ugc_mixed_banner_req",
      res = "ugc_mixed_banner_rsp",
      queueType = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "UGCSearchHandler"
    },
    [1893451303] = {
      req = "ugc_get_single_mod_purchase_rank_req",
      res = "ugc_get_single_mod_purchase_rank_rsp",
      handler = "UGCSearchHandler"
    },
    [1992170843] = {
      req = "ugc_search_mod_collection_req",
      res = "ugc_search_mod_collection_rsp",
      queueType = 1,
      handler = "UGCSearchHandler"
    },
    [2007292491] = {
      req = "ugc_gallery_hot_theme_req",
      res = "ugc_gallery_hot_theme_rsp",
      handler = "UGCSearchHandler"
    },
    [2065114675] = {
      req = "ugc_mark_recommend_mods_req",
      res = "ugc_mark_recommend_mods_rsp",
      timeout = 5,
      handler = "UGCSearchHandler"
    },
    [2070631815] = {
      req = "ugc_is_recommend_fresh_req",
      res = "ugc_is_recommend_fresh_rsp",
      handler = "UGCSearchHandler"
    },
    [13885863] = {
      req = "receive_koi_lottery_reward_req",
      res = "receive_koi_lottery_reward_rsp",
      handler = "UPassKoiHandler"
    },
    [239000573] = {
      res = "upass_koi_unclaimed_reward_notify",
      handler = "UPassKoiHandler"
    },
    [1017296999] = {
      req = "get_koi_lottery_data_req",
      res = "get_koi_lottery_data_rsp",
      handler = "UPassKoiHandler"
    },
    [1431550449] = {
      res = "send_koi_gift_reward_notify",
      handler = "UPassKoiHandler"
    },
    [1772166626] = {
      res = "upass_koi_alloc_lottery_notify",
      handler = "UPassKoiHandler"
    },
    [2003007239] = {
      req = "giveup_koi_lottery_req",
      res = "giveup_koi_lottery_rsp",
      handler = "UPassKoiHandler"
    },
    [108654275] = {
      req = "reply_comment_req",
      res = "reply_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [164217191] = {
      req = "set_ugc_comment_display_req",
      res = "set_ugc_comment_display_rsp",
      handler = "UgcCommentHandler"
    },
    [247127415] = {
      req = "query_ugc_comment_display_req",
      res = "query_ugc_comment_display_rsp",
      handler = "UgcCommentHandler"
    },
    [299344539] = {
      req = "ugc_post_feedback_req",
      res = "ugc_post_feedback_rsp",
      inGameOper = 0,
      handler = "UgcCommentHandler"
    },
    [447605287] = {
      req = "ugc_get_pub_meta_for_comment_req",
      res = "ugc_get_pub_meta_for_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [538602939] = {
      req = "del_reply_comment_req",
      res = "del_reply_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [725887175] = {
      req = "batch_get_comment_data_req",
      res = "batch_get_comment_data_rsp",
      handler = "UgcCommentHandler"
    },
    [777647699] = {
      req = "ugc_get_featured_comment_list_req",
      res = "ugc_get_featured_comment_list_rsp",
      handler = "UgcCommentHandler"
    },
    [788981095] = {
      req = "ugc_get_comment_redpoint_req",
      res = "ugc_get_comment_redpoint_rsp",
      handler = "UgcCommentHandler"
    },
    [838073803] = {
      req = "ugc_set_top_comment_req",
      res = "ugc_set_top_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [838311103] = {
      req = "ugc_batch_get_feedback_detail_req",
      res = "ugc_batch_get_feedback_detail_rsp",
      handler = "UgcCommentHandler"
    },
    [856152207] = {
      req = "ugc_mark_feedback_read_status_req",
      res = "ugc_mark_feedback_read_status_rsp",
      handler = "UgcCommentHandler"
    },
    [885368679] = {
      req = "query_user_comments_data_req",
      res = "query_user_comments_data_rsp",
      isUnique = 1,
      inGameOper = 0,
      handler = "UgcCommentHandler"
    },
    [931433511] = {
      req = "ugc_post_comment_req",
      res = "ugc_post_comment_rsp",
      inGameOper = 0,
      handler = "UgcCommentHandler"
    },
    [1010400295] = {
      req = "ugc_delete_top_comment_req",
      res = "ugc_delete_top_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [1071277863] = {
      req = "ugc_get_all_comment_key_list_req",
      res = "ugc_get_all_comment_key_list_rsp",
      handler = "UgcCommentHandler"
    },
    [1312724239] = {
      req = "ugc_delete_comment_redpoint_req",
      res = "ugc_delete_comment_redpoint_rsp",
      handler = "UgcCommentHandler"
    },
    [1326304031] = {
      req = "ugc_get_feedback_list_req",
      res = "ugc_get_feedback_list_rsp",
      handler = "UgcCommentHandler"
    },
    [1444741299] = {
      req = "ugc_author_delete_comment_for_map_req",
      res = "ugc_author_delete_comment_for_map_rsp",
      handler = "UgcCommentHandler"
    },
    [1514477991] = {
      req = "ugc_query_author_mod_comment_display_req",
      res = "ugc_query_author_mod_comment_display_rsp",
      handler = "UgcCommentHandler"
    },
    [1567957099] = {
      req = "author_del_featured_comment_req",
      res = "author_del_featured_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [1642788335] = {
      req = "ugc_author_post_comment_for_map_req",
      res = "ugc_author_post_comment_for_map_rsp",
      handler = "UgcCommentHandler"
    },
    [1723212067] = {
      req = "wow_comment_pre_check_req",
      res = "wow_comment_pre_check_rsp",
      inGameOper = 0,
      handler = "UgcCommentHandler"
    },
    [1929081383] = {
      req = "ugc_batch_delete_feedbacks_req",
      res = "ugc_batch_delete_feedbacks_rsp",
      handler = "UgcCommentHandler"
    },
    [2047154543] = {
      req = "author_set_featured_comment_req",
      res = "author_set_featured_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [2066336283] = {
      req = "ugc_get_feedback_detail_req",
      res = "ugc_get_feedback_detail_rsp",
      handler = "UgcCommentHandler"
    },
    [2069461783] = {
      req = "ugc_support_comment_req",
      res = "ugc_support_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [2122182119] = {
      req = "delete_comment_req",
      res = "delete_comment_rsp",
      handler = "UgcCommentHandler"
    },
    [388193539] = {
      req = "upass_explore_req",
      res = "upass_explore_rsp",
      handler = "UnknowPassSubwayHandler"
    },
    [1667382375] = {
      req = "upass_explore_reward_req",
      res = "upass_explore_reward_rsp",
      handler = "UnknowPassSubwayHandler"
    },
    [1761329959] = {
      req = "upass_explore_info_req",
      res = "upass_explore_info_rsp",
      handler = "UnknowPassSubwayHandler"
    },
    [114675335] = {
      req = "get_rp_anniv_ret_data_req",
      res = "get_rp_anniv_ret_data_rsp",
      handler = "UpassBackBoxHandle"
    },
    [404087227] = {
      req = "get_rp_anniv_must_chest_req",
      res = "get_rp_anniv_must_chest_rsp",
      isLock = 1,
      handler = "UpassBackBoxHandle"
    },
    [601563239] = {
      req = "get_rp_anniv_chest_items_req",
      res = "get_rp_anniv_chest_items_rsp",
      handler = "UpassBackBoxHandle"
    },
    [690686311] = {
      req = "get_rp_anniv_extra_chest_req",
      res = "get_rp_anniv_extra_chest_rsp",
      isLock = 1,
      handler = "UpassBackBoxHandle"
    },
    [783981415] = {
      req = "rp_anniv_ret_switch_camp_req",
      res = "rp_anniv_ret_switch_camp_rsp",
      handler = "UpassBackBoxHandle"
    },
    [881860343] = {
      req = "rp_anniv_ret_chest_ban_item_req",
      res = "rp_anniv_ret_chest_ban_item_rsp",
      handler = "UpassBackBoxHandle"
    },
    [1258240183] = {
      req = "get_rp_anniv_ret_chest_ban_data_req",
      res = "get_rp_anniv_ret_chest_ban_data_rsp",
      handler = "UpassBackBoxHandle"
    },
    [1314418148] = {
      res = "notify_rp_anniv_chest_info",
      handler = "UpassBackBoxHandle"
    },
    [2133563239] = {
      req = "rp_anniv_ret_select_camp_req",
      res = "rp_anniv_ret_select_camp_rsp",
      handler = "UpassBackBoxHandle"
    },
    [61194727] = {
      req = "rp_branch_get_task_award_req",
      res = "rp_branch_get_task_award_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [284969535] = {
      req = "rp_branch_get_extra_chest_req",
      res = "rp_branch_get_extra_chest_rsp",
      isLock = 1,
      timeInterval = 1,
      handler = "UpassBranchHandler"
    },
    [953210702] = {
      req = "sync_rp_branch_task_data_req",
      res = "sync_rp_branch_task_data_info",
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [1148181215] = {
      req = "rp_branch_buy_score_req",
      res = "rp_branch_buy_score_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [1223261991] = {
      req = "rp_branch_common_buy_req",
      res = "rp_branch_common_buy_rsp",
      isLock = 1,
      timeout = 10,
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [1368515239] = {
      req = "rp_branch_batch_get_task_award_req",
      res = "rp_branch_batch_get_task_award_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [1398139539] = {
      req = "rp_branch_player_data_req",
      res = "rp_branch_player_data_rsp",
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [1513609547] = {
      req = "rp_branch_batch_get_level_award_req",
      res = "rp_branch_batch_get_level_award_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [1569625047] = {
      req = "unknown_pass_type_req",
      res = "unknown_pass_type_rsp",
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [1649805863] = {
      req = "rp_branch_get_special_reward_req",
      res = "rp_branch_get_special_reward_rsp",
      isLock = 1,
      timeInterval = 1,
      handler = "UpassBranchHandler"
    },
    [1654017711] = {
      req = "rp_branch_get_level_award_req",
      res = "rp_branch_get_level_award_rsp",
      isLock = 1,
      timeout = 5,
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [2138887995] = {
      res = "rp_branch_score_notify_change",
      inGameOper = 0,
      handler = "UpassBranchHandler"
    },
    [442532395] = {
      req = "get_rp_custom_extra_chest_req",
      res = "get_rp_custom_extra_chest_rsp",
      isLock = 1,
      timeout = 5,
      handler = "UpassCustomChestHandler"
    },
    [501348311] = {
      req = "reset_rp_chest_pool_req",
      res = "reset_rp_chest_pool_rsp",
      isLock = 1,
      timeout = 5,
      handler = "UpassCustomChestHandler"
    },
    [656247015] = {
      req = "get_rp_custom_chest_data_req",
      res = "get_rp_custom_chest_data_rsp",
      handler = "UpassCustomChestHandler"
    },
    [755723687] = {
      req = "rp_chest_confirm_reward_pool_req",
      res = "rp_chest_confirm_reward_pool_rsp",
      isLock = 1,
      timeout = 5,
      handler = "UpassCustomChestHandler"
    },
    [1433280935] = {
      req = "get_rp_custom_must_chest_req",
      res = "get_rp_custom_must_chest_rsp",
      isLock = 1,
      timeout = 5,
      handler = "UpassCustomChestHandler"
    },
    [1656269991] = {
      req = "open_rp_custom_chest_req",
      res = "open_rp_custom_chest_rsp",
      isLock = 1,
      timeout = 5,
      handler = "UpassCustomChestHandler"
    },
    [26087859] = {
      req = "upass_pre_prize_buy_req",
      res = "upass_pre_prize_buy_rsp",
      handler = "UpassHandle"
    },
    [92247271] = {
      req = "upass_prime_take_month_award_req",
      res = "upass_prime_take_month_award_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [114807771] = {
      req = "upass_daily_award_req",
      res = "upass_daily_award_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [130201955] = {
      req = "upass_select_motion_req",
      res = "upass_select_motion_rsp",
      handler = "UpassHandle"
    },
    [134561319] = {
      req = "upass_refreash_daily_req",
      res = "upass_refreash_daily_rsp",
      handler = "UpassHandle"
    },
    [145714887] = {
      req = "limited_time_task_sync_req",
      res = "limited_time_task_sync_rsp",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [185944995] = {
      res = "game_end_show_finish_upass_task",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [273133618] = {
      res = "rp_anniversary_bonus_reward_ntf",
      handler = "UpassHandle"
    },
    [298365831] = {
      req = "general_task_daily_task_reward_req",
      res = "general_task_daily_task_reward_rsp",
      handler = "UpassHandle"
    },
    [301058194] = {
      req = "exit_result",
      res = "upass_banner_query_rsp",
      handler = "UpassHandle"
    },
    [310477219] = {
      req = "upass_new_get_req",
      res = "upass_new_get_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [384206375] = {
      req = "upass_reward_all_extra_score_req",
      res = "upass_reward_all_extra_score_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [384579463] = {
      req = "delete_rp_groupbuy_req",
      res = "delete_rp_groupbuy_rsp",
      handler = "UpassHandle"
    },
    [389915234] = {
      res = "upass_prime_info_change_notify",
      handler = "UpassHandle"
    },
    [400375079] = {
      req = "upass_prime_take_first_award_req",
      res = "upass_prime_take_first_award_rsp",
      handler = "UpassHandle"
    },
    [421664327] = {
      req = "upass_batch_get_level_award_req",
      res = "upass_batch_get_level_award_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [437620583] = {
      req = "create_rp_groupbuy_req",
      res = "create_rp_groupbuy_rsp",
      handler = "UpassHandle"
    },
    [453165600] = {
      res = "notify_invite_rp_groupbuy_result",
      handler = "UpassHandle"
    },
    [463912887] = {
      req = "upass_task_batch_reward_req",
      res = "upass_task_batch_reward_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [491897715] = {
      req = "upass_active_shop_exchange_rp_receipt_req",
      res = "upass_active_shop_exchange_rp_receipt_rsp",
      isLock = 1,
      timeout = 10,
      handler = "UpassHandle"
    },
    [501363111] = {
      req = "get_rp_groupbuy_info_req",
      res = "get_rp_groupbuy_info_rsp",
      handler = "UpassHandle"
    },
    [531517531] = {
      req = "upass_send_battle_largess_req",
      res = "upass_send_battle_largess_rsp",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [565464268] = {
      res = "upass_score_notify_chg",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [589994403] = {
      req = "general_task_week_task_batch_reward_req",
      res = "general_task_week_task_batch_reward_rsp",
      handler = "UpassHandle"
    },
    [602786727] = {
      req = "upass_task_daily_refresh_req",
      res = "upass_task_daily_refresh_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [602967111] = {
      req = "general_task_daily_refresh_req",
      res = "general_task_daily_refresh_rsp",
      handler = "UpassHandle"
    },
    [606539073] = {
      res = "general_task_sync_daily_reward_data",
      handler = "UpassHandle"
    },
    [665577527] = {
      req = "upass_active_shop_buy_req",
      res = "upass_active_shop_buy_rsp",
      isLock = 1,
      timeout = 10,
      handler = "UpassHandle"
    },
    [689146351] = {
      req = "upass_get_experience_upgrade_reward_req",
      res = "upass_get_experience_upgrade_reward_rsp",
      handler = "UpassHandle"
    },
    [693555047] = {
      req = "join_rp_groupbuy_req",
      res = "join_rp_groupbuy_rsp",
      handler = "UpassHandle"
    },
    [718709511] = {
      req = "upass_exchange_req",
      res = "upass_exchange_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [719800359] = {
      req = "upass_get_weekly_award_req",
      res = "upass_get_weekly_award_rsp",
      handler = "UpassHandle"
    },
    [728070751] = {
      req = "remove_invite_red_point_req",
      res = "remove_invite_red_point_rsp",
      handler = "UpassHandle"
    },
    [774689235] = {
      req = "upass_get_level_award_req",
      res = "upass_get_level_award_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [819311459] = {
      req = "upass_task_reward_req",
      res = "upass_task_reward_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [823035799] = {
      req = "general_weekly_active_award_req",
      res = "general_weekly_active_award_rsp",
      handler = "UpassHandle"
    },
    [857268974] = {
      req = "sync_upass_extra_score_req",
      res = "sync_upass_extra_score_info",
      handler = "UpassHandle"
    },
    [886436167] = {
      req = "invite_all_rp_groupbuy_friend_list_req",
      res = "invite_all_rp_groupbuy_friend_list_rsp",
      handler = "UpassHandle"
    },
    [928708263] = {
      req = "get_invite_red_point_req",
      res = "get_invite_red_point_rsp",
      handler = "UpassHandle"
    },
    [986269955] = {
      req = "upass_buy_level_award_req",
      res = "upass_buy_level_award_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1056532219] = {
      req = "upass_prime_take_continuous_award_req",
      res = "upass_prime_take_continuous_award_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1090058503] = {
      req = "upass_batch_get_record_req",
      res = "upass_batch_get_record_rsp",
      handler = "UpassHandle"
    },
    [1090346746] = {
      res = "unknown_pass_bonus_rsp",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1098415899] = {
      req = "upass_task_imm_finish_req",
      res = "upass_task_imm_finish_rsp",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1118464623] = {
      req = "upass_unlock_extra_score_task_req",
      res = "upass_unlock_extra_score_task_rsp",
      isUnique = 1,
      isLock = 1,
      timeInterval = 2,
      handler = "UpassHandle"
    },
    [1190121543] = {
      req = "upass_get_unclaimed_reward_req",
      res = "upass_get_unclaimed_reward_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1207385755] = {
      req = "upass_change_switch_req",
      res = "upass_change_switch_rsp",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1227177351] = {
      req = "upass_get_continuous_buy_award_req",
      res = "upass_get_continuous_buy_award_rsp",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1322309591] = {
      req = "general_task_week_task_reward_req",
      res = "general_task_week_task_reward_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1325883315] = {
      req = "upass_buy_pass_list_req",
      res = "upass_buy_pass_list_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1362460922] = {
      res = "upass_game_end_show_tasks_notify",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1395983599] = {
      res = "general_task_game_result_notify",
      handler = "UpassHandle"
    },
    [1402379786] = {
      res = "upass_notify_data_chg",
      handler = "UpassHandle"
    },
    [1435933251] = {
      req = "upass_buy_score_req",
      res = "upass_buy_score_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1453218884] = {
      res = "upass_send_old_user_awards_notify",
      handler = "UpassHandle"
    },
    [1486771671] = {
      req = "upass_exchange_list_req",
      res = "upass_exchange_list_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1495419695] = {
      req = "upass_sync_battle_largess_req",
      res = "upass_sync_battle_largess_rsp",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1532309151] = {
      req = "upass_pre_prize_take_progress_award_req",
      res = "upass_pre_prize_take_progress_award_rsp",
      handler = "UpassHandle"
    },
    [1547034939] = {
      req = "upass_reward_extra_score_task_req",
      res = "upass_reward_extra_score_task_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1570460201] = {
      res = "general_task_week_task_share_progress_sync",
      handler = "UpassHandle"
    },
    [1576392915] = {
      req = "general_task_daily_login_reward_req",
      res = "general_task_daily_login_reward_rsp",
      handler = "UpassHandle"
    },
    [1619233221] = {
      res = "sync_upass_score_card_info",
      handler = "UpassHandle"
    },
    [1623007235] = {
      res = "upass_task_adddition_ntfy",
      handler = "UpassHandle"
    },
    [1639341159] = {
      req = "get_rp_groupbuy_simple_info_req",
      res = "get_rp_groupbuy_simple_info_rsp",
      handler = "UpassHandle"
    },
    [1683996007] = {
      req = "upass_quick_level_up_req",
      res = "upass_quick_level_up_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1697852199] = {
      req = "general_task_week_task_imm_req",
      res = "general_task_week_task_imm_rsp",
      handler = "UpassHandle"
    },
    [1698908595] = {
      res = "general_weekly_active_sync",
      handler = "UpassHandle"
    },
    [1702826087] = {
      req = "upass_get_record_req",
      res = "upass_get_record_rsp",
      handler = "UpassHandle"
    },
    [1753658735] = {
      res = "general_task_week_task_friend_addition_sync",
      handler = "UpassHandle"
    },
    [1753678399] = {
      req = "general_task_batch_reward_req",
      res = "general_task_batch_reward_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [1768701571] = {
      req = "general_task_sync_all_req",
      res = "general_task_sync_all_rsp",
      handler = "UpassHandle"
    },
    [1770613746] = {
      res = "upass_imm_finish_task_rsp",
      handler = "UpassHandle"
    },
    [1778463059] = {
      req = "get_daily_task_ext_reward_info",
      res = "get_daily_task_ext_reward_info_res",
      handler = "UpassHandle"
    },
    [1811451157] = {
      res = "notify_upass_value_change",
      handler = "UpassHandle"
    },
    [1826564151] = {
      req = "upass_prime_query_req",
      res = "upass_prime_query_rsp",
      handler = "UpassHandle"
    },
    [1832680243] = {
      req = "general_task_daily_task_imm_req",
      res = "general_task_daily_task_imm_rsp",
      handler = "UpassHandle"
    },
    [1835347175] = {
      req = "limited_time_task_reward_req",
      res = "limited_time_task_reward_rsp",
      handler = "UpassHandle"
    },
    [1863723879] = {
      req = "get_rp_groupbuy_friend_invite_list_req",
      res = "get_rp_groupbuy_friend_invite_list_rsp",
      handler = "UpassHandle"
    },
    [1883574356] = {
      res = "limited_task_sync_data_change",
      handler = "UpassHandle"
    },
    [1888191139] = {
      req = "upass_get_abstract_page_req",
      res = "upass_get_abstract_page_rsp",
      handler = "UpassHandle"
    },
    [1905254695] = {
      req = "upass_buy_pass_req",
      res = "upass_buy_pass_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [1954371370] = {
      res = "week_task_auto_reward_notify",
      handler = "UpassHandle"
    },
    [2046686021] = {
      res = "general_task_sync_daily_task_change",
      handler = "UpassHandle"
    },
    [2065139907] = {
      res = "upass_pre_prize_score_chg_notify",
      handler = "UpassHandle"
    },
    [2099462187] = {
      req = "upass_get_curweek_award_req",
      res = "upass_get_curweek_award_rsp",
      isLock = 1,
      handler = "UpassHandle"
    },
    [2108503778] = {
      res = "upass_task_share_progress_notify",
      inGameOper = 0,
      handler = "UpassHandle"
    },
    [2129546471] = {
      req = "upass_get_daily_award_req",
      res = "upass_get_daily_award_rsp",
      handler = "UpassHandle"
    },
    [1007693031] = {
      req = "client_push_news_log",
      handler = "UrgentNoticeHandler"
    },
    [742976895] = {
      req = "query_global_switch_req",
      res = "query_global_switch_rsp",
      handler = "UserGlobalInfoHandler"
    },
    [841099760] = {
      res = "update_global_data",
      handler = "UserGlobalInfoHandler"
    },
    [1241367359] = {
      req = "get_global_list_req",
      res = "get_global_list_rsp",
      handler = "UserGlobalInfoHandler"
    },
    [2113849807] = {
      req = "set_global_switch_req",
      res = "set_global_switch_rsp",
      handler = "UserGlobalInfoHandler"
    },
    [255146855] = {
      req = "get_car_feature_data_req",
      res = "get_car_feature_data_rsp",
      handler = "VehicleAccessoryHandler"
    },
    [570658407] = {
      req = "car_accessory_op_req",
      res = "car_accessory_op_rsp",
      handler = "VehicleAccessoryHandler"
    },
    [574450627] = {
      req = "clear_car_feature_red_point_req",
      res = "clear_car_feature_red_point_rsp",
      handler = "VehicleAccessoryHandler"
    },
    [587402471] = {
      req = "car_unlock_accessory_req",
      res = "car_unlock_accessory_rsp",
      handler = "VehicleAccessoryHandler"
    },
    [1551465863] = {
      req = "get_sports_car_feature_req",
      res = "get_sports_car_feature_rsp",
      handler = "VehicleAccessoryHandler"
    },
    [1788340140] = {
      res = "notify_sports_car_feature_data",
      handler = "VehicleAccessoryHandler"
    },
    [1851933152] = {
      res = "notify_car_feature_data",
      handler = "VehicleAccessoryHandler"
    },
    [1874824507] = {
      res = "car_accessory_notify",
      handler = "VehicleAccessoryHandler"
    },
    [1880421223] = {
      req = "car_feature_op_req",
      res = "car_feature_op_rsp",
      handler = "VehicleAccessoryHandler"
    },
    [2060432571] = {
      req = "equip_car_feature_req",
      res = "equip_car_feature_rsp",
      timeInterval = 0.5,
      handler = "VehicleAccessoryHandler"
    },
    [38829951] = {
      req = "get_car_collection_data_req",
      res = "get_car_collection_data_rsp",
      handler = "VehicleCollectHandler"
    },
    [285208991] = {
      req = "take_car_collection_award_req",
      res = "take_car_collection_award_rsp",
      handler = "VehicleCollectHandler"
    },
    [481007911] = {
      req = "take_unlock_refund_req",
      res = "take_unlock_refund_rsp",
      inGameOper = 0,
      handler = "VehicleCollectHandler"
    },
    [635979223] = {
      req = "get_car_collection_info_req",
      res = "get_car_collection_info_rsp",
      handler = "VehicleCollectHandler"
    },
    [1052074523] = {
      req = "edit_car_plate_number_req",
      res = "edit_car_plate_number_rsp",
      handler = "VehicleCollectHandler"
    },
    [1707900135] = {
      req = "set_car_voice_switch_req",
      res = "set_car_voice_switch_rsp",
      isUnique = 1,
      handler = "VehicleCollectHandler"
    },
    [1844967463] = {
      req = "set_car_feature_switch_req",
      res = "set_car_feature_switch_rsp",
      handler = "VehicleCollectHandler"
    },
    [2074655559] = {
      req = "get_car_collection_award_status_req",
      res = "get_car_collection_award_status_rsp",
      handler = "VehicleCollectHandler"
    },
    [2123152103] = {
      req = "unlock_specific_sports_car_feature_req",
      res = "unlock_specific_sports_car_feature_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "VehicleCollectHandler"
    },
    [169344295] = {
      req = "get_car_applique_data_by_car_req",
      res = "get_car_applique_data_by_car_rsp",
      handler = "VehicleDIYHandler"
    },
    [477476231] = {
      req = "depot_exchange_req",
      res = "depot_exchange_rsp",
      handler = "VehicleDIYHandler"
    },
    [688806759] = {
      req = "save_car_applique_data_req",
      res = "save_car_applique_data_rsp",
      handler = "VehicleDIYHandler"
    },
    [1939760123] = {
      req = "get_car_applique_data_req",
      res = "get_car_applique_data_rsp",
      timeInterval = 1,
      inGameOper = 0,
      handler = "VehicleDIYHandler"
    },
    [507847879] = {
      req = "car_setting_req",
      res = "car_setting_rsp",
      handler = "VehicleRefitHandler"
    },
    [530662695] = {
      req = "car_modification_req",
      res = "car_modification_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "VehicleRefitHandler"
    },
    [873979367] = {
      req = "car_level_up_req",
      res = "car_level_up_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "VehicleRefitHandler"
    },
    [1179138151] = {
      req = "get_car_info_req",
      res = "get_car_info_rsp",
      isUnique = 1,
      handler = "VehicleRefitHandler"
    },
    [1179811431] = {
      req = "car_last_opt_req",
      res = "car_last_opt_rsp",
      isUnique = 1,
      handler = "VehicleRefitHandler"
    },
    [1798838304] = {
      req = "buy_car_modification_cost",
      res = "buy_car_modification_rsp",
      isUnique = 1,
      queueType = 1,
      handler = "VehicleRefitHandler"
    },
    [40944615] = {
      req = "version_album_query_data_req",
      res = "version_album_query_data_rsp",
      inGameOper = 0,
      handler = "VersionAlbumHandler"
    },
    [1052233511] = {
      req = "version_album_move_photo_req",
      res = "version_album_move_photo_rsp",
      inGameOper = 0,
      handler = "VersionAlbumHandler"
    },
    [1463111871] = {
      req = "version_album_add_photo_req",
      res = "version_album_add_photo_rsp",
      inGameOper = 0,
      handler = "VersionAlbumHandler"
    },
    [1805509619] = {
      req = "version_album_change_background_req",
      res = "version_album_change_background_rsp",
      inGameOper = 0,
      handler = "VersionAlbumHandler"
    },
    [2047363687] = {
      req = "version_album_delete_photo_req",
      res = "version_album_delete_photo_rsp",
      inGameOper = 0,
      handler = "VersionAlbumHandler"
    },
    [783722738] = {
      req = "set_vietnam_user_info_extrying_req",
      handler = "VngPersonalHandler"
    },
    [21526311] = {
      req = "batch_get_shared_backpack_selected_item_info_req",
      res = "batch_get_shared_backpack_selected_item_info_rsp",
      handler = "WardRobeHandler"
    },
    [50108811] = {
      req = "get_holography_equip_slot_req",
      res = "get_holography_equip_slot_rsp",
      handler = "WardRobeHandler"
    },
    [98535239] = {
      req = "use_plating_req",
      res = "use_plating_rsp",
      timeInterval = 1,
      handler = "WardRobeHandler"
    },
    [102989895] = {
      req = "unequip_motion_req",
      res = "unequip_motion_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [176171431] = {
      req = "equip_motion_req",
      res = "equip_motion_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [237494691] = {
      req = "query_depot_tag_req",
      res = "query_depot_tag_rsp",
      handler = "WardRobeHandler"
    },
    [239626455] = {
      req = "card_collect_get_depot_ds_req",
      res = "card_collect_get_depot_ds_rsp",
      handler = "WardRobeHandler"
    },
    [282763943] = {
      req = "depot_batch_put_on_req",
      res = "depot_batch_put_on_rsp",
      handler = "WardRobeHandler"
    },
    [334507264] = {
      res = "mini_dress_newest_notify",
      handler = "WardRobeHandler"
    },
    [361884267] = {
      req = "set_res_tag_req",
      res = "set_res_tag_rsp",
      handler = "WardRobeHandler"
    },
    [382030028] = {
      req = "put_on_weapon_wear",
      res = "put_on_weapon_wear_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [382807879] = {
      req = "shared_backpack_select_item_req",
      res = "shared_backpack_select_item_rsp",
      handler = "WardRobeHandler"
    },
    [405159263] = {
      req = "set_show_info_req",
      res = "set_show_info_rsp",
      handler = "WardRobeHandler"
    },
    [408926631] = {
      req = "unlock_gold_dress_bind_req",
      res = "unlock_gold_dress_bind_rsp",
      handler = "WardRobeHandler"
    },
    [408935175] = {
      req = "shared_backpack_select_item_v2_req",
      res = "shared_backpack_select_item_v2_rsp",
      handler = "WardRobeHandler"
    },
    [431491623] = {
      req = "get_special_weapon_wear_info_req",
      res = "get_special_weapon_wear_info_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [435386387] = {
      res = "update_rolewear_state",
      handler = "WardRobeHandler"
    },
    [443837146] = {
      res = "team_update_shared_backpack",
      handler = "WardRobeHandler"
    },
    [454104103] = {
      req = "change_bind_relation_req",
      res = "change_bind_relation_rsp",
      handler = "WardRobeHandler"
    },
    [460715367] = {
      req = "set_teamup_action_type_req",
      res = "set_teamup_action_type_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "WardRobeHandler"
    },
    [483952679] = {
      req = "equip_holography_req",
      res = "equip_holography_rsp",
      handler = "WardRobeHandler"
    },
    [501833067] = {
      req = "get_shared_backpack_permission_info_req",
      res = "get_shared_backpack_permission_info_rsp",
      handler = "WardRobeHandler"
    },
    [505037901] = {
      res = "notify_plating_show",
      timeInterval = 1,
      handler = "WardRobeHandler"
    },
    [512199271] = {
      req = "depot_put_down_req",
      res = "depot_put_down_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "WardRobeHandler"
    },
    [515926247] = {
      req = "unequip_mini_robot_motion_req",
      res = "unequip_mini_robot_motion_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [547751079] = {
      req = "get_shared_backpack_config_info_req",
      res = "get_shared_backpack_config_info_rsp",
      handler = "WardRobeHandler"
    },
    [597479463] = {
      req = "shared_backpack_batch_put_on_req",
      res = "shared_backpack_batch_put_on_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [649491291] = {
      req = "get_plating_req",
      res = "get_plating_rsp",
      handler = "WardRobeHandler"
    },
    [649901223] = {
      req = "get_mini_robot_motion_info_req",
      res = "get_mini_robot_motion_info_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [724719231] = {
      req = "effect_motion_setting_req",
      res = "effect_motion_setting_rsp",
      timeInterval = 1,
      handler = "WardRobeHandler"
    },
    [738526078] = {
      req = "get_item_decompose_info",
      res = "get_item_decompose_info_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [750165895] = {
      req = "put_on_weapon_pendant_req",
      res = "put_on_weapon_pendant_rsp",
      handler = "WardRobeHandler"
    },
    [830071601] = {
      res = "shared_backpack_permission_info_notify",
      handler = "WardRobeHandler"
    },
    [838246995] = {
      req = "exchange_motion_req",
      res = "exchange_motion_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [908257422] = {
      req = "pspace_put_on_weapon_wear",
      res = "pspace_put_on_weapon_wear_rsp",
      handler = "WardRobeHandler"
    },
    [921255623] = {
      req = "get_all_weapon_pendant_req",
      res = "get_all_weapon_pendant_rsp",
      timeInterval = 2,
      handler = "WardRobeHandler"
    },
    [926498291] = {
      req = "effect_motion_levelup_req",
      res = "effect_motion_levelup_rsp",
      timeInterval = 1,
      handler = "WardRobeHandler"
    },
    [937681383] = {
      req = "put_off_weapon_pendant_req",
      res = "put_off_weapon_pendant_rsp",
      handler = "WardRobeHandler"
    },
    [1063994371] = {
      req = "exchange_mini_robt_motion_req",
      res = "exchange_mini_robt_motion_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1071799841] = {
      res = "notify_depot_item_change",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1072851979] = {
      req = "set_plating_req",
      res = "set_plating_rsp",
      handler = "WardRobeHandler"
    },
    [1104786087] = {
      req = "grant_shared_backpack_permission_req",
      res = "grant_shared_backpack_permission_rsp",
      handler = "WardRobeHandler"
    },
    [1137756263] = {
      req = "set_shared_backpack_guide_status_req",
      res = "set_shared_backpack_guide_status_rsp",
      handler = "WardRobeHandler"
    },
    [1144947219] = {
      req = "take_car_page_award_req",
      res = "take_car_page_award_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1146308804] = {
      req = "unlock_rolewear",
      res = "unlock_rolewear_rsp",
      handler = "WardRobeHandler"
    },
    [1189797042] = {
      res = "notify_knapsack_chg_index",
      handler = "WardRobeHandler"
    },
    [1190500691] = {
      req = "change_depot_tag_name_req",
      res = "change_depot_tag_name_rsp",
      handler = "WardRobeHandler"
    },
    [1192281095] = {
      req = "get_item_jump_info_by_itemlist_req",
      res = "get_item_jump_info_by_itemlist_rsp",
      handler = "WardRobeHandler"
    },
    [1212123099] = {
      req = "depot_set_head_show_req",
      res = "depot_set_head_show_rsp",
      handler = "WardRobeHandler"
    },
    [1236759619] = {
      req = "equip_mini_robot_motion_req",
      res = "equip_mini_robot_motion_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1238013580] = {
      req = "use_item",
      res = "use_item_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [1238141565] = {
      res = "sync_mini_robot_motion_notify",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1253286245] = {
      res = "shared_backpack_selected_item_info_notify",
      handler = "WardRobeHandler"
    },
    [1284698599] = {
      req = "get_gold_cloth_bind_info_req",
      res = "get_gold_cloth_bind_info_rsp",
      handler = "WardRobeHandler"
    },
    [1326667751] = {
      req = "get_shared_backpack_info_req",
      res = "get_shared_backpack_info_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [1339010407] = {
      req = "shared_backpack_unlocked_req",
      res = "shared_backpack_unlocked_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [1351345308] = {
      req = "on_item_compose",
      res = "on_item_compose_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [1375221447] = {
      req = "put_on_gold_dress_bind_req",
      res = "put_on_gold_dress_bind_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1476600371] = {
      req = "get_xsuit_glide_req",
      res = "get_xsuit_glide_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1509401454] = {
      req = "get_avatar_box_list",
      res = "get_avatar_box_list_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [1511285693] = {
      req = "set_item_expired_notified",
      handler = "WardRobeHandler"
    },
    [1547223713] = {
      req = "get_all_skin_list",
      res = "get_weapon_skin_list_rsp",
      handler = "WardRobeHandler"
    },
    [1610768231] = {
      req = "get_shared_backpack_guide_status_req",
      res = "get_shared_backpack_guide_status_rsp",
      handler = "WardRobeHandler"
    },
    [1629943675] = {
      req = "set_mvp_action_type_req",
      res = "set_mvp_action_type_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "WardRobeHandler"
    },
    [1695792499] = {
      req = "depot_set_skin_info_req",
      res = "depot_set_skin_info_rsp",
      handler = "WardRobeHandler"
    },
    [1702002907] = {
      req = "put_off_gold_dress_bind_req",
      res = "put_off_gold_dress_bind_rsp",
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1707771246] = {
      req = "get_shared_backpack_table_params_req",
      res = "get_shared_backpack_params_rsp",
      isUnique = 1,
      queueType = 1,
      timeInterval = 5,
      handler = "WardRobeHandler"
    },
    [1710386307] = {
      req = "set_xsuit_glide_req",
      res = "set_xsuit_glide_rsp",
      timeInterval = 1,
      handler = "WardRobeHandler"
    },
    [1713407596] = {
      req = "metro_use_item",
      res = "metro_use_item_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [1714684903] = {
      req = "shared_backpack_put_down_req",
      res = "shared_backpack_put_down_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [1729770087] = {
      req = "change_special_weapon_skin_req",
      res = "change_special_weapon_skin_rsp",
      isLock = 1,
      inGameOper = 0,
      handler = "WardRobeHandler"
    },
    [1872657140] = {
      req = "select_use_rolewear",
      res = "select_use_rolewear_rsp",
      handler = "WardRobeHandler"
    },
    [1905941895] = {
      req = "get_shared_backpack_selected_item_info_req",
      res = "get_shared_backpack_selected_item_info_rsp",
      handler = "WardRobeHandler"
    },
    [1975731275] = {
      req = "shared_backpack_batch_config_item_req",
      res = "shared_backpack_batch_config_item_rsp",
      handler = "WardRobeHandler"
    },
    [1988771047] = {
      req = "depot_put_on_req",
      res = "depot_put_on_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 5,
      handler = "WardRobeHandler"
    },
    [2034884679] = {
      req = "unlock_multi_color_req",
      res = "unlock_multi_color_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [2043709095] = {
      req = "depot_batch_put_down_req",
      res = "depot_batch_put_down_rsp",
      handler = "WardRobeHandler"
    },
    [2049905491] = {
      req = "check_buy_item_type_req",
      res = "check_buy_item_type_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [2092197895] = {
      req = "shared_backpack_put_on_req",
      res = "shared_backpack_put_on_rsp",
      isLock = 1,
      handler = "WardRobeHandler"
    },
    [2109963911] = {
      req = "card_collect_set_depot_ds_req",
      res = "card_collect_set_depot_ds_rsp",
      handler = "WardRobeHandler"
    },
    [1394455399] = {
      req = "get_emoji_bubble_req",
      res = "get_emoji_bubble_rsp",
      handler = "WardrobeEmojiBubbleHandler"
    },
    [1774893671] = {
      req = "set_emoji_bubble_req",
      res = "set_emoji_bubble_rsp",
      handler = "WardrobeEmojiBubbleHandler"
    },
    [194539271] = {
      req = "set_interactive_action_req",
      res = "set_interactive_action_rsp",
      handler = "WardrobeInterActionHandler"
    },
    [965761159] = {
      req = "get_interactive_action_req",
      res = "get_interactive_action_rsp",
      handler = "WardrobeInterActionHandler"
    },
    [1257527235] = {
      req = "unlock_lobby_idle_req",
      res = "unlock_lobby_idle_rsp",
      handler = "WardrobeInterActionHandler"
    },
    [595484784] = {
      req = "select_item",
      handler = "WardrobeNewHandler"
    },
    [1012780591] = {
      req = "depot_modify_combat_vehicle_req",
      res = "depot_modify_combat_vehicle_rsp",
      handler = "WardrobeNewHandler"
    },
    [1124239581] = {
      req = "equip_motion_list_req",
      handler = "WardrobeNewHandler"
    },
    [62992652] = {
      req = "pre_team_act_query_team_info",
      res = "pre_team_act_query_team_info_rsp",
      handler = "WarmUpGroupHandler"
    },
    [190127340] = {
      req = "pre_team_act_join_team",
      res = "pre_team_act_join_team_rsp",
      isLock = 1,
      timeout = 5,
      handler = "WarmUpGroupHandler"
    },
    [394812812] = {
      req = "pre_team_act_invite_join",
      res = "pre_team_act_invite_join_rsp",
      isLock = 1,
      timeout = 5,
      handler = "WarmUpGroupHandler"
    },
    [1934596886] = {
      req = "pre_team_act_get_reward",
      res = "pre_team_act_get_reward_rsp",
      isLock = 1,
      timeout = 5,
      handler = "WarmUpGroupHandler"
    },
    [1945201548] = {
      req = "pre_team_act_create_team",
      res = "pre_team_act_create_team_rsp",
      isLock = 1,
      timeout = 5,
      handler = "WarmUpGroupHandler"
    },
    [2007057542] = {
      req = "pre_team_act_get_friend_teams",
      res = "pre_team_act_get_friend_teams_rsp",
      isLock = 1,
      timeout = 5,
      handler = "WarmUpGroupHandler"
    },
    [35011111] = {
      req = "modify_lbs_warzone_use_title_req",
      res = "modify_lbs_warzone_use_title_rsp",
      isLock = 1,
      handler = "WarzoneHandle"
    },
    [121916054] = {
      req = "modify_lbs_warzone_id",
      res = "modify_lbs_warzone_id_rsp",
      handler = "WarzoneHandle"
    },
    [286926055] = {
      req = "clear_lbs_warzone_title_redpoint_req",
      res = "clear_lbs_warzone_title_redpoint_rsp",
      isLock = 1,
      handler = "WarzoneHandle"
    },
    [291840417] = {
      res = "clear_lbs_warzone_use_title",
      handler = "WarzoneHandle"
    },
    [464419884] = {
      req = "get_lbs_strongest_rank",
      res = "get_lbs_strongest_rank_rsp",
      isLock = 1,
      handler = "WarzoneHandle"
    },
    [592903383] = {
      res = "enter_battle_watch_failed",
      inGameOper = 0,
      handler = "WarzoneHandle"
    },
    [695807439] = {
      req = "lbs_warzone_title_req",
      res = "lbs_warzone_title_rsp",
      isLock = 1,
      handler = "WarzoneHandle"
    },
    [732660787] = {
      req = "batch_get_profile_lbs_warzone_req",
      res = "batch_get_profile_lbs_warzone_rsp",
      inGameOper = 0,
      handler = "WarzoneHandle"
    },
    [807557779] = {
      res = "get_role_avatar_wear_rsp",
      inGameOper = 0,
      handler = "WarzoneHandle"
    },
    [911938442] = {
      res = "notify_lbs_warzone_title_redpoint_info",
      handler = "WarzoneHandle"
    },
    [1121620647] = {
      req = "query_lbs_streetzone_my_rank_req",
      res = "query_lbs_streetzone_my_rank_rsp",
      handler = "WarzoneHandle"
    },
    [1125483479] = {
      res = "exit_watch_game",
      inGameOper = 0,
      handler = "WarzoneHandle"
    },
    [1278537775] = {
      req = "query_lbs_warzone_playernum_req",
      res = "query_lbs_warzone_playernum_rsp",
      handler = "WarzoneHandle"
    },
    [1507319373] = {
      req = "hawkeye_report_broadcast",
      handler = "WarzoneHandle"
    },
    [1625331591] = {
      req = "pk_lbs_streetzone_rank_req",
      res = "pk_lbs_streetzone_rank_rsp",
      handler = "WarzoneHandle"
    },
    [1755824846] = {
      req = "get_lbs_topn_rank",
      res = "get_lbs_topn_rank_rsp",
      handler = "WarzoneHandle"
    },
    [1818011351] = {
      req = "query_lbs_streetzone_rank_req",
      res = "query_lbs_streetzone_rank_rsp",
      handler = "WarzoneHandle"
    },
    [2004670022] = {
      req = "get_lbs_global_rank",
      res = "get_lbs_global_rank_rsp",
      isLock = 1,
      handler = "WarzoneHandle"
    },
    [2068567836] = {
      req = "leave_hawkeye_watch",
      handler = "WarzoneHandle"
    },
    [3896383] = {
      req = "save_weapon_diy_custom_pattern_data_req",
      res = "save_weapon_diy_custom_pattern_data_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [86844903] = {
      req = "exchange_diy_pattern_req",
      res = "exchange_diy_pattern_rsp",
      handler = "WeaponDiyHandler"
    },
    [144554023] = {
      req = "unlock_weapon_diy_custom_pattern_layer_req",
      res = "unlock_weapon_diy_custom_pattern_layer_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [150047335] = {
      req = "get_base_pattern_and_color_req",
      res = "get_base_pattern_and_color_rsp",
      handler = "WeaponDiyHandler"
    },
    [337939355] = {
      req = "get_weapon_diy_summary_data_req",
      res = "get_weapon_diy_summary_data_rsp",
      handler = "WeaponDiyHandler"
    },
    [540769447] = {
      req = "save_weapon_diy_custom_plan_data_req",
      res = "save_weapon_diy_custom_plan_data_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [589802127] = {
      req = "get_other_weapon_diy_summary_data_req",
      res = "get_other_weapon_diy_summary_data_rsp",
      handler = "WeaponDiyHandler"
    },
    [743035093] = {
      res = "weapon_diy_material_notify",
      handler = "WeaponDiyHandler"
    },
    [750394791] = {
      req = "batch_get_player_ds_data_req",
      res = "batch_get_player_ds_data_rsp",
      handler = "WeaponDiyHandler"
    },
    [862090919] = {
      req = "use_weapon_diy_custom_plan_req",
      res = "use_weapon_diy_custom_plan_rsp",
      handler = "WeaponDiyHandler"
    },
    [960079783] = {
      req = "unlock_weapon_diy_weapon_layer_req",
      res = "unlock_weapon_diy_weapon_layer_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [993996295] = {
      req = "get_weapon_diy_weapon_list_req",
      res = "get_weapon_diy_weapon_list_rsp",
      handler = "WeaponDiyHandler"
    },
    [1064691807] = {
      req = "delete_weapon_diy_custom_plan_req",
      res = "delete_weapon_diy_custom_plan_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [1169448231] = {
      req = "get_weapon_diy_detail_data_req",
      res = "get_weapon_diy_detail_data_rsp",
      handler = "WeaponDiyHandler"
    },
    [1314315527] = {
      req = "weapon_diy_unlock_plan_req",
      res = "weapon_diy_unlock_plan_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [1353625743] = {
      req = "get_weapon_diy_custom_pattern_req",
      res = "get_weapon_diy_custom_pattern_rsp",
      handler = "WeaponDiyHandler"
    },
    [1382516231] = {
      req = "weapon_diy_unlock_base_req",
      res = "weapon_diy_unlock_base_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [1387029835] = {
      req = "get_weapon_diy_material_count_req",
      res = "get_weapon_diy_material_count_rsp",
      handler = "WeaponDiyHandler"
    },
    [1429715623] = {
      req = "get_player_ds_data_req",
      res = "get_player_ds_data_rsp",
      isUnique = 1,
      timeout = 5,
      needRsp = 1,
      inGameOper = 0,
      handler = "WeaponDiyHandler"
    },
    [1696309567] = {
      req = "batch_get_weapon_diy_summary_data_req",
      res = "batch_get_weapon_diy_summary_data_rsp",
      handler = "WeaponDiyHandler"
    },
    [1802917287] = {
      req = "delete_weapon_diy_custom_pattern_req",
      res = "delete_weapon_diy_custom_pattern_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [1916257439] = {
      req = "get_weapon_diy_custom_plan_data_req",
      res = "get_weapon_diy_custom_plan_data_rsp",
      handler = "WeaponDiyHandler"
    },
    [2054080199] = {
      req = "buy_weapon_diy_custom_plan_req",
      res = "buy_weapon_diy_custom_plan_rsp",
      isLock = 1,
      handler = "WeaponDiyHandler"
    },
    [526652867] = {
      req = "get_weapon_power_rank_req",
      res = "get_weapon_power_rank_rsp",
      handler = "WeaponStrengthHandler"
    },
    [695440831] = {
      req = "get_last_weapon_power_rank_reward_req",
      res = "get_last_weapon_power_rank_reward_rsp",
      handler = "WeaponStrengthHandler"
    },
    [816778566] = {
      res = "notify_weapon_power_result",
      inGameOper = 0,
      handler = "WeaponStrengthHandler"
    },
    [1124172387] = {
      req = "get_on_user_weapon_power_rank_req",
      res = "get_on_user_weapon_power_rank_rsp",
      handler = "WeaponStrengthHandler"
    },
    [1164671595] = {
      req = "get_weapon_power_data_req",
      res = "get_weapon_power_data_rsp",
      handler = "WeaponStrengthHandler"
    },
    [1774290343] = {
      req = "get_weapon_history_segment_data_req",
      res = "get_weapon_history_segment_data_rsp",
      handler = "WeaponStrengthHandler"
    },
    [135337959] = {
      req = "soulmate_corner_search_req",
      res = "soulmate_corner_search_rsp",
      handler = "WeddingActivityHandler"
    },
    [203308755] = {
      req = "soulmate_corner_publish_req",
      res = "soulmate_corner_publish_rsp",
      handler = "WeddingActivityHandler"
    },
    [500966535] = {
      req = "soulmate_corner_search_by_uid_name_req",
      res = "soulmate_corner_search_by_uid_name_rsp",
      handler = "WeddingActivityHandler"
    },
    [1132481815] = {
      req = "soulmate_corner_unpublish_req",
      res = "soulmate_corner_unpublish_rsp",
      handler = "WeddingActivityHandler"
    },
    [1698639939] = {
      req = "soulmate_guinness_act_share_req",
      res = "soulmate_guinness_act_share_rsp",
      handler = "WeddingActivityHandler"
    },
    [1858864867] = {
      req = "soulmate_guinness_act_award_req",
      res = "soulmate_guinness_act_award_rsp",
      handler = "WeddingActivityHandler"
    },
    [2000539815] = {
      req = "soulmate_guinness_act_info_req",
      res = "soulmate_guinness_act_info_rsp",
      handler = "WeddingActivityHandler"
    },
    [1271739543] = {
      res = "microvision_weekly_report_update_notify",
      handler = "WeekRportHandler"
    },
    [1322018887] = {
      req = "get_premium_recycling_data_req",
      res = "get_premium_recycling_data_rsp",
      handler = "WeekendMarketHandler"
    },
    [1601218643] = {
      req = "premium_recycling_req",
      res = "premium_recycling_rsp",
      handler = "WeekendMarketHandler"
    },
    [226420288] = {
      res = "teammate_wolf_theme_card_notify",
      handler = "WolfThemeHandler"
    },
    [2090172967] = {
      req = "query_wolf_theme_card_info_req",
      res = "query_wolf_theme_card_info_rsp",
      handler = "WolfThemeHandler"
    },
    [23500167] = {
      req = "get_worldcup_exchange_shop_req",
      res = "get_worldcup_exchange_shop_rsp",
      handler = "WorldCupHandler"
    },
    [84538727] = {
      req = "get_worldcup_game_data_req",
      res = "get_worldcup_game_data_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "WorldCupHandler"
    },
    [158875807] = {
      req = "get_race_data_req",
      res = "get_race_data_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "WorldCupHandler"
    },
    [199091527] = {
      req = "get_worldcup_fanchant_rank_req",
      res = "get_worldcup_fanchant_rank_rsp",
      handler = "WorldCupHandler"
    },
    [441755975] = {
      req = "get_worldcup_quiz_one_user_rank_req",
      res = "get_worldcup_quiz_one_user_rank_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "WorldCupHandler"
    },
    [509164919] = {
      req = "get_worldcup_task_award_req",
      res = "get_worldcup_task_award_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      handler = "WorldCupHandler"
    },
    [522093567] = {
      req = "get_worldcup_task_req",
      res = "get_worldcup_task_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      handler = "WorldCupHandler"
    },
    [695975175] = {
      req = "exchange_worldcup_item_req",
      res = "exchange_worldcup_item_rsp",
      handler = "WorldCupHandler"
    },
    [753249223] = {
      req = "get_worldcup_activity_list_req",
      res = "get_worldcup_activity_list_rsp",
      isUnique = 1,
      handler = "WorldCupHandler"
    },
    [811686789] = {
      res = "notify_fu_xing_info",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      handler = "WorldCupHandler"
    },
    [819738151] = {
      req = "get_worldcup_fanchant_match_info_req",
      res = "get_worldcup_fanchant_match_info_rsp",
      handler = "WorldCupHandler"
    },
    [848144707] = {
      req = "worldcup_fanchant_send_gift_req",
      res = "worldcup_fanchant_send_gift_rsp",
      handler = "WorldCupHandler"
    },
    [879668583] = {
      req = "get_worldcup_quiz_activity_req",
      res = "get_worldcup_quiz_activity_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "WorldCupHandler"
    },
    [938008679] = {
      req = "get_fu_xing_info_req",
      res = "get_fu_xing_info_rsp",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      handler = "WorldCupHandler"
    },
    [969618503] = {
      req = "get_worldcup_quiz_rank_req",
      res = "get_worldcup_quiz_rank_rsp",
      queueType = 1,
      timeout = 10,
      timeInterval = 1,
      handler = "WorldCupHandler"
    },
    [1044274129] = {
      res = "worldcup_fanchant_gift_notify",
      handler = "WorldCupHandler"
    },
    [1194081336] = {
      res = "notify_worldcup_task",
      queueType = 1,
      isLock = 1,
      timeout = 10,
      timeInterval = 3,
      handler = "WorldCupHandler"
    },
    [1356118631] = {
      req = "worldcup_quiz_game_req",
      res = "worldcup_quiz_game_rsp",
      queueType = 1,
      timeout = 10,
      handler = "WorldCupHandler"
    },
    [1593714471] = {
      req = "subscribe_worldcup_fanchant_req",
      res = "subscribe_worldcup_fanchant_rsp",
      handler = "WorldCupHandler"
    },
    [2033263879] = {
      req = "get_worldcup_fanchant_info_req",
      res = "get_worldcup_fanchant_info_rsp",
      handler = "WorldCupHandler"
    },
    [2053271638] = {
      res = "worldcup_prepare_notify",
      handler = "WorldCupHandler"
    },
    [139747687] = {
      req = "get_gold_dress_state_req",
      res = "get_gold_dress_state_rsp",
      handler = "XSuitHandler"
    },
    [169817159] = {
      req = "unlock_xsuit_glide_req",
      res = "unlock_xsuit_glide_rsp",
      handler = "XSuitHandler"
    },
    [248126303] = {
      req = "get_wish_pool_req",
      res = "get_wish_pool_rsp",
      timeout = 5,
      handler = "XSuitHandler"
    },
    [413309359] = {
      req = "open_gold_dress_req",
      res = "open_gold_dress_rsp",
      handler = "XSuitHandler"
    },
    [444539348] = {
      res = "team_update_gold_dress",
      handler = "XSuitHandler"
    },
    [746699151] = {
      req = "get_gold_dress_activity_req",
      res = "get_gold_dress_activity_rsp",
      handler = "XSuitHandler"
    },
    [880490923] = {
      req = "emtion_action_reply_req",
      res = "emtion_action_reply_rsp",
      handler = "XSuitHandler"
    },
    [936041735] = {
      req = "get_rise_star_info_req",
      res = "get_rise_star_info_rsp",
      handler = "XSuitHandler"
    },
    [980620199] = {
      req = "change_emtion_action_req",
      res = "change_emtion_action_rsp",
      handler = "XSuitHandler"
    },
    [1056513879] = {
      req = "get_give_condtion_req",
      res = "get_give_condtion_rsp",
      handler = "XSuitHandler"
    },
    [1099270815] = {
      req = "draw_gold_dress_req",
      res = "draw_gold_dress_rsp",
      handler = "XSuitHandler"
    },
    [1126377351] = {
      req = "gold_dress_flag_operation_req",
      res = "gold_dress_flag_operation_rsp",
      handler = "XSuitHandler"
    },
    [1151944727] = {
      req = "gold_dress_get_level_action_req",
      res = "gold_dress_get_level_action_rsp",
      handler = "XSuitHandler"
    },
    [1249575219] = {
      req = "rise_star_req",
      res = "rise_star_rsp",
      handler = "XSuitHandler"
    },
    [1261786215] = {
      req = "set_wish_pool_id_req",
      res = "set_wish_pool_id_rsp",
      timeout = 5,
      handler = "XSuitHandler"
    },
    [1293078951] = {
      req = "set_gold_dress_new_level_req",
      res = "set_gold_dress_new_level_rsp",
      handler = "XSuitHandler"
    },
    [1297130967] = {
      req = "unlock_gold_dress_level_feature_req",
      res = "unlock_gold_dress_level_feature_rsp",
      handler = "XSuitHandler"
    },
    [1438002932] = {
      res = "refresh_gold_dress_state_rsp",
      handler = "XSuitHandler"
    },
    [1441847655] = {
      req = "gold_dress_set_level_action_req",
      res = "gold_dress_set_level_action_rsp",
      handler = "XSuitHandler"
    },
    [1522060688] = {
      res = "notify_change_emtion_action",
      handler = "XSuitHandler"
    },
    [1624245415] = {
      req = "get_gold_dress_new_level_req",
      res = "get_gold_dress_new_level_rsp",
      handler = "XSuitHandler"
    },
    [1910843783] = {
      req = "get_accumulate_pool_reward_req",
      res = "get_accumulate_pool_reward_rsp",
      handler = "XSuitHandler"
    },
    [1938023015] = {
      req = "set_gold_dress_state_req",
      res = "set_gold_dress_state_rsp",
      handler = "XSuitHandler"
    },
    [2016980015] = {
      req = "unlock_gold_dress_state_req",
      res = "unlock_gold_dress_state_rsp",
      handler = "XSuitHandler"
    },
    [2093412579] = {
      req = "wear_gold_dress_req",
      res = "wear_gold_dress_rsp",
      handler = "XSuitHandler"
    },
    [2120963335] = {
      req = "do_onshot_exchange_by_activity_id_req",
      res = "do_onshot_exchange_by_activity_id_rsp",
      handler = "XSuitHandler"
    },
    [297181317] = {
      res = "notify_pre_loss_award",
      inGameOper = 0,
      handler = "ZoneAwardHandler"
    },
    [1922576873] = {
      res = "sync_best_zone",
      inGameOper = 0,
      handler = "ZoneBestHandler"
    },
    [1250332461] = {
      res = "notify_zone_change_reach_801_text",
      inGameOper = 0,
      handler = "ZoneChangeHandler"
    },
    [1887847412] = {
      req = "get_most_used_shadow_req",
      res = "sync_most_used_shadow",
      handler = "ZoneSetHandler"
    },
    [62847399] = {
      req = "get_kol_topfans5_req",
      res = "get_kol_topfans5_rsp",
      handler = "kol_handler"
    },
    [91411219] = {
      req = "take_kol_leaderboard_reward_req",
      res = "take_kol_leaderboard_reward_rsp",
      handler = "kol_handler"
    },
    [238674663] = {
      req = "get_top_fans_req",
      res = "get_top_fans_rsp",
      handler = "kol_handler"
    },
    [259039343] = {
      req = "join_kol_team_req",
      res = "join_kol_team_rsp",
      handler = "kol_handler"
    },
    [347904399] = {
      req = "get_user_homepage_req",
      res = "get_user_homepage_rsp",
      timeInterval = 10,
      handler = "kol_handler"
    },
    [1114348967] = {
      req = "get_kol_detail_req",
      res = "get_kol_detail_rsp",
      handler = "kol_handler"
    },
    [1305632007] = {
      req = "leave_kol_team_req",
      res = "leave_kol_team_rsp",
      handler = "kol_handler"
    },
    [1475154223] = {
      req = "get_kol_ranks_req",
      res = "get_kol_ranks_rsp",
      handler = "kol_handler"
    },
    [1600716659] = {
      req = "get_user_historical_records_req",
      res = "get_user_historical_records_rsp",
      handler = "kol_handler"
    },
    [1633738411] = {
      req = "get_history_season_rank_req",
      res = "get_history_season_rank_rsp",
      handler = "kol_handler"
    },
    [2097168103] = {
      req = "get_kol_list_req",
      res = "get_kol_list_rsp",
      handler = "kol_handler"
    }
  }
  NetConfig.reconnectMsgMap = {718633438}
end
return NetConfig