local logic_chat_channel_fiend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local TimeUtil = require("client.common.time_util")
local LogicHistorySystem = {
  lastSaveTime = 0,
  intervalSave = 3,
  ONE_FRIEND_CHAT_LIST_MAX_NUM = 20,
  friendChatAlreadyLoad = {},
  newChatUidList = {},
  is_change_msg_list = false,
  timer_to_save_file = nil
}
function LogicHistorySystem.ClearData()
  LogicHistorySystem.lastSaveTime = 0
  LogicHistorySystem.intervalSave = 3
  LogicHistorySystem.friendChatAlreadyLoad = {}
  LogicHistorySystem.newChatUidList = {}
  LogicHistorySystem.is_change_msg_list = false
end
function LogicHistorySystem.StartTimer()
  local time_ticker = require("common.time_ticker")
  LogicHistorySystem.timer_to_save_file = time_ticker.AddTimerLoop(0, function()
    LogicHistorySystem.SaveAll()
  end, TIMER_INFINITE, LogicHistorySystem.intervalSave)
  log(bWriteLog and "god test history starttimer")
end
function LogicHistorySystem.StopTimer()
  if LogicHistorySystem.timer_to_save_file then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(LogicHistorySystem.timer_to_save_file)
    LogicHistorySystem.timer_to_save_file = nil
  end
  log(bWriteLog and "god test history StopTimer")
end
function LogicHistorySystem.SaveAll()
  local thisTime = TimeUtil.GetServerTimeInSec()
  if thisTime - LogicHistorySystem.lastSaveTime > LogicHistorySystem.intervalSave then
    LogicHistorySystem.lastSaveTime = thisTime
    if LogicHistorySystem.is_change_msg_list then
      LogicHistorySystem.is_change_msg_list = false
      LogicHistorySystem.SaveFriendChat()
    end
  end
end
function LogicHistorySystem.MarkOneMsg(uid)
  LogicHistorySystem.is_change_msg_list = true
  if not LogicHistorySystem.newChatUidList[uid] then
    LogicHistorySystem.newChatUidList[uid] = uid
  end
end
function LogicHistorySystem.SaveFriendChat()
  local friendUid = 0
  local friendChatList = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveCount = 0
  local maxCount = 3
  local logic_lobby_chat_security = require("client.slua.logic.lobby_chat.logic_lobby_chat_security")
  logic_lobby_chat_security.UpdateKeyHash()
  local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
  local replay_msg_params_list = logic_share_replay.GetChatMsgParamsList()
  for _, v in pairs(LogicHistorySystem.newChatUidList) do
    friendUid = v
    local friend = logic_chat_channel_fiend.FriendChatList[friendUid]
    if friend then
      saveCount = saveCount + 1
      log(bWriteLog and "[god] saveCount " .. saveCount)
      if maxCount < saveCount then
        log(bWriteLog and "[god] save to much msg of friend !")
        break
      end
      friendChatList[friendUid] = {}
      friendChatList[friendUid].uid = friendUid
      friendChatList[friendUid].msgList = {}
      local index = 0
      if #friend.messageList > LogicHistorySystem.ONE_FRIEND_CHAT_LIST_MAX_NUM then
        index = #friend.messageList - LogicHistorySystem.ONE_FRIEND_CHAT_LIST_MAX_NUM
      end
      local msgTable
      for k = 1, #friend.messageList do
        if k > index then
          msgTable = DeepCopy(friend.messageList[k])
          if msgTable.msgType ~= chat_macro.ChatSecurityRemind and msgTable.msgType ~= chat_macro.LudoInviteMsgType then
            if msgTable.transOrOrgText then
              if msgTable.isTranslate then
                msgTable.msg = msgTable.transOrOrgText
                msgTable.transOrOrgText = nil
              end
              msgTable.transOrOrgText = nil
              msgTable.isTranslate = nil
              msgTable.languageFrom = nil
              msgTable.translatting = nil
              msgTable.translateFirstLangauge = nil
            end
            if msgTable.msgType == chat_macro.targetShareMsgType and msgTable.content.other then
              msgTable.share_ownerUid = msgTable.content.other.ownerUid
              msgTable.share_score = msgTable.content.other.score
              msgTable.share_timeStamp = msgTable.content.other.timeStamp
            end
            if msgTable.msgType == chat_macro.islandBattleShareMsgType and msgTable.content.other then
              msgTable.share_ownerUid = msgTable.content.other.ownerUid
              msgTable.oppoId = msgTable.content.other.oppoId
              msgTable.score_desc = msgTable.content.other.score_desc
              msgTable.isWin = msgTable.content.other.isWin
              msgTable.type = msgTable.content.other.type
            end
            if msgTable.msgType == chat_macro.passBuyFriendMsgType then
              msgTable.group_id = msgTable.content.other.group_id
              msgTable.group_count = msgTable.content.other.group_count
            end
            if msgTable.msgType == chat_macro.BF_RP_InviteGroupMsgType then
              msgTable.group_id = msgTable.content.other.group_id
              msgTable.group_count = msgTable.content.other.group_count
              msgTable.actType = msgTable.content.other.actType
              msgTable.activityId = msgTable.content.other.activityId
            end
            if msgTable.msgType == chat_macro.replayShareMsgType then
              for _, param in pairs(replay_msg_params_list) do
                msgTable[param] = msgTable.content.other[param]
              end
            end
            if msgTable.msgType == chat_macro.ChatRoomInviteMsgType and msgTable.content.other then
              msgTable.room_id = msgTable.content.other.id
              msgTable.room_member_num = msgTable.content.other.member_num
              msgTable.topic_id = msgTable.content.other.topic_id
            end
            if msgTable.msgType == chat_macro.UGCShareMsgType and msgTable.content.other then
              msgTable.mod_id = msgTable.content.other.mod_id
              msgTable.mod_name = msgTable.content.other.mod_name
              msgTable.mode_desc = msgTable.content.other.mode_desc
              msgTable.url = msgTable.content.other.url
              msgTable.templateId = msgTable.content.other.templateId
              msgTable.isMyMod = msgTable.content.other.isMyMod
            end
            if msgTable.msgType == chat_macro.UGCShareChallengeMsgType and msgTable.content.other then
              msgTable.mod_id = msgTable.content.other.mod_id
              msgTable.mod_name = msgTable.content.other.mod_name
              msgTable.mode_desc = msgTable.content.other.mode_desc
              msgTable.url = msgTable.content.other.url
              msgTable.templateId = msgTable.content.other.templateId
              msgTable.isMyMod = msgTable.content.other.isMyMod
              msgTable.clearanceState = msgTable.content.other.clearanceState
              msgTable.rank = msgTable.content.other.rank
              msgTable.score = msgTable.content.other.score
              msgTable.share_name = msgTable.content.other.share_name
              msgTable.win = msgTable.content.other.win
              msgTable.bSelectShareChallenge = msgTable.content.other.bSelectShareChallenge
              msgTable.leaderboard = msgTable.content.other.leaderboard
            end
            if msgTable.msgType == chat_macro.UGCShareChallengeResultMsgType and msgTable.content.other then
              msgTable.rank = msgTable.content.other.rank
              msgTable.clearanceState = msgTable.content.other.clearanceState
              msgTable.mod_name = msgTable.content.other.mod_name
              msgTable.mode_desc = msgTable.content.other.mode_desc
              msgTable.url = msgTable.content.other.url
              msgTable.pk_result = msgTable.content.other.pk_result
              msgTable.score = msgTable.content.other.score
              msgTable.sharer_uid = msgTable.content.other.sharer_uid
              msgTable.mod_id = msgTable.content.other.mod_id
            end
            if msgTable.msgType == chat_macro.PandoraInviteMsg and msgTable.content.other then
              msgTable.other = msgTable.content.other
            end
            if msgTable.msgType == chat_macro.HomePartyInviteMsgType and msgTable.content.other then
              msgTable.start_time = msgTable.content.other.start_time
              msgTable.end_time = msgTable.content.other.end_time
              msgTable.party_type = msgTable.content.other.party_type
              msgTable.name = msgTable.content.other.name
              msgTable.manor_invite_card = msgTable.content.other.manor_invite_card
            end
            if msgTable.msgType == chat_macro.WeddingInviteMsgType and msgTable.content.other then
              msgTable.start_time = msgTable.content.other.start_time
              msgTable.end_time = msgTable.content.other.end_time
              msgTable.name = msgTable.content.other.name
              msgTable.memberLeft = msgTable.content.other.memberLeft
              msgTable.squad_name = msgTable.content.other.squad_name
            end
            if msgTable.msgType == chat_macro.MilestoneShare and msgTable.content.other then
              msgTable.itemID = msgTable.content.other.itemID
            end
            if msgTable.msgType == chat_macro.UGCShareCollectionMsgType and msgTable.content.other then
              msgTable.mod_collection_id = msgTable.content.other.mod_collection_id
              msgTable.name = msgTable.content.other.name
              msgTable.tag = msgTable.content.other.tag
              msgTable.desc = msgTable.content.other.desc
              msgTable.url = msgTable.content.other.url
              msgTable.isMyMod = msgTable.content.other.isMyMod
            end
            if (msgTable.msgType == chat_macro.temuInvite or msgTable.msgType == chat_macro.temuTaskRemind) and msgTable.content.other then
              msgTable.other = msgTable.content.other
            end
            if msgTable.msgType == chat_macro.WarmUpGroupInvite and msgTable.content.other then
              msgTable.other = msgTable.content.other
            end
            if msgTable.content.evaluation then
              msgTable.evaluation = msgTable.content.evaluation
            end
            if msgTable.content.last_week_count then
              msgTable.chatMsg = msgTable.content.chatMsg
              msgTable.last_week_count = msgTable.content.last_week_count
              msgTable.intimacies = msgTable.content.intimacies
              msgTable.week_time = msgTable.content.week_time
            end
            if msgTable.content.chat_bubble then
              msgTable.chat_bubble = msgTable.content.chat_bubble
            end
            if msgTable.msgType == chat_macro.ManorChatMsgType and msgTable.content.manorUid then
              msgTable.manorUid = msgTable.content.manorUid
            end
            if (msgTable.msgType == chat_macro.homeJointInviteMsgType or msgTable.msgType == chat_macro.homeJointTerminateMsgType) and (not msgTable.msg or msgTable.msg == "") then
              msgTable.msg = tostring(msgTable.msgType)
            end
            if msgTable.msgType == chat_macro.SendPicShare then
              msgTable.sharePicUrl = msgTable.content.sharePicUrl
              msgTable.shareContentType = msgTable.content.shareContentType
              msgTable.sharePicSenderUid = msgTable.content.curUId
              msgTable.sendChatJumpUrl = msgTable.content.jumpUrl
            end
            if msgTable.msgType == chat_macro.BF_Sub_InviteGroupMsgType then
              msgTable.other = msgTable.content.other
            end
            if msgTable.msgType == chat_macro.CardCollectionSwapMsgType and msgTable.content.other then
              msgTable.other = msgTable.content.other
            end
            if msgTable.msgType == chat_macro.GroupBuyFriendsMsgType and msgTable.content.other then
              msgTable.other = msgTable.content.other
            end
            if msgTable.msgType == chat_macro.FlashMatchTeamInvite and msgTable.content.other then
              msgTable.other = msgTable.content.other
            end
            if msgTable.content then
              msgTable.content = nil
            end
            if msgTable.zoneId then
              msgTable.zoneId = nil
            end
            msgTable.zoneId = nil
            msgTable.zoneIp = nil
            logic_lobby_chat_security.PackMsg(msgTable)
            msgTable.version = Client.GetAppVersion() or "0.0.0.0"
            table.insert(friendChatList[friendUid].msgList, msgTable)
          end
        end
      end
      log(bWriteLog and "[god] save msg of friend !")
      local fileName = string.format("%s/%s/%s", PlayerPrefsSystem.ePlayerPrefsType.eFriendHistoryChat.path, tostring(DataMgr.roleData.openID), friendUid)
      PlayerPrefsSystem.SaveFriendHistroyChat(friendChatList[friendUid], fileName, friendUid)
    end
  end
  if maxCount < saveCount then
    for k, v in pairs(friendChatList) do
      LogicHistorySystem.newChatUidList[v.uid] = nil
    end
    LogicHistorySystem.is_change_msg_list = true
  else
    LogicHistorySystem.newChatUidList = {}
  end
end
function LogicHistorySystem.CheckIsLoad(friendUid)
  if LogicHistorySystem.friendChatAlreadyLoad[friendUid] == true then
    return true
  else
    return false
  end
end
function LogicHistorySystem.LoadFriendChat(friendUid)
  LogicHistorySystem.friendChatAlreadyLoad[friendUid] = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileName = string.format("%s/%s/%s", PlayerPrefsSystem.ePlayerPrefsType.eFriendHistoryChat.path, tostring(DataMgr.roleData.openID), friendUid)
  local playerPrefsDict = PlayerPrefsSystem.LoadFriendHistroyChat(fileName, friendUid)
  if playerPrefsDict ~= nil then
    return playerPrefsDict
  end
end
function LogicHistorySystem.CheckHistoryOneMsgParam(historyMsg)
  if historyMsg == nil then
    return false
  else
    if historyMsg.voiceMsgId ~= nil and historyMsg.voiceMsgId ~= "" then
      return true
    end
    local notValueParams = {
      "version",
      "uid",
      "send_time",
      "name",
      "msgChannel",
      "msgType"
    }
    local notNilParamList = {"level", "msg"}
    for _, v in pairs(notValueParams) do
      if historyMsg[v] == nil or historyMsg[v] == "" then
        return false
      end
    end
    for _, v in pairs(notNilParamList) do
      if historyMsg[v] == nil or historyMsg[v] == "" then
        return false
      end
    end
  end
  return true
end
function LogicHistorySystem.DeleteHistoryChatByUid(friendUid)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileName = string.format("%s/%s/%s", PlayerPrefsSystem.ePlayerPrefsType.eFriendHistoryChat.path, tostring(DataMgr.roleData.openID), friendUid)
  PlayerPrefsSystem.DeleteFriendHistoryChat(fileName, friendUid)
end
function LogicHistorySystem.SaveFriendChatListOrder()
  if not logic_chat_channel_fiend.FriendList or 0 == #logic_chat_channel_fiend.FriendList then
    log(bWriteLog and "LogicHistorySystem.SaveFriendChatListOrder empty")
    return
  end
  local cached = logic_chat_channel_fiend.SavedFriendListOrder or {}
  local same = #cached == #logic_chat_channel_fiend.FriendList
  local sortedUids = {}
  for i, v in ipairs(logic_chat_channel_fiend.FriendList) do
    sortedUids[i] = v.uid
    same = same and cached[i] == v.uid
  end
  if same then
    log(bWriteLog and "LogicHistorySystem.SaveFriendChatListOrder same order")
    return
  end
  logic_chat_channel_fiend.SavedFriendListOrder = sortedUids
  log(bWriteLog and string.format("LogicHistorySystem.SaveFriendChatList friendList:%s", table.concat(sortedUids, "|")))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(sortedUids, PlayerPrefsSystem.ePlayerPrefsType.eFriendChatOrder)
end
function LogicHistorySystem.LoadFriendChatListOrder()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tOrder = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFriendChatOrder) or {}
  log(bWriteLog and string.format(" LogicHistorySystem.LoadFriendChatListOrder :%s", table.concat(tOrder, "|")))
  return tOrder
end
return LogicHistorySystem