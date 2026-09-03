local macro = require("client.slua.logic.lobby_chat.chat_macro")
local super_list = require("common.super_list")
local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local TimeUtil = require("client.common.time_util")
local logic_chat_channel_corps = {
  isInitCorps = false,
  isGetCorpsNew = false,
  MAX_CORPS_MESSAGE_CACHE_NUM = 200,
  corpsLastChatTime = 0,
  corpsShowChatTime = 0,
  corpsNewsList = {},
  offlineChatMsgBuffer = {},
  isFirstGetNews = true,
  openChatMain = false,
  memberOnline = 0,
  channel = macro.Channel.channelCorps,
  newsNum = 0,
  chatTopMessageList = {},
  TopMsgNum = 0,
  MaxTopMsgNum = 5,
  TopMsgSortedList = {},
  TopMsg = "TopMsg",
  newTopMsg = false,
  TopMsgHighLight = false,
  isGetTeamFightCtat = false
}
local chatMessageList = super_list.Create()
local corpsMemberList = super_list.Create()
local chatTalkMessageList = super_list.Create()
local chatNewsMessageList = super_list.Create()
function logic_chat_channel_corps.Init()
  logic_chat_channel_corps.RegistEvent()
  logic_chat_channel_corps.isGetTeamFightCtat = false
end
function logic_chat_channel_corps.GetMessageList()
  return chatMessageList
end
function logic_chat_channel_corps.GetChatTalkMessageList()
  return chatTalkMessageList
end
function logic_chat_channel_corps.GetChatNewsMessageList()
  return chatNewsMessageList
end
function logic_chat_channel_corps.GetChatTopMessageList()
  return logic_chat_channel_corps.TopMsgSortedList, logic_chat_channel_corps.TopMsgNum
end
function logic_chat_channel_corps.GetMemberList()
  return corpsMemberList
end
function logic_chat_channel_corps.AddNewChat(chatMsg)
  log(bWriteLog and "logic_chat_channel_corps.AddNewChat")
  if not chatMsg.selfMsg and chatMsg.msgType == macro.teamRecruitMsgType then
    logic_chat_channel_corps.SetTeamRecruitNewChat(chatMsg, chatMsg.content)
  end
  logic_chat_channel_corps.SetGiftExchangeNewChat(chatMsg)
  if chat_main.currentChannel ~= macro.Channel.channelCorps or not logic_chat_channel_corps.openChatMain then
    logic_chat_channel_corps.UpdateRedpoint(1)
  end
  if #chatMessageList >= logic_chat_channel_corps.MAX_CORPS_MESSAGE_CACHE_NUM then
    local index = logic_chat_channel_corps.GetIndexToRemove(chatMessageList)
    logic_chat_table_pool.Recycle(chatMessageList[index])
    chatMessageList:RemoveItem(index)
  end
  if #chatTalkMessageList >= logic_chat_channel_corps.MAX_CORPS_MESSAGE_CACHE_NUM then
    local index = logic_chat_channel_corps.GetIndexToRemove(chatTalkMessageList)
    chatTalkMessageList:RemoveItem(index)
  end
  if #chatNewsMessageList >= logic_chat_channel_corps.MAX_CORPS_MESSAGE_CACHE_NUM then
    chatNewsMessageList:RemoveItem(1)
  end
  logic_chat_channel_corps.SetMsgTime(chatMsg)
  chatMessageList:AppendItem(chatMsg)
  if chatMsg.msgType == 0 then
    chatTalkMessageList:AppendItem(chatMsg)
  else
    chatNewsMessageList:AppendItem(chatMsg)
  end
  logic_chat_channel_corps.newsNum = logic_chat_channel_corps.newsNum + 1
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_CROPS_MSG, chatMsg)
end
function logic_chat_channel_corps.SetTeamRecruitNewChat(chatMsg, chat_content)
  local map_data = chat_content.team_recuit_map_data
  local chat_ctt = chat_content.text
  chatMsg.taskId = chat_content.taskId
  chatMsg.isRp = chat_content.isRp
  chatMsg.create_time = TimeUtil.GetServerTimeInSec()
  chatMsg.teamId = chat_content.team_id
  chatMsg.game_model_type = chat_content.game_model_type
  chatMsg.voiceType = chat_content.VoiceType
  local RecruitSystem = require("client.slua.logic.lobby_chat.logic_recruit")
  local _msg, _mapdata = RecruitSystem.TeamRecruitMap(chat_ctt, map_data)
  chatMsg.msg = _msg
  chatMsg.mapData = _mapdata
end
function logic_chat_channel_corps.SetGiftExchangeNewChat(chatMsg)
  if chatMsg.msgType == macro.corpsGiftMsgType and chatMsg.content and chatMsg.content.src_item_id and chatMsg.content.dst_item_id then
    local srcItem = CDataTable.GetTableData("Item", chatMsg.content.src_item_id)
    local dstItem = CDataTable.GetTableData("Item", chatMsg.content.dst_item_id)
    if srcItem and dstItem then
      local chat_ctt = LocUtil.LocalizeResFormat("8789", srcItem.ItemName, dstItem.ItemName)
      chatMsg.msg = chat_ctt
    end
  end
end
function logic_chat_channel_corps.OpenCorpsGiftExchange(chatMsg)
  local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
  if modeSystem.IsSocialIslandMode() then
    ShowNotice(9868)
    return
  end
  local CorpGiftExchangeSystem = require("client.slua.logic.corps_gift_exchange.logic_corp_gift_exchange")
  CorpGiftExchangeSystem.JumpFromChat(chatMsg.content.seq_id, chatMsg)
  chat_main.CloseChatWin()
end
function logic_chat_channel_corps.SetMsgTime(chatMsg)
  if chatMsg.msgType == 0 and (chatMsg.msgSendTime == nil or chatMsg.msgSendTime == "") then
    local thisTime = TimeUtil.OSTime()
    if chatMsg.send_time then
      thisTime = chatMsg.send_time
    end
    local diffTime = thisTime - logic_chat_channel_corps.corpsLastChatTime
    local interval = 300
    if diffTime > interval then
      chatMsg.msgSendTime = TimeUtil.FormatTime_HM(thisTime, true)
      logic_chat_channel_corps.corpsShowChatTime = thisTime
    else
      local diffRecordTime = thisTime - logic_chat_channel_corps.corpsShowChatTime
      if 60 < diffTime and interval < diffRecordTime then
        chatMsg.msgSendTime = TimeUtil.FormatTime_HM(thisTime, true)
        logic_chat_channel_corps.corpsShowChatTime = thisTime
      else
        chatMsg.msgSendTime = ""
      end
    end
    logic_chat_channel_corps.corpsLastChatTime = thisTime
    chatMsg.msgSendDate = TimeUtil.FormatTime_YMD(thisTime, true)
  end
end
function logic_chat_channel_corps.SendMsg(content)
  local msg = {}
  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = 0
  msg.quickMsg = false
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendNewsMsg(content, extra)
  local msg = {}
  msg.text = content or ""
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.corpsNewsMsgType
  msg.quickMsg = false
  msg.  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendVoiceMsg(voiceId, length, content)
  local msg = {}
  msg.voice = voiceId
  msg.text = content
  msg.voiceLength = length
  msg.quickMsg = false
  msg.msgType = macro.VoiceChatMsgType
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendAchivementShare(achievementShareId, finishTime)
  local channel = macro.Channel.channelCorps
  local content = LocUtil.GetLocalizeResStr("5027")
  local other = {}
  other.achievementId = achievementShareId
  other.finish_time = finishTime
  local msg = {}
  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.achivementMsgType
  msg.quickMsg = false
  msg.  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendSocialCardMsg(bSendRecord)
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(45916)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.roleinfoSocialCard
  msg.socialCardFloorID = 61200002
  msg.quickMsg = false
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  msg.social_card = SocialCardSystem.GetShareCardData(bSendRecord)
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendRedpacketMsg(st)
  local isOpen = require("client.slua.logic.crp.ChatRedpacketUtils").IsOpen()
  if not isOpen then
    return
  end
  local msg = {}
  msg.msgType = macro.redpacket
  msg.text = st.basic_info.message
  local utils = require("client.slua.logic.crp.ChatRedpacketUtils")
  msg.redpacket = utils.GetChatMsgStruct(st)
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.InitCorpsData()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.GetCorpsMemberList()
  CorpsMgr.get_corps_news_list_req()
  CorpsMemberSystem.get_corps_member_online_info_req()
end
function logic_chat_channel_corps.CheckExchangeGifgMsgTime(createTime)
  createTime = createTime or 0
  if createTime == 0 or TimeUtil.GetServerTimeInSec() - createTime > 172800 then
    return true
  end
  return false
end
function logic_chat_channel_corps.CheckFilterOfflineMsg(msg)
  if msg.data.msgType == macro.teamRecruitMsgType then
    return false
  elseif msg.data.msgType == macro.corpsGiftMsgType and logic_chat_channel_corps.CheckExchangeGifgMsgTime(msg.create_time) then
    return false
  end
  return true
end
function logic_chat_channel_corps.OnCorpsData(eventID, eventName, corps)
  log(bWriteLog and "god test OnCorpsData")
  logic_chat_channel_corps.AddOfflineCorpsChatMsg(corps)
  logic_chat_channel_corps.isInitCorps = true
end
function logic_chat_channel_corps.OnQuitCorps()
  logic_chat_channel_corps.UpdateRedpoint(0)
  logic_chat_table_pool.RecycleAll(chatMessageList)
  chatTalkMessageList:ClearData()
  chatNewsMessageList:ClearData()
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_CROPS_MSG)
  corpsMemberList:ClearData()
  logic_chat_channel_corps.corpsNewsList = {}
  logic_chat_channel_corps.isInitCorps = false
  logic_chat_channel_corps.offlineChatMsgBuffer = {}
  logic_chat_channel_corps.chatTopMessageList = {}
  logic_chat_channel_corps.TopMsgSortedList = {}
  logic_chat_channel_corps.TopMsgNum = 0
  logic_chat_channel_corps.newTopMsg = false
  logic_chat_channel_corps.TopMsgHighLight = false
  logic_chat_channel_corps.newsNum = 0
  logic_chat_channel_corps.isGetTeamFightCtat = false
  local logic_corps_teamfight = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_corps_teamfight)
  if logic_corps_teamfight == nil then
    logic_corps_teamfight = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_corps_teamfight)
  end
  logic_corps_teamfight:ClearTeamFightCtatAndRed()
end
function logic_chat_channel_corps.IsInCorps()
  return DataMgr.corpsInfo.id and DataMgr.corpsInfo.id ~= 0
end
function logic_chat_channel_corps.GetAnnouncement()
  if nil ~= DataMgr.corpsInfo and nil ~= DataMgr.corpsInfo.announcement then
    return LocUtil.GetLocalizeResStr(410065) .. DataMgr.corpsInfo.announcement
  end
  return ""
end
function logic_chat_channel_corps.GetNotice()
  if nil ~= DataMgr.corpsInfo and nil ~= DataMgr.corpsInfo.notice then
    return LocUtil.GetLocalizeResStr(421039) .. "\n" .. DataMgr.corpsInfo.notice
  end
  return ""
end
function logic_chat_channel_corps.AddOfflineCorpsChatMsg(corpsData)
  if logic_chat_channel_corps.isInitCorps and 0 < #chatMessageList then
    return
  end
  if corpsData == nil or corpsData.chat_data == nil and corpsData.pdd_data == nil and corpsData.rp_groupbuy_data == nil and corpsData.new_group_buy_data == nil then
    return
  end
  logic_chat_channel_corps.offlineChatMsgBuffer = {}
  logic_chat_channel_corps.RPGroupBuyMsg(corpsData.rp_groupbuy_data)
  logic_chat_channel_corps.RPGroupBuyMsg(corpsData.new_group_buy_data)
  local msgList = corpsData.chat_data
  local num = 0
  if msgList ~= nil then
    for k, v in pairs(msgList) do
      if logic_chat_channel_corps.CheckFilterOfflineMsg(v) then
        local bSelfMsg = tonumber(v.send_uid) == tonumber(DataMgr.roleData.uid)
        if not v.data.sendTime then
          v.data.sendTime = v.create_time
        end
        if v.data and v.data.msgType == 0 and not v.data.corps_msg_id then
          v.data.corps_msg_id = k
        end
        local chatMsg = chat_main.SetNewChat(logic_chat_table_pool.Get(), v.sender_name, v.chat_type, v.send_uid, v.send_uid, v.zone_id, v.nation, v.data, bSelfMsg)
        chatMsg.msg = chat_main.ReplaceEmoji(chatMsg.msg)
        logic_chat_channel_corps.SetGiftExchangeNewChat(chatMsg)
        logic_chat_channel_corps.SetMsgTime(chatMsg)
        if v.top_time then
          if v.data.corps_msg_id then
            chatMsg.top_time = v.top_time
            chatMsg.op_uid = v.op_uid
            logic_chat_channel_corps.chatTopMessageList[v.data.corps_msg_id] = chatMsg
          else
            log(bWriteLog and "logic_chat_channel_corps.AddOfflineCorpsChatMsg TopMsg no Id")
          end
        end
        table.insert(logic_chat_channel_corps.offlineChatMsgBuffer, chatMsg)
        local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
        if v.create_time > StarterPackSystem.lastLogoutTime then
          num = num + 1
        end
      end
    end
  end
  logic_chat_channel_corps.SortChatTopMsgList()
  logic_chat_channel_corps.SortChatMsgList(logic_chat_channel_corps.offlineChatMsgBuffer, true)
  if logic_chat_channel_corps.openChatMain then
    logic_chat_channel_corps.SetChatTalkMessageList(logic_chat_channel_corps.offlineChatMsgBuffer)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_SET_CORPS_NEWS_AND_OFFLINE, function()
      chatMessageList:SetData(logic_chat_channel_corps.offlineChatMsgBuffer)
    end, #logic_chat_channel_corps.offlineChatMsgBuffer)
  else
    logic_chat_channel_corps.SetChatTalkMessageList(logic_chat_channel_corps.offlineChatMsgBuffer)
    chatMessageList:SetData(logic_chat_channel_corps.offlineChatMsgBuffer)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_CROPS_MSG)
  end
end
function logic_chat_channel_corps.RPGroupBuyMsg(data)
  if data ~= nil then
    for k, v in pairs(data) do
      local bSelfMsg = tonumber(v.data.other.owner_id) == tonumber(DataMgr.roleData.uid)
      local senderName = ""
      if v.sender_name ~= nil then
        senderName = v.sender_name
      end
      local chatMsg = {}
      if v.chat_type == macro.Channel.channelCorps then
        chat_main.SetNewChat(chatMsg, senderName, v.chat_type, v.send_uid, v.send_uid, 0, v.nation, v.data, bSelfMsg)
        logic_chat_channel_corps.SetMsgTime(chatMsg)
        table.insert(logic_chat_channel_corps.offlineChatMsgBuffer, chatMsg)
      end
    end
  end
end
function logic_chat_channel_corps.UpdateRedpoint(num)
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  logic_chat_channel_manager:UpdateChannelRedPoint(macro.Channel.channelCorps, 0 < num)
  local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
  logic_chat_entrance:SetUnreadCorpsChatMsgCount(num)
end
function logic_chat_channel_corps.SetMemberInfo(memberInfo)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(memberInfo.id) or {}
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  local status = CorpsMemberSystem.GetOnlineStatusWithDefault(memberInfo.id)
  local info = {
    uid = profile.uid or memberInfo.id or 0,
    nickName = profile.nickName or "",
    level = profile.level or 1,
    picUrl = profile.picUrl or "",
    vipLevel = profile.vipLevel or 0,
    sex = profile.sex or 0,
    lastOnlineTime = profile.lastOnlineTime or 0,
    cur_avatar_box_id = profile.cur_avatar_box_id or 0,
    upassIsBuy = profile.upass_is_buy and profile.upass_is_buy == 1,
    upassShow = profile.upass_is_show or 0,
    upassKeepBuy = profile.upass_keep_buy or 0,
    roleNation = profile.nation or "",
    position = memberInfo.position,
    week_active = memberInfo.week_active,
    segment_info_solo = memberInfo.segment_info_solo,
    segment_info_duo = memberInfo.segment_info_duo,
    segment_info_squad = memberInfo.segment_info_squad,
    game_id = status.game_id or 0,
    land_id = status.land_id or 0,
    teamState = status.teamState or 0,
    maxTeamAmount = status.maxTeamAmount or 4,
    socialland_type = status.socialland_type or 0,
    currentTeamAmount = status.currentTeamAmount or 1,
    online = status.online or 0,
    tplan_type = status.tplan_type or 0,
    cwow_type = status.cwow_type or 0
  }
  return info
end
function logic_chat_channel_corps.SetCorpsMemberList()
  local chatCorpsMemberList = {}
  local onlineCount = 0
  for k, v in pairs(DataMgr.corpsInfo.corpsMemberList) do
    local info = logic_chat_channel_corps.SetMemberInfo(v)
    if info.online == 1 then
      onlineCount = onlineCount + 1
    end
    table.insert(chatCorpsMemberList, info)
  end
  logic_chat_channel_corps.memberOnline = onlineCount
  table.sort(chatCorpsMemberList, logic_chat_channel_corps.SortMember)
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_CROPS_SET_MEMBER)
  corpsMemberList:SetData(chatCorpsMemberList)
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_CROPS_MEMBER_CHANGE)
end
function logic_chat_channel_corps.SortMember(a, b)
  if a.online and b.online then
    if a.online > b.online then
      return true
    elseif a.online < b.online then
      return false
    end
  end
  if a.position and b.position then
    if a.position < b.position then
      return true
    elseif a.position > b.position then
      return false
    end
  end
  if a.week_active and b.week_active then
    if a.week_active > b.week_active then
      return true
    elseif a.week_active < b.week_active then
      return false
    end
  end
  if a.level and b.level then
    if a.level > b.level then
      return true
    elseif a.level < b.level then
      return false
    end
  end
  if a.uid and b.uid then
    if a.uid < b.uid then
      return true
    elseif a.uid > b.uid then
      return false
    end
  end
end
function logic_chat_channel_corps.RefreshCorpsMember(eventid, eventName, uidList)
  log(bWriteLog and "[tinghaohu] RefreshCorpsMember eventName = " .. eventName)
  if not uidList then
    return
  end
  for _, uid in pairs(uidList) do
    for k, memberInfo in pairs(corpsMemberList) do
      if tostring(memberInfo.uid) == tostring(uid) then
        local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
        local status = CorpsMemberSystem.GetOnlineStatus(uid)
        if status ~= nil then
          if tostring(uid) == tostring(DataMgr.roleData.uid) then
            memberInfo.online = 1
          else
            memberInfo.online = status.online
          end
          memberInfo.teamState = status.teamState or 0
          memberInfo.currentTeamAmount = status.currentTeamAmount or 1
          memberInfo.maxTeamAmount = status.maxTeamAmount or 4
          memberInfo.land_id = status.land_id or 0
          memberInfo.game_id = status.game_id or 0
          memberInfo.socialland_type = status.socialland_type or 0
          memberInfo.tplan_type = status.tplan_type or 0
          memberInfo.cwow_type = status.cwow_type or 0
        end
        break
      end
    end
  end
  corpsMemberList:Sort(logic_chat_channel_corps.SortMember)
end
function logic_chat_channel_corps.RefreshCorpsMemberOnlineInfo(eventid, eventName, uidList)
  log(bWriteLog and "[tinghaohu] RefreshCorpsMemberOnlineInfo eventName = " .. eventName)
  logic_chat_channel_corps.RefreshCorpsMember(eventid, eventName, uidList)
end
function logic_chat_channel_corps.GetNewsList()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local news_id_tohide = {
    [1] = true,
    [3] = true,
    [7] = true,
    [8] = true
  }
  local chatMsgList = {}
  for i, news in pairs(CorpsMgr.corps_news.news_list) do
    local isSkip = false
    if news_id_tohide[news.news_id] then
      isSkip = true
    end
    if not isSkip then
      local has = false
      for k, v in pairs(logic_chat_channel_corps.corpsNewsList) do
        if v.seq_id == news.seq_id then
          has = true
          break
        end
      end
      if has == false then
        local chatMsg = {}
        chatMsg.text = news.content
        chatMsg.send_time = news.time or 0
        chatMsg.msgChannel = macro.Channel.channelCorps
        chatMsg.msgType = macro.corpsNewsMsgType
        table.insert(chatMsgList, chatMsg)
      end
    end
  end
  if not logic_chat_channel_corps.isGetTeamFightCtat then
    local logic_corps_teamfight = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_corps_teamfight)
    if logic_corps_teamfight == nil then
      logic_corps_teamfight = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_corps_teamfight)
    end
    local chat = logic_corps_teamfight:GetTeamFightCtat()
    if chat and next(chat) then
      table.insert(chatMsgList, chat)
    end
    logic_chat_channel_corps.isGetTeamFightCtat = true
  end
  return chatMsgList
end
function logic_chat_channel_corps.SortChatMsgList(chatMsgList, isOffline)
  for _, v in pairs(chatMessageList) do
    if isOffline then
      local exists = false
      for _, msg in ipairs(chatMsgList) do
        if msg.send_time == v.send_time and msg.sender_uid == v.sender_uid then
          exists = true
          break
        end
      end
      if not exists then
        table.insert(chatMsgList, v)
      end
    elseif not isOffline then
      table.insert(chatMsgList, v)
    end
  end
  table.sort(chatMsgList, function(a, b)
    if a.send_time == nil or b.send_time == nil then
      return false
    end
    return a.send_time < b.send_time
  end)
  if #chatMsgList > logic_chat_channel_corps.MAX_CORPS_MESSAGE_CACHE_NUM then
    for k = 1, #chatMsgList - logic_chat_channel_corps.MAX_CORPS_MESSAGE_CACHE_NUM do
      logic_chat_table_pool.Recycle(chatMsgList[1])
      table.remove(chatMsgList, 1)
    end
  end
end
function logic_chat_channel_corps.OnRefreshCorpsNewList()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if CorpsMgr.corps_news == nil then
    return
  end
  local chatMsgList = logic_chat_channel_corps.GetNewsList()
  logic_chat_channel_corps.corpsNewsList = CorpsMgr.corps_news.news_list
  logic_chat_channel_corps.SortChatMsgList(chatMsgList)
  if logic_chat_channel_corps.openChatMain then
    logic_chat_channel_corps.SetChatTalkMessageList(chatMsgList)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_SET_CORPS_NEWS_AND_OFFLINE, function()
      chatMessageList:SetData(chatMsgList)
    end, #chatMsgList)
  else
    logic_chat_channel_corps.SetChatTalkMessageList(chatMsgList)
    chatMessageList:SetData(chatMsgList)
  end
end
function logic_chat_channel_corps.ClickCorpsGoto()
  chat_main.CloseChatWin()
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  logic_corps_tab_mgr.OpenCorpsUI()
end
function logic_chat_channel_corps.OpenCorpsTab()
  chat_main.OpenChatMain(macro.Channel.channelCorps)
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_OPEN_CORPS_CHANNEL_FROM_CROPS_SYSTEM)
end
function logic_chat_channel_corps.CorpsExchangeGift(exchange_info)
  local msgType = macro.corpsGiftMsgType
  local tabContent = {}
  tabContent.msgType = msgType or 0
  tabContent.src_item_id = exchange_info.src_id
  tabContent.dst_item_id = exchange_info.dst_id
  tabContent.seq_id = exchange_info.seq_id
  tabContent.sendTime = TimeUtil.GetServerTimeInSec()
  local msgId = chat_main.CacheMsg(tabContent)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, tabContent)
end
function logic_chat_channel_corps.RegistEvent()
  EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, logic_chat_channel_corps.SetCorpsMemberList)
  EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO, logic_chat_channel_corps.RefreshCorpsMember)
  EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO, logic_chat_channel_corps.RefreshCorpsMemberOnlineInfo)
  EventSystem:registEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_INFO, logic_chat_channel_corps.OnCorpsData)
  EventSystem:registEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_NEWS_LIST, logic_chat_channel_corps.OnRefreshCorpsNewList)
  EventSystem:registEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_QUIT, logic_chat_channel_corps.OnQuitCorps)
end
function logic_chat_channel_corps.UnRegistEvent()
  EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, logic_chat_channel_corps.SetCorpsMemberList)
  EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO, logic_chat_channel_corps.RefreshCorpsMember)
  EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO, logic_chat_channel_corps.RefreshCorpsMemberOnlineInfo)
  EventSystem:unregistEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_INFO, logic_chat_channel_corps.OnCorpsData)
  EventSystem:unregistEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_NEWS_LIST, logic_chat_channel_corps.OnRefreshCorpsNewList)
  EventSystem:unregistEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_QUIT, logic_chat_channel_corps.OnQuitCorps)
end
function logic_chat_channel_corps.ClearData()
  logic_chat_table_pool.RecycleAll(chatMessageList)
  chatTalkMessageList:ClearData()
  chatNewsMessageList:ClearData()
  corpsMemberList:ClearData()
  logic_chat_channel_corps.corpsNewsList = {}
  logic_chat_channel_corps.isInitCorps = false
  logic_chat_channel_corps.offlineChatMsgBuffer = {}
  logic_chat_channel_corps.UnRegistEvent()
end
function logic_chat_channel_corps.SendIslandTargetShare(toUid, ownerUid, score, timeStamp, timeUsed)
  local channel = macro.Channel.channelCorps
  local other = {}
  other.  other.  other.  other.time = timeUsed
  local msg = {}
  msg.text = "0"
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.targetShareMsgType
  msg.quickMsg = false
  msg.  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendEvaluationShare(toUid, score, labels, topicId)
  local channel = macro.Channel.channelCorps
  local evaluation = {score = score, label = labels}
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(21233)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.evaluationShareMsgType
  msg.quickMsg = false
  msg.  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendWonderfulReplayShare(toUid, otherInfo, topicId)
  local channel = macro.Channel.channelCorps
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(24668)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.replayShareMsgType
  msg.quickMsg = false
  msg.other = otherInfo
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendPopularGiftPKShare()
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = macro.popularGiftPKMsgType,
    quickMsg = false
  }
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendTeamPKReqSupportShare()
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = macro.teamPKReqSupportMsgType,
    quickMsg = false
  }
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendHomePKReqSupportShare()
  local msg = {
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = macro.homePKReqSupportMsgType,
    quickMsg = false
  }
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.ClearSomesMsg(uid)
  for k = #chatMessageList, 1, -1 do
    if chatMessageList[k].sender_uid == tostring(uid) then
      logic_chat_table_pool.Recycle(chatMessageList[k])
      chatMessageList:RemoveItem(k)
    end
  end
end
function logic_chat_channel_corps.SendChatRoomInvite(roomParam, _)
  local channel = macro.Channel.channelCorps
  local msg = {}
  msg.text = "0"
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.ChatRoomInviteMsgType
  msg.quickMsg = false
  msg.other = roomParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareSuccReq(ShareSceneType.ChatRoomShare, 0, 0, 0)
end
function logic_chat_channel_corps.SendUGCShareInvite(ugcParam, extraParam)
  local channel = macro.Channel.channelCorps
  local msg = {}
  local modName = ugcParam and ugcParam.mod_name or ""
  if not extraParam then
    log(bWriteLog and "logic_chat_channel_corps.SendUGCShareInvite  not extraParam")
    return
  end
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.UGCShareMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendUGCRoomShareInvite(ugcParam, extraParam)
  local channel = macro.Channel.channelCorps
  local msg = {}
  local modName = ugcParam and ugcParam.mod_name or ""
  if not extraParam then
    log(bWriteLog and "logic_chat_channel_corps.SendUGCRoomShareInvite  not extraParam")
    return
  end
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.UGCRoomShareMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendUGCShareCollectionList(ugcParam, extraParam)
  local channel = macro.Channel.channelCorps
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.UGCShareCollectionMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendMilestoneShare(nItemID, extraParam)
  local channel = macro.Channel.channelCorps
  extraParam = extraParam or {}
  local msg = {}
  msg.text = extraParam.msgText
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.MilestoneShare
  msg.quickMsg = false
  msg.other = {itemID = nItemID}
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendHomePartyShareInvite(homePartyParam, extraParam)
  local channel = macro.Channel.channelCorps
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(68158)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.HomePartyInviteMsgType
  msg.quickMsg = false
  msg.other = homePartyParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendWeddingShareInvite(homePartyParam, extraParam)
  local channel = macro.Channel.channelCorps
  local msg = {}
  msg.text = LocUtil.LocalizeResFormat(8075903)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.WeddingInviteMsgType
  msg.quickMsg = false
  msg.other = homePartyParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendProundHornMsg(content)
  log(bWriteLog and "[logic_chat_channel_corps] SendProundHornMsg: " .. tostring(content))
  local msg = {}
  msg.text = content
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.proundHornMsgType
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendSeasonLookbackShare()
  log(bWriteLog and "[logic_chat_channel_corps] SendSeasonLookbackShare")
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(512139)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.seasonLookbackMsgType
  msg.quickMsg = false
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  local max_segment, time = logic_season_lookback:GetSeasonMaxSegmentAndTime()
  local seasonID = logic_season_lookback:GetLookBackSeasonId()
  msg.other = {season_id = seasonID, season_segment = max_segment}
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendManorShare(manorUid)
  log(bWriteLog and "[logic_chat_channel_corps] SendManorShare")
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(64795)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.ManorChatMsgType
  msg.quickMsg = false
  msg.  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, macro.Channel.channelCorps, msgId, msg)
end
function logic_chat_channel_corps.SendWebgameInvite(ludoParam, _)
  local channel = macro.Channel.channelCorps
  local msg = {}
  local eGameType = ludoParam.eGameType
  local LudoConst = require("client.slua.logic.ludo.LudoConst")
  local desc = LudoConst.WebgameInviteTitleAndDesc[eGameType].desc
  msg.text = desc
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.LudoInviteMsgType
  msg.quickMsg = false
  msg.other = ludoParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendMainCityWebgameInvite(webgameParam)
  log(bWriteLog and "logic_chat_channel_corps.SendMainCityWebgameInvite")
  local channel = macro.Channel.channelCorps
  local msg = {}
  local eGameType = webgameParam.eGameType
  local cfg = CDataTable.GetTableData("MainCityH5PlatformCfg", eGameType)
  msg.text = LocUtil.GetLocalizeResStr(cfg.ShareDesc)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.MainCityShareWebGameMsgType
  msg.quickMsg = false
  msg.other = webgameParam
  local msgId = chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendMainCitySeesawInvite(seesawParam, extraParam)
  log(bWriteLog and "logic_chat_channel_corps.SendMainCitySeesawInvite")
  local msg = {
    text = LocUtil.GetLocalizeResStr(73143),
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = macro.MainCitySeesawInviteType,
    quickMsg = false,
    other = seesawParam
  }
  local msgId = chat_main.CacheMsg(msg)
  local channel = macro.Channel.channelCorps
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendMainCityShare(maincityParam, extraParam)
  log(bWriteLog and "logic_chat_channel_corps.SendMainCityShare")
  local msg = {
    text = LocUtil.GetLocalizeResStr(46880011),
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = macro.MainCityShareChatMsgType,
    quickMsg = false,
    other = maincityParam
  }
  local msgId = chat_main.CacheMsg(msg)
  local channel = macro.Channel.channelCorps
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SendPicShare(tSendChatData)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local nMsgId = chat_main.CacheMsg(tSendChatData)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, chat_macro.Channel.channelCorps, nMsgId, tSendChatData)
end
function logic_chat_channel_corps.SendFlashMatchTeamInvite(teamParam, extraParam)
  local teamName = teamParam.name or ""
  local msg = {}
  msg.text = teamName
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = macro.FlashMatchTeamInvite
  msg.quickMsg = false
  msg.other = teamParam
  local msgId = chat_main.CacheMsg(msg)
  local channel = macro.Channel.channelCorps
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_corps.SetChatTalkMessageList(dataList)
  local talkData = {}
  local newsData = {}
  if dataList and next(dataList) then
    for _, value in pairs(dataList) do
      if value.msgType == 0 then
        table.insert(talkData, value)
      else
        table.insert(newsData, value)
      end
    end
  end
  chatTalkMessageList:SetData(talkData)
  chatNewsMessageList:SetData(newsData)
end
function logic_chat_channel_corps.send_corps_chat_message_top_req(op, message_id)
  log(bWriteLog and "logic_chat_channel_corps.send_corps_chat_message_top_req :" .. tostring(op) .. " " .. tostring(message_id))
  if op == 1 and logic_chat_channel_corps.TopMsgNum >= logic_chat_channel_corps.MaxTopMsgNum and not logic_chat_channel_corps.chatTopMessageList[message_id] then
    log(bWriteLog and "logic_chat_channel_corps.send_corps_chat_message_top_req max num")
    local old_msg = logic_chat_channel_corps.TopMsgSortedList[logic_chat_channel_corps.MaxTopMsgNum]
    UIManager.ShowUI(UIManager.UI_Config.Corps_Homepagenew_TopPopupTips_Item_UIBP, message_id, old_msg)
  else
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_corps_chat_message_top_req(op, message_id)
  end
end
function logic_chat_channel_corps.ChangeChatTopMsgList(op, message_id, top_msg_info, old_message_id, from)
  log(bWriteLog and string.format("logic_chat_channel_corps.ChangeChatTopMsgList op:%s msgid:%s oldmsg_id:%s from:%s", tostring(op), tostring(message_id), tostring(old_message_id), tostring(from)))
  log_tree("logic_chat_channel_corps.ChangeChatTopMsgList top_msg_info ", top_msg_info)
  message_id = tonumber(message_id)
  if not message_id then
    log(bWriteLog and "logic_chat_channel_corps.ChangeChatTopMsgList error message_id")
    return
  end
  if (op == 1 or op == 3) and from == 1 then
    logic_chat_channel_corps.TopMsgHighLight = true
    local CanShowTopMsgTip
    CanShowTopMsgTip, logic_chat_channel_corps.newTopMsg = logic_chat_channel_corps.CanShowTopMsgTip()
    if CanShowTopMsgTip then
      local logic_chat_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
      logic_chat_entrance:SetCorpsChatTopMsgNotify(logic_chat_entrance.ENUM_CORP_MSG_TYPE.TOP_CHAT_MSG)
    end
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_CROPS_MSG)
  end
  if #chatTalkMessageList == 0 then
    log(bWriteLog and "logic_chat_channel_corps.ChangeChatTopMsgList no history")
    return
  end
  local AddTopMsg = function(message_id, top_msg_info, from)
    local top_time = tonumber(top_msg_info.top_time)
    if not top_time then
      log(bWriteLog and "logic_chat_channel_corps.ChangeChatTopMsgList error top_time")
      return
    end
    local op_uid = tonumber(top_msg_info.op_uid)
    for _, v in pairs(chatTalkMessageList) do
      if message_id == v.content.corps_msg_id then
        v.        v.        logic_chat_channel_corps.chatTopMessageList[message_id] = v
        return
      end
    end
    log(bWriteLog and "logic_chat_channel_corps.ChangeChatTopMsgList not find msg")
  end
  if op == 1 then
    AddTopMsg(message_id, top_msg_info, from)
  elseif op == 2 then
    logic_chat_channel_corps.chatTopMessageList[message_id] = nil
  elseif op == 3 then
    if old_message_id then
      logic_chat_channel_corps.chatTopMessageList[old_message_id] = nil
    end
    AddTopMsg(message_id, top_msg_info, from)
  end
  logic_chat_channel_corps.SortChatTopMsgList()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TOP_MSG_RSP)
end
function logic_chat_channel_corps.SortChatTopMsgList()
  logic_chat_channel_corps.TopMsgSortedList = {}
  for _, msg in pairs(logic_chat_channel_corps.chatTopMessageList) do
    table.insert(logic_chat_channel_corps.TopMsgSortedList, msg)
  end
  table.sort(logic_chat_channel_corps.TopMsgSortedList, function(a, b)
    if a.top_time == nil or b.top_time == nil then
      return false
    end
    return a.top_time > b.top_time
  end)
  logic_chat_channel_corps.TopMsgNum = #logic_chat_channel_corps.TopMsgSortedList
  return logic_chat_channel_corps.TopMsgSortedList
end
function logic_chat_channel_corps.UpdateChatList(sender_uid, chat_content)
  for k = #chatTalkMessageList, 1, -1 do
    local value = chatTalkMessageList[k]
    if value.sender_uid == tostring(sender_uid) and value.content.sendTime == chat_content.sendTime then
      value.content.corps_msg_id = chat_content.corps_msg_id
      break
    end
  end
end
function logic_chat_channel_corps.GetIndexToRemove(msgList)
  local index = 1
  for k, v in pairs(msgList) do
    if v.msgType ~= 0 then
      return index
    elseif v.content and v.content.corps_msg_id and logic_chat_channel_corps.chatTopMessageList[v.content.corps_msg_id] then
      log(bWriteLog and "logic_chat_channel_corps.GetIndexToRemove do next")
    else
      return index
    end
    index = index + 1
  end
  return index
end
function logic_chat_channel_corps.CanShowTopMsgTip()
  local canShowTip = false
  local canShowRed = false
  local currentTime = TimeUtil.GetServerTimeInSec()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local showCfg = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eCorpsTopMsgShowTimes)
  log_tree("logic_chat_channel_corps.CanShowTopMsgTip in", showCfg)
  if showCfg == nil then
    showCfg = {}
    showCfg.show_tip_times = 1
    showCfg.show_red_times = 1
    showCfg.time_Show = currentTime
    canShowTip = true
    canShowRed = true
    log(bWriteLog and "logic_chat_channel_corps.CanShowTopMsgTip no data")
  elseif showCfg.time_Show and TimeUtil.IsSameDay(showCfg.time_Show, currentTime) then
    log(bWriteLog and "logic_chat_channel_corps.CanShowTopMsgTip is same day")
    if showCfg.show_tip_times < 3 then
      local last_hour = TimeUtil.GetHouseByTotalSec(showCfg.time_Show)
      local now_hour = TimeUtil.GetHouseByTotalSec(currentTime)
      if last_hour and now_hour and 0 < now_hour - last_hour then
        log(bWriteLog and "logic_chat_channel_corps.CanShowTopMsgTip canShowTip")
        showCfg.show_tip_times = showCfg.show_tip_times + 1
        canShowTip = true
        showCfg.time_Show = currentTime
      end
    else
      canShowTip = false
    end
    if showCfg.show_red_times < 5 then
      log(bWriteLog and "logic_chat_channel_corps.CanShowTopMsgTip canShowRed")
      showCfg.show_red_times = showCfg.show_red_times + 1
      canShowRed = true
    else
      canShowRed = false
    end
  else
    log(bWriteLog and "logic_chat_channel_corps.CanShowTopMsgTip is new day")
    canShowTip = true
    canShowRed = true
    showCfg.show_tip_times = 1
    showCfg.show_red_times = 1
    showCfg.time_Show = currentTime
  end
  playerPrefsSystem.SaveTableToFile_N(showCfg, playerPrefsSystem.ePlayerPrefsType.eCorpsTopMsgShowTimes)
  log_tree("logic_chat_channel_corps.CanShowTopMsgTip out", showCfg)
  return canShowTip, canShowRed
end
return logic_chat_channel_corps