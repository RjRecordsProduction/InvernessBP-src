local ChatUtils = {}
function ChatUtils.IsChatOpen()
  if not LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_CHAT) then
    return false
  end
  return true
end
function ChatUtils.GetLanguageRelatedChannels()
  local availableChannels = {}
  local firstLanguage = DataMgr.FirstSecondLanguage[1]
  local secondLanguage = DataMgr.FirstSecondLanguage[2]
  local LogicChannelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if not LogicChannelWorld or not LogicChannelWorld.topic_channel_array then
    printf("ChatUtils.GetAvailableChannels array is nil")
    return availableChannels
  end
  printf("ChatUtils.GetAvailableChannels firstLanguage:%s, secondLanguage:%s", firstLanguage, secondLanguage)
  log_tree("ChatUtils.GetAvailableChannels", LogicChannelWorld.topic_channel_array)
  for k, v in pairs(LogicChannelWorld.topic_channel_array) do
    if v.lang_id ~= nil and (v.lang_id == firstLanguage or v.lang_id == secondLanguage) then
      table.insert(availableChannels, v)
    end
  end
  return availableChannels
end
function ChatUtils.SubscribeChannel(topic)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_topic_subscribe_req(topic)
end
function ChatUtils.SubscribeLanguageRelatedChannels()
  local availableChannels = ChatUtils.GetLanguageRelatedChannels()
  for _, channel in ipairs(availableChannels) do
    ChatUtils.SubscribeChannel(channel.id)
  end
end
return ChatUtils