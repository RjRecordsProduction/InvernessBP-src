local logic_chat_channel_team = {}
local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
local macro = require("client.slua.logic.lobby_chat.chat_macro")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local super_list = require("common.super_list")
local chatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 200
function logic_chat_channel_team.SendMsg(content)
  local msg = {}
  msg.voice = ""
  msg.text = content
  msg.voiceLength = 0
  msg.quickMsg = false
  msg.msgType = 0
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelTeam, msgId, msg)
end
function logic_chat_channel_team.SendVoiceMsg(voiceId, length, content)
  local msg = {}
  msg.voice = voiceId
  msg.text = content
  msg.voiceLength = length
  msg.quickMsg = false
  msg.msgType = macro.VoiceChatMsgType
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelTeam, msgId, msg)
end
function logic_chat_channel_team.SendAchivementShare(achievementShareId, finishTime)
  local channel = macro.Channel.channelTeam
  local content = LocUtil.GetLocalizeResStr("5027")
  local other = {}
  other.achievementId = achievementShareId
  other.finish_time = finishTime
  local msg = {}
  msg.text = content
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.achivementMsgType
  msg.quickMsg = false
  msg.  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_team.AddNewChat(chatMsg)
  if #chatMessageList >= MAX_MESSAGE_NUM then
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  chatMessageList:AppendItem(chatMsg)
  if chat_main.currentChannel ~= macro.Channel.channelTeam then
    local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
    logic_chat_channel_manager:UpdateChannelRedPoint(macro.Channel.channelTeam, true)
  end
  logic_chat_channel_team.ShowTeamChatMsg(chatMsg)
end
function logic_chat_channel_team.GetMessageList()
  return chatMessageList
end
function logic_chat_channel_team.SendQuickMsg(content)
  if nil == content or "" == content then
    return
  end
  local msg = {
    voice = "",
    text = content,
    voiceLength = 0,
    quickMsg = true,
    msgType = 0,
    msgID = content
  }
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelTeam, msgId, msg)
end
function logic_chat_channel_team.ClearData()
  logic_chat_table_pool.RecycleAll(chatMessageList)
end
function logic_chat_channel_team.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_team.ShowTeamChatMsg(chatMsg)
  if chatMsg and chatMsg.sender_uid and chatMsg.msg then
    local msg = chatMsg.msg
    if chatMsg.voiceMsgId then
      msg = LocUtil.GetLocalizeResStr(106016)
    end
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_IN_TEAM_CHANNEL, chatMsg.sender_uid, msg)
  end
end
return logic_chat_channel_team