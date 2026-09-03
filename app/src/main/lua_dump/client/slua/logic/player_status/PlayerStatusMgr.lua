local PlayerStatusMgr = {}
function PlayerStatusMgr:OnInitialize()
  PlayerStatusMgr.__super.OnInitialize(self)
  self:AddCommonEvent(EVENTTYPE_ROOM, EVENTID_GET_ROOMINFO, self.OnGetRoomInfo, self)
end
function PlayerStatusMgr:OnDestroy()
  self:RemoveCommonEvent(EVENTTYPE_ROOM, EVENTID_GET_ROOMINFO)
  PlayerStatusMgr.__super.OnDestroy(self)
end
function PlayerStatusMgr:DefineAndResetData()
  self.statusMap = {}
  self.typeRequestMap = {}
  self.typeCallBackMap = {}
  self.modInfoCallbacks = {}
  self.queryRoomIdCallbacks = {}
  self.roomInfoCallbacks = {}
  self.enableRequestModInfo = true
  self.requestModeInfoPandingList = {}
  self.needUpdateWoWInfoPlayerIdList = {}
end
function PlayerStatusMgr:GetStatusData(uid)
  if not self.statusMap[uid] then
    return nil
  end
  return self.statusMap[uid]
end
function PlayerStatusMgr:GetOrReqStatusData(type, uidList, callBack)
  local listUnGot = {}
  local infos = {}
  local index = 1
  local gapTime = ENUM_BATCH_GET_GROUP_AND_ONLINE_GAP[type] or ENUM_BATCH_GET_GROUP_AND_ONLINE_GAP.Default
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(uidList) do
    local statusData = self:GetStatusData(v)
    if statusData and statusData.rspTime and gapTime > serverTime - statusData.rspTime then
      infos[v] = statusData
    else
      listUnGot[index] = v
      index = index + 1
    end
  end
  if 0 < #listUnGot then
    self:send_batch_get_group_and_online_req(type, listUnGot)
    self.typeRequestMap[type] = uidList
    self.typeCallBackMap[type] = callBack
  elseif callBack then
    callBack(infos)
  end
end
function PlayerStatusMgr:send_batch_get_group_and_online_req(type, uidList)
  log(bWriteLog and "PlayerStatusMgr:send_batch_get_group_and_online_req type = " .. tostring(type))
  local StatusHandler = require("client.network.Protocol.StatusHandler")
  StatusHandler.send_batch_get_group_and_online_req(type, uidList)
end
function PlayerStatusMgr:IsNeedUpdateWoWInfo()
  if next(self.needUpdateWoWInfoPlayerIdList) then
    local StatusHandler = require("client.network.Protocol.StatusHandler")
    StatusHandler.send_batch_get_group_and_online_req(ENUM_BATCH_GET_GROUP_AND_ONLINE.TeamUpStranger, self.needUpdateWoWInfoPlayerIdList)
    self.needUpdateWoWInfoPlayerIdList = {}
  end
end
function PlayerStatusMgr:GetIsVideoInspect(uid)
  if not self.statusMap[uid] or not self.statusMap[uid].is_video_inspect then
    return false
  end
  return self.statusMap[uid].is_video_inspect
end
function PlayerStatusMgr:QueryFriendRoom(friend_uid, callback)
  if not self.queryRoomIdCallbacks[friend_uid] then
    self.queryRoomIdCallbacks[friend_uid] = {callback}
    local StatusHandler = require("client.network.Protocol.StatusHandler")
    StatusHandler.send_query_friend_room_id(friend_uid)
  else
    table.insert(self.queryRoomIdCallbacks[friend_uid], callback)
  end
end
function PlayerStatusMgr:OnQueryFriendRoom(friend_uid, roomId)
  if self.queryRoomIdCallbacks[friend_uid] then
    for i, callback in ipairs(self.queryRoomIdCallbacks[friend_uid]) do
      callback(roomId)
    end
    self.queryRoomIdCallbacks[friend_uid] = nil
  end
end
function PlayerStatusMgr:GetModInfoById(mod_id, callback)
  if not mod_id or mod_id <= 0 then
    return
  end
  if not self.modInfoCallbacks[mod_id] then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local modInfo = LogicUGC:GetModByWithoutPubCache(mod_id)
    if modInfo and modInfo.pub_mod_meta then
      self:AddTimerOnce(0, function()
        callback(modInfo.pub_mod_meta)
      end)
    else
      self.modInfoCallbacks[mod_id] = {callback}
    end
  else
    table.insert(self.modInfoCallbacks[mod_id], callback)
  end
end
function PlayerStatusMgr:RequestModInfoByIds(mod_ids)
  local valids = {}
  local hasInvalid = false
  for i, mod_id in ipairs(mod_ids) do
    if 0 < mod_id then
      valids[#valids + 1] = mod_id
    end
  end
  if #valids == 0 then
    return
  end
  if not self.enableRequestModInfo then
    for i, modId in ipairs(valids) do
      self.requestModeInfoPandingList[#self.requestModeInfoPandingList + 1] = modId
    end
    return
  end
  local t = {}
  for i, mod_id in ipairs(valids) do
    t[mod_id] = true
  end
  valids = {}
  for mod_id, _ in pairs(t) do
    valids[#valids + 1] = mod_id
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:BatchGetModInfo(valids, LogicUGC.C_ModListTypes.FirendStatus)
end
function PlayerStatusMgr:RequestModInfoByIdDelay(mod_id)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modInfo = LogicUGC:GetModByWithoutPubCache(mod_id)
  if modInfo then
    return
  end
  if not self.enableRequestModInfo then
    self.requestModeInfoPandingList[#self.requestModeInfoPandingList + 1] = mod_id
    return
  end
  if not self.requestTimer then
    self.requestTimer = self:AddTimerLoop(0, function()
      if self.delayRequestModIds and #self.delayRequestModIds > 0 then
        self:RequestModInfoByIds(self.delayRequestModIds)
        self.delayRequestModIds = nil
      end
    end, TIMER_INFINITE, 20)
  end
  if not self.delayRequestModIds then
    self.delayRequestModIds = {}
  end
  table.insert(self.delayRequestModIds, mod_id)
end
function PlayerStatusMgr:SetEnableRequestModInfo(enable)
  if self.enableRequestModInfo == enable then
    return
  end
  self.enableRequestModInfo = enable
  if enable then
    if #self.requestModeInfoPandingList > 0 then
      self:RequestModInfoByIds(self.requestModeInfoPandingList)
      self.requestModeInfoPandingList = {}
    end
  else
    if self.delayRequestModIds then
      for i, modId in ipairs(self.delayRequestModIds) do
        self.requestModeInfoPandingList[#self.requestModeInfoPandingList + 1] = modId
      end
    end
    self.delayRequestModIds = nil
  end
end
function PlayerStatusMgr:OnModInfoBatchRsp(MetaList, ReqListType, ClientParam, filter_offline_mod_list)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if ReqListType ~= LogicUGC.C_ModListTypes.FirendStatus then
    return
  end
  for mod_id, info in pairs(MetaList) do
    if self.modInfoCallbacks[mod_id] then
      for i, callback in ipairs(self.modInfoCallbacks[mod_id]) do
        callback(info.pub_mod_meta)
      end
      self.modInfoCallbacks[mod_id] = nil
    end
  end
end
function PlayerStatusMgr:GetRoomInfo(roomId, callback)
  if not self.roomInfoCallbacks[roomId] then
    self.roomInfoCallbacks[roomId] = {callback}
    if not self.queryRoomInfoQueue or #self.queryRoomInfoQueue == 0 then
      self.queryRoomInfoQueue = {roomId}
      self:_QueryRoomInfoDelay()
    else
      table.insert(self.queryRoomInfoQueue, roomId)
    end
  else
    table.insert(self.roomInfoCallbacks[roomId], callback)
  end
end
function PlayerStatusMgr:OnGetRoomInfo(_, _, roomId, roomInfo)
  if self.roomInfoCallbacks[roomId] then
    if roomInfo then
      for i, callback in ipairs(self.roomInfoCallbacks[roomId]) do
        callback(roomInfo)
      end
    end
    self.roomInfoCallbacks[roomId] = nil
  end
  table.remove(self.queryRoomInfoQueue, 1)
  self:_QueryRoomInfoDelay()
end
function PlayerStatusMgr:_QueryRoomInfoDelay()
  if #self.queryRoomInfoQueue > 0 then
    self:AddTimerOnce(1, function()
      local nextRoomId = self.queryRoomInfoQueue[1]
      local RoomHandler = require("client.network.Protocol.RoomHandler")
      RoomHandler.send_query_room_request(nextRoomId)
    end)
  end
end
function PlayerStatusMgr:on_batch_get_group_and_online_rsp(listType, res, infos)
  if res ~= NetErrorCode_NONE then
    log(bWriteLog and string.format("PlayerStatusMgr:on_batch_get_group_and_online_rsp res:%s", res))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for uid, v in pairs(infos) do
    v.    v.rspTime = serverTime
    if not v.cwow_type then
      v.cwow_type = 0
    end
    self.statusMap[uid] = v
    v.teamState = v.teamStateNew
    local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
    PlayerStatusUtil.HandleCommonStatusInfo(v)
  end
  for k, v in pairs(self.typeRequestMap[listType] or {}) do
    infos[v] = self:GetStatusData(v)
  end
  if self.typeCallBackMap[listType] and type(self.typeCallBackMap[listType]) == "function" then
    self.typeCallBackMap[listType](infos)
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:SetForceUpdateReserveData()
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_BATCH_GET_PLAYERSTATUS, infos)
  local logic_online_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_online_status)
  logic_online_status:proc_batch_get_group_and_online_rsp(listType, res, infos)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  logic_profile:proc_batch_get_group_and_online_rsp(listType, res, infos)
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.on_batch_get_group_and_online_rsp(listType, res, infos)
end
function PlayerStatusMgr:on_notify_online_status_chg(uid, isOnline)
  if not self.statusMap[uid] then
    self.statusMap[uid] = {}
  end
  self.statusMap[uid].  self.statusMap[uid].online = isOnline
  if isOnline == 0 then
    self.statusMap[uid].tplan_type = 0
    if self.statusMap[uid].is_video_inspect then
      self.statusMap[uid].is_video_inspect = false
    end
    self.statusMap[uid].mod_id = 0
  else
    self.statusMap[uid].teamState = 0
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ONLINE_STATE_CHANGE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GROUP_ONLINE_CHANGE, uid)
end
function PlayerStatusMgr:on_notify_group_status_chg(uid, newStatus)
  if not newStatus then
    return
  end
  log(bWriteLog and "LogicFriend.on_notify_group_status_chg uid===newStatus===: " .. tostring(newStatus.teamStateNew))
  if self:_IsFriendGameStateChanged(self.statusMap[uid], newStatus) then
    local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
    logic_friend_reserve:SetForceUpdateReserveData()
  end
  self:_SetStatusData(uid, newStatus)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GROUP_STATE_CHANGE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GROUP_ONLINE_CHANGE, uid)
end
function PlayerStatusMgr:on_notify_friend_play_hall_room_stat_chg(uid, ph_room_svr_id, play_hall_rooms)
  if not self.statusMap[uid] then
    self.statusMap[uid] = {}
  end
  if not play_hall_rooms then
    self.statusMap[uid].is_in_hall = false
  else
    self.statusMap[uid].is_in_hall = true
    self.statusMap[uid].hall_id = play_hall_rooms.hall_id
    self.statusMap[uid].mod_id = play_hall_rooms.mod_id
    self.statusMap[uid].  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GROUP_ONLINE_CHANGE, from_uid)
end
function PlayerStatusMgr:_IsFriendGameStateChanged(oldData, newData)
  if not oldData then
    return false
  end
  local oldGameId = oldData and oldData.game_id
  local newGameId = newData and newData.game_id
  log(bWriteLog and "[v_wllwu] UpdateOnlineAndGroupInfo beforeGameId = " .. tostring(oldGameId) .. " afterGameId = " .. tostring(newGameId))
  if not oldGameId then
    return newGameId ~= 0
  end
  return oldGameId ~= newGameId
end
function PlayerStatusMgr:_SetStatusData(uid, newStatus)
  if not self.statusMap[uid] then
    self.statusMap[uid] = {}
  end
  local online = self.statusMap[uid].online
  self.statusMap[uid] = newStatus
  self.statusMap[uid].  self.statusMap[uid].teamState = self.statusMap[uid].teamStateNew
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if PlayerStatusUtil.IsStealth(self.statusMap[uid]) then
    self.statusMap[uid].online = 0
  elseif online then
    self.statusMap[uid].  end
  if PlayerStatusUtil.IsBattle(self.statusMap[uid]) or self.statusMap[uid].timeSinceGameBegin and 0 < self.statusMap[uid].timeSinceGameBegin then
    local TimeUtil = require("client.common.time_util")
    self.statusMap[uid].gameBeginTime = TimeUtil.GetServerTimeInSec() - self.statusMap[uid].timeSinceGameBegin
  else
    self.statusMap[uid].gameBeginTime = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_player_status = class(CModuleBase, nil, PlayerStatusMgr)
return Clogic_player_status