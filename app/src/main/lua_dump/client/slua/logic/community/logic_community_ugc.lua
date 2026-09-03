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
  UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {
    menuList = tostring(mode_selection_macro.Enum_TabID.UGC)
  })
end
function logic_community.OnUGCPlayModCallback(eventType, eventID, vars)
  log_tree(bWriteLog and "[lucasji][logic_community] logic_community.OnUGCPlayModCallback vars", vars)
  if vars.modId then
    local LogicUGCCommunity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCommunityManager)
    LogicUGCCommunity:OnCommunityJumpToPlayMod(vars.modId)
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
  UIManager.ShowUI(UIManager.UI_Config.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP)
end
function logic_community.OnJumpToBeginnerLevel(eventType, eventID, vars)
  log(bWriteLog and "logic_community.OnJumpToBeginnerLevel")
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  local config_ugc_center = require("client.slua.logic.ugc.center.config_ugc_center")
  UGCPublishHandler.send_ugc_get_tutorial_level_data_req(config_ugc_center.Config_UGC_Center_TutorialSource.club)
end
function logic_community.GetWoWMapStatusInfo(modId, callback)
  if not modId or modId <= 0 then
    log_format("logic_community.GetWoWMapStatusInfo. modId is invalid")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modInfo = LogicUGC:GetModByAllCache(modId)
  if modInfo and modInfo.pub_mod_meta then
    local result = logic_community._CalcWoWMapStatusInfo(modId, modInfo)
    if callback then
      callback(result)
    end
  else
    log_format("logic_community.GetWoWMapStatusInfo. cache miss, requesting modInfo from server for modId=%d", modId)
    local UGCModHandler = require("client.network.Protocol.UGCModHandler")
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    UGCModHandler.send_ugc_pub_mod_info_batch_req({modId}, UGCMacros.ENUM_MODE_TYPE.Pub):Then(function(errCode, metaList, listType, typeParam)
      local fetchedModInfo = LogicUGC:GetModByAllCache(modId)
      local result = logic_community._CalcWoWMapStatusInfo(modId, fetchedModInfo)
      if callback then
        callback(result)
      end
    end)
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
    UGCModHandler.send_ugc_pub_mod_info_batch_req({modId}, UGCMacros.ENUM_MODE_TYPE.Pub):Then(function(errCode, metaList, listType, typeParam)
      local fetchedModInfo = LogicUGC:GetModByAllCache(modId)
      doDownload(fetchedModInfo)
    end)
  end
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
return logic_community