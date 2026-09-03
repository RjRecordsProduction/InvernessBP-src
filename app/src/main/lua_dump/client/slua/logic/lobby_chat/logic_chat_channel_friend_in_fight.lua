local logic_chat_channel_friend_in_fight = {
  chatSelectedFriendInFight = "",
  fightFriendChatList = {},
  chatEnterFight = false,
  MAX_FRIEND_MESSAGE_CACHE_NUM = 100
}
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
function logic_chat_channel_friend_in_fight.fight_send_msg(str_receiver_gid, content)
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local msg = {}
  msg.channelType = chat_macro.Channel.channelPrivate
  msg.text = content
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = 0
  local msgId = chat_main.CacheMsg(msg)
  ChatHandler.send_chat_req(str_receiver_gid, chat_macro.Channel.channelPrivate, msgId, msg)
end
function logic_chat_channel_friend_in_fight.on_enter_fight_chat(str_gid)
  logic_chat_channel_friend_in_fight.chatSelectedFriendInFight = str_gid
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  local refMsg = logic_chat_channel_friend.FriendChatList[str_gid]
  if nil ~= refMsg then
    refMsg.newMessageCount = 0
  end
  logic_chat_channel_friend.RefreshTotalUnread()
end
function logic_chat_channel_friend_in_fight.on_quit_fight_chat()
  logic_chat_channel_friend_in_fight.chatSelectedFriendInFight = ""
end
function logic_chat_channel_friend_in_fight.on_friend_fight_msg(str_gid, thisMsg)
  if false == logic_chat_channel_friend_in_fight.chatEnterFight then
    return
  end
  local msgTextId = chat_macro.ChatMsgContentTextConfig[thisMsg.msgType]
  if msgTextId then
    thisMsg.msg = LocUtil.GetLocalizeResStr(msgTextId)
  end
  IngameChat:on_notify_fight_friend_chat(str_gid, thisMsg)
end
function logic_chat_channel_friend_in_fight.EnterFight()
  logic_chat_channel_friend_in_fight.chatEnterFight = true
end
function logic_chat_channel_friend_in_fight.ClearFight()
  logic_chat_channel_friend_in_fight.chatEnterFight = false
end
return logic_chat_channel_friend_in_fight