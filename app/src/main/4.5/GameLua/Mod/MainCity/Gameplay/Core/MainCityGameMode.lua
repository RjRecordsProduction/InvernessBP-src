local MainCityGameMode = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local CacheMicphoneTlog = {}
function MainCityGameMode:ctor()
end
function MainCityGameMode:_PostConstruct()
  MainCityGameMode.__super._PostConstruct(self)
  self.bInitIgnoreMLAIType = true
end
function MainCityGameMode:ReceiveBeginPlay()
  MainCityGameMode.__super.ReceiveBeginPlay(self)
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    if not PlanPH_GamePlay_Tools.IsLocalBoot() then
      print(bWriteLog and "MainCityGameMode:ReceiveBeginPlay EnablePersistentObject")
      local maincity_persistent_object_utils = require("GameLua.Mod.MainCity.Gameplay.Utils.maincity_persistent_object_utils")
      maincity_persistent_object_utils.EnablePersistentObject()
    end
    local uPersistentLevel = CGameWorld.PersistentLevel
    if slua.isValid(uPersistentLevel) and slua.isValid(uPersistentLevel.WorldSettings) then
      uPersistentLevel.WorldSettings.bUseClientSideLevelStreamingVolumes = true
      print(bWriteLog and "MainCityGameMode:ReceiveBeginPlay bUseClientSideLevelStreamingVolumes set true")
    end
  end
  if self.InitConsoleVar and not Client then
    print(bWriteLog and "MainCityGameMode:ReceiveBeginPlay Call InitConsoleVar")
    self:InitConsoleVar("ds.PhysSubstepDisabled 1")
    self:InitConsoleVar("ReplayRecover.SerializeDSHUD 1")
    self:InitConsoleVar("net.EnableForceExit 1")
  end
  self:RemoveClassesForLowDevice()
end
function MainCityGameMode:ReceiveEndPlay(EndPlayReason)
  if UKismetSystemLibrary.IsDedicatedServer(self) then
    print(bWriteLog and "MainCityGameMode:ReceiveEndPlay DisablePersistentObject")
    local maincity_persistent_object_utils = require("GameLua.Mod.MainCity.Gameplay.Utils.maincity_persistent_object_utils")
    maincity_persistent_object_utils.DisablePersistentObject()
  end
  MainCityGameMode.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MainCityGameMode:PreInitGameState()
  print(bWriteLog and "MainCityGameMode:PreInitGameState")
end
function MainCityGameMode:InternalNotifyPlayerExit(uPlayerController)
  print(bWriteLog and "MainCityGameMode:InternalNotifyPlayerExit")
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "MainCityGameMode:InternalNotifyPlayerExit uPlayerController invalid")
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    print(bWriteLog and "MainCityGameMode:InternalNotifyPlayerExit uPlayerState invalid")
    return
  end
  local MicphoneTlog = uPlayerState.MicphoneTlog
  if not MicphoneTlog then
    print(bWriteLog and "MainCityGameMode:InternalNotifyPlayerExit MicphoneTlog nil")
    return
  end
  local nUID = uPlayerController.UID
  CacheMicphoneTlog[nUID] = {
    TeammateMicrophoneTime = MicphoneTlog.TeammateMicrophoneTime or 0,
    EnemyMicrophoneTime = MicphoneTlog.EnemyMicrophoneTime or 0
  }
  print(bWriteLog and string.format("MainCityGameMode:InternalNotifyPlayerExit TeammateMicrophoneTime=%s, EnemyMicrophoneTime=%s", tostring(CacheMicphoneTlog[nUID].TeammateMicrophoneTime), tostring(CacheMicphoneTlog[nUID].EnemyMicrophoneTime)))
end
function MainCityGameMode:RemoveClassesForLowDevice()
  if not Client then
    return
  end
  log(bWriteLog and "MainCityGameMode:RemoveClassesForLowDevice")
  local memopt = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.mem_opt)
  if memopt:EnableEnterMainCity() then
    return
  end
  log(bWriteLog and "MainCityGameMode:RemoveClassesForLowDevice start remove")
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local ClassCDO = STExtraGameplayStatics.GetClassDefaultObject(self:GetClass())
  if slua.isValid(ClassCDO) then
    ClassCDO.NewAIControllerClass = nil
    ClassCDO.DefaultPawnClass = nil
    ClassCDO.HUDClass = nil
  end
  self.NewAIControllerClass = nil
  self.DefaultPawnClass = nil
  self.HUDClass = nil
  log(bWriteLog and "MainCityGameMode:RemoveClassesForLowDevice finish remove")
end
function MainCityGameMode:GetPlayerMicphoneTlog(nUID)
  print(bWriteLog and string.format("MainCityGameMode:GetPlayerMicphoneTlog nUID=%s", tostring(nUID)))
  if nUID then
    return CacheMicphoneTlog[nUID] or {}
  end
  return {}
end
function MainCityGameMode:ClearPlayerMicphoneTlog(nUID)
  if nUID then
    CacheMicphoneTlog[nUID] = nil
  end
  print(bWriteLog and string.format("MainCityGameMode:ClearPlayerMicphoneTlog nUID=%s", tostring(nUID)))
end
function MainCityGameMode:GenReplayDone(errorMsg)
  print(bWriteLog and string.format("MainCityGameMode:GenReplayDone errorMsg[%s]", tostring(errorMsg)))
  if errorMsg ~= "" then
    GameplayCallbacks.MainCityGenReplayDone("fail", errorMsg)
  end
end
function MainCityGameMode:PlayerCanRestart(Player)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if UKismetSystemLibrary.IsStandalone(self.Object) then
    print(bWriteLog and "MainCityGameMode:PlayerCanRestart standalone return")
    return false
  end
  if not self:IsMatchInProgress() then
    return false
  end
  if not slua.isValid(Player) then
    return false
  end
  return Player:CanRestartPlayer()
end
local class = require("class")
local CGameModeBase = require("GameLua.GameCore.Framework.GameModeBase")
local CMainCityGameMode = class(CGameModeBase, nil, MainCityGameMode)
return CMainCityGameMode