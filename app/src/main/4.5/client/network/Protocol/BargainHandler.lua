local NetManager = require("client.network.comm.NetManager")
local BargainHandler = {}
BargainHandler.ERR_CODE = {
  SUCCESS = 0,
  BARGAIN_NOT_OPEN = 9940301,
  NO_ORDER = 9940302,
  ALREADY_BOUGHT = 9940303,
  ALREADY_FLOOR = 9940304,
  ALREADY_HELPED = 9940305,
  DAILY_LIMIT_HELPER = 9940306,
  DAILY_LIMIT_OWNER = 9940307,
  SELF_HELP = 9940308,
  PAY_FAIL = 9940309,
  NO_BALANCE = 9940310,
  TASK_LIMIT = 9940311,
  CFG_INVALID = 9940312,
  ORDER_NOT_FOUND = 9940313,
  OFFLINE = 9940314,
  REQ_TOO_FAST = 9940315,
  PARAM_ERROR = 9940316
}
function BargainHandler.send_get_bargain_simple_info_req()
  NetManager.SendPkg(1953890695)
end
function BargainHandler.on_get_bargain_simple_info_rsp(err_code, activity_durations, gifts_config, region_config, task_pool_config, helper_award, buy_award)
  if err_code ~= 0 then
    log(bWriteLog and "BargainHandler.on_get_bargain_simple_info_rsp - err_code: " .. tostring(err_code))
    return
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:SetRegionConfig(region_config)
  logic_bargain:OnGetBargainSimpleInfo(activity_durations, gifts_config, task_pool_config, helper_award, buy_award)
end
function BargainHandler.send_get_bargain_info_req()
  NetManager.SendPkg(337076135)
end
function BargainHandler.on_get_bargain_info_rsp(err_code, bargain_orders, buy_records)
  if err_code ~= 0 then
    log(bWriteLog and "BargainHandler.on_get_bargain_info_rsp - err_code: " .. tostring(err_code))
    if err_code ~= 108108 then
      ShowNotice(err_code)
    end
    return
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:OnGetBargainInfo(bargain_orders, buy_records)
end
function BargainHandler.send_bargain_purchase_req(bargain_id)
  NetManager.SendPkg(1577213351, bargain_id)
end
function BargainHandler.on_bargain_purchase_rsp(err_code, bargain_id, package_id, cost_id, cost_amount, items)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:OnPurchaseSucc(bargain_id, package_id, cost_id, cost_amount, items)
  BargainHandler.send_get_bargain_info_req()
end
function BargainHandler.send_get_help_cut_detail_req()
  NetManager.SendPkg(1562685903)
end
function BargainHandler.on_get_help_cut_detail_rsp(err_code, _, help_given, global_info)
  if err_code ~= 0 then
    log(bWriteLog and "BargainHandler.on_get_help_cut_detail_rsp - err_code: " .. tostring(err_code))
    ShowNotice(err_code)
    return
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:OnGetHelpGivenList(help_given or {}, global_info or {})
end
function BargainHandler.send_do_help_cut_req(bargain_id)
  NetManager.SendPkg(329828939, bargain_id)
end
function BargainHandler.on_do_help_cut_rsp(err_code, bargain_id, package_id, cut_amount, today_help_cut_count)
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  if err_code ~= 0 then
    log(bWriteLog and "BargainHandler.on_do_help_cut_rsp - err_code: " .. tostring(err_code))
    ShowNotice(err_code)
    if logic_bargain then
      logic_bargain:OnDoHelpCutFail(err_code)
    end
    return
  end
  logic_bargain:OnDoHelpCutSucc(bargain_id, package_id, cut_amount, today_help_cut_count)
end
function BargainHandler.send_batch_get_bargain_info_req(bargain_id_list)
  NetManager.SendPkg(1753388519, bargain_id_list)
end
function BargainHandler.on_batch_get_bargain_info_rsp(err_code, bargain_data)
  if err_code ~= 0 then
    log(bWriteLog and "BargainHandler.on_batch_get_bargain_info_rsp - err_code: " .. tostring(err_code))
    return
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:OnBatchGetBargainInfo(bargain_data)
end
function BargainHandler.send_get_bargain_task_list_req(bargain_id)
  NetManager.SendPkg(1240554195, bargain_id)
end
function BargainHandler.on_get_bargain_task_list_rsp(err_code, bargain_id, package_id, is_first_activate, task_cut_total, task_cut_limit, task_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:OnGetBargainTaskList(bargain_id, package_id, is_first_activate, task_cut_total, task_cut_limit, task_list or {})
end
function BargainHandler.send_invite_all_bargain_friend_list_req(uid_list, chat_type, msg_id, chat_content)
  NetManager.SendPkg(2138951943, uid_list, chat_type, msg_id, chat_content)
end
function BargainHandler.on_invite_all_bargain_friend_list_rsp(err_code, uid_list, chat_type, msg_id, chat_content)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_bargain_invite = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain_invite)
  local success_count = uid_list and #uid_list or 0
  logic_bargain_invite:OnInviteAllSucc(success_count, 0)
end
function BargainHandler.on_bargain_friend_cut_notify(bargain_id, package_id, helper_uid, cut_amount, current_price)
  log(bWriteLog and string.format("BargainHandler.on_bargain_friend_cut_notify - bargain_id=%s, package_id=%s, helper_uid=%s, cut=%s, cur_price=%s", tostring(bargain_id), tostring(package_id), tostring(helper_uid), tostring(cut_amount), tostring(current_price)))
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:OnFriendCutNotify(bargain_id, package_id, helper_uid, cut_amount, current_price)
  BargainHandler.send_get_bargain_info_req()
end
function BargainHandler.on_bargain_task_complete_notify(bargain_id, package_id, task_id, cut_amount, current_price)
  log(bWriteLog and string.format("BargainHandler.on_bargain_task_complete_notify - bargain_id=%s, package_id=%s, task_id=%s, cut=%s, cur_price=%s", tostring(bargain_id), tostring(package_id), tostring(task_id), tostring(cut_amount), tostring(current_price)))
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  logic_bargain:OnTaskCompleteNotify(bargain_id, package_id, task_id, cut_amount, current_price)
end
function BargainHandler.send_activate_bargain_order_req(bargain_id)
  NetManager.SendPkg(1561811815, bargain_id)
end
function BargainHandler.on_activate_bargain_order_rsp(err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_bargain = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_bargain)
  if logic_bargain then
    logic_bargain:OnActivateBargainOrderSucc()
  end
end
return BargainHandler