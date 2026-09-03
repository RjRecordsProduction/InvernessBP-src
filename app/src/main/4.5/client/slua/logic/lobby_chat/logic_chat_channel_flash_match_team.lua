local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
local super_list = require("common.super_list")
local ChatHandler = require("client.network.Protocol.ChatHandler")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local TimeUtil = require("client.common.time_util")
local logic_chat_channel_flash_match_team = {}
function logic_chat_channel_flash_match_team.Init()
  logic_chat_channel_flash_match_team.TimerInterval = {1, 0}
  logic_chat_channel_flash_match_team.TeamList = {}
  logic_chat_channel_flash_match_team.CurrentTeamId = 0
  logic_chat_channel_flash_match_team.FlashTeamChatList = {}
  logic_chat_channel_flash_match_team.MAX_FLASH_MATCH_TEAM_MESSAGE_CACHE_NUM = 30
  logic_chat_channel_flash_match_team.RegisterEvent()
  logic_chat_channel_flash_match_team.TeamChatHistoryList = {}
  logic_chat_channel_flash_match_team.PinnedTeamMap = {}
  logic_chat_channel_flash_match_team.MuteTeamMap = {}
end
function logic_chat_channel_flash_match_team.RegisterEvent()
  EventSystem:registEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG, logic_chat_channel_flash_match_team.OnInitFlashMatchTeamInfo)
  EventSystem:registEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_CREATE, logic_chat_channel_flash_match_team.OnInitFlashMatchTeamInfo)
end
function logic_chat_channel_flash_match_team.UnRegisterEvent()
  EventSystem:unregistEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG, logic_chat_channel_flash_match_team.OnInitFlashMatchTeamInfo)
  EventSystem:unregistEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_CREATE, logic_chat_channel_flash_match_team.OnInitFlashMatchTeamInfo)
end
function logic_chat_channel_flash_match_team.OnInitFlashMatchTeamInfo()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_chat_channel_flash_match_team.TeamList = logic_flash_match_team:getMyTeams()
  if next(logic_chat_channel_flash_match_team.TeamList) and logic_chat_channel_flash_match_team.CurrentTeamId == 0 then
    local teamList = logic_chat_channel_flash_match_team.GetSortedTeamIdList()
    logic_chat_channel_flash_match_team.CurrentTeamId = teamList[1] or 0
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_MATCH_TEAM_REFRESH_CHAT_CHANNEL_UI)
  logic_chat_channel_flash_match_team.CleanupStaleTeamData()
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_MATCH_TEAM_REFRESH_CHANNEL_UI)
end
function logic_chat_channel_flash_match_team.SetCurSelectTeamId(teamId)
  logic_chat_channel_flash_match_team.CurrentTeamId = teamId
end
function logic_chat_channel_flash_match_team:GetCurrentTeamId()
  return logic_chat_channel_flash_match_team.CurrentTeamId
end
function logic_chat_channel_flash_match_team:GetTeamList()
  return logic_chat_channel_flash_match_team.TeamList or {}
end
function logic_chat_channel_flash_match_team.GetSortedTeamIdList()
  local teamList = logic_chat_channel_flash_match_team.TeamList
  if not teamList or not next(teamList) then
    return {}
  end
  local data = {}
  for _, teamInfo in pairs(teamList) do
    table.insert(data, teamInfo.squad_id)
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local sortKeys = logic_flash_match_team:BuildDefaultSortKeys2(data)
  logic_flash_match_team:SortByDefaultKeys2(data, sortKeys)
  return data
end
function logic_chat_channel_flash_match_team.CheckTeamIsExist()
  if not logic_chat_channel_flash_match_team.TeamList or not next(logic_chat_channel_flash_match_team.TeamList) then
    return false
  end
  if next(logic_chat_channel_flash_match_team.TeamList) then
    for _, teamInfo in pairs(logic_chat_channel_flash_match_team.TeamList) do
      if not teamInfo.squad_id or teamInfo.squad_id == 0 then
        return false
      end
    end
  end
  return true
end
function logic_chat_channel_flash_match_team.GetTeamInfoByTeamId(teamId)
  log(bWriteLog and "logic_chat_channel_flash_match_team.GetTeamInfoByTeamId - teamId: " .. tostring(teamId))
  if logic_chat_channel_flash_match_team.TeamList and next(logic_chat_channel_flash_match_team.TeamList) then
    for _, teamInfo in pairs(logic_chat_channel_flash_match_team.TeamList) do
      if teamInfo.squad_id == teamId then
        return teamInfo
      end
    end
  end
  return {}
end
function logic_chat_channel_flash_match_team.ClearData()
  logic_chat_channel_flash_match_team.TeamList = nil
  logic_chat_channel_flash_match_team.CurrentTeamId = nil
  logic_chat_channel_flash_match_team.TimerInterval = nil
  logic_chat_channel_flash_match_team.TeamChatHistoryList = nil
  logic_chat_channel_flash_match_team.PinnedTeamMap = nil
  logic_chat_channel_flash_match_team.MuteTeamMap = nil
  logic_chat_channel_flash_match_team.UnRegisterEvent()
end
function logic_chat_channel_flash_match_team.SendMsg(content, msgtype)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(logic_chat_channel_flash_match_team.TimerInterval) then
    return
  end
  if not logic_chat_channel_flash_match_team.CanSendMsg(logic_chat_channel_flash_match_team.CurrentTeamId) then
    return
  end
  local msg = logic_chat_channel_flash_match_team.GetAndSetNormalMsg(content, msgtype)
  logic_chat_channel_flash_match_team.SendChatReq(msg, tonumber(DataMgr.roleData.uid))
end
function logic_chat_channel_flash_match_team.CanSendMsg(teamId)
  if teamId == 0 or teamId == "" then
    ShowNotice(8075920)
    return false
  end
  return true
end
function logic_chat_channel_flash_match_team.GetAndSetNormalMsg(content, msgtype)
  local channelType = chat_macro.Channel.channelFlashMatchTeam
  local msg = {}
  msg.  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = msgtype or 0
  msg.squad_id = logic_chat_channel_flash_match_team.CurrentTeamId
  return msg
end
function logic_chat_channel_flash_match_team.SendChatReq(msg, uid)
  local msgId = chat_main.CacheMsg(msg)
  ChatHandler.send_chat_req(uid, chat_macro.Channel.channelFlashMatchTeam, msgId, msg)
end
function logic_chat_channel_flash_match_team.SendVoiceMsg(voiceId, length, content)
  if nil == voiceId or "" == voiceId then
    return
  end
  if not logic_chat_channel_flash_match_team.CanSendMsg(logic_chat_channel_flash_match_team.CurrentTeamId) then
    return
  end
  log(bWriteLog and "logic_chat_channel_flash_match_team.SendVoiceMsg SendVoiceMsg")
  log_tree("logic_chat_channel_flash_match_team.SendVoiceMsg SendVoiceMsg", {
    id = voiceId,
    len = length,
    con = content
  })
  local tabContent = {
    voice = voiceId,
    text = content,
    voiceLength = length,
    msgType = chat_macro.VoiceChatMsgType,
    squad_id = logic_chat_channel_flash_match_team.CurrentTeamId
  }
  logic_chat_channel_flash_match_team.SendChatReq(tabContent, tonumber(DataMgr.roleData.uid))
end
function logic_chat_channel_flash_match_team.GetOfflineFlashMatchTeamChatMsgReq()
  if not logic_chat_channel_flash_match_team.CurrentTeamId or logic_chat_channel_flash_match_team.CurrentTeamId == 0 then
    log(bWriteLog and "logic_chat_channel_flash_match_team.GetOfflineFlashMatchTeamChatMsgReq - teamId is nil")
    return
  end
  if logic_chat_channel_flash_match_team.TeamChatHistoryList[logic_chat_channel_flash_match_team.CurrentTeamId] then
    log(bWriteLog and "logic_chat_channel_flash_match_team.GetOfflineFlashMatchTeamChatMsgReq teamId has history")
    return
  end
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_get_flash_squad_chat_history_req(logic_chat_channel_flash_match_team.CurrentTeamId)
  logic_chat_channel_flash_match_team.TeamChatHistoryList[logic_chat_channel_flash_match_team.CurrentTeamId] = true
end
function logic_chat_channel_flash_match_team.on_get_flash_squad_chat_history_rsp(chat_list)
  if chat_list == nil then
    return
  end
  logic_chat_channel_flash_match_team.CheckHistoryChatList = {}
  local logic_profile_security = require("client.slua.logic.profile.logic_profile_security")
  logic_profile_security.ProcOfflineChat(chat_list)
  for k, v in pairs(chat_list) do
    if not chat_main.IsChatShieldMsg(v.data) and not chat_main.IsMetroChatShield(v.data) and logic_chat_channel_flash_match_team.CheckHistoryChat(v.send_uid, v.data) then
      local uid = chat_main.GetIdStr(v.send_uid)
      local chatMsg = chat_main.SetNewChat(logic_chat_table_pool.Get(), v.sender_name, v.chat_type, v.send_uid, uid, v.zone_id, v.nation, v.data, uid == DataMgr.roleData.uid)
      chatMsg.msg = chat_main.ReplaceEmoji(chatMsg.msg)
      logic_chat_channel_flash_match_team.AddNewChat(chatMsg)
      local securityRemindMsg = chat_main.GetSecurityRemindMsg(chatMsg)
      if securityRemindMsg then
        logic_chat_channel_flash_match_team.AddNewChat(securityRemindMsg)
      end
    end
  end
end
function logic_chat_channel_flash_match_team.CheckHistoryChat(sendUid, data)
  if not data then
    return false
  end
  if not logic_chat_channel_flash_match_team.CheckHistoryChatList then
    logic_chat_channel_flash_match_team.CheckHistoryChatList = {}
  end
  local sendTime = data.sendTime
  if not sendTime or not sendUid then
    return true
  end
  local key = tostring(sendUid) .. "_" .. tostring(sendTime)
  if logic_chat_channel_flash_match_team.CheckHistoryChatList[key] then
    return false
  end
  logic_chat_channel_flash_match_team.CheckHistoryChatList[key] = true
  return true
end
function logic_chat_channel_flash_match_team.AddNewChat(chatMsg)
  local refMsg = logic_chat_channel_flash_match_team.CheckAndCreateChatMsg(chatMsg.squad_id)
  logic_chat_channel_flash_match_team.SetMsgTime(refMsg, chatMsg)
  logic_chat_channel_flash_match_team.SetMsgNewMessageCount(refMsg, chatMsg)
  logic_chat_channel_flash_match_team.AddNewMsgItem(refMsg, chatMsg)
  logic_chat_channel_flash_match_team.update_flash_team_unread(chatMsg, refMsg.newMessageCount)
end
function logic_chat_channel_flash_match_team.CheckAndCreateChatMsg(squad_id)
  log(bWriteLog and string.format("logic_chat_channel_flash_match_team.CheckAndCreateChatMsg %s", squad_id))
  if not squad_id then
    log(bWriteLog and "logic_chat_channel_flash_match_team.CheckAndCreateChatMsg squad_id is nil")
    return false
  end
  local refMsg = logic_chat_channel_flash_match_team.GetFlashTeamChatData(squad_id)
  if nil == refMsg then
    refMsg = {}
    refMsg.gid = squad_id
    refMsg.newMessageCount = 0
    refMsg.lastMsgSendTime = 0
    refMsg.recordLastMsgSendTime = 0
    refMsg.send_time = 0
    refMsg.messageList = super_list.Create()
    logic_chat_channel_flash_match_team.AddFlashTeamChatData(squad_id, refMsg)
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
  log_tree("logic_chat_channel_flash_match_team.CheckAndCreateChatMsg refMsg.messageList ", refMsg.messageList)
  return refMsg
end
function logic_chat_channel_flash_match_team.AddFlashTeamChatData(squad_id, chatMsg)
  logic_chat_channel_flash_match_team.FlashTeamChatList[squad_id] = chatMsg
end
function logic_chat_channel_flash_match_team.GetFlashTeamChatData(squad_id)
  return logic_chat_channel_flash_match_team.FlashTeamChatList[squad_id]
end
function logic_chat_channel_flash_match_team.AddNewMsgItem(refMsg, chatMsg)
  if #refMsg.messageList >= logic_chat_channel_flash_match_team.MAX_FLASH_MATCH_TEAM_MESSAGE_CACHE_NUM then
    logic_chat_table_pool.Recycle(refMsg.messageList[1])
    refMsg.messageList:RemoveItem(1)
  end
  refMsg.messageList:AppendItem(chatMsg)
end
function logic_chat_channel_flash_match_team.SetMsgTime(refMsg, chatMsg)
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
function logic_chat_channel_flash_match_team.SetMsgNewMessageCount(refMsg, chatMsg)
  if not refMsg then
    return
  end
  if chatMsg.squad_id == logic_chat_channel_flash_match_team.CurrentTeamId and chat_main.currentChannel == chat_macro.Channel.channelFlashMatchTeam and UIManager.IsUIShow(UIManager.UI_Config.ui_chat_main) then
    refMsg.newMessageCount = 0
  elseif chatMsg and chatMsg.sender_uid == tostring(DataMgr.roleData.uid) then
    log(bWriteLog and "logic_chat_channel_flash_match_team.SetMsgNewMessageCount isMyGroupBuyMsg, do nothing")
  else
    refMsg.newMessageCount = refMsg.newMessageCount + 1
  end
end
function logic_chat_channel_flash_match_team.update_flash_team_unread(chatMsg, message_count)
  local squad_id = chatMsg.squad_id
  if chatMsg.selfMsg then
    return
  end
  logic_chat_channel_flash_match_team.RefreshTotalUnread()
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_MATCH_TEAM_REFRESH_CHANNEL_UI)
end
function logic_chat_channel_flash_match_team.RefreshTotalUnread()
  logic_chat_channel_flash_match_team.RefreshChannelTabUnread()
  logic_chat_channel_flash_match_team.RefreshEntranceUnread()
end
function logic_chat_channel_flash_match_team.RefreshChannelTabUnread()
  local unreadCount = 0
  for squad_id, v in pairs(logic_chat_channel_flash_match_team.FlashTeamChatList) do
    if not logic_chat_channel_flash_match_team.IsTeamMuted(squad_id) then
      unreadCount = unreadCount + (v.newMessageCount or 0)
    end
  end
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelFlashMatchTeam, 0 < unreadCount)
end
function logic_chat_channel_flash_match_team.RefreshEntranceUnread()
  local unreadCount = 0
  for _, v in pairs(logic_chat_channel_flash_match_team.FlashTeamChatList) do
    if not logic_chat_channel_flash_match_team.IsTeamMuted(v.gid) then
      unreadCount = unreadCount + (v.newMessageCount or 0)
    end
  end
  local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
  logic_chat_entrance:SetUnreadFlashTeamChatMsgCount(unreadCount)
end
function logic_chat_channel_flash_match_team.ClearTeamUnread(squad_id)
  local refMsg = logic_chat_channel_flash_match_team.GetFlashTeamChatData(squad_id)
  if refMsg then
    refMsg.newMessageCount = 0
  end
end
function logic_chat_channel_flash_match_team.GetFlashTeamUnreadMsgCount(squad_id)
  local refMsg = logic_chat_channel_flash_match_team.GetFlashTeamChatData(squad_id)
  if refMsg then
    return refMsg.newMessageCount or 0
  end
  return 0
end
function logic_chat_channel_flash_match_team.GetTotalUnreadCount()
  local unreadCount = 0
  for _, v in pairs(logic_chat_channel_flash_match_team.FlashTeamChatList) do
    if not logic_chat_channel_flash_match_team.IsTeamMuted(v.gid) then
      unreadCount = unreadCount + (v.newMessageCount or 0)
    end
  end
  return unreadCount
end
function logic_chat_channel_flash_match_team.GetRefMsg(squad_id)
  local refMsg = logic_chat_channel_flash_match_team.CheckAndCreateChatMsg(squad_id)
  return refMsg
end
function logic_chat_channel_flash_match_team.SendWeddingShareInvite(homePartyParam, extraParam)
  if not extraParam or not extraParam.toSquadId then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite wrong param")
    return
  end
  local toSquadId = extraParam.toSquadId
  if not logic_chat_channel_flash_match_team.CanSendMsg(toSquadId) then
    return
  end
  local msg = {}
  msg.text = LocUtil.LocalizeResFormat(8075903)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.WeddingInviteMsgType
  msg.quickMsg = false
  msg.other = homePartyParam
  msg.squad_id = toSquadId
  logic_chat_channel_flash_match_team.SendChatReq(msg, tonumber(DataMgr.roleData.uid))
end
function logic_chat_channel_flash_match_team.CleanupStaleTeamData()
  local teamList = logic_chat_channel_flash_match_team.TeamList
  if not teamList then
    return
  end
  local validTeamIdSet = {}
  for _, teamInfo in pairs(teamList) do
    if teamInfo.squad_id and teamInfo.squad_id ~= 0 then
      validTeamIdSet[teamInfo.squad_id] = true
    end
  end
  local bMuteChanged = false
  logic_chat_channel_flash_match_team.LoadMuteData()
  if logic_chat_channel_flash_match_team.MuteTeamMap then
    for squadIdStr, _ in pairs(logic_chat_channel_flash_match_team.MuteTeamMap) do
      if not validTeamIdSet[tonumber(squadIdStr)] then
        logic_chat_channel_flash_match_team.MuteTeamMap[squadIdStr] = nil
        bMuteChanged = true
        log(bWriteLog and "logic_chat_channel_flash_match_team.CleanupStaleTeamData - removed stale muted squadId: " .. tostring(squadIdStr))
      end
    end
  end
  if bMuteChanged then
    logic_chat_channel_flash_match_team.SaveMuteData()
    log(bWriteLog and "logic_chat_channel_flash_match_team.CleanupStaleTeamData - stale mute data cleaned and saved")
  end
end
function logic_chat_channel_flash_match_team.LoadMuteData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local muteData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFlashTeamChatMute)
  if muteData and next(muteData) then
    for squadId, _ in pairs(muteData) do
      logic_chat_channel_flash_match_team.MuteTeamMap[squadId] = true
    end
  else
    logic_chat_channel_flash_match_team.MuteTeamMap = {}
  end
  log_tree("logic_chat_channel_flash_match_team.LoadMuteData = ", logic_chat_channel_flash_match_team.MuteTeamMap)
  log(bWriteLog and "logic_chat_channel_flash_match_team.LoadMuteData - loaded")
end
function logic_chat_channel_flash_match_team.SaveMuteData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local muteData = {}
  for squadId, _ in pairs(logic_chat_channel_flash_match_team.MuteTeamMap) do
    muteData[squadId] = true
  end
  PlayerPrefsSystem.SaveTableToFile_N(muteData, PlayerPrefsSystem.ePlayerPrefsType.eFlashTeamChatMute)
  log(bWriteLog and "logic_chat_channel_flash_match_team.SaveMuteData - saved")
end
function logic_chat_channel_flash_match_team.SetTeamPinned(squadId)
  if not squadId or squadId == 0 then
    return
  end
  if not logic_chat_channel_flash_match_team.PinnedTeamMap then
    logic_chat_channel_flash_match_team.PinnedTeamMap = {}
  end
  logic_chat_channel_flash_match_team.PinnedTeamMap[squadId] = true
  log(bWriteLog and "logic_chat_channel_flash_match_team.SetTeamPinned - squadId: " .. tostring(squadId))
end
function logic_chat_channel_flash_match_team.RemoveTeamPinned(squadId)
  if not squadId or squadId == 0 then
    return
  end
  if logic_chat_channel_flash_match_team.PinnedTeamMap then
    logic_chat_channel_flash_match_team.PinnedTeamMap[squadId] = nil
  end
  log(bWriteLog and "logic_chat_channel_flash_match_team.RemoveTeamPinned - squadId: " .. tostring(squadId))
end
function logic_chat_channel_flash_match_team.ReqTeamPinnedSetting(squadId, isPinned)
  if not squadId or squadId == 0 then
    return
  end
  local list = {}
  for squad_id, _ in pairs(logic_chat_channel_flash_match_team.PinnedTeamMap) do
    table.insert(list, squad_id)
  end
  if isPinned then
    table.insert(list, squadId)
  else
    for i = #list, 1, -1 do
      if list[i] == squadId then
        table.remove(list, i)
        break
      end
    end
  end
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_pin_flash_squad_req(list)
end
function logic_chat_channel_flash_match_team.IsTeamPinned(squadId)
  if not squadId or not logic_chat_channel_flash_match_team.PinnedTeamMap then
    return false
  end
  return logic_chat_channel_flash_match_team.PinnedTeamMap[squadId] == true
end
function logic_chat_channel_flash_match_team.SetTeamMute(squadId)
  if not squadId or squadId == 0 then
    return
  end
  if not logic_chat_channel_flash_match_team.MuteTeamMap then
    logic_chat_channel_flash_match_team.MuteTeamMap = {}
  end
  logic_chat_channel_flash_match_team.MuteTeamMap[tostring(squadId)] = true
  logic_chat_channel_flash_match_team.SaveMuteData()
  log(bWriteLog and "logic_chat_channel_flash_match_team.SetTeamMute - squadId: " .. tostring(squadId))
end
function logic_chat_channel_flash_match_team.RemoveTeamMute(squadId)
  if not squadId or squadId == 0 then
    return
  end
  if logic_chat_channel_flash_match_team.MuteTeamMap then
    logic_chat_channel_flash_match_team.MuteTeamMap[tostring(squadId)] = nil
    logic_chat_channel_flash_match_team.SaveMuteData()
  end
  log(bWriteLog and "logic_chat_channel_flash_match_team.RemoveTeamMute - squadId: " .. tostring(squadId))
end
function logic_chat_channel_flash_match_team.IsTeamMuted(squadId)
  if not squadId or not logic_chat_channel_flash_match_team.MuteTeamMap then
    return false
  end
  return logic_chat_channel_flash_match_team.MuteTeamMap[tostring(squadId)] == true
end
function logic_chat_channel_flash_match_team.GetMessageList(chatMsg)
  local squadId = chatMsg and chatMsg.squad_id or nil
  if not squadId then
    log(bWriteLog and "logic_chat_channel_flash_match_team.GetMessageList - squadId is nil")
    return nil
  end
  local refMsg = logic_chat_channel_flash_match_team.GetFlashTeamChatData(chatMsg.squad_id)
  if refMsg then
    return refMsg.messageList
  end
  return nil
end
return logic_chat_channel_flash_match_team