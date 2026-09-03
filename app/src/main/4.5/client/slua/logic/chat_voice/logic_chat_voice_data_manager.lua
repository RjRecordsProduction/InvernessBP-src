local TableUtil = require("common.table_util")
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local logic_chat_voice_utility = require("client.slua.logic.chat_voice.logic_chat_voice_utility")
local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
local Enum_RoomUpdateType = logic_chat_voice_const.Enum_RoomUpdateType
local Enum_MemberStateBitDefine = logic_chat_voice_const.Enum_MemberStateBitDefine
local logic_chat_voice_data_manager = {
  curRoomType = Enum_AntsVoiceRoomType.Temp,
  curRoomInfos = {},
  roomID2AllMembers = {},
  lastRoomInfos = {}
}
function logic_chat_voice_data_manager:OnLogin(bReLogin)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:OnLogin, bReLogin:%s", bReLogin))
  if bReLogin then
    self:SyncRoomInfo()
  end
end
function logic_chat_voice_data_manager:SyncRoomInfo()
  for roomType, roomInfo in pairs(self.curRoomInfos) do
    local roomID = roomInfo.roomID
    local antsVoiceUID = roomInfo.antsVoiceUID
    local stateTable = self:GetSelfStateByRoomType(roomType)
    local logic_chat_voice_protocol_manager = require("client.slua.logic.chat_voice.logic_chat_voice_protocol_manager")
    logic_chat_voice_protocol_manager:JoinVoiceRoom(roomType, roomID, antsVoiceUID, stateTable)
  end
end
function logic_chat_voice_data_manager:OnLogOut()
  self.curRoomType = Enum_AntsVoiceRoomType.Temp
  self.curRoomInfos = {}
  self.roomID2AllMembers = {}
  self.lastRoomInfos = {}
end
function logic_chat_voice_data_manager:SetCurRoomInfoByRoomType(roomType, roomInfo)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:SetCurRoomInfoByRoomType, roomType:%s", roomType))
  log_tree("[muidarzhang] logic_chat_voice_data_manager:SetCurRoomInfoByRoomType roomInfo:", roomInfo)
  if roomInfo ~= nil then
    self.curRoomType = roomType
  end
  local last_room = self.curRoomInfos[roomType] or {}
  self.lastRoomInfos[roomType] = last_room
  self.curRoomInfos[roomType] = roomInfo
end
function logic_chat_voice_data_manager:ClearRoomInfoByRoomType(roomType)
  printf("logic_chat_voice_data_manager:ClearRoomInfoByRoomType, roomType:%s", roomType)
  self.curRoomInfos[roomType] = nil
  self.curRoomType = Enum_AntsVoiceRoomType.Temp
end
function logic_chat_voice_data_manager:SetCurRoomInfoByRoomID(roomID, newRoomInfo)
  for roomType, oldRoomInfo in pairs(self.curRoomInfos) do
    if oldRoomInfo.roomID == roomID then
      if newRoomInfo then
        do
          local roomInfo = {
            roomID = roomID,
            antsVoiceUrl = oldRoomInfo.antsVoiceUrl,
            antsVoiceUID = newRoomInfo.antsVoiceUID
          }
          self:SetCurRoomInfoByRoomType(roomType, roomInfo)
        end
        break
      end
      self:ClearRoomInfoByRoomType(roomType)
      break
    end
  end
end
function logic_chat_voice_data_manager:SetAllMembersInfo(roomType, roomID, allMembersInfo)
  printf("logic_chat_voice_data_manager:SetAllMembersInfo, roomType, roomID:%s, %s", roomType, roomID)
  log_tree("allMembersInfo:", allMembersInfo)
  self.roomID2AllMembers[roomID] = allMembersInfo
end
function logic_chat_voice_data_manager:ClearAllMembersInfo(roomID)
  printf("logic_chat_voice_data_manager:ClearAllMembersInfo, roomID:%s", roomID)
  self.roomID2AllMembers[roomID] = nil
end
function logic_chat_voice_data_manager:UpdateMemberInfo(roomType, roomID, updateInfo)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:UpdateMemberInfo, roomType, roomID:%s, %s", roomType, roomID))
  if roomType == nil or roomID == nil or updateInfo == nil then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_data_manager:UpdateMemberInfo, roomType == nil or roomID == nil or updateInfo == nil. ")
    return
  end
  if TableUtil.GetTableValue(self.curRoomInfos, roomType, "roomID") ~= roomID then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_data_manager:UpdateMemberInfo, TableUtil.GetTableValue(self.curRoomInfos, roomType, \"roomID\") ~= roomID ")
  end
  local allMembersInfo = self.roomID2AllMembers[roomID]
  if allMembersInfo == nil then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_data_manager:UpdateMemberInfo, self.roomID2AllMembers[roomID] == nil. ")
    return
  end
  local updateType = updateInfo.update_type or 0
  local antsVoiceUid = updateInfo.AntsVoice_uid or 0
  local uid = updateInfo.update_uid
  if updateType == Enum_RoomUpdateType.MemberJoin then
    for gUid, struct in pairs(allMembersInfo) do
      if struct.uid == uid then
        allMembersInfo[gUid] = nil
      end
    end
    allMembersInfo[antsVoiceUid] = {
      uid = updateInfo.update_uid,
      state = updateInfo.state
    }
  elseif updateType == Enum_RoomUpdateType.MemberQuit then
    if antsVoiceUid == 0 or allMembersInfo[antsVoiceUid] == nil then
      for k, v in pairs(allMembersInfo) do
        if v.uid == uid then
          allMembersInfo[k] = nil
          break
        end
      end
    end
    allMembersInfo[antsVoiceUid] = nil
  elseif updateType == Enum_RoomUpdateType.MemberStateChange then
    local nUid = TableUtil.GetTableValue(allMembersInfo, antsVoiceUid, "uid")
    if nUid and uid == nUid then
      allMembersInfo[antsVoiceUid].state = updateInfo.state
    end
  end
end
function logic_chat_voice_data_manager:UpdateSelfMemberInfo(roomType, roomID, stateBit)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:UpdateSelfMemberInfo, roomType, roomID, stateBit:%s, %s, %s", roomType, roomID, stateBit))
  local antsVoiceUid = logic_chat_voice_data_manager:GetAntsVoiceUidByRoomType(roomType)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:UpdateSelfMemberInfo, antsVoiceUid:%s", antsVoiceUid))
  log_tree("[muidarzhang] logic_chat_voice_data_manager:UpdateSelfMemberInfo self.curRoomInfos:", self.curRoomInfos)
  if not self.roomID2AllMembers then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_data_manager:UpdateSelfMemberInfo, not self.roomID2AllMembers. ")
    return
  end
  local allMembersInfo = self.roomID2AllMembers[roomID]
  if not allMembersInfo then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_data_manager:UpdateSelfMemberInfo, not allMembersInfo. ")
    return
  end
  log_tree("[muidarzhang] logic_chat_voice_data_manager:UpdateSelfMemberInfo allMembersInfo:", allMembersInfo)
  if not allMembersInfo[antsVoiceUid] then
    log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:UpdateSelfMemberInfo, antsVoiceUid:%s", antsVoiceUid))
    log(bWriteLog and "[muidarzhang] logic_chat_voice_data_manager:UpdateSelfMemberInfo, not allMembersInfo[antsVoiceUid]. ")
    return
  end
  allMembersInfo[antsVoiceUid].state = stateBit
end
function logic_chat_voice_data_manager:GetSelfStateByRoomType(roomType)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomType, roomType:%s", tostring(roomType)))
  local state = {
    false,
    false,
    false
  }
  if self.curRoomType == roomType then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    state[Enum_MemberStateBitDefine.SpeakerBit] = logic_chat_voice:GetSpeakerState()
    state[Enum_MemberStateBitDefine.MicBit] = logic_chat_voice:GetMicState()
  elseif self.curRoomInfos[roomType] ~= nil then
    state[Enum_MemberStateBitDefine.TempLeaveBit] = true
  end
  log_tree("[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomType state:", state)
  return state
end
function logic_chat_voice_data_manager:GetSelfStateByRoomID(roomID)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomID, roomID:%s", roomID))
  local state = {
    false,
    false,
    false
  }
  local curRoomID = TableUtil.GetTableValue(self.curRoomInfos, self.curRoomType, "roomID")
  log_tree("[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomID self.curRoomInfos:", self.curRoomInfos)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomID, self.curRoomType:%s", self.curRoomType))
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomID, curRoomID:%s", curRoomID))
  if curRoomID == roomID then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomID, curRoomID == roomID. ")
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    state[Enum_MemberStateBitDefine.SpeakerBit] = logic_antsvoice_interface:TeamSpeakerEnable()
    state[Enum_MemberStateBitDefine.MicBit] = logic_antsvoice_interface:TeamMicphoneEnable()
  else
    for roomType, roomInfo in pairs(self.curRoomInfos) do
      if roomInfo.roomID == roomID then
        state[Enum_MemberStateBitDefine.TempLeaveBit] = true
        break
      end
    end
  end
  log_tree("[[muidarzhang] logic_chat_voice_data_manager:GetSelfStateByRoomID state:", state)
  return state
end
function logic_chat_voice_data_manager:GetAllMembersInfoListByRoomType(roomType)
  if not self.roomID2AllMembers then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_data_manager:GetAllMembersInfoListByRoomType, not self.roomID2AllMembers. ")
    return
  end
  local roomID = TableUtil.GetTableValue(self.curRoomInfos, roomType, "roomID")
  if not roomID then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_data_manager:GetAllMembersInfoListByRoomType, not roomID. ")
    return
  end
  local allMemberInfo = self.roomID2AllMembers[roomID]
  return self:_GetAllMembersInfoList(allMemberInfo, roomType, roomID)
end
function logic_chat_voice_data_manager:GetAllMembersInfoListByRoomID(roomID)
  if not self.roomID2AllMembers then
    log(bWriteLog and "[muidarzhang] logic_chat_voice_data_manager:GetAllMembersInfoListByRoomID, not self.roomID2AllMembers. ")
    return
  end
  local allMemberInfo = self.roomID2AllMembers[roomID]
  local roomType = self:GetRoomTypeByRoomID(roomID)
  return self:_GetAllMembersInfoList(allMemberInfo, roomType, roomID)
end
function logic_chat_voice_data_manager:_GetAllMembersInfoList(allMemberInfo, roomType, roomID)
  local allMembersInfoList = {}
  if not allMemberInfo then
    log(bWriteLog and "[muidarzhang] ERROR: logic_chat_voice_data_manager:_GetAllMembersInfoList, not allMemberInfo. ")
    return allMembersInfoList
  end
  for _, memberInfo in pairs(allMemberInfo) do
    local temp = memberInfo
    if type(temp.state) == "number" then
      temp.state = logic_chat_voice_utility.DecodeMemberState(memberInfo.state)
    end
    temp.    temp.    table.insert(allMembersInfoList, temp)
  end
  return allMembersInfoList
end
function logic_chat_voice_data_manager:GetMemberStateByRoomID(roomID, uid)
  local allMemberInfo = self.roomID2AllMembers[roomID]
  return self:_GetMemberStateByUID(allMemberInfo, uid)
end
function logic_chat_voice_data_manager:GetMemberStateByRoomType(roomType, uid)
  local roomID = self.curRoomInfos[roomType].roomID
  local allMemberInfo = self.roomID2AllMembers[roomID]
  return self:_GetMemberStateByUID(allMemberInfo, uid)
end
function logic_chat_voice_data_manager:_GetMemberStateByUID(allMemberInfo, uid)
  if not allMemberInfo or not type(allMemberInfo) == "table" then
    return {
      false,
      false,
      false
    }
  end
  for _, memberInfo in pairs(allMemberInfo) do
    if memberInfo.uid == uid then
      local state = memberInfo.state
      if type(state) == "table" then
        return state
      else
        return logic_chat_voice_utility.DecodeMemberState(state)
      end
    end
  end
  return {
    false,
    false,
    false
  }
end
function logic_chat_voice_data_manager:GetAllMembersInfoByRoomType(roomType)
  local roomID = self.curRoomInfos[roomType].roomID
  return self.roomID2AllMembers[roomID]
end
function logic_chat_voice_data_manager:GetAllMembersInfoByRoomID(roomID)
  return self.roomID2AllMembers[roomID]
end
function logic_chat_voice_data_manager:GetRoomIDByRoomType(roomType)
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:GetRoomIDByRoomType, roomType:%s", roomType))
  log_tree("[muidarzhang] logic_chat_voice_data_manager:GetRoomIDByRoomType self.curRoomInfos:", self.curRoomInfos)
  if self.curRoomInfos[roomType] then
    return self.curRoomInfos[roomType].roomID
  end
  return ""
end
function logic_chat_voice_data_manager:GetSDKCurTeamRoomInfo()
  local curTeamRoomName = slua_GameFrontendHUD:GetVoiceSDKInterface():GetTeamRoomName()
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  if curTeamRoomName == logic_chat_voice_const.NO_TEAM_ROOM_ROOM_NAME then
    return -1
  end
  local curTeamRoomType = logic_chat_voice_data_manager:GetRoomTypeByRoomID(curTeamRoomName)
  if curTeamRoomType == nil then
    return -1
  end
  return curTeamRoomType, curTeamRoomName
end
function logic_chat_voice_data_manager:GetRoomTypeByRoomID(roomID)
  log_tree("[muidarzhang] logic_chat_voice_data_manager:GetRoomTypeByRoomID self.curRoomInfos:", self.curRoomInfos)
  local tmpRoomType
  for roomType, roomInfo in pairs(self.curRoomInfos) do
    if roomInfo.roomID == roomID then
      tmpRoomType = roomType
    end
  end
  if tmpRoomType == nil then
    log_tree("[muidarzhang] logic_chat_voice_data_manager:GetRoomTypeByRoomID self.lastRoomInfos:", self.curRoomInfos)
    for roomType, roomInfo in pairs(self.lastRoomInfos) do
      if roomInfo.roomID == roomID then
        log_warning(bWriteLog and string.format("warning: logic_chat_voice_data_manager:GetRoomTypeByRoomID, founded roomID in lastRoomInfos, roomID:%s, roomType:%s", roomID, roomType))
        tmpRoomType = roomType
      end
    end
  end
  return tmpRoomType
end
function logic_chat_voice_data_manager:GetMemberUidByAntsVoiceUid(roomID, antsVoiceUid)
  local allMemberInfo = self.roomID2AllMembers[roomID]
  if not allMemberInfo then
    return
  end
  local memberInfo = allMemberInfo[antsVoiceUid]
  if memberInfo then
    return memberInfo.uid
  end
end
function logic_chat_voice_data_manager:GetCurRoomInfoByRoomType(roomType)
  return self.curRoomInfos[roomType] or {}
end
function logic_chat_voice_data_manager:GetCurRoomType()
  log(bWriteLog and string.format("logic_chat_voice_data_manager:GetCurRoomType, self.curRoomType:%s", self.curRoomType))
  return self.curRoomType
end
function logic_chat_voice_data_manager:GetCurRoomID()
  local curRoomID = ""
  if self.curRoomInfos and self.curRoomType then
    curRoomID = TableUtil.GetTableValue(self.curRoomInfos, self.curRoomType, "roomID") or ""
  end
  log(bWriteLog and string.format("[muidarzhang] logic_chat_voice_data_manager:GetCurRoomID, curRoomID:%s", curRoomID))
  return curRoomID
end
function logic_chat_voice_data_manager:GetAntsVoiceUidByRoomType(roomType)
  return TableUtil.GetTableValue(self.curRoomInfos, roomType, "antsVoiceUID") or 0
end
function logic_chat_voice_data_manager:GetAntsVoiceUrlByRoomType(roomType)
  return TableUtil.GetTableValue(self.curRoomInfos, roomType, "antsVoiceUrl") or ""
end
return logic_chat_voice_data_manager