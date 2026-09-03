local NetManager = require("client.network.comm.NetManager")
local NewGroupBuyHandler = {}
function NewGroupBuyHandler.send_get_new_group_buy_info_req()
  NetManager.SendPkg(1293134823)
end
function NewGroupBuyHandler.on_get_new_group_buy_info_rsp(err_code, group_list, gifts_id_list, gifts_config, gifts_buy_config, gifts_buy_info, groups_info, other_config)
  if err_code == 0 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    logic_group_buying:OnGetNewGroupInfo(group_list, gifts_id_list, gifts_config, gifts_buy_config, gifts_buy_info, groups_info, other_config)
  else
    log(bWriteLog and "NewGroupBuyHandler.on_get_new_group_buy_info_rsp  err_code: " .. tostring(err_code))
    if err_code ~= 108108 then
      ShowNotice(err_code)
    end
  end
end
function NewGroupBuyHandler.send_create_new_group_buy_req(gift_id, merged)
  NetManager.SendPkg(1542818343, gift_id, merged)
end
function NewGroupBuyHandler.on_create_new_group_buy_rsp(err_code, gift_id, group_id, group_info)
  if err_code == 0 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    logic_group_buying:OnGetCreateNewGroupBuy(gift_id, group_id, group_info)
    NewGroupBuyHandler.send_get_new_group_buy_info_req()
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.send_join_new_group_buy_req(group_id)
  NetManager.SendPkg(1215999559, group_id)
end
function NewGroupBuyHandler.on_join_new_group_buy_rsp(err_code, gift_id, group_id, group_info)
  if err_code == 0 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    logic_group_buying:OnGetJoinNewGroupBuy(gift_id, group_id, group_info)
    NewGroupBuyHandler.send_get_new_group_buy_info_req()
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.on_on_new_group_buy_full_notify(group_buy_id)
  log(bWriteLog and "NewGroupBuyHandler.on_on_new_group_buy_full_notify  group_buy_id: " .. tostring(group_buy_id))
  local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
  logic_group_buying:OnGroupBuySuccessNotify(group_buy_id)
  NewGroupBuyHandler.send_get_new_group_buy_info_req()
end
function NewGroupBuyHandler.send_pay_new_group_buy_req(group_id)
  NetManager.SendPkg(1907179827, group_id)
end
function NewGroupBuyHandler.on_pay_new_group_buy_rsp(err_code, gift_id, group_id, item_id, item_num, total_num)
  if err_code == 0 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    logic_group_buying:OnGetPayNewGroupBuy(gift_id, group_id, item_id, item_num, total_num)
    NewGroupBuyHandler.send_get_new_group_buy_info_req()
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.send_direct_pay_new_group_buy_req(gift_id)
  NetManager.SendPkg(1025847527, gift_id)
end
function NewGroupBuyHandler.on_direct_pay_new_group_buy_rsp(err_code, gift_id, item_id, item_num, total_number)
  if err_code == 0 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    logic_group_buying:OnGetDirectPayNewGroupBuy(gift_id, item_id, item_num, total_number)
    NewGroupBuyHandler.send_get_new_group_buy_info_req()
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.send_coupon_pay_new_group_buy_req(gift_id, isLow)
  NetManager.SendPkg(541883047, gift_id, isLow)
end
function NewGroupBuyHandler.on_coupon_pay_new_group_buy_rsp(err_code, gift_id, item_id, item_num, total_number)
  if err_code == 0 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    logic_group_buying:OnGetCouponPayNewGroupBuy(gift_id, item_id, item_num, total_number)
    NewGroupBuyHandler.send_get_new_group_buy_info_req()
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.send_refund_new_group_buy_entrance_req(group_id)
  NetManager.SendPkg(809516143, group_id)
end
function NewGroupBuyHandler.on_refund_new_group_buy_entrance_rsp(err_code, group_id, number, ticket_id)
  if err_code == 0 then
    local item_config = CDataTable.GetTableData("Item", ticket_id)
    ShowNotice(LocUtil.LocalizeResFormat(166095, number, item_config.ItemName))
    NewGroupBuyHandler.send_get_new_group_buy_info_req()
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.send_exchange_new_group_buy_entrance_req(res_id)
  NetManager.SendPkg(1880562467, res_id)
end
function NewGroupBuyHandler.on_exchange_new_group_buy_entrance_rsp(err_code, number, ticket_id)
  if err_code == 0 then
    local item_config = CDataTable.GetTableData("Item", ticket_id)
    ShowNotice(LocUtil.LocalizeResFormat(166060, number, item_config.ItemName))
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.send_batch_get_new_group_buy_info_req(group_id)
  NetManager.SendPkg(1055530855, group_id)
end
function NewGroupBuyHandler.on_batch_get_new_group_buy_info_rsp(err_code, group_info)
  if err_code == 0 then
    local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
    logic_group_buying:OnGetBatchGetNewGroupBuyInfo(group_info)
  else
    ShowNotice(err_code)
  end
end
function NewGroupBuyHandler.send_invite_all_new_group_buy_friend_list_req(uid_list, chat_type, msg_id, chat_content)
  NetManager.SendPkg(1184648551, uid_list, chat_type, msg_id, chat_content)
end
function NewGroupBuyHandler.on_invite_all_new_group_buy_friend_list_rsp(errcode, uidList, chat_type, msg_id, chat_content)
  if errcode == 0 then
    local logic_group_buying_invite = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying_invite)
    logic_group_buying_invite:InviteListAddAll(uidList)
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    local logic_chat_cache = require("client.slua.logic.lobby_chat.logic_chat_cache")
    local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
    chat_content = chat_content.text
    for k, v in pairs(uidList) do
      local id = msg_id + k - 1
      local tabContent = logic_chat_main.msgContentCacheMap[id]
      logic_chat_cache.cache_chat_rsp("ok", id, chat_type, 0, v, chat_content, nil, tabContent)
      channelMain.on_chat_rsp("ok", id, chat_type, 0, v, chat_content, nil)
    end
  else
    ShowNotice(errcode)
  end
end
function NewGroupBuyHandler.on_notify_invite_new_group_buy_result(error, invite_type, dst_uid)
  if error == 0 then
    local logic_group_buying_invite = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying_invite)
    if invite_type == 0 then
      logic_group_buying_invite:InviteListAdd(dst_uid)
    elseif invite_type == 1 then
      logic_group_buying_invite:InviteListAdd(DataMgr.corpsInfo.id)
    end
  else
    ShowNotice(error)
  end
end
function NewGroupBuyHandler.send_get_new_group_buy_simple_info_req()
  NetManager.SendPkg(1199556363)
end
function NewGroupBuyHandler.on_get_new_group_buy_simple_info_rsp(err_code, activity_info, region_config)
  local logic_group_buying = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying)
  logic_group_buying:SetRegionConfig(region_config)
  logic_group_buying:OnGetNewGroupBuySimpleInfo(activity_info)
end
return NewGroupBuyHandler