local NetManager = require("client.network.comm.NetManager")
local CharacterHandler = {bShowPlayDays = nil}
function CharacterHandler.on_character_update_hairid(characterid, hairid)
end
function CharacterHandler.send_get_alias_list()
  NetManager.SendPkg(1105161186)
end
function CharacterHandler.on_alias_list_res(res, list, red_point, alias)
  local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  RoleInfoAliasSystem.alias_list_res(res, list, red_point, alias)
end
function CharacterHandler.send_change_alias_req(id, state)
  NetManager.SendPkg(1795220455, id, state)
end
function CharacterHandler.on_change_alias_rsp(res, id, rank_id)
  local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  RoleInfoAliasSystem.change_alias_rsp(res, id, rank_id)
end
function CharacterHandler.on_notify_add_alias(isShow, alias_id, alias_info, isClickReward)
  log(bWriteLog and "CharacterHandler.on_notify_add_alias isShow = " .. tostring(isShow) .. ", alias_id = " .. alias_id .. ", isClickReward = " .. tostring(isClickReward))
  log_tree("alias_info = ", alias_info)
  local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  RoleInfoAliasSystem.notify_add_alias(isShow, alias_id, alias_info, isClickReward)
end
function CharacterHandler.send_change_avatar_box(item_id)
  NetManager.SendPkg(1560193412, item_id)
end
function CharacterHandler.on_change_avatar_box_rsp(ok, item_id)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.change_avatar_box_rsp(ok, item_id)
end
function CharacterHandler.on_get_new_avatar_box_notify(avatarBoxId, expireTime)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.OnHeadFrameNotify(avatarBoxId, expireTime)
end
function CharacterHandler.send_change_user_avatar(item_url)
  NetManager.SendPkg(1779363404, item_url)
end
function CharacterHandler.on_change_user_avatar_rsp(ok, item_url, endtime)
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  RoleInfoAvatarSystem.change_user_avatar_rsp(ok, item_url, endtime)
end
function CharacterHandler.on_update_user_avatar_url(item_url)
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  RoleInfoAvatarSystem.update_user_avatar_url(item_url)
end
function CharacterHandler.on_notify_unlock_new_avatar(list)
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  RoleInfoAvatarSystem.notify_unlock_new_avatar(list)
end
function CharacterHandler.send_get_unlock_progress_req()
  NetManager.SendPkg(1200785583)
end
function CharacterHandler.on_get_unlock_progress_rsp(res, headerProgress)
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  RoleInfoAvatarSystem.get_unlock_progress_rsp(res, headerProgress)
end
function CharacterHandler.send_get_history_record_summary(uid)
  log(bWriteLog and "CharacterHandler.send_get_history_record_summary uid = " .. uid)
  NetManager.SendPkg(2011674892, uid)
end
function CharacterHandler.on_get_history_record_summary_rsp(uid, list)
  log(bWriteLog and "CharacterHandler.on_get_history_record_summary_rsp uid = " .. uid)
  log_tree("CharacterHandler.on_get_history_record_summary_rsp list = ", list)
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  RoleInfoHistorySystem.get_history_record_summary_rsp(uid, list)
end
function CharacterHandler.send_bath_get_history_record(uid, battle_ids)
  log(bWriteLog and "CharacterHandler.send_bath_get_history_record uid = " .. uid)
  log_tree("battle_ids = ", battle_ids)
  NetManager.SendPkg(1812981382, uid, battle_ids)
end
function CharacterHandler.on_bath_get_history_record_rsp(uid, history_record_list)
  log(bWriteLog and "CharacterHandler.on_bath_get_history_record_rsp uid = " .. uid)
  log_tree("history_record_list = ", history_record_list)
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  RoleInfoHistorySystem.bath_get_history_record_rsp(uid, history_record_list)
end
function CharacterHandler.send_batch_get_peakgame_history_req(uid, battle_ids)
  log(bWriteLog and "CharacterHandler.send_batch_get_peakgame_history_req uid = " .. uid)
  log_tree("battle_ids = ", battle_ids)
  NetManager.SendPkg(1540769991, uid, battle_ids)
end
function CharacterHandler.on_batch_get_peakgame_history_rsp(err, uid, history_record_list)
  log(bWriteLog and "CharacterHandler.on_batch_get_peakgame_history_rsp err = " .. tostring(err) .. ", uid = " .. uid)
  log_tree("history_record_list = ", history_record_list)
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  RoleInfoHistorySystem.bath_get_history_record_rsp(uid, history_record_list)
end
function CharacterHandler.on_notify_first_history_record(is_first_record)
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  RoleInfoHistorySystem.notify_first_history_record(is_first_record)
end
function CharacterHandler.on_room_recruit_rsp(ret, time_left, chat_content)
  local RoomUpSystem = require("client.logic.roomup.logic_roomup")
  RoomUpSystem.room_recruit_rsp(ret, time_left, chat_content)
end
function CharacterHandler.on_notify_del_cycleroll_msgs(list)
end
function CharacterHandler.send_modify_role_privacy(privacyValue, opType)
  log(bWriteLog and "CharacterHandler.send_modify_role_privacy privacyValue = " .. tostring(privacyValue) .. ", opType = " .. tostring(opType))
  NetManager.SendPkg(177603748, privacyValue, opType)
end
function CharacterHandler.on_modify_role_privacy_rsp(res, privacyValue, opType)
  log(bWriteLog and "CharacterHandler.on_modify_role_privacy_rsp res = " .. res)
  if res ~= NetErrorCode_NONE then
    return
  end
  log(bWriteLog and "privacyValue = " .. tostring(privacyValue) .. ", opType = " .. tostring(opType))
  if opType == 1 then
    CharacterHandler.bShowPlayDays = privacyValue
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SHOW_PLAY_DAYS_UPDATE)
  end
end
function CharacterHandler.send_click_alias_batch_report(clicked_alias)
  log(bWriteLog and "send_click_alias_batch_report. " .. tostring(clicked_alias))
  NetManager.SendPkg(510203909, clicked_alias)
end
function CharacterHandler.send_get_show_alias_req()
  log(bWriteLog and "[wzp]CharacterHandler.send_get_show_alias_req")
  NetManager.SendPkg(546230311)
end
function CharacterHandler.on_get_show_alias_rsp(res, show_alias_info)
  if res ~= 0 then
    log(bWriteLog and "[wzp] get fail")
    return
  end
  log_tree("[wzp]CharacterHandler.on_get_show_alias_rsp show_alias_info", show_alias_info)
  local logic_roleInfo_honor_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_honor_title_select)
  logic_roleInfo_honor_title_select:on_get_show_alias_rsp(show_alias_info)
end
function CharacterHandler.send_set_show_alias_req(table)
  log_tree("[wzp]CharacterHandler.send_set_show_alias_req table", table)
  NetManager.SendPkg(693785255, table)
end
function CharacterHandler.on_set_show_alias_rsp(res, orderList)
  if res ~= 0 then
    log(bWriteLog and "[wzp] CharacterHandler.on_set_show_alias_rsp:select_Alias_List save no success")
    return
  end
  log_tree("[wzp] CharacterHandler.on_set_show_alias_rsp orderList", orderList)
  local logic_roleInfo_honor_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_honor_title_select)
  logic_roleInfo_honor_title_select:on_set_show_alias_rsp()
end
function CharacterHandler.send_get_peakgame_history_summary_req(uid)
  NetManager.SendPkg(1230921831, uid)
end
function CharacterHandler.on_get_peakgame_history_summary_rsp(err, uid, list)
  log_tree("CharacterHandler.on_get_peakgame_history_summary_rsp(uid,list)", list)
  log(bWriteLog and "CharacterHandler.on_get_peakgame_history_summary_rsp(uid,list):" .. uid)
  local RoleInfoHistorySystem = require("client.logic.roleinfo.logic_roleinfo_history")
  RoleInfoHistorySystem.get_history_record_summary_rsp(uid, list)
end
function CharacterHandler.send_set_is_show_enter_broadcast_req(is_show)
  NetManager.SendPkg(879185723, is_show)
end
function CharacterHandler.on_set_is_show_enter_broadcast_rsp(error_code, is_show)
  if error_code == 0 then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_IS_SHOW_ALIAS_ENTER_BROADCAST, is_show)
  end
end
function CharacterHandler.send_character_info_req()
  NetManager.SendPkg(1323568327)
end
function CharacterHandler.on_character_info_rsp(error_code, character_info, characterExchangeConfig)
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  NewCharacterNetSystem:on_character_info_rsp(character_info, error_code)
  local supply_optional_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.supply_optional_data)
  supply_optional_data:InitExchangeRawData(characterExchangeConfig)
  if error_code ~= 0 then
    NewCharacterNetSystem:ShowErrorTips(error_code)
  end
end
function CharacterHandler.send_get_friendly_points_data_req()
  NetManager.SendPkg(446953383)
end
function CharacterHandler.on_get_friendly_points_data_rsp(err_code, curr_value, today_value, friendly_points_day_max_value, friendly_points_total_max_value)
  local Logic_Friendly = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_Friendly)
  Logic_Friendly:on_get_friendly_points_data_rsp(err_code, curr_value, today_value, friendly_points_day_max_value, friendly_points_total_max_value)
end
function CharacterHandler.send_clear_hunter_vs_hunted_history_record_req()
  NetManager.SendPkg(291552115)
end
function CharacterHandler.on_clear_hunter_vs_hunted_history_record_rsp(err_code)
  log(bWriteLog and "on_clear_hunter_vs_hunted_history_record_rsp err_code" .. err_code)
  if err_code ~= 0 then
    log_error("on_clear_hunter_vs_hunted_history_record_rsp err = " .. err_code)
  end
end
function CharacterHandler.send_set_show_weapon_alias_req(weapon_alias_table)
  log(bWriteLog and "CharacterHandler.send_set_show_weapon_alias_req ")
  log_tree("weapon_alias_table = ", weapon_alias_table)
  NetManager.SendPkg(2121269011, weapon_alias_table)
end
function CharacterHandler.on_set_show_weapon_alias_rsp(res, orderList)
  log(bWriteLog and "CharacterHandler.on_set_show_weapon_alias_rsp res = " .. tostring(res))
  if res == 0 then
    log_tree("CharacterHandler.on_set_show_weapon_alias_rsp orderList = ", orderList)
    local logic_roleInfo_weaponstrength_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_weaponstrength_title_select)
    logic_roleInfo_weaponstrength_title_select:proc_set_show_weapon_alias_rsp(orderList)
  end
end
function CharacterHandler.send_get_show_weapon_alias_req()
  log(bWriteLog and "CharacterHandler.send_get_show_weapon_alias_req ")
  NetManager.SendPkg(1723553215)
end
function CharacterHandler.on_get_weapon_show_alias_rsp(res, show_alias_info)
  log(bWriteLog and "CharacterHandler.on_get_show_weapon_alias_rsp res = " .. tostring(res))
  if res == 0 then
    log_tree("CharacterHandler.on_get_show_weapon_alias_rsp show_alias_info = ", show_alias_info)
    local logic_roleInfo_weaponstrength_title_select = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_weaponstrength_title_select)
    logic_roleInfo_weaponstrength_title_select:proc_get_show_weapon_alias_rsp(show_alias_info)
  end
end
function CharacterHandler.send_get_hunter_vs_hunted_clear_time_req()
  log(bWriteLog and "CharacterHandler.send_get_hunter_vs_hunted_clear_time_req")
  NetManager.SendPkg(1067381139)
end
function CharacterHandler.on_get_hunter_vs_hunted_clear_time_rsp(err_code, time)
  log(bWriteLog and "CharacterHandler.on_get_hunter_vs_hunted_clear_time_rsp err_code" .. err_code)
  log(bWriteLog and "CharacterHandler.on_get_hunter_vs_hunted_clear_time_rsp time " .. (time or 0))
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  logic_history_combat:on_get_hunter_vs_hunted_clear_time_rsp(time or 0)
end
function CharacterHandler.send_set_hunter_vs_hunted_clear_time_req()
  log(bWriteLog and "CharacterHandler.send_set_hunter_vs_hunted_clear_time_req")
  NetManager.SendPkg(79387875)
end
function CharacterHandler.on_set_hunter_vs_hunted_clear_time_rsp(err_code)
  log(bWriteLog and "CharacterHandler.on_set_hunter_vs_hunted_clear_time_rsp err_code" .. err_code)
  if err_code ~= 0 then
    log_error("CharacterHandler.on_set_hunter_vs_hunted_clear_time_rsp err = " .. err_code)
  end
end
function CharacterHandler.on_hunter_vs_hunted_result(data)
  log_tree("CharacterHandler.on_hunter_vs_hunted_result data", data)
  local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
  logic_history_combat:ReqHistoryDataForHvHPop(data)
end
return CharacterHandler