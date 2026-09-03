local PlanPHVisitChatEntranceLogic = {}
function PlanPHVisitChatEntranceLogic:filterMsg(chatMsg)
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  if not logic_home_entry:IsPlanPHMode() then
    return true
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if chatMsg.msgChannel ~= chat_macro.Channel.channelGlobalManor and chatMsg.msgChannel ~= chat_macro.Channel.channelCurrentManor and chatMsg.msgChannel ~= chat_macro.Channel.channelPrivate then
    return true
  end
  if chatMsg.msgType == chat_macro.SupportTopicOptionMsgType then
    return true
  elseif chatMsg.msgType == chat_macro.ChatRoomSendGiftMsgType then
    return true
  end
  return false
end
local class = require("class")
local CLogicChatEntranceBase = require("client.slua.logic.lobby_chat.manor.PlanPHChatEntranceLogicBase")
local CPlanPHEditChatEntranceLogic = class(CLogicChatEntranceBase, nil, PlanPHVisitChatEntranceLogic)
return CPlanPHEditChatEntranceLogic