local NetManager = require("client.network.comm.NetManager")
local TEMUHandler = {}
function TEMUHandler.send_create_temu_group_req(stage_id)
  NetManager.SendPkg(1319067043, stage_id)
end
function TEMUHandler.on_create_temu_group_rsp(errcode, group_id)
  log(bWriteLog and "[SY]TEMUHandler.on_create_temu_group_rsp.errcode:" .. tostring(errcode) .. " group_id:" .. tostring(group_id))
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnCreateTeam(group_id)
end
function TEMUHandler.send_dismiss_temu_group_req()
  NetManager.SendPkg(855274247)
end
function TEMUHandler.on_dismiss_temu_group_rsp(errcode, group_id)
  log(bWriteLog and "[SY]TEMUHandler.on_dismiss_team_group_rsp.errcode:" .. tostring(errcode))
  if errcode ~= 0 then
    return
  end
end
function TEMUHandler.send_get_temu_group_info_req(group_id)
  NetManager.SendPkg(400182071, group_id)
end
function TEMUHandler.on_get_temu_group_info_rsp(errcode, info)
  log(bWriteLog and "[SY]TEMUHandler.on_get_temu_group_info_rsp.errcode:" .. tostring(errcode))
  log_tree("teamInfo", info)
  if errcode ~= 0 then
    return
  end
  local Logic_Temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_Temu:OnGetTeamInfo(info)
end
function TEMUHandler.send_join_temu_group_req(group_id)
  NetManager.SendPkg(1297265995, group_id)
end
function TEMUHandler.on_join_temu_group_rsp(errcode, group_id)
  log(bWriteLog and "[SY]TEMUHandler.on_join_temu_group_rsp.errcode:" .. tostring(errcode) .. " group_id:" .. tostring(group_id))
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnJoinTeam(group_id)
end
function TEMUHandler.send_leave_temu_group_req()
  NetManager.SendPkg(1216033831)
end
function TEMUHandler.on_leave_temu_group_rsp(errcode)
  log(bWriteLog and "[SY]TEMUHandler.on_leave_temu_group_rsp.errcode:" .. tostring(errcode))
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnLeaveTeam()
end
function TEMUHandler.send_temu_group_kick_member_req(member_uid)
  NetManager.SendPkg(457604839, member_uid)
end
function TEMUHandler.on_temu_group_kick_member_rsp(errcode, member_uid)
  log(bWriteLog and "[SY]TEMUHandler.on_temu_group_kick_member_rsp.errcode:" .. tostring(errcode) .. " member_uid:" .. tostring(member_uid))
  if errcode ~= 0 then
    return
  end
  local Logic_Temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_Temu:OnKickMember(member_uid)
end
function TEMUHandler.send_get_temu_stage_info_req(stage)
  NetManager.SendPkg(1100339187)
end
function TEMUHandler.on_get_temu_stage_info_rsp(errcode, stage_info)
  log(bWriteLog and "[SY]TEMUHandler.on_get_temu_stage_info_rsp.errcode:" .. tostring(errcode))
  if errcode ~= 0 then
    return
  end
  log_tree("stage_info", stage_info)
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnSendGetStageInfo(stage_info)
end
function TEMUHandler.send_take_temu_friendship_req(stage_id, task_id)
  NetManager.SendPkg(1021376039, stage_id, task_id)
end
function TEMUHandler.on_take_temu_friendship_rsp(errcode, award_list, stage_id, task_id)
  log(bWriteLog and "[SY]TEMUHandler.on_take_temu_friendship_rsp.errcode:" .. tostring(errcode) .. " stage_id:" .. tostring(stage_id) .. " task_id:" .. tostring(task_id))
  if errcode ~= 0 then
    return
  end
  log_tree("Logic_temu.OnSendCompleteTask.award_list", award_list)
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnSendCompleteTask(award_list, stage_id, task_id)
end
function TEMUHandler.send_invite_all_temu_group_friend_list_req(uid_list, chat_type, msg_id, chat_content)
  NetManager.SendPkg(208742775, uid_list, chat_type, msg_id, chat_content)
end
function TEMUHandler.on_invite_all_temu_group_friend_list_rsp(errcode, frd_list, chat_content)
  log(bWriteLog and "[SY]TEMUHandler.on_invite_all_temu_group_friend_list_rsp.errcode:" .. tostring(errcode))
  if errcode ~= 0 then
    return
  end
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local channel = chat_macro.Channel.channelPrivate
  if frd_list and chat_content then
    for k, v in pairs(frd_list) do
      local msgId = channelMain.CacheMsg(chat_content)
      channelMain.on_chat_rsp(NetErrorCode_NONE, msgId, channel, nil, v, chat_content.text)
    end
  end
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_INVITE_FRIEND_UPDATE)
end
function TEMUHandler.send_get_temu_group_friend_invite_list_req(stage_id)
  NetManager.SendPkg(468472403, stage_id)
end
function TEMUHandler.on_get_temu_group_friend_invite_list_rsp(errcode, data, stage_id)
  log(bWriteLog and "[SY]TEMUHandler.on_get_temu_group_friend_invite_list_rsp.errcode:" .. tostring(errcode) .. ".stage_id:" .. tostring(stage_id))
  if errcode ~= 0 then
    return
  end
  log_tree("OnSendGetGroupInviteMap", data)
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnSendGetGroupInviteMap(data, stage_id)
end
function TEMUHandler.send_get_temu_group_invite_list_req()
  NetManager.SendPkg(1969328423)
end
function TEMUHandler.on_get_temu_group_invite_list_rsp(errcode, data)
end
function TEMUHandler.send_remove_temu_invite_red_point_req(stage_id)
  NetManager.SendPkg(1969790247, stage_id)
end
function TEMUHandler.on_remove_temu_invite_red_point_rsp(errcode, stage_id)
  log(bWriteLog and "[SY]TEMUHandler.on_remove_temu_invite_red_point_rsp." .. tostring(stage_id))
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:ResetInviteRedDot(stage_id)
end
function TEMUHandler.send_buy_temu_group_pkg_req(stage_id, pkg_id)
  NetManager.SendPkg(2073603879, stage_id, pkg_id)
end
function TEMUHandler.on_buy_temu_group_pkg_rsp(errcode, stage_id, reward_list)
  log(bWriteLog and "[SY]TEMUHandler.on_buy_temu_group_pkg_rsp.errcode:", tostring(errcode))
  if errcode ~= 0 then
    return
  end
  log(bWriteLog and "[SY]Logic_temu.OnBuyComplete.stage_id:" .. tostring(stage_id))
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnBuyComplete(stage_id, reward_list)
end
function TEMUHandler.send_remind_teammate_purchase_package_req(uid_list)
  NetManager.SendPkg(870421927, uid_list)
end
function TEMUHandler.on_remind_teammate_purchase_package_rsp(errcode, uid_list)
  log(bWriteLog and "[SY]TEMUHandler.on_remind_teammate_purchase_package_rsp." .. tostring(errcode))
  ShowNotice(527069)
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnRemindTeamMate(uid_list)
end
function TEMUHandler.on_notify_invite_temu_groupbuy_result(errcode, recv_id, msg_type)
  log(bWriteLog and "[SY]TEMUHandler.on_notify_invite_temu_groupbuy_result." .. tostring(recv_id))
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if msg_type == chat_macro.temuTaskRemind then
    Logic_temu:RemindListAdd(recv_id)
    EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_TASK_REMIND)
  else
    Logic_temu:InviteListAdd(recv_id)
    EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_INVITE_FRIEND_UPDATE)
  end
end
function TEMUHandler.on_leave_temu_group_notify(group_id, activity_id, reason)
  log(bWriteLog and "[SY]TEMUHandler.on_leave_temu_group_notify." .. tostring(group_id))
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnLeaveTeam(group_id, activity_id, reason)
end
function TEMUHandler.send_get_temu_group_progress_req(stage_id)
  log(bWriteLog and "[SY]TEMUHandler.send_get_temu_group_progress_req." .. tostring(stage_id))
  NetManager.SendPkg(453306723, stage_id)
end
function TEMUHandler.on_get_temu_group_progress_rsp(errcode, stage_info)
  log(bWriteLog and "[SY]TEMUHandler.on_get_temu_group_progress_rsp.errcode:", tostring(errcode))
  if errcode ~= 0 then
    return
  end
  log_tree("on_get_temu_group_progress_rsp.stage_info", stage_info)
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnSendGetStageTaskProgress(stage_info)
end
function TEMUHandler.on_notify_temu_group_sub_stage_up(subStageID)
  log(bWriteLog and "[SY]TEMUHandler.on_notify_temu_group_sub_stage_up.")
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:MovenNextStage(subStageID)
end
function TEMUHandler.on_notify_temu_new_invite(stageId)
  log_tree("on_notify_temu_new_invite.stageId" .. tostring(stageId))
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnUpdateInviteRedDot(stageId)
end
function TEMUHandler.send_get_temu_red_point_req()
  NetManager.SendPkg(165305639)
end
function TEMUHandler.on_get_temu_red_point_rsp(errcode, be_invited_red_point, pkg_red_point, be_kicked_red_point)
  if errcode ~= 0 then
    return
  end
  log(bWriteLog and "[SY]TEMUHandler.on_get_temu_red_point_rsp." .. "red_point." .. tostring(pkg_red_point) .. " be_kicked_red_point." .. tostring(be_kicked_red_point))
  log_tree("be_invited_red_point", be_invited_red_point)
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnGetRedot(be_invited_red_point, pkg_red_point, be_kicked_red_point)
end
function TEMUHandler.send_remove_temu_be_kicked_red_point_req()
  NetManager.SendPkg(1328072639)
end
function TEMUHandler.on_remove_temu_be_kicked_red_point_rsp(errcode)
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnSendIsCheckGetKickTips()
end
function TEMUHandler.send_get_temu_recommend_list_from_pool_req(stage_id)
  NetManager.SendPkg(1436339355, stage_id)
end
function TEMUHandler.on_get_temu_recommend_list_from_pool_rsp(errcode, data, stage_id)
  if errcode ~= 0 then
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:OnSendGetRecommendInviteMap(data, stage_id)
end
function TEMUHandler.send_start_temu_task_phase_req()
  log(bWriteLog and "[SY]TEMUHandler.send_start_temu_task_phase_req.")
  NetManager.SendPkg(56541547)
end
function TEMUHandler.on_start_temu_task_phase_rsp(errcode)
  log(bWriteLog and "[SY]TEMUHandler.on_start_temu_task_phase_rsp.")
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:MovenNextStage(2)
end
function TEMUHandler.on_notify_temu_group_unlock_pkg(ret)
  log(bWriteLog and "[SY]TEMUHandler.on_start_temu_task_phase_rsp.")
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:UpdatePackageRedDot(ret)
end
function TEMUHandler.on_notify_temu_basic_info(group_id)
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:Login_SetTeamID(group_id)
end
function TEMUHandler.send_buy_temu_group_pkg_for_gift_req(stage_id, pkg_id, target_uid)
  NetManager.SendPkg(1340034267, stage_id, pkg_id, target_uid)
end
function TEMUHandler.on_buy_temu_group_pkg_for_gift_rsp(err_code, stage_id, pkg_id, target_uid)
  log(bWriteLog and "[SY]TEMUHandler.on_buy_temu_group_pkg_for_gift_rsp.err_code:" .. tostring(err_code))
  if err_code == 0 then
    ShowNotice(527146)
  elseif err_code == 20070028 then
    ShowNotice(527147)
  elseif err_code == 20070027 then
    ShowNotice(527153)
    return
  elseif err_code == 20070030 then
    ShowNotice(527161)
    return
  end
  local Logic_temu = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
  Logic_temu:SendGetSelfTeamInfo(true)
end
return TEMUHandler