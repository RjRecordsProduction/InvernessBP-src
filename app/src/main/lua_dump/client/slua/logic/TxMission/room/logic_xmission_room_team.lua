local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
local LogicTxMissionTeam = require("client.slua.logic.TxMission.logic_xmission_team")
local logic_xmission_room_team = {}
function logic_xmission_room_team:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_BE_KICKED, self.QuitRoomTeam, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_BE_DISBAND, self.QuitRoomTeam, self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_ROOM_MEMBER_UPDATE, self.on_sync_room_member, self)
end
function logic_xmission_room_team:IsSelfInXmissionRoom()
  if not RoomSystem.CurrentRoomInfo or not next(RoomSystem.CurrentRoomInfo) then
    return false
  end
  local mapInfo = CDataTable.GetTableData("Map", RoomSystem.CurrentRoomInfo.map_id)
  if not mapInfo then
    return false
  end
  if not RoomSystem.CurrentRoomInfo.room_type or RoomSystem.CurrentRoomInfo.room_type ~= CreateRoomConfig.C_RoomTypeMap.TMode and RoomSystem.CurrentRoomInfo.room_type ~= CreateRoomConfig.C_RoomTypeMap.TMatch then
    return false
  end
  return true
end
function logic_xmission_room_team:QuitRoomTeam()
  log(bWriteLog and "logic_xmission_room_team:QuitRoomTeam")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    log(bWriteLog and "logic_xmission_room_team:QuitRoomTeam return in team")
    return
  end
  LogicTxMissionTeam.ClearDataRemainSelf()
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  XMissionAvatarMgr.DestroyTeamAvatar()
  XMissionAvatarMgr.ShowAllAvatar()
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ROOM_MEMBER_CHANGE)
end
function logic_xmission_room_team:SyncRoomMember()
  log(bWriteLog and "logic_xmission_room_team:SyncRoomMember")
  if not self:IsSelfInXmissionRoom() then
    self:QuitRoomTeam()
    return
  end
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  XMissionAvatarMgr.DestroyTeamAvatar()
  LogicTxMissionTeam.ClearDataRemainSelf()
  local uids, members = RoomSystem.GetSelfTeamIds()
  if not members or not next(members) then
    return
  end
  for k, v in ipairs(uids) do
    if members[k] and members[k].tmode_room_team_info then
      LogicTxMissionTeam.CreateAvatarInfo(v, members[k].tmode_room_team_info)
      LogicTxMissionTeam.SetTeamInfo(v, members[k].tmode_room_team_info, 1)
    end
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ROOM_MEMBER_CHANGE)
end
function logic_xmission_room_team:on_sync_room_member()
  log(bWriteLog and "logic_xmission_room_team:on_sync_room_member")
  if not self:IsSelfInXmissionRoom() then
    log(bWriteLog and "logic_xmission_room_team:on_sync_room_member quit")
    self:QuitRoomTeam()
    return
  end
  local uids = RoomSystem.GetSelfTeamIds()
  local bIsChange = false
  local roomCount = 0
  for k, v in ipairs(uids) do
    roomCount = roomCount + 1
    if not LogicTxMissionTeam.teamInfo[tostring(v)] then
      bIsChange = true
      break
    end
  end
  local teamCount = 0
  for k, v in pairs(LogicTxMissionTeam.teamInfo) do
    teamCount = teamCount + 1
  end
  if teamCount ~= roomCount then
    bIsChange = true
  end
  log(bWriteLog and string.format("logic_xmission_room_team:on_sync_room_member %s, %s", roomCount, teamCount))
  if bIsChange then
    log(bWriteLog and "logic_xmission_room_team:on_sync_room_member changed")
    self:SyncRoomMember()
  end
end
function logic_xmission_room_team:GetTeamNum()
  local uids, members = RoomSystem.GetSelfTeamIds()
  return #uids
end
function logic_xmission_room_team:GetTeamMembers()
  if not self:IsSelfInXmissionRoom() then
    log(bWriteLog and "logic_xmission_room_team:GetTeamMembers not self:IsSelfInXmissionRoom")
    local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
    return logic_team_up.teamInfo and logic_team_up.teamInfo.members or {}
  end
  local result = {}
  local uids, members = RoomSystem.GetSelfTeamIds()
  for k, v in ipairs(uids) do
    if members and members[k] and members[k].tmode_room_team_info then
      result[v] = members[k].tmode_room_team_info
    end
  end
  return result
end
function logic_xmission_room_team:GetMemberInfo(UId)
  if not self:IsSelfInXmissionRoom() then
    local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
    return logic_team_up.GetMemberInfo(UId)
  end
  for k, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList or {}) do
    if v.openid == tostring(UId) then
      return v.tmode_room_team_info
    end
  end
  return nil
end
function logic_xmission_room_team:GetRowMemberInfo(UId)
  if not self:IsSelfInXmissionRoom() then
    local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
    return logic_team_up.GetMemberInfo(UId)
  end
  for k, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList or {}) do
    if v.openid == tostring(UId) then
      return v
    end
  end
  return nil
end
function logic_xmission_room_team:on_tmode_room_team_info_notify(room_id, uid, change_key, change_value)
  for k, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList or {}) do
    if v.openid == tostring(uid) and v.tmode_room_team_info then
      v.tmode_room_team_info[change_key] = change_value
    end
  end
  if change_key == "avatar_info" then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_MEMBER_CHANGE, uid)
  else
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TEAM_INFO_SYNC, uid)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_xmission_room_team)