local NetManager = require("client.network.comm.NetManager")
local ModCollectHandler = {}
function ModCollectHandler.send_get_collect_sys_upvote_info_req(uid)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(624662371, uid)
end
function ModCollectHandler.on_get_collect_sys_upvote_info_rsp(err_code, other_uid, upvote_count, upvote_record, upvoted_record)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  if tostring(other_uid) == tostring(DataMgr.roleData.uid) then
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    collect_module:SetLikeCount(upvote_count)
  end
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_UPVOTE_INFO, other_uid, upvote_count, upvote_record, upvoted_record)
  log_warning(bWriteLog and "  ModCollectHandler.on_get_collect_sys_upvote_info_rsp. other_uid: " .. tostring(other_uid))
  log_tree("  ModCollectHandler.on_get_collect_sys_upvote_info_rsp. upvoted_record ", upvoted_record)
end
function ModCollectHandler.send_cancel_collect_sys_upvote_req(uid)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(187107263, uid)
end
function ModCollectHandler.on_cancel_collect_sys_upvote_rsp(err_code, other_uid, upvote_count)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_CANCEL_UPVOTE, other_uid, upvote_count)
end
function ModCollectHandler.send_paste_collect_sys_show_info_req(badge_id, slot_id)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(2101796871, badge_id, slot_id)
end
function ModCollectHandler.on_paste_collect_sys_show_info_rsp(err_code, badge_id, slot_id, badge_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  log_warning(bWriteLog and "CollectHandler:OnClickButton_Enter. badge_id: " .. tostring(badge_id))
  log_warning(bWriteLog and "CollectHandler:OnClickButton_Enter. slot_id: " .. tostring(slot_id))
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_PASTE_COLLECT_BADGE, badge_list)
end
function ModCollectHandler.send_cancel_collect_sys_show_info_req(id, replace_flag)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(1317444263, id, replace_flag)
end
function ModCollectHandler.on_cancel_collect_sys_show_info_rsp(err_code, id, badge_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_PASTE_COLLECT_BADGE, badge_list)
end
function ModCollectHandler.send_take_collect_level_award_req(sys_id, level_id, pos_id, sub_sys_id)
  log(bWriteLog and string.format("CollectHandler.send_take_collect_level_award_req sys_id = %s, level_id = %s, pos_id = %s, sub_sys_id = %s", sys_id, level_id, pos_id, sub_sys_id))
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(145518951, sys_id, level_id, pos_id, sub_sys_id)
end
function ModCollectHandler.on_take_collect_level_award_rsp(err_code, sys_id, level_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function ModCollectHandler.send_batch_take_collect_level_award_req(sys_id, sub_sys_id)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(174831495, sys_id, sub_sys_id)
end
function ModCollectHandler.on_batch_take_collect_level_award_rsp(err_code, sys_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function ModCollectHandler.send_set_sticker_background_req(bg_id)
  NetManager.SendPkg(1269222375, bg_id)
end
function ModCollectHandler.on_set_sticker_background_rsp(err_code, bg_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  collect_room_module:OnChangeBg(bg_id)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_CHANGE_BG, bg_id)
end
function ModCollectHandler.send_set_show_milestone_data_req(slot_id, res_id)
  NetManager.SendPkg(336950843, slot_id, res_id)
end
function ModCollectHandler.on_set_show_milestone_data_rsp(err_code, slot_id, res_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and string.format("CollectHandler.on_set_show_milestone_data_rsp slot_id, res_id: %s, %s", tostring(slot_id), tostring(res_id)))
  local collect_pavilions_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_pavilions_module)
  collect_pavilions_module:OnSetShowMilestoneSlot(res_id, slot_id)
end
function ModCollectHandler.send_set_sticker_frame_req(frame_id)
  NetManager.SendPkg(1038185283, frame_id)
end
function ModCollectHandler.on_set_sticker_frame_rsp(err_code, frame_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  collect_room_module:OnChangeFrame(frame_id)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_CHANGE_FRAME, frame_id)
end
function ModCollectHandler.send_take_collect_sys_theme_award_req(theme_id)
  NetManager.SendPkg(1361600423, theme_id)
end
function ModCollectHandler.on_take_collect_sys_theme_award_rsp(err_code, theme_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function ModCollectHandler.send_batch_take_collect_sys_theme_award_req(theme_ids)
  NetManager.SendPkg(559711399, theme_ids)
end
function ModCollectHandler.on_batch_take_collect_sys_theme_award_rsp(err_code, theme_ids, award_items)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_BATCH_TAKE_THEME_AWARD_RESP, theme_ids, award_items)
end
function ModCollectHandler.send_report_collec_sys_theme_progress_req(theme_table)
  NetManager.SendPkg(1358346663, theme_table)
end
function ModCollectHandler.on_report_collec_sys_theme_progress_rsp(err_code, theme_table)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function ModCollectHandler.send_clear_sticker_security_detection_flag_req()
  NetManager.SendPkg(319897559)
end
function ModCollectHandler.on_clear_sticker_security_detection_flag_rsp(err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local collect_room_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_room_module)
  collect_room_module:SetStickerDetectionFlag(false)
end
function ModCollectHandler.send_batch_take_all_sub_page_level_award_req(sys_id)
  log(bWriteLog and string.format("ModCollectHandler.send_batch_take_all_sub_page_level_award_req sys_id = %s", sys_id))
  NetManager.SendPkg(1862326131, sys_id)
end
function ModCollectHandler.on_batch_take_all_sub_page_level_award_rsp(err_code, sys_id, award_list, award_status)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  log(bWriteLog and string.format("ModCollectHandler.on_batch_take_all_sub_page_level_award_rsp sys_id = %s", sys_id))
  log_tree("ModCollectHandler.on_batch_take_all_sub_page_level_award_rsp award_list = %s", award_list)
  log_tree("ModCollectHandler.on_batch_take_all_sub_page_level_award_rsp award_status = %s", award_status)
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  collect_library_module:OnGetGunDropBatch(sys_id, nil, award_status)
  local collect_award_module = ModuleManager.GetSplitModule(ModuleManager.LobbyModuleConfig.collect_award_module)
  collect_award_module:ShowGet(award_list)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_BATCH_TAKE_AWARD_RESP, sys_id, award_list, award_status)
end
local reqRsp = {
  send_take_collect_level_award_req = "on_take_collect_level_award_rsp",
  send_batch_take_collect_level_award_req = "on_batch_take_collect_level_award_rsp",
  send_take_collect_sys_theme_award_req = "on_take_collect_sys_theme_award_rsp",
  send_report_collec_sys_theme_progress_req = "on_report_collec_sys_theme_progress_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, ModCollectHandler)
return ModCollectHandler