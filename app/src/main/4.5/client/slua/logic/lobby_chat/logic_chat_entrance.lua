local logic_chat_entrance = {
  ENUM_FROM_TYPE = {
    FROM_LOBBY = 0,
    FROM_T_PLAN = 1,
    FROM_WOW = 2,
    FROM_MAINCITY = 3,
    FROM_PEAK = 4
  },
  quickMsgList = {},
  chatContent = {},
  hasNew = false,
  ENUM_CORP_MSG_TYPE = {TOP_CHAT_MSG = 0, NEW_NOTICE_MSG = 1}
}
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local RecruitSystem = require("client.slua.logic.lobby_chat.logic_recruit")
local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
local ids = {
  106002,
  106003,
  106004,
  106005,
  106006,
  106008
}
local chatInfoList = {}
function logic_chat_entrance:SetUnreadFriendChatMsgCount(count, uid)
  self:SetUnreadMsg(chat_macro.Channel.channelPrivate, count, uid)
end
function logic_chat_entrance:SetUnreadFriendReserveChatMsgCount(count, uid, isReserveMsg, isGameResultReserveMsg)
  self:SetUnreadMsg(chat_macro.Channel.channelPrivate, count, uid, isReserveMsg, isGameResultReserveMsg)
end
function logic_chat_entrance:SetUnreadCorpsChatMsgCount(count)
  self:SetUnreadMsg(chat_macro.Channel.channelCorps, count)
end
function logic_chat_entrance:SetUnreadFlashTeamChatMsgCount(count)
  self:SetUnreadMsg(chat_macro.Channel.channelFlashMatchTeam, count)
end
function logic_chat_entrance:SetCorpsChatTopMsgNotify(uid)
  self:SetUnreadMsg(chat_macro.Channel.channelCorps, 1, uid)
end
function logic_chat_entrance:SetUnreadMsg(channelID, count, uid, isReserveMsg, isGameResultReserveMsg)
  if 0 < count then
    log(bWriteLog and "logic_chat_entrance:SetUnreadMsg has redpoint, channelID:" .. tostring(channelID))
    self.UnreadMsg = {
      unreadChannelID = channelID,
      unreadCount = count,
      uid = uid,
      isReserveMsg = isReserveMsg,
          }
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_ENTERANCE_REFRESH_REDPOINT)
  elseif self.UnreadMsg and self.UnreadMsg.unreadChannelID == channelID then
    log(bWriteLog and "logic_chat_entrance:SetUnreadMsg no redpoint, channelID:" .. tostring(channelID))
    self.UnreadMsg = nil
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_ENTERANCE_REFRESH_REDPOINT)
  end
end
function logic_chat_entrance:GetUnreadMsg()
  return self.UnreadMsg
end
function logic_chat_entrance:ReadMsg()
  log(bWriteLog and "logic_chat_entrance:ReadMsg")
  self.UnreadMsg = nil
end
function logic_chat_entrance:GetQuickMsgList()
  if next(self.quickMsgList) == nil then
    for k, v in pairs(ids) do
      self.quickMsgList[v] = LocUtil.GetLocalizeResStr(v)
    end
  end
  return self.quickMsgList
end
function logic_chat_entrance:GetQuitMsg(index)
  local msgList = self:GetQuickMsgList()
  return msgList[ids[index]]
end
function logic_chat_entrance:GetQuitMsgId(index)
  return ids[index]
end
function logic_chat_entrance:ClearData()
  self.hasNew = false
  chatInfoList = {}
end
function logic_chat_entrance:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_chat_entrance:OnPreSwitchGameStatus")
  self:ClearData()
end
function logic_chat_entrance:OnLogOut()
  log(bWriteLog and "logic_chat_entrance:OnLogOut")
  self:ClearData()
end
function logic_chat_entrance:GetNewMsg(bNotSetNew)
  if not bNotSetNew then
    self.hasNew = false
  end
  return chatInfoList
end
function logic_chat_entrance:ReceiveNewMsg(chatMsg)
  if self:filterMsg(chatMsg) then
    return
  end
  self.hasNew = true
  chatInfoList = chatMsg
  local content = chatMsg and (chatMsg.msg or "") or ""
  local channel = chatMsg and chatMsg.msgChannel or 0
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_GET_NEW_CHAT_MSG, channel, content)
end
function logic_chat_entrance:OpenChatWinByTipConfig(tipConfig)
  if not tipConfig then
    return
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if tipConfig.ChannelID == chat_macro.Channel.channelPrivate then
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    local gid = logic_chat_channel_friend.GetNewChatFriendGid()
    if gid ~= "" then
      logic_chat_main.OpenChatMainByFriendId(gid)
    else
      logic_chat_main.OpenChatMain()
    end
  else
    logic_chat_main.OpenChatMain(tipConfig.ChannelID)
  end
end
function logic_chat_entrance:on_chat_quick_msg(content)
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if nil == content or "" == content then
    return
  end
  local tabContent = {
    voice = "",
    text = content,
    voiceLength = 0,
    quickMsg = true,
    msgType = 0,
    msgID = content
  }
  local msgId = logic_chat_main.CacheMsg(tabContent)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelTeam, msgId, tabContent)
end
function logic_chat_entrance:CheckShowMsg(chatMsg, from)
  from = from or self.ENUM_FROM_TYPE.FROM_LOBBY
  if chatMsg.msgType == chat_macro.teamRecruitMsgType or chatMsg.msgType == chat_macro.teamPlatFormRecruitMsgType then
    local isTPlanItem = false
    if chatMsg.msgType == chat_macro.teamRecruitMsgType then
      isTPlanItem = RecruitSystem.IsTPlanRecruit(chatMsg)
    else
      isTPlanItem = RecruitSystem.IsTPlanRecruitMsg(chatMsg.content)
    end
    if not isTPlanItem then
      if LogicTxMissionMain.IsInXMission() then
        return false, true
      else
        return true, false
      end
    elseif from == self.ENUM_FROM_TYPE.FROM_LOBBY then
      if LogicTxMissionMain.IsInXMission() then
        return false, false
      else
        return false, true
      end
    else
      return true, false
    end
  elseif chatMsg.msgType == chat_macro.corpsRecruitMsgType or chatMsg.msgType == chat_macro.roomRecruitMsgType then
    if from == self.ENUM_FROM_TYPE.FROM_T_PLAN then
      return false, true
    else
      return true, false
    end
  elseif LogicTxMissionMain.IsInXMission() and from ~= self.ENUM_FROM_TYPE.FROM_T_PLAN then
    return false, false
  end
  return true, false
end
function logic_chat_entrance:filterMsg(chatMsg)
  log_tree(bWriteLog and "logic_chat_entrance filterMsg chatMsg:", chatMsg)
  if chatMsg.msgChannel == chat_macro.Channel.channelWorldCupPK then
    return true
  elseif chatMsg.msgChannel == chat_macro.Channel.channelTeamRecruit then
    local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
    return logic_chat_recruit_msg:IsCanShowMsgInLobbyEntrance()
  end
  if chatMsg.msgType == chat_macro.XSuitGiftMsgType then
    return true
  elseif chatMsg.msgType == chat_macro.SupportTopicOptionMsgType then
    return true
  elseif chatMsg.msgType == chat_macro.ChatRoomSendGiftMsgType then
    return true
  end
  if chatMsg.content and chatMsg.content.is_positive == false then
    return true
  else
    return false
  end
end
local class = require("class")
local CLogicChatEntranceBase = require("client.slua.logic.lobby_chat.logic_chat_entrance_base")
local CLogicChatEntrance = class(CLogicChatEntranceBase, nil, logic_chat_entrance)
return CLogicChatEntrance