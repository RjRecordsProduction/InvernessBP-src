local BP_GameEventListener = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
function BP_GameEventListener:ctor()
  self.FlyLevelName = nil
end
function BP_GameEventListener:ReceiveBeginPlay()
  if Client then
    self:InitIncaseReconnect()
    self:ChangeStreamingLevel()
    self:UnloadTree()
    self:AddControlEvent(self, "OnGameEventListener", self.HandleGamePawnEvent, self)
    if not SubsystemMgr:Get("MapCityNameSubsystem") then
      self:CityNameLevelOnInit()
    end
  end
end
function BP_GameEventListener:HandleGamePawnEvent(GamePawnEvent)
  local GamePawnEventType = import("EGamePawnEvent")
  if GamePawnEvent then
    if GamePawnEvent == GamePawnEventType.ViewPlane then
      self:LoadTree()
      local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
      uGameInstance:EnableStreamingLevelLOD(true)
    elseif GamePawnEvent == GamePawnEventType.Land then
      self:EnableGrassLOD(1)
      self:ChangeStreamingLevel()
      self:UnloadTree()
      self:SetDefaultNearClipPlane()
      print(bWriteLog and "[GE] BP_GameEventListener Land")
    elseif GamePawnEvent == GamePawnEventType.ReBirth then
      self:InitIncaseReconnect()
    elseif GamePawnEvent == GamePawnEventType.HeightCheck_Mid then
      self:EnableGrassLOD(0)
    elseif GamePawnEvent == GamePawnEventType.HeightCheck_Low then
      self:ChangeStreamingLevel()
      self:UnloadTree()
      self:SetDefaultNearClipPlane()
    end
  end
end
function BP_GameEventListener:ReceiveEndPlay()
  self:SetDefaultRendering()
  if Client and not SubsystemMgr:Get("MapCityNameSubsystem") then
    self:CityNameLevelOnRelease()
  end
  self:Dispose()
end
function BP_GameEventListener:LoadTree()
  local UIUtil = require("client.common.ui_util")
  local deviceLevel = UIUtil.GetGameInstance():GetDeviceLevel()
  if deviceLevel == 2 then
    local GameplayStatics = import("GameplayStatics")
    local uWorld = slua_GameFrontendHUD:GetWorld()
    local async = require("client.common.async")
    async.Run(function(co)
      local FlyLevelName = self:GetFlyLevelName()
      if FlyLevelName then
        GameplayStatics.LoadStreamLevel(uWorld, FlyLevelName, true, false)
      end
    end)
  end
end
function BP_GameEventListener:UnloadTree()
  local UIUtil = require("client.common.ui_util")
  local deviceLevel = UIUtil.GetGameInstance():GetDeviceLevel()
  if deviceLevel == 2 then
    local GameplayStatics = import("GameplayStatics")
    local uWorld = slua_GameFrontendHUD:GetWorld()
    local async = require("client.common.async")
    async.Run(function(co)
      local FlyLevelName = self:GetFlyLevelName()
      if FlyLevelName then
        GameplayStatics.UnLoadStreamLevel(uWorld, FlyLevelName)
      end
    end)
  end
end
function BP_GameEventListener:GetFlyLevelName()
  if self.FlyLevelName == nil then
    local uWorld = slua_GameFrontendHUD:GetWorld()
    if slua.isValid(uWorld) and uWorld.WorldComposition then
      local TilesStreaming = uWorld.WorldComposition.TilesStreaming
      local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
      local ModType, ModType2 = GameMainConfig.GetModType()
      local sFlyLevelName = "Fly"
      local sFlyLevelModName = "Fly_" .. ModType
      if TilesStreaming:Num() > 0 then
        for i = 0, TilesStreaming:Num() - 1 do
          local uLevelStreaming = TilesStreaming:Get(i)
          if uLevelStreaming then
            local PackageName = uLevelStreaming.PackageNameToLoad
            if string.len(PackageName) >= string.len(sFlyLevelModName) and string.sub(PackageName, string.len(PackageName) - string.len(sFlyLevelModName) + 1, -1) == sFlyLevelModName then
              self.FlyLevelName = PackageName
              break
            end
            if string.len(PackageName) >= string.len(sFlyLevelName) and string.sub(PackageName, string.len(PackageName) - string.len(sFlyLevelName) + 1, -1) == sFlyLevelName then
              self.FlyLevelName = PackageName
              break
            end
          end
        end
      end
    end
  end
  return self.FlyLevelName
end
function BP_GameEventListener:InitIncaseReconnect()
  if self:IsPlayerLandFromTheAir() then
    self:ChangeStreamingLevel()
    self:EnableGrassLOD(1)
    self:UnloadTree()
    if not self:IsIOSPlatform() then
      UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, "r.SetNearClipPlane 3")
      self.bNearClipInPlane = false
      print(bWriteLog and "[GE] Init incase reconnect r.SetNearClipPlane 3")
    end
  elseif self:IsPlayerFlying() then
    self:LoadTree()
    local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
    uGameInstance:EnableStreamingLevelLOD(true)
    if not self:IsIOSPlatform() then
      UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, "r.SetNearClipPlane 230")
      self.bNearClipInPlane = true
      print(bWriteLog and "[GE] Init incase reconnect r.SetNearClipPlane 230")
    end
  end
end
function BP_GameEventListener:ChangeStreamingLevel()
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  if uGameInstance:GetDeviceLevel() >= 2 then
    uGameInstance:SetWorldCompositionRelativeDistance(1, -100000)
  else
    uGameInstance:EnableStreamingLevelLOD(false)
  end
end
function BP_GameEventListener:EnableGrassLOD(Enable)
  local uGameInstance = slua_GameFrontendHUD:GetGameInstance()
  uGameInstance:ExecuteCMD("grass.EnableLOD", tostring(Enable))
end
function BP_GameEventListener:SetDefaultRendering()
  self:SetDefaultNearClipPlane()
  self:ScaleScreenSizeCulling(0)
end
function BP_GameEventListener:IsIOSPlatform()
  local GameplayStatics = import("GameplayStatics")
  local PlatformID = GameplayStatics.GetPlatformInt()
  if PlatformID == 5 then
    return true
  else
    return false
  end
end
function BP_GameEventListener:SetDefaultNearClipPlane()
  if not self:IsIOSPlatform() then
    UKismetSystemLibrary.ExecuteConsoleCommand(self.Object, "r.SetNearClipPlane 3")
    self.bNearClipInPlane = false
    print(bWriteLog and "[GE] SetDefault r.SetNearClipPlane 3")
  end
end
function BP_GameEventListener:Reset()
  self.CityNameYaw = 0
  self.CityNameActors = {}
  self.bHasLoadLevel = false
  self.TickID = 1
  if self.Timer ~= nil then
    print(bWriteLog and "BP_GameEventListener:RemoveTimer")
    self:RemoveGameTimer(self.Timer)
  end
  self.Timer = nil
  self.CityNameLoopCountPerFrame = 1
  self.bShouldShowCityName = true
end
function BP_GameEventListener:AddCityNameActor(uCityNameActor)
  print(bWriteLog and "BP_GameEventListener:AddCityNameActor ", UKismetSystemLibrary.GetDisplayName(uCityNameActor), self.bShouldShowCityName)
  if self.CityNameActors == nil then
    self.CityNameActors = {}
  end
  table.insert(self.CityNameActors, uCityNameActor)
  uCityNameActor:SetActorTickEnabled(false)
  if not self.bShouldShowCityName then
    local RootComp = uCityNameActor:K2_GetRootComponent()
    if slua.isValid(RootComp) then
      RootComp:SetHiddenInGame(true, true)
    end
  end
end
function BP_GameEventListener:CityNameLevelOnInit()
  print(bWriteLog and "BP_GameEventListener:OnInit")
  self:Reset()
  self:BindEvents()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    if not uPlayerController:IsDemoPlaySpectator() and (not uPlayerController.IsInPetSpectator or not uPlayerController:IsInPetSpectator()) then
      local EStateType = import("EStateType")
      local PCState = uPlayerController:GetCurrentStateType()
      if PCState == EStateType.State_InPlane then
        self:LoadCityNameLevel(true)
      end
    end
  else
    print(bWriteLog and "BP_GameEventListener:OnInit uPlayerController invalid!")
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLv = GameInstance:GetExactDeviceLevel()
  if 1 <= nDeviceLv then
    self.CityNameLoopCountPerFrame = 10
  end
end
function BP_GameEventListener:CreateCityNamesTimer()
  if Client then
    if self.Timer ~= nil then
      return
    end
    print(bWriteLog and "BP_GameEventListener:CreateCityNamesTimer")
    self.Timer = self:AddGameTimer(0.05, true, function()
      if self.bHasLoadLevel == false then
        return
      end
      local count = #self.CityNameActors
      if count == 0 then
        return
      end
      local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
      if not slua.isValid(uPlayerController) then
        return
      end
      local uPlayerCharacter
      if uPlayerController.GetCurPlayerCharacter then
        uPlayerCharacter = uPlayerController:GetCurPlayerCharacter()
      end
      local PlayerLocation
      if not slua.isValid(uPlayerCharacter) then
        local uSpectatorPawn = uPlayerController:GetSpectatorPawn()
        if slua.isValid(uSpectatorPawn) then
          PlayerLocation = uSpectatorPawn:K2_GetActorLocation()
        end
      else
        PlayerLocation = uPlayerCharacter:K2_GetActorLocation()
      end
      if PlayerLocation == nil then
        return
      end
      for i = 1, self.CityNameLoopCountPerFrame do
        if count < self.TickID then
          self.TickID = 1
        end
        local city_name_obj = self.CityNameActors[self.TickID]
        if city_name_obj ~= nil and slua.isValid(city_name_obj.Object) then
          city_name_obj:UpdateCityName(PlayerLocation)
        else
          print(bWriteLog and "BP_GameEventListener:city_name_obj is not valid ", self.TickID)
        end
        self.TickID = self.TickID + 1
      end
    end)
  end
end
function BP_GameEventListener:RemoveCityNamesTimer()
  if self.Timer ~= nil then
    print(bWriteLog and "BP_GameEventListener:RemoveCityNamesTimer")
    self:RemoveGameTimer(self.Timer)
  end
  self.Timer = nil
end
function BP_GameEventListener:CityNameLevelOnRelease()
  print(bWriteLog and "BP_GameEventListener:OnRelease")
  self:LoadCityNameLevel(false)
  self:UnBindEvents()
  self:Reset()
end
function BP_GameEventListener:BindEvents()
  print(bWriteLog and "BP_GameEventListener:BindEvents")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:AddControlEvent(uPlayerController, "OnPlayerControllerStateChangedDelegate", self.PlayerControllerStateChanged, self)
  end
end
function BP_GameEventListener:UnBindEvents()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:RemoveControlEvent(uPlayerController, "OnPlayerControllerStateChangedDelegate")
  end
end
function BP_GameEventListener:PlayerControllerStateChanged(CurStateType)
  local EStateType = import("EStateType")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      print(bWriteLog and "BP_GameEventListener OnPlayerControllerStateChangedDelegate playerkey = ", Game:GetPlayerKey(uPlayerCharacter), CurStateType)
    end
    print(bWriteLog and "BP_GameEventListener OnPlayerControllerStateChangedDelegate ", CurStateType, uPlayerController:IsSpectator(), uPlayerController:IsDemoPlaySpectator(), uPlayerController:IsObserver())
    if not uPlayerController:IsDemoPlaySpectator() and (not uPlayerController.IsInPetSpectator or not uPlayerController:IsInPetSpectator()) then
      if CurStateType == EStateType.State_InPlane then
        self:LoadCityNameLevel(true)
      elseif CurStateType == EStateType.State_Fight and uPlayerController.GetLastStateType and uPlayerController:GetLastStateType() ~= EStateType.State_Initial and uPlayerController:GetLastStateType() ~= EStateType.State_None then
        self:LoadCityNameLevel(false)
        self:UnBindEvents()
        self:Reset()
      end
      if CurStateType == EStateType.State_ParachuteJump or CurStateType == EStateType.State_ParachuteOpen then
        self:CreateCityNamesTimer()
      end
    end
  end
end
function BP_GameEventListener:LoadCityNameLevel(bLoad)
  print(bWriteLog and "BP_GameEventListener:LoadCityNameLevel")
  local GameplayStatics = import("GameplayStatics")
  local World = slua_GameFrontendHUD:GetWorld()
  local async = require("client.common.async")
  if bLoad then
    if not self.bHasLoadLevel then
      async.Run(function(co)
        GameplayStatics.LoadStreamLevel(World, self:GetCityLevelName(), true, false)
        print(bWriteLog and "BP_GameEventListener:LoadCityNameLevel load")
        self.bHasLoadLevel = true
      end)
    end
  else
    async.Run(function(co)
      GameplayStatics.UnLoadStreamLevel(World, self:GetCityLevelName())
      print(bWriteLog and "BP_GameEventListener:LoadCityNameLevel unload")
      self.bHasLoadLevel = false
      self:RemoveCityNamesTimer()
    end)
  end
end
function BP_GameEventListener:GetCityNameRotationYaw()
  if self.CityNameYaw == 0 then
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(uPlayerController) then
      local uPlayerState = uPlayerController:GetCurPlayerState()
      if slua.isValid(uPlayerState) then
        local StartPos = uPlayerState:GetAirplaneStartLoc()
        local StopPos = uPlayerState:GetAirplaneStopLoc()
        local FlightDirection = StopPos - StartPos
        self.CityNameYaw = FlightDirection:Rotation().Yaw + 90
      else
        print(bWriteLog and "BP_GameEventListener:GetCityNameRotationYaw uPlayerState is invalid")
      end
    end
  end
  return self.CityNameYaw
end
function BP_GameEventListener:ShowAllCityName(bShow)
  print(bWriteLog and "BP_GameEventListener:ShowAllCityName", bShow)
  self.bShouldShowCityName = bShow
  if not self.CityNameActors then
    print(bWriteLog and "BP_GameEventListener:ShowAllCityName self.CityNameActors invalid")
    return
  end
  for _, CityNameActor in pairs(self.CityNameActors) do
    if Game:IsValid(CityNameActor) and CityNameActor.K2_GetRootComponent then
      local RootComp = CityNameActor:K2_GetRootComponent()
      if slua.isValid(RootComp) then
        RootComp:SetHiddenInGame(not bShow, true)
      end
    end
  end
end
function BP_GameEventListener:GetCityLevelName()
  print(bWriteLog and "BP_GameEventListener:GetCityLevelName")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, ModType2 = GameMainConfig.GetModType()
  local uWorld = slua_GameFrontendHUD:GetWorld()
  if slua.isValid(uWorld) and uWorld.WorldComposition then
    local TilesStreaming = uWorld.WorldComposition.TilesStreaming
    if ModType ~= "BaseMod" and ModType ~= "Default" and TilesStreaming:Num() > 0 then
      local sCityNameMod = "CityName_" .. ModType
      for i = 0, TilesStreaming:Num() - 1 do
        local uLevelStreaming = TilesStreaming:Get(i)
        if uLevelStreaming then
          local PackageName = uLevelStreaming.PackageNameToLoad
          if string.len(PackageName) >= string.len(sCityNameMod) and string.sub(PackageName, string.len(PackageName) - string.len(sCityNameMod) + 1, -1) == sCityNameMod then
            return sCityNameMod
          end
        end
      end
    end
  end
  return "CityName"
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, BP_GameEventListener)