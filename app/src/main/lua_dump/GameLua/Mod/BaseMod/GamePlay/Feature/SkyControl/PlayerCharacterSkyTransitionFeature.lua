local KismetSystemLibrary = import("KismetSystemLibrary")
local ECollisionChannel = import("ECollisionChannel")
local TableUtil = require("common.table_util")
local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PlayerCharacterSkyTransitionFeature = {}
local DefaultConfig = {StateId = 1, ParachuteEnsureCheck = true}
function PlayerCharacterSkyTransitionFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "StateChangedTime",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    }
  }
end
function PlayerCharacterSkyTransitionFeature:_PostConstruct()
  PlayerCharacterSkyTransitionFeature.__super._PostConstruct(self)
  self.FeatureConfig = TableUtil.DeepCloneTable(DefaultConfig)
  self.StateChangedTime = GamePlayTools.GetServerWorldTimeSeconds(self.Owner)
  self.EventDelegate = FeatureUtil.LuaDelegate()
  local SkyTransitionUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.SkyControl.SkyTransitionUtil")
  self.SkyTransitionConfig = SkyTransitionUtil.ParseSkyTransitionConfig()
  if not self.SkyTransitionConfig then
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:_PostConstruct SkyTransition is not enable, return"))
    return
  end
  self.StateMachine:Init(self.SkyTransitionConfig.States, self.SkyTransitionConfig.InitStateId)
  self:Reset()
  if Client then
    self.StateMachine:OnStateChanged(self.OnClientStateChanged, self)
    if self.Owner.HandleParachuteStateChangedOver then
      self:AddControlEvent(self.Owner, "HandleParachuteStateChangedOver", self.SkyTransitionHandleParachuteStateChangedOver, self)
    end
  end
end
function PlayerCharacterSkyTransitionFeature:ReceiveEndPlay(EndPlayReason)
  if EndPlayReason == import("EEndPlayReason").Destroyed and self.EventDelegate then
    self.EventDelegate:Dispose()
  end
  PlayerCharacterSkyTransitionFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerCharacterSkyTransitionFeature:SkyTransitionHandleParachuteStateChangedOver(ParachuteState)
  if not self.FeatureConfig.ParachuteEnsureCheck then
    return
  end
  local LastParachuteState = self.Owner.LastHandleParachuteState
  local EParachuteState = import("EParachuteState")
  if LastParachuteState ~= EParachuteState.PS_None and ParachuteState == EParachuteState.PS_None then
    local StateId = self.StateMachine:GetState()
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:SkyTransitionHandleParachuteStateChangedOver %s StateId = %s", self:ToString(), StateId))
    local PlayerController = self:GetMatchController()
    if slua.isValid(PlayerController) then
      PlayerController.SkyTransition:ForceRefreshState(StateId)
    end
  end
end
function PlayerCharacterSkyTransitionFeature:OnClientStateChanged()
  local StateId = self.StateMachine:GetState()
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:OnClientStateChanged %s StateId = %s, StateChangedTime = %s", self:ToString(), StateId, self.StateChangedTime))
  local PlayerController = self:GetMatchController()
  if slua.isValid(PlayerController) then
    self.EventDelegate:Broadcast("OnSkyTransitionStateChanged", StateId, self.StateChangedTime)
    local TriggerMode = self:GetTriggerMode(StateId)
    if TriggerMode == "Custom" then
      print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:OnClientStateChanged TriggerMode is Custom, return"))
      return
    end
    self:RefreshControllerState()
  else
    self.IsPlayerControllerNotReady = true
  end
end
function PlayerCharacterSkyTransitionFeature:RecheckClientState()
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:RecheckClientState self.IsPlayerControllerNotReady = %s", self.IsPlayerControllerNotReady))
  if self.IsPlayerControllerNotReady then
    self.IsPlayerControllerNotReady = nil
    self:OnClientStateChanged()
  end
end
function PlayerCharacterSkyTransitionFeature:GetTriggerMode(StateId)
  local Config = self:GetConfig(StateId)
  if Config and Config.OriginSkyTransitionConfig then
    return Config.OriginSkyTransitionConfig.TriggerMode
  end
end
function PlayerCharacterSkyTransitionFeature:RefreshControllerState()
  local StateId = self.StateMachine:GetState()
  local PlayerController = self:GetMatchController()
  if slua.isValid(PlayerController) then
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:RefreshControllerState %s StateId = %s, StateChangedTime = %s", self:ToString(), StateId, self.StateChangedTime))
    local Config = self:GetConfig(StateId)
    local EnsureCheckEnable
    if Config and Config.OriginSkyTransitionConfig then
      EnsureCheckEnable = Config.OriginSkyTransitionConfig.EnsureCheckEnable
    end
    PlayerController.SkyTransition:SetState(StateId, self.StateChangedTime, EnsureCheckEnable)
  end
end
function PlayerCharacterSkyTransitionFeature:GetMatchController()
  local IsLocal = self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed()
  if not IsLocal then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    PlayerController = slua_GameFrontendHUD:GetPlayerController()
    self:ReportException("PlayerCharacterSkyTransitionFeature:GetMatchController USE slua_GameFrontendHUD:GetPlayerController()")
  end
  if not slua.isValid(PlayerController) then
    self:ReportException("PlayerCharacterSkyTransitionFeature:GetMatchController PlayerController is not valid")
    return
  end
  if not PlayerController.SkyTransition then
    self:ReportException("PlayerCharacterSkyTransitionFeature:GetMatchController PlayerController.SkyTransition is not valid")
    return
  end
  return PlayerController
end
function PlayerCharacterSkyTransitionFeature:ReportException(ReportString)
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:ReportException %s", ReportString))
  GameReportUtils.BugglyPostExceptionFull("SkyTransitionException", ReportString, true)
end
function PlayerCharacterSkyTransitionFeature:Reset()
  if not self:HasAuthority() then
    return
  end
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:Reset %s", self.Owner.Object))
  self.StateInfos = {}
  self:SetStateActive(self.SkyTransitionConfig.InitStateId, true)
end
function PlayerCharacterSkyTransitionFeature:SetStateActive(State, IsActive)
  if not self:HasAuthority() then
    return
  end
  if IsActive == nil then
    IsActive = true
  end
  local ActiveState = self:RefreshActiveState(State, IsActive)
  if not ActiveState then
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:SetStateActive ActiveState is nil, return"))
    return
  end
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:SetStateActive %s StateId = %s %s | ActiveState = %s", self:ToString(), State, IsActive, ActiveState))
  self.StateChangedTime = GamePlayTools.GetServerWorldTimeSeconds()
  self.StateMachine:SetState(ActiveState)
end
function PlayerCharacterSkyTransitionFeature:RefreshActiveState(State, IsActive)
  if State == DefaultConfig.StateId and not IsActive then
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:RefreshActiveState Cannot set default state %s to false, return", State))
    return
  end
  if not self:GetConfig(State) then
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:RefreshActiveState State %s is not valid, return", State))
    return
  end
  if not self.StateInfos then
    self.StateInfos = {}
  end
  local Priority = self:GetPriority(State)
  local StateInfo
  for _, Info in ipairs(self.StateInfos) do
    if Info.Priority == Priority then
      State    end
  end
  if not StateInfo then
    StateInfo = {
      StateId = State,
      IsActive = IsActive,
          }
    table.insert(self.StateInfos, StateInfo)
    table.sort(self.StateInfos, function(a, b)
      return a.Priority < b.Priority
    end)
  elseif IsActive then
    StateInfo.StateId = State
    StateInfo.IsActive = true
  elseif not IsActive and StateInfo.StateId == State then
    StateInfo.IsActive = false
  end
  self:DebugStateInfos(self.StateInfos)
  return self:GetActiveState()
end
function PlayerCharacterSkyTransitionFeature:CopyStateInfosByPawn(uPawn)
  if not slua.isValid(uPawn) or not uPawn.SkyTransition then
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:CopyStateInfosByPawn uPawn is not valid"))
    return
  end
  local SrcStateInfos = TableUtil.CopyTable(uPawn.SkyTransition.StateInfos)
  self:CopyStateInfos(SrcStateInfos)
end
function PlayerCharacterSkyTransitionFeature:CopyStateInfos(StateInfos)
  self.StateInfos = TableUtil.CopyTable(StateInfos)
  self:DebugStateInfos(self.StateInfos)
  local ActiveState = self:GetActiveState()
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:CopyStateInfos %s | ActiveState = %s", self:ToString(), ActiveState))
  self.StateChangedTime = GamePlayTools.GetServerWorldTimeSeconds()
  self.StateMachine:SetState(ActiveState)
end
function PlayerCharacterSkyTransitionFeature:DetectTriggers()
  local Location = self.Owner:K2_GetActorLocation()
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:DetectTriggers %s Location = %s", self.Owner.Object, Location:ToString()))
  local ECC_Trigger = 18
  local TraceObjectTypes = {
    Game:ConvertToObjectType(ECC_Trigger)
  }
  local bOverlap, OutActors = KismetSystemLibrary.SphereOverlapActors(self.Owner, Location, 1, TraceObjectTypes, nil, nil, nil)
  local DetectedAreas = {}
  if bOverlap then
    local uOwnerObject = self.Owner.Object
    for _, uSkyTransitionTriggerActor in pairs(OutActors) do
      print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:DetectTriggers SkyTransitionTrigger = %s", uSkyTransitionTriggerActor))
      if uSkyTransitionTriggerActor.SetSkyTransitionState then
        uSkyTransitionTriggerActor:SetSkyTransitionState(uOwnerObject, true)
      end
      table.insert(DetectedAreas, uSkyTransitionTriggerActor)
    end
  end
  return DetectedAreas
end
function PlayerCharacterSkyTransitionFeature:GetActiveState()
  if not self.StateInfos then
    print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:GetActiveState StateInfos is not valid, will return default"))
    return DefaultConfig.StateId
  end
  for i = #self.StateInfos, 1, -1 do
    if self.StateInfos[i].IsActive then
      return self.StateInfos[i].StateId
    end
  end
end
function PlayerCharacterSkyTransitionFeature:GetPriority(State)
  if self.SkyTransitionConfig then
    for _, Config in pairs(self.SkyTransitionConfig.States) do
      if Config.Id == State and Config.OriginSkyTransitionConfig.Priority then
        return Config.OriginSkyTransitionConfig.Priority
      end
    end
  end
  return 0
end
function PlayerCharacterSkyTransitionFeature:GetConfig(State)
  if self.SkyTransitionConfig then
    for _, Config in pairs(self.SkyTransitionConfig.States) do
      if Config.Id == State then
        return Config
      end
    end
  end
end
function PlayerCharacterSkyTransitionFeature:GetState()
  return self.StateMachine:GetState()
end
function PlayerCharacterSkyTransitionFeature:DebugStateInfos(StateInfos)
  local StrList = {}
  for _, StateInfo in ipairs(StateInfos) do
    table.insert(StrList, string.format("{%s|%s|%s}", StateInfo.StateId, StateInfo.Priority, StateInfo.IsActive))
  end
  print(bWriteLog and string.format("PlayerCharacterSkyTransitionFeature:DebugStateInfos %s", table.concat(StrList, ", ")))
end
function PlayerCharacterSkyTransitionFeature:ToString()
  if self.Owner.ToString then
    return self.Owner:ToString()
  end
  return tostring(self.Owner)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerCharacterSkyTransitionFeature = class(CFeatureBase, nil, PlayerCharacterSkyTransitionFeature)
return require("combine_class").DeclareFeature(CPlayerCharacterSkyTransitionFeature, {
  {
    StateMachine = "GameLua.Mod.BaseMod.GamePlay.Feature.Common.StateMachineFeature"
  }
}, "PlayerCharacterSkyTransitionFeature")