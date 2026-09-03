local NetManager = require("client.network.comm.NetManager")
local AssemblyHandler = {}
local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
function AssemblyHandler.send_take_full_action_award(id)
  NetManager.SendPkg(192190348, id)
end
function AssemblyHandler.on_take_full_action_award_rsp(res, id, invoke_type)
  AssemblyActivitySystem.take_full_action_award_rsp(res, id, invoke_type)
end
function AssemblyHandler.send_take_task_award(task_id)
  NetManager.SendPkg(1596942382, task_id)
end
function AssemblyHandler.on_take_task_award_rsp(res, id, num, invoke_type)
  AssemblyActivitySystem.take_task_award_rsp(res, id, num, invoke_type)
end
function AssemblyHandler.on_assemb_notify(is_all, assemb_data, cfg, is_back_user)
  AssemblyActivitySystem.assemb_notify(is_all, assemb_data, cfg, is_back_user)
end
function AssemblyHandler.send_take_assemb_award(short_code)
  NetManager.SendPkg(496228198, short_code)
end
function AssemblyHandler.on_take_assemb_award_rsp(res, awardList)
  AssemblyActivitySystem.take_assemb_award_rsp(res, awardList)
end
function AssemblyHandler.send_assemb_invite_friend(uid, fromID)
  NetManager.SendPkg(742092236, uid, fromID)
end
function AssemblyHandler.on_assemb_invite_friend_rsp(res, id)
  AssemblyActivitySystem.assemb_invite_friend_rsp(res, id)
end
function AssemblyHandler.send_assemb_task_query_req(attr_name_list, cfg_name_list)
  log_tree(bWriteLog and "AssemblyHandler.send_assemb_task_query_req attr_name_list", attr_name_list)
  log_tree(bWriteLog and "AssemblyHandler.send_assemb_task_query_req cfg_name_list", cfg_name_list)
  NetManager.SendPkg(2056775557, attr_name_list, cfg_name_list)
end
function AssemblyHandler.on_rejoiner_task_notify(rejoin_task_info)
  AssemblyActivitySystem.on_rejoiner_task_notify(rejoin_task_info)
end
function AssemblyHandler.send_assemb_get_back_user_list_req(count, client_cb, frd_back_users)
  NetManager.SendPkg(1658802720, count, client_cb, frd_back_users)
end
function AssemblyHandler.on_assemb_get_back_user_list_res(ret, uid_list, client_cb)
  AssemblyActivitySystem.on_assemb_get_back_user_list_res(ret, uid_list, client_cb)
end
function AssemblyHandler.send_on_jpkr_assemb_reply(short_code)
  NetManager.SendPkg(826985675, short_code)
end
function AssemblyHandler.on_on_jpkr_assemb_rsp(ret_code, inviter_id)
  local AssemblyActivitySystem_JK = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_activity_jk)
  AssemblyActivitySystem_JK:on_jpkr_assemb_rsp(ret_code, inviter_id)
end
function AssemblyHandler.on_on_jpkr_assemb_award_notify(inviter_id)
  local AssemblyActivitySystem_JK = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_activity_jk)
  AssemblyActivitySystem_JK:on_jpkr_assemb_award_notify(inviter_id)
end
function AssemblyHandler.on_on_jpkr_assemb_bind_notify(invitee_id)
  local AssemblyActivitySystem_JK = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_assembly_activity_jk)
  AssemblyActivitySystem_JK:on_jpkr_assemb_bind_notify(invitee_id)
end
function AssemblyHandler.send_assemb_update_invite_list(uidList)
  log_tree(bWriteLog and "AssemblyHandler.send_assemb_update_invite_list uidList", uidList)
  NetManager.SendPkg(1093276195, uidList)
end
function AssemblyHandler.on_assemb_update_invite_list_res(err_code)
  log(bWriteLog and string.format("AssemblyHandler.on_assemb_update_invite_list_res, err_code:%s", err_code))
  if err_code == 0 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eAssemblyLastSycnFrdTime, false)
  end
end
function AssemblyHandler.send_trigger_assemb_gold_tips_req()
  log(bWriteLog and "AssemblyHandler.send_trigger_assemb_gold_tips_req")
  NetManager.SendPkg(743023432)
end
function AssemblyHandler.on_trigger_assemb_gold_tips_res(res, add_num)
  log(bWriteLog and string.format("AssemblyHandler.on_trigger_assemb_gold_tips_res, res:%s", res))
  log(bWriteLog and string.format("AssemblyHandler.on_trigger_assemb_gold_tips_res, add_num:%s", add_num))
  AssemblyActivitySystem.on_trigger_assemb_gold_tips_res(res, add_num)
end
return AssemblyHandler