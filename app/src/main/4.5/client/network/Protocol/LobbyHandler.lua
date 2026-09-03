local NetManager = require("client.network.comm.NetManager")
local LobbyHandler = {}
local newbie_guide_errcode_name = {
  [503004] = true,
  [503005] = true,
  [503006] = true,
  [503007] = true,
  [503008] = true,
  [503009] = true,
  [503010] = true
}
function LobbyHandler.send_get_bubble_info_req()
  NetManager.SendPkg(1435945011)
end
function LobbyHandler.on_get_bubble_info_rsp(bubbleDataList)
  local logic_lobby_bubble = require("client.slua.logic.lobby_bubble.logic_lobby_bubble")
  logic_lobby_bubble.on_get_bubble_info_rsp(bubbleDataList)
end
function LobbyHandler.send_get_release_notes()
  NetManager.SendPkg(597734332)
end
function LobbyHandler.on_get_release_notes_rsp(msg)
  local LogicNews = require("client.slua.logic.lobby.logic_lobby_news")
  LogicNews.RspNewsInfo(msg)
end
function LobbyHandler.on_get_season_broadcast_rsp(have_broadcast, refreshTime)
  LobbySystem.on_get_season_broadcast_rsp(have_broadcast, refreshTime)
end
function LobbyHandler.send_query_gm_request()
  NetManager.SendPkg(302308398)
end
function LobbyHandler.on_query_gm_respond(open)
  LobbySystem.query_s_manager_respond(open)
end
function LobbyHandler.send_get_championship_info()
  NetManager.SendPkg(594069509)
end
function LobbyHandler.on_championship_info_notify(redinfo)
  local matchCenterEntryLogic = require("client.slua.logic.lobby.Mid.logic_lobby_mid_match_center_entry")
  matchCenterEntryLogic.on_championship_info_notify(redinfo)
end
function LobbyHandler.send_cutscenes_report()
  NetManager.SendPkg(604304808)
end
function LobbyHandler.on_get_cutscenes_award_rsp(err, award_list, time)
  log(bWriteLog and "LobbyHandler.on_get_cutscenes_award_rsp" .. tostring(err))
  log_tree("LobbyHandler.on_get_cutscenes_award_rsp", award_list)
  local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
  if award_list and award_list[1] then
    KeyPlayVideoSystem.SetReward(award_list)
  end
end
function LobbyHandler.send_unbind_social_account_req(channel, is_imm)
  log(bWriteLog and string.format("LobbyHandler.send_unbind_social_account_req, channel:%s", channel))
  log(bWriteLog and string.format("LobbyHandler.send_unbind_social_account_req, is_imm:%s", is_imm))
  NetManager.SendPkg(1358366683, channel, is_imm)
end
function LobbyHandler.on_unbind_social_account_rsp(errcode, timestamp)
  log(bWriteLog and string.format("LobbyHandler.on_unbind_social_account_rsp, errcode:%s", errcode))
  log(bWriteLog and string.format("LobbyHandler.on_unbind_social_account_rsp, timestamp:%s", timestamp))
  if errcode ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if errcode == 881015 then
      local title = LocUtil.GetLocalizeResStr(101001)
      local text = LocUtil.GetLocalizeResStr(35119)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, text)
    elseif errcode == 100150049 then
      local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
      QRcodeRestrictManager:ShowRestrictTips()
      return
    elseif logic_account_protect_setting:IsNeedShowLimitErrorPopup(errcode) then
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_protect_setting:ShowLimitErrorPopup(setting_macro.AccountOperationType.Unbind, errcode)
    else
      ShowNotice(errcode)
    end
  else
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eAccountBindSocialRemind)
    if timestamp then
      local Unbind_Mgr = require("client.slua.logic.unbind_account.logic_unbind")
      Unbind_Mgr.SyncUnbindTime(timestamp)
    end
  end
end
function LobbyHandler.on_unbind_social_acc_rsp(errcode, errmsg, channel, is_imm)
  log(bWriteLog and "[jackey]on_unbind_social_acc_rsp->errcode: " .. tostring(errcode) .. ", errmsg = " .. tostring(errmsg) .. ", channel = " .. tostring(channel) .. ", is_imm = " .. tostring(is_imm))
  local Unbind_Mgr = require("client.slua.logic.unbind_account.logic_unbind")
  if errcode == 0 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eAccountBindSocialRemind)
    if is_imm then
      local title = LocUtil.GetLocalizeResStr(7390)
      local content = LocUtil.GetLocalizeResStr(38925)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, content)
      local IMSDKHelper = import("IMSDKHelper")
      local IMSDKHelperInstance = IMSDKHelper.GetInstance()
      if IMSDKHelperInstance then
        IMSDKHelperInstance:GetBindInfo()
      end
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_FAST_UNBIND_SUCCESS)
    elseif channel then
      Unbind_Mgr.SetIndexByChannel(channel)
      UIManager.ShowUI(UIManager.UI_Config.unbind_account_result)
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(2, function()
      local IMSDKHelper = import("IMSDKHelper")
      local IMSDKHelperInstance = IMSDKHelper.GetInstance()
      if IMSDKHelperInstance then
        IMSDKHelperInstance:GetBindInfo()
      end
    end)
    Unbind_Mgr.SyncUnbindData()
  else
    if errcode == 881000 then
      ShowNotice(7375)
    elseif errcode == 881001 then
      ShowNotice(7376)
    elseif errcode == 881002 then
      ShowNotice(7374)
    elseif errcode == 881007 then
      ShowNotice(7379)
    elseif errcode == 100151003 or errcode == 881010 then
      ShowNotice(9899)
    else
      ShowNotice(7377)
    end
    if errcode == 881012 or errcode == 881016 then
      Unbind_Mgr.SyncUnbindData()
    end
  end
end
function LobbyHandler.send_set_knapsack_pos_show_req(type, bShow)
  NetManager.SendPkg(1521143914, type, bShow)
end
function LobbyHandler.on_set_knapsack_show_rsp(res, bShow)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.set_knapsack_show_rsp(res, bShow)
end
function LobbyHandler.send_get_replay_downstream_urls_req()
  NetManager.SendPkg(790892615)
end
function LobbyHandler.on_get_replay_downstream_urls_rsp(list)
  local LobbyLogicOB = require("client.slua.logic.lobby.logic_lobby_ob")
  LobbyLogicOB.get_replay_downstream_urls_rsp(list)
end
function LobbyHandler.send_get_official_media()
  NetManager.SendPkg(1338657196)
end
function LobbyHandler.on_get_official_media_rsp(ok, media_tb)
end
function LobbyHandler.on_please_create_role(defaultWearInfo, newGuideSwitch)
  LobbySystem.on_please_create_role(defaultWearInfo, newGuideSwitch)
end
function LobbyHandler.on_sync_my_plat_name(nickname)
  LobbySystem.on_sync_my_plat_name(nickname)
end
function LobbyHandler.send_create_role_request(roleName, sex, headId, hairID, deviceInfoList, nation, beard_info, isUseSocialAvatar, b)
  log(bWriteLog and string.format("[LobbyHandler] isUseSocialAvatar : %s", isUseSocialAvatar))
  NetManager.SendPkg(2073891688, roleName, sex, headId, hairID, deviceInfoList, nation, beard_info, isUseSocialAvatar, b)
end
function LobbyHandler.on_create_role_respond(ret)
  LobbySystem.on_create_role_respond(ret)
end
function LobbyHandler.on_sync_base_info(roleData)
  log(bWriteLog and "LobbyHandler.on_sync_base_info")
  if false then
    log_tree("roleData = ", roleData)
  end
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.WaitSyncBaseInfo)
  LobbySystem.on_sync_base_info(roleData)
end
function LobbyHandler.on_sync_player_ban(banData)
  LobbySystem.on_sync_player_ban(banData)
end
function LobbyHandler.on_re_match_sync(match_Info)
  LobbySystem.on_reconnect_sync_matchInfo(match_Info)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:OnSyncMatchInfo(match_Info)
end
function LobbyHandler.on_remind_window_pop(title, content)
  LobbySystem.on_remind_window_pop(title, content)
end
function LobbyHandler.on_modify_role_face_respond(ret)
  LobbySystem.on_modify_role_face_respond(ret)
end
function LobbyHandler.send_batch_buy_avatar_features_req(list)
  NetManager.SendPkg(1041006383, list)
end
function LobbyHandler.on_batch_buy_avatar_features_rsp(ret, list, avatar_feature_list, req_list)
  LobbySystem.batch_buy_avatar_features_rsp(ret, list, avatar_feature_list, req_list)
end
function LobbyHandler.send_update_buy_avatar_features_req()
  NetManager.SendPkg(1941756295)
end
function LobbyHandler.on_update_buy_avatar_features_rsp(ret, avatar, avatar_feature_list)
  LobbySystem.update_buy_avatar_features_rsp(ret, avatar, avatar_feature_list)
end
function LobbyHandler.on_avatar_feature_notify(avatar_feature_list, new_activate_avatar_list)
  LobbySystem.avatar_feature_notify(avatar_feature_list, new_activate_avatar_list)
end
function LobbyHandler.send_fetch_nation_switch_req()
  NetManager.SendPkg(852691120)
end
function LobbyHandler.on_fetch_nation_switch_res(info)
  LobbySystem.on_fetch_nation_switch_res(info)
end
function LobbyHandler.on_gm_version(msg)
  LobbySystem.respGMVersion(msg)
end
function LobbyHandler.on_notify_get_rela_err(res)
  LobbySystem.on_relation_chain_error(res)
end
function LobbyHandler.on_notice_some_no_map(no_map_uids)
  LobbySystem.notice_some_no_map(no_map_uids)
end
function LobbyHandler.send_room_kick_no_map_req(room_id)
  NetManager.SendPkg(1049156263, room_id)
end
function LobbyHandler.on_room_kick_no_map_rsp(res)
  LobbySystem.room_kick_no_map_rsp(res)
end
function LobbyHandler.on_client_trace(client_trace)
  LobbySystem.client_trace(client_trace)
end
function LobbyHandler.send_depot_get_default_ware_req()
  NetManager.SendPkg(1142862887)
end
function LobbyHandler.on_depot_get_default_ware_rsp(wearInfo)
  LobbySystem.on_depot_get_default_ware_rsp(wearInfo)
end
function LobbyHandler.on_need_vietnam_user_extry_info()
end
function LobbyHandler.on_pet_module_close_rsp()
  LobbySystem.on_pet_module_close_rsp()
end
function LobbyHandler.send_get_client_basic_cfg()
  NetManager.SendPkg(1474252032)
end
function LobbyHandler.send_on_match_cancel_req()
  NetManager.SendPkg(2142824954)
end
function LobbyHandler.on_on_match_cancel_res(msg, userid, krjp_rematch)
  LobbySystem.on_match_cancel_rsp(msg, userid, krjp_rematch)
end
function LobbyHandler.send_report_system_entrance_info_req(entrance_info)
  log_tree(bWriteLog and "LobbyHandler.send_report_system_entrance_info_req entrance_info", entrance_info)
  NetManager.SendPkg(577982243, entrance_info)
end
function LobbyHandler.on_report_system_entrance_info_rsp(err_code, data)
  log(bWriteLog and string.format("LobbyHandler.on_report_system_entrance_info_rsp, err_code:%s", err_code))
  log_tree(bWriteLog and "LobbyHandler.send_report_system_entrance_info_req data", data)
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  logic_lobby_system_extension:on_report_system_entrance_info_rsp(err_code, data)
end
function LobbyHandler.on_loadpic_cfg_refresh(serverTableSetTime)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.loadpic_cfg_refresh(serverTableSetTime)
end
function LobbyHandler.send_get_account_bind_req()
  NetManager.SendPkg(2033295399)
end
function LobbyHandler.on_get_account_bind_rsp(is_need_show, nation_code, mobile, email, noschat_id, facebook_id, is_need_show_parent, parent_nation_code, parent_mobile, button_type, change_parent_mobile_url, next_change_time)
  local logic_information_bind = require("client.logic.setting.logic_information_bind")
  logic_information_bind.get_account_bind_rsp(is_need_show, nation_code, mobile, email, noschat_id, facebook_id, is_need_show_parent, parent_nation_code, parent_mobile, button_type, change_parent_mobile_url, next_change_time)
end
function LobbyHandler.send_get_backup_ip_req(count)
  NetManager.SendPkg(1337107063, count)
end
function LobbyHandler.on_get_backup_ip_rsp(res, ip_table)
  if res ~= 0 then
    log(bWriteLog and "on_get_backup_ip_rsp errorcode = " .. tostring(res))
    return
  end
  local logic_login_backup = require("client.logic.login.logic_login_backup")
  logic_login_backup.HandleLobbyServerIPs(ip_table)
end
function LobbyHandler.send_agree_new_privacy_policy(bAgree, area)
  NetManager.SendPkg(187819879, bAgree, area)
end
function LobbyHandler.on_get_agree_new_privacy_policy(err)
  log(bWriteLog and "creepy err" .. err)
end
function LobbyHandler.send_enter_big_event()
  NetManager.SendPkg(1619279154)
end
function LobbyHandler.send_quit_big_event()
  NetManager.SendPkg(2017227285)
end
function LobbyHandler.send_agree_new_privacy_policy_req(bAgree, area)
  NetManager.SendPkg(187819879, bAgree, area)
end
function LobbyHandler.on_agree_new_privacy_policy_rsp(errcode)
end
function LobbyHandler.send_get_top_red_point_req()
  NetManager.SendPkg(1945622690)
end
function LobbyHandler.on_top_red_point_notify(top_red_point_info, type, subtype)
  local lobbyLogic = require("client.slua.logic.lobby.logic_lobby_main")
  lobbyLogic.on_top_red_point_notify(top_red_point_info, type, subtype)
end
function LobbyHandler.send_close_top_red_point_req(type)
  NetManager.SendPkg(159427895, type)
end
function LobbyHandler.on_close_top_red_point_rsp(err, type)
  local lobbyLogic = require("client.slua.logic.lobby.logic_lobby_main")
  lobbyLogic.on_close_top_red_point_rsp(err, type)
end
function LobbyHandler.send_lobby_stay_time_report_req(report_uid, enter_lobby_num, battle_return_lobby_num, lobby_stay_time)
  NetManager.SendPkg(1844810238, report_uid, enter_lobby_num, battle_return_lobby_num, lobby_stay_time)
end
function LobbyHandler.on_do_sync_base_info(base_info)
  LobbySystem.on_do_sync_base_info(base_info)
end
function LobbyHandler.on_sync_depot_info(depot)
  log(bWriteLog and "LobbyHandler.on_sync_depot_info")
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  depot.items = {
    depot.items
  }
  logic_wardrobe_new.on_sync_depot_info(depot)
end
function LobbyHandler.on_sync_depot_item_info(cur_item_cnt, items, total_cnt)
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe_new.on_sync_depot_item_info(cur_item_cnt, items, total_cnt)
end
function LobbyHandler.on_sync_social_avatar(avatarURL)
  log(bWriteLog and "[CreateRoleUI] Set social Avatar " .. tostring(avatarURL))
  LobbySystem.AvatarURL = avatarURL
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GET_AVATAR_URL)
end
function LobbyHandler.send_report_loading_pic_req(loading_pic_id)
  NetManager.SendPkg(1900475179, loading_pic_id)
end
function LobbyHandler.on_add_battle_item_notify(itemid, count, MaxCount, type, can_into_depot)
  LobbySystem.On_add_battle_item_notify(itemid, count, MaxCount, type, can_into_depot)
end
function LobbyHandler.send_gm_mtr_begin(destination, ttl, snt)
  NetManager.SendPkg(1639504053, destination, ttl, snt)
end
function LobbyHandler.on_mtr_begin(destination, ttl, snt)
  LobbySystem.on_mtr_begin(destination, ttl, snt)
end
function LobbyHandler.send_mtr_report(status, result)
  NetManager.SendPkg(2101584442, status, result)
end
function LobbyHandler.send_client_timeout_report_req(req, delay, extra)
  local extra = {}
  if delay then
    extra.report_type = 2
    extra.explicit_loading_time = delay
  else
    extra.report_type = 1
  end
  local TimeUtil = require("client.common.time_util")
  extra.time_stamp = TimeUtil.GetServerTimeInSec()
  if req == "heart_beat" then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local timeOutRec = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNetTimeOut) or {}
    extra.no_rsp_count = 1
    for k, v in pairs(timeOutRec) do
      if tonumber(k) and tonumber(extra.time_stamp) and tonumber(k) < tonumber(extra.time_stamp) then
        extra.no_rsp_count = extra.no_rsp_count + 1
      end
    end
    timeOutRec[extra.time_stamp] = true
    PlayerPrefsSystem.SaveTableToFile_N(timeOutRec, PlayerPrefsSystem.ePlayerPrefsType.eNetTimeOut)
  end
  local logic_lobby_ping_report = require("client.slua.logic.match.logic_lobby_ping_report")
  if logic_lobby_ping_report.GetLobbyDelay then
    delay = logic_lobby_ping_report.GetLobbyDelay()
  end
  NetManager.SendPkg(1368962459, req, delay, extra)
end
function LobbyHandler.on_dalay_ban_text(msg)
  LobbySystem.on_dalay_ban_text_rsp(msg)
end
function LobbyHandler.on_privacy_policy_pop_up(tips_text, ok_button_text, cancel_button_text, region)
  if tips_text and tips_text ~= "" then
    log(bWriteLog and "LobbyHandler.on_privacy_policy_pop_up tips_text = " .. tips_text)
    local title = LocUtil.GetLocalizeResStr(5077)
    local ok = ""
    if ok_button_text and ok_button_text ~= "" then
      ok = ok_button_text
    else
      ok = LocUtil.GetLocalizeResStr(117035)
    end
    local cancel = ""
    if cancel_button_text and cancel_button_text ~= "" then
      cancel = cancel_button_text
    else
      cancel = LocUtil.GetLocalizeResStr(4111)
    end
    local clickOkCallback = function()
      LobbyHandler.send_agree_new_privacy_policy(true, region)
    end
    local clickCancelCallback = function()
      LobbyHandler.send_agree_new_privacy_policy(false, region)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tips_text, clickOkCallback, clickCancelCallback, ok, cancel)
  end
end
function LobbyHandler.on_posidon_update_ntf(res_list)
  if Client.bEditorSkipDownload then
    return
  end
  local decrypt_data = Client.Tea2Decrypt(res_list)
  local unpacked_res_list = slua.LuaArchiverDecode(LuaStateWrapper, decrypt_data)
  if unpacked_res_list == nil or next(unpacked_res_list) == nil then
    return
  end
  local invalid = {}
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    log(bWriteLog and "Something Lite")
    invalid = Client.CheckFilesInPakLite(unpacked_res_list)
  else
    log(bWriteLog and "Something Normal")
    invalid = Client.CheckFilesInPak(unpacked_res_list)
  end
  if invalid and next(invalid) then
    for _, v in ipairs(invalid) do
      log(bWriteLog and "Find Something:" .. tostring(v))
      Client.UnmountPakFile(v)
      Client.DeleteFile(v)
      Client.OnPakFileCRCCheck(v)
    end
    local tip = LocUtil.GetLocalizeResStr(25147)
    local title = LocUtil.GetLocalizeResStr(301137)
    local time_ticker = require("common.time_ticker")
    log(bWriteLog and "Trigger Req CHK List")
    time_ticker.AddTimerOnce(1, function()
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, tip, function()
        GameStatus.QuitGame()
        return true
      end)
    end)
  else
    log(bWriteLog and "Doing Something right")
  end
end
function LobbyHandler.on_anchor_white_cfg_notify(belong_warzone, warzone_pswd_cfg)
  log_tree("on_anchor_white_cfg_notify====belong_warzone", belong_warzone)
  log_tree("on_anchor_white_cfg_notify====warzone_pswd_cfg", warzone_pswd_cfg)
  local LobbyLogicOB = require("client.slua.logic.lobby.logic_lobby_ob")
  LobbyLogicOB.GetAnchor_White_Cfg_Notify(belong_warzone, warzone_pswd_cfg)
end
function LobbyHandler.send_modify_newbie_info_req(roleName, sex, headId, hairID, deviceInfoList, nation, beard_info, isUseSocialAvatar, b)
  NetManager.SendPkg(1951187399, roleName, sex, headId, hairID, deviceInfoList, nation, beard_info, isUseSocialAvatar, b)
end
function LobbyHandler.on_modify_newbie_info_rsp(newbie_info, err_code)
  log(bWriteLog and "LobbyHandler.on_modify_newbie_info_rsp " .. tostring(err_code))
  if err_code == nil or err_code == 0 then
    LobbySystem.UpdateNewbieRoleInfo(newbie_info)
    local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
    logicCreateRole.SetNewGuideMatchTimeOut(false)
    logicCreateRole.OnCloseAvatarResetPanel()
  else
    logic_connection_waiting:Hide(1)
    if err_code == 503004 then
      ShowNotice(29920)
    elseif err_code == 100000001 then
    elseif err_code == 503005 then
      ShowNotice(err_code)
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_CREATEROLE_NAMEREPEAT)
    elseif err_code == 503014 then
      ShowNotice(9001003)
    else
      ShowNotice(err_code)
    end
    if newbie_guide_errcode_name[err_code] then
      local StatManager = import("StatManager")
      log(bWriteLog and "[stat] report event 28")
      StatManager.GetInstance():ReportEventWithNoParam(28, true)
    end
  end
end
function LobbyHandler.on_notify_mil_label_changed(old_label, new_label, mail_id, expire_info, is_flag_visible, need_notify_player, cb_ext_params)
  LobbySystem.ShowIsolationBanMsg(old_label, new_label, mail_id, expire_info, is_flag_visible, need_notify_player, cb_ext_params)
end
function LobbyHandler.on_team_change_type_mil_ban_notify(request_mode, target_mode)
  LobbySystem.ShowIsolationTeamChangeNotify(request_mode, target_mode)
end
function LobbyHandler.send_refresh_account_bind_req(op_type, channel_type)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ACCOUNT_BIND_BY_SERVER_SWITCH_ID)
  if bSwitch then
    log(bWriteLog and string.format("LobbyHandler.send_refresh_account_bind_req, bSwitch:%s", bSwitch))
    return
  end
  NetManager.SendPkg(975101514, op_type, channel_type)
end
function LobbyHandler.send_check_account_bind_info_req(langType, bindType, is_real_click_bind)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ACCOUNT_BIND_BY_SERVER_SWITCH_ID)
  if bSwitch then
    log(bWriteLog and string.format("LobbyHandler.send_check_account_bind_info_req, bSwitch:%s", bSwitch))
    return
  end
  log(bWriteLog and "[accountbinding]send_check_account_bind_info_req->langType: " .. tostring(langType) .. " , bindType: " .. tostring(bindType))
  NetManager.SendPkg(316784120, langType, bindType, is_real_click_bind)
end
function LobbyHandler.on_check_account_bind_info_res(ret, bindType, expireTime)
  if ret == 100150049 then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  log(bWriteLog and "[accountbinding]on_check_account_bind_info_res->ret: " .. tostring(ret) .. " , bindType: " .. tostring(bindType) .. " , expireTime: " .. tostring(expireTime))
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_BIND_CHECK_RSP, ret, bindType, expireTime)
end
function LobbyHandler.on_social_unbind_tips_notify(channel, apply_ts)
  local TimeUtil = require("client.common.time_util")
  local restTime = TimeUtil.GetDeltaTimeWithCurTime(apply_ts)
  if restTime <= 0 then
    restTime = 1
  end
  local expireStr = TimeUtil.GetTimeLengthStr(restTime, false)
  ShowNotice(LocUtil.LocalizeResFormat(34163, expireStr))
end
function LobbyHandler.send_get_unbind_social_info_req()
  NetManager.SendPkg(1641273799)
end
function LobbyHandler.on_get_unbind_social_info_rsp(err, fast_unbind_info)
  log(bWriteLog and string.format("LobbyHandler.on_get_unbind_social_info_rsp, err:%s", err))
  log_tree(bWriteLog and "LobbyHandler.on_get_unbind_social_info_rsp fast_unbind_info", fast_unbind_info)
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  logic_account_sensitive_aciton:on_get_unbind_social_info_rsp(err, fast_unbind_info)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_FAST_UNBIND, err, fast_unbind_info)
end
function LobbyHandler.send_on_hades_update_rsp(param_list)
  log(bWriteLog and "leof Hade Update rsp")
  NetManager.SendPkg(1072186713, param_list)
end
function LobbyHandler.on_on_hades_update_ntf(check_list)
  log(bWriteLog and "Hade Update ntf")
  local magic = "7vu#CH5aJjs1Jjj5"
  local decrypt_data = Client.Tea2Decrypt(check_list, magic)
  local unpacked_chk_list = slua.LuaArchiverDecode(LuaStateWrapper, decrypt_data)
  if next(unpacked_chk_list) == nil then
    return
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  local chk_res = {}
  local SavedPrefix = ScriptHelperClient.ProjectSavedDir() .. "Paks/"
  local ContentPrefix = ScriptHelperClient.ProjectContentDir() .. "Paks/"
  local PurifiedRes = false
  for filename, param in pairs(unpacked_chk_list) do
    log(bWriteLog and "Filename " .. tostring(filename))
    if ScriptHelperClient.FullPathFileExist(SavedPrefix .. filename) or ScriptHelperClient.FullPathFileExist(ContentPrefix .. filename) then
      for no, blk in pairs(param) do
        local CRC = ScriptHelperClient.GetBlockCRC(filename, blk[1], blk[2])
        local hex_CRC = string.format("%x", CRC)
        if hex_CRC ~= blk[3] then
          if chk_res[filename] == nil then
            chk_res[filename] = {}
          end
          chk_res[filename][no] = {
            blk[1],
            blk[2],
            hex_CRC
          }
          log(bWriteLog and "Find Something zeus")
          if blk[4] == 1 then
            PurifiedRes = true
            ScriptHelperClient.UnmountPakFile(SavedPrefix .. filename)
            if Client.GetDevicePlatformName() == "Android" then
              ScriptHelperClient.UnmountPakFile("ShadowTrackerExtra/Content/Paks/" .. filename)
            else
              ScriptHelperClient.UnmountPakFile(ContentPrefix .. filename)
            end
            ScriptHelperClient.DeleteFile(SavedPrefix .. filename)
            ScriptHelperClient.DeleteFile(ContentPrefix .. filename)
            Client.OnPakFileCRCCheck(SavedPrefix .. filename)
            Client.OnPakFileCRCCheck(ContentPrefix .. filename)
          else
            log(bWriteLog and "hades without purify")
          end
        end
      end
    end
  end
  if next(chk_res) and PurifiedRes then
    local tip = LocUtil.GetLocalizeResStr(25147)
    local title = LocUtil.GetLocalizeResStr(301137)
    local time_ticker = require("common.time_ticker")
    log(bWriteLog and "Trigger Req CHK List")
    time_ticker.AddTimerOnce(1, function()
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, tip, function()
        GameStatus.QuitGame()
        return true
      end)
    end)
  end
  local packed_chk_list = slua.LuaArchiverEncode(LuaStateWrapper, chk_res)
  local encrypt_data = Client.Tea2Encrypt(packed_chk_list, magic)
  LobbyHandler.send_on_hades_update_rsp(encrypt_data)
end
function LobbyHandler.send_on_zeus_update_rsp(param_list, reason)
  log(bWriteLog and "leof zeus Update rsp")
  NetManager.SendPkg(405316045, param_list, reason)
end
function LobbyHandler.on_on_zeus_update_ntf(check_list, reason)
  log(bWriteLog and "zeus Update ntf")
  local magic = "7vu#CH5aJjs1Jjj5"
  local decrypt_data = Client.Tea2Decrypt(check_list, magic)
  local unpacked_chk_list = slua.LuaArchiverDecode(LuaStateWrapper, decrypt_data)
  if not unpacked_chk_list then
    return
  end
  if not next(unpacked_chk_list) then
    return
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  local SavedPrefix = ScriptHelperClient.ProjectSavedDir() .. "Paks/"
  local ContentPrefix = ScriptHelperClient.ProjectContentDir() .. "Paks/"
  local chk_res = {}
  for filename, param in pairs(unpacked_chk_list) do
    log(bWriteLog and "Filename " .. tostring(filename))
    if ScriptHelperClient.FullPathFileExist(SavedPrefix .. filename) or ScriptHelperClient.FullPathFileExist(ContentPrefix .. filename) then
      for no, blk in pairs(param) do
        local CRC = ScriptHelperClient.GetBlockCRC(filename, blk[1], blk[2])
        local hex_CRC = string.format("%x", CRC)
        if chk_res[filename] == nil then
          chk_res[filename] = {}
        end
        chk_res[filename][no] = {
          blk[1],
          blk[2],
          hex_CRC
        }
      end
    end
  end
  local packed_chk_list = slua.LuaArchiverEncode(LuaStateWrapper, chk_res)
  local encrypt_data = Client.Tea2Encrypt(packed_chk_list, magic)
  LobbyHandler.send_on_zeus_update_rsp(encrypt_data, reason)
end
function LobbyHandler.send_report_net_trace_infos(trace_tbl)
  NetManager.SendPkg(1071989376, trace_tbl)
end
function LobbyHandler.send_validate_nickname_req(nickname)
  NetManager.SendPkg(2025474135, nickname)
end
function LobbyHandler.on_validate_nickname_rsp(err_code, nickname)
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  logicCreateRole.proc_validate_nickname_rsp(err_code, nickname)
end
function LobbyHandler.send_get_valid_nickname_list_req(lang, nickname)
  NetManager.SendPkg(1242115143, lang, nickname)
end
function LobbyHandler.on_get_valid_nickname_list_rsp(err_code, nick_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  logicCreateRole.proc_get_valid_nickname_list_rsp(nick_list)
end
function LobbyHandler.send_set_custom_presentation_req(custom_presentation)
  NetManager.SendPkg(1286431279, custom_presentation)
end
function LobbyHandler.on_set_custom_presentation_rsp(err_code, custom_presentation)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "LobbyHandler.on_set_custom_presentation_rsp", custom_presentation)
  local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
  logic_custom_presentation:SetData(custom_presentation)
  ShowNotice(LocUtil.GetLocalizeResStr(79776))
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CUSTOM_PRESENTATION_CHANGE)
  UIManager.CloseUI(UIManager.UI_Config.Lobby_RoleInfo_CustomPresentation_Popup_UIBP)
end
function LobbyHandler.on_client_timeout_report_rsp(err_code, extra)
end
function LobbyHandler.send_newbie_createrole_get_rewards_req(reward_id)
  NetManager.SendPkg(2092791295, reward_id)
end
function LobbyHandler.on_newbie_createrole_get_rewards_rsp(err_code, reward_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local wardrobeClothesData = wardrobe_data:GetHallDepotItemDataByResID(reward_id)
  if not wardrobeClothesData then
    log_warning(bWriteLog and "LobbyHandler.on_newbie_createrole_get_rewards_rsp wardrobe not have item")
    return
  end
  local readyToPutOnID = wardrobeClothesData.insID
  local tRoleData = AvatarData.GetRoleWear()
  if tRoleData and tRoleData[1] then
    local hasPutOnId = tRoleData[1]
    if hasPutOnId == readyToPutOnID then
      log(bWriteLog and "LobbyHandler.on_newbie_createrole_get_rewards_rsp has put on")
      return
    end
  end
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogic:wardrobe_puton_req(readyToPutOnID)
end
function LobbyHandler.send_get_nick_name_for_register_req()
  NetManager.SendPkg(746503)
end
function LobbyHandler.on_get_nick_name_for_register_rsp(err_code, nickname)
  log(bWriteLog and string.format("LobbyHandler.on_get_nick_name_for_register_rsp, err_code:%s, nickname:%s", err_code, nickname))
  if err_code ~= 0 then
    return
  end
  if not nickname or nickname == "" then
    return
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GET_PLATFORM, nickname)
end
function LobbyHandler.send_commerce_entrance_info_req()
  NetManager.SendPkg(509964007)
end
function LobbyHandler.on_commerce_entrance_info_rsp(err_code, ret_info)
  log(bWriteLog and "LobbyHandler.on_commerce_entrance_info_rsp err_code = " .. tostring(err_code))
  log_tree(bWriteLog and "LobbyHandler.on_commerce_entrance_info_rsp ret_info", ret_info)
  if err_code ~= 0 then
    return
  end
  local logic_lobby_mid_entrance = require("client.slua.logic.lobby.Mid.logic_lobby_mid_entrance")
  logic_lobby_mid_entrance.SaveCommerceEntranceInfo(ret_info)
end
function LobbyHandler.send_report_pgs_info_req(login_info)
  NetManager.SendPkg(355550859, login_info)
end
function LobbyHandler.on_notify_get_pgs_info()
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  logic_store_game_interface:NotifyGetPGSLoginInfo()
end
function LobbyHandler.on_report_pgs_info_rsp(err_code, battle_ids)
  log(bWriteLog and "LobbyHandler.on_report_pgs_info_rsp err_code = " .. tostring(err_code))
  log_tree("LobbyHandler.on_report_pgs_info_rsp battle_ids", battle_ids)
end
function LobbyHandler.send_get_wifi_lock_info_req()
  NetManager.SendPkg(939991079)
end
function LobbyHandler.on_get_wifi_lock_info_rsp(info)
  log_tree(bWriteLog and "LobbyHandler.on_get_wifi_lock_info_rsp info", info)
  local WifiLockSystem = require("client.slua.logic.wifi_lock.logic_wifi_lock")
  WifiLockSystem.OnGetWifiLockInfoRsp(info)
end
return LobbyHandler