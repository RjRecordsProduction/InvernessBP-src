local logic_community = require("client.slua.logic.community.logic_community_def")
if not logic_community._bInit then
  require("client.slua.logic.community.logic_community_live")
  require("client.slua.logic.community.logic_community_jump")
  require("client.slua.logic.community.logic_community_entry")
  require("client.slua.logic.community.logic_community_helper")
  require("client.slua.logic.community.logic_community_match")
  require("client.slua.logic.community.logic_community_ugc")
  require("client.slua.logic.community.logic_community_commercial")
  logic_community._bInit = true
end
function logic_community.Init()
  logic_community.InitModuleCfg()
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, logic_community.OnEventidLoadingBegin)
  EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, logic_community.OnEventidMatchUpdateStatus)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ADD_OTHER_PLAYER, logic_community.OnTeamupPlayerCountChange)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER, logic_community.OnTeamupPlayerCountChange)
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, logic_community.OnBackLogin)
  EventSystem:registEvent(EVENTTYPE_SETTING, EVENTID_SET_REGION_OK, logic_community.OnInitRegionSetting)
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, logic_community.OnSelectZoneRsp)
  local SDKCallbackHelper = import("SDKCallbackHelper")
  local callbackInstance = SDKCallbackHelper.GetInstance()
  callbackInstance.SDKCallbackDelegate:Clear()
  callbackInstance.SDKCallbackDelegate:Add(logic_community.OnBpPluginNotify)
end
function logic_community.InitModuleCfg()
  log(bWriteLog and "logic_community.InitModuleCfg")
  if logic_community.GameToClubCfg and next(logic_community.GameToClubCfg) then
    print(bWriteLog and "logic_community.InitModuleCfg logic_community.GameToClubCfg is not empty")
    return
  end
  logic_community.GameToClubCfg = {
    [BP_ENUM_MODULE_COMMUNITY] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpCommunity
    },
    [BP_ENUM_MODULE_ClubHomepage] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpClubHomepage
    },
    [BP_ENUM_MODULE_TournamentList] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpTournamentList
    },
    [BP_ENUM_MODULE_TournamentDetail] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpTournamentDetail
    },
    [BP_ENUM_MODULE_TopicDetail] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpTopicDetail
    },
    [BP_ENUM_MODULE_NormalFeedDetail] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpNormalFeedDetail
    },
    [BP_ENUM_MODULE_COMMUNITY_LIVE] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpLiveDetail
    },
    [BP_ENUM_MODULE_COMMUNITY_SUM] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpPostUrl
    },
    [BP_ENUM_MODULE_COMMUNITY_Notify_Center] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpNotifyCenter
    },
    [BP_ENUM_MODULE_COMMUNITY_VERSIONTOPIC] = {
      eventType = EVENTTYPE_URL,
      func = logic_community.OnJumpVersionTopic
    }
  }
  for eventid, value in pairs(logic_community.GameToClubCfg) do
    EventSystem:registEvent(value.eventType, eventid, function(...)
      logic_community.isStayInH5 = true
      value.func(...)
    end)
  end
  logic_community.ClubToGameCfg = {
    [BP_ENUM_MODULE_ROLE_SPACE] = {
      func = logic_community.OnJumpRoleSpace
    },
    [BP_ENUM_MODULE_ROOM_LIST] = {
      func = logic_community.OnJumpRoomList
    },
    [BP_ENUM_MODULE_ROOM_ENTER] = {
      func = logic_community.OnJumpEnterRoom
    },
    [BP_ENUM_MODULE_COMMUNITY_Helpshift] = {
      func = logic_community.OnJumpHelpshift
    },
    [BP_ENUM_MODULE_JOIN_ZHUBO_TEAM] = {
      func = logic_community.OnJoinZhuboTeam
    },
    [BP_ENUM_MODULE_QUIT_COMMUNITYH5] = {
      func = logic_community.OnQuitCommunityH5
    },
    [BP_ENUM_MODULE_COMMUNITY_CHAT] = {
      func = logic_community.OnOpenCommunityChat
    },
    [BP_ENUM_MODULE_ALIAS] = {
      func = logic_community.OnJumpAlias
    },
    [BP_ENUM_MODULE_CLUB_TO_MALL_CHILD] = {
      func = logic_community.OnJumpMallChild
    },
    [BP_ENUM_MODULE_CLUB_TO_POPULARITY_RECENT] = {
      func = logic_community.OnJumpPopularityRecent
    },
    [BP_ENUM_MODULE_CLUB_JUMP_TO_MATCH_MODE_SELECTION] = {
      func = logic_community.OnJumpMatchModeSelection
    },
    [BP_ENUM_MODULE_CLUB_TO_ACTIVITY_CENTER] = {
      func = logic_community.OnJumpActivityCenter
    },
    [BP_ENUM_MODULE_CLUB_TO_DAILY_GIFT] = {
      func = logic_community.OnJumpDailyGift
    },
    [BP_ENUM_MODULE_UGC_MAIN_PANEL] = {
      func = logic_community.OnUGCJumpUGCMainPanel
    },
    [BP_ENUM_MODULE_UGC_PLAY_MOD] = {
      func = logic_community.OnUGCPlayModCallback
    },
    [BP_ENUM_MODULE_UGC_JUMPTO_MINEWORKS] = {
      func = logic_community.OnUGCCommunityBackToMineWorksPanelCallback
    },
    [BP_ENUM_MODULE_FRIEND] = {
      func = logic_community.OnJumpFriendList
    },
    [BP_ENUM_MODULE_COMMUNITY_HOMEINFOPAGE] = {
      func = logic_community.OnUGCCommunityBackToHomeInfoPageCallback
    },
    [BP_ENUM_MODULE_SEASON] = {
      func = logic_community.OnJumpSeason
    },
    [BP_ENUM_MODULE_UGC_BEGINNER_LEVEL] = {
      func = logic_community.OnJumpToBeginnerLevel
    }
  }
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CLUB_TO_GAME_MODULE, logic_community.OnClubToGame)
  EventSystem:registEvent(EVENTTYPE_SETTING, EVENTID_SET_REGION_OK, logic_community.NewSendEnterGameLobbyFromLogin)
  EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, logic_community.NewSendEnterGameLobby)
  EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, logic_community.OnApplicationReactived)
end
function logic_community.OnClubToGame(eventType, eventID, vars)
  log(bWriteLog and string.format("[janesjiang][Club] OnClubToGame eventType[%d] eventID[%d]", eventType, eventID))
  log_tree("OnClubToGame vars ", vars)
  if UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting) then
    log(bWriteLog and "[mxiliu]OnClubToGame is in room")
    return
  end
  local module_id
  if vars and vars.func_id then
    module_id = tonumber(vars.func_id)
  else
    return
  end
  if vars and vars.from then
    logic_community.SetJumpKind(vars.from)
  end
  if module_id == BP_ENUM_MODULE_QUIT_COMMUNITYH5 and logic_community.CheckClubMatchSwitch() and vars and vars.subscribe_match == "1" then
    logic_community.ReqClubMatchSubscription(true)
  end
  if logic_community.IsGameStatusInLobby() == false then
    log(bWriteLog and "logic_community.OnClubToGame IsGameStatusInLobby() == false")
    return
  end
  if module_id == BP_ENUM_MODULE_COMMUNITY_HOMEINFOPAGE then
    log(bWriteLog and "[zzw][logic_community] OnClubToGame BP_ENUM_MODULE_COMMUNITY_HOMEINFOPAGE ComeIn")
  end
  if logic_community.ClubToGameCfg and logic_community.ClubToGameCfg[module_id] then
    local func = logic_community.ClubToGameCfg[module_id].func
    if func and type(func) == "function" then
      logic_community.isStayInH5 = false
      func(eventType, module_id, vars)
    end
  end
end
function logic_community.IsUserClubMember(uid, ueObj, callback)
  log(bWriteLog and string.format("logic_community.IsUserClubMember uid:%s", uid))
  local suid = tostring(uid)
  if logic_community.ClubMemberCache[suid] then
    callback(true)
    return
  end
  local url = logic_community.GetVersionUrl() .. "/sns/user/checkcommunityuser"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json",
    ["Accept-Encoding"] = "gzip"
  }
  local jsonStr = string.format("{\"uids\":[\"%s\"]}", suid)
  log(bWriteLog and string.format("logic_community.IsUserClubMember openid:%s", openid))
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, jsonStr, ueObj, function(success, data)
    log(bWriteLog and string.format("logic_community.IsUserClubMember success:%s, data:%s", success, data))
    local tb = json.decode(data)
    if tb and tb.uidFlag and tb.uidFlag[suid] and tb.uidFlag[suid] == 1 then
      logic_community.ClubMemberCache[suid] = 1
      callback(true)
      return
    end
    callback(false)
  end)
end
function logic_community.RequestUserChatState(uidList, callback)
  log(bWriteLog and "[v_ywuyuan] logic_community.RequestUserChatState ")
  log_tree("uidList", uidList)
  if #uidList <= 0 then
    return
  end
  local url = logic_community.GetVersionUrl() .. "/chat/community/userstatev2"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local uid = DataMgr.roleData.uid
  local header = {
    openid = openid,
    uid = uid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json",
    ["Accept-Encoding"] = "gzip"
  }
  local jsonStr = ""
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, jsonStr, nil, function(success, data)
    log(bWriteLog and string.format("logic_community.RequestUserChatState success:%s, data:%s", success, data))
    local tb = json.decode(data)
    log_tree("RequestUserChatState", tb)
    if tb and tb.error == nil and tb.states then
      logic_community.ClubMemberStatusCache = tb.states
      log_tree("logic_community.ClubMemberStatusCache", logic_community.ClubMemberStatusCache)
      callback()
    end
  end)
end
function logic_community.ReqCorpsUnread(corps_id, ueObj, callback)
  log(bWriteLog and "[janesjiang][Club] ReqCorpsUnread corps_id " .. tostring(corps_id))
  local url = logic_community.GetVersionUrl() .. "/feed/unread"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json",
    ["Accept-Encoding"] = "gzip"
  }
  local jsonStr = json.encode({
    list_type = "FEED_LIST_TYPE_CORPS",
    corps_id = tostring(corps_id)
  })
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, jsonStr, ueObj, function(success, data)
    log(bWriteLog and "[janesjiang][Club] ReqCorpsUnread success " .. tostring(success))
    local tb = json.decode(data)
    log_tree("ReqCorpsUnread", tb)
    local bHasUnread = false
    if tb then
      if not tb.error then
        local number = tonumber(tb.number)
        if number ~= nil then
          bHasUnread = 0 < number
        else
          log(bWriteLog and "[janesjiang][Club] ReqCorpsUnread error tb.number invalid " .. tostring(tb.number))
        end
      else
        log(bWriteLog and "[janesjiang][Club] ReqCorpsUnread error " .. tostring(tb.error))
      end
    else
      log(bWriteLog and "[janesjiang][Club] ReqCorpsUnread fail to decode json")
    end
    if callback then
      callback(bHasUnread)
    end
  end)
end
function logic_community.ReqFeedUpdate()
  local url = logic_community.GetVersionUrl() .. "/feed/get_sa_sub_update"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json"
  }
  local lastLoginTimestamp = 0
  if DataMgr.roleData and DataMgr.roleData.old_last_login_time then
    lastLoginTimestamp = DataMgr.roleData.old_last_login_time
  end
  log(bWriteLog and "[janesjiang][Club] ReqFeedUpdate last_vist_timestamp = " .. tostring(lastLoginTimestamp))
  local jsonStr = json.encode({
    last_vist_timestamp = tostring(lastLoginTimestamp)
  })
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, jsonStr, nil, function(success, data)
    log(bWriteLog and "[janesjiang][Club] ReqFeedUpdate success " .. tostring(success))
    local tb = json.decode(data)
    if not tb then
      log(bWriteLog and "[janesjiang][Club] ReqFeedUpdate tb invalid")
      return
    end
    log_tree("ReqFeedUpdate", tb)
    if tb.error then
      log(bWriteLog and "[janesjiang][Club] ReqFeedUpdate error")
    else
      EventSystem:postEvent(EVENTTYPE_COMMUNITY, EVENTID_COMMUNITY_ON_FEED_UPDATE, tb)
    end
  end)
end
function logic_community.GetVersionEnv()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    return logic_community.EVersionEnv.CE
  elseif Client.IsReleaseVersion(NetInterface) then
    return logic_community.EVersionEnv.Release
  else
    return logic_community.EVersionEnv.Test
  end
end
function logic_community.GetVersionUrl()
  local env = logic_community.GetVersionEnv()
  local url
  if env == logic_community.EVersionEnv.Release then
    url = FuncUtil.GetDomainByID(3366081)
  elseif env == logic_community.EVersionEnv.CE then
    url = FuncUtil.GetDomainByID(3366082)
  else
    url = FuncUtil.GetDomainByID(3366083)
  end
  return url
end
function logic_community.ChangeLobbyBGMForIOSOnly(bPlay)
  log(bWriteLog and "logic_community.ChangeLobbyBGMForIOSOnly bPlay = " .. tostring(bPlay))
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.IOS then
    log(bWriteLog and "logic_community.ChangeLobbyBGMForIOSOnly not ios")
    return
  end
  if bPlay then
    GlobalData.RestoreLobbyBGM()
  else
    GlobalData.StopLobbyBGM()
  end
end
function logic_community.GetRoleInfoUrlParam(game_scene, useRandZone)
  local sns = ""
  local logicNewFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendList = logicNewFriend.GetFriendList(false)
  if friendList ~= nil and 0 < #friendList then
    for k, v in pairs(friendList) do
      if logic_community.CheckCanPass(v.uid) then
        local intimacy = v.intimacy or 0
        sns = sns .. v.uid .. "-" .. intimacy .. "_"
      end
    end
    sns = string.sub(sns, 0, #sns - 1)
  end
  log(bWriteLog and "logic_community.GetRoleInfoUrlParam sns = " .. sns)
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local webTicket = Client.GetWebViewTicket(NetInterface)
  local language = Client.GetCurrentLanguage()
  local chat_lang_id = DataMgr.FirstSecondLanguage and DataMgr.FirstSecondLanguage[1] or nil
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  local chat_lang = logic_chat_channel_world.GetLanguageNameByID(chat_lang_id)
  local roleData = DataMgr.roleData
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local logic_zone = require("client.slua.logic.teamup.logic_zone")
  local zone = logic_zone.nChooseZoneID
  local ipRegion = login_module:GetIpRegion()
  local name = Client.UrlEncode(roleData.nickName)
  local gender = roleData.gender
  local uid = roleData.uid
  local rank = logic_community.GetMaxRank()
  local level = roleData.level
  local nation = roleData.nation
  local serverID = DataMgr.club_report_svrid or -1
  log(bWriteLog and string.format("logic_community.GetRoleInfoUrlParam, serverID:%s", serverID))
  local headIconUrl = ""
  if roleData.headIconUrl then
    headIconUrl = Client.UrlEncode(Client.HtmlEncode(roleData.headIconUrl))
  else
    print(bWriteLog and "logic_community.GetRoleInfoUrlParam roleData.headIconUrl is nil")
  end
  if useRandZone then
    local TimeUtil = require("client.common.time_util")
    zone = TimeUtil.GetServerTimeInSec()
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local accountregion = FuncUtil.GetAccountRegionForBP()
  local user_type = 1
  if roleData.eugdpr then
    user_type = roleData.eugdpr.user_type or 1
  else
    log(bWriteLog and "logic_community.GetRoleInfoUrlParam no eugdpr")
  end
  local MinorVerificationSystem = require("client.slua.logic.minor_verification.logic_minor_verification")
  local minorflag = MinorVerificationSystem.MinorFlag or 0
  local env = logic_community.GetVersionEnv()
  local loc = ""
  local myZoneInfo = require("client.slua.logic.lbs.logic_lbs").GetMyZoneInfo()
  if myZoneInfo and type(myZoneInfo) == "table" and next(myZoneInfo) then
    loc = table.concat(myZoneInfo, "-")
  end
  local clan_id = "0"
  if DataMgr.corpsInfo and DataMgr.corpsInfo.id then
    clan_id = tostring(DataMgr.corpsInfo.id)
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local Unbind_Mgr = require("client.slua.logic.unbind_account.logic_unbind")
  local imsdk_channel_id = Unbind_Mgr.GetChannelIdByLoginPlatform(IMSDKHelperInstance:GetHDmpveChannelID())
  local url = "sns=" .. sns .. "&openId=" .. openid .. "&ticket=" .. webTicket .. "&lang=" .. language .. "&chat_lang=" .. chat_lang .. "&partition=" .. zone .. "&region=" .. ipRegion .. "&uid=" .. uid .. "&name=" .. name .. "&gender=" .. gender .. "&avatar=" .. headIconUrl .. "&rank=" .. rank .. "&level=" .. level .. "&nation=" .. nation .. "&accountregion=" .. accountregion .. "&user_type=" .. user_type .. "&minorflag=" .. minorflag .. "&env=" .. env .. "&loc=" .. loc .. "&clan_id=" .. clan_id .. "&patch_version=" .. ClientVersion .. "&game_server_id=" .. serverID .. "&acct_type=" .. imsdk_channel_id
  if DataMgr.minor_cert_status then
    url = url .. "&age_gate=" .. tostring(DataMgr.minor_cert_status)
  end
  if game_scene then
    url = url .. "&game_scene=" .. game_scene
  end
  if logic_community.GetShowEntry() then
    url = url .. "&club_enable=1"
  else
    url = url .. "&club_enable=0"
  end
  return url
end
function logic_community.IsUserAnchorSubscription()
  local anchor_subscription = LobbySystem.roleData.anchor_subscription
  log(bWriteLog and "logic_community.IsUserAnchorSubscription:" .. tostring(anchor_subscription))
  return anchor_subscription and anchor_subscription ~= 0
end
function logic_community._SendToCommunity(json)
  log(bWriteLog and string.format("logic_community._SendToCommunity json:%s", json))
  local bp_pluginBPLibrary = import("bp_pluginBPLibrary")
  if bp_pluginBPLibrary and bp_pluginBPLibrary.bp_pluginSendEvent then
    bp_pluginBPLibrary.bp_pluginSendEvent(json)
  end
end
function logic_community.OnBpPluginNotify(methodId, retJson, extraJson)
  if methodId ~= 2000 then
    return
  end
  local jsonObj = json.decode(retJson)
  if jsonObj.message == "snsJumpGame" then
    local url = jsonObj.body
    log(bWriteLog and string.format("[LWS] logic_community.OnBpPluginNotify url:%s", url))
    if url ~= nil and 10 < #url then
      local StringUtil = require("common.string_util")
      local bParse, gameUrl = StringUtil.AdjustParaAnalysis(url)
      if not bParse then
        log(bWriteLog and string.format("logic_community.OnBpPluginNotify FuncUtil:AdjustParaAnalysis parse failed url:%s", url))
        return
      end
      local timer_tick = require("common.time_ticker")
      timer_tick.AddTimerOnce(0.5, function()
        log(bWriteLog and string.format("[LWS] logic_community.OnBpPluginNotify JumpUrl:%s", gameUrl))
        LobbyUI.CheckToReportTLog(gameUrl)
        GlobalData.JumpUrl(gameUrl)
        timer_tick = nil
      end)
    end
  elseif jsonObj.message == "NotificationStartPIP" then
    local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
    local Enum_iOSAudioFeature = logic_chat_voice_const.Enum_iOSAudioFeature
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    local interface = logic_antsvoice_interface:GetGVoiceInterface()
    interface:SetFeature(Enum_iOSAudioFeature.Playback, true)
    interface:SetFeature(Enum_iOSAudioFeature.BackgroundAudio, true)
  elseif jsonObj.message == "NotificationStopPIP" then
    local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
    local Enum_iOSAudioFeature = logic_chat_voice_const.Enum_iOSAudioFeature
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    local interface = logic_antsvoice_interface:GetGVoiceInterface()
    interface:SetFeature(Enum_iOSAudioFeature.Playback, false)
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if not SettingConfig.backgroundChat then
      interface:SetFeature(Enum_iOSAudioFeature.BackgroundAudio, false)
    end
    logic_community.isStayInH5 = false
    logic_community.ChangeLobbyBGMForIOSOnly(true)
  end
end
function logic_community.SendAuthInfoChange()
  log(bWriteLog and "SendAuthInfoChange")
  if not logic_community.tb_auth_info_change then
    logic_community.tb_auth_info_change = {}
  end
  logic_community.tb_auth_info_change.action = "auth_info_change"
  logic_community.tb_auth_info_change.authInfo = "?" .. logic_community.GetRoleInfoUrlParam()
  log_tree(bWriteLog and "SendAuthInfoChange", logic_community.tb_auth_info_change)
  local jsonStr = json.encode(logic_community.tb_auth_info_change)
  logic_community._SendToCommunity(jsonStr)
  logic_community.tb_auth_info_change.action = nil
  logic_community.tb_auth_info_change.authInfo = nil
end
function logic_community.SendEnterGameLobby()
  log(bWriteLog and "SendEnterGameLobby")
  local time_ticker = require("common.time_ticker")
  logic_community.sendTimer = time_ticker.AddTimerLoop(1, function()
    log(bWriteLog and "login_module:on_login_rsp SendEnterGameLobby timer")
    if DataMgr.RegionData.region then
      time_ticker.RemoveTimer(logic_community.sendTimer)
    end
    if not logic_community.tb_enter_game_lobby then
      logic_community.tb_enter_game_lobby = {}
    end
    logic_community.tb_enter_game_lobby.action = "enter_game_lobby"
    logic_community.tb_enter_game_lobby.authInfo = "?" .. logic_community.GetRoleInfoUrlParam(nil, true)
    local validdeeplink = logic_community.CheckAndGetJumpDeepLink()
    if validdeeplink then
      logic_community.tb_enter_game_lobby.deeplink = validdeeplink
    end
    log_tree(bWriteLog and "SendEnterGameLobby", logic_community.tb_enter_game_lobby)
    local jsonStr = json.encode(logic_community.tb_enter_game_lobby)
    logic_community._SendToCommunity(jsonStr)
    logic_community.tb_enter_game_lobby.action = nil
    logic_community.tb_enter_game_lobby.authInfo = nil
    logic_community.ClearJumpDeepLink()
  end, 10, 1)
end
function logic_community.NewSendEnterGameLobby()
  log(bWriteLog and "NewSendEnterGameLobby")
  local kind = logic_community.GetJumpKind()
  if not kind or kind ~= "app_widget" then
    if logic_community.tb_enter_game_lobby then
      logic_community.tb_enter_game_lobby.url = nil
    end
    printf("logic_community.NewSendEnterGameLobby not app_widget")
    return
  end
  if not logic_community.tb_enter_game_lobby then
    logic_community.tb_enter_game_lobby = {}
  end
  logic_community.tb_enter_game_lobby.action = "enter_game_lobby"
  logic_community.tb_enter_game_lobby.authInfo = "?" .. logic_community.GetRoleInfoUrlParam()
  local validdeeplink = logic_community.CheckAndGetJumpDeepLink()
  if validdeeplink then
    logic_community.tb_enter_game_lobby.url = validdeeplink
  end
  log_tree(bWriteLog and "NewSendEnterGameLobby", logic_community.tb_enter_game_lobby)
  local jsonStr = json.encode(logic_community.tb_enter_game_lobby)
  logic_community._SendToCommunity(jsonStr)
  logic_community.tb_enter_game_lobby.action = nil
  logic_community.tb_enter_game_lobby.authInfo = nil
  logic_community.ClearJumpDeepLink()
  logic_community.ClearJumpKind()
end
function logic_community.NewSendEnterGameLobbyFromLogin()
  log_format(bWriteLog and "NewSendEnterGameLobbyFromLogin")
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local url = AdjustSystem:GetDeepLinkUrl()
  if string.find(url, "from=app_widget") then
    logic_community.SetJumpKind("app_widget")
    logic_community.SetJumpDeepLink(url)
  else
    log_format("logic_community.NewSendEnterGameLobbyFromLogin. not app_widget")
    return
  end
  local kind = logic_community.GetJumpKind()
  if not kind or kind ~= "app_widget" then
    if logic_community.tb_enter_game_lobby then
      logic_community.tb_enter_game_lobby.url = nil
    end
    log_format("logic_community.NewSendEnterGameLobby not app_widget")
    return
  end
  if not logic_community.tb_enter_game_lobby then
    logic_community.tb_enter_game_lobby = {}
  end
  logic_community.tb_enter_game_lobby.action = "enter_game_lobby"
  logic_community.tb_enter_game_lobby.authInfo = "?" .. logic_community.GetRoleInfoUrlParam()
  local validdeeplink = logic_community.CheckAndGetJumpDeepLink()
  if validdeeplink then
    logic_community.tb_enter_game_lobby.url = validdeeplink
  end
  log_tree(bWriteLog and "NewSendEnterGameLobby", logic_community.tb_enter_game_lobby)
  local jsonStr = json.encode(logic_community.tb_enter_game_lobby)
  logic_community._SendToCommunity(jsonStr)
  logic_community.tb_enter_game_lobby.action = nil
  logic_community.tb_enter_game_lobby.authInfo = nil
  logic_community.ClearJumpDeepLink()
  logic_community.ClearJumpKind()
end
function logic_community.OnApplicationReactived()
  logic_community.CheckDesktopTools()
end
function logic_community.CheckDesktopTools()
  local url = logic_community.launchMeemoFunctionUrl
  log(bWriteLog and "logic_community.CheckDesktopTools. url = " .. tostring(url))
  if url == nil then
    return
  end
  logic_community.launchMeemoFunctionUrl = nil
  local logic_activity_util = require("client.slua.logic.lobby.logic_activity_util")
  local desktopToolType = logic_activity_util.GetActivityDesktopToolType()
  log(bWriteLog and "logic_community.CheckDesktopTools. desktopToolType = " .. tostring(desktopToolType))
  local launchMeemoFunctionWidgetType = logic_community.launchMeemoFunctionWidgetType or 0
  if desktopToolType and desktopToolType & launchMeemoFunctionWidgetType ~= 0 then
    return
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_ADD_WIDGET_FAILURE)
end
function logic_community.SetJumpDeepLink(validDeepLink)
  log(bWriteLog and "[v_mxiliu]SetJumpDeepLink" .. validDeepLink)
  logic_community.end
function logic_community.ClearJumpDeepLink()
  log(bWriteLog and "[v_mxiliu]ClearJumpDeepLink")
  logic_community.tb_enter_game_lobby.url = nil
  logic_community.validDeepLink = nil
end
function logic_community.ClearJumpKind()
  log(bWriteLog and "[v_mxiliu]ClearJumpKind")
  logic_community.jumpKind = nil
end
function logic_community.SetJumpKind(kind)
  printf("logic_community.SetJumpKind %s", kind)
  logic_community.jumpKind = kind
end
function logic_community.GetJumpKind()
  printf("logic_community.GetJumpKind %s", logic_community.jumpKind)
  return logic_community.jumpKind
end
function logic_community.CheckAndGetJumpDeepLink()
  log(bWriteLog and "[v_mxiliu]CheckAndGetJumpDeepLink start")
  if logic_community.validDeepLink and logic_community.jumpKind and logic_community.jumpKind == "app_widget" then
    log(bWriteLog and "[v_mxiliu]CheckAndGetJumpDeepLink" .. logic_community.validDeepLink)
    return logic_community.validDeepLink
  end
  return nil
end
function logic_community.RequestVersionUpdate(callback)
  log(bWriteLog and "[v_wllwu] logic_community.RequestVersionUpdate ")
  local url = logic_community.GetVersionUrl() .. "/game/reddot"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json"
  }
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, "", nil, function(success, data)
    log(bWriteLog and string.format("[v_wllwu] logic_community.RequestVersionUpdate success:%s, data:%s", tostring(success), data))
    local tb = json.decode(data)
    log_tree(bWriteLog and "[v_wllwu] logic_community.RequestVersionUpdate ", tb)
    local info
    if tb then
      if not tb.error then
        info = tb
        log(bWriteLog and "[v_wllwu] logic_community.RequestVersionUpdate show " .. tostring(tb.show))
        if not logic_community.versionUpdateInfo then
          logic_community.versionUpdateInfo = tb
        else
          logic_community.versionUpdateInfo.show = tb.show
          logic_community.versionUpdateInfo.versionId = tb.versionId
        end
        logic_community.versionUpdateInfo.requestTime = curTime
        EventSystem:postEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, BP_ENUM_MODULE_COMMUNITY)
        logic_community.UpdateVersionUpdateLocalCache()
        log_tree(bWriteLog and "[v_wllwu] logic_community.RequestVersionUpdate success, logic_community.versionUpdateInfo ", logic_community.versionUpdateInfo)
      else
        log(bWriteLog and "[v_wllwu] logic_community.RequestVersionUpdate error ")
      end
    else
      log(bWriteLog and "[v_wllwu] logic_community.RequestVersionUpdate fail to decode json")
    end
    if callback then
      callback(info)
    end
  end)
end
function logic_community.IsClickFriendDeskTopToolGuideEntry()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuide) or {}
  log_tree(bWriteLog and "logic_community.IsClickFriendDeskTopToolGuideEntry saveData", saveData)
  if saveData.isClick370 then
    local version_util = require("client.common.version_util")
    local currentMainVersion = version_util.GetMainFormat(Client.GetAppVersion())
    if saveData.lastClickVersion ~= currentMainVersion then
      local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
      local _, totalCount = logic_new_friend.GetFriendOnlineCount()
      if 85 < totalCount then
        log(bWriteLog and "logic_community.IsClickFriendDeskTopToolGuideEntry return false for new version and friend count > 85")
        return false
      end
    end
    log(bWriteLog and "logic_community.IsClickFriendDeskTopToolGuideEntry return of already guide")
    return true
  end
  return false
end
function logic_community.IsNeedShowFriendDeskTopToolEntry()
  if not logic_community.GetShowEntry() then
    log(bWriteLog and "logic_community.IsNeedShowFriendDeskTopToolEntry return of not logic_community.GetShowEntry()")
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
    log(bWriteLog and "logic_community.IsNeedShowFriendDeskTopToolEntry return of not GLOBAL")
    return false
  end
  local logic_activity_util = require("client.slua.logic.lobby.logic_activity_util")
  local desktopToolType = logic_activity_util.GetActivityDesktopToolType()
  if desktopToolType and desktopToolType & ActivityDesktopToolType.Friend ~= 0 then
    log(bWriteLog and "logic_community.IsNeedShowFriendDeskTopToolEntry return of already set friend desktop tool")
    return false
  end
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local onlineCount, totalCount = logic_new_friend.GetFriendOnlineCount()
  if 85 < totalCount then
    return true, 2
  end
  if 0 < onlineCount then
    return true, 1
  end
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local innerList = logic_new_friend.GetInnerList()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local isHave = false
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, uid in ipairs(innerList) do
    local lastOnlineTime = logic_profile:GetLastOnlineTime(uid)
    if lastOnlineTime and curTime - lastOnlineTime <= 604800 then
      isHave = true
      break
    end
  end
  if isHave then
    return true, 1
  end
  return false
end
return logic_community