local logic_friend_list = {}
function logic_friend_list:OnInitialize()
  log(bWriteLog and "logic_friend_list:OnInitialize")
  self.res_friendlist = nil
  self.res_set_status_data = nil
  self.status_week_left_times = 3
end
function logic_friend_list:OnDestroy()
  log(bWriteLog and "logic_friend_list:OnDestroy")
end
function logic_friend_list:proc_get_all_friendlist_rsp(friendlist, rejoin_switch, set_status_data)
  log(bWriteLog and "logic_friend_list:proc_get_all_friendlist_rsp")
  self.res_  self.res_  self.status_week_left_times = set_status_data.total_week_times - set_status_data.week_times
end
function logic_friend_list:proc_on_get_intimacy_relation_rsp(list)
  log(bWriteLog and "logic_friend_list:proc_on_get_intimacy_relation_rsp")
  if self.res_friendlist == nil then
    return
  end
  if list == nil then
    return
  end
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  for uid, v in pairs(list) do
    local friendInfo = self.res_friendlist.plat_list[uid]
    if friendInfo == nil then
      friendInfo = self.res_friendlist.inner_list[uid]
    end
    if friendInfo then
      if v.state == logic_friend_intimacy.EStateType.None then
        friendInfo.state = v.state
      elseif v.state == logic_friend_intimacy.EStateType.Has_Send then
        friendInfo.state = v.state
      elseif v.state == logic_friend_intimacy.EStateType.Wait_Confirm then
        friendInfo.state = v.state
      elseif v.state == logic_friend_intimacy.EStateType.Has_Delete then
        friendInfo.state = v.state
      elseif v.state == logic_friend_intimacy.EStateType.Has_Build then
        friendInfo.state = v.state
        friendInfo.intimacy = v.intimacy
      end
    end
  end
end
function logic_friend_list:proc_build_intimacy_relation_rsp(friUid, relation)
  log(bWriteLog and "logic_friend_list:proc_build_intimacy_relation_rsp")
  local friendInfo = self:GetFriendInfo(friUid)
  if friendInfo == nil then
    return
  end
  log(bWriteLog and "logic_friend_list:proc_build_intimacy_relation_rsp 2")
  local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
  friendInfo.state = IntimacyConst.EStateType.Has_Send
end
function logic_friend_list:proc_cancel_build_intimacy_relation_rsp(friUid)
  log(bWriteLog and "logic_friend_list:proc_cancel_build_intimacy_relation_rsp")
  local friendInfo = self:GetFriendInfo(friUid)
  if friendInfo == nil then
    return
  end
  log(bWriteLog and "logic_friend_list:proc_build_intimacy_relation_rsp 2")
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  friendInfo.state = logic_friend_intimacy.EStateType.None
end
function logic_friend_list:proc_delete_intimacy_relation_rsp(friUid)
  log(bWriteLog and "logic_friend_list:proc_delete_intimacy_relation_rsp")
  local friendInfo = self:GetFriendInfo(friUid)
  if friendInfo == nil then
    return
  end
  log(bWriteLog and "logic_friend_list:proc_delete_intimacy_relation_rsp 2")
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  friendInfo.state = logic_friend_intimacy.EStateType.Has_Delete
end
function logic_friend_list:proc_notify_friend_intimacy_chg(friUid, chg, newIntimacy, extraInfo, weekSummaryInfo)
  log(bWriteLog and "logic_friend_list:proc_notify_friend_intimacy_chg")
  local info = self:GetFriendInfo(friUid)
  if info == nil then
    return
  end
  log(bWriteLog and "logic_friend_list:proc_notify_friend_intimacy_chg 2")
  info.intimacy = newIntimacy
  if weekSummaryInfo then
    info.last_week_end_intimacy = weekSummaryInfo.last_week_end_intimacy
    info.intimacy_last_week_inc_total = weekSummaryInfo.last_week_inc_total
  end
end
function logic_friend_list:proc_interact_key_event_notify(frd_uid, change_type, value, para1, para2, weekSummaryInfo)
  log(bWriteLog and "logic_friend_list:proc_interact_key_event_notify")
  local info = self:GetFriendInfo(frd_uid)
  if info == nil then
    return
  end
  log(bWriteLog and "logic_friend_list:proc_interact_key_event_notify 2")
  if weekSummaryInfo then
    info.last_week_inc_total = weekSummaryInfo.last_week_inc_total
    info.last_week_end_score = weekSummaryInfo.last_week_end_score
  end
end
function logic_friend_list:proc_add_black_list_rsp(frd_uid)
  log(bWriteLog and "logic_friend_list:proc_add_black_list_rsp frd_uid = " .. tostring(frd_uid))
  self:DeleteFriend(frd_uid)
end
function logic_friend_list:proc_get_black_list_rsp(blacklist)
  log(bWriteLog and "logic_friend_list:proc_get_black_list_rsp ")
  for _, uid in pairs(blacklist) do
    self:DeleteFriend(uid)
  end
end
function logic_friend_list:proc_add_inner_friend(frduid)
  log(bWriteLog and string.format("logic_friend_list:proc_add_inner_friend %s ", frduid))
  frduid = tonumber(frduid)
  if not frduid then
    log(bWriteLog and string.format("logic_friend_list:proc_add_inner_friend frduid = nil "))
    return
  end
  if self:GetFriendInfo(frduid) then
    log(bWriteLog and string.format("logic_friend_list:proc_add_inner_friend target has been added "))
    return
  end
  local data = {}
  data.uid = frduid
  data.intimacy = 0
  local TimeUtil = require("client.common.time_util")
  data.create_time = TimeUtil.GetServerTimeInSec()
  if self.res_friendlist then
    self.res_friendlist.inner_list[frduid] = data
  else
    log(bWriteLog and "logic_friend_list:proc_add_inner_friend res_friendlist = nil")
  end
end
function logic_friend_list:proc_del_inner_friend_batch_rsp(res, friendUidList)
  log(bWriteLog and "logic_friend_list.del_inner_friend_batch_rsp:" .. res)
  if res ~= NetErrorCode_NONE then
    return
  end
  for k, v in pairs(friendUidList or {}) do
    self:DeleteFriend(v)
  end
end
function logic_friend_list:proc_del_inner_friend_rsp(uid)
  log(bWriteLog and "logic_friend_list.del_inner_friend_batch_rsp: uid = " .. tostring(uid))
  self:DeleteFriend(uid)
end
function logic_friend_list:GetFriendInfo(uid)
  log(bWriteLog and "logic_friend_list:GetFriendInfo uid = " .. tostring(uid))
  local numuid = tonumber(uid)
  if self.res_friendlist == nil then
    return nil
  end
  local info
  if self.res_friendlist.inner_list and next(self.res_friendlist.inner_list) and self.res_friendlist.inner_list[numuid] then
    info = self.res_friendlist.inner_list[numuid]
    return info
  end
  if self.res_friendlist.plat_list and next(self.res_friendlist.plat_list) and self.res_friendlist.plat_list[numuid] then
    info = self.res_friendlist.plat_list[numuid]
  end
  return info
end
function logic_friend_list:GetIntimacy(uid)
  local info = self:GetFriendInfo(uid)
  if info == nil then
    return 0
  end
  return info.intimacy or 0
end
function logic_friend_list:GetLastWeekRiseIntimacy(uid)
  local info = self:GetFriendInfo(uid)
  if info == nil then
    return 0
  end
  return info.intimacy_last_week_inc_total or 0
end
function logic_friend_list:GetFriendInfoMap()
  if self.res_friendlist then
    local platlist = self.res_friendlist.plat_list
    local innerlist = self.res_friendlist.inner_list
    local combinedMap = {}
    if platlist == nil or next(platlist) == nil then
      log(bWriteLog and "logic_friend_list:GetFriendList platlist = nil")
    else
      for uid, v in pairs(platlist) do
        combinedMap[uid] = v
      end
    end
    if innerlist == nil or next(innerlist) == nil then
      log(bWriteLog and "logic_friend_list:GetFriendList innerlist = nil")
    else
      for uid, v in pairs(innerlist) do
        combinedMap[uid] = v
      end
    end
    return combinedMap
  else
    log(bWriteLog and "logic_friend_list:GetFriendInfoMap res_friendlist = nil")
  end
end
function logic_friend_list:GetFriendUidList()
  if not self.res_friendlist then
    log(bWriteLog and "logic_friend_list:GetFriendList res_friendlist = nil")
    return nil
  end
  local platlist = self.res_friendlist.plat_list
  local innerlist = self.res_friendlist.inner_list
  local combinedList = {}
  if platlist == nil or next(platlist) == nil then
    log(bWriteLog and "logic_friend_list:GetFriendList platlist = nil")
  else
    for uid, v in pairs(platlist) do
      combinedList[#combinedList + 1] = uid
    end
  end
  if innerlist == nil or next(innerlist) == nil then
    log(bWriteLog and "logic_friend_list:GetFriendList innerlist = nil")
  else
    for uid, v in pairs(innerlist) do
      combinedList[#combinedList + 1] = uid
    end
  end
  return combinedList
end
function logic_friend_list:DeleteFriend(frd_uid)
  log(bWriteLog and "logic_friend_list:DeleteFriend frd_uid = " .. tostring(frd_uid))
  if self.res_friendlist then
    if self.res_friendlist.inner_list and self.res_friendlist.inner_list[frd_uid] then
      self.res_friendlist.inner_list[frd_uid] = nil
    elseif self.res_friendlist.plat_list and self.res_friendlist.plat_list[frd_uid] then
      self.res_friendlist.plat_list[frd_uid] = nil
    else
      log(bWriteLog and "logic_friend_list:DeleteFriend cant find frd_uid = " .. tostring(frd_uid))
    end
  else
    log(bWriteLog and "logic_friend_list:DeleteFriendres_friendlist = nil")
  end
end
local class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
return class(ModuleBase, nil, logic_friend_list)