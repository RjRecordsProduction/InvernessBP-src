local logic_friend_intimacy = {
  EStateType = {
    None = 0,
    Has_Send = 1,
    Wait_Confirm = 2,
    Has_Delete = 3,
    Has_Build = 4
  },
  EIntimacyRelationType = {
    Bromance = 1,
    Lover = 2,
    Buddy = 3,
    BFF = 4,
    Family = 5,
    Bonding = 6
  }
}
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
function logic_friend_intimacy:OnInitialize()
  self.resIntimacyInfoMap = {}
  self.resPartnerInfoMap = {}
end
function logic_friend_intimacy:OnDestroy()
  self.resIntimacyInfoMap = {}
  self.resPartnerInfoMap = {}
end
function logic_friend_intimacy:proc_on_get_intimacy_relation_rsp(list, intimacy_partner_data, intimacy_reddot, visible_switchs, top_red_point_info)
  log(bWriteLog and "logic_friend_intimacy:proc_on_get_intimacy_relation_rsp")
  local myUid = tonumber(DataMgr.roleData.uid)
  if myUid == nil then
    return
  end
  self.resIntimacyInfoMap[myUid] = {
    list = list,
    intimacy_partner_data = intimacy_partner_data,
    intimacy_reddot = intimacy_reddot,
    visible_switchs = visible_switchs,
      }
  self.resPartnerInfoMap[myUid] = intimacy_partner_data
  self:update_soulmate_system_open()
end
function logic_friend_intimacy:proc_get_other_intimacy_relation_rsp(other_uid, list, visible_switchs, partner_uid)
  log(bWriteLog and "logic_friend_intimacy:proc_get_other_intimacy_relation_rsp")
  local myUid = tonumber(DataMgr.roleData.uid)
  if other_uid == myUid then
  else
    self.resIntimacyInfoMap[other_uid] = {
      list = list,
      intimacy_partner_data = nil,
      intimacy_reddot = nil,
      visible_switchs = visible_switchs,
      top_red_point_info = nil
    }
    self.resPartnerInfoMap[other_uid] = partner_uid
  end
end
function logic_friend_intimacy:proc_build_intimacy_relation_rsp(friUid, relation)
  log(bWriteLog and "logic_friend_intimacy:proc_build_intimacy_relation_rsp")
  local myUid = tonumber(DataMgr.roleData.uid)
  local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
  local success, friendInfo = self:UpdateIntimacyInfo(myUid, friUid, {
    param = relation,
    state = IntimacyConst.EStateType.Has_Send
  })
  if not success then
    printf("[ERROR] logic_friend_intimacy:proc_build_intimacy_relation_rsp update intimacy info failed. friUid: %s", friUid)
    return
  end
end
function logic_friend_intimacy:GetIntimacyType(uid, otherUid)
  log(bWriteLog and "logic_friend_intimacy:GetIntimacyType uid = " .. uid .. ", otherUid = " .. otherUid)
  uid = tonumber(uid)
  otherUid = tonumber(otherUid)
  local intimacyInfo = self.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return 0
  end
  local info = intimacyInfo.list[otherUid]
  if not info then
    return 0
  end
  local bMySelf = tonumber(DataMgr.roleData.uid) == uid
  if bMySelf then
    if info.state == logic_friend_intimacy.EStateType.Has_Build then
      return info.param
    else
      return 0
    end
  else
    return info.relation
  end
end
function logic_friend_intimacy:GetPartnerUid(uid)
  log(bWriteLog and "logic_friend_intimacy:GetPartnerUid uid = " .. uid)
  local partnerInfo = self.resPartnerInfoMap[uid]
  if not partnerInfo then
    return 0
  end
  local bMySelf = tonumber(DataMgr.roleData.uid) == uid
  if bMySelf then
    return partnerInfo.partner_uid
  else
    return partnerInfo or 0
  end
end
function logic_friend_intimacy:GetIntimacyInfo(uid, otherUid)
  uid = tonumber(uid)
  otherUid = tonumber(otherUid)
  local intimacyInfo = self.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return
  end
  return intimacyInfo.list[otherUid]
end
function logic_friend_intimacy:GetIntimacyMapByUid(uid)
  uid = tonumber(uid)
  local intimacyInfo = self.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return
  end
  return intimacyInfo.list
end
function logic_friend_intimacy:GetTargetIntimacyList(uid, relation)
  uid = tonumber(uid)
  local intimacyInfo = self.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return
  end
  local list = {}
  for k, v in pairs(intimacyInfo.list) do
    if uid == tonumber(DataMgr.roleData.uid) then
      if v.state == 4 and v.param == relation then
        list[k] = v
      end
    elseif v.relation == relation then
      list[k] = v
    end
  end
  return list
end
function logic_friend_intimacy:GetIntimacyCountByRelationAndState(uid, relation, state)
  uid = tonumber(uid)
  local isMySelf = tonumber(DataMgr.roleData.uid) == uid
  local intimacyInfo = self.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return 0
  end
  local cnt = 0
  if isMySelf then
    for k, v in pairs(intimacyInfo.list) do
      if v.param == relation and v.state == state then
        cnt = cnt + 1
      end
    end
  else
    for k, v in pairs(intimacyInfo.list) do
      if v.relation == relation then
        cnt = cnt + 1
      end
    end
  end
  return cnt
end
function logic_friend_intimacy:GetIntimacyRelationCount(uid, relation)
  uid = tonumber(uid)
  local isMySelf = tonumber(DataMgr.roleData.uid) == uid
  local intimacyInfo = self.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return 0
  end
  local cnt = 0
  if isMySelf then
    for k, v in pairs(intimacyInfo.list) do
      if v.state == 4 and v.param == relation then
        cnt = cnt + 1
      end
    end
  else
    for k, v in pairs(intimacyInfo.list) do
      if v.relation == relation then
        cnt = cnt + 1
      end
    end
  end
  return cnt
end
function logic_friend_intimacy:GetRelationCanBuildResult(targetUid, relation)
  targetUid = tonumber(targetUid)
  if relation <= 0 or relation > IntimacyConst.EIntimacyType.Max then
    return -1
  end
  if relation == IntimacyConst.EIntimacyType.Bonding then
    local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, IntimacyConst.EIntimacyType.Bonding)
    if 0 < cnt then
      printf("logic_friend_intimacy:GetRelationCanBuildResult -2 by self bonding")
      return 36
    end
    local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, IntimacyConst.EIntimacyType.Lover)
    if 0 < cnt then
      printf("logic_friend_intimacy:GetRelationCanBuildResult false by self lover")
      return 32
    end
    local cnt = self:GetIntimacyRelationCount(targetUid, IntimacyConst.EIntimacyType.Bonding)
    if 0 < cnt then
      printf("logic_friend_intimacy:GetRelationCanBuildResult false by target bonding")
      return 46
    end
    local cnt = self:GetIntimacyRelationCount(targetUid, IntimacyConst.EIntimacyType.Lover)
    if 0 < cnt then
      printf("logic_friend_intimacy:GetRelationCanBuildResult false by target lover")
      return 42
    end
  else
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local threshold = LogicFriend.Friend_Intimacy_Threshold
    local intimacy = LogicFriend.GetInnerFriendIntimacy(targetUid)
    if threshold > intimacy then
      return 1
    end
    local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
    local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, relation)
    local maxCnt = IntimacyUtils.GetRelationMaxCnt(relation)
    if cnt >= maxCnt then
      printf("logic_friend_intimacy:GetRelationCanBuildResult false by maxCnt")
      return 2
    end
    if relation == IntimacyConst.EIntimacyType.Lover then
      local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, IntimacyConst.EIntimacyType.Bonding)
      if 0 < cnt then
        printf("logic_friend_intimacy:GetRelationCanBuildResult false by self bonding")
        return 32
      end
    end
  end
  return 0
end
function logic_friend_intimacy:GetRelationCanChangeResult(targetUid, currentRelation, targetRelation)
  targetUid = tonumber(targetUid)
  if targetRelation <= 0 or targetRelation > IntimacyConst.EIntimacyType.Max then
    return -1
  end
  if targetRelation == IntimacyConst.EIntimacyType.Bonding then
    local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, IntimacyConst.EIntimacyType.Bonding)
    if 0 < cnt then
      printf("logic_friend_intimacy:GetRelationCanChangeResult false by self bonding")
      return 36
    end
    local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, IntimacyConst.EIntimacyType.Lover)
    if 0 < cnt and currentRelation ~= IntimacyConst.EIntimacyType.Lover then
      printf("logic_friend_intimacy:GetRelationCanChangeResult false by self lover")
      return 32
    end
    local cnt = self:GetIntimacyRelationCount(targetUid, IntimacyConst.EIntimacyType.Bonding)
    if 0 < cnt then
      printf("logic_friend_intimacy:GetRelationCanChangeResult false by target bonding")
      return 46
    end
    local cnt = self:GetIntimacyRelationCount(targetUid, IntimacyConst.EIntimacyType.Lover)
    if 0 < cnt and currentRelation ~= IntimacyConst.EIntimacyType.Lover then
      printf("logic_friend_intimacy:GetRelationCanChangeResult false by target lover")
      return 42
    end
  else
    local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, targetRelation)
    local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
    local maxCnt = IntimacyUtils.GetRelationMaxCnt(targetRelation)
    if cnt >= maxCnt then
      printf("logic_friend_intimacy:GetRelationCanChangeResult false by maxCnt, relation = %s, cnt = %s, maxCnt = %s", targetRelation, cnt, maxCnt)
      return 2
    end
    if targetRelation == IntimacyConst.EIntimacyType.Lover then
      local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, IntimacyConst.EIntimacyType.Bonding)
      if 0 < cnt then
        printf("logic_friend_intimacy:GetRelationCanChangeResult false by self bonding")
        return 36
      end
      local cnt = self:GetIntimacyRelationCount(DataMgr.roleData.uid, IntimacyConst.EIntimacyType.Lover)
      if 0 < cnt then
        printf("logic_friend_intimacy:GetRelationCanChangeResult false by self lover")
        return 32
      end
      local cnt = self:GetIntimacyRelationCount(targetUid, IntimacyConst.EIntimacyType.Bonding)
      if 0 < cnt then
        printf("logic_friend_intimacy:GetRelationCanChangeResult false by target bonding")
        return 46
      end
      local cnt = self:GetIntimacyRelationCount(targetUid, IntimacyConst.EIntimacyType.Lover)
      if 0 < cnt then
        printf("logic_friend_intimacy:GetRelationCanChangeResult false by target lover")
        return 42
      end
    end
  end
  return 0
end
function logic_friend_intimacy:UpdateIntimacyInfo(uid, otherUid, kvs)
  uid = tonumber(uid)
  otherUid = tonumber(otherUid)
  local intimacyInfo = self.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return false
  end
  local friendInfo = intimacyInfo.list[otherUid]
  if not friendInfo then
    friendInfo = {
      state = 0,
      param = 0,
      own_vow_id = 0,
      mate_vow_id = 0
    }
    intimacyInfo.list[otherUid] = friendInfo
  end
  if kvs then
    for k, v in pairs(kvs) do
      friendInfo[k] = v
    end
  end
  return true, friendInfo
end
function logic_friend_intimacy:proc_reply_intimacy_relation_rsp(friUid, relation, newIntimacyInfo)
  local myUid = tonumber(DataMgr.roleData.uid)
  local success, friendInfo = self:UpdateIntimacyInfo(myUid, friUid, newIntimacyInfo)
  if not success then
    printf("[ERROR] logic_friend_intimacy:proc_reply_intimacy_relation_rsp update intimacy info failed. friUid: %s", friUid)
    return
  end
  if relation == 6 then
    self:TryFetchMyProfile(true)
  end
end
function logic_friend_intimacy:proc_reply_change_intimacy_relation_rsp(friUid, relation, intimacy_info)
  local myUid = tonumber(DataMgr.roleData.uid)
  local success, friendInfo = self:UpdateIntimacyInfo(myUid, friUid, intimacy_info)
  if not success then
    printf("[ERROR] logic_friend_intimacy:proc_reply_change_intimacy_relation_rsp update intimacy info failed. friUid: %s", friUid)
    return
  end
  if relation == 6 then
    self:TryFetchMyProfile(true)
  end
end
function logic_friend_intimacy:TryFetchMyProfile(bPredictHasSoulmateSummary)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  local myUid = tonumber(DataMgr.roleData.uid)
  printf("logic_friend_intimacy:TryFetchMyProfile timer start. bPredictHasSoulmateSummary: %s", bPredictHasSoulmateSummary)
  self.soulmate_summary_update_timer = self:AddTimerLoop(1, function()
    logic_profile_get_wrap.GetNormalProfiles({myUid}, function()
      local profile = logic_profile:GetLocalProfile(myUid)
      if bPredictHasSoulmateSummary and profile.soulmate_summary then
        self:RemoveTimer(self.soulmate_summary_update_timer)
        self.soulmate_summary_update_timer = nil
        printf("logic_friend_intimacy:TryFetchMyProfile timer stop")
      elseif not bPredictHasSoulmateSummary and not profile.soulmate_summary then
        self:RemoveTimer(self.soulmate_summary_update_timer)
        self.soulmate_summary_update_timer = nil
        printf("logic_friend_intimacy:TryFetchMyProfile timer stop")
      else
        printf("logic_friend_intimacy:TryFetchMyProfile timer continue")
      end
    end, Enum_PROFILE_REPORT_CFG.PERSON_SPACE_INTIMACY, nil, true)
  end, 0, 1)
end
function logic_friend_intimacy:proc_notify_intimacy_relation_chg(friUid, state, param, rank_uid, other_params)
  local myUid = tonumber(DataMgr.roleData.uid)
  local intimacyInfo = self.resIntimacyInfoMap[myUid]
  if not intimacyInfo then
    return false
  end
  local oldFriendInfo = intimacyInfo.list[friUid]
  local oldState = oldFriendInfo and oldFriendInfo.state or 0
  local oldParam = oldFriendInfo and oldFriendInfo.param or 0
  local success, friendInfo = self:UpdateIntimacyInfo(myUid, friUid, other_params)
  if not success then
    printf("[ERROR] logic_friend_intimacy:proc_notify_intimacy_relation_chg update intimacy info failed. friUid: %s", friUid)
    return
  end
  friendInfo.  friendInfo.  if state == 4 and param == 6 then
    self:TryFetchMyProfile(true)
  elseif state == 3 and oldState == 4 and oldParam == 6 then
    self:TryFetchMyProfile(false)
  end
end
function logic_friend_intimacy:proc_cancel_change_intimacy_relation_rsp(friUid, change_type, param)
  local myUid = tonumber(DataMgr.roleData.uid)
  local success, friendInfo = self:UpdateIntimacyInfo(myUid, friUid, nil)
  if not success then
    printf("[ERROR] logic_friend_intimacy:proc_cancel_change_intimacy_relation_rsp update intimacy info failed. friUid: %s", friUid)
    return
  end
  friendInfo.state = 0
  friendInfo.mate_vow_id = 0
  friendInfo.own_vow_id = 0
end
function logic_friend_intimacy:proc_delete_intimacy_relation_rsp(friUid)
  local myUid = tonumber(DataMgr.roleData.uid)
  local success, friendInfo = self:UpdateIntimacyInfo(myUid, friUid, nil)
  if not success then
    printf("[ERROR] logic_friend_intimacy:proc_delete_intimacy_relation_rsp update intimacy info failed. friUid: %s", friUid)
    return
  end
  friendInfo.state = IntimacyConst.EStateType.Has_Delete
end
function logic_friend_intimacy:update_soulmate_system_open()
  local bSoulmateSystemOpen = false
  return bSoulmateSystemOpen
end
function logic_friend_intimacy:GetSoulmateSystemOpen()
  return self:update_soulmate_system_open()
end
local class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
return class(ModuleBase, nil, logic_friend_intimacy)