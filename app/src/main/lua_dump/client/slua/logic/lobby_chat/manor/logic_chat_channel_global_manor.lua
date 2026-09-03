local super_list = require("common.super_list")
local chatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 200
local logic_chat_channel_global_manor = {}
local UpdateRedpoint = function(show)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelGlobalManor, show)
end
function logic_chat_channel_global_manor.ClearData()
  chatMessageList:ClearData()
end
function logic_chat_channel_global_manor.AddNewChat(chatMsg)
  if #chatMessageList >= MAX_MESSAGE_NUM then
    local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if logic_chat_main.currentChannel ~= chat_macro.Channel.channelGlobalManor then
    UpdateRedpoint(true)
  end
  chatMessageList:AppendItem(chatMsg)
end
function logic_chat_channel_global_manor.GetMessageList()
  return chatMessageList
end
function logic_chat_channel_global_manor.SendMsg(content)
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  local global_topic_id = logic_chat_manor_topic:GetGlobalTopicId()
  if not global_topic_id then
    log(bWriteLog and "logic_chat_channel_global_manor.SendMsg no global_topic_id")
    ShowNotice(65465)
    return
  end
  local msg = {}
  msg.voice = ""
  msg.text = content
  msg.voiceLength = 0
  msg.quickMsg = false
  msg.msgType = 0
  msg.topic = global_topic_id
  msg.other = logic_chat_channel_global_manor.GetManorRoomInfo()
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalManor, msgId, msg)
end
function logic_chat_channel_global_manor.SendVoiceMsg(voiceId, length, content)
  if nil == voiceId or "" == voiceId then
    return
  end
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  local global_topic_id = logic_chat_manor_topic:GetGlobalTopicId()
  if not global_topic_id then
    log(bWriteLog and "logic_chat_channel_global_manor.SendVoiceMsg no global_topic_id")
    ShowNotice(65465)
    return
  end
  local msg = {}
  msg.voice = voiceId
  msg.text = content
  msg.voiceLength = length
  msg.quickMsg = false
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  msg.msgType = chat_macro.VoiceChatMsgType
  msg.topic = global_topic_id
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalManor, msgId, msg)
end
function logic_chat_channel_global_manor.SendWebgameInvite(ludoParam)
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  local global_topic_id = logic_chat_manor_topic:GetGlobalTopicId()
  if not global_topic_id then
    log(bWriteLog and "logic_chat_channel_global_manor.SendWebgameInvite no global_topic_id")
    ShowNotice(65465)
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local msg = {}
  msg.voice = ""
  local eGameType = ludoParam.eGameType
  local LudoConst = require("client.slua.logic.ludo.LudoConst")
  local desc = LudoConst.WebgameInviteTitleAndDesc[eGameType].desc
  msg.text = desc
  msg.voiceLength = 0
  msg.quickMsg = false
  msg.msgType = chat_macro.LudoInviteMsgType
  msg.topic = global_topic_id
  msg.other = ludoParam
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalManor, msgId, msg)
end
function logic_chat_channel_global_manor.SendHalloweenInvite(HalloweenParam)
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  local global_topic_id = logic_chat_manor_topic:GetGlobalTopicId()
  if not global_topic_id then
    log(bWriteLog and "logic_chat_channel_global_manor.SendHalloweenInvite no global_topic_id")
    ShowNotice(65465)
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local TimeUtil = require("client.common.time_util")
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(774737)
  msg.topic = global_topic_id
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.HalloweenInviteType
  msg.quickMsg = false
  msg.other = HalloweenParam
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalManor, msgId, msg)
end
function logic_chat_channel_global_manor.SendSnowPartyInvite(snowPartyParam)
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  local global_topic_id = logic_chat_manor_topic:GetGlobalTopicId()
  if not global_topic_id then
    log(bWriteLog and "logic_chat_channel_global_manor.SendSnowPartyInvite no global_topic_id")
    ShowNotice(65465)
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local TimeUtil = require("client.common.time_util")
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(83602)
  msg.topic = global_topic_id
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.SnowPartyInviteType
  msg.quickMsg = false
  msg.other = snowPartyParam
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalManor, msgId, msg)
end
function logic_chat_channel_global_manor.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_global_manor.ClearRedPointInfo()
  UpdateRedpoint(false)
end
function logic_chat_channel_global_manor.GetManorRoomInfo()
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local manor_data = logic_enter_game.manor_data
  if not manor_data then
    log(bWriteLog and "logic_chat_channel_global_manor.GetManorRoomInfo no manor_data")
    return nil
  end
  if not SubsystemMgr then
    log(bWriteLog and "logic_chat_channel_global_manor.GetManorRoomInfo no SubsystemMgr")
    return nil
  end
  local PlanPH_RoomSubsystem_Client = SubsystemMgr:Get("PlanPH_RoomSubsystem_Client")
  if not PlanPH_RoomSubsystem_Client then
    log(bWriteLog and "logic_chat_channel_global_manor.GetManorRoomInfo no PlanPH_RoomSubsystem_Client")
    return nil
  end
  local info = {}
  info.cur_room_id = PlanPH_RoomSubsystem_Client:GetCurrRoomId()
  info.manor_inst_id = manor_data.manor_inst_id
  log_tree(bWriteLog and "logic_chat_channel_global_manor.GetManorRoomInfo info:", info)
  return info
end
function logic_chat_channel_global_manor.SendMainCityShare(maincityParam, extraParam)
  log(bWriteLog and "logic_chat_channel_global_manor.SendMainCityShare")
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  local global_topic_id = logic_chat_manor_topic:GetGlobalTopicId()
  if not global_topic_id then
    log(bWriteLog and "logic_chat_channel_global_manor.SendSnowPartyInvite no global_topic_id")
    ShowNotice(65465)
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local TimeUtil = require("client.common.time_util")
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(46880011)
  msg.topic = global_topic_id
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.MainCityShareChatMsgType
  msg.quickMsg = false
  msg.other = maincityParam
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelGlobalManor, msgId, msg)
end
return logic_chat_channel_global_manor