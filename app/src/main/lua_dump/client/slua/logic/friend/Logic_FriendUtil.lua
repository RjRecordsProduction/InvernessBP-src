local Logic_FriendUtil = {}
function Logic_FriendUtil.MakeFriendInfo(sUId)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local tFriendData = logic_profile:GetLocalProfile(sUId)
  local nSex = logic_profile:GetRoleSexByUid(sUId)
  if not tFriendData then
    return nil
  end
  local tTempData = {
    gid = sUId,
    uid = sUId,
    picUrl = tFriendData.picUrl,
    sex = nSex,
    cur_avatar_box_id = tFriendData.cur_avatar_box_id,
    level = tFriendData.level,
    nickName = tFriendData.nickName,
    isSameClient = FuncUtil.JudgeIsSameClient(sUId),
    platName = tFriendData.platName,
    intimacy = LogicFriend.GetInnerFriendIntimacy(sUId),
    upass = tFriendData.upass
  }
  return tTempData
end
return Logic_FriendUtil