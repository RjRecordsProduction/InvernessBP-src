local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local super_list = require("common.super_list")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local chatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 30
local logic_chat_channel_social_island_chat = {
  islandMember = super_list.Create(),
  chatSendLv = 10
}
function logic_chat_channel_social_island_chat.AddNewChat(chatMsg)
  if #chatMessageList >= MAX_MESSAGE_NUM then
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  chatMessageList:AppendItem(chatMsg)
end
function logic_chat_channel_social_island_chat.GetMessageList()
  return chatMessageList
end
function logic_chat_channel_social_island_chat.SendMsg(content)
  if logic_chat_channel_social_island_chat.CheckHasRightToChat() == false then
    return
  end
  local msg = {}
  msg.msgType = 0
  msg.text = content
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local IslandChatNetClient = require("GameLua.Mod.SocialIsland.Client.Chat.IslandChatNetClient")
  IslandChatNetClient.send_chat_req(0, chat_macro.Channel.channelSocialIslandChat, msgId, msg)
end
function logic_chat_channel_social_island_chat.CheckHasRightToChat()
  return true
end
function logic_chat_channel_social_island_chat.ClearIslandChatData()
  logic_chat_channel_social_island_chat.islandMember:ClearData()
  logic_chat_table_pool.RecycleAll(chatMessageList)
end
function logic_chat_channel_social_island_chat.GetIslandMembers()
  return logic_chat_channel_social_island_chat.islandMember
end
function logic_chat_channel_social_island_chat.OnGameStateChange(status)
  log(bWriteLog and "logic_chat_channel_social_island_chat OnGameStateChange")
  logic_chat_channel_social_island_chat.ClearIslandChatData()
end
function logic_chat_channel_social_island_chat.enter_island_notify(uid, playerStatus)
  local memberIndex = logic_chat_channel_social_island_chat.get_member_index(uid)
  if memberIndex == -1 then
    local member = {}
    member.    member.online = playerStatus.online
    member.teamState = playerStatus.teamState
    logic_chat_channel_social_island_chat.islandMember:AppendItem(member)
    EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_ADD_ONE_PLAYER, member)
  end
end
function logic_chat_channel_social_island_chat.exit_island_notify(uid)
  local memberIndex = logic_chat_channel_social_island_chat.get_member_index(uid)
  if memberIndex ~= -1 then
    logic_chat_channel_social_island_chat.islandMember:RemoveItem(memberIndex)
    EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_EXIT_ONE_PLAYER, memberIndex)
  end
  EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_EXIT_ONE_PLAYER_NEW, uid)
end
function logic_chat_channel_social_island_chat.get_member_index(uid)
  local memberCount = #logic_chat_channel_social_island_chat.islandMember
  local memberIndex = -1
  if 0 < memberCount then
    for i = 1, memberCount do
      if tostring(logic_chat_channel_social_island_chat.islandMember[i].uid) == tostring(uid) then
        memberIndex = i
      end
    end
  end
  return memberIndex
end
function logic_chat_channel_social_island_chat.proc_update_island_member_state_notify(message)
  local memberCount = #logic_chat_channel_social_island_chat.islandMember
  if 0 < memberCount then
    for i = 1, memberCount do
      if tostring(logic_chat_channel_social_island_chat.islandMember[i].uid) == tostring(message.uid) then
        logic_chat_channel_social_island_chat.islandMember[i].online = message.online
        logic_chat_channel_social_island_chat.islandMember[i].teamState = message.teamState
        EventSystem:postEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_MEMBER_STATE_CHANGE, message.uid, message)
        break
      end
    end
  end
end
function logic_chat_channel_social_island_chat.get_history_chat_msg_notify(msgList, filterCallback)
  if msgList == nil then
    return
  end
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local IslandChatEntranceLogic = chat_main:GetIslandChatEntranceLogic()
  IslandChatEntranceLogic:ClearData()
  local offlineChatMsgBuffer = {}
  for _, v in pairs(msgList) do
    local bSelfMsg = tonumber(v.sender_uid) == tonumber(DataMgr.roleData.uid)
    if filterCallback then
      filterCallback(v.tabContent)
    end
    local chatMsg = chat_main.SetNewChat(logic_chat_table_pool.Get(), v.sender_name, v.channelType, v.sender_uid, v.sender_uid, nil, nil, v.tabContent, bSelfMsg)
    chatMsg.msg = chat_main.ReplaceEmoji(chatMsg.msg)
    table.insert(offlineChatMsgBuffer, chatMsg)
    IslandChatEntranceLogic:ReceiveNewMsg(chatMsg)
  end
  chatMessageList:SetData(offlineChatMsgBuffer)
end
function logic_chat_channel_social_island_chat.CheckInIsland(uid)
  log_tree("god test uid ", {uid})
  for _, v in pairs(logic_chat_channel_social_island_chat.islandMember) do
    if tonumber(v.uid) == tonumber(uid) then
      return true
    end
  end
  return false
end
function logic_chat_channel_social_island_chat.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
return logic_chat_channel_social_island_chat