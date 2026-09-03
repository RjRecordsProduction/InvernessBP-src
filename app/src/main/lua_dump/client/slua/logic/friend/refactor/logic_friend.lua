local logic_friend = {}
function logic_friend:DefineAndResetData()
  self.refactor_friendlist = nil
end
function logic_friend:RefactorAddOrDeleteFriend(uid, bIsAdd)
  log(bWriteLog and string.format("logic_friend:AddOrDeleteFriend %s bIsAdd=%s", uid, bIsAdd))
  if not self.refactor_friendlist or not next(self.refactor_friendlist) then
    return
  end
  uid = tonumber(uid)
  if not uid then
    return
  end
  if bIsAdd then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsInnerFriend(uid) then
      return
    end
    local data = LogicFriend.GetFriendData(uid) or {}
    data.    data.intimacy = 0
    local TimeUtil = require("client.common.time_util")
    data.create_time = TimeUtil.GetServerTimeInSec()
    self.refactor_friendlist.inner_list[uid] = data
  else
    if self.refactor_friendlist.inner_list then
      self.refactor_friendlist.inner_list[uid] = nil
    end
    if self.refactor_friendlist.plat_list then
      self.refactor_friendlist.plat_list[uid] = nil
    end
  end
end
function logic_friend:GetFriendData()
  return self.refactor_friendlist
end
function logic_friend:proc_get_all_friendlist_rsp(friendlist)
  local TableUtil = require("common.table_util")
  self.refactor_friendlist = TableUtil.CopyTable(friendlist)
end
function logic_friend:proc_del_inner_friend_batch_rsp(res, friendUidList)
  log(bWriteLog and "LogicFriend.del_inner_friend_batch_rsp:" .. res)
  if res ~= NetErrorCode_NONE then
    return
  end
  local isDelMap = {}
  for k, v in pairs(friendUidList or {}) do
    self:RefactorAddOrDeleteFriend(v, false)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_friend)