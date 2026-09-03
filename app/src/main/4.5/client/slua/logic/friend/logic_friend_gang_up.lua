local logic_friend_gang_up = {
  isInitGangUpdata = false,
  CanSendGangUpChat = false,
  gang_up_count = nil,
  gang_up_chat_friends = {},
  week_time = 0
}
function logic_friend_gang_up.GetMaxLastWeekLevel(uid)
  log(bWriteLog and "logic_friend_gang_up.GetMaxLastWeekLevel uid = " .. uid)
  local friend_counts = logic_friend_gang_up.GetFriendCounts()
  if friend_counts == nil then
    log(bWriteLog and "logic_friend_gang_up.GetMaxLastWeekLevel friend_counts == nil")
    return 0
  end
  local max_last_week_level = 0
  local tb = CDataTable.GetTable("FriendOpenBlackLevel")
  for k, v in pairs(tb) do
    if friend_counts[uid] and friend_counts[uid].last_week_count >= v.time and max_last_week_level < v.level then
      max_last_week_level = v.level
    end
  end
  log(bWriteLog and "logic_friend_gang_up.GetMaxLastWeekLevel max_last_week_level = " .. max_last_week_level)
  return max_last_week_level
end
function logic_friend_gang_up.GetFriendCounts()
  local gang_up_count = logic_friend_gang_up.gang_up_count
  if gang_up_count == nil then
    log(bWriteLog and "logic_friend_gang_up.GetFriendCounts gang_up_count == nil")
    return nil
  end
  local friend_counts = gang_up_count.friend_counts
  if friend_counts == nil then
    log(bWriteLog and "logic_friend_gang_up.GetFriendCounts friend_counts == nil")
    return nil
  end
  if next(friend_counts) == nil then
    log(bWriteLog and "logic_friend_gang_up.GetFriendCounts friend_counts empty")
    return nil
  end
  return friend_counts
end
function logic_friend_gang_up.proc_get_all_friendlist_rsp(friendlist)
  logic_friend_gang_up.gang_up_count = friendlist.gang_up_count or {
    friend_counts = {},
    last_refresh_time = 0
  }
  if logic_friend_gang_up.isInitGangUpdata == false and logic_friend_gang_up.CanSendGangUpChat then
    log(bWriteLog and "LogicFriend.on_get_all_friendlist_rsp 1")
    logic_friend_gang_up.send_gang_up_chat(logic_friend_gang_up.gang_up_chat_friends, logic_friend_gang_up.week_time)
  end
  logic_friend_gang_up.isInitGangUpdata = true
end
function logic_friend_gang_up.send_gang_up_chat(gang_up_chat_friends, week_time)
  log(bWriteLog and "logic_friend_gang_up.send_gang_up_chat")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  logic_friend_gang_up.CanSendGangUpChat = false
  local logic_friend_gang_up = require("client.slua.logic.friend.logic_friend_gang_up")
  local friend_counts = logic_friend_gang_up.GetFriendCounts()
  if friend_counts == nil then
    log(bWriteLog and "LogicFriend.send_gang_up_chat friend_counts == nil")
    return
  end
  local TimeUtil = require("client.common.time_util")
  for k, v in pairs(gang_up_chat_friends) do
    if friend_counts[k] == nil then
      return
    end
    local data = friend_counts[k]
    local channelType = chat_macro.Channel.channelPrivate
    local msg = {}
    msg.    local openBlackLevelRewardData = CDataTable.GetTable("FriendOpenBlackLevelReward")
    local rewardData = openBlackLevelRewardData[v]
    msg.text = ""
    msg.sendTime = TimeUtil.GetServerTimeInSec()
    msg.msgType = chat_macro.OpenBlackMsgType
    msg.chatMsg = rewardData.chatMsg
    msg.last_week_count = data.last_week_count
    msg.intimacies = rewardData.intimacies
    msg.    local msgId = chat_main.CacheMsg(msg)
    ChatHandler.send_chat_req(tostring(k), chat_macro.Channel.channelPrivate, msgId, msg)
  end
end
function logic_friend_gang_up.on_friend_gang_up_chat_ntfyf(gang_up_chat_friends, week_time)
  logic_friend_gang_up.  logic_friend_gang_up.  log(bWriteLog and string.format("LogicFriend.on_friend_gang_up_chat_ntfyf isInitGangUpdata = %s", logic_friend_gang_up.isInitGangUpdata))
  if logic_friend_gang_up.isInitGangUpdata then
    logic_friend_gang_up.send_gang_up_chat(gang_up_chat_friends, week_time)
  else
    logic_friend_gang_up.CanSendGangUpChat = true
  end
end
function logic_friend_gang_up.on_friend_gang_up_count_ntfy(update_counts)
  if not update_counts then
    return
  end
  local gang_up_count = logic_friend_gang_up.gang_up_count
  if not gang_up_count then
    return
  end
  if gang_up_count.friend_counts == nil then
    gang_up_count.friend_counts = {}
  end
  local friend_counts = gang_up_count.friend_counts
  for k, v in pairs(update_counts) do
    if friend_counts[k] then
      friend_counts[k].cur_week_count = v
    else
      friend_counts[k] = {cur_week_count = v, last_week_count = 0}
    end
  end
end
function logic_friend_gang_up.on_friend_gang_up_week_refresh_ntfy(update_counts)
  if not update_counts then
    return
  end
  logic_friend_gang_up.gang_up_count = logic_friend_gang_up.gang_up_count or {}
  logic_friend_gang_up.gang_up_count.friend_counts = update_counts
end
function logic_friend_gang_up.DeleteInnerFriend(friUid)
  local gang_up_count = logic_friend_gang_up.gang_up_count
  if gang_up_count and gang_up_count.friend_counts then
    gang_up_count.friend_counts[friUid] = nil
  end
end
return logic_friend_gang_up