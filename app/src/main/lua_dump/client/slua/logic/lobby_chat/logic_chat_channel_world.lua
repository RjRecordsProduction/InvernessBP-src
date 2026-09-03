local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
local super_list = require("common.super_list")
local ChatHandler = require("client.network.Protocol.ChatHandler")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local chat_message_processor = require("client.slua.logic.lobby_chat.chat_message_procesor")
local TimeUtil = require("client.common.time_util")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local isJk = PublishRegionMacros.IsJapanOrKorea()
local logic_chat_channel_world = {
  current_topicId = "",
  array_topic_msg = {},
  topic_channel_array = {},
  topic_redpoint_array = {},
  showSwitchTopicLanguageTimeSpan = 0,
  language_name_list = {},
  language_data_list = {},
  lastFetchLangList = {},
  chatWordOpenLv = 10,
  chatNewbieTopicOpenLv = 3,
  lastArTipsInterval = 172800,
  lastArExchangeInterval = 604800,
  arChatCount = 5,
  MAX_MESSAGE_TOPIC_NUM = 200,
  switchChannelMsgIndex = 0,
  arChatInterval = 259200,
  channel = chat_macro.Channel.channelWorld,
  arabicMinNum = 0,
  arabicMinRatio = 0,
  codeAgreeChangeToArabicChannel = 1,
  codeDisagreeChangeToArabicChannel = 2,
  curTopicType = nil,
  isShareMileJump = false,
  isShareWOWJump = false,
  bIsJumpToReturnTopic = false
}
function logic_chat_channel_world.Init()
end
function logic_chat_channel_world.SetCurTopicId(sTopicId)
  logic_chat_channel_world.current_topicId = sTopicId
end
function logic_chat_channel_world.SetChannelOpenLv(chatWordOpenLv)
  logic_chat_channel_world.chatWordOpenLv = chatWordOpenLv or 10
end
function logic_chat_channel_world.AddNewChat(chatMsg)
  chatMsg.msg = chat_message_processor.GetResultChatMsg(chatMsg.msg)
  if chatMsg.topic == nil then
    chatMsg.topic = "world_Channel"
    if chatMsg.msgChannel == chat_macro.Channel.channelCurrentMainCity then
      chatMsg.topic = chat_macro.TopicCurrentMainCity
    end
  end
  local topicMsgList = logic_chat_channel_world.CheckAndCreateSuperList(chatMsg.topic)
  if chatMsg.msg_id then
    for i = 1, #topicMsgList do
      local msg = topicMsgList[i]
      if msg.msg_id and msg.msg_id == chatMsg.msg_id then
        log(bWriteLog and "logic_chat_channel_world.AddNewChat duplicate msg_id:" .. tostring(chatMsg.msg_id))
        return
      end
    end
  end
  if #topicMsgList >= logic_chat_channel_world.MAX_MESSAGE_TOPIC_NUM then
    logic_chat_table_pool.Recycle(topicMsgList[1])
    topicMsgList:RemoveItem(1)
  end
  topicMsgList:AppendItem(chatMsg)
  if chatMsg and chatMsg.msgChannel == chat_macro.Channel.channelGroupBuy then
    local logic_group_buying_invite = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying_invite)
    logic_group_buying_invite:AddInfoReq({
      chatMsg.content.other.group_id
    })
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_GROUP_BUY_CHANGE)
  end
end
function logic_chat_channel_world.CheckAndCreateSuperList(topic)
  local topicMsgList = logic_chat_channel_world.array_topic_msg[topic]
  if not topicMsgList then
    topicMsgList = super_list.Create()
    logic_chat_channel_world.array_topic_msg[topic] = topicMsgList
  end
  return topicMsgList
end
function logic_chat_channel_world.GetTopicMsgList(topic)
  return logic_chat_channel_world.array_topic_msg[topic]
end
function logic_chat_channel_world.ClearTopicMsgList(topic)
  log(bWriteLog and "logic_chat_channel_world.ClearTopicMsgList topic" .. tostring(topic))
  local topicMsgList = super_list.Create()
  logic_chat_channel_world.array_topic_msg[topic] = topicMsgList
end
function logic_chat_channel_world.SendMsg(content, explicitMsgType)
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccessAndPopTips(logic_access_restriction.EAccessType.WorldChat) then
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "send msg has no right to chat")
    return
  end
  if logic_chat_channel_world.current_topicId == chat_macro.TopicLbsPredefinedChannel then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    if not LbsMgr.IsMyLbsModuleZoneReady(LbsMgr.SETTING_CFG_CHAT_ID) then
      ShowNotice(LocUtil.GetLocalizeResStr(25142))
      return
    end
  end
  local bIsMainCity
  if logic_chat_channel_world.current_topicId then
    bIsMainCity = string.find(logic_chat_channel_world.current_topicId, chat_macro.TopicCurrentMainCity) or string.find(logic_chat_channel_world.current_topicId, chat_macro.TopicGlobalMainCity)
  end
  if bIsMainCity then
    local chatInterval = 2
    local currentTime = TimeUtil.GetServerTimeInSec() or 0
    logic_chat_channel_world.lastSendMC = logic_chat_channel_world.lastSendMC or 0
    logic_chat_channel_world.lastSendMC = math.min(currentTime, logic_chat_channel_world.lastSendMC)
    if logic_chat_channel_world.lastSendMC and chatInterval > currentTime - logic_chat_channel_world.lastSendMC then
      local msgContent = string.format(LocUtil.GetLocalizeResStr(100007), math.min(2, chatInterval + logic_chat_channel_world.lastSendMC - currentTime))
      ShowNotice(msgContent)
      return
    end
    logic_chat_channel_world.lastSendMC = currentTime
  end
  local msg = {}
  msg.text = content
  msg.topic = logic_chat_channel_world.current_topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = explicitMsgType or 0
  msg.quickMsg = false
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.ArTopicTipsGuide(msgId, msg)
end
function logic_chat_channel_world.SendVoiceMsg(voiceId, length, content)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "send msg has no right to chat")
    return
  end
  if nil == voiceId or "" == voiceId then
    return
  end
  log(bWriteLog and "god test SendVoiceMsg")
  log_tree("god test SendVoiceMsg", {
    id = voiceId,
    len = length,
    con = content
  })
  local tabContent = {}
  tabContent.voice = voiceId
  tabContent.text = content
  tabContent.voiceLength = length
  tabContent.quickMsg = false
  tabContent.msgType = chat_macro.VoiceChatMsgType
  tabContent.topic = logic_chat_channel_world.current_topicId
  local msgId = chat_main.CacheMsg(tabContent)
  local channel = logic_chat_channel_world.GetChannelType(chat_macro.Channel.channelWorld, tabContent.topic)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, tabContent)
end
function logic_chat_channel_world.SendAchivementShare(achievementShareId, finishTime)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "send msg has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local content = LocUtil.GetLocalizeResStr("5027")
  local other = {}
  other.achievementId = achievementShareId
  other.finish_time = finishTime
  local msg = {}
  msg.text = content
  msg.topic = logic_chat_channel_world.current_topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.achivementMsgType
  msg.quickMsg = false
  msg.  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.GetChannelType(channelType, topicID)
  if logic_chat_channel_world.IsWorldCupTopic(topicID) then
    return chat_macro.Channel.channelWorldCup
  end
  if topicID == chat_macro.TopicWorldChannel or #logic_chat_channel_world.topic_channel_array < 1 then
    return channelType
  end
  if string.find(topicID, chat_macro.TopicCurrentMainCity) then
    return chat_macro.Channel.channelCurrentMainCity
  elseif string.find(topicID, chat_macro.TopicGlobalMainCity) then
    return chat_macro.Channel.channelGlobalMainCity
  end
  local currentTopicLangId = logic_chat_channel_world.topic_channel_array[1].lang_id
  local topicType
  for i, v in ipairs(logic_chat_channel_world.topic_channel_array) do
    if v.id == topicID then
      currentTopicLangId = v.lang_id
      topicType = v.type
      break
    end
  end
  if logic_chat_channel_world.lastFetchLangList ~= nil and 1 <= #logic_chat_channel_world.lastFetchLangList and logic_chat_channel_world.lastFetchLangList[1] == currentTopicLangId then
    return chat_macro.channelTopic, currentTopicLangId
  elseif topicType == chat_macro.TopicRegionType then
    return chat_macro.Channel.channelLBS
  elseif topicType == chat_macro.TopicSameAgeType then
    return chat_macro.Channel.channelSameAge
  elseif topicType == chat_macro.TopicUGCType then
    return chat_macro.Channel.channelUGC
  elseif topicType == chat_macro.TopicExchangeGiftType then
    return chat_macro.Channel.channelExchangeGift
  elseif topicType == chat_macro.TopicReturnType then
    return chat_macro.Channel.channelReturn
  elseif topicType == chat_macro.TopicNewbieType then
    return chat_macro.Channel.channelNewbie
  elseif topicType == chat_macro.TopicGroupBuyType then
    return chat_macro.Channel.channelGroupBuy
  else
    return chat_macro.channelTopic2, currentTopicLangId
  end
end
function logic_chat_channel_world.topic_fetch_lang_list_req(source)
  if logic_chat_channel_world.language_name_list == nil or next(logic_chat_channel_world.language_name_list) == nil then
    ChatHandler.send_topic_fetch_lang_list_req(source)
  else
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_FETCH_LANGUAGE_LIST, source)
  end
end
function logic_chat_channel_world.get_topic_list(force)
  if force or DataMgr.FirstSecondLanguage ~= nil and logic_chat_channel_world.lastFetchLangList ~= DataMgr.FirstSecondLanguage then
    ChatHandler.send_topic_flat_list_req(DataMgr.FirstSecondLanguage)
    logic_chat_channel_world.lastFetchLangList = DataMgr.FirstSecondLanguage
  else
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_FETCH_TOPIC_CHANNEL)
  end
end
function logic_chat_channel_world.topic_fetch_lang_list_rsp(list, timeSpan, source)
  logic_chat_channel_world.showSwitchTopicLanguageTimeSpan = timeSpan
  if type(list) == "table" then
    for k, v in pairs(list) do
      v.id = k
    end
    table.sort(list, function(a, b)
      return a.id < b.id
    end)
    logic_chat_channel_world.language_name_list = {}
    logic_chat_channel_world.language_data_list = {}
    for k, v in pairs(list) do
      local item = {
        id = k,
        name = v.lang,
        langName = v.lang_name
      }
      table.insert(logic_chat_channel_world.language_data_list, item)
      table.insert(logic_chat_channel_world.language_name_list, v.lang_name)
    end
    logic_chat_channel_world.TopicLanguageListReady()
    local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
    LanguageSelectSystem.UpdateFirstMatchLanguageName()
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_FETCH_LANGUAGE_LIST, source)
    local TranslateMgr = require("client.slua.logic.translator.translate_mgr")
    TranslateMgr.CheckContinueTranslate()
    local LogicUGCTrans = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTrans)
    LogicUGCTrans:CheckContinueTranslate()
  end
end
function logic_chat_channel_world.TopicLanguageListReady()
end
function logic_chat_channel_world.topic_flat_list_rsp(msg, list)
  log_tree("god test list", list)
  local logic_main_city_chat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_chat)
  list = logic_main_city_chat:ProcessChatListMC(list)
  local oldSelectIndex, newSelectTopicId, isOldSelectLbsTopic
  for index, item in ipairs(logic_chat_channel_world.topic_channel_array) do
    if item.id == logic_chat_channel_world.current_topicId then
      oldSelectIndex = index
      isOldSelectLbsTopic = item.type == chat_macro.TopicRegionType
      break
    end
  end
  logic_chat_channel_world.topic_channel_array = {}
  logic_chat_channel_world.topic_redpoint_array = {}
  if msg == NetErrorCode_NONE then
    if type(list) == "table" then
      local lbsTopicID, exchangeGiftTopicID
      for k, v in pairs(list) do
        local item = {
          id = v.id,
          name = v.name,
          lang_id = v.lang_id,
          type = v.type,
          first_lang_flag = v.first_lang_flag
        }
        table.insert(logic_chat_channel_world.topic_channel_array, item)
        local redPointItem = {}
        redPointItem.topicId = v.id
        redPointItem.num = 0
        table.insert(logic_chat_channel_world.topic_redpoint_array, redPointItem)
        if item.type == chat_macro.TopicRegionType then
          lbsTopicID = item.id
        elseif item.type == chat_macro.TopicExchangeGiftType then
          exchangeGiftTopicID = item.id
        end
      end
      if logic_chat_channel_world.current_topicId == chat_macro.TopicLbsPredefinedChannel and lbsTopicID then
        newSelectTopicId = lbsTopicID
      elseif logic_chat_channel_world.current_topicId == chat_macro.TopicExchangeGift and exchangeGiftTopicID then
        newSelectTopicId = exchangeGiftTopicID
      elseif logic_chat_channel_world.current_topicId == chat_macro.PlannerChatTopic then
        newSelectTopicId = chat_macro.PlannerChatTopic
      end
      if not newSelectTopicId then
        if oldSelectIndex then
          local newItem = logic_chat_channel_world.topic_channel_array[oldSelectIndex]
          if newItem then
            newSelectTopicId = newItem.id
          elseif next(logic_chat_channel_world.topic_channel_array) then
            newSelectTopicId = logic_chat_channel_world.topic_channel_array[1].id
          elseif isOldSelectLbsTopic then
            if next(logic_chat_channel_world.topic_channel_array) ~= nil then
              local _, firstTopic = next(logic_chat_channel_world.topic_channel_array)
              newSelectTopicId = firstTopic.id
            else
              newSelectTopicId = "world_Channel"
            end
          end
        else
          newSelectTopicId = logic_chat_channel_world.GetDefaultTopicId()
        end
      end
      logic_chat_channel_world.TopicListIsReady(newSelectTopicId)
    else
      logic_chat_channel_world.TopicListIsReady()
    end
  else
    logic_chat_channel_world.TopicListIsReady()
  end
end
function logic_chat_channel_world.GetDefaultTopicId()
  local defaultTopicId
  if logic_chat_channel_world.current_topicId == "world_Channel" then
    defaultTopicId = "world_Channel"
  else
    local topic_array = logic_chat_channel_world.topic_channel_array
    for k, v in pairs(topic_array) do
      if v.type == chat_macro.TopicRegionType then
        defaultTopicId = v.id
        break
      end
    end
    if not defaultTopicId then
      if 0 < #topic_array then
        defaultTopicId = topic_array[1].id
      else
        defaultTopicId = "world_Channel"
      end
    end
  end
  return defaultTopicId
end
function logic_chat_channel_world.TopicListIsReady(newSelectTopicId)
  if newSelectTopicId then
    log(bWriteLog and "logic_chat_channel_world.TopicListIsReady newSelectTopicId:" .. tostring(newSelectTopicId))
    logic_chat_channel_world.current_topicId = newSelectTopicId
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_FETCH_TOPIC_CHANNEL)
  else
    log(bWriteLog and "logic_chat_channel_world.TopicListIsReady no newSelectTopicId")
  end
end
function logic_chat_channel_world.CheckSubscribeChannel(topicId)
  logic_chat_channel_world.current_  if not logic_chat_channel_world.IsNeedSubscribeChannel(topicId) then
    return false
  end
  ChatHandler.send_topic_subscribe_req(topicId)
  return true
end
function logic_chat_channel_world.IsNeedSubscribeChannel(topicId)
  if not topicId or topicId == "" then
    return false
  end
  if topicId == "world_Channel" or topicId == chat_macro.TopicLbsPredefinedChannel then
    return false
  end
  if topicId == "current_maincity" then
    return false
  end
  if topicId == chat_macro.PlannerChatTopic then
    return false
  end
  return true
end
function logic_chat_channel_world.UnsubscribeChannel()
  if logic_chat_channel_world.current_topicId == "world_Channel" or LobbySystem.CheckOpen(BP_ENUM_UN_SUBSCRIBE_CHANNEL_SWITCH) then
  end
end
function logic_chat_channel_world.topic_subscribe_rsp(tid, msg)
  if msg == NetErrorCode_NONE then
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_SUBCRIBE_TOPIC_CHANNEL_SUCCESS, tid and tid.name)
  else
    ShowNotice(4724)
  end
end
function logic_chat_channel_world.topic_unsubscribe_rsp(tid, msg)
  if msg == NetErrorCode_NONE then
  else
  end
end
function logic_chat_channel_world.CheckIsFilterArCondition(text)
  if not text then
    return
  end
  text = tostring(text)
  local limitCharNum = logic_chat_channel_world.arabicMinNum
  local percentNum = logic_chat_channel_world.arabicMinRatio
  local StringUtil = require("common.string_util")
  local _, len = StringUtil.CheckName(text, false, nil, true)
  local _, count = string.gsub(text, "[\216-\219][\128-\191]", "")
  return limitCharNum <= len and percentNum <= count / len
end
function logic_chat_channel_world.PopArTipsEveryTime(msgId, channelType, msg)
  local title = LocUtil.GetLocalizeResStr(101001)
  local tips = LocUtil.GetLocalizeResStr(23581)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tips, function()
    local firstLanguage = DataMgr.FirstSecondLanguage[1]
    msg.switchStatus = logic_chat_channel_world.codeAgreeChangeToArabicChannel
    if firstLanguage ~= 101 then
      local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
      LanguageSelectSystem.ChatLanguageSelectReq(101, firstLanguage)
      local secondMatchLanguage = DataMgr.MatchLanguage[1]
      if secondMatchLanguage == 101 then
        secondMatchLanguage = nil
      end
      channelType = chat_macro.channelTopic
      LanguageSelectSystem.MatchLanguageSelectReq(101, secondMatchLanguage)
      logic_chat_channel_world.ChangeToArChannel(channelType, msgId, msg)
    else
      local currentTopicId
      for i, v in ipairs(logic_chat_channel_world.topic_channel_array) do
        if v.lang_id == 101 then
          currentTopicId = v.id
          break
        end
      end
      log(bWriteLog and "[wuling] PopArTipsEveryTime currentTopicId = " .. tostring(currentTopicId))
      if currentTopicId ~= nil then
        channelType = chat_macro.channelTopic
        msg.topic = currentTopicId
        logic_chat_channel_world.current_topicId = currentTopicId
        EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CHANGE_SELECT_TAB)
      end
      logic_chat_channel_world.SendChatReq(0, channelType, msgId, msg)
    end
  end, function()
    msg.switchStatus = logic_chat_channel_world.codeDisagreeChangeToArabicChannel
    logic_chat_channel_world.SendChatReq(0, channelType, msgId, msg)
  end)
end
function logic_chat_channel_world.CheckPopArTopicTips(content)
  if not LobbySystem.CheckOpen(BP_ENUM_POP_AR_TOPIC_TIPS_OPEN) then
    return false
  end
  local StringUtil = require("common.string_util")
  if not StringUtil.HasArChar(content) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eArCheckStatus)
  saveData = saveData or {}
  saveData.lastTipsTime = saveData.lastTipsTime or TimeUtil.GetServerTimeInSec()
  saveData.lastExchangeTime = saveData.lastExchangeTime or TimeUtil.GetServerTimeInSec()
  saveData.arChatHistory = saveData.arChatHistory or {}
  table.insert(saveData.arChatHistory, 1, TimeUtil.GetServerTimeInSec())
  if #saveData.arChatHistory >= 10 then
    table.remove(saveData.arChatHistory)
  end
  local HasUpdate
  local Interval = TimeUtil.GetServerTimeInSec() - saveData.lastTipsTime
  if Interval < 0 then
    saveData.lastTipsTime = TimeUtil.GetServerTimeInSec()
    saveData.lastExchangeTime = TimeUtil.GetServerTimeInSec()
    saveData.arChatHistory = {}
    HasUpdate = true
  end
  local ShowPopTips = false
  if Interval >= logic_chat_channel_world.lastArTipsInterval then
    ShowPopTips = true
    saveData.lastTipsTime = TimeUtil.GetServerTimeInSec()
    HasUpdate = true
  end
  if HasUpdate or #saveData.arChatHistory <= logic_chat_channel_world.arChatCount then
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eArCheckStatus)
  end
  return ShowPopTips
end
function logic_chat_channel_world.PopArTopicTips(msgId, channelType, msg)
  local msg_title = LocUtil.GetLocalizeResStr(101001)
  local msg_content = LocUtil.GetLocalizeResStr(8030)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, msg_title, msg_content, function()
    local secLan = DataMgr.FirstSecondLanguage[2]
    if secLan == 101 then
      secLan = nil
    end
    local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
    LanguageSelectSystem.ChatLanguageSelectReq(101, secLan)
    secLan = DataMgr.MatchLanguage[2]
    if secLan == 101 then
      secLan = nil
    end
    LanguageSelectSystem.MatchLanguageSelectReq(101, secLan)
    logic_chat_channel_world.ChangeToArChannel(channelType, msgId, msg)
  end, function()
    logic_chat_channel_world.SendChatReq(0, channelType, msgId, msg)
  end)
end
function logic_chat_channel_world.ChangeToArChannel(channelType, msgId, msg)
  local time_ticker = require("common.time_ticker")
  local checkTime = 0
  time_ticker.AddTimer(0.5, function()
    repeat
      checkTime = checkTime + 1
      local hasGetArTopic = false
      for i, v in ipairs(logic_chat_channel_world.topic_channel_array) do
        if v.lang_id == 101 then
          hasGetArTopic = true
          msg.topic = v.id
          logic_chat_channel_world.current_topicId = v.id
          break
        end
      end
      coroutine.yield(0.5)
    until hasGetArTopic or 4 <= checkTime
    if logic_chat_channel_world.curTopicType == chat_macro.TopicRegionType then
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CHANGE_SELECT_TAB)
    end
    logic_chat_channel_world.SendChatReq(0, channelType, msgId, msg)
  end)
end
function logic_chat_channel_world.GetDefaultChannel()
  log_tree(bWriteLog and "logic_chat_channel_world.GetDefaultChannel topic_channel_array:", logic_chat_channel_world.topic_channel_array)
  local region_topic_id
  for i = 1, #logic_chat_channel_world.topic_channel_array do
    local channel = logic_chat_channel_world.topic_channel_array[i]
    if channel.type == chat_macro.TopicRegionType then
      if not region_topic_id then
        region_topic_id = channel.id
      end
    elseif not logic_chat_channel_world.IsWorldCupTopic(channel.id) then
      return channel.id
    end
  end
  return region_topic_id
end
function logic_chat_channel_world.GetTwoLanguageTopicID()
  log_tree(bWriteLog and "logic_chat_channel_world.GetTwoLanguageTopicID topic_channel_array:", logic_chat_channel_world.topic_channel_array)
  local topicID1, topicID2
  for i = 1, #logic_chat_channel_world.topic_channel_array do
    local channel = logic_chat_channel_world.topic_channel_array[i]
    if channel.type == chat_macro.TopicNormalTyoe and channel.lang_id ~= nil then
      if not topicID1 and channel.first_lang_flag == 1 then
        topicID1 = channel.id
      elseif not topicID2 and channel.first_lang_flag == nil then
        topicID2 = channel.id
      end
    end
  end
  log(bWriteLog and "logic_chat_channel_world.GetTwoLanguageTopicID return topicID1 = " .. tostring(topicID1) .. ", topicID2 = " .. tostring(topicID2))
  return topicID1, topicID2
end
function logic_chat_channel_world.GetChannelTypeById(topicId)
  if not topicId then
    return
  end
  for _, channelInfo in ipairs(logic_chat_channel_world.topic_channel_array) do
    if channelInfo.id == topicId then
      return channelInfo.type
    end
  end
  return nil
end
function logic_chat_channel_world.GetChannelByTopicType(type)
  if not type then
    return
  end
  for _, channelInfo in ipairs(logic_chat_channel_world.topic_channel_array) do
    if channelInfo.type == type then
      return channelInfo.id
    end
  end
  return nil
end
function logic_chat_channel_world.CheckAutoExchangeArTopic()
  log(bWriteLog and "god test CheckAutoExchangeArTopic")
  if not LobbySystem.CheckOpen(BP_ENUM_AUTO_EXCHANGE_AR_TOPIC_OPEN) then
    return
  end
  if DataMgr.FirstSecondLanguage[1] == 101 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eArCheckStatus)
  saveData = saveData or {}
  saveData.lastExchangeTime = saveData.lastExchangeTime or TimeUtil.GetServerTimeInSec()
  saveData.arChatHistory = saveData.arChatHistory or {}
  local arChatCount = 0
  for i, time in ipairs(saveData.arChatHistory) do
    if TimeUtil.GetServerTimeInSec() - time <= logic_chat_channel_world.arChatInterval then
      arChatCount = arChatCount + 1
    end
  end
  if arChatCount < logic_chat_channel_world.arChatCount then
    return
  end
  local interval = TimeUtil.GetServerTimeInSec() - saveData.lastExchangeTime
  if interval >= logic_chat_channel_world.lastArExchangeInterval then
    local msg_title = LocUtil.GetLocalizeResStr(101001)
    local msg_content = LocUtil.GetLocalizeResStr(8030)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, msg_title, msg_content, function()
      local secLan = DataMgr.FirstSecondLanguage[2]
      if secLan == 101 then
        secLan = nil
      end
      local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
      LanguageSelectSystem.ChatLanguageSelectReq(101, DataMgr.FirstSecondLanguage[2])
      secLan = DataMgr.MatchLanguage[2]
      if secLan == 101 then
        secLan = nil
      end
      LanguageSelectSystem.MatchLanguageSelectReq(101, secLan)
    end)
    saveData.lastExchangeTime = TimeUtil.GetServerTimeInSec()
    saveData.arChatHistory = {}
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eArCheckStatus)
  end
end
function logic_chat_channel_world.CheckHasRightToChat()
  local worldOpenLvStr = logic_chat_channel_world.chatWordOpenLv
  local worldOpenLv = worldOpenLvStr == nil and 0 or tonumber(worldOpenLvStr)
  if chat_main.currentChannel == chat_macro.Channel.channelWorld then
    local satisfyLevel = worldOpenLv <= DataMgr.roleData.level
    local bIsNew = DataMgr.IsRecruit()
    local LogicChannelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
    local topic_type = LogicChannelWorld.curTopicType
    local bIsNewbieTopic = topic_type == chat_macro.TopicNewbieType
    if bIsNew and bIsNewbieTopic then
      satisfyLevel = DataMgr.roleData.level >= LogicChannelWorld.chatNewbieTopicOpenLv
    end
    if not satisfyLevel then
      local tips = LocUtil.LocalizeResFormat(106017, worldOpenLv)
      ShowNotice(tips)
      return false
    end
  end
  return true
end
function logic_chat_channel_world.GetTopicChangeTips()
  local roomName = ""
  local defaultName = {}
  defaultName.world_Channel = LocUtil.GetLocalizeResStr("4736")
  defaultName.current_maincity = LocUtil.GetLocalizeResStr(46880113)
  defaultName.global_maincity = LocUtil.GetLocalizeResStr(46880012)
  if defaultName[logic_chat_channel_world.current_topicId] then
    roomName = defaultName[logic_chat_channel_world.current_topicId]
  else
    for k, v in pairs(logic_chat_channel_world.topic_channel_array) do
      if v.id == logic_chat_channel_world.current_topicId then
        roomName = v.name
        break
      end
    end
  end
  return string.format(LocUtil.GetLocalizeResStr("5030"), "#" .. roomName)
end
function logic_chat_channel_world.GetMessageList(chatMsg)
  local msgList = logic_chat_channel_world.array_topic_msg[chatMsg.topic]
  return msgList
end
function logic_chat_channel_world.GetSelectPlayerList()
  return {}
end
function logic_chat_channel_world.ClearData()
  for _, v in pairs(logic_chat_channel_world.array_topic_msg) do
    logic_chat_table_pool.RecycleAll(v)
  end
  logic_chat_channel_world.array_topic_msg = {}
  logic_chat_channel_world.topic_channel_array = {}
  logic_chat_channel_world.topic_redpoint_array = {}
  logic_chat_channel_world.lastFetchLangList = {}
  logic_chat_channel_world.switchChannelMsgIndex = 0
  log(bWriteLog and "god test world channel Clear")
end
function logic_chat_channel_world.SendIslandTargetShare(toUid, ownerUid, score, timeStamp, timeUsed, topicId)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    printf("logic_chat_channel_world.SendIslandTargetShare has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local other = {}
  other.  other.  other.  other.time = timeUsed
  local msg = {}
  msg.text = "0"
  msg.topic = topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.targetShareMsgType
  msg.quickMsg = false
  msg.  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendEvaluationShare(toUid, score, labels, topicId)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendEvaluationShare has no right to chat")
    return
  end
  if logic_chat_channel_world.IsWorldCupTopic(topicId) then
    log(bWriteLog and "SendEvaluationShare cannot send to world cup")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local evaluation = {score = score, label = labels}
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(21233)
  msg.topic = topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.evaluationShareMsgType
  msg.quickMsg = false
  msg.  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendWonderfulReplayShare(toUid, otherInfo, topicId)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendWonderfulReplayShare has no right to chat")
    return
  end
  if logic_chat_channel_world.IsWorldCupTopic(topicId) then
    log(bWriteLog and "SendWonderfulReplayShare cannot send to world cup")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(24668)
  msg.topic = topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.replayShareMsgType
  msg.quickMsg = false
  msg.other = otherInfo
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendPopularGiftPKShare(toUid, topicId)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendPopularGiftPKShare has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {
    topic = topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.popularGiftPKMsgType,
    quickMsg = false
  }
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendTeamPKInviteFriendShare(toUid, topicId, curTeamNum, totalTeamNum)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendTeamPKInviteFriendShare has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {
    topic = topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.teamPKInviteFrdMsgType,
    quickMsg = false,
    curTeamNum = curTeamNum,
      }
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendTeamPKReqSupportShare(toUid, topicId)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendTeamPKReqSupportShare has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {
    topic = topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.teamPKReqSupportMsgType,
    quickMsg = false
  }
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendHomePKReqSupportShare(toUid, topicId)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendHomePKReqSupportShare has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {
    topic = topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.homePKReqSupportMsgType,
    quickMsg = false
  }
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendXSuitGiftMsg(msgData)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendXSuitGiftMsg has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {
    topic = logic_chat_channel_world.current_topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.XSuitGiftMsgType,
    other = msgData
  }
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendBestPartnerShare(topicId, curNum, totalNum)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendBestPartnerShare has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {
    topic = topicId,
    text = LocUtil.GetLocalizeResStr(46156),
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.bestPartnerMsgType,
    quickMsg = false,
    curNum = curNum,
      }
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendSocialCardMsg(bSendRecord)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "SendSocialCardMsg has no right to chat")
    return
  end
  if logic_chat_channel_world.current_topicId == chat_macro.TopicLbsPredefinedChannel then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    if not LbsMgr.IsMyLbsModuleZoneReady(LbsMgr.SETTING_CFG_CHAT_ID) then
      ShowNotice(LocUtil.GetLocalizeResStr(25142))
      return
    end
  end
  local msg = {}
  msg.msgType = chat_macro.roleinfoSocialCard
  msg.text = LocUtil.GetLocalizeResStr(45916)
  msg.topic = logic_chat_channel_world.current_topicId
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  msg.social_card = SocialCardSystem.GetShareCardData(bSendRecord)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.ArTopicTipsGuide(msgId, msg)
end
function logic_chat_channel_world.SendCropsCardMsg(msg)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "SendCropsCardMsg has no right to chat")
    return
  end
  if logic_chat_channel_world.current_topicId == chat_macro.TopicLbsPredefinedChannel then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    if not LbsMgr.IsMyLbsModuleZoneReady(LbsMgr.SETTING_CFG_CHAT_ID) then
      ShowNotice(LocUtil.GetLocalizeResStr(25142))
      return
    end
  end
  msg.text = ""
  msg.topic = logic_chat_channel_world.current_topicId
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.ArTopicTipsGuide(msgId, msg)
end
function logic_chat_channel_world.SendRedpacketMsg(st, explicit_topic_id)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "SendRedpacketMsg has no right to chat")
    return
  end
  local topicId = explicit_topic_id or logic_chat_channel_world.current_topicId
  if topicId == chat_macro.TopicLbsPredefinedChannel then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    if not LbsMgr.IsMyLbsModuleZoneReady(LbsMgr.SETTING_CFG_CHAT_ID) then
      ShowNotice(LocUtil.GetLocalizeResStr(25142))
      return
    end
  end
  local isOpen = require("client.slua.logic.crp.ChatRedpacketUtils").IsOpen()
  if not isOpen then
    return
  end
  local msg = {}
  msg.msgType = chat_macro.redpacket
  msg.text = st.basic_info.message
  msg.topic = topicId
  local utils = require("client.slua.logic.crp.ChatRedpacketUtils")
  msg.redpacket = utils.GetChatMsgStruct(st)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.ArTopicTipsGuide(msgId, msg)
end
function logic_chat_channel_world.SendHornMsg(content)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "SendHornMsg has no right to chat")
    return
  end
  if logic_chat_channel_world.current_topicId == chat_macro.TopicLbsPredefinedChannel then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    if not LbsMgr.IsMyLbsModuleZoneReady(LbsMgr.SETTING_CFG_CHAT_ID) then
      ShowNotice(LocUtil.GetLocalizeResStr(25142))
      return
    end
  end
  local msg = logic_chat_channel_world.SetHornMsg(content, logic_chat_channel_world.current_topicId)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.ArTopicTipsGuide(msgId, msg, true)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.HornConsume, nil, "")
end
function logic_chat_channel_world.SendProundHornMsg(content)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "SendProundHornMsg has no right to chat")
    return
  end
  if logic_chat_channel_world.current_topicId == chat_macro.TopicLbsPredefinedChannel then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    if not LbsMgr.IsMyLbsModuleZoneReady(LbsMgr.SETTING_CFG_CHAT_ID) then
      ShowNotice(LocUtil.GetLocalizeResStr(25142))
      return
    end
  end
  if logic_chat_channel_world.IsWorldCupTopic(logic_chat_channel_world.current_topicId) then
    log(bWriteLog and "SendProundHornMsg cannot send to world cup")
    return
  end
  local msg = logic_chat_channel_world.SetProundHornMsg(content, logic_chat_channel_world.current_topicId)
  local msgId = chat_main.CacheMsg(msg)
  msg.text = tostring(msg.text)
  logic_chat_channel_world.ArTopicTipsGuide(msgId, msg, true)
end
function logic_chat_channel_world.SetProundHornMsg(content, topic)
  local msg = {}
  msg.text = content
  msg.  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.proundHornMsgType
  return msg
end
function logic_chat_channel_world.ArTopicTipsGuide(msgId, msg, isHornMsg)
  local channelType = chat_macro.Channel.channelWorld
  local lang_id
  channelType, lang_id = logic_chat_channel_world.GetChannelType(channelType, logic_chat_channel_world.current_topicId)
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if region == PublishRegionMacros.BLUEHOLE then
    logic_chat_channel_world.SendChatReq(0, channelType, msgId, msg)
    return
  end
  if lang_id ~= 101 and (chat_macro.channelTopic == channelType or chat_macro.channelTopic2 == channelType) and not isHornMsg and logic_chat_channel_world.CheckIsFilterArCondition(msg.text) then
    logic_chat_channel_world.PopArTipsEveryTime(msgId, channelType, msg)
    return
  end
  if chat_macro.channelTopic == channelType and lang_id ~= 101 and logic_chat_channel_world.CheckPopArTopicTips(msg.text) then
    logic_chat_channel_world.PopArTopicTips(msgId, channelType, msg)
    return
  end
  if channelType == chat_macro.Channel.channelLBS then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    if LbsMgr.CheckAeguild() and logic_chat_channel_world.CheckIsFilterArCondition(msg.text) then
      logic_chat_channel_world.PopArTipsEveryTime(msgId, channelType, msg)
      return
    end
  end
  logic_chat_channel_world.SendChatReq(0, channelType, msgId, msg)
end
function logic_chat_channel_world.ClearSomesMsg(uid)
  for _, msgList in pairs(logic_chat_channel_world.array_topic_msg) do
    for k = #msgList, 1, -1 do
      if msgList[k].sender_uid == tostring(uid) then
        logic_chat_table_pool.Recycle(msgList[k])
        msgList:RemoveItem(k)
      end
    end
  end
end
function logic_chat_channel_world.SetHornMsg(content, topic)
  local msg = {}
  msg.text = content
  msg.  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.hornMsgType
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemInfo = wardrobe_data:GetHallDepotItemDataByResID(ChatHornItemId)
  if itemInfo then
    msg.horn_instid = tonumber(itemInfo.insID)
  end
  return msg
end
function logic_chat_channel_world.SendHornMsgByTopic(content, topic)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "SendHornMsg has no right to chat")
    return
  end
  local msg = logic_chat_channel_world.SetHornMsg(content, topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, chat_macro.Channel.channelWorld, msgId, msg)
end
function logic_chat_channel_world.SetArabicCfgData(arabic_chat_cfg)
  if not arabic_chat_cfg then
    return
  end
  logic_chat_channel_world.arabicMinNum = arabic_chat_cfg.min_num or 0
  logic_chat_channel_world.arabicMinRatio = arabic_chat_cfg.min_ratio or 0
end
function logic_chat_channel_world.SendChatRoomInvite(roomParam, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendChatRoomInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendChatRoomInvite has no right to chat")
    return
  end
  if logic_chat_channel_world.IsWorldCupTopic(extraParam.topicId) then
    log(bWriteLog and "logic_chat_channel_world.SendChatRoomInvite cannot send to world cup")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  msg.text = "0"
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.ChatRoomInviteMsgType
  msg.quickMsg = false
  msg.other = roomParam
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
  local ShareMgr = require("client.logic.share.share_logic")
  ShareMgr.ShareSuccReq(ShareSceneType.ChatRoomShare, 0, 0, 0)
end
function logic_chat_channel_world.IsWorldCupTopic(topicID)
  return false
end
function logic_chat_channel_world.SendUGCShareInvite(ugcParam, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite has no right to chat")
    return
  end
  local msg = {}
  msg.text = extraParam.msgText
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.UGCShareMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  local channel = chat_macro.Channel.channelUGC
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite region == PublishRegionMacros.BLUEHOLE")
    msg.topic = chat_macro.TopicWorldChannel
    channel = chat_macro.Channel.channelWorld
  end
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendUGCRoomShareInvite(ugcParam, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendUGCRoomShareInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendUGCRoomShareInvite has no right to chat")
    return
  end
  local msg = {}
  msg.text = extraParam.msgText
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.UGCRoomShareMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  local channel = chat_macro.Channel.channelUGC
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and "logic_chat_channel_world.SendUGCRoomShareInvite region == PublishRegionMacros.BLUEHOLE")
    msg.topic = chat_macro.TopicWorldChannel
    channel = chat_macro.Channel.channelWorld
  end
  local msgId = chat_main.CacheMsg(msg)
  ChatHandler.send_chat_req(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendMilestoneShare(nItemID, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendMilestoneShare wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendMilestoneShare has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  msg.text = extraParam.msgText
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.MilestoneShare
  msg.quickMsg = false
  msg.other = {itemID = nItemID}
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendUGCShareCollectionList(ugcParam, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  msg.text = extraParam.msgText
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.UGCShareCollectionMsgType
  msg.quickMsg = false
  msg.other = ugcParam
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local region = Client.GetPublishRegion()
  if region == PublishRegionMacros.BLUEHOLE then
    msg.topic = chat_macro.TopicWorldChannel
    channel = chat_macro.Channel.channelWorld
  end
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendHomePartyShareInvite(homePartyParam, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendUGCShareInvite has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(68158)
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.HomePartyInviteMsgType
  msg.quickMsg = false
  msg.other = homePartyParam
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendWeddingShareInvite(homePartyParam, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendWeddingShareInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendWeddingShareInvite has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  msg.text = LocUtil.LocalizeResFormat(8075903)
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.WeddingInviteMsgType
  msg.quickMsg = false
  msg.other = homePartyParam
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendSeasonLookbackShare()
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendSeasonLookbackShare has no right to chat")
    return
  end
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(512139)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.seasonLookbackMsgType
  msg.quickMsg = false
  msg.topic = chat_macro.TopicWorldChannel
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  local max_segment, time = logic_season_lookback:GetSeasonMaxSegmentAndTime()
  local seasonID = logic_season_lookback:GetLookBackSeasonId()
  msg.other = {season_id = seasonID, season_segment = max_segment}
  local channel = logic_chat_channel_world.GetChannelType(chat_macro.Channel.channelWorld, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendExchangeGift(exchangeInfo)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendExchangeGift has no right to chat")
    return
  end
  local msg = {}
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.ExchangeGiftMsgType
  msg.text = LocUtil.GetLocalizeResStr(62467)
  msg.quickMsg = false
  msg.topic = logic_chat_channel_world.current_topicId
  msg.other = exchangeInfo
  msg.ignoreLen = true
  local channel = logic_chat_channel_world.GetChannelType(chat_macro.Channel.channelWorld, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendManorShare(manorUid)
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendManorShare has no right to chat")
    return
  end
  local msg = {}
  msg.text = LocUtil.GetLocalizeResStr(64795)
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.ManorChatMsgType
  msg.quickMsg = false
  msg.topic = chat_macro.TopicWorldChannel
  msg.  local channel = logic_chat_channel_world.GetChannelType(chat_macro.Channel.channelWorld, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.GetLanguageLangNameByID(id)
  if id == nil then
    return ""
  end
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id and v.id == id then
      return v.langName or ""
    end
  end
  local configs = CDataTable.GetTable("BlueHoleMatchLang")
  for _, v in pairs(configs) do
    if v.id and v.id == id then
      return v.langName or ""
    end
  end
  return ""
end
function logic_chat_channel_world.GetLanguageLangNameByName(name)
  if name == nil then
    return ""
  end
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.name and v.name == name then
      return v.langName or ""
    end
  end
  return ""
end
function logic_chat_channel_world.GetLanguageNameByID(id)
  if id == nil then
    return ""
  end
  if id == 103 then
    return "zh-TW"
  end
  for i, v in ipairs(logic_chat_channel_world.language_data_list) do
    if v.id and v.id == id then
      return v.name or ""
    end
  end
  return ""
end
local StringUtil = require("common.string_util")
local strFind = StringUtil.StrFind
function logic_chat_channel_world.DoseTopicHideFilter(topic)
  return not isJk or topic ~= "world_Channel" and not strFind(topic, "ugc")
end
local sysLangTb = {
  cn = "zh",
  hans = "zh",
  hant = "zh"
}
function logic_chat_channel_world.CantShowMsg(chatData)
  if not isJk then
    return false
  end
  local topic = chatData.chat_content.topic or ""
  if logic_chat_channel_world.DoseTopicHideFilter(topic) then
    log_warning(bWriteLog and "  : chatData.chat_content.topic: " .. tostring(chatData.chat_content.topic))
    return false
  end
  local sysLang = string.lower(chatData.sys_lang)
  log_warning(bWriteLog and "  : sysLang: " .. tostring(sysLang))
  if sysLangTb[sysLang] then
    sysLang = sysLangTb[sysLang]
  end
  log_warning(bWriteLog and "  : sysLang later: " .. tostring(sysLang))
  local logic_chat_filter_language = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_filter_language)
  local filter_langs = logic_chat_filter_language:GetCurSelectLanguageData()
  local filter = prealloctable(0, #filter_langs)
  for _, id in ipairs(filter_langs) do
    filter[id] = 1
  end
  local curId
  for _, v in ipairs(logic_chat_channel_world.language_data_list) do
    if strFind(sysLang, v.name) then
      curId = v.id
      log_warning(bWriteLog and "  : findLang:" .. tostring(sysLang))
    end
  end
  if curId and not filter[curId] then
    log_warning(bWriteLog and "  :filter curId: " .. tostring(curId))
    return true
  elseif not curId then
    log_tree("  logic_chat_channel_world.CantShowMsg. logic_chat_channel_world.language_data_list ", logic_chat_channel_world.language_data_list)
    log_warning(bWriteLog and string.format("logic_chat_channel_world.CantShowMsg error. sysLang=%s", tostring(sysLang)))
  end
  return false
end
function logic_chat_channel_world.SendWebgameInvite(webgameParam, extraParam)
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendWebgameInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendWebgameInvite has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  local eGameType = webgameParam.eGameType
  local LudoConst = require("client.slua.logic.ludo.LudoConst")
  local desc = LudoConst.WebgameInviteTitleAndDesc[eGameType].desc
  msg.text = desc
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.LudoInviteMsgType
  msg.quickMsg = false
  msg.other = webgameParam
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendMainCityWebgameInvite(webgameParam, extraParam)
  log(bWriteLog and "logic_chat_channel_world.SendMainCityWebgameInvite")
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendWebgameInvite wrong param")
    return
  end
  local satisfy = logic_chat_channel_world.CheckHasRightToChat()
  if not satisfy then
    log(bWriteLog and "logic_chat_channel_world.SendWebgameInvite has no right to chat")
    return
  end
  local channel = chat_macro.Channel.channelWorld
  local msg = {}
  local eGameType = webgameParam.eGameType
  local cfg = CDataTable.GetTableData("MainCityH5PlatformCfg", eGameType)
  msg.text = LocUtil.GetLocalizeResStr(cfg.ShareDesc)
  msg.topic = extraParam.topicId
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = chat_macro.MainCityShareWebGameMsgType
  msg.quickMsg = false
  msg.other = webgameParam
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  local msgId = chat_main.CacheMsg(msg)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendMainCitySeesawInvite(seesawParam, extraParam)
  log(bWriteLog and "logic_chat_channel_world.SendMainCitySeesawInvite")
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendMainCitySeesawInvite invalid param, missing topicId")
    return
  end
  if not logic_chat_channel_world.CheckHasRightToChat() then
    log(bWriteLog and "logic_chat_channel_world.SendMainCitySeesawInvite has no right to chat")
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
  local msgId = chat_main.CacheMsg(msg)
  local channel = chat_macro.Channel.channelWorld
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendMainCityShare(maincityParam, extraParam)
  log(bWriteLog and "logic_chat_channel_world.SendMainCityShare")
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendMainCityShare invalid param, missing topicId")
    return
  end
  if not logic_chat_channel_world.CheckHasRightToChat() then
    log(bWriteLog and "logic_chat_channel_world.SendMainCityShare has no right to chat")
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
  local msgId = chat_main.CacheMsg(msg)
  local channel = chat_macro.Channel.channelWorld
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendFlashMatchTeamInvite(teamParam, extraParam)
  log(bWriteLog and "logic_chat_channel_world.SendFlashMatchTeamInvite")
  if not extraParam or not extraParam.topicId then
    log(bWriteLog and "logic_chat_channel_world.SendFlashMatchTeamInvite invalid param, missing topicId")
    return
  end
  if not logic_chat_channel_world.CheckHasRightToChat() then
    log(bWriteLog and "logic_chat_channel_world.SendFlashMatchTeamInvite has no right to chat")
    return
  end
  local teamName = teamParam.name or ""
  local msg = {
    text = teamName,
    topic = extraParam.topicId,
    sendTime = TimeUtil.GetServerTimeInSec(),
    msgType = chat_macro.FlashMatchTeamInvite,
    quickMsg = false,
    other = teamParam
  }
  local msgId = chat_main.CacheMsg(msg)
  local channel = chat_macro.Channel.channelWorld
  channel = logic_chat_channel_world.GetChannelType(channel, msg.topic)
  logic_chat_channel_world.SendChatReq(0, channel, msgId, msg)
end
function logic_chat_channel_world.SendPicShare(tSendChatData)
  local nMsgId = chat_main.CacheMsg(tSendChatData)
  logic_chat_channel_world.SendChatReq(0, chat_macro.Channel.channelWorld, nMsgId, tSendChatData)
end
function logic_chat_channel_world.SendBFSubGroupInvite(tSendChatData)
  local nMsgId = chat_main.CacheMsg(tSendChatData)
  logic_chat_channel_world.SendChatReq(0, chat_macro.Channel.channelWorld, nMsgId, tSendChatData)
end
function logic_chat_channel_world.SendBFRPGroupInvite(tSendChatData)
  local nMsgId = chat_main.CacheMsg(tSendChatData)
  logic_chat_channel_world.SendChatReq(0, chat_macro.Channel.channelWorld, nMsgId, tSendChatData)
end
function logic_chat_channel_world.SetIsShareWOWJump(isShareWOWJump)
  logic_chat_channel_world.end
function logic_chat_channel_world.SetIsShareMileJump(isShareMileJump)
  logic_chat_channel_world.end
function logic_chat_channel_world.SetIsJumpToReturnTopic(bIsJump)
  logic_chat_channel_world.bIsJumpToReturnTopic = bIsJump
end
function logic_chat_channel_world.SendChatReq(uid, channel, msgId, msg)
  if channel == chat_macro.Channel.channelCurrentMainCity then
    log(bWriteLog and "logic_chat_channel_world.SendMsg current maincity is ChatByDS")
    local MainCityChatNetClient = require("GameLua.Mod.MainCity.Client.Logic.Chat.MainCityChatNetClient")
    MainCityChatNetClient.send_chat_req(0, chat_macro.Channel.channelCurrentMainCity, msgId, msg)
    msg.topic = chat_macro.TopicCurrentMainCity
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.MainCity_MainCityChannel_Chat)
  else
    ChatHandler.send_chat_req(uid, channel, msgId, msg)
  end
end
return logic_chat_channel_world