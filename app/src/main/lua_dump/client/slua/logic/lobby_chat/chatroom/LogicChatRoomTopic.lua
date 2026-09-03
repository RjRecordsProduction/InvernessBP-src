local LogicChatRoomTopic = {}
function LogicChatRoomTopic:DefineAndResetData()
  self.allTopicData = nil
  self.currentTopicData = nil
  self.currentTopicID = 0
  self.currentOptionID = 0
end
function LogicChatRoomTopic:GetTopicTotalVoteCount(topicID)
  log(bWriteLog and "LogicChatRoomTopic:GetTopicTotalVoteCount topicID:" .. tostring(topicID))
  if not self.allTopicData or not self.allTopicData[topicID] then
    log(bWriteLog and "LogicChatRoomTopic:GetTopicTotalVoteCount no topicData")
    return 0
  end
  return self.allTopicData[topicID]
end
function LogicChatRoomTopic:GetCurrentTopicTotalVoteCount()
  log(bWriteLog and "LogicChatRoomTopic:GetCurrentTopicTotalVoteCount")
  if not self.currentTopicData then
    log(bWriteLog and "LogicChatRoomTopic:GetCurrentTopicTotalVoteCount no currentTopicData")
    return 0
  end
  local count = 0
  for _, optionCount in pairs(self.currentTopicData) do
    count = count + optionCount
  end
  return count
end
function LogicChatRoomTopic:GetCurrentTopicOptionVoteCount(optionID)
  if not self.currentTopicData then
    log(bWriteLog and "LogicChatRoomTopic:GetCurrentTopicOptionVoteCount no currentTopicData")
    return 0
  end
  return self.currentTopicData[optionID] or 0
end
function LogicChatRoomTopic:GetCurrentTopicID()
  return self.currentTopicID
end
function LogicChatRoomTopic:SetCurrentTopicID(topicID)
  log(bWriteLog and "LogicChatRoomTopic:SetCurrentTopicID topicID:" .. tostring(topicID))
  if self.currentTopicID == topicID then
    log(bWriteLog and "LogicChatRoomTopic:SetCurrentTopicID same topicID")
    return
  end
  self.currentTopicID = topicID or 0
  self:SetCurrentOptionID(0)
end
function LogicChatRoomTopic:IsTopicSelected(topicID)
  return self.currentTopicID == topicID
end
function LogicChatRoomTopic:GetCurrentOptionID()
  return self.currentOptionID
end
function LogicChatRoomTopic:CleanData()
  self:DefineAndResetData()
end
function LogicChatRoomTopic:send_get_chat_question_stat_req()
  if self.currentTopicID == 0 then
    log(bWriteLog and "LogicChatRoomTopic:send_get_chat_question_stat_req no currentTopicID")
    return
  end
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_get_chat_question_stat_req(self.currentTopicID)
end
function LogicChatRoomTopic:on_get_chat_question_stat_rsp(question_id, stat_data)
  self:SetCurrentTopicData(stat_data)
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_GET_TOPIC_DATA)
end
function LogicChatRoomTopic:send_channel_set_question_req(question_id)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_set_question_req(channel_id, question_id)
end
function LogicChatRoomTopic:on_channel_set_question_rsp(channel_id, question_id)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  ShowNotice(68051)
end
function LogicChatRoomTopic:on_notify_channel_question_id_update(new_question_id)
  log(bWriteLog and "LogicChatRoomTopic:on_notify_channel_question_id_update")
  self:SetCurrentTopicID(new_question_id)
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_SET_TOPIC_OK)
end
function LogicChatRoomTopic:send_chat_question_vote_req(question_id, my_choice)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_chat_question_vote_req(channel_id, question_id, my_choice)
end
function LogicChatRoomTopic:on_chat_question_vote_rsp(channel_id, question_id, my_choice)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  ShowNotice(46200)
  self:SetCurrentOptionID(my_choice)
  self:SendAnswerOptionMsg(question_id, my_choice)
  self:IncreaseVoteCount(question_id, my_choice)
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_VOTE_TOPIC_OK)
end
function LogicChatRoomTopic:send_get_all_chat_question_vote_count_req()
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_get_all_chat_question_vote_count_req()
end
function LogicChatRoomTopic:on_get_all_chat_question_vote_count_rsp(result)
  self:SetAllTopicData(result)
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_GET_VOTE_COUNT)
end
function LogicChatRoomTopic:SetAllTopicData(allTopicData)
  log_tree(bWriteLog and "LogicChatRoomTopic:SetAllTopicData allTopicData:", allTopicData)
  self.end
function LogicChatRoomTopic:SetCurrentTopicData(curTopicData)
  log_tree(bWriteLog and "LogicChatRoomTopic:SetCurrentTopicData curTopicData:", curTopicData)
  self.currentTopicData = curTopicData
end
function LogicChatRoomTopic:SetCurrentOptionID(optionID)
  log(bWriteLog and "LogicChatRoomTopic:SetCurrentOptionID optionID:" .. tostring(optionID))
  self.currentOptionID = optionID
end
function LogicChatRoomTopic:SendAnswerOptionMsg(topicID, optionID)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if logic_chat_channel_chat_room.CheckHasRightToChat() == false then
    return
  end
  local other = {}
  other.  other.  local msg = {}
  msg.text = ""
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  msg.msgType = chat_macro.SupportTopicOptionMsgType
  msg.quickMsg = false
  msg.  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(tonumber(logic_chat_channel_chat_room.GetMyChatRoomId()), chat_macro.Channel.channelChatRoom, msgId, msg)
end
function LogicChatRoomTopic:IncreaseVoteCount(question_id, optionID)
  if not self.currentTopicData then
    self.currentTopicData = {}
  end
  local curCount = self.currentTopicData[optionID] or 0
  self.currentTopicData[optionID] = curCount + 1
  if not self.allTopicData then
    self.allTopicData = {}
  end
  curCount = self.allTopicData[question_id] or 0
  self.allTopicData[question_id] = curCount + 1
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicChatRoomTopic = class(CModuleBase, nil, LogicChatRoomTopic)
return CLogicChatRoomTopic