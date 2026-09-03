local NetManager = require("client.network.comm.NetManager")
local LeisureSeasonHandler = {}
function LeisureSeasonHandler.send_get_casual_task_status_req(task_list)
  log_tree("LeisureSeasonHandler.send_get_casual_task_status_req task_list", task_list)
  NetManager.SendPkg(1579105575, task_list)
end
function LeisureSeasonHandler.on_get_casual_task_status_rsp(err_code, advance_integral, task_status_list, extra_table)
  log(bWriteLog and "LeisureSeasonHandler.on_get_casual_task_status_rsp err_code = " .. tostring(err_code) .. ", advance_integral = " .. tostring(advance_integral))
  log_tree("LeisureSeasonHandler.on_get_casual_task_status_rsp extra_table", extra_table)
  if err_code ~= 0 then
    ShowNotice(err_code)
    if err_code ~= 100251124 then
      return
    end
  end
  log_tree("LeisureSeasonHandler.on_get_casual_task_status_rsp task_status_list", task_status_list)
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnGetTaskStatusRsp(advance_integral, task_status_list, extra_table)
end
function LeisureSeasonHandler.send_take_casual_task_award_req(task_id)
  log(bWriteLog and "LeisureSeasonHandler.send_take_casual_task_award_req task_id = " .. tostring(task_id))
  NetManager.SendPkg(571949415, task_id)
end
function LeisureSeasonHandler.on_take_casual_task_award_rsp(err_code, awards)
  log(bWriteLog and "LeisureSeasonHandler.on_take_casual_task_award_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("LeisureSeasonHandler.on_take_casual_task_award_rsp, awards", awards)
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnGetTaskAwardRsp(awards)
end
function LeisureSeasonHandler.send_batch_take_casual_task_award_req(task_id_list)
  log_tree("LeisureSeasonHandler.send_batch_take_casual_task_award_req task_id_list", task_id_list)
  NetManager.SendPkg(535856615, task_id_list)
end
function LeisureSeasonHandler.on_batch_take_casual_task_award_rsp(err_code, awards)
  log(bWriteLog and "LeisureSeasonHandler.on_take_casual_task_award_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("LeisureSeasonHandler.on_take_casual_task_award_rsp, awards", awards)
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnGetTaskAwardRsp(awards)
end
function LeisureSeasonHandler.on_notify_casual_task_award_flag(casual_task_awrad_flag)
  log(bWriteLog and "LeisureSeasonHandler.on_notify_casual_task_award_flag casual_task_awrad_flag = " .. tostring(casual_task_awrad_flag))
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnNotifyTaskAwardFlag(casual_task_awrad_flag)
end
function LeisureSeasonHandler.send_get_casual_segment_integral_req()
  NetManager.SendPkg(695466583)
end
function LeisureSeasonHandler.on_get_casual_segment_integral_rsp(err_code, casual_segment_integral_table)
  log(bWriteLog and "LeisureSeasonHandler.on_get_casual_segment_integral_rsp err_code = " .. tostring(err_code))
  log_tree("LeisureSeasonHandler.on_get_casual_segment_integral_rsp, casual_segment_integral_table", casual_segment_integral_table)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_LEISURE_SEASON, EVENTID_LEISURE_SEASON_GET_MODE_SCORE_RSP, casual_segment_integral_table)
end
function LeisureSeasonHandler.on_notify_casual_segment_info(casual_segment_id, casual_segment_score, advance_integral, is_sync_classic_segment)
  log(bWriteLog and "LeisureSeasonHandler.on_notify_casual_segment_info casual_segment_id = " .. tostring(casual_segment_id) .. ", casual_segment_score = " .. tostring(casual_segment_score) .. ", advance_integral = " .. tostring(advance_integral) .. ", is_sync_classic_segment = " .. tostring(is_sync_classic_segment))
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnNotifySegmentInfo(casual_segment_id, casual_segment_score, advance_integral, is_sync_classic_segment)
end
function LeisureSeasonHandler.on_notify_casual_segment_award_flag(casual_segment_award_flag)
  log(bWriteLog and "LeisureSeasonHandler.on_notify_casual_segment_award_flag casual_segment_award_flag = " .. tostring(casual_segment_award_flag))
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnNotifySegmentAwardFlag(casual_segment_award_flag)
end
function LeisureSeasonHandler.send_take_casual_segment_award_req(reward_id)
  NetManager.SendPkg(1330744927, reward_id)
end
function LeisureSeasonHandler.on_take_casual_segment_award_rsp(err_code, awards)
  log(bWriteLog and "LeisureSeasonHandler.on_take_casual_task_award_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("LeisureSeasonHandler.on_take_casual_segment_award_rsp, awards", awards)
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnGetSegmentAwardRsp(awards)
end
function LeisureSeasonHandler.send_batch_take_casual_segment_award_req()
  NetManager.SendPkg(349245371)
end
function LeisureSeasonHandler.on_batch_take_casual_segment_award_rsp(err_code, reward_list)
  log(bWriteLog and "LeisureSeasonHandler.on_batch_take_casual_segment_award_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("LeisureSeasonHandler.on_batch_take_casual_segment_award_rsp, reward_list", reward_list)
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnGetSegmentAwardRsp(reward_list)
end
function LeisureSeasonHandler.send_get_casual_segment_reward_data_req()
  NetManager.SendPkg(52057255)
end
function LeisureSeasonHandler.on_get_casual_segment_reward_data_rsp(err_code, segment_reward_list)
  log(bWriteLog and "LeisureSeasonHandler.on_get_casual_segment_reward_data_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("LeisureSeasonHandler.on_get_casual_segment_reward_data_rsp, segment_reward_list", segment_reward_list)
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  logic_leisure_season:OnSegmentAwardStatusRsp(segment_reward_list)
end
function LeisureSeasonHandler.send_get_history_casual_season_record_req(uid, season_id)
  NetManager.SendPkg(1214189479, uid, season_id)
end
function LeisureSeasonHandler.on_get_history_casual_season_record_rsp(err_code, data, uid, season_id)
  log(bWriteLog and "LeisureSeasonHandler.on_get_role_history_casual_season_record_rsp uid = " .. tostring(uid) .. ", season_id = " .. tostring(season_id))
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  if err_code ~= 0 then
    if err_code == -1 then
      logic_leisure_season:OnGetRoleHistoryCasualSeasonRecordRsp(data, uid, season_id)
      return
    end
    ShowNotice(err_code)
    return
  end
  logic_leisure_season:OnGetRoleHistoryCasualSeasonRecordRsp(data, uid, season_id)
end
function LeisureSeasonHandler.on_notify_casual_shop_exchange_data(coin_exchange_info, permanent_items, season_items)
  log_tree(bWriteLog and "LeisureSeasonHandler.on_notify_casual_shop_exchange_data coin_exchange_info = ", coin_exchange_info)
  log_tree(bWriteLog and "LeisureSeasonHandler.on_notify_casual_shop_exchange_data permanent_items = ", permanent_items)
  log_tree(bWriteLog and "LeisureSeasonHandler.on_notify_casual_shop_exchange_data season_items = ", season_items)
  local logic_season_shop_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_shop_system)
  logic_season_shop_system:OnGetCasualShopExchangeInfo(coin_exchange_info, permanent_items, season_items)
end
function LeisureSeasonHandler.send_casual_shop_exchange_req(res_id, cnt)
  NetManager.SendPkg(1524709095, res_id, cnt)
end
function LeisureSeasonHandler.on_casual_shop_exchange_rsp(err_code, reward_list)
  log(bWriteLog and "LeisureSeasonHandler.on_casual_shop_exchange_rsp err_code = " .. tostring(err_code))
  log_tree(bWriteLog and "LeisureSeasonHandler.on_casual_shop_exchange_rsp ", reward_list)
  if err_code == 0 then
    ShowNotice(3016)
    EventSystem:postEvent(EVENTTYPE_SEASON_CONFIG, EVENTID_EXCHANGE_SUCCESS, reward_list)
  else
    ShowNotice(err_code)
  end
end
return LeisureSeasonHandler