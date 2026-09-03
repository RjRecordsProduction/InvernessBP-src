local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local super_list = require("common.super_list")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local chatMessageList = super_list.Create()
local MAX_MESSAGE_NUM = 200
local MAX_ROOM_COUNT = 200
local logic_chat_channel_chat_room = {
  chatRoomOpenLv = 25,
  maxPlayerCntPerChannel = 30,
  channelMap = {},
  myChannel = nil,
  chatRoomQueryPassword = false,
  ChatRoomIndex = -1,
  oldIndex = -1,
  isEndScroll = true,
  isBlockByNet = false,
  totalRoomCount = 0,
  isPullotherLanguage = false,
  AllLanguageMap = {},
  PullLanguageMap = {},
  pullLanguageId = 0,
  pullLanguageIndex = 0
}
logic_chat_channel_chat_room.ScrollPullStage = {none = 0, shouldRequest = 1}
local UpdateRedpoint = function(show)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(chat_macro.Channel.channelChatRoom, show)
end
function logic_chat_channel_chat_room.Init()
  logic_chat_channel_chat_room.RegisterEvent()
  logic_chat_channel_chat_room.ClearRecommendIndex()
end
function logic_chat_channel_chat_room.ClearData()
  log(bWriteLog and "logic_chat_channel_chat_room.ClearData")
  logic_chat_channel_chat_room.myChannel = nil
  logic_chat_channel_chat_room.channelMap = {}
  logic_chat_channel_chat_room.PullLanguageMap = {}
  logic_chat_channel_chat_room.totalRoomCount = 0
  logic_chat_channel_chat_room.pullLanguageId = 0
  logic_chat_channel_chat_room.pullLanguageIndex = 0
  logic_chat_channel_chat_room.ChatRoomIndex = -1
  chatMessageList:ClearData()
  logic_chat_channel_chat_room.UnRegisterEvent()
  local LogicJoinMicrophone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicJoinMicrophone)
  LogicJoinMicrophone:CleanData()
  local LogicChatRoomTopic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicChatRoomTopic)
  LogicChatRoomTopic:CleanData()
  local LogicChatRoomMember = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicChatRoomMember)
  LogicChatRoomMember:CleanData()
end
function logic_chat_channel_chat_room.OnGameStateChange()
  log(bWriteLog and "logic_chat_channel_chat_room.OnGameStateChange")
  if logic_chat_channel_chat_room.myChannel == nil then
    printf("logic_chat_channel_chat_room.OnGameStateChange: no chat room. return")
    return
  end
  xpcall(function()
    logic_chat_channel_chat_room.QuitVoiceRoom()
  end, require("common.utility").ErrorMessageHandler)
end
function logic_chat_channel_chat_room.RegisterEvent()
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, logic_chat_channel_chat_room.InitChatRoomRedPoint)
end
function logic_chat_channel_chat_room.UnRegisterEvent()
  EventSystem:unregistEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, logic_chat_channel_chat_room.InitChatRoomRedPoint)
end
function logic_chat_channel_chat_room.AddNewChat(chatMsg)
  if #chatMessageList >= MAX_MESSAGE_NUM then
    logic_chat_table_pool.Recycle(chatMessageList[1])
    chatMessageList:RemoveItem(1)
  end
  if not chatMsg.selfMsg and chatMsg.msgType == chat_macro.teamRecruitMsgType then
    logic_chat_channel_chat_room.SetTeamRecruitNewChat(chatMsg, chatMsg.content)
  end
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if logic_chat_main.currentChannel ~= chat_macro.Channel.channelChatRoom then
    UpdateRedpoint(true)
  end
  if chatMsg.msgType == chat_macro.ChatRoomSendGiftMsgType then
    EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_SEND_GIFT_NOTIFY, chatMsg.msgType, chatMsg.content.other)
  end
  chatMessageList:AppendItem(chatMsg)
end
function logic_chat_channel_chat_room.GetMessageList()
  return chatMessageList
end
function logic_chat_channel_chat_room.SendMsg(content)
  if logic_chat_channel_chat_room.CheckHasRightToChat() == false then
    return
  end
  local msg = {}
  msg.voice = ""
  msg.text = content
  msg.voiceLength = 0
  msg.quickMsg = false
  msg.msgType = 0
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(tonumber(logic_chat_channel_chat_room.GetMyChatRoomId()), chat_macro.Channel.channelChatRoom, msgId, msg)
end
function logic_chat_channel_chat_room.SendVoiceMsg(voiceId, length, content)
  if nil == voiceId or "" == voiceId then
    return
  end
  if logic_chat_channel_chat_room.CheckHasRightToChat() == false then
    return
  end
  local msg = {}
  msg.voice = voiceId
  msg.text = content
  msg.voiceLength = length
  msg.quickMsg = false
  msg.msgType = chat_macro.VoiceChatMsgType
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(tonumber(logic_chat_channel_chat_room.GetMyChatRoomId()), chat_macro.Channel.channelChatRoom, msgId, msg)
end
function logic_chat_channel_chat_room.SendAchivementShare(achievementShareId, finishTime)
  if logic_chat_channel_chat_room.CheckHasRightToChat() == false then
    return
  end
  local content = LocUtil.GetLocalizeResStr("5027")
  local other = {}
  other.achievementId = achievementShareId
  other.finish_time = finishTime
  local msg = {}
  msg.text = content
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.achivementMsgType
  msg.quickMsg = false
  msg.  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(tonumber(logic_chat_channel_chat_room.GetMyChatRoomId()), chat_macro.Channel.channelChatRoom, msgId, msg)
end
function logic_chat_channel_chat_room.SendWonderfulReplayShare(toUid, otherInfo, topicId)
  if logic_chat_channel_chat_room.CheckHasRightToChat() == false then
    return
  end
  local channel = chat_macro.Channel.channelChatRoom
  local msg = {}
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.text = LocUtil.GetLocalizeResStr(24668)
  msg.msgType = chat_macro.replayShareMsgType
  msg.quickMsg = false
  msg.other = otherInfo
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(tonumber(logic_chat_channel_chat_room.GetMyChatRoomId()), channel, msgId, msg)
end
function logic_chat_channel_chat_room.CheckHasRightToChat()
  if logic_chat_channel_chat_room.GetMyChatRoomId() == "0" then
    ShowNotice(106057)
    return false
  end
  return true
end
function logic_chat_channel_chat_room.CheckChatRoom_CreateName(createName)
  local StringUtil = require("common.string_util")
  createName = StringUtil.StrTrim(createName)
  local ret, len, retStr = StringUtil.CheckName(createName, true, 20, true)
  return ret, len, retStr
end
function logic_chat_channel_chat_room.SetChatRoomCfg(lv, max_create_cnt, max_player_cnt_per_channel)
  logic_chat_channel_chat_room.chatRoomOpenLv = lv or 25
  logic_chat_channel_chat_room.chatRoomMaxCreate = max_create_cnt or 3
  logic_chat_channel_chat_room.maxPlayerCntPerChannel = max_player_cnt_per_channel or 30
end
function logic_chat_channel_chat_room.isInTable(table, value)
  if table == nil then
    return true
  end
  for _, v in pairs(table) do
    if v.channel_info.id == value.channel_info.id then
      return false
    end
  end
  return true
end
function logic_chat_channel_chat_room.UpdateChannelList(channelList, channelTab, roomType)
  if not channelList then
    return
  end
  local tb = {
    channelList = channelList,
    channelTab = channelTab,
      }
  log_tree("logic_chat_channel_chat_room.UpdateChannelList tb:", tb)
  if not logic_chat_channel_chat_room.channelMap[channelTab] then
    logic_chat_channel_chat_room.channelMap[channelTab] = {}
  end
  if logic_chat_channel_chat_room.channelMap[channelTab][roomType] == nil then
    logic_chat_channel_chat_room.channelMap[channelTab][roomType] = channelList
    logic_chat_channel_chat_room.totalRoomCount = 0
    local count = 0
    for _, value in pairs(channelList) do
      count = count + 1
    end
    logic_chat_channel_chat_room.totalRoomCount = count
  elseif channelList.current_channel == nil then
    for _, value in pairs(channelList) do
      if value ~= nil and logic_chat_channel_chat_room.isInTable(logic_chat_channel_chat_room.channelMap[channelTab][roomType], value) then
        logic_chat_channel_chat_room.channelMap[channelTab][roomType][value.channel_info.id] = value
        logic_chat_channel_chat_room.totalRoomCount = logic_chat_channel_chat_room.totalRoomCount + 1
      end
    end
  end
  if channelList.current_channel ~= nil then
    local currentChannelID = channelList.current_channel
    local currentChannelInfo
    for k, v in pairs(channelList) do
      if type(k) == "number" and v ~= nil and v.channel_info ~= nil and currentChannelID ~= nil and currentChannelID == k then
        currentChannelInfo = v
      end
    end
    if currentChannelInfo ~= nil then
      logic_chat_channel_chat_room.UpdateMyChannel(currentChannelInfo)
    end
  end
end
function logic_chat_channel_chat_room.JudgePullOtherLanguageRoom()
  log(bWriteLog and "logic_chat_channel_chat_room.JudgePullOtherLanguageRoom")
  if logic_chat_channel_chat_room.totalRoomCount < MAX_ROOM_COUNT then
    local totalCount = #logic_chat_channel_chat_room.AllLanguageMap
    local pullCount = #logic_chat_channel_chat_room.PullLanguageMap
    if totalCount >= pullCount then
      logic_chat_channel_chat_room.isEndScroll = true
      local languageId = logic_chat_channel_chat_room.GetLanguageId()
      logic_chat_channel_chat_room.pullLanguageId = languageId
    end
  else
    local str = LocUtil.GetLocalizeResStr(18010240)
    ShowNotice(str)
    logic_chat_channel_chat_room.isEndScroll = false
  end
end
function logic_chat_channel_chat_room.GetLanguageId()
  log(bWriteLog and "logic_chat_channel_chat_room.GetLanguageId")
  if logic_chat_channel_chat_room.CheckPullLanguage(DataMgr.FirstSecondLanguage[2]) then
    logic_chat_channel_chat_room.pullLanguageId = DataMgr.FirstSecondLanguage[2]
    if logic_chat_channel_chat_room.PullLanguageMap == nil then
      logic_chat_channel_chat_room.PullLanguageMap = {}
    end
    if logic_chat_channel_chat_room.PullLanguageMap ~= nil and DataMgr.FirstSecondLanguage[2] ~= nil then
      logic_chat_channel_chat_room.PullLanguageMap[DataMgr.FirstSecondLanguage[2]] = 1
    end
    logic_chat_channel_chat_room.ChatRoomIndex = -1
    return DataMgr.FirstSecondLanguage[2]
  end
  logic_chat_channel_chat_room.pullLanguageIndex = logic_chat_channel_chat_room.pullLanguageIndex + 1
  local checkLanguageId = logic_chat_channel_chat_room.AllLanguageMap[logic_chat_channel_chat_room.pullLanguageIndex]
  if logic_chat_channel_chat_room.CheckPullLanguage(checkLanguageId) then
    logic_chat_channel_chat_room.PullLanguageMap[checkLanguageId] = 1
    logic_chat_channel_chat_room.ChatRoomIndex = -1
    return checkLanguageId
  end
end
function logic_chat_channel_chat_room.CheckPullLanguage(NeedCheckLanguageId)
  log(bWriteLog and "logic_chat_channel_chat_room.PullSecondLanguage")
  if #logic_chat_channel_chat_room.PullLanguageMap == 0 then
    return true
  end
  for LanguageId, isPull in pairs(logic_chat_channel_chat_room.PullLanguageMap) do
    if LanguageId == NeedCheckLanguageId then
      return false
    end
  end
  return true
end
function logic_chat_channel_chat_room.GetAllLanguageMap()
  log(bWriteLog and "[vvwwzhang]logic_chat_channel_chat_room.GetAllLanguageMap")
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local language_data_list = logic_chat_channel_world.language_data_list
  log_tree(bWriteLog and "language_data_list:", language_data_list)
  for _, language in ipairs(language_data_list) do
    if language.id ~= DataMgr.FirstSecondLanguage[1] and language.id ~= DataMgr.FirstSecondLanguage[2] then
      table.insert(logic_chat_channel_chat_room.AllLanguageMap, language.id)
    end
  end
end
function logic_chat_channel_chat_room.CheckHasRightToCreateOrJoinRoom()
  if DataMgr.roleData.level == nil then
    return true
  end
  local roomOpenLvStr = logic_chat_channel_chat_room.chatRoomOpenLv
  local roomOpenLv = roomOpenLvStr == nil and 0 or tonumber(roomOpenLvStr)
  local satisfyLevel = roomOpenLv <= DataMgr.roleData.level
  if not satisfyLevel then
    local tips = LocUtil.LocalizeResFormat(106059, roomOpenLv)
    ShowNotice(tips)
    return false
  end
  return true
end
function logic_chat_channel_chat_room.ShowErrorMsg(reason)
  if reason ~= nil then
    if tostring(reason) == "name-too-long" then
      ShowNotice(106028)
    elseif tostring(reason) == "key-too-long" then
      ShowNotice(106029)
    elseif tostring(reason) == "key-too-short" then
      ShowNotice(106030)
    elseif tostring(reason) == "have-dirty-in-name" then
      ShowNotice(117042)
    elseif tostring(reason) == "chatchannel_exist" then
      ShowNotice(106032)
    elseif tostring(reason) == "create-channel-exceed-limit" then
      ShowNotice(106033)
    elseif tostring(reason) == "channel-not-exists" then
      ShowNotice(106034)
    elseif tostring(reason) == "chatchannel-not-exist" then
      ShowNotice(106035)
    elseif tostring(reason) == "db_error" then
      ShowNotice(106036)
    elseif tostring(reason) == "chatchannel-is-full" then
      ShowNotice(106037)
    elseif tostring(reason) == "passwd-not-correct" then
      ShowNotice(106038)
    elseif tostring(reason) == "not-channel-owner" then
      ShowNotice(106039)
    elseif tostring(reason) == "announcement-too-long" then
      ShowNotice(106073)
    elseif tostring(reason) == "have-dirty-in-announcement" then
      ShowNotice(106074)
    elseif tostring(reason) == "in-create-cd" then
      ShowNotice(38767)
    elseif tostring(reason) == "is-guest" then
      ShowNotice(18466)
    elseif tostring(reason) == "is-closed" then
      ShowNotice(38770)
    elseif tostring(reason) == "chatchannel-ver-limit" then
      ShowNotice(15116)
    else
      log(bWriteLog and "unknown error " .. tostring(reason))
    end
  end
end
function logic_chat_channel_chat_room.GetMyChannel()
  return logic_chat_channel_chat_room.myChannel
end
function logic_chat_channel_chat_room.UpdateMyChannel(channel)
  logic_chat_channel_chat_room.myChannel = channel
  local LogicChatRoomTopic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicChatRoomTopic)
  LogicChatRoomTopic:SetCurrentTopicID(channel.channel_info.cur_question_id)
end
function logic_chat_channel_chat_room.GetMyChatRoomName()
  if logic_chat_channel_chat_room.myChannel ~= nil then
    return logic_chat_channel_chat_room.myChannel.channel_info.channel_name
  end
  return ""
end
function logic_chat_channel_chat_room.GetMyChatRoomPassword()
  if logic_chat_channel_chat_room.myChannel ~= nil and logic_chat_channel_chat_room.myChannel.channel_info.channel_need_key then
    return logic_chat_channel_chat_room.myChannel.passwd ~= nil and logic_chat_channel_chat_room.myChannel.passwd or ""
  end
  return ""
end
function logic_chat_channel_chat_room.GetMyChatRoomId()
  if logic_chat_channel_chat_room.myChannel ~= nil then
    return logic_chat_channel_chat_room.myChannel.channel_info.id
  end
  return "0"
end
function logic_chat_channel_chat_room.SetChatRoomQueryPassword(value)
  logic_chat_channel_chat_room.chatRoomQueryPassword = value
end
function logic_chat_channel_chat_room.IsMyRoomSelfCreate()
  return logic_chat_channel_chat_room.IsRoomOwner(DataMgr.roleData.uid)
end
function logic_chat_channel_chat_room.IsRoomOwner(uid)
  if logic_chat_channel_chat_room.myChannel ~= nil then
    return tostring(logic_chat_channel_chat_room.myChannel.channel_info.channel_owner) == tostring(uid)
  end
  return false
end
function logic_chat_channel_chat_room.GetChannelList(channelTab, roomType)
  if not logic_chat_channel_chat_room.channelMap[channelTab] then
    log(bWriteLog and "logic_chat_channel_chat_room.GetChannelList no channelTab")
    return {}
  end
  if not logic_chat_channel_chat_room.channelMap[channelTab][0] then
    log(bWriteLog and "logic_chat_channel_chat_room.GetChannelList no roomType")
    return {}
  end
  if roomType == 1 or roomType == 2 then
    local tables = {}
    for k, v in pairs(logic_chat_channel_chat_room.channelMap[channelTab][0]) do
      if v.channel_info.channel_type == roomType then
        table.insert(tables, v)
      end
    end
    local channelsArray = logic_chat_channel_chat_room.SortLangugeChannel(tables, channelTab, roomType)
    return channelsArray
  end
  local allChannelsArray = logic_chat_channel_chat_room.SortLangugeChannel(logic_chat_channel_chat_room.channelMap[channelTab][roomType], channelTab, roomType)
  return allChannelsArray
end
function logic_chat_channel_chat_room.SortLangugeChannel(curTables, channelTab, roomType)
  local Array = {}
  for id, info in pairs(curTables) do
    table.insert(Array, {id = id, info = info})
  end
  table.sort(Array, function(a, b)
    local presetValue = DataMgr.FirstSecondLanguage[1]
    local aId = 0
    local bId = 0
    if a.info then
      aId = logic_chat_channel_chat_room.GetLanguageNameByName(a.info.channel_info.local_lang)
    end
    if b.info then
      bId = logic_chat_channel_chat_room.GetLanguageNameByName(b.info.channel_info.local_lang)
    end
    if aId == presetValue and bId == presetValue then
      return false
    end
    if aId == presetValue and bId ~= presetValue then
      return true
    end
    if bId == presetValue and aId ~= presetValue then
      return false
    end
    return false
  end)
  return Array
end
function logic_chat_channel_chat_room.GetLanguageNameByName(name)
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  for _, v in ipairs(logic_chat_channel_world.language_data_list) do
    if type(name) == "string" then
      if v.name and v.name == name then
        return v.id or ""
      end
    elseif v.id and v.id == name then
      return v.name or ""
    end
  end
  return ""
end
function logic_chat_channel_chat_room.CheckMyChatRoomMarked()
  if logic_chat_channel_chat_room.myChannel ~= nil then
    return logic_chat_channel_chat_room.myChannel.is_collect
  end
  return false
end
function logic_chat_channel_chat_room.InitChatRoomRedPoint()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ChatRoomRedPoint
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData == nil or not saveData.hasGuide then
    UpdateRedpoint(true)
  else
    UpdateRedpoint(false)
  end
end
function logic_chat_channel_chat_room.ClearChatRoomRedPoint()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.ChatRoomRedPoint
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  saveData = saveData or {}
  saveData.hasGuide = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, fileType)
  UpdateRedpoint(false)
end
function logic_chat_channel_chat_room.GetMaxPlayerCnt()
  return logic_chat_channel_chat_room.maxPlayerCntPerChannel
end
function logic_chat_channel_chat_room.IsGuest()
  if _G.IsEditor then
    return false
  end
  local channel = Client.GetLoginChannel(NetInterface)
  return channel == BP_ENUM_PLAYFORM_TOURIST
end
function logic_chat_channel_chat_room.create_channel_req(name, need_key, key, channel_type, voice_mode)
  log(bWriteLog and "create_channel_req, name = " .. name .. ", need_key = " .. tostring(need_key) .. ", key = " .. key)
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_create_channel_req(name, need_key, key, channel_type, voice_mode)
end
function logic_chat_channel_chat_room.on_create_channel_rsp(ok, reason, channel_id, channel)
  log(bWriteLog and "create_channel_rsp " .. " ok = " .. tostring(ok) .. " , reason = " .. tostring(reason) .. " , channel_id = " .. tostring(channel_id))
  if ok then
    logic_chat_channel_chat_room.UpdateMyChannel(channel)
    UIManager.CloseUI(UIManager.UI_Config.ui_chat_room_create)
    EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_CREATE_SUCCESS)
  else
    logic_chat_channel_chat_room.ShowErrorMsg(reason)
  end
end
function logic_chat_channel_chat_room.get_channel_list_req()
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_get_channel_list_req()
end
function logic_chat_channel_chat_room.on_get_channel_list_rsp(channel_list)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  logic_chat_channel_chat_room.UpdateChannelList(channel_list, LogicChatRoomMacro.ChannelTab.Recent, 0)
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_GET_CHANNEL_LIST)
end
function logic_chat_channel_chat_room.send_join_channel_req(channel_id, key, join_channel_from_invite)
  if Client.IsShipping() and logic_chat_channel_chat_room.IsGuest() then
    ShowNotice(32709)
    return
  end
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_join_channel_req(channel_id, key, join_channel_from_invite)
end
function logic_chat_channel_chat_room.on_join_channel_rsp(channel_id, ok, reason, channel, join_channel_from_invite)
  if ok then
    local oldRoomId = logic_chat_channel_chat_room.GetMyChatRoomId()
    if oldRoomId ~= "0" and tonumber(oldRoomId) ~= tonumber(channel.channel_info.id) then
      log(bWriteLog and "on_join_channel_rsp change room")
      logic_chat_channel_chat_room.ClearData()
    end
    logic_chat_channel_chat_room.UpdateMyChannel(channel)
    local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
    if join_channel_from_invite == LogicChatRoomMacro.JoinType.from_invite or join_channel_from_invite == LogicChatRoomMacro.JoinType.from_sidebar then
      log(bWriteLog and "on_join_channel_rsp join_channel_from_invite")
      local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      logic_chat_main.OpenChatMain(chat_macro.Channel.channelChatRoom)
    else
      UIManager.CloseUI(UIManager.UI_Config.ui_chat_room_password)
      EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_ADD_SUCCESS)
    end
  else
    if channel_id ~= nil then
      if tostring(reason) == "passwd-not-correct" and logic_chat_channel_chat_room.chatRoomQueryPassword then
        logic_chat_channel_chat_room.chatRoomQueryPassword = false
        UIManager.ShowUI(UIManager.UI_Config.ui_chat_room_password, channel_id)
        return
      elseif tostring(reason) == "lite-global-shield" then
        ShowNotice(5046)
        return
      end
    end
    log(bWriteLog and "fail to join room, reason = " .. reason)
    logic_chat_channel_chat_room.ShowErrorMsg(reason)
    if tostring(reason) == "chatchannel-not-exist" then
      logic_chat_channel_chat_room.get_channel_list_req()
    end
  end
end
function logic_chat_channel_chat_room.send_exit_channel_req(channel_id)
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_exit_channel_req(channel_id)
end
function logic_chat_channel_chat_room.on_exit_channel_rsp(channel_id, ok, reason)
  if ok then
    if reason == "offmsg" then
      log(bWriteLog and "logic_chat_channel_chat_room.on_exit_channel_rsp offmsg")
    end
    logic_chat_channel_chat_room.QuitVoiceRoom()
    logic_chat_channel_chat_room.ClearData()
    EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_EXIT_SUCCESS)
  else
    log(bWriteLog and "fail to exit channel, reason = " .. reason)
    logic_chat_channel_chat_room.ShowErrorMsg(reason)
  end
end
function logic_chat_channel_chat_room.send_collect_channel_req(channel_id)
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_collect_channel_req(channel_id)
end
function logic_chat_channel_chat_room.on_collect_channel_rsp(channel_id, ok)
  if ok then
    ShowNotice(106066)
  else
    log(bWriteLog and "fail to collect channel")
    ShowNotice(106045)
  end
end
function logic_chat_channel_chat_room.change_channel_req(channel_id, channel_name, need_key, channel_key, channel_type, voice_mode)
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_change_channel_req(channel_id, channel_name, need_key, channel_key, channel_type, voice_mode)
end
function logic_chat_channel_chat_room.on_change_channel_rsp(channel_id, ok, reason, channel)
  if ok then
    if logic_chat_channel_chat_room.myChannel ~= nil then
      local members = logic_chat_channel_chat_room.myChannel.members
      logic_chat_channel_chat_room.UpdateMyChannel(channel)
      logic_chat_channel_chat_room.myChannel.      local TableUtil = require("common.table_util")
      logic_chat_channel_chat_room.myChannel.channel_info.member_num = TableUtil.CountTable(members)
      UIManager.CloseUI(UIManager.UI_Config.ui_chat_room_create)
      EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_CHANGE_SUCCESS)
    end
  else
    log(bWriteLog and "fail to change channel, reason = " .. reason)
    logic_chat_channel_chat_room.ShowErrorMsg(reason)
  end
end
function logic_chat_channel_chat_room.send_delete_channel_req(channel_id)
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_delete_channel_req(channel_id)
end
function logic_chat_channel_chat_room.on_delete_channel_rsp(channel_id, ok, reason)
  if ok then
    logic_chat_channel_chat_room.QuitVoiceRoom()
    logic_chat_channel_chat_room.ClearData()
    EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_DELETE_ROOM)
  else
    log(bWriteLog and "fail to remove channel, reason = " .. reason)
    logic_chat_channel_chat_room.ShowErrorMsg(reason)
  end
end
function logic_chat_channel_chat_room.send_cancel_collect_channel_req(channel_id)
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_cancel_collect_channel_req(channel_id)
end
function logic_chat_channel_chat_room.on_cancel_collect_channel_rsp(channel_id, ok)
  if ok then
    ShowNotice(106067)
  else
    log(bWriteLog and "fail to cancel collect channel")
    ShowNotice(106046)
  end
end
function logic_chat_channel_chat_room.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_chat_room.send_channel_recommend_req(channel_type, lang_id, index)
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_recommend_req(channel_type, lang_id, index)
  logic_chat_channel_chat_room.oldIndex = index
end
function logic_chat_channel_chat_room.on_channel_recommend_rsp(rec_list, channel_type, index)
  if not rec_list then
    return
  end
  if index then
    logic_chat_channel_chat_room.ChatRoomIndex = index
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  logic_chat_channel_chat_room.UpdateChannelList(rec_list, LogicChatRoomMacro.ChannelTab.Recommend, channel_type or 0)
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_GET_RECOMMEND_CHANNEL_LIST)
end
function logic_chat_channel_chat_room.on_dismiss_channel_notify(channel_id)
  if logic_chat_channel_chat_room.myChannel ~= nil and logic_chat_channel_chat_room.myChannel.channel_info ~= nil then
    local channelName = logic_chat_channel_chat_room.myChannel.channel_info.channel_name
    ShowNotice(string.format(DataMgr.GetMsgByID(106055), channelName))
  end
  logic_chat_channel_chat_room.QuitVoiceRoom()
  logic_chat_channel_chat_room.ClearData()
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_DELETE_ROOM)
end
function logic_chat_channel_chat_room.on_channel_merge_notify(channel_id, info_map)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  for uid, info in pairs(info_map) do
    if logic_chat_channel_chat_room.myChannel and logic_chat_channel_chat_room.myChannel.members and logic_chat_channel_chat_room.myChannel.channel_info then
      if info.chat_status == LogicChatRoomMacro.ChannelStatus.Watch or info.chat_status == LogicChatRoomMacro.ChannelStatus.OnMic then
        if logic_chat_channel_chat_room.myChannel.members[uid] then
          logic_chat_channel_chat_room.UpdateMemberStatus(uid, info.chat_status, info.status_ts)
        else
          logic_chat_channel_chat_room.myChannel.members[uid] = info
          logic_chat_channel_chat_room.myChannel.channel_info.member_num = logic_chat_channel_chat_room.myChannel.channel_info.member_num + 1
          EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_ADD_ONE_PLAYER)
        end
      elseif info.chat_status == LogicChatRoomMacro.ChannelStatus.Exit then
        logic_chat_channel_chat_room.MemberExit(uid)
      end
    end
  end
end
function logic_chat_channel_chat_room.ClearRecommendIndex()
  logic_chat_channel_chat_room.channelMap = {}
  logic_chat_channel_chat_room.ChatRoomIndex = -1
  logic_chat_channel_chat_room.isEndScroll = true
  logic_chat_channel_chat_room.PullLanguageMap = {}
  logic_chat_channel_chat_room.totalRoomCount = 0
  logic_chat_channel_chat_room.pullLanguageId = 0
  logic_chat_channel_chat_room.pullLanguageIndex = 0
end
function logic_chat_channel_chat_room.GetVoiceRoomID()
  return "pubg_chat_" .. tostring(logic_chat_channel_chat_room.GetMyChatRoomId())
end
function logic_chat_channel_chat_room.JoinVoiceRoom()
  if logic_chat_channel_chat_room.myChannel == nil then
    log(bWriteLog and "JoinVoiceRoom myChannel nil")
    return
  end
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  log(bWriteLog and "logic_chat_channel_chat_room.JoinVoiceRoom")
  logic_chat_voice:JoinAntsVoiceRoom(logic_chat_voice_const.Enum_AntsVoiceRoomType.LobbyChatRoom, logic_chat_channel_chat_room.GetVoiceRoomID(), logic_chat_channel_chat_room.myChannel.channel_info.AntsVoice_url)
end
function logic_chat_channel_chat_room.QuitVoiceRoom()
  if logic_chat_channel_chat_room.myChannel == nil then
    log(bWriteLog and "QuitVoiceRoom myChannel nil")
    return
  end
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local curTeamRoomName = logic_antsvoice_interface:GetTeamRoomName()
  if not logic_chat_channel_chat_room.IsChatVoiceRoom(curTeamRoomName) then
    log(bWriteLog and "QuitVoiceRoom is not chat voice room")
    return
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  log(bWriteLog and "logic_chat_channel_chat_room.QuitVoiceRoom")
  pcall(function()
    logic_chat_voice:QuitAntsVoiceRoom(logic_chat_voice_const.Enum_AntsVoiceRoomType.LobbyChatRoom)
  end)
  logic_chat_channel_chat_room.ClearRecommendIndex()
end
function logic_chat_channel_chat_room.IsSameVoiceRoom(roomType, roomID)
  local myRoomID = logic_chat_channel_chat_room.GetVoiceRoomID()
  log(bWriteLog and "IsSameVoiceRoom roomType:" .. tostring(roomType) .. " ,roomID:" .. tostring(roomID) .. " ,myRoomID:" .. tostring(myRoomID))
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  local sameRoom = tonumber(roomType) == logic_chat_voice_const.Enum_AntsVoiceRoomType.LobbyChatRoom and tostring(roomID) == tostring(myRoomID)
  return sameRoom
end
function logic_chat_channel_chat_room.IsMyVoiceRoomEvent(param)
  if not param or not next(param) then
    log(bWriteLog and "logic_chat_channel_chat_room.IsMyVoiceRoomEvent data error")
    return
  end
  if not logic_chat_channel_chat_room.IsSameVoiceRoom(param.roomType, param.roomID) then
    log(bWriteLog and "logic_chat_channel_chat_room.IsMyVoiceRoomEvent not same room")
    return false
  end
  if tonumber(param.uid) ~= tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "logic_chat_channel_chat_room.IsMyVoiceRoomEvent not myself")
    return false
  end
  return true
end
function logic_chat_channel_chat_room.IsInVoiceRoom()
  if logic_chat_channel_chat_room.myChannel == nil then
    log(bWriteLog and "IsInVoiceRoom myChannel nil")
    return false
  end
  local logic_chat_voice_data_manager = require("client.slua.logic.chat_voice.logic_chat_voice_data_manager")
  local curRoomType = logic_chat_voice_data_manager:GetCurRoomType()
  local curRoomID = logic_chat_voice_data_manager:GetCurRoomID()
  return logic_chat_channel_chat_room.IsSameVoiceRoom(curRoomType, curRoomID)
end
function logic_chat_channel_chat_room.SetTeamRecruitNewChat(chatMsg, chat_content)
  local map_data = chat_content.team_recuit_map_data
  local chat_ctt = chat_content.text
  chatMsg.taskId = chat_content.taskId
  chatMsg.isRp = chat_content.isRp
  local TimeUtil = require("client.common.time_util")
  chatMsg.create_time = TimeUtil.GetServerTimeInSec()
  chatMsg.teamId = chat_content.team_id
  chatMsg.game_model_type = chat_content.game_model_type
  chatMsg.voiceType = chat_content.VoiceType
  local RecruitSystem = require("client.slua.logic.lobby_chat.logic_recruit")
  local _msg, _mapdata = RecruitSystem.TeamRecruitMap(chat_ctt, map_data)
  chatMsg.msg = _msg
  chatMsg.mapData = _mapdata
end
function logic_chat_channel_chat_room.GetMyChatRoomVoiceMode()
  if logic_chat_channel_chat_room.myChannel then
    return logic_chat_channel_chat_room.myChannel.channel_info.voice_mode
  end
  log(bWriteLog and "logic_chat_channel_chat_room.GetMyChatRoomVoiceMode error")
  return -1
end
function logic_chat_channel_chat_room.GetMyChatRoomType()
  if logic_chat_channel_chat_room.myChannel then
    return logic_chat_channel_chat_room.myChannel.channel_info.channel_type
  end
  log(bWriteLog and "logic_chat_channel_chat_room.GetMyChatRoomType error")
  return -1
end
function logic_chat_channel_chat_room.IsCurrentRoom(roomId)
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  return channel_id == roomId
end
function logic_chat_channel_chat_room.MemberExit(uid)
  log(bWriteLog and "logic_chat_channel_chat_room.MemberExit uid:" .. tostring(uid))
  if not (logic_chat_channel_chat_room.myChannel and logic_chat_channel_chat_room.myChannel.members and logic_chat_channel_chat_room.myChannel.members[uid]) or not logic_chat_channel_chat_room.myChannel.channel_info then
    log(bWriteLog and "logic_chat_channel_chat_room.MemberExit no member")
    return
  end
  logic_chat_channel_chat_room.myChannel.members[uid] = nil
  logic_chat_channel_chat_room.myChannel.channel_info.member_num = logic_chat_channel_chat_room.myChannel.channel_info.member_num - 1
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_EXIT_ONE_PLAYER)
end
function logic_chat_channel_chat_room.UpdateMemberStatus(uid, status, status_ts)
  log(bWriteLog and "logic_chat_channel_chat_room.UpdateMemberStatus uid:" .. tostring(uid) .. ", status:" .. tostring(status))
  if not (logic_chat_channel_chat_room.myChannel and logic_chat_channel_chat_room.myChannel.members) or not logic_chat_channel_chat_room.myChannel.members[uid] then
    log(bWriteLog and "logic_chat_channel_chat_room.UpdateMemberStatus no member")
    return
  end
  if logic_chat_channel_chat_room.myChannel.members[uid].chat_status == status then
    log(bWriteLog and "logic_chat_channel_chat_room.UpdateMemberStatus same status")
    return
  end
  logic_chat_channel_chat_room.myChannel.members[uid].chat_  if not status_ts then
    local TimeUtil = require("client.common.time_util")
    status_ts = TimeUtil.GetServerTimeInSec()
  end
  logic_chat_channel_chat_room.myChannel.members[uid].  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_CHANGE_MIC_STATUS, uid)
end
function logic_chat_channel_chat_room.UpdateChatRoomBG(cur_chat_background_id)
  log(bWriteLog and "logic_chat_channel_chat_room.UpdateChatRoomBG cur_chat_background_id:" .. tostring(cur_chat_background_id))
  if not logic_chat_channel_chat_room.myChannel or not logic_chat_channel_chat_room.myChannel.channel_info then
    log(bWriteLog and "logic_chat_channel_chat_room.UpdateChatRoomBG no channel_info")
    return
  end
  logic_chat_channel_chat_room.myChannel.channel_info.chat_background_id = cur_chat_background_id
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_UPDATE_BG)
end
function logic_chat_channel_chat_room.GetChatRoomBG()
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  if not logic_chat_channel_chat_room.myChannel or not logic_chat_channel_chat_room.myChannel.channel_info then
    log(bWriteLog and "logic_chat_channel_chat_room.GetChatRoomBG no channel_info")
    return LogicChatRoomMacro.DefaultBGID
  end
  local chat_background_id = logic_chat_channel_chat_room.myChannel.channel_info.chat_background_id or LogicChatRoomMacro.DefaultBGID
  log(bWriteLog and "logic_chat_channel_chat_room.GetChatRoomBG chat_background_id:" .. tonumber(chat_background_id))
  return chat_background_id
end
function logic_chat_channel_chat_room.IsChatVoiceRoom(roomID)
  local StringUtil = require("common.string_util")
  return roomID and StringUtil.Starts(roomID, "pubg_chat_")
end
return logic_chat_channel_chat_room