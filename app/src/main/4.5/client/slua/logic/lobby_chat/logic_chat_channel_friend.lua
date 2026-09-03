local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
local super_list = require("common.super_list")
local ChatHandler = require("client.network.Protocol.ChatHandler")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local TimeUtil = require("client.common.time_util")
local logic_chat_channel_friend = {
  FriendList = super_list.Create(),
  ChatOnlineFriendCount = 0,
  ChatTotalFriendCount = 0,
  CurrentGid = "",
  SavedFriendListOrder = nil,
  FriendChatList = {},
  MAX_FRIEND_MESSAGE_CACHE_NUM = 100,
  RequestOfflineMsg = false,
  TimerInterval = {1, 0},
  bSnapshotLocked = false,
  _resortDebounceUids = {},
  _resortDebounceTimer = nil
}
function logic_chat_channel_friend.Init()
  local historyChat = require("client.slua.logic.lobby_chat.logic_history_chat")
  historyChat.StartTimer()
  logic_chat_channel_friend.RegisterEvent()
end
function logic_chat_channel_friend.RegisterEvent()
  EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ADD_DELETE_FRIEND, logic_chat_channel_friend.OnAddDeleteFriend)
  EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GROUP_ONLINE_CHANGE, logic_chat_channel_friend.OnRefreshFriendData)
  EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_PROFILE_ONLINE_GROUP_GET, logic_chat_channel_friend.OnRefreshFriendData)
  EventSystem:registEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_EXIT_ONE_PLAYER_NEW, logic_chat_channel_friend.OnStrangerLeaveIsland)
end
function logic_chat_channel_friend.UnRegisterEvent()
  EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ADD_DELETE_FRIEND, logic_chat_channel_friend.OnAddDeleteFriend)
  EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_PROFILE_ONLINE_GROUP_GET, logic_chat_channel_friend.OnRefreshFriendData)
  EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GROUP_ONLINE_CHANGE, logic_chat_channel_friend.OnRefreshFriendData)
  EventSystem:unregistEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_SOCIAL_ISLAND_EXIT_ONE_PLAYER_NEW, logic_chat_channel_friend.OnStrangerLeaveIsland)
end
function logic_chat_channel_friend.ClearData()
  local historyChat = require("client.slua.logic.lobby_chat.logic_history_chat")
  historyChat.SaveFriendChatListOrder()
  logic_chat_channel_friend.FriendList:ClearData()
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  for uid, v in pairs(logic_chat_channel_friend.FriendChatList) do
    if not logic_housekeeper_dialog_lobby:IsHouseKeeper(uid) then
      v.messageList:ClearData()
      logic_chat_channel_friend.FriendChatList[uid] = nil
    end
  end
  logic_chat_channel_friend.ChatOnlineFriendCount = 0
  logic_chat_channel_friend.ChatTotalFriendCount = 0
  logic_chat_channel_friend.CurrentGid = ""
  logic_chat_channel_friend.RequestOfflineMsg = false
  logic_chat_channel_friend.bSnapshotLocked = false
  logic_chat_channel_friend._resortDebounceUids = {}
  if logic_chat_channel_friend._resortDebounceTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(logic_chat_channel_friend._resortDebounceTimer)
    logic_chat_channel_friend._resortDebounceTimer = nil
  end
  historyChat.StopTimer()
  historyChat.ClearData()
  logic_chat_channel_friend.UnRegisterEvent()
end
function logic_chat_channel_friend.OnAddDeleteFriend(_, _, uid, isAddFriend)
  if isAddFriend then
    logic_chat_channel_friend.RefreshFriendData()
  else
    local refMsg = logic_chat_channel_friend.GetFriendChatData(uid)
    if refMsg then
      refMsg.messageList:ClearData()
      logic_chat_channel_friend.RemoveFriendChatData(uid)
    end
    if logic_chat_channel_friend.CurrentGid == tostring(uid) then
      logic_chat_channel_friend.CurrentGid = ""
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_DELETE_MEMBER_IN_FRIEND_LIST)
    end
    local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
    if logic_chat_stranger.IsStranger(uid) then
      logic_chat_channel_friend.DeleteStranger(uid)
    else
      logic_chat_channel_friend.RefreshFriendData()
      logic_chat_channel_friend.RefreshTotalUnread()
      local LogicHistorySystem = require("client.slua.logic.lobby_chat.logic_history_chat")
      LogicHistorySystem.DeleteHistoryChatByUid(uid)
    end
  end
end
function logic_chat_channel_friend.OnRefreshFriendData()
  logic_chat_channel_friend.RefreshFriendData()
end
function logic_chat_channel_friend.OnStrangerLeaveIsland(_, _, uid)
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  if logic_chat_stranger.IsStranger(uid) then
    logic_chat_channel_friend.DeleteStranger(uid)
    if tostring(logic_chat_channel_friend.CurrentGid) == tostring(uid) then
      logic_chat_channel_friend.CurrentGid = ""
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_DELETE_MEMBER_IN_FRIEND_LIST)
    end
  end
end
function logic_chat_channel_friend.RefreshFriendData()
  if logic_chat_channel_friend.bSnapshotLocked then
    logic_chat_channel_friend.RefreshOnlineCount()
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_REFRESH_FRIEND_UI)
    return
  end
  logic_chat_channel_friend.InitFriendList()
end
function logic_chat_channel_friend.RefreshOnlineCount()
  local onlineCount = 0
  local logicNewFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendList = logicNewFriend.GetFriendList(true)
  if friendList then
    for i = 1, #friendList do
      if friendList[i].online == 1 then
        onlineCount = onlineCount + 1
      end
    end
    logic_chat_channel_friend.ChatTotalFriendCount = #friendList
  end
  logic_chat_channel_friend.ChatOnlineFriendCount = onlineCount
end
function logic_chat_channel_friend.InitFriendList()
  local logicNewFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendList = logicNewFriend.GetFriendList(true)
  if nil == friendList then
    log(bWriteLog and "!!!!!!!!!!!!!!!!!!!empty friend list !!!!!!!!!!!!!!!!")
    return
  end
  if nil == logic_chat_channel_friend.SavedFriendListOrder then
    local historyChat = require("client.slua.logic.lobby_chat.logic_history_chat")
    logic_chat_channel_friend.SavedFriendListOrder = historyChat.LoadFriendChatListOrder()
  end
  if not next(logic_chat_channel_friend.FriendChatList) and 0 ~= #friendList and 0 ~= #logic_chat_channel_friend.SavedFriendListOrder then
    local sortedList = {}
    local savedOrder = logic_chat_channel_friend.SavedFriendListOrder
    if #friendList ~= #savedOrder then
      log(bWriteLog and string.format(" logic_chat_channel_friend.GetFriendData  length not equal :friendList:%s savedList:%s", #friendList, #savedOrder))
    end
    local friendMap = {}
    for i, vv in ipairs(friendList) do
      friendMap[vv.uid] = vv
    end
    local sortedLen = 0
    for i, v in ipairs(savedOrder) do
      local vv = friendMap[v]
      if vv then
        sortedLen = sortedLen + 1
        sortedList[sortedLen] = vv
        vv.savedOrder = sortedLen
        friendMap[v] = nil
      end
    end
    for i, v in ipairs(friendList) do
      if friendMap[v.uid] then
        sortedLen = sortedLen + 1
        sortedList[sortedLen] = v
        v.savedOrder = sortedLen
        v.uid = tonumber(v.uid)
      end
    end
    friendList = sortedList
  else
    log(bWriteLog and " logic_chat_channel_friend.GetFriendData use sort func")
    table.sort(friendList, logic_chat_channel_friend.SortFriendList)
  end
  logic_chat_channel_friend.ChatTotalFriendCount = #friendList
  local onlineCount = 0
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local totalCount = logic_chat_channel_friend.ChatTotalFriendCount
  for i = 1, totalCount do
    local friendInfo = friendList[i]
    local profile = logic_profile:GetLocalProfile(friendInfo.uid)
    if profile then
      if friendInfo.online == 1 then
        onlineCount = onlineCount + 1
      end
      profile.upassIsBuy = profile.upass_is_buy ~= 0
      profile.upassShow = profile.upass_is_show ~= 0
      profile.upassKeepBuy = profile.upass_keep_buy or 0
    end
  end
  logic_chat_channel_friend.ChatOnlineFriendCount = onlineCount
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  local strangerList = logic_chat_stranger.GetStrangerList()
  if next(strangerList) then
    for _, friendInfo in pairs(friendList) do
      local friendUid = tonumber(friendInfo.uid)
      if strangerList[friendUid] then
        strangerList[friendUid] = nil
      end
    end
    if next(strangerList) then
      local strangerArr = {}
      local strangerCount = 0
      for _, v in pairs(strangerList) do
        strangerCount = strangerCount + 1
        strangerArr[strangerCount] = v
      end
      local friendCount = #friendList
      for i = friendCount, 1, -1 do
        friendList[i + strangerCount] = friendList[i]
      end
      for i = 1, strangerCount do
        friendList[i] = strangerArr[i]
      end
    end
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  local curHousekeeperId = logic_housekeeper_dialog_lobby:GetCurHousekeeperId()
  local isPlanPHMode = logic_home_entry:IsPlanPHMode()
  log(bWriteLog and "logic_chat_channel_friend.InitFriendList curHousekeeperId = " .. tostring(curHousekeeperId) .. " isPlanPHMode = " .. tostring(isPlanPHMode))
  if not isPlanPHMode and 0 < curHousekeeperId then
    log(bWriteLog and "logic_chat_channel_friend.InitFriendList - not isPlanPHMode and curHousekeeperId > 0")
    local newMessageCount = logic_chat_channel_friend.GetFriendUnreadMsgCount(curHousekeeperId)
    table.insert(friendList, 1, {
      uid = curHousekeeperId,
      housekeeper = true,
      unreadCount = newMessageCount
    })
  end
  logic_chat_channel_friend.RefreshChannelTabUnread()
  logic_chat_channel_friend.FriendList:SetData(friendList)
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_REFRESH_FRIEND_UI)
end
function logic_chat_channel_friend.SortFriendList(a, b)
  local chatTime1 = logic_chat_channel_friend.GetFriendLastSendTime(a.uid)
  local chatTime2 = logic_chat_channel_friend.GetFriendLastSendTime(b.uid)
  if chatTime1 > chatTime2 then
    return true
  elseif chatTime1 < chatTime2 then
    return false
  end
  if a.online and b.online then
    if a.online > b.online then
      return true
    elseif a.online < b.online then
      return false
    end
  end
  if a.savedOrder and b.savedOrder then
    if a.savedOrder < b.savedOrder then
      return true
    elseif a.savedOrder > b.savedOrder then
      return false
    end
  end
  local uid_a = tonumber(a.uid)
  local uid_b = tonumber(b.uid)
  if uid_a == nil or uid_b == nil then
    return false
  else
    return uid_a > uid_b
  end
end
function logic_chat_channel_friend.GetFriendLastSendTime(uid)
  local refMsg = logic_chat_channel_friend.GetFriendChatData(uid)
  if refMsg then
    return refMsg.send_time
  end
  return 0
end
function logic_chat_channel_friend.TopTargetUserChatInList(sender_uid)
  if #logic_chat_channel_friend.FriendList > 0 and logic_chat_channel_friend.FriendList[1].uid ~= sender_uid then
    local index = 1
    local friend
    for k, v in pairs(logic_chat_channel_friend.FriendList) do
      if tonumber(v.uid) == tonumber(sender_uid) then
        index = k
        friend = v
        break
      end
    end
    if 1 < index then
      logic_chat_channel_friend.FriendList:RemoveItem(index)
      logic_chat_channel_friend.FriendList:InsertItem(1, friend)
    end
  end
end
function logic_chat_channel_friend.DynamicResortToTop(target_uid)
  target_uid = tonumber(target_uid)
  if not target_uid then
    return
  end
  local list = logic_chat_channel_friend.FriendList
  if #list == 0 then
    return
  end
  local targetIndex, targetItem
  for k, v in pairs(list) do
    if tonumber(v.uid) == target_uid then
      targetIndex = k
      targetItem = v
      break
    end
  end
  if not targetItem then
    log(bWriteLog and "DynamicResortToTop: uid not found in FriendList, uid=" .. tostring(target_uid))
    return
  end
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  local insertPos = 1
  for i, v in ipairs(list) do
    if v.housekeeper or logic_chat_stranger.IsStranger(v.uid) then
      insertPos = i + 1
    else
      break
    end
  end
  if targetIndex == insertPos then
    return
  end
  list:RemoveItem(targetIndex)
  if targetIndex < insertPos then
    insertPos = insertPos - 1
  end
  list:InsertItem(insertPos, targetItem)
  log(bWriteLog and "DynamicResortToTop: uid=" .. tostring(target_uid) .. " moved to pos=" .. tostring(insertPos))
end
function logic_chat_channel_friend.DynamicResortToTopDebounced(uid)
  uid = tonumber(uid)
  if not uid then
    return
  end
  logic_chat_channel_friend._resortDebounceUids[uid] = TimeUtil.GetServerTimeInSec()
  local time_ticker = require("common.time_ticker")
  if not logic_chat_channel_friend._resortDebounceTimer then
    logic_chat_channel_friend._resortDebounceTimer = time_ticker.AddTimerOnce(1.0, function()
      local sorted = {}
      for u, t in pairs(logic_chat_channel_friend._resortDebounceUids) do
        sorted[#sorted + 1] = {uid = u, time = t}
      end
      table.sort(sorted, function(a, b)
        return a.time < b.time
      end)
      for _, entry in ipairs(sorted) do
        logic_chat_channel_friend.DynamicResortToTop(entry.uid)
      end
      logic_chat_channel_friend._resortDebounceUids = {}
      logic_chat_channel_friend._resortDebounceTimer = nil
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_REFRESH_FRIEND_UI)
    end)
  end
end
function logic_chat_channel_friend.SetHouseKeeperToFriend(hkpId)
  log(bWriteLog and "logic_chat_channel_friend.SetHouseKeeperToFriend hkpId:" .. tostring(hkpId))
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  for index, friendInfo in pairs(logic_chat_channel_friend.FriendList) do
    if tonumber(friendInfo.uid) == tonumber(hkpId) then
      log(bWriteLog and "logic_chat_channel_friend.SetHouseKeeperToFriend already have")
      return
    elseif logic_housekeeper_dialog_lobby:IsHouseKeeper(friendInfo.uid) then
      logic_chat_channel_friend.FriendList:RemoveItem(index)
    end
  end
  logic_chat_channel_friend.FriendList:InsertItem(1, {uid = hkpId, housekeeper = true})
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_HKP_DIALOG_LOBBY_ADD_HKP)
end
function logic_chat_channel_friend.SetStrangerToFriend(stranger)
  logic_chat_channel_friend.FriendList:InsertItem(1, stranger)
  log(bWriteLog and "god test SetStrangerToFriend uid " .. tostring(stranger.uid))
end
function logic_chat_channel_friend.UpdateStrangerStauts(uid)
  for k, friendInfo in pairs(logic_chat_channel_friend.FriendList) do
    if tostring(friendInfo.uid) == tostring(uid) then
      logic_chat_channel_friend.FriendList[k] = friendInfo
      log(bWriteLog and "god test UpdateStrangerStauts uid " .. tostring(uid))
      break
    end
  end
end
function logic_chat_channel_friend.DeleteStranger(uid)
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  logic_chat_stranger.DeleteStranger(uid)
  log(bWriteLog and "god test DeleteStranger " .. tostring(uid))
  for k, friendInfo in pairs(logic_chat_channel_friend.FriendList) do
    if tostring(friendInfo.uid) == tostring(uid) then
      logic_chat_channel_friend.FriendList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_friend.ClearStranger()
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  logic_chat_stranger.ClearData()
  logic_chat_channel_friend.InitFriendList()
end
function logic_chat_channel_friend.EnterLobby()
  logic_chat_channel_friend.ClearStranger()
end
function logic_chat_channel_friend.CheckIsStranger(uid)
  local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
  local isFriend = FriendSystem.IsMyFriend(tonumber(uid))
  if isFriend then
    return false
  else
    return true
  end
end
function logic_chat_channel_friend.AddNewMsgItem(refMsg, chatMsg)
  for k, v in pairs(refMsg.messageList) do
    if v.msgType == chat_macro.OpenBlackMsgType and chatMsg.msgType == chat_macro.OpenBlackMsgType and v.content.week_time == chatMsg.content.week_time then
      return
    end
  end
  if #refMsg.messageList >= logic_chat_channel_friend.MAX_FRIEND_MESSAGE_CACHE_NUM then
    logic_chat_table_pool.Recycle(refMsg.messageList[1])
    refMsg.messageList:RemoveItem(1)
  end
  refMsg.messageList:AppendItem(chatMsg)
  local logic_chat_quick_msg = require("client.slua.logic.lobby_chat.logic_chat_quick_msg")
  logic_chat_quick_msg.TryShowAnswerUIWhenMsgCome(chatMsg)
end
function logic_chat_channel_friend.AddFightNewChat(chatMsg)
  if chatMsg.msgType == chat_macro.OpenBlackMsgType then
    return
  end
  if chatMsg.content.voice == nil or chatMsg.content.voice == "" then
    local logic_chat_channel_friend_in_fight = require("client.slua.logic.lobby_chat.logic_chat_channel_friend_in_fight")
    logic_chat_channel_friend_in_fight.on_friend_fight_msg(chatMsg.uid, chatMsg)
  end
end
function logic_chat_channel_friend.AddStrangerNewChat(chatMsg)
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  local refMsg = logic_chat_stranger.AddNewChat(chatMsg)
  logic_chat_channel_friend.update_friend_unread(chatMsg, refMsg.newMessageCount)
end
function logic_chat_channel_friend.AddNewChat(chatMsg)
  if chatMsg.content and chatMsg.content.is_stranger then
    logic_chat_channel_friend.AddStrangerNewChat(chatMsg)
  else
    logic_chat_channel_friend.LoadHistoryChat(chatMsg.uid)
    local refMsg = logic_chat_channel_friend.CheckAndCreateChatMsg(chatMsg.uid)
    logic_chat_channel_friend.SetMsgTime(refMsg, chatMsg)
    logic_chat_channel_friend.SetMsgNewMessageCount(refMsg, chatMsg)
    logic_chat_channel_friend.AddNewMsgItem(refMsg, chatMsg)
    logic_chat_channel_friend.update_friend_unread(chatMsg, refMsg.newMessageCount)
    logic_chat_channel_friend.MarkHistoryMsg(chatMsg)
    logic_chat_channel_friend.AddFightNewChat(chatMsg)
  end
end
function logic_chat_channel_friend.SetMsgTime(refMsg, chatMsg)
  if not refMsg then
    return
  end
  if refMsg.send_time < chatMsg.send_time then
    refMsg.send_time = chatMsg.send_time
  end
  local thisTime = TimeUtil.OSTime()
  if chatMsg.send_time and chatMsg.send_time > 0 then
    thisTime = chatMsg.send_time
  end
  local diffTime = thisTime - refMsg.lastMsgSendTime
  local interval = 300
  if diffTime > interval then
    chatMsg.msgSendTime = TimeUtil.FormatTime_HM(thisTime, true)
    refMsg.recordLastMsgSendTime = thisTime
  else
    local diffRecordTime = thisTime - refMsg.recordLastMsgSendTime
    if 0 < refMsg.recordLastMsgSendTime and 60 < diffTime and interval < diffRecordTime then
      chatMsg.msgSendTime = TimeUtil.FormatTime_HM(thisTime, true)
      refMsg.recordLastMsgSendTime = thisTime
    else
      chatMsg.msgSendTime = ""
    end
  end
  chatMsg.msgSendDate = TimeUtil.FormatTime_YMD(thisTime, true)
  refMsg.lastMsgSendTime = thisTime
end
function logic_chat_channel_friend.GetRefMsg(uid)
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  local ishkp = logic_housekeeper_dialog_lobby:IsHouseKeeper(uid)
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  if logic_new_friend.IsMyFriend(uid) or ishkp then
    return logic_chat_channel_friend.CheckAndCreateChatMsg(uid)
  else
    local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
    return logic_chat_stranger.CheckAndCreateChatMsg(uid)
  end
end
function logic_chat_channel_friend.CheckAndCreateChatMsg(uid)
  log(bWriteLog and string.format("logic_chat_channel_friend.CheckAndCreateChatMsg %s", uid))
  uid = tostring(uid)
  local refMsg = logic_chat_channel_friend.GetFriendChatData(uid)
  if nil == refMsg then
    refMsg = {}
    refMsg.gid = uid
    refMsg.newMessageCount = 0
    refMsg.lastMsgSendTime = 0
    refMsg.recordLastMsgSendTime = 0
    refMsg.send_time = 0
    refMsg.messageList = super_list.Create()
    logic_chat_channel_friend.AddFriendChatData(uid, refMsg)
  end
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  local isAddPokeSelf = true
  for k, v in pairs(refMsg.messageList) do
    if v.uid and v.uid == uid and v.Poke and v.selfMsg == false then
      isAddPokeSelf = false
    end
  end
  if logic_poke:IsPokeSelf(tonumber(uid)) and isAddPokeSelf and logic_poke:ChatAddPoke(uid, false) then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if not profile then
      return
    end
    local chatMsg = {
      name = profile.nickName,
      msgType = 0,
      Poke = true,
      uid = tostring(uid),
      sender_uid = tonumber(uid),
      msgChannel = 4,
      send_time = logic_poke:IsPokeSelf(tonumber(uid)),
      content = {is_positive = true},
      selfMsg = false
    }
    refMsg.messageList:AppendItem(chatMsg)
  end
  local isAddPokeFriend = true
  for k, v in pairs(refMsg.messageList) do
    if v.uid and v.uid == uid and v.Poke and v.selfMsg == true then
      isAddPokeFriend = false
    end
  end
  if logic_poke:IsPokeFriend(tonumber(uid)) and isAddPokeFriend and logic_poke:ChatAddPoke(uid, true) then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if not profile then
      return
    end
    local chatMsg = {
      name = profile.nickName,
      msgType = 0,
      Poke = true,
      uid = tostring(uid),
      sender_uid = tonumber(uid),
      msgChannel = 4,
      send_time = logic_poke:IsPokeFriend(tonumber(uid)),
      content = {is_positive = true},
      selfMsg = true
    }
    refMsg.messageList:AppendItem(chatMsg)
  end
  table.sort(refMsg.messageList, function(a, b)
    if a.send_time and b.send_time then
      return a.send_time < b.send_time
    elseif a.send_time then
      return false
    elseif b.send_time then
      return true
    else
      return false
    end
  end)
  log_tree("[v_yunjxing]logic_chat_channel_friend.CheckAndCreateChatMsg refMsg.messageList ", refMsg.messageList)
  return refMsg
end
function logic_chat_channel_friend.GetMessageList(chatMsg)
  local refMsg = logic_chat_channel_friend.GetFriendChatData(chatMsg.uid)
  if refMsg then
    return refMsg.messageList
  else
    local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
    local strangerChat = logic_chat_stranger.strangerChatList[chatMsg.uid]
    if strangerChat then
      return strangerChat.messageList
    end
  end
  return nil
end
function logic_chat_channel_friend.GetFriendChatData(suid)
  return logic_chat_channel_friend.FriendChatList[tostring(suid)]
end
function logic_chat_channel_friend.RemoveFriendChatData(suid)
  logic_chat_channel_friend.FriendChatList[tostring(suid)] = nil
end
function logic_chat_channel_friend.AddFriendChatData(suid, refMsg)
  logic_chat_channel_friend.FriendChatList[tostring(suid)] = refMsg
end
function logic_chat_channel_friend.GetNewChatFriendGid()
  local chatTime = 0
  local gid = ""
  for k, v in pairs(logic_chat_channel_friend.FriendChatList) do
    if 0 < v.newMessageCount and chatTime < v.send_time then
      chatTime = v.send_time
      gid = v.gid
    end
  end
  return gid
end
function logic_chat_channel_friend.ClearSomesMsg(uid)
  local refMsg = logic_chat_channel_friend.GetFriendChatData(uid)
  if refMsg then
    local chatMessageList = refMsg.messageList
    if chatMessageList then
      chatMessageList:ClearData()
    end
  end
end
function logic_chat_channel_friend.update_friend_unread(chatMsg, message_count)
  local uid = chatMsg.uid
  if chatMsg.Poke and chatMsg.selfMsg then
    return
  end
  local msgContent = chatMsg.content
  if not chatMsg.selfMsg and msgContent and (msgContent.isReserveMsg or msgContent.isGameResultReserveMsg) then
    local extraData = {
      isReserveMsg = chatMsg.content.isReserveMsg,
      isGameResultReserveMsg = chatMsg.content.isGameResultReserveMsg
    }
    logic_chat_channel_friend.RefreshTotalUnread(uid, extraData)
  else
    logic_chat_channel_friend.RefreshTotalUnread(uid)
  end
  logic_chat_channel_friend.RefreshUnreadList(uid, message_count)
  logic_chat_channel_friend.DynamicResortToTopDebounced(uid)
end
function logic_chat_channel_friend.RefreshUnreadList(uid, message_count)
  local refMsg = logic_chat_channel_friend.GetFriendChatData(uid)
  if refMsg then
    refMsg.newMessageCount = message_count
  else
    local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
    logic_chat_stranger.RefreshStrangerUnreadList(uid, message_count)
  end
  for k, v in pairs(logic_chat_channel_friend.FriendList) do
    if tonumber(v.uid) == tonumber(uid) and v.unreadCount ~= message_count then
      v.unreadCount = message_count
      logic_chat_channel_friend.FriendList[k] = v
      break
    end
  end
end
function logic_chat_channel_friend.RefreshTotalUnread(uid, extraData)
  logic_chat_channel_friend.RefreshChannelTabUnread()
  logic_chat_channel_friend.RefreshEntranceUnread(uid, extraData)
end
function logic_chat_channel_friend.RefreshChannelTabUnread()
  local unreadCount = 0
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local isPlanPHMode = logic_home_entry:IsPlanPHMode()
  for _, v in pairs(logic_chat_channel_friend.FriendChatList) do
    if not logic_housekeeper_dialog_lobby:IsHouseKeeper(v.gid) then
      unreadCount = unreadCount + v.newMessageCount
    elseif isPlanPHMode then
    else
      local logic_chat_butler_setting = require("client.slua.umg.lobby_chat.logic_chat_butler_setting")
      local isCloseHouseKeeperRemind = not logic_chat_butler_setting.isOpen
      if isCloseHouseKeeperRemind then
      else
        unreadCount = unreadCount + v.newMessageCount
      end
    end
  end
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  unreadCount = unreadCount + logic_chat_stranger.GetTotalUnread()
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelPrivate, 0 < unreadCount)
end
function logic_chat_channel_friend.RefreshEntranceUnread(uid, extraData)
  local unreadCount = 0
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  if logic_housekeeper_dialog_lobby:IsHouseKeeper(uid or 0) then
    for _, v in pairs(logic_chat_channel_friend.FriendChatList) do
      if tonumber(v.gid) == tonumber(uid) then
        unreadCount = unreadCount + v.newMessageCount
      end
    end
  else
    for _, v in pairs(logic_chat_channel_friend.FriendChatList) do
      if not logic_housekeeper_dialog_lobby:IsHouseKeeper(v.gid) then
        unreadCount = unreadCount + v.newMessageCount
      end
    end
    local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
    unreadCount = unreadCount + logic_chat_stranger.GetTotalUnread()
  end
  local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
  if extraData then
    logic_chat_entrance:SetUnreadFriendReserveChatMsgCount(unreadCount, uid, extraData.isReserveMsg, extraData.isGameResultReserveMsg)
  else
    logic_chat_entrance:SetUnreadFriendChatMsgCount(unreadCount, uid)
  end
end
function logic_chat_channel_friend.SetMsgNewMessageCount(refMsg, chatMsg)
  if not refMsg then
    return
  end
  if refMsg.gid == logic_chat_channel_friend.CurrentGid and chat_main.currentChannel == chat_macro.Channel.channelPrivate and UIManager.IsUIShow(UIManager.UI_Config.ui_chat_main) then
    refMsg.newMessageCount = 0
  elseif chatMsg and chatMsg.msgType == 16 and chatMsg.sender_uid == tostring(DataMgr.roleData.uid) then
    log(bWriteLog and "logic_chat_channel_friend.SetMsgNewMessageCount isMyGroupBuyMsg, do nothing")
  else
    local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
    local ishkp = logic_housekeeper_dialog_lobby:IsHouseKeeper(refMsg.gid)
    if ishkp then
      refMsg.newMessageCount = 1
    else
      refMsg.newMessageCount = refMsg.newMessageCount + 1
    end
  end
end
function logic_chat_channel_friend.GetFriendUnreadMsgCount(uid)
  local refMsg = logic_chat_channel_friend.GetFriendChatData(uid)
  if refMsg then
    return refMsg.newMessageCount
  end
  return 0
end
function logic_chat_channel_friend.req_get_offline_chat_msg_num()
  log(bWriteLog and "LobbyChatSystem.req_get_offline_chat_msg_num")
  ChatHandler.send_get_offline_chat_msg_count_req()
end
function logic_chat_channel_friend.on_get_offline_chat_msg_count(msg, count)
  log(bWriteLog and "LobbyChatSystem.on_get_offline_chat_msg_count " .. msg .. " " .. count)
  if msg == NetErrorCode_NONE or msg == "no_msg" then
    local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
    logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelPrivate, 0 < count)
    local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
    logic_chat_entrance:SetUnreadFriendChatMsgCount(count)
  end
end
function logic_chat_channel_friend.OnLoginSuccess()
  logic_chat_channel_friend.RequestOfflineMsg = false
end
function logic_chat_channel_friend.GetOfflineChatMsgReq()
  if not logic_chat_channel_friend.RequestOfflineMsg then
    ChatHandler.send_get_offline_chat_msg_req()
    logic_chat_channel_friend.RequestOfflineMsg = true
  end
end
function logic_chat_channel_friend.on_get_offline_chat_msg(offlineMsg)
  if offlineMsg == nil then
    return
  end
  local logic_profile_security = require("client.slua.logic.profile.logic_profile_security")
  logic_profile_security.ProcOfflineChat(offlineMsg)
  local offlineUids = {}
  for k, v in pairs(offlineMsg) do
    if not chat_main.IsChatShieldMsg(v.chat_content) and not chat_main.IsMetroChatShield(v.chat_content) then
      local uid = chat_main.GetIdStr(v.send_uid)
      v.chat_content.sendTime = v.send_time
      local chatMsg = chat_main.SetNewChat(logic_chat_table_pool.Get(), v.sender_name, v.chat_type, v.send_uid, uid, v.zone_id, v.nation, v.chat_content, false)
      chatMsg.msg = chat_main.ReplaceEmoji(chatMsg.msg)
      logic_chat_channel_friend.AddNewChat(chatMsg)
      local securityRemindMsg = chat_main.GetSecurityRemindMsg(chatMsg)
      if securityRemindMsg then
        logic_chat_channel_friend.AddNewChat(securityRemindMsg)
      end
      table.insert(offlineUids, uid)
    end
  end
  if 0 < #offlineUids then
    for k, v in pairs(offlineUids) do
      local refMsg = logic_chat_channel_friend.GetFriendChatData(v)
      if refMsg.messageList then
        refMsg.messageList:Sort(function(a, b)
          return a.send_time < b.send_time
        end)
      end
    end
  end
  logic_chat_channel_friend.InitFriendList()
end
function logic_chat_channel_friend.MarkHistoryMsg(chatMsg)
  local LogicHistorySystem = require("client.slua.logic.lobby_chat.logic_history_chat")
  LogicHistorySystem.MarkOneMsg(chatMsg.uid)
end
function logic_chat_channel_friend.LoadHistoryChat(uid)
  log(bWriteLog and "logic_chat_channel_friend.LoadHistoryChat uid:" .. tostring(uid))
  if uid == nil or uid == "" then
    log(bWriteLog and "LoadHistoryChat invalid param")
    return false
  end
  local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
  if FriendSystem.IsMyFriend(tonumber(uid)) == false then
    log(bWriteLog and "LoadHistoryChat not my friend")
    return false
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and "LoadHistoryChat no profile")
    return false
  end
  local LogicHistorySystem = require("client.slua.logic.lobby_chat.logic_history_chat")
  if LogicHistorySystem.CheckIsLoad(uid) then
    log(bWriteLog and "LoadHistoryChat already load")
    return false
  end
  local friendChat = LogicHistorySystem.LoadFriendChat(uid)
  if not friendChat then
    log(bWriteLog and "LoadHistoryChat no history chat")
    return false
  end
  log(bWriteLog and "LoadHistoryChat real load")
  logic_chat_channel_friend.SetHistoryChatData(uid, friendChat, profile)
  return true
end
function logic_chat_channel_friend.SetHistoryChatData(uid, friendChat, profile)
  local isFirstMsg = true
  local LogicHistorySystem = require("client.slua.logic.lobby_chat.logic_history_chat")
  local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
  local replay_msg_params_list = logic_share_replay.GetChatMsgParamsList()
  local logic_lobby_chat_security = require("client.slua.logic.lobby_chat.logic_lobby_chat_security")
  logic_lobby_chat_security.UpdateKeyHash()
  if logic_chat_channel_friend.CheckHistoryStructParam(friendChat) then
    for k, v in pairs(friendChat.msgList) do
      if LogicHistorySystem.CheckHistoryOneMsgParam(v) then
        local str_sender_gid = 0
        if v.selfMsg then
          str_sender_gid = DataMgr.roleData.uid
        else
          str_sender_gid = uid
        end
        if isFirstMsg then
          isFirstMsg = false
          v.msgSendTime = TimeUtil.FormatTime_HM(v.send_time, true) or ""
          v.msgSendDate = TimeUtil.FormatTime_HM(v.send_time, true) or ""
        end
        local content = logic_chat_channel_friend.GetContentData(uid, profile)
        if v.achievementId then
          if not content.other then
            content.other = {}
          end
          content.other.achievementId = v.achievementId
        end
        if Client.IsShipping() then
          local errorHandler = function(err)
            local errInfo = {
              [1] = v.msg,
              [2] = logic_lobby_chat_security.keyHash,
              [3] = tostring(err)
            }
            LogExceptionAndReport("logic_chat_channel_friend.SetHistoryChatDataNew error: " .. table.concat(errInfo, ", "), 6)
            return err
          end
          local callOk = xpcall(function()
            logic_lobby_chat_security.UnPackMsg(v)
          end, errorHandler)
          if not callOk then
            v.msg = "**"
            log_error("logic_chat_channel_friend.SetHistoryChatData error")
          end
        else
          logic_lobby_chat_security.UnPackMsg(v)
        end
        if v.msgType == chat_macro.targetShareMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.ownerUid = v.share_ownerUid
          content.other.score = v.share_score
          content.other.timeStamp = v.share_timeStamp
        end
        if v.msgType == chat_macro.islandBattleShareMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.ownerUid = v.share_ownerUid
          content.other.score_desc = v.score_desc
          content.other.oppoId = v.oppoId
          content.other.isWin = v.isWin
          content.other.type = v.type
        end
        if v.msgType == chat_macro.passBuyFriendMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.group_id = v.group_id
          content.other.group_count = v.group_count
        end
        if v.msgType == chat_macro.BF_RP_InviteGroupMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.group_id = v.group_id
          content.other.group_count = v.group_count
          content.other.actType = v.actType
          content.other.activityId = v.activityId
        end
        if v.msgType == chat_macro.replayShareMsgType then
          if not content.other then
            content.other = {}
          end
          for _, param in pairs(replay_msg_params_list) do
            content.other[param] = v[param]
          end
        end
        if v.msgType == chat_macro.ChatRoomInviteMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.id = v.room_id
          content.other.member_num = v.room_member_num
          content.other.topic_id = v.topic_id
        end
        if v.msgType == chat_macro.UGCShareMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.mod_id = v.mod_id
          content.other.mod_name = v.mod_name
          content.other.mode_desc = v.mode_desc
          content.other.url = v.url
          content.other.templateId = v.templateId
          content.other.isMyMod = v.isMyMod
        end
        if v.msgType == chat_macro.UGCShareChallengeMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.mod_id = v.mod_id
          content.other.mod_name = v.mod_name
          content.other.mode_desc = v.mode_desc
          content.other.url = v.url
          content.other.templateId = v.templateId
          content.other.isMyMod = v.isMyMod
          content.other.clearanceState = v.clearanceState
          content.other.score = v.score
          content.other.rank = v.rank
          content.other.share_name = v.share_name
          content.other.win = v.win
          content.other.bSelectShareChallenge = v.bSelectShareChallenge
          content.other.leaderboard = v.leaderboard
        end
        if v.msgType == chat_macro.UGCShareChallengeResultMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.rank = v.rank
          content.other.clearanceState = v.clearanceState
          content.other.mod_name = v.mod_name
          content.other.mode_desc = v.mode_desc
          content.other.url = v.url
          content.other.pk_result = v.pk_result
          content.other.score = v.score
          content.other.sharer_uid = v.sharer_uid
          content.other.mod_id = v.mod_id
        end
        if v.msgType == chat_macro.HomePartyInviteMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.start_time = v.start_time
          content.other.end_time = v.end_time
          content.other.party_type = v.party_type
          content.other.name = v.name
          content.other.manor_invite_card = v.manor_invite_card
        end
        if v.msgType == chat_macro.WeddingInviteMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.start_time = v.start_time
          content.other.end_time = v.end_time
          content.other.name = v.name
          content.other.memberLeft = v.memberLeft
          content.other.squad_name = v.squad_name
        end
        if v.msgType == chat_macro.UGCShareCollectionMsgType then
          if not content.other then
            content.other = {}
          end
          content.other.mod_collection_id = v.mod_collection_id
          content.other.name = v.name
          content.other.tag = v.tag
          content.other.desc = v.desc
          content.other.url = v.url
          content.other.isMyMod = v.isMyMod
        end
        if v.msgType == chat_macro.MilestoneShare then
          if not content.other then
            content.other = {}
          end
          content.other.itemID = v.itemID
        end
        if v.msgType == chat_macro.FriendRecruitType and not content.other then
          content.other = {}
        end
        if v.msgType == chat_macro.friendComebackMsgType and v.other then
          if not content.other then
            content.other = {}
          end
          for k1, v1 in pairs(v.other) do
            content.other[k1] = v1
          end
          printf("logic_chat_channel_friend:SetHistoryChatDataNew friendComebackMsg unpack, uid:%s, sendTime:%s, hasOther:%s", tostring(uid), tostring(v.send_time), tostring(content.other ~= nil and next(content.other) ~= nil))
        end
        if v.evaluation then
          content.evaluation = v.evaluation
        end
        if v.last_week_count then
          content.chatMsg = v.chatMsg
          content.last_week_count = v.last_week_count
          content.intimacies = v.intimacies
          content.week_time = v.week_time
        end
        if v.chat_bubble then
          content.chat_bubble = v.chat_bubble
        end
        if v.msgType == chat_macro.ManorChatMsgType and v.manorUid then
          content.manorUid = v.manorUid
        end
        if v.msgType == chat_macro.PandoraInviteMsg or v.msgType == chat_macro.temuInvite or v.msgType == chat_macro.temuTaskRemind or v.msgType == chat_macro.WarmUpGroupInvite or v.msgType == chat_macro.BF_Sub_InviteGroupMsgType or v.msgType == chat_macro.CardCollectionSwapMsgType or v.msgType == chat_macro.GroupBuyFriendsMsgType or v.msgType == chat_macro.BargainFriendsMsgType or v.msgType == chat_macro.BargainCorpsMsgType or v.msgType == chat_macro.BargainChannelsMsgType then
          content.other = v.other
        end
        if v.msgType == chat_macro.SendPicShare then
          content.sharePicUrl = v.sharePicUrl
          content.shareContentType = v.shareContentType
          content.curUId = v.sharePicSenderUid
          content.jumpUrl = v.sendChatJumpUrl
        end
        logic_chat_channel_friend.AddHistoryMsg(uid, str_sender_gid, v, content)
      else
        log(bWriteLog and "[god] can't read msg")
      end
    end
    local refMsg = logic_chat_channel_friend.GetFriendChatData(uid)
    if refMsg then
      refMsg.messageList:Sort(function(a, b)
        return a.send_time < b.send_time
      end)
    end
  end
end
function logic_chat_channel_friend.GetContentData(sender_uid, profile)
  local content
  if tonumber(sender_uid) == tonumber(profile.uid) then
    local alias = profile.alias or {}
    local upass = profile.upass
    local contentdata = {
      url = profile.picUrl,
      level = profile.level,
      avatarBox = profile.cur_avatar_box_id
    }
    if alias then
      contentdata.aliasid = alias.id
      contentdata.aliarank = alias.rank
      contentdata.alias_ext_info = alias.ext_info
      contentdata.aliasnation = alias.nation
      contentdata.alias_rank_id = alias.rank_id
    end
    if upass then
      contentdata.upass = {
        is_buy = upass.is_buy,
        switch_battle_title = upass.switch.battle_title,
        keep_buy = upass.keep_buy,
        cur_value = upass.cur_value
      }
    end
    content = contentdata
  end
  return content
end
function logic_chat_channel_friend.CheckHistoryStructParam(historyData)
  if not historyData or type(historyData) ~= "table" then
    return false
  end
  if not historyData.uid then
    return false
  end
  if not historyData.msgList or type(historyData.msgList) ~= "table" then
    return false
  end
  return true
end
function logic_chat_channel_friend.AddHistoryMsg(str_gid, str_sender_gid, msgData, content)
  local StringUtil = require("common.string_util")
  str_gid = StringUtil.StrTrim(str_gid)
  local thisMsg = {}
  thisMsg.msgChannel = chat_macro.Channel.channelPrivate
  thisMsg.msgType = msgData.msgType
  thisMsg.uid = str_gid
  thisMsg.name = msgData.name
  thisMsg.msg = msgData.msg
  thisMsg.selfMsg = msgData.selfMsg
  thisMsg.voiceMsgId = msgData.voiceMsgId
  thisMsg.voiceMsgTime = msgData.voiceMsgTime
  thisMsg.roomId = ""
  thisMsg.sender_uid = str_sender_gid
  thisMsg.  thisMsg.send_time = msgData.send_time or TimeUtil.OSTime()
  if msgData.msgSendTime and msgData.msgSendTime ~= "" then
    thisMsg.msgSendTime = TimeUtil.FormatTime_HM(msgData.send_time, true)
    thisMsg.msgSendDate = TimeUtil.FormatTime_YMD(msgData.send_time, true)
  end
  if msgData.achievementId ~= nil and type(msgData.achievementId) == "number" then
    thisMsg.msgType = chat_macro.achivementMsgType
  end
  chat_main.STATIC_MESSAGE_COUNTER = chat_main.STATIC_MESSAGE_COUNTER + 1
  thisMsg.level = chat_main.STATIC_MESSAGE_COUNTER
  thisMsg.roleNation = msgData.roleNation
  local refMsg = logic_chat_channel_friend.CheckAndCreateChatMsg(str_gid)
  if refMsg.send_time < thisMsg.send_time then
    refMsg.send_time = thisMsg.send_time
  end
  refMsg.lastMsgSendTime = refMsg.send_time
  logic_chat_channel_friend.AddNewMsgItem(refMsg, thisMsg)
end
function logic_chat_channel_friend.SendMsg(content, msgtype)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(logic_chat_channel_friend.TimerInterval) then
    return
  end
  local logic_housekeeper_dialog_lobby = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_lobby)
  local hkpID = tonumber(logic_chat_channel_friend.CurrentGid)
  if logic_housekeeper_dialog_lobby:IsHouseKeeper(hkpID) then
    local logic_AIChat_Trans = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_AIChat_Trans)
    logic_AIChat_Trans:send_manor_butler_ai_dialogue_req(hkpID, true, content, false)
    return
  end
  if not logic_chat_channel_friend.CanSendMsg(logic_chat_channel_friend.CurrentGid) then
    return
  end
  local msg = logic_chat_channel_friend.GetAndSetNormalMsg(content, msgtype)
  logic_chat_channel_friend.SendChatReq(msg, logic_chat_channel_friend.CurrentGid)
end
function logic_chat_channel_friend.GetAndSetNormalMsg(content, msgtype)
  local channelType = chat_macro.Channel.channelPrivate
  local msg = {}
  msg.  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = msgtype or 0
  return msg
end
function logic_chat_channel_friend.SendMsgByQuickTeam(content, uid)
  local msg = logic_chat_channel_friend.GetAndSetNormalMsg(content)
  msg.isFromQuickTeam = true
  msg.ignoreLen = true
  if not logic_chat_channel_friend.CanSendMsg(uid) then
    return
  end
  logic_chat_channel_friend.SendChatReq(msg, uid)
end
function logic_chat_channel_friend.SendVoiceMsg(voiceId, length, content)
  if nil == voiceId or "" == voiceId then
    return
  end
  if not logic_chat_channel_friend.CanSendMsg(logic_chat_channel_friend.CurrentGid) then
    return
  end
  log(bWriteLog and "god test SendVoiceMsg")
  log_tree("god test SendVoiceMsg", {
    id = voiceId,
    len = length,
    con = content
  })
  local tabContent = {
    voice = voiceId,
    text = content,
    voiceLength = length,
    msgType = chat_macro.VoiceChatMsgType
  }
  logic_chat_channel_friend.SendChatReq(tabContent, logic_chat_channel_friend.CurrentGid)
end
function logic_chat_channel_friend.SendAchivementShare(achievementShareId, finishTime)
  if not logic_chat_channel_friend.CanSendMsg(logic_chat_channel_friend.CurrentGid) then
    return
  end
  local content = LocUtil.GetLocalizeResStr("5027")
  local other = {}
  other.achievementId = achievementShareId
  other.finish_time = finishTime
  local msg = {}
  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.achivementMsgType
  msg.  logic_chat_channel_friend.SendChatReq(msg, logic_chat_channel_friend.CurrentGid)
end
function logic_chat_channel_friend.SendChatReq(msg, uid)
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  if logic_chat_stranger.IsStranger(uid) then
    local logic_chat_channel_island = require("client.slua.logic.lobby_chat.logic_chat_channel_social_island_chat")
    if logic_chat_channel_island.CheckInIsland(uid) then
      msg.is_stranger = true
    else
      ShowNotice(LocUtil.GetLocalizeResStr(9829))
      return
    end
  else
    local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
    local isFriend = FriendSystem.IsMyFriend(tonumber(uid))
    if not isFriend then
      ShowNotice(LocUtil.GetLocalizeResStr(106020))
      return
    end
  end
  local msgId = chat_main.CacheMsg(msg)
  ChatHandler.send_chat_req(uid, chat_macro.Channel.channelPrivate, msgId, msg)
end
function logic_chat_channel_friend.CanSendMsg(uid)
  if uid == 0 or uid == "" then
    ShowNotice(LocUtil.GetLocalizeResStr(106019))
    return false
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile and profile.level < 5 and profile.account_type == 5 then
    ShowNotice(LocUtil.LocalizeResFormat(11630, 5))
  end
  local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
  if modeSystem.IsSocialIslandMode() then
    return true
  end
  local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
  local isFriend = FriendSystem.IsMyFriend(tonumber(uid))
  if isFriend then
    return true
  else
    ShowNotice(LocUtil.GetLocalizeResStr(106020))
    return false
  end
end
function logic_chat_channel_friend.SendIslandTargetShare(toUid, ownerUid, score, timeStamp, timeUsed)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local other = {}
  other.  other.  other.  other.time = timeUsed
  local msg = {}
  msg.text = "0"
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.targetShareMsgType
  msg.quickMsg = false
  msg.  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendEvaluationShare(toUid, score, labels, topicId)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local evaluation = {score = score, label = labels}
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(21233)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.evaluationShareMsgType
  msg.quickMsg = false
  msg.  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendWonderfulReplayShare(toUid, otherInfo, topicId)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(24668)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.replayShareMsgType
  msg.quickMsg = false
  msg.other = otherInfo
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendPopularGiftPKShare(toUid, topicId)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.popularGiftPKMsgType,
    quickMsg = false
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendTeamPKReqSupportShare(toUid, topicId)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.teamPKReqSupportMsgType,
    quickMsg = false
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendHomePKReqSupportShare(toUid, topicId)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.homePKReqSupportMsgType,
    quickMsg = false
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendHomePKStyleSupportShare(toUid, styleType)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.homePKStyleSupportMsgType,
    quickMsg = false,
    other = {styleType = styleType}
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendHomeJointInviteMsg(toUid, topicId)
  log(bWriteLog and "[DeanJYT] logic_chat_channel_friend.SendHomeJointInviteMsg toUid = " .. tostring(toUid))
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.homeJointInviteMsgType,
    quickMsg = false
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendHomeJointTerminateMsg(toUid, topicId)
  log(bWriteLog and "[Dongkaizha] logic_chat_channel_friend.SendHomeJointTerminateMsg toUid = " .. tostring(toUid))
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.homeJointTerminateMsgType,
    quickMsg = false
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendSeasonLookbackShare(toUid)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(512139)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.seasonLookbackMsgType
  msg.quickMsg = false
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  local max_segment, time = logic_season_lookback:GetSeasonMaxSegmentAndTime()
  local seasonID = logic_season_lookback:GetLookBackSeasonId()
  msg.other = {season_id = seasonID, season_segment = max_segment}
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendManorShare(toUid, manorUid)
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(64795)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.ManorChatMsgType
  msg.quickMsg = false
  msg.  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendNotifyFriendComeBack(uid)
  local content = LocUtil.GetLocalizeResStr("12405")
  local msg = {}
  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.friendComebackMsgType
  msg.ignoreLen = true
  if DataMgr.roleData.back_user_data then
    msg.other = DataMgr.roleData.back_user_data.frd_notify_items
  end
  logic_chat_channel_friend.SendChatReq(msg, uid)
end
function logic_chat_channel_friend.AutoReplyComeBackMsg(uid)
  local chatData = logic_chat_channel_friend.GetFriendChatData(uid)
  if not chatData then
    return
  end
  local messageList = chatData.messageList
  if not messageList then
    return
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  if not logic_return_activity:CheckAutoReplyMsg(messageList) then
    return
  end
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local msg = {
    text = LocUtil.GetLocalizeResStr(86265),
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.chatNormalMsgType,
    channelType = chat_macro.Channel.channelPrivate
  }
  local msgId = chat_main.CacheMsg(msg)
  ChatHandler.send_chat_req(uid, chat_macro.Channel.channelPrivate, msgId, msg)
end
function logic_chat_channel_friend.SendNotifyFriendShareCard(uid)
  local content = LocUtil.GetLocalizeResStr(86264)
  local msg = {}
  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.friendComebackMsgType
  msg.ignoreLen = true
  msg.other = {
    [2195002] = 1
  }
  logic_chat_channel_friend.SendChatReq(msg, uid)
end
function logic_chat_channel_friend.SendChatRoomInvite(roomParam, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendChatRoomInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    log(bWriteLog and "logic_chat_channel_friend.SendChatRoomInvite cannot send")
    return
  end
  local msg = {}
  msg.text = "0"
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.ChatRoomInviteMsgType
  msg.quickMsg = false
  msg.other = roomParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareSuccReq(ShareSceneType.ChatRoomShare, 0, 0, 0)
end
function logic_chat_channel_friend.SendUGCShareInvite(ugcParam, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendUGCShareInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  if ugcParam.bSelectShareChallenge then
    msg.msgType = chat_macro.UGCShareChallengeMsgType
  else
    msg.msgType = chat_macro.UGCShareMsgType
  end
  msg.quickMsg = false
  msg.other = ugcParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendUGCRoomShareInvite(ugcParam, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendUGCRoomShareInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.UGCRoomShareMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendUGCShareCollectionList(ugcParam, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendUGCShareInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.UGCShareCollectionMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendMilestoneShare(nItemID, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendMilestoneShare wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.MilestoneShare
  msg.quickMsg = false
  msg.other = {itemID = nItemID}
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendHomePartyShareInvite(homePartyParam, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(68158)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.HomePartyInviteMsgType
  msg.quickMsg = false
  msg.other = homePartyParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendWeddingShareInvite(homePartyParam, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  local msg = {}
  msg.text = LocUtil.LocalizeResFormat(8075903)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.WeddingInviteMsgType
  msg.quickMsg = false
  msg.other = homePartyParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendWebgameInvite(ludoParam, extraParam)
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendWebgameInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    log(bWriteLog and "logic_chat_channel_friend.SendWebgameInvite cannot send")
    return
  end
  local msg = {}
  local eGameType = ludoParam.eGameType
  local LudoConst = require("client.slua.logic.ludo.LudoConst")
  local desc = LudoConst.WebgameInviteTitleAndDesc[eGameType].desc
  msg.text = desc
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.LudoInviteMsgType
  msg.quickMsg = false
  msg.other = ludoParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendMainCityWebgameInvite(webgameParam, extraParam)
  log(bWriteLog and "logic_chat_channel_friend.SendMainCityWebgameInvite")
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendMainCityWebgameInvite wrong param")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    log(bWriteLog and "logic_chat_channel_friend.SendMainCityWebgameInvite cannot send")
    return
  end
  local msg = {}
  local eGameType = webgameParam.eGameType
  local cfg = CDataTable.GetTableData("MainCityH5PlatformCfg", eGameType)
  msg.text = LocUtil.GetLocalizeResStr(cfg.ShareDesc)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.MainCityShareWebGameMsgType
  msg.quickMsg = false
  msg.other = webgameParam
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendMainCitySeesawInvite(seesawParam, extraParam)
  log(bWriteLog and "logic_chat_channel_friend.SendMainCitySeesawInvite")
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendMainCitySeesawInvite invalid param, missing toUid")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    log(bWriteLog and "logic_chat_channel_friend.SendMainCitySeesawInvite can't send msg to " .. tostring(toUid))
    return
  end
  local msg = {
    text = LocUtil.GetLocalizeResStr(73143),
    topic = extraParam.topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.MainCitySeesawInviteType,
    quickMsg = false,
    other = seesawParam
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendMainCityShare(maincityParam, extraParam)
  log(bWriteLog and "logic_chat_channel_friend.SendMainCityShare")
  if not extraParam or not extraParam.toUid then
    log(bWriteLog and "logic_chat_channel_friend.SendMainCityShare invalid param, missing toUid")
    return
  end
  local toUid = extraParam.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    log(bWriteLog and "logic_chat_channel_friend.SendMainCityShare can't send msg to " .. tostring(toUid))
    return
  end
  local msg = {
    text = LocUtil.GetLocalizeResStr(46880011),
    topic = extraParam.topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.MainCityShareChatMsgType,
    quickMsg = false,
    other = maincityParam
  }
  logic_chat_channel_friend.SendChatReq(msg, toUid)
end
function logic_chat_channel_friend.SendPicShare(tSendChatData)
  local toUid = tSendChatData.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  logic_chat_channel_friend.SendChatReq(tSendChatData, toUid)
end
function logic_chat_channel_friend.SendBFSubGroupInvite(tSendChatData)
  local toUid = tSendChatData.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  logic_chat_channel_friend.SendChatReq(tSendChatData, toUid)
end
function logic_chat_channel_friend.SendBFRPGroupInvite(tSendChatData)
  local toUid = tSendChatData.toUid
  if not logic_chat_channel_friend.CanSendMsg(toUid) then
    return
  end
  logic_chat_channel_friend.SendChatReq(tSendChatData, toUid)
end
function logic_chat_channel_friend.GetFriendBgID(uid)
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  local interact_info = logic_interaction:GetInteractInfo(uid)
  local backendId = 1
  if interact_info and interact_info.chat_background_id then
    backendId = interact_info.chat_background_id
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.FriendChatBgRecord) or {}
  local record = cfg and cfg[DataMgr.roleData.uid] and cfg[DataMgr.roleData.uid][uid]
  local id = record or backendId
  log(bWriteLog and "logic_chat_channel_friend.GetFriendBgID  uid = " .. tostring(uid) .. " id = " .. id)
  return id
end
function logic_chat_channel_friend.DeleteFriendBgID(uid)
  logic_chat_channel_friend.SetFriendBgIDLocal(uid, nil)
end
function logic_chat_channel_friend.SetFriendBgIDLocal(uid, id)
  log(bWriteLog and "logic_chat_channel_friend.SetFriendBgIDLocal uid" .. tostring(uid) .. " id " .. tostring(id))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.FriendChatBgRecord) or {}
  if not next(cfg) or not cfg[DataMgr.roleData.uid] then
    cfg[DataMgr.roleData.uid] = {}
  end
  cfg[DataMgr.roleData.uid][uid] = id
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.FriendChatBgRecord)
end
function logic_chat_channel_friend.SetFriendBgID(uid, seasonInfo)
  log(bWriteLog and "logic_chat_channel_friend.SetFriendBgID uid" .. tostring(uid))
  log_tree("logic_chat_channel_friend.SetFriendBgID seasonInfo", seasonInfo)
  local crystalId = seasonInfo and seasonInfo.crystalId or nil
  local type = 1
  ChatHandler.send_set_frd_chat_background_req(uid, crystalId, type)
end
return logic_chat_channel_friend