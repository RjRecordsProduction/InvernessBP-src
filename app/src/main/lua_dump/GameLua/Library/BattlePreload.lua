local BattlePreload = {}
local EBattlePreloadStage = import("EBattlePreloadStage")
local KismetSystemLibrary = import("KismetSystemLibrary")
local FObjectPoolConfig = import("ObjectPoolConfig")
function BattlePreload:InitByLua()
  if Client then
    EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.OnModePreSwitch, self)
    EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH_END, self.OnModePreSwitchEnd, self)
    EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH_START, self.OnModePostSwitchStart, self)
    EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.OnModePostSwitch, self)
    EventSystem:registEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, self.OnGameModeStateChange, self)
    EventSystem:registEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self.OnBattleResult, self)
    EventSystem:registEvent(EVENTTYPE_INGAME_PLANESHOW, EVENTID_INGAME_PLANESHOW_END, self.OnPlaneShowEnd, self)
    return true
  end
end
function BattlePreload:OnBattleResult()
  log_shipping_client("BattlePreload:OnBattleResult")
  self:ResetPreloadState(true)
  local memopt = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.mem_opt)
  if memopt then
    memopt:DynamicDisableParticleStreamingOnPostLoad(true)
    print(bWriteLog and "BattlePreload:OnBattleResult DynamicDisableParticleStreamingOnPostLoad true")
  end
end
function BattlePreload:OnPlaneShowEnd()
  local memopt = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.mem_opt)
  if memopt then
    memopt:DynamicDisableParticleStreamingOnPostLoad(false)
    print(bWriteLog and "BattlePreload:OnPlaneShowEnd DynamicDisableParticleStreamingOnPostLoad false")
  end
end
function BattlePreload:IsEnabledByLua()
  if not Client then
    return false
  end
  local ScriptHelperEngine = import("ScriptHelperEngine")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client and Client.GetMemorySize() < 3 then
    log_shipping_client("BattlePreload:IsEnabledByLua false for low memory device: " .. tostring(Client.GetMemorySize()))
    return false
  end
  if Client.GetAndroidSOVersion() == 32 then
    log_shipping_client("BattlePreload:IsEnabledByLua false for Android 32 device: " .. tostring(Client.GetAndroidSOVersion()))
    return false
  end
  if self:IsObserver() then
    log_shipping_client("BattlePreload:IsEnabledByLua false for Observer")
    return false
  end
  log_shipping_client("BattlePreload:IsEnabledByLua true")
  return true
end
function BattlePreload:IsReEnterGame()
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  if logic_enter_game.PendingReEnterInfo then
    log_shipping_client("BattlePreload:IsReEnterGame true")
    return true
  end
  log_shipping_client("BattlePreload:IsReEnterGame false")
  return false
end
function BattlePreload:CheckNewObjectPoolConfigByLua(Config, bSpawning)
  log(bWriteLog and "BattlePreload:CheckNewObjectPoolConfigByLua")
  if self:IsReEnterGame() then
    return false
  end
  local AssetName = Config.ClassType:GetLongPackageName()
  if AssetName == "/Game/BluePrints/Core/BP_PlayerPawn" then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    local ModType, ModType2 = GameMainConfig.GetModType()
    if ModType ~= "BaseMod" and ModType2 ~= "BaseMod" then
      log(bWriteLog and string.format("BattlePreload:CheckNewObjectPoolConfigByLua failed not BaseMod ModType:%s, ModType2:%s", tostring(ModType), tostring(ModType2)))
      return false
    end
  end
  return true
end
function BattlePreload:ModifyNewObjectPoolConfigByLua(Config)
  log(bWriteLog and "BattlePreload:ModifyNewObjectPoolConfigByLua")
  local Modified  if self:IsReEnterGame() then
    ModifiedConfig.InitCapacity = ModifiedConfig.InitCapacity / 2
    log(bWriteLog and "BattlePreload:ModifyNewObjectPoolConfigByLua set capacity to half")
  end
  return ModifiedConfig
end
function BattlePreload:OnModePreSwitch(_, __, Statuses)
  self._bCacheCanAddStageToProcessingQueue = nil
  local PreGameStatus = Statuses.pre
  local NextGameStatus = Statuses.current
  log(bWriteLog and string.format("BattlePreload:OnModePreSwitch PreGameStatus: %s, NextGameStatus: %s", PreGameStatus, NextGameStatus))
  if PreGameStatus == GameStatus.Login and NextGameStatus == GameStatus.Lobby then
    self:LuaAddStageToProcessingQueue(EBattlePreloadStage.LoginToLobby)
  end
  if PreGameStatus == GameStatus.Lobby and NextGameStatus == GameStatus.Fighting then
    self:LuaAddStageToProcessingQueue(EBattlePreloadStage.LobbyToFighting)
  end
end
function BattlePreload:OnModePreSwitchEnd(_, __, Status)
  log(bWriteLog and string.format("BattlePreload:OnModePreSwitchEnd GameStatus: %s", Status))
end
function BattlePreload:OnModePostSwitchStart(_, __, Statuses)
  local PreGameStatus = Statuses.pre
  local CurrentGameStatus = Statuses.current
  log(bWriteLog and string.format("BattlePreload:OnModePostSwitchStart PreGameStatus: %s, CurrentGameStatus: %s", PreGameStatus, CurrentGameStatus))
end
function BattlePreload:OnModePostSwitch(_, __, Statuses)
  local PreGameStatus = Statuses.pre
  local CurrentGameStatus = Statuses.current
  log(bWriteLog and string.format("BattlePreload:OnModePostSwitch PreGameStatus: %s, CurrentGameStatus: %s", PreGameStatus, CurrentGameStatus))
  if IsEditor and PreGameStatus == "None" and CurrentGameStatus == GameStatus.Fighting then
    self:LuaAddStageToProcessingQueue(EBattlePreloadStage.LobbyToFighting)
  end
  if CurrentGameStatus == GameStatus.Fighting then
    self:LuaAddStageToProcessingQueue(EBattlePreloadStage.Fighting_BeforeReadyState)
  end
  if CurrentGameStatus == GameStatus.Lobby then
    self:LuaAddStageToProcessingQueue(EBattlePreloadStage.Other)
    if PreGameStatus == GameStatus.Fighting then
      self:ResetPreloadState(true)
      self._bCacheCanAddStageToProcessingQueue = nil
    end
  end
end
function BattlePreload:OnGameModeStateChange(_, __, State)
  log(bWriteLog and string.format("BattlePreload:OnGameModeStateChange State: %s", State))
  if State == "ReadyState" then
    self:LuaAddStageToProcessingQueue(EBattlePreloadStage.Fighting_ReadyState)
  end
  if State == "FightingState" then
    self:LuaAddStageToProcessingQueue(EBattlePreloadStage.Other)
  end
end
function BattlePreload:IsObserver()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    return (not uPlayerController.IsObserver or not uPlayerController:IsObserver()) and uPlayerController.IsDemoPlayGlobalObserver and uPlayerController:IsDemoPlayGlobalObserver()
  end
  return false
end
function BattlePreload:LuaAddStageToProcessingQueue(Stage)
  if not self:CanAddStageToProcessingQueue() then
    return
  end
  self:AddStageToProcessingQueue(Stage)
end
function BattlePreload:CanAddStageToProcessingQueue()
  if self._bCacheCanAddStageToProcessingQueue == nil then
    self._bCacheCanAddStageToProcessingQueue = true
    if self:IsCreativeMode() then
      local TCDeviceLevel = 7
      if Client then
        TCDeviceLevel = Client.GetTCDeviceLevel()
      end
      if TCDeviceLevel <= 3 then
        self._bCacheCanAddStageToProcessingQueue = false
      end
    end
  end
  return self._bCacheCanAddStageToProcessingQueue
end
function BattlePreload:IsCreativeMode()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if LogicUGC and LogicUGC:IsUGCGameMod() then
    return true
  end
  return false
end
local class = require("class")
local object = require("object")
return class(object, nil, BattlePreload)