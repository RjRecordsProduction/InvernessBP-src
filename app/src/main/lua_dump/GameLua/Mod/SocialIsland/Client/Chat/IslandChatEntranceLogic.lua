local IslandChatEntranceLogic = {hasNew = false, maxMsg = 4}
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
local ChatFuncUtil = require("client.slua.umg.lobby_chat.chat_funcUtil")
local chatInfoList = {}
function IslandChatEntranceLogic:ClearData()
  self.hasNew = false
  chatInfoList = {}
end
function IslandChatEntranceLogic:filterMsg(chatMsg)
  if require("GameLua.Mod.SocialIsland.GamePlay.Config.Test_Config").bOpenSimulate then
  elseif not MatchModeMgrSystem.IsSocialIslandMode() then
    return true
  end
  if chatMsg.msgChannel == chat_macro.Channel.channelTeamRecruit or chatMsg.msgChannel == chat_macro.Channel.channelWorld or chatMsg.msgChannel == chat_macro.channelTopic or chatMsg.msgChannel == chat_macro.channelTopic2 or chatMsg.msgChannel == chat_macro.Channel.channelClub or chatMsg.msgChannel == chat_macro.Channel.channelWorldCup or chatMsg.msgChannel == chat_macro.Channel.channelWorldCupPK or chatMsg.msgChannel == chat_macro.Channel.channelUGC then
    return true
  end
  if ChatFuncUtil.IsIslandBroadcastMsg(chatMsg.msgType) then
    return true
  end
  if chatMsg.msgType == chat_macro.XSuitGiftMsgType then
    return true
  elseif chatMsg.msgType == chat_macro.ExchangeGiftMsgType then
    return true
  elseif chatMsg.msgType == chat_macro.SupportTopicOptionMsgType then
    return true
  elseif chatMsg.msgType == chat_macro.ChatRoomSendGiftMsgType then
    return true
  end
  return false
end
function IslandChatEntranceLogic:GetMsgList()
  self.hasNew = false
  return chatInfoList
end
function IslandChatEntranceLogic:ReceiveNewMsg(chatMsg)
  if self:filterMsg(chatMsg) then
    return
  end
  self.hasNew = true
  if #chatInfoList >= self.maxMsg then
    table.remove(chatInfoList, 1)
  end
  table.insert(chatInfoList, chatMsg)
end
function IslandChatEntranceLogic:GetTeamRecruitMsgContent(chatMsg)
  return LocUtil.LocalizeResFormat(7791)
end
function IslandChatEntranceLogic:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "LogicIslandChatEntrance OnPreSwitchGameStatus")
  self:ClearData()
end
function IslandChatEntranceLogic:OnLogOut()
  log(bWriteLog and "LogicIslandChatEntrance OnLogOut")
  self:ClearData()
end
local class = require("class")
local CLogicChatEntranceBase = require("client.slua.logic.lobby_chat.logic_chat_entrance_base")
local CLogicIslandChatEntrance = class(CLogicChatEntranceBase, nil, IslandChatEntranceLogic)
return CLogicIslandChatEntrance