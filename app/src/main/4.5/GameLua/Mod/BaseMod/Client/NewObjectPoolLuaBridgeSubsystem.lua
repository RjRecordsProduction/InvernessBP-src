local EObjectPoolFenceType = import("EObjectPoolFenceType")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local FObjectPoolConfig = import("ObjectPoolConfig")
local TimeUtil = require("client.common.time_util")
local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
local NewObjectPoolLuaBridgeSubsystem = {}
local DynamicAddClassList = {
  {
    AvaialableMods = {BaseMod = true},
    ClassType = "/Game/BluePrints/Core/BP_PlayerPawn.BP_PlayerPawn_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    ClassType = "/Game/Mod/LootTruck/Arts_PlayerBluePrints/VH_LootTruck.VH_LootTruck_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 2,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {EasternRealm = true},
    ClassType = "/Game/Mod/EasternRealm/BluePrints/Core/BP_PlayerCharacter_EasternRealm.BP_PlayerCharacter_EasternRealm_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {Neon = true},
    ClassType = "/Game/Mod/Neon/BluePrints/Core/BP_PlayerCharacter_Neon.BP_PlayerCharacter_Neon_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {ZNQ7th = true},
    AvailableMaps = {
      Baltic_Main = true,
      PUBG_Desert = true,
      PUBG_Savage_Main = true
    },
    ClassType = "/Game/Mod/ZNQ7th/BluePrints/Core/BP_PlayerCharacter_ZNQ7th.BP_PlayerCharacter_ZNQ7th_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {ZNQ7th = true},
    AvailableMaps = {FourMaps_Main = true},
    ClassType = "/Game/Mod/ZNQ7th/BluePrints/Core/Livik/BP_PlayerCharacter_ZNQ7th_Livik.BP_PlayerCharacter_ZNQ7th_Livik_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {ZNQ7th = true},
    AvailableMaps = {PUBG_Neon_Main = true},
    ClassType = "/Game/Mod/ZNQ7th/BluePrints/Core/Neon/BP_PlayerCharacter_ZNQ7th_Neon.BP_PlayerCharacter_ZNQ7th_Neon_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {SteamTrain = true},
    AvailableMaps = {Baltic_Main = true},
    ClassType = "/Game/Mod/SteamTrain/BluePrints/Core/BP_PlayerCharacter_SteamTrain.BP_PlayerCharacter_SteamTrain_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {SteamTrain = true},
    AvailableMaps = {FourMaps_Main = true},
    ClassType = "/Game/Mod/SteamTrain/BluePrints/Core/Livik/BP_PlayerCharacter_SteamTrain_Livik.BP_PlayerCharacter_SteamTrain_Livik_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {BaseMod = true},
    ClassType = "/Game/Mod/SteamTrain/BluePrints/Core/Neon/BP_PlayerCharacter_SteamTrain_Neon.BP_PlayerCharacter_SteamTrain_Neon_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {PlanBT = true},
    ClassType = "/Game/Mod/PlanBT/BluePrints/Actor/BP_Monster.BP_Monster_C",
    bRecyclable = true,
    bRecreateWhenRecycle = true,
    InitCapacity = 20,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {IceWorld4 = true},
    AvailableMaps = {Baltic_Main = true},
    ClassType = "/Game/Mod/IceWorld4/BluePrints/Core/BP_PlayerCharacter_IceWorld4.BP_PlayerCharacter_IceWorld4_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {IceWorld4 = true},
    AvailableMaps = {DihorOtok_Main = true},
    ClassType = "/Game/Mod/IceWorld4/BluePrints/Core/DihorOtok/BP_PlayerCharacter_IceWorld4_DihorOtok.BP_PlayerCharacter_IceWorld4_DihorOtok_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  },
  {
    AvaialableMods = {IceWorld4 = true},
    AvailableMaps = {FourMaps_Main = true},
    ClassType = "/Game/Mod/IceWorld4/BluePrints/Core/Livik/BP_PlayerCharacter_IceWorld4_Livik.BP_PlayerCharacter_IceWorld4_Livik_C",
    bRecyclable = false,
    bRecreateWhenRecycle = false,
    InitCapacity = 40,
    BackendSwitcherCBit = 3,
    ClientSwitcher = 1
  }
}
function NewObjectPoolLuaBridgeSubsystem:ctor()
  self.SpawnActorCounter_Character = 0
  self.StartTimeStamp = TimeUtil.GetServerTimeInSec()
end
function NewObjectPoolLuaBridgeSubsystem:CheckConfig(Config)
  local ModType, ModType2 = GameMainConfig.GetModType()
  if not ModType or ModType == "" then
    ModType = "BaseMod"
  end
  local MapName = CGame:GetMapName()
  log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:CheckConfig Config ClassType: " .. Config.ClassType)
  log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:CheckConfig ModType: " .. ModType .. " ModType2: " .. ModType2)
  log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:CheckConfig MapName: " .. MapName)
  local Res = true
  if not Config.AvaialableMods or not Config.AvaialableMods[ModType] then
    log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:CheckConfig Mod not Avaialable, ModType: " .. ModType)
    return false
  end
  if Config.AvailableMaps ~= nil and not Config.AvailableMaps[MapName] then
    log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:CheckConfig Map not Avaialable, MapName: " .. MapName)
    return false
  end
  return true
end
function NewObjectPoolLuaBridgeSubsystem:OnInit()
  local SubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
  local NewObjectPoolSystemClass = import("NewObjectPoolSystem")
  self.NewObjectPoolSystem = SubsystemBlueprintLibrary.GetWorldSubsystem(CGameWorld, NewObjectPoolSystemClass)
  local ModeID = GameMainConfig.GetModeID()
  local ModType, ModeType2 = GameMainConfig.GetModType()
  ModType = ModType or ""
  if not ModType or ModType == "" then
    ModType = "BaseMod"
  end
  if not self.NewObjectPoolSystem then
    return
  end
  if not self.NewObjectPoolSystem:GetInited() then
    return
  end
  local soVersion = Client.GetAndroidSOVersion()
  local allow32Device = soVersion and soVersion == 32 and HDmpveRemote.HDmpveRemoteConfigGetBool("DisableObjectPool32", false)
  if Client.GetMemorySize() < 2 or allow32Device then
    log_shipping_client("NewObjectPoolLuaBridgeSubsystem:OnInit Disable for low memory")
    return
  end
  for i, Config in ipairs(DynamicAddClassList) do
    local ObjectPoolConfig = FObjectPoolConfig()
    if self:CheckConfig(Config) then
      for Prop, Val in pairs(Config) do
        if Prop == "ClassType" then
          ObjectPoolConfig.ClassType = FSoftObjectPtr(Config.ClassType)
        elseif ObjectPoolConfig[Prop] ~= nil then
          ObjectPoolConfig[Prop] = Val
        end
      end
      self.NewObjectPoolSystem:Add(ObjectPoolConfig)
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
    [1] = "FightingState"
  }, self.HandleEnterGame, self)
end
function NewObjectPoolLuaBridgeSubsystem:OnRelease()
  local ModType, _ = GameMainConfig.GetModType()
  local TimeDuration = TimeUtil.GetServerTimeInSec() - self.StartTimeStamp
  local ReportInfo = string.format("DeviceLevel: %d, PlayerLevel:%d, ModType: %s,TimeDuration:%d, CharacterSpawnCount: %d", Client.GetExactDeviceLevel(), DataMgr.roleData.level, ModType, TimeDuration, self.SpawnActorCounter_Character)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SpawnCounter_Character, nil, ReportInfo, true)
  log_shipping_client("NewObjectPoolLuaBridgeSubsystem:OnRelease " .. ReportInfo)
  if self.NewObjectPoolSystem and slua.isValid(self.NewObjectPoolSystem) then
    self.NewObjectPoolSystem:ClearAll(false)
  end
  NewObjectPoolLuaBridgeSubsystem.__super.OnRelease(self)
end
function NewObjectPoolLuaBridgeSubsystem:HandleEnterGame()
  log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:HandleEnterGame")
  self.StartTimeStamp = TimeUtil.GetServerTimeInSec()
  if self.NewObjectPoolSystem and slua.isValid(self.NewObjectPoolSystem) then
    self.NewObjectPoolSystem:RemoveFence(EObjectPoolFenceType.Spawning, "ReadyState")
    log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:HandleEnterGame Remove ReadyState fence to enable new object pool")
  end
end
function NewObjectPoolLuaBridgeSubsystem:PauseSpawnFromPool(bPause)
  log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:PauseSpawnFromPool")
  if self.NewObjectPoolSystem and slua.isValid(self.NewObjectPoolSystem) then
    if bPause then
      self.NewObjectPoolSystem:CreateFence(EObjectPoolFenceType.Spawning, "LuaPauseSpawn")
    else
      self.NewObjectPoolSystem:RemoveFence(EObjectPoolFenceType.Spawning, "LuaPauseSpawn")
    end
  end
end
function NewObjectPoolLuaBridgeSubsystem:PauseAutoCreateObjectInPool(bPause)
  log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:PauseAutoCreateObjectInPool")
  if self.NewObjectPoolSystem and slua.isValid(self.NewObjectPoolSystem) then
    if bPause then
      self.NewObjectPoolSystem:CreateFence(EObjectPoolFenceType.Ticking, "LuaPauseTick")
    else
      self.NewObjectPoolSystem:RemoveFence(EObjectPoolFenceType.Ticking, "LuaPauseTick")
    end
  end
end
function NewObjectPoolLuaBridgeSubsystem:PauseRecycleToPool(bPause)
  log(bWriteLog and "NewObjectPoolLuaBridgeSubsystem:PauseRecycleToPool")
  if self.NewObjectPoolSystem and slua.isValid(self.NewObjectPoolSystem) then
    if bPause then
      self.NewObjectPoolSystem:CreateFence(EObjectPoolFenceType.Recycling, "LuaPauseRecycle")
    else
      self.NewObjectPoolSystem:RemoveFence(EObjectPoolFenceType.Recycling, "LuaPauseRecycle")
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, NewObjectPoolLuaBridgeSubsystem)