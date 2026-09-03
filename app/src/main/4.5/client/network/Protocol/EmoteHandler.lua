local NetManager = require("client.network.comm.NetManager")
local EmoteHandler = {}
function EmoteHandler.on_notify_new_milestone_rsp(item_info)
  log_tree("on_get_all_milestone_data_rsp item_info)", item_info)
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  LobbyEmoteManager:AddAcquiredMilestone(item_info)
end
function EmoteHandler.send_get_all_milestone_data_req()
  NetManager.SendPkg(543314631)
end
function EmoteHandler.on_get_all_milestone_data_rsp(errcode, all_tbl, cloth_set, weapon_set, vehicle_set, extra_set, all_expressions, expressions_set, smp_show_milestone)
  log_tree("on_get_all_milestone_data_rsp all_tbl", all_tbl)
  log_tree("on_get_all_milestone_data_rsp cloth_set", cloth_set)
  log_tree("on_get_all_milestone_data_rsp weapon_set", weapon_set)
  log_tree("on_get_all_milestone_data_rsp all_expressions", all_expressions)
  log_tree("on_get_all_milestone_data_rsp expressions_set", expressions_set)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  LobbyEmoteManager:OnMileStoneDataRsp(all_tbl, cloth_set, weapon_set, vehicle_set, extra_set, all_expressions, expressions_set, smp_show_milestone)
end
function EmoteHandler.send_save_milestone_slot_info_req(sys_type, slot_set, expression_id)
  log(bWriteLog and string.format("EmoteHandler.send_save_milestone_slot_info_req sys_type = %s", sys_type))
  log_tree("send_save_milestone_slot_info_req slot_set", slot_set)
  NetManager.SendPkg(1520190695, sys_type, slot_set, expression_id)
end
function EmoteHandler.on_save_milestone_slot_info_rsp(err_code, sys_type, slot_set, expression_id)
  log(bWriteLog and string.format("EmoteHandler.on_save_milestone_slot_info_rsp err_code = %s, sys_type = %s", err_code, sys_type))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("on_save_milestone_slot_info_rsp slot_set", slot_set)
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  LobbyEmoteManager:ResMilestoneSlotInfo(sys_type, slot_set, expression_id)
end
return EmoteHandler