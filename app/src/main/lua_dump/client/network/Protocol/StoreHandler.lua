local NetManager = require("client.network.comm.NetManager")
local StoreHandler = {}
function StoreHandler.send_get_shop_tab_list_req()
  NetManager.SendPkg(1927275691)
end
function StoreHandler.on_get_shop_tab_list_rsp(supply_version, supply_list, lucky_strategy_table, frame_style_conf)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:ResponseSupplyTabList(supply_version, supply_list, lucky_strategy_table, frame_style_conf)
end
function StoreHandler.send_get_market_tab_list_req()
  NetManager.SendPkg(1333833931)
end
function StoreHandler.on_get_market_tab_list_rsp(store_version, store_list)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:ResponseStoreTabList(store_version, store_list)
end
function StoreHandler.send_get_shop_info_req(tab_id, sub_id, is_ams_chest)
  NetManager.SendPkg(1056088219, tab_id, sub_id, is_ams_chest)
end
function StoreHandler.on_get_shop_info_rsp(supply_version, info, shop_wish_info)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:ResponseSupplyData(supply_version, info, shop_wish_info)
end
function StoreHandler.send_get_market_info_req(tab_id, sub_id)
  NetManager.SendPkg(805926587, tab_id, sub_id)
end
function StoreHandler.on_get_market_info_rsp(store_version, info, back_user_buy_info, material_limit_info, rp_list)
  log_tree("on_get_market_info_rsp material_limit_info", material_limit_info)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:ResponseStoreData(store_version, info, back_user_buy_info, material_limit_info, rp_list)
  if info and next(info) and info[1] == StoreConst.Page_Special_Material_Pack then
    local StoreLimitedSubscribeData = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
    StoreLimitedSubscribeData:ReceivedOfferData(info[StoreConst.label_market_index_market_list])
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_GIFT_DATA_HANDLE)
  end
end
function StoreHandler.send_buy_shop_by_id_req(params)
  NetManager.SendPkg(2136611687, params)
end
function StoreHandler.on_buy_shop_by_id_rsp(error_code, shop_id, info, chest_wish_info)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:buy_shop_by_id_rsp(error_code, shop_id, info, chest_wish_info)
end
function StoreHandler.send_buy_market_by_id_req(params)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrict = QRcodeRestrictManager:CheckShopBuyRestrictByMoneyType(params[3])
  log(bWriteLog and "StoreHandler.send_buy_market_by_id_req isRestrict : " .. tostring(isRestrict))
  if isRestrict then
    return
  end
  NetManager.SendPkg(1989951463, params)
end
function StoreHandler.on_buy_market_by_id_rsp(error_code, market_id, info)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:buy_market_by_id_rsp(error_code, market_id, info)
end
function StoreHandler.on_sync_market_version(version, show_market_red)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:SyncVersionCheck(version, show_market_red)
end
function StoreHandler.send_get_market_buy_info_req_v3()
  NetManager.SendPkg(1893412707)
end
function StoreHandler.on_get_market_buy_info_rsp_v3(list, isAll, backuser_buy_limit_info, material_limit_info, rp_list)
  log(bWriteLog and string.format("StoreHandler.on_get_market_buy_info_rsp_v3 isAll = %s", isAll))
  log_tree("list", list)
  log_tree(bWriteLog and "StoreHandler.on_get_market_buy_info_rsp_v3 backuser_buy_limit_info", backuser_buy_limit_info)
  log_tree("on_get_market_buy_info_rsp_v3 material_limit_info", material_limit_info)
  local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
  store_limit_buy_manager:ResLimitBuyInfo(list, isAll, backuser_buy_limit_info, material_limit_info, rp_list)
end
function StoreHandler.send_give_gift_from_market_req_v3(params)
  NetManager.SendPkg(1100459299, params)
end
function StoreHandler.on_give_gift_from_market_rsp_v3(error_code, askIndex)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:give_gift_from_market_rsp_v3(error_code, askIndex)
end
function StoreHandler.on_update_shop_price_rsp_v3(shop_id, price_list)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:update_shop_price_rsp_v3(shop_id, price_list)
end
function StoreHandler.send_get_market_chest_info_req(market_id)
  NetManager.SendPkg(883803187, market_id)
end
function StoreHandler.on_get_market_chest_info_rsp(res, market_id, data, preview_items)
  local treasure_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.treasure_chest_manager)
  treasure_chest_manager:ResponseChestInfo(res, market_id, data, preview_items)
end
function StoreHandler.on_market_buy_chest_item_notify(res, itemList, tabId, decItemData)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:market_buy_chest_item_notify(res, itemList, tabId, decItemData)
end
function StoreHandler.send_add_market_collect_by_item_req(item_id, source_type)
  NetManager.SendPkg(1129178855, item_id, source_type)
end
function StoreHandler.on_add_market_collect_by_item_rsp(err_code, market_collect_data, source_type, item_id, collect_cnt)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:add_market_collect_by_item_rsp(err_code, market_collect_data, source_type, item_id, collect_cnt)
end
function StoreHandler.send_cancel_market_collect_by_item_req(item_id)
  NetManager.SendPkg(1369077667, item_id)
end
function StoreHandler.on_cancel_market_collect_by_item_rsp(err_code, market_collect_data, item_id)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:cancel_market_collect_by_item_rsp(err_code, market_collect_data, item_id)
end
function StoreHandler.send_get_market_collect_jump_info_req()
  NetManager.SendPkg(1951163943)
end
function StoreHandler.on_get_market_collect_jump_info_rsp(market_collect_jump_info)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:get_market_collect_jump_info_rsp(market_collect_jump_info)
end
function StoreHandler.send_get_market_collect_red_point_req()
  NetManager.SendPkg(1118532007)
  log(bWriteLog and "xccStoreHandler.send_get_market_collect_red_point_req")
end
function StoreHandler.on_get_market_collect_red_point_rsp(need_red_point_table)
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  store_collect_data:SetNeedRedPointTabData(need_red_point_table)
  log_tree("xccStoreHandler.on_get_market_collect_red_point_rsp", need_red_point_table)
end
function StoreHandler.on_notice_shop_guarantee_reward(reward_items)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:notice_shop_guarantee_reward(reward_items)
end
function StoreHandler.send_receive_guarantee_reward_req(reward_items, is_ams_chest)
  NetManager.SendPkg(1353850343, reward_items, is_ams_chest)
end
function StoreHandler.on_receive_guarantee_reward_rsp(err_code, reward_items, boxName)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:receive_guarantee_reward_rsp(err_code, reward_items, boxName)
end
function StoreHandler.on_box_energy_receive_award_rsp(res, itemlist, boxName, decompose_list)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:box_energy_receive_award_rsp(res, itemlist, boxName, decompose_list)
end
function StoreHandler.on_please_direct_buy(cache_key, direct_itemid)
  log(bWriteLog and string.format("StoreHandler.on_please_direct_buy. cache_key=%s, direct_itemid=%s", tostring(cache_key), tostring(direct_itemid)))
  local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
  store_direct_purchase_manager:OnDirectPurchase(cache_key, direct_itemid)
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_PLEASE_DIRECT_PURCHASE, cache_key, direct_itemid)
end
function StoreHandler.send_direct_buy_result_req(cache_key, ret_code, inner_ret_code)
  NetManager.SendPkg(2123020243, cache_key, ret_code, inner_ret_code)
end
function StoreHandler.on_direct_buy_result_rsp(cache_key, ret_code, inner_ret_code)
end
function StoreHandler.send_fetch_chest_result_req(value)
  NetManager.SendPkg(1595012615, value)
end
function StoreHandler.on_fetch_chest_result_rsp(err_code, info)
end
function StoreHandler.send_get_reopen_box_full_req()
  NetManager.SendPkg(551999099)
end
function StoreHandler.on_get_reopen_box_full_rsp(res, list)
end
function StoreHandler.send_do_biochemical_activity_one_draw_req(round_count, draw_count, voucherId)
  NetManager.SendPkg(1344591655, round_count, draw_count, voucherId)
end
function StoreHandler.on_do_biochemical_activity_one_draw_rsp(res, self_biochemical_activity_data, award_info)
end
function StoreHandler.send_limited_discount_buy(activityId, index, num)
  NetManager.SendPkg(1367989132, activityId, index, num)
end
function StoreHandler.on_limited_discount_buy_rsp(res, res_id, count)
  local DiscountSystem = require("client.slua.logic.Discount_Fever.DiscountSystem")
  DiscountSystem.SendGetItemRes(res, res_id, count)
end
function StoreHandler.send_get_lucky_draw_unback_activity_req(ActivityId)
  NetManager.SendPkg(150985639, ActivityId)
end
function StoreHandler.on_get_lucky_draw_unback_activity_rsp(res, lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, my_activity_data, lucky_draw_unback_global_cfg, lucky_draw_unback_resource_cfg, lucky_draw_unback_bp_cfg, lucky_draw_unback_discount_cfg)
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.get_lucky_draw_unback_activity_rsp(res, lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, my_activity_data, lucky_draw_unback_global_cfg, lucky_draw_unback_resource_cfg, lucky_draw_unback_bp_cfg, lucky_draw_unback_discount_cfg)
end
function StoreHandler.send_do_one_draw_by_activity_req(ActivityID, Round_Count, Had_Draw_Count, CurVoucherId)
  NetManager.SendPkg(1453876871, ActivityID, Round_Count, Had_Draw_Count, CurVoucherId)
end
function StoreHandler.on_do_one_draw_by_activity_rsp(res, my_activity_data, award_info, award_List)
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.do_one_draw_by_activity_rsp(res, my_activity_data, award_info, award_List)
end
function StoreHandler.on_buy_shop_by_id_ntf(item_list, decompose_list, other_list)
  local ShopSystem = require("client.logic.shop.logic_shop")
  ShopSystem.on_open_pandora_chest_rsp(item_list, decompose_list, other_list)
end
function StoreHandler.send_market_get_askinfo_req()
  NetManager.SendPkg(1512379751)
end
function StoreHandler.on_market_get_askinfo_rsp(res, askInfo)
end
function StoreHandler.send_activity_market_buy_req(activityId)
  NetManager.SendPkg(785709972, activityId)
end
function StoreHandler.send_get_shop_limit_req()
  NetManager.SendPkg(800935847)
end
function StoreHandler.on_get_shop_limit_rsp(ret)
  log_tree(" StoreHandler.on_get_shop_limit_rsp ret = ", ret)
  if ret and next(ret) then
    local LogicSupplyUcAgLimit = require("client.slua.logic.supply.logic_supply_uc_ag_limit")
    LogicSupplyUcAgLimit.RsqShopAGLimit(ret)
  end
end
function StoreHandler.on_update_shop_limit(shop_id, shop_limit)
  log_tree(" StoreHandler.on_update_shop_limit shop_id, shop_limit = ", {shop_id, shop_limit})
  if shop_id and shop_limit and next(shop_limit) then
    local LogicSupplyUcAgLimit = require("client.slua.logic.supply.logic_supply_uc_ag_limit")
    LogicSupplyUcAgLimit.RefShopAGLimit(shop_id, shop_limit)
  end
end
function StoreHandler.send_new_props_list_req()
  NetManager.SendPkg(865297031)
end
function StoreHandler.on_new_props_list_rsp(newest_list)
end
function StoreHandler.send_get_shop_newest_info_req()
  NetManager.SendPkg(143353639)
end
function StoreHandler.on_get_shop_newest_info_rsp(info)
end
function StoreHandler.send_chest_collect_req(chest_id, source_type, collected_state)
  NetManager.SendPkg(1689138763, chest_id, source_type, collected_state)
end
function StoreHandler.on_chest_collect_rsp(err_code, chest_id, collected_state)
  local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
  supply_collect_chest_manager:chest_collect_rsp(err_code, chest_id, collected_state)
end
function StoreHandler.send_get_all_collect_chest_data_req()
  NetManager.SendPkg(1684522119)
end
function StoreHandler.on_get_all_collect_chest_data_rsp(all_chest_collected_list)
  local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
  supply_collect_chest_manager:get_all_collect_chest_data_rsp(all_chest_collected_list)
end
function StoreHandler.on_get_chest_bubble_notify_rsp(need_notify_chest_list)
  local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
  supply_collect_chest_manager:get_chest_bubble_notify_rsp(need_notify_chest_list)
end
function StoreHandler.on_notify_rc_task(rc_task_info, rc_task_cfg)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:on_notify_rc_task(rc_task_info, rc_task_cfg)
end
function StoreHandler.send_get_market_support_currency_req()
  NetManager.SendPkg(955603559)
end
function StoreHandler.on_get_market_support_currency_rsp(info, zone_key)
  local moneySystem = require("client.slua.logic.store.logic_money_component")
  moneySystem.RspStoreCurrencyConfig(info, zone_key)
  log_tree("xcc StoreHandler.on_get_market_support_currency_rsp info = ", info)
end
function StoreHandler.on_market_dynamic_price_change_notify(change_list)
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:ResponseDynamicPrice(change_list)
end
function StoreHandler.send_update_shop_wish_info_req(shop_id, item_id)
  NetManager.SendPkg(1785414199, shop_id, item_id)
end
function StoreHandler.on_update_shop_wish_info_rsp(err_code, wish_level, item_id, open_chest_times)
  if not err_code == 0 then
    ShowNotice(err_code)
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_WISH_BACK, err_code, item_id, wish_level, open_chest_times)
end
function StoreHandler.send_get_market_recommend_info_req(tab_id, sub_id)
  NetManager.SendPkg(836149903, tab_id, sub_id)
end
function StoreHandler.on_get_market_recommend_info_rsp(store_version, info)
  local StoreRecommendData = require("client.slua.logic.store.store_recommend_data")
  StoreRecommendData.RspRecommendData(store_version, info)
end
function StoreHandler.send_newbie_chest_buy(activity_id)
  NetManager.SendPkg(800915276, activity_id)
end
function StoreHandler.on_newbie_chest_buy_rsp(ok, chest_tab, decompose_list)
end
function StoreHandler.send_get_stage_chest_cfg(activity_id)
  NetManager.SendPkg(571956532, activity_id)
end
function StoreHandler.on_get_stage_chest_cfg_rsp(err_code, stage_cfg)
  if not err_code == 0 then
    ShowNotice(err_code)
  else
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_STAGE_BACK, stage_cfg)
  end
end
function StoreHandler.send_buy_stage_chest(activity_id)
  NetManager.SendPkg(900798814, activity_id)
end
function StoreHandler.on_buy_stage_chest_rsp(err_code, award_data, decompose_data, act_data)
  if not err_code == 0 then
    ShowNotice(err_code)
  else
    log_tree("decompose_data", decompose_data)
    log_tree("award_data", award_data)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_STAGE_BUY, award_data, decompose_data, act_data)
  end
end
function StoreHandler.send_get_global_mcollect_data_by_page_req(page_id)
  NetManager.SendPkg(1808111143, page_id)
end
function StoreHandler.on_get_global_mcollect_data_by_page_rsp(page_id, collect_tbl)
  if not page_id then
    log_error("on_get_global_mcollect_data_by_page_rsp page_id is nil.")
    return
  end
  if not collect_tbl then
    log_error("on_get_global_mcollect_data_by_page_rsp collect_tbl is nil.")
    return
  end
  log_tree("on_get_global_mcollect_data_by_page_rsp", collect_tbl)
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  store_collect_data:RespondCollectData(page_id, collect_tbl)
end
function StoreHandler.send_get_self_global_mcollect_data_req()
  NetManager.SendPkg(768423139)
end
function StoreHandler.on_get_self_global_mcollect_data_rsp(ret_tbl)
  log_tree("on_get_self_global_mcollect_data_rsp:ret_tbl", ret_tbl)
  if ret_tbl then
    local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
    store_collect_data:RespondSelfCollectData(ret_tbl)
  else
    log_error("self collect data is nil.")
  end
end
function StoreHandler.send_get_item_send_rule_config_req(activity_id)
  NetManager.SendPkg(983732495, activity_id)
end
function StoreHandler.on_get_item_send_rule_config_rsp(err_code, activity_id, config_table)
  if err_code == 0 then
    log_tree("on_get_item_send_rule_config_rsp == ", config_table)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKY_EXCHANGE_SENT_GIFT, activity_id, config_table)
  else
    log_error("on_get_item_send_rule_config_rsp data is nil.")
  end
end
function StoreHandler.send_get_market_gift_limit_info_req(market_id)
  log(bWriteLog and string.format("StoreHandler.send_get_market_gift_limit_info_req market_id = %s", market_id))
  NetManager.SendPkg(746322023, market_id)
end
function StoreHandler.on_get_market_gift_limit_info_rsp(list)
  log_tree("on_get_market_gift_limit_info_rsp : list = ", list)
  local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
  store_limit_buy_manager:ResSpecialGiftLimitInfo(list)
end
function StoreHandler.send_get_shop_flowlight_req()
  NetManager.SendPkg(1117896135)
end
function StoreHandler.on_get_shop_flowlight_rsp(err_code, supply_new_tag, supply_infos, LuckyBackGuide)
  log(bWriteLog and string.format("StoreHandler.on_get_shop_flowlight_rsp supply_new_tag = %s", supply_new_tag))
  log_tree("on_get_shop_flowlight_rsp supply_infos :", supply_infos)
  log(bWriteLog and "xcc StoreHandler.on_get_shop_flowlight_rsp" .. tostring(LuckyBackGuide))
  if err_code == 0 then
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:RspOptimizeSupplyInfo(supply_new_tag, supply_infos)
  else
    log_error("on_get_shop_flowlight_rsp err_code = " .. tostring(err_code))
  end
end
function StoreHandler.send_subscribe_commodity_req(market_id, optype)
  local StoreLimitedSubscribeData = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
  local offer2ShopId = StoreLimitedSubscribeData:JudgementOfferShareShopIdList(market_id)
  if not offer2ShopId then
    NetManager.SendPkg(66498475, market_id, optype)
  else
    NetManager.SendPkg(66498475, offer2ShopId, 0)
  end
end
function StoreHandler.on_subscribe_commodity_rsp(retcode, market_id, optype)
  if retcode == 0 then
    local StoreLimitedSubscribeData = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
    StoreLimitedSubscribeData:SetLimitedSubscribeState(market_id, optype)
  else
    ShowNotice(64346, true)
  end
end
function StoreHandler.on_get_subscribe_commodity_info_rsp(ret_code, sub_cnt, subs_list)
  log(bWriteLog and "StoreHandler.on_get_subscribe_commodity_info_rsp==" .. ret_code .. "==" .. sub_cnt)
  log_tree("StoreHandler.on_get_subscribe_commodity_info_rsp", subs_list)
  if ret_code == 0 then
    local StoreLimitedSubscribeData = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
    StoreLimitedSubscribeData:ReceivedLimitedSubscribeData(subs_list, sub_cnt)
  end
end
function StoreHandler.send_get_all_cond_gift_req(param_list)
  NetManager.SendPkg(964425315, param_list)
end
function StoreHandler.on_get_all_cond_gift_rsp(error_code)
  if not error_code == 0 then
    ShowNotice(error_code)
  end
end
function StoreHandler.send_get_market_collect_tips_jump_info_req()
  NetManager.SendPkg(1428642807)
end
function StoreHandler.on_get_market_collect_tips_jump_info_rsp(collect_jump_info)
  log_tree(bWriteLog and "StoreHandler.on_get_market_collect_tips_jump_info_rsp : ", collect_jump_info)
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  store_collect_data:ReceiveCollectTipsData(collect_jump_info)
end
function StoreHandler.send_get_global_collect_data_by_itemlist_req(item_list)
  NetManager.SendPkg(480951099, item_list)
end
function StoreHandler.on_get_global_collect_data_by_itemlist_rsp(ret_tbl)
  log(bWriteLog and "StoreHandler.on_get_global_collect_data_by_itemlist_rsp")
  log_tree("ret_tbl = ", ret_tbl)
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  store_collect_data:RespondSelfCollectData(ret_tbl)
end
function StoreHandler.on_get_all_cond_gift_notify(retcode, market_ret)
  log(bWriteLog and "[YY]on_get_all_cond_gift_notify==retcode=" .. tostring(retcode))
  log_tree("on_get_all_cond_gift_notify==market_ret = ", market_ret)
  if market_ret and next(market_ret) then
    ShowNotice(48259)
  end
end
function StoreHandler.send_set_performance_switch_req(switch_value)
  NetManager.SendPkg(63273841, switch_value)
end
function StoreHandler.send_do_draw_discount_by_activity_req(activity_id, round_id, had_draw_count)
  NetManager.SendPkg(1261842727, activity_id, round_id, had_draw_count)
end
function StoreHandler.on_do_draw_discount_by_activity_rsp(res, activity_id, discount_Info)
  if res ~= 0 then
    log(bWriteLog and "[SY]StoreHandler.on_do_draw_discount_by_activity_rsp.res = " .. res .. "")
    return
  end
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.on_do_draw_discount_by_activity_rsp(activity_id, discount_Info)
end
return StoreHandler