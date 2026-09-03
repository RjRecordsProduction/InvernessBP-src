local UTweenFloatStandardFactory = import("TweenFloatStandardFactory")
local ETweenEaseType = import("ETweenEaseType")
local ETweenLoopType = import("ETweenLoopType")
local TableUtil = require("common.table_util")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local PhotoGrapherConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.PhotoGrapherConfig")
local IngameSelfieWeatherSubsystem = {}
local ENSURE_CHECK_INTERVAL = 0.5
local MIN_UPDATE_FRAME_INTERVAL = 0.03333333333333333
local ESkyType = {
  None = 0,
  Morning = 1,
  Midday = 2,
  Night = 3
}
local WEATHER_CONFIG = {
  PUBG_Forest_SunnyDay = {
    InitValue = 0,
    InitSkyType = ESkyType.Morning,
    LevelSequenceActorClass = "/Game/Mod/EvoBase/Arts_Scenes/Weather/InGamePhotoLevelSequenceActor_Sunny.InGamePhotoLevelSequenceActor_Sunny_C"
  },
  PUBG_Forest_SunnyDay_2UpDate = {
    InitValue = 0.5,
    InitSkyType = ESkyType.Midday,
    LevelSequenceActorClass = "/Game/Mod/EvoBase/Arts_Scenes/Weather/InGamePhotoLevelSequenceActor_Dusk.InGamePhotoLevelSequenceActor_Dusk_C"
  }
}
local SKY_CONFIG = {
  Sunny = {
    Material = "/Game/Mod/EvoBase/Arts_Scenes/Weather/MI_NewSky_Forest_Sunnyday_TOD.MI_NewSky_Forest_Sunnyday_TOD"
  },
  Dusk = {
    MorningMidday = "/Game/Mod/EvoBase/Arts_Scenes/Weather/M_260_SkySwitch_MorningMidday.M_260_SkySwitch_MorningMidday",
    MiddayNight = "/Game/Mod/EvoBase/Arts_Scenes/Weather/M_260_SkySwitch_MiddayNight.M_260_SkySwitch_MiddayNight"
  },
  MaterialTransitionBias = 0.2
}
function IngameSelfieWeatherSubsystem:ctor()
end
function IngameSelfieWeatherSubsystem:_PostConstruct()
end
function IngameSelfieWeatherSubsystem:OnInit()
  self.SkyTransitionQueue = {}
  self.IsActive = false
  self.InitValue = 0
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_CLIENT_SKY_TRANSITION_START, self.OnClientSkyTransitionStart, self)
end
function IngameSelfieWeatherSubsystem:OnRelease()
  self.IsActive = false
  self.WeatherConfig = nil
  self.SequencePlayer = nil
  self.CacheTargetValue = 0
  self.OriginLength = nil
  self.SkyTransitionQueue = nil
  self.TweenManagerActor = nil
  self:_ClearPlaybackTimer()
  self:_ClearEnsureCheckTimer()
  self:_ClearSkyTransitionTimer()
  IngameSelfieWeatherSubsystem.__super.OnRelease(self)
end
function IngameSelfieWeatherSubsystem:OnClientSkyTransitionStart(_, __, CurrentState, JumpAndStop)
  print(bWriteLog and string.format("IngameSelfieWeatherSubsystem:OnClientSkyTransitionStart %s %s", CurrentState, JumpAndStop))
  local IsInSkyArea = CurrentState ~= 1
  self.IsInSkyTransitionArea = IsInSkyArea
  if IsInSkyArea then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SELFIE_WEATHER_CHANGE_SKY_AREA)
  else
    self:AddGameTimer(5, false, function()
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SELFIE_WEATHER_CHANGE_SKY_AREA)
    end)
  end
end
function IngameSelfieWeatherSubsystem:InitWeather()
  printf("IngameSelfieWeatherSubsystem:InitWeather")
  self.IsSupportChangeWeather = self:IsSupportChangingWeather()
  local InitValue = 0
  if not self.IsSupportChangeWeather then
    printf("IngameSelfieWeatherSubsystem:InitWeather not support")
    return false, 0
  end
  local WeatherLevel = SubsystemMgr:Get("WeatherSubsystem"):GetWeatherLevel(true)
  local Config = WEATHER_CONFIG[WeatherLevel]
  self.Weather  self.IsSunnyWeather = WeatherLevel == "PUBG_Forest_SunnyDay"
  printf("IngameSelfieWeatherSubsystem:InitWeather WeatherLevel = %s", WeatherLevel)
  if self.IsSupportChangeWeather then
    local uPlayerController = GameplayData.GetPlayerController()
    local LevelSeqActor = ActorTools.GetOneActor(uPlayerController, Config.LevelSequenceActorClass)
    if not slua.isValid(LevelSeqActor) or not slua.isValid(LevelSeqActor.SequencePlayer) then
      printf("IngameSelfieWeatherSubsystem:InitWeather LevelSeqActor or LevelSeqActor.SequencePlayer not valid")
      self.IsSupportChangeWeather = false
      return self.IsSupportChangeWeather, InitValue
    end
    self.SequencePlayer = self:InitLevelSequenceActor(uPlayerController, LevelSeqActor)
    InitValue = Config.InitValue
    self.CacheTargetValue = InitValue
    self:UpdateWeatherSequence(InitValue, false)
    self.CurrentSkyType = Config.InitSkyType
  end
  self.  return self.IsSupportChangeWeather
end
function IngameSelfieWeatherSubsystem:IsSupportChangingWeather()
  return self:IsWeatherLevelSupportChangingWeather() and not self.IsInSkyTransitionArea
end
function IngameSelfieWeatherSubsystem:IsWeatherLevelSupportChangingWeather()
  local ModeType, _ = GameMainConfig.GetModType()
  if TableUtil.IsInTable(PhotoGrapherConfig.PhotographerDisableWeatherMainModType, ModeType) then
    return false
  end
  local WeatherLevel = SubsystemMgr:Get("WeatherSubsystem"):GetWeatherLevel(true)
  return WEATHER_CONFIG[WeatherLevel] ~= nil
end
function IngameSelfieWeatherSubsystem:InitLevelSequenceActor(uPlayerController, LevelSeqActor)
  if uPlayerController.SkyTransition and not self.HasBindSequenceTracks then
    self.HasBindSequenceTracks = uPlayerController.SkyTransition:TryBindSequenceTracks(LevelSeqActor)
    if self.HasBindSequenceTracks then
      print(bWriteLog and string.format("IngameSelfieWeatherSubsystem:InitLevelSequenceActor UpdateTrackBindingData"))
      LevelSeqActor:UpdateTrackBindingData()
    end
    print(bWriteLog and string.format("IngameSelfieWeatherSubsystem:InitLevelSequenceActor HasBindSequenceTracks = %s", self.HasBindSequenceTracks))
  end
  return LevelSeqActor.SequencePlayer
end
function IngameSelfieWeatherSubsystem:SetValue(Value)
  if not self:IsSupportChangingWeather() then
    return
  end
  self.CacheTarget  self:TryUpdateWeatherSequence(1)
  self:TryUpdateSkyTransition()
end
function IngameSelfieWeatherSubsystem:Reset()
  printf("IngameSelfieWeatherSubsystem:Reset")
  self.CacheTargetValue = self.InitValue
  if not self.IsInSkyTransitionArea and self.WeatherConfig then
    self:UpdateWeatherSequence(0, false)
  end
  self:SetActive(false)
end
function IngameSelfieWeatherSubsystem:SetActive(IsActive)
  printf("IngameSelfieWeatherSubsystem:SetActive %s", IsActive)
  if not self:IsSupportChangingWeather() then
    self:_ClearEnsureCheckTimer()
    printf("IngameSelfieWeatherSubsystem:SetActive self:IsSupportChangingWeather() == false, return")
    return
  end
  if self.IsActive == IsActive then
    printf("IngameSelfieWeatherSubsystem:SetActive not changed, return")
    return
  end
  self:_ClearEnsureCheckTimer()
  if IsActive then
    self.EnsureCheckTimer = self:AddGameTimer(ENSURE_CHECK_INTERVAL, true, function()
      self:TryUpdateWeatherSequence(2)
      self:TryUpdateSkyTransition()
    end)
    if self.IsSunnyWeather then
      self:_ChangeSkyMaterial(SKY_CONFIG.Sunny.Material)
    end
  else
    local WeatherSubsystem = SubsystemMgr:Get("WeatherSubsystem")
    WeatherSubsystem:RestoreSkyMaterial(GameplayData.GetPlayerCharacter())
    WeatherSubsystem:CancelChangeSkyMaterialCallback()
    self:_ClearSkyTransitionTimer()
    self:_ClearPlaybackTimer()
  end
  self.end
function IngameSelfieWeatherSubsystem:TryUpdateWeatherSequence(reason)
  if self.PlaybackTimer or not self.CacheTargetValue then
    return
  end
  self:UpdateWeatherSequence(self.CacheTargetValue, true)
end
function IngameSelfieWeatherSubsystem:UpdateWeatherSequence(ToValue, IsTransitionable)
  if not slua.isValid(self.SequencePlayer) then
    return
  end
  ToValue = FuncUtil.Clamp(ToValue, 0, 1)
  if not self.OriginLength then
    self.OriginLength = self.SequencePlayer:GetLength()
    printf("IngameSelfieWeatherSubsystem:UpdateWeatherSequence OriginLength = %s", self.OriginLength)
  end
  self:_ClearPlaybackTimer()
  if IsTransitionable then
    local FromValue = self.SequencePlayer:GetPlaybackPosition() / self.OriginLength
    local Delta = math.abs(FromValue - ToValue)
    if Delta < MIN_UPDATE_FRAME_INTERVAL then
      return
    end
    local PlayDirection = ToValue >= FromValue
    local Duration = Delta
    if PlayDirection then
      self.SequencePlayer:Play()
    else
      self.SequencePlayer:PlayReverse()
    end
    printf("IngameSelfieWeatherSubsystem:SetWeatherSequence IsTransitionable %s -> %s (d = %s), Direction = %s", FromValue, ToValue, Duration, PlayDirection)
    self.PlaybackTimer = self:AddGameTimer(MIN_UPDATE_FRAME_INTERVAL, true, function()
      if slua.isValid(self.SequencePlayer) then
        local CurrentPlaybackPos = self.SequencePlayer:GetPlaybackPosition()
        if PlayDirection and CurrentPlaybackPos >= self.OriginLength * ToValue or not PlayDirection and CurrentPlaybackPos <= self.OriginLength * ToValue then
          self.SequencePlayer:Pause()
          printf("IngameSelfieWeatherSubsystem Pause fix PlaybackPosition %s -> %s", CurrentPlaybackPos, self.SequencePlayer:GetPlaybackPosition())
          self:_ClearPlaybackTimer()
        end
      end
    end)
  else
    self.SequencePlayer:SetPlaybackPosition(self.OriginLength * ToValue)
    self.SequencePlayer:Stop()
    printf("IngameSelfieWeatherSubsystem:SetWeatherSequence %s", ToValue)
  end
end
function IngameSelfieWeatherSubsystem:TryUpdateSkyTransition()
  if self.SkyTransitionTimer or self.IsSunnyWeather then
    return
  end
  local ToValue = self.CacheTargetValue
  local ToSkyType = self.CurrentSkyType
  if ToValue < SKY_CONFIG.MaterialTransitionBias then
    ToSkyType = ESkyType.Morning
  elseif ToValue > 0.5 - SKY_CONFIG.MaterialTransitionBias / 2 and ToValue < 0.5 + SKY_CONFIG.MaterialTransitionBias / 2 then
    ToSkyType = ESkyType.Midday
  elseif ToValue > 1 - SKY_CONFIG.MaterialTransitionBias then
    ToSkyType = ESkyType.Night
  end
  if self.CurrentSkyType ~= ToSkyType then
    if math.abs(self.CurrentSkyType - ToSkyType) == 2 then
      printf("IngameSelfieWeatherSubsystem:TryUpdateSkyTransition Enqueue {%d, %d}, {%d, %d}", self.CurrentSkyType, ESkyType.Midday, ESkyType.Midday, ToSkyType)
      table.insert(self.SkyTransitionQueue, {
        self.CurrentSkyType,
        ESkyType.Midday
      })
      table.insert(self.SkyTransitionQueue, {
        ESkyType.Midday,
        ToSkyType
      })
    else
      printf("IngameSelfieWeatherSubsystem:TryUpdateSkyTransition Enqueue {%d, %d}", self.CurrentSkyType, ToSkyType)
      table.insert(self.SkyTransitionQueue, {
        self.CurrentSkyType,
        ToSkyType
      })
    end
    self:CheckSkyTransition()
  end
end
function IngameSelfieWeatherSubsystem:CheckSkyTransition()
  if not self.SkyTransitionQueue or #self.SkyTransitionQueue == 0 then
    return
  end
  local SkyTransitionInfo = table.remove(self.SkyTransitionQueue, 1)
  local FromSkyType = SkyTransitionInfo[1]
  local ToSkyType = SkyTransitionInfo[2]
  printf("IngameSelfieWeatherSubsystem:CheckSkyTransition Dequeue %d -> %d", FromSkyType, ToSkyType)
  local SkyMaterialAsset
  SkyMaterialAsset = SKY_CONFIG.Dusk.MorningMidday
  if ToSkyType == ESkyType.Night or ToSkyType == ESkyType.Midday and self.CurrentSkyType == ESkyType.Night then
    SkyMaterialAsset = SKY_CONFIG.Dusk.MiddayNight
  end
  self:_ChangeSkyMaterial(SkyMaterialAsset, function(SkyMaterial)
    if not SkyMaterial or not slua.isValid(SkyMaterial) then
      return
    end
    self:_EnsureTweenManagerActor()
    local FromValue = ToSkyType == ESkyType.Midday and 1 or 0
    local ToValue = 1 - FromValue
    local Duration = 1
    printf("IngameSelfieWeatherSubsystem:CheckSkyTransition ChangeSkyMaterial %s SkyType(%d -> %d), tween factor %s -> %s", SkyMaterialAsset, self.CurrentSkyType, ToSkyType, FromValue, ToValue)
    local _, TweenFloat = UTweenFloatStandardFactory.BP_CreateTweenMaterialFloatFromTo(nil, SkyMaterial, nil, nil, "Morning&Night Factor", FromValue, ToValue, Duration, ETweenEaseType.Linear, 1, ETweenLoopType.Yoyo, 0, 1, -1)
    self.SkyTransitionTimer = self:AddGameTimer(Duration, false, function()
      self.SkyTransitionTimer = nil
      self.CurrentSkyType = ToSkyType
      self:CheckSkyTransition()
    end)
  end)
end
function IngameSelfieWeatherSubsystem:_EnsureTweenManagerActor()
  if self.TweenManagerActor then
    return
  end
  local uPC = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPC) then
    return
  end
  local loadClass = slua.loadClass("/Game/Mod/EvoBase/Arts_Scenes/Weather/BP_TweenManagerActor.BP_TweenManagerActor")
  local uWorld = slua_GameFrontendHUD:GetWorld()
  self.TweenManagerActor = uWorld:SpawnActor(loadClass, uPC:K2_GetActorLocation(), nil, nil)
  if slua.isValid(self.TweenManagerActor) then
    printf("IngameSelfieWeatherSubsystem:_CheckTweenManagerActor Create BP_TweenManagerActor")
  else
    printf("IngameSelfieWeatherSubsystem:_CheckTweenManagerActor Create BP_TweenManagerActor failed")
  end
end
function IngameSelfieWeatherSubsystem:_ChangeSkyMaterial(SkyMaterialAsset, Callback)
  printf("IngameSelfieWeatherSubsystem:_ChangeSkyMaterial %s", SkyMaterialAsset)
  local WeatherSubsystem = SubsystemMgr:Get("WeatherSubsystem")
  WeatherSubsystem:CancelChangeSkyMaterialCallback()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  printf("IngameSelfieWeatherSubsystem:_ChangeSkyMaterial - WeatherSubsystem:ChangeSkyMaterial %s", SkyMaterialAsset)
  return WeatherSubsystem:ChangeSkyMaterial(uPlayerCharacter, SkyMaterialAsset, Callback)
end
function IngameSelfieWeatherSubsystem:_ClearEnsureCheckTimer()
  if self.EnsureCheckTimer then
    self:RemoveGameTimer(self.EnsureCheckTimer)
    self.EnsureCheckTimer = nil
  end
end
function IngameSelfieWeatherSubsystem:_ClearPlaybackTimer()
  if self.PlaybackTimer then
    self:RemoveGameTimer(self.PlaybackTimer)
    self.PlaybackTimer = nil
  end
end
function IngameSelfieWeatherSubsystem:_ClearSkyTransitionTimer()
  if self.SkyTransitionTimer then
    self:RemoveGameTimer(self.SkyTransitionTimer)
    self.SkyTransitionTimer = nil
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, IngameSelfieWeatherSubsystem)