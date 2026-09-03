local LogicJoinMicrophone = {}
function LogicJoinMicrophone:DefineAndResetData()
  self.openMicList = {}
end
function LogicJoinMicrophone:PushOpenMic(openMicType, inviter_uid)
  log(bWriteLog and "LogicJoinMicrophone:PushOpenMic")
  if not self:CanInsertMsg(openMicType, inviter_uid) then
    return
  end
  table.insert(self.openMicList, {type = openMicType, inviter_uid = inviter_uid})
  self:ShowOpenMic()
end
function LogicJoinMicrophone:ShowOpenMic()
  if next(self.openMicList) then
    log(bWriteLog and "LogicJoinMicrophone:ShowOpenMic pop")
    EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_SHOW_OPEN_MIC, self.openMicList[1])
  else
    log(bWriteLog and "LogicJoinMicrophone:ShowOpenMic no invite")
    EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_HIDE_OPEN_MIC)
  end
end
function LogicJoinMicrophone:ShowNextOpenMic(inviter_uid)
  log(bWriteLog and "LogicJoinMicrophone:ShowNextOpenMic")
  if next(self.openMicList) and self.openMicList[1].inviter_uid == inviter_uid then
    log(bWriteLog and "LogicJoinMicrophone:ShowNextOpenMic remove")
    table.remove(self.openMicList, 1)
  end
  self:ShowOpenMic()
end
function LogicJoinMicrophone:CleanData()
  log(bWriteLog and "LogicJoinMicrophone:CleanData")
  self.openMicList = {}
end
function LogicJoinMicrophone:CanInsertMsg(openMicType, inviter_uid)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local roomId = logic_chat_channel_chat_room.GetMyChatRoomId()
  if tonumber(roomId) == 0 then
    log(bWriteLog and "LogicJoinMicrophone:CanInsertMsg I am not in room")
    return false
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  if openMicType == LogicChatRoomMacro.OpenMicType.Invite then
    local myChannel = logic_chat_channel_chat_room.GetMyChannel()
    if myChannel.channel_info.channel_owner ~= inviter_uid then
      log(bWriteLog and "LogicJoinMicrophone:CanInsertMsg inviter not master")
      return false
    end
    if logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
      log(bWriteLog and "LogicJoinMicrophone:CanInsertMsg I am not visitor")
      return false
    end
  end
  if openMicType == LogicChatRoomMacro.OpenMicType.Apply then
    local myChannel = logic_chat_channel_chat_room.GetMyChannel()
    if myChannel.channel_info.channel_owner == inviter_uid then
      log(bWriteLog and "LogicJoinMicrophone:CanInsertMsg inviter not visitor")
      return false
    end
    if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
      log(bWriteLog and "LogicJoinMicrophone:CanInsertMsg I am not master")
      return false
    end
  end
  log(bWriteLog and "LogicJoinMicrophone:CanInsertMsg can")
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicJoinMicrophone = class(CModuleBase, nil, LogicJoinMicrophone)
return CLogicJoinMicrophone