local ClientEVOConfig = {
  bInit = false,
  bLevelStreamingBackEndEnable = false,
  SavedLevelStreamingRemoveLevelTimeLimit = 5,
  SavedLevelStreamingOptSpecialApplyWorldOffsetActorNum = 1,
  SavedLevelStreamingOptSpecialHeavyRegComponentNum = 1,
  SavedLevelStreamingOptSpecialRegComponentTimeLimit = 3,
  SavedLevelStreamingOptSpecialUnRegComponentTimeLimit = 3,
  SavedLevelStreamingOptSpecialHeavyUnRegComponentNum = 1,
  SavedLevelStreamingOptSpecialRouteActorEndPlayGranularity = 10,
  SavedLevelStreamingOptSpecialComponentsRegistrationGranularity = 10,
  SavedLevelStreamingOptSpecialHISMPhysicBodyIncrementClearNum = 150,
  SavedLevelStreamingOptSpecialHeavyActorBeginPlayNum = 0,
  SavedLevelStreamingOptSpecialRouteActorInitializeGranularity = 3,
  SavedLevelStreamingOptSpecialLimitPreformStep = 1,
  SavedLevelStreamingOptSpecialSortLevlFromPriority = 1,
  SavedLevelStreamingOptSpecialIncrementalUnregisterComponents = 1,
  SavedLevelStreamingOptSpecialMaxUnLoadLevelGCMemoryThresholds = 50000,
  SavedLevelStreamingOptSpecialBodyStreamingCountPerTimeLimit = 20,
  SavedLevelStreamingOptSpecialBodyStreamingTimeLimit = 5,
  SavedSuperFrameEnableUpdateLevelStreamingInUpdateCamera = 0,
  bTickAsyncLoadingSetInFighting = false,
  bTickAsyncLoadingBackEndEnable = false,
  SavedTickAsyncLoadingOptSpecialMaxHeavyObjectPostLoadCost = 32768,
  SavedTickAsyncLoadingOptSpecialIncrementalUpdateDistanceVolumeGranularity = 100,
  SavedTickAsyncLoadingOptSpecialPostLoadThreadEnabled = 1,
  SavedTickAsyncLoadingOptSpecialTexCubeMaxSizeLimit = 32,
  bEnterBorderland = false,
  BorderlandModList = {
    2301,
    2302,
    2303,
    2304,
    2305,
    2306,
    2311,
    2312,
    2313,
    2314,
    2315,
    2316,
    90016,
    90017,
    90018,
    90019,
    90020,
    90021
  },
  bEnterTMod = false,
  TModList = {
    23001,
    23004,
    23005,
    23006,
    23007,
    23008,
    23009,
    23010,
    23012,
    23013,
    23104,
    23015,
    23016,
    23017,
    23018,
    23019,
    23020,
    91067,
    91068,
    91069,
    91070,
    91071,
    91072,
    91073,
    91074
  },
  bEnterSingleMode = false,
  SingModlList = {
    24005,
    24006,
    24007,
    24008,
    24009,
    24010
  },
  SavedUseLowFakeLandScape = 0,
  bUseLowFakeLandScapeBackEndEnable = false,
  bEnableSlateGICloud = false,
  bEnableInvalidationPanelsCloud = false,
  bDisableNestedInvalidationBoxCloud = false,
  bEnableUIDynamicBatch = false,
  bEnableSlateThrottle = false,
  bEnableSlateLayoutCache = false,
  bEnableSlateLayoutCacheBackendValue = false,
  EnableNewObjectPoolConfigValue = nil,
  NewObjectPoolGCConfigValue = nil,
  TextureMipOffsetbackUp = -1,
  bEnableIOSPSOCache = false,
  NewObjectPoolAvailableMod = {
    BaseMod = true,
    Mecha = true,
    Atlantis = true,
    NewbieGame = true,
    TPlanPVE = true,
    CreativeBase = true,
    HeavyWeapon = true,
    Halloween4 = true,
    IceWorld3 = true,
    EasternRealm = true,
    Neon = true,
    ZNQ7th = true,
    SteamTrain = true,
    Egypt2 = true,
    TDM = false
  },
  LayoutCacheAvailableMod = {
    BaseMod = true,
    SteamTrain = true,
    TPlanPVE = true,
    PlanTF = true,
    Halloween5 = true,
    Escape = true,
    IceWorld4 = true,
    ZNQ8th = true
  },
  InvalidationPanelsAvailableMod = {TDM = false},
  SlateGIAvailableMod = {
    CreativeBase = false,
    MainCity = false,
    SocialIsland = false,
    PlanPH = false,
    PlanCH = false,
    SingleTraining = false
  },
  bNewObjectPoolGCOptimizationEnable = false,
  bNewObjectPoolDefferedPhysicsState = false,
  bEnable400AnimationOptimization = false,
  bEnableNotRenderedParallelUpdateBackEnd = false,
  bEnableNotRenderedParallelUpdateApplied = false,
  bEnableRefreshBonesTickAnimationOptBackEnd = false,
  bEnableRefreshBonesTickAnimationOptApplied = false,
  DefaultJankCollectionTimeThresholdOnIni = 0,
  DefaultSleepTimeThodOnIni = 5.0E-4,
  DefaultSleepSlackTimeOnIni = 5.0E-4,
  CurrentWorldName = "",
  LastWorldName = "",
  CurrentModID = 0,
  SlateTickDownWhitList = {
    Baltic_Main = 1,
    FourMaps_Main = 1,
    PUBG_Desert = 1,
    DihorOtok_Main = 1,
    PUBG_Savage_Main = 1
  },
  SlateThrottleWhiteList = {Baltic_Main = 1, UEDPIE_1_Baltic_Main = 1},
  bUseSlateThrottleWhiteList = true,
  SlateGIThrottleWhiteList = {Baltic_Main = 1, UEDPIE_1_Baltic_Main = 1},
  bUseSlateGIThrottleWhiteList = true,
  bLevelEnd = false,
  bCallLoadingUIOpend = false,
  backupHLODScale = 1.0,
  CurrentBattleFPSLevel = 1,
  CollectorTimerID = 0,
  DefaultGCSweepTimeOnIni = 0,
  EnableGCSweepTimeModifiy_GCloud = 0,
  CloseGCWhitList = {
    AR_Library = 1,
    TD_FoolsDayBigHead_Factory = 1,
    TD_Factory_Depot_Main = 1,
    HP_City_Main = 1,
    TD_Ruins_Half = 1,
    TD_RushHour = 1,
    TD_Santorini = 1
  },
  BackUpbUseNewHole = -1,
  BakcUpNumVisibleComponents = 0,
  BackGrassUpdateIntervel = 5,
  bFirstEnterLobby = true,
  bOpenDevLog = false,
  ManagedTickSysFlagBackEnd = 0,
  bEnableActorSpawnQueueCloud = false
}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
function ClientEVOConfig.IsSuperFrameScaleFactorDownEnable()
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local TCDeviceLevel = Client.GetTCDeviceLevel()
  local EnableSuperFrameDownScaleFactor = Client.HDmpveRemoteConfigGetInt("EnableSuperFrameDownScaleFactor", 0)
  return 0 < EnableSuperFrameDownScaleFactor and platformName == DevicePlatformNameMacros.Android and (TCDeviceLevel == 5 or TCDeviceLevel == 6)
end
function ClientEVOConfig.Init()
  if ClientEVOConfig.bInit == true then
    return
  end
  ClientEVOConfig.bInit = true
  ClientEVOConfig.CollectorTimerID = 0
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_PRE_BATTLE_RESULT, ClientEVOConfig.HandleOnPreBattleResult)
  EventSystem:registEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_START_PHASE, ClientEVOConfig.HandleOnBattleResultStartPase)
  EventSystem:registEvent(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_END_PHASE, ClientEVOConfig.HandleOnBattleResultEndPase)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_PRE_BEGIN, ClientEVOConfig.HandleOnLoadingPreBegin)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, ClientEVOConfig.HandleOnLoadingEnd)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  ClientEVOConfig.DefaultJankCollectionTimeThresholdOnIni = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("Jank.CollectionTimeThreshold")
  ClientEVOConfig.DefaultSleepTimeThodOnIni = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("Engine.GSleepTimeThod")
  ClientEVOConfig.DefaultSleepSlackTimeOnIni = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("Engine.GSleepSlackTimeThod")
  ClientEVOConfig.backupHLODScale = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("r.HLOD.DistanceScale")
  ClientEVOConfig.BackGrassUpdateIntervel = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.PowerOptSepcial.LandScapeSeries.GrassUpdateInterval")
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  local settingConfig = LogicSettingGraphics.GetSettingConfig()
  ClientEVOConfig.CurrentBattleFPSLevel = settingConfig.BattleFPS
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if ClientEVOConfig.EnableNewObjectPoolConfigValue == nil then
    ClientEVOConfig.EnableNewObjectPoolConfigValue = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("g.EnableNewObjectPool")
    log_shipping_client("ClientEVOConfig.EnableNewObjectPoolConfigValue: " .. tostring(ClientEVOConfig.EnableNewObjectPoolConfigValue))
  end
  if HDmpveRemote.HDmpveRemoteConfigGetInt("DisablePreloadInLobby", 0) == 1 then
    ClientEVOConfig.NewObjectPoolAvailableMod.NoviceGuidance = false
    ClientEVOConfig.NewObjectPoolAvailableMod.MainCity = false
    ClientEVOConfig.NewObjectPoolAvailableMod.PlanPH = false
  end
end
function ClientEVOConfig.ShouldEnableNotRenderedParallelUpdate()
  return ClientEVOConfig.bEnableNotRenderedParallelUpdateBackEnd and GameStatus.IsInFightingNotSocialNotMainCityNotHome()
end
function ClientEVOConfig.ToggleNotRenderedParallelUpdate(bEnable)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local currentStatus = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("a.EnableNotRenderedParallelUpdate") or 0
  local bApplied = currentStatus == 1
  ClientEVOConfig.bEnableNotRenderedParallelUpdateApplied = bApplied
  if bEnable == bApplied then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local value = bEnable and 1 or 0
  GameInstance:ExecuteCMD("a.IgnoreEvaluationPhaseSkipped", value)
  GameInstance:ExecuteCMD("a.EnableNotRenderedParallelUpdate", value)
  GameInstance:ExecuteCMD("a.SkipFlipWhenNoEvaluation", value)
  GameInstance:ExecuteCMD("a.UseSymmetricSwapForParallelEval", 0)
  ClientEVOConfig.bEnableNotRenderedParallelUpdateApplied = bEnable
  log_shipping_client(string.format("[AnimationOpt] EnableNotRenderedParallelUpdateApplied==%s", tostring(bEnable)))
end
function ClientEVOConfig.RefreshNotRenderedParallelUpdate()
  ClientEVOConfig.ToggleNotRenderedParallelUpdate(ClientEVOConfig.ShouldEnableNotRenderedParallelUpdate())
end
function ClientEVOConfig.ShouldEnableRefreshBonesTickAnimationOpt()
  return ClientEVOConfig.bEnableRefreshBonesTickAnimationOptBackEnd and GameStatus.IsInFightingNotSocialNotMainCityNotHome()
end
function ClientEVOConfig.ToggleRefreshBonesTickAnimationOpt(bEnable)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local currentStatus = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("a.PrimeDormantSubInstanceUpdateCounter") or 0
  local bApplied = currentStatus ~= 0
  ClientEVOConfig.bEnableRefreshBonesTickAnimationOptApplied = bApplied
  if bEnable == bApplied then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local value = bEnable and 1 or 0
  GameInstance:ExecuteCMD("a.PrimeDormantSubInstanceUpdateCounter", value)
  ClientEVOConfig.bEnableRefreshBonesTickAnimationOptApplied = bEnable
  log_shipping_client(string.format("[AnimationOpt] EnableRefreshBonesTickAnimationOptApplied==%s", tostring(bEnable)))
end
function ClientEVOConfig.RefreshBonesTickAnimationOpt()
  ClientEVOConfig.ToggleRefreshBonesTickAnimationOpt(ClientEVOConfig.ShouldEnableRefreshBonesTickAnimationOpt())
end
function ClientEVOConfig.Optimize_Android_32_OOM()
  local so_version = Client.GetAndroidSOVersion()
  if so_version ~= 32 or Client.GetMemorySize() >= 4 then
    return
  end
  if HDmpveRemote.HDmpveRemoteConfigGetInt("Android_Performance_32_OOM", 0) == 1 then
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    GameInstance:ExecuteCMD("g.EnableNewObjectPool", 0)
  end
end
function ClientEVOConfig.Optimize_Android_Performance_Swap_2G()
  local mem = Client.GetMemorySize()
  if mem ~= 2 then
    return
  end
  local enable = HDmpveRemote.HDmpveRemoteConfigGetInt("Android_Performance_Swap", 0)
  if enable == 0 then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("s.ActorChanCleanUpOptSpecial.Enable", 0)
  GameInstance:ExecuteCMD("am.EnablePreloadAnimInGame", 0)
  GameInstance:ExecuteCMD("p.LowMemorySizeConfig", 5)
  GameInstance:ExecuteCMD("diy.SetDecalBakingRTSize", 256)
  GameInstance:ExecuteCMD("Engine.TickGCWhenTravelWorld", 1)
  GameInstance:ExecuteCMD("r.LevelStreamingDistanceOffset", -15000)
end
function ClientEVOConfig.Optimize_Android_Performance_Swap_3G()
  local mem = Client.GetMemorySize()
  if mem ~= 3 then
    return
  end
  local enable = HDmpveRemote.HDmpveRemoteConfigGetInt("Android_Performance_Swap", 0)
  if enable == 0 then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("r.Streaming.MaxTempMemoryAllowed", 4)
  GameInstance:ExecuteCMD("r.Streaming.DropMips", 2)
  GameInstance:ExecuteCMD("s.ActorChanCleanUpOptSpecial.Enable", 0)
  GameInstance:ExecuteCMD("am.EnablePreloadAnimInGame", 0)
  GameInstance:ExecuteCMD("p.LowMemorySizeConfig", 0)
  GameInstance:ExecuteCMD("diy.SetDecalBakingRTSize", 256)
  GameInstance:ExecuteCMD("Engine.TickGCWhenTravelWorld", 1)
  GameInstance:ExecuteCMD("r.LevelStreamingDistanceOffset", -15000)
end
function ClientEVOConfig.Optimize_Android_Performance_Swap_4G()
  local mem = Client.GetMemorySize()
  if mem ~= 4 then
    return
  end
  local enable = HDmpveRemote.HDmpveRemoteConfigGetInt("Android_Performance_Swap4", 0)
  if enable == 0 then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("r.Streaming.MaxTempMemoryAllowed", 4)
  GameInstance:ExecuteCMD("r.Streaming.DropMips", 2)
  GameInstance:ExecuteCMD("s.ActorChanCleanUpOptSpecial.Enable", 0)
  GameInstance:ExecuteCMD("am.EnablePreloadAnimInGame", 0)
  GameInstance:ExecuteCMD("diy.SetDecalBakingRTSize", 256)
  GameInstance:ExecuteCMD("Engine.TickGCWhenTravelWorld", 1)
  GameInstance:ExecuteCMD("r.LevelStreamingDistanceOffset", -1500)
end
function ClientEVOConfig.DisableLevelStreamingOpt()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local GameplayStatics = import("GameplayStatics")
  GameplayStatics.FlushLevelStreaming(GameInstance)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  ClientEVOConfig.SavedLevelStreamingRemoveLevelTimeLimit = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingRemoveLevelTimeLimit")
  ClientEVOConfig.SavedLevelStreamingOptSpecialApplyWorldOffsetActorNum = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("s.LevelStreamingOptSpecial.ApplyWorldOffsetActorNum")
  ClientEVOConfig.SavedLevelStreamingOptSpecialHeavyRegComponentNum = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.HeavyRegComponentNum")
  ClientEVOConfig.SavedLevelStreamingOptSpecialRegComponentTimeLimit = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.RegComponentTimeLimit")
  ClientEVOConfig.SavedLevelStreamingOptSpecialUnRegComponentTimeLimit = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.UnRegComponentTimeLimit")
  ClientEVOConfig.SavedLevelStreamingOptSpecialHeavyUnRegComponentNum = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.HeavyUnRegComponentNum")
  ClientEVOConfig.SavedLevelStreamingOptSpecialRouteActorEndPlayGranularity = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.RouteActorEndPlayGranularity")
  ClientEVOConfig.SavedLevelStreamingOptSpecialComponentsRegistrationGranularity = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.ComponentsRegistrationGranularity")
  ClientEVOConfig.SavedLevelStreamingOptSpecialHISMPhysicBodyIncrementClearNum = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.HISMPhysicBodyIncrementClearNum")
  ClientEVOConfig.SavedLevelStreamingOptSpecialHeavyActorBeginPlayNum = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.HeavyActorBeginPlayNum")
  ClientEVOConfig.SavedLevelStreamingOptSpecialRouteActorInitializeGranularity = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.RouteActorInitializeGranularity")
  ClientEVOConfig.SavedLevelStreamingOptSpecialLimitPreformStep = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.LimitPreformStep")
  ClientEVOConfig.SavedLevelStreamingOptSpecialSortLevlFromPriority = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.SortLevlFromPriority")
  ClientEVOConfig.SavedLevelStreamingOptSpecialIncrementalUnregisterComponents = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.IncrementalUnregisterComponents")
  ClientEVOConfig.SavedLevelStreamingOptSpecialMaxUnLoadLevelGCMemoryThresholds = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.MaxUnLoadLevelGCMemoryThresholds")
  ClientEVOConfig.SavedLevelStreamingOptSpecialBodyStreamingCountPerTimeLimit = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.BodyStreamingCountPerTimeLimit")
  ClientEVOConfig.SavedLevelStreamingOptSpecialBodyStreamingTimeLimit = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.LevelStreamingOptSpecial.BodyStreamingTimeLimit")
  ClientEVOConfig.SavedSuperFrameEnableUpdateLevelStreamingInUpdateCamera = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.SuperFrame.EnableUpdateLevelStreamingInUpdateCamera")
  GameInstance:ExecuteCMD("s.LevelStreamingRemoveLevelTimeLimit", 99)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.ApplyWorldOffsetActorNum", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HeavyRegComponentNum", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.RegComponentTimeLimit", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.UnRegComponentTimeLimit", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HeavyUnRegComponentNum", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.RouteActorEndPlayGranularity", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.ComponentsRegistrationGranularity", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HISMPhysicBodyIncrementClearNum", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HeavyActorBeginPlayNum", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.RouteActorInitializeGranularity", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.LimitPreformStep", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.SortLevlFromPriority", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.IncrementalUnregisterComponents", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.MaxUnLoadLevelGCMemoryThresholds", 0)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.BodyStreamingCountPerTimeLimit", 999999)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.BodyStreamingTimeLimit", 0)
  GameInstance:ExecuteCMD("r.SuperFrame.EnableUpdateLevelStreamingInUpdateCamera", 0)
end
function ClientEVOConfig.EnableLevelStreamingOpt()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local GameplayStatics = import("GameplayStatics")
  GameplayStatics.FlushLevelStreaming(GameInstance)
  GameInstance:ExecuteCMD("s.LevelStreamingRemoveLevelTimeLimit", ClientEVOConfig.SavedLevelStreamingRemoveLevelTimeLimit)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.ApplyWorldOffsetActorNum", ClientEVOConfig.SavedLevelStreamingOptSpecialApplyWorldOffsetActorNum)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HeavyRegComponentNum", ClientEVOConfig.SavedLevelStreamingOptSpecialHeavyRegComponentNum)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.RegComponentTimeLimit", ClientEVOConfig.SavedLevelStreamingOptSpecialRegComponentTimeLimit)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.UnRegComponentTimeLimit", ClientEVOConfig.SavedLevelStreamingOptSpecialUnRegComponentTimeLimit)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HeavyUnRegComponentNum", ClientEVOConfig.SavedLevelStreamingOptSpecialHeavyUnRegComponentNum)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.RouteActorEndPlayGranularity", ClientEVOConfig.SavedLevelStreamingOptSpecialRouteActorEndPlayGranularity)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.ComponentsRegistrationGranularity", ClientEVOConfig.SavedLevelStreamingOptSpecialComponentsRegistrationGranularity)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HISMPhysicBodyIncrementClearNum", ClientEVOConfig.SavedLevelStreamingOptSpecialHISMPhysicBodyIncrementClearNum)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.HeavyActorBeginPlayNum", ClientEVOConfig.SavedLevelStreamingOptSpecialHeavyActorBeginPlayNum)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.RouteActorInitializeGranularity", ClientEVOConfig.SavedLevelStreamingOptSpecialRouteActorInitializeGranularity)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.LimitPreformStep", ClientEVOConfig.SavedLevelStreamingOptSpecialLimitPreformStep)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.SortLevlFromPriority", ClientEVOConfig.SavedLevelStreamingOptSpecialSortLevlFromPriority)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.IncrementalUnregisterComponents", ClientEVOConfig.SavedLevelStreamingOptSpecialIncrementalUnregisterComponents)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.MaxUnLoadLevelGCMemoryThresholds", ClientEVOConfig.SavedLevelStreamingOptSpecialMaxUnLoadLevelGCMemoryThresholds)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.BodyStreamingCountPerTimeLimit", ClientEVOConfig.SavedLevelStreamingOptSpecialBodyStreamingCountPerTimeLimit)
  GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.BodyStreamingTimeLimit", ClientEVOConfig.SavedLevelStreamingOptSpecialBodyStreamingTimeLimit)
  GameInstance:ExecuteCMD("r.SuperFrame.EnableUpdateLevelStreamingInUpdateCamera", ClientEVOConfig.SavedSuperFrameEnableUpdateLevelStreamingInUpdateCamera)
end
function ClientEVOConfig.DisableTickAsyncLoadingOpt()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local GameplayStatics = import("GameplayStatics")
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  ClientEVOConfig.SavedTickAsyncLoadingOptSpecialMaxHeavyObjectPostLoadCost = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.TickAsyncLoadingOptSpecial.MaxHeavyObjectPostLoadCost")
  ClientEVOConfig.SavedTickAsyncLoadingOptSpecialIncrementalUpdateDistanceVolumeGranularity = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.TickAsyncLoadingOptSpecial.IncrementalUpdateDistanceVolumeGranularity")
  ClientEVOConfig.SavedTickAsyncLoadingOptSpecialPostLoadThreadEnabled = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.TickAsyncLoadingOptSpecial.PostLoadThreadEnabled")
  ClientEVOConfig.SavedTickAsyncLoadingOptSpecialTexCubeMaxSizeLimit = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.TickAsyncLoadingOptSpecial.TexCubeMaxSizeLimit")
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.MaxHeavyObjectPostLoadCost", 0)
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.IncrementalUpdateDistanceVolumeGranularity", 0)
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.PostLoadThreadEnabled", 0)
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.TexCubeMaxSizeLimit", 0)
end
function ClientEVOConfig.EnableTickAsyncLoadingOpt()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local GameplayStatics = import("GameplayStatics")
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.MaxHeavyObjectPostLoadCost", ClientEVOConfig.SavedTickAsyncLoadingOptSpecialMaxHeavyObjectPostLoadCost)
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.IncrementalUpdateDistanceVolumeGranularity", ClientEVOConfig.SavedTickAsyncLoadingOptSpecialIncrementalUpdateDistanceVolumeGranularity)
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.PostLoadThreadEnabled", ClientEVOConfig.SavedTickAsyncLoadingOptSpecialPostLoadThreadEnabled)
  GameInstance:ExecuteCMD("s.TickAsyncLoadingOptSpecial.TexCubeMaxSizeLimit", ClientEVOConfig.SavedTickAsyncLoadingOptSpecialTexCubeMaxSizeLimit)
end
function ClientEVOConfig.OpenDevLog()
  ClientEVOConfig.bOpenDevLog = true
  local STExtraGameInstance = import("STExtraGameInstance")
  STExtraGameInstance.GetInstance():ExecuteCMD("log.CloseLogOnTestOrShipping", 0)
  local PandoraAdapter = require("client.slua.logic.Pandora.pandora_v2_adapter")
  PandoraAdapter:SetDebugLog(true)
  local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  gamelet_interface:EnableLog(true)
end
function ClientEVOConfig.OnPreBackEndSwitcherSet(SmartBearerSwitcher, SuperFrameSwitcher, ClientBackEndSwitcherA, ClientBackEndSwitcherB, ClientBackEndSwitcherC, PostLoadSwitcher)
  local GameplayStatics = import("GameplayStatics")
  if SuperFrameSwitcher and SuperFrameSwitcher & 16777216 ~= 0 then
    ClientEVOConfig.DisableTickAsyncLoadingOpt()
    ClientEVOConfig.bTickAsyncLoadingBackEndEnable = true
  end
  if SuperFrameSwitcher and SuperFrameSwitcher & 8388608 ~= 0 then
    ClientEVOConfig.bLevelStreamingBackEndEnable = true
  end
  if ClientBackEndSwitcherC and ClientBackEndSwitcherC & 2 ~= 0 then
    ClientEVOConfig.bUseLowFakeLandScapeBackEndEnable = true
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableSlateGlobalInvalidation", false) == true then
    ClientEVOConfig.bEnableSlateGICloud = true
    log_shipping_client("[SlateGI] Cloud Switch: EnableSlateGlobalInvalidation==true")
  else
    ClientEVOConfig.bEnableSlateGICloud = false
    log_shipping_client("[SlateGI] Cloud Switch: EnableSlateGlobalInvalidation==false")
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableInvalidationPanels", false) == true or IsEditor then
    ClientEVOConfig.bEnableInvalidationPanelsCloud = true
    log_shipping_client("[SlateGI] Cloud Switch: EnableInvalidationPanels==true")
  else
    ClientEVOConfig.bEnableInvalidationPanelsCloud = false
    log_shipping_client("[SlateGI] Cloud Switch: EnableInvalidationPanels==false")
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("DisableNestedInvalidationBox", false) == true then
    ClientEVOConfig.bDisableNestedInvalidationBoxCloud = true
    log_shipping_client("[SlateGI] Cloud Switch: DisableNestedInvalidationBox==true")
  else
    ClientEVOConfig.bDisableNestedInvalidationBoxCloud = false
    log_shipping_client("[SlateGI] Cloud Switch: DisableNestedInvalidationBox==false")
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableActorSpawnQueue", false) == true then
    ClientEVOConfig.bEnableActorSpawnQueueCloud = true
    log_shipping_client("[ActorSpawnQueue] Cloud Switch: EnableActorSpawnQueue==true")
  end
  if ClientBackEndSwitcherA and ClientBackEndSwitcherA & 32 ~= 0 then
    ClientEVOConfig.bEnableUIDynamicBatch = true
    log(bWriteLog and "[UIDynamicBatch] ClientBackEndSwitcherA UIDynamicBatch==5")
  end
  if ClientBackEndSwitcherA and ClientBackEndSwitcherA & 32768 ~= 0 then
    ClientEVOConfig.bEnableSlateLayoutCacheBackendValue = true
    ClientEVOConfig.bEnableSlateLayoutCache = true
    log(bWriteLog and "[UIDynamicBatch] ClientBackEndSwitcherA SlateLayoutCache==15")
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if ClientBackEndSwitcherB and ClientBackEndSwitcherB & 2048 ~= 0 and GameInstance:IsIOSVersionAbove14() then
    ClientEVOConfig.bEnableIOSPSOCache = true
    log(bWriteLog and "[IOSPSOCache] ClientBackEndSwitcherB IOSPSOCache==11")
  end
  local EnableSlateThrottleFromRemote = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableSlateThrottle", 0)
  local deviceModel = string.lower(Client.GetDeviceModel() or "")
  local isIpad = deviceModel:sub(1, 4) == "ipad"
  if 0 < EnableSlateThrottleFromRemote and not isIpad then
    GameInstance:ExecuteCMD("Slate.EnableThrottle", 1)
    ClientEVOConfig.bUseSlateThrottleWhiteList = EnableSlateThrottleFromRemote == 1
    log_shipping_client(string.format("[UIThrottle] EnableSlateThrottle==true bUseSlateThrottleWhiteList==%s", tostring(ClientEVOConfig.bUseSlateThrottleWhiteList)))
  else
    GameInstance:ExecuteCMD("Slate.EnableThrottle", 0)
    log_shipping_client("[UIThrottle] EnableSlateThrottle==false")
  end
  local EnableSlateGIThrottleFromRemote = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableSlateGIThrottle", 0)
  if 0 < EnableSlateGIThrottleFromRemote and not isIpad then
    GameInstance:ExecuteCMD("Slate.EnableGIThrottle", 1)
    ClientEVOConfig.bUseSlateGIThrottleWhiteList = EnableSlateGIThrottleFromRemote == 1
    log_shipping_client(string.format("[SlateGIThrottle] EnableSlateGIThrottle==true bUseSlateGIThrottleWhiteList==%s", tostring(ClientEVOConfig.bUseSlateGIThrottleWhiteList)))
  else
    GameInstance:ExecuteCMD("Slate.EnableGIThrottle", 0)
    log_shipping_client("[SlateGIThrottle] EnableSlateGIThrottle==false")
  end
  local EnableNotRenderedParallelUpdate = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableNotRenderedParallelUpdate", 0)
  ClientEVOConfig.bEnableNotRenderedParallelUpdateBackEnd = 0 < EnableNotRenderedParallelUpdate
  log_shipping_client(string.format("[AnimationOpt] EnableNotRenderedParallelUpdateBackEnd==%s", tostring(ClientEVOConfig.bEnableNotRenderedParallelUpdateBackEnd)))
  ClientEVOConfig.RefreshNotRenderedParallelUpdate()
  local EnableRefreshBonesTickAnimationOpt = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableRefreshBonesTickAnimationOpt", 0)
  ClientEVOConfig.bEnableRefreshBonesTickAnimationOptBackEnd = 0 < EnableRefreshBonesTickAnimationOpt
  log_shipping_client(string.format("[AnimationOpt] EnableRefreshBonesTickAnimationOptBackEnd==%s", tostring(ClientEVOConfig.bEnableRefreshBonesTickAnimationOptBackEnd)))
  ClientEVOConfig.RefreshBonesTickAnimationOpt()
  if ClientBackEndSwitcherC and ClientBackEndSwitcherC & 16 ~= 0 then
    ClientEVOConfig.bNewObjectPoolGCOptimizationEnable = true
  end
  if ClientBackEndSwitcherC and ClientBackEndSwitcherC & 64 ~= 0 then
    ClientEVOConfig.bNewObjectPoolDefferedPhysicsState = true
  end
  if ClientBackEndSwitcherC and ClientBackEndSwitcherC & 512 ~= 0 then
    ClientEVOConfig.bEnable400AnimationOptimization = true
  end
  log_shipping_client("ClientEVOConfig.OnPreBackEndSwitcherSet ClientBackEndSwitcherC: " .. tostring(ClientBackEndSwitcherC))
  local EnableJankCollectionFromRemote = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableJankCollection", 1)
  GameInstance:ExecuteCMD("Jank.EnableCollection", EnableJankCollectionFromRemote)
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if ClientEVOConfig.DefaultSleepTimeThodOnIni > 1.0E-6 and 1.0E-6 < ClientEVOConfig.DefaultSleepSlackTimeOnIni then
    if platformName == DevicePlatformNameMacros.IOS then
      local sleepvalue = Client.HDmpveRemoteConfigGetInt("GSleepTimeThod_IOS", -1)
      if sleepvalue < 0 then
        GameInstance:ExecuteCMD("Engine.GSleepTimeThod", ClientEVOConfig.DefaultSleepTimeThodOnIni)
      else
        GameInstance:ExecuteCMD("Engine.GSleepTimeThod", sleepvalue / 10000)
      end
      local sleepSlackvalue = Client.HDmpveRemoteConfigGetInt("GSleepSlackTimeThod_IOS", -1)
      if sleepSlackvalue < 0 then
        GameInstance:ExecuteCMD("Engine.GSleepSlackTimeThod", ClientEVOConfig.DefaultSleepSlackTimeOnIni)
      else
        GameInstance:ExecuteCMD("Engine.GSleepSlackTimeThod", sleepSlackvalue / 10000)
      end
    elseif platformName == DevicePlatformNameMacros.Android then
      local sleepvalue = Client.HDmpveRemoteConfigGetInt("GSleepTimeThod_AOS", -1)
      if sleepvalue < 0 then
        GameInstance:ExecuteCMD("Engine.GSleepTimeThod", ClientEVOConfig.DefaultSleepTimeThodOnIni)
      else
        GameInstance:ExecuteCMD("Engine.GSleepTimeThod", sleepvalue / 10000)
      end
      local sleepSlackvalue = Client.HDmpveRemoteConfigGetInt("GSleepSlackTimeThod_AOS", -1)
      if sleepSlackvalue < 0 then
        GameInstance:ExecuteCMD("Engine.GSleepSlackTimeThod", ClientEVOConfig.DefaultSleepSlackTimeOnIni)
      else
        GameInstance:ExecuteCMD("Engine.GSleepSlackTimeThod", sleepSlackvalue / 10000)
      end
    end
    local delayValue = Client.HDmpveRemoteConfigGetInt("DealyHideLoadingUI", 0)
    GameInstance:ExecuteCMD("s.DealyHideLoadingUI", delayValue / 1000)
  end
  ClientEVOConfig.EnableGCSweepTimeModifiy_GCloud = Client.HDmpveRemoteConfigGetInt("EnableGCSweepTimeModifiy", 0)
  local EnableSimulateMoveOptSwitcher = Client.HDmpveRemoteConfigGetInt("EnableSimulateMoveOpt", 0)
  GameInstance:ExecuteCMD("mv.SimulateOptBackEndSwitcher", EnableSimulateMoveOptSwitcher)
  if not Client.IsEditor() then
    if 3 <= EnableSimulateMoveOptSwitcher then
      GameInstance:ExecuteCMD("st.CompOpt.Enable", 1)
    else
      GameInstance:ExecuteCMD("st.CompOpt.Enable", 0)
    end
  else
    GameInstance:ExecuteCMD("st.CompOpt.Enable", 1)
  end
  if not Client.IsDevelopment() and not ClientEVOConfig.bOpenDevLog then
    GameInstance:ExecuteCMD("log.CloseLogOnTestOrShipping", Client.HDmpveRemoteConfigGetInt("GCloseLogOnTestOrShipping", 0))
  end
  Client.SetFixPostLoadSubojbectsBugEnable(Client.HDmpveRemoteConfigGetInt("OpenFixPostLoadSubojbectsBug", 0))
  if ClientBackEndSwitcherB and ClientBackEndSwitcherB & 1048576 ~= 0 then
    GameInstance:ExecuteCMD("r.UseCahcedFileModule", 1)
  end
  if ClientBackEndSwitcherB and ClientBackEndSwitcherB & 32768 ~= 0 then
    GameInstance:ExecuteCMD("r.FindFileInPakFilesOptEnable", 1)
    GameInstance:ExecuteCMD("r.FindFileInPakFilesMountPointOptEnable", 1)
  end
  if ClientBackEndSwitcherB and ClientBackEndSwitcherB & 65536 ~= 0 then
    GameInstance:ExecuteCMD("r.EnableShaderSerializeBaseOpt", 1)
  end
  if ClientBackEndSwitcherB and ClientBackEndSwitcherB & 33554432 ~= 0 then
    GameInstance:ExecuteCMD("Slate.EnableIsChildWidgetCulledOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableArrangeLayeredChildrenOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableCalculateCullingAndClippingRulesOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableAddShapedTextElementOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableNewKeyboardConfigOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableGetShaderResourceOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableTunePrePassSortMapOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableTunePassOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableTuneElementsNewOpt", 1)
    GameInstance:ExecuteCMD("Slate.EnableAlwaysPaintOpt", 1)
  end
  local EnableROCOrrange = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableROCOrrange", 0)
  GameInstance:ExecuteCMD("r.EnableROCOrrange", EnableROCOrrange)
  GameInstance:ExecuteCMD("r.EnableDynamicShaderOrrange", EnableROCOrrange)
  local EnableNewLandScapeStragety = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableNewLandScapeStragety", 0)
  GameInstance:ExecuteCMD("r.UseNewStragetyV2", EnableNewLandScapeStragety)
  local EnableRenderPipeLine = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableRenderPipeLine", 0)
  GameInstance:ExecuteCMD("r.EnableStaticShaderOrrange", EnableRenderPipeLine)
  local EnableLandScapeSubsectionbox = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableLandScapeSubsectionbox", 0)
  GameInstance:ExecuteCMD("r.Landscape.EnableSubSectionOptimize", EnableLandScapeSubsectionbox)
  local EnableIgnoreDynamicInstancingShader = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableIgnoreDynamicInstancingShader", 0)
  GameInstance:ExecuteCMD("r.Mobile.IgnoreDynamicInstancingShader", EnableIgnoreDynamicInstancingShader)
  local ForceEnableSubSection = HDmpveRemote.HDmpveRemoteConfigGetInt("ForceEnableSubSection", 1)
  GameInstance:ExecuteCMD("r.ForceEnableSubSection", ForceEnableSubSection)
  GameInstance:ExecuteCMD("r.ParticleDynamicInstance", Client.HDmpveRemoteConfigGetInt("EnableParticleDynamicInstance", 0))
  ClientEVOConfig.ManagedTickSysFlagBackEnd = 2
  if not Client.IsEditor() then
    ClientEVOConfig.ManagedTickSysFlagBackEnd = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableManagedTickSys", 0)
  end
  log(bWriteLog and "ManagedTickSys enable form backend:" .. tostring(ClientEVOConfig.ManagedTickSysFlagBackEnd))
  if 2 <= ClientEVOConfig.ManagedTickSysFlagBackEnd then
    Client.ReadManagedTickMapSwitchers()
  end
  local SequenceEnableOpt = HDmpveRemote.HDmpveRemoteConfigGetInt("SequenceEnableOpt", 0)
  GameInstance:ExecuteCMD("r.SequenceEnableOpt", SequenceEnableOpt)
  local PickUpJankOpt = HDmpveRemote.HDmpveRemoteConfigGetInt("PickUpJankOpt", 0)
  GameInstance:ExecuteCMD("r.EnablePickUpUnLimitPool", PickUpJankOpt)
  GameInstance:ExecuteCMD("z.EnablePreCreateWidgetCache", HDmpveRemote.HDmpveRemoteConfigGetInt("EnablePreCreateWidgetCache", 0))
  local LoadObjectOpt = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableLoadObjectOpt", 0)
  GameInstance:ExecuteCMD("s.EnableLoadObjectOpt", LoadObjectOpt)
  if 0 < LoadObjectOpt then
    GameInstance:ExecuteCMD("s.LoadObjectOpt.DeadLoopTime", LoadObjectOpt)
  else
    GameInstance:ExecuteCMD("s.LoadObjectOpt.DeadLoopTime", -1)
  end
  if ClientEVOConfig.IsSuperFrameScaleFactorDownEnable() then
    GameInstance:ExecuteCMD("r.FrameImproveModeInVerySmooth", 1)
    GameInstance:ExecuteCMD("r.PUBGDeviceFPSVerySmooth", 60)
    GameInstance.Userdetailsetting.PUBGDeviceFPSVerySmooth = 60
    log("OnPreBackEndSwitcherSet: SuperFrame VerySmooth FPS unlock -> 60")
  end
end
function ClientEVOConfig.HandleOnLoadingPreBegin()
  if not Client then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local GameplayStatics = import("GameplayStatics")
  if ClientEVOConfig.CollectorTimerID and ClientEVOConfig.CollectorTimerID > 0 then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ClientEVOConfig.CollectorTimerID)
    ClientEVOConfig.CollectorTimerID = 0
  end
  GameInstance:ExecuteCMD("Jank.EnableCollectionFromGamePlay", 0)
  GameInstance:ExecuteCMD("s.EnableLoadObjectOptFromGamePlay", 0)
  Client.ClearJankStats()
  ClientEVOConfig.bCallLoadingUIOpend = true
end
function ClientEVOConfig.HandleOnLoadingEnd()
  if not Client or not ClientEVOConfig.bCallLoadingUIOpend then
    return
  end
  ClientEVOConfig.bCallLoadingUIOpend = false
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local GameplayStatics = import("GameplayStatics")
  local time_ticker = require("common.time_ticker")
  ClientEVOConfig.CollectorTimerID = time_ticker.AddTimerOnce(10, function()
    ClientEVOConfig.CollectorTimerID = 0
    if GameStatus.IsInFightingStatus() and not GameStatus.IsIn2DLobby() then
      GameInstance:ExecuteCMD("Jank.EnableCollectionFromGamePlay", 1)
      GameInstance:ExecuteCMD("s.EnableLoadObjectOptFromGamePlay", 1)
      Client.ClearJankStats()
      Client.SyncLoadInfoCollector_OnLevelStart()
    end
  end)
  if GameStatus.IsInFightingStatus() and not GameStatus.IsIn2DLobby() then
    local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
    log(bWriteLog and "LobbySystem:on_match_success SendMessageToCloudGame MatchBegin")
    logic_cloud_game:SendMessageToCloudGame(logic_cloud_game.ProtocolName.MatchBegin, "MatchBegin")
  end
end
function ClientEVOConfig.HandleOnPreBattleResult()
  if not Client then
    return
  end
  if ClientEVOConfig.CollectorTimerID and ClientEVOConfig.CollectorTimerID > 0 then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ClientEVOConfig.CollectorTimerID)
    ClientEVOConfig.CollectorTimerID = 0
  end
  if ClientEVOConfig.bLevelEnd then
    return
  end
  ClientEVOConfig.bLevelEnd = true
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  ClientEVOConfig.ToggleNotRenderedParallelUpdate(false)
  ClientEVOConfig.ToggleRefreshBonesTickAnimationOpt(false)
  if not GameStatus.IsInFightingStatus() or GameStatus.IsIn2DLobby() then
    GameInstance:ExecuteCMD("Jank.EnableCollectionFromGamePlay", 0)
    GameInstance:ExecuteCMD("Slate.EnableDownTickIntervalForGamePlay", 0)
    GameInstance:ExecuteCMD("s.EnableLoadObjectOptFromGamePlay", 0)
    Client.SyncLoadInfoCollector_Reset()
    Client.ClearJankStats()
    return
  end
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    local TApmSceneMarker = import("TApmSceneMarker")
    TApmHelper.postEvent(606, "end", false)
    log(bWriteLog and "TApmSceneMarker.MarkFlowScene(111)")
    TApmSceneMarker.MarkFlowScene(111)
  end
  GameInstance:ExecuteCMD("Jank.EnableCollectionFromGamePlay", 0)
  GameInstance:ExecuteCMD("Slate.EnableDownTickIntervalForGamePlay", 0)
  GameInstance:ExecuteCMD("s.EnableLoadObjectOptFromGamePlay", 0)
  Client.ClearJankStats()
  Client.SyncLoadInfoCollector_OnLevelEnd()
  ClientEVOConfig.ToggleSlateGI(false)
  ClientEVOConfig.ToggleSlateLayoutCache(false)
  ClientEVOConfig.ToggleActorSpawnQueue(false)
  GameInstance:ExecuteCMD("Slate.EnableGIThrottle", 0)
  GameInstance:ExecuteCMD("Slate.EnableThrottle", 0)
  GameInstance:ExecuteCMD("Slate.EnableIsChildWidgetCulledOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableArrangeLayeredChildrenOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableCalculateCullingAndClippingRulesOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableAddShapedTextElementOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableNewKeyboardConfigOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableGetShaderResourceOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTunePrePassSortMapOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTunePassOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTuneElementsNewOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableAlwaysPaintOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTuneElements", 0)
  GameInstance:ExecuteCMD("Slate.EnableLinePreMerge", 0)
  GameInstance:ExecuteCMD("Slate.UIDynamicBatchOpt", 0)
  GameInstance:ExecuteCMD("Slate.UIDynamicBatchTextOpt", 0)
  GameInstance:ExecuteCMD("Slate.UIDynamicBatchCustomOpt", 0)
end
function ClientEVOConfig.OnBeforeConfirmBackToLobby()
  if not Client then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  ClientEVOConfig.ToggleNotRenderedParallelUpdate(false)
  ClientEVOConfig.ToggleRefreshBonesTickAnimationOpt(false)
  if ClientEVOConfig.CollectorTimerID and ClientEVOConfig.CollectorTimerID > 0 then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ClientEVOConfig.CollectorTimerID)
    ClientEVOConfig.CollectorTimerID = 0
  end
  ClientEVOConfig.bLevelEnd = true
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    local TApmSceneMarker = import("TApmSceneMarker")
    TApmHelper.postEvent(606, "end", false)
    TApmSceneMarker.MarkFlowScene(111)
  end
  GameInstance:ExecuteCMD("Jank.EnableCollectionFromGamePlay", 0)
  GameInstance:ExecuteCMD("Slate.EnableDownTickIntervalForGamePlay", 0)
  GameInstance:ExecuteCMD("s.EnableLoadObjectOptFromGamePlay", 0)
  Client.ClearJankStats()
  Client.SyncLoadInfoCollector_OnLevelEnd()
end
function ClientEVOConfig.HandleOnBattleResultStartPase()
  if not Client then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  ClientEVOConfig.ToggleSlateGI(false)
  ClientEVOConfig.ToggleSlateLayoutCache(false)
  GameInstance:ExecuteCMD("Slate.EnableGIThrottle", 0)
  GameInstance:ExecuteCMD("Slate.EnableThrottle", 0)
  GameInstance:ExecuteCMD("Slate.EnableIsChildWidgetCulledOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableArrangeLayeredChildrenOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableCalculateCullingAndClippingRulesOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableAddShapedTextElementOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableNewKeyboardConfigOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableGetShaderResourceOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTunePrePassSortMapOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTunePassOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTuneElementsNewOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableAlwaysPaintOpt", 0)
  GameInstance:ExecuteCMD("Slate.EnableTuneElements", 0)
  GameInstance:ExecuteCMD("Slate.EnableLinePreMerge", 0)
  GameInstance:ExecuteCMD("Slate.UIDynamicBatchOpt", 0)
  GameInstance:ExecuteCMD("Slate.UIDynamicBatchTextOpt", 0)
  GameInstance:ExecuteCMD("Slate.UIDynamicBatchCustomOpt", 0)
end
function ClientEVOConfig.HandleOnBattleResultEndPase()
  if not Client then
    return
  end
end
function ClientEVOConfig.PostBackEndSwitcherSet(SmartBearerSwitcher, SuperFrameSwitcher, ClientBackEndSwitcherA, ClientBackEndSwitcherB, ClientBackEndSwitcherC, PostLoadSwitcher)
  local switcher = "SmartBearerSwitcher:" .. tostring(SmartBearerSwitcher) .. ",SuperFrameSwitcher:" .. tostring(SuperFrameSwitcher) .. ",ClientBackEndSwitcherA:" .. tostring(ClientBackEndSwitcherA) .. ",ClientBackEndSwitcherB:" .. tostring(ClientBackEndSwitcherB) .. ",ClientBackEndSwitcherC:" .. tostring(ClientBackEndSwitcherC) .. ",PostLoadSwitcher:" .. tostring(PostLoadSwitcher)
  Client.AddAttachFileString("ClientEVOBackEndSwitcher", false, switcher)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  ClientEVOConfig.SavedUseLowFakeLandScape = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.FakeLandscape.EnableLow")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    TApmHelper.postEvent(788, Client.GetYYXDeviceModel(), false)
  end
end
function ClientEVOConfig.OnModePreSwitch(preState, nextState)
  if not Client then
    return
  end
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    ClientEVOConfig.ToggleNotRenderedParallelUpdate(ClientEVOConfig.bEnableNotRenderedParallelUpdateBackEnd)
    ClientEVOConfig.ToggleRefreshBonesTickAnimationOpt(ClientEVOConfig.bEnableRefreshBonesTickAnimationOptBackEnd)
  end
  if preState == nextState then
    log(bWriteLog and "[ClientEVOConfig] OnModePreSwitch return preState == nextState!!")
    return
  end
  log(bWriteLog and "[ClientEVOConfig] OnModePreSwitch nextState=" .. tostring(nextState))
  if ClientEVOConfig.bLevelStreamingBackEndEnable then
    if nextState == GameStatus.Lobby and ClientEVOConfig.bEnterBorderland then
      ClientEVOConfig.bEnterBorderland = false
      ClientEVOConfig.EnableLevelStreamingOpt()
    elseif nextState == GameStatus.Lobby and ClientEVOConfig.bEnterTMod then
      ClientEVOConfig.bEnterTMod = false
      ClientEVOConfig.EnableLevelStreamingOpt()
    elseif nextState == GameStatus.Lobby and ClientEVOConfig.bEnterSingleMode then
      ClientEVOConfig.bEnterSingleMode = false
      ClientEVOConfig.EnableLevelStreamingOpt()
    end
  end
  if ClientEVOConfig.bTickAsyncLoadingBackEndEnable then
    if nextState == GameStatus.Lobby and ClientEVOConfig.bTickAsyncLoadingSetInFighting then
      ClientEVOConfig.DisableTickAsyncLoadingOpt()
      ClientEVOConfig.bTickAsyncLoadingSetInFighting = false
    end
    if nextState == GameStatus.Fighting and not ClientEVOConfig.bTickAsyncLoadingSetInFighting then
      ClientEVOConfig.EnableTickAsyncLoadingOpt()
      ClientEVOConfig.bTickAsyncLoadingSetInFighting = true
    end
  end
  if nextState ~= GameStatus.Fighting then
    ClientEVOConfig.ToggleProfileInNeon(false, "lobby")
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if ClientEVOConfig.bEnableUIDynamicBatch then
    if nextState == GameStatus.Lobby then
      GameInstance:ExecuteCMD("Slate.EnableTuneElements", 0)
      GameInstance:ExecuteCMD("Slate.EnableLinePreMerge", 0)
      GameInstance:ExecuteCMD("Slate.UIDynamicBatchOpt", 0)
      GameInstance:ExecuteCMD("Slate.UIDynamicBatchTextOpt", 0)
      GameInstance:ExecuteCMD("Slate.UIDynamicBatchCustomOpt", 0)
      GameInstance:ExecuteCMD("Slate.EnableRenderTune", 0)
      GameInstance:ExecuteCMD("Slate.EnableTuneClipping", 0)
      log(bWriteLog and "[UIDynamicBatch] Slate.EnableRenderTune 0")
    end
    if nextState == GameStatus.Fighting then
      GameInstance:ExecuteCMD("Slate.EnableTuneElements", 1)
      GameInstance:ExecuteCMD("Slate.EnableLinePreMerge", 1)
      GameInstance:ExecuteCMD("Slate.UIDynamicBatchOpt", 1)
      GameInstance:ExecuteCMD("Slate.UIDynamicBatchTextOpt", 0)
      GameInstance:ExecuteCMD("Slate.UIDynamicBatchCustomOpt", 1)
      GameInstance:ExecuteCMD("Slate.EnableRenderTune", 1)
      GameInstance:ExecuteCMD("Slate.EnableTuneClipping", 1)
      log(bWriteLog and "[UIDynamicBatch] Slate.EnableRenderTune 1")
      GameInstance:ResetLastTimeMobileContentScaleFactor()
    end
  end
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if not ClientEVOConfig.DefaultHitTestOptimization then
    ClientEVOConfig.DefaultHitTestOptimization = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("s.GEnableHitTestOptimization") or 0
  end
  if nextState == GameStatus.Fighting then
    GameInstance:ExecuteCMD("s.GEnableHitTestOptimization", 0)
  else
    GameInstance:ExecuteCMD("s.GEnableHitTestOptimization", ClientEVOConfig.DefaultHitTestOptimization)
  end
  if ClientEVOConfig.EnableNewObjectPoolConfigValue == nil then
    ClientEVOConfig.EnableNewObjectPoolConfigValue = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("g.EnableNewObjectPool")
    log_shipping_client("ClientEVOConfig.EnableNewObjectPoolConfigValue: " .. tostring(ClientEVOConfig.EnableNewObjectPoolConfigValue))
  end
  if nextState ~= GameStatus.Fighting and not Client.IsEditor() then
    GameInstance:ExecuteCMD("g.EnableNewObjectPool", 0)
  end
  if ClientEVOConfig.bEnableIOSPSOCache and uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.IOSPSORuntimeCache") ~= 0 then
    if nextState == GameStatus.Lobby then
      FuncUtil.UE4ExecuteConsoleCommand("MetalPSOCache.Save")
      GameInstance:ExecuteCMD("r.MetalPSOCacheMode", 5)
      log(bWriteLog and "[IOSPSOCache] r.MetalPSOCacheMode 5 ignore")
    end
    if nextState == GameStatus.Fighting then
      GameInstance:ExecuteCMD("r.MetalPSOCacheMode", 3)
      log(bWriteLog and "[IOSPSOCache] r.MetalPSOCacheMode 3 Append And Use")
    end
  end
  if nextState == GameStatus.Lobby then
    GameInstance:ExecuteCMD("r.Mobile.IOSAsyncCreatePSO", 0)
    GameInstance:ExecuteCMD("r.Mobile.IOSAsyncCreatePSOTranslucent", 0)
    GameInstance:ExecuteCMD("r.AsyncCreateTexture", 0)
    local EnergySaving = import("EnergySavingManagerLuaBridge")
    if EnergySaving then
      EnergySaving.CloseEnergySavingMode()
    end
    GameInstance:ExecuteCMD("r.HLOD.EnableScopeDistanceScale", 0)
    GameInstance:ExecuteCMD("a.URO.Enable", 0)
    GameInstance:ExecuteCMD("r.CachePSOSeparateFighting", 0)
    GameInstance:ExecuteCMD("r.ParticleMinTimeBetweenTick", 0)
    GameInstance:ExecuteCMD("r.ParticleMinTimeTickDistance", 5000)
  else
    GameInstance:ExecuteCMD("a.URO.Enable", 1)
    GameInstance:ExecuteCMD("r.CachePSOSeparateFighting", 1)
    GameInstance:ExecuteCMD("r.ParticleMinTimeBetweenTick", 25)
    GameInstance:ExecuteCMD("r.ParticleMinTimeTickDistance", 0)
  end
  local lowVirDevice = Client.GetAndroidSOVersion() == 32 and 3 > Client.GetMemorySize()
  if nextState == GameStatus.Fighting and not lowVirDevice then
    GameInstance:ExecuteCMD("r.Mobile.IOSAsyncCreatePSO", 1)
    GameInstance:ExecuteCMD("r.Mobile.IOSAsyncCreatePSOTranslucent", 1)
    local nDeviceLevel = GameInstance:GetExactDeviceLevel()
    if nDeviceLevel <= 0 then
      GameInstance:ExecuteCMD("r.AsyncCreateTexture", 1)
    end
  end
  if 0 < ClientEVOConfig.ManagedTickSysFlagBackEnd and nextState == GameStatus.Fighting then
    GameInstance:ExecuteCMD("tick.EnableManagedTickSysFlag", ClientEVOConfig.ManagedTickSysFlagBackEnd)
  else
    GameInstance:ExecuteCMD("tick.EnableManagedTickSysFlag", 0)
  end
  Client.SwitchMapMangedTickProfile(ClientEVOConfig.CurrentModID)
  local Enable3DShareUI = Client.HDmpveRemoteConfigGetBool("Enable3DShareUI", false)
  if Enable3DShareUI then
    if nextState == GameStatus.Fighting then
      GameInstance:ExecuteCMD("slate.Enable3DShareUI", 1)
    else
      GameInstance:ExecuteCMD("slate.Enable3DShareUI", 0)
    end
  end
  if nextState == GameStatus.Lobby then
    ClientEVOConfig.ToggleSlateGI(false)
    ClientEVOConfig.NeedInvalidationBoxThisGame = false
  end
end
function ClientEVOConfig.OnSetInGameModeID(ModID)
  if not Client then
    return
  end
  log(bWriteLog and "[ClientEVOConfig] OnSetInGameModeID ModID=" .. tostring(ModID))
  local TableUtil = require("common.table_util")
  ClientEVOConfig.Current  if ClientEVOConfig.bLevelStreamingBackEndEnable then
    if not ClientEVOConfig.bEnterBorderland and TableUtil.IsInTable(ClientEVOConfig.BorderlandModList, ModID) then
      ClientEVOConfig.bEnterBorderland = true
      ClientEVOConfig.DisableLevelStreamingOpt()
    elseif not ClientEVOConfig.bEnterTMod and TableUtil.IsInTable(ClientEVOConfig.TModList, ModID) then
      ClientEVOConfig.bEnterTMod = true
      ClientEVOConfig.DisableLevelStreamingOpt()
    elseif not ClientEVOConfig.bEnterSingleMode and TableUtil.IsInTable(ClientEVOConfig.SingModlList, ModID) then
      ClientEVOConfig.bEnterSingleMode = true
      ClientEVOConfig.DisableLevelStreamingOpt()
    end
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if ModID and tonumber(ModID) then
    local SubModeCfg = CDataTable.GetTableData("BTMode", tonumber(ModID))
    if SubModeCfg and SubModeCfg.ModType then
      log(bWriteLog and "ClientEVOConfig.OnSetInGameModeID: " .. SubModeCfg.ModType)
      local StringUtil = require("common.string_util")
      local ModTypes = StringUtil.Split(SubModeCfg.ModType, ";")
      local ModType = ModTypes and ModTypes[1]
      if ModType and (ClientEVOConfig.SlateGIAvailableMod[ModType] == true or ClientEVOConfig.SlateGIAvailableMod[ModType] == nil) and not ClientEVOConfig.IsCreativeMode() then
        log_shipping_client("ClientEVOConfig ToggleSlateGI Mod: " .. SubModeCfg.ModType)
        ClientEVOConfig.ToggleSlateGI(true)
      else
        ClientEVOConfig.ToggleSlateGI(false)
        log_shipping_client("ClientEVOConfig ToggleSlateGI Mod: " .. SubModeCfg.ModType .. " Not Supported Mod")
      end
      local bNewObjectPoolEnabled = false
      if ModType and (ClientEVOConfig.NewObjectPoolAvailableMod[ModType] == true or ClientEVOConfig.NewObjectPoolAvailableMod[ModType] == nil) then
        bNewObjectPoolEnabled = true
        if HDmpveRemote.HDmpveRemoteConfigGetInt("ForceDisableObjectPool", 0) == 1 then
          bNewObjectPoolEnabled = false
        end
      end
      if bNewObjectPoolEnabled then
        log_shipping_client("ClientEVOConfig.EnableNewObjectPoolConfigValue: " .. tostring(ClientEVOConfig.EnableNewObjectPoolConfigValue))
        GameInstance:ExecuteCMD("g.EnableNewObjectPool", ClientEVOConfig.EnableNewObjectPoolConfigValue)
        log(bWriteLog and "ClientEVOConfig.OnSetInGameModeID: " .. SubModeCfg.ModType .. " EnableNewObjectPool: " .. tostring(ClientEVOConfig.EnableNewObjectPoolConfigValue))
      else
        GameInstance:ExecuteCMD("g.EnableNewObjectPool", 0)
        log(bWriteLog and "ClientEVOConfig.OnSetInGameModeID: " .. SubModeCfg.ModType .. " EnableNewObjectPool: 0 Not Supported Mod")
      end
      if ModType and ClientEVOConfig.LayoutCacheAvailableMod[ModType] then
        log_shipping_client("ClientEVOConfig ToggleSlateLayoutCache Mod: " .. SubModeCfg.ModType)
        ClientEVOConfig.ToggleSlateLayoutCache(true)
      end
      if ModType and ClientEVOConfig.InvalidationPanelsAvailableMod[ModType] == false then
        log_shipping_client("ClientEVOConfig ToggleInvalidationPanels Disable for Mod: " .. SubModeCfg.ModType)
        ClientEVOConfig.ToggleInvalidationPanels(false)
        ClientEVOConfig.NeedInvalidationBoxThisGame = false
      else
        ClientEVOConfig.ToggleInvalidationPanels(ClientEVOConfig.bEnableInvalidationPanelsCloud or IsEditor)
        ClientEVOConfig.NeedInvalidationBoxThisGame = ClientEVOConfig.bEnableInvalidationPanelsCloud or IsEditor
      end
    end
  end
  if not ClientEVOConfig.NewObjectPoolGCConfigValue then
    local CVarEnableTemporalDisregardForGC = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("g.EnableTemporalDisregardForGC")
    local CVarNewObjectPoolDisregardForGC = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("g.NewObjectPool.DisregardForGC")
    ClientEVOConfig.NewObjectPoolGCConfigValue = CVarEnableTemporalDisregardForGC == 1 and CVarNewObjectPoolDisregardForGC == 1
  end
  if ClientEVOConfig.bNewObjectPoolGCOptimizationEnable and ClientEVOConfig.NewObjectPoolGCConfigValue then
    GameInstance:ExecuteCMD("g.EnableTemporalDisregardForGC", 1)
    GameInstance:ExecuteCMD("g.NewObjectPool.DisregardForGC", 1)
  else
    GameInstance:ExecuteCMD("g.EnableTemporalDisregardForGC", 0)
    GameInstance:ExecuteCMD("g.NewObjectPool.DisregardForGC", 0)
  end
  if ClientEVOConfig.bNewObjectPoolDefferedPhysicsState or Client.IsEditor() then
    GameInstance:ExecuteCMD("p.CanForcePhysicsStateDeferred", 1)
  else
    GameInstance:ExecuteCMD("p.CanForcePhysicsStateDeferred", 0)
  end
end
function ClientEVOConfig.OnPreLoadMap(mapName)
  if not Client then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  Client.ClearSyncLoadCacheSystem()
  GameInstance:ExecuteCMD("s.EnableSyncLoadCacheSystem_GamePlay", 0)
  log(bWriteLog and "[ClientEVOConfig] OnPreLoadMap EnableSyncLoadCacheSystem_GamePlay~2")
  ClientEVOConfig.LastWorldName = ClientEVOConfig.CurrentWorldName
  ClientEVOConfig.CurrentWorldName = Client.GetCleanFileName(mapName)
  if ClientEVOConfig.bUseLowFakeLandScapeBackEndEnable then
    local bIsBalticMaps = string.find(mapName, "Baltic_Main", 1)
    if bIsBalticMaps then
      GameInstance:ExecuteCMD("r.FakeLandscape.EnableLow", 1)
    else
      GameInstance:ExecuteCMD("r.FakeLandscape.EnableLow", ClientEVOConfig.SavedUseLowFakeLandScape)
    end
  end
  ClientEVOConfig.ToggleProfileInNeon(true, ClientEVOConfig.CurrentWorldName)
  if ClientEVOConfig.BackUpbUseNewHole == -1 then
    local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    ClientEVOConfig.BackUpbUseNewHole = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.UseNewLandscapeHole")
    ClientEVOConfig.BakcUpNumVisibleComponents = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.VisiableComponentNumOnLanded")
    log_shipping_client("[ClientEVOConfig] LandscapeBackup BackUpbUseNewHole " .. tostring(ClientEVOConfig.BackUpbUseNewHole) .. " BakcUpNumVisibleComponents " .. tostring(ClientEVOConfig.BakcUpNumVisibleComponents))
  end
  local SmartBearerManagerLuaBridge = import("SmartBearerManagerLuaBridge")
  if SmartBearerManagerLuaBridge ~= nil then
    local bSubMountPointOptEnable = SmartBearerManagerLuaBridge.IsClientBackEndSwitcherBEnable(23)
    local bFindFileOpt_Pandora = SmartBearerManagerLuaBridge.IsClientBackEndSwitcherBEnable(24)
    local bIsBRMap = string.find(mapName, "Baltic_Main", 1) or string.find(mapName, "FourMaps_Main", 1)
    log_shipping_client("[ClientEVOConfig] SubMountPointOpt bIsBRMap[" .. tostring(bIsBRMap) .. "] bSubMountPointOptEnable[" .. tostring(bSubMountPointOptEnable) .. "] bFindFileOpt_Pandora[" .. tostring(bFindFileOpt_Pandora) .. "]")
    if bIsBRMap and bSubMountPointOptEnable and Client.EnableSubMountPoint() then
      GameInstance:ExecuteCMD("r.FindFileSubMountPointOpt", 1)
      GameInstance:ExecuteCMD("r.TrustSubMountPoint", 1)
    else
      GameInstance:ExecuteCMD("r.FindFileSubMountPointOpt", 0)
      GameInstance:ExecuteCMD("r.FindFileOptEnablePandoraPakOpt", 0)
    end
    if bIsBRMap and bFindFileOpt_Pandora then
      GameInstance:ExecuteCMD("r.FindFileOptEnablePandoraPakOpt", 1)
    else
      GameInstance:ExecuteCMD("r.TrustSubMountPoint", 0)
    end
  end
end
function ClientEVOConfig.OnModePostSwitch(preState, nextState)
  if not Client then
    return
  end
  ClientEVOConfig.RefreshNotRenderedParallelUpdate()
  ClientEVOConfig.RefreshBonesTickAnimationOpt()
  if preState == nextState then
    log(bWriteLog and "[ClientEVOConfig] OnModePostSwitch return preState == nextState!!")
    return
  end
  ClientEVOConfig.bLevelEnd = false
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("Slate.EnableDownTickIntervalForGamePlay", 0)
  Client.ResetAllSlateTickEveryFrame()
  log(bWriteLog and "[ClientEVOConfig] OnModePostSwitch nextState=" .. tostring(nextState) .. ",CurrentModID:" .. tostring(ClientEVOConfig.CurrentModID))
  Client.TPerforPlatDataReport(GameFrontendHUD, 401, tostring(ClientEVOConfig.CurrentModID))
  Client.ClearSyncLoadCacheSystem()
  if not GameStatus.InSupportDownloadState() then
    GameInstance:ExecuteCMD("s.EnableSyncLoadCacheSystem_GamePlay", 1)
    log(bWriteLog and "[ClientEVOConfig] OnModePostSwitch EnableSyncLoadCacheSystem_GamePlay new ~1")
  else
    GameInstance:ExecuteCMD("s.EnableSyncLoadCacheSystem_GamePlay", 0)
    log(bWriteLog and "[ClientEVOConfig] OnModePostSwitch EnableSyncLoadCacheSystem_GamePlay new ~0")
  end
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    if nextState == GameStatus.Fighting then
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      local _, viewId = logic_mode_selection:GetCurSelectInfo()
      local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
      local BTMode = CDataTable.GetTableData("BTMode", logic_enter_game.sub_mode)
      local ModeFightType = -1
      if BTMode and BTMode.ModeFightType then
        ModeFightType = BTMode.ModeFightType
      end
      local viewTable = CDataTable.GetSplitTableData("Lobby", "ModeSelection", "view_contain_table", viewId)
      local RankType = -1
      if viewTable and viewTable.is_rank then
        RankType = viewTable.is_rank
      end
      local TApmHelper = import("TApmHelper")
      local tempValue = ModeFightType % 10 * 10
      tempValue = tempValue + RankType % 10
      log(bWriteLog and "[ClientEVOConfig] PostModeID to TGPA" .. tostring(logic_enter_game.sub_mode) .. "ModeType: " .. tostring(ModeFightType) .. "RankType: " .. tostring(RankType) .. "TGPAValue: " .. tostring(tempValue))
      TApmHelper.PostGameStatusToTGPAIS(40, tostring(tempValue))
    else
      local TApmHelper = import("TApmHelper")
      TApmHelper.PostGameStatusToTGPAIS(40, tostring(0))
      log(bWriteLog and "[ClientEVOConfig] PostModeID to TGPA" .. tostring(0))
    end
  end
end
function ClientEVOConfig.ToggleProfileInNeon(bEnable, mapName)
  log(bWriteLog and "[ClientEVOConfig] ToggleProfileInNeon currmap" .. mapName .. "Enable?:" .. tostring(bEnable))
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if bEnable then
    local Pos = string.find(mapName, "PUBG_Neon_Main")
    if Pos then
      log(bWriteLog and "[ClientEVOConfig] ToggleProfileInNeon NEon Toggle")
      local mipLodBias = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("r.MipLODBiasFromQuality")
      local TCDeviceLevel = Client.GetTCDeviceLevel()
      if TCDeviceLevel < 7 and ClientEVOConfig.TextureMipOffsetbackUp == -1 then
        if mipLodBias < 1 then
          GameInstance:ExecuteCMD("r.MipLODBiasFromQuality", 1)
          ClientEVOConfig.TextureMipOffsetbackUp = 0
        end
        GameInstance:ExecuteCMD("r.SuperFrame.ScreenSizeCullFactor", 1.2)
      end
    end
  else
    log(bWriteLog and "[ClientEVOConfig] ToggleProfileInNeon NEon Toggle")
    local TCDeviceLevel = Client.GetTCDeviceLevel()
    if TCDeviceLevel < 7 and ClientEVOConfig.TextureMipOffsetbackUp == 0 then
      GameInstance:ExecuteCMD("r.MipLODBiasFromQuality", 0)
      ClientEVOConfig.TextureMipOffsetbackUp = -1
      GameInstance:ExecuteCMD("r.SuperFrame.ScreenSizeCullFactor", 1.0)
    end
  end
end
function ClientEVOConfig.GetSlateGIState()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local SlateGIStatus = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("slate.EnableGI")
  if SlateGIStatus == 1 then
    return true
  else
    return false
  end
end
function ClientEVOConfig.GetIBState()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local IBStatus = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("Slate.EnableInvalidationPanels")
  if IBStatus == 1 then
    return true
  else
    return false
  end
end
function ClientEVOConfig.ToggleInvalidationPanels(bEnable)
  if not ClientEVOConfig.bEnableInvalidationPanelsCloud and not IsEditor then
    log_shipping_client("[ClientEVOConfig] ToggleInvalidationPanels Cloud Switch Off")
    bEnable = false
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if not GameInstance or not slua.isValid(GameInstance) then
    log_shipping_client("[ClientEVOConfig] ToggleInvalidationPanels GameInstance is nil")
    return
  end
  if bEnable then
    GameInstance:ExecuteCMD("Slate.EnableInvalidationPanels", 1)
    log_shipping_client("[ClientEVOConfig] ToggleInvalidationPanels Slate.EnableInvalidationPanels 1")
  else
    GameInstance:ExecuteCMD("Slate.EnableInvalidationPanels", 0)
    log_shipping_client("[ClientEVOConfig] ToggleInvalidationPanels Slate.EnableInvalidationPanels 0")
  end
end
function ClientEVOConfig.ToggleSlateGI(bEnable)
  if not ClientEVOConfig.bEnableSlateGICloud and not IsEditor then
    log_shipping_client("[ClientEVOConfig] ToggleSlateGI Cloud Switch Off")
    bEnable = false
  else
    log_shipping_client("[ClientEVOConfig] ToggleSlateGI Cloud Switch On")
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local SlateGIStatus = ClientEVOConfig.GetSlateGIState()
  log_shipping_client("[ClientEVOConfig] ToggleSlateGI Current SlateGI Status:" .. tostring(SlateGIStatus) .. ", Enable?:" .. tostring(bEnable))
  if bEnable then
    if SlateGIStatus == true then
      log_shipping_client("[ClientEVOConfig] ToggleSlateGI SlateGI already enabled")
      return
    end
    GameInstance:ExecuteCMD("slate.EnableGI", 1)
    ClientEVOConfig.ToggleSlateLayoutCache(false)
    log_shipping_client("[ClientEVOConfig] ToggleSlateGI Slate.EnableGI 1")
  else
    if SlateGIStatus == false then
      log_shipping_client("[ClientEVOConfig] ToggleSlateGI SlateGI already disabled")
      return
    end
    GameInstance:ExecuteCMD("slate.EnableGI", 0)
    ClientEVOConfig.ToggleSlateLayoutCache(false)
    log_shipping_client("[ClientEVOConfig] ToggleSlateGI Slate.EnableGI 0")
  end
end
function ClientEVOConfig.GetActorSpawnQueueState()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local ActorSpawnQueueEnable = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("net.ActorSpawnQueue.Enable")
  return ActorSpawnQueueEnable == 1
end
function ClientEVOConfig.ToggleActorSpawnQueue(bEnable)
  if not ClientEVOConfig.bEnableActorSpawnQueueCloud then
    bEnable = false
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local ActorSpawnQueueEnable = ClientEVOConfig.GetActorSpawnQueueState()
  log_shipping_client("[ClientEVOConfig] ToggleActorSpawnQueue Current ActorSpawnQueue Status:" .. tostring(ActorSpawnQueueEnable) .. ", Enable?:" .. tostring(bEnable))
  if bEnable then
    GameInstance:ExecuteCMD("net.ActorSpawnQueue.Enable", 1)
    GameInstance:ExecuteCMD("net.ActorSpawnQueue.ClassAvailableIfNotListed", 1)
    log_shipping_client("[ClientEVOConfig] ToggleActorSpawnQueue net.ActorSpawnQueue.Enable 1")
  else
    GameInstance:ExecuteCMD("net.ActorSpawnQueue.Enable", 0)
    log_shipping_client("[ClientEVOConfig] ToggleActorSpawnQueue net.ActorSpawnQueue.Enable 0")
  end
end
function ClientEVOConfig.ToggleSlateLayoutCache(bEnable)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  ClientEVOConfig.bEnableSlateLayoutCache = ClientEVOConfig.bEnableSlateLayoutCacheBackendValue
  SwitcherModifiedCount = 0
  if not ClientEVOConfig.bEnableSlateLayoutCache then
    GameInstance:ExecuteCMD("slate.EnableLayoutCaching", 0)
    GameInstance:ExecuteCMD("slate.AutoFixSlateLayoutCaching", 0)
    return
  end
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local SlateLayoutCacheStatus = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("slate.EnableLayoutCaching")
  if bEnable then
    if SlateLayoutCacheStatus ~= 1 then
      GameInstance:ExecuteCMD("slate.EnableLayoutCaching", 1)
      GameInstance:ExecuteCMD("slate.AutoFixSlateLayoutCaching", 1)
      log_shipping_client("[ClientEVOConfig] ToggleSlateLayoutCache Slate.EnableLayoutCaching 1")
      log_shipping_client("[ClientEVOConfig] ToggleSlateLayoutCache Slate.AutoFixSlateLayoutCaching 1")
    end
  elseif SlateLayoutCacheStatus == 1 then
    GameInstance:ExecuteCMD("slate.EnableLayoutCaching", 0)
    GameInstance:ExecuteCMD("slate.AutoFixSlateLayoutCaching", 0)
    log_shipping_client("[ClientEVOConfig] ToggleSlateLayoutCache Slate.EnableLayoutCaching 0")
    log_shipping_client("[ClientEVOConfig] ToggleSlateLayoutCache Slate.AutoFixSlateLayoutCaching 0")
  end
end
function ClientEVOConfig.GetDesiredSlateLayoutCacheState()
  if GameStatus.GetGameStatus() ~= GameStatus.Fighting then
    return 0
  end
  return ClientEVOConfig.bEnableSlateLayoutCache and 1 or 0
end
function ClientEVOConfig.ReportDeviceOverHeatInfo(key, value)
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    TApmHelper.postEvent(key, tostring(value), false)
  end
end
function ClientEVOConfig.OnPostSetFPS(fpsLevel)
  if not Client then
    return
  end
  log(bWriteLog and "[ClientEVOConfig] OnPostSetFPS")
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local TableUtil = require("common.table_util")
  if 7 <= fpsLevel and ClientEVOConfig.SlateTickDownWhitList[ClientEVOConfig.CurrentWorldName] and not TableUtil.IsInTable(ClientEVOConfig.TModList, ClientEVOConfig.CurrentModID) then
    if fpsLevel == 7 then
      GameInstance:ExecuteCMD("Slate.DownTickInterval", 0.0333)
    elseif fpsLevel == 8 then
      GameInstance:ExecuteCMD("Slate.DownTickInterval", 0.0333)
    end
    GameInstance:ExecuteCMD("Slate.EnableDownTickIntervalForGamePlay", 1)
  else
    GameInstance:ExecuteCMD("Slate.EnableDownTickIntervalForGamePlay", 0)
  end
  log_shipping_client("[ClientEVOConfig.OnPostSetFPS] Current WorldName:" .. tostring(ClientEVOConfig.CurrentWorldName) .. ",fpsLevel:" .. tostring(fpsLevel) .. ",CurrentModID:" .. tostring(ClientEVOConfig.CurrentModID))
  local bSlateThrottleCheckPass = 8 <= fpsLevel
  bSlateThrottleCheckPass = ClientEVOConfig.bUseSlateThrottleWhiteList and bSlateThrottleCheckPass and ClientEVOConfig.SlateThrottleWhiteList[ClientEVOConfig.CurrentWorldName] and not TableUtil.IsInTable(ClientEVOConfig.TModList, ClientEVOConfig.CurrentModID)
  if bSlateThrottleCheckPass then
    GameInstance:ExecuteCMD("Slate.Frequency", 60)
    ClientEVOConfig.bEnableSlateThrottle = true
  else
    GameInstance:ExecuteCMD("Slate.Frequency", -1)
    ClientEVOConfig.bEnableSlateThrottle = false
  end
  local bSlateGIThrottleCheckPass = 8 <= fpsLevel
  bSlateGIThrottleCheckPass = ClientEVOConfig.bUseSlateGIThrottleWhiteList and bSlateGIThrottleCheckPass and ClientEVOConfig.SlateGIThrottleWhiteList[ClientEVOConfig.CurrentWorldName] and not TableUtil.IsInTable(ClientEVOConfig.TModList, ClientEVOConfig.CurrentModID)
  if bSlateGIThrottleCheckPass then
    GameInstance:ExecuteCMD("Slate.Frequency", 60)
    ClientEVOConfig.bEnableSlateThrottle = true
  else
    GameInstance:ExecuteCMD("Slate.Frequency", -1)
    ClientEVOConfig.bEnableSlateThrottle = false
  end
  if 8 <= fpsLevel then
    GameInstance:ExecuteCMD("s.PowerOptSepcial.LandScapeSeries.GrassUpdateInterval", 10)
    GameInstance:ExecuteCMD("s.ProcessAsyncLoadingRate", HDmpveRemote.HDmpveRemoteConfigGetInt("ProcessAsyncLoadingRate", -30) * 0.001)
  else
    GameInstance:ExecuteCMD("s.PowerOptSepcial.LandScapeSeries.GrassUpdateInterval", ClientEVOConfig.BackGrassUpdateIntervel)
    GameInstance:ExecuteCMD("s.ProcessAsyncLoadingRate", -0.003)
  end
  if 7 <= fpsLevel then
    if fpsLevel == 7 then
      GameInstance:ExecuteCMD("r.TextureStreamingReduceFrameCount", 3)
    elseif fpsLevel == 8 then
      GameInstance:ExecuteCMD("r.TextureStreamingReduceFrameCount", 4)
    end
  end
  Client.ResetAllSlateTickEveryFrame()
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local fps = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.MaxFPS")
    TApmHelper.SetTragetFrameRate(fps)
  end
  local SetStreamingPoolSizeOnSetting = HDmpveRemote.HDmpveRemoteConfigGetInt("SetStreamingPoolSizeOnSetting", 0)
  if 0 < SetStreamingPoolSizeOnSetting then
    GameInstance:ExecuteCMD("r.Streaming.PoolSize", SetStreamingPoolSizeOnSetting)
    GameInstance:ExecuteCMD("r.Streaming.AdditionalPoolSize", 0)
  end
  Client.RefershAllManagedTickConfigWhenFPSChanged()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local platformName = Client.GetDevicePlatformName()
  if fpsLevel == 6 and platformName == DevicePlatformNameMacros.IOS then
    GameInstance:ExecuteCMD("Engine.GSleepSlackTimeThod", 0.0012)
    GameInstance:ExecuteCMD("Engine.GSleepTimeThod", 0.0012)
  end
  local OverrideJankCollectionTimeThresholdFromRemote = 0
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if 8 <= fpsLevel then
    OverrideJankCollectionTimeThresholdFromRemote = HDmpveRemote.HDmpveRemoteConfigGetInt("JankCollectionTimeThreshold_120FPS", 0)
  elseif 7 <= fpsLevel then
    OverrideJankCollectionTimeThresholdFromRemote = HDmpveRemote.HDmpveRemoteConfigGetInt("JankCollectionTimeThreshold_90FPS", 0)
  else
    OverrideJankCollectionTimeThresholdFromRemote = HDmpveRemote.HDmpveRemoteConfigGetInt("JankCollectionTimeThreshold", 0)
  end
  if 1 <= OverrideJankCollectionTimeThresholdFromRemote then
    GameInstance:ExecuteCMD("Jank.CollectionTimeThreshold", OverrideJankCollectionTimeThresholdFromRemote)
  else
    GameInstance:ExecuteCMD("Jank.CollectionTimeThreshold", ClientEVOConfig.DefaultJankCollectionTimeThresholdOnIni)
  end
end
function ClientEVOConfig.ApplyGCIntervelFromMap(mapID)
  if not Client then
    return
  end
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local so_version = Client.GetAndroidSOVersion()
  if platformName ~= DevicePlatformNameMacros.Android or ClientEVOConfig.EnableGCSweepTimeModifiy_GCloud <= 0 or so_version == 32 then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local TCDeviceLevel = Client.GetTCDeviceLevel()
  local MemorySize = Client.GetMemorySize()
  if mapID == 0 then
    if 5 <= MemorySize and 6 <= TCDeviceLevel and ClientEVOConfig.CloseGCWhitList[ClientEVOConfig.CurrentWorldName] then
      GameInstance:ExecuteCMD("gc.TimeBetweenPurgingPendingKillObjects", 900)
      log(bWriteLog and "[ClientEVOConfig] ApplyGCIntervelFromMap gc.TimeBetweenPurgingPendingKillObjects 900")
    end
  elseif mapID == 1 and 5 <= MemorySize and 7 <= TCDeviceLevel then
    GameInstance:ExecuteCMD("gc.TimeBetweenPurgingPendingKillObjects", 90)
    log(bWriteLog and "[ClientEVOConfig] ApplyGCIntervelFromMap gc.TimeBetweenPurgingPendingKillObjects 90")
  end
end
function ClientEVOConfig.IsCreativeMode()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC and (LogicUGC:IsUGCGameMod() or LogicUGC:IsUGCEditMod()) then
    return true
  end
  return false
end
function ClientEVOConfig.RevertGCIntervelFromMap(mapID)
  if not Client then
    return
  end
  log(bWriteLog and "[ClientEVOConfig] RevertGCIntervelFromMap mapid:" .. tostring(mapID))
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local so_version = Client.GetAndroidSOVersion()
  if platformName ~= DevicePlatformNameMacros.Android or ClientEVOConfig.EnableGCSweepTimeModifiy_GCloud <= 0 or so_version == 32 then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local TCDeviceLevel = Client.GetTCDeviceLevel()
  local MemorySize = Client.GetMemorySize()
  if mapID == 0 then
    if 5 <= MemorySize and 6 <= TCDeviceLevel then
      GameInstance:ExecuteCMD("gc.TimeBetweenPurgingPendingKillObjects", 60)
      log(bWriteLog and "[ClientEVOConfig] RevertGCIntervelFromMap gc.TimeBetweenPurgingPendingKillObjects 60")
    end
  elseif mapID == 1 and 5 <= MemorySize and 7 <= TCDeviceLevel then
    GameInstance:ExecuteCMD("gc.TimeBetweenPurgingPendingKillObjects", 60)
    log(bWriteLog and "[ClientEVOConfig] RevertGCIntervelFromMap gc.TimeBetweenPurgingPendingKillObjects 60")
  end
end
return ClientEVOConfig