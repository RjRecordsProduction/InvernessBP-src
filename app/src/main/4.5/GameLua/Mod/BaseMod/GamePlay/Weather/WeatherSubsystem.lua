local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local TableUtil = require("common.table_util")
local StringUtil = require("common.string_util")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local WeatherSubsystem = {}
local Config = {
  SkyAsset = {
    SkySphereActorClass = "/Game/Arts_Scenes/Meshs/Sky/BP_Sky_Sphere_Base.BP_Sky_Sphere_Base_C"
  },
  DefaultFallbackWeatherLevel = "PUBG_Forest_SunnyDay",
  Test = {WeatherHigh = false}
}
local ENSURE_WEATHER_LEVEL_LOADED_INTERVAL = 5
local ENSURE_WEATHER_LEVEL_LOADED_RETRY_TIMES = 5
function WeatherSubsystem:_PostConstruct()
  printf("WeatherSubsystem:_PostConstruct")
  self.CurrentWeatherLevel = ""
  self.CacheMaterials = {}
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_STATE_WEATHER_CHANGE, self._OnWeatherLevelChanged, self)
  if Client then
    self.PreInitClientWeatherTimer = self:AddGameTimer(0, false, function()
      self:PreInitClientWeather()
    end)
    self.IsReleased = false
  end
end
function WeatherSubsystem:OnInit()
  printf("WeatherSubsystem:OnInit")
  if not Client then
    if GamePlayTools.IsEditor() then
      self:InitDSWeather()
    else
      self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_INIT, self.InitDSWeather, self)
    end
  end
end
function WeatherSubsystem:OnRelease()
  printf("WeatherSubsystem:OnRelease")
  self:TryRemoveNamedGameTimer("PreInitClientWeatherTimer")
  self.CacheMaterials = {}
  self.OriginSkyMaterial = nil
  if Client then
    self:_SetEnsureWeatherLevelLoadedEnabled(false)
    self:_RestoreHDRWeather()
    self.IsReleased = true
  end
  WeatherSubsystem.__super.OnRelease(self)
end
function WeatherSubsystem:PreInitClientWeather()
  if _G.IsEditor then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if Config.Test.WeatherHigh then
      UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "p.EditorTestWeatherHigh 1")
    else
      UKismetSystemLibrary.ExecuteConsoleCommand(uPlayerController, "p.EditorTestWeatherHigh 0")
    end
  end
  local WeatherConfig = GamePlayTools.GetCurrentConfig("WeatherConfig")
  if WeatherConfig.DisableHDRWeather == true then
    self:_DisableHDRWeather("WeatherConfig.DisableHDRWeather")
  elseif GamePlayTools.IsThemeBRMode() and GameMainConfig.GetMapType() == "Baltic" then
    self:_DisableHDRWeather("IsThemeBRMode & Baltic")
  end
  if WeatherConfig.DisablePreloadDefaultWeather == true then
    printf("WeatherSubsystem:OnInit DisablePreloadDefaultWeather, return")
    return
  end
  self.DefaultWeatherLevel, self.MapWeatherLevels = self:_GetDefaultWeatherLevel()
  if self.MapWeatherLevels and #self.MapWeatherLevels > 0 then
    if #self.MapWeatherLevels == 1 then
      if Config.Test.ForceWeather then
        self.DefaultWeatherLevel = Config.Test.ForceWeather
      end
      if not self:IsWeatherLevelEmpty(self.DefaultWeatherLevel) then
        printf("WeatherSubsystem:OnInit Find only one weather, start load default: %s", self.DefaultWeatherLevel)
        self:ChangeWeather(self.DefaultWeatherLevel)
      else
        printf("WeatherSubsystem:OnInit DefaultWeatherLevel is empty, will ignore weather")
      end
    else
      printf("WeatherSubsystem:OnInit Find %d weathers, will determined by EVENTID_GAME_STATE_WEATHER_CHANGE", #self.MapWeatherLevels)
    end
  else
    printf("WeatherSubsystem:OnInit Find no weathers, will ignore weather")
  end
end
function WeatherSubsystem:TryCacheOriginSkyMaterial()
  if (not self.OriginSkyMaterial or not slua.isValid(self.OriginSkyMaterial)) and slua.isValid(CGameWorld) then
    local SkySphereActor = ActorTools.GetOneActor(CGameWorld, Config.SkyAsset.SkySphereActorClass)
    if slua.isValid(SkySphereActor) then
      self.OriginSkyMaterial = SkySphereActor.SrcMaterial
      printf("WeatherSubsystem:ChangeSkyMaterial cache origin sky material: %s", self.OriginSkyMaterial)
    end
  end
end
function WeatherSubsystem:_OnWeatherLevelChanged(_, __, NewWeatherLevel)
  printf("[NewWeather] WeatherSubsystem:ChangeWeather _OnWeatherLevelChanged----------------------------------- %s", NewWeatherLevel)
  self:ChangeWeather(NewWeatherLevel)
end
function WeatherSubsystem:GetWeatherLevel(bCheckHighWeatherLevel)
  if not bCheckHighWeatherLevel then
    return self.CurrentWeatherLevel
  else
    return self:_GetFinalWeatherLevel(self.CurrentWeatherLevel)
  end
end
function WeatherSubsystem:ChangeWeather(NewWeatherLevel)
  if self:IsWeatherLevelEmpty(NewWeatherLevel) then
    printf("[NewWeather] WeatherSubsystem:ChangeWeather NewWeatherLevel is empty (%s), return", NewWeatherLevel)
    return
  end
  printf("[NewWeather] WeatherSubsystem:ChangeWeather (%s)", NewWeatherLevel)
  if not Client then
    CGameState.WeatherLevel = NewWeatherLevel
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_CHANGE_WEATHER_DS, NewWeatherLevel)
  else
    local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
    if not LevelStreamingMgr then
      printf("[NewWeather] WeatherSubsystem:ChangeWeather LevelStreamingMgr is not valid, return")
      return
    end
    if self.CurrentWeatherLevel == NewWeatherLevel then
      if LevelStreamingMgr:IsStreamLevelLoaded(self.CurrentWeatherLevel) then
        printf("[NewWeather] WeatherSubsystem:ChangeWeather same weather %s is loaded, return", NewWeatherLevel)
        return false
      elseif self.LoadingWeatherLevel == NewWeatherLevel then
        printf("[NewWeather] WeatherSubsystem:ChangeWeather same weather %s is under loading, return", NewWeatherLevel)
        return false
      end
    end
    self:CheckWeatherLevelExist(NewWeatherLevel)
    if not LevelStreamingMgr:IsStreamLevelExist(NewWeatherLevel) then
      if NewWeatherLevel ~= self.DefaultWeatherLevel then
        printf("[NewWeather] WeatherSubsystem:ChangeWeather level %s is not exist, try default weather", NewWeatherLevel)
        return self:ChangeWeather(self.DefaultWeatherLevel)
      else
        printf("[NewWeather] WeatherSubsystem:ChangeWeather default level %s is not exist", NewWeatherLevel)
        return false
      end
    end
    printf("[NewWeather] WeatherSubsystem:ChangeWeather Unload: %s -> Load: %s", self.CurrentWeatherLevel, NewWeatherLevel)
    if self.CurrentWeatherLevel ~= nil and self.CurrentWeatherLevel ~= "" then
      if self:ShouldUnLoadOldWeather() then
        printf("[NewWeather] WeatherSubsystem:ChangeWeather [Unload] UnloadStreamLevelNoLatent: %s -> Load: %s", self.CurrentWeatherLevel, NewWeatherLevel)
        if self:IsAsyncUnload() then
          LevelStreamingMgr:UnloadStreamLevel(self.CurrentWeatherLevel)
        else
          LevelStreamingMgr:UnloadStreamLevelNoLatent(self.CurrentWeatherLevel)
        end
      else
        printf("[NewWeather] WeatherSubsystem:ChangeWeather [Unload] ChangeStreamLevelVisible: %s -> Load: %s", self.CurrentWeatherLevel, NewWeatherLevel)
        LevelStreamingMgr:ChangeStreamLevelVisible(self.CurrentWeatherLevel, false)
        self:FlushStreamingLevelStatus()
      end
    end
    local FinalWeatherLevel = self:_GetFinalWeatherLevel(NewWeatherLevel)
    if not LevelStreamingMgr:IsStreamLevelExist(FinalWeatherLevel) then
      printf("[NewWeather] WeatherSubsystem:ChangeWeather FinalWeatherLevel: %s is not exist", FinalWeatherLevel)
      FinalWeatherLevel = NewWeatherLevel
    end
    self.CurrentWeatherLevel = NewWeatherLevel
    if not LevelStreamingMgr:IsStreamLevelLoaded(FinalWeatherLevel) then
      self:LoadStreamingLevel(FinalWeatherLevel)
      self:_SetEnsureWeatherLevelLoadedEnabled(true)
    else
      LevelStreamingMgr:ChangeStreamLevelVisible(FinalWeatherLevel, true)
      self:FlushStreamingLevelStatus()
      self:OnLoadWeatherLevelCompleted(FinalWeatherLevel)
    end
    return true
  end
end
function WeatherSubsystem:IsAsyncUnload()
  return false
end
function WeatherSubsystem:FlushAfterChagned()
  return false
end
function WeatherSubsystem:FlushStreamingLevelStatus()
  print(bWriteLog and "WeatherSubsystem:FlushStreamingLevelStatus")
  if self:FlushAfterChagned() then
    print(bWriteLog and "WeatherSubsystem:FlushStreamingLevelStatus Flushing")
    local uWorld = slua_GameFrontendHUD:GetWorld()
    if slua.isValid(uWorld) then
      local GameplayStatics = import("GameplayStatics")
      GameplayStatics.FlushLevelStreaming(uWorld)
    end
  end
end
function WeatherSubsystem:LoadStreamingLevel(LevelName)
  printf("[NewWeather] WeatherSubsystem:LoadStreamingLevel %s", LevelName)
  if not LevelName then
    return
  end
  self.LoadingWeatherLevel = LevelName
  local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
  LevelStreamingMgr:LoadStreamLevelNoLatent(LevelName, true, true)
  LevelStreamingMgr:RegistLevelLoadedFunc(LevelName, true, true, function()
    printf("[NewWeather] WeatherSubsystem:LoadStreamingLevel %s completed!!", LevelName)
    self.LoadingWeatherLevel = nil
    if not self.IsReleased then
      self:OnLoadWeatherLevelCompleted(LevelName)
    else
      printf("[NewWeather] WeatherSubsystem:LoadStreamingLevel completed but IsReleased")
    end
  end)
end
function WeatherSubsystem:OnLoadWeatherLevelCompleted(LevelName)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ON_LOAD_WEATHER_COMPLETED, LevelName)
  self:UpdateSunDirection()
end
function WeatherSubsystem:UpdateSunDirection()
  print(bWriteLog and string.format("WeatherSubsystem:UpdateSunDirection"))
  local uSkySphereActor = self:GetSkySphere(CGameWorld)
  if not slua.isValid(uSkySphereActor) or not uSkySphereActor.UpdateSunDirection then
    print(bWriteLog and string.format("WeatherSubsystem:UpdateSunDirection uSkySphereActor is not valid, return"))
    return
  end
  if not slua.isValid(uSkySphereActor.StaticMesh) then
    print(bWriteLog and string.format("WeatherSubsystem:UpdateSunDirection uSkySphereActor.StaticMesh is not valid, return"))
    return
  end
  local uStaticMeshMaterial = uSkySphereActor.StaticMesh:GetMaterial(0)
  if not slua.isValid(uStaticMeshMaterial) then
    print(bWriteLog and string.format("WeatherSubsystem:UpdateSunDirection uStaticMeshMaterial is not valid, return"))
    return
  end
  if uSkySphereActor["Sky material"] == uStaticMeshMaterial then
    print(bWriteLog and string.format("WeatherSubsystem:UpdateSunDirection uSkySphereActor['Sky material'] (%s) == uStaticMeshMaterial (%s), return", uSkySphereActor["Sky material"], uStaticMeshMaterial))
    return
  end
  if Game:IsClassOf(uStaticMeshMaterial, import("/Script/Engine.MaterialInstanceDynamic")) then
    print(bWriteLog and string.format("WeatherSubsystem:UpdateSunDirection update Sky material %s | %s", uSkySphereActor["Sky material"], uStaticMeshMaterial))
    uSkySphereActor["Sky material"] = uStaticMeshMaterial
    uSkySphereActor:UpdateSunDirection()
  else
    print(bWriteLog and string.format("WeatherSubsystem:UpdateSunDirection %s is not StaticMeshMaterial, ignore", uStaticMeshMaterial))
  end
end
function WeatherSubsystem:ShouldUnLoadOldWeather()
  return true
end
function WeatherSubsystem:CheckWeatherLevelExist(WeatherLevel)
end
function WeatherSubsystem:_GetDefaultWeatherLevel()
  local ExtractItems = function(ConfigStr)
    if StringUtil.Starts(ConfigStr, "{") and StringUtil.Ends(ConfigStr, "}") then
      local TempStr = string.sub(ConfigStr, 2, string.len(ConfigStr) - 1)
      return StringUtil.Split(TempStr, ";")
    else
      return {}
    end
  end
  local bClient = Client ~= nil
  local ModeID = GameMainConfig.GetModeID()
  local BTMode = CDataTable.GetTableData("BTMode", ModeID)
  if BTMode then
    local MapData = CDataTable.GetTableData("Map", BTMode.MapID)
    if MapData then
      local MapDefaultWeatherLevel = MapData.DefaultWeatherLevel
      local MapWeatherLevels = TableUtil.Map(ExtractItems(MapData.WeatherLevels), function(Item)
        if StringUtil.Starts(Item, "\"") and StringUtil.Ends(Item, "\"") then
          return string.sub(Item, 2, string.len(Item) - 1)
        end
        return Item
      end)
      printf("[NewWeather] WeatherSubsystem:_GetDefaultWeatherLevel ModeID: %s  MapID: %s, MapDefaultWeatherLevel: %s", ModeID, BTMode.MapID, MapDefaultWeatherLevel)
      local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
      if LevelStreamingMgr then
        if LevelStreamingMgr:IsStreamLevelExist(MapDefaultWeatherLevel) then
          return MapDefaultWeatherLevel, MapWeatherLevels
        else
          printf("[NewWeather] WeatherSubsystem:_GetDefaultWeatherLevel Not Exist MapDefaultWeatherLevel: %s", MapDefaultWeatherLevel)
        end
      end
    end
  end
  printf("[NewWeather] WeatherSubsystem:_GetDefaultWeatherLevel use fallback weather %s", Config.DefaultFallbackWeatherLevel)
  return Config.DefaultFallbackWeatherLevel, {
    Config.DefaultFallbackWeatherLevel
  }
end
function WeatherSubsystem:_GetFinalWeatherLevel(WeatherLevel)
  local STExtraGameInstance = import("STExtraGameInstance")
  local uGameInstance = STExtraGameInstance.GetInstance()
  local Final  if slua.isValid(uGameInstance) then
    FinalWeatherLevel = uGameInstance:GetLoadWeatherName(WeatherLevel)
    if FinalWeatherLevel ~= WeatherLevel then
      printf("[NewWeather] WeatherSubsystem use high weather: %s -> %s", WeatherLevel, FinalWeatherLevel)
    end
  end
  return FinalWeatherLevel
end
function WeatherSubsystem:_SetEnsureWeatherLevelLoadedEnabled(bEnabled)
  self:_StopEnsureWeatherLevelLoadedTimer()
  printf("WeatherSubsystem:_SetEnsureWeatherLevelLoadedEnabled %s", bEnabled)
  if not bEnabled then
    return
  end
  local RetryTimes = 0
  local RetryWeatherLevel = self:_GetFinalWeatherLevel(self.CurrentWeatherLevel)
  self.EnsureWeatherLevelLoadedTimer = self:AddGameTimer(ENSURE_WEATHER_LEVEL_LOADED_INTERVAL, true, function()
    if not RetryWeatherLevel then
      printf("WeatherSubsystem EnsureWeatherLevelLoaded WeatherLevel is not valid")
      self:_SetEnsureWeatherLevelLoadedEnabled(false)
    end
    local LevelStreamingMgr = SubsystemMgr:Get("LevelStreamingMgr")
    local IsLoaded = LevelStreamingMgr ~= nil and LevelStreamingMgr:IsStreamLevelLoaded(RetryWeatherLevel)
    RetryTimes = RetryTimes + 1
    if IsLoaded then
      printf("WeatherSubsystem EnsureWeatherLevelLoaded %s is loaded", RetryWeatherLevel)
      self.LoadingWeatherLevel = nil
      self:_SetEnsureWeatherLevelLoadedEnabled(false)
    elseif RetryTimes >= ENSURE_WEATHER_LEVEL_LOADED_RETRY_TIMES then
      log_error("WeatherSubsystem EnsureWeatherLevelLoaded retry reach max times")
      self.LoadingWeatherLevel = nil
      self:_SetEnsureWeatherLevelLoadedEnabled(false)
    else
      printf("WeatherSubsystem EnsureWeatherLevelLoaded %s not loaded, retry %s time", RetryWeatherLevel, RetryTimes)
      self.CurrentWeatherLevel = RetryTimes <= 2 and self.CurrentWeatherLevel or self.DefaultWeatherLevel
      if self.CurrentWeatherLevel == nil then
        printf("WeatherSubsystem EnsureWeatherLevelLoaded CurrentWeatherLevel is nil, _GetDefaultWeatherLevel")
        self.CurrentWeatherLevel, self.MapWeatherLevels = self:_GetDefaultWeatherLevel()
      end
      printf("WeatherSubsystem EnsureWeatherLevelLoaded CurrentWeatherLevel = %s", self.CurrentWeatherLevel)
      RetryWeatherLevel = self:_GetFinalWeatherLevel(self.CurrentWeatherLevel)
      if LevelStreamingMgr then
        printf("[NewWeather] WeatherSubsystem:ChangeWeather LoadingWeatherLevel = %s", RetryWeatherLevel)
        self:LoadStreamingLevel(RetryWeatherLevel)
      end
    end
  end)
end
function WeatherSubsystem:_StopEnsureWeatherLevelLoadedTimer()
  if self.EnsureWeatherLevelLoadedTimer then
    self:RemoveGameTimer(self.EnsureWeatherLevelLoadedTimer)
    self.EnsureWeatherLevelLoadedTimer = nil
  end
end
function WeatherSubsystem:ChangeSkyMaterial(uWorldObject, AssetPath, Callback)
  if not Client then
    return
  end
  local SkySphereActor = ActorTools.GetOneActor(uWorldObject, Config.SkyAsset.SkySphereActorClass)
  if not slua.isValid(SkySphereActor) then
    printf("[NewWeather] WeatherSubsystem:ChangeSkyMaterialr Cannot find SkySphereActor(%s)", Config.SkyAsset.SkySphereActorClass)
    return
  end
  printf("[NewWeather] WeatherSubsystem:ChangeSkyMaterial %s", AssetPath)
  self:TryCacheOriginSkyMaterial()
  self.AsyncChangeSkyMaterial  self:InternalGetSkyMaterial(SkySphereActor.StaticMesh, AssetPath, function(Mat)
    local GameInstance = slua.getGameInstance()
    if slua.isValid(GameInstance) then
      GameInstance:AsyncPSOFlushShaderByLua()
    end
    SkySphereActor.StaticMesh:SetMaterial(0, Mat)
    if self.AsyncChangeSkyMaterialCallback then
      print(bWriteLog and "WeatherSubsystem:ChangeSkyMaterial AsyncChangeSkyMaterialCallback")
      self.AsyncChangeSkyMaterialCallback(Mat)
    end
  end)
end
function WeatherSubsystem:InternalGetSkyMaterial(StaticMesh, AssetPath, Callback)
  if not self.CacheMaterials[AssetPath] then
    local Util = require("client.slua_ui_framework.util")
    local KismetMaterialLibrary = import("KismetMaterialLibrary")
    Util.GetAssetAsync(AssetPath, function(uMaterial)
      local DynamicMaterialInstance = KismetMaterialLibrary.CreateDynamicMaterialInstance(StaticMesh, uMaterial)
      if slua.isValid(DynamicMaterialInstance) then
        printf("[NewWeather] WeatherSubsystem:ChangeSkyMaterial Create dynamic material instance: %s", AssetPath)
        self.CacheMaterials[AssetPath] = DynamicMaterialInstance
        Callback(self.CacheMaterials[AssetPath])
      else
        printf("[NewWeather] WeatherSubsystem:ChangeSkyMaterial Create dynamic material instance failed: %s", AssetPath)
      end
    end)
  else
    Callback(self.CacheMaterials[AssetPath])
  end
end
function WeatherSubsystem:CancelChangeSkyMaterialCallback()
  print(bWriteLog and "WeatherSubsystem:CancelChangeSkyMaterialCallback")
  self.AsyncChangeSkyMaterialCallback = nil
end
function WeatherSubsystem:RestoreSkyMaterial(uWorldObject)
  if slua.isValid(self.OriginSkyMaterial) then
    local SkySphereActor = ActorTools.GetOneActor(uWorldObject, Config.SkyAsset.SkySphereActorClass)
    if not slua.isValid(SkySphereActor) then
      printf("WeatherSubsystem:RestoreSkyMaterial Cannot find SkySphereActor(%s)", Config.SkyAsset.SkySphereActorClass)
      return
    end
    printf("WeatherSubsystem:RestoreSkyMaterial")
    SkySphereActor.StaticMesh:SetMaterial(0, self.OriginSkyMaterial)
  else
    printf("WeatherSubsystem:RestoreSkyMaterial OriginSkyMaterial not valid")
  end
end
function WeatherSubsystem:GetSkySphere(uWorldObject)
  local SkySphereActor = ActorTools.GetOneActor(uWorldObject, Config.SkyAsset.SkySphereActorClass)
  if not slua.isValid(SkySphereActor) then
    printf("[NewWeather] WeatherSubsystem:GetSkySphere Cannot find SkySphereActor(%s)", Config.SkyAsset.SkySphereActorClass)
    return
  end
  return SkySphereActor
end
function WeatherSubsystem:_DisableHDRWeather(Reason)
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if slua.isValid(uGameInstance) then
    printf("WeatherSubsystem:DisableHDRWeather Disable HDR weather Reason: %s", Reason)
    self.CacheHighWeatherNames = {}
    for i = 0, uGameInstance.HighWeatherNames:Num() - 1 do
      local Name = uGameInstance.HighWeatherNames:Get(i)
      printf("WeatherSubsystem:DisableHDRWeather Cache GameInstance.HighWeatherNames %s", Name)
      table.insert(self.CacheHighWeatherNames, Name)
    end
    uGameInstance.HighWeatherNames:Clear()
  end
end
function WeatherSubsystem:_RestoreHDRWeather()
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if slua.isValid(uGameInstance) and self.CacheHighWeatherNames then
    uGameInstance.HighWeatherNames:Clear()
    for _, Name in ipairs(self.CacheHighWeatherNames) do
      printf("CWeatherSubsystem:_RestoreHDRWeather Restore GameInstance.HighWeatherNames %s", Name)
      uGameInstance.HighWeatherNames:Add(Name)
    end
  end
end
function WeatherSubsystem:InitDSWeather()
  printf("WeatherSubsystem:InitDSWeather")
  if Client then
    return
  end
  local WeatherConfig = GamePlayTools.GetCurrentConfig("WeatherConfig")
  if WeatherConfig and WeatherConfig.IgnoreWeatherSyncFromLobbyServer == true then
    printf("WeatherSubsystem:InitDSWeather IgnoreWeatherSyncFromLobbyServer, return")
    return
  end
  if GamePlayTools.IsEditor() then
    local WeatherId, WeatherLevel = self:_GetMapWeatherInfoInEditor()
    CGameState.    CGameState.    printf("WeatherSubsystem:InitDSWeather(Editor) WeatherId = %s, WeatherLevel = %s", CGameState.WeatherId, CGameState.WeatherLevel)
  else
    CGameState.WeatherId = CGameMode.WeatherID
    CGameState.WeatherLevel = CGameMode.WeatherName
    printf("WeatherSubsystem:InitDSWeather(Lobby) WeatherId = %s, WeatherLevel = %s", CGameState.WeatherId, CGameState.WeatherLevel)
  end
  self.CurrentWeatherLevel = CGameState.WeatherLevel
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_STATE_WEATHER_INIT, CGameState.WeatherId, CGameState.WeatherLevel)
  CGameState:ForceNetUpdate()
  if not self:IsUseClientSideLevelStreamingVolumes() then
    printf("WeatherSubsystem:InitDSWeather not UseClientSideLevelStreamingVolumes, will load DS weather")
    local FinalWeatherLevel = self:_GetFinalWeatherLevel(CGameState.WeatherLevel)
    self:DSLoadStreamLevelNoLatent(FinalWeatherLevel)
  end
end
function WeatherSubsystem:IsUseClientSideLevelStreamingVolumes()
  local uPersistentLevel = CGameWorld.PersistentLevel
  if not slua.isValid(uPersistentLevel) or not slua.isValid(uPersistentLevel.WorldSettings) then
    return true
  end
  return uPersistentLevel.WorldSettings.bUseClientSideLevelStreamingVolumes
end
function WeatherSubsystem:DSLoadStreamLevelNoLatent(LevelName)
  printf("WeatherSubsystem:DSLoadStreamLevelNoLatent %s", LevelName)
  if self:IsWeatherLevelEmpty(LevelName) then
    return
  end
  local StreamingLevels = CGameWorld.StreamingLevels
  if not slua.isValid(StreamingLevels) then
    return
  end
  local StringUtil = require("common.string_util")
  for _, uLevelStreaming in pairs(StreamingLevels) do
    local PackageName = uLevelStreaming:GetWorldAssetPackageFName()
    if StringUtil.Ends(PackageName, LevelName) then
      printf("WeatherSubsystem:DSLoadStreamLevelNoLatent LoadStreamLevel: %s", LevelName)
      uLevelStreaming.bShouldBlockOnLoad = true
      uLevelStreaming.bShouldBeLoaded = true
      uLevelStreaming.bShouldBeVisible = true
      uLevelStreaming.LevelLODIndex = -1
    end
  end
end
function WeatherSubsystem:_GetMapWeatherInfoInEditor()
  local ExtractItems = function(ConfigStr)
    if StringUtil.Starts(ConfigStr, "{") and StringUtil.Ends(ConfigStr, "}") then
      local TempStr = string.sub(ConfigStr, 2, string.len(ConfigStr) - 1)
      return StringUtil.Split(TempStr, ";")
    else
      return {}
    end
  end
  local WeatherId = 1
  local WeatherLevel = "PUBG_Forest_SunnyDay"
  if Config.Test.ForceWeather then
    WeatherId = 99
    WeatherLevel = Config.Test.ForceWeather
    return WeatherId, WeatherLevel
  end
  local ModeID = GameMainConfig.GetModeID()
  local BTMode = CDataTable.GetTableData("BTMode", ModeID)
  if BTMode then
    local MapData = CDataTable.GetTableData("Map", BTMode.MapID)
    if MapData and MapData.WeatherWeights and MapData.WeatherLevels then
      local WeatherIds = TableUtil.Map(ExtractItems(MapData.WeatherIds), function(Item)
        return tonumber(Item)
      end)
      local WeatherWeights = TableUtil.Map(ExtractItems(MapData.WeatherWeights), function(Item)
        return tonumber(Item)
      end)
      local WeatherLevels = TableUtil.Map(ExtractItems(MapData.WeatherLevels), function(Item)
        if StringUtil.Starts(Item, "\"") and StringUtil.Ends(Item, "\"") then
          return string.sub(Item, 2, string.len(Item) - 1)
        end
        return Item
      end)
      if #WeatherIds ~= #WeatherWeights or #WeatherIds ~= #WeatherLevels then
        log_error("[NewWeather] Map config error")
        return WeatherId, WeatherLevel
      end
      local ValueWeights = {}
      for i = 1, #WeatherIds do
        local Id = WeatherIds[i]
        local Level = WeatherLevels[i]
        local Weight = WeatherWeights[i]
        ValueWeights[{Id, Level}] = Weight
      end
      printf("WeatherSubsystem:_GetMapWeatherInfoInEditor ModeId = %s MapId = %s", ModeID, BTMode.MapID)
      log_tree("WeatherSubsystem:_GetMapWeatherInfoInEditor", ValueWeights)
      local Result = Game:RandomByWeight(ValueWeights, 1)[1]
      if Result and 0 < #Result then
        WeatherId, WeatherLevel = Result[1], Result[2]
      else
        return WeatherId, WeatherLevel
      end
    end
  end
  return WeatherId, WeatherLevel
end
function WeatherSubsystem:IsWeatherLevelEmpty(WeatherLevel)
  if WeatherLevel == nil or StringUtil.StrTrim(WeatherLevel) == "" then
    return true
  end
  return false
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, WeatherSubsystem)