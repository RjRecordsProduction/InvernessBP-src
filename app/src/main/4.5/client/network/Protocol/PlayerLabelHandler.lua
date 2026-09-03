local NetManager = require("client.network.comm.NetManager")
local PlayerLabelHandler = {
  labelResult = nil,
  markLabelResult = {},
  match_num = -1,
  warm_match_data = nil,
  fight_guide_itemInfo = nil,
  oldplayer_flag = nil
}
function PlayerLabelHandler.send_get_personas_labels_req(is_all_labels, labels_tab)
  log_tree("PlayerLabelHandler send_get_personas_labels_req is_all_labels = ", is_all_labels)
  log_tree("PlayerLabelHandler send_get_personas_labels_req labels_tab = ", labels_tab)
  NetManager.SendPkg(1771113387, is_all_labels, labels_tab)
end
function PlayerLabelHandler.on_get_personas_labels_rsp(error_code, result)
  log_tree("PlayerLabelHandler on_get_personas_labels_rsp error_code = ", error_code)
  log_tree("PlayerLabelHandler on_get_personas_labels_rsp result = ", result)
  PlayerLabelHandler.labelResult = result
  local PlayerLabelCondition = require("client.slua.logic.GuideFlow.Condition.PlayerLabelCondition")
  PlayerLabelCondition.labelConditionMap = {}
end
function PlayerLabelHandler.send_update_growup_mark_label_req(act_ids, opt_id, check_code)
  log_tree("PlayerLabelHandler.send_update_growup_mark_label_req act_ids = ", act_ids)
  log(bWriteLog and "opt_id = " .. opt_id)
  NetManager.SendPkg(1086918631, act_ids, opt_id, check_code)
end
function PlayerLabelHandler.on_update_growup_mark_label_rsp(err_code, opt_id, act_ids)
  log(bWriteLog and "PlayerLabelHandler on_update_growup_mark_label_rsp err_code = " .. err_code)
  if err_code ~= 0 then
    return
  end
  for k, v in pairs(act_ids) do
    if opt_id == 0 then
      PlayerLabelHandler.markLabelResult[v] = true
    else
      PlayerLabelHandler.markLabelResult[v] = nil
    end
  end
  log_tree("markLabelResult = ", PlayerLabelHandler.markLabelResult)
  local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
  LocalPushSystem:UpdateMarkLabelPush()
end
function PlayerLabelHandler.send_get_growup_mark_label_req(check_code)
  NetManager.SendPkg(977580131, check_code)
end
function PlayerLabelHandler.on_get_growup_mark_label_rsp(markLabelResult)
  log_tree("PlayerLabelHandler on_get_growup_mark_label_rsp markLabelResult = ", markLabelResult)
  PlayerLabelHandler.end
function PlayerLabelHandler.IsMarkGrowupLabelByID(label)
  return PlayerLabelHandler.markLabelResult[label]
end
function PlayerLabelHandler.send_newbie_fight_guide_get_reward_req(award_id, item_info)
  PlayerLabelHandler.fight_guide_itemInfo = item_info
  NetManager.SendPkg(2063944151, award_id, item_info)
end
function PlayerLabelHandler.on_newbie_fight_guide_get_reward_rsp(err_code, award_id)
  log_tree("[qintong] :on_newbie_fight_guide_get_reward_rsp" .. type(err_code) .. err_code, PlayerLabelHandler.fight_guide_itemInfo)
  if LobbySystem.CheckUseNewGuide() then
    EventSystem:postEvent(EVENTTYPE_NEWBIE, EVENTID_NEWBIE_GET_AWARD, award_id)
    return
  end
end
function PlayerLabelHandler.OnReceData(match_num)
  PlayerLabelHandler.  PlayerLabelHandler.oldplayer_flag = match_num == -1
  log(bWriteLog and "[qintong] LoginSystem match_num == " .. tostring(match_num) .. tostring(PlayerLabelHandler.oldplayer_flag))
end
function PlayerLabelHandler.OnReceWarm(warm_data)
  PlayerLabelHandler.warm_match_data = warm_data
end
function PlayerLabelHandler.send_get_match_num_req()
end
function PlayerLabelHandler.on_get_match_num_rsp(match_num)
end
function PlayerLabelHandler.send_sync_guide_season_cond_req()
  NetManager.SendPkg(529342313)
end
function PlayerLabelHandler.on_sync_guide_cond_rsp(sync_cond_info)
  log_tree("[qintong] PlayerLabelHandler.on_sync_guide_cond_rsp", sync_cond_info)
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.UpdateWeakGuide(sync_cond_info)
end
function PlayerLabelHandler.send_update_care_mentor_label_req(count)
  NetManager.SendPkg(113444711, count)
  log(bWriteLog and "PlayerLabelHandler.send_update_care_mentor_label_req count = " .. count)
end
function PlayerLabelHandler.on_update_care_mentor_label_rsp(err_code, count)
  log(bWriteLog and "PlayerLabelHandler.on_update_care_mentor_label_rsp err_code = " .. err_code)
  if err_code ~= 0 then
    return
  end
  log(bWriteLog and "PlayerLabelHandler.on_update_care_mentor_label_rsp count = " .. count)
end
function PlayerLabelHandler.send_set_ai_alloc_mark_req(op_type, mark_id)
  NetManager.SendPkg(1023059607, op_type, mark_id)
  log(bWriteLog and "PlayerLabelHandler.send_set_ai_alloc_mark_req op_type = .." .. op_type)
  log(bWriteLog and "PlayerLabelHandler.send_set_ai_alloc_mark_req mark_id = .." .. mark_id)
end
function PlayerLabelHandler.on_set_ai_alloc_mark_rsp(ok, op_type, mark_id)
  log(bWriteLog and "PlayerLabelHandler.on_set_ai_alloc_mark_rsp ok = .." .. ok)
  if ok ~= 0 then
    return
  end
  log(bWriteLog and "PlayerLabelHandler.on_set_ai_alloc_mark_rsp op_type = .." .. op_type)
  log(bWriteLog and "PlayerLabelHandler.on_set_ai_alloc_mark_rsp mark_id = .." .. mark_id)
end
function PlayerLabelHandler.on_set_growup_rating_protect_mark_rsp()
end
function PlayerLabelHandler.send_set_rating_protect_mark(param1, param2)
  NetManager.SendPkg(1027084125, param1, param2)
end
function PlayerLabelHandler.send_set_warm_game_mark_req(param1, param2)
  NetManager.SendPkg(2140257127, param1, param2)
end
function PlayerLabelHandler.on_set_warm_game_mark_rsp()
end
function PlayerLabelHandler.send_is_choose_novice_level(is_chosen)
  NetManager.SendPkg(371179236, is_chosen)
end
function PlayerLabelHandler.on_notify_match_client_type_history(history)
  PlayerLabelHandler.warm_match_data = history
  log_tree("on_notify_match_client_type_history", history)
end
function PlayerLabelHandler.send_warm_game_label_rsp(label_ids, op_type, other_param)
  NetManager.SendPkg(-685398913, label_ids, op_type, other_param)
end
function PlayerLabelHandler.send_set_warm_game_label_req(label_ids, op_type, other_param)
  NetManager.SendPkg(1580503291, label_ids, op_type, other_param)
end
function PlayerLabelHandler.on_set_warm_game_label_rsp()
end
function PlayerLabelHandler.send_system_entrance_show_guide()
  NetManager.SendPkg(80545835)
end
function PlayerLabelHandler.send_more_entrance_show()
  NetManager.SendPkg(160488186)
end
function PlayerLabelHandler.send_get_sales_high_quality_items()
  NetManager.SendPkg(167385932)
end
function PlayerLabelHandler.on_get_sales_high_quality_items_rsp(items)
  log(bWriteLog and "PlayerLabelHandler.on_get_sales_high_quality_items_rsp.")
  if not items then
    return
  end
  local PufferOdpakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local list = {}
  for k, v in pairs(items) do
    if PufferOdpakManager:GetStateByItemID(v) == PufferConst.ENUM_DownloadState.Done then
      table.insert(list, v)
    end
  end
  log_tree("item downloaded = ", list)
  PlayerLabelHandler.send_report_has_high_quality_items_res(list)
end
function PlayerLabelHandler.send_report_has_high_quality_items_res(items_list)
  NetManager.SendPkg(216577296, items_list)
end
return PlayerLabelHandler