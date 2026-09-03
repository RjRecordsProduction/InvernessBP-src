local RoomListSystem = {
  roomInfoList = {},
  bCanGetMoreList = false,
  bGetMore = false,
  nCurZoneID = 0,
  nCurMapID = 0,
  nCurViewType = "",
  nCurTabIndex = 1
}
local _validType = {
  "view_common",
  "view_match",
  "view_ugc"
}
function RoomListSystem.ShowUI(tabIndex, isPCOB)
  RoomListSystem.roomInfoList = {}
  RoomListSystem.bCanGetMoreList = false
  RoomListSystem.nCurTabIndex = tabIndex ~= nil and tabIndex or 1
  UIManager.ShowUI(UIManager.UI_Config.room_list, isPCOB)
end
function RoomListSystem.CanShowUI()
  local uiConfig = UIManager.GetConfigByKey("room_list")
  if not uiConfig then
    log(bWriteLog and "RoomListSystem.CanShowUI UI config not found ")
    return false
  end
  local pak_util = require("client.common.pak_util")
  if not pak_util.IsFileExist(uiConfig.path) then
    log(bWriteLog and "RoomListSystem.CanShowUI uiConfig.path not exist ")
    return false
  end
  log(bWriteLog and "RoomListSystem.CanShowUI uiConfig.path exist ")
  return true
end
function RoomListSystem.ReqRoomList(zoneID, mapID, viewType, page)
  log_tree("[edward][logic_room_list] RoomListSystem.ReqRoomList", {
    zoneID,
    mapID,
    viewType,
    tostring(page)
  })
  zoneID = zoneID or RoomSystem.RoomZoneId
  mapID = mapID or 1
  local isvalidType = false
  for k, v in ipairs(_validType) do
    if viewType and v == viewType then
      isvalidType = true
      break
    end
  end
  viewType = isvalidType and viewType or "view_common"
  page = page or 1
  if 1 < page then
    RoomListSystem.bGetMore = true
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_query_rooms_req(viewType, zoneID, mapID, page)
end
function RoomListSystem.ReqRoomListWhenError()
  if UIManager.IsUIShow(UIManager.UI_Config.room_list) and RoomListSystem.nCurZoneID > 0 and 0 < RoomListSystem.nCurMapID then
    RoomListSystem.ReqRoomList(RoomListSystem.nCurZoneID, RoomListSystem.nCurMapID, RoomListSystem.nCurViewType)
  end
end
function RoomListSystem.ClearTempData()
  RoomListSystem.nCurZoneID = 0
  RoomListSystem.nCurMapID = 0
  RoomListSystem.nCurViewType = ""
end
function RoomListSystem.EnterRoom(roomID, pwd, room_type)
  if not roomID or roomID == 0 then
    log_error(bWriteLog and "[edward][logic_room_list] RoomListSystem.EnterRoom roomID is error!!!!!!")
    return
  end
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  if TournamentsManager.query_room_id == roomID then
    local TournamentHandler = require("client.network.Protocol.TournamentHandler")
    TournamentsManager.joinRoomData = {
      room_id = roomID,
      tournament_id = TournamentsManager.query_tournament_id,
      password = pwd
    }
    TournamentHandler.send_tournament_free_room_join_req(roomID, TournamentsManager.query_tournament_id, pwd)
  else
    RoomSystem.req_join_room(roomID, pwd, nil, room_type)
  end
end
function RoomListSystem.CheckRoomIDValid(id)
  if type(id) ~= "string" then
    return false
  end
  local idLen = string.len(id)
  if idLen <= 0 then
    ShowNotice(110087)
    return false
  end
  for i = 1, idLen do
    local curByte = string.byte(id, i)
    if curByte < 48 or 57 < curByte then
      ShowNotice(110088)
      return false
    end
  end
  return true
end
function RoomListSystem.OnSyncRoomList(view, pos, total)
  if not view then
    return
  end
  if 0 < total and next(view) then
    RoomListSystem.bCanGetMoreList = true
  end
  log_tree("[edward][logic_room_list] RoomListSystem.OnSyncRoomList viewCount= " .. tostring(#view) .. " pos = " .. tostring(pos) .. " total = " .. tostring(total), view)
  if pos == 1 and not RoomListSystem.bGetMore then
    RoomListSystem.roomInfoList = {}
    for i, v in pairs(view) do
      if v.gm_turing == nil then
        table.insert(RoomListSystem.roomInfoList, v)
      end
    end
    table.sort(RoomListSystem.roomInfoList, function(a, b)
      if a.state == b.state then
        return a.create_time > b.create_time
      else
        return b.state == "idle"
      end
    end)
  else
    local turing_count = 0
    for i, v in pairs(view) do
      if v.gm_turing == nil then
      else
        turing_count = turing_count + 1
      end
    end
    local isExist = false
    for _roomIndex = 1, total - turing_count do
      isExist = false
      local info = view[_roomIndex]
      if info then
        for ii, vv in ipairs(RoomListSystem.roomInfoList) do
          if vv.id == info.id then
            RoomListSystem.roomInfoList[ii] = info
            isExist = true
            break
          end
        end
        if not isExist then
          table.insert(RoomListSystem.roomInfoList, info)
        end
      end
    end
  end
  RoomListSystem.bGetMore = false
  if not RoomListSystem.roomInfoList then
    RoomListSystem.roomInfoList = {}
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_UPDATE_ROOM_LIST)
end
function RoomListSystem.OnQueryRoomRespond(room_id, room)
  local version_util = require("client.common.version_util")
  if not version_util.IsMatchVersion(room.version) then
    DataMgr.ShowMessageBoxByID(110091)
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_RESET_ROOM_LIST)
    return
  end
  if room.lock_state then
    UIManager.ShowUI(UIManager.UI_Config.room_list_password_popup, room_id)
  else
    RoomListSystem.EnterRoom(room_id, "")
  end
end
return RoomListSystem