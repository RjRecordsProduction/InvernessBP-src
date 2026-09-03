local super_list = require("common.super_list")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local logic_world_cup_chat_pk = {current_topicId = nil, MAX_MESSAGE_NUM = 200}
local chatMessageList = super_list.Create()
function logic_world_cup_chat_pk.AddNewChat(chatMsg)
  if #chatMessageList >= logic_world_cup_chat_pk.MAX_MESSAGE_NUM then
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  chatMessageList:AppendItem(chatMsg)
end
function logic_world_cup_chat_pk.GetMessageList()
  return chatMessageList
end
function logic_world_cup_chat_pk.SendMsg(content)
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.WorldChat) then
    return
  end
  local satisfy = logic_world_cup_chat_pk.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "send msg has no right to chat")
    return
  end
  local msg = {}
  msg.text = content
  msg.topic = logic_world_cup_chat_pk.current_topicId
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = 0
  msg.quickMsg = false
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelWorldCupPK, msgId, msg)
end
function logic_world_cup_chat_pk.SendVoiceMsg(voiceId, length, content)
  local satisfy = logic_world_cup_chat_pk.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "send msg has no right to chat")
    return
  end
  if nil == voiceId or "" == voiceId then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local msg = {}
  msg.text = content
  msg.voice = voiceId
  msg.voiceLength = length
  msg.msgType = chat_macro.VoiceChatMsgType
  msg.quickMsg = false
  msg.topic = logic_world_cup_chat_pk.current_topicId
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelWorldCupPK, msgId, msg)
end
function logic_world_cup_chat_pk.SendHornMsg(content)
  local satisfy = logic_world_cup_chat_pk.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "SendHornMsg has no right to chat")
    return
  end
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local msg = logic_chat_channel_world.SetHornMsg(content, logic_world_cup_chat_pk.current_topicId)
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelWorldCupPK, msgId, msg)
end
function logic_world_cup_chat_pk.CheckHasRightToChat()
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  return logic_chat_channel_world.CheckHasRightToChat()
end
function logic_world_cup_chat_pk.ClearData()
  logic_chat_table_pool.RecycleAll(chatMessageList)
  logic_world_cup_chat_pk.pkInfo = nil
end
function logic_world_cup_chat_pk.on_subscribe_world_cup_rsp(topic_id)
  logic_world_cup_chat_pk.backup_channel_info()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  logic_chat_main.SetCurrentChannel(chat_macro.Channel.channelWorldCupPK)
  logic_world_cup_chat_pk.current_topicId = topic_id
end
function logic_world_cup_chat_pk.backup_channel_info()
  if not logic_world_cup_chat_pk.backup_currentChannel then
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    logic_world_cup_chat_pk.backup_currentChannel = logic_chat_main.currentChannel
  end
end
function logic_world_cup_chat_pk.recover_channel_info()
  if logic_world_cup_chat_pk.backup_currentChannel then
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    logic_chat_main.SetCurrentChannel(logic_world_cup_chat_pk.backup_currentChannel)
    logic_world_cup_chat_pk.backup_currentChannel = nil
  end
end
function logic_world_cup_chat_pk.SetPKInfo(pkInfo)
  logic_world_cup_chat_pk.end
function logic_world_cup_chat_pk.GetPKInfo()
  return logic_world_cup_chat_pk.pkInfo
end
return logic_world_cup_chat_pk