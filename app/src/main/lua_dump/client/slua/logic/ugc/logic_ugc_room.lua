local Logic_UGC_Room = {
  roomList = nil,
  bReqRoomList = false,
  bCanGetMoreList = false,
  bGetMore = false,
  bjoinRoom = false
}
function Logic_UGC_Room:ClearData()
  self.roomList = nil
  self.bReqRoomList = false
  self.bCanGetMoreList = false
  self.bGetMore = false
end
function Logic_UGC_Room:SetCanGetMoreList(result)
  self.bCanGetMoreList = result
end
function Logic_UGC_Room:IsQueryRoomList()
  return self.bReqRoomList
end
function Logic_UGC_Room:SetjoinRoomAnimation(bool)
  self.bjoinRoom = bool
end
function Logic_UGC_Room:GetjoinRoomAnimation()
  return self.bjoinRoom
end
function Logic_UGC_Room:ShowRoomWaitingUI()
  log(bWriteLog and "Logic_UGC_Room:ShowRoomWaitingUI")
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimerOnce(0.5, function()
    local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
    log(bWriteLog and "Logic_UGC_Room:ShowRoomWaitingUI IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
    if not IsInLobbyOrMainCity then
      return
    end
    local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
    local task = {
      module = self,
      funcName = "_RealShowRoomWaitingUI",
      param = self,
      debugInfo = "Logic_UGC_Room:_RealShowRoomWaitingUI",
      protect = true
    }
    queue_task_module:Enqueue(queue_task_module.TaskEnum.Room, task)
  end)
end
function Logic_UGC_Room:_RealShowRoomWaitingUI()
  log(bWriteLog and "Logic_UGC_Room:_RealShowRoomWaitingUI")
  log_tree(bWriteLog and "Logic_UGC_Room._RealShowRoomWaitingUI RoomSystem.CurrentRoomInfo = ", RoomSystem.CurrentRoomInfo)
  if RoomSystem.CurrentRoomInfo == nil or not next(RoomSystem.CurrentRoomInfo) then
    log(bWriteLog and "Logic_UGC_Room._RealShowRoomWaitingUI RoomSystem.CurrentRoomInfo is nil")
    return
  end
  if RoomSystem.CurrentRoomInfo.id == nil then
    log(bWriteLog and "_RealShowRoomWaitingUI RoomSystem.CurrentRoomInfo.id is nil")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.UGCRoomWaitingPanel)
end
function Logic_UGC_Room:IsShowWaiting()
  UIManager.IsUIShow(UIManager.UI_Config.UGCRoomWaitingPanel)
end
function Logic_UGC_Room:GetRoomList(template_type)
  if not self.roomList then
    return {}
  end
  if not self.roomList[template_type] then
    return {}
  end
  return self.roomList[template_type]
end
function Logic_UGC_Room:ReqEnterRoom(roomID, pwd, enterType)
  if not roomID or roomID == 0 then
    log(bWriteLog and "[UGC] Logic_UGC_Room:EnterRoom roomID is error!!!!!!")
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  RoomSystem.req_join_room(roomID, pwd, nil, enterType)
end
function Logic_UGC_Room:ReqExitRoom()
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_exit_room(tonumber(DataMgr.roleData.uid))
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  CreateRoomSystem.IsFromDeepLink = false
  RoomSystem.SelfLeave = true
end
function Logic_UGC_Room:ReqStartRoomGame()
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_start_game_request()
end
function Logic_UGC_Room:ReqQueryRoom(roomID)
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_query_room_password_state_req(roomID)
end
function Logic_UGC_Room:SetRequestCount(requestCount)
  self.shouldRequestCount = requestCount
end
function Logic_UGC_Room:ReqRoomList(zoneID, page, templateType)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  page = page or 1
  if 1 < page then
    self.bGetMore = true
  end
  self.bReqRoomList = true
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_query_rooms_req(Config_UGC.RoomListType, zoneID, nil, page, templateType)
  log(bWriteLog and string.format("[UGC] Logic_UGC_Room:ReqRoomList, zoneID: %d, page: %d, templateType: %d", zoneID, page, templateType))
end
function Logic_UGC_Room:ReqModItemRoomList(modInfo)
  if not modInfo then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local config = Config_UGC.GetTemplateConfigByID(modInfo.base.template_id)
  self.bReqRoomList = true
  self:SetRequestCount(1)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.nChooseZoneID
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_query_rooms_req(Config_UGC.DetailRoomListType, zoneID, nil, nil, config.Type, modInfo.mod_id)
end
function Logic_UGC_Room:ReqCreateRoom(params)
  if not params or not next(params) then
    log_warning(bWriteLog and "[UGC] Logic_UGC:ReqCreateRoom param is error")
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local CreateRoomHandler = require("client.network.Protocol.CreateRoomHandler")
  CreateRoomHandler.send_create_room_request(params.name, nil, params.pwd, nil, nil, nil, Config_UGC.RoomType, nil, nil, nil, nil, params.modID)
  local LogicUGCExposure = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCExposure)
  LogicUGCExposure:ClearMayState()
end
function Logic_UGC_Room:OnSyncRoomList(list, page, total, template_type)
  self.bReqRoomList = false
  if not list then
    return
  end
  if not self.roomList then
    self.roomList = {}
  end
  if not self.roomList[template_type] then
    self.roomList[template_type] = {}
  end
  if 0 < total and next(list) then
    self.bCanGetMoreList = true
    if page == 1 and not self.bGetMore then
      self.roomList[template_type] = {}
      for i, v in pairs(list) do
        table.insert(self.roomList[template_type], v)
      end
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      table.sort(self.roomList[template_type], function(a, b)
        if a.state == b.state then
          return a.create_time > b.create_time
        else
          return a.state == Config_UGC.IdleState
        end
      end)
    else
      local isExist
      for _roomIndex = 1, total do
        isExist = false
        local newRoom = list[_roomIndex]
        if newRoom then
          for ii, oldRoom in ipairs(self.roomList[template_type]) do
            if oldRoom.id == newRoom.id then
              self.roomList[template_type][ii] = newRoom
              isExist = true
              break
            end
          end
          if not isExist then
            table.insert(self.roomList[template_type], newRoom)
          end
        end
      end
    end
  else
    self.roomList[template_type] = {}
  end
  self.bGetMore = false
  self.shouldRequestCount = self.shouldRequestCount - 1
  if self.shouldRequestCount == 0 then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UPDATE_ROOM_LIST)
  end
  log(bWriteLog and string.format("[UGC] Logic_UGC_Room:OnSyncRoomList, page: %d, list count: %d, total: %d, templateType: %d", page, #list, total, template_type))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCRoom = class(CModuleBase, nil, Logic_UGC_Room)
return CLogicUGCRoom