local super_list = require("common.super_list")
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local ChatHandler = require("client.network.Protocol.ChatHandler")
local _tChatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 200
local Logic_ChatChannelGlobalHall = {}
local _fUpdateRedDot = function(bShow)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelGlobalPlanCH, bShow)
end
function Logic_ChatChannelGlobalHall.ClearData()
  _tChatMessageList:ClearData()
end
function Logic_ChatChannelGlobalHall.AddNewChat(tChatMsg)
  if #_tChatMessageList >= MAX_MESSAGE_NUM then
    local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
    logic_chat_table_pool.Recycle(_tChatMessageList[1])
    _tChatMessageList:RemoveItem(1)
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if logic_chat_main.currentChannel ~= chat_macro.Channel.channelGlobalPlanCH then
    _fUpdateRedDot(true)
  end
  _tChatMessageList:AppendItem(tChatMsg)
end
function Logic_ChatChannelGlobalHall.GetMessageList()
  return _tChatMessageList
end
function Logic_ChatChannelGlobalHall.SendMsg(sContent)
  local Logic_PlanCHTopicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_PlanCHTopicModule)
  local nGlobalTopicId = Logic_PlanCHTopicModule:GetGlobalTopicId()
  if not nGlobalTopicId then
    log(bWriteLog and "Logic_ChatChannelGlobalHall.SendMsg no global_topic_id")
    ShowNotice(65465)
    return
  end
  local tMsg = {}
  tMsg.voice = ""
  tMsg.text = sContent
  tMsg.voiceLength = 0
  tMsg.quickMsg = false
  tMsg.msgType = 0
  tMsg.topic = nGlobalTopicId
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local nMsgId = chat_main.CacheMsg(tMsg)
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalPlanCH, nMsgId, tMsg)
end
function Logic_ChatChannelGlobalHall.SendVoiceMsg(sVoiceId, nLength, sContent)
  if nil == sVoiceId or "" == sVoiceId then
    return
  end
  local Logic_PlanCHTopicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_PlanCHTopicModule)
  local nGlobalTopicId = Logic_PlanCHTopicModule:GetGlobalTopicId()
  if not nGlobalTopicId then
    log(bWriteLog and "Logic_ChatChannelGlobalHall.SendVoiceMsg no global_topic_id")
    ShowNotice(65465)
    return
  end
  local tMsg = {}
  tMsg.voice = sVoiceId
  tMsg.text = sContent
  tMsg.voiceLength = nLength
  tMsg.quickMsg = false
  tMsg.msgType = chat_macro.VoiceChatMsgType
  tMsg.topic = nGlobalTopicId
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local nMsgId = chat_main.CacheMsg(tMsg)
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalPlanCH, nMsgId, tMsg)
end
function Logic_ChatChannelGlobalHall.ClearSomesMsg(nUid)
  for k = #_tChatMessageList, 1, -1 do
    if _tChatMessageList[k].sender_uid == tostring(nUid) then
      local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
      logic_chat_table_pool.Recycle(_tChatMessageList[k])
      _tChatMessageList:RemoveItem(k)
    end
  end
end
function Logic_ChatChannelGlobalHall.ClearRedPointInfo()
  _fUpdateRedDot(false)
end
return Logic_ChatChannelGlobalHall