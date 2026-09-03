local friend_intimacy_net_tool = {}
local friend_intimacy_net_config = require("client.slua.logic.friend.Intimacy.friend_intimacy_net_config")
function friend_intimacy_net_tool.GetBuildInitmacyUidList(uid)
  log(bWriteLog and "friend_intimacy_net_tool.GetInitmacyUidList uid = " .. uid)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local intimacyInfo = logic_friend_intimacy.resIntimacyInfoMap[uid]
  if not intimacyInfo then
    return {}
  end
  local bMySelf = tonumber(DataMgr.roleData.uid) == uid
  local uidInfoList = {}
  if bMySelf then
    for k, v in pairs(intimacyInfo.list) do
      if v.state == logic_friend_intimacy.EStateType.Has_Build then
        uidInfoList[#uidInfoList + 1] = {
          uid = k,
          intimacy = v.intimacy or 0
        }
      end
    end
  else
    local intimacy_visible_switchs_tool = require("client.slua.logic.friend.Intimacy.intimacy_visible_switchs_tool")
    for k, v in pairs(intimacyInfo.list) do
      local relation = logic_friend_intimacy:GetIntimacyType(uid, k)
      if intimacy_visible_switchs_tool.GetRelationVisibleSwitchs(uid, relation) then
        uidInfoList[#uidInfoList + 1] = {
          uid = k,
          intimacy = v.intimacy or 0
        }
      end
    end
  end
  table.sort(uidInfoList, function(a, b)
    if a.intimacy < b.intimacy then
      return false
    elseif a.intimacy > b.intimacy then
      return true
    else
      return a.uid < b.uid
    end
  end)
  return uidInfoList
end
function friend_intimacy_net_tool.GetIntimacyRiseUidList(uidMap)
  log(bWriteLog and "friend_intimacy_net_tool.GetIntimacyRiseUidList")
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  local res_friendlist = logic_friend_list.res_friendlist
  local friendlist = logic_friend_list:GetFriendInfoMap()
  if friendlist == nil then
    return {}
  end
  local uidInfoList = {}
  for uid, v in pairs(friendlist) do
    if uidMap[uid] == nil and res_friendlist.interact_info_list[uid] then
      local compare_interactInfo = res_friendlist.interact_info_list[uid]
      if v.intimacy_last_week_inc_total and v.intimacy_last_week_inc_total > 200 and compare_interactInfo.last_week_inc_total and compare_interactInfo.last_week_inc_total > 18 then
        uidInfoList[#uidInfoList + 1] = {
          uid = uid,
          uidLevel = 1,
          intimacy_last_week_inc_total = v.intimacy_last_week_inc_total
        }
      elseif v.intimacy_last_week_inc_total and v.intimacy_last_week_inc_total > 100 and compare_interactInfo.last_week_inc_total and compare_interactInfo.last_week_inc_total > 9 then
        uidInfoList[#uidInfoList + 1] = {
          uid = uid,
          uidLevel = 2,
          intimacy_last_week_inc_total = v.intimacy_last_week_inc_total
        }
      elseif v.intimacy_last_week_inc_total and v.intimacy_last_week_inc_total > 50 and compare_interactInfo.last_week_inc_total and compare_interactInfo.last_week_inc_total > 3 then
        uidInfoList[#uidInfoList + 1] = {
          uid = uid,
          uidLevel = 3,
          intimacy_last_week_inc_total = v.intimacy_last_week_inc_total
        }
      end
    end
  end
  table.sort(uidInfoList, function(a, b)
    if a.uidLevel < b.uidLevel then
      return true
    elseif a.uidLevel > b.uidLevel then
      return false
    elseif a.intimacy_last_week_inc_total < b.intimacy_last_week_inc_total then
      return false
    elseif a.intimacy_last_week_inc_total > b.intimacy_last_week_inc_total then
      return true
    else
      return a.uid < b.uid
    end
  end)
  return uidInfoList
end
function friend_intimacy_net_tool.GetUidList(uid)
  log(bWriteLog and "friend_intimacy_net_tool.GetUidList uid = " .. uid)
  local bMySelf = tonumber(DataMgr.roleData.uid) == uid
  local uidInfoList = friend_intimacy_net_tool.GetBuildInitmacyUidList(uid)
  log_tree("uidInfoList = ", uidInfoList)
  if #uidInfoList >= friend_intimacy_net_config.HeadNumMax or bMySelf == false then
    table.sort(uidInfoList, function(a, b)
      if a.intimacy < b.intimacy then
        return false
      elseif a.intimacy > b.intimacy then
        return true
      else
        return a.uid < b.uid
      end
    end)
    return uidInfoList
  end
  local uidMap = {}
  for k, v in pairs(uidInfoList) do
    uidMap[v.uid] = true
  end
  local riseUidInfoList = friend_intimacy_net_tool.GetIntimacyRiseUidList(uidMap)
  log_tree("riseUidInfoList = ", riseUidInfoList)
  local lackNum = friend_intimacy_net_config.HeadNumMax - #uidInfoList
  local lastList = {}
  for i = 1, #uidInfoList do
    lastList[#lastList + 1] = uidInfoList[i]
  end
  for i = 1, lackNum do
    lastList[#lastList + 1] = riseUidInfoList[i]
  end
  log_tree("lastList = ", lastList)
  return lastList
end
function friend_intimacy_net_tool.IsPartner(uid, otherUid)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local partnerInfo = logic_friend_intimacy.resPartnerInfoMap[uid]
  if partnerInfo == nil then
    return false
  end
  local bMySelf = tonumber(DataMgr.roleData.uid) == uid
  if bMySelf then
    return partnerInfo.partner_uid == otherUid
  else
    return partnerInfo == otherUid
  end
end
function friend_intimacy_net_tool.IsJoint(uid, otherUid)
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(uid)
  if homeProfile == nil then
    return false
  end
  if homeProfile.joint_members == nil then
    return false
  end
  for jointUid, v in pairs(homeProfile.joint_members) do
    if jointUid == otherUid then
      return true
    end
  end
  return false
end
function friend_intimacy_net_tool.IsInteract(uid, otherUid)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  local res_rela_frd_list = logic_person_relation.res_rela_frd_list
  if res_rela_frd_list == nil then
    return false
  end
  for k, interactUid in pairs(res_rela_frd_list) do
    if interactUid == otherUid then
      return true
    end
  end
  return false
end
function friend_intimacy_net_tool.GetIconPath(uid, otherUid)
  log(bWriteLog and "friend_intimacy_net_tool.GetIconPath uid = " .. uid .. ", otherUid = " .. otherUid)
  if friend_intimacy_net_tool.IsPartner(uid, otherUid) then
    log(bWriteLog and "friend_intimacy_net_tool.GetIconPath 1")
    return friend_intimacy_net_config.headIconPathList[1]
  end
  if friend_intimacy_net_tool.IsJoint(uid, otherUid) then
    log(bWriteLog and "friend_intimacy_net_tool.GetIconPath 2")
    return friend_intimacy_net_config.headIconPathList[2]
  end
  if friend_intimacy_net_tool.IsInteract(uid, otherUid) then
    log(bWriteLog and "friend_intimacy_net_tool.GetIconPath 3")
    return friend_intimacy_net_config.headIconPathList[3]
  end
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local intimacyType = logic_friend_intimacy:GetIntimacyType(uid, otherUid)
  log(bWriteLog and "friend_intimacy_net_tool.GetIconPath intimacyType = " .. intimacyType)
  if intimacyType == 0 then
    return ""
  end
  local logic_intimacy_award = require("client.slua.logic.person_space.logic_intimacy_award")
  local iconPath = logic_intimacy_award.GetInitimacyIcon_other_new(intimacyType)
  return iconPath
end
return friend_intimacy_net_tool