local NetManager = require("client.network.comm.NetManager")
local GlobalNetHandler = {}
function GlobalNetHandler.on_client_req_limited_notify(msg)
  log(bWriteLog and "on_client_req_limited_notify msg=" .. msg)
  if msg ~= "client_req_limited_notify" then
    NetManager.ProcReqLimited(msg)
  end
  if msg == "lbs_nearly_player_req" then
    EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_LIST)
  else
    if msg ~= "get_market_info_req" and Client.IsDevelopment() then
      ShowNotice(LocUtil.GetLocalizeResStr(5060) .. "(" .. tostring(msg) .. ")")
    else
    end
  end
  if msg == "ugc_duplicate_pub_mod_req" or msg == "ugc_duplicate_mod_req" or msg == "ugc_publish_mod_req" or msg == "change_intimacy_relation_req" or msg == "soulmate_corner_search_req" then
    ShowNotice(LocUtil.GetLocalizeResStr(655386))
  end
end
function GlobalNetHandler.send_get_loading_pic_cfg(region_index)
  NetManager.SendPkg(1213367246, region_index)
end
function GlobalNetHandler.on_get_loading_pic_cfg_rsp(login_loading_table, battle_loading_table)
end
function GlobalNetHandler.send_get_load_background_cfg_req()
  NetManager.SendPkg(1705770239)
end
function GlobalNetHandler.on_get_load_background_cfg_rsp(loading_pictures, login_loading_cfg, battle_loading_cfg)
  log_tree("GlobalNetHandler.on_get_load_background_cfg_rsp login_loading_cfg", login_loading_cfg)
  log_tree("GlobalNetHandler.on_get_load_background_cfg_rsp battle_loading_cfg", battle_loading_cfg)
  log_tree("GlobalNetHandler.on_get_load_background_cfg_rsp loading_pictures", loading_pictures)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(loading_pictures, PlayerPrefsSystem.ePlayerPrefsType.eLoadBgPics)
  PlayerPrefsSystem.SaveTableToFile_N(login_loading_cfg, PlayerPrefsSystem.ePlayerPrefsType.eLoadBgCfgLogin)
  PlayerPrefsSystem.SaveTableToFile_N(battle_loading_cfg, PlayerPrefsSystem.ePlayerPrefsType.eLoadBgCfgBattle)
end
function GlobalNetHandler.send_button_push_click_log(button_type, reason, str)
  NetManager.SendPkg(1109334369, button_type, reason, str)
end
function GlobalNetHandler.send_video_play_report_req(name, time, video_id, first_play, single_daily_count, total_daily_count, skip_ctrl, cd_sec, is_skip)
  NetManager.SendPkg(277052152, name, time, video_id, first_play, single_daily_count, total_daily_count, skip_ctrl, cd_sec, is_skip)
end
function GlobalNetHandler.send_res_download_report_req(download_type, download_id)
  NetManager.SendPkg(34683699, download_type, download_id)
end
function GlobalNetHandler.send_get_new_loading_pic_cfg_req()
  NetManager.SendPkg(1767781323)
end
function GlobalNetHandler.on_get_new_loading_pic_cfg_rsp(err_code, loading_cfg_table)
end
function GlobalNetHandler.send_ip_region_check_req()
  NetManager.SendPkg(607533496)
end
function GlobalNetHandler.on_ip_region_check_res(err_code, err_msg)
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  RechargeSystem.ip_region_check_res(err_code, err_msg)
end
function GlobalNetHandler.send_video_skip_ctrl_req(video_id, first_play, single_daily_count, total_daily_count)
  NetManager.SendPkg(1148755527, video_id, first_play, single_daily_count, total_daily_count)
end
function GlobalNetHandler.on_video_skip_ctrl_rsp(err, video_id, skip_ctrl, cd_sec)
  if err ~= 0 then
    return
  end
  local VideoSystem = require("client.slua.logic.video.logic_video_manager")
  VideoSystem.On_Video_Skip_Ctrl_Rsp(video_id, skip_ctrl, cd_sec)
  log(bWriteLog and " err===" .. err)
  log(bWriteLog and " video_id===" .. video_id)
  log(bWriteLog and " skip_ctrl===" .. skip_ctrl)
  log(bWriteLog and " cd_sec===" .. tostring(cd_sec))
end
function GlobalNetHandler.send_batch_button_click_log(button_click_log_list)
  log_tree("GlobalNetHandler.send_batch_button_click_log button_click_log_list:", button_click_log_list)
  NetManager.SendPkg(1169364147, button_click_log_list)
end
function GlobalNetHandler.send_report_event_duration_log(event_type, duration_time)
  NetManager.SendPkg(1317958927, event_type, duration_time)
end
function GlobalNetHandler.send_get_loading_show_cfg_req()
  NetManager.SendPkg(1363316455)
end
function GlobalNetHandler.on_get_loading_show_cfg_rsp(err_code, loading_cfg_table)
  if err_code ~= 0 then
    ShowNotice(err_code)
  elseif loading_cfg_table then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(loading_cfg_table, PlayerPrefsSystem.ePlayerPrefsType.eLoadingConfig)
  end
end
function GlobalNetHandler.on_notify_client_tips(tip_type, msg_id, msg)
  local sShowStr = msg_id and LocUtil.GetLocalizeResStr(msg_id) or msg
  if tip_type == 1 then
    ShowNotice(sShowStr)
  elseif tip_type == 2 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(5077), sShowStr)
  end
end
function GlobalNetHandler.send_report_age_gate_voice_flow(id)
  NetManager.SendPkg(559153996, id)
end
function GlobalNetHandler.send_report_general_illegal_click_req(event_type, detail_device_type, illegal_event_detail)
  NetManager.SendPkg(1326535638, event_type, detail_device_type, illegal_event_detail)
end
return GlobalNetHandler