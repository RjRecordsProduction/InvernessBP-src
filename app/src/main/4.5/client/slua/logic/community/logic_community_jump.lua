local logic_community = require("client.slua.logic.community.logic_community_def")
function logic_community.IsGameStatusInLobby()
  return GameStatus.IsInLobbyOrMainCity()
end
function logic_community.IsCurLoginAccount(params)
  if params then
    local bUid = DataMgr.roleData.uid == params.uid
    local bOpenid = DataMgr.roleData.openid == params.openid
    return bUid or bOpenid
  end
  return false
end
function logic_community.OnJumpCommunity(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpCommunity", vars)
  logic_community.JumpToCommunity(vars)
end
function logic_community.JumpToCommunity(params_table)
  log(bWriteLog and "[janesjiang][Club] logic_community.JumpToCommunity")
  if logic_community.GetShowEntry() == false then
    ShowNotice(23579)
    return
  end
  if logic_community.IsShowVersionUpdateRedDot() then
    logic_community.UpdateVersionUpdateRedDotRecord()
  end
  local   local bReq = false
  local bNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SOCIAL_LOBBY, 10)
  if bNewbie then
    bReq = true
    DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SOCIAL_LOBBY, 10)
  end
  local CommunityHandler = require("client.network.Protocol.CommunityHandler")
  if CommunityHandler.bGetServerData and CommunityHandler.red_type ~= nil and CommunityHandler.red_type ~= 0 then
    if CommunityHandler.red_type ~= 106 then
      bReq = true
      CommunityHandler.send_shequn_clear_reddot_req(CommunityHandler.red_type)
    end
    CommunityHandler.red_type = 0
  end
  if bReq then
    EventSystem:postEvent(EVENTTYPE_COMMUNITY, EVENTID_COMMUNITY_NOTIFY_REDDOT_INFO)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.2, function()
      logic_community.GotoCommunityH5(nil, params_table)
    end)
  else
    logic_community.GotoCommunityH5(nil, params_table)
  end
end
function logic_community.GotoCommunityH5(sendReport, params_table)
  log(bWriteLog and string.format("[janesjiang][Club] logic_community.GotoCommunityH5 sendReport:%s", sendReport))
  if sendReport == nil or sendReport == true then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.COMMUNITY_ENTER)
  end
  local jump, game_scene = logic_community.MakeJumpUrl("?", params_table)
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.BackToCommunity()
  log(bWriteLog and "[janesjiang][Club] logic_community.BackToCommunity")
  logic_community.GotoCommunityH5(false, {
    game_scene = logic_community.GameScene.BackFromPersonalSpace
  })
end
function logic_community.GotoClubUserProfile(uid, game_scene)
  log(bWriteLog and string.format("[janesjiang][Club] logic_community.GotoClubUserProfile uid:%s", uid))
  local jump = "/home_page?target_uid=" .. uid
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.GetMaxRank()
  local maxSegment = 101
  if DataMgr.roleData then
    if DataMgr.roleData.allzoneSegment then
      local maxSegmentInfo = DataMgr.GetMaxSegmentInfo(DataMgr.roleData.allzoneSegment)
      log_tree("[janesjiang][Club] GetMaxRank maxSegmentInfo", maxSegmentInfo)
      maxSegment = maxSegmentInfo.SegmentLevel
    else
      log(bWriteLog and "[janesjiang][Club] logic_community.GetMaxRank allzoneSegment is nil")
    end
  else
    log(bWriteLog and "[janesjiang][Club] logic_community.GetMaxRank roleData is nil")
  end
  return maxSegment
end
function logic_community.OnPostRoomInfo(roomid, password)
  if logic_community.tmp_room_jump_info then
    log(bWriteLog and "logic_community.OnPostRoomInfo " .. tostring(roomid) .. " " .. tostring(password))
    password = password or ""
    local UIUtil = require("client.common.ui_util")
    log_tree("logic_community.OnPostRoomInfo info = ", logic_community.tmp_room_jump_info)
    local url = logic_community.tmp_room_jump_info.sns_lp
    log(bWriteLog and "logic_community.OnPostRoomInfo url=" .. tostring(url))
    local sendTab = {}
    for k, v in pairs(logic_community.tmp_room_jump_info) do
      if k ~= "sns_lp" then
        sendTab[k] = v
      end
    end
    sendTab.room_id = tostring(roomid)
    sendTab.    local sendStr = json.encode(sendTab)
    log(bWriteLog and "logic_community.OnPostRoomInfo sendStr" .. tostring(sendStr))
    local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
    local header = {
      ["Content-Type"] = "application/json; charset=utf-8"
    }
    http_manager:Post(url, header, sendStr, nil, function(success, data)
      log(bWriteLog and string.format("logic_community.OnPostRoomInfo success:%s, data:%s", success, data))
    end)
    logic_community.tmp_room_jump_info = nil
  end
  logic_community.SendOnRoomStateChange(true, roomid, password)
end
function logic_community.OnJumpRoleSpace(eventType, eventID, vars)
  log_tree(bWriteLog and "[janesjiang][Club] logic_community.OnJumpRoleSpace vars", vars)
  local uid = DataMgr.roleData.uid
  if vars and vars.uid then
    uid = vars.uid
  end
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  SocialPersonSpaceSystem.EnterPersonSpace(uid, true, RoleInfoMainSystem.RoleInfoOpenFromType.CommunityH5)
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnUGCCommunityBackToHomeInfoPageCallback(eventType, eventID, vars)
  if vars == nil then
    return
  end
  log_tree("[zzw][logic_community] OnUGCCommunityBackToHomeInfoPageCallback vars", vars)
  if vars.uid == nil then
    log(bWriteLog and "[zzw][logic_community] OnUGCCommunityBackToHomeInfoPageCallback uid nil")
    return
  else
    log(bWriteLog and "[zzw][logic_community] OnUGCCommunityBackToHomeInfoPageCallback uid:" .. vars.uid .. ",self.uid:" .. DataMgr.roleData.uid)
  end
  if vars and vars.from then
    local logic_community = require("client.slua.logic.community.logic_community")
    logic_community.SetJumpKind(vars.from)
  end
  local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
  if vars.uid and vars.uid == DataMgr.roleData.uid then
    LogicUGCCommunity:OnCommunityJumpToSelfSpacePage(vars.uid)
  else
    LogicUGCCommunity:OnCommunityJumpToWOWPlaySelectPage(vars.uid)
  end
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnJumpAlias(eventType, eventID, vars)
  log(bWriteLog and string.format("logic_community.OnJumpAlias id:%s", vars.id))
  local aliasId
  if vars.id then
    aliasId = vars.id
  end
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local PersonalizationConst = require("client.slua.umg.roleInfoNew.PersonalizationConst")
  RoleInfoMainSystem.Show(RoleInfoMainSystem.Personalize, RoleInfoMainSystem.RoleInfoOpenFromType.Null, DataMgr.roleData.uid, {
    personalInfo = {
      openTab = PersonalizationConst.ENUM_Type.Alias,
      itemID = aliasId
    }
  })
end
function logic_community.OnJumpRoomList(eventType, eventID, vars)
  log(bWriteLog and string.format("logic_community.OnJumpRoomList  vars:%s", vars))
  UIManager.ShowUI(UIManager.UI_Config.room_list)
  RoomSystem.Enter()
  logic_community.tmp_room_jump_info = vars
  log_tree("logic_community.OnJumpRoomList", vars)
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnJumpEnterRoom(eventType, eventID, vars)
  log_tree(bWriteLog and "[janesjiang][Club] logic_community.OnJumpEnterRoom", vars)
  if vars and vars.id then
    RoomSystem.req_join_room(tonumber(vars.id), vars.psd or "")
  end
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnOpenCommunityChat(eventType, eventID, vars)
  log_tree(bWriteLog and "logic_community.OnOpenCommunityChat vars: ", vars)
  if vars and vars.id then
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    logic_chat_main.OpenChatMainByClubId(vars.id)
  end
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnJumpClubHomepage(eventType, eventID, vars)
  log(bWriteLog and "logic_community.OnJumpClubHomepage")
  if vars and vars.id then
    local jump, game_scene = logic_community.MakeJumpUrl("/club_homepage?", vars)
    logic_community.DoJumpCommunityUrl(jump, game_scene)
  end
end
function logic_community.OnJumpTournamentList(eventType, eventID, vars)
  log(bWriteLog and string.format("logic_community.OnJumpTournamentList  vars:%s", vars))
  local jump, game_scene = logic_community.MakeJumpUrl("/tournament_list?", vars)
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.OnJumpTournamentDetail(eventType, eventID, vars)
  log(bWriteLog and string.format("logic_community.OnJumpTournamentDetail  vars:%s", vars))
  if vars and vars.id then
    local jump, game_scene = logic_community.MakeJumpUrl("/tournament_detail?", vars)
    logic_community.DoJumpCommunityUrl(jump, game_scene)
  end
end
function logic_community.OnJumpTopicDetail(eventType, eventID, vars)
  log(bWriteLog and string.format("[janesjiang][Club] logic_community.OnJumpTopicDetail vars:%s", vars))
  if vars and vars.id then
    local jump, game_scene = logic_community.MakeJumpUrl("/topic_detail?", vars)
    logic_community.DoJumpCommunityUrl(jump, game_scene)
  end
end
function logic_community.OnJumpNormalFeedDetail(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpNormalFeedDetail vars", vars)
  if vars and vars.id then
    local jump, game_scene = logic_community.MakeJumpUrl("/normal_feed_detail?", vars)
    logic_community.DoJumpCommunityUrl(jump, game_scene)
  end
end
function logic_community.OnJumpLiveDetail(_, _, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpLiveDetail vars", vars)
  if vars and vars.id then
    local jump, game_scene = logic_community.MakeJumpUrl("/live_detail?", vars)
    logic_community.DoJumpCommunityUrl(jump, game_scene)
  end
end
function logic_community.OnJumpPostUrl(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpPostUrl vars", vars)
  local IntlHelper = import("IntlHelper")
  if logic_community.GetShowEntry() == false then
    ShowNotice(23579)
    logic_community.ClearAdjustDeepLink()
    return
  end
  if vars and vars.deeplink then
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    local url = webModule:URLDecode(vars.deeplink)
    url = string.gsub(url, FuncUtil.GetKeywordByID(3377010) .. "sdk://meemo", "")
    url = url .. "?"
    local jump, game_scene = logic_community.MakeJumpUrl(url, vars)
    logic_community.DoJumpCommunityUrl(jump, game_scene)
  end
end
function logic_community.OnJumpHelpshift(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpHelpshift vars", vars)
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  LogicCustomerService.HelpshiftShowFAQsWithInfo()
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnJumpNotifyCenter(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpNotifyCenter vars", vars)
  local jump, game_scene = logic_community.MakeJumpUrl("/notify_center?", vars)
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.OnJumpMatchModeSelection(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpMatchModeSelection vars", vars)
  local jump_url = "game://?module=" .. BP_ENUM_MODULE_MATCH_MODE_SELECTION
  if vars and type(vars) == "table" then
    for k, v in pairs(vars) do
      if k ~= "func_id" and k ~= "module" then
        jump_url = jump_url .. "&" .. tostring(k) .. "=" .. tostring(v)
      end
    end
  end
  GlobalData.JumpUrl(jump_url)
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnJumpActivityCenter(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpActivityCenter vars", vars)
  local params = {
    uid = vars and vars.uid,
    openid = vars and vars.openid
  }
  if not logic_community.IsCurLoginAccount(params) then
    log(bWriteLog and "[janesjiang][Club] logic_community.OnJumpActivityCenter not cur login account")
  end
  local jump_utils = require("client.logic.store.jump_utils")
  local url = jump_utils.GenerateGameUrl(BP_ENUM_MODULE_ACTIVITY)
  GlobalData.JumpUrl(url)
end
function logic_community.OnJumpDailyGift(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpDailyGift vars", vars)
  local params = {
    uid = vars and vars.uid,
    openid = vars and vars.openid
  }
  if not logic_community.IsCurLoginAccount(params) then
    log(bWriteLog and "[janesjiang][Club] logic_community.OnJumpDailyGift not cur login account")
    return
  end
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  if not store_supply_manager:CanBuyDailyFreeGiftBox() then
    log(bWriteLog and "[janesjiang][Club] logic_community.OnJumpDailyGift can't buy daily gift")
    return
  end
  local itemID = store_supply_manager:GetDelayFreeGiftItemID()
  GlobalData.JumpUrl(string.format("game://?module=%s&tab1=%s&tab2=%s&itemId=%s", BP_ENUM_MODULE_MALL_CHILD, StoreConst.Page_New_ID_Recommend, StoreConst.subtype_new_recommend_ucb, itemID))
end
function logic_community.OnJumpMallChild(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpMallChild vars", vars)
  local jump_url = "game://?module=" .. BP_ENUM_MODULE_MALL_CHILD
  if vars and type(vars) == "table" and vars.productId then
    jump_url = jump_url .. "&productId=" .. tostring(vars.productId)
  end
  jump_url = jump_url .. "&from=" .. BP_ENUM_MODULE_CLUB_TO_MALL_CHILD
  GlobalData.JumpUrl(jump_url)
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnJumpPopularityRecent(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpPopularityRecent vars", vars)
  local uid = DataMgr.roleData.uid
  local tab_type
  if vars and type(vars) == "table" then
    if vars.uid then
      uid = vars.uid
    end
    if vars.tabType then
      tab_type = tonumber(vars.tabType)
    end
  end
  local SocialPersonSpaceSystem = require("client.slua.logic.lobby.Left.logic_social_person_space")
  SocialPersonSpaceSystem.EnterPersonSpace(uid, true)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.OpenPopularityUI(uid, tab_type)
  logic_community.ClearAdjustDeepLink()
end
function logic_community.OnJumpVersionTopic(eventType, eventID, vars)
  log_tree("[janesjiang][Club] logic_community.OnJumpVersionTopic vars", vars)
  if vars and vars.id then
    local jump, game_scene = logic_community.MakeJumpUrl("/version_topic_detail?", vars)
    logic_community.DoJumpCommunityUrl(jump, game_scene)
  end
end
function logic_community.MakeJumpUrl(proto_url, vars)
  local param_string, game_scene = logic_community.ParseCommunityParams(vars)
  local jump = proto_url or ""
  if param_string then
    jump = jump .. param_string
  end
  return jump, game_scene
end
function logic_community.DoJumpCommunityUrl(jump, game_scene, isBackToLobby)
  local IntlHelper = import("IntlHelper")
  log(bWriteLog and "logic_community.DoJumpCommunityUrl")
  log(bWriteLog and "logic_community.DoJumpCommunityUrl isBackToLobby: " .. tostring(isBackToLobby))
  if logic_community.GetShowEntry() == false then
    ShowNotice(23579)
    logic_community.ClearAdjustDeepLink()
    return false
  end
  local roleInfoUrl = logic_community.GetRoleInfoUrlParam(game_scene)
  local url = jump .. "&" .. roleInfoUrl
  if not isBackToLobby then
    url = url .. "&" .. logic_community.GetFromScene()
  end
  log(bWriteLog and "logic_community.url = " .. url)
  logic_community.ChangeLobbyBGMForIOSOnly(false)
  local result = logic_community.LuanchMeemoFunction(url)
  logic_community.ClearAdjustDeepLink()
  return result
end
function logic_community.OpenClubHomepage(club_id, game_scene)
  log(bWriteLog and "logic_community.OpenClubHomepage")
  local jump = "/club_homepage?id=" .. club_id
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.OpenClubDetail(club_id)
  log(bWriteLog and "logic_community.OpenClubDetail")
  local jump = "/club_detail?id=" .. club_id
  logic_community.DoJumpCommunityUrl(jump)
end
function logic_community.OpenRecommendClubList(game_scene)
  log(bWriteLog and "logic_community.OpenRecommendClubList")
  local jump = "/reco_club_list?"
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.GetFromScene()
  return "from_scene=1"
end
function logic_community.OpenCorpsFeedPage(game_scene)
  log(bWriteLog and "logic_community.OpenCorpsFeedPage")
  local jump = "/feed_page?scene=13" .. "&" .. logic_community.GetFromScene()
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.OpenPublishFeed(share_type, item_id, img_path, game_scene)
  local jump = "/publish_feed?share=1"
  if item_id then
    jump = jump .. "&id=" .. tostring(item_id)
  end
  if img_path then
    local urlEncode = Client.UrlEncode(img_path)
    jump = jump .. "&img=" .. urlEncode
  end
  if share_type then
    jump = jump .. "&type=" .. tostring(share_type)
  end
  jump = jump .. "&" .. logic_community.GetFromScene()
  local jump_result = logic_community.DoJumpCommunityUrl(jump, game_scene)
  log(bWriteLog and string.format("[janesjiang][Club] logic_community.OpenPublishFeed jump_result[%s] share_type[%s] item_id[%s] img_path[%s]", tostring(jump_result), tostring(share_type), tostring(item_id), tostring(img_path)))
end
function logic_community.OpenNormalFeedDetail(club_id, game_scene)
  log(bWriteLog and "logic_community.OpenNormalFeedDetail")
  local jump = "/normal_feed_detail?id=" .. club_id
  logic_community.DoJumpCommunityUrl(jump, game_scene)
end
function logic_community.OpenUGCPublish(modeInfo, gameScene)
  if not modeInfo then
    return
  end
  local jump = string.format("/publish_feed?share=1&id=%d&type=6", modeInfo.mod_id)
  log(bWriteLog and "logic_community.OpenUGCPublish jump: " .. jump)
  gameScene = gameScene or logic_community.GameScene.UGCMapDetail
  local result = logic_community.DoJumpCommunityUrl(jump, gameScene)
  if result then
    local UGCHandler = require("client.network.Protocol.UGCHandler")
    UGCHandler.send_ugc_share_pub_mod_req(1, modeInfo.mod_id, modeInfo.base.uid, 0)
  end
end
function logic_community.OpenUGCCollectionsPublish(ScreenshotPath)
  local UrlEncode = Client.UrlEncode(ScreenshotPath)
  local Topic = "167506103813078da0e8auto"
  local Env = logic_community.GetVersionEnv()
  if Env == logic_community.EVersionEnv.Release then
    Topic = "167282237097445a1c3fauto"
  end
  local Jump = string.format("/publish_feed?share=1&type=8&game_scene=UGCMapCollectionShare&img=%s&topic_id=%s", UrlEncode, Topic)
  log(bWriteLog and "logic_community.OpenUGCCollectionsPublish jump: " .. Jump)
  logic_community.DoJumpCommunityUrl(Jump, logic_community.GameScene.UGCMapCollectionShare)
end
function logic_community.OpenUGCPMapDetail(mod_id, gameScene)
  local jump = string.format("/ugc_map_detail?id=%d", mod_id)
  log(bWriteLog and "logic_community.OpenUGCPMapDetail jump: " .. jump)
  gameScene = gameScene or logic_community.GameScene.UGCMapDetail
  logic_community.DoJumpCommunityUrl(jump, gameScene)
end
function logic_community.OpenRecommendVideo(mod_id, feed_id)
  local jump = string.format("/ugc_map_detail?id=%d&feedId=%s", mod_id, feed_id or "")
  log(bWriteLog and "logic_community.OpenUGCPublishFeed jump: " .. jump)
  logic_community.DoJumpCommunityUrl(jump, logic_community.GameScene.UGCMapPalyFull)
end
function logic_community.OpenPopularityBattlePublish()
  local env = logic_community.GetVersionEnv()
  local jumpUrl = "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fpublish_feed%3Fshare%3D1%26type%3D5%26game_scene%3DPopularityBattle%26topic_id%3D16819565747782571d06auto"
  if env == logic_community.EVersionEnv.Release then
    jumpUrl = "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fpublish_feed%3Fshare%3D1%26type%3D5%26game_scene%3DPopularityBattle%26topic_id%3D167963670634676d92b4auto"
  end
  log(bWriteLog and "logic_community.OpenPopularityBattlePublish url = " .. jumpUrl)
  GlobalData.JumpUrl(jumpUrl)
end
function logic_community.OpenPopularityDestesktopModule()
  GlobalData.JumpUrl("game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D1%26game_scene%3DPKing_widget%26widget_pip%3D1%26from_scene%3D1")
end
function logic_community.OpenHomePKDestesktopModule()
  log(bWriteLog and "logic_community.OpenHomePKDestesktopModule")
  GlobalData.JumpUrl("game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D2%26game_scene%3DHomePK%26widget_pip%3D1%26from_scene%3D1")
end
function logic_community.OpenPeekGameWonderfulTime(source)
  log(bWriteLog and "logic_community.OpenPeekGameWonderfulTime..source:" .. source)
  local urlPath
  if source == "Rank" then
    urlPath = "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Ftopic_detail%3Fid%3D173883467179696dbbb7auto%26game_scene%3DUltimateRank"
  elseif source == "Main" then
    urlPath = "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Ftopic_detail%3Fid%3D173883467179696dbbb7auto%26game_scene%3DUltimateMain"
  elseif source == "Mode" then
    urlPath = "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Ftopic_detail%3Fid%3D173883467179696dbbb7auto%26game_scene%3DUltimateMode"
  end
  if urlPath then
    GlobalData.JumpUrl(urlPath)
  end
end
function logic_community.OpenSeasonRecordDesktopModule()
  log(bWriteLog and "logic_community.OpenSeasonRecordDesktopModule")
  GlobalData.JumpUrl("game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D3%26game_scene%3DTierWidget%26from_scene%3D1")
end
function logic_community.ClearAdjustDeepLink()
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  AdjustSystem:ClearAdjustDeepLink()
end
function logic_community.NotifyClubShareResult(publishSuccess)
  log(bWriteLog and "logic_community.NotifyClubShareResult publishSuccess:" .. tostring(publishSuccess))
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  if not HostedProtoBridge then
    log(bWriteLog and "logic_community.NotifyClubShareResult HostedProtoBridge is nil")
    return
  end
  local data = {
    type = "ClubShareResult",
    content = tostring(publishSuccess)
  }
  local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
  HostedProtoBridge:OnSendMessage(HostedConst.HostedType.Pandora, data)
end
function logic_community.ReturnToCommunity(return_url, scene)
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local jump = webModule:URLDecode(return_url)
  log(bWriteLog and "logic_community.ReturnToCommunity jump: " .. jump .. " scene:" .. scene)
  return logic_community.DoJumpCommunityUrl(jump, nil, true)
end