local intimacy_visible_switchs_tool = {
  EVisibleSwitchType = {
    Hide = 0,
    Visible = 1,
    Visible_Frind = 2
  }
}
function intimacy_visible_switchs_tool.GetTotalVisibleSwitchs(uid)
  log(bWriteLog and "intimacy_visible_switchs_tool.GetTotalVisibleSwitchs uid = " .. uid)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  if logic_friend_intimacy.resIntimacyInfoMap == nil or not logic_friend_intimacy.resIntimacyInfoMap[uid] then
    return nil
  end
  if logic_friend_intimacy.resIntimacyInfoMap[uid].visible_switchs == nil then
    return nil
  end
  if logic_friend_intimacy.resIntimacyInfoMap[uid].visible_switchs[0] == intimacy_visible_switchs_tool.EVisibleSwitchType.Hide then
    return nil
  end
  return logic_friend_intimacy.resIntimacyInfoMap[uid].visible_switchs[0]
end
function intimacy_visible_switchs_tool.GetRelationVisibleSwitchs(uid, relation)
  log(bWriteLog and "intimacy_visible_switchs_tool.GetRelationVisibleSwitchs uid = " .. tostring(uid) .. " relation = " .. tostring(relation))
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  if logic_friend_intimacy.resIntimacyInfoMap == nil or not logic_friend_intimacy.resIntimacyInfoMap[uid] then
    return false
  end
  if logic_friend_intimacy.resIntimacyInfoMap[uid].visible_switchs == nil then
    return false
  end
  if logic_friend_intimacy.resIntimacyInfoMap[uid].visible_switchs[0] == intimacy_visible_switchs_tool.EVisibleSwitchType.Hide or logic_friend_intimacy.resIntimacyInfoMap[uid].visible_switchs[0] == nil then
    return false
  end
  return logic_friend_intimacy.resIntimacyInfoMap[uid].visible_switchs[relation]
end
function intimacy_visible_switchs_tool.GetVisiblePlayer(uid)
  log(bWriteLog and "intimacy_visible_switchs_tool.GetVisiblePlayer uid = " .. uid)
  local playerUid = tonumber(uid)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  if not logic_friend_intimacy.resIntimacyInfoMap or not logic_friend_intimacy.resIntimacyInfoMap[playerUid] then
    return false
  end
  local visible_switchs = logic_friend_intimacy.resIntimacyInfoMap[playerUid].visible_switchs
  if visible_switchs == nil then
    return false
  end
  if visible_switchs[0] == nil or visible_switchs[0] == intimacy_visible_switchs_tool.EVisibleSwitchType.Hide then
    return false
  end
  local self_uid = tonumber(DataMgr.roleData.uid)
  local relation = logic_friend_intimacy:GetIntimacyType(self_uid, playerUid)
  if visible_switchs[0] == intimacy_visible_switchs_tool.EVisibleSwitchType.Visible then
    return intimacy_visible_switchs_tool.CheckAllRelation(visible_switchs)
  elseif visible_switchs[0] == intimacy_visible_switchs_tool.EVisibleSwitchType.Visible_Frind then
    local friendInfo = logic_friend_list:GetFriendInfo(playerUid)
    if friendInfo then
      return true
    else
      return false
    end
  elseif visible_switchs[0] == true then
    if visible_switchs[relation] ~= nil then
      return visible_switchs[relation]
    else
      return true
    end
  else
    return false
  end
end
function intimacy_visible_switchs_tool.CheckAllRelation(visible_switchs)
  local bAllClose = false
  for i = 1, #visible_switchs do
    if visible_switchs[i] == true then
      return true
    end
  end
  log(bWriteLog and "intimacy_visible_switchs_tool.CheckAllRelation bAllClose = " .. tostring(bAllClose))
  return bAllClose
end
return intimacy_visible_switchs_tool