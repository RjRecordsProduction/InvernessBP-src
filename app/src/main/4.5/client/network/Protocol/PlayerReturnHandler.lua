local NetManager = require("client.network.comm.NetManager")
local PlayerReturnHandler = {}
function PlayerReturnHandler.send_backuser_get_login_reward_info_req()
  NetManager.SendPkg(586049281)
end
function PlayerReturnHandler.on_backuser_get_login_reward_info_notify(res, info, reward_list, path)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_login_reward_info_notify, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_login_reward_info_notify info", info)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_login_reward_info_notify reward_list", reward_list)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_login_reward_info_notify, path:%s", path))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_login_reward_info_notify(info, reward_list, path)
end
function PlayerReturnHandler.send_backuser_get_login_reward_req(index)
  log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_get_login_reward_req, index:%s", index))
  NetManager.SendPkg(252265336, index)
end
function PlayerReturnHandler.on_backuser_get_login_reward_res(res, index)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_login_reward_res, res:%s", res))
  log(bWriteLog and string.format("PlayerReturnHandler\227\128\130on_backuser_get_login_reward_res, index:%s", index))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_login_reward_res(index)
  logic_player_return.on_back_user_report_event(index)
end
function PlayerReturnHandler.send_backuser_get_task_list_req()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "PlayerReturnHandler.send_backuser_get_task_list_req activity end")
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_CLOSE)
    return
  end
  NetManager.SendPkg(127275688)
end
function PlayerReturnHandler.on_backuser_get_task_list_res(res, task_list, ext_info, active_cfg, is_flush_task_per_day, task_reward_cfg)
  local logic_come_back_task = require("client.slua.logic.player_return.logic_come_back_task")
  logic_come_back_task.on_backuser_get_task_list_res(res, task_list, ext_info, active_cfg, is_flush_task_per_day, task_reward_cfg)
end
function PlayerReturnHandler.send_backuser_start_req(uids)
  NetManager.SendPkg(958743374, uids)
end
function PlayerReturnHandler.send_backuser_get_user_gift_req()
  NetManager.SendPkg(1547294056)
end
function PlayerReturnHandler.on_backuser_get_user_gift_res(res, reward_list)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_user_gift_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_user_gift_res reward_list", reward_list)
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_GET_GIFT_RSP, res)
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_user_gift_res(reward_list)
end
function PlayerReturnHandler.send_backuser_get_topup_rebate_info_req()
  NetManager.SendPkg(514035208)
end
function PlayerReturnHandler.on_backuser_get_topup_rebate_info_res(res, info)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_topup_rebate_info_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_topup_rebate_info_res info", info)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_topup_rebate_info_res(info)
end
function PlayerReturnHandler.send_backuser_get_privilege_data_req()
  NetManager.SendPkg(1202334890)
end
function PlayerReturnHandler.on_backuser_get_privilege_data_res(res, data, battle_task_cfg, privi_cfg, day_win_cnt)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_privilege_data_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_privilege_data_res data", data)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_privilege_data_res battle_task_cfg", battle_task_cfg)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_privilege_data_res privi_cfg", privi_cfg)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_privilege_data_res, day_win_cnt:%s", day_win_cnt))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_privilege_data_res(data, battle_task_cfg, privi_cfg, day_win_cnt)
end
function PlayerReturnHandler.send_backuser_battle_task_reward_req(progress)
  log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_battle_task_reward_req, progress:%s", progress))
  NetManager.SendPkg(1896194688, progress)
end
function PlayerReturnHandler.on_backuser_battle_task_reward_res(res, got_indexs)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_battle_task_reward_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_battle_task_reward_res got_indexs", got_indexs)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_battle_task_reward_res(got_indexs)
end
function PlayerReturnHandler.send_back_user_notify_friends_gifts_req(friend_uid_list, friend_num)
  log_tree(bWriteLog and "PlayerReturnHandler.send_back_user_notify_friends_gifts_req friend_uid_list", friend_uid_list)
  log(bWriteLog and "PlayerReturnHandler.send_back_user_notify_friends_gifts_req friend_num = " .. tostring(friend_num))
  NetManager.SendPkg(380976008, friend_uid_list, friend_num)
end
function PlayerReturnHandler.on_back_user_notify_friends_gifts_res(res)
  log(bWriteLog and string.format("PlayerReturnHandler.on_back_user_notify_friends_gifts_res, res:%s", res))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_back_user_notify_friends_gifts_res()
end
function PlayerReturnHandler.on_backuser_data_change_notify(change_type, para1, para2)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_data_change_notify, change_type:%s", change_type))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_data_change_notify para1", para1)
  if change_type == 1 then
    log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_data_change_notify para2", para2)
    local logic_come_back_task = require("client.slua.logic.player_return.logic_come_back_task")
    logic_come_back_task.on_backuser_task_change_notify(para1, para2)
  elseif change_type == 2 then
    log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_data_change_notify, para2:%s", para2))
    local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
    logic_player_return.on_backuser_privilege_change_notify(para1, para2)
  elseif change_type == 3 then
    log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_data_change_notify, para2:%s", para2))
  end
end
function PlayerReturnHandler.send_backuser_get_user_guide_req()
  NetManager.SendPkg(138833858)
end
function PlayerReturnHandler.on_backuser_get_user_guide_res(res, guide_cfg, is_got)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_user_guide_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_user_guide_res guide_cfg", guide_cfg)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_user_guide_res, is_got:%s", is_got))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_user_guide_res(guide_cfg, is_got)
end
function PlayerReturnHandler.send_backuser_get_guide_reward_req()
  NetManager.SendPkg(216425666)
end
function PlayerReturnHandler.on_backuser_get_guide_reward_res(res, item_list)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_guide_reward_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_guide_reward_res item_list", item_list)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_guide_reward_res(item_list)
end
function PlayerReturnHandler.send_backuser_set_guide_finished_req()
  NetManager.SendPkg(1639256104)
end
function PlayerReturnHandler.on_backuser_set_guide_finished_res(res, status)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_set_guide_finished_res, res:%s", res))
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_set_guide_finished_res, status:%s", status))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_set_guide_finished_res(status)
end
function PlayerReturnHandler.send_backuser_get_new_content_req()
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsTabMenuOpen(return_activity_macro.Enum_MenuID.Newpost) then
    log(bWriteLog and "PlayerReturnHandler.send_backuser_get_new_content_req return of not open")
    return
  end
  NetManager.SendPkg(806168712)
end
function PlayerReturnHandler.on_backuser_get_new_content_res(res, content_list)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_new_content_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_new_content_res content_list", content_list)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_new_content_res(content_list)
end
function PlayerReturnHandler.on_backuser_info_notify(res, _)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_info_notify, res:%s", res))
  if res ~= 0 then
    return
  end
  if DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.page_info then
    DataMgr.roleData.back_user_data.page_info[32012] = true
    local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
    logic_longline_task.isShowLongline = DataMgr.roleData.back_user_data.is_longline_task
    if logic_longline_task.isShowLongline and not logic_longline_task.hasReqBackUserData then
      PlayerReturnHandler.send_backuser_get_task_list_req()
      logic_longline_task.hasReqBackUserData = true
    end
  end
end
function PlayerReturnHandler.send_backuser_get_daily_reward_req()
  NetManager.SendPkg(212286032)
end
function PlayerReturnHandler.on_backuser_get_daily_reward_res(res, status, item_list)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_daily_reward_res, res:%s", res))
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_daily_reward_res, status:%s", status))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_daily_reward_res item_list", item_list)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_daily_reward_res(status)
end
function PlayerReturnHandler.on_back_user_daily_battle_award_notify(status)
  log(bWriteLog and string.format("PlayerReturnHandler.on_back_user_daily_battle_award_notify, status:%s", status))
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_back_user_daily_battle_award_notify(status)
end
function PlayerReturnHandler.send_backuser_longline_task_reward_req(reward_type, param)
  log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_longline_task_reward_req, reward_type:%s", reward_type))
  if type(param) == "number" then
    log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_longline_task_reward_req, param:%s", param))
  elseif type(param) == "table" then
    log_tree(bWriteLog and "PlayerReturnHandler.send_backuser_longline_task_reward_req param", param)
  end
  NetManager.SendPkg(171389472, reward_type, param)
end
function PlayerReturnHandler.on_backuser_longline_task_reward_res(res, reward_type, param)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_longline_task_reward_res, res:%s", res))
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_longline_task_reward_res, reward_type:%s", reward_type))
  if type(param) == "number" then
    log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_longline_task_reward_res, param:%s", param))
  elseif type(param) == "table" then
    log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_reward_res param", param)
  end
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  logic_longline_task.on_backuser_longline_task_reward_res(reward_type, param)
end
function PlayerReturnHandler.on_backuser_longline_task_notify(res, task_data, task_list, task_reward_config, week_login_config, score_buy_config, exchange_cfg, inviter_list)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_longline_task_notify, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_notify task_data", task_data)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_notify task_list", task_list)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_notify task_reward_config", task_reward_config)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_notify week_login_config", week_login_config)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_notify score_buy_config", score_buy_config)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_notify exchange_cfg", exchange_cfg)
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_longline_task_notify inviter_list", inviter_list)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
  logic_longline_task.on_backuser_longline_task_notify(task_data, task_list, task_reward_config, week_login_config, score_buy_config, exchange_cfg, inviter_list)
end
function PlayerReturnHandler.send_backuser_get_segment_goal_req()
  NetManager.SendPkg(565436160)
end
function PlayerReturnHandler.on_backuser_get_segment_goal_res(res, goal_info, max_rating, config)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_segment_goal_res, res:%s", res))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_segment_goal_res goal_info", goal_info)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_segment_goal_res, max_rating:%s", max_rating))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_get_segment_goal_res config", config)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return_rank = require("client.slua.logic.player_return.logic_player_return_rank")
  logic_player_return_rank.on_backuser_get_segment_goal_res(res, goal_info, max_rating, config)
end
function PlayerReturnHandler.send_backuser_segment_goal_reward_req(index)
  log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_segment_goal_reward_req, index:%s", index))
  NetManager.SendPkg(1260263176, index)
end
function PlayerReturnHandler.on_backuser_segment_goal_reward_res(res, index)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_segment_goal_reward_res, res:%s", res))
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_segment_goal_reward_res, index:%s", index))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_player_return_rank = require("client.slua.logic.player_return.logic_player_return_rank")
  logic_player_return_rank.on_backuser_segment_goal_reward_res(res, index)
end
function PlayerReturnHandler.send_backuser_get_new_content_task_award_req(task_id)
  log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_get_new_content_task_award_req, task_id:%s", task_id))
  NetManager.SendPkg(1463215475, task_id)
end
function PlayerReturnHandler.on_backuser_get_new_content_task_award_rsp(err_code)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_get_new_content_task_award_rsp, err_code:%s", err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_backuser_get_new_content_task_award_rsp()
end
function PlayerReturnHandler.on_warm_statistic_info_notify(warm_statistic_info)
  log_tree(bWriteLog and "PlayerReturnHandler.on_warm_statistic_info_notify warm_statistic_info", warm_statistic_info)
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.on_warm_statistic_info_notify(warm_statistic_info)
end
function PlayerReturnHandler.send_backuser_select_all_index_req(selects)
  log_tree(bWriteLog and "PlayerReturnHandler.send_backuser_select_all_index_req selects", selects)
  NetManager.SendPkg(1524487050, selects)
end
function PlayerReturnHandler.on_backuser_select_all_index_res(err_code, selects)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_select_all_index_res, err_code:%s", err_code))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_select_all_index_res selects", selects)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if selects then
    local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
    logic_longline_task.UpdateSelectIndex(selects)
  end
end
function PlayerReturnHandler.send_backuser_get_friend_recommend_req()
  NetManager.SendPkg(1658099008)
end
function PlayerReturnHandler.on_backuser_get_friend_recommend_res(ret, is_friend_recommend)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_select_all_index_res, ret:%s", ret))
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_select_all_index_res, is_friend_recommend:%s", is_friend_recommend))
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:on_backuser_get_friend_recommend_res(ret, is_friend_recommend)
end
function PlayerReturnHandler.send_backuser_active_frd_sync_req(uids)
  log_tree(bWriteLog and "PlayerReturnHandler.send_backuser_active_frd_sync_req uids", uids)
  local TableUtil = require("common.table_util")
  if TableUtil.IsDataEqual(uids, DataMgr.roleData.back_user_data.friend_record_data.frd_list) then
    log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_active_frd_sync_req, strCode:%s", "return"))
    return
  end
  NetManager.SendPkg(1244575368, uids)
end
function PlayerReturnHandler.on_backuser_active_frd_sync_res(ret, uid_info_list)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_active_frd_sync_res, ret:%s", ret))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_active_frd_sync_res uid_info_list", uid_info_list)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:on_backuser_active_frd_sync_res(ret, uid_info_list)
end
function PlayerReturnHandler.send_backuser_frd_active_reward_req(frd_uid)
  log(bWriteLog and string.format("PlayerReturnHandler.send_backuser_frd_active_reward_req, frd_uid:%s", frd_uid))
  NetManager.SendPkg(616869992, frd_uid)
end
function PlayerReturnHandler.on_backuser_frd_active_reward_res(ret, frd_uid, itemlist)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_frd_active_reward_res, frd_uid:%s", frd_uid))
  log_tree(bWriteLog and "PlayerReturnHandler.on_backuser_frd_active_reward_res itemlist", itemlist)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:on_backuser_frd_active_reward_res(ret, frd_uid, itemlist)
end
function PlayerReturnHandler.on_notify_seg_protect_times(seg_protect_times)
  log(bWriteLog and string.format("on_notify_seg_protect_times, seg_protect_times:%s", seg_protect_times))
  if DataMgr.roleData.back_user_data then
    DataMgr.roleData.back_user_data.  end
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_SEG_PROTECT_TIMES)
end
function PlayerReturnHandler.on_back_user_score_change_notify(ret_level, ret_score)
  log(bWriteLog and string.format("PlayerReturnHandler.on_back_user_score_change_notify, ret_level:%s", ret_level))
  log(bWriteLog and string.format("PlayerReturnHandler.on_back_user_score_change_notify, ret_score:%s", ret_score))
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:on_back_user_score_change_notify(ret_level, ret_score)
end
function PlayerReturnHandler.send_get_topup_rebate_reward_req(uc_num)
  log(bWriteLog and string.format("PlayerReturnHandler.send_get_topup_rebate_reward_req, uc_num:%s", uc_num))
  NetManager.SendPkg(1850967552, uc_num)
end
function PlayerReturnHandler.on_get_topup_rebate_reward_res(err_code, uc_num, rebate_num)
  log(bWriteLog and string.format("PlayerReturnHandler.on_get_topup_rebate_reward_res, err_code:%s", err_code))
  log(bWriteLog and string.format("PlayerReturnHandler.on_get_topup_rebate_reward_res, uc_num:%s", uc_num))
  log(bWriteLog and string.format("PlayerReturnHandler.on_get_topup_rebate_reward_res, rebate_num:%s", rebate_num))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.play_return_UC_got, uc_num, rebate_num)
  EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_PLAYER_RETURN_BUY_UC_CHANGE)
end
function PlayerReturnHandler.send_get_back_user_welcome_gift_req()
  NetManager.SendPkg(280219496)
end
function PlayerReturnHandler.on_get_back_user_welcome_gift_res(errcode, drop_id)
  log(bWriteLog and string.format("PlayerReturnHandler.on_get_back_user_welcome_gift_res, errcode:%s", errcode))
  log(bWriteLog and string.format("PlayerReturnHandler.on_get_back_user_welcome_gift_res, drop_id:%s", drop_id))
  if errcode ~= 0 then
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_GET_WELCOME_GIFT_RSP, errcode)
    ShowNotice(errcode)
    return
  end
  local _CheckHaveShareItem = function(arrayItemList)
    if not arrayItemList or #arrayItemList <= 0 then
      return
    end
    local ItemGetModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.rare_item_get_module)
    for _, itemData in ipairs(arrayItemList) do
      if ItemGetModule:NeedShare(itemData) then
        return true
      end
    end
    return false
  end
  local onGetChestRsp = function(chest_id, chestinfo)
    if chest_id == drop_id then
      local arrayItemList = {}
      for _, v in ipairs(chestinfo) do
        local arrayItem = {
          res_id = v.DropItemID,
          count = v.DropItemNum,
          expire_ts = v.DropItemTime
        }
        table.insert(arrayItemList, arrayItem)
      end
      local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      local tExtendData
      if not UIManager:GetUI(UIManager.UI_Config.ReturnActivity_Reward_UIBP) then
        tExtendData = {
          fCloseCallback = function()
            local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
            NewFaceSlapSystem:BlockSlap()
            local time_ticker = require("common.time_ticker")
            PlayerReturnHandler.timer = time_ticker.AddTimerLoop(0, function()
              if UIManager.IsAndroidStackEmpty() then
                local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
                if not logic_return_activity_guide:IsHitNewGuide() then
                  logic_player_return.AfterPackageUIFunc()
                end
                NewFaceSlapSystem:ReleaseBlockSlap()
                time_ticker.RemoveTimer(PlayerReturnHandler.timer)
              end
            end, TIMER_INFINITE, 0.2)
          end
        }
      end
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList, false, true, tExtendData)
      EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_COME_BACK_GET_WELCOME_GIFT_RSP, errcode)
      if DataMgr and DataMgr.roleData and DataMgr.roleData.back_user_data then
        DataMgr.roleData.back_user_data.welcome_gift_dropid = nil
      end
    end
  end
  local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
  BasicDataChestTable:GetOrReqData(drop_id, onGetChestRsp)
end
function PlayerReturnHandler.on_client_guide_abtest_notify(client_guide_abtest_cfg)
  log_tree(bWriteLog and "PlayerReturnHandler.on_client_guide_abtest_notify client_guide_abtest_cfg", client_guide_abtest_cfg)
  if not DataMgr then
    log(bWriteLog and "PlayerReturnHandler.on_client_guide_abtest_notify return of 1")
    return
  end
  if not DataMgr.roleData then
    log(bWriteLog and "PlayerReturnHandler.on_client_guide_abtest_notify return of 2")
    return
  end
  if not DataMgr.roleData.back_user_data then
    log(bWriteLog and "PlayerReturnHandler.on_client_guide_abtest_notify return of 3")
    return
  end
  if DataMgr.roleData.back_user_data.client_guide_abtest_cfg then
    log(bWriteLog and "PlayerReturnHandler.on_client_guide_abtest_notify return of 4")
    return
  end
  if client_guide_abtest_cfg and type(client_guide_abtest_cfg) == "table" then
    DataMgr.roleData.back_user_data.  end
end
function PlayerReturnHandler.on_share_card_info_notity(frd_uid, share_card_info)
  log(bWriteLog and string.format("PlayerReturnHandler.on_share_card_info_notity, frd_uid:%s", frd_uid))
  log_tree(bWriteLog and "PlayerReturnHandler.on_share_card_info_notity share_card_info", share_card_info)
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  logic_return_team_recommend:on_share_card_info_notity(frd_uid, share_card_info)
end
function PlayerReturnHandler.on_back_user_guide_profile_notify(profile_id, backuser_guide_type_table)
  log(bWriteLog and string.format("PlayerReturnHandler.on_back_user_guide_profile_notify, profile_id:%s", profile_id))
  log_tree(bWriteLog and "PlayerReturnHandler.on_back_user_guide_profile_notify backuser_guide_type_table", backuser_guide_type_table)
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  logic_return_activity_guide:on_back_user_guide_profile_notify(profile_id, backuser_guide_type_table)
end
function PlayerReturnHandler.send_backuser_client_recommend_frd_req()
  log(bWriteLog and "PlayerReturnHandler.send_backuser_client_recommend_frd_req")
  NetManager.SendPkg(1897663115)
end
function PlayerReturnHandler.on_backuser_client_recommend_frd_rsp(res)
  log(bWriteLog and string.format("PlayerReturnHandler.on_backuser_client_recommend_frd_rsp, res:%s", res))
end
function PlayerReturnHandler.send_back_user_client_recommend_frd_report(uid)
  log(bWriteLog and string.format("PlayerReturnHandler.send_back_user_client_recommend_frd_report, uid:%s", uid))
  NetManager.SendPkg(2013579678, uid)
end
function PlayerReturnHandler.send_backuser_claim_mode_first_battle_reward_req()
  log(bWriteLog and "PlayerReturnHandler:send_backuser_claim_mode_first_battle_reward_req - Claim all rewards")
  NetManager.SendPkg(96733295)
end
function PlayerReturnHandler.on_backuser_claim_mode_first_battle_reward_rsp(err_code, item_list)
  log(bWriteLog and string.format("PlayerReturnHandler:on_backuser_claim_mode_first_battle_reward_rsp - err_code:%s", tostring(err_code)))
  log_tree("PlayerReturnHandler:on_backuser_claim_mode_first_battle_reward_rsp - item_list", item_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function PlayerReturnHandler.on_backuser_mode_first_battle_status_notify(mode_category, is_first_any_mode)
  log(bWriteLog and string.format("PlayerReturnHandler:on_backuser_mode_first_battle_status_notify - mode_category:%s, is_first_any_mode:%s", tostring(mode_category), tostring(is_first_any_mode)))
  local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
  logic_return_activity_first_battle:on_backuser_mode_first_battle_status_notify(mode_category)
end
local reqRsp = {
  send_backuser_get_login_reward_req = "on_backuser_get_login_reward_res",
  send_backuser_get_daily_reward_req = "on_backuser_get_daily_reward_res",
  send_backuser_select_all_index_req = "on_backuser_select_all_index_res",
  send_backuser_client_recommend_frd_req = "on_backuser_client_recommend_frd_rsp",
  send_backuser_claim_mode_first_battle_reward_req = "on_backuser_claim_mode_first_battle_reward_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, PlayerReturnHandler)
return PlayerReturnHandler