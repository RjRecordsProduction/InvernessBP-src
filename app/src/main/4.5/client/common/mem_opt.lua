local mem_opt = {
  pandora_released = false,
  gamelet_released = false,
  release_asset = false
}
local ReleaseLobbyPawnClass = function()
  local LobbyPawnPool = require("client.logic.avatar.lobby_pawn_pool")
  LobbyPawnPool.ReleasePawnClass()
end
local OptOnPostBackToLobby = function()
  log(bWriteLog and "OptOnBackToLobby")
  if mem_opt.release_asset then
    Client.MemOptSetGameState(1)
    Client.MemOption(32)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseBPClassManager", false) then
    Client.MemOption(16)
  end
  Client.RemoveBPClassManager()
  if not GameStatus.IsInMainCity() and HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseInGameUIManager", false) then
    slua_GameFrontendHUD:ReleaseInGameUIManager()
    slua_GameFrontendHUD:CreateInGameUIManager()
  end
  Client.ReleaseGameEnginePlaybackComp(HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseGameEnginePlaybackComp2", 10))
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ForceReleaseAIController", false) then
    Client.MemOption(21)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseLuaModule", false) then
    for ModulePath, Module in pairs(_G.package.loaded) do
      if string.find(ModulePath, "GameLua.Mod.") then
        if string.find(ModulePath, "BaseMod") then
          if not string.find(ModulePath, "Common") then
            log(bWriteLog and "[kh] OptOnBackToLobby: ReleaseModule: " .. ModulePath)
            _G.package.loaded[ModulePath] = nil
          end
        elseif not string.find(ModulePath, "MainCity") and not string.find(ModulePath, "Lobby") and not string.find(ModulePath, "PlanPH") then
          log(bWriteLog and "[kh] OptOnBackToLobby: ReleaseModule: " .. ModulePath)
          _G.package.loaded[ModulePath] = nil
        end
      end
    end
  end
end
local OptOnPreEnterGame = function()
  log(bWriteLog and "OptOnEnterGame")
  if mem_opt.release_asset then
    Client.MemOptSetGameState(3)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseInGameUIManager", false) then
    slua_GameFrontendHUD:ReleaseInGameUIManager()
    slua_GameFrontendHUD:CreateInGameUIManager()
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseGameletEnvMgrInstance", false) then
    Client.MemOption(14)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("RelaseGameletPuertsEnvMgr", false) then
    Client.MemOption(15)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseLuaBlueprintSysMgr", 0) == 1 then
    slua_GameFrontendHUD:ReleaseLuaBlueprintSysMgr()
  end
  ReleaseLobbyPawnClass()
end
local OptOnPreBackToLobby = function()
  if mem_opt.release_asset then
    Client.MemOptSetGameState(3)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseLuaBlueprintSysMgr", 0) == 1 then
    slua_GameFrontendHUD:ReleaseLuaBlueprintSysMgr()
  end
  if mem_opt.pandora_released then
    local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    pandoraSystem.Init()
    mem_opt.pandora_released = false
  end
  if mem_opt.gamelet_released then
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    gamelet_interface:Open()
    mem_opt.gamelet_released = false
  end
end
local OptOnPostEnterGame = function()
  if mem_opt.release_asset then
    Client.MemOptSetGameState(2)
    Client.MemOption(32)
  end
  local enable = HDmpveRemote.HDmpveRemoteConfigGetInt("IngamePGSwitcher", 0)
  if enable < Client.GetMemorySize() then
    return
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if not PlanPH_GamePlay_Tools.IsPHomeMode() then
    if not mem_opt.pandora_released and HDmpveRemote.HDmpveRemoteConfigGetBool("ReleasePandoraInGame", true) then
      log(bWriteLog and "[kh] ReleasePandoraInGame")
      local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
      pandoraSystem.Release()
      mem_opt.pandora_released = true
    end
    if not mem_opt.gamelet_released and HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseGameletInGame", true) then
      local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
      gamelet_interface:Close()
      mem_opt.gamelet_released = true
    end
  end
end
function mem_opt:OnInitialize()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  if HDmpveRemote.HDmpveRemoteConfigGetBool("MigrateIndexToMmap", false) then
    Client.FeatureGuardSet("MigrateIndexToMmap", true)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("MigrateIndexToMmapBasePak", false) then
    Client.FeatureGuardSet("MigrateIndexToMmapBasePak", true)
  end
  if mem_opt.release_asset then
    GameInstance:ExecuteCMD("s.AutoManagerActiveHandles", 1)
  end
  if _G.IsEditor then
    GameInstance:ExecuteCMD("gc.TimeBetweenPurgingPendingKillObjects", 1800)
    log(bWriteLog and "[mem_opt] OnInitialize EditorPIE gc.TimeBetweenPurgingPendingKillObjects 1800")
  end
  local memSize = Client.GetMemorySize()
  if 4 <= memSize then
    local GCVerifier = HDmpveRemote.HDmpveRemoteConfigGetInt("LLuaGCMemVerifier430", 0)
    if 0 < GCVerifier then
      GameInstance:ExecuteCMD("gc.LLuaGCMemVerifier", GCVerifier + memSize)
    end
  end
  if Client.GetMemorySize() <= 4 then
    Client.DisableSysCache()
    GameInstance:ExecuteCMD("diy.EnableDecalBakingRTCache", 0)
    if Client.GetMemorySize() <= 4 then
      if HDmpveRemote.HDmpveRemoteConfigGetBool("MemOptLowMem400Switch", false) then
        local STExtraGameInstance = import("STExtraGameInstance")
        local GameInstance = STExtraGameInstance.GetInstance()
        if HDmpveRemote.HDmpveRemoteConfigGetBool("MemOptLowMem400Switch1", false) then
          GameInstance:ExecuteCMD("z.EnableBattlePreload", 0)
        end
        if HDmpveRemote.HDmpveRemoteConfigGetBool("MemOptLowMem400Switch2", false) then
          GameInstance:ExecuteCMD("am.EnablePreloadAnimInGame", 0)
        end
        local PoolSize = HDmpveRemote.HDmpveRemoteConfigGetInt("MemOptLowMem400Switch3", 0)
        if PoolSize ~= 0 then
          GameInstance:ExecuteCMD("r.Streaming.PoolSize", PoolSize)
        end
        if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableLegacyFontDataCache", false) then
          GameInstance:ExecuteCMD("s.EnableLegacyFontDataCache", 0)
        end
      end
      if HDmpveRemote.HDmpveRemoteConfigGetBool("MemOptLowMem410SwitchObjectPool", false) then
        GameInstance:ExecuteCMD("g.EnableNewObjectPool", 0)
      end
      if HDmpveRemote.HDmpveRemoteConfigGetBool("GCOnLoadMap", false) then
        GameInstance:ExecuteCMD("Engine.TickGCWhenTravelWorld", 1)
      end
      if HDmpveRemote.HDmpveRemoteConfigGetBool("GCInterval", false) then
        GameInstance:ExecuteCMD("gc.TimeBetweenPurgingPendingKillObjects", 20)
      end
      local MapLoadOffset = HDmpveRemote.HDmpveRemoteConfigGetInt("MapLoadOffset", 0)
      if MapLoadOffset ~= 0 then
        GameInstance:ExecuteCMD("r.LevelStreamingDistanceOffset", MapLoadOffset)
      end
      if HDmpveRemote.HDmpveRemoteConfigGetBool("DropStreamingMips", false) then
        GameInstance:ExecuteCMD("r.Streaming.DropMips", 2)
      end
      if HDmpveRemote.HDmpveRemoteConfigGetBool("DisableGCCluster", false) then
        GameInstance:ExecuteCMD("gc.CreateGCClusters", 0)
      end
      GameInstance:ExecuteCMD("kh.LazyCreateMainCity", HDmpveRemote.HDmpveRemoteConfigGetInt("LazyCreateMainCity", 0))
      GameInstance:ExecuteCMD("pakcache.NumUnreferencedBlocksToCache", HDmpveRemote.HDmpveRemoteConfigGetInt("NumUnreferencedBlocksToCache", 10))
      GameInstance:ExecuteCMD("s.LevelStreamingOptSpecial.MaxUnLoadLevelGCMemoryThresholds", HDmpveRemote.HDmpveRemoteConfigGetInt("MaxUnLoadLevelGCMemoryThresholds", 50000))
    end
    GameInstance:ExecuteCMD("s.LDisablePreloadPackage", HDmpveRemote.HDmpveRemoteConfigGetInt("DisablePreloadPackage", 0))
    if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseAnim", false) then
      GameInstance:ExecuteCMD("am.SupportUGCAnim", 0)
      GameInstance:ExecuteCMD("anim.ReleaseAnimLoadHandles", 2)
    end
    if HDmpveRemote.HDmpveRemoteConfigGetBool("DefragMetalHeap", false) then
      GameInstance:ExecuteCMD("rhi.Metal.HeapDefragUnderUtilisedFraction", 0.3)
      GameInstance:ExecuteCMD("rhi.Metal.HeapMemToDefragPerFrame", 8388608)
    end
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("SluaPredestruct", false) then
    GameInstance:ExecuteCMD("slua.predestruct", 1)
  end
  GameInstance:ExecuteCMD("gc.LLuaGCMemVerifier", HDmpveRemote.HDmpveRemoteConfigGetInt("LLuaGCMemVerifier", 0))
  if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableCloseCacheFlag", true) then
    local FilePath = Client.ProjectSavedDir() .. "/Paks/CloseCacheFlag_350"
    Client.DeleteFile(FilePath)
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local DocumentDir = Client.GetPureIOSDocumentsDirectory()
    local DefaultAnsiMemSize = HDmpveRemote.HDmpveRemoteConfigGetInt("DefaultAnsiMallocIOS_430MemSize", 4000)
    local EnableAnsiMallocIOS_430 = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableAnsiMallocIOS_430", 0)
    if 0 < EnableAnsiMallocIOS_430 or DefaultAnsiMemSize <= Client.GetMemorySize() then
      local AnsiFlagPath = DocumentDir .. "/ansi.flag"
      log(bWriteLog and "[kh] EnableAnsiMallocIOS_430 " .. tostring(EnableAnsiMallocIOS_430) .. " DefaultAnsiMemSize:" .. tostring(DefaultAnsiMemSize))
      local file = io.open(AnsiFlagPath, "w")
      if file then
        file:write("1")
        file:close()
      end
    end
    local EnableBinnedMallocIOS_430 = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableBinnedMallocIOS_430", 0)
    if 0 < EnableBinnedMallocIOS_430 then
      log(bWriteLog and "[kh] EnableBinnedMallocIOS_430 EnableBinnedMallocIOS_430" .. tostring(EnableBinnedMallocIOS_430))
      local BinnedFlagPath = DocumentDir .. "/Binned.flag"
      local file = io.open(BinnedFlagPath, "w")
      if file then
        file:write("1")
        file:close()
      end
    end
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("MemOpt400SwapMemory", true) and Client.GetDevicePlatformName() == "Android" then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerLoop(0, function()
      Client.SuppressSwap()
    end, TIMER_INFINITE, 30)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("MonitorFootprintEveryFrame", false) then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerLoop(0, function()
      local memoryStatus = Client.GetMemoryStats()
      log(bWriteLog and "[kh] footprint: " .. memoryStatus.UsedPhysical / 1024.0 / 1024.0 .. " MB")
    end, TIMER_INFINITE, time_ticker.NEXT_FRAME)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("EnableBattleSubsystem", true) then
    GameInstance:ExecuteCMD("kh.battlesubsystem.enable.AESpawnSubsystem", 1)
    GameInstance:ExecuteCMD("kh.battlesubsystem.enable.weaponeffect", 1)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleasePxShapeInBodyInstance", true) then
    GameInstance:ExecuteCMD("p.ReleaseNpShapeInDestor", 1)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("iOSSkipUnusedShaderSerialize", true) then
    GameInstance:ExecuteCMD("r.SkipUnusedShaderSerialize", 1)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseInGameUIManager", false) then
    function LuaClassObj.GetGameStatus()
      return GameStatus.GetGameStatus()
    end
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ShrinkDrawBufferOnSUIParticleDestory", false) then
    GameInstance:ExecuteCMD("r.ShrinkDrawBufferEnable", 1)
    Client.ShrinkDrawBuffer()
  end
  if Client.GetMemorySize() <= Client.LowMemoryInGB() then
    GameInstance:ExecuteCMD("kh.battlesubsystem.enable", HDmpveRemote.HDmpveRemoteConfigGetInt("EnableButtleSubsystem", 0))
    GameInstance:ExecuteCMD("kh.battlesubsystem.login.enable", HDmpveRemote.HDmpveRemoteConfigGetInt("EnableLoginSubSystem", 0))
    GameInstance:ExecuteCMD("kh.battlesubsystem.lobby.enable", HDmpveRemote.HDmpveRemoteConfigGetInt("EnableLobbySubSystem", 0))
    GameInstance:ExecuteCMD("kh.battlesubsystem.maincity.enable", HDmpveRemote.HDmpveRemoteConfigGetInt("EnableMainCitySubSystem", 0))
  end
  GameInstance:ExecuteCMD("kh.stupidpdralloc", HDmpveRemote.HDmpveRemoteConfigGetInt("EnablePdrStupidAlloc", 0))
  GameInstance:ExecuteCMD("kh.TransferActor", HDmpveRemote.HDmpveRemoteConfigGetInt("kh.TransferActor", 15))
  GameInstance:ExecuteCMD("am.ReleaseCacheAnimContainerInstances", HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseCacheAnimContainerInstances", 0))
  GameInstance:ExecuteCMD("S.UseBackpackSubsystem", HDmpveRemote.HDmpveRemoteConfigGetInt("UseBackpackSubsystem", 0))
  if HDmpveRemote.HDmpveRemoteConfigGetBool("RegisterOOMReport", true) then
    Client.MemOption(23)
  end
  GameInstance:ExecuteCMD("r.LReleaseUAEDataTable", HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseUAEDataTable", 0))
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseOodleLeak", false) then
    Client.SaveStringToFile("1", "oodle.flag")
  end
end
function mem_opt:OnPreSwitchGameStatus(preState, nextState)
  if preState == nextState then
    return
  end
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) then
    OptOnPreEnterGame()
  elseif GameStatus.IsInLobbyOrMainCity() then
    OptOnPreBackToLobby()
  else
    ReleaseLobbyPawnClass()
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("MemOpt400Switch", true) then
    Client.ClearSluaClassCache()
    Client.MemOption(0)
    local UAvatarUtils = import("AvatarUtils")
    local UBackpackUtils = import("BackpackUtils")
    UBackpackUtils.ClearItemExistCache()
    Client.MemOption(3)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleasePostProcessingRT", false) then
    Client.MemOption(1)
  end
  Client.ReleaseGameEnginePlaybackComp(HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseGameEnginePlaybackComp0", 10))
  Client.ReleaseGameEnginePlaybackComp(HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseGameEnginePlaybackComp1", 10))
  Client.ReleaseGameEnginePlaybackComp(HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseGameEnginePlaybackComp5", 10))
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseWeaponBPUtils", false) then
    Client.MemOption(4)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseDeathPlaybackUtils", false) then
    Client.MemOption(5)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseSTExtraUIUtils", false) then
    Client.MemOption(6)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseSTExtraDelegateMgr", false) then
    Client.MemOption(7)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseLuaDamageInfo", false) then
    Client.MemOption(8)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseSTExtraModLogicSwitchLibrary", false) then
    Client.MemOption(9)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseLobbyWeaponManagerComponent", false) then
    Client.MemOption(10)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseSJKAssetUtils", false) then
    Client.MemOption(11)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseLuaShootWeaponDamageInfo", false) then
    Client.MemOption(12)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ClearPSO", false) then
    Client.MemOption(13)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseUAETableManager", false) then
    Client.MemOption(17)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseAvatarAssetBPUtils", false) then
    Client.MemOption(18)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseLuaPlayerStartInfo", false) then
    Client.MemOption(19)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseClothAvatarUtils", false) then
    Client.MemOption(22)
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("s.CanReleaseLegacyFontDataCache", HDmpveRemote.HDmpveRemoteConfigGetInt("ReleaseLegacyFontDataCache", 0))
end
function mem_opt:OnPostSwitchGameStatus(preState, nextState)
  if preState == nextState then
    return
  end
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    OptOnPostBackToLobby()
  elseif GameStatus.IsInFightingNotMainCity() then
    OptOnPostEnterGame()
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseRTPoolResources", false) then
    Client.ReleaseRTPoolResources()
  end
  if GameStatus.IsIn2DLobby() and Client.GetMemorySize() <= Client.LowMemoryInGB() and HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseAutoNavInLobby", false) then
    Client.MemOption(24)
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseAllTables", false) then
    Client.ReleaseAllTables()
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(3, function()
    if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseBodySetupInSprite", false) then
      Client.MemOption(27)
    end
    if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseBodySetupInPaperTileMap", false) then
      Client.MemOption(28)
    end
    if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseBodySetupInPaperTerrainComponent", false) then
      Client.MemOption(29)
    end
  end)
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseOodleLeak", false) then
    time_ticker.AddTimerOnce(3, function()
      Client.MemOption(26)
    end)
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  if STExtraGameInstance then
    local GameInstance = STExtraGameInstance.GetInstance()
    GameInstance:ExecuteCMD("r.ShrinkSlateBuffer", HDmpveRemote.HDmpveRemoteConfigGetInt("ShrinkSlateBuffer", 0))
  end
  if HDmpveRemote.HDmpveRemoteConfigGetBool("AggressiveGC", false) then
    Client.MemOption(34)
  end
  Client.TrimEngineMemory()
end
function mem_opt:EnableEnterMainCity()
  if Client and Client.GetMemorySize() <= Client.LowMemoryInGB() then
    return HDmpveRemote.HDmpveRemoteConfigGetBool("EnableEnterMainCity", true)
  end
  return true
end
function mem_opt:DynamicDisableParticleStreamingOnPostLoad(disable)
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local DynamicDisableParticleStreamingOnPostLoad = HDmpveRemote.HDmpveRemoteConfigGetInt("DynamicDisableParticleStreamingOnPostLoad", 1)
  if DynamicDisableParticleStreamingOnPostLoad == 0 then
    return
  end
  if disable then
    gameInstance:ExecuteCMD("r.CVarParticleDisableStreamingOnPostLoad", 1)
  else
    gameInstance:ExecuteCMD("r.CVarParticleDisableStreamingOnPostLoad", 0)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local cmem_opt = class(CModuleBase, nil, mem_opt)
return cmem_opt