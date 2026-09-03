local macro = require("client.slua.logic.lobby_chat.chat_macro")
local logic_chat_horn = require("client.slua.logic.lobby_chat.logic_chat_horn")
local logic_chat_table_pool = require("client.slua.logic.lobby_chat.logic_chat_table_pool")
local logic_chat_short_table_pool = require("client.slua.logic.lobby_chat.logic_chat_short_table_pool")
local ChatFuncUtil = require("client.slua.umg.lobby_chat.chat_funcUtil")
local logic_chat_channel_social_island_chat = require("client.slua.logic.lobby_chat.logic_chat_channel_social_island_chat")
local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
local logic_chat_main = {
  currentChannel = macro.Channel.channelWorld,
  STATIC_MESSAGE_COUNTER = 0,
  ndRspRateSpeedControl = 0,
  msgIdGuid = 0,
  msgContentCacheMap = {},
  chatMacro = macro,
  canOpenChatWnd = true,
  hornMsgPrefix = "<img src=\"Horn_Chat_Msg_Icon\"/> ",
  beCloseFromOther = false,
  shieldExpiredTimeTbl = {},
  shieldPercentTb = {},
  SelectshieldExpiredTimeTbl = {},
  jumpBackData = nil
}
local chatBuffer = {}
local bufferMaxSize = 250
local chatTimer
local isInit = false
local channelConfig = {
  [macro.Channel.channelWorld] = "client.slua.logic.lobby_chat.logic_chat_channel_world",
  [macro.Channel.channelPrivate] = "client.slua.logic.lobby_chat.logic_chat_channel_friend",
  [macro.Channel.channelChatRoom] = "client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room",
  [macro.Channel.channelTeam] = "client.slua.logic.lobby_chat.logic_chat_channel_team",
  [macro.Channel.channelTeamRecruit] = "client.slua.logic.lobby_chat.logic_chat_channel_team_recruit",
  [macro.Channel.channelSocialIslandChat] = "client.slua.logic.lobby_chat.logic_chat_channel_social_island_chat",
  [macro.Channel.channelCorps] = "client.slua.logic.lobby_chat.logic_chat_channel_corps",
  [macro.Channel.channelClub] = "client.slua.logic.lobby_chat.logic_chat_channel_club",
  [macro.Channel.channelWorldCupPK] = "client.slua.logic.lobby_chat.world_cup.logic_world_cup_chat_pk",
  [macro.Channel.WaitingRoom] = "client.slua.logic.lobby_chat.logic_chat_channel_waiting_room",
  [macro.Channel.WaitingRoomTeam] = "client.slua.logic.lobby_chat.logic_chat_channel_waiting_room_team",
  [macro.Channel.channelGlobalManor] = "client.slua.logic.lobby_chat.manor.logic_chat_channel_global_manor",
  [macro.Channel.channelCurrentManor] = "client.slua.logic.lobby_chat.manor.logic_chat_channel_current_manor",
  [macro.Channel.channelFlashMatchTeam] = "client.slua.logic.lobby_chat.logic_chat_channel_flash_match_team"
}
local DefaultMaxChatContentLen = 128
local DefaultVoiceMsgOpenLv = 20
function logic_chat_main.Init()
  isInit = true
  for _, v in pairs(channelConfig) do
    local channelLogic = require(v)
    if channelLogic.Init then
      channelLogic.Init()
    end
  end
  logic_chat_main.RegistEvent()
  logic_chat_main.StartTimer()
end
function logic_chat_main.OnLogin()
  chatBuffer = {}
  local chat_info = LobbySystem.roleData.chat_info
  if chat_info then
    DataMgr.FirstSecondLanguage = chat_info.player_langs
    local logic_chat_channel_team_recruit = require("client.slua.logic.lobby_chat.logic_chat_channel_team_recruit")
    logic_chat_channel_team_recruit.maxTeamRecruitDelayTime = chat_info.team_recruit_max_delay or 300
    local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
    logic_chat_channel_world.topic_fetch_lang_list_rsp(chat_info.chat_lang_cfg, chat_info.topic_change_language_freq)
  end
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.sync_chat_with_match_langs()
end
function logic_chat_main.EnterLobby()
  logic_chat_main.currentChannel = macro.Channel.channelWorld
  for _, v in pairs(channelConfig) do
    local channelLogic = require(v)
    if channelLogic.EnterLobby then
      channelLogic.EnterLobby()
    end
  end
end
function logic_chat_main.StartTimer()
  local time_ticker = require("common.time_ticker")
  chatTimer = time_ticker.AddTimerLoop(0, function()
    logic_chat_main.ChatTick()
  end, TIMER_INFINITE, time_ticker.NEXT_FRAME)
  log(bWriteLog and "god test chat starttimer")
end
function logic_chat_main.StopTimer()
  if chatTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(chatTimer)
    chatTimer = nil
  end
  log(bWriteLog and "god test chat StopTimer")
end
function logic_chat_main.OpenChatMain(channel)
  log(bWriteLog and "god test canOpenChatWnd " .. tostring(logic_chat_main.canOpenChatWnd))
  if not logic_chat_main.CanOpenChat(false) then
    return
  end
  if channel then
    logic_chat_main.currentChannel = channel
  end
  local logic_chat_channel_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_channel_manager)
  if not logic_chat_main.currentChannel or not logic_chat_channel_manager:IsChannelExist(logic_chat_main.currentChannel) then
    local channelList = logic_chat_channel_manager:GetChannelList()
    if channelList then
      logic_chat_main.currentChannel = channelList[1].channelId
    end
  end
  logic_chat_main.OpenChatMainUI()
end
function logic_chat_main.OpenChatMainByTopic(topic)
  log(bWriteLog and "god test canOpenChatWnd " .. tostring(logic_chat_main.canOpenChatWnd))
  if not logic_chat_main.canOpenChatWnd then
    return
  end
  logic_chat_main.currentChannel = macro.Channel.channelWorld
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  logic_chat_channel_world.current_topicId = topic
  logic_chat_main.OpenChatMainUI()
end
function logic_chat_main.OpenChatMainByFriendId(uid)
  if not logic_chat_main.canOpenChatWnd then
    return
  end
  local FriendSystem = require("client.slua.logic.friend.logic_new_friend")
  local isFriend = FriendSystem.IsMyFriend(uid)
  if not isFriend then
    ShowNotice(LocUtil.GetLocalizeResStr(106075))
    return
  end
  logic_chat_main.currentChannel = macro.Channel.channelPrivate
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  logic_chat_channel_friend.CurrentGid = tostring(uid)
  logic_chat_main.OpenChatMainUI()
end
function logic_chat_main.OpenChatMainByHouseKeeperId(uid)
  if not logic_chat_main.canOpenChatWnd then
    return
  end
  logic_chat_main.currentChannel = macro.Channel.channelPrivate
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  logic_chat_channel_friend.CurrentGid = tostring(uid)
  logic_chat_main.OpenChatMainUI()
end
function logic_chat_main.OpenChatMainByStrangerId(uid)
  if not logic_chat_main.canOpenChatWnd then
    return
  end
  local logic_chat_stranger = require("client.slua.logic.lobby_chat.logic_chat_stranger")
  logic_chat_stranger.OpenChatWinByStranger(uid)
  logic_chat_main.currentChannel = macro.Channel.channelPrivate
  logic_chat_main.OpenChatMainUI()
end
function logic_chat_main.OpenChatMainByClubId(club_id)
  if not logic_chat_main.canOpenChatWnd then
    return
  end
  local logic_chat_channel_club = require("client.slua.logic.lobby_chat.logic_chat_channel_club")
  logic_chat_channel_club.SetCurrentClubId(club_id)
  logic_chat_main.currentChannel = macro.Channel.channelClub
  logic_chat_main.OpenChatMainUI()
end
function logic_chat_main.OpenChatMainByFlashTeamSquadId(squad_id)
  if not logic_chat_main.canOpenChatWnd then
    return
  end
  if not squad_id or squad_id == 0 then
    log(bWriteLog and "logic_chat_main.OpenChatMainByFlashTeamSquadId squad_id is nil or 0")
    return
  end
  local logic_chat_channel_flash_match_team = require("client.slua.logic.lobby_chat.logic_chat_channel_flash_match_team")
  logic_chat_channel_flash_match_team.SetCurSelectTeamId(squad_id)
  logic_chat_main.currentChannel = macro.Channel.channelFlashMatchTeam
  logic_chat_main.OpenChatMainUI()
end
function logic_chat_main.OpenChatMainUI()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    UIManager.ShowUI(UIManager.UI_Config.ui_chat_main)
  end)
end
function logic_chat_main.SendMsg(content, msgtype)
  local StringUtil = require("common.string_util")
  content = StringUtil.CheckNameRetrunName(content)
  if "" == content then
    ShowNotice(LocUtil.GetLocalizeResStr(106018))
    return false
  end
  if channelConfig[logic_chat_main.currentChannel] then
    local logicSystem = require(channelConfig[logic_chat_main.currentChannel])
    if logicSystem.SendMsg then
      logicSystem.SendMsg(content, msgtype)
    end
  end
  return true
end
function logic_chat_main.SendVoiceMsg(content, length, voiceId)
  if not logic_chat_main.CheckHasRightToSendVoice() then
    return
  end
  if channelConfig[logic_chat_main.currentChannel] then
    local logicSystem = require(channelConfig[logic_chat_main.currentChannel])
    if logicSystem.SendVoiceMsg then
      logicSystem.SendVoiceMsg(voiceId, length, content)
    end
  end
end
function logic_chat_main.CheckHasRightToSendVoice()
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  if logic_chat_main.currentChannel == chat_macro.Channel.channelPrivate then
    log(bWriteLog and "logic_chat_main.CheckHasRightToSendVoice private")
    return true
  end
  local voiceMsgOpenLv = logic_chat_main.GetVoiceMsgOpenLv()
  if voiceMsgOpenLv <= DataMgr.roleData.level then
    return true
  else
    local tips = LocUtil.LocalizeResFormat(7736, voiceMsgOpenLv)
    ShowNotice(tips)
    return false
  end
end
function logic_chat_main.SendAchivementShare(achievementShareId, finishTime)
  if channelConfig[logic_chat_main.currentChannel] then
    local logicSystem = require(channelConfig[logic_chat_main.currentChannel])
    if logicSystem.SendAchivementShare then
      logicSystem.SendAchivementShare(achievementShareId, finishTime)
    end
  end
end
function logic_chat_main.chat_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, nation)
  local uid = logic_chat_main.GetIdStr(sender_uid)
  local zone_id = chat_content.zone_id
  local selfMsg = logic_chat_main.IsSelfMsg(sender_uid)
  if selfMsg and chat_type == macro.Channel.channelCorps and chat_content.msgType == macro.chatNormalMsgType then
    local logic_chat_channel_corps = require("client.slua.logic.lobby_chat.logic_chat_channel_corps")
    logic_chat_channel_corps.UpdateChatList(sender_uid, chat_content)
  end
  if logic_chat_main.CheckMsg(sender_uid, chat_content.msgType, false) and logic_chat_main.FilterMsg(chat_content, zone_id, selfMsg) then
    chat_content.text = logic_chat_main.remove_color(chat_content.text)
    logic_chat_main.AddChatBuffer(sender_name, chat_type, sender_uid, uid, zone_id, nation, chat_content, selfMsg)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_ON_RECV_CHATMSG, {
      chat_type = chat_type,
      sender_uid = sender_uid,
      content = chat_content
    })
    local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
    if chat_content and chat_content.msgChannel == chat_macro.Channel.channelGroupBuy then
      local logic_group_buying_invite = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying_invite)
      logic_group_buying_invite:AddInfoReq({
        chat_content.other.group_id
      })
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_GROUP_BUY_CHANGE)
    end
  end
end
function logic_chat_main.remove_color(text)
  if not text then
    return
  end
  for k, v in pairs(macro.FILTER_WORDS) do
    text = string.gsub(text, v, "")
  end
  return text
end
function logic_chat_main.IsSelfMsg(sender_uid)
  if not sender_uid then
    return false
  end
  return tonumber(sender_uid) == tonumber(DataMgr.roleData.uid)
end
function logic_chat_main.chat_merge_notify(merge_world_chat, is_history)
  if nil == merge_world_chat or #merge_world_chat == 0 then
    log(bWriteLog and "logic_chat_main.chat_merge_notify empty merge list")
    return
  end
  log(bWriteLog and "logic_chat_main.chat_merge_notify " .. #merge_world_chat)
  local logic_chat_channel_team_recruit = require(channelConfig[macro.Channel.channelTeamRecruit])
  for i = 1, #merge_world_chat do
    local chatData = merge_world_chat[i]
    if logic_chat_channel_team_recruit.IsShowSelfTeamRecruitMsg(chatData, is_history) then
      logic_chat_main.AddOneChatMsg(chatData, is_history)
    end
  end
end
function logic_chat_main.AddOneChatMsg(chatData, is_history)
  local logic_profile_security = require("client.slua.logic.profile.logic_profile_security")
  logic_profile_security.ProcMergeChat(chatData.send_uid, chatData)
  local TableUtil = require("common.table_util")
  local msgType = TableUtil.GetTableValue(chatData, "chat_content", "msgType")
  local selfMsg = logic_chat_main.IsSelfMsg(chatData.send_uid)
  log_warning(bWriteLog and "  : selfMsg: " .. tostring(selfMsg))
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  if not selfMsg and logic_chat_channel_world.CantShowMsg(chatData) then
    return
  end
  if logic_chat_main.CheckMsg(chatData.send_uid, msgType, is_history) and logic_chat_main.FilterMsg(chatData.chat_content, chatData.zone_id, selfMsg) then
    chatData.chat_content.text = logic_chat_main.remove_color(chatData.chat_content.text)
    logic_chat_main.AddChatBuffer(chatData.sender_name, chatData.chat_type, chatData.send_uid, chatData.send_uid, chatData.zone_id, chatData.nation, chatData.chat_content, selfMsg)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_ON_RECV_CHATMSG, {
      chat_type = chatData.chat_type,
      sender_uid = chatData.send_uid,
      content = chatData.chat_content
    })
  end
end
function logic_chat_main.AddChatBuffer(sender_name, chat_type, send_uid, uid, zone_id, nation, chat_content, selfMsg)
  local chatMsg = logic_chat_main.SetNewChat(logic_chat_table_pool.Get(), sender_name, chat_type, send_uid, uid, zone_id, nation, chat_content, selfMsg)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    logic_chat_main.AddChatInFight(chatMsg)
  else
    if #chatBuffer > bufferMaxSize then
      logic_chat_table_pool.Recycle(chatBuffer[1])
      table.remove(chatBuffer, 1)
    end
    table.insert(chatBuffer, chatMsg)
  end
end
function logic_chat_main.AddPokeMsg(uid, selfMsg)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local chatMsg = {
    name = profile.nickName,
    msgType = 0,
    Poke = true,
    uid = tostring(uid),
    sender_uid = tonumber(uid),
    msgChannel = 4,
    send_time = serverTime,
    content = {is_positive = true},
      }
  table.insert(chatBuffer, chatMsg)
  table.sort(chatBuffer, function(a, b)
    return a.send_time < b.send_time
  end)
  log_tree("[v_yunjxing] chatBuffer ", chatBuffer)
end
function logic_chat_main.AddInteractiveMsg(uid, selfMsg, InteractiveRed, msg, iconPatch, iconName)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({uid}, function(list)
    local profile = list[1]
    if profile then
      local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
      local chatMsg = {
        name = profile.nickName,
        msgType = 0,
        Interactive = true,
        InteractiveRed = InteractiveRed,
        uid = tostring(uid),
        sender_uid = tonumber(uid),
        msgChannel = chat_macro.Channel.channelPrivate,
        send_time = serverTime,
        content = {is_positive = true},
        selfMsg = selfMsg,
        msgInteractive = msg,
        iconPatch = iconPatch,
              }
      table.insert(chatBuffer, chatMsg)
      table.sort(chatBuffer, function(a, b)
        return a.send_time < b.send_time
      end)
      log_tree("[v_yunjxing] chatBuffer ", chatBuffer)
    end
  end, Enum_PROFILE_REPORT_CFG.FRIEND_INTERACTION)
end
function logic_chat_main.AddAlterInteractiveMsg(uid, msgText)
  log(bWriteLog and "logic_chat_main.AddAlterInteractiveMsg uid" .. tostring(uid) .. " msg:" .. tostring(msgText))
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({uid}, function(list)
    local profile = list[1]
    if profile then
      local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
      local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      local channelType = chat_macro.Channel.channelPrivate
      local msg = {}
      msg.text = msgText
      msg.sendTime = TimeUtil.GetServerTimeInSec()
      msg.      msg.msgType = 0
      msg.bInTlobby = false
      local msgId = chat_main.CacheMsg(msg)
      local ChatHandler = require("client.network.Protocol.ChatHandler")
      ChatHandler.send_chat_req(uid, channelType, msgId, msg)
    end
  end, Enum_PROFILE_REPORT_CFG.FRIEND_INTERACTION)
end
function logic_chat_main.AddChatInFight(chatMsg)
  logic_chat_main.AddNewChat(chatMsg)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:AddReserveMsgNotifyInGame(chatMsg)
end
function logic_chat_main.ChatTick()
  if 0 < #chatBuffer then
    xpcall(function()
      logic_chat_main.AddNewChat(chatBuffer[1])
    end, require("common.utility").ErrorMessageHandler)
    table.remove(chatBuffer, 1)
  end
end
function logic_chat_main.room_recruit_rsp(chat_content)
  local sender_name = DataMgr.roleData.nickName
  local sender_uid = DataMgr.roleData.uid
  local zone_id = RoomSystem.CurrentRoomInfo.zone_id
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local nation = logic_profile:GetPlayerNation(sender_uid)
  local chatMsg = logic_chat_main.SetNewChat(logic_chat_table_pool.Get(), sender_name, macro.Channel.channelTeamRecruit, sender_uid, DataMgr.roleData.uid, zone_id, nation, chat_content, true)
  chatMsg.roomId = chat_content.room_id
  chatMsg.game_model_type = chat_content.game_model_type
  logic_chat_main.AddNewChat(chatMsg)
end
function logic_chat_main.Team_recruit(channel, sender_name, chat_ctt, sender_uid, selfMsg, team_id, nation, map_data, paramInfo)
  local chat_content = {msgType = 1, text = chat_ctt}
  local uid = logic_chat_main.GetIdStr(sender_uid)
  local zone_id = ""
  local chatMsg = logic_chat_main.SetNewChat(logic_chat_table_pool.Get(), sender_name, channel, sender_uid, uid, zone_id, nation, chat_content, selfMsg)
  local RecruitSystem = require("client.slua.logic.lobby_chat.logic_recruit")
  local _msg, _mapdata, _isInTPlan = RecruitSystem.TeamRecruitMap(chat_ctt, map_data)
  if not _mapdata then
    log_warning("can't find map data,recruit failed!")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if not (not _isInTPlan or LogicTxMissionMain.IsInXMission()) or not _isInTPlan and LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "not match IsInXMission stat")
    return
  end
  chatMsg.msg = _msg
  chatMsg.mapData = _mapdata
  chatMsg.teamId = team_id
  if paramInfo then
    chatMsg.taskId = paramInfo.taskId
    chatMsg.isRp = paramInfo.isRp
    chatMsg.create_time = paramInfo.create_time
  end
  logic_chat_main.AddNewChat(chatMsg)
end
function logic_chat_main.SetNewChat(chatMsg, sender_name, chat_type, sender_uid, uid, zone_id, nation, chat_content, selfMsg)
  chatMsg.content = chat_content
  chatMsg.name = sender_name
  chatMsg.msgChannel = chat_type
  chatMsg.sender_uid = logic_chat_main.GetIdStr(sender_uid)
  chatMsg.  chatMsg.topic = chat_content.topic
  chatMsg.  local TimeUtil = require("client.common.time_util")
  chatMsg.send_time = chat_content.sendTime or TimeUtil.GetServerTimeInSec()
  chatMsg.zoneIp = ""
  chatMsg.zoneText = ""
  chatMsg.new = true
  if zone_id == nil or zone_id == "" then
    zone_id = ZoneSystem.nChooseZoneID
  end
  chatMsg.zoneId = zone_id
  local zoneList = ZoneSystem.chooseZoneList
  for i, v in pairs(zoneList) do
    if v.zone_id == zone_id then
      chatMsg.zoneIp = v.tpingsvr_ip
      break
    end
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  chatMsg.zoneText = logic_multiple_area:GetDisplayNameByZoneID(zone_id)
  local chat_ctt = chat_content.text or ""
  local other = chat_content.other
  if true == chat_content.quickMsg then
    chat_ctt = LocUtil.GetLocalizeResStr(chat_content.text)
  end
  if nil ~= chat_content.voice and "" ~= chat_content.voice then
    chatMsg.voiceMsgTime = chat_content.voiceLength
    chatMsg.voiceMsgId = chat_content.voice
  end
  chatMsg.msg = chat_ctt
  chatMsg.msgType = chat_content.msgType
  if other ~= nil and other.msg_type ~= nil then
    chatMsg.msgType = other.msg_type
  end
  logic_chat_main.STATIC_MESSAGE_COUNTER = logic_chat_main.STATIC_MESSAGE_COUNTER + 1
  chatMsg.level = logic_chat_main.STATIC_MESSAGE_COUNTER
  chatMsg.roleNation = nation
  if other and other.oppoId and other.oppoId ~= 0 then
    chatMsg.oppoId = other.oppoId
  end
  if chat_content.club_id and 0 < chat_content.club_id then
    chatMsg.club_id = chat_content.club_id
  end
  if chat_type == macro.Channel.channelFlashMatchTeam then
    chatMsg.squad_id = chat_content.squad_id
  end
  return chatMsg
end
function logic_chat_main.GetAchievementDetailByChatMessage(chatMsg)
  if chatMsg.msgType ~= macro.achivementMsgType then
    return nil
  end
  local other = chatMsg.content.other
  if other == nil then
    return nil
  end
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  local achievement = logic_achievement.MakeSingleDetailData(other.achievementId)
  if achievement.id ~= nil then
    achievement.finish_time = other.finish_time
    achievement.owner_player_name = chatMsg.name
  end
  return achievement
end
function logic_chat_main.GetAchievementNameByChatMessage(chatMsg)
  if chatMsg.msgType ~= macro.achivementMsgType then
    return nil
  end
  local other = chatMsg.content.other
  if other == nil then
    return nil
  end
  local cfg = CDataTable.GetTableData("AchievementCfg", other.achievementId)
  if cfg then
    return cfg.Name
  end
  return nil
end
function logic_chat_main.FilterMsg(chat_content, zone_id, selfMsg)
  if logic_chat_main.IsChatShieldMsg(chat_content) then
    return false
  end
  if logic_chat_main.IsMetroChatShield(chat_content) then
    return false
  end
  if logic_chat_main.IsSelectToShield(chat_content) then
    return false
  end
  if chat_content.msgType == macro.teamRecruitMsgType then
    local logic_chat_channel_team_recruit = require(channelConfig[macro.Channel.channelTeamRecruit])
    return logic_chat_channel_team_recruit.TeamRecruitMsgTypeFilter(chat_content, zone_id, selfMsg)
  elseif chat_content.msgType == macro.hornMsgType or chat_content.msgType == macro.giftFreeHornMsgType or chat_content.msg_type == macro.proundHornMsgType then
    if LobbySystem.CheckOpen(BP_ENUM_CHAT_HORN_SWITCH) and logic_chat_horn:GetChatHornSwitch() then
      return true
    else
      return false
    end
  elseif chat_content.msgType == macro.teamPlatFormRecruitMsgType then
    local logic_chat_channel_team_recruit = require(channelConfig[macro.Channel.channelTeamRecruit])
    return logic_chat_channel_team_recruit.IsCanShowRecruitMsg(chat_content, selfMsg)
  elseif chat_content.msgType == macro.ExchangeGiftMsgType then
    local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
    local giftInfo = logic_send_gift.GetGiftData(chat_content.other.gift_type)
    if not giftInfo or not LobbySystem.CheckOpen(BP_ENUM_MODULE_EXCHANGEGIFT_SWITCH) then
      return false
    end
  elseif chat_content.msgType == macro.ManorChatMsgType then
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if not logic_home_switch:CheckHomeSwitchOpen() or logic_home_switch:CheckHomeLimit() then
      return false
    end
  end
  return true
end
function logic_chat_main.CheckMsg(sender_uid, msg_type, is_history)
  if msg_type and msg_type >= macro.MsgTypeStart and not macro.MsgTypeCheck[msg_type] then
    log(bWriteLog and "logic_chat_main.CheckMsg No Config MsgTypeCheck, msg_type:" .. tostring(msg_type))
    return false
  end
  if sender_uid == nil then
    log(bWriteLog and "logic_chat_main.CheckMsg sender_uid is nil")
    return false
  end
  if is_history then
    log(bWriteLog and "logic_chat_main.CheckMsg is_history")
    return true
  end
  if ChatFuncUtil.IsIslandBroadcastMsg(msg_type) then
    return true
  end
  local strGid = ""
  if type(sender_uid) == "string" then
    strGid = sender_uid
  else
    local gid = math.floor(sender_uid)
    strGid = tostring(gid)
  end
  if tonumber(strGid) == tonumber(DataMgr.roleData.uid) then
    if msg_type == macro.teamPlatFormRecruitMsgType or msg_type == macro.ChatRoomSendGiftMsgType or msg_type == macro.UGCPlayHallRecruit then
      return true
    end
    return false
  end
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  if logic_friend_blacklist:IsBlacklist(strGid) then
    return false
  end
  return true
end
function logic_chat_main.GetIdStr(id)
  if not id then
    return nil
  end
  local strGid = ""
  if type(id) == "string" then
    strG  else
    local gid = math.floor(id)
    strGid = tostring(gid)
  end
  return strGid
end
function logic_chat_main.ReplaceEmoji(chatContent)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  local newChatContent = ScriptHelperEngine.ReplaceEmoji(chatContent or "", 64, utf8.char(160))
  if newChatContent == "" then
    return chatContent
  end
  return newChatContent
end
function logic_chat_main.on_chat_rsp(res, msg_id, chat_type, surplus, receiver_gid, chat_content, ext_info)
  log(bWriteLog and "[v_wllwu] logic_chat_main.on_chat_rsp, res = " .. tostring(res) .. ", msg_id = " .. tostring(msg_id))
  if msg_id == nil then
    return
  end
  local tabContent = logic_chat_main.msgContentCacheMap[msg_id]
  logic_chat_main.msgContentCacheMap[msg_id] = nil
  if res ~= NetErrorCode_NONE then
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_SEND_MSG_FAIL)
  end
  if res == "chat-banned" then
    logic_chat_main.ChatBanned(receiver_gid, chat_content, ext_info)
    return
  end
  if res == "chat_cheat_banned" then
    ShowNotice(22006)
    return
  end
  if res == NetErrorCode_NONE then
    if tabContent then
      if tabContent.isFromQuickTeam then
        ShowNotice(7892)
      elseif tabContent.msgType == macro.targetShareMsgType then
        logic_chat_main.PopUpTargetShareTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.ManorChatMsgType then
        logic_chat_main.PopUpTargetShareTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.islandBattleShareMsgType then
        logic_chat_main.PopUpTargetShareTips(chat_type, receiver_gid)
        tabContent.other.oppoId = tabContent.other.oppoId or 0
      elseif tabContent.msgType == macro.evaluationShareMsgType then
        logic_chat_main.PopUpEvaluationShareTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.replayShareMsgType then
        EventSystem:postEvent(EVENTTYPE_REPLAY, EVENTTYPE_REPLAY_SHARE_CHAT)
        if tabContent.other then
          logic_chat_main.PopUpReplayShareTips(chat_type, tabContent.other.isForward)
          local logic_replay = require("client.slua.logic.replay.logic_replay")
          local replay_macro = require("client.slua.logic.replay.replay_macro")
          local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
          local json_url = tabContent.other.jsonUrl
          local replay_url = tabContent.other.replayUrl
          local domain_id = tabContent.other.domainID
          json_url = logic_share_replay.GetFullShareUrl(json_url, replay_macro.FileType.INFO, domain_id)
          replay_url = logic_share_replay.GetFullShareUrl(replay_url, replay_macro.FileType.REPLAY, domain_id)
          logic_replay.send_share_replay_report(1, json_url .. ";" .. replay_url, replay_macro.SourceType.CHAT)
        end
      elseif tabContent.msgType == macro.ChatRoomInviteMsgType then
        logic_chat_main.PopUpChatRoomInviteTips(chat_type)
      elseif tabContent.msgType == macro.LudoInviteMsgType then
        logic_chat_main.PopUpChatRoomInviteTips(chat_type)
      elseif tabContent.msgType == macro.seasonLookbackMsgType then
        ShowNotice(512142)
      elseif tabContent.msgType == macro.UGCShareMsgType then
        logic_chat_main.PopUpUGCShareInviteTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.UGCShareChallengeMsgType then
        logic_chat_main.PopUpUGCShareInviteTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.UGCRoomShareMsgType then
        logic_chat_main.PopUpUGCRoomShareInviteTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.MilestoneShare then
        logic_chat_main.PopUpMilestoneShareInviteTips(chat_type)
      elseif tabContent.msgType == macro.UGCShareCollectionMsgType then
        logic_chat_main.PopUpUGCShareCollectionListInviteTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.HomePartyInviteMsgType then
        ShowNotice(102031)
      elseif tabContent.msgType == macro.HalloweenInviteType then
        logic_chat_main.PopUpChatRoomInviteTips(chat_type)
      elseif tabContent.msgType == macro.SnowPartyInviteType then
        logic_chat_main.PopUpChatRoomInviteTips(chat_type)
      elseif tabContent.msgType == macro.MainCitySeesawInviteType then
        logic_chat_main.PopUpChatRoomInviteTips(chat_type)
      elseif tabContent.msgType == macro.MainCityShareChatMsgType then
        logic_chat_main.PopUpChatRoomInviteTips(chat_type)
      elseif tabContent.msgType == macro.SendPicShare then
        logic_chat_main.PopUpPicShareInviteTips(chat_type, receiver_gid)
      elseif tabContent.msgType == macro.MainCityShareWebGameMsgType then
        logic_chat_main.PopUpChatRoomInviteTips(chat_type)
      elseif tabContent.msgType == macro.WeddingInviteMsgType then
        ShowNotice(102031)
      elseif tabContent.msgType == macro.GroupBuyFriendsMsgType then
        ShowNotice(102031)
      elseif tabContent.msgType == macro.GroupBuyCorpsMsgType then
        ShowNotice(102031)
      elseif tabContent.msgType == macro.GroupBuyChannelsMsgType then
        ShowNotice(102031)
      elseif tabContent.msgType == macro.FlashMatchTeamInvite then
        ShowNotice(102031)
      end
      if tabContent.msgType == macro.redpacket then
        ShowNotice(100080025)
      elseif logic_chat_main.FilterRspHornMsg(chat_type, tabContent.text, tabContent.msgType) then
        logic_chat_main.AnalyzeMsg(chat_type, msg_id, tabContent, chat_content, receiver_gid)
      end
    end
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_SEND_MSG_SUC, tabContent)
    return
  elseif res == "chat_busy" then
    ShowNotice(LocUtil.GetLocalizeResStr(106012))
  elseif res == "chat_frequent" then
    if tabContent and tabContent.msgType and tabContent.msgType == macro.roleinfoSocialCard then
      local msgContent = LocUtil.LocalizeResFormat(45920, surplus)
      log(bWriteLog and msgContent)
      ShowNotice(msgContent)
    else
      local msgContent = string.format(LocUtil.GetLocalizeResStr(100007), surplus)
      log(bWriteLog and msgContent)
      ShowNotice(msgContent)
    end
  elseif res == "no-corps" then
    local tips = LocUtil.GetLocalizeResStr(5085)
    ShowNotice(tips)
  elseif res == "chat_level_limit" then
    local tips = LocUtil.LocalizeResFormat(18140104, 10)
    ShowNotice(tips)
  elseif res == "horn_chat_filte" then
    ShowNotice(9003)
  elseif res == "horn_buy_error" then
    ShowNotice(9004)
  elseif res == "horn_not_enough" then
    ShowNotice(8799)
  elseif res == "horn_no_sense_chat_banned" or res == "horn_chat_banned" then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("9222"), LocUtil.GetLocalizeResStr("9223"))
  elseif res == "too_many_horn_msg" then
    ShowNotice(9402)
  elseif res == "in_black_list" then
    ShowNotice(9730)
  elseif res == "chat_len" then
    ShowNotice(LocUtil.LocalizeResFormat(44425, logic_chat_main.GetMaxChatContentLen()))
  elseif res == "owed_limit" then
    ShowNotice(24226)
  elseif res == "not_in_club" then
    ShowNotice(11720003)
  elseif res == "psmatch_team_level_limit" then
    local logic_popular_team_pk_util = require("client.slua.logic.popular_team_pk.logic_popular_team_pk_util")
    logic_popular_team_pk_util.ShowLevelLimitTips()
  elseif res == "voice_msg_level_limit" then
    local tips = LocUtil.LocalizeResFormat(7736, logic_chat_main.GetVoiceMsgOpenLv())
    ShowNotice(tips)
  elseif res == "wow_limit" then
    if chat_content.msgType == 4 then
      ShowNotice(69541)
    else
      ShowNotice(69422)
    end
  elseif res == "ugc-share-limit" then
    ShowNotice(69426)
  end
end
function logic_chat_main.AnalyzeMsg(chat_type, msg_id, tabContent, chat_content, receiver_gid)
  if not tabContent then
    return
  end
  if chat_type == macro.Channel.channelTeamRecruit then
    return
  end
  if chat_type == macro.Channel.channelCorps and tabContent == nil then
    return
  end
  if nil ~= chat_content and "" ~= chat_content then
    tabContent.text = chat_content
  end
  local sender_name = DataMgr.roleData.nickName
  local sender_uid = DataMgr.roleData.uid
  if type(sender_uid) == "string" and sender_uid == "" then
    sender_uid = 0
  end
  local msg_type = tabContent.msgType
  if tabContent.other ~= nil and tabContent.other.msg_type ~= nil then
    msg_type = tabContent.other.msg_type
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local nation = logic_profile:GetPlayerNation(sender_uid)
  local uid = logic_chat_main.GetIdStr(receiver_gid)
  local zone_id = ""
  local selfMsg = true
  local chatMsg = logic_chat_main.SetNewChat(logic_chat_table_pool.Get(), sender_name, chat_type, sender_uid, uid, zone_id, nation, tabContent, selfMsg)
  chatMsg.  logic_chat_main.AddNewChat(chatMsg)
end
function logic_chat_main.AddNewChat(chatMsg)
  printf("logic_chat_main.AddNewChat chatMsg: %s", chatMsg.msg)
  chatMsg.msg = logic_chat_main.ReplaceEmoji(chatMsg.msg)
  if chatMsg.msgType == 26 then
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.GetNewMessage(chatMsg)
  end
  if chatMsg.msgChannel == 4 and chatMsg.msgType == 16 then
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    UnknowPassBuyActSystem.GetNewMessage(chatMsg)
  end
  if chatMsg.msgType == macro.hornMsgType or chatMsg.msgType == macro.giftFreeHornMsgType then
    logic_chat_main.PostHornMsg(chatMsg)
  elseif chatMsg.msgType == macro.proundHornMsgType then
    logic_chat_main.PostProundHornMsg(chatMsg)
  end
  if chatMsg.msgType == macro.XSuitGiftMsgType then
    logic_chat_main.PostXSuitGiftMsg(chatMsg)
  end
  if chatMsg.msgType == macro.redpacket then
    local basic_info = chatMsg.content.redpacket.basic_info
    local utils = require("client.slua.logic.crp.ChatRedpacketUtils")
    if basic_info then
      if basic_info.is_announced and basic_info.msg_type == utils.EMsgType.World then
        if utils.IsJapanOrKorea() and basic_info.reward_type == utils.ERewardType.UC then
          log(bWriteLog and " logic_chat_main.AddNewChat ignore is_announced uc redpacket in jk.")
        else
          logic_chat_main.PostHornMsg(chatMsg)
        end
      end
      if utils.IsJapanOrKorea() and basic_info.reward_type == utils.ERewardType.UC then
        log(bWriteLog and " logic_chat_main.AddNewChat ignore uc redpacket in jk.")
        return
      end
    end
  end
  logic_chat_main.SetChatEntranceMsg(chatMsg)
  local channel = logic_chat_main.GetChannel(chatMsg)
  if chatMsg.topic == nil then
    chatMsg.topic = logic_chat_main.GetTopicByChannel(channel)
  end
  if chatMsg.msgType == macro.GroupBuyChannelsMsgType then
    local logic_group_buying_invite = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_group_buying_invite)
  end
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    logicSystem.AddNewChat(chatMsg)
    local securityRemindMsg = logic_chat_main.GetSecurityRemindMsg(chatMsg)
    if securityRemindMsg then
      logicSystem.AddNewChat(securityRemindMsg)
    end
  end
  if chatMsg.msgChannel ~= macro.Channel.channelExchangeGift and chatMsg.msgType == macro.ExchangeGiftMsgType then
    local TableUtil = require("common.table_util")
    local addMsg = TableUtil.CopyTable(chatMsg)
    addMsg.topic = macro.TopicExchangeGift
    local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
    logic_chat_channel_world.AddNewChat(addMsg)
  end
end
function logic_chat_main.GetChannel(chatMsg)
  local channel = chatMsg.msgChannel
  if channel == macro.channelTopic or channel == macro.channelTopic2 or channel == macro.Channel.channelLBS or channel == macro.Channel.channelSameAge or channel == macro.Channel.channelWorldCup or channel == macro.Channel.channelUGC or channel == macro.Channel.channelExchangeGift or channel == macro.Channel.channelCurrentMainCity or channel == macro.Channel.channelGlobalMainCity or channel == macro.Channel.channelReturn or channel == macro.Channel.channelNewbie or channel == macro.Channel.channelGroupBuy then
    channel = macro.Channel.channelWorld
  end
  return channel
end
function logic_chat_main.GetTopicByChannel(channel)
  if channel == macro.Channel.channelCurrentMainCity then
    return macro.TopicCurrentMainCity
  elseif channel == macro.Channel.channelGlobalMainCity then
    return macro.TopicGlobalMainCity
  elseif channel == macro.Channel.channelExchangeGift then
    return macro.TopicExchangeGift
  end
  return nil
end
function logic_chat_main.ChatBanned(receiver_gid, chat_content, ext_info)
  local TimeUtil = require("client.common.time_util")
  local time = chat_content
  local date = TimeUtil.FormatTime_YMDHMS(time, true)
  local str = string.format(LocUtil.GetLocalizeResStr(301143), tostring(date))
  local promptTip = LocUtil.GetLocalizeResStr("101001")
  if nil == receiver_gid or "" == receiver_gid then
    receiver_gid = LocUtil.LocalizeResFormat(5083)
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local clickReduceCallback = function()
    local loginType = login_module.nLoginType
    local country = login_module:GetIpRegion()
    local IntlHelper = import("IntlHelper")
    local timezone = IntlHelper.GetLocalTimezone()
    local language = Client.GetCurrentLanguage()
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    local StringUtil = require("common.string_util")
    local strUserName = StringUtil.EncodeURI(DataMgr.roleData.nickName)
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366177) .. "/user_guide/index.html?" .. FuncUtil.GetKeywordByID(3377009) .. "Id=" .. Client.GetITopGameId() .. "&language=" .. language .. "&country=" .. country .. "&loginType=" .. loginType .. "&roleName=" .. strUserName .. "&timeZone=" .. timezone, true)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.AccountSage_ChatReduce)
  end
  local clickAppeallCallback = function()
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.AccountSage_ChatAppeal)
    local logic_security = require("client.slua.logic.security.logic_security")
    logic_security.JumpAppealURL()
  end
  local clickCancelCallback = function()
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.AccountSage_ChatAppeal)
    local helpShiftStr = ""
    helpShiftStr = "account_limit_mute"
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    LogicCustomerService.HelpshiftShowFAQsWithInfo(helpShiftStr)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local stAppeal = LocUtil.GetLocalizeResStr(4004)
  local stReduce = LocUtil.GetLocalizeResStr(8500233)
  if ext_info and ext_info.appeal_link_switch then
    if ext_info.link_type and ext_info.link_type == 2 then
      CommonMsgBoxMgr.Show(3, promptTip, receiver_gid .. str, clickReduceCallback, nil, stReduce)
    else
      CommonMsgBoxMgr.Show(3, promptTip, receiver_gid .. str, clickAppeallCallback, nil, stAppeal)
    end
  elseif ext_info and ext_info.link_type and ext_info.link_type == 2 then
    CommonMsgBoxMgr.Show(2, promptTip, receiver_gid .. str, clickReduceCallback, clickCancelCallback, stReduce, stAppeal)
  else
    CommonMsgBoxMgr.Show(2, promptTip, receiver_gid .. str, nil, clickCancelCallback, nil, stAppeal)
  end
end
function logic_chat_main.GetHeadDataByChatMsg(avatarData, chatMsg)
  return logic_chat_main.GetHeadData(avatarData, chatMsg.sender_uid, chatMsg.name, chatMsg.roleNation, chatMsg.content)
end
function logic_chat_main.GetHeadData(headdata, senderuid, sender_name, sendernation, contentdata)
  local uid = tostring(math.floor(senderuid))
  if uid == DataMgr.roleData.uid then
    headdata.Gid = uid
    logic_chat_main.InitMyHeadData(headdata)
    if DataMgr.roleData.voice_feedback then
      headdata.mic_level = DataMgr.roleData.voice_feedback.mic_level
      headdata.mic_lang = DataMgr.roleData.voice_feedback.frequency_lang
    end
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    headdata.Gid = tostring(math.floor(senderuid))
    headdata.Url = contentdata.url
    headdata.NickName = sender_name
    headdata.AvatarBox = contentdata.avatarBox
    headdata.AliasId = contentdata.aliasid
    headdata.AliasTitle = FuncUtil.Gen_title(contentdata.aliasid, contentdata.aliarank, contentdata.alias_ext_info, contentdata.alias_rank_id)
    headdata.AliasNation = contentdata.aliasnation
    headdata.AliasRankId = contentdata.alias_rank_id
    headdata.Level = contentdata.level
    headdata.mic_level = contentdata.mic_level
    headdata.mic_lang = contentdata.mic_lang
    headdata.RoleNation = sendernation
    headdata.light_board_info = contentdata.light_board_info
    headdata.collect_data = contentdata.brief_collect_data
    if contentdata.segment_info then
      headdata.MaxSegment = contentdata.segment_info
    else
      local profile = logic_profile:GetLocalProfile(uid)
      if profile and profile.segment_info then
        headdata.MaxSegment = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
      end
    end
    if contentdata.Gender then
      headdata.Gender = contentdata.Gender
    else
      local profile = logic_profile:GetLocalProfile(uid)
      if profile and profile.social_card then
        headdata.Gender = profile.social_card.new_sex
      end
    end
    if contentdata.auth_type then
      headdata.auth_type = contentdata.auth_type
    else
      local profile = logic_profile:GetLocalProfile(uid)
      if profile then
        headdata.auth_type = profile.auth_type
      end
    end
    if contentdata.auth_end_time then
      headdata.auth_end_time = contentdata.auth_end_time
    else
      local profile = logic_profile:GetLocalProfile(uid)
      if profile then
        headdata.auth_end_time = profile.auth_end_time
      end
    end
    local loigc_chat_extra = require("client.slua.logic.lobby_chat.logic_chat_extra")
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      headdata.UpassIsBuy, headdata.UpassShow, headdata.UpassKeepBuy, headdata.UpassCurValue, headdata.pass_type = loigc_chat_extra.ParseUpassInfo(profile.upass)
    else
      headdata.UpassIsBuy, headdata.UpassShow, headdata.UpassKeepBuy, headdata.UpassCurValue, headdata.pass_type = loigc_chat_extra.ParseUpassInfo(contentdata.upass)
    end
    if headdata.UpassIsBuy then
      if headdata.UpassIsBuy > 0 then
        headdata.UpassIsBuy = true
      else
        headdata.UpassIsBuy = false
      end
    else
      headdata.UpassIsBuy = false
    end
  end
  if contentdata and contentdata.NicknameColor then
    headdata.NicknameColor = contentdata.NicknameColor
  end
  return headdata
end
function logic_chat_main.OnSendMsgSuccess(msg_id)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  if logic_chat_main.ndRspRateSpeedControl == 0 then
    logic_chat_main.endRspRateSpeedControl = serverTime
  end
  if serverTime - logic_chat_main.sendRspRateSpeedControl < 2 then
    return
  end
  logic_chat_main.sendRspRateSpeedControl = serverTime
end
function logic_chat_main.CacheMsg(tabContent)
  logic_chat_main.msgIdGuid = logic_chat_main.msgIdGuid + 1
  logic_chat_main.msgContentCacheMap[logic_chat_main.msgIdGuid] = tabContent
  return logic_chat_main.msgIdGuid
end
function logic_chat_main.IsLocalBoot()
  if Client then
    if not Client.IsDevelopment() then
      return false
    end
    local uid = DataMgr.roleData.uid
    return uid == ""
  else
    return _G.IsEditor
  end
end
function logic_chat_main.filter_text_req(text, context)
  if nil == text or "" == text then
    return
  end
  if nil == context or "" == context then
    return
  end
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_filter_text_req(text, context)
  if IsEditor and logic_chat_main.IsLocalBoot() then
    logic_chat_main.filter_text_rsp(text, context)
  end
end
function logic_chat_main.filter_text_rsp(filter_text, context)
  if nil == context or "" == context then
    return
  end
  log(bWriteLog and "filter_text_rsp filter_text, context:" .. filter_text .. context)
  IngameChat:on_filter_finish(filter_text, context)
end
function logic_chat_main.ClearData()
  isInit = false
  logic_chat_main.beCloseFromOther = false
  for _, v in pairs(channelConfig) do
    local channelLogic = require(v)
    if channelLogic.ClearData then
      channelLogic.ClearData()
    end
  end
  logic_chat_main.UnregistEvent()
  logic_chat_main.StopTimer()
end
function logic_chat_main.CloseChatWin()
  UIManager.CloseUI(UIManager.UI_Config.ui_chat_main)
end
function logic_chat_main.CloseChatWinFromOther()
  logic_chat_main.beCloseFromOther = true
  UIManager.CloseUI(UIManager.UI_Config.ui_chat_main)
end
function logic_chat_main.RegistEvent()
  EventSystem:registEvent(EVENTTYPE_CHAT, EVENTID_CHAT_TRANSLATE_CALLBACK, logic_chat_main.OnTranslate)
  EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, logic_chat_main.WardRobeAvatarResetClose)
end
function logic_chat_main.UnregistEvent()
  EventSystem:unregistEvent(EVENTTYPE_CHAT, EVENTID_CHAT_TRANSLATE_CALLBACK, logic_chat_main.OnTranslate)
  EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, logic_chat_main.WardRobeAvatarResetClose)
end
function logic_chat_main.OnTranslate(eventId, eventName, chatMsg)
  logic_chat_main.TranslateText(chatMsg)
end
function logic_chat_main.TranslateText(chatMsg)
  if not chatMsg.transOrOrgText then
    log(bWriteLog and "translate fail")
    return
  end
  local channel = logic_chat_main.GetChannel(chatMsg)
  if not channelConfig[channel] then
    return
  end
  logic_chat_main.bTranslateTexting = true
  local channelLogic = require(channelConfig[channel])
  if channelLogic.GetMessageList then
    local msgList = channelLogic.GetMessageList(chatMsg)
    if msgList then
      for k, msgData in pairs(msgList) do
        if msgData.level == chatMsg.level then
          local translateText = chatMsg.transOrOrgText
          msgData.transOrOrgText = msgData.msg
          msgData.msg = translateText
          msgData.isTranslate = true
          msgList[k] = msgData
          break
        end
      end
    end
  end
  logic_chat_main.bTranslateTexting = false
end
function logic_chat_main.OnResetTranslateText(chatMsg)
  logic_chat_main.bTranslateTexting = true
  local channel = logic_chat_main.GetChannel(chatMsg)
  local channelLogic = require(channelConfig[channel])
  if channelLogic.GetMessageList then
    local msgList = channelLogic.GetMessageList(chatMsg)
    if msgList then
      for k, msgData in pairs(msgList) do
        if msgData.level == chatMsg.level then
          local orignalText = chatMsg.transOrOrgText
          msgData.transOrOrgText = msgData.msg
          msgData.msg = orignalText
          msgData.isTranslate = false
          msgList[k] = msgData
          break
        end
      end
    end
  end
  logic_chat_main.bTranslateTexting = false
end
function logic_chat_main.OnModePostSwitch(preState, nextState)
  logic_chat_channel_social_island_chat.OnGameStateChange(nextState)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  logic_chat_channel_chat_room.OnGameStateChange()
  log(bWriteLog and "god test nextState " .. tostring(nextState))
  local logicFriend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend_in_fight")
  if nextState == GameStatus.Lobby then
    if not isInit then
      logic_chat_main.Init()
    end
    logic_chat_main.EnterLobby()
    logicFriend.ClearFight()
  elseif nextState == GameStatus.Fighting then
    if not GameStatus.IsInMainCity() then
      local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
      if modeSystem.IsSocialIslandMode() then
        if not isInit then
          logic_chat_main.Init()
        end
        logic_chat_main.currentChannel = macro.Channel.channelSocialIslandChat
      else
        local logic_replay = require("client.slua.logic.replay.logic_replay")
        if logic_replay.IsPlayingReplay() then
          log(bWriteLog and "[v_wllwu] logic_chat_main.OnModePostSwitch => replay is playing")
          return
        end
        local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
        if PlanPH_GamePlay_Tools.IsPHomeMode() then
          log(bWriteLog and "logic_chat_main.OnModePostSwitch PHomeMode")
          return
        end
        if GameStatus.IsInLobbyOrMainCity() then
          log(bWriteLog and "logic_chat_main.OnModePostSwitch MainCityMode")
          return
        end
        logicFriend.EnterFight()
        logic_chat_main.ClearData()
      end
    end
  elseif nextState == GameStatus.Login then
    logic_chat_main.ClearData()
    log(bWriteLog and "OnModePostSwitch clear shieldExpiredTimeTbl")
    logic_chat_main.shieldExpiredTimeTbl = {}
    logic_chat_main.shieldPercentTb = {}
    logic_chat_main.SelectshieldExpiredTimeTbl = {}
  end
end
function logic_chat_main.OnGameStateChange(eventType, eventID, vars)
end
function logic_chat_main.SendIslandTargetShare(channel, toUid, ownerUid, score, timeStamp, timeUsed, topicId)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendIslandTargetShare then
      logicSystem.SendIslandTargetShare(toUid, ownerUid, score, timeStamp, timeUsed, topicId)
    end
  end
end
function logic_chat_main.SendIslandBatteShare(channel, toUid, ownerUid, score, oppoId, battleType, topicId)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem then
      logic_chat_main.SendIslandBattleShareReq(logicSystem, toUid, ownerUid, score, oppoId, battleType, topicId)
    end
  end
end
function logic_chat_main.SendEvaluationShare(channel, score, labels, toUid, topicId)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendEvaluationShare then
      logicSystem.SendEvaluationShare(toUid, score, labels, topicId)
    end
  end
end
function logic_chat_main.SendWonderfulReplayShare(channel, replayInfo, toUid, topicId)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendWonderfulReplayShare then
      logicSystem.SendWonderfulReplayShare(toUid, replayInfo, topicId)
    end
  end
end
function logic_chat_main.SendPopularGiftPKShare(channel, toUid, topicId)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendPopularGiftPKShare then
      logicSystem.SendPopularGiftPKShare(toUid, topicId)
    end
  end
end
function logic_chat_main.SendTeamPKInviteFriendShare(channel, toUid, topicId, curTeamNum, totalTeamNum)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendTeamPKInviteFriendShare then
      logicSystem.SendTeamPKInviteFriendShare(toUid, topicId, curTeamNum, totalTeamNum)
    end
  end
end
function logic_chat_main.SendTeamPKReqSupportShare(channel, toUid, topicId, curTeamNum, totalTeamNum)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendTeamPKReqSupportShare then
      logicSystem.SendTeamPKReqSupportShare(toUid, topicId, curTeamNum, totalTeamNum)
    end
  end
end
function logic_chat_main.SendHomePKReqSupportShare(channel, toUid, topicId)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendHomePKReqSupportShare then
      logicSystem.SendHomePKReqSupportShare(toUid, topicId)
    end
  end
end
function logic_chat_main.SendIslandBattleShareReq(logicSystem, toUid, ownerUid, score, oppoId, type, topicId)
  local other = {}
  other.  other.score_desc = score
  other.  other.  local StringUtil = require("common.string_util")
  local strArray = StringUtil.Split(tostring(score), ":")
  if 2 <= #strArray then
    if tonumber(strArray[1]) > tonumber(strArray[2]) then
      other.isWin = true
    else
      other.isWin = false
    end
  end
  local msg = {}
  local channel
  if topicId and logicSystem.channel then
    channel = logicSystem.channel
    channel = logicSystem.GetChannelType(channel, topicId)
    msg.topic = topicId
  elseif logicSystem.channel then
    channel = logicSystem.channel
  end
  msg.text = "0"
  local TimeUtil = require("client.common.time_util")
  msg.sendTime = TimeUtil.GetServerTimeInSec()
  msg.msgType = type
  msg.quickMsg = false
  msg.  local msgId = logic_chat_main.CacheMsg(msg)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  if logicSystem.channel then
    ChatHandler.send_chat_req(0, channel, msgId, msg)
  else
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    logic_chat_channel_friend.SendChatReq(msg, toUid)
  end
end
function logic_chat_main.GetHeadDataByProfile(profile)
  local headdata = {}
  local uid = tostring(math.floor(profile.uid))
  if uid == DataMgr.roleData.uid then
    headdata.Gid = uid
    logic_chat_main.InitMyHeadData(headdata)
  else
    headdata.Gid = uid
    headdata.Url = profile.picUrl
    headdata.NickName = profile.nickName
    headdata.AvatarBox = profile.cur_avatar_box_id
    headdata.AliasId = profile.alias.id
    headdata.AliasTitle = FuncUtil.Gen_title(profile.alias.id, profile.alias.rank, profile.alias.ext_info, profile.alias.rank_id)
    headdata.AliasNation = profile.alias.nation
    headdata.AliasRankId = profile.alias.rank_id
    headdata.Level = profile.level
    headdata.auth_type = profile.auth_type
    headdata.auth_end_time = profile.auth_end_time
    headdata.chat_bubble = profile.chat_bubble
    headdata.collect_data = profile.collect_data
    headdata.region = profile.region
    if profile.social_card then
      headdata.Gender = profile.social_card.new_sex
    end
    headdata.RoleNation = profile.nation
    headdata.MaxSegment = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
    local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
    headdata.UpassIsBuy, headdata.UpassShow, headdata.UpassKeepBuy, headdata.UpassCurValue, headdata.pass_type = UnknowPassUtil.ParseUpassInfo(profile.upass)
    if headdata.UpassIsBuy > 0 then
      headdata.UpassIsBuy = true
    else
      headdata.UpassIsBuy = false
    end
  end
  return headdata
end
function logic_chat_main.InitMyHeadData(headdata)
  headdata.Url = DataMgr.roleData.headIconUrl
  headdata.Level = DataMgr.roleData.level
  headdata.NickName = DataMgr.roleData.nickName
  headdata.AvatarBox = DataMgr.roleData.cur_avatar_box_id
  headdata.AliasId = DataMgr.roleData.alias.id
  headdata.AliasTitle = DataMgr.roleData.alias.title
  headdata.AliasNation = DataMgr.roleData.alias.nation
  headdata.AliasRankId = DataMgr.roleData.alias.rank_id
  headdata.RoleNation = DataMgr.roleData.nation
  headdata.MaxSegment = DataMgr.GetMaxRankLevel()
  headdata.auth_type = DataMgr.roleData.auth_type
  headdata.auth_end_time = DataMgr.roleData.auth_end_time
  headdata.chat_bubble = DataMgr.roleData.chat_bubble
  headdata.UpassIsBuy = UnknowPassSystem.IsBuyElite or false
  headdata.UpassShow = UnknowPassSystem.switch.ui or false
  headdata.UpassKeepBuy = UnknowPassSystem.GetKeeyBuy()
  headdata.UpassCurValue = UnknowPassSystem.GetCurValue()
  headdata.pass_type = UnknowPassSystem.PassType or 0
  headdata.collect_data = DataMgr.roleData.brief_collect_data
  headdata.region = DataMgr.RegionData.region
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.MySocialCard then
    headdata.Gender = SocialCardSystem.MySocialCard.new_sex
  end
end
function logic_chat_main.SetMaxChatContentLen(max_chat_content_len)
  logic_chat_main.MaxChatContentLen = max_chat_content_len or DefaultMaxChatContentLen
end
function logic_chat_main.GetMaxChatContentLen()
  return logic_chat_main.MaxChatContentLen or DefaultMaxChatContentLen
end
function logic_chat_main.SendSocialCardMsg(bSendRecord)
  if channelConfig[logic_chat_main.currentChannel] then
    local logicSystem = require(channelConfig[logic_chat_main.currentChannel])
    if logicSystem.SendSocialCardMsg then
      logicSystem.SendSocialCardMsg(bSendRecord)
    end
  end
end
function logic_chat_main.SendRedpacketMsg(st)
  if channelConfig[logic_chat_main.currentChannel] then
    local logicSystem = require(channelConfig[logic_chat_main.currentChannel])
    if logicSystem.SendRedpacketMsg then
      logicSystem.SendRedpacketMsg(st)
    end
  end
end
function logic_chat_main.SendCropsCardMsg(uid)
  if channelConfig[logic_chat_main.currentChannel] then
    local msg = {}
    local TimeUtil = require("client.common.time_util")
    msg.sendTime = TimeUtil.GetServerTimeInSec()
    msg.msgType = macro.CorpsInfoShareMsgType
    msg.quickMsg = false
    msg.corps_share_info = {}
    msg.corps_share_info.corps_id = uid
    local logicSystem = require(channelConfig[logic_chat_main.currentChannel])
    if logicSystem.SendCropsCardMsg then
      logicSystem.SendCropsCardMsg(msg)
    end
  end
end
function logic_chat_main.SendHornMsg(content)
  if channelConfig[logic_chat_main.currentChannel] then
    local logicSystem = require(channelConfig[logic_chat_main.currentChannel])
    if logicSystem.SendHornMsg then
      logicSystem.SendHornMsg(content)
    end
  end
end
function logic_chat_main.SendProundHornMsg(content)
  local logic_chat_channel_corps = require(channelConfig[macro.Channel.channelCorps])
  if logic_chat_channel_corps.SendProundHornMsg then
    logic_chat_channel_corps.SendProundHornMsg(content)
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(1, function()
    local logic_chat_channel_world = require(channelConfig[macro.Channel.channelWorld])
    if logic_chat_channel_world.SendProundHornMsg then
      logic_chat_channel_world.SendProundHornMsg(content)
    end
  end)
end
function logic_chat_main.FilterRspHornMsg(chat_type, chat_text, msg_type)
  if msg_type == macro.hornMsgType or msg_type == macro.giftFreeHornMsgType or msg_type == macro.proundHornMsgType then
    if LobbySystem.CheckOpen(BP_ENUM_CHAT_HORN_SWITCH) then
      return true
    else
      return false
    end
  end
  return true
end
function logic_chat_main.PostHornMsg(chatMsg)
  local avatar_data
  if chatMsg.selfMsg then
    avatar_data = logic_chat_main.GetHeadData(logic_chat_short_table_pool.Get(), DataMgr.roleData.uid, nil, nil, nil)
  else
    avatar_data = logic_chat_main.GetHeadData(logic_chat_short_table_pool.Get(), chatMsg.sender_uid, chatMsg.name, chatMsg.roleNation, chatMsg.content)
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_HORN_MSG_COME, chatMsg.msgChannel, chatMsg.msg, avatar_data, chatMsg.selfMsg, chatMsg.topic)
  logic_chat_short_table_pool.Recycle(avatar_data)
end
function logic_chat_main.PostXSuitGiftMsg(chatMsg)
  local logic_chat_tips_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_tips_manager)
  logic_chat_tips_manager:AddTips(chatMsg, tonumber(chatMsg.sender_uid) == tonumber(DataMgr.roleData.uid))
end
function logic_chat_main.PostProundHornMsg(chatMsg)
  local avatar_data
  if chatMsg.selfMsg then
    avatar_data = logic_chat_main.GetHeadData(logic_chat_short_table_pool.Get(), DataMgr.roleData.uid, nil, nil, nil)
  else
    avatar_data = logic_chat_main.GetHeadData(logic_chat_short_table_pool.Get(), chatMsg.sender_uid, chatMsg.name, chatMsg.roleNation, chatMsg.content)
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_PROUND_HORN_MSG_COME, chatMsg.msgChannel, chatMsg.msg, avatar_data, chatMsg.selfMsg, chatMsg.topic)
  logic_chat_short_table_pool.Recycle(avatar_data)
end
function logic_chat_main.WardRobeAvatarResetClose()
  if logic_chat_main.beCloseFromOther then
    logic_chat_main.OpenChatMain()
    logic_chat_main.beCloseFromOther = false
  end
end
function logic_chat_main.ClearSomeonesMsg(uid)
  for _, v in pairs(channelConfig) do
    local channelLogic = require(v)
    if channelLogic.ClearSomesMsg then
      channelLogic.ClearSomesMsg(uid)
    end
  end
end
function logic_chat_main.OpenWorldAndTeamRecruitMsg(switch)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
  if modeSystem.IsSocialIslandMode() then
    ChatHandler.send_open_world_and_team_recruit_req(switch)
  end
end
function logic_chat_main.PopUpTargetShareTips(chat_type, receiver_gid)
  if chat_type == macro.Channel.channelWorld or chat_type == macro.channelTopic or chat_type == macro.channelTopic2 then
    ShowNotice(9893)
  elseif chat_type == macro.Channel.channelCorps then
    ShowNotice(9894)
  elseif chat_type == macro.Channel.channelPrivate then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(receiver_gid)
    if profile then
      local txt = LocUtil.LocalizeResFormat(9892, profile.nickName)
      ShowNotice(txt)
    end
  end
end
function logic_chat_main.PopUpEvaluationShareTips(chat_type, receiver_gid)
  if chat_type == macro.Channel.channelWorld or chat_type == macro.channelTopic or chat_type == macro.channelTopic2 then
    ShowNotice(9893)
  elseif chat_type == macro.Channel.channelCorps then
    ShowNotice(9894)
  elseif chat_type == macro.Channel.channelPrivate then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(receiver_gid)
    if profile then
      local txt = LocUtil.LocalizeResFormat(9892, profile.nickName)
      ShowNotice(txt)
    end
  end
end
function logic_chat_main.PopUpReplayShareTips(chat_type, is_forward)
  if chat_type == macro.Channel.channelWorld then
    ShowNotice(24682)
  elseif chat_type == macro.channelTopic or chat_type == macro.channelTopic2 or chat_type == macro.Channel.channelLBS then
    ShowNotice(9893)
  elseif chat_type == macro.Channel.channelCorps then
    ShowNotice(is_forward and 25306 or 9894)
  elseif chat_type == macro.Channel.channelPrivate then
    ShowNotice(is_forward and 25304 or 25307)
  end
end
function logic_chat_main.IsValid()
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return false
  end
  return true
end
function logic_chat_main.IsSubsideValid()
  if Client.IsJaguar() then
    ShowNotice(120001)
    return false
  else
    return true
  end
end
function logic_chat_main.GetLogicChatEntrance()
  return ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_entrance)
end
function logic_chat_main.GetIslandChatEntranceLogic()
  return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.IslandChatEntranceLogic)
end
function logic_chat_main.GetPlanPHEditChatEntranceLogic()
  return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlanPHEditChatEntranceLogic)
end
function logic_chat_main.GetPlanPHVisitChatEntranceLogic()
  return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlanPHVisitChatEntranceLogic)
end
function logic_chat_main.SendChatRoomInvite(channel, roomParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendChatRoomInvite then
      logicSystem.SendChatRoomInvite(roomParam, extraParam)
    end
  end
end
function logic_chat_main.PopUpChatRoomInviteTips(chat_type)
  if chat_type == macro.Channel.channelCorps then
    ShowNotice(9894)
  else
    ShowNotice(9893)
  end
end
function logic_chat_main.SendMilestoneShare(channel, nItemID, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendMilestoneShare then
      logicSystem.SendMilestoneShare(nItemID, extraParam)
    end
  end
end
function logic_chat_main.SendUGCShareInvite(channel, roomParam, extraParam, modInfo)
  if not modInfo and not modInfo.base and not roomParam then
    return
  end
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendUGCShareInvite then
      logicSystem.SendUGCShareInvite(roomParam, extraParam)
    end
  end
end
function logic_chat_main.SendUGCRoomShareInvite(channel, roomParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendUGCRoomShareInvite then
      logicSystem.SendUGCRoomShareInvite(roomParam, extraParam)
    end
  end
end
function logic_chat_main.SendUGCShareCollectionListInvite(channel, roomParam, extraParam)
  if not roomParam then
    return
  end
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendUGCShareCollectionList then
      logicSystem.SendUGCShareCollectionList(roomParam, extraParam)
    end
  end
end
function logic_chat_main.PopUpUGCShareInviteTips(chat_type, receiver_gid)
  if chat_type == macro.Channel.channelWorld or chat_type == macro.Channel.channelUGC or chat_type == macro.Channel.channelCorps or chat_type == macro.Channel.channelPrivate then
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if lobbyMain and not IsWoWEditor then
      local confirmClick = function()
        log(bWriteLog and "logic_chat_main.PopUpUGCShareInviteTips:confirmClick chat_type = " .. tostring(chat_type))
        UIManager.AndroidBackToLobby()
        logic_chat_main.currentChannel = chat_type
        if chat_type == macro.Channel.channelPrivate then
          local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
          logic_chat_channel_friend.CurrentGid = tostring(receiver_gid)
        end
        if chat_type == macro.Channel.channelUGC or chat_type == macro.Channel.channelWorld then
          logic_chat_main.currentChannel = macro.Channel.channelWorld
          local LogicChannelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
          LogicChannelWorld.SetIsShareWOWJump(true)
        end
        logic_chat_main.OpenChatMainUI()
      end
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(67920), confirmClick)
    else
      ShowNotice(102031)
    end
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_WORLD_SHARE_MOD_SUCCESS)
  end
end
function logic_chat_main.PopUpPicShareInviteTips(chat_type, receiver_gid)
  if chat_type == macro.Channel.channelWorld or chat_type == macro.Channel.channelCorps or chat_type == macro.Channel.channelPrivate then
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if lobbyMain then
      local confirmClick = function()
        log(bWriteLog and "logic_chat_main.PopUpPicShareInviteTips:confirmClick chat_type = " .. tostring(chat_type))
        UIManager.AndroidBackToLobby()
        logic_chat_main.currentChannel = chat_type
        if chat_type == macro.Channel.channelPrivate then
          local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
          logic_chat_channel_friend.CurrentGid = tostring(receiver_gid)
        elseif chat_type == macro.Channel.channelWorld then
          local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
          local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
          logic_chat_channel_world.SetCurTopicId(chat_macro.TopicWorldChannel)
        end
        logic_chat_main.OpenChatMainUI()
      end
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(67920), confirmClick)
    else
      ShowNotice(102031)
    end
  end
end
function logic_chat_main.PopUpUGCRoomShareInviteTips(chat_type, receiver_gid)
  if chat_type == macro.Channel.channelWorld or chat_type == macro.Channel.channelUGC or chat_type == macro.Channel.channelCorps or chat_type == macro.Channel.channelPrivate then
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if lobbyMain and not IsWoWEditor then
      local confirmClick = function()
        log(bWriteLog and "logic_chat_main.PopUpUGCShareInviteTips:confirmClick chat_type = " .. tostring(chat_type))
        UIManager.CloseUI(UIManager.UI_Config.UGCRoomSharePanel)
        logic_chat_main.currentChannel = chat_type
        if chat_type == macro.Channel.channelPrivate then
          local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
          logic_chat_channel_friend.CurrentGid = tostring(receiver_gid)
        end
        if chat_type == macro.Channel.channelUGC or chat_type == macro.Channel.channelWorld then
          logic_chat_main.currentChannel = macro.Channel.channelWorld
          local LogicChannelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
          LogicChannelWorld.SetIsShareWOWJump(true)
        end
        logic_chat_main.OpenChatMainUI()
      end
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(67920), confirmClick)
    else
      ShowNotice(102031)
    end
  end
end
function logic_chat_main.PopUpUGCShareCollectionListInviteTips(chat_type, receiver_gid)
  if IsWoWEditor then
    ShowNotice(102031)
    return
  end
  if chat_type == macro.Channel.channelWorld or chat_type == macro.Channel.channelUGC or chat_type == macro.Channel.channelWorld or chat_type == macro.Channel.channelCorps or chat_type == macro.Channel.channelPrivate or chat_type == macro.Channel.channelClub then
    local confirmClick = function()
      log(bWriteLog and "logic_chat_main.PopUpUGCShareInviteTips:confirmClick chat_type = " .. tostring(chat_type))
      UIManager.AndroidBackToLobby()
      logic_chat_main.currentChannel = chat_type
      if chat_type == macro.Channel.channelPrivate then
        local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
        logic_chat_channel_friend.CurrentGid = tostring(receiver_gid)
      end
      if chat_type == macro.Channel.channelUGC or chat_type == macro.Channel.channelWorld then
        logic_chat_main.currentChannel = macro.Channel.channelWorld
        local LogicChannelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
        LogicChannelWorld.SetIsShareWOWJump(true)
      end
      logic_chat_main.OpenChatMainUI()
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(67920), confirmClick)
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_WORLD_SHARE_COLLECTIONLIST_SUCCESS)
  end
end
function logic_chat_main.SendHomePartyShareInvite(channel, roomParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendHomePartyShareInvite then
      logicSystem.SendHomePartyShareInvite(roomParam, extraParam)
    end
  end
end
function logic_chat_main.SendWeddingShareInvite(channel, roomParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendWeddingShareInvite then
      logicSystem.SendWeddingShareInvite(roomParam, extraParam)
    end
  end
end
function logic_chat_main.SendFlashMatchTeamInvite(channel, teamParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendFlashMatchTeamInvite then
      logicSystem.SendFlashMatchTeamInvite(teamParam, extraParam)
    end
  end
end
function logic_chat_main.PopUpMilestoneShareInviteTips(chat_type)
  if chat_type == macro.Channel.channelClub or chat_type == macro.Channel.channelWorld or chat_type == macro.Channel.channelCorps or chat_type == macro.Channel.channelPrivate or chat_type == macro.Channel.channelClub then
    local confirmClick = function()
      log(bWriteLog and "logic_chat_main.PopUpMilestoneShareInviteTips:confirmClick chat_type = " .. tostring(chat_type))
      UIManager.AndroidBackToLobby()
      logic_chat_main.OpenChatMain(chat_type)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(4, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(67920), confirmClick)
  end
end
function logic_chat_main.on_metro_chat_shield_expired_ntfy(expired_time, label, percent)
  if percent then
    logic_chat_main.shieldPercentTb[label] = percent
  end
end
function logic_chat_main.on_metro_chat_shield_expired_list_ntfy(labelTb, shieldPercentTb)
  if not labelTb or not next(labelTb) then
    return
  end
  for label, expired_time in pairs(labelTb) do
    logic_chat_main.shieldExpiredTimeTbl[label] = expired_time
  end
  for label, percent in pairs(shieldPercentTb or {}) do
    logic_chat_main.shieldPercentTb[label] = percent
  end
end
function logic_chat_main.IsSelectToShield(chat_content)
  if not chat_content.chat_shield_label then
    log(bWriteLog and "IsMetroChatShield not chat_shield_label")
    return false
  else
    local logic_shield = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_shield)
    local labels = {}
    labels = logic_shield:GetShieldLabels()
    if labels == nil then
      return false
    end
    if labels then
      for label, expired_time in pairs(labels) do
        logic_chat_main.SelectshieldExpiredTimeTbl[label] = expired_time
      end
    end
  end
  local curLabel = logic_chat_main.SelectshieldExpiredTimeTbl[chat_content.chat_shield_label]
  if curLabel == nil then
    return false
  end
  if curLabel == 0 or curLabel == 1 then
    if curLabel == 0 then
      return false
    elseif curLabel == 1 then
      return true
    end
  else
    local TimeUtil = require("client.common.time_util")
    local filter = logic_chat_main.SelectshieldExpiredTimeTbl[chat_content.chat_shield_label] > TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "IsMetroChatShield filter:" .. tostring(filter))
    if not filter then
      return false
    else
      return true
    end
  end
end
function logic_chat_main.IsMetroChatShield(chat_content)
  if not chat_content.chat_shield_label then
    log(bWriteLog and "IsMetroChatShield not chat_shield_label")
    return false
  end
  if not logic_chat_main.shieldExpiredTimeTbl[chat_content.chat_shield_label] then
    log(bWriteLog and "IsMetroChatShield not shield")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local filter = logic_chat_main.shieldExpiredTimeTbl[chat_content.chat_shield_label] > TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "IsMetroChatShield filter:" .. tostring(filter))
  if not filter then
    return false
  end
  local _percent = logic_chat_main.shieldPercentTb[chat_content.chat_shield_label]
  log(bWriteLog and "IsMetroChatShield _percent:" .. tostring(_percent))
  if not _percent then
    return true
  end
  local _random = math.random(1, 100)
  log(bWriteLog and "IsMetroChatShield _random:" .. tostring(_random))
  return _percent >= _random
end
function logic_chat_main.IsChatShieldMsg(chat_content)
  if not chat_content then
    return false
  end
  return chat_content.is_chat_shield_msg
end
function logic_chat_main.SetCurrentChannel(channel)
  logic_chat_main.currentChannel = channel
end
function logic_chat_main.SetChatEntranceMsg(chatMsg)
  printf("logic_chat_main.SetChatEntranceMsg: %s", chatMsg.msg)
  local logic_chat_entrance = logic_chat_main.GetLogicChatEntrance()
  logic_chat_entrance:ReceiveNewMsg(chatMsg)
  local IslandChatEntranceLogic = logic_chat_main.GetIslandChatEntranceLogic()
  IslandChatEntranceLogic:ReceiveNewMsg(chatMsg)
  local PlanPHEditChatEntranceLogic = logic_chat_main.GetPlanPHEditChatEntranceLogic()
  PlanPHEditChatEntranceLogic:ReceiveNewMsg(chatMsg)
  local PlanPHVisitChatEntranceLogic = logic_chat_main.GetPlanPHVisitChatEntranceLogic()
  PlanPHVisitChatEntranceLogic:ReceiveNewMsg(chatMsg)
end
local RemindInterval = 3600
function logic_chat_main.GetSecurityRemindMsg(chatMsg)
  log_tree(bWriteLog and "logic_chat_main.GetSecurityRemindMsg chatMsg:", chatMsg)
  if not chatMsg.content or not chatMsg.content.sec_pre_filte_ret then
    log(bWriteLog and "logic_chat_main.GetSecurityRemindMsg no sec_pre_filte_ret")
    return nil
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eChatSecurityRemindMsg)
  if saveData then
    local curServerTime = TimeUtil.GetServerTimeInSec()
    if curServerTime - saveData.lastRemindTime < RemindInterval then
      log(bWriteLog and "logic_chat_main.GetSecurityRemindMsg CD")
      return nil
    end
  end
  if not logic_chat_main.CanShowRemind() then
    log(bWriteLog and "logic_chat_main.GetSecurityRemindMsg cannot show")
    return nil
  end
  local securityConfig = CDataTable.GetTableData("ChatSecurity", chatMsg.content.sec_pre_filte_ret)
  if not securityConfig then
    log(bWriteLog and "logic_chat_main.GetSecurityRemindMsg not securityConfig")
    return nil
  end
  saveData = saveData or {}
  saveData.lastRemindTime = TimeUtil.GetServerTimeInSec()
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eChatSecurityRemindMsg)
  local TableUtil = require("common.table_util")
  local remindMsg = TableUtil.CopyTable(chatMsg)
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  remindMsg.msgType = chat_macro.ChatSecurityRemind
  remindMsg.msg = securityConfig.Desc
  remindMsg.send_time = TimeUtil.GetServerTimeInSec()
  return remindMsg
end
function logic_chat_main.CanShowRemind()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
    log(bWriteLog and "logic_chat_main.CanShowRemind not global")
    return false
  end
  local logic_mode_mgr = require("client.slua.logic.match.logic_mode_mgr")
  if logic_mode_mgr.IsSocialIslandMode() then
    log(bWriteLog and "logic_chat_main.CanShowRemind socialIsland")
    return false
  end
  local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
  if logic_xmission_main.IsInXMission() then
    log(bWriteLog and "logic_chat_main.CanShowRemind XMission")
    return false
  end
  if RoomSystem.IsShowWaiting() then
    log(bWriteLog and "logic_chat_main.CanShowRemind waiting")
    return false
  end
  return true
end
function logic_chat_main.CanOpenChat(isShowTips)
  local ChatUtils = require("client.slua.logic.lobby_chat.ChatUtils")
  if not ChatUtils.IsChatOpen() and not LobbySystem.CheckOpen(BP_ENUM_ONLY_CHAT_TEAM_RECRUIT_SWITCH) then
    if isShowTips then
      local title = LocUtil.GetLocalizeResStr(101001)
      local text = LocUtil.GetLocalizeResStr(120001)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, text)
    end
    return false
  end
  return true
end
function logic_chat_main.RecordJumpBackData(uiData)
  logic_chat_main.jumpBackData = uiData
end
function logic_chat_main.ClearJumpBackData()
  logic_chat_main.jumpBackData = nil
end
function logic_chat_main.JumpBackToLastUI()
  local data = logic_chat_main.jumpBackData
  if not data or not data.configName then
    logic_chat_main.jumpBackData = nil
    return
  end
  if data.ctorData and #data.ctorData > 0 then
    UIManager.ShowUI(UIManager.UI_Config[data.configName], table.unpack(data.ctorData))
  else
    UIManager.ShowUI(UIManager.UI_Config[data.configName])
  end
  logic_chat_main.jumpBackData = nil
end
function logic_chat_main.JumpRemindUrl()
  local jump_utils = require("client.logic.store.jump_utils")
  local jump_from = require("client.logic.store.jump_from")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_HOSTED_SAFETY_CENTER, {
    from = jump_from.SDK_SafetyCenter_from.Chat
  })
end
function logic_chat_main.SetVoiceMsgOpenLv(voice_msg_open_level)
  logic_chat_main.VoiceMsgOpenLv = voice_msg_open_level
end
function logic_chat_main.GetVoiceMsgOpenLv()
  return logic_chat_main.VoiceMsgOpenLv or DefaultVoiceMsgOpenLv
end
function logic_chat_main.SetReportCacheData(cache)
  logic_chat_main.reportCache = cache
end
function logic_chat_main.GetReportCacheData()
  return logic_chat_main.reportCache
end
function logic_chat_main.OnJumpChatRoomChannel()
  log(bWriteLog and "logic_chat_main.OnJumpChatRoomChannel")
  logic_chat_main.OpenChatMain(macro.Channel.channelChatRoom)
end
function logic_chat_main.SendWebgameInvite(channel, ludoParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendWebgameInvite then
      logicSystem.SendWebgameInvite(ludoParam, extraParam)
    end
  end
end
function logic_chat_main.SendHalloweenInvite(channel, halloweenParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendHalloweenInvite then
      logicSystem.SendHalloweenInvite(halloweenParam)
    end
  end
end
function logic_chat_main.SendSnowPartyInvite(channel, snowPartyParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendSnowPartyInvite then
      logicSystem.SendSnowPartyInvite(snowPartyParam)
    end
  end
end
function logic_chat_main.SendMainCitySeesawInvite(channel, seesawParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendMainCitySeesawInvite then
      logicSystem.SendMainCitySeesawInvite(seesawParam, extraParam)
    end
  end
end
function logic_chat_main.SendMainCityShare(channel, maincityParam, extraParam)
  log(bWriteLog and "logic_chat_main.SendMainCityShare channel = " .. tostring(channel))
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendMainCityShare then
      logicSystem.SendMainCityShare(maincityParam, extraParam)
    end
  end
end
function logic_chat_main.SendMainCityWebgameInvite(channel, webgameParam, extraParam)
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendMainCityWebgameInvite then
      logicSystem.SendMainCityWebgameInvite(webgameParam, extraParam)
    end
  end
end
function logic_chat_main.SendPicShare(channel, tSendChatData)
  if not channel or not tSendChatData then
    return
  end
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendPicShare then
      logicSystem.SendPicShare(tSendChatData)
    end
  end
end
function logic_chat_main.SendBFSubGroupInvite(channel, tSendChatData)
  if not channel or not tSendChatData then
    return
  end
  tSendChatData.ignoreLen = true
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendBFSubGroupInvite then
      logicSystem.SendBFSubGroupInvite(tSendChatData)
    end
  end
end
function logic_chat_main.SendBFRPGroupInvite(channel, tSendChatData)
  if not channel or not tSendChatData then
    return
  end
  if channelConfig[channel] then
    local logicSystem = require(channelConfig[channel])
    if logicSystem.SendBFRPGroupInvite then
      logicSystem.SendBFRPGroupInvite(tSendChatData)
    end
  end
end
return logic_chat_main