local logic_friend_group_compare = {}
function logic_friend_group_compare.Sort_TeamMode(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_TeamMode")
  if a.online ~= b.online then
    if a.online == 1 and b.online == 0 then
      return true
    elseif a.online == 0 and b.online == 1 then
      return false
    end
  end
  if a.lastOnlineTime and b.lastOnlineTime then
    return a.lastOnlineTime > b.lastOnlineTime
  elseif a.lastOnlineTime and not b.lastOnlineTime then
    return true
  else
    return false
  end
end
function logic_friend_group_compare.Sort_FriendTime(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_FriendTime")
  if a.online ~= b.online then
    if a.online == 1 and b.online == 0 then
      return true
    elseif a.online == 0 and b.online == 1 then
      return false
    end
  end
  if a.create_time and b.create_time then
    return a.create_time > b.create_time
  end
  if a.create_time and not b.create_time then
    return true
  end
  return false
end
function logic_friend_group_compare.Sort_TeamMateTime(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_TeamMateTime")
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactDataA = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(a.uid)
  local interactDataB = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(b.uid)
  if a.online ~= b.online then
    if a.online == 1 and b.online == 0 then
      return true
    elseif a.online == 0 and b.online == 1 then
      return false
    end
  end
  if interactDataA and interactDataB then
    if interactDataA.recent_play_date and interactDataB.recent_play_date then
      return interactDataA.recent_play_date > interactDataB.recent_play_date
    elseif interactDataA.recent_play_date and not interactDataB.recent_play_date then
      return true
    elseif not interactDataA.recent_play_date and interactDataB.recent_play_date then
      return false
    end
  elseif interactDataA and not interactDataB then
    return true
  elseif not interactDataA and interactDataB then
    return false
  end
  if a.lastOnlineTime and b.lastOnlineTime then
    return a.lastOnlineTime > b.lastOnlineTime
  elseif a.lastOnlineTime then
    return true
  elseif b.lastOnlineTime then
    return false
  end
end
function logic_friend_group_compare.Sort_Intimacy(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_Intimacy")
  if a.intimacy == b.intimacy then
    if a.online ~= b.online then
      if a.online == 1 and b.online == 0 then
        return true
      elseif a.online == 0 and b.online == 1 then
        return false
      end
    end
    return a.lastOnlineTime > b.lastOnlineTime
  end
  if a.online ~= b.online then
    if a.online == 1 and b.online == 0 then
      return true
    elseif a.online == 0 and b.online == 1 then
      return false
    end
  end
  return a.intimacy > b.intimacy
end
function logic_friend_group_compare.Sort_FriendSource(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_FriendSource")
  if a.sourceMappingID == 0 or b.sourceMappingID == 0 or a.sourceMappingID == b.sourceMappingID then
    if a.online ~= b.online then
      if a.online == 1 and b.online == 0 then
        return true
      elseif a.online == 0 and b.online == 1 then
        return false
      end
    end
    return a.lastOnlineTime > b.lastOnlineTime
  end
  return a.lastOnlineTime > b.lastOnlineTime
end
function logic_friend_group_compare.Sort_RecentTeamMode(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_RecentTeamMode")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if not statusA then
    return false
  elseif not statusB then
    return true
  end
  if statusA.online ~= statusB.online then
    if statusA.online == 1 and statusB.online == 0 then
      return true
    elseif statusA.online == 0 and statusB.online == 1 then
      return false
    end
  end
  if a.interactData and a.interactData.newestInteractTime and b.interactData and b.interactData.newestInteractTime then
    return a.interactData.newestInteractTime > b.interactData.newestInteractTime
  end
  return false
end
function logic_friend_group_compare.Sort_MakeRecentTime(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_MakeRecentTime")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if statusA.online ~= statusB.online then
    if statusA.online == 1 and statusB.online == 0 then
      return true
    elseif statusA.online == 0 and statusB.online == 1 then
      return false
    end
  end
  if a.interactData.oldestKnowTime and b.interactData.oldestKnowTime then
    return a.interactData.oldestKnowTime > b.interactData.oldestKnowTime
  end
  return false
end
function logic_friend_group_compare.Sort_NewestInteract(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_NewestInteract")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if statusA.online ~= statusB.online then
    if statusA.online == 1 and statusB.online == 0 then
      return true
    elseif statusA.online == 0 and statusB.online == 1 then
      return false
    end
  end
  if a.interactData.newestInteractTime and b.interactData.newestInteractTime then
    return a.interactData.newestInteractTime > b.interactData.newestInteractTime
  end
  return false
end
function logic_friend_group_compare.Sort_RecentReason(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_RecentReason")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if statusA.online ~= statusB.online then
    if statusA.online == 1 and statusB.online == 0 then
      return true
    elseif statusA.online == 0 and statusB.online == 1 then
      return false
    end
  end
  if a.interactData.newestInteractTime and b.interactData.newestInteractTime then
    return a.interactData.newestInteractTime > b.interactData.newestInteractTime
  end
  return false
end
function logic_friend_group_compare.Sort_Default(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_Default")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if not statusA or not statusB then
    return false
  end
  if statusA.online ~= statusB.online then
    if statusA.online == 1 and statusB.online == 0 then
      return true
    elseif statusA.online == 0 and statusB.online == 1 then
      return false
    end
  end
  if not a.interactData or not b.interactData then
    return false
  end
  if a.interactData.newestInteractTime and b.interactData.newestInteractTime then
    return a.interactData.newestInteractTime > b.interactData.newestInteractTime
  end
  return false
end
function logic_friend_group_compare.Sort_Mode(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_Mode")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if statusA and statusB and statusA.online ~= statusB.online then
    if statusA.online == 1 and statusB.online == 0 then
      return true
    elseif statusA.online == 0 and statusB.online == 1 then
      return false
    end
  end
  if a.intimacy and b.intimacy and a.intimacy ~= b.intimacy then
    return a.intimacy > b.intimacy
  end
  if a.lastOnlineTime and b.lastOnlineTime and a.lastOnlineTime ~= b.lastOnlineTime then
    return a.lastOnlineTime > b.lastOnlineTime
  end
  if a.level and b.level and a.level ~= b.level then
    return a.level > b.level
  end
  return false
end
function logic_friend_group_compare.Sort_Interact(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_Interact")
  if not a.interact or not b.interact then
    log(bWriteLog and "logic_friend_group_compare.Sort_Interact failed due to nil")
    return false
  end
  if a.interact == b.interact then
    if a.online ~= b.online then
      if a.online == 1 and b.online == 0 then
        return true
      elseif a.online == 0 and b.online == 1 then
        return false
      end
    end
    return a.lastOnlineTime > b.lastOnlineTime
  end
  if a.online ~= b.online then
    if a.online == 1 and b.online == 0 then
      return true
    elseif a.online == 0 and b.online == 1 then
      return false
    end
  end
  return a.interact > b.interact
end
function logic_friend_group_compare.Sort_Return(a, b)
  log(bWriteLog and "logic_friend_group_compare.Sort_RecentReason")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if statusA and statusB and statusA.online ~= statusB.online then
    if statusA.online == 1 and statusB.online == 0 then
      return true
    elseif statusA.online == 0 and statusB.online == 1 then
      return false
    end
  end
  if a.lastOnlineTime and b.lastOnlineTime and a.lastOnlineTime ~= b.lastOnlineTime then
    return a.lastOnlineTime > b.lastOnlineTime
  end
end
return logic_friend_group_compare