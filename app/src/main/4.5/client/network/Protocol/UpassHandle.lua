local NetManager = require("client.network.comm.NetManager")
local UpassHandle = {
  serverRecord = {},
  combatScore = 0
}
function UpassHandle.send_upass_buy_pass_list_req(cli_ver)
  NetManager.SendPkg(1325883315, cli_ver)
end
function UpassHandle.on_upass_buy_pass_list_rsp(buyTable, isBuy, passType, level_limit, svr_ver)
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySystem.upass_buy_pass_list_rsp(buyTable, isBuy, passType, level_limit, svr_ver)
end
function UpassHandle.send_upass_buy_pass_req(buyid, vouchers, cb_reason, fromType)
  NetManager.SendPkg(1905254695, buyid, vouchers, cb_reason, fromType)
end
function UpassHandle.on_upass_buy_pass_rsp(err_code, awards, score, level, before_level, has_reward_score, keep_buy_count, cb_reason, experience_level, refund_infos, continuous_buy)
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySystem.upass_buy_pass_rsp(err_code, awards, score, level, before_level, has_reward_score, keep_buy_count, cb_reason, experience_level, refund_infos, continuous_buy)
end
function UpassHandle.send_upass_new_get_req()
  NetManager.SendPkg(310477219)
end
function UpassHandle.on_upass_new_get_rsp(upass_score, upass_level, res_data)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_new_get_rsp(upass_score, upass_level, res_data)
end
function UpassHandle.send_upass_get_level_award_req(level, is_elite_task, group_id, is_elite_plus)
  log(bWriteLog and string.format("UpassHandle.send_upass_get_level_award_req level = %s, is_elite_task = %s, group_id = %s, is_elite_plus = %s", level, is_elite_task, group_id, is_elite_plus))
  NetManager.SendPkg(774689235, level, is_elite_task, group_id, is_elite_plus)
end
function UpassHandle.on_upass_get_level_award_rsp(res, level, is_elite_task, reward_list, group_id, need_buy_awards, is_elite_plus)
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  UnknowPassAwardSystem.upass_get_level_award_rsp(res, level, is_elite_task, reward_list, group_id, need_buy_awards, is_elite_plus)
end
function UpassHandle.send_upass_get_daily_award_req(task_id)
  NetManager.SendPkg(2129546471, task_id)
end
function UpassHandle.on_upass_get_daily_award_rsp(res, task_id)
end
function UpassHandle.send_upass_get_weekly_award_req(week_index, task_id)
  NetManager.SendPkg(719800359, week_index, task_id)
end
function UpassHandle.on_upass_get_weekly_award_rsp(res, week_index, task_id)
end
function UpassHandle.send_upass_task_batch_reward_req()
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(true)
  NetManager.SendPkg(463912887)
end
function UpassHandle.on_upass_task_batch_reward_rsp(res, total_score)
end
function UpassHandle.send_upass_refreash_daily_req(task_id)
  NetManager.SendPkg(134561319, task_id)
end
function UpassHandle.on_upass_refreash_daily_rsp(res, task_id, new_task_info)
end
function UpassHandle.send_upass_exchange_list_req()
  NetManager.SendPkg(1486771671)
end
function UpassHandle.on_upass_exchange_list_rsp(res, tb, exchange_limit, privilege_info)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.upass_exchange_list_rsp(res, tb, exchange_limit, privilege_info)
end
function UpassHandle.send_upass_exchange_req(exchangeId, item_count, cur_buy_count, vouchers, use_discount)
  NetManager.SendPkg(718709511, exchangeId, item_count, cur_buy_count, vouchers, use_discount)
end
function UpassHandle.on_upass_exchange_rsp(res, id, reward_list, new_buy_count, chest_items)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.upass_exchange_rsp(res, id, reward_list, new_buy_count, chest_items)
end
function UpassHandle.send_upass_quick_level_up_req(buyLevel, curLevel)
  NetManager.SendPkg(1683996007, buyLevel, curLevel)
end
function UpassHandle.on_upass_quick_level_up_rsp(res, score_add, price_cost, upass_score, upass_level, before_level)
end
function UpassHandle.send_upass_batch_get_level_award_req(selects)
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(true)
  NetManager.SendPkg(421664327, selects)
end
function UpassHandle.on_upass_batch_get_level_award_rsp(res, reward_tb, need_buy_awards)
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(false)
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  UnknowPassAwardSystem.upass_batch_get_level_award_rsp(res, reward_tb, need_buy_awards)
end
function UpassHandle.send_upass_change_switch_req(ui, battle_title, battle_show, record_privacy)
  NetManager.SendPkg(1207385755, ui, battle_title, battle_show, record_privacy)
end
function UpassHandle.on_upass_change_switch_rsp(res, switch)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  UnknowPassSystem.  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.SetUnknowPassSwitch(switch)
end
function UpassHandle.send_upass_get_curweek_award_req()
  NetManager.SendPkg(2099462187)
end
function UpassHandle.on_upass_get_curweek_award_rsp(res, reward_list)
end
function UpassHandle.on_upass_score_notify_chg(value, cur_score, cur_level, before_level, reason, pre_prize_score, total_collected_score, acc_score, is_show, experience_level)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.UPassScoreNotifyChg(value, cur_score, cur_level, before_level, reason, pre_prize_score, total_collected_score, acc_score, is_show, experience_level)
end
function UpassHandle.on_sync_upass_score_card_info(score, itemid, count, cur_score, cur_level)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.SyncUpassScoreCardInfo(score, itemid, count, cur_score, cur_level)
end
function UpassHandle.send_upass_get_unclaimed_reward_req()
  NetManager.SendPkg(1190121543)
end
function UpassHandle.on_upass_get_unclaimed_reward_rsp(res, reward_tb)
end
function UpassHandle.on_upass_notify_data_chg()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_notify_data_chg()
end
function UpassHandle.send_upass_buy_score_req(diff_score, cur_level, cur_score, id, vouchers)
  NetManager.SendPkg(1435933251, diff_score, cur_level, cur_score, id, vouchers)
end
function UpassHandle.on_upass_buy_score_rsp(res, score_add, price_cost, upass_score, upass_level, before_level)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_buy_score_rsp(res, score_add, price_cost, upass_score, upass_level, before_level)
end
function UpassHandle.send_upass_daily_award_req()
  NetManager.SendPkg(114807771)
end
function UpassHandle.on_upass_daily_award_rsp(resCode, awardCfg, cur_time)
end
function UpassHandle.on_game_end_show_finish_upass_task(taskId)
end
function UpassHandle.send_upass_buy_level_award_req(award_id)
  NetManager.SendPkg(986269955, award_id)
end
function UpassHandle.on_upass_buy_level_award_rsp(res, award_id, reward_list)
end
function UpassHandle.on_unknown_pass_bonus_rsp(res, bonusId, items)
end
function UpassHandle.send_upass_task_daily_refresh_req(group_id)
  NetManager.SendPkg(602786727, group_id)
end
function UpassHandle.on_upass_task_daily_refresh_rsp(res, group_id, task_left_time, new_task_info)
end
function UpassHandle.send_upass_task_reward_req(group_id)
  NetManager.SendPkg(819311459, group_id)
end
function UpassHandle.on_upass_task_reward_rsp(res, group_id)
end
function UpassHandle.send_upass_task_imm_finish_req(group_id)
  NetManager.SendPkg(1098415899, group_id)
end
function UpassHandle.on_upass_task_imm_finish_rsp(ret, group_id, group, get_reward_num_if_buy)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.upass_task_imm_finish_rsp(ret, group_id, group, get_reward_num_if_buy)
end
function UpassHandle.on_upass_task_share_progress_notify(change_tasks)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.upass_task_share_progress_notify(change_tasks)
end
function UpassHandle.on_upass_game_end_show_tasks_notify(final_tasks)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.upass_game_end_show_tasks_notify(final_tasks)
end
function UpassHandle.on_upass_task_adddition_ntfy(task_id, addition)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.upass_task_adddition_ntfy(task_id, addition)
end
function UpassHandle.send_upass_prime_query_req()
  NetManager.SendPkg(1826564151)
end
function UpassHandle.on_upass_prime_query_rsp(upass_prime_buy, upass_prime_privilege_cfg, continuous_awards_cfg, upass_prime_info, gift_data)
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  UnknowPassPrimeSystem.upass_prime_query_rsp(upass_prime_buy, upass_prime_privilege_cfg, continuous_awards_cfg, upass_prime_info, gift_data)
end
function UpassHandle.send_upass_prime_take_continuous_award_req(type, id)
  NetManager.SendPkg(1056532219, type, id)
end
function UpassHandle.on_upass_prime_take_continuous_award_rsp(err_code, award)
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  UnknowPassPrimeSystem.upass_prime_take_continuous_award_rsp(err_code, award)
end
function UpassHandle.send_upass_prime_take_month_award_req(prime_type, infoID)
  NetManager.SendPkg(92247271, prime_type, infoID)
end
function UpassHandle.on_upass_prime_take_month_award_rsp(err_code, award)
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  UnknowPassPrimeSystem.upass_prime_take_month_award_rsp(err_code, award)
end
function UpassHandle.send_upass_prime_take_first_award_req(prime_type, infoID)
  NetManager.SendPkg(400375079, prime_type, infoID)
end
function UpassHandle.on_upass_prime_take_first_award_rsp(err_code, award)
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  UnknowPassPrimeSystem.upass_prime_take_first_award_rsp(err_code, award)
end
function UpassHandle.on_upass_prime_info_change_notify(prime_data)
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  UnknowPassPrimeSystem.upass_prime_info_change_notify(prime_data)
end
function UpassHandle.send_exit_result()
  NetManager.SendPkg(301058194)
end
function UpassHandle.on_upass_banner_query_rsp(banner_id, banner_type, url, jump, param)
  local UnknowPassSlapSystem = require("client.slua.logic.unknow_pass.NewRPInitFlow.logic_unknowpass_slap")
  UnknowPassSlapSystem.upass_banner_query_rsp(banner_id, banner_type, url, jump, param)
end
function UpassHandle.on_upass_imm_finish_task_rsp(ret, task_id, task_data, get_reward_num_if_buy)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.upass_imm_finish_task_rsp(ret, task_id, task_data, get_reward_num_if_buy)
end
function UpassHandle.send_get_rp_groupbuy_simple_info_req(id_list)
  NetManager.SendPkg(1639341159, id_list)
end
function UpassHandle.on_get_rp_groupbuy_simple_info_rsp(err_code, info, uid_list)
  local unknowpassHandle = require("client.network.Protocol.UpassHandle")
  unknowpassHandle.send_get_invite_red_point_req()
  if err_code ~= 0 then
    log(bWriteLog and "UpassHandle.on_get_rp_groupbuy_simple_info_rsp error_code = " .. err_code)
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local getProfileList = {}
    for i, j in pairs(info) do
      if j.leader_uid and logic_profile:GetLocalProfile(j.leader_uid) == nil then
        table.insert(getProfileList, j.leader_uid)
      end
    end
    if 0 < #getProfileList then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.UPASS_GROUP_BUY, getProfileList, function()
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_REFRESH)
      end)
    end
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.ConvertServerData(info, uid_list)
    if UnknowPassBuyActSystem.bIsReqRecommendData then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_RECOMMEND_INFO_UPDATE)
      UnknowPassBuyActSystem.bIsReqRecommendData = false
    end
  end
end
function UpassHandle.send_get_rp_groupbuy_info_req(id)
  NetManager.SendPkg(501363111, id)
end
function UpassHandle.on_get_rp_groupbuy_info_rsp(err_code, info)
  if err_code ~= 0 then
    log(bWriteLog and "UpassHandle.on_get_rp_groupbuy_info_rsp error_code = " .. err_code)
    UpassHandle.ShowErrorCode(err_code)
  else
    log_tree("UpassHandle.on_get_rp_groupbuy_info_rsp info = ", info)
    local group_id = info.leader_uid
    if info.member then
      table.sort(info.member, function(a, b)
        return (a.join_time or 0) < (b.join_time or 0)
      end)
    end
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.detailInfoList[group_id] = info
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local getProfileList = {}
    for i, j in pairs(info.member) do
      if logic_profile:GetLocalProfile(j.uid) == nil then
        table.insert(getProfileList, j.uid)
      end
    end
    if 0 < #getProfileList then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.UPASS_GROUP_BUY, getProfileList, function()
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_DETAIL_REFRESH)
      end)
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_DETAIL_REFRESH)
    if UnknowPassBuyActSystem.openDetailId == group_id then
      if not UIManager.IsUIShow(UIManager.UI_Config.activity_buy_upass) then
        local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
        ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_BUY_UPASS_ACT, {})
      end
      local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
      local ver = UnknowPassUtil.GetVersionNumber()
      UIManager.ShowUIWithBpPath(UIManager.UI_Config.activity_buy_upass_detail, string.format("/Game/Arts_UI/UnknowPass_BannerActivity/%s/RP_GroupBuy/UnknowPass_TeamContentPopup_UIBP.UnknowPass_TeamContentPopup_UIBP", ver), group_id, UnknowPassBuyActSystem.from)
      UnknowPassBuyActSystem.openDetailId = 0
      UnknowPassBuyActSystem.from = 0
    end
  end
end
function UpassHandle.send_create_rp_groupbuy_req()
  NetManager.SendPkg(437620583)
end
function UpassHandle.on_create_rp_groupbuy_rsp(err_code, id)
  if err_code ~= 0 then
    UpassHandle.ShowErrorCode(err_code)
  else
    ShowNotice(54061)
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.isNewJoin = true
    UnknowPassBuyActSystem.SetProfileGroupID(id)
    UpassHandle.send_get_rp_groupbuy_simple_info_req({id})
    UnknowPassBuyActSystem.HideInviteReddot()
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_JOIN_SUCCESS)
  end
end
function UpassHandle.send_delete_rp_groupbuy_req()
  NetManager.SendPkg(384579463)
end
function UpassHandle.on_delete_rp_groupbuy_rsp(err_code, id)
  if err_code ~= 0 then
    UpassHandle.ShowErrorCode(err_code)
  else
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.InitMyGroupData()
    UnknowPassBuyActSystem.SetProfileGroupID(0)
    UIManager.CloseUI(UIManager.UI_Config.activity_buy_upass_detail)
    ShowNotice(54063)
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_REFRESH)
    UnknowPassBuyActSystem.GetNeedShowReddot()
  end
end
function UpassHandle.send_join_rp_groupbuy_req(id, uid)
  log(bWriteLog and "UpassHandle.send_join_rp_groupbuy_req id = " .. tostring(id))
  NetManager.SendPkg(693555047, id, uid)
end
function UpassHandle.on_join_rp_groupbuy_rsp(err_code, id)
  if err_code ~= 0 then
    UpassHandle.ShowErrorCode(err_code)
  else
    log(bWriteLog and "UpassHandle.on_join_rp_groupbuy_rsp id = " .. tostring(id))
    ShowNotice(LocUtil.LocalizeResFormat(54062))
    UIManager.CloseUI(UIManager.UI_Config.activity_buy_upass_detail)
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.isNewJoin = true
    UnknowPassBuyActSystem.SetProfileGroupID(id)
    UnknowPassBuyActSystem.HideInviteReddot()
    UpassHandle.send_get_rp_groupbuy_simple_info_req({id})
  end
end
function UpassHandle.send_get_rp_groupbuy_friend_invite_list_req()
  NetManager.SendPkg(1863723879)
end
function UpassHandle.on_get_rp_groupbuy_friend_invite_list_rsp(errcode, info)
  if errcode ~= 0 then
    UpassHandle.ShowErrorCode(errcode)
  else
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.friendInviterList = info
    log_tree("UpassHandle.on_get_rp_groupbuy_friend_invite_list_rsp List = ", info)
    UnknowPassBuyActSystem.RefreshInviterList()
  end
end
function UpassHandle.send_invite_all_rp_groupbuy_friend_list_req(uid_list, chat_type, msg_id, chat_content)
  NetManager.SendPkg(886436167, uid_list, chat_type, msg_id, chat_content)
end
function UpassHandle.on_invite_all_rp_groupbuy_friend_list_rsp(errcode, uidList, chat_type, msg_id, chat_content)
  if errcode ~= 0 then
    UpassHandle.ShowErrorCode(errcode)
  else
    local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
    local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
    local channel = chat_macro.Channel.channelPrivate
    log_tree("god test uidList ", uidList)
    if uidList and chat_content then
      for k, v in pairs(uidList) do
        local msgId = channelMain.CacheMsg(chat_content)
        channelMain.on_chat_rsp(NetErrorCode_NONE, msgId, channel, nil, v, chat_content.text)
      end
    end
    ShowNotice(54069)
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_INVITE_REFRESH)
  end
end
function UpassHandle.ShowErrorCode(errcode)
  log(bWriteLog and "UpassHandle.ShowErrorCode error_code = " .. errcode)
  local msgID = 0
  if errcode == 9990024 then
    msgID = 53000
  elseif errcode == 9990025 then
    msgID = 53001
  elseif errcode == 9990026 then
    msgID = 53002
  elseif errcode == 9990027 then
    msgID = 53003
  elseif errcode == 9990028 then
    msgID = 53004
  elseif errcode == 9990029 then
    msgID = 53005
  elseif errcode == 9990030 then
    msgID = 53006
  elseif errcode == 9990031 then
    msgID = 100080025
  end
  if msgID ~= 0 then
    ShowNotice(msgID)
  end
end
function UpassHandle.on_notify_invite_rp_groupbuy_result(error, invite_type, dst_uid)
  log(bWriteLog and "UpassHandle.on_notify_invite_rp_groupbuy_result error = " .. tostring(error))
  if error == 9990030 then
    UpassHandle.ShowErrorCode(error)
  elseif error ~= 0 then
    ShowNotice(100080023)
  else
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    if invite_type == 0 then
      UnknowPassBuyActSystem.InviteListAdd(dst_uid)
    elseif invite_type == 1 then
      UnknowPassBuyActSystem.InviteListAdd(DataMgr.corpsInfo.id)
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_INVITE_REFRESH)
  end
end
function UpassHandle.send_upass_pre_prize_buy_req(cur_index, num)
  NetManager.SendPkg(26087859, cur_index, num)
end
function UpassHandle.on_upass_pre_prize_buy_rsp(err_code, pre_prize, all_awards)
  if err_code ~= 0 then
    UpassHandle.ShowErrorCode(err_code)
  else
    local UnknowPassGiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
    UnknowPassGiftSystem.on_upass_pre_prize_buy_rsp(pre_prize, all_awards)
  end
end
function UpassHandle.send_upass_pre_prize_take_progress_award_req(index, progress)
  NetManager.SendPkg(1532309151, index, progress)
end
function UpassHandle.on_upass_pre_prize_take_progress_award_rsp(err_code, pre_prize, all_awards)
  if err_code ~= 0 then
    ShowNotice(err_code)
  else
    local UnknowPassGiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
    UnknowPassGiftSystem.on_upass_pre_prize_take_progress_award_rsp(pre_prize, all_awards)
  end
end
function UpassHandle.on_upass_pre_prize_score_chg_notify(old_score, cur_score)
  local UnknowPassGiftSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  UnknowPassGiftSystem.on_upass_pre_prize_score_chg_notify(old_score, cur_score)
end
function UpassHandle.send_general_task_week_task_imm_req(week_index, task_group_id)
  log(bWriteLog and "UpassHandle.send_general_task_week_task_imm_req" .. tostring(week_index) .. " " .. tostring(task_group_id))
  NetManager.SendPkg(1697852199, week_index, task_group_id)
end
function UpassHandle.on_general_task_week_task_imm_rsp(err, week_index, task_group_id)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.upass_task_imm_finish_rsp(err)
end
function UpassHandle.send_general_task_week_task_reward_req(week_index, task_group_id)
  NetManager.SendPkg(1322309591, week_index, task_group_id)
end
function UpassHandle.on_general_task_week_task_reward_rsp(err, week_index, task_group_id)
  if err ~= 0 then
    log(bWriteLog and "UpassHandle.on_general_task_week_task_reward_rsp" .. err)
    ShowNotice(err)
    return
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_get_req()
  UpassHandle.send_general_task_sync_all_req()
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.ShowTaskRewardGet(week_index, task_group_id)
end
function UpassHandle.send_general_task_batch_reward_req()
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(true)
  NetManager.SendPkg(1753678399)
end
function UpassHandle.on_general_task_batch_reward_rsp(err, rewards)
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(false)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.on_general_task_batch_reward_rsp(rewards)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_get_req()
end
function UpassHandle.on_general_weekly_active_sync(data)
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_weekly_active_sync(data)
end
function UpassHandle.send_general_weekly_active_award_req(award_id)
  NetManager.SendPkg(823035799, award_id)
end
function UpassHandle.on_general_weekly_active_award_rsp(err, award_id)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_weekly_active_award_rsp(award_id)
end
function UpassHandle.send_general_task_sync_all_req()
  log(bWriteLog and "UpassHandle.send_general_task_sync_all_req")
  NetManager.SendPkg(1768701571)
end
function UpassHandle.on_general_task_sync_all_rsp(data)
  log(bWriteLog and "UpassHandle.on_general_task_sync_all_rsp")
  log_tree("on_general_task_sync_all_rsp ", data)
  local logic_new_day_task = require("client.slua.logic.task.logic_new_day_task")
  logic_new_day_task.GeneralTaskRsp(data)
end
function UpassHandle.on_general_season_active_sync(data)
end
function UpassHandle.send_general_season_active_award_req(award_id)
  NetManager.SendPkg(1154598839, award_id)
end
function UpassHandle.on_general_season_active_award_rsp(err, award_id)
end
function UpassHandle.on_general_task_sync_daily_task_change(daily_task)
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_task_sync_daily_task_change(daily_task)
end
function UpassHandle.send_general_task_daily_task_imm_req(task_id)
  NetManager.SendPkg(1832680243, task_id)
end
function UpassHandle.on_general_task_daily_task_imm_rsp(err, task_id)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_task_daily_task_imm_rsp(task_id)
end
function UpassHandle.send_general_task_daily_task_reward_req(task_id)
  log(bWriteLog and "UpassHandle.send_general_task_daily_task_reward_req task_id = " .. tostring(task_id))
  NetManager.SendPkg(298365831, task_id)
end
function UpassHandle.on_general_task_daily_task_reward_rsp(err, task_id)
  log(bWriteLog and "UpassHandle.on_general_task_daily_task_reward_rsp err = " .. tostring(err) .. " task_id = " .. tostring(task_id))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_task_daily_task_reward_rsp(task_id)
end
function UpassHandle.send_general_task_daily_refresh_req(task_id)
  NetManager.SendPkg(602967111, task_id)
end
function UpassHandle.on_general_task_daily_refresh_rsp(err, old_task_id, new_task_id, task_data, refresh_count)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_task_daily_refresh_rsp(old_task_id, new_task_id, task_data, refresh_count)
end
function UpassHandle.send_general_task_daily_login_reward_req()
  NetManager.SendPkg(1576392915)
end
function UpassHandle.on_general_task_daily_login_reward_rsp(err, ext_err, res_map)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_task_daily_login_reward_rsp(ext_err, res_map)
  UpassHandle.send_get_daily_task_ext_reward_info()
end
function UpassHandle.on_general_task_game_result_notify(active_data, task_list)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.on_general_task_game_result_notify(active_data, task_list)
end
function UpassHandle.send_general_task_week_task_batch_reward_req()
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(true)
  NetManager.SendPkg(589994403)
end
function UpassHandle.on_general_task_week_task_batch_reward_rsp(err, result)
  local rpGift = require("client.slua.logic.unknow_pass.logic_unknowpass_gift")
  rpGift.SetAddFlag(false)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.on_general_task_week_task_batch_reward_rsp(err, result)
end
function UpassHandle.send_get_invite_red_point_req()
  NetManager.SendPkg(928708263)
end
function UpassHandle.on_get_invite_red_point_rsp(errcode, ret)
  log(bWriteLog and "god test on_get_invite_red_point_rsp ret " .. tostring(ret))
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  if ret == 1 then
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.GetNewMessage()
  end
end
function UpassHandle.send_remove_invite_red_point_req()
  NetManager.SendPkg(728070751)
end
function UpassHandle.on_remove_invite_red_point_rsp(errcode)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
end
function UpassHandle.on_general_task_week_task_friend_addition_sync(result)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  for i, v in pairs(result) do
    UnknowPassMissionSystem.upass_task_adddition_ntfy(v.task_id, v.addition)
  end
end
function UpassHandle.on_general_task_week_task_share_progress_sync(result)
  log_tree("on_general_task_week_task_share_progress_sync", result)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  for i, v in pairs(result) do
    UnknowPassMissionSystem.upass_task_share_progress_ntfy(v.task_id, v.share_progress, v.value, v.status)
  end
  EventSystem:postEvent(EVENTTYPE_ACCOUNT, EVENTID_CHANGE_SHARE_PROGRESS)
end
function UpassHandle.send_limited_time_task_sync_req(is_activity_ui)
  log(bWriteLog and "UpassHandle.send_limited_time_task_sync_req, is_activity_ui = " .. tostring(is_activity_ui))
  NetManager.SendPkg(145714887, is_activity_ui)
end
function UpassHandle.on_limited_time_task_sync_rsp(err_code, task_data, limitd_task_award_tip)
  if err_code ~= 0 then
    return
  end
  log_tree("UpassHandle.on_limited_time_task_sync_rsp ", task_data)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.limitedTimeActMission = {}
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  for i, task in pairs(task_data) do
    if task.type == 1 then
      local daily_task_data = {}
      daily_task_data.task_id = task.task_id
      daily_task_data.status = task.status
      daily_task_data.reward_level, daily_task_data.rewards = NewDayTaskSystem.GetTaskRewardCfg(task.reward_id)
      daily_task_data.isLoginAward = false
      daily_task_data.reward_id = task.reward_id
      daily_task_data.cfg_id = task.cfg_id or 1
      daily_task_data.create_time = task.create_time
      daily_task_data.end_time = task.end_time
      daily_task_data.task_type = NewDayTaskSystem.LimitedTimeTaskType
      daily_task_data.finish_value = task.finish_value or 1
      daily_task_data.value = task.value or 0
      daily_task_data.task_pool_index = task.task_pool_index or 0
      daily_task_data.task_pool_total = task.task_pool_total or 0
      daily_task_data.desc = NewDayTaskSystem.GetDailyTaskDesc(task.task_id)
      NewDayTaskSystem.LimitTask = daily_task_data
      log_tree("daily_task_data = ", daily_task_data)
      EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_LIMIT_DATA)
    elseif task.type == 2 then
      local RP_task_data = {}
      RP_task_data.task_id = task.task_id
      RP_task_data.status = task.status
      RP_task_data.reward_level, RP_task_data.rewards = NewDayTaskSystem.GetTaskRewardCfg(task.reward_id)
      RP_task_data.count = RP_task_data.rewards[1] and RP_task_data.rewards[1].res_num or 0
      RP_task_data.isLoginAward = false
      RP_task_data.reward_id = task.reward_id
      RP_task_data.cfg_id = task.cfg_id or 1
      RP_task_data.create_time = task.create_time
      RP_task_data.end_time = task.end_time
      RP_task_data.task_type = 0
      RP_task_data.finish_value = task.finish_value or 1
      RP_task_data.value = task.value or 0
      RP_task_data.desc = NewDayTaskSystem.GetDailyTaskDesc(task.task_id)
      UnknowPassMissionSystem.limitedTimeMission = RP_task_data
      local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
      passReddotMainSystem.UpdateReddot()
    elseif task.type == 3 then
      local Act_task_data = {}
      Act_task_data.task_id = task.task_id
      Act_task_data.status = task.status
      Act_task_data.reward_level, Act_task_data.rewards = NewDayTaskSystem.GetTaskRewardCfg(task.reward_id)
      Act_task_data.count = Act_task_data.rewards[1] and Act_task_data.rewards[1].res_num or 0
      Act_task_data.isLoginAward = false
      Act_task_data.reward_id = task.reward_id
      Act_task_data.cfg_id = task.cfg_id or 1
      Act_task_data.create_time = task.create_time
      Act_task_data.end_time = task.end_time
      Act_task_data.task_type = 0
      Act_task_data.finish_value = task.finish_value or 1
      Act_task_data.value = task.value or 0
      Act_task_data.desc = NewDayTaskSystem.GetDailyTaskDesc(task.task_id)
      table.insert(UnknowPassMissionSystem.limitedTimeActMission, Act_task_data)
      UnknowPassMissionSystem.limitedTimeActMissionRedData = limitd_task_award_tip
    end
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_LIMITMISSION)
  if UnknowPassMissionSystem.limitedTimeActMission and next(UnknowPassMissionSystem.limitedTimeActMission) then
    local changes = {
      idList = {
        [ActivityFixedID.LimitActTask] = true
      },
      typeList = {}
    }
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changes)
  end
end
function UpassHandle.send_limited_time_task_reward_req(cfg_id, task_id)
  NetManager.SendPkg(1835347175, cfg_id, task_id)
end
function UpassHandle.on_limited_time_task_reward_rsp(err_code, task_id, reward_id, task_type)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_warning(bWriteLog and string.format("UpassHandle.on_limited_time_task_reward_rsp. err_code%s, task_id%s, reward_id%s, task_type%s", err_code, task_id, reward_id, task_type))
  local TableUtil = require("common.table_util")
  if task_type == 1 then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    local _, task = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, _task)
      return _task.task_id == task_id
    end)
    if NewDayTaskSystem.LimitTask.task_id == task_id then
      task = NewDayTaskSystem.LimitTask
    end
    if task then
      task.status = 2
      NewDayTaskSystem.ShowReward(task.reward_id)
      NewDayTaskSystem.SortTask(NewDayTaskSystem.DailyTasks)
      local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
      TaskMgrSystem.RefreshLobbyTaskRedDot()
      EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
    end
  elseif task_type == 2 then
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    NewDayTaskSystem.ShowReward(reward_id)
    UpassHandle.send_limited_time_task_sync_req(false)
  else
    local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
    NewDayTaskSystem.ShowReward(reward_id)
    UpassHandle.send_limited_time_task_sync_req(true)
    local changes = {
      idList = {
        [ActivityFixedID.LimitActTask] = true
      },
      typeList = {}
    }
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changes)
  end
end
function UpassHandle.on_limited_task_sync_data_change(sync_data)
  log_tree("UpassHandle.on_limited_task_sync_data_change", sync_data)
  for i, v in pairs(sync_data) do
    if v.type == 1 then
      local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
      for _, task in pairs(NewDayTaskSystem.DailyTasks) do
        if task.task_id == v.task_id then
          task.status = v.status
          task.value = v.value
          break
        end
      end
      NewDayTaskSystem.SortTask(NewDayTaskSystem.DailyTasks)
      if NewDayTaskSystem.LimitTask.task_id == v.task_id then
        NewDayTaskSystem.LimitTask.status = v.status
        NewDayTaskSystem.LimitTask.value = v.value
      end
      EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
    elseif v.type == 2 then
      local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
      local data = UnknowPassMissionSystem.limitedTimeMission
      if next(data) then
        data.status = v.status
        data.value = v.value
      end
    end
  end
end
function UpassHandle.send_upass_get_record_req(target_uid)
  NetManager.SendPkg(1702826087, target_uid)
end
function UpassHandle.on_upass_get_record_rsp(err_code, target_uid, record)
  log(bWriteLog and "UpassHandle.on_upass_get_record_rsp: " .. tostring(err_code) .. tostring(target_uid))
  log_tree("UpassHandle.on_upass_get_record_rsp", record)
  if err_code ~= 0 then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RECORD_INFO_UPDATE, err_code)
    return
  end
  UpassHandle.serverRecord = record
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_RECORD_INFO_UPDATE, err_code, target_uid, record)
end
function UpassHandle.on_notify_upass_value_change(before_cur_value, before_acc_value, change_value, after_cur_value, after_acc_value, change_history, keepBuy)
  log(bWriteLog and " UpassHandle.on_notify_upass_value_change " .. change_value)
  local UnknowPassRecordSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_record")
  UnknowPassRecordSystem.  UnknowPassRecordSystem.  UnknowPassRecordSystem.  UnknowPassRecordSystem.  if UnknowPassSystem.Data and UnknowPassSystem.Data.base then
    UnknowPassSystem.Data.base.keep_buy = keepBuy
  end
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  if not UnknowPassUtil.IsSeriesAStart() and 0 < change_value then
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if PassDataSystem.GetRpResourceDownloadState() ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.UnknowPass_Record_Tips_UIBP, change_value)
  end
end
function UpassHandle.send_upass_select_motion_req(select_map)
  NetManager.SendPkg(130201955, select_map)
end
function UpassHandle.on_upass_select_motion_rsp(err_code, map, got)
  if err_code ~= 0 then
    return
  end
  local Season = UnknowPassSystem.Season
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.UpdateSelectEmotion(map, got)
end
function UpassHandle.send_upass_sync_battle_largess_req()
  NetManager.SendPkg(1495419695)
end
function UpassHandle.on_upass_sync_battle_largess_rsp(sync_data)
  UpassHandle.Battle_Largess = sync_data
end
function UpassHandle.GetLargessMaxCount()
  if not UpassHandle.Battle_Largess or not UpassHandle.Battle_Largess.counters then
    log(bWriteLog and "UpassHandle.GetLargessMaxCount no data")
    return 0
  end
  local type = "CommonRP"
  if UnknowPassSystem.PassType == 2 then
    type = "EliteRP"
  end
  local cfg = CDataTable.GetTable("UnknowPassBuyGiveParamCfg")
  local counters = UpassHandle.Battle_Largess.counters
  log(bWriteLog and "UpassHandle.GetLargessMaxCount " .. tostring(cfg.season_send_limit[type] - counters[1]) .. tostring(cfg.week_send_limit[type] - counters[3]) .. tostring(cfg.day_send_limit[type] - counters[5]) .. tostring(cfg.game_send_limit[type] - counters[7]))
  local min_times = math.min(cfg.season_send_limit[type] - counters[1], cfg.week_send_limit[type] - counters[3], cfg.day_send_limit[type] - counters[5], cfg.game_send_limit[type] - counters[7])
  min_times = math.max(0, min_times)
  log(bWriteLog and "UpassHandle.GetLargessMaxCount result " .. tostring(min_times))
  return min_times
end
function UpassHandle.send_upass_send_battle_largess_req(game_id, recver_uid)
  NetManager.SendPkg(531517531, game_id, recver_uid)
end
function UpassHandle.on_upass_send_battle_largess_rsp(err_code, game_id, recver_uid, left_send_count)
  if err_code == 0 then
    if UnknowPassSystem and UnknowPassSystem.Season >= 59 and UnknowPassSystem.IsBuyElite and UnknowPassSystem.PassType == 2 then
    else
      ShowNotice(62405)
    end
    local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
    if IngameLikeClientSubSystem then
      IngameLikeClientSubSystem:OnSendGiveRPSuccess(err_code, left_send_count)
    end
  else
    log(bWriteLog and "on_upass_send_battle_largess_rsp " .. tostring(err_code))
    ShowNotice(err_code)
  end
end
function UpassHandle.send_upass_get_abstract_page_req()
  NetManager.SendPkg(1888191139)
end
function UpassHandle.on_upass_get_abstract_page_rsp(page_info)
  local logic_unknowpass_activity_collection = require("client.slua.logic.unknow_pass.logic_unknowpass_activity_collection")
  logic_unknowpass_activity_collection.OnGetCollectionPageInfoRsp(page_info)
end
function UpassHandle.on_week_task_auto_reward_notify(pre_prize_score, cur_score)
  log(bWriteLog and "UpassHandle.on_week_task_auto_reward_notify " .. tostring(pre_prize_score) .. tostring(cur_score))
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "UpassHandle.on_week_task_auto_reward_notify 1")
    UpassHandle.combatScore = UpassHandle.combatScore + pre_prize_score + cur_score
  else
    log(bWriteLog and "UpassHandle.on_week_task_auto_reward_notify 2")
    if cur_score == 0 then
      ShowNotice(LocUtil.LocalizeResFormat(13009, pre_prize_score))
    elseif pre_prize_score == 0 then
      ShowNotice(LocUtil.LocalizeResFormat(29146, cur_score))
    else
      ShowNotice(LocUtil.LocalizeResFormat(13010, pre_prize_score, cur_score))
    end
  end
end
function UpassHandle.on_general_task_sync_daily_reward_data(result)
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_general_task_sync_daily_reward_data(result)
end
function UpassHandle.send_upass_unlock_extra_score_task_req(round_id)
  log(bWriteLog and "UpassHandle.send_upass_unlock_extra_score_task_req")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  NetManager.SendPkg(1118464623, round_id)
end
function UpassHandle.on_upass_unlock_extra_score_task_rsp(err_code, round_id, is_unlock, all_score)
  if err_code ~= 0 then
    if err_code == 502068 then
      ShowNotice(502015)
    else
      ShowNotice(err_code)
    end
    return
  end
  ShowNotice(38818)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.rp_extra_score.  if 0 < all_score then
    local rewards = {}
    table.insert(rewards, {
      res_id = 1099,
      count = all_score,
      0
    })
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local tExtendData = {
      fCloseCallback = function()
        EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_UPDATE_EXTRASCORE_UNLOCK)
      end
    }
    Logic_CommonItemGet.ShowPanel_DefaultStyle(rewards, false, true, tExtendData)
  else
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_UPDATE_EXTRASCORE_UNLOCK)
  end
end
function UpassHandle.send_upass_reward_extra_score_task_req(task_id)
  NetManager.SendPkg(1547034939, task_id)
end
function UpassHandle.on_upass_reward_extra_score_task_rsp(err_code, task_id, task_data, reward_score, cur_score)
  if err_code ~= 0 then
    if err_code == 502068 then
      ShowNotice(502015)
    else
      ShowNotice(err_code)
    end
    return
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.rp_extra_score.tasks[task_id] = task_data
  PassDataSystem.rp_extra_score.  local rewards = {}
  table.insert(rewards, {
    res_id = 1099,
    count = reward_score,
    0
  })
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tExtendData = {
    fCloseCallback = PassDataSystem.CheckExtraScoreEndRound
  }
  Logic_CommonItemGet.ShowPanel_DefaultStyle(rewards, false, true, tExtendData)
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_UPDATE_EXTRASCORE_UPDATEALL)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_TASK_UPDATE_EXTRASCORE)
end
function UpassHandle.send_sync_upass_extra_score_req()
  NetManager.SendPkg(857268974)
end
function UpassHandle.on_sync_upass_extra_score_info(rp_extra_score_data)
  log_tree("UpassHandle.on_sync_upass_extra_score_info ", rp_extra_score_data)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.rp_extra_score = rp_extra_score_data or {}
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_UPDATE_EXTRASCORE)
end
function UpassHandle.send_upass_reward_all_extra_score_req()
  NetManager.SendPkg(384206375)
end
function UpassHandle.on_upass_reward_all_extra_score_rsp(err_code, all_score)
  if err_code ~= 0 then
    if err_code == 502068 then
      ShowNotice(502015)
    else
      ShowNotice(err_code)
    end
    return
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  local rewards = {}
  table.insert(rewards, {
    res_id = 1099,
    count = all_score,
    0
  })
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tExtendData = {
    fCloseCallback = PassDataSystem.CheckExtraScoreEndRound
  }
  Logic_CommonItemGet.ShowPanel_DefaultStyle(rewards, false, true, tExtendData)
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_UPDATE_EXTRASCORE_UPDATEALL)
end
function UpassHandle.send_upass_get_experience_upgrade_reward_req(selects)
  NetManager.SendPkg(689146351, selects)
end
function UpassHandle.on_upass_get_experience_upgrade_reward_rsp(err_code, awards)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local rewards = {}
  for i, v in pairs(awards) do
    local itemData = {
      res_id = v.item_id,
      count = v.item_num,
      valid_hours = v.item_expire_time,
      color_id = 0,
      pattern_id = 0
    }
    table.insert(rewards, itemData)
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(rewards)
  UpassHandle.send_upass_new_get_req()
end
function UpassHandle.send_get_daily_task_ext_reward_info()
  NetManager.SendPkg(1778463059)
end
function UpassHandle.on_get_daily_task_ext_reward_info_res(errcode, status, drop_id, ext_reward_res_map)
  if drop_id then
    log(bWriteLog and "on_get_daily_task_ext_reward_info_res drop_id" .. drop_id)
  end
  if not drop_id then
    status = 2
  end
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  NewDayTaskSystem.on_get_daily_task_ext_reward_info_res(status, drop_id, ext_reward_res_map)
end
function UpassHandle.send_upass_batch_get_record_req(uid_list)
  NetManager.SendPkg(1090058503, uid_list)
end
function UpassHandle.on_upass_batch_get_record_rsp(err_code, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_FIRST_WEEK_ROLEHISTRO_INFO_UPDATE, data)
end
function UpassHandle.send_upass_get_continuous_buy_award_req(pass_type, index)
  NetManager.SendPkg(1227177351, pass_type, index)
end
function UpassHandle.on_upass_get_continuous_buy_award_rsp(err_code, pass_type, index, items)
  if err_code ~= 0 then
    ShowNotice(err_code)
    log(bWriteLog and "on_upass_get_continuous_buy_award_rsp error = " .. err_code)
    return
  end
  local UnknowPassAwardSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_award")
  UnknowPassAwardSystem.HandGetRewardRsp(pass_type, index, items)
end
function UpassHandle.on_rp_anniversary_bonus_reward_ntf(err_code, bonus_list, awards, score, level, before_level, has_reward_score, keep_buy_count, cb_reason, experience_level, refund_infos, continuous_buy)
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySystem.on_rp_anniversary_bonus_reward_ntf(err_code, bonus_list, awards, score, level, before_level, has_reward_score, keep_buy_count, cb_reason, experience_level, refund_infos, continuous_buy)
end
function UpassHandle.on_upass_send_old_user_awards_notify(err_code, res_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local UnknowPassBuySystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy")
  UnknowPassBuySystem.on_upass_send_old_user_awards_notify(res_list)
end
function UpassHandle.send_upass_active_shop_exchange_rp_receipt_req(billno, exchange_num)
  NetManager.SendPkg(491897715, billno, exchange_num)
end
function UpassHandle.on_upass_active_shop_exchange_rp_receipt_rsp(err_code, info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.on_upass_active_shop_exchange_rp_receipt_rsp(info)
end
function UpassHandle.send_upass_active_shop_buy_req(unique_id, exchange_id, count, billno)
  NetManager.SendPkg(665577527, unique_id, exchange_id, count, billno)
end
function UpassHandle.on_upass_active_shop_buy_rsp(err_code, info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  UnknowPassExchangeSystem.on_upass_active_shop_buy_rsp(info)
end
return UpassHandle