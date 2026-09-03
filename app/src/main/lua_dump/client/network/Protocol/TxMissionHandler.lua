local NetManager = require("client.network.comm.NetManager")
local TxMissionHandler = {bUseNewLogic = false, bUseNewGuide = false}
function TxMissionHandler.send_metro_info_req()
  log(bWriteLog and "TxMissionHandler.send_metro_info_req")
  NetManager.SendPkg(1810231111)
end
function TxMissionHandler.on_metro_info_rsp(res, depot_capacity, metro)
  log(bWriteLog and "TxMissionHandler.on_metro_info_rsp res = " .. res)
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res)
    return
  end
  log_tree("depot_capacity = ", depot_capacity)
  log_tree("metro = ", metro)
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  logic_xmission_info:proc_metro_info_rsp(depot_capacity, metro)
  local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
  logic_xmission_entrance:PreCheckXMissionOnlineCallback()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.on_metro_info_rsp(depot_capacity, metro)
  local logic_affix_pictorial_book = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_affix_pictorial_book)
  logic_affix_pictorial_book:update_owned_affixs(metro.owned_affixs)
  TxMissionHandler.send_get_insurance_status()
end
function TxMissionHandler.send_metro_move_item_req(inst_id, num, dst_desc, dst_slot, dst_inst_id, silent)
  log(bWriteLog and "TxMissionHandler.send_metro_move_item_req inst_id = " .. inst_id .. ", num = " .. num .. ", dst_desc = " .. dst_desc .. ", dst_slot = " .. dst_slot .. ", dst_inst_id = " .. dst_inst_id .. ", silent = " .. tostring(silent))
  NetManager.SendPkg(1604937991, inst_id, num, dst_desc, dst_slot, dst_inst_id, silent)
end
function TxMissionHandler.on_metro_move_item_rsp(res, inst_id, dst_desc, dst_slot, dst_inst_id)
  log(bWriteLog and "TxMissionHandler.on_metro_move_item_rsp res = " .. res .. ", inst_id = " .. tostring(inst_id) .. ", dst_desc = " .. tostring(dst_desc) .. ", dst_slot = " .. tostring(dst_slot) .. ", dst_inst_id = " .. tostring(dst_inst_id))
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res or 11345)
    return
  end
  local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  LogicTxMissionWarPre.on_metro_move_item_rsp(inst_id, dst_desc, dst_slot, dst_inst_id)
end
function TxMissionHandler.send_metro_sell_req(inst_id, item_num)
  log(bWriteLog and "send_metro_sell_req inst_id:" .. tostring(inst_id))
  NetManager.SendPkg(203743367, inst_id, item_num)
end
function TxMissionHandler.on_metro_sell_rsp(res, inst_id, item_num, moneys)
  log(bWriteLog and "on_metro_sell_rsp res:" .. tostring(res) .. " sell_inst:" .. tostring(inst_id))
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res)
    return
  end
  if res == 0 then
    local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
    logic_xmission_black_market.SellOneItemRsp(res, inst_id, item_num, moneys)
  end
end
function TxMissionHandler.on_metro_item_change_ntfy(dst_desc, inst_id, item, dst_slot, dst_inst_id)
  log(bWriteLog and "TxMissionHandler.on_metro_item_change_ntfy dst_desc = " .. dst_desc .. ", inst_id = " .. inst_id .. ", dst_slot = " .. tostring(dst_slot) .. ", dst_inst_id = " .. tostring(dst_inst_id))
  log_tree("item = ", item)
  local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  LogicTxMissionWarPre.on_metro_item_change_ntfy(inst_id, item, dst_desc, dst_slot, dst_inst_id)
end
function TxMissionHandler.on_metro_money_ntfy(item_id, after, item_num)
  log(bWriteLog and "on_metro_money_ntfy item_id:" .. tostring(item_id) .. " after:" .. tostring(after) .. " item_num:" .. tostring(item_num))
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.on_metro_money_ntfy(item_id, after, item_num)
end
function TxMissionHandler.send_enter_metro_scence_req()
  log(bWriteLog and "TxMissionHandler.send_enter_metro_scence_req")
  NetManager.SendPkg(810119047)
end
function TxMissionHandler.on_enter_metro_scence_rsp(res, metro_scence_data, rate_up_data, ext_info)
  log(bWriteLog and "TxMissionHandler.on_enter_metro_scence_rsp res = " .. res)
  log_tree("metro_scence_data = ", metro_scence_data)
  log_tree("rate_up_data = ", rate_up_data)
  log_tree("ext_info = ", ext_info)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    LogicTxMissionDownload.MAP_KEY
  })
  LogicTxMissionMain.ClearResetIsInXmissionTimer()
  if res ~= 0 or state ~= PufferConst.ENUM_DownloadState.Done then
    if res == 100251043 and state ~= PufferConst.ENUM_DownloadState.Done then
      LogicTxMissionDownload.OpenDownload()
    else
      TxMissionHandler.ShowErrorTips(res, ext_info)
    end
    if LogicTxMissionMain.IsInXMission(true) then
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      local timer_tick = require("common.time_ticker")
      if res == 100250003 then
        LogicTxMissionMain.OnQuitXMission(res)
        local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
        LobbyThemeManager:ExitXMission()
        LobbyThemeManager:ShowTheme()
        timer_tick.AddTimerOnce(2, function()
          log(bWriteLog and "on_enter_metro_scence_rsp, 100250003 timer_tick.")
          LoadingSystem.RefreshLoadPercent(1)
        end)
      else
        timer_tick.AddTimerOnce(10, function()
          log(bWriteLog and "on_enter_metro_scence_rsp, timer_tick.")
          LoadingSystem.RefreshLoadPercent(1)
          LogicTxMissionMain.QuitXMission(true)
        end)
      end
    elseif state ~= PufferConst.ENUM_DownloadState.Done then
      LogicTxMissionMain.QuitXMission(true)
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.metro_team_flag then
      TeamUpNewSystem.teamInfo.metro_team_flag = false
    end
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ON_ENTERTPLAN_NOTIFY, false)
    UIManager.CloseUI(UIManager.UI_Config.ModeSelection_Opening_Train_UIBP)
    return
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ON_ENTERTPLAN_NOTIFY, true)
  LogicTxMissionMain.OnEnterXMissionRsp(metro_scence_data, rate_up_data)
end
function TxMissionHandler.send_exit_metro_scence_req()
  log(bWriteLog and "[muidarzhang] TxMissionHandler.send_exit_metro_scence_req")
  NetManager.SendPkg(1536687259)
end
function TxMissionHandler.on_exit_metro_scence_rsp(res, exit_reason)
  log_format(bWriteLog and "TxMissionHandler.on_exit_metro_scence_rsp, res:%s, exit_reason:%s", res, exit_reason)
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res)
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.OnQuitXMission(exit_reason)
end
function TxMissionHandler.send_report_enter_metro_scence()
  NetManager.SendPkg(1569425701)
end
function TxMissionHandler.send_report_exit_metro_scence()
  NetManager.SendPkg(8735533)
end
function TxMissionHandler.on_query_client_metro_scence_status()
end
function TxMissionHandler.send_metro_trans_team_type_req(opt)
  NetManager.SendPkg(842924151, opt)
end
function TxMissionHandler.on_metro_trans_team_type_rsp(res, opt, team_id, invalid_members, ext_info)
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res, ext_info, invalid_members)
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.OnChangeTeamTypeRsp(team_id, opt)
end
function TxMissionHandler.on_metro_bag_capacity_ntfy(bag_type, added)
  local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  LogicTxMissionWarPre.on_metro_bag_capacity_ntfy(bag_type, added)
end
function TxMissionHandler.send_metro_shop_query_label_list_req(last_version)
  log(bWriteLog and "TxMissionHandler.send_metro_shop_query_label_list_req")
  NetManager.SendPkg(40828463, last_version)
end
function TxMissionHandler.on_metro_shop_query_label_list_rsp(err, version, tabList, subTabList)
  if err ~= 0 then
    TxMissionHandler.ShowErrorTips(err)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.OnGetTabList(err, version, tabList, subTabList)
end
function TxMissionHandler.send_metro_shop_query_label_info_req(last_version, tabId)
  NetManager.SendPkg(737936463, last_version, tabId)
end
function TxMissionHandler.on_metro_shop_query_label_info_rsp(err, version, tabId, filterList, tabInfo)
  if err ~= 0 then
    TxMissionHandler.ShowErrorTips(err)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.OnGetTabInfo(err, version, tabId, filterList, tabInfo)
end
function TxMissionHandler.send_metro_select_confirm_req(mode_group, fill)
  log(bWriteLog and "TxMissionHandler.send_metro_select_confirm_req fill = " .. fill)
  log_tree("mode_group = ", mode_group)
  NetManager.SendPkg(1925550375, mode_group, fill)
end
function TxMissionHandler.on_metro_select_confirm_rsp(res, mode_group)
  log(bWriteLog and "TxMissionHandler.on_metro_select_confirm_rsp res = " .. res)
  log_tree("mode_group = ", mode_group)
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res, mode_group)
    return
  end
  local LogicTxMissionTeam = require("client.slua.logic.TxMission.logic_xmission_team")
  LogicTxMissionTeam.on_metro_select_confirm_rsp(mode_group)
end
function TxMissionHandler.on_metro_shop_ver_notify(version)
end
function TxMissionHandler.send_metro_take_profit_award_req(profit_num)
  log(bWriteLog and "TxMissionHandler.send_metro_take_profit_award_req : profit_num = " .. profit_num)
  NetManager.SendPkg(1781807203, profit_num)
end
function TxMissionHandler.on_metro_take_profit_award_rsp(err, profit_num, awards_list)
  log(bWriteLog and string.format("TxMissionHandler.on_metro_take_profit_award_rsp : err = %s  profit_num =  %s ", err, profit_num))
  log_tree("TxMissionHandler.on_metro_take_profit_award_rsp :  awards_list = ", awards_list)
  if err ~= 0 then
    TxMissionHandler.ShowErrorTips(err)
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.OnTakeWorthAward(err, profit_num, awards_list)
end
function TxMissionHandler.on_metro_profit_notify(old_cur_value, old_max_value, cur_profit_value, max_profit_value)
  log(bWriteLog and string.format("TxMissionHandler.on_metro_profit_notify : old_cur_value = %s  old_max_value =  %s  cur_profit_value  =  %s  max_profit_value =  %s", old_cur_value, old_max_value, cur_profit_value, max_profit_value))
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.on_metro_profit_ntfy(old_cur_value, old_max_value, cur_profit_value, max_profit_value)
end
function TxMissionHandler.send_set_rating_zone_id(zone_id)
  NetManager.SendPkg(1477300514, zone_id)
end
function TxMissionHandler.on_set_rating_zone_id_notify(res, zone_id)
end
function TxMissionHandler.send_metro_task_sync_all_req()
  NetManager.SendPkg(1655826949)
  log(bWriteLog and " TxMissionHandler.send_metro_task_sync_all_req")
end
function TxMissionHandler.on_metro_task_sync_all(task_all_info)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    log(bWriteLog and string.format(" Not dealt with in battle."))
    return
  end
  local LogicXmissionTask = require("client.slua.logic.TxMission.xmission_task.logic_xmission_task")
  LogicXmissionTask.ResponseInitData(task_all_info)
  log_tree(" TxMissionHandler.on_metro_task_sync_all : task_all_info = ", task_all_info)
end
function TxMissionHandler.on_metro_task_sync_one(category, task_id, task_info)
  local LogicXmissionTask = require("client.slua.logic.TxMission.xmission_task.logic_xmission_task")
  LogicXmissionTask.ResponsePushedTask(category, task_id, task_info)
  log(bWriteLog and string.format("TxMissionHandler.on_metro_task_sync_one : category : %s , task_id : %s ", category, task_id))
  log_tree("TxMissionHandler.on_metro_task_sync_one : task_info = ", task_info)
end
function TxMissionHandler.send_metro_task_take_award_req(category, task_id)
  log(bWriteLog and "TxMissionHandler.send_metro_task_take_award_req category = " .. category .. ", task_id = " .. task_id)
  NetManager.SendPkg(2104098439, category, task_id)
end
function TxMissionHandler.on_metro_task_take_award_rsp(err_code, category, task_id, award_list)
  log(bWriteLog and "TxMissionHandler.on_metro_task_take_award_rsp err_code = " .. err_code .. ", category = " .. tostring(category) .. ", task_id = " .. tostring(task_id))
  log_tree("award_list = ", award_list)
  if err_code ~= 0 then
    TxMissionHandler.ShowErrorTips(err_code)
    return
  end
  local LogicXmissionTask = require("client.slua.logic.TxMission.xmission_task.logic_xmission_task")
  LogicXmissionTask.ResponseGetTaskAward(err_code, category, task_id, award_list)
end
function TxMissionHandler.send_metro_collection_get_story_req()
  NetManager.SendPkg(1755074343)
end
function TxMissionHandler.on_metro_collection_get_story_rsp(ret, data)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  local TxMissionCollectionStorySystem = require("client.slua.logic.TxMission.collection.story.logic_xmission_collection_story")
  TxMissionCollectionStorySystem.get_metro_collection_get_story_rsp(ret, data)
end
function TxMissionHandler.send_metro_collection_read_story_req(story_id)
  NetManager.SendPkg(1799655175, story_id)
end
function TxMissionHandler.on_metro_collection_read_story_rsp(ret)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  local TxMissionCollectionStorySystem = require("client.slua.logic.TxMission.collection.story.logic_xmission_collection_story")
  TxMissionCollectionStorySystem.get_metro_collection_read_story_rsp(ret)
end
function TxMissionHandler.send_metro_collection_get_achievement_req()
  NetManager.SendPkg(937825703)
end
function TxMissionHandler.on_metro_collection_get_achievement_rsp(ret, data)
end
function TxMissionHandler.send_metro_collection_receive_achievement_req(achievement_id)
  NetManager.SendPkg(252203815, achievement_id)
end
function TxMissionHandler.on_metro_collection_receive_achievement_rsp(ret)
end
function TxMissionHandler.send_metro_collection_get_red_point_req()
  NetManager.SendPkg(1147363975)
end
function TxMissionHandler.on_metro_collection_get_red_point_rsp(show_point)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.on_metro_collection_get_red_point_rsp(show_point)
end
function TxMissionHandler.send_metro_repaire_req(inst_id)
  NetManager.SendPkg(1478913907, inst_id)
end
function TxMissionHandler.on_metro_repaire_rsp(err, inst_id, item)
  if err ~= 0 then
    TxMissionHandler.ShowErrorTips(err)
    return
  end
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  logic_xmission_warpre.on_metro_repaire_rsp(err, inst_id)
end
function TxMissionHandler.send_metro_batch_sell_req(sell_items)
  NetManager.SendPkg(1998753575, sell_items)
end
function TxMissionHandler.on_metro_batch_sell_rsp(res, sell_items, all_moneys)
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.SellMoreItemRsp(res, sell_items, all_moneys)
end
function TxMissionHandler.on_metro_npc_sync_one(npc_id, data)
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  XMissionNpcSystem.OnMetroNpcSyncOne(npc_id, data)
end
function TxMissionHandler.on_metro_npc_level_up_notify(npc_id, old_level, new_level, awards_list)
  log(bWriteLog and string.format("TxMissionHandler.on_metro_npc_level_up_notify, npc_id:%s, old_level:%s, new_level:%s", npc_id, old_level, new_level))
  log_tree(bWriteLog and "TxMissionHandler.on_metro_npc_level_up_notify awards_list", awards_list)
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  XMissionNpcSystem.OnMetroNpcLevelUpNotify(npc_id, old_level, new_level, awards_list)
end
function TxMissionHandler.on_metro_npc_effects_sync(effect_data)
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  XMissionNpcSystem.OnMetroNpcEffectsSync(effect_data)
end
function TxMissionHandler.send_metro_npc_talk_req(npc_id)
  NetManager.SendPkg(431970887, npc_id)
end
function TxMissionHandler.on_metro_npc_talk_rsp(err_code, npc_id, plot_id, favor)
  if err_code ~= 0 then
    TxMissionHandler.ShowErrorTips(err_code)
    return
  end
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  XMissionNpcSystem.OnMetroNpcTalkRsp(npc_id, plot_id, favor)
end
function TxMissionHandler.send_metro_npc_gift_req(npc_id, inst_id, num)
  log(bWriteLog and "TxMissionHandler.send_metro_npc_gift_req npc_id = " .. npc_id .. ", inst_id = " .. inst_id .. ", num = " .. num)
  NetManager.SendPkg(30460487, npc_id, inst_id, num)
end
function TxMissionHandler.on_metro_npc_gift_rsp(err_code, npc_id, plot_id, favor, base_favor, random_favor, daily_send_gift_cnt, npcData)
  log_format(bWriteLog and "TxMissionHandler:on_metro_npc_gift_rsp. err_code:%s npc_id:%s plot_id:%s favor:%s base_favor:%s random_favor:%s daily_send_gift_cnt:%s", tostring(err_code), tostring(npc_id), tostring(plot_id), tostring(favor), tostring(base_favor), tostring(random_favor), tostring(daily_send_gift_cnt))
  log_tree("TxMissionHandler.on_metro_npc_gift_rsp npcData ", npcData)
  if err_code ~= 0 then
    TxMissionHandler.ShowErrorTips(err_code)
    return
  end
  local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
  XMissionNpcSystem.OnMetroNpcGiftRsp(npc_id, plot_id, favor, base_favor, random_favor, daily_send_gift_cnt)
  XMissionNpcSystem.OnMetroNpcSyncOne(npc_id, npcData, random_favor)
end
function TxMissionHandler.on_metro_npc_trigger_plot_notify(plot_id, param_type, param1)
  log(bWriteLog and "TxMissionHandler.on_metro_npc_trigger_plot_notify plot_id = " .. plot_id .. ", param_type = " .. tostring(param_type))
  log_tree("param1 = ", param1)
  if TxMissionHandler.bUseNewLogic then
    local logic_xmission_npc_plot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_npc_plot)
    logic_xmission_npc_plot:proc_metro_npc_trigger_plot_notify(plot_id, param_type, param1)
  else
    local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
    XMissionNpcSystem.OnMetroNpcTriggerPlotNotify(plot_id, param_type, param1)
  end
end
function TxMissionHandler.send_metro_shop_buy_shop_req(shopId, num)
  log(bWriteLog and "TxMissionHandler.send_metro_shop_buy_shop_req shopId = " .. shopId .. ", num = " .. num)
  NetManager.SendPkg(1279350971, shopId, num)
end
function TxMissionHandler.on_metro_shop_buy_shop_rsp(err, shopId, num, haveBought)
  log(bWriteLog and "TxMissionHandler.on_metro_shop_buy_shop_rsp err = " .. err .. ", shopId = " .. tostring(shopId) .. ", num = " .. tostring(num) .. ", haveBought = " .. tostring(haveBought))
  if err ~= 0 then
    TxMissionHandler.ShowErrorTips(err)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.PurchaseOneItemRsp(err, shopId, num, haveBought)
end
function TxMissionHandler.send_metro_shop_buy_mystery_req(index, shop_id, count)
  NetManager.SendPkg(909326759, index, shop_id, count)
end
function TxMissionHandler.on_metro_shop_buy_mystery_rsp(ret, index, shop_id, count, has_buy_num)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.PurchaseMysticalOneItemRsp(ret, index, shop_id, count, has_buy_num)
end
function TxMissionHandler.on_notify_prestige_change(prestige, prestige_level)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.OnPrestigeChangeNotify(prestige, prestige_level)
end
function TxMissionHandler.on_notify_prestige_level_change(old_prestige_level, new_prestige_level, award_list)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.OnPrestigeLevelChangeNotify(old_prestige_level, new_prestige_level, award_list)
end
function TxMissionHandler.send_metro_shop_query_user_data_req(last_version)
  NetManager.SendPkg(355636551, last_version)
end
function TxMissionHandler.on_metro_shop_query_user_data_rsp(ret, version, user_data)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.GetUserDataInfoRsp(ret, version, user_data)
end
function TxMissionHandler.send_metro_shop_query_mystery_info_req(last_version)
  NetManager.SendPkg(919231547, last_version)
end
function TxMissionHandler.on_metro_shop_query_mystery_info_rsp(ret, version, mystery_data)
  log(bWriteLog and "TxMissionHandler.on_metro_shop_query_mystery_info_rsp")
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.canSecReq = true
  logic_xmission_black_market.OnGetTabInfo(ret, version, logic_xmission_black_market.mysticalTabId, nil, mystery_data)
end
function TxMissionHandler.send_metro_shop_get_red_point_req()
  NetManager.SendPkg(1021780967)
end
function TxMissionHandler.on_metro_shop_get_red_point_rsp(show_point)
end
function TxMissionHandler.send_metro_shop_unlock_mystery_req()
  NetManager.SendPkg(602640975)
end
function TxMissionHandler.on_metro_shop_unlock_mystery_rsp(ret, version, mystery_data)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.OnGetTabInfo(ret, version, logic_xmission_black_market.mysticalTabId, nil, mystery_data)
end
function TxMissionHandler.send_metro_shop_refresh_mystery_req(is_free, refresh_count)
  log(bWriteLog and "TxMissionHandler.send_metro_shop_refresh_mystery_req")
  NetManager.SendPkg(355231047, is_free, refresh_count)
end
function TxMissionHandler.on_metro_shop_refresh_mystery_rsp(ret, version, mystery_data)
  log(bWriteLog and "TxMissionHandler.on_metro_shop_refresh_mystery_rsp")
  if ret == 100251002 then
    ShowNotice(LocUtil.GetLocalizeResStr(25143))
    TxMissionHandler.send_metro_shop_query_mystery_info_req(0)
  elseif ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  else
    local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
    logic_xmission_black_market.OnGetTabInfo(ret, version, logic_xmission_black_market.mysticalTabId, nil, mystery_data)
  end
end
function TxMissionHandler.send_metro_shop_receive_mystery_daily_chest_req()
  NetManager.SendPkg(1230278727)
end
function TxMissionHandler.on_metro_shop_receive_mystery_daily_chest_rsp(ret, item_list)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  log_tree("TxMissionHandler.on_metro_shop_receive_mystery_daily_chest_rsp item_list:", item_list)
end
function TxMissionHandler.send_uninstall_bag_items_req()
  NetManager.SendPkg(824881835)
end
function TxMissionHandler.on_uninstall_bag_items_rsp(ret)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_ITEM_NOTIFY)
end
function TxMissionHandler.send_metro_mastery_info_req()
  log(bWriteLog and "TxMissionHandler.send_metro_mastery_info_req")
  NetManager.SendPkg(756639687)
end
function TxMissionHandler.on_metro_mastery_info_rsp(err, deploy)
  if err ~= 0 then
    TxMissionHandler.ShowErrorTips(err)
    return
  end
  log_tree("TxMissionHandler.on_metro_mastery_info_rsp deploy = ", deploy)
  local TalentDataMgr = require("client.slua.logic.TxMission.talent.logic_xmission_talent_data")
  TalentDataMgr:OnGetTalentData(err, deploy)
end
function TxMissionHandler.send_metro_mastery_deploy_req(deploy_id, mastery_id, point)
  log(bWriteLog and "TxMissionHandler.send_metro_mastery_deploy_req " .. deploy_id .. " " .. mastery_id .. " " .. point)
  NetManager.SendPkg(1405606055, deploy_id, mastery_id, point)
end
function TxMissionHandler.on_metro_mastery_deploy_rsp(err, deploy_id, mastery_id, point)
  log(bWriteLog and "TxMissionHandler.on_metro_mastery_deploy_rsp err:" .. tostring(err))
  if err ~= 0 then
    TxMissionHandler.ShowErrorTips(err)
    TxMissionHandler.send_metro_mastery_info_req()
    return
  end
  local TalentDataMgr = require("client.slua.logic.TxMission.talent.logic_xmission_talent_data")
  TalentDataMgr:OnDeployChanged(err, deploy_id, mastery_id, point)
end
function TxMissionHandler.send_metro_mastery_select_req(deploy_id)
  log(bWriteLog and "TxMissionHandler.send_metro_mastery_select_req " .. deploy_id)
  NetManager.SendPkg(1007488551, deploy_id)
end
function TxMissionHandler.on_metro_mastery_select_rsp(err, deploy_id)
  log(bWriteLog and "TxMissionHandler.on_metro_mastery_select_rsp err:" .. tostring(err))
  local TalentDataMgr = require("client.slua.logic.TxMission.talent.logic_xmission_talent_data")
  if err ~= 0 then
    if err == 100251044 then
      TalentDataMgr:ProcessBagCapacityConflict()
    else
      TxMissionHandler.ShowErrorTips(err)
    end
    return
  end
  TalentDataMgr:OnUseScheme(err, deploy_id)
end
function TxMissionHandler.send_metro_mastery_reset_req(deploy_id)
  log(bWriteLog and "TxMissionHandler.send_metro_mastery_reset_req " .. deploy_id)
  NetManager.SendPkg(833165399, deploy_id)
end
function TxMissionHandler.on_metro_mastery_reset_rsp(err, deploy_id)
  log(bWriteLog and "TxMissionHandler.on_metro_mastery_reset_rsp " .. err)
  local TalentDataMgr = require("client.slua.logic.TxMission.talent.logic_xmission_talent_data")
  if err ~= 0 then
    if err == 100251044 then
      TalentDataMgr:ProcessBagCapacityConflict()
    else
      TxMissionHandler.ShowErrorTips(err)
    end
    return
  end
  TalentDataMgr:OnResetCurSheme(err, deploy_id)
end
function TxMissionHandler.send_metro_shop_buy_box_req(box_shop_id, count, content_shop_ids)
  NetManager.SendPkg(750752551, box_shop_id, count, content_shop_ids)
end
function TxMissionHandler.on_metro_shop_buy_box_rsp(ret, shop_id, count, has_buy_num, box_all_res_list, box_result_inst_list)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.PurchaseChestOneItemRsp(ret, shop_id, count, has_buy_num, box_all_res_list, box_result_inst_list)
end
function TxMissionHandler.send_metro_shop_get_label_red_point_req()
  NetManager.SendPkg(90858279)
end
function TxMissionHandler.on_metro_shop_get_label_red_point_rsp(ret, first_point_data, second_point_data)
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.GetReddotInfoRsp(ret, first_point_data, second_point_data)
end
function TxMissionHandler.send_metro_shop_remove_label_red_point_req(first_label_id, second_label_id)
  NetManager.SendPkg(1906576482, first_label_id, second_label_id)
end
function TxMissionHandler.send_metro_lbs_rank_req(rank_type, rank_id)
  log(bWriteLog and string.format(" LogicXWarZoneRank.GetWarZoneRankListReq rank_type : %s rank_id : %s", rank_type, rank_id))
  NetManager.SendPkg(1722289351, rank_type, rank_id)
end
function TxMissionHandler.on_metro_lbs_rank_rsp(err_code, rank_type, rank_id, rank_list)
  log(bWriteLog and string.format(" TxMissionHandler.on_metro_lbs_rank_rsp err_code : %s rank_type : %s rank_id : %s", err_code, rank_type, rank_id))
  log_tree(" TxMissionHandler.on_metro_lbs_rank_rsp rank_list = ", rank_list)
  if err_code == 0 then
    local LogicXWarZoneRank = require("client.slua.logic.TxMission.rank.logic_xmission_warzone_rank")
    LogicXWarZoneRank.GetWarZoneRankListRes(err_code, rank_type, rank_id, rank_list)
  else
    TxMissionHandler.ShowErrorTips(err_code)
  end
end
local ShowErrorPopUpWindows = function(error, banInfo, ext_info)
  local TableUtil = require("common.table_util")
  local TimeUtil = require("client.common.time_util")
  local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
  local curTime = TimeUtil.GetServerTimeInSec()
  local remainTime = 0
  if error == 100251031 then
    log_tree("TxMissionHandler.ShowErrorPopUpWindows banInfo = ", banInfo)
    remainTime = tonumber(TableUtil.GetTableValue(banInfo[BanMacro.PLAYER_BAN_T_MODE_NOT_INVITE], "end_time") or 0) - curTime
  elseif error == 100251051 then
    log_tree("TxMissionHandler.ShowErrorPopUpWindows banInfo = ", TableUtil.GetTableValue(LobbySystem.roleData, "mil_info"))
    remainTime = tonumber(TableUtil.GetTableValue(LobbySystem.roleData, "mil_info", "expire_time") or 0) - curTime
  end
  log(bWriteLog and string.format("[muidarzhang] ShowErrorPopUpWindows, remainTime:%s", remainTime))
  if remainTime <= 0 then
    ShowNotice(error)
    return
  end
  local timeStr = TimeUtil.FormatCountDownTime_DHMS(remainTime)
  local userName = DataMgr.roleData.nickName or ""
  local userUid = DataMgr.roleData.uid or ""
  local strCode = error
  if error == 100251031 then
    strCode = tonumber(TableUtil.GetTableValue(banInfo[BanMacro.PLAYER_BAN_T_MODE_NOT_INVITE], "reason")) or 38850
    if strCode < 10000 then
      strCode = 38850
    end
  end
  local banTipStr = LocUtil.LocalizeFormatConcatenation(strCode, userName, userUid, timeStr)
  log(bWriteLog and string.format("[muidarzhang] ShowErrorPopUpWindows, strCode:%s", strCode))
  if not ext_info or type(ext_info) ~= "table" or not ext_info.appeal_link_switch then
    local localResCfg = LocUtil.GetLocalizeResStr(strCode)
    if not (not (strCode < 10000) and localResCfg) or localResCfg == "" then
      ShowNotice(error)
      return
    end
    if banTipStr == "" then
      ShowNotice(error)
      return
    end
  end
  local ban_reason = banInfo[BanMacro.PLAYER_BAN_T_MODE_NOT_INVITE] and banInfo[BanMacro.PLAYER_BAN_T_MODE_NOT_INVITE].reason
  if ban_reason then
    log(bWriteLog and "ShowErrorPopUpWindows ban_reason: " .. tostring(ban_reason))
    local ban_reason_id = tonumber(ban_reason)
    if ban_reason_id then
      local HasDone = {
        [38850] = true,
        [37501] = true,
        [100251051] = true
      }
      if HasDone[ban_reason_id] then
        log(bWriteLog and "ShowErrorPopUpWindows ban_reason has done")
      else
        local banTipStr_txt = LocUtil.LocalizeFormatConcatenation(ban_reason_id, timeStr)
        if banTipStr_txt and banTipStr_txt ~= "" then
          banTipStr = banTipStr_txt
        else
          log(bWriteLog and "ShowErrorPopUpWindows ban_reason is nil :" .. tostring(ban_reason_id))
        end
      end
    else
      banTipStr = ban_reason
    end
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local OpenCustomerService = function()
    local helpShiftStr = ""
    if error == 100251031 then
      log(bWriteLog and "[muidarzhang] OpenCustomerService, 100251031. ")
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_TPlan_BusinessSecurity_Click)
      helpShiftStr = "mr_ban_tplanlimit"
    elseif error == 100251051 then
      log(bWriteLog and "[muidarzhang] OpenCustomerService, 100251051. ")
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_TPlan_ProjectSecurity_Click)
      helpShiftStr = "mr_ban_miltplanlimit"
    end
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local strRegion = Client.GetPublishRegion()
    if strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.FIT then
      LogicCustomerService.HelpshiftShowSingleFAQ("390", helpShiftStr)
    else
      LogicCustomerService.HelpshiftShowFAQsWithInfo(helpShiftStr)
    end
  end
  local clickAppeallCallback = function()
    if error == 100251031 then
      log(bWriteLog and "[muidarzhang] OpenCustomerService, 100251031. ")
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_TPlan_BusinessSecurity_Click)
    elseif error == 100251051 then
      log(bWriteLog and "[muidarzhang] OpenCustomerService, 100251051. ")
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_TPlan_ProjectSecurity_Click)
    end
    local logic_security = require("client.slua.logic.security.logic_security")
    logic_security.JumpAppealURL()
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local clickReduceCallback = function()
    local loginType = login_module.nLoginType
    local country = login_module:GetIpRegion()
    local IntlHelper = import("IntlHelper")
    local timezone = IntlHelper.GetLocalTimezone()
    local language = Client.GetCurrentLanguage()
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    local StringUtil = require("common.string_util")
    local strUserName = StringUtil.EncodeURI(DataMgr.roleData.nickName)
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366177) .. "/user_guide/index.html?" .. FuncUtil.GetKeywordByID(3377009) .. "Id=" .. Client.GetITopGameId() .. "&language=" .. language .. "&country=" .. country .. "&loginType=" .. loginType .. "&roleName=" .. strUserName .. "&timeZone=" .. timezone, true)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Appeal_Observation_Click)
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local stAppeal = LocUtil.GetLocalizeResStr(4004)
  log_tree("ShowErrorPopUpWindows ext_info = ", ext_info)
  if ext_info and ext_info.is_soft_punish then
    stAppeal = LocUtil.GetLocalizeResStr(8500233)
    banTipStr = LocUtil.LocalizeResFormatByStr(ext_info.reason, userName, userUid, timeStr)
    CommonMsgBoxMgr.Show(3, title, banTipStr, clickReduceCallback, nil, stAppeal)
  elseif ext_info and ext_info.appeal_link_switch then
    CommonMsgBoxMgr.Show(3, title, banTipStr, clickAppeallCallback, nil, stAppeal)
  else
    CommonMsgBoxMgr.Show(2, title, banTipStr, nil, OpenCustomerService, nil, stAppeal)
  end
end
function TxMissionHandler.ShowErrorTips(error_id, ext_info, invalid_members)
  log(bWriteLog and "TxMissionHandler ShowErrorTips, error_id = " .. error_id)
  local errorMsg = LocUtil.GetLocalizeResStr(error_id)
  local banInfo = DataMgr.ban
  if tonumber(error_id) == 100251048 then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ERROR)
    local msgData = {
      clickOkCallback = function()
        local SettingUtil = require("client.slua.logic.setting.setting_util")
        SettingUtil.Enter("Account")
      end,
      msg = errorMsg,
      styleType = 3
    }
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(msgData.styleType, nil, msgData.msg, msgData.clickOkCallback)
  elseif banInfo and (tonumber(error_id) == 100251031 or tonumber(error_id) == 100251051) then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if not LogicTxMissionMain.banWindowShow then
      return
    end
    log(bWriteLog and "[muidarzhang] TxMissionHandler.ShowErrorTips, banInfo and (tonumber(error_id) == 100251031 or tonumber(error_id) == 100251051).")
    ShowErrorPopUpWindows(error_id, banInfo, ext_info)
  elseif tonumber(error_id) == 100251052 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.LocalizeResFormat(101001)
    local msg = LocUtil.LocalizeResFormat(101706)
    CommonMsgBoxMgr.Show(1, title, msg)
  elseif tonumber(error_id) == 100251041 then
    if invalid_members and next(invalid_members) then
      local id, errCode = next(invalid_members)
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(id)
      local name = ""
      if profile then
        name = profile.nickName
      end
      if errCode == 100150049 then
        ShowNotice(LocUtil.LocalizeResFormat(200000129, name))
      elseif errCode == 100251034 then
        ShowNotice(LocUtil.LocalizeResFormat(7925, name))
      else
        ShowNotice(errorMsg)
      end
    else
      ShowNotice(errorMsg)
    end
  elseif tonumber(error_id) == 100251077 then
    local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
    xmission_wardrobe_data.CheckUndercoverCapacity(ext_info.mode_group, true)
  else
    ShowNotice(errorMsg)
    local logic_mode_selection_for_umg = require("client.slua.logic.mode_selection.logic_mode_selection_for_umg")
    logic_mode_selection_for_umg.SetNotMTXMissionIfHasClosed()
  end
end
function TxMissionHandler.send_metro_take_profit_award_batch_req()
  NetManager.SendPkg(833420855)
end
function TxMissionHandler.on_metro_take_profit_award_batch_rsp(err_code, awards, award_list)
  log(bWriteLog and string.format("TxMissionHandler.on_metro_take_profit_award_rsp : err = %s ", err_code))
  log_tree("TxMissionHandler.on_metro_take_profit_award_rsp :  awards = ", awards)
  log_tree("TxMissionHandler.on_metro_take_profit_award_rsp :  award_list = ", award_list)
  if err_code ~= 0 then
    TxMissionHandler.ShowErrorTips(err_code)
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.ReceiveAllSettlementGift(err_code, awards, award_list)
end
function TxMissionHandler.send_metro_open_chest_req(inst_id, count)
  NetManager.SendPkg(1293431335, inst_id, count)
end
function TxMissionHandler.on_metro_open_chest_rsp(ret, items)
  log(bWriteLog and string.format("TxMissionHandler.on_metro_open_chest_rsp, ret:%s", ret))
  log_tree("TxMissionHandler.on_metro_open_chest_rsp items:", items)
  if ret == 0 then
    local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    LogicTxMissionWarPre.metro_open_chest_rsp(items)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_ITEM_NOTIFY)
  else
    TxMissionHandler.ShowErrorTips(ret)
    local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
    if logic_xmission_operation:GetIsReceivingChset() then
      logic_xmission_operation:SetIsReceivingChset(false)
    end
  end
end
function TxMissionHandler.send_metro_guide_query_req()
  log(bWriteLog and "TxMissionHandler.send_metro_guide_query_req")
  NetManager.SendPkg(1518821879)
end
function TxMissionHandler.on_metro_guide_query_rsp(err, state, victoryCount, totalCount)
  log(bWriteLog and "TxMissionHandler.on_metro_guide_query_rsp err = " .. err .. ", victoryCount = " .. tostring(victoryCount) .. ", totalCount = " .. tostring(totalCount))
  log_tree("state = ", state)
  if err ~= 0 then
    return
  end
  if TxMissionHandler.bUseNewGuide then
    local logic_xmission_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_guide)
    logic_xmission_guide:proc_metro_guide_query_rsp(state, victoryCount, totalCount)
  else
    local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
    LogicXMissionBeginnerGuide.GetGuideStateRsp(err, state, victoryCount, totalCount)
  end
end
function TxMissionHandler.send_metro_guide_set_progress_req(state)
  NetManager.SendPkg(1235702695, state)
end
function TxMissionHandler.on_metro_guide_set_progress_rsp(err, state)
  if err == 0 then
    local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
    LogicXMissionBeginnerGuide.SyncGuideStateRsp(err, state)
  else
    TxMissionHandler.ShowErrorTips(err)
  end
end
function TxMissionHandler.send_metro_guide_set_status_req(battle, state)
  NetManager.SendPkg(1020956103, battle, state)
end
function TxMissionHandler.on_metro_guide_set_status_rsp(err, battle, state)
  if err == 0 then
    local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
    LogicXMissionBeginnerGuide.SyncGuideBattleStateRsp(err, battle, state)
  else
    TxMissionHandler.ShowErrorTips(err)
  end
end
function TxMissionHandler.send_metro_wipe_new_req(inst_ids)
  log(bWriteLog and "TxMissionHandler.send_metro_wipe_new_req")
  log_tree("inst_ids = ", inst_ids)
  NetManager.SendPkg(297791559, inst_ids)
end
function TxMissionHandler.on_metro_wipe_new_rsp(ret, inst_ids)
  log(bWriteLog and "TxMissionHandler.on_metro_wipe_new_rsp ret = " .. ret)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  log_tree("inst_ids = ", inst_ids)
end
function TxMissionHandler.on_metro_team_guide_unfinished_notify()
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  LogicXMissionBeginnerGuide.ShowTipsWhenLeaderStartGameFailed()
end
function TxMissionHandler.on_metro_depot_capacity_notify(after)
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  xmission_wardrobe_data.on_metro_depot_capacity_notify(after)
end
function TxMissionHandler.on_metro_mastery_ntfy(add_point, after, total_point)
  log(bWriteLog and "TxMissionHandler.on_metro_mastery_ntfy add_point " .. add_point .. " after" .. after .. "total_point" .. total_point)
  local data = {
    add_point = add_point,
    new_total_point = after,
    old_  }
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.OnTalentDataChangeNotify(data)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TALENT_DATA_NOTIFY)
end
function TxMissionHandler.send_trigger_task_by_cli(cli_category, task_id)
  NetManager.SendPkg(615540795, cli_category, task_id)
end
function TxMissionHandler.send_metro_shop_get_entry_red_point_req()
  NetManager.SendPkg(1815768295)
end
function TxMissionHandler.on_metro_shop_get_entry_red_point_rsp(show)
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.GetEntryReddotInfoRsp(show)
end
function TxMissionHandler.send_metro_match_req(metro_worth_check_vote_token)
  NetManager.SendPkg(1818320970, metro_worth_check_vote_token)
end
function TxMissionHandler.send_metro_get_content_by_chestids(chestIdList, key)
  NetManager.SendPkg(1253147972, chestIdList, key)
end
function TxMissionHandler.on_metro_get_content_by_chestids_rsp(res, key, chestList)
  log(bWriteLog and "TxMissionHandler.on_metro_get_content_by_chestids_rsp")
  if res == NetErrorCode_NONE then
    local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
    logic_xmission_black_market.GetChestByIDListRsp(key, chestList)
  else
    log(bWriteLog and "TxMissionHandler.on_metro_get_content_by_chestids_rsp, res = " .. tostring(res))
  end
end
function TxMissionHandler.send_metro_task_npc_gift_req(npc_id, item_id, num, task_id, item_list)
  NetManager.SendPkg(1530860591, npc_id, item_id, num, task_id, item_list)
end
function TxMissionHandler.on_metro_enter_notify()
  log(bWriteLog and "[muidarzhang] TxMissionHandler.on_metro_enter_notify")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.on_metro_enter_notify()
end
function TxMissionHandler.send_metro_task_npc_gift_req_new(taskId, itemList)
  NetManager.SendPkg(813559546, taskId, itemList)
end
function TxMissionHandler.on_notify_military_level_change(old_level, new_level, new_exp)
  log(bWriteLog and "TxMissionHandler.on_notify_military_level_change old_level = " .. old_level .. ", new_level = " .. new_level .. ", new_exp = " .. new_exp)
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  logic_xmission_info:proc_notify_military_level_change(old_level, new_level, new_exp)
  local LogicTxMissionSeason = require("client.slua.logic.TxMission.season.logic_xmission_season")
  LogicTxMissionSeason.on_notify_military_level_change(old_level, new_level, new_exp)
end
function TxMissionHandler.send_metro_get_season_award_req(id)
  log(bWriteLog and "TxMissionHandler.send_metro_get_season_award_req level = " .. id)
  NetManager.SendPkg(233278599, id)
end
function TxMissionHandler.on_metro_get_season_award_rsp(errcode, id, awards_list)
  log(bWriteLog and "TxMissionHandler.on_metro_get_season_award_rsp errcode = " .. errcode)
  if errcode ~= 0 then
    TxMissionHandler.ShowErrorTips(errcode)
    return
  end
  local level = id
  log_tree("level = ", level)
  log_tree("awards_list = ", awards_list)
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  logic_xmission_info:proc_metro_get_season_award_rsp(level, awards_list)
  local LogicTxMissionSeason = require("client.slua.logic.TxMission.season.logic_xmission_season")
  LogicTxMissionSeason.on_metro_get_season_award_rsp(level, awards_list)
end
function TxMissionHandler.send_uninstall_unbag_items_req()
  NetManager.SendPkg(465900767)
end
function TxMissionHandler.on_uninstall_unbag_items_rsp(ret)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
  else
    TxMissionHandler.ShowErrorTips(13120)
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_ITEM_NOTIFY)
end
function TxMissionHandler.on_on_metro_season_switch_notify(old_season_id, new_season_id)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  LogicTxMissionMain.OnQuitXMission()
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_SEASON_CHANGE, old_season_id, new_season_id)
end
function TxMissionHandler.on_metro_affix_new_ntfy(new_affixs)
  log_tree(bWriteLog and "TxMissionHandler.on_metro_affix_new_ntfy new_affixs:", new_affixs)
  local logic_affix_pictorial_book = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_affix_pictorial_book)
  logic_affix_pictorial_book:on_metro_affix_new_ntfy(new_affixs)
end
function TxMissionHandler.send_metro_affix_read_req(affix_types)
  log_tree(bWriteLog and "TxMissionHandler.send_metro_affix_read_req affix_types:", affix_types)
  NetManager.SendPkg(159015463, affix_types)
end
function TxMissionHandler.on_metro_affix_read_rsp(err_code, affix_types)
  log(bWriteLog and "TxMissionHandler.on_metro_affix_read_rsp err_code:" .. tostring(err_code))
  log_tree(bWriteLog and "TxMissionHandler.on_metro_affix_read_rsp affix_types:", affix_types)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_affix_pictorial_book = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_affix_pictorial_book)
  logic_affix_pictorial_book:on_metro_affix_read_rsp(affix_types)
end
function TxMissionHandler.on_sync_metro_shop_ver(ver)
  log(bWriteLog and string.format("TxMissionHandler.on_sync_metro_shop_ver, ver:%s", ver))
  local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
  LogicXMissionBlackMarket.tabInfo = {}
  LogicXMissionBlackMarket.tabList = {}
  LogicXMissionBlackMarket.subTabList = {}
  LogicXMissionBlackMarket.requestChest = {}
  LogicXMissionBlackMarket.chestInfo = {}
  LogicXMissionBlackMarket.GetTabList()
end
function TxMissionHandler.send_get_insurance_status()
  log(bWriteLog and "TxMissionHandler.send_get_insurance_status")
  NetManager.SendPkg(565379468)
end
function TxMissionHandler.on_get_insurance_status_rsp(err_code)
  log(bWriteLog and "TxMissionHandler.on_get_insurance_status_rsp err_code = " .. tostring(err_code))
  local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
  if err_code == 0 then
    logic_xmission_insurance:SetInsurance(true)
  else
    logic_xmission_insurance:SetInsurance(false)
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_INSURANCE_RSP)
end
function TxMissionHandler.send_insure_req(inst_id)
  log(bWriteLog and "TxMissionHandler.send_insure_req inst_id = " .. tostring(inst_id))
  NetManager.SendPkg(169913351, inst_id)
end
function TxMissionHandler.on_insure_rsp(err_code)
  log(bWriteLog and "TxMissionHandler.on_insure_rsp err_code = " .. tostring(err_code))
  if err_code == 100251008 then
    ShowNotice(48116)
    return
  elseif err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  ShowNotice(51021)
  local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
  logic_xmission_insurance:SetInsurance(true)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_INSURANCE_RSP, true)
end
function TxMissionHandler.send_metro_shop_get_rp_item_req(shop_id)
  log(bWriteLog and "TxMissionHandler.send_metro_shop_get_rp_item_req " .. tostring(shop_id))
  NetManager.SendPkg(1325147015, shop_id)
end
function TxMissionHandler.on_metro_shop_get_rp_item_rsp(err_code, rewardList)
  log(bWriteLog and "TxMissionHandler.on_metro_shop_get_rp_item_rsp " .. tostring(err_code))
  local logic_xmission_black_market = require("client.slua.logic.TxMission.logic_xmission_black_market")
  logic_xmission_black_market.GetRPPrivilegeItemRewardRsp(err_code, rewardList)
end
function TxMissionHandler.send_get_metro_insurance_guide()
  NetManager.SendPkg(58567112)
end
function TxMissionHandler.send_get_insure_price_req()
  NetManager.SendPkg(1208749607)
end
function TxMissionHandler.on_get_insure_price_rsp(price)
  log(bWriteLog and "TxMissionHandler.on_get_insure_price_rsp price = " .. tostring(price))
  local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
  logic_xmission_insurance:SetPrice(price)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_INSURANCE_RSP)
end
function TxMissionHandler.send_metro_wipe_insure_req(inst_ids)
  log(bWriteLog and "TxMissionHandler.send_metro_wipe_insure_req")
  log_tree("inst_ids = ", inst_ids)
  NetManager.SendPkg(6133691, inst_ids)
end
function TxMissionHandler.on_metro_wipe_insure_rsp(ret, inst_ids)
  log(bWriteLog and "TxMissionHandler.on_metro_wipe_insure_rsp ret = " .. ret)
  if ret ~= 0 then
    TxMissionHandler.ShowErrorTips(ret)
    return
  end
  log_tree("inst_ids = ", inst_ids)
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  for _, v in pairs(inst_ids) do
    log(bWriteLog and "TxMissionHandler.on_metro_wipe_insure_rsp inst_id = " .. tostring(v))
    local item = xmission_wardrobe_data.GetItemByInstID(v)
    if item then
      item.insured = nil
    end
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_ITEM_NOTIFY)
end
function TxMissionHandler.on_metro_collection_notify_new_story(data)
end
function TxMissionHandler.send_metro_batch_repaire_req(inst_ids)
  log_tree(bWriteLog and "TxMissionHandler.send_metro_batch_repaire_req instIdList", inst_ids)
  NetManager.SendPkg(1799130663, inst_ids)
end
function TxMissionHandler.on_metro_batch_repaire_rsp(res, item_res)
  log(bWriteLog and string.format("TxMissionHandler.on_metro_batch_repaire_rsp, res:%s", res))
  log_tree(bWriteLog and "TxMissionHandler.on_metro_batch_repaire_rsp item_res", item_res)
  if res ~= 0 then
    TxMissionHandler.ShowErrorTips(res)
    return
  end
  local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  for inst_id, v in pairs(item_res) do
    if v == 0 then
      local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
      if itemInfo then
        itemInfo.durability = nil
      end
    end
  end
  ShowNotice(66928)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_REPAIR_SUCCESS)
end
function TxMissionHandler.send_report_metro_worth_check_vote_req(vote_token, vote_res)
  log(bWriteLog and string.format("TxMissionHandler.send_report_metro_worth_check_vote_req, vote_token:%s", vote_token))
  log(bWriteLog and string.format("TxMissionHandler.send_report_metro_worth_check_vote_req, vote_res:%s", vote_res))
  local TimeUtil = require("client.common.time_util")
  if vote_token - TimeUtil.GetServerTimeInSec() <= 0.5 then
    log(bWriteLog and string.format("send_report_metro_worth_check_vote_req, vote_token - TimeUtil.GetServerTimeInSec() <= %s", 0.5))
    return
  end
  NetManager.SendPkg(220569188, vote_token, vote_res)
end
function TxMissionHandler.send_query_tmode_room_battle_historys_req()
  NetManager.SendPkg(341326503)
end
function TxMissionHandler.on_query_tmode_room_battle_historys_rsp(res, uid, room_id, battle_historys)
  log(bWriteLog and "TxMissionHandler.on_query_tmode_room_battle_historys_rsp res = " .. res)
  if res ~= 0 then
    ShowNotice(res)
    return true
  end
  log_tree(bWriteLog and "TxMissionHandler.on_query_tmode_room_battle_historys_rsp", battle_historys)
end
function TxMissionHandler.send_build_pve_affix_req(inst_id)
  log(bWriteLog and "TxMissionHandler.send_build_pve_affix_req inst_id = " .. inst_id)
  NetManager.SendPkg(2000781447, inst_id)
end
function TxMissionHandler.on_build_pve_affix_rsp(errcode, affixs)
  log(bWriteLog and "TxMissionHandler.on_build_pve_affix_rsp errcode = " .. errcode)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  local logic_xmission_operation_make_affix = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation_make_affix)
  logic_xmission_operation_make_affix:on_build_pve_affix_rsp(affixs)
end
function TxMissionHandler.send_refine_pve_affix_req(inst_id)
  log(bWriteLog and "TxMissionHandler.send_refine_pve_affix_req inst_id = " .. inst_id)
  NetManager.SendPkg(139262823, inst_id)
end
function TxMissionHandler.on_refine_pve_affix_rsp(errcode, affixs)
  log(bWriteLog and "TxMissionHandler.on_refine_pve_affix_rsp errcode = " .. errcode)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  local logic_xmission_operation_make_affix = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation_make_affix)
  logic_xmission_operation_make_affix:on_refine_pve_affix_rsp(affixs)
end
function TxMissionHandler.send_refine_pve_affix_result_confirm_req(inst_id, select)
  local tb = {inst_id = inst_id, select = select}
  log_tree(bWriteLog and "TxMissionHandler.send_refine_pve_affix_result_confirm_req, tb =  ", tb)
  NetManager.SendPkg(1370531797, inst_id, select)
end
function TxMissionHandler.on_refine_pve_affix_confirm_rsp(errcode, affixs)
  log(bWriteLog and "TxMissionHandler.on_refine_pve_affix_confirm_rsp errcode = " .. errcode)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  local logic_xmission_operation_make_affix = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation_make_affix)
  logic_xmission_operation_make_affix:on_refine_pve_affix_confirm_rsp(affixs)
end
function TxMissionHandler.send_get_pve_affix_wait_confirm_req()
  log(bWriteLog and "TxMissionHandler.send_get_pve_affix_wait_confirm_req")
  NetManager.SendPkg(1139986344)
end
function TxMissionHandler.on_get_pve_affix_wait_confirm_res(table)
  log_tree(bWriteLog and "TxMissionHandler.on_get_pve_affix_wait_confirm_res, table =  ", table)
  local logic_xmission_operation_make_affix = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation_make_affix)
  logic_xmission_operation_make_affix:on_get_pve_affix_wait_confirm_res(table)
end
function TxMissionHandler.on_notify_metro_activity_banner(activity_id, trigger_type)
  log(bWriteLog and string.format("TxMissionHandler.on_notify_metro_activity_banner, activity_id:%s", activity_id))
  log(bWriteLog and string.format("TxMissionHandler.on_notify_metro_activity_banner, trigger_type:%s", trigger_type))
  local logic_xmission_box_activity_detail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_box_activity_detail)
  logic_xmission_box_activity_detail:OnNotifyMetroActivityBanner(activity_id, trigger_type)
end
function TxMissionHandler.send_get_metro_vs_slots_req(submode)
  NetManager.SendPkg(1554422279, submode)
end
function TxMissionHandler.on_get_metro_vs_slots_rsp(err_code, metro_vs_slots, metro_vs_bag)
  log(bWriteLog and string.format("TxMissionHandler.on_get_metro_vs_slots_rsp, err_code:%s", err_code))
  log_tree(bWriteLog and "TxMissionHandler.on_get_metro_vs_slots_rsp metro_vs_slots", metro_vs_slots)
  log_tree(bWriteLog and "TxMissionHandler.on_get_metro_vs_slots_rsp metro_vs_bag", metro_vs_bag)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_xmission_team_competition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_team_competition)
  logic_xmission_team_competition:on_get_metro_vs_slots_rsp(metro_vs_slots, metro_vs_bag)
end
function TxMissionHandler.send_set_mastery_tag_id_req(deploy_id, tag_id, tag_type)
  log(bWriteLog and string.format("TxMissionHandler.send_set_mastery_tag_id_req, deploy_id:%s tag_id:%s tag_type:%s", deploy_id, tag_id, tag_type))
  NetManager.SendPkg(1556595111, deploy_id, tag_id, tag_type)
end
function TxMissionHandler.on_set_mastery_tag_id_rsp(err_code)
  if err_code ~= 0 then
    log(bWriteLog and string.format("TxMissionHandler.on_set_mastery_tag_id_rsp, err_code:%s", err_code))
    ShowNotice(err_code)
    return
  end
end
function TxMissionHandler.send_report_temporary_mastery_open_req()
  log(bWriteLog and "TxMissionHandler.send_report_temporary_mastery_open_req")
  NetManager.SendPkg(2141709743)
end
function TxMissionHandler.on_report_temporary_mastery_open_rsp(err_code, last_popup_period_id)
  if err_code ~= 0 then
    log(bWriteLog and string.format("TxMissionHandler.on_report_temporary_mastery_open_rsp, err_code:%s", err_code))
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and string.format("TxMissionHandler.on_report_temporary_mastery_open_rsp, last_popup_period_id:%s", last_popup_period_id))
  local TalentDataMgr = require("client.slua.logic.TxMission.talent.logic_xmission_talent_data")
  TalentDataMgr:TryOpenWeekendTalentRsp(last_popup_period_id)
end
function TxMissionHandler.send_set_streamer_recommand_suit_req(suit_shop_id, operate_type)
  log(bWriteLog and string.format("TxMissionHandler.send_set_streamer_recommand_suit_req, suit_shop_id:%s operate_type:%s", suit_shop_id, operate_type))
  NetManager.SendPkg(667371511, suit_shop_id, operate_type)
end
function TxMissionHandler.on_set_streamer_recommand_suit_rsp(err_code)
  if err_code ~= 0 then
    log(bWriteLog and string.format("TxMissionHandler.on_set_mastery_tag_id_rsp, err_code:%s", err_code))
    ShowNotice(err_code)
    return
  end
end
function TxMissionHandler.send_metro_npc_daily_info_req()
  NetManager.SendPkg(1231201895)
end
function TxMissionHandler.on_metro_npc_daily_info_rsp(err_code, sync_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if sync_info then
    local logic_xmission_npc = require("client.slua.logic.TxMission.logic_xmission_npc")
    logic_xmission_npc.SetDailySendGiftNum(sync_info.daily_send_gift_cnt)
  end
end
local reqRsp = {
  send_query_tmode_room_battle_historys_req = "on_query_tmode_room_battle_historys_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, TxMissionHandler)
return TxMissionHandler