local logic_friend_group = {}
local friend_macros = require("client.slua.logic.friend.friend_macros")
local C_TEMP = "temp"
local C_FriendListDataType = {PureList = 1, WithTitle = 2}
function logic_friend_group:DefineAndResetData()
  self:_InitConfig()
  self:_InitFuncMap()
  self.ListItemType = friend_macros.E_ListItemType
  self.currentSelectGroupList = {}
  self.bFoldingFirstGroup = false
  self.currentListNum = 0
  self.WowOpenOffline = false
end
function logic_friend_group:_IsTeamModeMatch(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_IsTeamModeMatch groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsTeamModeMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local friendUID = friendData.uid
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactData = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(friendUID)
  local bInCondition = false
  local hasData = interactData and interactData.group_id_list and next(interactData.group_id_list)
  if not param1 then
    bInCondition = not hasData
  else
    local teamTime = hasData and interactData.group_id_list[param1] or 0
    if 0 < teamTime then
      bInCondition = true
    end
  end
  log(bWriteLog and string.format("logic_friend_group:_IsFriendTimeMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsFriendTimeMatch(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_IsFriendTimeMatch groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsFriendTimeMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
  end
  local friendUID = friendData.uid
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactData = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(friendUID)
  local add_friend_days = interactData and interactData.add_friend_days or 0
  if not logic_friend_interact_record.IsAddFriendDaysValid(add_friend_days) then
    return false
  end
  local bInCondition
  if param2 == C_TEMP then
    bInCondition = self.compareFuncMap[groupData.CompareType](add_friend_days, param1)
  else
    bInCondition = self.compareFuncMap[groupData.CompareType](add_friend_days, param1, param2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsFriendTimeMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsTeamMateTimeMatch(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_IsTeamMateTimeMatch groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsTeamMateTimeMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
  end
  local friendUID = friendData.uid
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactData = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(friendUID)
  local TimeUtil = require("client.common.time_util")
  local recentPlayTime = -999
  if interactData and interactData.recent_play_date then
    local nDiff = TimeUtil.GetServerTimeInSec() - interactData.recent_play_date
    recentPlayTime = math.floor(nDiff / 86400)
  end
  local bInCondition
  if recentPlayTime == -999 and param1 then
    bInCondition = false
  elseif param2 == C_TEMP then
    bInCondition = self.compareFuncMap[groupData.CompareType](recentPlayTime, param1)
  else
    bInCondition = self.compareFuncMap[groupData.CompareType](recentPlayTime, param1, param2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsTeamMateTimeMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsIntimacyMatch(friendData, groupID, index)
  log(bWriteLog and "logic_friend_group:_IsIntimacyMatch groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsIntimacyMatch not group config")
    return
  end
  if index > self.currentListNum then
    return false
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  local index1 = math.floor(self.currentListNum * param1)
  local index2 = 0
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
    index2 = math.floor(self.currentListNum * param2)
  end
  local friendUID = friendData.uid
  local groupBase = 400
  local lastGroup = 405
  local gIdx = tonumber(groupID) - groupBase
  local leastGroup = groupBase + tonumber(index)
  leastGroup = lastGroup < leastGroup and lastGroup or leastGroup
  if index < gIdx then
    return false
  elseif tonumber(groupID) == leastGroup then
    if not friendData.tmpGIdx then
      return true
    end
    friendData.tmpGIdx = nil
  end
  local bInCondition
  if param2 == C_TEMP then
    bInCondition = self.compareFuncMap[groupData.CompareType](index, index1)
  else
    bInCondition = self.compareFuncMap[groupData.CompareType](index, index1, index2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsIntimacyMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  if bInCondition then
    friendData.tmpGIdx = gIdx
  end
  return bInCondition
end
function logic_friend_group:_IsFriendSourceMatch(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_IsFriendSourceMatch groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsFriendSourceMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
  end
  local friendUID = friendData.uid
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactData = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(friendUID)
  local source = 0
  if interactData and interactData.add_from then
    source = interactData.add_from
  else
    source = friendData.source or 0
  end
  local mappingID = self:GetFriendSourceID(source)
  if mappingID ~= 0 then
    log(bWriteLog and "logic_friend_group:_IsFriendSourceMatch uid = " .. friendUID .. " from = " .. mappingID)
  end
  friendData.sourceMappingID = mappingID
  local bInCondition
  if param2 == C_TEMP then
    bInCondition = self.compareFuncMap[groupData.CompareType](mappingID, param1)
  else
    bInCondition = self.compareFuncMap[groupData.CompareType](mappingID, param1, param2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsFriendSourceMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsRecentTeamModeMatch(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsRecentTeamModeMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local friendUID = friendData.uid
  local TableUtil = require("common.table_util")
  local group_id_list = TableUtil.GetTableValue(friendData, "interactData", "interactServerData", friend_macros.E_RecentInteractType.TeamBattle, "group_id_list")
  local recentTeamModeID = 0
  local bInCondition = false
  local bHasRecord = group_id_list and next(group_id_list)
  if bHasRecord then
    if param1 then
      bInCondition = group_id_list[param1] ~= nil
    else
      bInCondition = true
      for gID, gData in pairs(self.friendGroupConfig) do
        local otherParam1 = tonumber(gData.Param1)
        if otherParam1 and group_id_list[otherParam1] ~= nil then
          bInCondition = false
        end
      end
    end
  else
    bInCondition = param1 == nil
  end
  log(bWriteLog and string.format("logic_friend_group:_IsRecentTeamModeMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsMakeRecentTimeMatch(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsMakeRecentTimeMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
  end
  local friendUID = friendData.uid
  local TimeUtil = require("client.common.time_util")
  local oldestKnowTime = -999
  if not friendData.interactData then
    return false
  end
  if friendData.interactData.oldestKnowTime then
    local nDiff = TimeUtil.GetServerTimeInSec() - friendData.interactData.oldestKnowTime
    if nDiff <= 0 then
      log(bWriteLog and "logic_friend_group:_IsMakeRecentTimeMatch time diff <= 0! ")
      nDiff = 1
    end
    oldestKnowTime = math.ceil(nDiff / 86400)
  end
  local bInCondition
  if oldestKnowTime == -999 and param1 then
    bInCondition = false
  elseif param2 == C_TEMP then
    bInCondition = self.compareFuncMap[groupData.CompareType](oldestKnowTime, param1)
  else
    bInCondition = self.compareFuncMap[groupData.CompareType](oldestKnowTime, param1, param2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsMakeRecentTimeMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsRecentReasonMatch(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsRecentReasonMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
  end
  local friendUID = friendData.uid
  local bInCondition = false
  local TableUtil = require("common.table_util")
  local interactTypeData = TableUtil.GetTableValue(friendData, "interactData", "oldestInteractType")
  if interactTypeData then
    bInCondition = self.compareFuncMap[groupData.CompareType](interactTypeData, param1, param2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsRecentReasonMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsNewestInteractMatch(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsNewestInteractMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
  end
  local friendUID = friendData.uid
  local TimeUtil = require("client.common.time_util")
  local newestInteractTime = -999
  if friendData.interactData.newestInteractTime then
    local nDiff = TimeUtil.GetServerTimeInSec() - friendData.interactData.newestInteractTime
    if nDiff <= 0 then
      log(bWriteLog and "logic_friend_group:_IsMakeRecentTimeMatch time diff <= 0! ")
      nDiff = 1
    end
    newestInteractTime = math.ceil(nDiff / 86400)
  end
  local bInCondition
  if newestInteractTime == -999 and param1 then
    bInCondition = false
  elseif param2 == C_TEMP then
    bInCondition = self.compareFuncMap[groupData.CompareType](newestInteractTime, param1)
  else
    bInCondition = self.compareFuncMap[groupData.CompareType](newestInteractTime, param1, param2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsNewestInteractMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  return bInCondition
end
function logic_friend_group:_IsRecentModeMatch(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_IsRecentModeMatch groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsRecentModeMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local friendUID = friendData.uid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(friendUID, false)
  local recentModeID = profile and profile.heavy_involved_mode_i
  local bInCondition = recentModeID == param1
  log(bWriteLog and string.format("logic_friend_group:_IsRecentModeMatch friendUID = %s, recentModeID = %s, param1 = %s, bInCondition = %s", friendUID, tostring(recentModeID), tostring(param1), bInCondition))
  return bInCondition
end
function logic_friend_group:_IsModeMatch(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_IsModeMatch groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_group:_IsModeMatch not group config")
    return
  end
  local param1 = tonumber(groupData.Param1)
  local friendUID = friendData.uid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(friendUID, true)
  local ModeID = profile and profile.heavy_involved_mode_i
  local bInCondition = ModeID == param1
  log(bWriteLog and string.format("logic_friend_group:_IsModeMatch friendUID = %s, ModeID = %s, param1 = %s, bInCondition = %s", friendUID, tostring(ModeID), tostring(param1), bInCondition))
  return bInCondition
end
function logic_friend_group:_IsInteractMatch(friendData, groupID, index)
  log(bWriteLog and "logic_friend_group:_IsInteractionMatch" .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_goup:_IsInteractionMatch not group config")
    return
  end
  if index > self.currentListNum then
    return false
  end
  local param1 = tonumber(groupData.Param1)
  local param2 = C_TEMP
  local index1 = math.floor(self.currentListNum * param1)
  local index2 = 0
  if groupData.Param2 ~= "" then
    param2 = tonumber(groupData.Param2)
    index2 = math.floor(self.currentListNum * param2)
  end
  local friendUID = friendData.uid
  local lastGroup = 1305
  local gIdx = tonumber(groupID) - 1300
  local leastGroup = 1300 + tonumber(index)
  leastGroup = lastGroup < leastGroup and lastGroup or leastGroup
  if index < gIdx then
    return false
  elseif tonumber(groupID) == leastGroup then
    if not friendData.tmpGIdx then
      return true
    end
    friendData.tmpGIdx = nil
  end
  local bInCondition
  if param2 == C_TEMP then
    bInCondition = self.compareFuncMap[groupData.CompareType](index, index1)
  else
    bInCondition = self.compareFuncMap[groupData.CompareType](index, index1, index2)
  end
  log(bWriteLog and string.format("logic_friend_group:_IsInteractionMatch friendUID = %s , bInCondition = %s", friendUID, bInCondition))
  if bInCondition then
    friendData.tmpGIdx = gIdx
  end
  return bInCondition
end
function logic_friend_group:_IsReturnMatch(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_IsInteractionMatch" .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  if not groupData then
    log_error(bWriteLog and "logic_friend_goup:_IsInteractionMatch not group config")
    return
  end
  local friendUID = friendData.uid
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(friendUID, true)
  local bIsReturner = false
  local param1 = tonumber(groupData.Param1) == 1
  if profile and profile.rejoin_start_time and profile.dynamic_life_time then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    local rejoin_start_time = profile.rejoin_start_time
    local day_second = 86400
    local rejoin_end_time = rejoin_start_time + profile.dynamic_life_time * 86400
    bIsReturner = serverTime < rejoin_end_time
    log(bWriteLog and string.format("logic_oldfriend_care.IsRejoinPlayer, uid:%s", profile.uid))
    log(bWriteLog and "logic_oldfriend_care.IsRejoinPlayer, rejoin_start_time is: " .. tostring(rejoin_start_time) .. "; rejoin_end_time is: " .. tostring(rejoin_end_time) .. "; serverTime is: " .. tostring(serverTime))
  end
  return bIsReturner == param1
end
function logic_friend_group:_GetTeamModeLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local teamModeID = tonumber(groupData.Param1)
  local text = ""
  local cfg = CDataTable.GetTableData("FriendGroupCfg", groupID)
  if not cfg then
    return text, nil
  end
  local label = cfg.Content
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactData = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(friendData.uid)
  local teamTime = interactData and interactData.group_id_list and next(interactData.group_id_list) and interactData.group_id_list[teamModeID] and math.floor(interactData.group_id_list[teamModeID]) or 0
  if groupData.FriendTagText1 ~= "" then
    local hour = teamTime / 3600
    if hour < 0.1 then
      hour = 0.1
    end
    local timeStr = ""
    if hour < 1 then
      timeStr = string.format("%.1f", hour)
    else
      timeStr = tostring(math.floor(hour))
    end
    text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), label, timeStr)
  end
  return text, nil
end
function logic_friend_group:_GetFriendTimeLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local friendUID = friendData.uid
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactData = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(friendUID)
  local add_friend_days = interactData and interactData.add_friend_days or 1
  local text = ""
  if groupData.FriendTagText1 ~= "" then
    if logic_friend_interact_record.IsAddFriendDaysValid(add_friend_days) then
      text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), add_friend_days)
    else
      text = LocUtil.GetLocalizeResStr(62341)
    end
  end
  return text, nil
end
function logic_friend_group:_GetTeamMateTimeLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local friendUID = friendData.uid
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactData = logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(friendUID)
  local recentPlayTime = interactData and interactData.recent_play_date
  local text = ""
  if recentPlayTime then
    local TimeUtil = require("client.common.time_util")
    local timeAgoStr = TimeUtil.GetTimeAgoStr(recentPlayTime, false)
    if groupData.FriendTagText1 ~= "" then
      text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), timeAgoStr)
    end
  end
  return text, nil
end
function logic_friend_group:_GetIntimacyLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local intimacy = friendData.intimacy
  local text = ""
  if groupData.FriendTagText1 ~= "" then
    text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), tostring(intimacy))
  end
  return text, nil
end
function logic_friend_group:_GetInteractLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local interact = friendData.interact
  local text = ""
  if groupData.FriendTagText1 ~= "" then
    text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), tostring(interact))
  end
  return text, nil
end
function logic_friend_group:_GetFriendSourceLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local cfg = CDataTable.GetTableData("FriendSourceMappingCfg", friendData.sourceMappingID)
  if not cfg then
    return "", nil
  end
  local sourceLabel = cfg.PlayerTagShowText
  local text = ""
  if groupData.FriendTagText1 ~= "" then
    text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), sourceLabel)
  end
  return text, nil
end
function logic_friend_group:_GetMakeRecentTimeLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local oldestTime = friendData.interactData.oldestKnowTime
  local timeAgoStr = ""
  if oldestTime then
    local TimeUtil = require("client.common.time_util")
    timeAgoStr = TimeUtil.GetTimeAgoStr(oldestTime)
  end
  local interactLocID = 0
  local interactStr = ""
  if friendData.interactData.oldestInteractType then
    local logic_friend_group_tools = require("client.slua.logic.friend.logic_friend_group_tools")
    local interactLocID = logic_friend_group_tools.GetRecentInteractLabel(friendData.interactData.oldestInteractType, friendData.interactData.oldestInteractOp)
    if 0 < interactLocID then
      interactStr = LocUtil.GetLocalizeResStr(interactLocID)
    end
  end
  return timeAgoStr, interactStr
end
function logic_friend_group:_GetNewestInteractLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local newestTime = friendData.interactData.newestInteractTime
  local timeAgoStr = ""
  if newestTime then
    local TimeUtil = require("client.common.time_util")
    timeAgoStr = TimeUtil.GetTimeAgoStr(newestTime)
  end
  local interactLocID = 0
  local interactStr = ""
  if friendData.interactData.newestInteractType then
    local logic_friend_group_tools = require("client.slua.logic.friend.logic_friend_group_tools")
    interactLocID = logic_friend_group_tools.GetRecentInteractLabel(friendData.interactData.newestInteractType, friendData.interactData.newestInteractOp)
    if 0 < interactLocID then
      interactStr = LocUtil.GetLocalizeResStr(interactLocID)
    end
  end
  return timeAgoStr, interactStr
end
function logic_friend_group:_GetRecentReasonLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local oldestKnowTime = friendData.interactData.oldestKnowTime
  local oldestInteractType = friendData.interactData.oldestInteractType
  local timeAgoStr = ""
  local interactStr = ""
  local param1 = tonumber(groupData.Param1)
  if oldestKnowTime then
    local TimeUtil = require("client.common.time_util")
    timeAgoStr = TimeUtil.GetTimeAgoStr(oldestKnowTime)
  end
  if groupData.FriendTagText1 ~= "" then
    local locID = tonumber(groupData.FriendTagText1)
    local logic_friend_group_tools = require("client.slua.logic.friend.logic_friend_group_tools")
    local sourceText = logic_friend_group_tools.GetRecentInteractSourceLabel(oldestInteractType)
    interactStr = LocUtil.LocalizeResFormat(locID, sourceText)
  end
  return interactStr, timeAgoStr
end
function logic_friend_group:_GetRecentTeamTimeLabel(friendData, groupID)
  local groupData = self.friendGroupConfig[groupID]
  local text = ""
  if not groupData.Param1 then
    return text, nil
  end
  local param1 = tonumber(groupData.Param1)
  local TableUtil = require("common.table_util")
  local times = TableUtil.GetTableValue(friendData, "interactData", "interactServerData", friend_macros.E_RecentInteractType.TeamBattle, "group_id_list", param1) or 0
  if times == 0 then
    return text, nil
  end
  if param1 and groupData.FriendTagText1 ~= "" then
    local locID = tonumber(groupData.FriendTagText1)
    local cfg = CDataTable.GetTableData("FriendGroupCfg", groupID)
    if not cfg then
      return text, nil
    end
    local label = cfg.Content
    text = LocUtil.LocalizeResFormat(locID, label, times)
  end
  return text, nil
end
function logic_friend_group:_GetModeLabel(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_GetModeLabel groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  local cfg = CDataTable.GetTableData("FriendGroupCfg", groupID)
  if not cfg then
    return "", nil
  end
  local ModeLabel = cfg.Content
  local text = LocUtil.LocalizeResFormat(76016, ModeLabel)
  if groupData.FriendTagText1 ~= "" then
    text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), ModeLabel)
  end
  return text, nil
end
function logic_friend_group:_GetRecentModeLabel(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_GetRecentModeLabel groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  local cfg = CDataTable.GetTableData("FriendGroupCfg", groupID)
  if not cfg then
    return "", nil
  end
  local RecentMode = cfg.Content
  local text = ""
  if groupData.FriendTagText1 ~= "" then
    text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), RecentMode)
  end
  return text, nil
end
function logic_friend_group:_GetReturnLabel(friendData, groupID)
  log(bWriteLog and "logic_friend_group:_GetRecentModeLabel groupID = " .. tostring(groupID))
  local groupData = self.friendGroupConfig[groupID]
  local cfg = CDataTable.GetTableData("FriendGroupCfg", groupID)
  if not cfg then
    return "", nil
  end
  local Return = cfg.Content
  local text = ""
  if groupData.FriendTagText1 ~= "" then
    text = LocUtil.LocalizeResFormat(tonumber(groupData.FriendTagText1), Return)
  end
  return text, nil
end
function logic_friend_group:_InitFuncMap()
  local E_ParamType = friend_macros.E_ParamType
  self.matchFuncMap = {
    [E_ParamType.FriendDefault] = function(friendData, groupID)
      return true
    end,
    [E_ParamType.TeamMode] = function(friendData, groupID)
      return self:_IsTeamModeMatch(friendData, groupID)
    end,
    [E_ParamType.FriendTime] = function(friendData, groupID)
      return self:_IsFriendTimeMatch(friendData, groupID)
    end,
    [E_ParamType.TeamMateTime] = function(friendData, groupID)
      return self:_IsTeamMateTimeMatch(friendData, groupID)
    end,
    [E_ParamType.Intimacy] = function(friendData, groupID, index)
      return self:_IsIntimacyMatch(friendData, groupID, index)
    end,
    [E_ParamType.Interact] = function(friendData, groupID, index)
      return self:_IsInteractMatch(friendData, groupID, index)
    end,
    [E_ParamType.FriendSource] = function(friendData, groupID)
      return self:_IsFriendSourceMatch(friendData, groupID)
    end,
    [E_ParamType.RecentTeamMode] = function(friendData, groupID)
      return self:_IsRecentTeamModeMatch(friendData, groupID)
    end,
    [E_ParamType.MakeRecentTime] = function(friendData, groupID)
      return self:_IsMakeRecentTimeMatch(friendData, groupID)
    end,
    [E_ParamType.NewestInteract] = function(friendData, groupID)
      return self:_IsNewestInteractMatch(friendData, groupID)
    end,
    [E_ParamType.RecentReason] = function(friendData, groupID)
      return self:_IsRecentReasonMatch(friendData, groupID)
    end,
    [E_ParamType.RecentMode] = function(friendData, groupID)
      return self:_IsRecentModeMatch(friendData, groupID)
    end,
    [E_ParamType.Mode] = function(friendData, groupID)
      return self:_IsModeMatch(friendData, groupID)
    end,
    [E_ParamType.Returner] = function(friendData, groupID)
      return self:_IsReturnMatch(friendData, groupID)
    end,
    [E_ParamType.Default] = function(friendData, groupID)
      return true
    end
  }
  self.compareFuncMap = {
    ET = function(a, b)
      if not b then
        return a == -999
      end
      return a == b
    end,
    LT = function(a, b)
      return a < b
    end,
    GET = function(a, b)
      return b <= a
    end,
    GET_LT = function(a, b, c)
      return b <= a and a < c
    end
  }
  local logic_friend_group_compare = require("client.slua.logic.friend.logic_friend_group_compare")
  self.sortFuncMap = {
    [E_ParamType.TeamMode] = function(a, b)
      return logic_friend_group_compare.Sort_TeamMode(a, b)
    end,
    [E_ParamType.FriendTime] = function(a, b)
      return logic_friend_group_compare.Sort_FriendTime(a, b)
    end,
    [E_ParamType.TeamMateTime] = function(a, b)
      return logic_friend_group_compare.Sort_TeamMateTime(a, b)
    end,
    [E_ParamType.Intimacy] = function(a, b)
      return logic_friend_group_compare.Sort_Intimacy(a, b)
    end,
    [E_ParamType.Interact] = function(a, b)
      return logic_friend_group_compare.Sort_Interact(a, b)
    end,
    [E_ParamType.FriendSource] = function(a, b)
      return logic_friend_group_compare.Sort_FriendSource(a, b)
    end,
    [E_ParamType.RecentTeamMode] = function(a, b)
      return logic_friend_group_compare.Sort_RecentTeamMode(a, b)
    end,
    [E_ParamType.MakeRecentTime] = function(a, b)
      return logic_friend_group_compare.Sort_MakeRecentTime(a, b)
    end,
    [E_ParamType.NewestInteract] = function(a, b)
      return logic_friend_group_compare.Sort_NewestInteract(a, b)
    end,
    [E_ParamType.RecentReason] = function(a, b)
      return logic_friend_group_compare.Sort_RecentReason(a, b)
    end,
    [E_ParamType.Default] = function(a, b)
      return logic_friend_group_compare.Sort_Default(a, b)
    end,
    [E_ParamType.RecentMode] = function(a, b)
      return logic_friend_group_compare.Sort_Mode(a, b)
    end,
    [E_ParamType.Mode] = function(a, b)
      return logic_friend_group_compare.Sort_Mode(a, b)
    end,
    [E_ParamType.Returner] = function(a, b)
      return logic_friend_group_compare.Sort_Return(a, b)
    end
  }
  self.getFriendLabelTextFuncMap = {
    [E_ParamType.TeamMode] = function(friendData, groupID)
      return self:_GetTeamModeLabel(friendData, groupID)
    end,
    [E_ParamType.FriendTime] = function(friendData, groupID)
      return self:_GetFriendTimeLabel(friendData, groupID)
    end,
    [E_ParamType.TeamMateTime] = function(friendData, groupID)
      return self:_GetTeamMateTimeLabel(friendData, groupID)
    end,
    [E_ParamType.Intimacy] = function(friendData, groupID)
      return self:_GetIntimacyLabel(friendData, groupID)
    end,
    [E_ParamType.Interact] = function(friendData, groupID)
      return self:_GetInteractLabel(friendData, groupID)
    end,
    [E_ParamType.FriendSource] = function(friendData, groupID)
      return self:_GetFriendSourceLabel(friendData, groupID)
    end,
    [E_ParamType.MakeRecentTime] = function(friendData, groupID)
      return self:_GetMakeRecentTimeLabel(friendData, groupID)
    end,
    [E_ParamType.NewestInteract] = function(friendData, groupID)
      return self:_GetNewestInteractLabel(friendData, groupID)
    end,
    [E_ParamType.RecentReason] = function(friendData, groupID)
      return self:_GetRecentReasonLabel(friendData, groupID)
    end,
    [E_ParamType.RecentTeamMode] = function(friendData, groupID)
      return self:_GetRecentTeamTimeLabel(friendData, groupID)
    end,
    [E_ParamType.Mode] = function(friendData, groupID)
      return self:_GetModeLabel(friendData, groupID)
    end,
    [E_ParamType.RecentMode] = function(friendData, groupID)
      return self:_GetRecentModeLabel(friendData, groupID)
    end,
    [E_ParamType.Returner] = function(friendData, groupID)
      return self:_GetReturnLabel(friendData, groupID)
    end
  }
  self.preGroupDataFuncMap = {
    [E_ParamType.Intimacy] = function(friendData)
      local validNum = 0
      for k, v in pairs(friendData) do
        local intimacy = friendData[k].intimacy
        if intimacy and intimacy ~= 0 then
          validNum = validNum + 1
        end
      end
      table.sort(friendData, function(a, b)
        return a.intimacy > b.intimacy
      end)
      self.currentListNum = validNum
    end,
    [E_ParamType.Interact] = function(friendData)
      local validNum = 0
      local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
      for k, v in pairs(friendData) do
        local interactScore = logic_interaction:GetInteractionScore(v.uid)
        friendData[k].interact = interactScore or 0
        if interactScore and interactScore ~= 0 then
          validNum = validNum + 1
        end
      end
      table.sort(friendData, function(a, b)
        return a.interact > b.interact
      end)
      self.currentListNum = validNum
    end,
    [E_ParamType.FriendDefault] = function(friendData)
      local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
      table.sort(friendData, function(a, b)
        return LogicTeamUpSideBar.FriendsSortFunc(a, b)
      end)
    end
  }
end
function logic_friend_group:_InitConfig()
  self.friendTagConfig = {}
  self.friendGroupConfig = {}
  self.friendTagFilterConfig = {}
  self.friendSourceMappingConfig = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local BlueHole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  local tableName = BlueHole and "FriendTagCfg_India" or "FriendTagCfg"
  local tagConfig = CDataTable.GetTable(tableName)
  if tagConfig then
    for _, data in pairs(tagConfig) do
      self.friendTagConfig[data.ID] = data
    end
  end
  local sortFunc = function(a, b)
    return a.ShowOrder < b.ShowOrder
  end
  local tagSourceConfig1 = CDataTable.GetTableByFilter(tableName, "Belonging", 1)
  if tagSourceConfig1 then
    self.friendTagFilterConfig[1] = {}
    for index, data in pairs(tagSourceConfig1) do
      table.insert(self.friendTagFilterConfig[1], data)
    end
    table.sort(self.friendTagFilterConfig[1], sortFunc)
  end
  local tagSourceConfig2 = CDataTable.GetTableByFilter(tableName, "Belonging", 2)
  if tagSourceConfig2 then
    self.friendTagFilterConfig[2] = {}
    for index, data in pairs(tagSourceConfig2) do
      table.insert(self.friendTagFilterConfig[2], data)
    end
    table.sort(self.friendTagFilterConfig[2], sortFunc)
  end
  local groupConfig = CDataTable.GetTable("FriendGroupCfg")
  if groupConfig then
    for _, data in pairs(groupConfig) do
      self.friendGroupConfig[data.ID] = data
    end
  end
  local friendSourceMapConfig = CDataTable.GetTable("FriendSourceMappingCfg")
  if friendSourceMapConfig then
    for _, data in pairs(friendSourceMapConfig) do
      self.friendSourceMappingConfig[data.ID] = data
    end
  end
end
function logic_friend_group:GetFriendTagsDataByType(type)
  local tags = self.friendTagFilterConfig and self.friendTagFilterConfig[type]
  log(bWriteLog and "logic_friend_group:GetSourceTagsByType type" .. tostring(type))
  log_tree(bWriteLog and "logic_friend_group:GetSourceTagsByType", tags)
  local tagDataList = {}
  if tags then
    for i, v in ipairs(tags) do
      local name = v.Content
      local tipsContent
      if v.TipsID > 0 then
        tipsContent = LocUtil.GetLocalizeResStr(v.TipsID)
      end
      table.insert(tagDataList, {
        text = name,
        tips = tipsContent,
        data = v
      })
    end
  end
  return tagDataList
end
function logic_friend_group:GetTagGroups(tagID)
  if not tagID then
    log_error(bWriteLog and "logic_friend_group:GetTagGroup not tagID")
    return {}
  end
  local config = self.friendTagConfig[tagID]
  local groups = {}
  if config then
    for i = 0, config.List_a:Num() - 1 do
      table.insert(groups, config.List_a:Get(i))
    end
    return groups
  end
  return groups
end
function logic_friend_group:GetGroupInfo(playerList, tagID)
  log(bWriteLog and "logic_friend_group:GetGroupInfo tagID = " .. tostring(tagID))
  local groups = self:GetTagGroups(tagID)
  local info = {}
  if playerList and next(playerList) then
    self.currentListNum = #playerList
    log(bWriteLog and "logic_friend_group:GetGroupInfo currentListNum = " .. tostring(self.currentListNum))
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local bInitCurrentList = false
  if groups and next(groups) then
    for index, groupID in ipairs(groups) do
      info[index] = {
        ID = groupID,
        onlineNum = 0,
        totalNum = 0,
        playerDatas = {}
      }
      local groupData = self.friendGroupConfig[groupID]
      local GroupType = groupData.GroupType
      if not bInitCurrentList then
        bInitCurrentList = true
        if self.preGroupDataFuncMap and self.preGroupDataFuncMap[GroupType] then
          self.preGroupDataFuncMap[GroupType](playerList)
        end
      end
      for playerIndex, playerData in ipairs(playerList) do
        if self.matchFuncMap[GroupType] then
          local isMatch = self.matchFuncMap[GroupType](playerData, groupID, playerIndex)
          if isMatch then
            table.insert(info[index].playerDatas, playerData)
            info[index].totalNum = info[index].totalNum + 1
            if playerData.online == 1 then
              info[index].onlineNum = info[index].onlineNum + 1
            elseif not playerData.online then
              local status = PlayerStatusMgr:GetStatusData(playerData.uid)
              if status and status.online == 1 then
                info[index].onlineNum = info[index].onlineNum + 1
              end
            end
          end
        end
      end
      local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
      local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
      local tabID = logic_friend_list_ui:GetTabID()
      if tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
        local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
        table.sort(info[index].playerDatas, LogicTeamUpSideBar.CorpsSortFunc)
      elseif self.sortFuncMap[GroupType] then
        table.sort(info[index].playerDatas, self.sortFuncMap[GroupType])
      end
    end
  end
  log_tree(bWriteLog and "logic_friend_group:GetGroupInfo info = ", info)
  return info
end
function logic_friend_group:GetReuseData(playerlist, tagID)
  log_tree("logic_friend_group:GetReuseData playerList=", playerlist)
  local info = self:GetGroupInfo(playerlist, tagID)
  if not next(info) then
    log_error(bWriteLog and "logic_friend_group:GetReuseData not info")
    return {}
  end
  local reuseDatas = {}
  if not self.currentSelectGroupList or not next(self.currentSelectGroupList) and not self.bFoldingFirstGroup then
    self.show_groupID = 0
    for index, infoData in ipairs(info) do
      if infoData.totalNum ~= 0 then
        self.show_groupID = infoData.ID
        self.currentSelectGroupList = {
          [self.show_groupID] = true
        }
        break
      end
    end
  end
  local TableUtil = require("common.table_util")
  for index, infoData in ipairs(info) do
    local E_DefaultIDType = friend_macros.E_DefaultIDType
    if tagID ~= E_DefaultIDType.friendDefaultID and tagID ~= E_DefaultIDType.recentDefaultID then
      local titleData = {
        itemType = self.ListItemType.Title,
        onlineNum = infoData.onlineNum,
        totalNum = infoData.totalNum,
        reuseFallGroupID = infoData.ID
      }
      table.insert(reuseDatas, titleData)
    end
    local hasSelectedGroup = self.currentSelectGroupList and self.currentSelectGroupList[infoData.ID]
    if hasSelectedGroup then
      for playerIndex, playerData in ipairs(infoData.playerDatas) do
        local playerReuseData = TableUtil.DeepCloneTable(playerData)
        playerReuseData.itemType = self.ListItemType.Friend
        playerReuseData.reuseFallGroupID = infoData.ID
        table.insert(reuseDatas, playerReuseData)
      end
    end
  end
  return reuseDatas
end
function logic_friend_group:GetListTypeEnum()
  return C_FriendListDataType
end
function logic_friend_group:GetGroupNameByID(groupID)
  local config = self.friendGroupConfig[groupID]
  if config then
    return config.Content
  end
  return ""
end
function logic_friend_group:ResetSelectGroupList()
  log(bWriteLog and "logic_friend_group:ResetSelectGroupList")
  self.currentSelectGroupList = {}
end
function logic_friend_group:IsHasSelectGroupID(groupID)
  log(bWriteLog and "logic_friend_group:IsHasSelectGroupID groupID = " .. tostring(groupID))
  return self.currentSelectGroupList[groupID]
end
function logic_friend_group:AddSelectGroupID(groupID)
  log(bWriteLog and "logic_friend_group:AddSelectGroupID groupID = " .. tostring(groupID))
  self.currentSelectGroupList[groupID] = true
end
function logic_friend_group:RemoveSelectGroupID(groupID)
  log(bWriteLog and "logic_friend_group:RemoveSelectGroupID")
  if self.currentSelectGroupList[groupID] then
    log(bWriteLog and "logic_friend_group:RemoveSelectGroupID = " .. tostring(groupID))
    self.currentSelectGroupList[groupID] = nil
  end
end
function logic_friend_group:GetFriendSourceID(friendSource)
  log(bWriteLog and "logic_friend_group:GetFriendSourceID friendSource = " .. tostring(friendSource))
  local id = 0
  for _, sourceMapConfig in pairs(self.friendSourceMappingConfig) do
    local bFind = false
    for i = 0, sourceMapConfig.Source_a:Num() - 1 do
      local sourceID = sourceMapConfig.Source_a:Get(i)
      if tonumber(sourceID) == friendSource then
        id = sourceMapConfig.ID
        bFind = true
        break
      end
    end
    if bFind then
      break
    end
  end
  log(bWriteLog and "logic_friend_group:GetFriendSourceID id = " .. id)
  return id
end
function logic_friend_group:GetFriendLabel(friendData, groupID)
  local groupConfig = self.friendGroupConfig[groupID]
  if groupConfig and self.getFriendLabelTextFuncMap[groupConfig.GroupType] then
    return self.getFriendLabelTextFuncMap[groupConfig.GroupType](friendData, groupID)
  end
  return nil, nil
end
function logic_friend_group:SetFoldingFirstGroup(state)
  self.bFoldingFirstGroup = state
end
function logic_friend_group:SetWowOfflineState(boole)
  self.WowOpenOffline = boole
end
function logic_friend_group:GetWOWReuseData(palyerlist)
  if not palyerlist then
    return
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local OnlineList, OfflineList, AnatherList = logic_ugc_mode:CheckOnLineList(palyerlist)
  if not next(OnlineList) and next(OfflineList) then
    table.insert(OnlineList, OfflineList[1])
    table.remove(OfflineList, 1)
  end
  local ReturnList = {}
  if next(OnlineList) then
    table.insert(ReturnList, {
      friends = OnlineList,
      itemType = 0,
      Hidden = true,
      Open = true,
      friendindex = #OnlineList
    })
  end
  if next(OfflineList) then
    table.insert(ReturnList, {
      friends = self.WowOpenOffline and OfflineList or {},
      itemType = 0,
      Hidden = false,
      Open = self.WowOpenOffline,
      friendindex = #OfflineList
    })
  end
  if next(AnatherList) then
    table.insert(ReturnList, {
      friends = AnatherList,
      itemType = 1,
      Hidden = false,
      Open = true,
      friendindex = #AnatherList
    })
  end
  local bHasOnline = next(OnlineList) ~= nil
  return ReturnList, C_FriendListDataType.PureList, bHasOnline
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_friend_group = class(CModuleBase, nil, logic_friend_group)
return Clogic_friend_group