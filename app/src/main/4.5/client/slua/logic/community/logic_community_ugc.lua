local logic_community = require("client.slua.logic.community.logic_community_def")
function logic_community.DoJumpUGCCommunityUrl(jump, game_scene, isSkipCloseFlag, isBackToLobby)
  log(bWriteLog and "logic_community.DoJumpUGCCommunityUrl jump: " .. tostring(jump) .. ", game_scene: " .. tostring(game_scene) .. ", isSkipCloseFlag: " .. tostring(isSkipCloseFlag))
  log(bWriteLog and "logic_community.DoJumpUGCCommunityUrl isBackToLobby: " .. tostring(isBackToLobby))
  local roleInfoUrl = logic_community.GetRoleInfoUrlParam(game_scene)
  local url = jump .. "&" .. roleInfoUrl
  if not isBackToLobby then
    url = url .. "&" .. logic_community.GetFromScene()
  end
  log(bWriteLog and "logic_community.DoJumpUGCCommunityUrl, url = " .. url)
  local canEnter = true
  if not isSkipCloseFlag then
    if logic_community.GetShowEntry() == false then
      ShowNotice(23579)
      canEnter = false
    elseif logic_community.ClubCheckAgeGate(true) == false then
      canEnter = false
    end
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  if not canEnter then
    AdjustSystem:ClearAdjustDeepLink()
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE then
    local CommunityHandler = require("client.network.Protocol.CommunityHandler")
    if CommunityHandler then
      CommunityHandler.send_jump_to_club()
    end
  end
  logic_community.ChangeLobbyBGMForIOSOnly(false)
  local bp_pluginBPLibrary = import("bp_pluginBPLibrary")
  bp_pluginBPLibrary.bp_pluginLaunchMeemoFunction(url)
  AdjustSystem:ClearAdjustDeepLink()
  return true
end
function logic_community.DoPostUGCCommunityUrl(url, post_content, callback, skipOpenCheck)
  url = logic_community.GetVersionUrl() .. url
  log_tree(bWriteLog and "logic_community.DoPostUGCCommunityUrl, url= " .. url)
  if not logic_community.GetShowEntry() and skipOpenCheck ~= true then
    return
  end
  local paltform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local os = "0"
  if paltform == DevicePlatformNameMacros.IOS then
    os = "1"
  end
  local BusinessHelper = import("BusinessHelper")
  local post_header = {
    openid = BusinessHelper.GetOpenId(),
    ticket = Client.GetWebViewTicket(NetInterface),
    region = FuncUtil.GetAccountRegionForBP(),
    lang = Client.GetCurrentLanguage(),
    ["Content-Type"] = "application/json",
      }
  log_tree(bWriteLog and "logic_community.DoPostUGCCommunityUrl, post_head = ", post_header)
  if next(post_content) then
    post_content = json.encode(post_content)
  else
    post_content = "{}"
  end
  log(bWriteLog and "logic_community.DoPostUGCCommunityUrl, post_content = " .. post_content)
  local func = function(success, data)
    log(bWriteLog and "logic_community.DoPostUGCCommunityUrlCallback success = " .. tostring(success) .. ", data = " .. data)
    if success then
      local dataInfo = json.decode(data)
      if dataInfo ~= nil then
        log_tree("dataInfo = ", dataInfo)
        if callback ~= nil then
          callback(true, dataInfo)
        end
        return
      end
    end
    if callback ~= nil then
      callback(false, nil)
    end
  end
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, post_header, post_content, nil, func)
end
function logic_community.OnUGCJumpUGCMainPanel(eventType, eventID, vars)
  log(bWriteLog and "[lucasji][logic_community] OnUGCJumpUGCMainPanel")
  if vars.author_state then
    local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
    LogicUGCCommunity:OnAuthorCallback(vars.author_state)
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:ShowMainUI({
    menuList = tostring(mode_selection_macro.Enum_TabID.UGC)
  })
end
function logic_community.OnUGCPlayModCallback(eventType, eventID, vars)
  log_tree(bWriteLog and "[lucasji][logic_community] logic_community.OnUGCPlayModCallback vars", vars)
  if vars.modId then
    local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
    LogicUGCCommunity:OnCommunityJumpToPlayMod(vars.modId, vars.return_url)
  end
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  AdjustSystem:ClearAdjustDeepLink()
end
function logic_community.OnUGCCommunityBackToMineWorksPanelCallback(eventType, eventID, vars)
  log(bWriteLog and "[lucasji][logic_community] OnUGCCommunityBackToMineWorksPanelCallback")
  local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
  LogicUGCCommunity:OnCommunityJumpToMineWorksPanel()
end
function logic_community.OnJumpFriendList(eventType, eventID, vars)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.OnJumpUrl(eventType, eventID, vars)
end
function logic_community.OnJumpModeSelection(eventType, eventID, vars)
end
function logic_community.OnJumpSeason(eventType, eventID, vars)
  log_tree("[v_vvjiali] logic_community.OnJumpSeason vars", vars)
  local params = {
    uid = vars and vars.uid,
    openid = vars and vars.openid
  }
  if not logic_community.IsCurLoginAccount(params) then
    log(bWriteLog and "[v_vvjiali] logic_community.OnJumpSeason not cur login account")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "[v_vvjiali] logic_community.OnJumpSeason not in lobby or  mainCity")
    ShowNotice(33631)
    return
  end
  local logic_season_util = require("client.logic.season.logic_season_util")
  if logic_season_util.IsModReady() then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP)
  end
end
function logic_community.OnJumpToBeginnerLevel(eventType, eventID, vars)
  log(bWriteLog and "logic_community.OnJumpToBeginnerLevel")
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
  UGCPublishHandler.send_ugc_get_tutorial_level_data_req(config_ugc_center.Config_UGC_Center_TutorialSource.club)
end
function logic_community.GetWoWMapStatusInfo(modIds, callback)
  if not modIds or #modIds == 0 then
    log_format("logic_community.GetWoWMapStatusInfo. modIds is invalid or empty")
    if callback then
      callback({
        results = {}
      })
    end
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local CalcAllResults = function()
    local results = {}
    for _, modId in ipairs(modIds) do
      if modId and 0 < modId then
        local modInfo = LogicUGC:GetModByAllCache(modId)
        results[modId] = logic_community._CalcWoWMapStatusInfo(modId, modInfo)
      end
    end
    return results
  end
  local ExistList, ReqModList = LogicUGC:BatchGetModInfo(modIds, LogicUGC.C_ModListTypes.Link, function(_, _, _, bHasMore)
    if bHasMore then
      return
    end
    if callback then
      callback({
        results = CalcAllResults()
      })
    end
  end)
  if (not ExistList or not next(ExistList)) and (not ReqModList or #ReqModList == 0) and callback then
    callback({
      results = {}
    })
  end
end
function logic_community._CalcWoWMapStatusInfo(modId, modInfo)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local state = LogicUGCResManager:GetStateByModID(UGCMacros.ENUM_DownloaderType.ModCopy, modId)
  local cSize, tSize = 0, 0
  if modInfo and modInfo.pub_mod_meta then
    cSize, tSize = LogicUGCResManager:GetResSize(UGCMacros.ENUM_DownloaderType.ModCopy, modInfo.pub_mod_meta)
  end
  log_format("logic_community._CalcWoWMapStatusInfo. modId=%d, state=%s, currentSize=%s, totalSize=%s", modId, state, cSize, tSize)
  return {
    modId = modId,
    state = state,
    currentSize = cSize,
    totalSize = tSize
  }
end
function logic_community.DownloadWoWMap(modId, callback)
  if not modId or modId <= 0 then
    log_format("logic_community.DownloadWoWMap. modId is invalid")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modInfo = LogicUGC:GetModByAllCache(modId)
  local doDownload = function(info)
    if not info or not info.pub_mod_meta then
      log_format("logic_community.DownloadWoWMap. modInfo is nil for modId=%d", modId)
      if callback then
        callback({modId = modId, success = false})
      end
      return
    end
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    LogicUGCResManager:DownloadRes(UGCMacros.ENUM_DownloaderType.ModCopy, info.pub_mod_meta)
    log_format("logic_community.DownloadWoWMap. start download modId=%d", modId)
    if callback then
      callback({modId = modId, success = true})
    end
  end
  if modInfo and modInfo.pub_mod_meta then
    doDownload(modInfo)
  else
    log_format("logic_community.DownloadWoWMap. cache miss, requesting modInfo from server for modId=%d", modId)
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    UGCModHandler.send_ugc_pub_mod_info_batch_req({modId}, UGCMacros.ENUM_MODE_TYPE.Link):Then(function(errCode, metaList, listType, typeParam)
      local fetchedModInfo = LogicUGC:GetModByAllCache(modId)
      doDownload(fetchedModInfo)
    end)
  end
end
function logic_community.PauseWoWMapDownload(modId)
  if not modId or modId <= 0 then
    log_format("logic_community.PauseWoWMapDownload. modId is invalid")
    return {modId = modId, success = false}
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modInfo = LogicUGC:GetModByAllCache(modId)
  if not modInfo or not modInfo.pub_mod_meta then
    log_format("logic_community.PauseWoWMapDownload. modInfo is nil for modId=%d", modId)
    return {modId = modId, success = false}
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  LogicUGCResManager:PauseRes(UGCMacros.ENUM_DownloaderType.ModCopy, modInfo.pub_mod_meta)
  log_format("logic_community.PauseWoWMapDownload. pause download modId=%d", modId)
  return {modId = modId, success = true}
end
function logic_community.GetTemplateMapStatusInfo(templateId, modId, callback)
  if not templateId or templateId <= 0 then
    log_format("logic_community.GetTemplateMapStatusInfo. templateId is invalid")
    return
  end
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  local modInfo = LogicUGCTemplate:ReadLocalMeta(templateId)
  if not modInfo then
    log_format("logic_community.GetTemplateMapStatusInfo. modInfo is nil for templateId=%d", templateId)
    if callback then
      callback({
        modId = modId,
        state = 0,
        currentSize = 0,
        totalSize = 0
      })
    end
    return
  end
  if not modId or modId == "" or modId == 0 then
    log_error("logic_community.GetTemplateMapStatusInfo. modId is invalid for templateId=%d", templateId)
    return
  end
  if not modInfo.base then
    log_error("logic_community.GetTemplateMapStatusInfo. modInfo.base is nil for templateId=%d", templateId)
    if callback then
      callback({
        modId = modId,
        state = 0,
        currentSize = 0,
        totalSize = 0
      })
    end
    return
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  modInfo.base.mod_id = modId
  modInfo.mod_id = modId
  local state = LogicUGCResManager:GetResState(UGCMacros.ENUM_DownloaderType.ModCopy, modInfo)
  local cSize, tSize = LogicUGCResManager:GetResSize(UGCMacros.ENUM_DownloaderType.ModCopy, modInfo)
  log_format("logic_community.GetTemplateMapStatusInfo. templateId=%d, modId=%s, state=%s, currentSize=%s, totalSize=%s", templateId, tostring(modId), tostring(state), tostring(cSize), tostring(tSize))
  if callback then
    callback({
      modId = modId,
      state = state,
      currentSize = cSize,
      totalSize = tSize
    })
  end
end
function logic_community.DownloadTemplateMap(templateId, modId, callback)
  if not templateId or templateId <= 0 then
    log_format("logic_community.DownloadTemplateMap. templateId is invalid")
    return
  end
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  local modInfo = LogicUGCTemplate:ReadLocalMeta(templateId)
  if not modInfo then
    log_format("logic_community.DownloadTemplateMap. modInfo is nil for templateId=%d", templateId)
    if callback then
      callback({modId = modId, success = false})
    end
    return
  end
  if not modId or modId == "" or modId == 0 then
    log_error("logic_community.DownloadTemplateMap. modId is invalid for templateId=%d", templateId)
    if callback then
      callback({modId = modId, success = false})
    end
    return
  end
  if not modInfo.base then
    log_error("logic_community.DownloadTemplateMap. modInfo.base is nil for templateId=%d", templateId)
    if callback then
      callback({modId = modId, success = false})
    end
    return
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  modInfo.base.mod_id = modId
  modInfo.mod_id = modId
  LogicUGCResManager:DownloadRes(UGCMacros.ENUM_DownloaderType.ModCopy, modInfo)
  log_format("logic_community.DownloadTemplateMap. start download templateId=%d, modId=%s", templateId, tostring(modId))
  if callback then
    callback({modId = modId, success = true})
  end
end
function logic_community.OnJumpUGCFavoritePanel(_, _, var)
  log(bWriteLog and "logic_community.OnJumpUGCFavoritePanel")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:EnterUGC()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local extraParam
  if var and var.return_url then
    extraParam = {
      return_url = var.return_url
    }
  end
  UIManager.ShowUI(UIManager.UI_Config.UGC_Main_Mine_Sub_UI, Config_UGC.Enum_MineTabID.MyCollection, extraParam)
end
function logic_community.OnJumpUGCAndStartMatch(_, _, var)
  if not var or not var.modId then
    log(bWriteLog and "logic_community.OnJumpUGCAndStartMatch var or var.modId is nil")
    return
  end
  local mod_id = tonumber(var.modId)
  log(bWriteLog and "logic_community.OnJumpUGCAndStartMatch modId:" .. tostring(mod_id))
  if not mod_id or mod_id < 0 then
    log(bWriteLog and "logic_community.OnJumpUGCAndStartMatch modId is invalid")
    return
  end
  local LobbySystem = require("client.logic.login.logic_lobby")
  if LobbySystem.isInMatch then
    ShowNotice(110017)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(500045)
    return false
  end
  if TeamUpNewSystem.IsMemberInSocialLand() then
    ShowNotice(48411)
    return false
  end
  logic_community.bWaitForMatch = not var.noMatch or tonumber(var.noMatch) ~= 1
  logic_community.bBackToCommunityTip = var.return_url
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  LogicUGCMatch:ReqChooseModForMatch(mod_id)
  local ExposePage = TLogEventDefine.UGC_Mod_Exposure_Community_Play
  if var.exposePage then
    ExposePage = tonumber(var.exposePage)
  end
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  Logic_UGC_TLog:SendModTLog(mod_id, ExposePage)
  Logic_UGC_TLog:SendInteractionTLog(UGCMacros.ENU_UGC_TLOG_REACH_TYPE.SELECT, mod_id)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SELECT_MOD)
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  LogicUGCModRank:SelectRankList(mod_id)
end
function logic_community.OnUGCMatchEnterMod()
  if not logic_community.bWaitForMatch then
    log(bWriteLog and "logic_community.OnUGCMatchEnterMod not bWaitForMatch, skip")
    return
  end
  log(bWriteLog and "logic_community.OnUGCMatchEnterMod ready to start")
  logic_community.bWaitForMatch = false
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if UGCPlayHallRoom then
    if UGCPlayHallRoom:GetRoomInfo() then
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHOW_PLAY_HALL_ROOM_UI, "Lobby")
      return
    elseif UGCPlayHallRoom:CheckPendingMatchState() then
      return
    end
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local ugcMatchInfo = LogicUGCMatch:HasUGCMatchInfo()
  if not ugcMatchInfo then
    log(bWriteLog and "logic_community.OnUGCMatchEnterMod ugcMatchInfo is nil, skip")
    return
  end
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  logic_season_guide_manager:RecordClassicRank(false)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission(true) then
    return
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local status = MatchSystem.nMatchStatus
  log(bWriteLog and "logic_community.OnUGCMatchEnterMod status = " .. tostring(status))
  logic_community.OnClickEntryForUGC(status)
end
function logic_community.OnClickEntryForUGC(status)
  log(bWriteLog and "logic_community.OnClickEntryForUGC status = " .. tostring(status))
  if status == ENUM_MatchStatus.Not then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local FinishCallback = function()
      logic_community.CheckEntry(status)
    end
    if LogicUGC:ShowAutoTranslateCheckWindow(FinishCallback) == false then
      logic_community.CheckEntry(status)
    end
  else
    logic_community.CheckEntry(status)
  end
end
function logic_community.CheckEntry(status)
  log(bWriteLog and "logic_community.CheckEntry status = " .. tostring(status))
  if status == ENUM_MatchStatus.Not or status == ENUM_MatchStatus.Ready then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.RecordDsVersion()
    if PufferDownloader.CheckAllMapPak(nil, logic_community.OnCheckAllMapPakResult) then
      logic_community.OnClickEntryInternal()
    end
    return
  end
  logic_community.OnClickEntryInternal()
end
function logic_community.OnCheckAllMapPakResult(bOK)
  log(bWriteLog and "logic_community.OnCheckAllMapPakResult bOK = " .. tostring(bOK))
  if bOK then
    logic_community.OnClickEntryInternal()
  end
end
function logic_community.OnClickEntryInternal()
  log(bWriteLog and "logic_community.OnClickEntryInternal")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.bIsMatchingTrainMode = false
  MatchModeMgrSystem.bIsMatchingSocialIsland = false
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local status = MatchSystem.nMatchStatus
  log(bWriteLog and "logic_community.OnClickEntryInternal status = " .. tostring(status))
  if status == ENUM_MatchStatus.Not then
    if TeamUpNewSystem.IsTeamLeader() then
      logic_community.StartMatch()
    else
      logic_community.ReadyMatch()
    end
  elseif status == ENUM_MatchStatus.Ready then
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    if MentorSystem.mentor_prematch_state then
      MentorSystem.send_mentor_prematch_cancel_req()
      return
    end
    if TeamUpNewSystem.IsTeamLeader() then
      logic_community.StartMatch()
    else
      logic_community.CancelReady()
    end
  elseif status == ENUM_MatchStatus.Matching then
    logic_community.CancelMatch()
  elseif status == ENUM_MatchStatus.Success then
    if TeamUpNewSystem.IsTeamLeader() then
      logic_community.StartMatch()
    else
      logic_community.ReadyMatch()
    end
  end
end
function logic_community.StartMatch()
  log(bWriteLog and "logic_community.StartMatch")
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.CloseTeamUpSideBar()
  local StartMatchCallback = function()
    log(bWriteLog and "logic_community.StartMatchCallback")
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.bShowMatchTimeoutNotice = false
    MatchSystem.SetSameLanguageMatchTimeOut(false)
    BattleResult.IgnoreDSError = false
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    if LogicUGCMatch:HasUGCMatchInfo() then
      log(bWriteLog and "logic_community.StartMatchCallback LogicUGCMatch:HasUGCMatchInfo")
      local editMatchInfo = LogicUGCMatch:GetEditMatchInfo()
      if editMatchInfo then
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        local bInTeam = TeamUpNewSystem.IsInTeam()
        local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
        if bInTeam then
          LogicUGCCRUD:EnterTeamCreate(editMatchInfo.slot, editMatchInfo.base.template_id)
        else
          LogicUGCCRUD:ReqStartEditGame(editMatchInfo.slot, true)
        end
      else
        LogicUGCMatch:ReqStartGame("community")
      end
    elseif LogicUGCMulti.bIsBundleMatch then
      log(bWriteLog and "logic_community.StartMatchCallback LogicUGCMulti.bIsBundleMatch")
      LogicUGCMulti:StartMatch()
    else
      log(bWriteLog and "logic_community.StartMatchCallback else")
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInOneMoreGameTeam() then
    log(bWriteLog and "logic_community.StartMatchCallback TeamUpNewSystem.IsInOneMoreGameTeam")
    local title = LocUtil.GetLocalizeResStr(101001)
    local msg = LocUtil.GetLocalizeResStr(8028)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, StartMatchCallback)
    return
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsBLUEHOLE = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  log(bWriteLog and "logic_community.StartMatch bIsBLUEHOLE = " .. tostring(bIsBLUEHOLE))
  if not ZoneSystem.nChooseZoneID or ZoneSystem.nChooseZoneID == 0 then
    if GlobalData.IsJapanOrKorea() then
      ZoneSystem.on_select_zone_req(6)
      StartMatchCallback()
    elseif bIsBLUEHOLE then
      ZoneSystem.on_select_zone_req(3)
      StartMatchCallback()
    else
      local ShowZoneOption = function()
        UIManager.ShowUI(UIManager.UI_Config.Setting_ChangeServer, function()
        end)
      end
      local title = LocUtil.GetLocalizeResStr(101001)
      local msg = LocUtil.GetLocalizeResStr(7568)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, msg, ShowZoneOption)
    end
    return
  end
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local isChoosingZoneAccess = logic_zone_delay.IsChoosingZoneAccess()
  local isMatchVersion = Client.IsMatchVersion()
  if isChoosingZoneAccess or bIsBLUEHOLE or isMatchVersion then
    StartMatchCallback()
  else
    logic_zone_delay.ShowDelayTips(StartMatchCallback)
  end
end
function logic_community.ReadyMatch()
  log(bWriteLog and "logic_community.ReadyMatch")
  local reqStatus = ENUM_MatchStatus.Ready
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  TeamupHandler.send_team_change_member_status_request(reqStatus, DeviceOSInfo.InfoList)
end
function logic_community.CancelReady()
  log(bWriteLog and "logic_community.CancelReady")
  local reqStatus = ENUM_MatchStatus.Not
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  TeamupHandler.send_team_change_member_status_request(reqStatus, DeviceOSInfo.InfoList)
end
function logic_community.CancelMatch()
  log(bWriteLog and "logic_community.CancelMatch")
  LobbySystem.on_match_cancel_req()
end
return logic_community