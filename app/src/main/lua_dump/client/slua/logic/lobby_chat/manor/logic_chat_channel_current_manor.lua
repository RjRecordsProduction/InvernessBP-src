local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local super_list = require("common.super_list")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local chatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 200
local logic_chat_channel_current_manor = {}
local UpdateRedpoint = function(show)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelCurrentManor, show)
end
function logic_chat_channel_current_manor.ClearData()
  chatMessageList:ClearData()
end
function logic_chat_channel_current_manor.AddNewChat(chatMsg)
  if #chatMessageList >= MAX_MESSAGE_NUM then
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if logic_chat_main.currentChannel ~= chat_macro.Channel.channelCurrentManor then
    UpdateRedpoint(true)
  end
  chatMessageList:AppendItem(chatMsg)
end
function logic_chat_channel_current_manor.GetMessageList()
  return chatMessageList
end
function logic_chat_channel_current_manor.SendMsg(content)
  local msg = {}
  msg.voice = ""
  msg.text = content
  msg.voiceLength = 0
  msg.msgType = 0
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  if logic_chat_manor_topic:ChatByDS() then
    log(bWriteLog and "logic_chat_channel_current_manor.SendMsg ChatByDS")
    local PlanPHChatNetClient = require("GameLua.Mod.PlanPH.Client.Logic.Chat.PlanPHChatNetClient")
    PlanPHChatNetClient.send_chat_req(0, chat_macro.Channel.channelCurrentManor, msgId, msg)
  else
    log(bWriteLog and "logic_chat_channel_current_manor.SendMsg Chat By Lobby Server")
    local current_topic_id = logic_chat_manor_topic:GetCurrentTopicId()
    if not current_topic_id then
      log(bWriteLog and "logic_chat_channel_global_manor.SendMsg no current_topic_id")
      return
    end
    msg.topic = current_topic_id
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    ChatHandler.send_chat_req(0, chat_macro.Channel.channelCurrentManor, msgId, msg)
  end
end
function logic_chat_channel_current_manor.SendVoiceMsg(voiceId, length, content)
  if nil == voiceId or "" == voiceId then
    return
  end
  local msg = {}
  msg.voice = voiceId
  msg.text = content
  msg.voiceLength = length
  msg.msgType = chat_macro.VoiceChatMsgType
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  if logic_chat_manor_topic:ChatByDS() then
    log(bWriteLog and "logic_chat_channel_current_manor.SendVoiceMsg ChatByDS")
    local PlanPHChatNetClient = require("GameLua.Mod.PlanPH.Client.Logic.Chat.PlanPHChatNetClient")
    PlanPHChatNetClient.send_chat_req(0, chat_macro.Channel.channelCurrentManor, msgId, msg)
  else
    log(bWriteLog and "logic_chat_channel_current_manor.SendVoiceMsg Chat By Lobby Server")
    local current_topic_id = logic_chat_manor_topic:GetCurrentTopicId()
    if not current_topic_id then
      log(bWriteLog and "logic_chat_channel_global_manor.SendVoiceMsg no current_topic_id")
      return
    end
    msg.topic = current_topic_id
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    ChatHandler.send_chat_req(0, chat_macro.Channel.channelCurrentManor, msgId, msg)
  end
end
function logic_chat_channel_current_manor.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_current_manor.ClearRedPointInfo()
  UpdateRedpoint(false)
end
return logic_chat_channel_current_manor