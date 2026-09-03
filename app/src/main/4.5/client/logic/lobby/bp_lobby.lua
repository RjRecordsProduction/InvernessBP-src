LobbyUI = LobbyUI or {
  lobbySkinTimer = nil,
  lastDay = -1,
  isShowLeagueTips = false,
  countDownTimer = nil,
  countDownTime = 0,
  TimeToCountDown = 0,
  IsTimeToEnter = false,
  onButtonMysteriousShopClickDelegate = nil,
  currentStatus = "",
  canReportOneExposure = {},
  lobby_callbackentrance = nil,
  Clock_PassUnlock = nil,
  LobbyModeSwitched = false,
  isDownloaderVisible = false,
  isDownloaderFold = true,
  pb_preUpdateTime = 0
}
local EmulatorCheck_FirstinLobby = true
local UserHideLobbyAutoAdaptBox = false
DataMgrInit = false
function LobbyUI.InitOnlyOne()
end
function LobbyUI.OnModePreSwitch(preState, nextState)
  log(bWriteLog and "LobbyUI.OnModePreSwitch " .. tostring(nextState))
  if nextState ~= GameStatus.Lobby then
    local logicCornerDot = require("client.slua.umg.lobby.lobby_corner_dot")
    logicCornerDot.ClearData()
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    ModelDisplayer.Destroy()
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    TeamAvatarManager.Destroy()
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.DestroyAllAvatar()
  else
    Client.SetDumpShaderCompile(0)
  end
end
function LobbyUI.CollectOpenReadInfo(nextState)
  if Client.IsReleaseVersion(NetInterface) then
    log(bWriteLog and "Client.CollectOpenReadInfo return for IsReleaseVersion...")
    return
  end
  log(bWriteLog and "Client.DumpOpenReadCollect Beg")
  Client.DumpOpenReadCollect(GameFrontendHUD, Client.ProjectSavedDir() .. "ResUseColect/OpenReadList.log")
  log(bWriteLog and "Client.DumpOpenReadCollect End")
end
function LobbyUI.ExportLocalUsage(nextState)
  local ExportLocalUsageOpen = HDmpveRemote.HDmpveRemoteConfigGetInt("ExportLocalUsageOpen", 0)
  log_format("[LobbyUI.ExportLocalUsage] ExportLocalUsageOpen:  %s", ExportLocalUsageOpen)
  if ExportLocalUsageOpen <= 0 then
    log_format("[LobbyUI.ExportLocalUsage] return for ExportLocalUsageOpen :  %s", ExportLocalUsageOpen)
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local key_0 = PlayerPrefsSystem.ePlayerPrefsType.eExportLocalUsageOpenVersion
  local key = "ExportLocalUsageOpen_" .. tostring(ExportLocalUsageOpen)
  log(bWriteLog and "LobbyUI.ExportLocalUsage key_0 = " .. tostring(key_0))
  log(bWriteLog and "LobbyUI.ExportLocalUsage key = " .. tostring(key))
  local versionCfg = PlayerPrefsSystem.LoadFileToTable_N(key_0) or {}
  if versionCfg[key] then
    log(bWriteLog and "LobbyUI.ExportLocalUsage return for exist key = " .. key)
    return
  end
  log("[LobbyUI.ExportLocalUsage] Client.ExportLocalUsage beg")
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  gameInstance:ExecuteCMD("ios.SkipConvertAbsolutePath", 1)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    Client.ExportLocalUsage_2(Client.GetPureIOSDocumentsDirectory(), Client.ProjectSavedDir() .. "/Logs/LocalStorageDump_document.txt")
    Client.ExportLocalUsage_2(Client.GetPureIOSLibraryDirectory(), Client.ProjectSavedDir() .. "/Logs/LocalStorageDump_library.txt")
    Client.ExportLocalUsage_2(Client.GetPureIOSTmpDirectory(), Client.ProjectSavedDir() .. "/Logs/LocalStorageDump_tmp.txt")
  else
    Client.ExportLocalUsage_2(Client.GetRootDir(), Client.ProjectSavedDir() .. "/Logs/LocalStorageDump_aos.txt")
  end
  gameInstance:ExecuteCMD("ios.SkipConvertAbsolutePath", 0)
  log("[LobbyUI.ExportLocalUsage] Client.ExportLocalUsage end")
  versionCfg[key] = true
  PlayerPrefsSystem.SaveTableToFile_N(versionCfg, key_0)
  log(bWriteLog and "LobbyUI.ExportLocalUsage SaveTableToFile_N key = " .. tostring(key))
end
function LobbyUI.OnModePostSwitch(preState, nextState)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  if not LobbySystem then
    return
  end
  LobbySystem.ExposureReportWhenChangeScene(nextState)
  LobbySystem.ReportLobbyStayTime()
  LobbyUI.CollectOpenReadInfo(nextState)
  LobbyUI.ExportLocalUsage(nextState)
  if GameStatus.IsInLobbyOrMainCity() then
    FuncUtil.AddCrashContextMainFlow("70")
  end
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  local time_ticker = require("common.time_ticker")
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  if nextState == GameStatus.Lobby then
    log_shipping_client("[Login process]bp_lobby_OnModeSwitched begin")
    LobbySystem.isCanDeleteOp = true
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    TeamAvatarManager.Init()
    local JumpUtils = require("client.logic.store.jump_utils")
    JumpUtils.Init()
    ui_jump_manager.Init()
    Client.EnableAutoObjectRefreshStage(true)
    BattleResultUI.ScrollBox_MissionList = nil
    DeathMatchResultUI.ScrollBox_MissionList = nil
    if IsWoWEditor then
      LobbyUI.SwitchToWoWEditorLobby()
    else
      LobbyUI.SwitchToLobby()
    end
  else
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, LobbyUI.DepotDataChange)
    local ItemPrewViewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
    ItemPrewViewSystem.CloseItemPreviewPanel()
    if UIManager.IsUIShow(UIManager.UI_Config.ingame_process_webview) then
      UIManager.CloseUI(UIManager.UI_Config.ingame_process_webview)
    end
    ui_jump_manager.Stop()
  end
  Client.ShrinkUObjectHashTables()
  if nextState == GameStatus.Login then
    LobbySystem.ResetMatchInfo()
    Client.USFSCacheSysContextSwitchWrite(true)
    local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
    LogicTeamUpSideBar.CloseLobbyFriendEntrance()
    DataMgr.NewerHaveShowEightDay = false
    PufferDownloader.DownloadRewardCfg = {}
    PufferDownloader.RecommendReddot = false
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    LuckybackActivitySystem.ResetDataWhileLogin()
    local handler = require("client.network.Protocol.EveryDayPackHandler")
    if handler.activity_data then
      handler.activity_data = nil
    end
    local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
    RoleInfoAvatarFrameSystem.SetHasGetData(false)
  elseif nextState == GameStatus.Fighting then
    log(bWriteLog and "LobbyUI.OnModePostSwitch Fighting")
    if GameStatus.IsInMainCity() then
      ui_jump_manager.Init()
    else
      Client.USFSCacheSysContextSwitchWrite(false)
      local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
      LogicTeamUpSideBar.CloseLobbyFriendEntrance()
      UIManager.CloseUI(UIManager.UI_Config.esport_center)
      UIManager.CloseUI(UIManager.UI_Config.egame_center)
      Client.StopH5Downloading()
      local logic_chat_extra = require("client.slua.logic.lobby_chat.logic_chat_extra")
      logic_chat_extra.RecordVoiceMicTLog(true)
    end
    PufferDownloader.SwitchToFighting()
  elseif nextState == GameStatus.Lobby then
    PufferDownloader.SwitchToLobby()
    Client.USFSCacheSysContextSwitchWrite(true)
    if PufferDownloader.BattleDownloadSwitch then
      PufferDownloader.SetBattleDownloadSwitch(false)
    end
    if ScriptHelperEngine.IsLowMemoryDevice() then
      local gc_util = require("common.gc_util")
      gc_util.FullGC()
    end
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if PufferDownloader.ClearPufferInGame and PufferDownloader.bStopPufferDownloader and Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and ScriptHelperEngine.IsLowMemoryDevice() then
      time_ticker.AddTimerOnce(10, function()
        local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
        local PufferConfig = PufferConfigSys:GetDefaultConfig()
        Client.ReInitializePuffer(GameFrontendHUD, false, PufferConfig.MaxDownloadsPerTask, PufferConfig.MaxDownTask, PufferConfig.MaxDownloadSpeed, true, false, 1, PufferConfig.PufferDownloadFuncDict, PufferConfig.HttpDnsType, PufferConfig.DownloadStageType, PufferConfig.DownloadEngineType)
        PufferDownloader.bStopPufferDownloader = false
        log(bWriteLog and "ReInitializePuffer")
        local gc_util = require("common.gc_util")
        gc_util.FullGC()
        Client.RecoverShrunkODPaksBins()
        LobbySystem.LoadAmendODs(LobbySystem.roleData.encryption_info)
      end)
    elseif PufferDownloader.bStopPufferDownloader then
      local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
      local PufferConfig = PufferConfigSys:GetDefaultConfig()
      Client.ReInitializePuffer(GameFrontendHUD, false, PufferConfig.MaxDownloadsPerTask, PufferConfig.MaxDownTask, PufferConfig.MaxDownloadSpeed, true, false, 1, PufferConfig.PufferDownloadFuncDict, PufferConfig.HttpDnsType, PufferConfig.DownloadStageType, PufferConfig.DownloadEngineType)
      PufferDownloader.bStopPufferDownloader = false
      log(bWriteLog and "ReInitializePuffer during lobby")
    end
    local logic_chat_extra = require("client.slua.logic.lobby_chat.logic_chat_extra")
    logic_chat_extra.CheckAndTLogMicVoice()
    log(bWriteLog and "Client.GetODPaksFileUseTime 1111")
    Client.GetODPaksFileUseTime("Logs/FileUseTime.txt")
  end
end
function LobbyUI.SwitchToLobby()
  local time_ticker = require("common.time_ticker")
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkEventStart(logic_cost_collector.EVENT_KEYS.CREATE_MAIN_UI)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Main_UIBP)
  logic_cost_collector:MarkEventEnd(logic_cost_collector.EVENT_KEYS.CREATE_MAIN_UI)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    time_ticker.AddTimerOnce(6, function()
      local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
      LobbyThemeManager:ShowTheme()
    end)
  else
    local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
    LobbyThemeManager:ShowTheme()
  end
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  log(bWriteLog and "[qintong ] OnModeSwitched in lobby enter_guide.executeFightGuide =  " .. tostring(enter_guide.executeFightGuide))
  if enter_guide.executeFightGuide then
  else
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if not LogicTxMissionMain.IsInXMission() then
      time_ticker.AddTimerOnce(0, function()
        LoadingSystem.RefreshLoadPercent(1)
      end)
    end
  end
  log(bWriteLog and "OnModeSwitched in lobby!!!")
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_LOBBY_LOAD_DONE)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.CreateTeamUI()
  logic_cost_collector:MarkEventStart(logic_cost_collector.EVENT_KEYS.CREATE_AVATAR)
  LobbySystem.CreatLobbyAvatar()
  logic_cost_collector:MarkEventEnd(logic_cost_collector.EVENT_KEYS.CREATE_AVATAR)
  local MainCityConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
  if not MainCityConfig.bOptimization then
    local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
    Lobby_Main_City.PreLoadChar()
  end
  LobbySystem.RefreshBannerDisplayList()
  local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
  if LuckAirDropSystem._DelayLobbyCreate then
    local rs = coroutine.resume(LuckAirDropSystem._DelayLobbyCreate)
    if not rs then
      log(bWriteLog and "no regist LuckAirDropSystem DelayLobbyCreate")
    end
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  device_module:CheckWakeupDataForTeamup()
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
  LobbySystem.UpdateSettingRedPoint()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT)
  local showTip = slua_GameFrontendHUD:GetShouldShowAdaptTipInLobby()
  if showTip and not UserHideLobbyAutoAdaptBox then
    local gem_report_utils = require("client.logic.store.gem_report_utils")
    local title = LocUtil.GetLocalizeResStr(101001)
    local tips = DataMgr.GetMsgByIDForBattleText(30083)
    ClientSendTLogReport(TLogEventDefine.SmoothSelfAdapt, 0, gem_report_utils.SubEventName_SelfAdapt_Show)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tips, LobbyUI.OpenAutoAdaptSwitch, LobbyUI.HideAutoAdaptBox)
  end
  local everyDayUCSystem = require("client.logic.everyday_pack.logic_everyday_uc")
  everyDayUCSystem.IsRedPoint()
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
  if not PushSystem:IsLaunchedByNotification() then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    time_ticker.AddTimerOnce(1, function()
      if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(10007) then
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHaveClickTaskGuide)
        if table == nil or table.HaveClickTaskGuide == false then
          UIManager.ShowUI(UIManager.UI_Config.newbie_lobby_task)
        end
      end
      local showRPGuide = false
      local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
      if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(10600) and not LogicTxMissionMain.IsInXMission() then
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHaveClickRPGuide)
        if table == nil or table.HaveClickRPGuide == false then
          showRPGuide = true
          UIManager.ShowUI(UIManager.UI_Config.newbie_lobby_rp)
        end
      end
      if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(20000) and not DataMgr.NewerHaveShowEightDay and not showRPGuide and DataMgr.IsEightDaySlpaed then
        local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
        if logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
          local logic_newbie_reward_eight_day = require("client.slua.logic.activity.newbie.logic_newbie_reward_eight_day")
          logic_newbie_reward_eight_day.ShowUI()
        else
          local EightDaySystem = require("client.slua.logic.activity.newbie.logic_newbie_eight_day")
          EightDaySystem.ShowUI()
        end
        DataMgr.NewerHaveShowEightDay = true
      end
      if LogicNewbie.IsNewbie() then
        local newbieState = LogicNewbie.GetNewbieGuideState(20002)
        if newbieState == ENUM_NewbieState.Force then
          UIManager.ShowUI(UIManager.UI_Config.newbie_mode_select_entry, true)
        elseif newbieState == ENUM_NewbieState.Week then
          UIManager.ShowUI(UIManager.UI_Config.newbie_mode_select_entry, false)
        end
      end
      LogicNewbie.ShowSlideGuide()
      local logic_main_city_newbie_guide_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_newbie_guide_entry)
      logic_main_city_newbie_guide_entry:ShowMainCityEntryGuide()
      local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
      local spData = RoleInfoMainSystem.GetSuperData()
      LobbySystem.LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_ROLE_INFO, spData.historyRed)
    end)
  end
  time_ticker.AddTimerOnce(1, function()
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if lobbyMain then
      local midBannerUI = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Activity_UIBP)
      if midBannerUI ~= nil and midBannerUI.UpdateShowRedpoint then
        midBannerUI:UpdateShowRedpoint()
      end
    end
  end)
  time_ticker.AddTimerOnce(1, function()
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      DataMgr.roleData.uid
    }, nil, Enum_PROFILE_REPORT_CFG.LOBBY)
  end, false, true)
  local SceneSwitchLatenQueueSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SceneSwitchLatenQueueSystem)
  if SceneSwitchLatenQueueSystem.bHasStoreData == false then
    SceneSwitchLatenQueueSystem.bHasStoreData = true
    time_ticker.AddTimerOnce(5, function()
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      if not GlobalData.IsJapanOrKorea() then
        store_supply_manager:GetTabList(StoreConst.store_tab)
      end
      store_supply_manager:ReqOptimizeSupplyInfo()
    end, false, true)
  end
  time_ticker.AddTimerOnce(1, function()
    LobbySystem.query_gm_request()
    LobbySystem.isCanDeleteOp = true
  end, false, true)
  time_ticker.AddTimerOnce(2, function()
    local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
    if not RoleInfoAvatarFrameSystem.HasGetData() then
      RoleInfoAvatarFrameSystem.SetHasGetData(true)
      RoleInfoAvatarFrameSystem.get_avatar_box_list()
      local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
      RoleInfoAvatarSystem.send_get_user_avatar_list()
    end
  end, false, true)
  local EmulatorSystem = require("client.logic.login.logic_emulator")
  EmulatorSystem.FirstCheckEmulatorTip()
  EmulatorSystem.CheckEmulatorTip()
  time_ticker.AddTimerOnce(0.1, function()
    LobbySystem.CheckLeagueGameSubMode()
    local TournamentIntroduceSystem = require("client.slua.logic.tournament.logic_tournament_introduce")
    TournamentIntroduceSystem.UpdateRedPoint()
  end)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.ReqGetSeasonRechargeInfo(true)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_CHANGE, LobbyUI.DepotDataChange)
  local rankInspectSystem = require("client.slua.logic.rank.logic_rank_inspect")
  rankInspectSystem.PopAfterSettlement()
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  NewCharacterNetSystem:ShowCharacterLevelUpView()
  log_shipping_client("[Login process]bp_lobby_OnModeSwitched end")
  local OnGetSocialTable = function(tableName, data)
    local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform")
    for id, info in pairs(data or {}) do
      SettingPlatformSystem.platformInfo[id] = info
      SettingPlatformSystem.OnGetPlatformInfo()
    end
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.social_authorize_config, OnGetSocialTable)
  local logic_backend_translation = require("client.slua.logic.backend_translation.logic_backend_translation")
  logic_backend_translation.RequestBackendTranlationPatch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.bIsInitLogin then
    log(bWriteLog and "LobbyUI.OnModePostSwitch ShowVNGPersonalInfo")
    LobbySystem.ShowVNGPersonalInfo()
  end
end
function LobbyUI.SwitchToWoWEditorLobby()
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:BlockSlap()
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkEventStart(logic_cost_collector.EVENT_KEYS.CREATE_MAIN_UI)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Main_UIBP)
  logic_cost_collector:MarkEventEnd(logic_cost_collector.EVENT_KEYS.CREATE_MAIN_UI)
  LobbySystem.query_gm_request()
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  if not RoleInfoAvatarFrameSystem.HasGetData() then
    RoleInfoAvatarFrameSystem.SetHasGetData(true)
    RoleInfoAvatarFrameSystem.get_avatar_box_list()
    local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
    RoleInfoAvatarSystem.send_get_user_avatar_list()
  end
  local OnGetSocialTable = function(tableName, data)
    local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform")
    for id, info in pairs(data or {}) do
      SettingPlatformSystem.platformInfo[id] = info
      SettingPlatformSystem.OnGetPlatformInfo()
    end
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.social_authorize_config, OnGetSocialTable)
  local logic_backend_translation = require("client.slua.logic.backend_translation.logic_backend_translation")
  logic_backend_translation.RequestBackendTranlationPatch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.bIsInitLogin then
    log(bWriteLog and "LobbyUI.OnModePostSwitch ShowVNGPersonalInfo")
    LobbySystem.ShowVNGPersonalInfo()
  end
end
function LobbyUI.DepotDataChange(eventType, eventID, vars)
  log(bWriteLog and "LobbyUI.DepotDataChange")
  local LogicHalloweenVehicle = require("client.logic.activity.logic_halloween_vehicle")
  if vars ~= nil then
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    for i, v in pairs(vars) do
      if v.res_id == LogicHalloweenVehicle.TicketId then
        LogicHalloweenVehicle.UpdateShowRedPoint()
      end
      if v.res_id == wardrobe_macro.ENUM_WardrobePropResId.VS_TEAM_RATING_PROTECT_TIMES_CARD then
        local ui_doublecard_tips = UIManager.GetUI(UIManager.UI_Config.lobby_doublecard_buff_panel)
        if ui_doublecard_tips and ui_doublecard_tips:IsShow() then
          local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
          ui_doublecard_tips:ShowArenaTimesCard()
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT)
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  if currentTime - LobbyUI.pb_preUpdateTime > 60 then
    LobbyUI.pb_preUpdateTime = currentTime
  end
end
local ReleaseAllData = function(eventType, eventID, vars)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  log(bWriteLog and "ReleaseAllData " .. eventType)
  if eventType ~= EVENTTYPE_LOGIN then
    return
  end
  if eventID == EVENTID_BACKLOGIN then
    log(bWriteLog and "ReleaseAllData")
    LobbyUI.ReleaseData()
    logic_achievement_float_tip.HasClickedIngore = false
    LobbyUI.isShowLeagueTips = false
  end
end
function LobbyUI.ReleaseData()
  log(bWriteLog and "lobby release data")
  DataMgr.ResetData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.ClearData()
  BP_LevelChange = false
  local LevelUpSystem = require("client.logic.levelup.logic_levelup")
  LevelUpSystem.IsLevelUp = false
  LevelUpSystem.IsPveLevelUp = false
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.ResetRedPointData()
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  RoleInfoAvatarSystem.ResetRedPointData()
  local ESportRankSystem = require("client.slua.logic.esport.logic_esport_rank")
  ESportRankSystem.ClearData()
  local LogicExchangeShop = require("client.slua.logic.esport.logic_exchange_shop")
  LogicExchangeShop.ClearData()
  local BottomRightMessageBoxSystem = require("client.logic.common.logic_bottomright_messagebox")
  BottomRightMessageBoxSystem.ResetData()
  local BottomRightTipsSystem = require("client.slua.logic.activity.logic_bottomright_tips")
  BottomRightTipsSystem.ResetData()
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.ResetVoiceData()
  local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
  LogicXMissionBlackMarket.ClearData()
  local ExploreSystem = require("client.slua.logic.explore.logic_explore")
  ExploreSystem.Destroy()
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  LogicXMissionBeginnerGuide.ClearData()
  local DataMigrationSystem = require("client.slua.logic.data_migration.data_migration_logic")
  DataMigrationSystem.ResetData()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.PauseAllDownloadTasks()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.ClearData()
  local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
  KeyPlayVideoSystem.Reset()
  local logic_weapon_diy = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  logic_weapon_diy:Reset()
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  SubscribeCarnivalSystem.ResetData()
  local curStatus = GameStatus.GetGameStatus()
  if curStatus ~= GameStatus.Login then
    Client.CloseH5WebView(GameFrontendHUD)
  end
  local logic_backend_translation = require("client.slua.logic.backend_translation.logic_backend_translation")
  logic_backend_translation.ResetData()
end
local OnFaceSlapEnd = function()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  LogicNewbie.ShowSlideGuide()
end
function LobbyUI.Init()
  log_shipping_client("[Login process] lobby init")
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_MATCH_REDPOINT)
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, ReleaseAllData)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, OnFaceSlapEnd)
end
function LobbyUI.HandleUPassActRedPoint()
  local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
  UnknowPassBuyActSystem.GetNeedShowReddot()
end
function LobbyUI.HandleEverydayPackActRedPoint()
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  local red = EveryDayPackSystem.HasRedPoint()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_EVERYDAY_PACK, red)
  local isRed = EveryDayPackSystem.IsEverydayV2RedPoint()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_EVERYDAY_PACK_V2, isRed)
end
function LobbyUI.CheckToReportTLog(url)
  url = GlobalData.PreprocessUrl(url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  if params.from then
    log(bWriteLog and "LobbyUI.CheckToReportTLog, from = " .. tostring(params.from))
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.DeepLinkCall, 0, params.from)
  end
end
function LobbyUI.OpenAutoAdaptSwitch()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  settingConfig.DeviceAutoAdaptEx = true
  ClientSendTLogReport(TLogEventDefine.SmoothSelfAdapt, 0, gem_report_utils.SubEventName_SelfAdapt_Confirm)
end
function LobbyUI.HideAutoAdaptBox()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  UserHideLobbyAutoAdaptBox = true
  ClientSendTLogReport(TLogEventDefine.SmoothSelfAdapt, 0, gem_report_utils.SubEventName_SelfAdapt_Cancel)
end
return LobbyUI