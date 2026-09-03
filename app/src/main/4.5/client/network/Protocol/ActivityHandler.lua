local NetManager = require("client.network.comm.NetManager")
local ActivityHandler = {}
function ActivityHandler.send_take_activity_award_req(activityId, awardIndex, get_times)
  NetManager.SendPkg(1155447928, activityId, awardIndex, get_times)
end
function ActivityHandler.on_take_activity_award_res(errorCode, activityId, awardIndex, factor, chest_open_items, item_list)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.OnTakeActivityAwardRsp(errorCode, activityId, awardIndex, factor, chest_open_items, item_list)
end
function ActivityHandler.send_take_special_activity_award_req(activityId, select)
  NetManager.SendPkg(1550200104, activityId, select)
end
function ActivityHandler.on_take_special_activity_award_res(errorCode, activityId, awardId, factor)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.OnTakeSpecialActivityAwardRsp(errorCode, activityId, awardId, factor)
end
function ActivityHandler.send_get_activity_batch_req(activity_list)
  NetManager.SendPkg(1543249480, activity_list)
end
function ActivityHandler.on_get_activity_batch_res(activityTable)
  log_tree("MyLogTree ActivityHandler.on_get_activity_batch_res", activityTable or {})
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.InsertActivityList(activityTable)
end
function ActivityHandler.send_get_activity_list_req()
  log(bWriteLog and "ActivityHandler.send_get_activity_list_req")
  NetManager.SendPkg(1072929576)
end
function ActivityHandler.on_get_activity_list_res(activityTable)
  log(bWriteLog and "ActivityHandler.on_get_activity_list_res.")
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessActivityData)
  local activityConfig = require("client.slua.logic.activity.activity_config")
  activityConfig.StartCache(1, true)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.InitActivityList(activityTable, ActivityHandler.bIsReGetActivityList, ActivityHandler.bIsReGetDisplay)
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  if ActivityHandler.bIsReGetActivityList then
    if ActivityRedDot.CheckShouldBuildFully() then
      ActivityRedDot.RebuildScenesFull()
    else
      ActivityRedDot.ReBuildAllEntrances()
    end
  else
    ActivityRedDot.BuildAllEntrances()
  end
  ActivityHandler.bIsReGetActivityList = false
  ActivityHandler.bIsReGetDisplay = false
  ActivityHandler.send_get_ab_testing_groupids_req()
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ALL_ACTIVITY_CHANGE)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessActivityData)
end
function ActivityHandler.send_get_activity_one_req(activityId)
  NetManager.SendPkg(2111139400, activityId)
end
function ActivityHandler.on_get_activity_one_res(actId, activityData)
  log(bWriteLog and "ActivityHandler.on_get_activity_one_res")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.UpdateActivityData(actId, activityData)
end
function ActivityHandler.send_get_act_gather_list_req()
  NetManager.SendPkg(609534450)
end
function ActivityHandler.on_get_act_gather_list_res(dataList)
end
function ActivityHandler.send_get_active_cycle_roll()
  NetManager.SendPkg(361721564)
end
function ActivityHandler.on_notify_cycleroll_msgs(list)
end
function ActivityHandler.send_get_activity_display_req()
  NetManager.SendPkg(1987047048)
end
function ActivityHandler.on_get_activity_display_res(activity_display_table)
  LobbySystem.on_get_activity_display_res(activity_display_table)
end
function ActivityHandler.send_get_season_recharge_info_req()
  NetManager.SendPkg(228123815)
end
function ActivityHandler.on_get_season_recharge_info_rsp(res, data)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.OnGetSeasonRechargeInfoRsp(res, data)
end
function ActivityHandler.send_update_activity_anim_flag(activity_type, flag)
  NetManager.SendPkg(1528814154, activity_type, flag)
end
function ActivityHandler.send_week_signup_award_req(day, cost, sign_type)
  NetManager.SendPkg(1444818816, day, cost, sign_type)
end
function ActivityHandler.on_week_signup_award_res(res, day, itemList, resign_time, isClickReward, sign_type)
  local WeekSignMgr = require("client.slua.logic.week_sign.logic_weeksign")
  WeekSignMgr.Week_Signup_Award_Res(res, day, itemList, resign_time, isClickReward, sign_type)
end
function ActivityHandler.on_week_signup_chg_notify(signup)
  DataMgr.InitWeekSignUpList(signup)
end
function ActivityHandler.send_take_season_recharge_award_req(index)
  NetManager.SendPkg(1772492775, index)
end
function ActivityHandler.on_take_season_recharge_award_rsp(res, data)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.OnTakeSeasonRechargeAwardRsp(res, data)
end
function ActivityHandler.send_season_recharge_buy_req()
  NetManager.SendPkg(2034843251)
end
function ActivityHandler.on_season_recharge_buy_rsp(res, data)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.OnSeasonRechargeBuyRsp(res, data)
end
function ActivityHandler.on_season_recharge_progress_changed_notify(data)
  local TheFirstChargeSystem = require("client.slua.logic.recharge.logic_the_first_charge")
  TheFirstChargeSystem.ChangedNotify(data)
end
function ActivityHandler.on_notify_activity_and_display_changed(is_activity_changed, is_display_chagned)
  if is_activity_changed and is_display_chagned then
    ActivityHandler.bIsReGetActivityList = true
    ActivityHandler.bIsReGetDisplay = true
    local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
    ActivityCenterModule.IsActDataReady = false
    ActivityHandler.send_get_activity_list_req()
  else
    if is_activity_changed then
      ActivityHandler.bIsReGetActivityList = true
      local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
      ActivityCenterModule.IsActDataReady = false
      ActivityHandler.send_get_activity_list_req()
    end
    if is_display_chagned then
      ActivityHandler.send_get_activity_display_req()
    end
  end
end
function ActivityHandler.send_get_ab_testing_groupids_req()
  if not DataMgr.roleData.ab_testing_groupid then
    NetManager.SendPkg(1081868023)
  end
end
function ActivityHandler.on_get_ab_testing_groupids_rsp(tag)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.OnGetAbTestingGroupidsRsp(tag)
end
function ActivityHandler.send_deal_activity_req(activityId, awardIndex, select)
  NetManager.SendPkg(774533762, activityId, awardIndex, select)
end
function ActivityHandler.on_deal_activity_res(err_code)
end
function ActivityHandler.send_get_biochemical_activity_data_req()
  NetManager.SendPkg(1262484459)
end
function ActivityHandler.on_get_biochemical_activity_data_rsp(res, lucky_draw_unback_cfg, lucky_draw_unback_price_cfg, self_biochemical_activity_data, start_time, end_time)
end
function ActivityHandler.send_take_ams_lucky_draw_unback_egg_req(activity_id, index)
  NetManager.SendPkg(526929351, activity_id, index)
end
function ActivityHandler.on_take_ams_lucky_draw_unback_egg_rsp(errcode, itemid, num, award_index)
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.on_take_ams_lucky_draw_unback_rsp(errcode, itemid, num, award_index)
end
function ActivityHandler.on_ams_lucky_draw_unback_egg_ntf(award_index)
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.on_notify_ams_lucky_draw_unback_info(award_index)
end
function ActivityHandler.send_get_ams_lucky_draw_unback_req(activity_id)
  NetManager.SendPkg(621215191, activity_id)
end
function ActivityHandler.on_get_ams_lucky_draw_unback_rsp(errcode, awards_list)
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.on_get_ams_lucky_draw_unback_rsp(errcode, awards_list)
end
function ActivityHandler.send_get_item_choice_list_req(item_id)
  NetManager.SendPkg(1448556455, item_id)
end
function ActivityHandler.on_get_item_choice_list_rsp(ret)
  local PickOneBoxSystem = require("client.slua.logic.common.logic_common_pickonebox")
  PickOneBoxSystem.get_item_choice_list_rsp(ret)
end
function ActivityHandler.send_act_cycle_chest_take_award_req(chest_type)
  NetManager.SendPkg(217833063, chest_type)
end
function ActivityHandler.on_act_cycle_chest_take_award_rsp(ret_code, item_list)
  local logic_periodic_crate = require("client.slua.logic.activity.PeriodicCrate.logic_periodic_crate")
  logic_periodic_crate.OnGetPeriodicCrateAward(ret_code, item_list)
end
function ActivityHandler.on_sync_growup_duration_acts_rsp(err_code, sync_acts)
  if err_code ~= 0 then
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.AddActivityList(sync_acts)
end
function ActivityHandler.send_activity_goslar_score_report_req(score)
  NetManager.SendPkg(1168079725, score)
end
function ActivityHandler.on_notify_display_new_table_src(activity_table)
end
function ActivityHandler.send_report_last_open_act_center_ts(ts)
  NetManager.SendPkg(295438885, ts)
end
function ActivityHandler.send_get_activity_map_by_id_req(mode_group_id)
  NetManager.SendPkg(862896968, mode_group_id)
end
function ActivityHandler.on_get_activity_map_by_id_res(mode_group_id, mode_list)
  local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
  LogicRatingProtectActivity.on_get_activity_map_by_id_res(mode_group_id, mode_list)
end
function ActivityHandler.send_get_activity_map_by_id_list_req(mode_group_id_list)
  NetManager.SendPkg(786712170, mode_group_id_list)
end
function ActivityHandler.on_get_activity_map_by_id_list_res(mode_group_id_list, mode_group_list)
  local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
  LogicRatingProtectActivity.on_get_activity_map_by_id_list_res(mode_group_id_list, mode_group_list)
end
function ActivityHandler.send_week_batch_signup_award_req(weekday)
  NetManager.SendPkg(961641986, weekday)
end
function ActivityHandler.on_week_batch_signup_award_res(res, weekday, itemlist, resign_times, isClickReward, sign_type_ret)
  local WeekSignMgr = require("client.slua.logic.week_sign.logic_weeksign")
  WeekSignMgr.Week_Signup_Award_Offset_Res(res, weekday, itemlist, resign_times, isClickReward, sign_type_ret)
end
function ActivityHandler.send_click_activity_report_req(ss, activity_id, stage_id)
  NetManager.SendPkg(522882794, ss, activity_id, stage_id)
end
function ActivityHandler.send_get_refund_black_act_list_req()
  NetManager.SendPkg(641640175)
end
function ActivityHandler.on_get_refund_black_act_list_rsp(err_code, list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_activity_recharge_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_activity_recharge_mgr)
  logic_activity_recharge_mgr:SetActivityBlackList(list)
end
function ActivityHandler.send_report_add_desktop_tool_req(desktop_tool_type)
  log(bWriteLog and string.format("ActivityHandler.send_report_add_desktop_tool_req. desktop_tool_type=%s", tostring(desktop_tool_type)))
  NetManager.SendPkg(2080606155, desktop_tool_type)
end
function ActivityHandler.on_account_bind_activity_notify(bind_activity_data, cfg)
  log_tree(bWriteLog and "ActivityHandler.on_account_bind_activity_notify : ", bind_activity_data)
  log_tree(bWriteLog and "ActivityHandler.on_account_bind_activity_notify Cfg: ", cfg)
  local logic_singlebind = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_singlebind)
  logic_singlebind:UpdateData(bind_activity_data, cfg)
end
function ActivityHandler.send_get_activity_reward_req()
  NetManager.SendPkg(357550459)
end
function ActivityHandler.on_get_activity_reward_rsp(errcode, itemlist)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  log_tree(bWriteLog and "ActivityHandler.on_get_activity_reward_rsp : ", itemlist)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(itemlist)
  local logic_singlebind = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_singlebind)
  logic_singlebind:TakeAnyBindAwardRsp(errcode, itemlist)
end
function ActivityHandler.on_exchange_new_conf_ntf(err_code, activity_ids)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "ActivityHandler.on_exchange_new_conf_ntf", activity_ids)
end
function ActivityHandler.send_pre_buy_rp(activity_id, index)
  NetManager.SendPkg(1938459308, activity_id, index)
end
function ActivityHandler.on_pre_buy_rp_rsp(errcode, res_list, dyn_dic)
  if errcode ~= 0 then
    log(bWriteLog and " ActivityHandler.on_pre_buy_rp_rsp errcode >>> " .. errcode)
    return
  end
  local tAllReward = {}
  for k, v in pairs(res_list) do
    table.insert(tAllReward, {
      res_id = k,
      count = v,
      valid_hours = dyn_dic[k] and dyn_dic[k].valid_hours or 0
    })
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllReward)
end
function ActivityHandler.send_eliminate_exchage_act_red_point_req(activity_id, position_id)
  NetManager.SendPkg(1094253875, activity_id, position_id)
end
function ActivityHandler.on_eliminate_exchage_act_red_point_rsp(err_code, my_activity_data)
  log_tree(bWriteLog and "ActivityHandler.on_eliminate_exchage_act_red_point_rsp", my_activity_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function ActivityHandler.on_draw_lucky_surprising_item_ntf(err_code, act_type, act_id, item_list)
  if err_code == 0 then
    log(bWriteLog and "[zjq] on_draw_lucky_surprising_item_ntf.ShowEgg " .. tostring(act_id))
    log_tree(bWriteLog and "ActivityHandler.on_draw_lucky_surprising_item_ntf", item_list)
    local logic_luckyback_activity = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    logic_luckyback_activity.on_draw_lucky_surprising_item_ntf(item_list, act_id)
    local LuckyDoubleSystem = require("client.slua.logic.lobby_activity.logic_luckydouble_activity")
    LuckyDoubleSystem.on_draw_lucky_surprising_item_ntf(item_list, act_id)
    local logic_luckyunback_activity = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
    logic_luckyunback_activity.on_draw_lucky_surprising_item_ntf(item_list, act_id)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBASE_REFRESH_EGG_SHOW, item_list, act_id)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LuckyDoubleSupplyEggBeShow, LuckyDoubleSystem.CurRoundIndex)
  end
end
function ActivityHandler.send_get_tag_icon_cfg_req()
  NetManager.SendPkg(1275382055)
end
function ActivityHandler.on_get_tag_icon_cfg_rsp(err_code, activity_id)
  log(bWriteLog and string.format("ActivityHandler.on_get_tag_icon_cfg_rsp. err_code=%s", tostring(err_code)))
  log_tree("ActivityHandler.on_get_tag_icon_cfg_rsp activity_id = ", activity_id)
  if err_code == 0 then
    local ActivityCenterTabModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterTabModule)
    ActivityCenterTabModule:SetActCenterTabConfig(activity_id)
  end
end
function ActivityHandler.send_batch_take_activity_award_req(activity_id, indexes)
  NetManager.SendPkg(1446661547, activity_id, indexes)
end
function ActivityHandler.on_batch_take_activity_award_rsp(err_code, activity_id, index_awards)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.OnBatchTakeActivityAwardRsp(err_code, activity_id, index_awards)
end
local reqRsp = {
  send_eliminate_exchage_act_red_point_req = "on_eliminate_exchage_act_red_point_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, ActivityHandler)
return ActivityHandler