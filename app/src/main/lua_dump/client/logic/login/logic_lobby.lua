LobbySystem = LobbySystem or {
  isInMatch = false,
  statusReady = 1,
  statusUnready = 2,
  isNewPlayer = false,
  currentLobbyPlayerDataList = {},
  isWaittingEnterBattle = false,
  LobbyMenuOpenStatus = {},
  LobbyMenuOpenStatus_New = {},
  lastOpenCorpsTime = 0,
  activityDisplayDataList = {},
  uiRect = "0,0,0,0",
  sceenHoleRect = "0,0,0,0",
  forcedExitGameTimes = 0,
  is_DeathMatchMode = false,
  LobbyBubbleList = {},
  roleData = {},
  BattleItem = {
    itemid = 0,
    count = 0,
    MaxCount = 0,
    Describe = ""
  },
  isMentorMatch = false,
  isWaitToEnterGame = false,
  AvatarURL = nil,
  enterLobbyNum = 0,
  backLobbyNum = 0,
  EnterLobbyTime = 0,
  player_count = 0,
  canReportOneExposure = {},
  previousStatus = "",
  currentStatus = "",
  delayShowTipTimer = nil,
  bHaveBroadcastRedpoint = false,
  newGuideSwitch = false,
  enterNewbieLevel = false,
  activityBtnDisplayList = {},
  activityDownLoadList = {},
  ReportNetContinuousSaturateTimer = nil,
  vulkan_whitelist = 0,
  jump_whiteList = {
    [BP_ENUM_MODULE_SPECIAL_OFFER] = 1,
    [BP_ENUM_MODULE_SMALL_RP_BUY_SCORE] = 1,
    [BP_ENUM_MODULE_SMALL_RP_TASK] = 1,
    [BP_ENUM_MODULE_BLACK_FRIDAY_MAIN] = 1,
    [BP_ENUM_MODULE_ROLEINFO] = 1,
    [BP_ENUM_MODULE_CARD_COLLECTION_MAIN] = 1
  },
  isTodayFirstLogin = false
}
local TimeUtil = require("client.common.time_util")
local local LobbySystem.NewbieRoleState = {
  Init = 1,
  UpdateRole = 2,
  NormalRole = 3
}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local E_RegionTable = {
  [PublishRegionMacros.GLOBAL] = "GlobalMenuSwitchTable",
  [PublishRegionMacros.JAPAN] = "JKMenuSwitchTable",
  [PublishRegionMacros.KOREA] = "JKMenuSwitchTable",
  [PublishRegionMacros.BLUEHOLE] = "BlueHoleMenuSwitchTable",
  [PublishRegionMacros.TW] = "TWMenuSwitchTable",
  [PublishRegionMacros.VNG] = "VNGMenuSwitchTable",
  [PublishRegionMacros.CE] = "CEMenuSwitchTable",
  [PublishRegionMacros.FIT] = "GlobalMenuSwitchTable",
  [PublishRegionMacros.FITCE] = "CEMenuSwitchTable"
}
local Enum_LobbyDownloadResType = {
  Theme = 1,
  PlayerRole = 2,
  EntryAction = 3
}
LobbySystem.local ErrorCodeId = {
  [13010001] = 32546,
  [13010002] = 32547,
  [13010003] = 32548,
  [13010004] = 32549,
  [13010005] = 32550,
  [13010006] = 32551,
  [13010007] = 32552,
  [13010008] = 32553,
  [13010009] = 32554,
  [13010010] = 32555
}
LobbySystem.local LoginSuccessModules = {
  "client.logic.roleinfo.logic_roleinfo",
  "client.logic.login.logic_lobby",
  "client.logic.data.data_mgr",
  "common.func_util",
  "client.logic.pay.logic_centauri",
  "client.logic.lobby.hall_theme_utils",
  "client.umg.bp_global",
  "client.network.comm.NetManager",
  "client.slua.logic.push.logic_fcm_push",
  "client.slua.logic.match.logic_lobby_ping_report",
  "client.network.Protocol.VehicleRefitHandler",
  "client.network.Protocol.WeaponDiyHandler",
  "client.slua.logic.match.logic_match",
  "client.slua.logic.SmallPayment.Logic_SmallPayment",
  "client.slua.logic.gamemaster.logic_accel",
  "client.slua.logic.weapon_diy.logic_weapon_diy",
  "client.slua.logic.lobby.lab.logic_lab_new",
  "client.network.Protocol.NewerGuideHandler",
  "client.network.Protocol.NewbieGuideHandler",
  "client.slua.logic.friend.logic_new_friend",
  "client.slua.logic.Pandora.pandora_logic",
  "client.slua.logic.XSuit.logic_xsuit",
  "client.slua.logic.lobby_chat.logic_chat_main",
  "client.logic.countryarea.logic_eugdpr",
  "client.slua.logic.scrollnotice.logic_scrollnotice",
  "client.slua.logic.common.logic_reddot",
  "client.slua.logic.GuideFlow.logic_guide_flow",
  "client.slua.logic.unknow_pass.logic_unknowpass_buy_act",
  "client.slua.logic.TxMission.logic_xmission_main",
  "client.slua.logic.subscribe.logic_subscribe_carnival_activity",
  "client.slua.logic.oldfriend.logic_oldfriend_care",
  "client.slua.logic.GuideFlow.Action.StartBtnEffectAction",
  "client.slua.logic.fairgame.logic_fairgame_popup",
  "client.slua.logic.pubgm_music.logic_pubgm_music",
  "client.logic.message_push.logic_message_push_trigger",
  "client.logic.season.logic_season_review",
  "client.slua.logic.teamup.logic_shadow_zone",
  "client.slua.logic.achievement.logic_achievement",
  "client.slua.logic.lobby_activity.logic_ladder_draw",
  "client.logic.logic_region_block.logic_region_block",
  "client.slua.logic.room.logic_create_room",
  "client.slua.logic.corps.logic_corps_fight",
  "client.slua.logic.corps.logic_corps",
  "client.slua.logic.common.logic_common_legal_msg",
  "client.slua.logic.team_evaluation.logic_team_evaluation_view",
  "client.slua.logic.lobby.logic_mode_entry",
  "client.slua.logic.lbs.logic_lbs",
  "client.slua.logic.replay.logic_replay",
  "client.slua.logic.jaguar.logic_jaguar",
  "client.slua.logic.coupon.logic_coupon",
  "client.logic.setting.logic_setting",
  "client.slua.logic.unknow_pass.RedPoint.unknowpass_redpoint_data",
  "client.slua.logic.unknow_pass.RedPoint.RPtask_redpoint_data",
  "client.slua.logic.friend.RedPoint.Friend_redpoint_data",
  "client.slua.logic.moment.moment_reddot_data",
  "client.module_framework.ModuleManager",
  "client.slua.logic.download.puffer_switch",
  "client.slua.logic.teamup.logic_team_up_limit",
  "client.slua.logic.network_trace.logic_trace",
  "client.logic.advertise.logic_advertise_sdk",
  "client.slua.logic.chat_voice.logic_antsvoice_interface",
  "client.slua.logic.Appraise.logic_appraise"
}
local PacketTypeTable = {
  [1] = "APPLE_AUDIT",
  [2] = "FORMAL"
}
LobbySystem.local NeedCheckDeviceLimit = true
function LobbySystem.OptimizeMemory()
  print(bWriteLog and "LobbySystem.OptimizeMemory")
  if Client.IsEmulator() then
    return
  end
  local DisableReduceVirMem = HDmpveRemote.HDmpveRemoteConfigGetString("DisableReduceVirMem", "")
  if DisableReduceVirMem ~= "DisableReduceVirMem" then
    Client.ReduceVirMem(0, 50)
    local os_version = Client.GetOSVersion()
    local so_version = Client.GetAndroidSOVersion()
    local first_ch = string.sub(os_version, 1, 1)
    if so_version and so_version == 32 and os_version then
      if first_ch == "4" or first_ch == "5" or first_ch == "6" or first_ch == "7" or first_ch == "8" then
        local remain_size = HDmpveRemote.HDmpveRemoteConfigGetInt("ReduceVirMemUsingRemap", 84934656)
        if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableReduceVirMemUsingRemap", true) then
          Client.RemapMemMap("dalvik-main space", remain_size)
        end
      end
      if 0 < HDmpveRemote.HDmpveRemoteConfigGetInt("32BitRemoveWebview", 0) then
        Client.RemoveWebView()
      end
    end
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseSplashScreenImage", true) then
    Client.ReleaseSplashScreenImage()
  end
  slua_GameFrontendHUD:DestroyDolphin()
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  ClientEVOConfig.Optimize_Android_Performance_Swap_2G()
  ClientEVOConfig.Optimize_Android_Performance_Swap_3G()
  ClientEVOConfig.Optimize_Android_Performance_Swap_4G()
  ClientEVOConfig.Optimize_Android_32_OOM()
  local memopt = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.mem_opt)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
end
function LobbySystem.OnLogin(bReLogin)
  print(bWriteLog and "LobbySystem.OnLogin")
  local roleData = LobbySystem.roleData
  local UIAdaptation = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIAdaptation)
  UIAdaptation:LoginAdaption(bReLogin)
  local SettingSystem = require("client.logic.setting.logic_setting")
  if roleData.explicit_label_switch_info ~= nil then
    LobbySystem.LobbyMenuOpenStatus_New = roleData.explicit_label_switch_info
  end
  if roleData.label_switch_info ~= nil then
    LobbySystem.on_fetch_label_switch_res(roleData.label_switch_info)
  end
  LobbySystem.OnLobbyMenuDataInitialied()
  if not bReLogin then
    LobbySystem.OptimizeMemory()
    log(bWriteLog and "LobbySystem.OnLogin. after optimizeMemory")
    if FixCrash and FixCrash.OpenID and FixCrash.OpenID == roleData.openid then
      print(bWriteLog and "LobbySystem.OnLogin Fix Crash")
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_reset_all_custom_settings_req()
      FixCrash = nil
    else
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local SettingSubsystem_CPP = slua_GameFrontendHUD:GetSettingSubsystem()
      if slua.isValid(SettingSubsystem_CPP) then
        SettingSubsystem_CPP:ClearCustomSetting()
      end
      local bIsSameOpenID = false
      local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
      if SettingConfig then
        print(bWriteLog and string.format("LobbySystem.OnLogin OpenID=%s, openid=%s, %s", tostring(SettingConfig.OpenID), tostring(roleData.openid), tostring(SettingConfig.OpenID == roleData.openid)))
        if SettingConfig.OpenID == roleData.openid then
          bIsSameOpenID = true
        else
          SettingConfig.OpenID = roleData.openid
        end
      end
      local bDelay_CheckCustomSettingGameVersion = false
      local setting_ver_info = roleData.setting_ver_info or {}
      setting_ver_info[0] = nil
      setting_ver_info[100] = nil
      if bIsSameOpenID then
        local Setting_UIElemLayout_Interface = require("client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Interface")
        for SlotType, SlotTypeVersion in pairs(setting_ver_info) do
          local bNeedQuery = false
          if SettingSystem.IsNeedQueryCustomSetting(SlotType, SlotTypeVersion) then
            bNeedQuery = true
          elseif 1 < SlotTypeVersion then
            if type(SlotType) == "number" and 100 < SlotType then
              local sFileName = Setting_UIElemLayout_Interface.GetSlotNameByIndex_Legacy(SlotType - 100)
              local SavEncodeSystem = require("client.logic.setting.SavEncodeSystem")
              if not SavEncodeSystem.ValidateSaveFile(sFileName) then
                bNeedQuery = true
              end
            elseif type(SlotType) == "string" then
              local CustomLayoutArchiver = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutArchiver")
              if not CustomLayoutArchiver.LoadFile(SlotType) then
                bNeedQuery = true
              end
            end
          end
          if bNeedQuery then
            bDelay_CheckCustomSettingGameVersion = true
            SettingSystem.query_custom_setting(SlotType)
          end
        end
      else
        if not bIsSameOpenID then
          local FileNameNumList = {
            "",
            "01",
            "02",
            "03",
            "04",
            "05",
            "06",
            "07",
            "08",
            "09",
            "10"
          }
          for _, NumStr in ipairs(FileNameNumList) do
            local LastPlayerSavFileName = Client.ProjectSavedDir() .. "/SaveGames/UIElemLayout_Slot" .. NumStr .. ".sav"
            Client.DeleteFile(LastPlayerSavFileName)
            print(bWriteLog and string.format("LobbySystem.OnLogin Delete Former Player's SavFile %s", LastPlayerSavFileName))
          end
          Client.DeleteDirectory(Client.ProjectSavedDir() .. "SaveGames/CustomLayout")
        end
        bDelay_CheckCustomSettingGameVersion = true
        for SlotType, SlotTypeVersion in pairs(setting_ver_info) do
          if SlotType ~= 0 and SlotType ~= 100 then
            SettingSystem.query_custom_setting(SlotType)
          end
        end
      end
      if not bDelay_CheckCustomSettingGameVersion then
        SettingSystem.CheckCustomSettingGameVersion(0.01)
      else
        SettingSystem.CheckCustomSettingGameVersion(3)
      end
      local SettingHandler = require("client.network.Protocol.SettingHandler")
      SettingHandler.send_get_all_screen_resolutions_req()
    end
    local Settingconfig = slua_GameFrontendHUD:GetUserSettings()
    if Settingconfig then
      log(bWriteLog and "LobbySystem.OnLogin Clear PubgPlusGuide")
      Settingconfig.PubgPlusGuideConfig:Clear()
      Settingconfig.PubgPlusGuideRecord:Clear()
      slua_GameFrontendHUD:FinishModifyUserSettings()
    end
  end
  if roleData.recharge_viplevel ~= nil then
    log(bWriteLog and "SaveTableToFile recharge_viplevel:" .. roleData.recharge_viplevel)
    local key = "PlayerRechargeVipLevel"
    local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    local localStoreDic = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
    if localStoreDic == nil then
      localStoreDic = {}
    end
    if localStoreDic[key] == nil or localStoreDic[key] ~= nil and localStoreDic[key] ~= roleData.recharge_viplevel then
      localStoreDic[key] = roleData.recharge_viplevel
      PlayerPrefs.SaveTableToFile_N(localStoreDic, PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
    end
    log(bWriteLog and "SaveTableToFile recharge_viplevel END")
  end
  Client.CheckRegisterGestureConflictWithZoom()
  if LobbySystem.roleData.last_logout_time then
    local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
    StarterPackSystem.SetLastLoginTime(LobbySystem.roleData.last_logout_time)
    local NoticesUtil = require("client.logic.Notice.NoticesUtil")
    NoticesUtil.SetLastLogoutTime(LobbySystem.roleData.last_logout_time)
  end
  if not bReLogin then
    LobbySystem.activityBtnDisplayList = {}
  end
  LobbySystem.ResetSettings()
  LobbySystem.EnsureHapticSetting()
  LobbySystem.DoConsoleCmdFromRemoteConfig()
  LobbySystem.DoCheckGMLog()
  Client.SetUseMouseForTouch(true)
  if Client.RecordThreadIndexByGameThreadIOS then
    Client.RecordThreadIndexByGameThreadIOS()
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGetSalesHighQualityItems)
  local now = TimeUtil.GetServerTimeInSec()
  LobbySystem.isTodayFirstLogin = not saveData or not saveData.time or not TimeUtil.IsSameDay(now, saveData.time)
  if LobbySystem.isTodayFirstLogin then
    PlayerPrefsSystem.SaveTableToFile_N({time = now}, PlayerPrefsSystem.ePlayerPrefsType.eGetSalesHighQualityItems)
    local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
    log(bWriteLog and "PlayerLabelHandler.send_get_sales_high_quality_items")
    PlayerLabelHandler.send_get_sales_high_quality_items()
  end
  if not Client.IsReleaseVersion(NetInterface) then
    log(bWriteLog and "IsDevelopment upload sync asset beg")
    local str = Client.LoadFileToString("SyncLoadInfo.txt")
    local StringUtil = require("common.string_util")
    local Lines = StringUtil.Split(str, "\n")
    if next(Lines) then
      local Count = 0
      local instanceID = FuncUtil.GetHDmpveInstanceId()
      for _, Line in ipairs(Lines) do
        log(bWriteLog and "IsDevelopment upload sync Line: " .. Line)
        local SyncInfo = StringUtil.Split(Line, ",")
        if 3 <= #SyncInfo and (0 < #SyncInfo[1] or 0 < #SyncInfo[2]) then
          local itemParam = {
            tostring(SyncInfo[1]),
            tostring(SyncInfo[2]),
            tostring(instanceID),
            tostring(Count),
            tostring(SyncInfo[3])
          }
          Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "SyncPreLoadPackageInfo", itemParam)
          Count = Count + 1
        end
      end
      log(bWriteLog and "IsDevelopment upload sync asset end " .. tostring(Count))
    end
  end
  local puffer_res_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  puffer_res_manager:ReInitVulkanShader()
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  logic_home_switch:InitRightModeData()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  log(bWriteLog and "LobbySystem.OnLogin| as.ParachuteAnimOP 0")
end
function LobbySystem.OnLobbyMenuDataInitialied()
  local isViberateOpen = LobbySystem.CheckOpen(20335) and 1 or 0
  Client.SetUIConfigTMFPTapEnableFlag(isViberateOpen)
end
function LobbySystem.ResetSettings()
  print(bWriteLog and "LobbySystem.ResetSettings")
  local Settingconfig = slua_GameFrontendHUD:GetUserSettings()
  if Settingconfig and Settingconfig.bResetDeathPlaybackSwitch == false then
    local bMiddleOrHighDevice = false
    local UIUtil = require("client.common.ui_util")
    local GameInstance = UIUtil.GetGameInstance()
    if Game:IsValid(GameInstance) then
      bMiddleOrHighDevice = GameInstance:GetDeviceLevel() >= 1
    end
    if bMiddleOrHighDevice then
      if Settingconfig.DeathPlaybackSwitch == false then
        Settingconfig.DeathPlaybackSwitch = true
      end
      if Settingconfig.bRecordWonderfulReplayOpen == false then
        Settingconfig.bRecordWonderfulReplayOpen = true
      end
    end
    Settingconfig.bResetDeathPlaybackSwitch = true
    slua_GameFrontendHUD:FinishModifyUserSettings()
  end
end
function LobbySystem.EnsureHapticSetting()
  print(bWriteLog and "LobbySystem.EnsureHapticSetting")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.HapticSwitch = SettingConfig.HapticSwitch or 0
  local SupportHaptic = Client.GetTMFPTapDeviceSupportFlag() - 1
  if SettingConfig.HapticSwitch ~= 0 then
    SettingConfig.HapticSwitch = SupportHaptic
  end
  Client.SetUserTMFPTapEnableFlag(SettingConfig.HapticSwitch + 1)
  print(bWriteLog and "LobbySystem.EnsureHapticSetting HapticSwitch=" .. SettingConfig.HapticSwitch)
end
function LobbySystem.DoConsoleCmdFromRemoteConfig()
  log(bWriteLog and "LobbySystem.DoConsoleCmdFromRemoteConfig")
  local optSwitch = HDmpveRemote.HDmpveRemoteConfigGetString("GetSharedReaderWithLock", "")
  if optSwitch ~= "" then
    FuncUtil.UE4ExecuteConsoleCommand("r.GetSharedReaderWithLock " .. optSwitch)
    log(bWriteLog and "LobbySystem.DoConsoleCmdFromRemoteConfig GetSharedReaderWithLock=" .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetString("CloseUselessODPaksOnGameThread", "")
  if optSwitch ~= "" then
    FuncUtil.UE4ExecuteConsoleCommand("r.CloseUselessODPaksOnGameThread " .. optSwitch)
    log(bWriteLog and "LobbySystem.DoConsoleCmdFromRemoteConfig CloseUselessODPaksOnGameThread=" .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetString("CloseUselessODPaksOnGameThreadTickInterval", "")
  if optSwitch ~= "" then
    FuncUtil.UE4ExecuteConsoleCommand("r.CloseUselessODPaksOnGameThreadTickInterval " .. optSwitch)
    log(bWriteLog and "LobbySystem.DoConsoleCmdFromRemoteConfig CloseUselessODPaksOnGameThreadTickInterval=" .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("LoadObjectPackageFlagsPrivateFix", 1)
  if optSwitch == 0 then
    FuncUtil.UE4ExecuteConsoleCommand("s.LoadObjectPackageFlagsPrivateFix " .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("LoadObjectPackageFlagsPrivateFixForDS", 1)
  if optSwitch == 0 then
    FuncUtil.UE4ExecuteConsoleCommand("s.LoadObjectPackageFlagsPrivateFixForDS " .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("UseIOMuxUDPPing", 0)
  if optSwitch ~= 0 then
    FuncUtil.UE4ExecuteConsoleCommand("s.UseIOMuxUDPPing " .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetBool("WeaponSwallowSameShootBulletEffectInBound", false)
  if not optSwitch then
    FuncUtil.UE4ExecuteConsoleCommand("weapon.SwallowSameShootBulletEffectInBound False")
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("TextureUpdateWithMinMips", 0)
  if optSwitch ~= 0 then
    FuncUtil.UE4ExecuteConsoleCommand("r.Texture.UpdateWithMinMips " .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("GainCrashLogInfoBackground", 0)
  if optSwitch ~= 0 then
    if optSwitch & 1 ~= 0 then
      local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
      ClientEVOConfig.OpenDevLog()
      FuncUtil.UE4ExecuteConsoleCommand("Log reorigin")
      LogUtil.SetForceLog(true)
      local LogFilter = require("common.log_filter")
      LogFilter.SetLogTreeEnable(true)
      LogFilter.SetWriteLog(true)
      Client.SwitchOutputDeviceFileLog()
    end
    if optSwitch & 2 ~= 0 then
      Client.GainSystemLog()
    end
    if optSwitch & 4 ~= 0 then
      local BugReporter
      local UIUtil = require("client.common.ui_util")
      local gameFrontendHUD = UIUtil.GetGameFrontendHUD()
      if gameFrontendHUD and slua.isValid(gameFrontendHUD) then
        BugReporter = gameFrontendHUD:GetBugReporter()
        BugReporter:SendLog("GainCrashLogInfoBackground", "", 0.0, 0.0, 0.0, true, true)
      end
    end
    log(bWriteLog and "LobbySystem.DoConsoleCmdFromRemoteConfig GainCrashLogInfoBackground=" .. optSwitch)
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local DeviceLevel = GameInstance:GetDeviceLevel()
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("ProcessAnrDeviceLevel", -9)
  if Client.GetDevicePlatformName() == "Android" and DeviceLevel <= optSwitch then
    optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("TickAsyncLoadingTimeLimit", -1)
    if 0 <= optSwitch then
      optSwitch = optSwitch / 1000
      FuncUtil.UE4ExecuteConsoleCommand("s.TickAsyncLoadingTimeLimit " .. optSwitch)
    end
    optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("TickAsyncLoadingUseFullTimeLimit", -1)
    if 0 <= optSwitch then
      FuncUtil.UE4ExecuteConsoleCommand("s.TickAsyncLoadingUseFullTimeLimit " .. optSwitch)
    end
    optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("TickAsyncLoadingSleepTime", -1)
    if 0 <= optSwitch then
      optSwitch = optSwitch / 10000
      FuncUtil.UE4ExecuteConsoleCommand("s.TickAsyncLoadingSleepTime " .. optSwitch)
    end
    optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("LoadMapSleepTime", -1)
    if 0 <= optSwitch then
      optSwitch = optSwitch / 10000
      FuncUtil.UE4ExecuteConsoleCommand("s.LoadMapSleepTime " .. optSwitch)
    end
    optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("LoadMapFraming", -1)
    if 0 <= optSwitch then
      FuncUtil.UE4ExecuteConsoleCommand("s.LoadMapFraming " .. optSwitch)
    end
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("ForceDisableCvm", 0)
  if optSwitch == 0 and Client.InitializeCvmWithRunPhase then
    Client.InitializeCvmWithRunPhase(4)
    Client.InitializeCvmWithRunPhase(5)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("IosStuckSwitchGameStatusInterval", 0)
  if 0 <= optSwitch then
    FuncUtil.UE4ExecuteConsoleCommand("s.IosStuckSwitchGameStatusInterval " .. optSwitch)
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("UDPPingSetSocketRecvTimeout", -1)
  if 0 <= optSwitch then
    FuncUtil.UE4ExecuteConsoleCommand("s.UDPPingSetSocketRecvTimeout " .. optSwitch)
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isCEVersion = PublishRegionMacros.IsCEVersion()
  if not Client.IsReleaseVersion(NetInterface) or isCEVersion then
    optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("IOSCrashWhenFreeUnknownPtr", 1)
    if 0 <= optSwitch then
      FuncUtil.UE4ExecuteConsoleCommand("MallocBinned.CrashWhenFreeUnknownPtr " .. optSwitch)
    end
    local SetLogPathNotifyType = HDmpveRemote.HDmpveRemoteConfigGetInt("CrashSetLogPathNotifyType", -1)
    if 0 <= SetLogPathNotifyType then
      FuncUtil.UE4ExecuteConsoleCommand("s.OnCrashSetLogPathNotifyType " .. SetLogPathNotifyType)
    end
  end
  optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("VehicleReportAudioData", -1)
  if 0 <= optSwitch then
    FuncUtil.UE4ExecuteConsoleCommand("Vehicle.ReportAudioData " .. optSwitch)
  end
  local DisableClothSimulate = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableClothSimulate", false)
  if DisableClothSimulate then
    FuncUtil.UE4ExecuteConsoleCommand("r.EnableNvCloth 0")
  end
  local DisableClothTwoMesh = HDmpveRemote.HDmpveRemoteConfigGetBool("DisableClothTwoMesh", false)
  if DisableClothTwoMesh then
    FuncUtil.UE4ExecuteConsoleCommand("a.ClothForceAlternateSkinning 0")
  end
  FuncUtil.CheckBackpackBlueprintDelegateDelayEnable()
end
function LobbySystem.DoCheckGMLog()
  require("client.logic.gm.RequireBlackList")
  local GMDebug = RequireBlackList("blacklist.slua.logic.log.logic_gm_debug")
  if GMDebug then
    GMDebug:initialized()
  else
    log_shipping_client("LobbySystem.DoCheckGMLog GMDebug is nil")
  end
  local PerUIGM = RequireBlackList("blacklist.slua.logic.gm_data.logic_per_ui_gm")
  if PerUIGM then
    PerUIGM:initialized()
  end
end
function LobbySystem.Enter()
  log(bWriteLog and "enter lobby")
  LobbySystem.isWaitToEnterGame = false
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ENTERLOBBY)
end
function LobbySystem.Leave()
  log(bWriteLog and "leave lobby")
end
local LocalEnterLobby = function()
  if Client.IsEditor() and require("GameLua.Mod.SocialIsland.GamePlay.Config.Test_Config").bConnectLobbySvr == true then
    return
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local ShareMgr = require("client.logic.share.share_logic")
  log_shipping_client("[Login process] on_sync_base_info EnterLobby")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.SetInitPercent(20)
  LoadingSystem.ShowLoading(true)
  LobbyUI.Init()
  LobbySystem.Enter()
  local login_protect_utils = require("client.slua.logic.login.login_protect_utils")
  login_protect_utils.RecordLoginSucTime()
  local str = TeamAvatarManager.GetMainAvatarEquipmentsString()
  if nil ~= str and "" ~= str then
    Client.CrashLog(NetInterface, 4, "Login", "Enter Lobby " .. str)
  end
  LobbySystem.enterLobbyNum = LobbySystem.enterLobbyNum + 1
end
function LobbySystem.on_please_create_role(defaultWearInfo, inNewGuideSwitch)
  log_shipping_client("please_create_role")
  log_tree("LobbySystem.on_please_create_role, defaultWearInfo = ", defaultWearInfo)
  NetUtil.StopCheckLoginOtherLobbyServer()
  NetUtil.StopCheckLoginRsp()
  if Client.IsShipping() and LobbySystem.CheckOpen(BP_ENUM_GUEST_REGISTER_LIMIT) then
    log_shipping_client("LobbySystem.on_please_create_role BP_ENUM_GUEST_REGISTER_LIMIT open")
    log_shipping_client("LobbySystem.on_please_create_role BP_AuthLoginChannel = " .. Client.GetLoginChannel(NetInterface))
    if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local tableGuestCnt = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eJKGuestRegisterCnt)
      if tableGuestCnt == nil then
        log_shipping_client("LobbySystem.on_please_create_role JKGuestRegisterCnt == nil")
        tableGuestCnt = {}
        tableGuestCnt.JKGuestRegisterCnt = 0
        tableGuestCnt.LastRegisterTime = 0
      end
      if tableGuestCnt.LastRegisterTime and TimeUtil.GetServerTimeInSec() - tableGuestCnt.LastRegisterTime > 86400 then
        tableGuestCnt.JKGuestRegisterCnt = 0
        PlayerPrefsSystem.SaveTableToFile_N(tableGuestCnt, PlayerPrefsSystem.ePlayerPrefsType.eJKGuestRegisterCnt)
      end
      if tableGuestCnt.JKGuestRegisterCnt >= 3 then
        ShowNotice(7565)
        return
      end
    end
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  if device_module.nDeviceLimit == -1 and NeedCheckDeviceLimit == true then
    LobbySystem.CheckDeviceLimitRefuse()
    return
  end
  local curStatus = GameStatus.GetGameStatus()
  if curStatus == GameStatus.Createrole then
    log(bWriteLog and "is already in createrole")
    return
  end
  local logic_tt_ban = require("client.logic.login.logic_tt_ban")
  if not logic_tt_ban:CheckIfCanCreateRole() then
    log(bWriteLog and "[ERROR] Can not create role!")
    return
  end
  LobbySystem.isNewPlayer = true
  local channel = Client.GetLoginChannel(NetInterface)
  log(bWriteLog and "GetLoginChannel:" .. channel)
  GlobalData.SetPlatform(channel)
  LobbySystem.PlayerDefaultWearInfo = defaultWearInfo
  log(bWriteLog and "[newGuideSwitch] on_please_create_role " .. tostring(inNewGuideSwitch))
  LobbySystem.newGuideSwitch = inNewGuideSwitch == 1
  if LobbySystem.CheckNewGuideSwitch() then
    LobbySystem.CreateDefaultRole()
  else
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.SetInitPercent(20)
    LoadingSystem.ShowLoading(true)
    GameStatus.SwitchToCreateRoleState()
  end
end
function LobbySystem.CreateDefaultRole()
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  local defaultName = ""
  local defalutSex = 2
  local avatars = LobbySystem.GetArrayAvatarInit()
  local defaultRace = 10007
  local defalutHeadId = avatars[defaultRace].BodyID
  local defaultHairType = 20001
  local avatar = avatars[defaultHairType]
  local defaultHairColor = 1
  local hairType = 1
  if avatar ~= nil then
    hairType = tonumber(avatar.Hair)
  end
  local hairIdStr = string.format("%s%02s%03s", BP_ENUM_AVATAR_HAIR, defaultHairColor, hairType)
  local defautlHairId = tonumber(hairIdStr, 10)
  local beardInfo = {}
  local currentLoginPlatform = Client.GetLoginChannel(NetInterface)
  if currentLoginPlatform ~= BP_ENUM_PLAYFORM_TOURIST then
    local IMSDKHelper = import("IMSDKHelper")
    if IMSDKHelper then
      log(bWriteLog and "get channel nick name")
      local nickname
      if Client.IsEditor() then
        nickname = ""
      else
        nickname = IMSDKHelper.GetChannelNickname()
      end
      log(bWriteLog and "nick name is: " .. tostring(nickname))
      if nickname then
        local StringUtil = require("common.string_util")
        local _, len, resultName = StringUtil.CheckName(nickname, true)
        if 14 < len and resultName then
          resultName = StringUtil.SubString(resultName, 1, 12)
        end
        if resultName then
          defaultName = resultName
          log(bWriteLog and "after check nick name is: " .. tostring(defaultName))
        end
        local CreateRoleSystem = require("client.slua.logic.createRole.logic_createRole")
        if CreateRoleSystem.SCreateRoleName == "" then
          CreateRoleSystem.SCreateRoleName = nickname
        end
      end
    end
  end
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  LobbyHandler.send_create_role_request(defaultName, defalutSex, defalutHeadId, defautlHairId, DeviceOSInfo.InfoList, "", beardInfo, true)
end
function LobbySystem.GetChannelNickname()
  local currentLoginPlatform = Client.GetLoginChannel(NetInterface)
  if currentLoginPlatform == BP_ENUM_PLAYFORM_TOURIST then
    log_warning(bWriteLog and "LobbySystem.GetChannelNickname is TOURIST")
    return ""
  end
  local IMSDKHelper = import("IMSDKHelper")
  if not IMSDKHelper then
    log_warning(bWriteLog and "LobbySystem.GetChannelNickname IMSDKHelper is nil")
    return ""
  end
  local nickname = ""
  if not Client.IsEditor() then
    nickname = IMSDKHelper.GetChannelNickname()
  end
  local StringUtil = require("common.string_util")
  local _, len, resultName = StringUtil.CheckName(nickname, true)
  if 14 < len and resultName then
    resultName = StringUtil.SubString(resultName, 1, 12)
  end
  log_warning(bWriteLog and "LobbySystem.GetChannelNickname nickname is: " .. nickname)
  return resultName
end
function LobbySystem.GetArrayAvatarInit()
  local arrayAvatarInitTable = {}
  local avatarInit = CDataTable.GetTable("AvatarInit")
  for k, v in pairs(avatarInit) do
    arrayAvatarInitTable[tonumber(k)] = v
  end
  return arrayAvatarInitTable
end
function LobbySystem.on_sync_my_plat_name(nickname)
  log(bWriteLog and "on_sync_my_plat_name" .. nickname)
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  logicCreateRole.SetNickName(nickname)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GET_PLATFORM, nickname)
end
function LobbySystem.on_create_role_respond(ret)
  log(bWriteLog and "create_role_respond -- " .. ret)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  logic_connection_waiting:Hide(1)
  Client.ReportEventRegisterCompleted()
  if ret ~= NetErrorCode_NONE then
    local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
    logicCreateRole.ShowError(ret)
    local StatManager = import("StatManager")
    log(bWriteLog and "[stat] report event 28")
    StatManager.GetInstance():ReportEventWithNoParam(28, true)
    if ret == "name-exist" then
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_CREATEROLE_NAMEREPEAT)
    end
  else
    local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
    logicCreateRole.OnCloseAvatarResetPanel()
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_Newbie_CreateRole)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.Newbie_CreateRole)
    if Client.IsShipping() and LobbySystem.CheckOpen(BP_ENUM_GUEST_REGISTER_LIMIT) and Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local tableGuestCnt = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eJKGuestRegisterCnt)
      if tableGuestCnt then
        tableGuestCnt.JKGuestRegisterCnt = tableGuestCnt.JKGuestRegisterCnt + 1
      else
        tableGuestCnt = {}
        tableGuestCnt.JKGuestRegisterCnt = 1
      end
      tableGuestCnt.LastRegisterTime = TimeUtil.GetServerTimeInSec()
      log_shipping_client("LobbySystem.on_create_role_respond tableGuestCnt.LastRegisterTime = " .. tostring(tableGuestCnt.LastRegisterTime))
      PlayerPrefsSystem.SaveTableToFile_N(tableGuestCnt, PlayerPrefsSystem.ePlayerPrefsType.eJKGuestRegisterCnt)
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(5, function()
      log(bWriteLog and "LobbySystem.on_create_role_respond ShowVNGPersonalInfo")
      LobbySystem.ShowVNGPersonalInfo()
    end)
  end
  if ret == "bad_param" or ret == "bad-request" then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:backLogin()
  end
  if ret == "nonage_limit_1" or ret == "nonage_limit_2" or ret == "nonage_limit_3" or ret == "nonage_limit_4" then
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    SettingAccount.ClientLogout()
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:backLogin()
  end
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.MarkAsCreatingRole()
  LobbySystem.ChangeNewAccountDefaultSettings()
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  if logic_compliance.certState then
    local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
    EUGDPRHandler.send_minor_cert_report_req(logic_compliance.certState)
  end
end
function LobbySystem.ChangeNewAccountDefaultSettings()
  print(bWriteLog and "LobbySystem.ChangeNewAccountDefaultSettings")
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.AutoPickUpSideSight = false
  SettingConfig.bConsumeThrow = false
  SettingConfig.AutoPickUpPistol = false
  SettingConfig.AutoPickUpSideSight = false
  SettingConfig.AmmoRemain = true
  SettingConfig.OldMarkStyle = 2
  SettingConfig.SoundVisualizationType = 3
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function LobbySystem.SetUIRectOffset(uiRect)
  log(bWriteLog and "devindzhang set uirect " .. uiRect)
  Client.SetUIRectOffset(uiRect)
  local UIBPFunctionLibrary = import("UIBPFunctionLibrary")
  if slua.isValid(UIBPFunctionLibrary) then
    UIBPFunctionLibrary.SetUIRectOffset(uiRect)
  end
end
function LobbySystem.GetABTestId()
  local telemetry_file_name = string.format("%s_%s", "SaveGames/ABTesting", "tel.bin")
  local str = Client.LoadFileToString(telemetry_file_name)
  if str ~= nil and str ~= "" then
    local tab = json.decode(str)
    for k, v in pairs(tab) do
      if k == "abtesting" then
        return v
      end
    end
  end
  return nil
end
function LobbySystem.GetClientBasicCfg()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg then
    log(bWriteLog and "Start to get client_basic_cfg first time")
    LobbySystem.client_basic_cfg_update_time = TimeUtil.GetServerTimeInSec()
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_get_client_basic_cfg()
    return
  end
  local now = TimeUtil.GetServerTimeInSec()
  if now - LobbySystem.client_basic_cfg_update_time > 900 then
    log(bWriteLog and "Start to get client_basic_cfg again")
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_get_client_basic_cfg()
  else
    log(bWriteLog and "Less than 15min from the last getting operation for client_basic_cfg")
    local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
    RecommendHandler.AutoDownload()
  end
end
function LobbySystem.UpdateNewbieRoleInfo(newbie_info)
  log(bWriteLog and "get newbie update role info: " .. newbie_info.newbie_name)
  log_tree("update newbie role info: ", newbie_info)
  logic_connection_waiting:Hide(1)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_CREATEROLE_SELECT_CLOTHES, newbie_info.newbie_gamegender)
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  logicCreateRole.ClosePanel()
  LobbySystem.roleData.name = newbie_info.newbie_name
  LobbySystem.roleData.nation = newbie_info.newbie_nation
  LobbySystem.roleData.avatar.gamegender = newbie_info.newbie_gamegender
  LobbySystem.roleData.avatar.hairid = newbie_info.newbie_avatar_hairid
  LobbySystem.roleData.avatar.headid = newbie_info.newbie_avatar_headid
  LobbySystem.roleData.avatar.beardid = newbie_info.newbie_avatar_beardid
  LobbySystem.roleData.avatar.beardcolor = newbie_info.newbie_avatar_beardcolor
  LobbySystem.roleData.is_first_login = LobbySystem.NewbieRoleState.NormalRole
  DataMgr.UpdateNickName(newbie_info.newbie_name)
  DataMgr.roleData.nation = newbie_info.newbie_nation
  DataMgr.roleData.gender = newbie_info.newbie_gamegender
  AvatarData.SetGameGender(newbie_info.newbie_gamegender)
  AvatarData.SetHeadID(newbie_info.newbie_avatar_headid)
  AvatarData.SetHairID(newbie_info.newbie_avatar_hairid)
  if newbie_info.newbie_avatar_beardid then
    AvatarData.SetBeardID(newbie_info.newbie_avatar_beardid)
  end
  if newbie_info.newbie_avatar_beardcolor then
    AvatarData.SetBeardColorID(newbie_info.newbie_avatar_beardcolor)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.team_info_request()
  log(bWriteLog and "update lobby avatar")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.UpdatePlayer()
  if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and "[v_ywuyuan] LobbySystem.UpdateNewbieRoleInfo not bluehole")
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    growthprojectMgrB.RunNewTypeGuides()
  else
    local MinorVerificationSystem = require("client.slua.logic.minor_verification.logic_minor_verification")
    MinorVerificationSystem.BeginVerificationFlow(function()
      log(bWriteLog and "[v_ywuyuan] LobbySystem.UpdateNewbieRoleInfo bluehole")
      local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
      growthprojectMgrB.RunNewTypeGuides()
    end)
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLENAME)
end
function LobbySystem.SetEncryptKey(KeyParamString)
  local StringUtil = require("common.string_util")
  local KeyParams = StringUtil.Split(KeyParamString, "|")
  if #KeyParams < 4 then
    log(bWriteLog and "EncryptionManager return for KeyParams < 4: " .. tostring(KeyParamString))
    return
  end
  local EncKey = KeyParams[2]
  local KeyChainId = tonumber(KeyParams[3])
  local KeyIndex = tonumber(KeyParams[4])
  Client.SetEncryptKey(KeyChainId, KeyIndex, EncKey)
  log(bWriteLog and "EncryptionManager key set: " .. tostring(EncKey) .. " " .. tostring(KeyChainId) .. " " .. tostring(KeyIndex))
end
function LobbySystem.LoadAmendODs(encryption_info)
  log_tree("LobbySystem.LoadAmendODs encryption_info = ", encryption_info)
  log(bWriteLog and "LobbySystem DataInfo beg")
  local Keys = {}
  local StringUtil = require("common.string_util")
  local DataInfo = encryption_info or {}
  for k, v in pairs(DataInfo) do
    log(bWriteLog and "LobbySystem DataInfo: " .. v.key)
    if StringUtil.Starts(v.key, "###") then
      LobbySystem.SetEncryptKey(v.key)
    else
      Keys[k] = v.key
    end
  end
  log(bWriteLog and "LobbySystem OD Paks Loaded")
  Client.LoadAmendODs(Keys)
  local PakEncryptionKeys = HDmpveRemote.HDmpveRemoteConfigGetString("PakEncryptionKeys", "")
  if string.len(PakEncryptionKeys) <= 0 then
    return
  end
  local PakEncryptionKeyList = StringUtil.Split(PakEncryptionKeys, "%")
  for _, keystring in pairs(PakEncryptionKeyList) do
    LobbySystem.SetEncryptKey(keystring)
  end
end
function LobbySystem.on_sync_base_info(roleData)
  local time_step_macros = require("client.slua.logic.performance.time_step_macros")
  local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
  logic_time_cost_report:SetRoleData(roleData)
  logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.LoginToSyncBaseInfoStart)
  logic_time_cost_report:SetStepStart(time_step_macros.ENUM_TIME_STEP.SyncBaseInfoStartToSyncBaseInfoEnd)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessSyncBaseInfo)
  log_shipping_client("[Login process] LobbySystem.on_sync_base_info begin")
  log(bWriteLog and "  :roleData.ios_acc_del_ts" .. tostring(roleData.ios_acc_del_ts))
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module.bRecvSyncBaseInfo = true
  if login_module.bIsRelogin then
    local strRegion = Client.GetPublishRegion()
    if strRegion ~= PublishRegionMacros.BLUEHOLE then
      local TApmHelper = import("TApmHelper")
      TApmHelper.postEvent(702, "GameServerReconnect", false)
    end
  end
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  RechargeSystem.bIsShowH5Pay = roleData.support_web_pay
  log(bWriteLog and " RechargeSystem.bIsShowH5Pay >>>>> " .. tostring(RechargeSystem.bIsShowH5Pay))
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  LobbyIdleUnlock:SetUnlockSwitch(roleData.jk_lobby_idle_switch)
  logic_cost_collector:MarkTransition(logic_cost_collector.EVENT_KEYS.CONNECT_SERVER, logic_cost_collector.EVENT_KEYS.LOAD_MAP)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.LoadLobbyMap)
  local UIAdaptation = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIAdaptation)
  UIAdaptation:SetDefalutRectOffset(roleData.ui_rect)
  UIAdaptation:SetAlien(roleData.screen_scale)
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local TimeTicker = require("common.time_ticker")
  TimeTicker.AddTimerOnce(0.1, function()
    log_shipping_client("LobbySystem.on_sync_base_info SendEigeninfo")
    xpcall(function()
      LobbySystem.SendEigeninfo(roleData.eigeninfo, 1)
    end, function(err)
      log_shipping_client("LobbySystem.on_sync_base_info SendEigeninfo error: " .. err)
    end)
  end)
  log(bWriteLog and "LobbySystem.on_sync_base_info, reg_ver = " .. tostring(roleData.reg_ver))
  log(bWriteLog and "LobbySystem.on_sync_base_info, quartz = " .. tostring(roleData.quartz))
  log(bWriteLog and "LobbySystem.on_sync_base_info, has_inherit_data = " .. tostring(roleData.has_inherit_data))
  log(bWriteLog and "LobbySystem.on_sync_base_info mc_common_switch = " .. tostring(roleData.mc_common_switch))
  log(bWriteLog and "LobbySystem.on_sync_base_info newbie_abtest_group = " .. tostring(roleData.newbie_abtest_group))
  log(bWriteLog and "LobbySystem.on_sync_base_info newbie_guide_gamestart_abtest_id = " .. tostring(roleData.newbie_guide_gamestart_abtest_id))
  log(bWriteLog and "LobbySystem.on_sync_base_info segment_progress_goal = " .. tostring(roleData.segment_progress_goal))
  log_tree(bWriteLog and "LobbySystem.on_sync_base_info eu_agegate_gray_cfg = ", roleData.eu_agegate_gray_cfg)
  log_tree(bWriteLog and "LobbySystem.on_sync_base_info cur_promotion_data = ", roleData.cur_promotion_data)
  log_tree(bWriteLog and "LobbySystem.on_sync_base_info new_newbie_perfect_excessive_abtest_id = ", roleData.new_newbie_perfect_excessive_abtest_id)
  log(bWriteLog and "LobbySystem.on_sync_base_info free_inout_join_level = ", roleData.free_inout_join_level)
  log(bWriteLog and "LobbySystem.on_sync_base_info is_in_metro = ", roleData.is_in_metro)
  LobbySystem.  log(bWriteLog and "LobbySystem.on_sync_base_info roleData.wow_hall_is_open = " .. tostring(roleData.wow_hall_is_open))
  LobbySystem.set_vulkan_status()
  local encryption_item_info = {}
  if roleData.encryption_item_info then
    for _, v in pairs(roleData.encryption_item_info) do
      table.insert(encryption_item_info, (v - 2022) / 202203)
    end
  end
  Client.EncryptItemData(encryption_item_info)
  local logic_mail_proto = require("client.slua.logic.mail.logic_mail_proto")
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  logic_mail_proto.query_mail_summary_req(MailMacro.Enum_Request_MailList_Source.Login)
  log_tree("god test socialland_luckmate_info ", roleData.socialland_luckmate_info)
  FuncUtil.OnLogin()
  if roleData.newer_guide_data and roleData.newer_guide_data[1] then
    LogicNewbie.newbieTotalGameCnt = roleData.newer_guide_data[1]
  end
  if roleData.depot_version == 0 or roleData.depot_version == nil then
    TeamAvatarManager.NeedCorrect = true
  end
  NetUtil.StopCheckLoginOtherLobbyServer()
  log_warning(bWriteLog and "  : roleData.plot_id: " .. tostring(roleData.plot_id))
  if roleData.plot_id then
    local PlotSystem = require("client.slua.logic.plot.logic_plot_activity")
    PlotSystem.get_plot_info()
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  if device_module.nDeviceLimit == -1 and NeedCheckDeviceLimit == true then
    LobbySystem.CheckDeviceLimitRefuse()
    logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessSyncBaseInfo)
    return
  end
  if GameStatus.IsInLobbyOrMainCity() then
    local logic_main_city_reconnect = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_reconnect)
    logic_main_city_reconnect:ReStartMainCityReconnectCheck(login_module.bIsRelogin)
  else
    NetUtil.StartCheckDSActive()
  end
  LobbySystem.isInLobby = true
  LobbySystem.isCanDeleteOp = true
  local curStatus = GameStatus.GetGameStatus()
  log_shipping_client("[Login process] LobbySystem.on_sync_base_info curStatus:" .. curStatus .. ", isRelogin: " .. tostring(login_module.bIsRelogin))
  if Client.IsEditor() and curStatus == GameStatus.Fighting and require("GameLua.Mod.SocialIsland.GamePlay.Config.Test_Config").bConnectLobbySvr == false then
    logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessSyncBaseInfo)
    return
  end
  local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
  LogicGlobalSensitivity.last_save_custom_sensitive_tm = roleData.last_save_custom_sensitive_tm
  local SettingSystem = require("client.logic.setting.logic_setting")
  if roleData.custom_settings_new_time and roleData.custom_settings_new_time.Setting_Basic then
    SettingSystem.last_save_setting_basic_tm = roleData.custom_settings_new_time.Setting_Basic
  end
  if roleData.last_save_weapon_settings_tm then
    local LogicCustomSensitivity = require("client.logic.setting.logic_setting_custom_sensitivity")
    LogicCustomSensitivity.last_save_weapon_settings_tm = roleData.last_save_weapon_settings_tm[1]
    local LogicCustomAccessories = require("client.logic.setting.logic_setting_custom_accessiores")
    LogicCustomAccessories.last_save_weapon_settings_tm = roleData.last_save_weapon_settings_tm[2]
  end
  if not roleData.last_report_keys_setting or 0 >= roleData.last_report_keys_setting then
    SubSetting_ElemLayout_Upload = true
  end
  local rankInspectSystem = require("client.slua.logic.rank.logic_rank_inspect")
  rankInspectSystem.ResRankInspectInfo(roleData.rank_replay_switch, roleData.rank_replay_value)
  local creditValue = 100
  if roleData.credit ~= nil then
    creditValue = roleData.credit
  end
  log_tree("[ljw] roleDataTb.mil_info", roleData.mil_info)
  roleData.alias.title = FuncUtil.Gen_title(roleData.alias.id, roleData.alias.rank, roleData.alias.ext_info, roleData.alias.rank_id, roleData.alias.area_name)
  local TableUtil = require("common.table_util")
  local roleDataTb = {
    nickName = roleData.name,
    level = roleData.level,
    openID = roleData.openid,
    uid = tostring(roleData.uid),
    nation = roleData.nation,
    roleExp = roleData.exp,
    gold = roleData.gold,
    ticket = roleData.ticket,
    fp_token = roleData.fp_token,
    diamond = roleData.diamond,
    item_store = roleData.item_store,
    smelt = roleData.smelt,
    gold_chip = roleData.gold_chip,
    battle_coin = roleData.tournament_score,
    eternal_diamond = roleData.quartz or 0,
    avatar = roleData.avatar,
    avatar_feature_list = roleData.avatar_feature_list,
    activate_avatar_list = roleData.new_activate_avatar_list,
    depot = roleData.depot and roleData.depot.items or nil,
    depot_show_info = roleData.depot_show_info,
    teamup_action_type = roleData.teamup_action_type,
    rolewear = roleData.rolewear[roleData.use_rolewear],
    rolewear_array = roleData.rolewear,
    rolewear_state = roleData.rolewear_state,
    use_rolewear = roleData.use_rolewear,
    pspace_rolewear_index = roleData.pspace_rolewear_index,
    parachute = roleData.parachute or "",
    gliding = roleData.gliding,
    foot_special_effect_id = roleData.foot_special_effect_id,
    aircraft_put_id = roleData.aircraft_put_id,
    minitv_dressid = roleData.minitv_dressid,
    wearRatingShield = TableUtil.GetTableValue(roleData, "rating_card", "times_card", "is_effect") and TableUtil.GetTableValue(roleData, "rating_card", "times_card", "card_instid") or "",
    wearSeasonRatingShield = TableUtil.GetTableValue(roleData, "rating_card", "season_times_card", "is_effect") and TableUtil.GetTableValue(roleData, "rating_card", "season_times_card", "card_instid") or "",
    seasonPakeGameRatingShield = TableUtil.GetTableValue(roleData, "rating_card", "peakgame_times_card", "card_instid") or "",
    seasonPakeGameAddScoreCardInfo = TableUtil.GetTableValue(roleData, "rating_card", "peakgame_add_score_card"),
    seasonAddScoreCardInfo = TableUtil.GetTableValue(roleData, "rating_card", "season_add_score_card"),
    ratingShieldExpireTime = TableUtil.GetTableValue(roleData, "rating_card", "time_card", "expire_time") or 0,
    signature = roleData.signature,
    headIconUrl = roleData.pic_url,
    gender = roleData.rela_sex,
    segment = roleData.segment_info,
    segmentTitleData = roleData.hsegment_title_det,
    isSeasonStarOpen = roleData.is_season_star_open,
    isHsegmentTitleOpen = roleData.is_hsegment_title_open,
    arena_season_id = roleData.arena_season_id,
    arena_rating_and_segment = roleData.arena_rating_and_segment,
    sink_season_id = roleData.subside_season_index,
    sink_segment = roleData.subside_segment_info,
    sink_segment_rating = roleData.subside_segment_rating,
    eugdpr = roleData.eugdpr,
    login_reward = roleData.login_reward,
    last_login_reward_remind = roleData.last_login_reward_remind,
    activeness = roleData.activeness,
    task = roleData.task,
    levelTask = roleData.level_task,
    week_signup = roleData.week_signup,
    share_award = roleData.share_award,
    cur_avatar_box_id = roleData.cur_avatar_box_id,
    bgbg_vip = roleData.bgbg_vip,
    anchor = 0,
    xy_red_point = roleData.xy_red_point,
    modify_name_time = roleData.modify_name_time,
    registertime = roleData.registertime,
    reg_ver = roleData.reg_ver,
    last_modify_nation_time = roleData.last_modify_nation_time,
    last_modify_nation_item_time = roleData.last_modify_nation_item_time,
    Recharge = roleData.first_save,
    fresher_type = roleData.fresher_type,
    double_card = roleData.double_card,
    jp_age = roleData.jp_age,
    gen_ticket = roleData.gen_ticket,
    room_card_info = roleData.room_cards and roleData.room_cards.ordinary or {},
    room_card_info_adv = roleData.room_cards and roleData.room_cards.advanced or {},
    room_card_info_mat = roleData.room_cards and roleData.room_cards.match or {},
    room_cards = roleData.room_cards,
    credit = creditValue,
    enableWatch = roleData.enable_watch,
    watch_privacy = roleData.watch_privacy or 1,
    enable_watch_remind = roleData.enable_watch_remind or 1,
    receive_nonfriend_team_request = roleData.receive_nonfriend_team_request or 1,
    corps_money = roleData.corps_money,
    planeSkinInsID = roleData.fly_skin,
    wingmanSkinInsID = roleData.wingman_skin,
    alias = roleData.alias,
    corps_alias_data = roleData.corps_alias_data,
    krjp_del_account_left_time = roleData.krjp_del_account_left_time,
    last_equip_forever_skins = roleData.last_equip_forever_skins,
    win_statue = roleData.win_statue,
    bagSkinInsID = roleData.bag_skin or 0,
    helmetSkinInsID = roleData.helmet_skin or 0,
    armorSkinInsID = roleData.armor_skin or 0,
    vehicleSkinInsIDTable = roleData.vst,
    rejoin_task = roleData.rejoin_task,
    carteam_coin_count = roleData.carteam_coin_count,
    head_show = roleData.head_show or 0,
    bag_level = roleData.bag_level or 1,
    helmet_level = roleData.helmet_level or 1,
    season_id = LobbySystem.GetSaftySeasonValue(roleData.season_index),
    carteam_id = roleData.carteam_id,
    pve_exp = roleData.pve_exp or 0,
    pve_level = roleData.pve_level or 1,
    character_ids = roleData.character_ids,
    all_knapsack_ext_info = roleData.all_knapsack_ext_info,
    season_switch_display = roleData.season_switch_display,
    brand = roleData.brand,
    total_season_recharge = roleData.total_season_recharge,
    idip_area_id = roleData.idip_area_id or -1,
    rating_card = roleData.rating_card,
    segment_protect_shield_info = roleData.segment_protect_shield_info,
    echo_port = roleData.echo_port or 8030,
    xy_userid = roleData.xy_userid or "",
    ace_imprint_show_id = roleData.ace_imprint_show_id,
    ace_imprint_base_id = roleData.ace_imprint_base_id,
    ace_imprint_show_cnt = roleData.ace_imprint_show_cnt or 0,
    team_consribe_switch = roleData.team_consribe_switch,
    team_consribe_voice_switch = roleData.team_consribe_voice_switch,
    team_consribe_tplan_switch = roleData.team_consribe_tplan_switch,
    voice_feedback = roleData.voice_feedback,
    sound_monitor = roleData.is_sound_abnormal_report_open,
    big_event_newbie_guide = roleData.big_event_newbie_guide,
    game_flag = roleData.game_flag,
    back_user_data = roleData.back_user_data,
    is_new_player = roleData.is_new_player,
    is_come_back_player = roleData.is_come_back_player,
    next_select_zone_time = roleData.next_select_zone_time,
    growup_mark_labels = roleData.growup_mark_labels,
    activity_teams = roleData.activity_teams,
    old_last_login_time = roleData.old_last_login_time,
    VGameAppID = roleData.game_appid,
    newbie_points = roleData.newbie_points,
    moment_info = roleData.moment_info,
    no_login_label_info = roleData.no_login_label_info,
    arabic_chat_cfg = roleData.arabic_chat_cfg,
    all_segment_protect_times = roleData.all_segment_protect_times,
    mil_info = roleData.mil_info,
    cheat_flag = roleData.cheat_flag,
    minitv_onekey_flag = roleData.minitv_onekey_flag,
    car_plate_info = roleData.car_plate_info,
    mode_views_api_version = roleData.mode_views_api_version,
    match_success_animation = roleData.match_success_animation,
    ios_acc_del_ts = roleData.ios_acc_del_ts,
    aos_acc_del_ts = roleData.aos_acc_del_ts,
    novice_guidance_flag = roleData.novice_guidance_flag,
    cur_team_notify_skin_id = roleData.cur_team_notify_skin_id,
    friend_nickname_skin = roleData.friend_nickname_skin,
    chat_bubble = roleData.chat_bubble,
    is_open_ugc = roleData.is_open_ugc,
    ugc_hot_theme = roleData.ugc_hot_theme,
    club_report_svrid = roleData.club_report_svrid,
    fcm_switch_data = roleData.fcm_switch_data or {},
    fcm_switch_cfg = roleData.fcm_switch_cfg or {},
    last_30days_recharge_amount = roleData.last_30days_recharge_amount or 0,
    last_recharge_amount = roleData.last_recharge_amount or 0,
    friends_most_recharge_amount = roleData.friends_most_recharge_amount or 0,
    last_pay_time = roleData.last_pay_time or 0,
    dragon_ball_unlock_state = roleData.dragon_ball_unlock_state or false,
    manor_switch = roleData.manor_switch,
    social_card_share_limit = roleData.social_card_share_limit,
    ugc_author_info = roleData.ugc_author_info,
    metro_souvenirs = roleData.metro_souvenirs,
    brief_collect_data = roleData.brief_collect_data,
    brief_collect_hall_data = roleData.brief_collect_hall_data,
    wow_creation_score = roleData.wow_creation_score,
    casual_segment_id = roleData.casual_segment_id,
    casual_segment_score = roleData.casual_segment_score,
    casual_task_award_flag = roleData.casual_task_award_flag,
    casual_segment_award_flag = roleData.casual_segment_award_flag,
    peakgame_can_take_reward = roleData.peakgame_can_take_reward,
    peakgame_start_time = roleData.peakgame_start_time,
    last_season_max_segment = roleData.last_season_max_segment,
    segment_show_type = roleData.segment_show_type,
    peakgame_rating_info = roleData.peakgame_rating_info,
    peakgame_history_max_segment = roleData.peakgame_history_max_segment,
    peakgame_start_time_list = roleData.peakgame_start_time_list,
    convience_mode_settings = roleData.convience_mode_settings,
    performance_switch = roleData.performance_switch,
    kol_leaderboard = roleData.kol_leaderboard,
    common_subtype_wear_data = roleData.common_subtype_wear_data,
    save_sum = roleData.save_sum,
    mvp_action_type = roleData.mvp_action_type,
    penguins_wash_times = roleData.penguins_wash_times,
    last_penguins_wash_tm = roleData.last_penguins_wash_tm,
    bride_npc_data = roleData.bride_npc_data,
    gun_upgrade_parts_switch = roleData.gun_upgrade_parts_switch,
    open_llm_chat_v2 = roleData.open_llm_chat_v2,
    ugc_advanced_crystal = roleData.ugc_advanced_crystal,
    common_depot_puton = roleData.common_depot_puton,
    newbie_match_guide_flag = roleData.newbie_match_guide_flag,
    free_inout_join_level = roleData.free_inout_join_level
  }
  log_tree("LobbySystem.on_sync_base_info. roleData.bride_npc_data = ", roleData.bride_npc_data)
  log_tree("god test roleData.feedback_voice ", roleData.voice_feedback)
  log(bWriteLog and "roleData.novice_guidance_flag " .. tostring(roleData.novice_guidance_flag))
  log(bWriteLog and "roleData.rank_guide_flag " .. tostring(roleData.rank_guide_flag))
  log(bWriteLog and "roleData.newbie_groupid " .. tostring(roleData.newbie_groupid))
  log(bWriteLog and "roleData.performance_switch " .. tostring(roleData.performance_switch))
  log(bWriteLog and "roleData.club_report_svrid :" .. tostring(roleDataTb.club_report_svrid))
  if not roleData.performance_switch or roleData.performance_switch == 1 then
    local PlayAnimationFeatureInGameGuide = require("client.slua.umg.newbie_guide.PlayAnimationFeatureInGameGuide")
    PlayAnimationFeatureInGameGuide.performance_switch = true
  end
  if roleData.weapon_wear_info == nil then
    roleDataTb.weapon_id = 0
    roleDataTb.weapon_skin_resID = 0
    roleDataTb.weapon_skin_insID = 0
    roleDataTb.weapon_isUsingRecommend = false
    roleDataTb.weapon_planID = ""
    roleDataTb.extra_weapon_list = {}
  else
    roleDataTb.weapon_id = roleData.weapon_wear_info.weapon_id or 0
    roleDataTb.weapon_skin_resID = roleData.weapon_wear_info.skin_id or 0
    roleDataTb.weapon_skin_insID = 0
    roleDataTb.weapon_isUsingRecommend = roleData.weapon_wear_info.is_using_recommend or false
    roleDataTb.weapon_planID = roleData.weapon_wear_info.cur_use_plan
    roleDataTb.extra_weapon_list = roleData.weapon_wear_info.ext_info or {}
  end
  if roleData.anchor ~= nil then
    roleDataTb.anchor = roleData.anchor
  end
  if roleData.anchor_origin then
    roleDataTb.anchor_origin = roleData.anchor_origin
  end
  if roleData.luck_airdrop ~= nil then
    roleDataTb.luck_airdrop = roleData.luck_airdrop
  end
  if roleData.can_watch_google_ad then
    roleDataTb.can_watch_google_ad = roleData.can_watch_google_ad
  else
    log(bWriteLog and "[mxiliu]roleData.can_watch_google_ad no have")
  end
  if roleData.zone_id then
    roleDataTb.zone_id = roleData.zone_id
  end
  if roleData.item_upgrade_switch_info then
    roleDataTb.item_upgrade_switch_info = roleData.item_upgrade_switch_info
  end
  if roleData.weapon_audio_volume_info then
    roleDataTb.weapon_audio_volume_info = roleData.weapon_audio_volume_info
  end
  if roleData.minor_cert_status then
    roleDataTb.minor_cert_status = roleData.minor_cert_status
  end
  if roleData.can_show_rp_bubble then
    roleDataTb.can_show_rp_bubble = roleData.can_show_rp_bubble
  end
  if roleData.bgmi_wiki and roleData.common_red_point_cfg then
    local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
    Logic_Activity_Center.SetCenterMessageRedPoint(roleData.common_red_point_cfg)
    if not FuncUtil.IsPlayerJPKR() then
      local logic_vlink_sdk = require("client.slua.logic.vlink_sdk.logic_vlink_sdk")
      logic_vlink_sdk.SetSwitchCfgData(roleData.bgmi_wiki, roleData.common_red_point_cfg)
    end
  end
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  LogicSettingBasic.bSeasonFriendDataPrivacy = roleData.season_reward_head_frame_privacy
  if roleData.prime_badge_no_show_flag ~= nil then
    if roleData.prime_badge_no_show_flag == 0 then
      LogicSettingBasic.bShowSubscribeBadge = true
    else
      LogicSettingBasic.bShowSubscribeBadge = false
    end
  end
  roleDataTb.bag_pendants = roleData.bag_pendants or {}
  DataMgr.InitRoleData(roleDataTb)
  DataMgr.InitRoleSetting(roleData.role_setting)
  DataMgr.new_privacy_policy_flag = roleData.new_privacy_policy_flag
  DataMgr.on_get_newbie_guide_rsp(0, roleData.newbie_guide or {})
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.ResetData()
  log(bWriteLog and "[ZH] get segment_rating")
  if roleData.segment_rating then
    DataMgr.roleData.segment_rating = roleData.segment_rating
  end
  if roleData.upass then
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.ProcLoginSyncPassData(roleData.upass)
  end
  if roleData.authorize_list then
    log(bWriteLog and "Get authorize_list")
    local SettingPlatformSystem = require("client.slua.logic.setting.logic_platform")
    SettingPlatformSystem.SaveAuthorizeInfo(roleData.authorize_list)
  end
  if roleData.easy_buy_limits then
    local CommonItemBuySystem = require("client.slua.logic.common.logic_common_item_buy")
    CommonItemBuySystem.limits_table = roleData.easy_buy_limits
  end
  if roleData.au_code then
    local CrewAuthLogic = require("client.slua.logic.crew.logic_crew_authentication")
    CrewAuthLogic.SetAuthCode(roleData.au_code)
  end
  if roleData.top_red_point_info then
    local logic_lobby_main = require("client.slua.logic.lobby.logic_lobby_main")
    logic_lobby_main.RecordLobbyTopReddotData(roleData.top_red_point_info)
  end
  if roleData.grome_control then
    local logic_grome_link = require("client.slua.logic.gromelink.logic_grome_link")
    logic_grome_link:OnSyncBaseInfoWithGRomeControl(roleData.grome_control)
  end
  if roleData.cloud_game_info then
    local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
    logic_cloud_game:onSyncBaseInfo(roleData.cloud_game_info)
  end
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  logic_outfit_combination:SetOpenRandomByServer(roleData.support_outfit_sys)
  logic_outfit_combination:OnDailyRandomOutfitCombination(roleData.open_combinations_random)
  log(bWriteLog and "  : login_module.isRelogin: " .. tostring(login_module.bIsRelogin))
  local logic_main_city_music = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_music)
  logic_main_city_music:InitLoginStatus()
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LbsMgr.UpdateWarZoneInfo(roleData.lbs_warzone_info)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  login_module:SetisInitLogin(true)
  StarterPackSystem.InitLastlogin(roleData.old_last_login_time)
  Client.SetTestEditorNum(-460, tostring(roleData.openid), "test", 0)
  if roleData.cutscenes_id then
    local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
    KeyPlayVideoSystem.videoId = roleData.cutscenes_id
    log(bWriteLog and "KeyPlayVideoSystem.videoId = " .. tostring(KeyPlayVideoSystem.videoId))
  end
  local Unbind_Mgr = require("client.slua.logic.unbind_account.logic_unbind")
  log_tree(bWriteLog and "unbind_social_account", roleData.unbind_social_account)
  Unbind_Mgr.SyncUnbindData(roleData.unbind_social_account)
  Unbind_Mgr.SyncUnbindOpen(roleData.unbind_social_account_switch)
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  if LogicSettingGraphics.GraphicsSeparate() then
    LogicSettingGraphics.GenerateSeparatedGraphicsSettings()
  end
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.EnableRecommend = roleData.enable_sidebar_recommend
  log(bWriteLog and "[newGuideSwitch] sync_base_info " .. tostring(roleData.newbie_guide_open))
  local newbie_guide_open = roleData.newbie_guide_open or 0
  LobbySystem.newGuideSwitch = newbie_guide_open == 1
  local logic_season_switch_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_switch_slap)
  logic_season_switch_slap:SaveSeasonSwitchData(roleData.season_switch_display)
  if roleData.system_entrance_config then
    DataMgr.roleData.system_entrance_config = roleData.system_entrance_config
    if roleData.entrance_count then
      DataMgr.roleData.system_entrance_config.entrance_count = roleData.entrance_count
    end
    if roleData.last_entrance_show_guide then
      DataMgr.roleData.system_entrance_config.last_entrance_show_guide = roleData.last_entrance_show_guide
    end
    if roleData.last_entrance_show_guide then
      DataMgr.roleData.system_entrance_config.more_entrance_count = roleData.more_entrance_count or 0
    end
  end
  if not login_module.bIsRelogin then
    log(bWriteLog and "[qintong] : in game  enter_guide.Start " .. slua.getMicroseconds())
    local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
    PlayerLabelHandler.OnReceData(roleData.match_num)
    PlayerLabelHandler.OnReceWarm(roleData.match_client_type_history)
    local enter_guide = require("client.slua.logic.growth_project.enter_guide")
    enter_guide.SaveData(roleData.growup_novice_level)
    if LobbySystem.CheckUseNewGuide() then
      log(bWriteLog and "============>NewGuide new guide is_first_login: " .. tostring(roleData.is_first_login))
      if roleData.is_first_login == LobbySystem.NewbieRoleState.Init then
        TeamUpNewSystem.team_info_request()
        local NewModeHandler = require("client.network.Protocol.NewModeHandler")
        NewModeHandler.send_get_mode_shield_v2_req()
        log(bWriteLog and "============>NewGuide send mode shield req")
        LobbySystem.WaitForMatchMod(roleData)
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        LogicUGC:GetGalleryParamConfig()
      else
        LocalEnterLobby()
      end
    else
      LocalEnterLobby()
    end
    LobbySystem.query_gm_request()
  else
    log(bWriteLog and "duan xian chogn lian team_info_request")
    TeamUpNewSystem.ReconnectFetchTeamUpInfo()
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_RECONNECT)
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  logic_player_return.HandleHideUIWhenPlayerReturn()
  if roleData.last_battlerecord_stats then
    logic_player_return.SetWarmData(roleData.last_battlerecord_stats)
  end
  local PufferDownloadHandler = require("client.network.Protocol.PufferDownloadHandler")
  PufferDownloadHandler.send_mini_client_reward_cfg_req()
  PufferDownloadHandler.reserve_download_version = ""
  if roleData.reserve_download and roleData.reserve_download.cli_sub_ver then
    local cli_sub_ver = roleData.reserve_download.cli_sub_ver
    log(bWriteLog and "roleData.reserve_download.cli_sub_ver: " .. cli_sub_ver)
    local StringUtil = require("common.string_util")
    cli_sub_ver = string.sub(cli_sub_ver, 1, -3)
    local appVersion = Client.GetApplicationVersion()
    if not StringUtil.Starts(appVersion, cli_sub_ver) then
      PufferDownloadHandler.send_reserve_download(1)
      PufferDownloadHandler.reserve_download_version = roleData.reserve_download.cli_sub_ver
    end
  else
    PufferDownloadHandler.send_reserve_download(1)
  end
  LobbySystem.GetClientBasicCfg()
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  ItemUpGradeHandler.send_upgrade_query_accessory_req()
  ItemUpGradeHandler.send_taluo_get_dress_change_gun_flag_req()
  ItemUpGradeHandler.send_upgrade_query_refit_req()
  local lobbyHandler = require("client.network.Protocol.LobbyHandler")
  lobbyHandler.send_get_release_notes()
  local MinorVerificationSystem = require("client.slua.logic.minor_verification.logic_minor_verification")
  MinorVerificationSystem.Init(roleData.minor_verification_info, roleData.debug_use_five_phone)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local _ = logic_subscribe_handler.GetSubscribeModuleObj()
  local logic_player_return_login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_login)
  logic_player_return_login:InitData(roleData.back_user_data)
  local ui_show_queue_manager = require("client.common.uibase.ui_show_queue_manager")
  ui_show_queue_manager.OnLogin()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  if season_year_util.CheckFunctionIsOpen() then
    local logic_season_year_badge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_year_badge)
    logic_season_year_badge:ReqSeasonYearBadgeInfo(false)
  end
  local logic_newbie_activity_reddot = require("client.slua.logic.activity.newbie.logic_newbie_activity_reddot")
  local logic_newbie_reward_abtest_reddot = require("client.slua.logic.activity.newbie.logic_newbie_reward_abtest_reddot")
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    logic_newbie_reward_abtest_reddot.InitData()
  elseif NewbieActivitySystem.activity_data then
    log(bWriteLog and "NewbieActivityRedDot.InitData from sync_base_info")
    logic_newbie_activity_reddot.InitData()
  end
  log(bWriteLog and "postEvent EVENTID_LOGIN_SUCCESS")
  local utility = require("common.utility")
  for _, path in pairs(LoginSuccessModules) do
    local logic = require(path)
    xpcall(logic.OnLogin, utility.ErrorMessageHandler, login_module.bIsRelogin)
  end
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, login_module.bIsRelogin)
  LobbySystem.OnPostLogin(roleData, roleDataTb)
  logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.SyncBaseInfoStartToSyncBaseInfoEnd)
  logic_time_cost_report:SetStepStart(time_step_macros.ENUM_TIME_STEP.SyncBaseInfoEndToLoadingUIClose)
end
function LobbySystem.OnPostLogin(roleData, roleDataTb)
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  logic_gamelet_interface:OnLoginGameLetImpl(false)
  log(bWriteLog and "[Login process] LobbySystem.on_sync_base_info DelayInitFun start")
  LobbySystem.ShowKrJpDelAccountPanel()
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  if enter_guide.CheckIsDoing() then
    enter_guide.StartZoneListInfoRspTimer()
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  ZoneSystem.InitSendReqInfo()
  ZoneSystem.query_match_zone_list_req()
  ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  TournamentsManager.Init()
  if roleData.week_signup_info ~= nil then
    local WeekSignMgr = require("client.slua.logic.week_sign.logic_weeksign")
    WeekSignMgr.SetSignUpTable(roleData.week_signup_info)
  end
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.InitActorVoiceInfo()
  log(bWriteLog and "BP_NA" .. " sended")
  LobbySystem.RecordRoleDataToLocal(roleDataTb.uid or "", roleDataTb.nickName or "", roleDataTb.openID or "")
  Client.GEMReportEnterLobbyEvent(GameFrontendHUD, true, "Success")
  LobbySystem.InitCrossDayHandle()
  if roleData.ab_testing_groupid ~= nil then
    DataMgr.roleData.ab_testing_groupid = roleData.ab_testing_groupid
    log(bWriteLog and "ABTest###   AB tag \239\188\154" .. tostring(roleData.ab_testing_groupid))
    local telemetry_file_name = string.format("%s_%s", "SaveGames/ABTesting", "tel.bin")
    local bHasSavedGrouId = false
    if not StarterPackSystem.lastLogoutTime or StarterPackSystem.lastLogoutTime == 0 then
      log(bWriteLog and "ZK this is a new user")
    else
      local str = Client.LoadFileToString(telemetry_file_name)
      if str ~= nil and str ~= "" then
        local tab = json.decode(str)
        for k, v in pairs(tab) do
          if k == "abtesting" and v == roleData.ab_testing_groupid then
            log(bWriteLog and "ZK get " .. tostring(k) .. "  " .. tostring(v))
            bHasSavedGrouId = true
          end
        end
      end
    end
    if bHasSavedGrouId == false then
      local tab = {}
      tab.abtesting = roleData.ab_testing_groupid
      local jsonStr = json.encode(tab)
      log(bWriteLog and "ZK Save Json file for ab testing , ID " .. roleData.ab_testing_groupid)
      Client.SaveStringToFile(jsonStr, telemetry_file_name)
      log(bWriteLog and "ABTest###   AB teletry: " .. tostring(roleData.ab_testing_groupid))
      gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_StarterPack, gem_report_utils.SubEventName_ABTestingGroup, tostring(DataMgr.roleData.uid), tostring(roleData.ab_testing_groupid))
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.ABTestingGroup, 0, tostring(roleData.ab_testing_groupid))
    end
  else
    log(bWriteLog and "ABTest###   AB tag \239\188\154null")
  end
  xpcall(function()
    gem_report_utils.ReissueSendCachedGEMReport()
  end, require("common.utility").ErrorMessageHandler)
  log_shipping_client("[Login process] LobbySystem.on_sync_base_info end")
  LobbySystem.EnableEncryptedPaks(roleData.encrypted_paks)
  if LobbySystem.CheckOpen(1002022) then
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_get_backup_ip_req()
  end
  local cdn_downloader = require("client.common.cdn_downloader")
  cdn_downloader.DeleteExpiredFiLe()
  local achievement_newflag_helper = require("client.slua.logic.achievement.achievement_newflag_helper")
  achievement_newflag_helper.Init()
  if roleData.reported_player_battle_score then
    local BattleEvaluationCondition = require("client.slua.logic.GuideFlow.Condition.BattleEvaluationCondition")
    log(bWriteLog and "login,SetBattleType" .. roleData.reported_player_battle_score.battleType)
    log(bWriteLog and "login,SetScore" .. roleData.reported_player_battle_score.score)
    BattleEvaluationCondition.SetBattleType(roleData.reported_player_battle_score.battleType)
    BattleEvaluationCondition.SetScore(roleData.reported_player_battle_score.score)
  end
  if roleData.client_sponsor_award and 0 < #roleData.client_sponsor_award then
    local award_data = roleData.client_sponsor_award[1]
    if award_data then
      local ShareMgr = require("client.logic.share.share_logic")
      ShareMgr.SetSponsorAward(award_data.reward_cnt, award_data.refresh_time)
    end
  end
  LobbySystem.LoadAmendODs(roleData.encryption_info)
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:SaveClickedBubbleIDList(roleData.moment_bubble)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve.nAllowReserveFlag = roleData.friend_appointment_privacy
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  logic_team_platform_new:UpdateSwitch(roleData.use_conscribe_recruit)
  local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
  logic_chat_recruit_msg:UpdateNewPlanSwitch(roleData.use_conscribe_fetch_recruit)
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  logic_season_lookback:SetLookBackSwitchInfo(roleData.season_lookback_switch_info)
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  LogicCustomerService.SetGameletSDKSwitch(roleData.teg_customer_switch)
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  logic_zone_delay.SetShadowRegion(roleData.shadow_region)
  local LogicTraceSystem = require("client.slua.logic.network_trace.logic_trace")
  LogicTraceSystem.UpdateTraceSvrCfg(roleData.shadow_trace_cfg or {})
  local logic_light_board = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_light_board)
  logic_light_board:InitLightBoardInfo(roleData)
  local logic_ugc_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment)
  logic_ugc_comment:SetSupportCommentData(roleData.support_comment_data)
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:SetSupportAppreciationCommentData(roleData.review_panel_support_data)
  local logic_ugc_copilot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_copilot)
  logic_ugc_copilot:OnSyncInfoUpdated()
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.limitedTimeActMissionRedData = roleData.limitd_task_award_tip
  local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
  logic_advertisement_BlueHole:send_get_bh_google_ad_info_req()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:send_get_qrcode_login_data_req()
  if roleData.common_red_point_cfg and roleData.common_red_point_cfg[5] then
    local logic_co_creation_base = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_co_creation_base)
    logic_co_creation_base:SetCreationRedHotData(roleData.common_red_point_cfg[5])
  end
  local logic_manor_draw_reward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_manor_draw_reward)
  logic_manor_draw_reward:SetIsRun(roleData.open_manor_draw_reward)
  local logic_lobby_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_souvenirs)
  logic_lobby_souvenirs:SetMySouvenirsData(roleData.collection_sys)
  local logic_home_collection_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_collection_task)
  logic_home_collection_task:RequestManorTaskCfg()
  local logic_popular_home_pk_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk_task)
  logic_popular_home_pk_task:SetAwardFlag(roleData.manor_pk_task_award_flag)
  local logic_home_golden_tree = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_golden_tree)
  logic_home_golden_tree:SetPlantingCollectInfo(roleData.manor_tree_collect_limit)
  logic_home_golden_tree:SetPlantingWaterInfo(roleData.manor_tree_water_limit)
  logic_home_golden_tree:SetPlantingFeedInfo(roleData.manor_tree_feed_limit)
  LogicSettingBasic.SetShowChatRoom(roleData.chat_channel_status_switch)
  local logic_ugc_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
  logic_ugc_season:SetUGCSeasonSegmentData(roleData.ugc_segment_info)
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:GetRankMechanism(roleData.ugc_ui_abtest and roleData.ugc_ui_abtest.gallery_explore_mix_abtest or 0)
  local Logic_UGC_Personalization = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_personalization)
  Logic_UGC_Personalization:SetABTest(roleData.ugc_ui_abtest and roleData.ugc_ui_abtest.guess_you_like_config_abtest or 0)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.ProcessSyncBaseInfo)
  local logic_vng_personal_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_vng_personal_info)
  logic_vng_personal_info:RequestVNGPersonalInfoWhenLogin()
  print(bWriteLog and "[LobbySystem.on_sync_base_info] call CHiggsBosonComponent.OnLogin()")
  local CHiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
  CHiggsBosonComponent.OnLogin()
  if roleData.anchor_random_name and roleData.anchor_random_name ~= "" then
    local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
    LogicPeakGame.peakgameHideName = 1
    LogicPeakGame.peakgame_anchorName = roleData.anchor_random_name
  end
  local logic_ugc_active_motivation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_active_motivation)
  logic_ugc_active_motivation:SetActiveMotivationState(roleData.incentive_program_join_state)
  local logic_ugc_new_map = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_map)
  logic_ugc_new_map:SetNewMapABTest(roleData.ugc_ui_abtest and roleData.ugc_ui_abtest.gallery_new_mod_abtest or 0)
  local logic_ugc_mine = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mine)
  logic_ugc_mine:SetMineABTest(roleData.ugc_ui_abtest and roleData.ugc_ui_abtest.mine_homepage_abtest or 0)
  local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
  logic_ugc_intention:SetIntentionABTest(roleData.ugc_ui_abtest and roleData.ugc_ui_abtest.recomm_fresh_abtest or 0)
  local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
  logic_ugc_new_process:SetNewbieGuideData(roleData.wow_newbie_guide_data or {})
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and not PublishRegionMacros.IsJapanOrKorea() then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local rewardData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoginTwoStepReward) or {}
    log_tree("LobbySystem.OnPostLogin. rewardData = ", rewardData)
    if not rewardData[DataMgr.roleData.uid] then
      local LoginHandler = require("client.network.Protocol.LoginHandler")
      local version_util = require("client.common.version_util")
      local verNum = version_util.GetCurVersionNumber()
      LoginHandler.send_get_two_step_download_reward_req(tostring(verNum))
      rewardData[DataMgr.roleData.uid] = true
      PlayerPrefsSystem.SaveTableToFile_N(rewardData, PlayerPrefsSystem.ePlayerPrefsType.eLoginTwoStepReward)
    end
  end
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  Logic_UGC:GetAllAutoTransEnabled()
  Logic_UGC:SetFreeInOutLevel(roleData.free_inout_join_level)
  local logic_card_collection_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collection_season)
  logic_card_collection_season:QuerySwapClaimOnLogin()
end
function LobbySystem.set_vulkan_status()
  LobbySystem.vulkan_whitelist = LobbySystem.roleData.get_vulkan_switch_status
  if Client.GetForceVulkanAvailable() then
    LobbySystem.vulkan_whitelist = 1
  end
  if LobbySystem.vulkan_whitelist == 1 then
    log(bWriteLog and "[Masou]LobbySystem.set_vulkan_status, Enable Vulkan Switch!")
  else
    Client.SetUserVulkanSetting(false)
    log(bWriteLog and "[Masou]LobbySystem.set_vulkan_status, Disable Vulkan Switch!")
  end
end
function LobbySystem.CheckVulkanWhiteListEnable()
  if Client.GetForceVulkanAvailable() then
    return true
  end
  if LobbySystem.vulkan_whitelist == 1 then
    return true
  else
    return false
  end
end
function LobbySystem.WaitForMatchMod(roleData)
  local onGetMatchMod
  logic_connection_waiting:Show(1)
  local time_ticker = require("common.time_ticker")
  local timer = time_ticker.AddTimerOnce(5, function()
    logic_connection_waiting:Hide(1)
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD, onGetMatchMod)
    LobbySystem.roleData.is_first_login = LobbySystem.NewbieRoleState.UpdateRole
    LocalEnterLobby()
    log(bWriteLog and "============>NewGuide match timeout")
    local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
    logicCreateRole.SetNewGuideMatchTimeOut(true)
  end)
  function onGetMatchMod()
    log(bWriteLog and "============>NewGuide match mod")
    logic_connection_waiting:Hide(1)
    time_ticker.RemoveTimer(timer)
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD, onGetMatchMod)
    if roleData.growup_novice_level then
      local LogicNewbie = require("client.logic.newbie.logic_newbie")
      local uiConfig = LogicNewbie.GetWelcomeUIConfig()
      UIManager.ShowUI(uiConfig)
    else
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.SetInitPercent(0)
      LoadingSystem.ShowLoading(true)
      LobbySystem.DirectStartMatch()
      LobbySystem.roleData.is_first_login = LobbySystem.NewbieRoleState.UpdateRole
    end
  end
  EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD, onGetMatchMod)
end
function LobbySystem.DirectStartMatch()
  log(bWriteLog and "LobbySystem.DirectStartMatch")
  local zoneSystem = require("client.slua.logic.teamup.logic_zone")
  if zoneSystem.autoChooseZoneFinished then
    LobbySystem.CheckNewMode()
  else
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, 5, EVENTTYPE_TEAMUP, EVENTID_AUTO_CHOOSE_ZONE_END)
      LobbySystem.CheckNewMode()
    end)
  end
end
function LobbySystem.CheckNewMode()
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local needChanged = newbieGuideManager.ChangeMatchCount(1, function()
    log(bWriteLog and "============>LobbySystem CheckNewMode DirectStartMatchImpl")
    LobbySystem.DirectStartMatchImpl()
  end)
  if not needChanged then
    LobbySystem.DirectStartMatchImpl()
  end
  LobbySystem.WaitForMatchSuccess()
end
function LobbySystem.DirectStartMatchImpl()
  log(bWriteLog and "LobbySystem.DirectStartMatchImpl")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local defaultMatchID = MatchModeMgrSystem.nSelectMatchID
  if defaultMatchID == 0 then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local teamInfo = TeamUpNewSystem.teamInfo
    if teamInfo and teamInfo.team_type then
      defaultMatchID = tonumber(teamInfo.team_type)
    end
    if not defaultMatchID or defaultMatchID == 0 then
      MatchModeMgrSystem.nSelectMatchID = MatchModeMgrSystem.GetDefaultMatchID()
    end
  end
  local autoFill = 0
  if Client.IsShipping() then
    autoFill = MatchModeMgrSystem.bAutoMatch and 1 or 0
  end
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  if newbieGuideManager.NewbieFlagFor200() then
    if defaultMatchID == 113 then
      defaultMatchID = 111
    end
    autoFill = 0
  end
  log(bWriteLog and "LobbySystem.DirectStartMatchImpl NewGuide start matching, matching mode = " .. tostring(defaultMatchID) .. " fill = " .. tostring(autoFill))
  local arrayMapId = MatchModeMgrSystem.CheckDataBeforeMatch(defaultMatchID)
  log_tree("LobbySystem.DirectStartMatchImpl arrayMapId =", arrayMapId)
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_on_match_req(defaultMatchID, autoFill, arrayMapId, DeviceOSInfo.InfoList)
end
function LobbySystem.WaitForMatchSuccess()
  local onMatchSuccess
  local time_ticker = require("common.time_ticker")
  local timer = time_ticker.AddTimerOnce(30, function()
    log(bWriteLog and "LobbySystem.WaitForMatchSuccess NewGuide on_match_success timeout")
    LobbySystem.roleData.is_first_login = LobbySystem.NewbieRoleState.UpdateRole
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.ResetData()
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS, onMatchSuccess)
    log(bWriteLog and "LobbySystem.WaitForMatchSuccess NewGuide send match cancel")
  end)
  function onMatchSuccess()
    log(bWriteLog and "LobbySystem.WaitForMatchSuccess NewGuide on_match_success")
    time_ticker.RemoveTimer(timer)
    EventSystem:unregistEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS, onMatchSuccess)
  end
  EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS, onMatchSuccess)
end
function LobbySystem.SendEigeninfo(eigeninfo, call_from_type)
  if not Client.IsShipping() and LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_CLOSE_EIGENINFO_DEV) then
    return
  end
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  log_shipping_client("SendEigeninfo")
  local needLog = 0
  local ErrorCode = 0
  if eigeninfo then
    if needLog == 1 then
      log_tree("SendEigeninfo eigeninfo", eigeninfo)
    end
    for k, v in pairs(eigeninfo) do
      if v then
        local infoName = tostring(v.file_name)
        local infoValue = tostring(v.eigenvalue)
        local crc = v.crc
        local len = #infoValue
        log_shipping_client("SendEigeninfo EigenvalueId = " .. tostring(k))
        local EigeninfoStr = string.format(" Client.SendEigeninfo infoName=%s, len=%s, crc=%s", tostring(infoName), tostring(len), tostring(crc))
        log_shipping_client(EigeninfoStr)
        if v.eigenvalue ~= nil and v.file_name ~= nil and v.crc ~= nil then
          _G.Tss = _G.TssManager
          if Tss then
            local _, ret = xpcall(function()
              local ret = Tss.SendEigeninfoData(infoName, infoValue, len, crc, needLog)
              return ret
            end, function(err)
              log_shipping_client("SendEigeninfo call Tss.SendEigeninfoData failed: " .. tostring(err))
              local utility = require("common.utility")
              utility.ErrorMessageHandler(err)
              local strReport = EigeninfoStr .. " debug:" .. tostring(err) .. " infovalue:" .. infoValue
              local iDisable = HDmpveRemote.HDmpveRemoteConfigGetInt("EigenReportReportLvl", 0)
              log_shipping_client("SendEigeninfo EigenReportReportLvl: " .. tostring(iDisable))
              if tonumber(iDisable) == 1 then
                strReport = EigeninfoStr .. " debug:" .. tostring(err)
              elseif tonumber(iDisable) == 2 then
                strReport = EigeninfoStr
              end
              gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_Gokuba, gem_report_utils.SubEventName_TssSetError, tostring(7) .. strReport, tostring(call_from_type))
            end)
            if ret then
              log_shipping_client("SendEigeninfo Tss.SendEigeninfoData ret = " .. tostring(ret))
              ErrorCode = tonumber(ret)
              if tonumber(ret) ~= 0 then
                gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_Gokuba, gem_report_utils.SubEventName_TssSetError, tostring(5) .. EigeninfoStr, tostring(call_from_type), tonumber(ret))
              else
                gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_Gokuba, gem_report_utils.SubEventName_TssSetError, tostring(6), tostring(call_from_type), tonumber(ret))
              end
            end
          else
            log_shipping_client("SendEigeninfo Tss is nil")
            ErrorCode = 101
            gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_Gokuba, gem_report_utils.SubEventName_TssSetError, tostring(0), tostring(call_from_type))
          end
        else
          log_shipping_client("SendEigeninfo eigenvalue or file_name or crc is nil")
          ErrorCode = 102
          gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_Gokuba, gem_report_utils.SubEventName_TssSetError, tostring(1), tostring(call_from_type))
        end
      else
        log_shipping_client("SendEigeninfo v is nil")
        ErrorCode = 103
        gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_Gokuba, gem_report_utils.SubEventName_TssSetError, tostring(2), tostring(call_from_type))
      end
    end
  else
    log_shipping_client("SendEigeninfo eigeninfo is nil")
    ErrorCode = 104
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_Gokuba, gem_report_utils.SubEventName_TssSetError, tostring(3), tostring(call_from_type))
  end
  if call_from_type == 1 then
    Tss.SaveSendEigeninfoCode(ErrorCode)
  end
end
function LobbySystem.EnableEncryptedPaks(encrypted_paks)
  log(bWriteLog and "Enable EncryotedPaks")
  if not encrypted_paks or not next(encrypted_paks) then
    return
  end
  for i, k in pairs(encrypted_paks) do
    local path = ""
    local filename = ""
    if Client.IsSplitMiniPakVersion() == false then
      filename = "res_minerva" .. tostring(i) .. "_obb.pak"
      path = Client.ProjectContentDir() .. "paks/" .. filename
    else
      filename = "res_minerva" .. tostring(i) .. "_" .. Client.GetApplicationVersion() .. ".pak"
      path = Client.ProjectSavedDir() .. "paks/" .. filename
    end
    if Client.IsFileExistsWithPakCheck(path) then
      log(bWriteLog and "Start to mount " .. tostring(path))
      local success = Client.MountPakFile(path, k)
      local param = {
        tostring(success),
        tostring(false),
        tostring(filename)
      }
      PufferDownloader.GEMReportSubEvent("PufferMountPak", param)
    else
      log(bWriteLog and "Mount Failed" .. tostring(path) .. " not exist!")
    end
  end
end
function LobbySystem.on_sync_player_ban(banData)
  log_tree("on_sync_player_ban", banData)
  DataMgr.InitBanData(banData)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.IsMatchInBanList() then
    MatchSystem.SetMatchBanStatus()
  end
end
function LobbySystem.RecordRoleDataToLocal(roleID, nickName, openID)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local tempStr = "{\"openID\" : %s ,\"nickName\" : \"%s\", \"realOpenID\" : %s }"
    local saveStr = string.format(tempStr, tostring(roleID), tostring(nickName), tostring(openID))
    Client.SaveStringToFile(saveStr, "/RoleInfo/RoleInfo.json")
  end
end
function LobbySystem.OnBattleBeginPlay()
  log(bWriteLog and "----enter battle success---")
  NetUtil.EnterBattleLoadingTime = TimeUtil.OSTime() - NetUtil.waitingEnterBattleStartTime
  NetUtil.StopCheckEnterBattle()
  local LogicGRomelink = require("client.slua.logic.gromelink.logic_grome_link")
  LogicGRomelink:OnEnterBattleResult(LogicGRomelink.ENUM_ENTER_GAME_RET.SUCC)
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "LobbySystem.OnBattleBeginPlay isInMainCity = " .. tostring(isInMainCity))
  if not isInMainCity then
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.RefreshLoadPercent(1)
  end
  if LobbySystem.is_DeathMatchMode == true then
    log(bWriteLog and "LoadingDeathMatchUI OnBattleBeginPlay RefreshLoadPercent=1")
    LobbySystem.TDMLoadingSuccess = true
    local timer_ticker = require("common.time_ticker")
    if LobbySystem.OnBattleBeginPlayTimer ~= nil then
      timer_ticker.RemoveTimer(LobbySystem.OnBattleBeginPlayTimer)
      LobbySystem.OnBattleBeginPlayTimer = nil
    end
    if LobbySystem.TeamShowReadySuccess then
      LobbySystem.OnBattleBeginPlayTimer = timer_ticker.AddTimerOnce(1, function()
        log(bWriteLog and "LoadingDeathMatchUI OnBattleBeginPlay RefreshLoadPercent=1 delay")
        local TeamCompLoading = require("client.slua.logic.loading.logic_teamcomp_loading")
        TeamCompLoading.RefreshLoadPercent(1)
      end, false)
    else
      LobbySystem.OnBattleBeginPlayTimer = timer_ticker.AddTimerOnce(10, function()
        log(bWriteLog and "LoadingDeathMatchUI OnBattleBeginPlay RefreshLoadPercent=1 delay")
        local TeamCompLoading = require("client.slua.logic.loading.logic_teamcomp_loading")
        TeamCompLoading.RefreshLoadPercent(1)
      end, false)
    end
  end
  LobbySystem.SetWaitingBattleFlag(false)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.GetGameFrontendHUD() ~= nil then
    UIUtil.GetGameFrontendHUD():SetClientEnterBattleStage("EnterBattleSuccess")
  end
  UnrealNet.HandleNetworkExceptionReport("EnterBattleSuccess", "", "")
  local memorySize = Client.GetMemorySize()
  if memorySize < 2 then
    UIManager.CloseUI(UIManager.UI_Config.loading)
    local ui_pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
    ui_pool:Clear()
    log(bWriteLog and "ClientEntry -----  loading bp closed!")
  end
  local timer_ticker = require("common.time_ticker")
  if LobbySystem.ReportNetContinuousSaturateTimer ~= nil then
    timer_ticker.RemoveTimer(LobbySystem.ReportNetContinuousSaturateTimer)
    LobbySystem.ReportNetContinuousSaturateTimer = nil
  end
  LobbySystem.ReportNetContinuousSaturateTimer = timer_ticker.AddTimerOnce(60, LobbySystem.TickCheckDSNetContinuousSaturate, false)
end
function LobbySystem.TDMTeamShowReady()
  log(bWriteLog and "LobbySystem.TDMTeamShowRead RefreshLoadPercent =1")
  LobbySystem.TeamShowReadySuccess = true
  if LobbySystem.is_DeathMatchMode == true and LobbySystem.TDMLoadingSuccess then
    local timer_ticker = require("common.time_ticker")
    if LobbySystem.OnBattleBeginPlayTimer ~= nil then
      timer_ticker.RemoveTimer(LobbySystem.OnBattleBeginPlayTimer)
      LobbySystem.OnBattleBeginPlayTimer = nil
    end
    if LobbySystem.OnBattleBeginPlayTimer2 ~= nil then
      timer_ticker.RemoveTimer(LobbySystem.OnBattleBeginPlayTimer2)
      LobbySystem.OnBattleBeginPlayTimer2 = nil
    end
    LobbySystem.OnBattleBeginPlayTimer2 = timer_ticker.AddTimerOnce(1, function()
      log(bWriteLog and "LoadingDeathMatchUI TDMTeamShowReady RefreshLoadPercent=1 delay")
      local TeamCompLoading = require("client.slua.logic.loading.logic_teamcomp_loading")
      TeamCompLoading.RefreshLoadPercent(1)
    end, false)
  end
end
function LobbySystem.TickCheckDSNetContinuousSaturate()
  if GameStatus.IsInFightingStatus() then
    local UIUtil = require("client.common.ui_util")
    if UIUtil.GetGameFrontendHUD() ~= nil then
      UIUtil.GetGameFrontendHUD():ReportNetContinuousSaturate()
    end
    local timer_ticker = require("common.time_ticker")
    LobbySystem.ReportNetContinuousSaturateTimer = timer_ticker.AddTimerOnce(60, LobbySystem.TickCheckDSNetContinuousSaturate, false)
  else
    LobbySystem.ReportNetContinuousSaturateTimer = nil
  end
end
function LobbySystem.ReportNetContinuousSaturate(CurrentTime, SaturateTime, SaturateFrames)
  NetUtil.SendPkg("report_client_net_continuous_saturate", CurrentTime, SaturateTime, SaturateFrames)
  log(bWriteLog and "UnrealNet ContinuousSaturateReport, Time: " .. tostring(CurrentTime) .. ", SaturateTime: " .. tostring(SaturateTime) .. ", SaturateFrames: " .. tostring(SaturateFrames))
end
function LobbySystem.CrashKitReportNetContinuousSaturate(CurrentTime, SaturateTime, SaturateFrames, SaturateInfo)
  log(bWriteLog and "UnrealNet CrashKitReportNetContinuousSaturate, Time: " .. tostring(CurrentTime) .. ", SaturateTime: " .. tostring(SaturateTime) .. ", SaturateFrames: " .. tostring(SaturateFrames) .. ", SaturateInfo: " .. tostring(SaturateInfo))
  local CrashKitReportString = string.format([[
GameTime:%d, SaturateTime:%f, SaturateFrames:%u
SaturateInfo:
%s]], CurrentTime, SaturateTime, SaturateFrames, SaturateInfo)
  local BuglyExceptionName = "ClientNetContinuousSaturate"
  local bIsReportBuglyNetContinuousSaturate = false
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  if GameReportUtils and GameReportUtils.CheckCanBugglyPostException(BuglyExceptionName) then
    bIsReportBuglyNetContinuousSaturate = GameReportUtils.BugglyPostExceptionFull(BuglyExceptionName, CrashKitReportString, Client.IsEditor() or Client.IsDevelopment())
  end
  if bIsReportBuglyNetContinuousSaturate and Client.IsEditor() or Client.IsDevelopment() then
    print(bWriteLog and "UnrealNet CrashKitReportNetContinuousSaturate Content:" .. CrashKitReportString)
  end
end
function LobbySystem.SetWaitingBattleFlag(tFlag)
  log(bWriteLog and "set waitting battle flag to " .. tostring(tFlag))
  LobbySystem.isWaittingEnterBattle = tFlag
end
function LobbySystem.on_start_match_req()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsTeamLeader() == false then
    LobbySystem.change_status_req()
    local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
    logic_main_city_achievement_task_report.ClickStartGameInMainCity(true)
  end
  if TeamUpNewSystem.IsEverybodyReady() == false then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() and TeamUpNewSystem.IsAnyoneInGuiding() then
      ShowNotice(LocUtil.GetLocalizeResStr(22014))
    else
      local data = LocUtil.GetLocalizeResStr(111013)
      ShowNotice(data)
    end
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.nSelectMatchID == 0 then
    MatchModeMgrSystem.nSelectMatchID = MatchModeMgrSystem.GetDefaultMatchID()
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if not MatchSystem.CanMatchInBan(MatchModeMgrSystem.nSelectMatchID) then
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager:MountCurMaps() then
    return
  end
  local autoFill = MatchModeMgrSystem.bAutoMatch and 1 or 0
  log(bWriteLog and "LobbySystem.on_start_match_req matching mode = " .. tostring(MatchModeMgrSystem.nSelectMatchID) .. " fill = " .. tostring(autoFill))
  local arrayMapId = MatchModeMgrSystem.CheckDataBeforeMatch(MatchModeMgrSystem.nSelectMatchID)
  log_tree("LobbySystem.on_start_match_req arrayMapId =", arrayMapId)
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_on_match_req(MatchModeMgrSystem.nSelectMatchID, autoFill, arrayMapId, DeviceOSInfo.InfoList)
  local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
  logic_main_city_achievement_task_report.ClickStartGameInMainCity(true)
  local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
  if logic_mode_asymmertric:GetHasSelectedCamp() then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.AsymMode_Start_Match)
  end
end
function LobbySystem.on_start_match_rsp(msg, waitTime, reason, surplustime, estimatetime, matchLang, ban_count, line_pos, line_speed, is_mentor, res_params, match_guide_cfg, is_all_krjp_region, ext_info)
  log(bWriteLog and "socialperry LobbySystem.on_start_match_rsp")
  if ext_info then
    log_tree("LobbySystem.on_start_match_rsp ext_info = ", ext_info)
  end
  log_tree("res_params = ", res_params)
  local enter_guide = require("client.slua.logic.growth_project.enter_guide")
  if enter_guide.CheckIsDoing() and msg == NetErrorCode_NONE then
    enter_guide.StopMatchRspTimer()
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if msg == NetErrorCode_NONE and not is_all_krjp_region then
    MatchSystem.bIsSwitchServerShowed = true
  end
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_FIGHTING, msg)
  log(bWriteLog and "LobbySystem.on_start_match_rsp, Received on_match_res, msg = " .. tostring(msg) .. ", reason = " .. tostring(reason) .. ", mode = " .. tostring(surplustime) .. ", runawayuid = " .. tostring(ban_count) .. ",is_mentor:" .. tostring(is_mentor))
  logic_connection_waiting:Hide(1)
  local logic_main_city_reconnect = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_reconnect)
  logic_main_city_reconnect:SetIsInTrySwitchMainCityState(false)
  if msg ~= NetErrorCode_NONE then
    if msg == 505046 then
      UIManager.ShowUI(UIManager.UI_Config.crew_safety_detection_peak)
    else
      LobbySystem.HandleMatchErrorCode(msg, waitTime, reason, surplustime, res_params, ext_info)
    end
    local logic_main_city_connect_state = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_connect_state)
    logic_main_city_connect_state:SetConnectingState(false, false)
    logic_main_city_connect_state:SetMainCityReadyChange(false)
    return
  end
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  logic_team_zone_ping:SetNotCrossMatch(ext_info)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.SetJRForceMatch(ext_info)
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  if logic_replay.IsPlayingReplay() then
    ShowNotice(116100021)
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  MatchModeMgrSystem.bIsMatchingSocialIsland = surplustime == 321
  log(bWriteLog and "[   bIsMatchingSocialIsland " .. tostring(MatchModeMgrSystem.bIsMatchingSocialIsland))
  LobbySystem.isInMatch = true
  LobbySystem.forcedExitGameTimes = ban_count
  LobbySystem.isMentorMatch = is_mentor
  log(bWriteLog and "LobbySystem.on_start_match_rsp forcedExitGameTimes = " .. tostring(ban_count))
  MatchSystem.nMatchBeginTime = TimeUtil.GetServerTimeInSec()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_RES_OK, estimatetime, surplustime)
  if UIManager.IsUIShow(UIManager.UI_Config.tournament_teamup) or UIManager.IsUIShow(UIManager.UI_Config.championship_teamup) then
    return
  end
  local LogicMatchEntry = require("client.slua.logic.lobby.Mid.logic_match_entry")
  LogicMatchEntry.ResetDisplayState()
  MatchSystem.StartMatch(estimatetime, matchLang, line_pos, line_speed, ext_info)
  local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
  logic_tournament_main:OnMatchResPreTime(estimatetime)
  if not match_guide_cfg then
    return
  end
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  logic_long_time_match:SetLTMatchTriggerConfig(match_guide_cfg)
  local logic_multi_select_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_multi_select_match)
  logic_multi_select_match:SetMSMatchTriggerCfg(match_guide_cfg.multi_select_match_trigger_cfg)
end
function LobbySystem.HandleMatchErrorCode(msg, waitTime, reason, surplustime, res_params, ext_info)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local str_prompt = LocUtil.GetLocalizeResStr(101001)
  if msg == "no_map" then
    if TeamUpNewSystem.GetTeamNum() <= 1 then
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      logic_mode_selection:ResetModeToAvailableMap()
      local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
      if LogicUGCMulti.bIsBundleMatch then
        ShowNotice(8019)
        LogicUGCMulti:ClearReportCache(true)
      end
    end
    return
  end
  if msg == "mode_shield" then
    ShowNotice(LocUtil.LocalizeResFormat(27180))
    return
  end
  if msg == "owed_state_banned" then
    ShowNotice(LocUtil.GetLocalizeResStr(100000004))
    return
  end
  if msg == "ban-hurt-team-player-matching-error" then
    UIManager.ShowUI(UIManager.UI_Config.ReputationSystem_Punish_Popup_UIBP, reason, waitTime, 2)
    return
  end
  if msg == "someone_in_solo" then
    ShowNotice(LocUtil.GetLocalizeResStr(792255))
    return
  end
  if msg == "invalid_promotion" then
    ShowNotice(LocUtil.GetLocalizeResStr(85158))
    return
  end
  if msg == "mode_banned" or msg == "mode_not_invited" or msg == "match_isolation_label_vs_rank_banned" then
    local time = surplustime
    local date = TimeUtil.FormatTime_YMDHMS(time, true)
    local str = ""
    if msg == "mode_not_invited" then
      str = string.format(DataMgr.GetMultiLineMsgByID(301129), tostring(date))
      reason = reason or ""
      CommonMsgBoxMgr.Show(1, str_prompt, reason .. str)
      return
    end
    if ext_info and ext_info.show_new_window and ext_info.show_new_window == 1 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowDragonBallBanTip(msg, reason, surplustime, ext_info)
      return
    end
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    log(bWriteLog and "LobbySystem.HandleMatchErrorCode msg = " .. tostring(msg))
    log(bWriteLog and "LobbySystem.HandleMatchErrorCode MatchModeMgrSystem.nSelectMatchID = " .. tostring(MatchModeMgrSystem.nSelectMatchID))
    if msg == "match_isolation_label_vs_rank_banned" or FuncUtil.IsRankTeamMode(MatchModeMgrSystem.nSelectMatchID) then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowVSBanTip(msg, surplustime, ext_info)
      return
    end
    str = LocUtil.LocalizeResFormat(25299, date)
    if reason then
      log(bWriteLog and "LobbySystem.HandleMatchErrorCode ban_reason: " .. tostring(reason))
      local ban_reason_id = tonumber(reason)
      if ban_reason_id then
        local HasDone = {
          [38850] = true,
          [37501] = true,
          [100251051] = true
        }
        if HasDone[ban_reason_id] then
          log(bWriteLog and "LobbySystem.HandleMatchErrorCode ban_reason has done")
          local userName = DataMgr.roleData.nickName or ""
          local userUid = DataMgr.roleData.uid or ""
          local time_Str = TimeUtil.FormatCountDownTime_DHMS(surplustime - TimeUtil.GetServerTimeInSec())
          str = LocUtil.LocalizeFormatConcatenation(38850, userName, userUid, time_Str)
        else
          local txt_reason = LocUtil.LocalizeFormatConcatenation(ban_reason_id, date)
          if txt_reason and txt_reason ~= "" then
            str = txt_reason
          else
            log(bWriteLog and "LobbySystem.HandleMatchErrorCode ban_reason is nil :" .. tostring(ban_reason_id))
          end
        end
      else
        str = reason
      end
    end
    CommonMsgBoxMgr.Show(1, str_prompt, str)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if msg == "member-play-banned" or msg == "member-play-not-invited" then
    local tmpdate = TimeUtil.FormatTime_YMDHMS(surplustime, true)
    local str = ""
    if reason == tonumber(DataMgr.roleData.uid) then
      str = LocUtil.LocalizeResFormat(25299, tmpdate)
      CommonMsgBoxMgr.Show(1, str_prompt, str)
    else
      local banned_id = 25300
      if msg == "member-play-not-invited" then
        banned_id = 11981
      end
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local friend = logic_profile:GetLocalProfile(reason)
      if friend ~= nil then
        str = LocUtil.LocalizeResFormat(banned_id, friend.nickName, tmpdate)
        CommonMsgBoxMgr.Show(1, str_prompt, str)
      else
        do
          local uidList = {reason}
          local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
          logic_profile_get_wrap.GetNormalProfiles(uidList, function(list)
            if 1 <= #list then
              str = LocUtil.LocalizeResFormat(banned_id, list[1].nickName, tmpdate)
              CommonMsgBoxMgr.Show(1, str_prompt, str)
            end
          end, Enum_PROFILE_REPORT_CFG.BAN_TEAMMATE_INFO)
        end
      end
    end
    return
  end
  if msg == "ban-multi-player-matching-error" or msg == "vsrank-ban-multi-player-matching-error" then
    UIManager.ShowUI(UIManager.UI_Config.ReputationSystem_Punish_Popup_UIBP, reason, waitTime, 1)
    return
  end
  if msg == "member_mil_ban" then
    local title = LocUtil.GetLocalizeResStr(5077)
    local msgContent = LocUtil.LocalizeResFormat(32634, tostring(reason))
    CommonMsgBoxMgr.Show(1, title, msgContent)
    return
  end
  if msg == "mode_is_shield" or msg == "droiyan_mode_is_close" or msg == "mode_is_closed" then
    local data = LocUtil.GetLocalizeResStr(111022)
    ShowNotice(data)
    return
  elseif msg == "invalid_hunter_in_team" then
    ShowNotice(4002047)
    return
  elseif msg == "too_many_escape" then
    if reason and tonumber(reason) then
      local profileData = logic_profile:GetLocalProfile(tonumber(reason))
      local playerName1 = reason
      if profileData then
        playerName1 = profileData.nickName
      end
      ShowNotice(LocUtil.LocalizeResFormat(64263, playerName1))
    else
      ShowNotice(LocUtil.LocalizeResFormat(4002048, TimeUtil.FormatTime_HMS(waitTime or 0, true)))
    end
    return
  elseif msg == "invalid_all_in_team" then
    ShowNotice(64262)
    return
  end
  if msg == "guest_multi_mode_banned" then
    ShowNotice(LocUtil.LocalizeResFormat(22006))
    return
  end
  if msg == "member-not-ready" then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() and TeamUpNewSystem.IsAnyoneInGuiding() then
      ShowNotice(LocUtil.GetLocalizeResStr(22014))
    else
      local data = LocUtil.GetLocalizeResStr(111013)
      ShowNotice(data)
    end
    return
  end
  if msg == "member-no-valid" or msg == "invalid-pve-member" then
    if waitTime then
      local textKey1, textKey2, textKey3
      if msg == "member-no-valid" then
        textKey1 = 7925
        textKey2 = 7926
        textKey3 = 7927
      else
        textKey1 = 6876
        textKey2 = 6877
        textKey3 = 6878
      end
      local data, playerName1, playerName2, playerName3
      if #waitTime == 1 then
        local profileData = logic_profile:GetLocalProfile(waitTime[1])
        if profileData then
          playerName1 = profileData.nickName
          data = LocUtil.LocalizeResFormat(textKey1, playerName1)
        end
      elseif #waitTime == 2 then
        local profileData1 = logic_profile:GetLocalProfile(waitTime[1])
        local profileData2 = logic_profile:GetLocalProfile(waitTime[2])
        if profileData1 and profileData2 then
          playerName1 = profileData1.nickName
          playerName2 = profileData2.nickName
          data = LocUtil.LocalizeResFormat(textKey2, playerName1, playerName2)
        end
      elseif #waitTime == 3 then
        local profileData1 = logic_profile:GetLocalProfile(waitTime[1])
        local profileData2 = logic_profile:GetLocalProfile(waitTime[2])
        local profileData3 = logic_profile:GetLocalProfile(waitTime[3])
        if profileData1 and profileData2 then
          playerName1 = profileData1.nickName
          playerName2 = profileData2.nickName
          playerName3 = profileData3.nickName
          data = LocUtil.LocalizeResFormat(textKey3, playerName1, playerName2, playerName3)
        end
      end
      if data then
        ShowNotice(data)
      end
    end
    return
  end
  if msg == "guest-limit" then
    local content = LocUtil.LocalizeResFormat("6862")
    ShowNotice(content)
    return
  end
  if msg == "low_priority_match_banned" or msg == "match_isolation_label_banned" then
    local leftTime = TimeUtil.FormatCountDownTime_DHMS(waitTime)
    if reason ~= tonumber(DataMgr.roleData.uid) and TeamUpNewSystem.GetTeamNum() > 1 then
      local str = ""
      local profileData = logic_profile:GetLocalProfile(reason)
      if profileData then
        str = LocUtil.LocalizeResFormat(10361, profileData.nickName, leftTime)
      else
        str = LocUtil.LocalizeResFormat(10361, LocUtil.GetLocalizeResStr(6317), leftTime)
      end
      CommonMsgBoxMgr.Show(1, str_prompt, str)
    else
      local MatchSystem = require("client.slua.logic.match.logic_match")
      if msg == "match_isolation_label_banned" then
        MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29114))
      else
        MatchSystem.ShowBanTip(MatchSystem.GetSelectModeBanTip())
      end
    end
    return
  end
  if msg == "invalid_choosen_mode_groups" then
    log_tree("[ZH] \233\148\153\232\175\175\231\160\129 reason", reason)
    if not reason then
      return
    end
    for k, v in pairs(reason) do
      local textID = ErrorCodeId[v]
      ShowNotice(LocUtil.LocalizeResFormat(textID))
    end
    return
  elseif msg == "invalid_choosen_mode_groups_for_members" then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local _, subViewId = logic_mode_selection:GetCurSelectInfo()
    log_tree("[ZH] \233\148\153\232\175\175\231\160\129 waitTime", waitTime)
    for k, v in pairs(waitTime) do
      if tonumber(DataMgr.roleData.uid) == tonumber(k) then
        local textID = ErrorCodeId[v[subViewId] or 13010001]
        ShowNotice(LocUtil.LocalizeResFormat(textID))
      else
        local textID = ErrorCodeId[(v[subViewId] or 13010001) + 5]
        local PlayerInfo = logic_profile:GetLocalProfile(k)
        if PlayerInfo and PlayerInfo.nickName then
          ShowNotice(LocUtil.LocalizeResFormat(textID, PlayerInfo.nickName))
        end
      end
    end
    return
  end
  if msg == "player_matching" then
    local data = LocUtil.GetLocalizeResStr(111015)
    local msgContent = data
    ShowNotice(msgContent)
    local MatchSystem = require("client.slua.logic.match.logic_match")
    log(bWriteLog and "LobbySystem.HandleMatchErrorCode MatchSystem.QueryPlayerState 1")
    MatchSystem.QueryPlayerState()
  elseif msg == "match_failed" then
    local content = LocUtil.GetLocalizeResStr(9911101)
    ShowNotice(content)
    LobbySystem.ResetMatchInfo()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.MatchCancel()
  elseif msg == "mode_banned" or msg == "mode_not_invited" then
    local content = LocUtil.GetLocalizeResStr(9911102)
    ShowNotice(content)
  elseif msg == "mode_is_shield" then
    local content = LocUtil.GetLocalizeResStr(9911103)
    ShowNotice(content)
  elseif msg == "invalid_match_mode" then
    local content = LocUtil.GetLocalizeResStr(9911104)
    ShowNotice(content)
  elseif msg == "player_gameing" then
    local content = LocUtil.GetLocalizeResStr(9911106)
    ShowNotice(content)
    log(bWriteLog and "LobbySystem.HandleMatchErrorCode MatchSystem.QueryPlayerState 2")
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.QueryPlayerState()
  elseif msg == "overload" then
    local content = LocUtil.GetLocalizeResStr(9911107)
    ShowNotice(content)
  elseif msg == "invalid_team_size" then
    local content = LocUtil.GetLocalizeResStr(9911108)
    ShowNotice(content)
  elseif msg == "member-offline" then
    local content = LocUtil.GetLocalizeResStr(9911110)
    ShowNotice(content)
  elseif msg == "member-in-game" then
    local content = ""
    local home_macros = require("client.slua.logic.home.home_macros")
    if res_params.member_sub_mode == home_macros.Home_SubMode.Visit then
      content = LocUtil.GetLocalizeResStr(64788)
    else
      content = LocUtil.GetLocalizeResStr(9911111)
    end
    ShowNotice(content)
  elseif msg == "droiyan_mode_is_close" then
    local content = LocUtil.GetLocalizeResStr(9911113)
    ShowNotice(content)
  elseif msg == "match_player_too_little" then
    local content = LocUtil.GetLocalizeResStr(9911114)
    ShowNotice(content)
    log(bWriteLog and "----server cancel match----")
    LobbySystem.ResetMatchInfo()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.MatchCancel()
  elseif msg == "credit_is_too_low" then
    local content = LocUtil.LocalizeResFormat(62190, DataMgr.roleData.credit)
    CommonMsgBoxMgr.Show(1, str_prompt, content)
  elseif msg == "member-credit-is-too-low" then
    local content = ""
    if res_params and res_params.member_credit_uid and res_params.member_credit_uid ~= tonumber(DataMgr.roleData.uid) and TeamUpNewSystem.GetTeamNum() > 1 then
      local memberInfo = TeamUpNewSystem.GetMemberInfo(res_params.member_credit_uid)
      local memberCredit = memberInfo and memberInfo.credit or 0
      local profileData = logic_profile:GetLocalProfile(res_params.member_credit_uid)
      if profileData then
        content = LocUtil.LocalizeResFormat(62191, profileData.nickName, memberCredit)
      else
        content = LocUtil.LocalizeResFormat(62191, LocUtil.GetLocalizeResStr(6317), memberCredit)
      end
    else
      content = LocUtil.LocalizeResFormat(62190, DataMgr.roleData.credit)
    end
    CommonMsgBoxMgr.Show(1, str_prompt, content)
  elseif msg == "peakgame_segment_limit" then
    local content = ""
    local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
    local minPeakSeg = LogicPeakGame:GetPeakGameMinSeg() or 701
    local minPeakSegCfg = FuncUtil.GetRankTableData(minPeakSeg)
    local segName = minPeakSegCfg and minPeakSegCfg.Name or ""
    if res_params and res_params.peakgame_limit_uid and res_params.peakgame_limit_uid ~= tonumber(DataMgr.roleData.uid) and TeamUpNewSystem.GetTeamNum() > 1 then
      local profileData = logic_profile:GetLocalProfile(res_params.peakgame_limit_uid)
      if profileData then
        content = LocUtil.LocalizeResFormat(68350, profileData.nickName, segName)
      else
        content = LocUtil.LocalizeResFormat(68350, LocUtil.GetLocalizeResStr(6317), segName)
      end
    else
      content = LocUtil.LocalizeResFormat(68349, segName)
    end
    ShowNotice(content)
  elseif msg == "entering_other_socialland" then
    local content = LocUtil.GetLocalizeResStr(100110116)
    ShowNotice(content)
  elseif type(msg) == "number" then
    if msg == 100150049 then
      local profile = logic_profile:GetLocalProfile(reason)
      local name = ""
      if profile then
        name = profile.nickName
      end
      ShowNotice(LocUtil.LocalizeResFormat(200000094, name))
    elseif msg == 100150060 then
      local GoSingleBindActivity = function()
        local clickOKCallback = function()
          GlobalData.JumpGameUrl("game://?module=1001300")
        end
        local msgTitle = LocUtil.GetLocalizeResStr(5077)
        local msgContent = LocUtil.GetLocalizeResStr(67682)
        local cancelTip = LocUtil.GetLocalizeResStr(7510)
        local goBindTip = LocUtil.GetLocalizeResStr(67683)
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(2, msgTitle, msgContent, clickOKCallback, nil, goBindTip, cancelTip)
      end
      local logic_singlebind = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_singlebind)
      if TeamUpNewSystem.IsInTeam() and TeamUpNewSystem.IsTeamLeader(DataMgr.roleData.uid) and not logic_singlebind:IsSingleBindVK() then
        log(bWriteLog and "LobbySystem.HandleMatchErrorCode Is Team Leader and self isn't vk single bind!")
        local profile = logic_profile:GetLocalProfile(reason)
        local name = ""
        if profile then
          name = profile.nickName
        end
        ShowNotice(LocUtil.LocalizeResFormat(67684, name))
      elseif GameStatus.IsInLobbyOrMainCity() then
        GoSingleBindActivity()
      else
        ShowNotice(67685)
      end
    elseif msg == 505051 then
      local profile = logic_profile:GetLocalProfile(res_params.peakgame_limit_uid)
      local name = ""
      if profile then
        name = profile.nickName
      end
      ShowNotice(LocUtil.LocalizeResFormat(68446, name))
    elseif msg == 100150063 then
      local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
      logic_account_protect_setting:ShowModeLimitPopup(reason)
    else
      local content = LocUtil.GetLocalizeResStr(msg)
      ShowNotice(content)
    end
  elseif msg == "level_limit" then
    local content = LocUtil.GetLocalizeResStr(5000146)
    ShowNotice(content)
  elseif msg == "match_socialland_frequently" then
    local content = LocUtil.GetLocalizeResStr(100110117)
    ShowNotice(content)
  elseif msg == "match_main_city_frequently" then
    local content = LocUtil.GetLocalizeResStr(656043)
    ShowNotice(content)
  elseif msg == "player_matching_socialland" then
    local content = LocUtil.GetLocalizeResStr(100110115)
    ShowNotice(content)
  elseif msg == "has_not_open_member" then
    local content = LocUtil.GetLocalizeResStr(520028)
    ShowNotice(content)
  elseif msg == "single_training_match_fast" then
    local content = LocUtil.GetLocalizeResStr(35151)
    ShowNotice(content)
  elseif msg == "member-no-map" then
    local content = LocUtil.GetLocalizeResStr(520028)
    ShowNotice(content)
  elseif msg == "metro_match_error" then
    local err_code = waitTime
    LobbySystem.HandleMetroMathErrorCode(err_code, ext_info)
  elseif msg == "metro_members_invalid" and reason then
    local bShow = false
    local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
    for k, v in pairs(reason) do
      log(bWriteLog and "metro_members_invalid reason key:" .. tostring(k) .. " value:" .. tostring(v))
      if v == 100251077 then
        bShow = true
        local nickName = TeamUpNewSystem.GetMemberName(k)
        if nickName and nickName ~= "" then
        else
          nickName = tostring(k)
        end
        local content = LocUtil.LocalizeResFormat(66683, nickName, xmission_wardrobe_data.GetCurUndercoverCapacity())
        ShowNotice(content)
      elseif v == 100251081 then
        bShow = true
      else
        local str = ""
        local content = LocUtil.GetLocalizeResStr(v)
        if content and content ~= "" then
          str = content
        end
        local nickName = TeamUpNewSystem.GetMemberName(k)
        if nickName and nickName ~= "" then
          str = nickName .. str
        else
          str = tostring(k) .. str
        end
        if str and str ~= "" then
          bShow = true
          ShowNotice(str)
        end
      end
    end
    if not bShow then
      ShowNotice("unknow error code :" .. msg)
    end
  elseif msg == "err_anniv_3_in_mini_game" then
    local content = LocUtil.GetLocalizeResStr(102100007)
    ShowNotice(content)
  elseif msg == "minor_limit" then
    LobbySystem.ResetMatchInfo()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.MatchCancel()
  elseif msg == "pre_team_limit" then
    if LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) and TeamUpNewSystem.IsTeamLeader(DataMgr.roleData.uid) and res_params and res_params.uid_list and res_params.leader_seg then
      UIManager.ShowUI(UIManager.UI_Config.Segment_TeamRestriction_UIBP, res_params.leader_seg, res_params.uid_list, res_params.zone_id)
    end
  elseif msg == "server_protected" then
    ShowNotice(48494)
    if tonumber(surplustime) and tonumber(surplustime) == 26000 then
      local logic_main_city_heart = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_heart)
      logic_main_city_heart:SetEanbleHeartCheck(false)
    end
  elseif msg == "device_cost_limit" then
    ShowNotice(48458)
  elseif msg == "ugc-no-valid-mod" then
    LobbySystem.ResetMatchInfo()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.MatchCancel()
    local title = LocUtil.GetLocalizeResStr(8600135)
    local text = LocUtil.GetLocalizeResStr(48975)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, text, function()
      local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
      UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {
        menuList = tostring(mode_selection_macro.Enum_TabID.UGC)
      })
    end)
  elseif msg == "member_mil_ban_t_mode" then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.GetLocalizeResStr(101001)
    CommonMsgBoxMgr.Show(3, title, LocUtil.LocalizeResFormat(10361, reason))
  elseif msg == "player_matching_cwow" then
    ShowNotice(511095)
  elseif msg == "player_matching_main_city" then
    ShowNotice(656196)
  elseif msg == "main_city_match_player_too_little" then
    ShowNotice(656196)
  elseif msg == "speech_ban" then
    ShowNotice(75229)
  elseif msg == "mc_limit" then
    ShowNotice(101110001)
  elseif msg == "not-leader" then
    ShowNotice(525110)
  elseif msg == "team_leader_no_map" then
    ShowNotice(78438)
  elseif msg == "free_inout_target_game_not_found" then
    ShowNotice(101310027)
    LobbySystem.ResetMatchInfo()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.MatchCancel()
  else
    ShowNotice("unknow error code :" .. msg)
  end
end
function LobbySystem.HandleMetroMathErrorCode(err_code, ext_info)
  if not err_code then
    return
  end
  if ext_info and ext_info.is_soft_punish then
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
      BasicDataTLogReport:ReportImmediate(TLogEventDefine.Ban_Appeal_Observation_Click)
    end
    local title = LocUtil.GetLocalizeResStr(101001)
    local stAppeal = LocUtil.GetLocalizeResStr(4004)
    log_tree("HandleMetroMathErrorCode ShowErrorPopUpWindows ext_info = ", ext_info)
    stAppeal = LocUtil.GetLocalizeResStr(8500233)
    local TableUtil = require("common.table_util")
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local title = LocUtil.GetLocalizeResStr(101001)
    local userName = DataMgr.roleData.nickName or ""
    local userUid = DataMgr.roleData.uid or ""
    local remainTime = tonumber(TableUtil.GetTableValue(LobbySystem.roleData, "mil_info", "expire_time") or 0) - curTime
    local banTipStr = LocUtil.LocalizeResFormatByStr(ext_info.reason, userName, userUid, timeStr)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(3, title, banTipStr, clickReduceCallback, nil, stAppeal)
    return
  end
  if err_code == 100251064 then
    local LogicTxMissionSeason = require("client.slua.logic.TxMission.season.logic_xmission_season")
    local TimeUtil = require("client.common.time_util")
    local MatchStartTime = LogicTxMissionSeason.GetMatchTime()
    local matchtime = TimeUtil.TimeStringToUnixstamp(MatchStartTime)
    local nowTime = TimeUtil.GetServerTimeInSec()
    local nTotalTime = matchtime - nowTime
    local lesstime = TimeUtil.FormatCountDownTime_D_or_HMS(nTotalTime, 1)
    ShowNotice(LocUtil.LocalizeResFormat(27754, lesstime))
  elseif err_code == 100251077 then
    local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
    if not xmission_wardrobe_data.CheckUndercoverCapacity(nil, true) then
      return
    end
  elseif err_code == 100251051 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local TableUtil = require("common.table_util")
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local title = LocUtil.GetLocalizeResStr(101001)
    local userName = DataMgr.roleData.nickName or ""
    local userUid = DataMgr.roleData.uid or ""
    local remainTime = tonumber(TableUtil.GetTableValue(LobbySystem.roleData, "mil_info", "expire_time") or 0) - curTime
    local banTipStr = LocUtil.LocalizeResFormat(100251051, userName, userUid, TimeUtil.FormatCountDownTime_DHMS(remainTime))
    CommonMsgBoxMgr.Show(3, title, banTipStr)
  elseif err_code == 100251130 then
    log_tree(bWriteLog and "LobbySystem.HandleMetroMathErrorCode ext_info", ext_info)
    local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
    LogicTxMissionMatch.ShowNewbieRestrictionUIByCode(ext_info.restriction_code)
  else
    local content = LocUtil.GetLocalizeResStr(err_code)
    ShowNotice(content)
  end
  if err_code == 100250012 or err_code == 100250013 or err_code == 100250014 then
    log(bWriteLog and "LobbySystem.HandleMatchErrorCode MatchSystem.QueryPlayerState 3")
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.QueryPlayerState()
  end
end
function LobbySystem.query_gm_request()
  if Client.IsReleaseVersion(NetInterface) and globalConfig.IsDirectConnect() and not GlobalData.IsIOSCheck() then
    return
  end
  log(bWriteLog and "query_gm_request")
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_query_gm_request()
end
function LobbySystem.change_status_req()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local curStatus = TeamUpNewSystem.GetMyStatus()
  local reqStatus = curStatus
  if curStatus == LobbySystem.statusReady then
    reqStatus = LobbySystem.statusUnready
  end
  if curStatus == LobbySystem.statusUnready then
    reqStatus = LobbySystem.statusReady
  end
  log(bWriteLog and "request switch my status to : " .. reqStatus)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  TeamupHandler.send_team_change_member_status_request(reqStatus, DeviceOSInfo.InfoList)
end
function LobbySystem.change_status_rsp(err_code, _)
  log(bWriteLog and "[mxiliu]LobbySystem:change_status_rsp, err_code=" .. tostring(err_code))
  if err_code ~= 0 then
    if err_code == 100150060 then
      local clickOKCallback = function()
        GlobalData.JumpGameUrl("game://?module=1001300")
      end
      local msgTitle = LocUtil.GetLocalizeResStr(5077)
      local msgContent = LocUtil.GetLocalizeResStr(67682)
      local cancelTip = LocUtil.GetLocalizeResStr(7510)
      local goBindTip = LocUtil.GetLocalizeResStr(67683)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, msgTitle, msgContent, clickOKCallback, nil, goBindTip, cancelTip)
    elseif err_code == 505046 then
      UIManager.ShowUI(UIManager.UI_Config.crew_safety_detection_peak)
    else
      ShowNotice(LocUtil.LocalizeResFormat(tostring(err_code)))
    end
  end
end
function LobbySystem.on_match_cancel_req()
  log(bWriteLog and "--cancel match --")
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_on_match_cancel_req()
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  TournamentsManager.SetCancelState()
  local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
  logic_main_city_achievement_task_report.ClickStartGameInMainCity(false)
  local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
  if logic_mode_asymmertric:GetHasSelectedCamp() then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local MatchSystem = require("client.slua.logic.match.logic_match")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.AsymMode_Cancel_Match, 0, tostring(MatchSystem.nMatchingTime))
  end
end
function LobbySystem.on_match_cancel_rsp(msg, userid, krjp_rematch)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  log(bWriteLog and string.format("-----receive player cancel match msg = %s, userid = %s, krjp_rematch = %s", msg, userid, krjp_rematch))
  if msg == NetErrorCode_NONE or msg == "failed" then
    if msg == "failed" then
      local msgContent = LocUtil.GetLocalizeResStr(8019)
      log(bWriteLog and msgContent)
      ShowNotice(msgContent)
    end
    LobbySystem.ResetMatchInfo()
    MatchSystem.ResetData()
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local selfUID = TeamUpNewSystem.GetSelfUID()
    if not TeamUpNewSystem.IsTeamLeader() and userid == selfUID then
      local menberInfo = TeamUpNewSystem.GetMemberInfo(userid)
      if menberInfo and menberInfo.status == LobbySystem.statusUnready then
        MatchSystem.MatchCancel()
      end
      local TeamupHandler = require("client.network.Protocol.TeamupHandler")
      local DeviceOSInfo = require("client.logic.data.data_device_os")
      DeviceOSInfo.getDeviceOSInfo()
      TeamupHandler.send_team_change_member_status_request(LobbySystem.statusUnready, DeviceOSInfo.InfoList)
    else
      if UIManager.IsUIShow(UIManager.UI_Config.tournament_teamup) or UIManager.IsUIShow(UIManager.UI_Config.championship_teamup) then
        EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_CANCEL_MATCH_RES_OK)
      else
        MatchSystem.MatchCancel()
      end
      local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
      logic_long_time_match:TrySwitchLTMatchMode()
      local logic_multi_select_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_multi_select_match)
      logic_multi_select_match:TrySwitchMSMatch()
    end
  end
  if msg == "ok" and krjp_rematch then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      log(bWriteLog and "-----receive player cancel match xmission branch")
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_metro_match_req()
    else
      LobbySystem.on_start_match_req()
    end
    MatchSystem.bIsSwitchServerShowed = true
    MatchSystem.bKrJpRematch = true
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_CROSS_SUCCESS)
  end
  if msg == "not_found" then
    local msgContent = LocUtil.GetLocalizeResStr(111016)
    log(bWriteLog and msgContent)
    ShowNotice(msgContent)
    log(bWriteLog and "LobbySystem.HandleMatchErrorCode MatchSystem.QueryPlayerState 4")
    MatchSystem.QueryPlayerState()
  end
  if msg == "can-not-subjoin" then
    local msgContent = LocUtil.GetLocalizeResStr(6380)
    log(bWriteLog and msgContent)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, "", msgContent, nil, nil)
    ShowNotice(msgContent)
  end
  if msg == "socialland_limit" then
    LobbySystem.ShowTipsAndReturnToLobby(100110110)
  end
  if msg == "loading_cant_matching" then
    LobbySystem.ShowTipsAndReturnToLobby(65280)
  end
  if msg == "loading_enter_new_match" then
    LobbySystem.ShowTipsAndReturnToLobby(880060077)
  end
  if MatchSystem.bKrJpRematch and not krjp_rematch then
    MatchSystem.bKrJpRematch = false
    ShowNotice(42938)
  end
  EventSystem:postEvent(EVNETID_MATCH_NEW_GUIDE, EVENTID_MATCH_NEWBIE_HIDE_FORCEGUIDE)
end
function LobbySystem.ShowTipsAndReturnToLobby(textId)
  local msgContent = LocUtil.GetLocalizeResStr(textId)
  log(bWriteLog and msgContent)
  ShowNotice(msgContent)
  LobbySystem.SetWaitingBattleFlag(false)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.RefreshLoadPercent(1)
  Client.ReturnToLobby(GameFrontendHUD)
end
function LobbySystem.on_reconnect_sync_matchInfo(match_info)
  if match_info then
    log(bWriteLog and "----receive reconnect match info ----")
    LobbySystem.isInMatch = true
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.nSelectMatchID = match_info.match_mode
    MatchModeMgrSystem.bAutoMatch = match_info.fill and match_info == 1 or false
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.nMatchBeginTime = match_info.begin_time
    MatchSystem.CheckWaitingState(match_info.predictive_time, match_info.match_langs, match_info.line_pos, match_info.line_speed)
    MatchSystem.ResetWhenReconnected()
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_SYNC_MATCH_INFO)
  else
    log(bWriteLog and "----player does not have match status----")
    LobbySystem.ResetMatchInfo()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.MatchCancel()
  end
end
function LobbySystem.SetFeedBackFlag(Flag)
  log(bWriteLog and "SetFeedBackFlag " .. tostring(Flag))
  if Flag ~= nil then
    BP_ShowFeedBack = Flag
  else
    BP_ShowFeedBack = false
  end
end
function LobbySystem.ResetMatchInfo()
  log(bWriteLog and "LobbySystem.ResetMatchInfo")
  LobbySystem.isInMatch = false
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.nMatchBeginTime = 0
end
function LobbySystem.ReturnToLobby()
  log(bWriteLog and "LobbySystem.ReturnToLobby")
  UPassgameEndShowFinishTasksList = {}
  log(bWriteLog and "LobbySystem.ReturnToLobby - deanytjin test should show mail 9")
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  if GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "LobbySystem.ReturnToLobby already in lobby or maincity")
    return
  end
  Client.ReturnToLobby(GameFrontendHUD)
end
function LobbySystem.on_match_success(msg, team_info, antsvoice_url, deathmatch_teams, game_team_size, gameid, team_id, camp_id, sub_mode, feedback_flag, ugc_mod)
  log(bWriteLog and "socialperry LobbySystem.on_match_success")
  log_tree("LobbySystem.on_match_success team info = ", team_info)
  log(bWriteLog and "on_match_success..submode id= " .. tostring(sub_mode) .. " gameid= " .. tostring(gameid))
  log(bWriteLog and "receive match success response msg = " .. msg)
  local logic_multi_select_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_multi_select_match)
  logic_multi_select_match:RemoveGuideTimer()
  if msg == NetErrorCode_NONE then
    local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
    RecommendHandler.OnMatchSuccess(sub_mode)
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_PRE_MATCH_SUCCESS, sub_mode)
    LobbySystem.isWaitToEnterGame = true
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.SetInGameModeID(sub_mode)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem and TeamUpNewSystem.SetTempMatchTeamData then
      TeamUpNewSystem.SetTempMatchTeamData(team_info)
    end
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    LogicUGC:SetUGCGameMod(sub_mode)
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    LogicUGCMatch:UpdateLastMatchTime()
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    LogicUGCMulti:SetMatchMod(ugc_mod)
    log(bWriteLog and "on_match_success.." .. tostring(MatchModeMgrSystem.nSelectMatchID))
    Client.TPerforPlatDataReport(GameFrontendHUD, 400, tostring(MatchModeMgrSystem.nSelectMatchID))
    local param = {
      tostring(MatchModeMgrSystem.nSelectMatchID)
    }
    NetUtil.GEMReportSubEvent("EnterBattle", param)
    LobbySystem.ResetMatchInfo()
    LobbySystem.ShowMatchSuccess(deathmatch_teams, game_team_size, sub_mode)
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS)
    log(bWriteLog and "LobbySystem.on_match_success new enter room rule")
    local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
    logic_enter_game:SetAntsVoiceInfo({team_id = team_id, camp_id = camp_id})
    local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
    logic_chat_voice_doctor:AddJoinTeamRoomStep(700)
    MatchModeMgrSystem.ClearData()
    local UIUtil = require("client.common.ui_util")
    if UIUtil.GetGameFrontendHUD() ~= nil then
      UIUtil.GetGameFrontendHUD():SetClientEnterBattleStage("LobbyMsg_MatchSuccess")
      if gameid ~= nil then
        NetUtil.SetEnterBattleGameID(tostring(gameid))
      end
    end
    local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
    logic_season_guide_manager:AddMatchCount(1)
    local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
    newbieGuideManager.AddMatchCount(sub_mode)
    local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
    logic_long_time_match:ReportLTMatchInfo()
    local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
    logic_return_activity:ReportReturnGuideMatch()
    logic_multi_select_match:OnMatchSuccess()
    return
  end
  if msg == "match_failed" then
    local content = LocUtil.GetLocalizeResStr(9911101)
    ShowNotice(content)
    LobbySystem.ResetMatchInfo()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.MatchCancel()
  end
  if msg == "load-game-fail!" then
    if sub_mode and sub_mode == 26000 and GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "LobbySystem.on_match_success IsInLobbyOrMainCity load-game-fail!")
    else
      local title = LocUtil.GetLocalizeResStr(101001)
      local content = LocUtil.GetLocalizeResStr(9911109)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, content, LobbySystem.onLoadServerFailed, nil)
    end
  end
  if msg == "version-not-support" then
    if sub_mode and sub_mode == 26000 and GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "LobbySystem.on_match_success IsInLobbyOrMainCity version-not-support")
      local content = LocUtil.GetLocalizeResStr(9911112)
      ShowNotice(content)
    else
      local title = LocUtil.GetLocalizeResStr(101001)
      local content = LocUtil.GetLocalizeResStr(9911112)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, content, LobbySystem.onLoadServerFailed, nil)
    end
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:SetIsReturnGuideMatch(false)
  return
end
function LobbySystem.onLoadServerFailed()
  log(bWriteLog and "load server failed")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.RefreshLoadPercent(1)
  Client.ReturnToLobby(GameFrontendHUD)
end
function LobbySystem.ShowMatchSuccess(deathmatch_teams, game_team_size, sub_mode)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if not MatchModeMgrSystem.IsSocialIslandMode(true) then
    MatchSystem.MatchSuccess()
  else
    MatchSystem.MatchSocialIslandSuccess()
  end
  LobbySystem.CloseOtherMenu()
  if not GameStatus.IsInMainCity() then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.HidePanel()
  end
  if UIManager.GetUI(UIManager.UI_Config.Assembly_Main_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Assembly_Main_UIBP)
  end
  if UIManager.GetUI(UIManager.UI_Config.lobby_report_bug) then
    UIManager.CloseUI(UIManager.UI_Config.lobby_report_bug)
  end
  if LobbySystem.CheckUseNewGuide() then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    local uiConfig = LogicNewbie.GetWelcomeUIConfig()
    if UIManager.GetUI(uiConfig) then
      UIManager.CloseUI(uiConfig)
    end
  end
  log(bWriteLog and "LobbySystem.ShowMatchSuccess MatchModeMgrSystem.nSelectMatchID:" .. tostring(MatchModeMgrSystem.nSelectMatchID))
  LobbySystem.is_DeathMatchMode = false
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local isNormalTeamMod = MatchModeMgrSystem.nSelectMatchID == 703 or MatchModeMgrSystem.nSelectMatchID == 713 or MatchModeMgrSystem.nSelectMatchID == 723 or MatchModeMgrSystem.nSelectMatchID == 733 or MatchModeMgrSystem.nSelectMatchID == 603 or MatchModeMgrSystem.nSelectMatchID == 1703 or MatchModeMgrSystem.nSelectMatchID == 1713 or MatchModeMgrSystem.nSelectMatchID == 2713 or MatchModeMgrSystem.nSelectMatchID == 2703 or MatchModeMgrSystem.nSelectMatchID == 23713
  local isXmissionTeamMod = LogicTxMissionMain.IsInXMission() and LogicTxMissionMatch.metro_scene_data and LogicTxMissionMatch.metro_scene_data.match_params and LogicTxMissionMatch.metro_scene_data.match_params.team_type == 23713
  if (isNormalTeamMod or isXmissionTeamMod) and deathmatch_teams then
    LobbySystem.is_DeathMatchMode = true
    log_tree("LoadingDeathMatchUI -- deathmatch_teams: ", deathmatch_teams)
    log_tree("LoadingDeathMatchUI -- game_team_size: ", game_team_size)
    log(bWriteLog and "LoadingDeathMatchUI -- ReadyToInit")
    local TeamCompLoading = require("client.slua.logic.loading.logic_teamcomp_loading")
    TeamCompLoading.ShowLoading(deathmatch_teams, game_team_size, sub_mode)
  else
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local Lobby_Main_City = require("client.slua.logic.lobby.MainCity.Lobby_Main_City")
    if not Lobby_Main_City.IsMainCitySubMode(sub_mode) then
      if logic_mode_selection:PlayAnimOnMatchSuccess() then
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimerOnce(0.5, function()
          LoadingSystem.ShowLoading(false, nil, sub_mode)
        end)
      else
        LoadingSystem.ShowLoading(false, nil, sub_mode)
      end
    end
  end
  LobbySystem.SetWaitingBattleFlag(true)
  if NetUtil then
    NetUtil.StartCheckEnterBattle(sub_mode)
  end
end
function LobbySystem.on_remind_window_pop(title, content)
  log(bWriteLog and "on_remind_window_pop")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, content)
end
function LobbySystem.on_fetch_nation_switch_res(info)
end
function LobbySystem.on_fetch_label_switch_res(info)
  LobbySystem.LobbyMenuOpenStatus = info
  Client.OnCombatHitFeedback(GameFrontendHUD, info[BP_ENUM_SURVIVE_COMBAT_HIT_FEEDBACK].is_open == 1)
  local ChatUtils = require("client.slua.logic.lobby_chat.ChatUtils")
  if not ChatUtils.IsChatOpen() then
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    logic_chat_main.canOpenChatWnd = false
  end
  local bObjectPoolSwitch = LobbySystem.CheckOpen(BP_ENUM_OBJECTPOOL_SERVER_SWITCH)
  Client.ObjectPoolServerSwitch(bObjectPoolSwitch)
  if LobbySystem.CheckOpen(80017) then
    log(bWriteLog and "Client.GMH5Enable(true)")
    Client.GMH5Enable(true)
  else
    log(bWriteLog and "Client.GMH5Enable(false)")
    Client.GMH5Enable(false)
  end
  LobbySystem.ReportXIDToTAPM()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH)
  local wonderful_play_lua_interface = require("client.slua.logic.replay.wonderful_play_lua_interface")
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_SWITCH)
  wonderful_play_lua_interface.SetGWonderfulPlaybackSwitch(bSwitch)
  local vulkanSwitch = LobbySystem.CheckOpen(BP_ENUM_VULKAN_SWITCH)
  local isVulkanEnable = Client.GetUserVulkanSetting()
  log(bWriteLog and "LobbySystem.on_fetch_label_switch_res vulkanSwitch: " .. tostring(vulkanSwitch))
  log(bWriteLog and "LobbySystem.on_fetch_label_switch_res isVulkanEnable: " .. tostring(isVulkanEnable))
  if not vulkanSwitch and isVulkanEnable then
    Client.SetUserVulkanSetting(false)
  end
end
function LobbySystem.ReportXIDToTAPM()
  local xidSwitch = LobbySystem.CheckOpen(BP_ENUM_TAPM_XID)
  if xidSwitch then
    local mapData = {}
    mapData.openid = tostring(DataMgr.roleData.openID)
    mapData.roleid = tostring(DataMgr.roleData.uid)
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    mapData.areaid = tostring(ZoneSystem.nChooseZoneID)
    mapData.appid = Client.GetITopGameId()
    local loginChannel = Client.GetLoginChannel(NetInterface)
    local SettingSystem = require("client.logic.setting.logic_setting")
    mapData.platid = SettingSystem.GetNameByHDmpveChannel(loginChannel)
    log(bWriteLog and "PostGameStatusToTGPASMap openid:" .. mapData.openid)
    log(bWriteLog and "PostGameStatusToTGPASMap roleid:" .. mapData.roleid)
    log(bWriteLog and "PostGameStatusToTGPASMap areaid:" .. mapData.areaid)
    log(bWriteLog and "PostGameStatusToTGPASMap appid:" .. mapData.appid)
    log(bWriteLog and "PostGameStatusToTGPASMap platid:" .. mapData.platid)
    Client.PostGameStatusToTMFPSMap(GameFrontendHUD, "DeviceBind", mapData)
  else
    log(bWriteLog and "PostGameStatusToTGPASMap xidSwitch is false")
  end
end
function LobbySystem.GetLocalExplicitOpenConfig(menuId)
  local config
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    config = CDataTable.GetTableData("ExplicitMenuSwitchTable_BuleHole", menuId)
  elseif GlobalData.IsIOSCheck() then
    config = CDataTable.GetTableData("ExplicitMenuSwitchTable_IOS", menuId)
  else
    config = CDataTable.GetTableData("ExplicitMenuSwitchTable", menuId)
  end
  config = config or CDataTable.GetTableData("ExplicitMenuSwitchTable", menuId)
  return config
end
function LobbySystem.CheckLocalDefaultOpen(menuId)
  local strRegion = Client.GetPublishRegion()
  local switchConfig
  if not menuId then
    log_error("menuId is nil")
    return false
  end
  local isOpen
  switchConfig = LobbySystem.GetLocalExplicitOpenConfig(menuId)
  if switchConfig and switchConfig.Open then
    isOpen = switchConfig.Open == 1
    if isOpen == false then
      print(bWriteLog and "LobbySystem.CheckLocalDefaultOpen 1 not open. menuId:" .. menuId)
    end
    return isOpen
  end
  if LobbySystem.E_RegionTable[strRegion] then
    local switchTableName = LobbySystem.E_RegionTable[strRegion]
    switchConfig = CDataTable.GetTableData(switchTableName, menuId)
  else
    switchConfig = CDataTable.GetTableData("GlobalMenuSwitchTable", menuId)
  end
  if not switchConfig then
    if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
      switchConfig = CDataTable.GetTableData("GlobalMenuSwitchTable", menuId)
      if not switchConfig then
        log_warning(bWriteLog and string.format("[YY]menuId=%d is not configured in local region=%s and GLOBAL", menuId, strRegion))
        return true
      end
      isOpen = switchConfig.Open == 1
      if isOpen == false then
        print(bWriteLog and "LobbySystem.CheckLocalDefaultOpen 2 not open. menuId:" .. menuId)
      end
      return isOpen
    end
    log_warning(bWriteLog and string.format("[YY]menuId=%d is not configured in local region=GLOBAL", menuId))
    return true
  end
  if LobbySystem.LobbyMenuOpenStatus and next(LobbySystem.LobbyMenuOpenStatus) then
    log(bWriteLog and string.format("[YY]menuId=%d is configured in local but not from server", menuId))
  end
  isOpen = switchConfig.Open == 1
  if isOpen == false then
    print(bWriteLog and "LobbySystem.CheckLocalDefaultOpen 3 not open. menuId:" .. menuId)
  end
  return isOpen
end
function LobbySystem.CheckOpen(menuId)
  local isOpen
  local switchInfo = LobbySystem.LobbyMenuOpenStatus_New[menuId]
  if switchInfo and switchInfo.is_open then
    isOpen = switchInfo.is_open == 1
    log(bWriteLog and string.format("LobbySystem.CheckOpen. menuId=%s, isOpen=%s", tostring(menuId), tostring(isOpen)))
    return isOpen
  end
  switchInfo = LobbySystem.LobbyMenuOpenStatus[menuId]
  if switchInfo == nil then
    isOpen = LobbySystem.CheckLocalDefaultOpen(menuId)
    log(bWriteLog and string.format("LobbySystem.CheckOpen. menuId=%s, isOpen=%s", tostring(menuId), tostring(isOpen)))
    return isOpen
  end
  isOpen = switchInfo.is_open == 1
  log(bWriteLog and string.format("LobbySystem.CheckOpen. menuId=%s, isOpen=%s", tostring(menuId), tostring(isOpen)))
  return isOpen
end
function LobbySystem.IsNeedShowLogError(menuId)
  if LobbySystem.LobbyMenuOpenStatus == nil then
    return true
  end
  if LobbySystem.LobbyMenuOpenStatus[menuId] == nil then
    return true
  end
  return false
end
function LobbySystem.CheckLobbyMenuOpen(menuId, isShowTip)
  if isShowTip == nil then
    isShowTip = true
  end
  if type(menuId) == "string" then
    log_error(bWriteLog and "CheckLobbyMenuOpen menuId must be a number value! menuId=" .. tostring(menuId))
    menuId = tonumber(menuId) or 0
  end
  local switchInfo = LobbySystem.LobbyMenuOpenStatus_New[menuId]
  if switchInfo and switchInfo.is_open then
    return tonumber(switchInfo.is_open) == 1
  end
  switchInfo = LobbySystem.LobbyMenuOpenStatus[menuId]
  if switchInfo == nil then
    return LobbySystem.CheckLocalDefaultOpen(menuId)
  end
  if tonumber(switchInfo.is_open) == 0 then
    if isShowTip then
      local title = LocUtil.GetLocalizeResStr(101001)
      local text = LocUtil.GetLocalizeResStr(120001)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, text)
    end
    return false
  else
    return true
  end
end
function LobbySystem.CheckLeagueGameSubMode()
  local curStatus = GameStatus.GetGameStatus()
  local UILobbyMatchList = require("client.logic.lobby.logic_lobby_matchlist")
  if GameStatus.IsInLobbyOrMainCity() and DataMgr.allstar_id and DataMgr.allstar_id > 0 then
    local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
    NewFaceSlapSystem:BlockSlap()
    local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
    ESportAllStarSystem.ShowUI()
    NewFaceSlapSystem:ReleaseBlockSlap()
  elseif GameStatus.IsInLobbyOrMainCity() and DataMgr.tournament_id and 0 < DataMgr.tournament_id then
    if DataMgr.match_union_info then
      UILobbyMatchList.EnterQualifying()
    else
      local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
      logic_tournament_main:ShowMainUI()
      local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
      TournamentsManager.EnterTournamentTeamup(DataMgr.tournament_id)
    end
  elseif DataMgr.is_pug_result then
    UILobbyMatchList.EnterChampionship()
  end
  DataMgr.allstar_id = nil
  DataMgr.tournament_id = nil
  DataMgr.is_pug_result = nil
end
function LobbySystem.LobbyRedPointUpdate(menuId, show)
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  logic_lobby_reddot.ProcModuleReddot(menuId, show)
  if next(BP_LobbyHighestBannerData) ~= nil and BP_LobbyHighestBannerData.JumpUrl then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(BP_LobbyHighestBannerData.JumpUrl)
    local actid = params.actid
    local moduleid = params.module
    if moduleid and moduleid == tostring(menuId) or actid and actid == tostring(menuId) then
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_REDPOINT_CHANGE, show)
    end
  end
end
function LobbySystem.UpdateSettingRedPoint()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "LobbySystem.UpdateSettingRedPoint")
  if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(10006) then
    return
  end
  local logic_setting = require("client.logic.setting.logic_setting")
  local state = logic_setting.NeedShowSettingRed()
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  log(bWriteLog and "  : state" .. tostring(state))
  logic_lobby_reddot.ProcModuleReddot(BP_ENUM_MODULE_SETTING, state)
end
function LobbySystem.CloseOtherMenu()
  if UIManager.GetUI(UIManager.UI_Config.Assembly_Main_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Assembly_Main_UIBP)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.ingame_process_webview) then
    UIManager.CloseUI(UIManager.UI_Config.ingame_process_webview)
  end
end
local DISABLE_PLAY_VIDEO_DEVICES_LIST = {
  "K88",
  "ASUS_Z00LD",
  "SM-A7100",
  "MI PAD",
  "MotoG3-TE",
  "SM-A320F",
  "moto z3"
}
function LobbySystem.CheckVideoOpenStatus()
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  log(bWriteLog and "current device: " .. tostring(DeviceOSInfo.InfoList.DeviceName))
  for i = 1, #DISABLE_PLAY_VIDEO_DEVICES_LIST do
    if DISABLE_PLAY_VIDEO_DEVICES_LIST[i] == DeviceOSInfo.InfoList.DeviceName then
      log(bWriteLog and "current device doesn't support video play")
      return false
    end
  end
  return true
end
function LobbySystem.ExposureReportInLobby(eventType)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  if eventType == 0 and LobbySystem.canReportOneExposure.banner == true then
    LobbySystem.canReportOneExposure.banner = false
    for _, v in pairs(LobbySystem.activityBtnDisplayList) do
      gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_LobbyBannerJump, gem_report_utils.GetReportParam(v.ID, v.JumpUrl, false))
      local TLogReasonStrTable = {
        event_name = gem_report_utils.SubEventName_LobbyBannerJump,
        banner_id = v.ID,
        language = Client.GetCurrentLanguage(),
        module = gem_report_utils.GetReportModule(v.JumpUrl),
        click = false
      }
      if string.find(v.JumpUrl, "activityid=") then
        local activityId = string.match(v.JumpUrl, "activityid=(%d+)")
        TLogReasonStrTable.activityid = tonumber(activityId)
      end
      local TLogReasonStr = json.encode(TLogReasonStrTable)
      ClientSendTLogReport(TLogEventDefine.ExposureEntrance, 0, TLogReasonStr)
      log(bWriteLog and "TLog new format, LobbySystem.ExposureReportInLobby Banner, reason : " .. tostring(eventType) .. " reasonStr : " .. tostring(TLogReasonStr))
    end
  end
end
function LobbySystem.IsCanWatchEnemy()
  return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_WATCH_CHAIN)
end
function LobbySystem.on_modify_role_face_respond(ret)
  log(bWriteLog and "on_modify_role_face_respond")
  if ret == "bad_param" then
    ShowNotice(LocUtil.GetLocalizeResStr(301270))
  elseif ret == "no enough gold or item" then
    ShowNotice(LocUtil.GetLocalizeResStr(301269))
  elseif ret == NetErrorCode_NONE then
    ShowNotice(LocUtil.GetLocalizeResStr(301268))
    local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
    logicCreateRole.BuyAvatarOK()
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.UpdatePlayer()
  end
end
function LobbySystem.batch_buy_avatar_features_rsp(ret, list, avatar_feature_list, req_list)
  log(bWriteLog and "batch_buy_avatar_features_rsp:" .. tostring(ret))
  if ret == NetErrorCode_NONE then
    log_tree("LobbySystem.batch_buy_avatar_features_rsp", list)
    log_tree("LobbySystem.batch_buy_avatar_features_rsp", avatar_feature_list)
    if avatar_feature_list ~= nil then
      local avatar_list = {}
      for k, v in pairs(avatar_feature_list) do
        avatar_list[k] = v
      end
      DataMgr.avatarData.    end
    if UIManager.IsUIShow(UIManager.UI_Config.Lobby_CreatRole) then
      ShowNotice(LocUtil.GetLocalizeResStr(301268))
      local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
      logicCreateRole.BuyAvatarOK(list)
      local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
      LobbyAvatarManager.UpdatePlayer()
    else
      local WardrobeAppearance = require("client.slua.logic.wardrobe.logic_wardrobe_appearance")
      WardrobeAppearance:UpdateAvatarCallback(list, req_list)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_CURRENT_TAB)
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:GetOrReqData(DataMgr.roleData.uid, function(callUid, callInfo)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, callUid)
    end, {bForceReq = true}, Enum_AvatarShowSource.LobbySystem)
  elseif ret == "not-enough-gold" then
    ShowNotice(LocUtil.GetLocalizeResStr(301269))
  elseif ret == "not-enough-uc" then
    ShowNotice(LocUtil.GetLocalizeResStr(4787))
  elseif ret == "pay-error" then
    ShowNotice(LocUtil.GetLocalizeResStr(502005))
  elseif ret == "cfg-error" then
    ShowNotice(LocUtil.GetLocalizeResStr(990010))
  elseif ret == "repeat-buy" or ret == "already-in-use" then
    ShowNotice(LocUtil.GetLocalizeResStr(4793))
  elseif ret == 507001 then
    ShowNotice(LocUtil.GetLocalizeResStr(6405))
  elseif ret == "qrcode_login_limit" then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
  end
end
function LobbySystem.check_avatar_time()
  local needupdate = false
  for k, v in pairs(DataMgr.avatarData.avatar_list) do
    local remainTime = DataMgr.GetAvatarRemainTime(k)
    if remainTime < 0 then
      needupdate = true
      break
    end
  end
  if needupdate then
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_update_buy_avatar_features_req()
  end
end
function LobbySystem.update_buy_avatar_features_rsp(ret, avatar, avatar_feature_list)
  log(bWriteLog and "update_buy_avatar_features_rsp:" .. tostring(ret))
  if ret == NetErrorCode_NONE then
    log_tree("avatar data", avatar)
    AvatarData.SetHeadID(avatar.headid)
    AvatarData.SetGameGender(avatar.gamegender)
    AvatarData.SetHairID(avatar.hairid)
    AvatarData.SetBeardID(avatar.beardid or 0)
    AvatarData.SetBeardColorID(avatar.beardcolor or 0)
    local avatar_list = {}
    if avatar_feature_list ~= nil then
      for k, v in pairs(avatar_feature_list) do
        avatar_list[k] = v
      end
    end
    DataMgr.avatarData.    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.UpdatePlayer()
  end
end
function LobbySystem.avatar_feature_notify(avatar_feature_list, new_activate_avatar_list)
  local avatar_list = {}
  if avatar_feature_list ~= nil then
    for k, v in pairs(avatar_feature_list) do
      avatar_list[k] = v
    end
  end
  DataMgr.avatarData.  local activate_avatar_list = {}
  if new_activate_avatar_list ~= nil then
    for k, v in pairs(new_activate_avatar_list) do
      activate_avatar_list[k] = v
    end
  end
  DataMgr.avatarData.  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.UpdatePlayer()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_CURRENT_TAB)
end
function LobbySystem.QueryActivityDisplayStatus()
  log(bWriteLog and "LobbySystem.QueryActivityDisplayStatus, Send get_activity_display_req")
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_get_activity_display_req()
end
local LocalIfActivityShowByUrl = function(actUrl)
  local success, pandoraSystem = pcall(require, "client.slua.logic.Pandora.pandora_system")
  if not success or not pandoraSystem then
    log_error("LocalIfActivityShowByUrl: pandora_system module not found")
    return true
  end
  if actUrl and not pandoraSystem.CheckActIsShowByUrl(actUrl) then
    return false
  end
  return true
end
local LocalIfActivityShow = function(actType, data)
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  if not logic_multiple_area:IsPaymentSupport() then
    if data ~= nil and (string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_EVERYDAY_PACK) or string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_EVERYDAY_PACK_V2) or string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_CUSTOM_PACK) or string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_RECHARGE_GAS_STATION)) then
      return false
    end
    if actType == ActivityDisplayType.FIRST_RECHARGE or actType == ActivityDisplayType.FIRST_RECHARGE2 or data ~= nil and string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON) then
      return false
    end
  end
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  if actType == ActivityType.ACTIVITY_CENTER_IMAGE then
    local ActivityNewCenter = require("client.slua.logic.activity.logic_activity_center")
    table.insert(ActivityNewCenter.enterData, data)
    return false
  end
  if data and data.BackupParam1 and data.BackupParam1 ~= "" then
    local uctTime = data.BackupParam1
    local disTime = TimeUtil.TimeStringToUnixstamp(uctTime)
    local now = TimeUtil.GetServerTimeInSec()
    if disTime and disTime <= now and data.ShowSceneID and data.ShowSceneID == ActivitySceneID.EntrySet and data.EntryImagePath ~= "" then
      return false
    end
  end
  local EightDaySystem = require("client.slua.logic.activity.newbie.logic_newbie_eight_day")
  if actType == ActivityType.NEW_PLAYER and EightDaySystem.GetShowErrorCode() ~= 0 then
    return false
  end
  local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
  local bOpen = logic_new_player_spin.IsOpen()
  if actType == ActivityType.NEW_PLAYER_SPIN and not bOpen then
    return false
  end
  if actType == ActivityType.BIND_SEND_GIFT then
    local logic_bind_facebook = require("client.slua.logic.activity.logic_bind_facebook")
    return logic_bind_facebook.IsShowDisplayActivity()
  end
  if actType == ActivityType.STARTER_PACK_US or data ~= nil and data.JumpUrl and string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_STARTER_PACK) then
    if StarterPackSystem.IsOpen() == false then
      return false
    end
    if data ~= nil and data.ID then
      if StarterPackSystem.IsValidActivity(data) == false then
        return false
      end
      StarterPackSystem.UpdateCarousalIconPath(data)
    end
    return true
  end
  if data ~= nil and string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_BUY_UPASS_ACT) then
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    log(bWriteLog and "UnknowPassBuyActSystem.GetNeedShowEntrance = " .. tostring(UnknowPassBuyActSystem.GetNeedShowEntrance()))
    return UnknowPassBuyActSystem.GetNeedShowEntrance()
  end
  if actType == ActivityDisplayType.UPDATE_RP then
    return not UnknowPassSystem.IsBuyElite
  end
  if actType == ActivityDisplayType.FIRST_RECHARGE_BANNER or actType == ActivityDisplayType.FIRST_RECHARGE_BANNER_JPKR or data ~= nil and string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON) then
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    log(bWriteLog and "on_get_activity_LocalIfActivityShow" .. tostring(RechargeSystem.isHideFirstCharge))
    return not RechargeSystem.isHideFirstCharge
  end
  if data ~= nil and string.find(data.JumpUrl, "module=" .. BP_EMUM_MODULE_BILLBOARD_FOR_COMEBACK) then
    local bulletinManager = require("client.slua.umg.activity.bulletin_board.bulletin_manager")
    if not bulletinManager.ComebackBannerCheck() then
      return false
    end
  end
  if data ~= nil and not LocalIfActivityShowByUrl(data.JumpUrl) then
    log(bWriteLog and "LocalIfActivityShowByUrl pandora not ready")
    log(bWriteLog and "data.JumpUrl: " .. data.JumpUrl)
    return false
  end
  if data ~= nil and string.find(data.JumpUrl, "module=" .. BP_ENUM_MODULE_EVERYDAY_PACK_V2) then
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local nCurAOSSHOP = Client.GetAOSSHOP()
    if nCurAOSSHOP ~= AOSSHOPMacros.Google and nCurAOSSHOP ~= AOSSHOPMacros.HMS and nCurAOSSHOP ~= AOSSHOPMacros.ThirdPartyPayment then
      return false
    end
  end
  return true
end
function LobbySystem.refresh_activity_display_byCentauri()
  LobbySystem.RefreshBannerDisplayList()
end
function LobbySystem.refresh_activity_display_bystarterpack()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if ActivityNewSystem.GetActivityLoop() then
    return
  end
  LobbySystem.RefreshBannerDisplayList()
end
function LobbySystem.RecreateActivityBanner()
  local logicCornerDot = require("client.slua.umg.lobby.lobby_corner_dot")
  logicCornerDot.ResetBannerWidgetMapping()
  logicCornerDot.RefreshLobbyCornerDot()
end
function LobbySystem.refresh_activity_display_starterpack_countdown()
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  for k, v in pairs(LobbySystem.activityBtnDisplayList) do
    if v.ActivityType == ActivityType.STARTER_PACK_US or string.find(v.JumpUrl, "module=" .. BP_ENUM_MODULE_STARTER_PACK) then
      v.ActivityName = StarterPackSystem.GetPurchaseEffectiveTimeDesc()
      v.IsShowCountDownIcon = true
      if v.ActivityName == "SOON" then
        v.IsShowCountDownIcon = false
        v.ActivityName = ""
      end
      break
    end
  end
end
function LobbySystem.refresh_activity_display_by_unknow_pass()
  LobbySystem.RefreshBannerDisplayList()
end
local IsShowThisBannerByUrl = function(jump_url)
  if not jump_url then
    return
  end
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(jump_url)
  if not params then
    return
  end
  local moduleId = tonumber(params.module)
  if moduleId == BP_ENUM_MODULE_SUBSCRIBE_CARNIVAL then
    local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
    if not LobbySystem.CheckOpen(BP_ENUM_SUBSCRIBE_CARNIVAL_ID) or not SubscribeCarnivalSystem.IsActivityOpen() then
      return false
    end
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    if Client.GetAOSSHOP() == AOSSHOPMacros.HMS then
      local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
      local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
      return subscribeModuleObj:HMSIsOpenSubscribe()
    end
  elseif moduleId == BP_ENUM_MODULE_PRIME then
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    return subscribeModuleObj:CheckMenuOpen()
  end
  return true
end
function LobbySystem.refresh_activity_display_byPandora()
  LobbySystem.RefreshBannerDisplayList()
end
function LobbySystem.on_get_activity_display_res(activity_display_table)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local TableUtil = require("common.table_util")
  log(bWriteLog and "LobbySystem.on_get_activity_display_res, table.num = " .. TableUtil.CountTable(activity_display_table))
  local   local   LobbySystem.activityDisplayDataList = {}
  LobbySystem.activityBtnDisplayList = {}
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local isshowprime = subscribeModuleObj:CheckMenuOpen()
  local ActivityEntrySetSystem = require("client.slua.logic.activity.logic_activity_entry_set")
  ActivityEntrySetSystem.ClearData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local BOUNDS = 2147400000
  local ActivityMiniTVData = {}
  local NewBieActivityData = {}
  local osTime = TimeUtil.OSTime()
  local now = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(activity_display_table) do
    local data = {
      ID = k,
      Priority = v.display or 0,
      ActivityName = v.activity_name or "",
      ActivityDesc = v.activity_desc or "",
      IconPath = v.icon,
      JumpUrl = v.jump,
      StartTime = TimeUtil.FormatTime_YMDHMS(BOUNDS < v.start_time and BOUNDS or v.start_time, true),
      EndTime = TimeUtil.FormatTime_YMDHMS(BOUNDS < v.end_time and BOUNDS or v.end_time, true),
      StartTimeUTC = v.start_time,
      EndTimeUTC = v.end_time,
      IsNew = LobbySystem.CheckIfBannerNeedShowFx(k, v.start_time),
      ActivityType = v.act_type,
      IsShowCountDownIcon = false,
      Weight = v.weight,
      BPPath = v.blueprint_path or "",
      DependItems = v.auto_download_items or "",
      Depends = v.dependent_resources or "",
      ShowSceneID = v.show_scene_id and tonumber(v.show_scene_id) or 0,
      EntryImagePath = v.scene_image_link or "",
      BackupParam1 = v.back_up_one or "",
      BackupParam2 = v.back_up_two or "",
      BannerType = v.banner_type or 0,
      ActId = v.act_id,
      CreatedUtc = 0,
      CreatedProcess = 0,
      isNewbie = v.is_newbie or 0,
      EndShowDay = v.newbie_end_time,
      StartShowDay = v.newbie_start_time,
      CornerIconPath = v.subscript_pic_path or ""
    }
    if v.back_up_one and v.back_up_one ~= "" then
      local StringUtil = require("common.string_util")
      local params = StringUtil.ParseURLParams(v.back_up_one)
      if string.find(v.back_up_one, "banner_info") then
        data.effectBp = v.scene_image_link or ""
        data.height = params.height and params.height ~= "" and tonumber(params.height) or SideBannerHeightType.small
        data.discount = params.discount and params.discount ~= "" and tonumber(params.discount)
        local featureIdList = StringUtil.Split(params.id, "|")
        local featureIconList = StringUtil.Split(params.icon, "|")
        data.featureList = {}
        for index, id in ipairs(featureIdList) do
          table.insert(data.featureList, {
            id = tonumber(id),
            icon = featureIconList[index]
          })
        end
      elseif string.find(v.back_up_one, "character_info") then
        local up_start = params.up_start and params.up_start ~= "" and tostring(params.up_start) or nil
        data.chanceUpBeginTime = up_start and TimeUtil.TimeStringToUnixstamp(up_start) or 0
        local up_end = params.up_end and params.up_end ~= "" and tostring(params.up_end) or nil
        data.chanceUpEndTime = up_end and TimeUtil.TimeStringToUnixstamp(up_end) or 0
        data.frameStyle = params.frameStyle and params.frameStyle ~= "" and tonumber(params.frameStyle) or 0
      end
    end
    if v.start_time == 0 then
      data.StartTimeUTC = osTime
    end
    if v.end_time == 0 then
      data.EndTimeUTC = data.StartTimeUTC + 31536000
    end
    local tmp = ActivityNewSystem.GetActivityByID(v.act_id)
    if not tmp or not tmp.Type then
      data.Type = 0
    else
      data.Type = tmp.Type
      if data.Type == ActivityType.ONLINE_TIME then
        data.CreatedUtc = now
        data.CreatedProcess = tmp.List[#tmp.List].Progress
      end
    end
    if data.ActivityType == ActivityType.MiniTV then
      data.VersionStr = v.version
      if data.isNewbie == 1 then
        data.EndShowDay = v.newbie_end_time
        data.StartShowDay = v.newbie_start_time
        NewBieActivityData[#NewBieActivityData + 1] = data
      else
        ActivityMiniTVData[#ActivityMiniTVData + 1] = data
      end
    else
      if LocalIfActivityShow(data.ActivityType, data) then
        if IsShowThisBannerByUrl(data.JumpUrl) then
          LobbySystem.activityBtnDisplayList[#LobbySystem.activityBtnDisplayList + 1] = data
        end
        log(bWriteLog and "LobbySystem.on_get_activity_display_res, type = " .. tostring(data.ActivityType) .. ", name = " .. data.ActivityName .. ", url = " .. data.JumpUrl .. ", start = " .. data.StartTime .. ", end = " .. data.EndTime .. ", weight = " .. data.Weight)
      else
        log(bWriteLog and "LobbySystem.on_get_activity_display_res, name = " .. data.ActivityName .. ", url = " .. data.JumpUrl .. ", but except")
      end
      if not isshowprime and data.JumpUrl == "game://?module=1006002" then
      elseif IsShowThisBannerByUrl(data.JumpUrl) then
        LobbySystem.activityDisplayDataList[#LobbySystem.activityDisplayDataList + 1] = data
      end
    end
  end
  table.sort(LobbySystem.activityBtnDisplayList, LobbySystem.SortActivityDisplayListFunc)
  LobbySystem.RecreateActivityBanner()
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:RefreshSupplyBannerListTag()
  local logic_newbie_bubble = require("client.slua.logic.mini_tv.logic_newbie_bubble")
  logic_newbie_bubble.SaveNewBieBannerInfo(NewBieActivityData)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE, activity_display_table, ActivityMiniTVData)
  LobbySystem.ExposureReportInLobby(0)
  if not LogicNewbie.IsNewbie() or LogicNewbie.NeedShowNewbieGuide(10603) then
    local TheFirstChargeSystem = require("client.slua.logic.recharge.logic_the_first_charge")
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON, TheFirstChargeSystem.red_dot)
  end
  local LuckyUnbackSystem = require("client.slua.logic.lobby_activity.logic_luckyunback_activity")
  LuckyUnbackSystem.InitRedPoint()
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.redPoint.bannerRedPoint = LuckybackActivitySystem.CanShowBannerRedPoint()
  LuckybackActivitySystem.InitRedPoint()
  LobbySystem.HandleEverydayPackActRedPoint()
  local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
  UnknowPassBuyActSystem.GetNeedShowReddot(true)
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  pandoraSystem.UpdateRedPoint()
  ActivityNewSystem.PostActivityRedDot(true)
  local everyDayUCSystem = require("client.logic.everyday_pack.logic_everyday_uc")
  everyDayUCSystem.GetEveryDayData()
  if ActivityNewSystem.IsActivityOpenByBanner(BP_ENUM_MODULE_RECRUIT) then
    local LogicRecruit = require("client.slua.logic.recruit.logic_recruit_newer")
    LogicRecruit:ReuqestRecruitInfo()
  end
  local Logic_Financial = require("client.slua.logic.Financial.Logic_Financial")
  Logic_Financial.Init()
  local Logic_SmallPayment = require("client.slua.logic.SmallPayment.Logic_SmallPayment")
  Logic_SmallPayment.Init()
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:send_small_rp_player_data_req()
  if ActivityNewSystem.IsActivityOpenByBanner(BP_ENUM_MODULE_APLAN_EXPLORE) then
    local ExploreSystem = require("client.slua.logic.explore.logic_explore")
    ExploreSystem.Init()
    local logic_whole_explore = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_whole_explore)
    logic_whole_explore:Init()
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(2, function()
    LobbySystem.HandleUPassActRedPoint()
  end)
end
local CheckIsPandoraItemUpgrade = function()
  return false
end
local CheckIsPandoraItemUpgradeWithGroupID = function(data, checkGroupID)
  if CheckIsPandoraItemUpgrade(data.JumpUrl) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(data.JumpUrl)
    local groupID = tonumber(params.GroupID) or 0
    return checkGroupID == groupID
  end
end
function LobbySystem.CheckHasPandoraItemUpgradeActWithItemID(itemID)
  local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local cfg = ItemUpgradeMgr:GetUpgradeCfg(itemID)
  if cfg then
    if next(BP_LobbyHighestBannerData) then
      local bValid = CheckIsPandoraItemUpgradeWithGroupID(BP_LobbyHighestBannerData, cfg.GroupID)
      if bValid then
        return true, BP_LobbyHighestBannerData.JumpUrl
      end
    end
    if LobbySystem.activityDisplayDataList ~= nil then
      for _, v in pairs(LobbySystem.activityDisplayDataList) do
        local bValid = CheckIsPandoraItemUpgradeWithGroupID(v, cfg.GroupID)
        if bValid then
          return true, v.JumpUrl
        end
      end
    end
  end
  return false, nil
end
function LobbySystem.CheckPandoraItemUpgradeActRefGroupID()
  local groupMap = {}
  if next(BP_LobbyHighestBannerData) and CheckIsPandoraItemUpgrade(BP_LobbyHighestBannerData.JumpUrl) then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(BP_LobbyHighestBannerData.JumpUrl)
    local groupID = tonumber(params.GroupID) or 0
    if groupID ~= 0 then
      groupMap[groupID] = 1
    end
  end
  if LobbySystem.activityDisplayDataList ~= nil then
    for _, v in pairs(LobbySystem.activityDisplayDataList) do
      if CheckIsPandoraItemUpgrade(v.JumpUrl) then
        local StringUtil = require("common.string_util")
        local params = StringUtil.ParseURLParams(v.JumpUrl)
        local groupID = tonumber(params.GroupID) or 0
        if groupID ~= 0 then
          groupMap[groupID] = 1
        end
      end
    end
  end
  return groupMap
end
BP_LobbyHighestBannerData = {}
function LobbySystem.SetHighestBannerData()
  BP_LobbyHighestBannerData = {}
  if #LobbySystem.activityBtnDisplayList < 1 then
    return
  end
  local idx = 0
  for i, v in ipairs(LobbySystem.activityBtnDisplayList) do
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(v.JumpUrl)
    local actid = tonumber(params.actid)
    local moduleid = tonumber(params.module)
    if (ENUM_LOBBY_TOPENTRANCE_PATH[moduleid] or ENUM_LOBBY_TOPENTRANCE_PATH[actid]) and v.Weight ~= 0 then
      idx = i
      BP_LobbyHighestBannerData = v
      break
    end
  end
  if idx == 0 then
    log_warning("No banner LobbySystem.SetHighestBannerData")
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_CHANGE, nil)
    return
  end
  table.remove(LobbySystem.activityBtnDisplayList, idx)
  if next(BP_LobbyHighestBannerData) ~= nil then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_CHANGE, BP_LobbyHighestBannerData)
  end
end
function LobbySystem.RefreshBannerDisplayList()
  LobbySystem.activityBtnDisplayList = {}
  for i = #LobbySystem.activityDisplayDataList, 1, -1 do
    local displayData = LobbySystem.activityDisplayDataList[i]
    local data = {}
    data.ID = displayData.ID
    data.Priority = displayData.Priority
    data.ActivityName = displayData.ActivityName
    data.IconPath = displayData.IconPath
    data.JumpUrl = displayData.JumpUrl
    data.StartTime = displayData.StartTime
    data.EndTime = displayData.EndTime
    data.StartTimeUTC = displayData.StartTimeUTC
    data.EndTimeUTC = displayData.EndTimeUTC
    data.ActivityType = displayData.ActivityType
    data.IsShowCountDownIcon = displayData.IsShowCountDownIcon
    data.Weight = displayData.Weight
    data.BPPath = displayData.BPPath
    data.IsNew = displayData.IsNew
    data.ShowSceneID = displayData.ShowSceneID
    data.EntryImagePath = displayData.EntryImagePath
    data.DependItems = displayData.DependItems
    data.Depends = displayData.Depends
    data.BackupParam1 = displayData.BackupParam1
    data.BackupParam2 = displayData.BackupParam2
    data.Type = displayData.Type
    data.ActId = displayData.ActId
    data.CreatedUtc = displayData.CreatedUtc
    data.CreatedProcess = displayData.CreatedProcess
    data.BannerType = displayData.BannerType or 0
    data.height = displayData.height or SideBannerHeightType.small
    data.effectBp = displayData.effectBp or ""
    data.discount = displayData.discount or 0
    data.featureList = displayData.featureList or {}
    data.chanceUpBeginTime = displayData.chanceUpBeginTime or 0
    data.chanceUpEndTime = displayData.chanceUpEndTime or 0
    data.frameStyle = displayData.frameStyle or 0
    if LocalIfActivityShow(data.ActivityType, data) then
      table.insert(LobbySystem.activityBtnDisplayList, data)
    end
  end
  table.sort(LobbySystem.activityBtnDisplayList, LobbySystem.SortActivityDisplayListFunc)
  LobbySystem.RecreateActivityBanner()
end
function LobbySystem.CheckIfBannerNeedShowFx(id, StartTimeUTC)
  if TimeUtil.GetServerTimeInSec() - StartTimeUTC >= 259200 and not LobbySystem.ShowNewIconActivity(id) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBannerFx)
  if not (saveData and saveData[tostring(id)]) or not saveData[tostring(id)][tostring(StartTimeUTC)] then
    return true
  end
  return false
end
function LobbySystem.ShowNewIconActivity(ID)
  if ID == 13387 or ID == 13391 or ID == 13393 then
    return true
  end
  return false
end
function LobbySystem.SaveIfBannerGotClicked(id, StartTimeUTC)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBannerFx)
  saveData = saveData or {}
  saveData[tostring(id)] = saveData[tostring(id)] or {}
  saveData[tostring(id)][tostring(StartTimeUTC)] = true
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eBannerFx)
end
function LobbySystem.SetActivityIfShow(actType)
  if not LobbySystem.activityBtnDisplayList then
    return
  end
  local targetActivityIdx
  for i, v in ipairs(LobbySystem.activityBtnDisplayList) do
    log(bWriteLog and v.Type)
    if v.Type == actType and not LocalIfActivityShow(actType, v) then
      targetActivityIdx = i
      break
    end
  end
  if targetActivityIdx then
    table.remove(LobbySystem.activityBtnDisplayList, targetActivityIdx)
    LobbySystem.RecreateActivityBanner()
  end
end
function LobbySystem.SetActivityIfShowByModuleId(ModuleId)
  local JumpUtils = require("client.logic.store.jump_utils")
  if not LobbySystem.activityBtnDisplayList then
    return
  end
  local targetActivityIdx
  for i, v in ipairs(LobbySystem.activityBtnDisplayList) do
    if (JumpUtils.IsGameJumpUrl(v.JumpUrl) or JumpUtils.IsPanDoraJumpUrl(v.JumpUrl) and string.find(v.JumpUrl, "module=" .. tostring(ModuleId))) and not LocalIfActivityShowByUrl(v.JumpUrl) then
      targetActivityIdx = i
      break
    end
  end
  if targetActivityIdx then
    table.remove(LobbySystem.activityBtnDisplayList, targetActivityIdx)
    LobbySystem.RecreateActivityBanner()
  end
end
function LobbySystem.CheckUrlCanJump(url)
  local StringUtil = require("common.string_util")
  if LobbySystem.CheckJumpWhiteList(url) then
    return true
  end
  if BP_LobbyHighestBannerData and next(BP_LobbyHighestBannerData) ~= nil and StringUtil.Starts(BP_LobbyHighestBannerData.JumpUrl, url) and TimeUtil.UnixTimeBetween(BP_LobbyHighestBannerData.StartTimeUTC, BP_LobbyHighestBannerData.EndTimeUTC) == 0 then
    return true
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  for _, v in pairs(LobbySystem.activityBtnDisplayList) do
    if StringUtil.Starts(v.JumpUrl, url) or JumpUtils.CheckUrlModuleID(v.JumpUrl, url) then
      if TimeUtil.UnixTimeBetween(v.StartTimeUTC, v.EndTimeUTC) == 0 then
        return true
      else
        log_warning(bWriteLog and "  LobbySystem.CheckUrlCanJump time error. v.JumpUrl " .. tostring(v.JumpUrl))
        local start = TimeUtil.FormatTime_YMD(v.StartTimeUTC)
        local sEnd = TimeUtil.FormatTime_YMD(v.EndTimeUTC)
        log_warning(bWriteLog and "  LobbySystem.CheckUrlCanJump. start " .. tostring(start))
        log_warning(bWriteLog and "  LobbySystem.CheckUrlCanJump. sEnd " .. tostring(sEnd))
        return false
      end
    end
  end
  return false
end
function LobbySystem.CheckJumpWhiteList(url)
  if not LobbySystem.jump_whiteList or not next(LobbySystem.jump_whiteList) then
    return false
  end
  local StringUtil = require("common.string_util")
  local urlParam = StringUtil.ParseURLParams(url)
  local module = tonumber(urlParam.module)
  if not LobbySystem.jump_whiteList[module] then
    return false
  end
  if module == BP_ENUM_MODULE_SPECIAL_OFFER then
    if not urlParam.id then
      return false
    end
    local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
    local id = tonumber(urlParam.id)
    if id then
      if not cfg.id2CheckShow[id] then
        id = cfg.ActId2Id[id]
      end
      if id == cfg.golden then
        return true
      elseif cfg.id2CheckShow[id] then
        local checkShowFunc = cfg.id2CheckShow[id]
        if not (id and cfg.uiCdg[id]) or checkShowFunc and not checkShowFunc(urlParam) then
          return false
        end
      end
    end
  elseif module == BP_ENUM_MODULE_SMALL_RP_BUY_SCORE or module == BP_ENUM_MODULE_SMALL_RP_TASK then
    local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
    local checkShowFunc = cfg.id2CheckShow[cfg.SmallRP]
    if checkShowFunc and not checkShowFunc(urlParam) then
      return false
    end
  elseif module == BP_ENUM_MODULE_BLACK_FRIDAY_MAIN then
    local BlackFridayMainModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayMainModule)
    if not BlackFridayMainModule:HasInit() then
      return false
    end
    local type = tonumber(urlParam.type)
    if type then
      return BlackFridayMainModule:HasActivityData(type)
    end
  elseif module == BP_ENUM_MODULE_ROLEINFO then
    local index = tonumber(urlParam.index)
    if not index then
      return false
    end
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    if RoleInfoMainSystem.IsCollectTabbByIndex(index) then
      local ispermanent = tonumber(urlParam.ispermanent)
      if ispermanent and ispermanent == 1 then
        log(bWriteLog and "LobbySystem.CheckJumpWhiteList IsCollectTabbByIndex ispermanent == 1")
        return true
      end
    end
    return false
  elseif module == BP_ENUM_MODULE_CARD_COLLECTION_MAIN then
    local CardCollectionMainJumpModule = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.CardCollectionMainJumpModule)
    return CardCollectionMainJumpModule:JumpCheck(urlParam)
  end
  return true
end
function LobbySystem.HandleEverydayPackActRedPoint()
  local hasAct = false
  local   for k, v in pairs(LobbySystem.activityBtnDisplayList) do
    if v.JumpUrl and string.find(v.JumpUrl, "module=" .. BP_ENUM_MODULE_EVERYDAY_PACK) or v.JumpUrl and string.find(v.JumpUrl, "module=" .. BP_ENUM_MODULE_EVERYDAY_PACK_V2) then
      hasAct = true
      break
    end
  end
  if hasAct == true then
    LobbyUI.HandleEverydayPackActRedPoint()
  end
end
function LobbySystem.HandleUPassActRedPoint()
  local hasUPassAct = false
  for k, v in pairs(LobbySystem.activityBtnDisplayList) do
    if v.JumpUrl and string.find(v.JumpUrl, "module=" .. BP_ENUM_MODULE_BUY_UPASS_ACT) then
      hasUPassAct = true
      break
    end
  end
  if hasUPassAct == true then
    LobbyUI.HandleUPassActRedPoint()
  end
end
function LobbySystem.HandleHalloweenVehicleRedPoint()
  local LogicHalloweenVehicle = require("client.logic.activity.logic_halloween_vehicle")
  for k, v in pairs(LobbySystem.activityBtnDisplayList) do
    if v.JumpUrl and string.find(v.JumpUrl, "module=" .. BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE) then
      LogicHalloweenVehicle.UpdateShowRedPoint()
      return
    end
  end
end
function LobbySystem.HandleAnniversaryRedPoint()
end
function LobbySystem.SortActivityDisplayListFunc(a, b)
  local nowTime = TimeUtil.GetServerTimeInSec()
  local aTime = a.StartTimeUTC or 0
  local bTime = b.StartTimeUTC or 0
  local aWeight = a.Weight or 0
  local bWeight = b.Weight or 0
  if aWeight == bWeight then
    if aTime == bTime then
      return (a.ID or 0) > (b.ID or 0)
    else
      return aTime > bTime
    end
  elseif aTime == bTime then
    return (a.Weight or 0) > (b.Weight or 0)
  elseif TimeUtil.IsSameDay(aTime, nowTime) or TimeUtil.IsSameDay(bTime, nowTime) then
    return aTime > bTime
  else
    return aWeight > bWeight
  end
end
function LobbySystem.query_s_manager_respond(open)
  log(bWriteLog and "query_gm_respond = " .. tostring(open))
  DataMgr.SetSManager(open)
  if not GameStatus.IsInLobbyOrMainCity() then
    local waterMask = require("client.slua.umg.Fighting_Watermark.Fighting_Watermark_BP")
    waterMask.RefreshWatermarkByGMSwitch()
  else
    local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
    LobbyWaterMarkSystem.RefreshWatermarkByGMSwitch()
  end
end
function LobbySystem.CheckDeviceLimitRefuse()
  local RefuseCallBack = function()
    GameStatus.QuitGame()
  end
  local tips = DataMgr.GetMultiLineMsgByID(101716)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), tips, RefuseCallBack, RefuseCallBack)
end
function LobbySystem.CheckDeviceLimitTip()
  if NeedCheckDeviceLimit == false then
    return
  end
  local tips = DataMgr.GetMultiLineMsgByID(101716)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), tips)
end
function LobbySystem.respGMVersion(msg)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.SetDsVersion(msg)
end
function LobbySystem.UpdateLobbyNewbieState()
  log(bWriteLog and "LobbySystem.UpdateLobbyNewbieState")
  LobbySystem.UpdateSettingRedPoint()
end
function LobbySystem.GetDoubleCardName(localizeID, value)
  local result = 1 + value / 100
  local intValue = math.floor(result)
  if math.abs(result - intValue) < 1.0E-4 then
    result = intValue
  end
  return LocUtil.LocalizeResFormat(localizeID, result)
end
function LobbySystem.UpdateLobbyCorpsRedDot(hasReddot)
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_CORPS, hasReddot)
  local corpsTabMgr = UIManager.GetUI(UIManager.UI_Config.CorpsTabMgr)
  if corpsTabMgr then
    corpsTabMgr:RefreshAllTabs()
  end
end
function LobbySystem.GetDoubleCardTimeStr(timestamp)
  local remainTime = timestamp - TimeUtil.GetServerTimeInSec()
  return TimeUtil.FormatCountDownTime_DH_or_HM(remainTime, true)
end
function LobbySystem.GetSaftySeasonValue(seasonValue)
  if seasonValue == nil or seasonValue <= 0 then
    return 1
  end
  return seasonValue
end
function LobbySystem.on_relation_chain_error(res)
  if res == nil then
    return
  end
  log(bWriteLog and "LobbySystem.on_relation_chain_error:" .. res)
  if res == "-405" then
    Client.ProcessServerRelationChainError(NetInterface, res, 259200)
  end
end
function LobbySystem.ShowKrJpDelAccountPanel()
  local ExitGameToLogin = function()
    log(bWriteLog and "[CCW]LobbySystem.ShowKrJpDelAccountPanel  ExitGameToLogin")
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:sendLogout()
  end
  local CanelKrJpDelAccount = function()
    log(bWriteLog and "[CCW]LobbySystem.ShowKrJpDelAccountPanel  CanelKrJpDelAccount")
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.SendKoreaCancelDeleteAccount()
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local strRegion = Client.GetPublishRegion()
  if PublishRegionMacros.IsJapanOrKorea() and DataMgr.krjp_del_account_left_time > 0 and login_module.commonSwitch ~= nil and login_module.commonSwitch.KRJPDelAccountSwitch == true then
    log(bWriteLog and "LobbySystem.ShowKrJpDelAccountPanel strRegion:" .. strRegion .. " krjp_del_account_left_time:" .. DataMgr.krjp_del_account_left_time)
    local timeSecond = DataMgr.krjp_del_account_left_time
    local day = timeSecond / 86400
    local hours = (day - math.floor(day)) * 24
    local timeStr = tostring(math.floor(day)) .. LocUtil.GetLocalizeResStr(301367)
    if 0 < hours then
      timeStr = timeStr .. tostring(math.floor(hours)) .. LocUtil.GetLocalizeResStr(1215)
    end
    local msgContent = string.format(LocUtil.GetLocalizeResStr(4640), timeStr)
    local msgTiltle = LocUtil.GetLocalizeResStr(101001)
    local strOK = LocUtil.GetLocalizeResStr(4948)
    local strCanel = LocUtil.GetLocalizeResStr(4114)
    log(bWriteLog and "LobbySystem.ShowKrJpDelAccountPanel strRegion:" .. strRegion .. " krjp_del_account_left_time:" .. DataMgr.krjp_del_account_left_time .. " msgTiltle:" .. msgTiltle .. " msgContent:" .. msgContent .. " strOK:" .. strOK .. " strCanel:" .. strCanel)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, msgTiltle, msgContent, CanelKrJpDelAccount, ExitGameToLogin, strOK, strCanel)
  end
end
function LobbySystem.on_get_season_broadcast_rsp(have_broadcast, refreshTime)
  local bHaveBroadcast = have_broadcast == 1
  local center_reddot_data = require("client.slua.logic.esport.center_reddot_data")
  if bHaveBroadcast then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local lastRedPointTime = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterRedPointInfo) or 0
    if TimeUtil.GetServerTimeInSec() - lastRedPointTime >= refreshTime * 3600 and not PublishRegionMacros.IsJapanOrKorea() then
      PlayerPrefsSystem.SaveTableToFile_N(TimeUtil.GetServerTimeInSec(), PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterRedPointInfo)
      center_reddot_data.UpdateCenterCount(1)
      return
    end
  end
  center_reddot_data.SendRemoveCenterTlog()
  center_reddot_data.UpdateCenterCount(0)
end
function LobbySystem.notice_some_no_map(no_map_uids)
  local num = #no_map_uids
  if num == 0 then
    return
  end
  for k, v in pairs(no_map_uids) do
    log(bWriteLog and "LobbySystem.notice_some_no_map, uid = " .. v)
    if tonumber(v) == tonumber(DataMgr.roleData.uid) then
      local noticeId = 31047
      local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
      local room_info = RoomSystem.CurrentRoomInfo
      if logic_ugc_mode:IsSelectUgcMode() or room_info and next(room_info) and room_info.room_type == "ugc" then
        logic_ugc_mode:ShowCurSelectUGCModDownloadNotice()
      else
        ShowNotice(noticeId)
      end
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_THEME_FLASH)
      return
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local tips = ""
  local isAllStarTeamMatch = UIManager.IsUIShow(UIManager.UI_Config.allstar_match_team)
  if 1 < num then
    tips = string.format(LocUtil.GetLocalizeResStr(5007), num)
    if isAllStarTeamMatch then
      if num == 2 then
        local nickNameA = LobbySystem.GetNickNameByUid(no_map_uids[1])
        local nickNameB = LobbySystem.GetNickNameByUid(no_map_uids[2])
        tips = LocUtil.LocalizeResFormat(37496, nickNameA, nickNameB)
      else
        tips = LocUtil.LocalizeResFormat(37497, num)
      end
    end
  else
    local nickName = LobbySystem.GetNickNameByUid(no_map_uids[1])
    tips = string.format(LocUtil.GetLocalizeResStr(5006), nickName)
  end
  local msgConfig = tips .. " " .. LocUtil.GetLocalizeResStr(5008)
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local room_info = RoomSystem.CurrentRoomInfo
  if logic_ugc_mode:IsSelectUgcMode() or room_info and next(room_info) and room_info.room_type == "ugc" then
    local names = ""
    local maxCount = 3
    local nameCount = 0
    local hasMore = false
    for k, v in pairs(no_map_uids) do
      local memName = LobbySystem.GetNickNameByUid(no_map_uids[k])
      if memName then
        if maxCount > nameCount then
          if 0 < #names then
            names = names .. "\239\188\140" .. memName
          else
            names = memName
          end
          nameCount = nameCount + 1
        else
          hasMore = true
          break
        end
      end
    end
    if hasMore then
      names = names .. "..."
    end
    msgConfig = LocUtil.LocalizeResFormat(10120063, names)
  end
  if TeamUpNewSystem.IsTeamLeader() and 1 < TeamUpNewSystem.GetTeamNum() or RoomSystem.isRoomOwner() then
    local title = LocUtil.GetLocalizeResStr(101001)
    local okLabel = LocUtil.GetLocalizeResStr(110036)
    local cancelLabel = LocUtil.GetLocalizeResStr(110035)
    local msgCfg = msgConfig
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msgCfg, function()
      LobbySystem.KickNoMapPeoplesOut()
    end, nil, okLabel, cancelLabel)
  else
    ShowNotice(tips)
  end
end
function LobbySystem.GetNickNameByUid(uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local data = TeamUpNewSystem.GetMemberInfo(uid)
  local nickName = ""
  if data then
    nickName = data.name
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profileData = logic_profile:GetLocalProfile(uid)
    if profileData then
      nickName = profileData.nickName
    else
      nickName = tostring(uid)
    end
  end
  return nickName
end
function LobbySystem.KickNoMapPeoplesOut()
  if RoomSystem.isRoomOwner() then
    local room_id = 0
    if RoomSystem.CurrentRoomInfo ~= nil then
      room_id = RoomSystem.CurrentRoomInfo.id
      log(bWriteLog and "LobbySystem.KickNoMapPeoplesOut, Send room_kick_no_map_req, room_id = " .. tostring(room_id))
      local LobbyHandler = require("client.network.Protocol.LobbyHandler")
      LobbyHandler.send_room_kick_no_map_req(room_id)
    else
      log(bWriteLog and "LobbySystem.KickNoMapPeoplesOut, Can't believe it.")
    end
  else
    log(bWriteLog and "LobbySystem.KickNoMapPeoplesOut, Send team_kick_no_map_req")
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_team_kick_no_map_req()
  end
end
function LobbySystem.room_kick_no_map_rsp(res)
  log(bWriteLog and "LobbySystem.room_kick_no_map_rsp, res = " .. tostring(res))
  if res == NetErrorCode_NONE then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local teamNum = TeamUpNewSystem.GetTeamNum()
    if TeamUpNewSystem.IsTeamLeader() and 1 < teamNum or teamNum == 1 or RoomSystem.isRoomOwner() then
    else
      local warning = LocUtil.GetLocalizeResStr(5009)
      ShowNotice(warning)
    end
  end
end
function LobbySystem.team_kick_no_map_rsp(res)
  log(bWriteLog and "LobbySystem.team_kick_no_map_rsp, res = " .. tostring(res))
  if res == NetErrorCode_NONE then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local teamNum = TeamUpNewSystem.GetTeamNum()
    if TeamUpNewSystem.IsTeamLeader() and 1 < teamNum or teamNum == 1 or RoomSystem.isRoomOwner() then
    else
      local warning = LocUtil.GetLocalizeResStr(5009)
      ShowNotice(warning)
    end
  end
end
local AlreadySendClientLog = false
function LobbySystem.client_trace(client_trace)
  if client_trace and not AlreadySendClientLog then
    Client.SendClientLog(GameFrontendHUD, "REPROTBUG-REASON-OTHER", "GetClientLog", true)
    Client.SendClientLog(GameFrontendHUD, "REPROTBUG-REASON-OTHER", "GetClientLog", false)
    AlreadySendClientLog = true
  end
end
function LobbySystem.on_depot_get_default_ware_rsp(wearInfo)
  log_tree("on_depot_get_default_ware_rsp", wearInfo)
  LobbySystem.PlayerDefaultWearInfo = {}
  LobbySystem.PlayerDefaultWearInfo = wearInfo
  local logicCreateRole = require("client.slua.logic.createRole.logic_createRole")
  logicCreateRole.InitDefaultWearInfo()
end
function LobbySystem.SendDefaultWearInfoReq()
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_depot_get_default_ware_req()
  log(bWriteLog and "Send depot_get_default_ware_req")
end
function LobbySystem.PlayItemPreviewAnimation(itemID, dontShowItemPreview, type, itemPara, validHours, other)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.GM_ShowDetailItem then
    itemID = UIUtil.GM_ShowDetailItem
  end
  if not itemID then
    return false
  end
  if string.find(itemID, ",") == nil then
    log(bWriteLog and "LobbySystem.PlayItemPreviewAnimation" .. itemID)
    if LobbySystem.CheckShowPackagePreview(itemID) == true then
      UIManager.ShowUI(UIManager.UI_Config.package_preview_panel, itemID)
      return true
    end
  else
    local mid = string.find(itemID, ",")
    local first = tonumber(string.sub(itemID, 1, mid - 1))
    local second = tonumber(string.sub(itemID, mid + 1, #itemID))
    log(bWriteLog and "LobbySystem.PlayItemPreviewAnimation " .. first .. " and " .. tostring(second))
    if LobbySystem.CheckShowPackagePreview(first) == true and LobbySystem.CheckShowPackagePreview(second) == true then
      UIManager.ShowUI(UIManager.UI_Config.package_preview_panel, first)
      return true
    end
  end
  local ctorData = {
    itemID = itemID,
    dontShowItemPreview = dontShowItemPreview,
    type = type,
    itemPara = itemPara,
    validHours = validHours,
      }
  local ItemPreviewJumpModule = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.ItemPreviewJumpModule)
  if not ItemPreviewJumpModule:JumpCheck(ctorData) then
    return false
  end
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_ITEM_PREVIEW, ctorData)
  return true
end
function LobbySystem.OpenPackagePanel(itemID)
  local isShow = LobbySystem.CheckShowPackagePreview(itemID)
  if isShow == true and UIManager then
    UIManager.ShowUI(UIManager.UI_Config.package_preview_panel, itemID)
  end
end
function LobbySystem.CheckShowPackagePreview(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  local isShow = false
  if itemCfg ~= nil and itemCfg.ItemType == ENUM_ITEM_TYPE.Starter_Pack and LobbySystem.CheckCanShowPreviewByItemSubType(itemCfg.ItemSubType) then
    isShow = true
  end
  return isShow
end
function LobbySystem.CheckCanShowPreviewByItemSubType(type)
  local cfgType = {
    1501,
    1502,
    1503,
    1504,
    1506,
    1508,
    1509
  }
  for k, v in pairs(cfgType) do
    if v == type then
      return true
    end
  end
  return false
end
function LobbySystem.OnClickItemForPreview(itemId, dontShowItemPreview, type, itemPara, validHours, other)
  log(bWriteLog and "LobbySystem.OnClickItemForPreview")
  local Social_Person_Space_UIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
  if Social_Person_Space_UIBP then
    return
  end
  local now = TimeUtil.GetMiliseconds()
  LobbySystem.utcTime = LobbySystem.utcTime or TimeUtil.GetMiliseconds()
  local diffTime = now - LobbySystem.utcTime
  log(bWriteLog and "LobbySystem.OnClickItemForPreview diffTime:" .. tostring(diffTime))
  if now - LobbySystem.utcTime <= 300 then
    LobbySystem.PlayItemPreviewAnimation(itemId, dontShowItemPreview, type, itemPara, validHours, other)
  end
end
function LobbySystem.OnPressItemForPreview()
  LobbySystem.utcTime = TimeUtil.GetMiliseconds()
end
function LobbySystem.CloseItemPreivew()
  local ItemPrewViewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  ItemPrewViewSystem.isHideByAvatarReset = false
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_CLOSE)
  if ItemPrewViewSystem.isHideByAvatarReset then
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE)
  end
end
function LobbySystem.ShowVNGPersonalInfo()
  local logic_vng_personal_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_vng_personal_info)
  local bNeedShowVNGPersonal = logic_vng_personal_info:GetNeedShowVNGPersonal()
  local curStatus = GameStatus.GetGameStatus()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  log(bWriteLog and string.format("LobbySystem.ShowVNGPersonalInfo curStatus:%s, bNeedShowVNGPersonal:%s, bIsInitLogin:%s", curStatus, tostring(bNeedShowVNGPersonal), tostring(login_module.bIsInitLogin)))
  if not (GameStatus.IsInLobbyOrMainCity() and bNeedShowVNGPersonal) or not login_module.bIsInitLogin then
    return
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(1, function()
    curStatus = GameStatus.GetGameStatus()
    if not GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and string.format("LobbySystem.ShowVNGPersonalInfo curStatus:%s", curStatus))
      return
    end
    logic_vng_personal_info:OpenVNGPersonalInfoUrl(1)
  end)
end
function LobbySystem.on_pet_module_close_rsp()
  log(bWriteLog and "LobbySystem.on_pet_module_close_rsp")
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet.PetSystemClosed = true
  EventSystem:postEvent(EVENTTYPE_PET, EVENTID_PET_System_Closed)
end
function LobbySystem.OnSubscribeToTopicSuccess(topic, success)
  log(bWriteLog and "LobbySystem.OnSubscribeToTopicSuccess topic:" .. topic .. ", success: " .. tostring(success))
  local FCMPushSystem = require("client.slua.logic.push.logic_fcm_push")
  FCMPushSystem.OnSubscribeToTopicSuccess(topic, success)
end
function LobbySystem.OnRequestPermissionsResult(requestCode, permissions, grantResult)
  log(bWriteLog and "LobbySystem.OnRequestPermissionsResult requestCode:" .. tostring(requestCode) .. ", permissions: " .. permissions .. ", grantResult: " .. grantResult)
  if requestCode == 100 and permissions == "[android.permission.RECORD_AUDIO]" and grantResult == "[-1]" then
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:OnRequestPermissionsResult(requestCode, permissions, grantResult)
  end
end
function LobbySystem.on_match_across_zone_res(msg)
  log(bWriteLog and "[edward][logic_lobby] LobbySystem.on_match_across_zone_res, msg = " .. msg)
  if msg == NetErrorCode_NONE then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.CrossMatchSuccess()
  elseif msg == "wrong_state" then
    ShowNotice(43710)
  elseif msg == "is_not_krjp" then
    ShowNotice(43711)
  end
end
function LobbySystem.On_add_battle_item_notify(itemid, count, MaxCount, type, can_into_depot)
  log(bWriteLog and "LobbySystem.On_add_battle_item_notify, itemid = " .. tostring(itemid) .. ", count = " .. tostring(count) .. ", MaxCount = " .. tostring(MaxCount) .. ", type = " .. tostring(type))
  if type == 1 then
    local BottomRightMessageBoxSystem = require("client.logic.common.logic_bottomright_messagebox")
    BottomRightMessageBoxSystem.On_add_battle_item_notify(itemid, count, MaxCount, type, can_into_depot)
  else
    LobbySystem.BattleItem = LobbySystem.BattleItem or {}
    LobbySystem.BattleItem.    LobbySystem.BattleItem.    LobbySystem.BattleItem.    LobbySystem.BattleItem.    local resItem = CDataTable.GetTableData("Item", itemid)
    if not MaxCount then
      LobbySystem.BattleItem.Describe = LocUtil.LocalizeResFormat("6519", count, resItem.ItemName)
    else
      LobbySystem.BattleItem.Describe = LocUtil.LocalizeResFormat("6520", resItem.ItemName, MaxCount)
    end
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_ADD_BATTLE_ITEM_NOTIFY)
  end
end
function LobbySystem.ShowBattleItemTip()
  log(bWriteLog and "LobbySystem.ShowBattleItemTip")
  if not (LobbySystem.BattleItem and LobbySystem.BattleItem.itemid) or tonumber(LobbySystem.BattleItem.itemid) <= 0 then
    log_warning(bWriteLog and "LobbySystem.ShowBattleItemTip no battle item. itemid = " .. tostring(LobbySystem.BattleItem and LobbySystem.BattleItem.itemid))
    return
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local count = LobbySystem.BattleItem.MaxCount
  local topLimit = true
  if not count then
    count = LobbySystem.BattleItem.count
    topLimit = false
  end
  local text = LocUtil.GetLocalizeResStr(4996)
  local itemId = LobbySystem.BattleItem.itemid
  local callback = function()
    FuncUtil.ItemJump(itemId)
  end
  local jumpInfo = {btnText = text, callback = callback}
  if LobbySystem.BattleItem.can_into_depot ~= 1 then
    jumpInfo = nil
  end
  local title = LocUtil.LocalizeResFormat(6719)
  RightPopSystem.ShowPopupWithNum(title, LobbySystem.BattleItem.itemid, count, topLimit, jumpInfo)
  LobbySystem.BattleItem = {}
end
function LobbySystem.CloseBattleItemTip()
  log(bWriteLog and "LobbySystem.CloseBattleItemTip")
  UIManager.CloseUI(UIManager.UI_Config.Common_RightBottom_Tip_UIBP)
  LobbySystem.BattleItem = {}
end
function LobbySystem.ShowFirstBannerByModuleId(ModuleId)
  local JumpUtils = require("client.logic.store.jump_utils")
  if not LobbySystem.activityBtnDisplayList then
    return
  end
  for i, v in ipairs(LobbySystem.activityBtnDisplayList) do
    if (JumpUtils.IsGameJumpUrl(v.JumpUrl) or JumpUtils.IsPanDoraJumpUrl(v.JumpUrl)) and string.find(v.JumpUrl, "module=" .. tostring(ModuleId)) then
      if i ~= 1 then
        local tmp = LobbySystem.activityBtnDisplayList[i]
        LobbySystem.activityBtnDisplayList[i] = LobbySystem.activityBtnDisplayList[1]
        LobbySystem.activityBtnDisplayList[1] = tmp
        LobbySystem.RecreateActivityBanner()
      end
      break
    end
  end
end
function LobbySystem.GetActivityJumpURLByModuleID(moduleID)
  if not LobbySystem.activityBtnDisplayList then
    return nil
  end
  local JumpUtils = require("client.logic.store.jump_utils")
  for i, v in ipairs(LobbySystem.activityBtnDisplayList) do
    if (JumpUtils.IsGameJumpUrl(v.JumpUrl) or JumpUtils.IsPanDoraJumpUrl(v.JumpUrl)) and string.find(v.JumpUrl, "module=" .. tostring(moduleID)) then
      return v.JumpUrl
    end
  end
  return nil
end
function LobbySystem.GetActivityDownLoadListByModuleID(moduleID, activityid)
  if not LobbySystem.activityBtnDisplayList or not moduleID then
    return {}
  end
  local bCheckState = moduleID and activityid
  log(bWriteLog and "xcc LobbySystem:GetActivityDownLoadListByModuleID moduleID:" .. tostring(moduleID) .. ", activityid:" .. tostring(activityid))
  local JumpUtils = require("client.logic.store.jump_utils")
  for i, data in ipairs(LobbySystem.activityBtnDisplayList) do
    local bAllow = bCheckState and string.find(data.JumpUrl, "activityid=" .. tostring(activityid)) or not bCheckState and string.find(data.JumpUrl, "module=" .. tostring(moduleID))
    if (JumpUtils.IsGameJumpUrl(data.JumpUrl) or JumpUtils.IsPanDoraJumpUrl(data.JumpUrl)) and bAllow then
      local Id = bCheckState and activityid or moduleID
      if LobbySystem.activityDownLoadList[Id] then
        log_tree("xcc LobbySystem:GetActivityDownLoadListByModuleID download:", LobbySystem.activityDownLoadList[Id])
        return LobbySystem.activityDownLoadList[Id]
      end
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local list = {}
      if data.BPPath and data.BPPath ~= "" then
        table.insert(list, data.BPPath)
        if moduleID ~= BP_ENUM_MODULE_BLACK_FRIDAY_MAIN then
          table.insert(list, PufferConst.ActivityAudioItemID)
        end
        log(bWriteLog and string.format("LobbySystem:GetActivityDownLoadListByModuleID BPPath:%s", tostring(data.BPPath)))
      end
      if data.Depends and data.Depends ~= "" then
        log(bWriteLog and string.format("LobbySystem:GetActivityDownLoadListByModuleID Depends:%s", tostring(data.Depends)))
        local StringUtil = require("common.string_util")
        local splitRet = StringUtil.Split(data.Depends, "|")
        for _, v in pairs(splitRet) do
          if tonumber(v) then
            table.insert(list, tonumber(v))
          elseif StringUtil.Ends(tostring(v), ".mp4") then
            table.insert(list, DataMgr.GetVideoDownloadPath(v))
          else
            table.insert(list, v)
          end
        end
      end
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local downloadList = PufferManager.GetDownloadListByModuleIDActivityID(moduleID, activityid)
      if next(downloadList) then
        for _, v in pairs(downloadList) do
          local bCanInsert = true
          for _, v2 in pairs(list) do
            if v == v2 then
              bCanInsert = false
              break
            end
          end
          if bCanInsert then
            table.insert(list, v)
          end
        end
      end
      LobbySystem.activityDownLoadList[Id] = list
      return LobbySystem.activityDownLoadList[Id]
    end
  end
  return {}
end
function LobbySystem.CreatLobbyAvatar()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if LobbySystem.NeedWaitCreatLobbyAvatar() then
    LobbySystem.WaitDepotInfo = true
    return
  end
  LobbySystem.WaitDepotInfo = nil
  LobbyAvatarManager.DestroyAllAvatar()
  TeamAvatarManager.ShowAllAvatar()
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  local logTimeCost = function()
    local endTime = getTime()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyAvatar][LobbySystem.CreatLobbyAvatar] bSync=true Pool=false Time:[%.3fms]", (endTime - startTime) / 1000))
  end
  local bDisableAsyncLoadLobbyPawn = HDmpveRemote.HDmpveRemoteConfigGetBool("bDisableAsyncLoadLobbyPawn", false)
  if bDisableAsyncLoadLobbyPawn then
    LobbyAvatarManager.CreateMyAvatar()
  else
    LobbyAvatarManager.CreateMyAvatarAsync()
  end
  logTimeCost()
end
function LobbySystem.NeedWaitCreatLobbyAvatar()
  if not LobbySystem.roleData.depot then
    return true
  end
  if LobbySystem.roleData.has_inherit_data then
    local logic_wardrobe_data_center = require("client.slua.logic.wardrobe.logic_wardrobe_data_center")
    local DataEntity = logic_wardrobe_data_center.GetWardrobeData(EWardrobeDataSource.InheritWardrobe)
    if not DataEntity.bInit then
      return true
    end
  end
  return false
end
function LobbySystem.ExposureReportWhenChangeScene(gamestatus)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  LobbySystem.previousStatus = LobbySystem.currentStatus
  LobbySystem.currentStatus = gamestatus
  if LobbySystem.previousStatus ~= GameStatus.Lobby and LobbySystem.currentStatus == GameStatus.Lobby then
    if LobbySystem.previousStatus == GameStatus.Login then
      LobbySystem.canReportOneExposure.banner = true
      LobbySystem.canReportOneExposure.store_tips = true
    else
      LobbySystem.canReportOneExposure.banner = false
      for _, v in pairs(LobbySystem.activityBtnDisplayList) do
        gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_LobbyBannerJump, gem_report_utils.GetReportParam(v.ID, v.JumpUrl, false))
        local TLogReasonStrTable = {
          event_name = gem_report_utils.SubEventName_LobbyBannerJump,
          banner_id = v.ID,
          language = Client.GetCurrentLanguage(),
          module = gem_report_utils.GetReportModule(v.JumpUrl),
          click = false
        }
        if string.find(v.JumpUrl, "activityid=") then
          local activityId = string.match(v.JumpUrl, "activityid=(%d+)")
          TLogReasonStrTable.activityid = tonumber(activityId)
        end
        local TLogReasonStr = json.encode(TLogReasonStrTable)
        ClientSendTLogReport(TLogEventDefine.ExposureEntrance, 0, TLogReasonStr)
        log(bWriteLog and "TLog new format, LobbySystem.ExposureReportWhenChangeScene, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
      end
      LobbySystem.canReportOneExposure.store_tips = true
    end
  end
end
function LobbySystem.ReportLobbyStayTime()
  if LobbySystem.currentStatus == GameStatus.Lobby then
    if LobbySystem.previousStatus ~= GameStatus.Lobby then
      LobbySystem.EnterLobbyTime = TimeUtil.GetServerTimeInSec()
      if LobbySystem.previousStatus == GameStatus.Fighting then
        LobbySystem.backLobbyNum = LobbySystem.backLobbyNum + 1
      else
        local uid, time, enter_num, back_num = LobbySystem.GetLobbyStaytimeInfo()
        if uid and time and 0 < time then
          local LobbyHandler = require("client.network.Protocol.LobbyHandler")
          LobbyHandler.send_lobby_stay_time_report_req(uid, enter_num or 0, back_num or 0, time)
          LobbySystem.SaveLobbyStaytimeInfo(0)
        end
      end
    end
  elseif LobbySystem.EnterLobbyTime > 0 then
    local time_interval = TimeUtil.GetServerTimeInSec() - LobbySystem.EnterLobbyTime
    local uid, time, enter_num, back_num = LobbySystem.GetLobbyStaytimeInfo()
    LobbySystem.SaveLobbyStaytimeInfo((time or 0) + time_interval)
    LobbySystem.EnterLobbyTime = 0
    if LobbySystem.currentStatus == GameStatus.Login then
      LobbySystem.enterLobbyNum = 0
      LobbySystem.backLobbyNum = 0
    end
  end
end
function LobbySystem.InitCrossDayHandle()
  LobbySystem.RemoveCrossDayTimer()
  local cur_time = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "InitCrossDayHandle \230\156\141\229\138\161\229\153\168\230\157\131\229\168\129\230\151\182\233\151\180\230\136\179\239\188\140\230\151\182\229\136\187 cur_time:" .. TimeUtil.GetServerTimeInSec())
  local temp_date = TimeUtil.OSDate("!*t", cur_time + 86400)
  log(bWriteLog and "InitCrossDayHandle UTC0\229\156\176\229\140\186\231\154\132\228\184\139\228\184\128\229\164\169\230\151\165\230\156\159 temp_date:" .. dump(temp_date))
  local diff_time = TimeUtil.GetTimeZone() * 3600
  log(bWriteLog and "InitCrossDayHandle \230\177\130\229\135\186\230\156\172\229\156\176\230\151\182\229\140\186\239\188\140\230\175\148\229\166\130\228\184\1568\239\188\140\229\128\188\228\184\1868*3600 diff_time:" .. diff_time)
  local next_day_UnixTime = TimeUtil.OSTime({
    year = temp_date.year,
    month = temp_date.month,
    day = temp_date.day,
    hour = 0
  })
  log(bWriteLog and "InitCrossDayHandle \230\177\130\229\135\186\230\156\172\229\156\176\230\151\182\233\151\180\228\184\139\228\184\128\229\164\169\233\155\182\231\130\185\231\154\132\230\151\182\233\151\180\230\136\179 next_day_time0:" .. next_day_UnixTime)
  local next_day_time0 = next_day_UnixTime + diff_time
  log(bWriteLog and "InitCrossDayHandle \230\177\130\229\135\186UTC0\228\184\139\228\184\128\229\164\169\233\155\182\231\130\185\231\154\132\230\151\182\233\151\180\230\136\179 next_day_time0:" .. next_day_time0)
  local gap_time = next_day_time0 - cur_time
  log(bWriteLog and "InitCrossDayHandle \230\177\130\229\135\186UTC0\229\136\176\233\155\182\231\130\185\231\154\132\229\128\146\232\174\161\230\151\182 gap_time:" .. gap_time)
  local interval = math.random(60)
  if 0 < interval + gap_time then
    local time_ticker = require("common.time_ticker")
    log(bWriteLog and "InitCrossDayHandle addtime:" .. interval + gap_time)
    log(bWriteLog and "xcc LobbySystem.InitCrossDayHandle startTime " .. tostring(TimeUtil.FormatTime_YMDHMS(cur_time, false)))
    log(bWriteLog and "xcc LobbySystem.InitCrossDayHandle endTime " .. tostring(TimeUtil.FormatTime_YMDHMS(cur_time + interval + gap_time, false)))
    LobbySystem.cross_day_timer = time_ticker.AddTimerOnce(interval + gap_time, LobbySystem.OnTimerNextDayByRandomDelay, false)
  end
  if 0 < gap_time then
    local time_ticker = require("common.time_ticker")
    log(bWriteLog and "InitCrossDayHandle addtime:" .. gap_time)
    log(bWriteLog and "accurate LobbySystem.InitCrossDayHandle startTime " .. tostring(TimeUtil.FormatTime_YMDHMS(cur_time, false)))
    log(bWriteLog and "accurate LobbySystem.InitCrossDayHandle endTime " .. tostring(TimeUtil.FormatTime_YMDHMS(cur_time + gap_time, false)))
    LobbySystem.cross_day_accurate_timer = time_ticker.AddTimerOnce(gap_time, function()
      local temp_date = TimeUtil.OSDate("!*t", TimeUtil.GetServerTimeInSec())
      if temp_date.wday == 2 then
        log(bWriteLog and "LobbyUI.OnTimerNextDayByRandomDelay, post event = EVENTID_NEXTWEEK_ZERO")
        EventSystem:postEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTWEEK_ZERO)
      end
    end)
  end
end
function LobbySystem.OnTimerNextDayByRandomDelay()
  LobbySystem.RemoveCrossDayTimer()
  local inBattle = GameStatus.IsInFightingNotSocialNotMainCityNotHome()
  if inBattle then
    local interval = math.random(60)
    local time_ticker = require("common.time_ticker")
    LobbySystem.cross_day_timer = time_ticker.AddTimerOnce(interval, LobbySystem.OnTimerNextDayByRandomDelay, false)
    return
  end
  log(bWriteLog and "LobbyUI.OnTimerNextDayByRandomDelay, post event = EVENTID_NEXTDAY_ZERO")
  EventSystem:postEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO)
end
function LobbySystem.RemoveCrossDayTimer()
  if LobbySystem.cross_day_timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(LobbySystem.cross_day_timer)
    LobbySystem.cross_day_timer = nil
  end
  if LobbySystem.cross_day_accurate_timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(LobbySystem.cross_day_accurate_timer)
    LobbySystem.cross_day_accurate_timer = nil
  end
end
function LobbySystem.GetLobbyStaytimeInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyStayTime)
  if cacheInfo and cacheInfo.stayTime then
    return cacheInfo.uid, cacheInfo.stayTime, cacheInfo.enterLobbyNum, cacheInfo.backLobbyNum
  end
  return nil, nil, nil, nil
end
function LobbySystem.SaveLobbyStaytimeInfo(seconds)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = {}
  info.stayTime = seconds
  info.uid = tonumber(DataMgr.roleData.uid)
  info.enterLobbyNum = LobbySystem.enterLobbyNum
  info.backLobbyNum = LobbySystem.backLobbyNum
  PlayerPrefsSystem.SaveTableToFile_N(info, PlayerPrefsSystem.ePlayerPrefsType.eLobbyStayTime)
end
function LobbySystem.OnSDKCallback(type, parameter, extraJson)
  log(bWriteLog and "LobbySystem.OnSDKCallback, type = " .. tostring(type) .. " parameter: " .. tostring(parameter) .. " json: " .. extraJson)
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  if type == SDKMacros.SDKCallBackType.SDK_CB_NET_TRACE then
    local TraceSystem = require("client.slua.logic.network_trace.logic_trace")
    TraceSystem.OnTraceCallback(parameter, extraJson)
  end
end
function LobbySystem.on_mtr_begin(destination, ttl, snt)
  log(bWriteLog and "LobbySystem.on_mtr_begin, host = " .. destination .. " TTL = " .. tostring(ttl) .. tostring(snt))
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  local TraceSystem = require("client.slua.logic.network_trace.logic_trace")
  TraceSystem.StartTrace(SDKMacros.TraceTrigger.Server, destination, ttl)
end
function LobbySystem.on_dalay_ban_text_rsp(msg)
  if msg == "delay-kick-out" then
    local title = LocUtil.GetLocalizeResStr(102012)
    local text = LocUtil.GetLocalizeResStr(24229)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, text)
  end
end
function LobbySystem.CheckUseNewGuide()
  if LobbySystem.CheckNewGuideSwitch() and LobbySystem.roleData.is_first_login then
    return true
  end
  return false
end
function LobbySystem.CheckUseWoWGuideSwitch()
  if Client and Client.IsDevelopment() and Client.IsFileExistByFileName("EnterWoWNewbie.txt") then
    return true
  end
  return LobbySystem.CheckOpen(95024)
end
function LobbySystem.CheckNewGuideSwitch()
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  if newbieGuideManager.GetDisableInEditor() and _G.IsEditor then
    return false
  end
  if newbieGuideManager.GetNewbieDebugSwitch() then
    return false
  end
  log(bWriteLog and "============>LobbySystem CheckNewGuideSwitch: " .. tostring(LobbySystem.newGuideSwitch))
  return LobbySystem.newGuideSwitch
end
function LobbySystem.CheckAreaGraySwitchOpend(nInSwitchId, nInRatio, sInArea)
  log(bWriteLog and "LobbySystem.GetAreaGreySwitch nInSwitchId = " .. nInSwitchId)
  local StringUtil = require("common.string_util")
  local roleData = LobbySystem.roleData
  if roleData.area_gray_switch ~= nil then
    log_tree("LobbySystem.CheckAreaGraySwitchOpend roleData.area_gray_switch = ", roleData.area_gray_switch)
    local tAreaGraySwitch = roleData.area_gray_switch[nInSwitchId]
    if tAreaGraySwitch then
      local nRatio = tAreaGraySwitch.ratio
      local sArea = tAreaGraySwitch.area
      local bInRatio = false
      local bInArea = false
      if nRatio == nil then
        bInRatio = true
        log(bWriteLog and "LobbySystem.GetAreaGreySwitch bInRatio = true, nRatio is nil")
      elseif nInRatio == nil then
        bInRatio = false
        log(bWriteLog and "LobbySystem.GetAreaGreySwitch bInRatio = false nInRatio is nil")
      else
        bInRatio = nInRatio < nRatio
        log(bWriteLog and "LobbySystem.GetAreaGreySwitch bInRatio = " .. tostring(bInRatio) .. " nInRatio = " .. nInRatio .. " nRatio = " .. nRatio)
      end
      if sArea == nil then
        bInArea = true
        log(bWriteLog and "LobbySystem.GetAreaGreySwitch bInArea = true, nRatio is nil")
      elseif sInArea == nil then
        bInArea = false
        log(bWriteLog and "LobbySystem.GetAreaGreySwitch bInArea = false sInArea is nil")
      else
        local tArea = StringUtil.Split(sArea, "|")
        for key, value in pairs(tArea) do
          if value == sInArea then
            bInArea = true
            log(bWriteLog and "LobbySystem.GetAreaGreySwitch bInArea = true found in area sInArea = " .. sInArea .. " sArea = " .. sInArea)
            break
          end
        end
      end
      return bInRatio and bInArea
    else
      log(bWriteLog and "LobbySystem.GetAreaGreySwitch tAreaGraySwitch is nil return true")
      return true
    end
  else
    log(bWriteLog and "LobbySystem.GetAreaGreySwitch area_gray_switch is nil return true")
    return true
  end
end
function LobbySystem.ShowIsolationBanMsg(_, new_label, mail_id, expire_info, is_flag_visible, need_notify_player, cb_ext_params)
  local tip = ""
  local arg
  if not DataMgr.roleData.mil_info then
    DataMgr.roleData.mil_info = {}
  end
  DataMgr.roleData.mil_info.label = new_label
  if not DataMgr.roleData.mil_info.ext_info then
    DataMgr.roleData.mil_info.ext_info = {}
  end
  DataMgr.roleData.mil_info.expire_time = expire_info.expire_time
  DataMgr.roleData.mil_info.ext_info.expire_time = expire_info.expire_time
  DataMgr.roleData.mil_info.ext_info.remaining_time = expire_info.remaining_time
  DataMgr.roleData.mil_info.ext_info.  DataMgr.roleData.mil_info.  if expire_info.expire_type == 0 then
    local time = expire_info.expire_time
    if time then
      arg = TimeUtil.FormatTime_YMDHMS(time)
    end
  end
  local remainTime = expire_info.remaining_time
  if remainTime then
    arg = TimeUtil.FormatCountDownTime_DHMS(remainTime, 1)
  end
  if arg then
    tip = LocUtil.LocalizeResFormat(mail_id, arg)
  else
    tip = LocUtil.GetLocalizeResStr(mail_id)
  end
  if new_label == 2 and is_flag_visible == 1 and need_notify_player then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    log(bWriteLog and "LobbySystem.ShowIsolationBanMsg cb_ext_params = " .. tostring(cb_ext_params))
    log(bWriteLog and "LobbySystem.ShowIsolationBanMsg appeal_switch = " .. tostring(cb_ext_params.appeal_switch))
    if PublishRegionMacros.IsBLUEHOLE() or cb_ext_params and cb_ext_params.appeal_switch then
      MatchSystem.ShowNewObserveTips(tip)
    else
      MatchSystem.ShowObserveTips(tip)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_MAILINFO)
  log(bWriteLog and "ShowIsolationBanMsg new_label: " .. tostring(new_label) .. " mail_id: " .. tostring(mail_id) .. " expire_info: " .. tostring(expire_info))
end
function LobbySystem.ShowIsolationTeamChangeNotify(request_mode, target_mode)
  log(bWriteLog and "request_mode: " .. tostring(request_mode) .. " target_mode: " .. tostring(target_mode))
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local filterInfo = logic_mode_selection:GetFilterInfo()
  local playerContentText = {
    [1] = 993048,
    [2] = 993049,
    [3] = 8800027,
    [4] = 993050,
    [5] = 8800028,
    [6] = 8800029,
    [7] = 8800030,
    [8] = 993098
  }
  local playerNumText = LocUtil.LocalizeResFormat(playerContentText[filterInfo.teamNum])
  local perspectText = LocUtil.LocalizeResFormat(filterInfo.perspective)
  local content = LocUtil.LocalizeResFormat(31200, perspectText, playerNumText)
  local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
  noticeSystem.RemoveAllNotice()
  ShowNotice(content)
  local title = LocUtil.GetLocalizeResStr(101001)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, LocUtil.GetLocalizeResStr(29114))
end
function LobbySystem.UpdateServerTimeInSec()
  local TimeUtil = require("client.common.time_util")
  local ServerTimeInSec = math.floor(TimeUtil.GetServerTimeInSec())
  print(bWriteLog and "LobbySystem.GetServerTimeInSec ServerTimeInSec: " .. tostring(ServerTimeInSec))
  local ScriptHelperClient = import("ScriptHelperClient")
  ScriptHelperClient.SetServerTimeInSec(ServerTimeInSec)
  return ServerTimeInSec
end
return LobbySystem