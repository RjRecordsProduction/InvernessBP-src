local NetManager = require("client.network.comm.NetManager")
local FriendApplyBattleHandler = {}
function FriendApplyBattleHandler.send_please_add_me_as_friend_req(list)
  NetManager.SendPkg(1124912776, list)
end
function FriendApplyBattleHandler.on_please_add_me_as_friend_resp(frd_uid)
  local logic_friend_apply_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply_battle)
  logic_friend_apply_battle:proc_please_add_me_as_friend_resp(frd_uid)
end
function FriendApplyBattleHandler.send_will_add_you_as_friend_req(uid, gameid)
  NetManager.SendPkg(1109207350, uid, gameid)
end
function FriendApplyBattleHandler.on_add_inner_friend_op_rsp(res, friUid, op)
  if res == NetErrorCode_NONE and op == 1 then
    local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
    logic_friend:RefactorAddOrDeleteFriend(friUid, true)
    local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
    logic_friend_list:proc_add_inner_friend(friUid)
  end
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:proc_add_inner_friend_op_rsp(res, friUid, op)
end
return FriendApplyBattleHandler