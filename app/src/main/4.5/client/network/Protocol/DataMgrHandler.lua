local NetManager = require("client.network.comm.NetManager")
local DataMgrHandler = {}
function DataMgrHandler.on_notify_roleattr_change(attriType, attriValue, attriTab, isClickReward)
  DataMgr.OnRoleAttrChangeNotify(attriType, attriValue, attriTab, isClickReward)
end
function DataMgrHandler.on_task_notify_chg(isAll, task)
  DataMgr.UpdateTaskChange(isAll, task)
end
function DataMgrHandler.on_level_task_notify_chg(isAll, levelTask)
  DataMgr.UpdateLevelTaskChange(isAll, levelTask)
end
function DataMgrHandler.on_share_notify_chg(share_times)
  DataMgr.UpdateShareChange(share_times)
end
function DataMgrHandler.send_set_wxsubscribe_list_req()
  NetManager.SendPkg(671270664)
end
function DataMgrHandler.on_set_wxsubscribe_list_res(result)
end
function DataMgrHandler.on_bulletin_get_hashlist_res(ret, hashlist)
end
function DataMgrHandler.on_bulletin_get_list_res(ret, bulletinList)
end
function DataMgrHandler.on_corps_task_chg(isAll, task)
  DataMgr.UpdateCorpsTaskChange()
end
function DataMgrHandler.on_corp_member_notify(res, member_info)
  DataMgr.UpdateCorpsAcitveNum(res, member_info)
end
function DataMgrHandler.on_sync_room_card_info(card_type, room_card_info, item_id)
  DataMgr.sync_room_card_info(card_type, room_card_info, item_id)
end
function DataMgrHandler.on_sync_room_adv_card_info(room_card_info, item_id)
  DataMgr.sync_room_adv_card_info(room_card_info, item_id)
end
function DataMgrHandler.send_sync_motion_info_req()
  NetManager.SendPkg(101076285)
end
function DataMgrHandler.on_sync_motion_info(motion_info, limit)
  DataMgr.sync_motion_info(motion_info, limit)
end
function DataMgrHandler.send_set_newbie_guide_req(module_id, key, val)
  log(bWriteLog and "DataMgrHandler.send_set_newbie_guide_req module_id = " .. module_id .. ", key = " .. key .. ", val = " .. tostring(val))
  NetManager.SendPkg(1435572327, module_id, key, val)
end
function DataMgrHandler.on_set_newbie_guide_rsp(err_code, module_id, key, value)
  log(bWriteLog and "DataMgrHandler.on_set_newbie_guide_rsp err_code = " .. err_code .. ", module_id = " .. tostring(module_id) .. ", key = " .. tostring(key) .. ", value = " .. tostring(value))
  DataMgr.on_set_newbie_guide_rsp(err_code, module_id, key, value)
end
function DataMgrHandler.on_sync_match_param(lang, cross_time, cross_max_ping, zoneList, jpkr, match_strategy, krjp_asia)
  local tb = {lang = lang, cross_time = cross_time}
  log_tree(bWriteLog and "DataMgrHandler.on_sync_match_param tb:", tb)
  DataMgr.sync_match_param(lang, cross_time, cross_max_ping, zoneList, jpkr, match_strategy, krjp_asia)
end
function DataMgrHandler.on_carteam_coin_count_notify_chg(value, cur_carteam_coin_count, reason)
  DataMgr.carteam_coin_count_notify_chg(value, cur_carteam_coin_count, reason)
end
function DataMgrHandler.send_set_role_setting_req(settingKey, settingValue)
  NetManager.SendPkg(2004526247, settingKey, settingValue)
end
function DataMgrHandler.on_set_role_setting_rsp(res, settingKey, settingValue)
  DataMgr.OnRoleSetting(res, settingKey, settingValue)
end
function DataMgrHandler.on_notify_recharge_record(recharge_amount, recharge_time)
  log(bWriteLog and "DataMgrHandler.on_notify_recharge_record recharge_amount " .. recharge_amount .. " recharge_time " .. recharge_time)
  DataMgr.last_  DataMgr.last_pay_time = recharge_time
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVEMTID_REFRESH_TAG_SHOW)
end
function DataMgrHandler.send_save_convenient_mode_req(tableData)
  log(bWriteLog and "DataMgrHandler.send_save_convenient_mode_req.")
  log_tree("tableData = ", tableData)
  local TableUtil = require("common.table_util")
  DataMgr.last_convenient_mode = TableUtil.CopyTable(tableData)
  NetManager.SendPkg(1611062055, tableData)
end
function DataMgrHandler.on_save_convenient_mode_rsp(err)
  log(bWriteLog and string.format("DataMgrHandler.on_save_convenient_mode_rsp. err=%s", tostring(err)))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  DataMgr.roleData.convience_mode_settings = DataMgr.last_convenient_mode
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  logic_home_switch:UpdateLobbyRightMode()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ROLEINFO_CHANGE_CONVIENCE_MODE_SETTINGS)
end
function DataMgrHandler.on_notify_wow_recharge_record(last_ugc_recharge_amount, last_ugc_pay_time)
  log(bWriteLog and "DataMgrHandler.on_notify_wow_recharge_record last_ugc_recharge_amount = " .. last_ugc_recharge_amount .. ", last_ugc_pay_time = " .. last_ugc_pay_time)
  DataMgr.  DataMgr.  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVEMTID_REFRESH_TAG_SHOW)
end
return DataMgrHandler