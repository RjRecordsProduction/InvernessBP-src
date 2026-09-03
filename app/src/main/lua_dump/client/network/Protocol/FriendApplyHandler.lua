local NetManager = require("client.network.comm.NetManager")
local FriendApplyHandler = {}
function FriendApplyHandler.send_get_addfriend_reqlist_req()
  NetManager.SendPkg(1028934551)
end
function FriendApplyHandler.on_get_addfriend_reqlist_rsp(res, uid, addfriend_reqlist)
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:proc_get_addfriend_reqlist_rsp(res, uid, addfriend_reqlist)
end
function FriendApplyHandler.on_add_inner_friend_op_notify(op, friUid, extend_info)
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_op_notify op: " .. op .. " friUid: " .. friUid)
  log_tree(extend_info)
  if op ~= 1 then
    return
  end
  local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
  logic_friend:RefactorAddOrDeleteFriend(friUid, true)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_add_inner_friend(friUid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.AddInnerFriend(friUid)
  if extend_info then
    LogicFriend.AddSource(friUid, extend_info.source)
  else
    log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_op_notify\239\188\154 extend info is nil")
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.FRIEND_ADD, {friUid}, LogicFriend.on_batch_get_profile_rsp)
end
function FriendApplyHandler.on_auto_add_inner_friend_notify(uid)
  uid = tonumber(uid)
  local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
  logic_friend:RefactorAddOrDeleteFriend(uid, true)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_add_inner_friend(uid)
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:proc_auto_add_inner_friend_notify(uid)
end
function FriendApplyHandler.send_add_inner_friend_op_req(friUid, op, msg, extend_info)
  NetManager.SendPkg(1543030903, friUid, op, msg, extend_info)
end
function FriendApplyHandler.on_add_inner_friend_op_rsp(res, friUid, op)
  if res == NetErrorCode_NONE and op == 1 then
    local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
    logic_friend:RefactorAddOrDeleteFriend(friUid, true)
    local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
    logic_friend_list:proc_add_inner_friend(friUid)
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:proc_add_inner_friend_op_rsp(res, friUid, op)
end
function FriendApplyHandler.send_batch_add_inner_friend_op_req(list, op, extend_info)
  log_tree(bWriteLog and "[v_wllwu] FriendApplyHandler.send_batch_add_inner_friend_op_req, extend_info is:", extend_info)
  NetManager.SendPkg(383952899, list, op, extend_info)
end
function FriendApplyHandler.on_batch_add_inner_friend_op_rsp(res, result, op)
  log(bWriteLog and string.format("FriendApplyHandler.on_batch_add_inner_friend_op_rs %s %s", res, op))
  if res == NetErrorCode_NONE and op ~= 0 then
    local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
    for uid, res in pairs(result) do
      if res == NetErrorCode_NONE then
        logic_friend:RefactorAddOrDeleteFriend(uid, true)
        local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
        logic_friend_list:proc_add_inner_friend(uid)
      end
    end
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:proc_batch_add_inner_friend_op_rsp(res, result, op)
end
function FriendApplyHandler.send_batch_add_friend_req(uid_list, msg, from, extend_info)
  log(bWriteLog and "FriendApplyHandler.send_batch_add_friend_req")
  NetManager.SendPkg(1382179111, uid_list, msg, from, extend_info)
end
function FriendApplyHandler.on_batch_add_friend_rsp(res)
  log(bWriteLog and string.format("FriendApplyHandler.on_batch_add_friend_rsp res:%s", res))
  if res == 13070003 then
    local title = LocUtil.GetLocalizeResStr(101001)
    local text = LocUtil.GetLocalizeResStr(44791)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, text)
    return
  end
  if res ~= 0 then
    return
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_VERIFY_SEND_CLICK, true, true)
end
function FriendApplyHandler.send_add_inner_friend_req(uid, msg, from, extendInfo)
  uid = tonumber(uid)
  log(bWriteLog and string.format("FriendApplyHandler.send_add_inner_friend_req uid:%s msg:%s ", tostring(uid), tostring(msg)))
  log(bWriteLog and "FriendApplyHandler.send_add_inner_friend_req uid type = " .. type(uid))
  NetManager.SendPkg(128198055, uid, msg, from, extendInfo)
end
function FriendApplyHandler.on_add_inner_friend_rsp(res, endtime, reason, uid)
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_rsp res: " .. res)
  local TimeUtil = require("client.common.time_util")
  if res == NetErrorCode_NONE then
    local msg = LocUtil.GetLocalizeResStr(200001)
    if msg then
      local str = msg
      ShowNotice(str)
    end
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_VERIFY_SEND_CLICK, uid)
  elseif res == "ban-add-friend" then
    log(bWriteLog and "LogicFriend.on_add_inner_friend_rsp endtime: " .. endtime .. " reason: " .. reason)
    local title = LocUtil.GetLocalizeResStr(101001)
    local date = TimeUtil.FormatTime_YMDHMS(endtime, true)
    local textvalue = LocUtil.GetLocalizeResStr(115007)
    local text = string.format(textvalue, reason .. "\n", date)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, text)
  elseif res == "fri_already" then
    local str = LocUtil.GetLocalizeResStr(200007)
    ShowNotice(str)
  elseif res == "fri_list_full" then
    ShowNotice(200008)
  elseif res == "fri_repeat" then
    local str = LocUtil.GetLocalizeResStr(200002)
    ShowNotice(str)
  elseif res == "fri_self" then
    local str = LocUtil.GetLocalizeResStr(200004)
    ShowNotice(str)
  elseif res == "already_in_req_list" then
    local str = LocUtil.GetLocalizeResStr(7956)
    ShowNotice(str)
  elseif res == "day_limit" then
    local str = LocUtil.GetLocalizeResStr(200072)
    ShowNotice(str)
  elseif res == "tss-check-error" then
    log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_rsp endtime: " .. tostring(endtime) .. " reason: " .. tostring(reason))
    local title = LocUtil.GetLocalizeResStr(101001)
    local text = LocUtil.GetLocalizeResStr(44791)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, text)
  else
    local str = LocUtil.GetLocalizeResStr(200005)
    ShowNotice(str)
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INNERADD_NOTIFY, DataMgr.roleData.uid)
end
function FriendApplyHandler.on_add_inner_friend_notify(add_req_friend, msg, msgcreateTime, from, is_dirty_cn, can_be_hidden, mutual_friends_cnt)
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_notify add_req_friend = " .. tostring(add_req_friend))
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_notify msg = " .. tostring(msg))
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_notify msgcreateTime = " .. tostring(msgcreateTime))
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_notify from = " .. tostring(from))
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_notify is_dirty_cn = " .. tostring(is_dirty_cn))
  log(bWriteLog and "FriendApplyHandler.on_add_inner_friend_notify can_be_hidden = " .. tostring(can_be_hidden))
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:proc_add_inner_friend_notify(add_req_friend, msg, msgcreateTime, from, is_dirty_cn, can_be_hidden, mutual_friends_cnt)
end
function FriendApplyHandler.on_del_addfriend_req_notify(uid)
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:DelApplyList(uid)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
end
return FriendApplyHandler