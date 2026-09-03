local NetManager = require("client.network.comm.NetManager")
local FriendBlacklistHandler = {}
function FriendBlacklistHandler.send_get_black_list_req()
  log(bWriteLog and "FriendBlacklistHandler.send_get_black_list_req")
  NetManager.SendPkg(582743719)
end
function FriendBlacklistHandler.on_get_black_list_rsp(res, uid, blacklist, other_blacklist)
  log(bWriteLog and "FriendBlacklistHandler.on_get_black_list_rsp res:" .. res)
  if res ~= NetErrorCode_NONE then
    return
  end
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  if blacklist then
    log_tree("FriendBlacklistHandler.on_get_black_list_rsp blacklist = ", blacklist)
    logic_friend_blacklist:proc_get_black_list_rsp(blacklist)
    local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
    logic_friend_list:proc_get_black_list_rsp(blacklist)
  end
  if other_blacklist then
    log_tree("FriendBlacklistHandler.on_get_black_list_rsp other_blacklist = ", other_blacklist)
    logic_friend_blacklist:proc_get_byblack_list_rsp(other_blacklist)
  end
end
function FriendBlacklistHandler.send_add_black_list_req(friUid, add_black_scene, extend_info)
  log(bWriteLog and "FriendBlacklistHandler.send_add_black_list_req friUid = " .. tostring(friUid) .. " add_black_scene = " .. tostring(add_black_scene))
  NetManager.SendPkg(2023865351, friUid, add_black_scene, extend_info)
end
function FriendBlacklistHandler.on_add_black_list_rsp(res, friUid)
  log(bWriteLog and "FriendBlacklistHandler.on_add_black_list_rsp res: " .. res .. " : " .. friUid)
  if res == "fri_repeat" then
    ShowNotice(200009)
    return
  end
  if res == "fri_list_full" then
    ShowNotice(200012)
    return
  end
  if res == "fri_not_exist" then
    ShowNotice(200013)
    return
  end
  if res ~= NetErrorCode_NONE then
    return
  end
  ShowNotice(773332)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  logic_friend_blacklist:proc_add_black_list_rsp(friUid)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_add_black_list_rsp(friUid)
end
function FriendBlacklistHandler.send_del_black_list_req(friUid)
  log(bWriteLog and "FriendBlacklistHandler.send_del_black_list_req friUid = " .. friUid)
  NetManager.SendPkg(1307257607, friUid)
end
function FriendBlacklistHandler.on_del_black_list_rsp(res, friUid)
  log(bWriteLog and string.format("FriendBlacklistHandler.on_del_black_list_rsp res:%s friUid:%s", res, tostring(friUid)))
  if res ~= NetErrorCode_NONE then
    return
  end
  local logic_match_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  logic_match_blacklist:proc_del_black_list_rsp(friUid)
end
function FriendBlacklistHandler.send_get_match_black_list_req()
  log(bWriteLog and "FriendBlacklistHandler.send_get_match_black_list_req")
  NetManager.SendPkg(1276567015)
end
function FriendBlacklistHandler.on_get_match_black_list_rsp(res, black_list)
  log(bWriteLog and "FriendBlacklistHandler.on_get_match_black_list_rsp res:" .. tostring(res))
  local logic_match_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_match_blacklist)
  logic_match_blacklist:on_get_match_black_list_rsp(res, black_list)
end
function FriendBlacklistHandler.send_add_match_black_list_req(black_uid, scene_id)
  log(bWriteLog and "FriendBlacklistHandler.send_add_match_black_list_req black_uid = " .. tostring(black_uid) .. " scene_id = " .. tostring(scene_id))
  NetManager.SendPkg(1492423783, black_uid, scene_id)
end
function FriendBlacklistHandler.on_add_match_black_list_rsp(res, black_uid, black_list)
  log(bWriteLog and "FriendBlacklistHandler.on_add_match_black_list_rsp res:" .. tostring(res) .. " black_uid " .. tostring(black_uid))
  local logic_match_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_match_blacklist)
  logic_match_blacklist:on_add_match_black_list_rsp(res, black_uid, black_list)
end
function FriendBlacklistHandler.send_del_match_black_list_req(black_uid)
  log(bWriteLog and "FriendBlacklistHandler.on_del_match_black_list_rsp black_uid" .. tostring(black_uid))
  NetManager.SendPkg(950204071, black_uid)
end
function FriendBlacklistHandler.on_del_match_black_list_rsp(res, black_uid, black_list)
  log(bWriteLog and "FriendBlacklistHandler.on_del_match_black_list_rsp res" .. tostring(res) .. " black_uid " .. tostring(black_uid))
  local logic_match_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_match_blacklist)
  logic_match_blacklist:on_del_match_black_list_rsp(res, black_uid, black_list)
end
function FriendBlacklistHandler.on_add_black_change_notify(friUid, is_add_black)
  log(bWriteLog and "FriendBlacklistHandler.on_add_black_change_notify uid" .. tostring(friUid) .. " is_add_black " .. tostring(is_add_black))
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  logic_friend_blacklist:proc_add_black_change_notify(friUid, is_add_black)
end
return FriendBlacklistHandler