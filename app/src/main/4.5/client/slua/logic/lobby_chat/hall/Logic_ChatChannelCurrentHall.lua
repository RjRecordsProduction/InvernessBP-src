local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local super_list = require("common.super_list")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local _tChatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 200
local Logic_ChatChannelCurrentHall = {}
local _fUpdateRedpoint = function(bShow)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelCurPlanCH, bShow)
end
function Logic_ChatChannelCurrentHall.ClearData()
  _tChatMessageList:ClearData()
end
function Logic_ChatChannelCurrentHall.AddNewChat(tChatMsg)
  if #_tChatMessageList >= MAX_MESSAGE_NUM then
    logic_chat_table_pool.Recycle(_tChatMessageList[1])
    _tChatMessageList:RemoveItem(1)
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if logic_chat_main.currentChannel ~= chat_macro.Channel.channelCurPlanCH then
    _fUpdateRedpoint(true)
  end
  _tChatMessageList:AppendItem(tChatMsg)
end
function Logic_ChatChannelCurrentHall.GetMessageList()
  return _tChatMessageList
end
function Logic_ChatChannelCurrentHall.SendMsg(sContent)
  local tMsg = {}
  tMsg.voice = ""
  tMsg.text = sContent
  tMsg.voiceLength = 0
  tMsg.msgType = 0
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local nMsgId = chat_main.CacheMsg(tMsg)
  local Logic_PlanCHTopicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_PlanCHTopicModule)
  if Logic_PlanCHTopicModule:ChatByDS() then
    log(bWriteLog and "Logic_ChatChannelCurrentHall.SendMsg ChatByDS")
    local PlanCH_ChatNetClient = require("GameLua.Mod.PlanCH.Client.Logic.Chat.PlanCH_ChatNetClient")
    PlanCH_ChatNetClient.send_chat_req(0, chat_macro.Channel.channelCurPlanCH, nMsgId, tMsg)
  else
    log(bWriteLog and "Logic_ChatChannelCurrentHall.SendMsg Chat By Lobby Server")
    local nCurrentTopicId = Logic_PlanCHTopicModule:GetCurrentTopicId()
    if not nCurrentTopicId then
      log(bWriteLog and "Logic_ChatChannelCurrentHall.SendMsg no current_topic_id")
      return
    end
    tMsg.topic = nCurrentTopicId
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    ChatHandler.send_chat_req(0, chat_macro.Channel.channelCurPlanCH, nMsgId, tMsg)
  end
end
function Logic_ChatChannelCurrentHall.SendVoiceMsg(sVoiceId, nLength, sContent)
  if nil == sVoiceId or "" == sVoiceId then
    return
  end
  local tMsg = {}
  tMsg.voice = sVoiceId
  tMsg.text = sContent
  tMsg.voiceLength = nLength
  tMsg.msgType = chat_macro.VoiceChatMsgType
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local nMsgId = chat_main.CacheMsg(tMsg)
  local Logic_PlanCHTopicModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_PlanCHTopicModule)
  if Logic_PlanCHTopicModule:ChatByDS() then
    log(bWriteLog and "Logic_ChatChannelCurrentHall.SendVoiceMsg ChatByDS")
    local PlanCH_ChatNetClient = require("GameLua.Mod.PlanCH.Client.Logic.Chat.PlanCH_ChatNetClient")
    PlanCH_ChatNetClient.send_chat_req(0, chat_macro.Channel.channelCurPlanCH, nMsgId, tMsg)
  else
    log(bWriteLog and "Logic_ChatChannelCurrentHall.SendVoiceMsg Chat By Lobby Server")
    local nCurrentTopicId = Logic_PlanCHTopicModule:GetCurrentTopicId()
    if not nCurrentTopicId then
      log(bWriteLog and "Logic_ChatChannelCurrentHall.SendVoiceMsg no current_topic_id")
      return
    end
    tMsg.topic = nCurrentTopicId
    local ChatHandler = require("client.network.Protocol.ChatHandler")
    ChatHandler.send_chat_req(0, chat_macro.Channel.channelCurPlanCH, nMsgId, tMsg)
  end
end
function Logic_ChatChannelCurrentHall.ClearSomesMsg(nUid)
  for k = #_tChatMessageList, 1, -1 do
    if _tChatMessageList[k].sender_uid == tostring(nUid) then
      logic_chat_table_pool.Recycle(_tChatMessageList[k])
      _tChatMessageList:RemoveItem(k)
    end
  end
end
function Logic_ChatChannelCurrentHall.ClearRedPointInfo()
  _fUpdateRedpoint(false)
end
return Logic_ChatChannelCurrentHall