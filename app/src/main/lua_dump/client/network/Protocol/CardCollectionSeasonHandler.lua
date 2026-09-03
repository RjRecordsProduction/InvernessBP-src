local NetManager = require("client.network.comm.NetManager")
local CardCollectionSeasonHandler = {}
function CardCollectionSeasonHandler.send_card_collect_get_bottle_req()
  log(bWriteLog and "[CardCollection] CardCollectionSeasonHandler.send_card_collect_get_bottle_req")
  NetManager.SendPkg(789137615)
end
function CardCollectionSeasonHandler.on_card_collect_get_bottle_rsp(err_code, award_list, send_uid)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  if not (award_list and award_list) or #award_list == 0 then
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_get_bottle_rsp(award_list, send_uid)
end
function CardCollectionSeasonHandler.send_card_collect_query_series_data_req(series_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_query_series_data_req series_id: %d", series_id))
  NetManager.SendPkg(1059249831, series_id)
end
function CardCollectionSeasonHandler.on_card_collect_query_series_data_rsp(err_code, series_id, series_data)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_query_series_data_rsp(series_id, series_data)
end
function CardCollectionSeasonHandler.send_card_collect_get_score_award_req(seg_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_get_score_award_req seg_id: %s", tostring(seg_id)))
  NetManager.SendPkg(743967207, seg_id)
end
function CardCollectionSeasonHandler.on_card_collect_get_score_award_rsp(err_code, seg_id, award_item)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_get_score_award_rsp(seg_id, award_item)
end
function CardCollectionSeasonHandler.send_card_collect_get_collect_award_req(series_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_get_collect_award_req series_id: %s", tostring(series_id)))
  NetManager.SendPkg(1005174055, series_id)
end
function CardCollectionSeasonHandler.on_card_collect_get_collect_award_rsp(err_code, series_id, award_item)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_get_collect_award_rsp(series_id, award_item)
end
function CardCollectionSeasonHandler.send_card_collect_query_summary_data_req()
  log(bWriteLog and "[CardCollection] CardCollectionSeasonHandler.send_card_collect_query_summary_data_req")
  NetManager.SendPkg(1389997275)
end
function CardCollectionSeasonHandler.send_card_collect_query_season_data_req(season_id, is_click_open_card)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_query_season_data_req season_id: %s, is_click_open_card: %s", tostring(season_id), tostring(is_click_open_card)))
  NetManager.SendPkg(120822247, season_id, is_click_open_card)
end
function CardCollectionSeasonHandler.on_card_collect_query_season_data_rsp(err_code, season_id, season_data)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_query_season_data_rsp(season_id, season_data)
end
function CardCollectionSeasonHandler.send_card_collect_set_show_series_id_req(series_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_set_show_series_id_req series_id: %s", tostring(series_id)))
  NetManager.SendPkg(1072418243, series_id)
end
function CardCollectionSeasonHandler.on_card_collect_set_show_series_id_rsp(err_code, show_series_id)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_set_show_series_id_rsp(show_series_id)
end
function CardCollectionSeasonHandler.send_card_collect_get_exchange_list_req(order_type, offset)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_get_exchange_list_req order_type: %s, offset: %s", tostring(order_type), tostring(offset)))
  NetManager.SendPkg(781713191, order_type, offset)
end
function CardCollectionSeasonHandler.on_card_collect_get_exchange_list_rsp(err_code, order_type, offset, count, total_count, exchange_list)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_get_exchange_list_rsp(order_type, offset, count, total_count, exchange_list)
end
function CardCollectionSeasonHandler.send_card_collect_batch_decompose_req(card_list)
  log_tree("[CardCollection] CardCollectionSeasonHandler.send_card_collect_batch_decompose_req card_list", card_list)
  NetManager.SendPkg(682290855, card_list)
end
function CardCollectionSeasonHandler.on_card_collect_batch_decompose_rsp(err_code, card_list, card_pieces_list)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_batch_decompose_rsp(card_list, card_pieces_list)
end
function CardCollectionSeasonHandler.send_card_collect_compose_card_pack_req(card_pack_id, card_pack_count)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_compose_card_pack_req card_pack_id: %s, card_pack_count: %s", tostring(card_pack_id), tostring(card_pack_count)))
  NetManager.SendPkg(46924519, card_pack_id, card_pack_count)
end
function CardCollectionSeasonHandler.on_card_collect_compose_card_pack_rsp(err_code, card_pack_id, card_pack_count, card_list, card_pack_buy_count)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_compose_card_pack_rsp(card_pack_id, card_pack_count, card_list, card_pack_buy_count)
end
function CardCollectionSeasonHandler.send_card_collect_gen_exchange_req(given_card, expect_card_id)
  log_tree(string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_gen_exchange_req expect_card_id: %s, given_card", tostring(expect_card_id)), given_card)
  NetManager.SendPkg(748034499, given_card, expect_card_id)
end
function CardCollectionSeasonHandler.on_card_collect_gen_exchange_rsp(err_code, give_card_list, expect_res_id, short_order_id, create_time)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_gen_exchange_rsp(give_card_list, expect_res_id, short_order_id, create_time)
end
function CardCollectionSeasonHandler.send_card_collect_cancel_exchange_req(order_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_cancel_exchange_req order_id: %s", tostring(order_id)))
  NetManager.SendPkg(354826535, order_id)
end
function CardCollectionSeasonHandler.on_card_collect_cancel_exchange_rsp(err_code, order_id)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_cancel_exchange_rsp(order_id)
end
function CardCollectionSeasonHandler.send_card_collect_deal_exchange_req(order_id, select_card_id, operate_type)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_deal_exchange_req order_id: %s, select_card_id: %s, operate_type: %s", tostring(order_id), tostring(select_card_id), tostring(operate_type)))
  NetManager.SendPkg(541097031, order_id, select_card_id, operate_type)
end
function CardCollectionSeasonHandler.on_card_collect_deal_exchange_rsp(err_code, order_id, select_card_id)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_deal_exchange_rsp(order_id, select_card_id)
end
function CardCollectionSeasonHandler.send_card_collect_gift_card_req(card_id, receive_uid)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_gift_card_req card_id: %s, receive_uid: %s", tostring(card_id), tostring(receive_uid)))
  NetManager.SendPkg(1678756903, card_id, receive_uid)
end
function CardCollectionSeasonHandler.on_card_collect_gift_card_rsp(err_code, card_id, receive_uid)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_gift_card_rsp(card_id, receive_uid)
end
function CardCollectionSeasonHandler.send_card_collect_get_exchange_req(short_order_id)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_get_exchange_req short_order_id: %s", tostring(short_order_id)))
  NetManager.SendPkg(2105441995, short_order_id)
end
function CardCollectionSeasonHandler.on_card_collect_get_exchange_rsp(err_code, order_info)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_get_exchange_rsp(order_info)
end
function CardCollectionSeasonHandler.send_card_collect_get_newbie_card_req()
  log(bWriteLog and "[CardCollection] CardCollectionSeasonHandler.send_card_collect_get_newbie_card_req")
  NetManager.SendPkg(1966099495)
end
function CardCollectionSeasonHandler.on_card_collect_get_newbie_card_rsp(err_code, register_years, collect_level, card_list)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_get_newbie_card_rsp(register_years, collect_level, card_list)
end
function CardCollectionSeasonHandler.send_card_collect_set_show_order_req(order_list)
  log_tree("[CardCollection] CardCollectionSeasonHandler.send_card_collect_set_show_order_req order_list", order_list)
  NetManager.SendPkg(1217152199, order_list)
end
function CardCollectionSeasonHandler.on_card_collect_set_show_order_rsp(err_code, order_list)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_set_show_series_id_rsp(order_list)
end
function CardCollectionSeasonHandler.send_card_collect_query_finish_series_req()
  log(bWriteLog and "[CardCollection] CardCollectionSeasonHandler.send_card_collect_query_finish_series_req")
  NetManager.SendPkg(1102648679)
end
function CardCollectionSeasonHandler.on_card_collect_query_finish_series_rsp(err_code, series_list, show_series_id)
end
function CardCollectionSeasonHandler.send_card_collect_send_bottle_req(bottle_card_id, send_type)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_send_bottle_req bottle_card_id: %s, send_type: %s", tostring(bottle_card_id), tostring(send_type)))
  NetManager.SendPkg(671729191, bottle_card_id, send_type)
end
function CardCollectionSeasonHandler.on_card_collect_send_bottle_rsp(err_code, bottle_card_id, send_type, award_list)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_card_collection_season:on_card_collect_send_bottle_rsp(bottle_card_id, send_type, award_list)
end
function CardCollectionSeasonHandler.on_card_collect_query_summary_data_rsp(err_code, summary_data, card_depot_data)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_query_summary_data_rsp(summary_data, card_depot_data)
end
function CardCollectionSeasonHandler.send_card_collect_claim_award_req(claim_type)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_claim_award_req claim_type: %s", tostring(claim_type)))
  NetManager.SendPkg(1023499047, claim_type)
end
function CardCollectionSeasonHandler.on_card_collect_claim_award_rsp(err_code, claim_type, order_count, award_list, dealer_uid_list)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_claim_award_rsp(claim_type, order_count, award_list, dealer_uid_list)
end
function CardCollectionSeasonHandler.send_card_collect_query_show_info_req(target_uid)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.send_card_collect_query_show_info_req target_uid: %s", tostring(target_uid)))
  NetManager.SendPkg(1273575015, target_uid)
end
function CardCollectionSeasonHandler.on_card_collect_query_show_info_rsp(err_code, target_uid, show_info)
  if err_code ~= 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(err_code))
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_query_show_info_rsp(target_uid, show_info)
end
function CardCollectionSeasonHandler.on_card_collect_series_finish_ntf(series_id, season_id, card_id)
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_series_finish_ntf(series_id, season_id, card_id)
end
function CardCollectionSeasonHandler.on_card_collect_season_finish_ntf(season_id)
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_season_finish_ntf(season_id)
end
function CardCollectionSeasonHandler.send_card_collect_share_exchange_req(order_id, share_type)
  NetManager.SendPkg(143967583, order_id, share_type, share_data)
end
function CardCollectionSeasonHandler.on_card_collect_share_exchange_rsp(err_code, order_id, share_type, share_data)
  log(bWriteLog and string.format("[CardCollection] CardCollectionSeasonHandler.on_card_collect_share_exchange_rsp: order_id: %s, share_type: %s", tostring(order_id), tostring(share_type)))
  log_tree("[CardCollection] CardCollectionSeasonHandler.on_card_collect_share_exchange_rsp share_data", share_data)
end
function CardCollectionSeasonHandler.send_card_collect_history_click_req()
  log(bWriteLog and "[CardCollection] CardCollectionSeasonHandler.send_card_collect_history_click_req")
  NetManager.SendPkg(1676289959)
end
function CardCollectionSeasonHandler.on_card_collect_history_click_rsp(err_code, migrated_item_ids, get_card_collect_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_card_collect_history_click_rsp(migrated_item_ids, get_card_collect_data)
end
function CardCollectionSeasonHandler.on_add_card_pack_result_notify(card_pack_id, card_pack_count, card_list, reason, subreason)
  local logic_cardcollection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_cardcollection:on_add_card_pack_result_notify(card_pack_id, card_pack_count, card_list, reason, subreason)
end
function CardCollectionSeasonHandler.send_card_collect_batch_query_card_req(resid_list)
  NetManager.SendPkg(1180703531, resid_list)
end
function CardCollectionSeasonHandler.on_card_collect_batch_query_card_rsp(err_code, resid_count_map)
  log(bWriteLog and string.format("CardCollectionHandler.on_card_collect_batch_query_card_rsp, err_code:%s", err_code))
  log_tree(bWriteLog and "CardCollectionHandler.on_card_collect_batch_query_card_rsp resid_count_map", resid_count_map)
  if err_code ~= 0 or not resid_count_map then
    return
  end
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  if logic_card_collection_season then
    logic_card_collection_season:UpdateCardCountCache(resid_count_map)
  end
  local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
  if logic_legend_weapon and logic_legend_weapon.OnCardQueryRsp then
    logic_legend_weapon:OnCardQueryRsp(err_code, resid_count_map)
  end
end
local reqRsp = {
  send_card_collect_batch_query_card_req = "on_card_collect_batch_query_card_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, CardCollectionSeasonHandler)
return CardCollectionSeasonHandler