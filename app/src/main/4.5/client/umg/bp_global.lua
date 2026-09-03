GlobalData = GlobalData or {BluetoothOption = -1, LastSceneName = ""}
BP_Platform = 0
BP_Share_Platform = 0
BP_StartUpType = 0
BP_IsAppleAudit = false
BP_IOS_CHECK = false
BP_REVIEW_SVR_ENABLE_GM = false
BP_IS_EXTERNAL_CHANNEL = false
BP_Global_AndroidKey_IsValid = true
BP_Global_AdvertiseNeedShowtask = false
local AdvertiseUnitID = ""
BP_Global_PreviewItemId = 0
function bp_global_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_global, {
    {
      Path = "/Game/UMG/UI_Logic/Global_Bp.Global_Bp_C",
      Container = "Default",
      ZOrder = 0
    }
  }, {"Lobby", "Login"}, true, false)
end
function GlobalData.OnModePostSwitch(preState, nextState)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    CDataTable.ReleaseDataStructMaps()
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  if nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    if UIManager.IsUIShow(UIManager.UI_Config.video_player_system) then
      UIManager.CloseUI(UIManager.UI_Config.video_player_system)
    end
    GlobalData.StopLobbyBGM()
  elseif nextState == GameStatus.Login then
    local GameFrontendHUD = slua_GameFrontendHUD:GetUtils()
    GameFrontendHUD:ClearAllSceneCameras()
  elseif nextState == GameStatus.Lobby and GameStatus.Fighting == GlobalData.LastSceneName then
    log(bWriteLog and "GlobalData.LastSceneName:" .. tostring(GlobalData.LastSceneName))
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.bIsFightingBackLobby = true
  end
  GlobalData.LastSceneName = nextState
end
function GlobalData.StopLobbyBGM()
  log(bWriteLog and "GlobalData.StopLobbyBGM")
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  musicManager:StopMusic()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_MUSIC_OFF)
  GlobalData.EnterFightStopMusic()
  local logic_lobby_music = require("client.slua.logic.lobby.logic_lobby_music")
  logic_lobby_music.ClearPlayerTicker()
end
function GlobalData.RestoreLobbyBGM()
  log(bWriteLog and "GlobalData.RestoreLobbyBGM")
  local logic_main_city_music = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_music)
  local status = logic_main_city_music:GetEnterMainCityMode()
  log(bWriteLog and "GlobalData.RestoreLobbyBGM enterMainCityMode = " .. status)
  if GameStatus.IsIn2DLobby() and status == 0 then
    log(bWriteLog and "GlobalData.RestoreLobbyBGM in lobby")
    local logic_community = require("client.slua.logic.community.logic_community")
    if logic_community.isStayInH5 then
      log(bWriteLog and "GlobalData.RestoreLobbyBGM in H5")
      return
    end
    local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
    if logicCreateRole.IsInCreateRolePhase() then
      log(bWriteLog and "GlobalData.RestoreLobbyBGM in create role phase")
      return
    end
    if GameStatus.IsInMainCity() then
      log(bWriteLog and "GlobalData.RestoreLobbyBGM in main city")
      logic_main_city_music:PlayMusic()
      return
    else
      logic_main_city_music:PauseMusic()
    end
    local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
    if logic_xmission_main.IsInXMission() then
      log(bWriteLog and "GlobalData.RestoreLobbyBGM in XMission")
      GlobalData.StopLobbyBGM()
      local audio_util = require("client.common.audio_util")
      audio_util.PlayAudio(sound_config.TPlan_BGM)
    else
      log(bWriteLog and "GlobalData.RestoreLobbyBGM not in XMission")
      local logic_lobby_music = require("client.slua.logic.lobby.logic_lobby_music")
      logic_lobby_music.SwitchLobbyBGM()
      EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_MUSIC_ON)
    end
  end
end
function GlobalData.OnLogin()
  local roleData = LobbySystem.roleData
  local channel = Client.GetLoginChannel(NetInterface)
  log(bWriteLog and "GetLoginChannel:" .. channel)
  GlobalData.SetPlatform(channel)
  if roleData.startup_type ~= nil then
    GlobalData.SetStartUpType(roleData.startup_type)
  end
  if roleData.apple_audit ~= nil then
    GlobalData.SetIsAppleAudit(roleData.apple_audit)
  else
    GlobalData.SetIsAppleAudit(false)
  end
end
function GlobalData.SetPlatform(platform)
  BP_Platform = platform
  log(bWriteLog and "SetPlatform " .. BP_Platform)
  GlobalData.HideWidgetsByTourist()
end
function GlobalData.GetPlatform()
  return BP_Platform
end
function GlobalData.SetStartUpType(iType)
  BP_StartUpType = iType
  log(bWriteLog and "SetStartUpType " .. BP_StartUpType)
end
function GlobalData.SetIsAppleAudit(bValue)
  if bValue == true then
    BP_IsAppleAudit = bValue
  elseif GlobalData.IsIOSCheck() then
    BP_IsAppleAudit = true
  else
    BP_IsAppleAudit = BP_IS_EXTERNAL_CHANNEL
  end
  log(bWriteLog and "SetIsAppleAudit " .. tostring(BP_IsAppleAudit))
end
function EventSetInfo_Push()
end
function EventFetchInfo()
end
function CvmRotateClockwise(Yaw, DeltaTime)
  return Yaw + DeltaTime * 90.0
end
function ShowTipsWhenParamNotInStandard(url)
  log(bWriteLog and "ShowTipsWhenParamNotInStandard, url = " .. tostring(url))
  local standard = {
    cr = true,
    language = true,
    region = true,
    game_area = true,
    gameid = true,
    nickname = true,
    head_pic = true,
    game_season = true,
    sTicket = true,
    version = true,
    area_id = true,
    sign = true,
    openid = true,
    uid = true,
    client = true,
    never_adjust = true
  }
  local param = {}
  local StringUtil = require("common.string_util")
  local temp = StringUtil.ParseURLParams(url)
  for k, v in pairs(temp) do
    if standard[k] ~= true then
      table.insert(param, k)
      log_warning("ShowTipsWhenParamNotInStandard, \"" .. k .. "\" is not a standard url parameter, please confirm!")
    end
  end
  if 0 < #param then
    local GlobalHandler = require("client.network.Protocol.GlobalHandler")
    GlobalHandler.send_nonstandard_url_parameter(param, url)
  end
end
local TryTwitterJumpAppUrl = function(appUrl, webViewUrl)
  log(bWriteLog and "GlobalData:TryJumpAppUrl appUrl = " .. tostring(appUrl))
  log(bWriteLog and "GlobalData:TryJumpAppUrl webViewUrl = " .. tostring(webViewUrl))
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  if appUrl and string.find(appUrl, ShareSource.Twitter) then
    local hasInitTwitter = Client.IsInstallTwitter(NetInterface)
    log(bWriteLog and "GlobalData:TryJumpAppUrl hasInitTwitter = " .. tostring(hasInitTwitter))
    if hasInitTwitter then
      Client.LaunchUrl(appUrl)
    elseif webViewUrl and webViewUrl ~= "" then
      WebviewSDK:OpenURL(webViewUrl)
    end
  elseif webViewUrl and webViewUrl ~= "" then
    WebviewSDK:OpenURL(webViewUrl)
  end
end
function GlobalData.JumpUrl(url, jumpSource)
  if not url or type(url) ~= "string" or url == "" then
    return
  end
  if jumpSource ~= nil and jumpSource ~= "" then
    local JumpSourceMacros = require("client.slua.config.ClientMacros.JumpSourceMacros")
    local StringUtil = require("common.string_util")
    url = StringUtil.AppendUrlParam(url, JumpSourceMacros.URL_KEY, jumpSource)
  end
  log(bWriteLog and "GlobalData:JumpUrl, url = " .. tostring(url))
  local JumpUtils = require("client.logic.store.jump_utils")
  if url == nil then
    log(bWriteLog and "url == nil")
    return
  end
  if JumpUtils.IsGameJumpUrl(url) then
    GlobalData.JumpGameUrl(url)
  elseif JumpUtils.IsPanDoraJumpUrl(url) then
    local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    log(bWriteLog and "[ :EventJumpUrl JumpUtils.IsPanDoraJumpUrl")
    pandoraSystem.TryJumpUrl(url)
  elseif JumpUtils.IsTwitterJumpUrl(url) then
    TryTwitterJumpAppUrl(url, nil)
    GlobalData.StopLobbyBGM()
  else
    GlobalData.JumpWebUrl(url)
  end
end
function GlobalData.JumpGameUrl(url)
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  url = webModule:URLDecode(url)
  url = GlobalData.PreprocessUrl(url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  log_tree(bWriteLog and "GlobalData.JumpGameUrl params:", params)
  local moduleId
  if params.module and params.module ~= "" then
    moduleId = tonumber(params.module)
  end
  if IsWoWEditor and moduleId == BP_ENUM_MODULE_ACTIVITY then
    ShowNotice(116009)
    return
  end
  local activityID
  local collectResourceList = {}
  if params.activityid and params.activityid ~= "" then
    activityID = tonumber(params.activityid)
    if activityID then
      local logic_activity_mgr = require("client.slua.logic.activity.logic_activity_mgr")
      local act = logic_activity_mgr.GetActivityByID(activityID)
      if not act then
        if moduleId == BP_ENUM_MODULE_BUY_UPASS_ACT then
          ShowNotice(73203)
        elseif params.tipsid and params.tipsid ~= "" then
          local tipsID = tonumber(params.tipsid)
          ShowNotice(tipsID)
        else
          ShowNotice(108101)
        end
        return
      else
        local nStart, nEnd = act.StartTime, act.EndTime
        local TimeUtil = require("client.common.time_util")
        local now = TimeUtil.GetServerTimeInSec()
        if nStart > now then
          ShowNotice(7809)
          return
        elseif nEnd < now then
          if moduleId == BP_ENUM_MODULE_BUY_UPASS_ACT then
            ShowNotice(73203)
          else
            ShowNotice(4002)
          end
          return
        end
      end
      collectResourceList = LobbySystem.GetActivityDownLoadListByModuleID(moduleId, activityID) or {}
    end
  elseif moduleId == BP_ENUM_MODULE_XSUIT_SPIN then
    collectResourceList = LobbySystem.GetActivityDownLoadListByModuleID(moduleId) or {}
  end
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  CreateRoomSystem.ParseThirdPartyFullCallBackLink(params, url)
  log(bWriteLog and "moduleId:" .. tostring(moduleId))
  if not GlobalData.ActResourceDownloaded(collectResourceList, moduleId, activityID) then
    log(bWriteLog and string.format("EventJumpUrl not download"))
    return
  end
  local store_jump_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_jump_manager)
  if store_jump_manager:CheckBannerInSupply(params) then
    store_jump_manager:JumpSupplyBanner(params)
    return
  end
  if params.from == "app_widget" then
    local logic_community = require("client.slua.logic.community.logic_community")
    logic_community.SetJumpKind("app_widget")
  end
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(moduleId, params)
end
function GlobalData.ActResourceDownloaded(curList, moduleId, activityId, downLoadType)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local newList = next(curList) and curList or PufferManager.GetDownloadListByModuleIDActivityID(moduleId, activityId)
  if not next(newList) then
    EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_GAME_URL_DOWNLOAD_BREAK, false, moduleId, activityId)
    return true
  end
  log_tree(bWriteLog and "GlobalData.ActResource Collect : ", newList)
  downLoadType = downLoadType or PufferConst.ENUM_DownloadType.ODPAK
  log(bWriteLog and "xcc GlobalData.ActResourceDownloaded downLoadType : " .. tostring(downLoadType))
  local state = PufferManager.GetState(downLoadType, newList)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local title = LocUtil.GetLocalizeResStr(5077)
    local curSize, size = PufferManager.GetSize(downLoadType, newList)
    size = size - curSize
    size = downLoadType == PufferConst.ENUM_DownloadType.ODPACK and size or size / PufferConst.MB
    local strSize = string.format("%.2f MB", size)
    local askTips = LocUtil.LocalizeResFormat(7921, strSize)
    local ok = function()
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      PufferManager.Download(downLoadType, newList, PufferTlog.Enum_TLog_From.Click, nil, {bSkipPopUp = true, bFirst = true})
    end
    EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_GAME_URL_DOWNLOAD_BREAK, true, moduleId, activityId)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, askTips, ok)
    return false
  end
  EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_JUMP_GAME_URL_DOWNLOAD_BREAK, false, moduleId, activityId)
  return true
end
function GlobalData.GetBannerDependList(activityId)
  local list = {}
  local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
  local bannerDataList = logic_lobby_mid_banner.GetSidebarBannerList(true)
  for _, data in pairs(bannerDataList) do
    if string.find(data.JumpUrl, tostring(activityId)) and data.Depends and data.Depends ~= "" then
      log(bWriteLog and string.format("GlobalData.JumpGameUrl Depends:%s", tostring(data.Depends)))
      local StringUtil = require("common.string_util")
      local splitRet = StringUtil.Split(data.Depends, "|")
      for i, v in pairs(splitRet) do
        if tonumber(v) then
          table.insert(list, tonumber(v))
        elseif StringUtil.Ends(tostring(v), ".mp4") then
          table.insert(list, DataMgr.GetVideoDownloadPath(v))
        else
          table.insert(list, v)
        end
      end
      break
    end
  end
  return list
end
function GlobalData.JumpWebUrl(url)
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  webModule:JumpToWebPage(url)
end
function GlobalData.PreprocessUrl(url)
  if string.find(url, "invitecode") then
    local tempUrl = string.gsub(url, " ", "&")
    tempUrl = string.gsub(tempUrl, "+", "&")
    return tempUrl
  end
  return url
end
function GlobalData.CheckCanJumpByTypeID(itemID, jumpTypeID)
  local JumpUtils = require("client.logic.store.jump_utils")
  jumpTypeID = tonumber(jumpTypeID)
  log(bWriteLog and "GlobalData:CheckCanJumpByTypeID itemID, jumpTypeID" .. tostring(itemID) .. ", " .. tostring(jumpTypeID))
  local jumpCfg = CDataTable.GetTableData("JumpConfig", jumpTypeID)
  if jumpCfg == nil then
    log(bWriteLog and "GlobalData:CheckCanJumpByTypeID jumpCfg = nil")
    return false
  end
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(jumpCfg.JumpUrl)
  local moduleId = tonumber(params.module)
  if moduleId and moduleId == BP_ENUM_MODULE_UNKNOW_PASS then
    local seasonId = tonumber(params.seasonId)
    if seasonId and seasonId == UnknowPassSystem.Season then
      return true
    end
    return false
  end
  if jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.SupplyOrStoreReward then
    local _itemID = tonumber(params.itemId)
    if _itemID == nil then
      return false
    end
    local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local itemJumpCfg = ItemUpgradeMgr:GetItemSourceJumpConfig(_itemID)
    if itemJumpCfg == nil then
      return false
    end
    local jumpStr = itemJumpCfg.JumpType or ""
    if jumpStr == "" then
      return false
    end
    local jumpTypeList = StringUtil.Split(jumpStr, "|")
    for i, jType in ipairs(jumpTypeList) do
      local nJumpID = tonumber(jType)
      if nJumpID ~= JumpUtils.ENUM_JUMP_TYPE.SupplyOrStoreReward then
        return GlobalData.CheckCanJumpByTypeID(_itemID, nJumpID)
      end
    end
    return false
  end
  local LuckUtil = require("client.slua.logic.lobby_activity.luck_util")
  if jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.Store then
    local shopInfo = JumpUtils.FindJumpInfoAllByToModelId(itemID, JumpUtils.MODEL_ID_STORE)
    log_tree("GlobalData:CheckCanJumpByTypeID shopInfo", shopInfo)
    if shopInfo == nil then
      log(bWriteLog and "GlobalData:CheckCanJumpByTypeID--new shopInfo is nil , itemID is :" .. tostring(itemID))
      return false
    end
    return true
  elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.Supply then
    local supplyInfo = JumpUtils.FindJumpInfoAllByToModelId(itemID, JumpUtils.MODEL_ID_SUPPLY)
    log(bWriteLog and "GlobalData:CheckCanJumpByTypeID supplyInfo", supplyInfo)
    local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
    if supplyInfo == nil or supply_collect_chest_manager:GetShopTabInfoByShopId(supplyInfo.Tab1) == nil then
      log(bWriteLog and "GlobalData:CheckCanJumpByTypeID--new supplyInfo is nil , itemID is :" .. tostring(itemID))
      return false
    end
    return true
  elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.JKStore then
    local shopInfo = JumpUtils.FindJumpInfoAll(itemID)
    log_tree("GlobalData:CheckCanJumpByTypeID shopInfo", shopInfo)
    if shopInfo == nil then
      log(bWriteLog and "GlobalData:CheckCanJumpByTypeID--new shopInfo is nil , itemID is :" .. tostring(itemID))
      return false
    end
    return true
  elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.Pass or jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.BP then
    return false
  elseif jumpTypeID == 86 and not LuckUtil.isJapan() then
    return false
  elseif jumpTypeID == 85 and not GlobalData.IsJapanOrKorea() then
    return false
  elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.SmallRPTask then
    local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
    return Logic_SmallRP:GetIsOpen()
  elseif JumpUtils.IsHttpOrHttpsJumpUrl(jumpCfg.JumpUrl) then
    local pattern = "timeRange=(%d+)_(%d+)"
    local startTime, endTime = string.match(jumpCfg.JumpUrl, pattern)
    if startTime and endTime then
      startTime = tonumber(startTime) or 0
      endTime = tonumber(endTime) or 0
      local TimeUtil = require("client.common.time_util")
      return TimeUtil.UnixTimeBetween(startTime, endTime) == 0
    end
    return true
  elseif 0 < string.len(jumpCfg.JumpUrl) and LobbySystem.CheckUrlCanJump(jumpCfg.JumpUrl) == true then
    return true
  end
  return false
end
function GlobalData.JumpByTypeID(itemID, jumpTypeID, from, bJumpSupplyFirst)
  local JumpUtils = require("client.logic.store.jump_utils")
  jumpTypeID = tonumber(jumpTypeID)
  log(bWriteLog and "GlobalData:JumpByTypeID itemID, jumpTypeID" .. tostring(itemID) .. ", " .. tostring(jumpTypeID))
  local jumpCfg = CDataTable.GetTableData("JumpConfig", jumpTypeID)
  if jumpCfg == nil then
    return false
  end
  if JumpUtils.CheckExistJumpType(jumpTypeID) then
    local bSupplyOrStore = JumpUtils.MODEL_ID_STORE
    if jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.Supply then
      bSupplyOrStore = JumpUtils.MODEL_ID_SUPPLY
    elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.JKStore then
      bSupplyOrStore = bJumpSupplyFirst and JumpUtils.MODEL_ID_SUPPLY or JumpUtils.MODEL_ID_STORE
    elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.Pass or jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.BP then
      return false
    elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.SmallRPTask then
      GlobalData.JumpUrl(jumpCfg.JumpUrl)
      return true
    elseif jumpTypeID == JumpUtils.ENUM_JUMP_TYPE.SupplyOrStoreReward then
      local StringUtil = require("common.string_util")
      local params = StringUtil.ParseURLParams(jumpCfg.JumpUrl)
      local _itemID = tonumber(params.itemId)
      if _itemID == nil then
        return false
      end
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      local itemJumpCfg = ItemUpgradeMgr:GetItemSourceJumpConfig(_itemID)
      if itemJumpCfg == nil then
        return false
      end
      local jumpStr = itemJumpCfg.JumpType or ""
      if jumpStr == "" then
        return false
      end
      local StringUtil = require("common.string_util")
      local jumpTypeList = StringUtil.Split(jumpStr, "|")
      for i, jType in ipairs(jumpTypeList) do
        local nJumpID = tonumber(jType)
        if nJumpID ~= JumpUtils.ENUM_JUMP_TYPE.SupplyOrStoreReward then
          GlobalData.JumpByTypeID(_itemID, nJumpID, from, bJumpSupplyFirst)
          return true
        end
      end
    end
    local params = JumpUtils.FindJumpInfoFirst(itemID, bSupplyOrStore)
    if params ~= nil then
      if params.moduleId == JumpUtils.MODEL_ID_STORE then
        local jump_utils = require("client.logic.store.jump_utils")
        jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, params)
      else
        if from and from == BP_ENUM_MODULE_ITEM_UPGRADE then
          params.from = StoreConst.source_UpgradeJumpToCrate
        end
        local jump_utils = require("client.logic.store.jump_utils")
        jump_utils.OpenJumpModule(BP_ENUM_MODULE_SUPPLY, params)
      end
      return true
    else
      return false
    end
  elseif JumpUtils.IsHttpOrHttpsJumpUrl(jumpCfg.JumpUrl) then
    local url = jumpCfg.JumpUrl
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    url = webModule:AddParameterByPersonalInfo(url, true, true)
    GlobalData.JumpWebUrl(url)
  else
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    local frame = store_supply_manager:GetCurrentFrame()
    if frame ~= nil then
      frame:CloseSelf()
    end
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(jumpCfg.JumpUrl)
    local seasonId = tonumber(params.seasonId)
    local bIsCanJumpRP = false
    if seasonId and seasonId == UnknowPassSystem.Season then
      bIsCanJumpRP = true
    end
    if string.len(jumpCfg.JumpUrl) > 0 and LobbySystem.CheckUrlCanJump(jumpCfg.JumpUrl) == true or bIsCanJumpRP then
      GlobalData.JumpUrl(jumpCfg.JumpUrl)
      return true
    end
  end
  return false
end
function EventAndroidQuitGame()
  log(bWriteLog and "EventAndroidQuitGame")
  local clickOkCallback = function()
    local logic_community = require("client.slua.logic.community.logic_community")
    logic_community.SendQuitGame()
    GameStatus.QuitGame()
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, LocUtil.GetLocalizeResStr(301168), clickOkCallback, nil)
end
function OnAppDidEnterBackground()
  log_shipping_client("bp_global OnAppDidEnterBackground")
end
function OnApplicationDeactivated()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  log_shipping_client("bp_global OnApplicationDeactivated")
  gem_report_utils.ClearAllWorkTime()
  local LobbyGmSystem = RequireBlackList("blacklist.slua.logic.gm_data.lobby_gm_logic")
  if LobbyGmSystem then
    LobbyGmSystem.OnApplicationDeactive()
  end
  local curStatus = GameStatus.GetGameStatus()
  if curStatus == GameStatus.Lobby then
    EventSystem:postEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED)
  end
  EventSystem:postEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED_EX)
  Client.CrashLog(NetInterface, 4, "App", "Deactivated")
end
function OnApplicationReactivated()
  log_shipping_client("bp_global OnApplicationReactivated")
  local curStatus = GameStatus.GetGameStatus()
  log_shipping_client("OnApplicationReactivated, curStatus = " .. tostring(curStatus))
  if GameStatus.IsInLobbyOrMainCity() then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    local bEnterMainCityLoading = Lobby_Main_City_Enter.bEnterMainCityLoading
    log(bWriteLog and "bp_global OnApplicationReactivated bEnterMainCityLoading = " .. tostring(bEnterMainCityLoading))
    if not bEnterMainCityLoading then
      local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
      if AdjustSystem.HasCheckJump then
        AdjustSystem:CheckAdjustJumpTo(true)
        local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
        PushSystem:CheckNotificationJumpTo(true)
      end
    end
    local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
    LuckAirDropSystem.OnApplicationReactivated()
    local LobbyGmSystem = RequireBlackList("blacklist.slua.logic.gm_data.lobby_gm_logic")
    if LobbyGmSystem then
      LobbyGmSystem.OnApplicationReactivated()
    end
    EventSystem:postEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED)
  end
  EventSystem:postEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX)
  Client.CrashLog(NetInterface, 4, "App", "Reactivated")
  if Client and Client.IsDevelopment and Client.IsDevelopment() then
    local bOk, MobileHotUpdate = pcall(RequireBlackList, "blacklist.editor.debugger.mobile_hot_update")
    if bOk and MobileHotUpdate and MobileHotUpdate.DoHotUpdate then
      xpcall(MobileHotUpdate.DoHotUpdate, utility and utility.ErrorMessageHandler or function(err)
        log_warning(bWriteLog and "bp_global OnApplicationReactivated MobileHotUpdate.DoHotUpdate error: " .. tostring(err))
      end)
    else
      log_warning(bWriteLog and "bp_global OnApplicationReactivated load mobile_hot_update failed: " .. tostring(MobileHotUpdate))
    end
  end
  local StoreIndiaUtils = require("client.logic.store.store_india_utils")
  if StoreIndiaUtils.bGotoH5 == true then
    StoreIndiaUtils.bGotoH5 = false
    local CentauriHandler = require("client.network.Protocol.CentauriHandler")
    CentauriHandler.send_imobile_notify_client_charge(0)
  end
end
function OnApplicationEnterBackground()
  log(bWriteLog and "OnApplicationEnterBackground")
  local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
  PushSystem:OnApplicationEnterBackground()
end
function OnApplicationEnterForeground()
  log(bWriteLog and "OnApplicationEnterForeground")
  CentauriManager.OnApplicationEnterForeground()
  local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
  PushSystem:OnApplicationEnterForeground()
end
function OnApplicationWillTerminate()
  log(bWriteLog and "OnApplicationWillTerminate")
  local logic_download_delete = require("client.slua.logic.download.delete.logic_download_delete")
  logic_download_delete.UploadGemPufferSizeInfo("OnApplicationWillTerminate")
end
BP_GEM_REPORT_SUBEVENT = ""
BP_GEM_REPORT_PARA1 = ""
BP_GEM_REPORT_PARA2 = ""
function EventSendClickGemReport()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent(BP_GEM_REPORT_SUBEVENT, BP_GEM_REPORT_PARA1, BP_GEM_REPORT_PARA2)
end
function EventClickLobbyEventGemReport()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportLobbyClickEvent(BP_GEM_REPORT_SUBEVENT, BP_GEM_REPORT_PARA1, BP_GEM_REPORT_PARA2)
end
BP_BA_BUTTON_TYPE = 1
BP_BA_REASON = 1
function EventSendBAReport()
  ClientSendBAReport(BP_BA_BUTTON_TYPE, BP_BA_REASON)
end
function ClientSendBAReport(button_type, reason, str, IsImmediateReport)
  log(bWriteLog and "[YY]button_click_log button_type:" .. tostring(button_type) .. " reason:" .. tostring(reason) .. " str:" .. tostring(str))
  if not ModuleManager.DataModuleConfig then
    return
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  if IsImmediateReport then
    BasicDataTLogReport:ReportImmediate(button_type, reason, str)
  else
    BasicDataTLogReport:ReportDelay(button_type, reason, str)
  end
end
function ClientSendTLogReport(button_type, reason, str, IsImmediateReport)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  log(bWriteLog and "[YY]ClientSendTLogReport button_type:" .. tostring(button_type) .. " reason:" .. tostring(reason) .. " str:" .. tostring(str))
  if not gem_report_utils.GetReportLobbyEventEnable() then
    return
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  if IsImmediateReport then
    BasicDataTLogReport:ReportImmediate(button_type, reason, str)
  else
    BasicDataTLogReport:ReportDelay(button_type, reason, str)
  end
end
function EventGlobalCloseItemTips()
  UIManager.CloseUI(UIManager.UI_Config.itemtips_panel)
end
function EventShowPlatQQStartup()
end
function EventShowPlatWXStartup()
end
function EventShowPlatIconTips()
  if BP_Platform == BP_ENUM_PLAYFORM_WX then
    ShowNotice(660011)
  end
end
BP_CHECK_MENU_OPEN_ID = 0
BP_CHECK_MENU_OPEN_RESULT = false
function EventCheckIfMenuOpen()
  BP_CHECK_MENU_OPEN_RESULT = LobbySystem.CheckOpen(BP_CHECK_MENU_OPEN_ID)
end
function GlobalData.IsIOSCheck()
  return BP_IOS_CHECK
end
function GlobalData.SaveIOSCheck(info)
  if info ~= nil then
    if info.ReviewSvrEnableGM ~= nil and info.ReviewSvrEnableGM == "1" then
      log(bWriteLog and "GlobalData.SaveIOSCheck info.ReviewSvrEnableGM: " .. info.ReviewSvrEnableGM)
      BP_REVIEW_SVR_ENABLE_GM = true
    end
    if info.IOSCheck ~= nil and info.IOSCheck == "1" then
      log(bWriteLog and "GlobalData.SaveIOSCheck info.IOSCheck11: " .. info.IOSCheck)
      BP_IOS_CHECK = true
      EventSystem:postEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK)
    end
  end
end
function GlobalData.IsReviewSvrEnableGM()
  return BP_REVIEW_SVR_ENABLE_GM
end
function GlobalData.IsPlatformTourist()
  return BP_Platform == BP_ENUM_PLAYFORM_TOURIST
end
function GlobalData.HideWidgetsByTourist()
  if not GlobalData.IsPlatformTourist() then
    return
  end
end
BP_STRUCT_NATION_SWITCH = {
  Updated = false,
  NationAllSwitch = false,
  NationBattleSwitch = false,
  NationRankSwitch = false
}
function EventFetchNationSwitch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local switch = login_module.nation_switch
  if switch then
    BP_STRUCT_NATION_SWITCH.Updated = switch.updated
    BP_STRUCT_NATION_SWITCH.NationAllSwitch = switch.NationAllSwitch
    BP_STRUCT_NATION_SWITCH.NationBattleSwitch = switch.NationBattleSwitch
    BP_STRUCT_NATION_SWITCH.NationRankSwitch = switch.NationRankSwitch
  end
end
GLOBAL_USE_ITEM = 0
function GlobalData.OpenUseItemsUI(instID)
  GLOBAL_USE_ITEM = instID
  EventGlobalUseItem()
end
function EventGlobalUseItem()
  local wardrobe_item_use_utils = require("client.slua.logic.wardrobe.wardrobe_item_use_utils")
  wardrobe_item_use_utils.UseItem(GLOBAL_USE_ITEM)
end
BP_GlobalSwitchCameraIndex = 0
function GlobalData.SwitchSceneCameraByIndex(idx)
  BP_GlobalSwitchCameraIndex = idx
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera_Only(BP_GlobalSwitchCameraIndex)
end
function GlobalData.SetAndroidKeyIsValid(bValid)
  BP_Global_AndroidKey_IsValid = bValid
end
function GlobalData.LoadAdvertise()
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:SetUserId(tostring(DataMgr.roleData.openID))
  GlobalData.LoadAdvertiseBp()
  EventSystem:postEvent(EVENTTYPE_ADVERTISE, EVENTID_ADVERTISE_LOAD)
end
function GlobalData.LoadAdvertiseByType(type)
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:SetUserId(tostring(DataMgr.roleData.openID) .. ";" .. tostring(1))
  GlobalData.LoadAdvertiseBp()
  EventSystem:postEvent(EVENTTYPE_ADVERTISE, EVENTID_ADVERTISE_LOAD)
end
function GlobalData.TryLoadAdvertise()
  GlobalData.TryLoadAdvertiseBp()
end
function GlobalData.PlayAdvertise()
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:SetUserId(tostring(DataMgr.roleData.openID))
  GlobalData.PlayAdvertiseBp()
end
function GlobalData.PlayAdvertiseByType(type)
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  if AdvertiseSdk:IsAdvertiseLoaded() then
    log(bWriteLog and "GlobalData.PlayBonusAdvertise " .. tostring(DataMgr.roleData.openID) .. ";" .. tostring(1))
    GlobalData.PlayAdvertiseBp()
  else
    log(bWriteLog and "GlobalData.PlayBonusAdvertise not loaded")
    GlobalData.LoadAdvertiseByType(type)
    ShowNotice(6506)
  end
end
function GlobalData.GetLocalizeStringWithNum(id, NumStringIndex, String1, String2, String3, String4)
  return GlobalData.GetLocalizeStringWithNumBp(id or 0, NumStringIndex or 0, String1 or "", String2 or "", String3 or "", String4 or "")
end
function GlobalData.GetLocalizeStringWithString(string, NumStringIndex, String1, String2, String3, String4)
  if string == nil then
    return ""
  end
  local index = NumStringIndex or 0
  local str1 = String1 or ""
  local str2 = String2 or ""
  local str3 = String3 or ""
  local str4 = String4 or ""
  local IntlHelper = import("IntlHelper")
  return IntlHelper.GetLocalizeStringWithString(string, index, str1, str2, str3, str4)
end
function GlobalData.GetMallShow10Animation()
  return GlobalData.GetMallShow10AnimationBp()
end
function GlobalData.SaveMallShow10Animation(isCheck)
  GlobalData.SaveMallShow10AnimationBp(isCheck)
end
function GlobalData.GetRechargePayPos()
  return GlobalData.GetRechargePayPosBp()
end
function GlobalData.SaveRechargePayPos(RechargePayPos)
  GlobalData.SaveRechargePayPosBp(RechargePayPos)
end
function GlobalData.IsJapanOrKorea()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return PublishRegionMacros.IsJapanOrKorea()
end
function GlobalData.IsBLUEHOLE()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return PublishRegionMacros.IsBLUEHOLE()
end
function GlobalData.ShowCountryAreaUI(OpenType, SelectNation)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return
  end
  log(bWriteLog and "GlobalData.ShowCountryAreaUI:" .. tostring(OpenType) .. ",SelectNation:" .. SelectNation)
  UIManager.ShowUI(UIManager.UI_Config.country_area_popup, OpenType, SelectNation)
end
function GlobalData.AddUTCSubffix(text, isUTC)
  if GlobalData.IsJapanOrKorea() then
    if isUTC then
      return LocUtil.LocalizeResFormat(7248, text)
    else
      return LocUtil.LocalizeResFormat(7249, text)
    end
  end
  return text
end
function EventComMsgBoxSluaClickUrl(MetaData)
  log_tree("EventComMsgBoxSluaClickUrl MetaData:", MetaData)
  EventSystem:postEvent(EVENTTYPE_HYPERLINK, EVENTID_HLINK_COMMSGBOXSLUA, MetaData)
end
function GlobalData.SetShadowDistanceScale(scale)
  GlobalData.SetShadowDistanceScaleBp(scale)
end
function GlobalData.GetShadowDistanceScale()
  return GlobalData.GetShadowDistanceScaleBp()
end
function GlobalData.SaveBluetoothOpt(bluetoothOption)
  log(bWriteLog and "GlobalData.SaveBluetoothOpt:" .. tostring(bluetoothOption))
  GlobalData.BluetoothOption = bluetoothOption
end
function GlobalData.GetNationSwitch(name)
  EventFetchNationSwitch()
  if BP_STRUCT_NATION_SWITCH.Updated then
    if name == "All" then
      return BP_STRUCT_NATION_SWITCH.NationAllSwitch
    elseif name == "Rank" then
      return BP_STRUCT_NATION_SWITCH.NationRankSwitch
    elseif name == "Battle" then
      return BP_STRUCT_NATION_SWITCH.NationBattleSwitch
    end
  else
    local switchStr = string.format("Nation%sSwitch", name)
    local cfg = CDataTable.GetTableData("SystemConfig", switchStr)
    if cfg and cfg.ConfigValue == 1 then
      return true
    end
  end
  return false
end
function GlobalData.GetNationInfo(nationCode)
  local cfg = CDataTable.GetTableData("RegionConfig", nationCode)
  if cfg then
    return cfg
  else
    cfg = CDataTable.GetTableData("RegionConfig", "G1")
    return cfg
  end
end
function GlobalData.EnterFightStopMusic()
  local AkGameplayStatics = import("AkGameplayStatics")
  local BusinessHelper = import("BusinessHelper")
  local UIUtil = require("client.common.ui_util")
  local UiRoot = UIUtil.GetWidgetByName("bp_global", "Global_Bp")
  if UiRoot then
    local asset_util = require("common.asset_util")
    local akEvent = asset_util.GetAssetSync("/Game/WwiseEvent/UI/Play_Music_Stop.Play_Music_Stop")
    AkGameplayStatics.PostEventAtLocation(akEvent, FVector(0, 0, 0), FRotator(0, 0, 0), "", UiRoot)
  end
end
function GlobalData.LoadAdvertiseBp()
  EventFetchInfo()
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:LoadAdvertise(AdvertiseUnitID)
end
function GlobalData.SetAdvertiseUnitID(id)
  AdvertiseUnitID = id
end
function GlobalData.TryLoadAdvertiseBp()
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  local IsLoadAd = AdvertiseSdk:IsAdvertiseLoaded()
  if IsLoadAd then
    EventFetchInfo()
    AdvertiseSdk:LoadAdvertise(AdvertiseUnitID)
  end
end
function GlobalData.PlayAdvertiseBp()
  local IMSDKHelper = import("IMSDKHelper")
  local ImSdkObj = IMSDKHelper.GetInstance()
  ImSdkObj:PlayAdvertise()
end
function GlobalData.GetLocalizeStringWithNumBp(id, NumStringIndex, String1, String2, String3, String4)
  local IntlHelper = import("IntlHelper")
  local Tips = IntlHelper.GetLocalizeStringWithNum(id, NumStringIndex, String1, String2, String3, String4)
  return Tips
end
function GlobalData.GetMallShow10AnimationBp()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  return SettingConfig.MallShowGet10Animation
end
function GlobalData.SaveMallShow10AnimationBp(isCheck)
  local GameBackendHUD = import("GameBackendHUD")
  local UIUtil = require("client.common.ui_util")
  local BackendHudObject = GameBackendHUD.GetInstance()
  local UiRoot = UIUtil.GetWidgetByName("bp_global", "Global_Bp")
  local FrontHudObject
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.MallShowGet10Animation = isCheck
  if UiRoot then
    FrontHudObject = BackendHudObject:GetFirstGameFrontendHUD(UiRoot)
    FrontHudObject:BeginModifyUserSettings()
    FrontHudObject:FinishModifyUserSettings()
  end
end
function GlobalData.GetRechargePayPosBp()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  log(bWriteLog and "[PXY]GetRechargePayPosBp")
  return SettingConfig.RechargePosSave
end
function GlobalData.SaveRechargePayPosBp(RechargePayPos)
  local GameBackendHUD = import("GameBackendHUD")
  local UIUtil = require("client.common.ui_util")
  local BackendHudObject = GameBackendHUD.GetInstance()
  local UiRoot = UIUtil.GetWidgetByName("bp_global", "Global_Bp")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.RechargePosSave = RechargePayPos
  local FrontHudObject
  if UiRoot then
    FrontHudObject = BackendHudObject:GetFirstGameFrontendHUD(UiRoot)
    FrontHudObject:BeginModifyUserSettings()
    FrontHudObject:FinishModifyUserSettings()
  end
end
function GlobalData.SetShadowDistanceScaleBp(scale)
  local kismet_string_library = require("common.kismet_string_library")
  local BpGlobalString = kismet_string_library.Conv_FloatToString(scale)
  local BpDistanceScale = "r.Shadow.DistanceScale " .. BpGlobalString
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local UIUtil = require("client.common.ui_util")
  local UiRoot = UIUtil.GetWidgetByName("bp_global", "Global_Bp")
  if UiRoot then
    KismetSystemLibrary.ExecuteConsoleCommand(UiRoot, BpDistanceScale, nil)
  end
  log(bWriteLog and "[PXY]SetShadowDistanceScaleBp")
end
function GlobalData.GetShadowDistanceScaleBp()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local BpDistanceScaleValue = KismetSystemLibrary.GetConsoleVariableFloatValue("r.Shadow.DistanceScale")
  BpDistanceScaleValue = BpDistanceScaleValue or 0.0
  return BpDistanceScaleValue
end
return GlobalData