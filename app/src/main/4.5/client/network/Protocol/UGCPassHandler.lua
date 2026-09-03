local NetManager = require("client.network.comm.NetManager")
local UGCPassHandler = {}
function UGCPassHandler.send_ugc_personal_setting_get_req()
  log(bWriteLog and "UGCPassHandler.send_ugc_personal_setting_get_req ")
  NetManager.SendPkg(732330855)
end
function UGCPassHandler.on_ugc_personal_setting_get_rsp(err_code, ugc_personal_setting, ugc_personal_depot)
  if err_code ~= 0 then
    ShowNotice(err_code)
    log(bWriteLog and "UGCPassHandler.on_ugc_personal_setting_get_rsp err")
    return
  end
  log_tree(bWriteLog and "UGCPassHandler.on_ugc_personal_setting_get_rsp ugc_personal_setting ", ugc_personal_setting)
  log_tree(bWriteLog and "UGCPassHandler.on_ugc_personal_setting_get_rsp ugc_personal_depot ", ugc_personal_depot)
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  logic_ugc_inventory:InventoryRsp(ugc_personal_setting, ugc_personal_depot)
end
function UGCPassHandler.send_ugc_personal_setting_set_req(maintype, subtype, res_ids)
  log(bWriteLog and "UGCPassHandler.send_ugc_personal_setting_set_req maintype = " .. maintype .. ",subtype = " .. subtype)
  log_tree(bWriteLog and "UGCPassHandler.send_ugc_personal_setting_set_req inst_ids ", res_ids)
  NetManager.SendPkg(349029223, maintype, subtype, res_ids)
end
function UGCPassHandler.on_ugc_personal_setting_set_rsp(err_code, maintype, subtype, subtype_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    log(bWriteLog and "UGCPassHandler.send_ugc_personal_setting_set_rsp err")
    return
  end
  log(bWriteLog and "UGCPassHandler.send_ugc_personal_setting_set_req maintype = " .. maintype .. ",subtype = " .. subtype)
  log_tree(bWriteLog and "UGCPassHandler.send_ugc_personal_setting_set_rsp subtype_list ", subtype_list)
  local logic_ugc_inventory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_inventory)
  logic_ugc_inventory:SettingInventoryRsp(maintype, subtype, subtype_list)
end
function UGCPassHandler.send_ugc_pass_enter_redpoint_req()
  NetManager.SendPkg(57727083)
end
function UGCPassHandler.on_ugc_pass_enter_redpoint_rsp(err_code, flag)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnUGCWOWRedPointInfoRsp(err_code, flag)
end
function UGCPassHandler.on_ugc_pass_has_reward_notify(notify_info)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnUGCPassRewardInfoNotify(notify_info)
end
function UGCPassHandler.send_ugc_pass_get_info_req()
  NetManager.SendPkg(26867471)
end
function UGCPassHandler.on_ugc_pass_get_info_rsp(err_code, info)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnUGCWOWPassInfoRsp(err_code, info)
end
function UGCPassHandler.send_ugc_pass_open_check_req()
  NetManager.SendPkg(436423959)
end
function UGCPassHandler.on_ugc_pass_open_check_rsp(err_code)
end
function UGCPassHandler.send_ugc_pass_get_static_season_info_req()
  NetManager.SendPkg(1132089843)
end
function UGCPassHandler.on_ugc_pass_get_static_season_info_rsp(err_code, static_season_info)
  if err_code ~= 0 and tonumber(err_code) ~= 2008001 then
    log(bWriteLog and "UGCPassHandler.on_ugc_pass_get_static_season_info_rsp err_code err_code = ", err_code)
  end
  if static_season_info then
    log_tree("UGCPassHandler.on_ugc_pass_get_static_season_info_rsp static_season_info", static_season_info)
    local LogicUGCRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRank)
    LogicUGCRank:ugc_pass_get_static_season_info_rsp(static_season_info)
  end
end
function UGCPassHandler.send_ugc_pass_get_level_award_req(level, is_elite_reward)
  NetManager.SendPkg(314091815, level, is_elite_reward)
end
function UGCPassHandler.on_ugc_pass_get_level_award_rsp(err_code, level, is_elite_reward, item_list, level_info)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:WOWPassGetAwardRsp(err_code, level, is_elite_reward, item_list, level_info)
end
function UGCPassHandler.send_ugc_pass_get_all_level_award_req()
  NetManager.SendPkg(369808167)
end
function UGCPassHandler.on_ugc_pass_get_all_level_award_rsp(err_code, item_list, level_info)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:WOWPassGetAllAwardRsp(err_code, item_list, level_info)
end
function UGCPassHandler.send_ugc_pass_buy_level_req(diff_score, cur_level, cur_score)
  NetManager.SendPkg(540681575, diff_score, cur_level, cur_score)
end
function UGCPassHandler.on_ugc_pass_buy_level_rsp(err_code, buy_score, pass_score, current_pass_level, before_pass_level)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnUGCWOWPassBuyLevelRsp(err_code, buy_score, pass_score, current_pass_level, before_pass_level)
end
function UGCPassHandler.on_ugc_pass_score_change_notify(value, pass_score, current_pass_level)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnUGCPassScoreLevelChangeRsp(value, pass_score, current_pass_level)
end
function UGCPassHandler.send_ugc_buy_pass_req()
  NetManager.SendPkg(667407911)
end
function UGCPassHandler.on_ugc_buy_pass_rsp(err_code, instant_reward_list, pass_score, current_pass_level, level_reward_status)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:ReqUGCWOWPassBuyRsp(err_code, instant_reward_list, pass_score, current_pass_level, level_reward_status)
end
function UGCPassHandler.send_ugc_pass_buy_guide_req()
  print(bWriteLog and "[gordon ugc req] send_ugc_buy_pass_req")
  NetManager.SendPkg(536411303)
end
function UGCPassHandler.on_ugc_pass_buy_guide_rsp(err_code, show_flag)
  print(bWriteLog and string.format("[gordon ugc rsp] on_ugc_pass_buy_guide_rsp: error_code: %s, show_flag: %s", err_code, show_flag))
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:ReqUGCWOWPassBuyGuideRsp(err_code, show_flag)
end
function UGCPassHandler.send_ugc_pass_record_info_req()
  NetManager.SendPkg(1321236775)
end
function UGCPassHandler.on_ugc_pass_record_info_rsp(err_code, record_list)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnPassRecordInfoRsp(err_code, record_list)
end
function UGCPassHandler.send_ugc_pass_finish_task_by_card_req(week_id, task_id)
  NetManager.SendPkg(1677009767, week_id, task_id)
end
function UGCPassHandler.on_ugc_pass_finish_task_by_card_rsp(err_code, week_id, task_id)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnFinishTaskByCardRsp(err_code, week_id, task_id)
end
function UGCPassHandler.send_ugc_pass_get_current_task_status_req()
  NetManager.SendPkg(1302344423)
end
function UGCPassHandler.on_ugc_pass_get_current_task_status_rsp(err_code, status_list)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnGetUGCWOWPassTaskStatusRsp(err_code, status_list)
end
function UGCPassHandler.on_ugc_pass_task_status_change_notify(status_list)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnUGCWOWPassTaskStatusNotify(status_list)
end
function UGCPassHandler.send_ugc_pass_get_task_reward_req(week_id, task_id)
  NetManager.SendPkg(1405594407, week_id, task_id)
end
function UGCPassHandler.on_ugc_pass_get_task_reward_rsp(err_code, week_id, task_id, item_list)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnGetSingleTaskRewardRsp(err_code, week_id, task_id, item_list)
end
function UGCPassHandler.send_ugc_pass_get_all_task_reward_req()
  NetManager.SendPkg(989985959)
end
function UGCPassHandler.on_ugc_pass_get_all_task_reward_rsp(err_code, item_list)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnGetAllTaskRewardRsp(err_code, item_list)
end
function UGCPassHandler.on_ugc_pass_level_reward_status_notify(status_list)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:LevelRewardStatusChangeNotify(status_list)
end
function UGCPassHandler.send_ugc_pass_get_buy_info_req()
  NetManager.SendPkg(2118417171)
end
function UGCPassHandler.on_ugc_pass_get_buy_info_rsp(err_code, info)
  local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
  logic_ugc_WOWPass:OnUGCWOWPassIsBuyRsp(err_code, info.is_buy)
end
function UGCPassHandler.send_ugc_take_one_season_award_req(id)
  NetManager.SendPkg(274534131, id)
end
function UGCPassHandler.on_ugc_take_one_season_award_rsp(err_code, segment_id, awards)
end
function UGCPassHandler.send_ugc_get_season_rating_add_records_req()
  log(bWriteLog and "UGCPassHandler.send_ugc_get_season_rating_add_records_req")
  NetManager.SendPkg(1705726535)
end
function UGCPassHandler.on_ugc_get_season_rating_add_records_rsp(err_code, result)
  log(bWriteLog and "UGCPassHandler.on_ugc_get_season_rating_add_records_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCPassHandler.send_ugc_season_get_exchange_list_req()
  log(bWriteLog and "UGCPassHandler.send_ugc_season_get_exchange_list_req")
  NetManager.SendPkg(773102695)
end
function UGCPassHandler.on_ugc_season_get_exchange_list_rsp(err_code, exchange_shop_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCPassHandler.send_ugc_season_take_exchange_by_id_req(shop_id, shop_count)
  log(bWriteLog and "UGCPassHandler.send_ugc_season_get_exchange_list_req shop_id = " .. shop_id .. " shop_count = " .. shop_count)
  NetManager.SendPkg(307181991, shop_id, shop_count)
end
function UGCPassHandler.on_ugc_season_take_exchange_by_id_rsp(err_code, shop_id, shop_count, on_exchange_shop_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCPassHandler.send_ugc_wallet_get_balance_req()
  NetManager.SendPkg(1737259111)
end
function UGCPassHandler.on_ugc_wallet_get_balance_rsp(err_code, wallet_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCWallet = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_wallet)
  log_tree("UGCPassHandler.on_ugc_wallet_get_balance_rsp wallet_data = ", wallet_data)
  LogicUGCWallet:on_ugc_wallet_get_balance_rsp(wallet_data)
end
function UGCPassHandler.send_ugc_wallet_get_benefit_overview_req(income_type)
  NetManager.SendPkg(906321963, income_type)
end
function UGCPassHandler.on_ugc_wallet_get_benefit_overview_rsp(err_code, wallet_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCWallet = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_wallet)
  log_tree("UGCPassHandler.on_ugc_wallet_get_benefit_overview_rsp wallet_data = ", wallet_data)
  LogicUGCWallet:on_ugc_wallet_get_benefit_overview_rsp(wallet_data)
end
function UGCPassHandler.send_ugc_wallet_get_benefit_details_req(api_name)
  NetManager.SendPkg(1442905447, api_name)
end
function UGCPassHandler.on_ugc_wallet_get_benefit_details_rsp(err_code, api_name, wallet_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCWallet = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_wallet)
  LogicUGCWallet:on_ugc_wallet_get_benefit_details_rsp(api_name, wallet_data)
end
function UGCPassHandler.send_ugc_wallet_withdrawal_req(amount, uuid, inner_token)
  log(bWriteLog and "UGCPassHandler.send_ugc_wallet_withdrawal_req amount = " .. tostring(amount) .. " uuid = " .. tostring(uuid) .. " inner_token = " .. tostring(inner_token))
  NetManager.SendPkg(870428199, amount, uuid, inner_token)
end
function UGCPassHandler.on_ugc_wallet_withdrawal_rsp(err_code, wallet_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCWallet = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_wallet)
  log_tree("UGCPassHandler.on_ugc_wallet_withdrawal_rsp wallet_data = ", wallet_data)
  LogicUGCWallet:on_ugc_wallet_withdrawal_rsp(wallet_data)
end
local Creative_ShowError_Tips = function(err_code)
  if err_code == 500174 then
    ShowNotice(1050079)
  elseif err_code == 500175 then
    ShowNotice(500175)
  elseif err_code == 500180 then
    ShowNotice(500180)
  elseif err_code == 500176 then
    ShowNotice(9910012)
  elseif err_code == 500177 then
    ShowNotice(411015)
  elseif err_code == 500178 then
    ShowNotice(13065016)
  elseif err_code == 500179 then
    ShowNotice(1050080)
  else
    ShowNotice(err_code)
  end
end
function UGCPassHandler.send_ugc_other_creative_info_req(target_uid)
  NetManager.SendPkg(1497643167, target_uid)
end
function UGCPassHandler.on_ugc_other_creative_info_rsp(err_code, target_uid, sync_info)
  if err_code ~= 0 then
    Creative_ShowError_Tips(err_code)
    return
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:OnCreativerInfoRsp(target_uid, sync_info)
end
function UGCPassHandler.send_ugc_self_creative_info_req()
  NetManager.SendPkg(14145895)
end
function UGCPassHandler.on_ugc_self_creative_info_rsp(err_code, sync_info)
  if err_code ~= 0 then
    Creative_ShowError_Tips(err_code)
    return
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:OnSelfCreativerInfoRsp(sync_info)
  local logic_ugc_reward_incentives = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_reward_incentives)
  logic_ugc_reward_incentives:on_ugc_self_creative_info_rsp(sync_info)
end
function UGCPassHandler.send_ugc_creative_level_award_req(level)
  log(bWriteLog and "UGCPassHandler.send_ugc_creative_level_award_req level = " .. tostring(level))
  NetManager.SendPkg(813288487, level)
end
function UGCPassHandler.on_ugc_creative_level_award_rsp(err_code, level, level_award_info, reward_items)
  if err_code ~= 0 then
    Creative_ShowError_Tips(err_code)
    return
  end
  local logic_ugc_reward_incentives = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_reward_incentives)
  logic_ugc_reward_incentives:on_ugc_creative_level_award_rsp(level, level_award_info, reward_items)
end
function UGCPassHandler.send_wow_apply_join_incentive_program_req()
  NetManager.SendPkg(1366949991)
end
function UGCPassHandler.on_wow_apply_join_incentive_program_rsp(err_code, incentive_program_data)
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_wow_apply_join_incentive_program_rsp(err_code, incentive_program_data)
end
function UGCPassHandler.on_notify_update_wow_incentive_program_data(incentive_program_data)
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_notify_update_wow_incentive_program_data(incentive_program_data)
end
function UGCPassHandler.send_wow_get_incentive_program_award_req(task_id)
  NetManager.SendPkg(575013847, task_id)
end
function UGCPassHandler.on_wow_get_incentive_program_award_rsp(err_code, task_id, task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_wow_get_incentive_program_award_rsp(task_id, task_data)
end
function UGCPassHandler.send_wow_query_incentive_program_join_state_req()
  NetManager.SendPkg(664176583)
end
function UGCPassHandler.on_wow_query_incentive_program_join_state_rsp(err_code, join_state)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_wow_query_incentive_program_join_state_rsp(join_state)
end
function UGCPassHandler.send_wow_query_incentive_program_task_data_req()
  NetManager.SendPkg(1704913123)
end
function UGCPassHandler.on_wow_query_incentive_program_task_data_rsp(err_code, task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCPassHandler.on_wow_query_incentive_program_task_data_rsp task_data = ", task_data)
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_wow_query_incentive_program_task_data_rsp(task_data)
end
function UGCPassHandler.send_wow_get_IPR_rank_history_req()
  NetManager.SendPkg(1579653671)
end
function UGCPassHandler.on_wow_get_IPR_rank_history_rsp(err_code, data)
  local logic_rank_Creativity = require("client.slua.logic.activity.logic_rank_Incentive")
  logic_rank_Creativity.GetHistoryRankListRsp(err_code, data)
end
function UGCPassHandler.send_wow_get_incentive_program_revenue_req()
  NetManager.SendPkg(364438643)
  log(bWriteLog and "UGCPassHandler.send_wow_get_IPR_des_cfg_req222")
end
function UGCPassHandler.on_wow_get_incentive_program_revenue_rsp(err_code, data)
  if err_code ~= 0 and err_code ~= 522014 then
    ShowNotice(err_code)
  end
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_wow_get_incentive_program_revenue_rsp(err_code, data)
end
function UGCPassHandler.send_wow_get_IPR_des_cfg_req()
  NetManager.SendPkg(475107651)
  log(bWriteLog and "UGCPassHandler.send_wow_get_IPR_des_cfg_req111")
end
function UGCPassHandler.on_wow_get_IPR_des_cfg_rsp(err_code, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_wow_get_IPR_des_cfg_rsp(err_code, data)
end
function UGCPassHandler.send_wow_get_IPR_rank_req()
  NetManager.SendPkg(2070218343)
end
function UGCPassHandler.on_wow_get_IPR_rank_rsp(err_code, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  local logic_rank_Creativity = require("client.slua.logic.activity.logic_rank_Incentive")
  logic_rank_Creativity.GetRankListRsp(err_code, data)
end
function UGCPassHandler.send_ugc_weekly_active_award_req(award_id)
  print(bWriteLog and bwriteLog and "UGCPassHandler.send_ugc_weekly_active_award_req " .. tostring(award_id))
  NetManager.SendPkg(1376407539, award_id)
end
function UGCPassHandler.on_ugc_weekly_active_award_rsp(err_code, award_id)
  print(bWriteLog and bwriteLog and "UGCPassHandler.on_ugc_weekly_active_award_rsp " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  LogicUGCTask:on_ugc_weekly_active_award_rsp(award_id)
end
function UGCPassHandler.send_ugc_daily_task_get_task_data_req()
  print(bWriteLog and bwriteLog and "UGCPassHandler.send_ugc_daily_task_get_task_data_req")
  NetManager.SendPkg(1650262695)
end
function UGCPassHandler.on_ugc_daily_task_get_task_data_rsp(err_code, task_data)
  print(bWriteLog and "UGCPassHandler.on_ugc_daily_task_get_task_data_rsp " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  LogicUGCTask:on_ugc_daily_task_get_task_data_rsp(task_data)
end
function UGCPassHandler.send_ugc_daily_task_get_award_req(task_id)
  print(bWriteLog and "UGCPassHandler.send_ugc_daily_task_get_award_req " .. tostring(task_id))
  NetManager.SendPkg(715938471, task_id)
end
function UGCPassHandler.on_ugc_daily_task_get_award_rsp(err_code, task_id, task_data)
  print(bWriteLog and "UGCPassHandler.on_ugc_daily_task_get_award_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  LogicUGCTask:on_ugc_daily_task_get_award_rsp(task_id, task_data)
end
function UGCPassHandler.send_ugc_daily_task_batch_get_reward_req()
  print(bWriteLog and bwriteLog and "UGCPassHandler.send_ugc_daily_task_batch_get_reward_req ")
  NetManager.SendPkg(2024847375)
end
function UGCPassHandler.on_ugc_daily_task_batch_get_reward_rsp(err_code)
  print(bWriteLog and "UGCPassHandler.on_ugc_daily_task_batch_get_reward_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.show_all_awards_of_task(rewards)
end
function UGCPassHandler.send_ugc_daily_task_refresh_req(task_id)
  print(bWriteLog and bwriteLog and "UGCPassHandler.send_ugc_daily_task_refresh_req " .. tostring(task_id))
  NetManager.SendPkg(1216788967, task_id)
end
function UGCPassHandler.on_ugc_daily_task_refresh_rsp(err_code, task_id, new_task_id, new_task_info, refresh_count)
  print(bWriteLog and bwriteLog and "UGCPassHandler.on_ugc_daily_task_refresh_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  LogicUGCTask:on_ugc_daily_task_refresh_rsp(task_id, new_task_id, new_task_info, refresh_count)
end
function UGCPassHandler.send_ugc_daily_task_complete_imm_req(task_id)
  print(bWriteLog and bwriteLog and "UGCPassHandler.send_ugc_daily_task_complete_imm_req " .. tostring(task_id))
  NetManager.SendPkg(1376775751, task_id)
end
function UGCPassHandler.on_ugc_daily_task_complete_imm_rsp(err_code, task_id)
  print(bWriteLog and bwriteLog and "UGCPassHandler.on_ugc_daily_task_complete_imm_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  LogicUGCTask:on_ugc_daily_task_complete_imm_rsp(task_id)
end
function UGCPassHandler.on_ugc_weekly_active_sync(task_data)
  print(bWriteLog and bwriteLog and "UGCPassHandler.on_ugc_weekly_active_sync ")
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  LogicUGCTask:on_ugc_weekly_active_sync(task_data)
end
function UGCPassHandler.on_ugc_daily_task_sync(task_data)
  print(bWriteLog and "UGCPassHandler.on_ugc_daily_task_sync ")
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  LogicUGCTask:on_ugc_daily_task_sync(task_data)
end
function UGCPassHandler.send_ugc_task_receive_all_rewards_req()
  NetManager.SendPkg(94512871)
end
function UGCPassHandler.on_ugc_task_receive_all_rewards_rsp(err_code, result_reward_id_list)
  print(bWriteLog and bwriteLog and "UGCPassHandler.on_ugc_task_receive_all_rewards_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.on_general_task_batch_reward_rsp(result_reward_id_list, true)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_get_req()
end
function UGCPassHandler.send_wow_get_new_author_inspire_req()
  NetManager.SendPkg(1380228359)
end
function UGCPassHandler.on_wow_get_new_author_inspire_rsp(err_code, data)
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:on_wow_get_new_author_inspire_rsp(err_code, data)
end
function UGCPassHandler.send_wow_get_revenue_rank_req()
  NetManager.SendPkg(2045402599)
end
function UGCPassHandler.on_wow_get_revenue_rank_rsp(err_code, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  local logic_rank_Creativity = require("client.slua.logic.activity.logic_rank_Incentive")
  logic_rank_Creativity.GetRankListRsp(err_code, data)
end
function UGCPassHandler.send_wow_get_author_revenue_req()
  NetManager.SendPkg(999566055)
end
function UGCPassHandler.on_wow_get_author_revenue_rsp(err_code, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
end
function UGCPassHandler.send_ugc_wowpass_task_rsperror_tlog_req(error_info)
  NetManager.SendPkg(211358442, error_info)
end
return UGCPassHandler