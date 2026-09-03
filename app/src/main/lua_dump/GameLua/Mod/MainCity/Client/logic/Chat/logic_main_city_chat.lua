local logic_main_city_chat = {}
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
function logic_main_city_chat:DefineAndResetData()
  log(bWriteLog and "logic_main_city_chat:DefineAndResetData")
  self.globalMainCityTopic = nil
  self.hasSubscribed = false
  self.chatBubbles = {}
end
function logic_main_city_chat:OnInitialize()
  log(bWriteLog and "logic_main_city_chat:OnInitialize")
end
function logic_main_city_chat:RegistEvents()
  log(bWriteLog and "logic_main_city_chat:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_SUBCRIBE_TOPIC_CHANNEL_SUCCESS, self.OnSubscribeMainCityTopic, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_CONNECTED_TO_DS, self.OnMainCityConnectedToDS, self)
end
function logic_main_city_chat:OnMainCityConnectedToDS()
  log(bWriteLog and "logic_main_city_chat:OnMainCityConnectedToDS")
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelList()
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  logic_chat_channel_world.ClearTopicMsgList(chat_macro.TopicCurrentMainCity)
  if self.globalMainCityTopic then
    logic_chat_channel_world.ClearTopicMsgList(self.globalMainCityTopic)
  else
    local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
    logic_chat_channel_world.get_topic_list(true)
  end
  log(bWriteLog and "logic_main_city_chat:OnMainCityConnectedToDS" .. tostring(chat_macro.TopicCurrentMainCity) .. " & " .. tostring(self.globalMainCityTopic))
end
function logic_main_city_chat:IsMainCityChannel(channel)
  if not channel then
    return false
  end
  if channel == chat_macro.Channel.channelGlobalMainCity then
    return true
  elseif channel == chat_macro.Channel.channelCurrentMainCity then
    return true
  else
    return false
  end
end
function logic_main_city_chat:IsMainCityTopic(topicId)
  if not topicId then
    return false
  end
  if string.find(topicId, chat_macro.TopicGlobalMainCity) then
    return true
  end
  if string.find(topicId, chat_macro.TopicCurrentMainCity) then
    return true
  end
  return false
end
function logic_main_city_chat:IsGlobalMainCityTopic(topicId)
  if not topicId then
    return false
  end
  if string.find(topicId, chat_macro.TopicGlobalMainCity) then
    return true
  end
  return false
end
function logic_main_city_chat:GetGlobalMainCityTopic()
  return self.globalMainCityTopic
end
function logic_main_city_chat:RequestMainCityTopic()
  log(bWriteLog and "logic_main_city_chat:RequestMainCityTopic")
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  logic_chat_channel_world.get_topic_list(true)
end
function logic_main_city_chat:OnSubscribeMainCityTopic(_, _, topicId)
  if self:IsGlobalMainCityTopic(topicId) then
    log(bWriteLog and "logic_main_city_chat:OnSubscribeMainCityTopic success " .. tostring(topicId))
    self.hasSubscribed = true
    self.globalMainCityTopic = topicId
  end
end
function logic_main_city_chat:UpdateChatBubble(nUid, bubbleInfo)
  if not nUid then
    return
  end
  if not self.chatBubbles then
    self.chatBubbles = {}
  end
  if bubbleInfo == nil then
    self.chatBubbles[nUid] = nil
  else
    self.chatBubbles[nUid] = bubbleInfo
  end
end
function logic_main_city_chat:IsChatBubbleCovered(nUid)
  if not nUid then
    return
  end
  local info = self.chatBubbles[nUid]
  if info then
    for k, v in pairs(self.chatBubbles) do
      if k ~= nUid and info.distance > v.distance and self:IsOverlapBetween(k, nUid) then
        log(bWriteLog and "logic_main_city_chat:IsOverlap nUid" .. tostring(nUid) .. " covered by " .. tostring(k))
        return true
      end
    end
  end
  return false
end
function logic_main_city_chat:IsOverlapBetween(uid1, uid2)
  local itemData1 = self.chatBubbles[uid1]
  local itemData2 = self.chatBubbles[uid2]
  local diffX = math.abs(itemData1.X - itemData2.X)
  local diffY = math.abs(itemData1.Y - itemData2.Y)
  local sizeX = itemData1.sizeX + itemData2.sizeX
  local sizeY = itemData1.sizeY + itemData2.sizeY
  return diffX < 0.5 * sizeX and diffY < 0.5 * sizeY
end
function logic_main_city_chat:ProcessChatListMC(list)
  log(bWriteLog and "logic_main_city_chat:ProcessChatListMC")
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bShowCurrentMaincity = Lobby_Main_City_Enter and Lobby_Main_City_Enter.bInMainCity
  local GlobalMainCityData
  local CurrentMainCityData = {
    id = chat_macro.TopicCurrentMainCity,
    type = chat_macro.TopicCurrentMainCityType,
    score = 0,
    name = LocUtil.GetLocalizeResStr(46880113)
  }
  local result = {}
  if list then
    for index, data in pairs(list) do
      if data.id and string.find(data.id, chat_macro.TopicGlobalMainCity) then
        log(bWriteLog and "logic_main_city_chat:ProcessChatListMC find gMC" .. tostring(data.id))
        data.name = LocUtil.GetLocalizeResStr(46880012)
        GlobalMainCityData = data
        local ChatHandler = require("client.network.Protocol.ChatHandler")
        ChatHandler.send_topic_subscribe_req(data.id)
      else
        table.insert(result, data)
      end
    end
  else
    log(bWriteLog and "logic_chat_channel_world.topic_flat_list_rsp empty list")
  end
  if GlobalMainCityData then
    log(bWriteLog and "logic_main_city_chat:ProcessChatListMC global")
    table.insert(result, 1, GlobalMainCityData)
    bShowCurrentMaincity = true
  end
  if bShowCurrentMaincity then
    log(bWriteLog and "logic_main_city_chat:ProcessChatListMC current")
    table.insert(result, 1, CurrentMainCityData)
  end
  return result
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_main_city_chat)