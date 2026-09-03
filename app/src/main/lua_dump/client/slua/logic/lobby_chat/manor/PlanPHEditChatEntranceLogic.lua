local PlanPHEditChatEntranceLogic = {}
function PlanPHEditChatEntranceLogic:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_HOME_ENTER_EDIT_HOME_SUCCESS, self.OnEnterEditHomeSuccess, self)
end
function PlanPHEditChatEntranceLogic:filterMsg(chatMsg)
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  if not logic_home_entry:IsPlanPHMode() then
    printf("PlanPHEditChatEntranceLogic:filterMsg return by not logic_home_entry:IsPlanPHMode")
    return true
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bEditHomeMode = PlanPH_GamePlay_Tools.IsEditHomeMode()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if bEditHomeMode and chatMsg.msgChannel == chat_macro.Channel.channelCurrentManor then
    printf("PlanPHEditChatEntranceLogic:filterMsg return by bEditHomeMode and msgChannel. %s", chatMsg.msgChannel)
    return true
  end
  if chatMsg.msgChannel ~= chat_macro.Channel.channelCurrentManor and chatMsg.msgChannel ~= chat_macro.Channel.channelPrivate then
    printf("PlanPHEditChatEntranceLogic:filterMsg return by msgChannel. %s", chatMsg.msgChannel)
    return true
  end
  if chatMsg.msgType == chat_macro.SupportTopicOptionMsgType then
    printf("PlanPHEditChatEntranceLogic:filterMsg return by msgType. %s", chatMsg.msgType)
    return true
  elseif chatMsg.msgType == chat_macro.ChatRoomSendGiftMsgType then
    printf("PlanPHEditChatEntranceLogic:filterMsg return by msgType. %s", chatMsg.msgType)
    return true
  end
  return false
end
function PlanPHEditChatEntranceLogic:OnEnterEditHomeSuccess()
  log(bWriteLog and "PlanPHEditChatEntranceLogic:OnEnterEditHomeSuccess")
  self:DefineAndResetData()
end
local class = require("class")
local CLogicChatEntranceBase = require("client.slua.logic.lobby_chat.manor.PlanPHChatEntranceLogicBase")
local CPlanPHEditChatEntranceLogic = class(CLogicChatEntranceBase, nil, PlanPHEditChatEntranceLogic)
return CPlanPHEditChatEntranceLogic