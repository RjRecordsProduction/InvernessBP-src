local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local super_list = require("common.super_list")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local chatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 200
local logic_chat_channel_waiting_room = {}
local UpdateRedpoint = function(show)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.WaitingRoom, show)
end
function logic_chat_channel_waiting_room.ClearData()
  chatMessageList:ClearData()
end
function logic_chat_channel_waiting_room.AddNewChat(chatMsg)
  if #chatMessageList >= MAX_MESSAGE_NUM then
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if logic_chat_main.currentChannel ~= chat_macro.Channel.WaitingRoom and logic_chat_main.currentChannel ~= chat_macro.Channel.WaitingRoomTeam then
    UpdateRedpoint(true)
  end
  chatMessageList:AppendItem(chatMsg)
end
function logic_chat_channel_waiting_room.GetCurrentRoomMessageList()
  local RoomSystem = require("client.logic.login.logic_room")
  local roomId = RoomSystem.CurrentRoomInfo.id
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].content and chatMessageList[k].content.roomId ~= roomId then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
  return chatMessageList
end
function logic_chat_channel_waiting_room.GetMessageList()
  return chatMessageList
end
function logic_chat_channel_waiting_room.SendMsg(content)
  local msg = {}
  msg.voice = ""
  msg.text = content
  msg.voiceLength = 0
  msg.quickMsg = false
  msg.msgType = 0
  local RoomSystem = require("client.logic.login.logic_room")
  msg.roomId = RoomSystem.CurrentRoomInfo.id
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.WaitingRoom, msgId, msg)
end
function logic_chat_channel_waiting_room.SendVoiceMsg(voiceId, length, content)
  if nil == voiceId or "" == voiceId then
    return
  end
  local msg = {}
  msg.voice = voiceId
  msg.text = content
  msg.voiceLength = length
  msg.quickMsg = false
  msg.msgType = chat_macro.VoiceChatMsgType
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.WaitingRoom, msgId, msg)
end
function logic_chat_channel_waiting_room.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_waiting_room.ClearRedPointInfo()
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.WaitingRoom, false)
end
return logic_chat_channel_waiting_room