local NetManager = require("client.network.comm.NetManager")
local FriendHandler = {
  friend_status_data = {},
  status_ids_list = {},
  latest_like_timestamp = 0,
  bOpenLog = false
}
function FriendHandler.send_get_all_friendlist_req()
  log(bWriteLog and "FriendHandler.send_get_all_friendlist_req")
  NetManager.SendPkg(485636135)
end
function FriendHandler.on_get_all_friendlist_rsp(res, friendlist, rejoin_switch, set_status_data, interaction_data)
  log(bWriteLog and "FriendHandler.on_get_all_friendlist_rsp res = " .. res .. ", rejoin_switch = " .. tostring(rejoin_switch))
  if res ~= "ok" then
    return
  end
  if FriendHandler.bOpenLog then
    log_tree("friendlist = ", friendlist)
    log_tree("set_status_data = ", set_status_data)
    log_tree("interaction_data = ", interaction_data)
  end
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  logic_friend_interact_record:SetHighFrequencyInteractData(interaction_data or {})
  if not interaction_data then
    logic_friend_interact_record:RequestHighFrequencyInteractData()
  end
  local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
  logic_friend:proc_get_all_friendlist_rsp(friendlist)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_get_all_friendlist_rsp(friendlist, rejoin_switch, set_status_data)
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  logic_friend_gang_up:proc_get_all_friendlist_rsp(friendlist)
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  if friendlist and friendlist.interact_info_list then
    logic_interaction:on_fire_list(friendlist.interact_info_list)
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_get_all_friendlist_rsp(res, friendlist, rejoin_switch, set_status_data)
  local HostedFriendProtocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedFriendProtocol)
  if HostedFriendProtocol and HostedFriendProtocol.FriendDataReady then
    HostedFriendProtocol:FriendListRet()
  end
end
function FriendHandler.send_get_friend_misc_info_req(frdUid, rejoin_num)
  log(bWriteLog and "[v_wllwu] FriendHandler.send_get_friend_misc_info_req, frdUid is: " .. tostring(frdUid) .. "; rejoin_num is: " .. tostring(rejoin_num))
  NetManager.SendPkg(1124666919, frdUid, rejoin_num)
end
function FriendHandler.on_get_friend_misc_info_rsp(result)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  logic_mail_proto.on_get_friend_misc_info_rsp(result)
end
function FriendHandler.send_get_intimacy_relation_req(needRedpoint)
  log(bWriteLog and "FriendHandler.send_get_intimacy_relation_req needRedpoint = ", tostring(needRedpoint))
  local PersonSpaceRelationshipSystem = require("client.logic.personspace.logic_person_space_relationship")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  log(bWriteLog and string.format("send_get_intimacy_relation_req, RoleInfoSystem.CurShowPlayerInfoUid:%s", RoleInfoSystem.CurShowPlayerInfoUid))
  if RoleInfoSystem.CurShowPlayerInfoUid ~= 0 and not PersonSpaceRelationshipSystem.IsMySelf(RoleInfoSystem.CurShowPlayerInfoUid) then
    return
  end
  NetManager.SendPkg(1857718907, needRedpoint)
end
function FriendHandler.on_get_intimacy_relation_rsp(list, intimacy_partner_data, intimacy_reddot, visible_switchs, top_red_point_info)
  log(bWriteLog and "FriendHandler.on_get_intimacy_relation_rsp")
  if FriendHandler.bOpenLog then
    log_tree("list = ", list)
    log_tree("intimacy_partner_data = ", intimacy_partner_data)
    log_tree("intimacy_reddot = ", intimacy_reddot)
    log_tree("visible_switchs = ", visible_switchs)
    log_tree("top_red_point_info = ", top_red_point_info)
  end
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  logic_friend_intimacy:proc_on_get_intimacy_relation_rsp(list, intimacy_partner_data, intimacy_reddot, visible_switchs, top_red_point_info)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_on_get_intimacy_relation_rsp(list)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_get_intimacy_relation_rsp(list)
  PersonSpaceSystem.get_intimacy_relation_rsp(list, intimacy_partner_data, intimacy_reddot, visible_switchs, top_red_point_info)
  local Lobby_RoleInfo_IntimateRelationship_Popup_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_RoleInfo_IntimateRelationship_Popup_UIBP)
  if Lobby_RoleInfo_IntimateRelationship_Popup_UIBP then
    Lobby_RoleInfo_IntimateRelationship_Popup_UIBP:SetAwardLevelData(list)
  end
end
function FriendHandler.on_notify_friend_intimacy_chg(friUid, chg, newIntimacy, extraInfo, weekSummaryInfo)
  log(bWriteLog and "FriendHandler.on_notify_friend_intimacy_chg friUid = " .. friUid .. ", chg = " .. chg .. ", newIntimacy = " .. newIntimacy)
  log_tree("extraInfo = ", extraInfo)
  log_tree("weekSummaryInfo = ", weekSummaryInfo)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_notify_friend_intimacy_chg(friUid, chg, newIntimacy, extraInfo, weekSummaryInfo)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.notify_friend_intimacy_chg(friUid, chg, newIntimacy, extraInfo)
end
function FriendHandler.send_get_recent_teammate_req()
  log(bWriteLog and "FriendHandler.send_get_recent_teammate_req")
  NetManager.SendPkg(1745184407)
end
function FriendHandler.on_get_recent_teammate_rsp(list)
  log(bWriteLog and "FriendHandler.on_get_recent_teammate_rsp")
  if FriendHandler.bOpenLog then
    log_tree("list = ", list)
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_get_recent_teammate_rsp(list)
end
function FriendHandler.send_del_inner_friend_req(friUid)
  printf("FriendHandler.send_del_inner_friend_req friUid:%s", friUid)
  NetManager.SendPkg(1107434471, friUid)
end
function FriendHandler.on_del_inner_friend_rsp(res, uid)
  printf("FriendHandler.on_del_inner_friend_rsp res:%s, uid:%s", res, uid)
  if res == NetErrorCode_NONE then
    local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
    logic_friend:RefactorAddOrDeleteFriend(uid, false)
    local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
    logic_friend_list:proc_del_inner_friend_rsp(uid)
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_del_inner_friend_rsp(res, uid)
end
function FriendHandler.send_get_upvote_recent_req()
  printf("FriendHandler.send_get_upvote_recent_req")
  NetManager.SendPkg(1484021403)
end
function FriendHandler.on_get_upvote_recent_rsp(data)
  printf("FriendHandler.on_get_upvote_recent_rsp data:%s", data)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.get_upvote_recent_rsp(data)
end
function FriendHandler.send_build_intimacy_relation_req(friUid, relation, vow_id)
  printf("FriendHandler.send_build_intimacy_relation_req friUid:%s, relation:%s, vow_id:%s", friUid, relation, vow_id)
  vow_id = vow_id or 0
  NetManager.SendPkg(1639063835, friUid, relation, vow_id)
end
function FriendHandler.on_build_intimacy_relation_rsp(res, friUid, relation, limit)
  printf("FriendHandler.on_build_intimacy_relation_rsp res = %s, friUid = %s, relation = %s, limit = %s", res, friUid, relation, limit)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if res ~= NetErrorCode_NONE then
    LogicFriend.ShowIntimacyErrCode(res, relation, limit)
    return true
  end
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  logic_friend_intimacy:proc_build_intimacy_relation_rsp(friUid, relation)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_build_intimacy_relation_rsp(friUid, relation)
  LogicFriend.proc_build_intimacy_relation_rsp(friUid, relation)
end
function FriendHandler.send_delete_intimacy_relation_req(friUid)
  log(bWriteLog and "FriendHandler.send_delete_intimacy_relation_req friUid = " .. tostring(friUid))
  NetManager.SendPkg(56079783, friUid)
end
function FriendHandler.on_delete_intimacy_relation_rsp(res, friUid, relation)
  log(bWriteLog and "FriendHandler.on_delete_intimacy_relation_rsp res = " .. tostring(res) .. " friUid = " .. tostring(friUid) .. ", relation = " .. tostring(relation))
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_delete_intimacy_relation_rsp(friUid)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  logic_friend_intimacy:proc_delete_intimacy_relation_rsp(friUid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_delete_intimacy_relation_rsp(res, friUid, relation)
end
function FriendHandler.send_cancel_build_intimacy_relation_req(friUid)
  log(bWriteLog and "FriendHandler.send_cancel_build_intimacy_relation_req friUid = " .. tostring(friUid))
  NetManager.SendPkg(1931538023, friUid)
end
function FriendHandler.on_cancel_build_intimacy_relation_rsp(res, friUid)
  log(bWriteLog and "FriendHandler.on_cancel_build_intimacy_relation_rsp res = " .. tostring(res) .. " friUid = " .. tostring(friUid))
  if res == NetErrorCode_NONE then
    ShowNotice(200058)
  elseif res == "state-error" then
    ShowNotice(200059)
    return
  end
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_cancel_build_intimacy_relation_rsp(friUid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_cancel_build_intimacy_relation_rsp(res, friUid)
end
function FriendHandler.on_notify_intimacy_relation_chg(friUid, state, param, rank_uid, other_params)
  printf("FriendHandler.on_notify_intimacy_relation_chg friUid:%s, state:%s, param:%s, rank_uid:%s", friUid, state, param, rank_uid)
  if other_params then
    log_tree("FriendHandler.on_notify_intimacy_relation_chg other_params:", other_params)
  end
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  logic_friend_intimacy:proc_notify_intimacy_relation_chg(friUid, state, param, rank_uid, other_params)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_notify_intimacy_relation_chg(friUid, state, param, rank_uid, other_params)
end
function FriendHandler.send_reply_intimacy_relation_req(friUid, relation, op, cbdata, vow_id)
  printf("FriendHandler.send_reply_intimacy_relation_req friUid:%s, relation:%s, op:%s, vow_id:%s, cbdata:%s", friUid, relation, op, vow_id, cbdata)
  vow_id = vow_id or 0
  NetManager.SendPkg(281412907, friUid, relation, op, cbdata, vow_id)
end
function FriendHandler.on_reply_intimacy_relation_rsp(res, friUid, relation, op, cbdata, limit, intimacyInfo)
  printf("FriendHandler.on_reply_intimacy_relation_rsp res:%s, friUid:%s, relation:%s, op:%s, cbdata:%s, limit:%s", res, friUid, relation, op, cbdata, limit)
  if intimacyInfo then
    log_tree("FriendHandler.on_reply_intimacy_relation_rsp intimacyInfo:", intimacyInfo)
  end
  if res == NetErrorCode_NONE and op == 1 and intimacyInfo then
    local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
    logic_friend_intimacy:proc_reply_intimacy_relation_rsp(friUid, relation, intimacyInfo)
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_reply_intimacy_relation_rsp(res, friUid, relation, op, limit)
end
function FriendHandler.on_del_inner_friend_notify(uid)
  printf("FriendHandler.on_del_inner_friend_notify uid:%s", uid)
  local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
  logic_friend:RefactorAddOrDeleteFriend(uid, false)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_del_inner_friend_rsp(uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_del_inner_friend_notify(uid)
end
function FriendHandler.on_notify_team_result_finished()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_notify_team_result_finished()
end
function FriendHandler.on_notify_topn_plat_friend_chg_info(list)
  printf("FriendHandler.on_notify_topn_plat_friend_chg_info list:%s", list)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_notify_topn_plat_friend_chg_info(list)
end
function FriendHandler.on_appointment_game_friend_notify(friUid, from, msg_id)
  printf("FriendHandler.on_appointment_game_friend_notify friUid:%s, from:%s, msg_id:%s", friUid, from, msg_id)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_appointment_game_friend_notify(friUid, from)
end
function FriendHandler.send_appointment_game_friend_answer(uid, bReply, from)
  printf("FriendHandler.send_appointment_game_friend_answer uid:%s, bReply:%s, from:%s", uid, bReply, from)
  NetManager.SendPkg(557014886, uid, bReply, from)
end
function FriendHandler.send_appointment_game_friend_req(uid, from, msg_id)
  printf("FriendHandler.send_appointment_game_friend_req uid:%s, from:%s, msg_id:%s", uid, from, msg_id)
  NetManager.SendPkg(1019574960, uid, from, msg_id)
end
function FriendHandler.on_appointment_game_friend_res(num_uid, result, from, invite_info)
  printf("FriendHandler.on_appointment_game_friend_res num_uid:%s, result:%s, from:%s, invite_info:%s", num_uid, result, from, invite_info)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_appointment_game_friend_res(num_uid, result, from, invite_info)
end
function FriendHandler.on_notify_appointment_friend_list(fri_list)
  printf("FriendHandler.on_notify_appointment_friend_list fri_list:%s", fri_list)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_notify_appointment_friend_list(fri_list)
end
function FriendHandler.on_appointment_friend_game_end(num_uid)
  printf("FriendHandler.on_appointment_friend_game_end num_uid:%s", num_uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_appointment_friend_game_end(num_uid)
end
function FriendHandler.on_cancel_build_intimacy_relation_notify(friUid, canBuild)
  printf("FriendHandler.on_cancel_build_intimacy_relation_notify friUid:%s, canBuild:%s", friUid, canBuild)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_cancel_build_intimacy_relation_notify(friUid, canBuild)
end
function FriendHandler.send_del_inner_friend_batch_req(list)
  printf("FriendHandler.send_del_inner_friend_batch_req list:%s", list)
  NetManager.SendPkg(1734064071, list)
end
function FriendHandler.on_del_inner_friend_batch_rsp(res, friendUidList)
  printf("FriendHandler.on_del_inner_friend_batch_rsp res:%s, friendUidList:%s", res, friendUidList)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_del_inner_friend_batch_rsp(res, friendUidList)
  local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
  logic_friend:proc_del_inner_friend_batch_rsp(res, friendUidList)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.del_inner_friend_batch_rsp(res, friendUidList)
end
function FriendHandler.send_invite_offline_friend_req(channel)
  printf("FriendHandler.send_invite_offline_friend_req channel:%s", channel)
  NetManager.SendPkg(506495507, channel)
end
function FriendHandler.on_invite_offline_friend_rsp(res, teamid)
  printf("FriendHandler.on_invite_offline_friend_rsp res:%s, teamid:%s", res, teamid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_invite_offline_friend_rsp(res, teamid)
end
function FriendHandler.send_send_friend_item_req(friUid, itemID, num)
  printf("FriendHandler.send_send_friend_item_req friUid:%s, itemID:%s, num:%s", friUid, itemID, num)
  NetManager.SendPkg(1178102375, friUid, itemID, num)
end
function FriendHandler.on_send_friend_item_rsp(res)
  printf("FriendHandler.on_send_friend_item_rsp res:%s", res)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_send_friend_item_rsp(res)
end
function FriendHandler.send_update_friend_remark_req(uid, remark_name)
  printf("FriendHandler.send_update_friend_remark_req uid:%s, remark_name:%s", uid, remark_name)
  NetManager.SendPkg(342807655, uid, remark_name)
end
function FriendHandler.on_update_friend_remark_rsp(err_code, uid, remark_name)
  printf("FriendHandler.on_update_friend_remark_rsp err_code:%s, uid:%s, remark_name:%s", err_code, uid, remark_name)
  if err_code == 0 then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    LogicFriend.SetRemark(uid, remark_name)
  elseif err_code == 100240003 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, nil, LocUtil.GetLocalizeResStr(44791))
  elseif err_code == 100240002 then
    ShowNotice(100240002)
  elseif err_code == 100240001 then
    ShowNotice(100240001)
  else
    ShowNotice(100240000)
  end
end
function FriendHandler.send_check_and_update_invite_plat_req(friUid)
  printf("FriendHandler.send_check_and_update_invite_plat_req friUid:%s", friUid)
  NetManager.SendPkg(397073191, friUid)
end
function FriendHandler.on_check_and_update_invite_plat_rsp(res, friUid)
  printf("FriendHandler.on_check_and_update_invite_plat_rsp res:%s, friUid:%s", res, friUid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.check_and_update_invite_plat_rsp(res, friUid)
end
function FriendHandler.send_set_friend_banned_tips_time()
  printf("FriendHandler.send_set_friend_banned_tips_time")
  NetManager.SendPkg(1623896061)
end
function FriendHandler.send_get_friend_status_detail_req()
  printf("FriendHandler.send_get_friend_status_detail_req")
  NetManager.SendPkg(996838631)
end
function FriendHandler.on_get_friend_status_detail_rsp(ret_code, friend_status_data, status_ids_list)
  log(bWriteLog and "FriendHandler.on_get_friend_status_detail_rsp " .. ret_code)
  log_tree("FriendHandler.on_get_friend_status_detail_rsp ", friend_status_data)
  log_tree("FriendHandler.on_get_friend_status_detail_rsp ", status_ids_list)
  if ret_code == 0 then
    FriendHandler.friend_status_data = friend_status_data or {}
    FriendHandler.status_ids_list = status_ids_list or {}
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_GET_FRIEND_STATUS_DETAIL)
  end
end
function FriendHandler.send_set_friend_status_new_req(sub_status_id, custom_txt, icon_idx)
  printf("FriendHandler.send_set_friend_status_new_req sub_status_id:%s, custom_txt:%s, icon_idx:%s", sub_status_id, custom_txt, icon_idx)
  NetManager.SendPkg(157476303, sub_status_id, custom_txt, icon_idx)
end
function FriendHandler.on_set_friend_status_new_rsp(ret_code, friend_status_data, left_times)
  printf("FriendHandler.on_set_friend_status_new_rsp ret_code:%s, friend_status_data:%s, left_times:%s", ret_code, friend_status_data, left_times)
  if ret_code ~= 0 then
    if ret_code == 13020008 then
      ShowNotice(LocUtil.LocalizeResFormat(37242, 15))
    elseif ret_code == 13020010 then
      ShowNotice(LocUtil.LocalizeResFormat(37438))
    elseif ret_code == 13020015 then
      ShowNotice(13020015)
    elseif ret_code == 13020016 then
      ShowNotice(13020016)
    elseif ret_code == 13020017 then
      ShowNotice(13020017)
    elseif ret_code == 13020018 then
      ShowNotice(13020018)
    end
    return
  end
  log_tree("on_set_friend_status_new_rsp", friend_status_data)
  FriendHandler.  local cfg = CDataTable.GetTableData("FriendStatusCfg", friend_status_data.sub_status_id)
  if cfg then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if cfg.type == 7 then
      FriendHandler.status_week_    end
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_SELF_STATUS_CHANGE)
  if cfg then
    local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
    if CorpsMemberSystem.UpdateStatus(tonumber(DataMgr.roleData.uid), {
      teamState = cfg.type
    }) then
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_STATUS_UPDATE, DataMgr.roleData.uid)
    end
  end
end
function FriendHandler.send_do_friend_status_like_req(target_uid)
  printf("FriendHandler.send_do_friend_status_req target_uid:%s", target_uid)
  NetManager.SendPkg(38132935, target_uid)
end
function FriendHandler.on_do_friend_status_like_rsp(ret_code, target_uid, self_like_list)
  printf("FriendHandler.on_do_friend_status_like_rsp ret_code:%s, target_uid:%s, self_like_list:%s", ret_code, target_uid, self_like_list)
  FriendHandler.friend_status_data = FriendHandler.friend_status_data or {}
  FriendHandler.friend_status_data.end
function FriendHandler.on_add_frd_status_like_notify(like_uid, timestamp, liked_list)
  log_tree("FriendHandler.on_add_frd_status_like_notify ", liked_list)
  FriendHandler.friend_status_data = FriendHandler.friend_status_data or {}
  FriendHandler.friend_status_data.  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_FRIEND_LIKED_NOTIFY)
end
function FriendHandler.on_frd_status_change_notify(frd_uid, sub_status_id, end_timestamp, custom_txt, icon_idx)
  log(bWriteLog and "FriendHandler.on_frd_status_change_notify " .. tostring(frd_uid) .. ", " .. tostring(sub_status_id) .. ", " .. tostring(custom_txt) .. ", " .. tostring(icon_idx))
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({frd_uid}, function(list)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(frd_uid)
    if profile then
      profile.frd_status_id = sub_status_id
      profile.frd_status_end_time = end_timestamp
      profile.frd_      profile.frd_    end
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_STATUS_CHANGE)
  end, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
end
function FriendHandler.send_intimacy_friend_recommend_req(recommend_type, is_same_language)
  printf("FriendHandler.send_intimacy_friend_recommend_req recommend_type:%s, is_same_language:%s", recommend_type, is_same_language)
  NetManager.SendPkg(1401805203, recommend_type, is_same_language)
end
function FriendHandler.on_intimacy_friend_recommend_rsp(ret_code, ret_table)
  printf("FriendHandler.on_intimacy_friend_recommend_rsp ret_code:%s, ret_table:%s", ret_code, ret_table)
  if ret_code ~= 0 then
    ShowNotice(ret_code)
    return
  end
  FriendHandler.LastRecommendTb = ret_table
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_RECOMMEND_RSP, ret_table)
end
function FriendHandler.send_do_friend_top_op_req(op_list)
  printf("FriendHandler.send_do_friend_top_op_req op_list:%s", op_list)
  log_tree("FriendHandler.send_do_friend_top_op_req ", op_list)
  NetManager.SendPkg(1512350823, op_list)
end
function FriendHandler.on_do_friend_top_op_rsp(ret_code, ret_list)
  printf("FriendHandler.on_do_friend_top_op_rsp ret_code:%s, ret_list:%s", ret_code, ret_list)
  if ret_code ~= 0 then
    ShowNotice(ret_code)
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_do_friend_top_op_rsp(ret_list)
end
function FriendHandler.send_take_intimacy_award_req(target_uid, intimacy_level)
  log(bWriteLog and "[PXY]send_take_intimacy_award_req target_uid = " .. tostring(target_uid) .. ",intimacy_level = " .. tostring(intimacy_level))
  NetManager.SendPkg(1857937715, target_uid, intimacy_level)
end
function FriendHandler.on_take_intimacy_award_rsp(ret_code, target_uid, award_level, item_list)
  log(bWriteLog and "[pxy]on_take_intimacy_award_rsp ret_code = " .. tostring(ret_code) .. ", target_uid = " .. tostring(target_uid) .. ", award_level = " .. tostring(award_level))
  log_tree("FriendHandler.on_take_intimacy_award_rsp item_list", item_list)
  if ret_code ~= 0 then
    ShowNotice(ret_code)
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_take_intimacy_award_rsp(award_level, target_uid, item_list)
end
function FriendHandler.send_modify_friend_appointment_privacy_req(privacy)
  log(bWriteLog and "FriendHandler.send_modify_friend_appointment_privacy_req privacy = " .. privacy)
  NetManager.SendPkg(1308907275, privacy)
end
function FriendHandler.on_modify_friend_appointment_privacy_rsp(err_code, privacy)
  log(bWriteLog and "FriendHandler.on_modify_friend_appointment_privacy_rsp err_code = " .. tostring(err_code) .. ", privacy = " .. tostring(privacy))
  if err_code ~= 0 then
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:proc_modify_friend_appointment_privacy_rsp(privacy)
end
function FriendHandler.send_get_appointment_friend_req()
  printf("FriendHandler.send_get_appointment_friend_req")
  NetManager.SendPkg(91891879)
end
function FriendHandler.on_get_appointment_friend_rsp(err_code, send_friends, auto_reply)
  printf("FriendHandler.on_get_appointment_friend_rsp err_code:%s, send_friends:%s, auto_reply:%s", err_code, send_friends, auto_reply)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:OnGetHistoryReserveInfoReq(err_code, send_friends, auto_reply)
end
function FriendHandler.send_appointment_friend_auto_reply_req(res)
  printf("FriendHandler.send_appointment_friend_auto_reply_req res:%s", res)
  NetManager.SendPkg(1221534975, res)
end
function FriendHandler.on_appointment_friend_auto_reply_rsp(err_code, res)
  printf("FriendHandler.on_appointment_friend_auto_reply_rsp err_code:%s, res:%s", err_code, res)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:OnChangeAutoReplyReq(err_code, res)
end
function FriendHandler.on_notify_appointment_friends(accept_friends)
  printf("FriendHandler.on_notify_appointment_friends accept_friends:%s", accept_friends)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:NotifyFriends(accept_friends)
end
function FriendHandler.send_get_season_interact_records_req(uid)
  log(bWriteLog and "[DeanJYT] FriendHandler.send_get_season_interact_records_req")
  NetManager.SendPkg(2104529339, uid)
end
function FriendHandler.on_get_season_interact_records_rsp(res, uid, data)
  if res ~= 0 then
    log(bWriteLog and "[DeanJYT] FriendHandler.on_get_season_interact_records_rsp error on rsp, res = " .. tostring(res))
    return
  end
  local decompressedData = slua.LuaArchiverDecode(LuaStateWrapper, data) or {}
  log_tree("[DeanJYT] FriendHandler.on_get_season_interact_records_rsp uid = " .. tostring(uid) .. ", decompressedData = ", decompressedData)
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  logic_friend_interact_record:OnSeasonInteractDataForPlayerRsp(uid, decompressedData)
end
function FriendHandler.send_get_interact_records_req(uid)
  log(bWriteLog and "[DeanJYT] FriendHandler.send_get_interact_records_req")
  NetManager.SendPkg(1918849255, uid)
end
function FriendHandler.on_get_interact_records_rsp(res, uid, data)
  if res ~= 0 then
    log(bWriteLog and "[DeanJYT] FriendHandler.on_get_interact_records_rsp error on rsp, res = " .. tostring(res))
    return
  end
  local decompressedData = slua.LuaArchiverDecode(LuaStateWrapper, data) or {}
  log_tree("[DeanJYT] FriendHandler.on_get_interact_records_rsp uid = " .. tostring(uid) .. ", decompressedData = ", decompressedData)
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  logic_friend_interact_record:OnCumulativeInteractDataForPlayerRsp(uid, decompressedData)
end
function FriendHandler.send_get_all_friendlist_interact_req()
  log(bWriteLog and "FriendHandler.send_get_all_friendlist_interact_req")
  NetManager.SendPkg(864561683)
end
function FriendHandler.on_get_all_friendlist_interact_rsp(res, data)
  log(bWriteLog and "FriendHandler.on_get_all_friendlist_interact_rsp res = " .. res)
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  logic_friend_interact_record:proc_get_all_friendlist_interact_rsp(res, data)
end
function FriendHandler.on_friend_gang_up_count_ntfy(update_counts)
  log(bWriteLog and "FriendHandler.on_friend_gang_up_count_ntfy")
  log_tree("update_counts = ", update_counts)
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  logic_friend_gang_up.on_friend_gang_up_count_ntfy(update_counts)
end
function FriendHandler.on_friend_gang_up_chat_ntfy(gang_up_chat_friends, week_time)
  log(bWriteLog and "FriendHandler.on_friend_gang_up_chat_ntfy")
  log_tree("gang_up_chat_friends = ", gang_up_chat_friends)
  log_tree("week_time = ", week_time)
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  logic_friend_gang_up.on_friend_gang_up_chat_ntfyf(gang_up_chat_friends, week_time)
end
function FriendHandler.on_friend_gang_up_week_refresh_ntfy(data)
  log(bWriteLog and "FriendHandler.on_friend_gang_up_week_refresh_ntfy")
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  logic_friend_gang_up.on_friend_gang_up_week_refresh_ntfy(data.friend_counts)
end
function FriendHandler.send_get_openid_by_nickname_req(nickname, cb)
  printf("FriendHandler.send_get_openid_by_nickname_req nickname:%s, cb:%s", nickname, cb)
  NetManager.SendPkg(1958943335, nickname, cb)
end
function FriendHandler.on_get_openid_by_nickname_rsp(nickname, res, openid, cb)
  printf("FriendHandler.on_get_openid_by_nickname_rsp nickname:%s, res:%s, openid:%s, cb:%s", nickname, res, openid, cb)
end
function FriendHandler.send_report_interaction_req(to_uid, interaction_type)
  printf("FriendHandler.send_report_interaction_req to_uid:%s, interaction_type:%s", to_uid, interaction_type)
  NetManager.SendPkg(591822567, to_uid, interaction_type)
end
function FriendHandler.send_get_not_fir_interaction_req()
  printf("FriendHandler.send_get_not_fir_interaction_req")
  NetManager.SendPkg(615096143)
end
function FriendHandler.on_get_not_fir_interaction_rsp(err_code, interact_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "on_get_not_fir_interaction_rsp info = ", interact_info)
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  logic_friend_interact_record:SetRecentInteractData(interact_info)
end
function FriendHandler.on_report_interaction_rsp(ret, to_uid, interaction_type, extend_info)
  log(bWriteLog and "FriendHandler.on_report_interaction_rsp ret = " .. tostring(ret))
end
function FriendHandler.send_change_intimacy_relation_req(fri_uid, change_type, param, vow_id)
  printf("FriendHandler.send_change_intimacy_relation_req fri_uid:%s, change_type:%s, param:%s, vow_id:%s", fri_uid, change_type, param, vow_id)
  vow_id = vow_id or 0
  NetManager.SendPkg(1295818535, fri_uid, change_type, param, vow_id)
end
function FriendHandler.on_change_intimacy_relation_rsp(res, fri_uid, change_type, param)
  log(bWriteLog and "FriendHandler.on_change_intimacy_relation_rsp res = " .. res)
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  if res ~= 0 then
    ShowNotice(logic_new_friend.get_change_intimacy_relation_tip(res))
    return true
  end
  log(bWriteLog and "fri_uid = " .. fri_uid .. ", change_type = " .. change_type .. ", param = " .. param)
  logic_new_friend.proc_change_intimacy_relation_rsp(fri_uid, change_type, param)
  if change_type == logic_new_friend.RelationChangeType.RelationType then
    ShowNotice(73277)
  elseif change_type == logic_new_friend.RelationChangeType.CustomName then
    ShowNotice(73261)
  end
end
function FriendHandler.send_reply_change_intimacy_relation_req(fri_uid, op, change_type, param, vow_id)
  printf("FriendHandler.send_reply_change_intimacy_relation_req friUid:%s, op:%s, change_type:%s, param:%s, vow_id:%s", fri_uid, op, change_type, param, vow_id)
  vow_id = vow_id or 0
  NetManager.SendPkg(2112290343, fri_uid, op, change_type, param, vow_id)
end
function FriendHandler.on_reply_change_intimacy_relation_rsp(res, fri_uid, op, change_type, param, intimacy_info)
  printf("FriendHandler.on_reply_change_intimacy_relation_rsp res = %s, fri_uid = %s, op = %s, change_type = %s, param = %s, intimacy_info = %s", res, fri_uid, op, change_type, param, intimacy_info)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if res ~= 0 then
    if res == "cur-relation-full" and param == 6 then
      ShowNotice(82943)
    else
      ShowNotice(LogicFriend.get_change_intimacy_relation_tip(res))
    end
    return true
  end
  if op == LogicFriend.RelationApplyOp.Agree then
    local ui_util = require("client.common.ui_util")
    if change_type == LogicFriend.RelationChangeType.RelationType then
      local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
      logic_friend_intimacy:proc_reply_change_intimacy_relation_rsp(fri_uid, param, intimacy_info)
      ShowNotice(LocUtil.LocalizeResFormat(73286, ui_util.GetIntimacyRelationName(param)))
    elseif change_type == LogicFriend.RelationChangeType.CustomName then
      ShowNotice(LocUtil.LocalizeResFormat(73286, param))
    end
    LogicFriend.on_reply_change_intimacy_relation_rsp(fri_uid, op, change_type, param)
  elseif op == LogicFriend.RelationApplyOp.Refuse then
    LogicFriend.on_reply_change_intimacy_relation_rsp(fri_uid, op, change_type, param)
  end
end
function FriendHandler.send_cancel_change_intimacy_relation_req(fri_uid, change_type, param)
  printf("FriendHandler.send_cancel_change_intimacy_relation_req fri_uid:%s, change_type:%s, param:%s", fri_uid, change_type, param)
  NetManager.SendPkg(1530862471, fri_uid, change_type, param)
end
function FriendHandler.on_cancel_change_intimacy_relation_rsp(res, fri_uid, change_type, param)
  printf("FriendHandler.on_cancel_change_intimacy_relation_rsp res:%s, fri_uid:%s, change_type:%s, param:%s", res, fri_uid, change_type, param)
  if res ~= 0 then
    ShowNotice(res)
    return true
  end
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  logic_friend_intimacy:proc_cancel_change_intimacy_relation_rsp(fri_uid, change_type, param)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_cancel_change_intimacy_relation_rsp(fri_uid, change_type, param)
end
function FriendHandler.on_notify_change_intimacy_relation_update(fri_uid, change_type, change_data)
  printf("FriendHandler.on_notify_change_intimacy_relation_update fri_uid:%s, change_type:%s, change_data:%s", fri_uid, change_type, change_data)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_notify_change_intimacy_relation_update(fri_uid, change_type, change_data)
end
function FriendHandler.on_notify_intimacy_level_up(fri_uid, level, item_list)
  printf("FriendHandler.on_notify_intimacy_level_up fri_uid:%s, level:%s, item_list:%s", fri_uid, level, item_list)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.on_notify_intimacy_level_up(fri_uid, level, item_list)
end
function FriendHandler.send_report_friend_info_req(type, code, err_str)
  log(bWriteLog and "FriendHandler.send_report_friend_info_req")
  log(bWriteLog and "type " .. tostring(type) .. " code " .. tostring(code) .. " err_str " .. tostring(err_str))
  NetManager.SendPkg(610315015, type, code, err_str)
end
function FriendHandler.on_report_friend_info_rsp(res, type, code, err_str)
  log(bWriteLog and "FriendHandler.on_report_friend_info_rsp res " .. tostring(res))
  log(bWriteLog and "type " .. tostring(type) .. " code " .. tostring(code) .. " err_str " .. tostring(err_str))
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.proc_report_friend_info_rsp(res, type, code, err_str)
end
function FriendHandler.on_notify_rela_need_login(iNeedLogin)
  log(bWriteLog and "FriendHandler.on_notify_rela_need_login" .. tostring(iNeedLogin))
  local logic_friend_spk_fb = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_spk_fb)
  logic_friend_spk_fb:proc_notify_rela_need_login(iNeedLogin)
end
function FriendHandler.send_spk_grant_success_req()
  log(bWriteLog and "FriendHandler.send_spk_grant_success_req")
  NetManager.SendPkg(2076858151)
end
function FriendHandler.on_spk_grant_success_rsp(ret)
  log(bWriteLog and "FriendHandler.on_spk_grant_success_rsp ret " .. tostring(ret))
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local logic_friend_spk_fb = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_spk_fb)
  logic_friend_spk_fb:RefreshFriends()
end
function FriendHandler.send_get_friend_interact_milestone_req(friend_uid)
  log(bWriteLog and "FriendHandler.send_get_friend_interact_milestone_req friend_uid " .. tostring(friend_uid))
  NetManager.SendPkg(1716088527, friend_uid)
end
function FriendHandler.on_get_friend_interact_milestone_rsp(err_code, friend_uid, milestone_info, like_data)
  log(bWriteLog and "FriendHandler.on_get_friend_interact_milestone_rsp err_code " .. tostring(err_code) .. ", friend_uid " .. tostring(friend_uid))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("FriendHandler.on_get_friend_interact_milestone_rsp milestone_info ", milestone_info)
  log_tree("FriendHandler.on_get_friend_interact_milestone_rsp like_data ", like_data)
  local logic_friend_memory_record = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_memory_record)
  logic_friend_memory_record:on_get_friend_interact_milestone_rsp(err_code, friend_uid, milestone_info, like_data)
end
function FriendHandler.send_friend_interact_milestone_like_req(friend_uid, field_name, index, op_type)
  log(bWriteLog and "FriendHandler.send_friend_interact_milestone_like_req friend_uid " .. tostring(friend_uid) .. ", field_name " .. tostring(field_name) .. ", index " .. tostring(index) .. ", op_type " .. tostring(op_type))
  NetManager.SendPkg(547460039, friend_uid, field_name, index, op_type)
end
function FriendHandler.on_friend_interact_milestone_like_rsp(err_code, friend_uid, field_name, index, op_type)
  log(bWriteLog and "FriendHandler.on_friend_interact_milestone_like_rsp err_code " .. tostring(err_code) .. ", friend_uid " .. tostring(friend_uid) .. ", field_name " .. tostring(field_name) .. ", index " .. tostring(index) .. ", op_type " .. tostring(op_type))
  if err_code ~= 0 then
    ShowNotice(err_code)
    if err_code == 13070105 then
      FriendHandler.send_get_friend_interact_milestone_req(friend_uid)
    end
    return
  end
  local logic_friend_memory_record = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_memory_record)
  logic_friend_memory_record:on_friend_interact_milestone_like_rsp(err_code, friend_uid, field_name, index, op_type)
end
local reqRsp = {
  send_build_intimacy_relation_req = "on_build_intimacy_relation_rsp",
  send_reply_intimacy_relation_req = "on_reply_intimacy_relation_rsp",
  send_change_intimacy_relation_req = "on_change_intimacy_relation_rsp",
  send_reply_change_intimacy_relation_req = "on_reply_change_intimacy_relation_rsp",
  send_cancel_change_intimacy_relation_req = "on_cancel_change_intimacy_relation_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, FriendHandler)
return FriendHandler