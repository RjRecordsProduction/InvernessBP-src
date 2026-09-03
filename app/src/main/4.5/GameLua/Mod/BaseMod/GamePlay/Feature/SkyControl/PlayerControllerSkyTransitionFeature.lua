local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
local UGameplayStatics = import("GameplayStatics")
local FSeqActorBindingData = import("SeqActorBindingData")
local TableUtil = require("common.table_util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local PlayerControllerSkyTransitionFeature = {}
local DefaultConfig = {
  EnsureCheck = {
    Enable = true,
    Interval = 6,
    CheckMaxTimes = 2
  },
  DebugSkyInfo = true
}
function PlayerControllerSkyTransitionFeature:_PostConstruct()
  PlayerControllerSkyTransitionFeature.__super._PostConstruct(self)
  self:InitConfig()
  if Client then
    local SkyTransitionUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.SkyControl.SkyTransitionUtil")
    self.SkyTransitionConfig = SkyTransitionUtil.ParseSkyTransitionConfig()
    if not self.SkyTransitionConfig then
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:_PostConstruct SkyTransition is not enable, return"))
      return
    end
    self.TransitionableStateMachine.StateMachine.IsEnableClientSetState = true
    self.TransitionableStateMachine:Init(self.SkyTransitionConfig)
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_LOAD_WEATHER_COMPLETED, self.OnLoadWeatherCompleted, self)
    self:OnLoadWeatherCompleted()
    self:AddControlEvent(self.Owner, "OnSpectatorChange", self.OnSpectatorChange, self)
    self:AddControlEvent(self.Owner, "PlayerControllerRespawnedDelegate", self.OnPlayerControllerRespawned, self)
    local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(uGameInstance) then
      local uGameReplay = uGameInstance:GetCompletePlayback()
      if slua.isValid(uGameReplay) then
        self:AddControlEvent(uGameReplay, "OnReplayResetViewTargetDelegate", self.OnReplayResetViewTarget, self)
      end
    end
  end
end
function PlayerControllerSkyTransitionFeature:InitConfig()
  self.FeatureConfig = TableUtil.DeepCloneTable(DefaultConfig)
end
function PlayerControllerSkyTransitionFeature:ReceiveBeginPlay()
  PlayerControllerSkyTransitionFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:ReceiveBeginPlay"))
  if Client and self.SkyTransitionConfig then
    self:RecheckClientState(true)
    self.TransitionableStateMachine.Transition:OnPlay(self._OnPlayTransition, self)
    self.TransitionableStateMachine.Transition:OnJump(self._OnJumpTransition, self)
    self:UpdateSkySphere()
  end
end
function PlayerControllerSkyTransitionFeature:RecheckClientState(FirstCheck)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:RecheckClientState FirstCheck = %s", FirstCheck))
  local uPlayerCharacter = self.Owner:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerCharacter) and uPlayerCharacter.SkyTransition then
    uPlayerCharacter.SkyTransition:RecheckClientState()
  else
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:RecheckClientState uPlayerCharacter not ready"))
    if FirstCheck then
      self:AddGameTimer(0.1, false, function()
        self:RecheckClientState(false)
      end)
    end
  end
end
function PlayerControllerSkyTransitionFeature:ReceiveEndPlay(EndPlayReason)
  self.LevelSequenceActor = nil
  self:TryRemoveNamedGameTimer("RespawnDelayRefreshStateTimer")
  self:TryRemoveNamedGameTimer("OnTransitionFinishTimer")
  self:ClearEnsureCheckTimer()
  PlayerControllerSkyTransitionFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerControllerSkyTransitionFeature:OnLoadWeatherCompleted(_, __, WeatherLevelName)
  if WeatherLevelName == nil then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnLoadWeatherCompleted WeatherLevelName is nil, try get from WeatherSubsystem"))
    local WeatherSubsystem = SubsystemMgr:Get("WeatherSubsystem")
    if WeatherSubsystem and WeatherSubsystem.LoadingWeatherLevel == nil then
      local WeatherLevel = WeatherSubsystem:GetWeatherLevel()
      if WeatherLevel and WeatherLevel ~= "" then
        WeatherLevelName = WeatherLevel
        print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnLoadWeatherCompleted get from WeatherSubsystem: %s", WeatherLevel))
      end
    end
  end
  if WeatherLevelName == nil then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnLoadWeatherCompleted WeatherLevelName is nil, return"))
    return
  end
  local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
  self.uWeatherLevelStreaming = LevelStreamingMgr:GetStreamLevel(WeatherLevelName)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnLoadWeatherCompleted %s", WeatherLevelName))
  for _, StateConfig in ipairs(self.SkyTransitionConfig.States) do
    local Info = self:GetSequenceAssetPath(StateConfig.OriginSkyTransitionConfig, WeatherLevelName)
    StateConfig.SequenceAssetPath = Info.Sequence
    StateConfig.MaterialAssetPath = Info.Material
  end
  self:InitTransitionConfigs()
end
function PlayerControllerSkyTransitionFeature:GetSequenceAssetPath(StateConfig, WeatherLevelName)
  local Name = StateConfig.Name
  local Result = {Sequence = ""}
  if StateConfig.Sequence then
    self:InternalCopyStateConfig(StateConfig, Result)
    local ConditionConfig = self:CheckCondition(StateConfig, WeatherLevelName)
    if ConditionConfig then
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath match condition (ConditionName = %s)", ConditionConfig.Name))
      self:InternalCopyStateConfig(ConditionConfig, Result)
    end
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath Sequence = %s (Name = %s)", Result.Sequence, Name))
    return Result
  end
  if not StateConfig.Map then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath Map is not valid (Name = %s)", Name))
    return Result
  end
  local MapType = GameMainConfig.GetMapType()
  local MapConfig = StateConfig.Map[MapType]
  if not MapConfig then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath MapType = %s config is not valid (Name = %s)", MapType, Name))
    return Result
  end
  if MapConfig.Sequence then
    self:InternalCopyStateConfig(MapConfig, Result)
    local ConditionConfig = self:CheckCondition(MapConfig, WeatherLevelName)
    if ConditionConfig then
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath MapType = %s -> match condition (ConditionName = %s)", MapType, ConditionConfig.Name))
      self:InternalCopyStateConfig(ConditionConfig, Result)
    end
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath MapType = %s -> Sequence = %s (Name = %s)", MapType, Result.Sequence, Name))
    return Result
  end
  if not MapConfig[WeatherLevelName] then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath WeatherLevelName = %s config is not valid (Name = %s)", WeatherLevelName, Name))
    return Result
  end
  self:InternalCopyStateConfig(MapConfig[WeatherLevelName], Result)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetSequenceAssetPath Sequence = %s from Map = %s, WeatherLevelName = %s (Name = %s)", Result, MapType, WeatherLevelName, Name))
  return Result
end
function PlayerControllerSkyTransitionFeature:InternalCopyStateConfig(Src, Dst)
  if not Src or not Dst then
    return
  end
  Dst.Sequence = Src.Sequence
  Dst.Material = Src.Material
end
function PlayerControllerSkyTransitionFeature:CheckCondition(Config, WeatherLevelName)
  if not Config or not Config.Conditions then
    return
  end
  for i, ConditionConfig in ipairs(Config.Conditions) do
    if ConditionConfig and ConditionConfig.Predicate and ConditionConfig.Predicate(self.Owner, WeatherLevelName) then
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:CheckCondition match i = %s", i))
      return ConditionConfig
    end
  end
end
function PlayerControllerSkyTransitionFeature:PrepareSequenceActor()
  if not Client then
    return
  end
  if not slua.isValid(self.Owner.Object) then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PrepareSequenceActor self.Owner.Object is not valid, return"))
    return
  end
  if self.LevelSequenceActor and slua.isValid(self.LevelSequenceActor) then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PrepareSequenceActor actor is ready, return"))
    return
  end
  local uTransform = FTransform()
  if self.Owner and self.Owner.K2_GetActorLocation then
    uTransform:SetLocation(self.Owner:K2_GetActorLocation())
  end
  local LevelSequenceActorClass = slua.loadClass("/Game/Mod/EvoBase/BluePrints/Actor/BP_SkyTransitionLevelSequenceActor.BP_SkyTransitionLevelSequenceActor")
  local LevelSequenceActor = UGameplayStatics.BeginDeferredActorSpawnFromClass(self.Owner.Object, LevelSequenceActorClass, uTransform, ESpawnActorCollisionHandlingMethod.Undefined, self.Owner.Object)
  if not slua.isValid(LevelSequenceActor) then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PrepareSequenceActor create actor failed, return"))
    return
  end
  LevelSequenceActor.bAutoPlay = false
  LevelSequenceActor.bInitPlayerBeforeBeginPlay = false
  UGameplayStatics.FinishSpawningActor(LevelSequenceActor, uTransform)
  local DefaultConfig
  for _, Config in ipairs(self.SkyTransitionConfig.States) do
    local Name = Config.Name
    local SequenceAssetPath = Config.SequenceAssetPath
    if Config.IsDefault then
      Default    end
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PrepareSequenceActor Name = %s, SequencePath = %s", Name, SequenceAssetPath))
    if Client and SequenceAssetPath and (Config.OriginSkyTransitionConfig.Preload == nil or Config.OriginSkyTransitionConfig.Preload == true) then
      self:PreloadAsset(SequenceAssetPath)
      if Config.MaterialAssetPath then
        self:PreloadAsset(Config.MaterialAssetPath)
      end
    end
  end
  LevelSequenceActor.bInitPlayerBeforeBeginPlay = true
  if Client and DefaultConfig and DefaultConfig.SequenceAssetPath then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PrepareSequenceActor SetLevelSequenceAssetPath: %s", DefaultConfig.SequenceAssetPath))
    LevelSequenceActor:SetLevelSequenceAssetPath(DefaultConfig.SequenceAssetPath)
  end
  self.  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PrepareSequenceActor finish"))
end
function PlayerControllerSkyTransitionFeature:PreloadSequenceById(StateId)
  local Config = self:GetStateConfig(StateId)
  if Config then
    self:PreloadAsset(Config.OriginSkyTransitionConfig.Sequence)
    if Config.OriginSkyTransitionConfig.Material then
      self:PreloadAsset(Config.OriginSkyTransitionConfig.Material)
    end
  end
end
function PlayerControllerSkyTransitionFeature:PreloadAsset(AssetPath)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PreloadAsset %s", AssetPath))
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(AssetPath, function(Asset)
    if slua.isValid(Asset) then
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:PreloadAsset %s success", AssetPath))
      self.TransitionableStateMachine:SetCacheAsset(AssetPath, Asset)
    end
  end)
end
function PlayerControllerSkyTransitionFeature:InitTransitionConfigs()
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:InitTransitionConfigs"))
  if #self.SkyTransitionConfig.States <= 1 then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:InitTransitionConfigs #states = %s, return", #self.SkyTransitionConfig.States))
    return
  end
  self:PrepareSequenceActor()
  self:RebindSequenceTracks()
  local TransitionConfig = {
    States = {}
  }
  for _, Config in ipairs(self.SkyTransitionConfig.States) do
    TransitionConfig.States[Config.Id] = {
      SequenceActor = self.LevelSequenceActor,
      SequenceAssetPath = Config.SequenceAssetPath,
      TransitionCDTime = Config.OriginSkyTransitionConfig.TransitionCDTime
    }
  end
  self.TransitionableStateMachine:InitTransitionConfigs(TransitionConfig)
end
function PlayerControllerSkyTransitionFeature:SetState(StateId, StateChangedTime, EnsureCheckEnable)
  if self.bClientStateBlock then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:SetState %s %s %s, bClientStateBlock return", StateId, StateChangedTime, EnsureCheckEnable))
    return
  end
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:SetState %s %s %s", StateId, StateChangedTime, EnsureCheckEnable))
  self.TransitionableStateMachine.  self.TransitionableStateMachine:SetState(StateId)
  if EnsureCheckEnable == nil then
    EnsureCheckEnable = self.FeatureConfig.EnsureCheck.Enable
  end
  if EnsureCheckEnable then
    self:ClearEnsureCheckTimer()
    self.EnsureCheckTimer = self:AddGameTimer(self.FeatureConfig.EnsureCheck.Interval, true, function()
      self:EnsureSkyTransition()
    end)
  end
end
function PlayerControllerSkyTransitionFeature:ClientSetState(StateId, StateChangedTime)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:ClientSetState %s %s", StateId, StateChangedTime))
  self.TransitionableStateMachine.  self.TransitionableStateMachine:SetState(StateId)
  self.bClientStateBlock = true
end
function PlayerControllerSkyTransitionFeature:ClientReSetState(StateChangedTime)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:ClientReSetState %s", StateChangedTime))
  self.bClientStateBlock = false
  local ViewTarget
  if self.Owner.GetCurPlayerCharacterOrPetSpectator then
    ViewTarget = self.Owner:GetCurPlayerCharacterOrPetSpectator()
  elseif self.Owner.GetCurPlayerCharacter then
    ViewTarget = self.Owner:GetCurPlayerCharacter()
  end
  if slua.isValid(ViewTarget) and ViewTarget.SkyTransition then
    local ViewTargetStateId = ViewTarget.SkyTransition:GetState()
    self:SetState(ViewTargetStateId, StateChangedTime)
  end
end
function PlayerControllerSkyTransitionFeature:SetClientStateBlock(bBlock)
  self.bClientStateBlock = bBlock
end
function PlayerControllerSkyTransitionFeature:ForceRefreshState(StateId)
  if self.bClientStateBlock then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:ForceRefreshState %s, bClientStateBlock return", StateId))
    return
  end
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:ForceRefreshState StateId = %s", StateId))
  local StateMachine = self.TransitionableStateMachine.StateMachine
  if StateMachine.StateId ~= StateId then
    StateMachine.OldStateId = StateMachine.StateId
    StateMachine.    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:ForceRefreshState set statemachine StateId %s -> %s", StateMachine.OldStateId, StateId))
  end
  self.TransitionableStateMachine:ApplyTransition(StateId, true)
  if self.FeatureConfig.DebugSkyInfo then
    self:DebugSkyInfo(true)
  end
end
function PlayerControllerSkyTransitionFeature:EnsureSkyTransition()
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  if self.bClientStateBlock then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:EnsureSkyTransition, bClientStateBlock return"))
    return
  end
  local ViewTarget
  if self.Owner.GetCurPawn then
    ViewTarget = self.Owner:GetCurPawn()
  end
  if not slua.isValid(ViewTarget) or not ViewTarget.SkyTransition then
    if self.Owner.GetCurPlayerCharacterOrPetSpectator then
      ViewTarget = self.Owner:GetCurPlayerCharacterOrPetSpectator()
    elseif self.Owner.GetCurPlayerCharacter then
      ViewTarget = self.Owner:GetCurPlayerCharacter()
    end
  end
  if slua.isValid(ViewTarget) and ViewTarget.SkyTransition then
    local ViewTargetStateId = ViewTarget.SkyTransition:GetState()
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:EnsureSkyTransition ViewTargetStateId = %s", ViewTargetStateId))
    self:ForceRefreshState(ViewTargetStateId)
  else
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:EnsureSkyTransition ViewTarget is not valid, return"))
    return
  end
  if not self.RetryTimes then
    self.RetryTimes = 0
  end
  self.RetryTimes = self.RetryTimes + 1
  if self.RetryTimes >= self.FeatureConfig.EnsureCheck.CheckMaxTimes then
    self:ClearEnsureCheckTimer()
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:EnsureSkyTransition reach max times"))
    return
  end
end
function PlayerControllerSkyTransitionFeature:ClearEnsureCheckTimer()
  if self.EnsureCheckTimer then
    self:RemoveGameTimer(self.EnsureCheckTimer)
    self.EnsureCheckTimer = nil
  end
  self.RetryTimes = 0
end
function PlayerControllerSkyTransitionFeature:GetState()
  return self.TransitionableStateMachine:GetState()
end
function PlayerControllerSkyTransitionFeature:_OnPlayTransition()
  local StateId = self:GetState()
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:_OnPlayTransition StateId = %s", StateId))
  self:PreStartSkyTransition(false, StateId)
  self:TryRemoveNamedGameTimer("OnTransitionFinishTimer")
  self.OnTransitionFinishTimer = self:AddGameTimer(self.TransitionableStateMachine.Transition:GetLength(), false, function()
    local StateId = self:GetState()
    self:OnTransitionFinish(StateId)
  end)
  self:UpdateSkySphere()
end
function PlayerControllerSkyTransitionFeature:_OnJumpTransition()
  local StateId = self:GetState()
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:_OnJumpTransition StateId = %s", StateId))
  self:PreStartSkyTransition(true, StateId)
  self:OnTransitionFinish(StateId)
end
function PlayerControllerSkyTransitionFeature:PreStartSkyTransition(JumpAndStop, CurrentState)
  local StateConfig = self:GetStateConfig(CurrentState)
  if not StateConfig then
    return
  end
  local PlatName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local GameInstance = slua.getGameInstance()
  if slua.isValid(GameInstance) then
    GameInstance:AsyncPSOFlushShaderByLua()
  end
  self:PrepareSequenceActor()
  if not self.HasBindSequenceTracks then
    self.HasBindSequenceTracks = self:TryBindSequenceTracks(self.LevelSequenceActor)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CLIENT_SKY_TRANSITION_START, CurrentState, JumpAndStop)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:StartSkyTransition CurrentState = %s, JumpAndStop = %s", CurrentState, JumpAndStop))
  if self.FeatureConfig.DebugSkyInfo then
    if not JumpAndStop then
      self:DebugSkyInfo(true)
    end
    local Delay = self.TransitionableStateMachine.Transition:GetLength() + 1
    if JumpAndStop then
      Delay = 0.1
    end
    self:AddGameTimer(Delay, false, function()
      self:DebugSkyInfo(false)
    end)
  end
end
function PlayerControllerSkyTransitionFeature:TryBindSequenceTracks(SeqActor)
  if not slua.isValid(SeqActor) then
    print(bWriteLog and "PlayerControllerSkyTransitionFeature:TryBindSequenceTracks SequenceActor is not valid, return")
    return false
  end
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:TryBindSequenceTracks %s", SeqActor))
  local BindingList = slua.Array(UEnums.EPropertyClass.Struct, FSeqActorBindingData)
  local AllSkyTransitionActors = self:GetTransitionActors()
  local BindingActorNum = 0
  for _, Actor in pairs(AllSkyTransitionActors) do
    if slua.isValid(Actor) then
      local TrackName = self:GetActorBindingTrackName(Actor)
      if TrackName then
        local BindingData = FSeqActorBindingData()
        BindingData.        BindingData.Binding        BindingList:Add(BindingData)
        print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:TryBindSequenceTracks TrackName = %s, Actor = %s", TrackName, Actor))
        BindingActorNum = BindingActorNum + 1
        local BindingID = SeqActor:GetPossessableByName(TrackName)
        local Guid = BindingID.Guid
        if Guid.A == 0 and Guid.B == 0 and Guid.C == 0 and Guid.D == 0 then
          print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:TryBindSequenceTracks TrackName = %s is not found, please check sequence", TrackName))
        end
      end
    end
  end
  if 0 < BindingActorNum then
    SeqActor:SetTrackBindingData(BindingList)
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:TryBindSequenceTracks success!"))
    return true
  else
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:TryBindSequenceTracks failed!"))
    return false
  end
end
function PlayerControllerSkyTransitionFeature:RebindSequenceTracks()
  self.HasBindSequenceTracks = self:TryBindSequenceTracks(self.LevelSequenceActor)
end
function PlayerControllerSkyTransitionFeature:GetActorBindingTrackName(Actor)
  local DirectionalLight = import("/Script/Engine.DirectionalLight")
  local SkyLight = import("/Script/Engine.SkyLight")
  local ExponentialHeightFog = import("/Script/Engine.ExponentialHeightFog")
  local SkySphereBase = import("/Game/Arts_Scenes/Meshs/Sky/BP_Sky_Sphere_Base.BP_Sky_Sphere_Base_C")
  local TrackName2Class = {
    DirectionalLight = DirectionalLight,
    SkyLight = SkyLight,
    ExponentialHeightFog = ExponentialHeightFog,
    SkySphere = SkySphereBase
  }
  for TrackName, uClass in pairs(TrackName2Class) do
    if Game:IsClassOf(Actor, uClass) then
      return TrackName
    end
  end
end
function PlayerControllerSkyTransitionFeature:OnTransitionFinish(StateId)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnTransitionFinish StateId = %s", StateId))
  self:UpdateSkySphere()
  local Config = self:GetStateConfig(StateId)
  if Config and Config.OriginSkyTransitionConfig then
    local IsEnableLensFlare = Config.OriginSkyTransitionConfig.EnableLensFlare ~= false
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnTransitionFinish StateId = %s, IsEnableLensFlare = %s", StateId, IsEnableLensFlare))
    local GameInstance = slua.getGameInstance()
    GameInstance:ExecuteCMD("r.EnableLensFlareActor", IsEnableLensFlare == true and 1 or 0)
  end
  local PlatName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local GameInstance = slua.getGameInstance()
end
function PlayerControllerSkyTransitionFeature:UpdateSkySphere()
  self:UpdateSkySphereTransform()
  self:UpdateSunDirection()
end
function PlayerControllerSkyTransitionFeature:UpdateSkySphereTransform()
  local StateId = self:GetState()
  local Config = self:GetStateConfig(StateId)
  if not (Config and Config.OriginSkyTransitionConfig) or not Config.OriginSkyTransitionConfig.SkySphereFollowActor then
    return
  end
  local SkySphereFollowActorConfig = Config.OriginSkyTransitionConfig.SkySphereFollowActor
  local uFollowActor
  if type(SkySphereFollowActorConfig) == "string" then
    uFollowActor = ActorTools.GetOneActor(self.Owner, SkySphereFollowActorConfig)
  elseif type(SkySphereFollowActorConfig) == "function" then
    uFollowActor = SkySphereFollowActorConfig(self.Owner)
  end
  if not slua.isValid(uFollowActor) then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:UpdateSkySphereTransform no FollowActor found"))
    return
  end
  local FollowLocation = uFollowActor:K2_GetActorLocation()
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:UpdateSkySphereTransform FollowLocation = %s (%s)", FollowLocation:ToString(), uFollowActor))
  local SkySphereBase = import("/Game/Arts_Scenes/Meshs/Sky/BP_Sky_Sphere_Base.BP_Sky_Sphere_Base_C")
  local AllSkyTransitionActors = self:GetTransitionActors()
  for _, Actor in pairs(AllSkyTransitionActors) do
    if slua.isValid(Actor) and Game:IsClassOf(Actor, SkySphereBase) then
      Actor:K2_SetActorLocation(FollowLocation, false, nil, true)
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:UpdateSkySphereTransform set SkySphere location to %s", FollowLocation:ToString()))
    end
  end
end
function PlayerControllerSkyTransitionFeature:UpdateSunDirection()
  local WeatherSubsystem = SubsystemMgr:Get("WeatherSubsystem")
  if WeatherSubsystem then
    WeatherSubsystem:UpdateSunDirection()
  end
end
function PlayerControllerSkyTransitionFeature:GetStateConfig(StateId)
  if not self.SkyTransitionConfig or not self.SkyTransitionConfig.States then
    return
  end
  for _, Config in ipairs(self.SkyTransitionConfig.States) do
    if Config.Id == StateId then
      return Config
    end
  end
end
function PlayerControllerSkyTransitionFeature:OnPostViewTargetChanged(uNewViewTarget, uCurrentViewTarget)
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPostViewTargetChanged %s -> %s", uCurrentViewTarget, uNewViewTarget))
  if not slua.isValid(uNewViewTarget) then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPostViewTargetChanged uNewTarget is not valid, return"))
    return
  end
  if uNewViewTarget == uCurrentViewTarget then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPostViewTargetChanged uNewViewTarget == uCurrentViewTarget, return"))
    return
  end
  local uPlayerController = self.Owner
  local SkyTransitionId = 0
  local VehicleBaseClass = import("STExtraVehicleBase")
  if Game:IsClassOf(uNewViewTarget, VehicleBaseClass) then
    if uNewViewTarget.SkyTransition then
      SkyTransitionId = uNewViewTarget.SkyTransition:GetState()
    else
      local uCurPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
      SkyTransitionId = uCurPlayerCharacter.SkyTransition:GetState()
    end
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPostViewTargetChanged uNewTarget is STExtraVehicleBase, SkyTransitionId = %s", SkyTransitionId))
  elseif uNewViewTarget.SkyTransition then
    SkyTransitionId = uNewViewTarget.SkyTransition:GetState()
  else
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPostViewTargetChanged uNewTarget.SkyTransition is not valid, return"))
    return
  end
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPostViewTargetChanged SkyTransitionId = %s", SkyTransitionId))
  self.TransitionableStateMachine.StateChangedTime = 0
  self.TransitionableStateMachine:SetState(SkyTransitionId)
  self:ForceRefreshState(SkyTransitionId)
end
function PlayerControllerSkyTransitionFeature:OnSpectatorChange()
  local ViewTarget = self.Owner:GetCurPawn()
  if not slua.isValid(ViewTarget) then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnSpectatorChange ViewTarget is not valid, return"))
    return
  end
  if not ViewTarget.SkyTransition then
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnSpectatorChange ViewTarget(%s) has no SkyTransition, return", ViewTarget))
    return
  end
  local ViewTargetStateId = ViewTarget.SkyTransition:GetState()
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnSpectatorChange switch to PlayerKey = %s, StateId = %s", ViewTarget.PlayerKey, ViewTargetStateId))
  self:SetState(ViewTargetStateId, 0)
  self.HasTriggeredSpectatorChange = true
end
function PlayerControllerSkyTransitionFeature:OnPlayerControllerRespawned()
  self.RespawnDelayRefreshStateTimer = self:AddGameTimer(0.1, false, function()
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPlayerControllerRespawned Delay"))
    local uPlayerCharacter = self.Owner:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) and uPlayerCharacter.SkyTransition then
      local StateId = uPlayerCharacter.SkyTransition:GetState()
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnPlayerControllerRespawned StateId = %s", StateId))
      self:ForceRefreshState(StateId)
    end
  end)
end
function PlayerControllerSkyTransitionFeature:OnReplayResetViewTarget()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local ViewTarget = uPlayerController:GetCurPawn()
  if slua.isValid(ViewTarget) and uPlayerController.bIsForReplay then
    if not ViewTarget.SkyTransition then
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnReplayResetViewTarget ViewTarget has no SkyTransition, return"))
      return
    end
    local ViewTargetStateId = ViewTarget.SkyTransition:GetState()
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:OnReplayResetViewTarget StateId = %s", ViewTargetStateId))
    self:SetState(ViewTargetStateId, 0)
  end
end
function PlayerControllerSkyTransitionFeature:DebugSkyInfo(IsStart)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  if not self.Owner.GetCurPlayerCharacter then
    return
  end
  local PlayerCharacter = self.Owner:GetCurPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  local DirectionalLight = import("/Script/Engine.DirectionalLight")
  local SkyLight = import("/Script/Engine.SkyLight")
  local ExponentialHeightFog = import("/Script/Engine.ExponentialHeightFog")
  local SkySphereBase = import("/Game/Arts_Scenes/Meshs/Sky/BP_Sky_Sphere_Base.BP_Sky_Sphere_Base_C")
  local StrPlayerCharacter = PlayerCharacter.ToString ~= nil and PlayerCharacter:ToString() or PlayerCharacter.PlayerKey
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo ==[%s]== PlayerCharacter %s Location = %s", IsStart == true and "START" or "END", StrPlayerCharacter, PlayerCharacter:K2_GetActorLocation():ToString()))
  local AllSkyTransitionActors = self:GetTransitionActors()
  for _, Actor in pairs(AllSkyTransitionActors) do
    if slua.isValid(Actor) then
      print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo => %s", Actor))
      if Game:IsClassOf(Actor, ExponentialHeightFog) then
        local FogHeightFalloff = Actor.Component.FogHeightFalloff
        local FogDensity = Actor.Component.FogDensity
        local Location = Actor:K2_GetActorLocation()
        print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo => ExponentialHeightFog FogHeightFalloff = %s, FogDensity = %s, Location = %s", FogHeightFalloff, FogDensity, Location:ToString()))
      elseif Game:IsClassOf(Actor, SkyLight) then
        local LightColor = Actor.LightComponent.LightColor
        print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo => SkyLight LightColor = %s", LightColor:ToString()))
      elseif Game:IsClassOf(Actor, DirectionalLight) then
        local Intensity = Actor.LightComponent.Intensity
        local LightColor = Actor.LightComponent.LightColor
        local Rotation = Actor:K2_GetActorRotation()
        print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo => DirectionalLight Intensity = %s, LightColor = %s, Rotation = %s", Intensity, LightColor:ToString(), Rotation:ToString()))
      elseif Game:IsClassOf(Actor, SkySphereBase) then
        local Location = Actor:K2_GetActorLocation()
        local Rotation = Actor:K2_GetActorRotation()
        local Scale = Actor:GetActorScale3D()
        local Material = Actor.StaticMesh:GetMaterial(0)
        local MaterialStr = slua.isValid(Material) and tostring(Material) or "Invalid Material"
        print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo => SkySphere Location = %s, Rotation = %s, Scale = %s, Material = %s", Location:ToString(), Rotation:ToString(), Scale:ToString(), MaterialStr))
      end
    end
  end
  local SkySpheres = ActorTools.GetAllActors(self.Owner.Object, "/Game/Arts_Scenes/Meshs/Sky/BP_Sky_Sphere_Base.BP_Sky_Sphere_Base_C")
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo CheckSkySphere Num = %s", SkySpheres:Num()))
  for _, SkySphere in pairs(SkySpheres) do
    print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:DebugSkyInfo CheckSkySphere %s", SkySphere))
  end
end
function PlayerControllerSkyTransitionFeature:GetTransitionActors()
  if not slua.isValid(self.uWeatherLevelStreaming) then
    return self:GetTransitionActorsLegacy()
  end
  local uLevel = self.uWeatherLevelStreaming:GetLoadedLevel()
  if not slua.isValid(uLevel) then
    return self:GetTransitionActorsLegacy()
  end
  local STExtraGameplayStatics = import("STExtraGameplayStatics")
  local AllSkyTransitionActors = STExtraGameplayStatics.GetLevelActors(uLevel, "SkyTransition")
  return AllSkyTransitionActors
end
function PlayerControllerSkyTransitionFeature:GetTransitionActorsLegacy()
  print(bWriteLog and string.format("PlayerControllerSkyTransitionFeature:GetTransitionActorsLegacy"))
  local AllSkyTransitionActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
  AllSkyTransitionActors = UGameplayStatics.GetAllActorsWithTag(CGameWorld, "SkyTransition", AllSkyTransitionActors)
  return AllSkyTransitionActors
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerControllerSkyTransitionFeature = class(CFeatureBase, nil, PlayerControllerSkyTransitionFeature)
return require("combine_class").DeclareFeature(CPlayerControllerSkyTransitionFeature, {
  {
    TransitionableStateMachine = "GameLua.Mod.BaseMod.GamePlay.Feature.Common.TransitionableStateMachineFeature"
  }
}, "PlayerControllerSkyTransitionFeature")