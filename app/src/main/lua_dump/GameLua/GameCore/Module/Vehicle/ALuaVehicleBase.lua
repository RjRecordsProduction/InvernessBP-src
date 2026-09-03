local LuaVehicleBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {
    "OnMeshPhysicsCreate",
    "VehicleSkillEnergyChanged",
    "VehicleEndPlayEvent"
  }
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local BackpackUtils = import("BackpackUtils")
local ESTExtraVehicleHealthState = import("ESTExtraVehicleHealthState")
local GameplayStatics = import("GameplayStatics")
local KismetSystemLibrary = import("KismetSystemLibrary")
local GameLuaAPI = import("/Script/ShadowTrackerExtra.GameLuaAPI")
local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
local UScriptGameplayStatics = import("ScriptGameplayStatics")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
function LuaVehicleBase:ctor(SelfType)
  self.SeatComponent = nil
  self.AvatarComponent = nil
  self.AdvanceAvatarComponent = nil
  self.BP_VehicleDIYComp = nil
  self.ClientUsedAvatarID = 0
  self.CommonComponent = nil
  self.SpringArm = nil
  self.LastOccupiers = {}
  self.AttachedCharacterLocation = {}
  self.AttachedCharacterBlock = {}
  self.OnMeshPhysicsCreateDelegate = "OnMeshPhysicsCreate"
  self.bCanVehicleExit = true
  self.VehicleRegisterSkills = {}
  self.VehicleProtectionInternalTimer = nil
  self.OriginalCheckStuckInterval = 1
  self.OriginalStuckDuration = 5
  self.UseTimer = nil
  self.DrivingDistance = 0
  self.RecordCharacter = nil
  self.bIsBornIslandVehicle = false
  self.bUGCSkillAirDrop = false
  self.WeddingCarIndex = 0
  self.PassengerEnterShowTextID = nil
  self.PassengerEnterShowIconPath = nil
  self.DriverEnterShowTextID = nil
  self.DriverEnterShowIconPath = nil
  self.LeaveVehicleTextID = nil
  self.LeaveVehicleIconPath = nil
  self.VehicleHPBarName = ""
  self.bUGCInstance = false
  self.UGCInstanceId = 0
end
function LuaVehicleBase:_PostConstruct()
  LuaVehicleBase.__super._PostConstruct(self)
  self:InitConfig()
  if Client then
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SEQUENCE_MSG, self.HandleForbidEnterVehicle, self)
    self:AddControlEvent(self, "OnClientEnterVehicleEvent", self.ClientHandleEnterVehicle, self)
    self:AddControlEvent(self, "OnClientExitVehicleEvent", self.ClientHandleExitVehicle, self)
    self:AddControlEvent(self, "OnClientChangeVehicleSeatEvent", self.ClientHandleChangeVehicleSeat, self)
  else
    self:AddControlEvent(self, "OnEnterVehicle", self.ServerHandleEnterVehicleResult, self)
  end
  self:AddControlEvent(self, "OnVehicleHealthStateChanged", self.LuaHandleHealthStateChanged, self)
  self:AddControlEvent(self, "OnVehicleHealthDestroy", self.LuaHandleVehicleHealthDestroy, self)
  local VehicleSeat = self:GetVehicleSeats()
  if slua.isValid(VehicleSeat) then
    self:AddControlEvent(VehicleSeat, "OnDriverChange", self.HandleDriverChanged, self)
    self:AddControlEvent(VehicleSeat, "OnSeatAttached", self.HandleSeatAttached, self)
    self:AddControlEvent(VehicleSeat, "OnSeatDetached", self.HandleSeatDetached, self)
    self:AddControlEvent(VehicleSeat, "OnSeatChanged", self.HandleSeatChanged, self)
    self:AddControlEvent(VehicleSeat, "OnSeatOccupiersChanged", self.HandleSeatOccupiersChanged, self)
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local bStandalone = UKismetSystemLibrary.IsStandalone(self)
    if bStandalone or not Client then
      self:AddControlEvent(VehicleSeat, "OnSeatDetachedBefore", self.HandleOnSeatDetachedBefore, self)
    end
    if Client then
      self:AddControlEvent(VehicleSeat, "OnClientDriverChange", self.HandleClientDriverChangeEvent, self)
      self:AddControlEvent(VehicleSeat, "OnPlayerCannotExitVehicle", self.HandleOnPlayerCannotExitVehicle, self)
    end
  end
  local VehicleAvatar = self:GetAvatarComponent()
  if slua.isValid(VehicleAvatar) then
    self:AddControlEvent(VehicleAvatar, "VehicleAvatarEqiuped", self.HandleClientAvatarEquiped, self)
    self:AddControlEvent(VehicleAvatar, "VehicleLoadedFPPMesh", self.HandleVehicleLoadedFPPMesh, self)
    self:AddControlEvent(VehicleAvatar, "OnServerAvatarEquiped", self.HandleServerAvatarEquiped, self)
    self:AddControlEvent(VehicleAvatar, "OnVehicleSwitchEffectEnd", self.HandleClientVehicleSwitchEffectEnd, self)
    self.ClientUsedAvatarID = VehicleAvatar:GetDefaultAvatarID()
  end
  local VehicleAdvanceAvatarComp = self:GetAdvanceAvatarComponent()
  if slua.isValid(VehicleAdvanceAvatarComp) then
    self:AddControlEvent(VehicleAdvanceAvatarComp, "OnAvatarAllMeshLoaded", self.HandleAdvanceAvatarEquipped, self)
    self:AddControlEvent(VehicleAdvanceAvatarComp, "OnServerAvatarEquiped", self.HandleAdvanceAvatarEquipped, self)
  end
  local VehicleCabrioletComponent = self:GetVehicleCabrioletComponent()
  if slua.isValid(VehicleCabrioletComponent) and not Client then
    self:AddControlEvent(VehicleCabrioletComponent, "OnVehicleCabrioletStateChanged", self.HandleCabrioletStateChanged, self)
  end
end
function LuaVehicleBase:GetLifetimeReplicatedProps()
  print(bWriteLog and "LuaVehicleBase:GetLifetimeReplicatedProps")
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bUGCSkillAirDrop",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "WeddingCarIndex",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function LuaVehicleBase:OnRep_bUGCSkillAirDrop(OldValue)
  print(bWriteLog and "LuaVehicleBase:OnRep_bUGCSkillAirDrop, OldValue" .. tostring(OldValue))
end
function LuaVehicleBase:OnRep_WeddingCarIndex(OldValue)
  print(bWriteLog and "LuaVehicleBase:OnRep_bIsWeddingFirCar, OldValue" .. tostring(OldValue))
end
function LuaVehicleBase:HandleClientDriverChangeEvent(uOldDriver, uNewDriver)
  if slua.isValid(uNewDriver) and uNewDriver:IsLocallyControlled() and Game:IsValid(self:GetVehicleSpringArm()) and self:GetVehicleSpringArm().bForceInitCameraLagWhenDriverGetOn then
    self:GetVehicleSpringArm().bDoLocationLagInit = false
  end
  self.bBaseAutoMoveForward = false
end
function LuaVehicleBase:HandleOnPlayerCannotExitVehicle(uCharacter, SeatType, SeatIndex)
  if not slua.isValid(uCharacter) then
    return
  end
  local uCurLocation = self:K2_GetActorLocation()
  if self.uLastCannotExitLocation ~= nil and FVector.Distance(uCurLocation, self.uLastCannotExitLocation) < 100 then
    return
  end
  self.uLastCannotExitLocation = uCurLocation
  local CurSpeed = self:GetForwardSpeed()
  if 100 < CurSpeed then
    return
  end
  local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
  local CrashKitReportString = string.format("VehicleLocation:%s,%s,%s SeatIdx:%s", tostring(uCurLocation.X), tostring(uCurLocation.Y), tostring(uCurLocation.Z), tostring(SeatIndex))
  GameReportUtils.BugglyPostExceptionFull("PlayerCannotLeaveVehicle", CrashKitReportString, false)
  print(bWriteLog and "LuaVehicleBase:HandleOnPlayerCannotExitVehicle() " .. CrashKitReportString)
end
function LuaVehicleBase:InitConfig()
  print(bWriteLog and "LuaVehicleBase:InitConfig", self.Object)
  local VehicleConfig = require("GameLua.GameCore.Module.Vehicle.VehicleConfig")
  local TargetConfig = VehicleConfig.GenConfig(self.Object, self.VehicleShapeType)
  if TargetConfig and next(TargetConfig) then
    for Key, Value in pairs(TargetConfig) do
      self[Key] = Value
    end
  end
  self:InitComponents(TargetConfig and TargetConfig.Components or nil)
  self:InitComponentAttributes(TargetConfig and TargetConfig.ComponentsAttrModify or nil)
  self:InitVehicleFeatures(TargetConfig and TargetConfig.VehicleFeatures or nil)
  self:InitCustomConfigs(TargetConfig and TargetConfig.CustomConfigs or nil)
end
function LuaVehicleBase:GetVehicleControlUIConfig()
  return nil
end
function LuaVehicleBase:GetUIConfig()
  return nil
end
function LuaVehicleBase:InitComponents(Components)
  if not Components or not next(Components) then
    return
  end
  for ComponentName, Entry in pairs(Components) do
    local ComponentPath, ComponentConfig = table.unpack(Entry)
    self:AsyncLoadAsset(ComponentPath, function(ComponentClass)
      print(bWriteLog and "LuaVehicleBase:InitConfig", self.Object, ComponentPath)
      if slua.isValid(self.Object) and slua.isValid(ComponentClass) then
        local Component = UScriptGameplayStatics.CreateComponent(self, ComponentClass, ComponentName, false)
        if slua.isValid(Component) then
          self[ComponentName] = Component
          if Component.InitConfig then
            Component:InitConfig(ComponentConfig)
          end
          self:_ExecuteFunctions(ComponentName)
        end
      end
    end)
  end
end
function LuaVehicleBase:InitComponentAttributes(ComponentAttributes)
  if not ComponentAttributes or not next(ComponentAttributes) then
    return
  end
  local InitFunction = function(Component, Attributes)
    if not slua.isValid(Component) then
      return
    end
    for AttributeName, Value in pairs(Attributes) do
      if string.find(AttributeName, "_BPPath") ~= nil then
        AttributeName = string.gsub(AttributeName, "_BPPath", "")
        local SoftObjectPath = KismetSystemLibrary.MakeSoftObjectPath(Value)
        local LoadedDelegate = slua.createDelegate(function(Asset)
          if slua.isValid(Asset) and slua.isValid(Component) then
            Component[AttributeName] = Asset
            print(bWriteLog and string.format("[Vehicle] LuaBase:InitComponentAttributes %s. %s %s  Load Finish", Game:GetPlainName(self), AttributeName, Value))
          end
        end)
        USTExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(SoftObjectPath, LoadedDelegate)
        print(bWriteLog and string.format("[Vehicle] LuaBase:InitComponentAttributes %s. %s %s", Game:GetPlainName(self), AttributeName, Value))
      else
        Component[AttributeName] = Value
        print(bWriteLog and string.format("[Vehicle] LuaBase:InitInitComponentAttributes Config %s. %s %s", Game:GetPlainName(self), AttributeName, tostring(Value)))
      end
    end
  end
  for ComponentName, Attributes in pairs(ComponentAttributes) do
    InitFunction(self[ComponentName], Attributes)
  end
end
function LuaVehicleBase:InitVehicleFeatures(VehicleFeatures)
  if not VehicleFeatures or not next(VehicleFeatures) then
    return
  end
  local FeatureTypes = {}
  for FeatureType, _ in pairs(VehicleFeatures) do
    table.insert(FeatureTypes, FeatureType)
  end
  table.sort(FeatureTypes)
  local Features = {}
  local class = require("class")
  for _, FeatureType in pairs(FeatureTypes) do
    local Config = VehicleFeatures[FeatureType]
    local FeaturePath, NetSide, Params = table.unpack(Config)
    if slua.IsLuaModuleExists(FeaturePath) then
      local FeatureClass = require(FeaturePath)
      local Feature = FeatureClass(self.Object)
      if Params and next(Params) then
        for Key, Value in pairs(Params) do
          Feature[Key] = Value
        end
      end
      if Feature._PostConstruct then
        Feature:_PostConstruct()
      end
      Features[FeatureType] = Feature
    end
  end
  self.Vehicleend
function LuaVehicleBase:InitCustomConfigs(CustomConfigs)
  if not CustomConfigs or not next(CustomConfigs) then
    return
  end
  self.Vehicleend
function LuaVehicleBase:ClearVehicleFeatures()
  if self.VehicleFeatures and next(self.VehicleFeatures) then
    for _, Feature in pairs(self.VehicleFeatures) do
      if Feature and Feature.Dispose then
        Feature:Dispose()
      end
    end
    self.VehicleFeatures = nil
  end
end
function LuaVehicleBase:CallFunction(ComponentName, FunctionName, ...)
  if self[ComponentName] then
    local Component = self[ComponentName]
    if slua.isValid(Component) and Component[FunctionName] then
      return Component[FunctionName](Component, ...)
    end
  else
    local Function = table.pack(ComponentName, FunctionName, ...)
    self.FunctionCache = self.FunctionCache or {}
    if self.FunctionCache then
      self.FunctionCache[ComponentName] = self.FunctionCache[ComponentName] or {}
      table.insert(self.FunctionCache[ComponentName], Function)
    end
  end
end
function LuaVehicleBase:_ExecuteFunctions(ComponentName)
  if not self.FunctionCache or not self.FunctionCache[ComponentName] then
    return
  end
  for _, Function in pairs(self.FunctionCache[ComponentName]) do
    local _, FunctionName, Params = table.unpack(Function)
    self:CallFunction(ComponentName, FunctionName, Params)
  end
end
function LuaVehicleBase:ReceiveBeginPlay()
  LuaVehicleBase.__super.ReceiveBeginPlay(self)
  self:InitOptimizeLeaveVehicle()
  local VehicleSubSystem = SubsystemMgr:Get("VehicleSubsystem")
  if VehicleSubSystem then
    VehicleSubSystem:BeginPlay(self.Object)
  end
  if Client then
    self:CheckAvatarDormant()
    local uAvatarComp = self:GetAvatarComponent()
    if slua.isValid(uAvatarComp) then
      self:AddControlEvent(uAvatarComp, "OnEndChangeItemAvatar", self.OnEndChangeVehicleItemAvatar, self)
    end
    local uAdvanceAvatarComp = self:GetAdvanceAvatarComponent()
    if slua.isValid(uAdvanceAvatarComp) then
      self:AddControlEvent(uAdvanceAvatarComp, "OnRegisterEntityTick", self.CheckAvatarDormant, self)
    end
  else
    local VehicleCommon = self:GetCommonComponent()
    if slua.isValid(VehicleCommon) then
      self:AddControlEvent(VehicleCommon, "OnHPPreChange", self.HandleHPPreChange, self)
    end
    self.bSkipComparePropertiesForReplay = true
    local uProtectionComp = self:GetProtectionComponent()
    if uProtectionComp and slua.isValid(uProtectionComp) then
      self.OriginalCheckStuckInterval = uProtectionComp.CheckStuckInterval
      self.OriginalStuckDuration = uProtectionComp.StuckDuration
    end
    if slua.isValid(self.VehicleMovement) and self.VehicleMovement.DriftSetup then
      self.VehicleMovement.DriftSetup.MaxOmega = 360
      printf(bWriteLog and "LuaVehicleBase ReceiveBeginPlay MaxOmega:%f", self.VehicleMovement.DriftSetup.MaxOmega)
    end
    local uSyncComp = self:GetVehicleSync()
    if slua.isValid(uSyncComp) then
      uSyncComp.VehicleHitRewindThreshold.ValidDeltaSeconds = 0.35
    end
  end
  self.DefaultStartLocation = self:K2_GetActorLocation()
  self.DefaultStartRotation = self:K2_GetActorRotation()
  self.Tags:Add("StuckGround")
end
function LuaVehicleBase:AfterBeginPlay()
  if self.Super.AfterBeginPlay then
    self.Super:AfterBeginPlay()
  end
  local uVehicleShootAntiCheat = self.VehicleShootAntiCheat
  if slua.isValid(uVehicleShootAntiCheat) then
    uVehicleShootAntiCheat.BoundBoxExtendMoveTime = 0
  end
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_AFTER_BEGINPLAY, self.Object)
end
function LuaVehicleBase:GetShootVertifyHitBoxScale(VehicleHistotyData, MovementRecordData)
  return FVector(2, 2, 2)
end
function LuaVehicleBase:ServerHandleEnterVehicleResult(bSuccess)
end
function LuaVehicleBase:ClientHandleEnterVehicle(uCharacter, SeatType)
  if not slua.isValid(uCharacter) then
    return
  end
  if SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat and slua.isValid(self:GetVehicleSpringArm()) then
    self:GetVehicleSpringArm().bDoCollisionTest = true
  end
  local ESTEPoseState = import("ESTEPoseState")
  uCharacter.ClientSidePoseState = ESTEPoseState.Stand
  local uCustomSpringArm = uCharacter:GetThirdPersonSpringArm()
  if slua.isValid(uCustomSpringArm) then
    print("LuaVehicleBase:ClientHandleEnterVehicle bDoCollisionTest set to true")
    uCustomSpringArm.bDoCollisionTest = true
  end
  if Game:IsBioVehicle(self.Object) then
    if slua.isValid(self.CapsuleComponent) and not self.CapsuleComponent:ComponentHasTag("QuickSignIgnore") then
      self.CapsuleComponent.ComponentTags:Add("QuickSignIgnore")
    end
    if slua.isValid(self.HeadCapsuleComponent) and not self.HeadCapsuleComponent:ComponentHasTag("QuickSignIgnore") then
      self.HeadCapsuleComponent.ComponentTags:Add("QuickSignIgnore")
    end
  end
end
function LuaVehicleBase:ClientHandleExitVehicle(uCharacter, SeatType)
  if not slua.isValid(uCharacter) then
    return
  end
  local ESTEPoseState = import("ESTEPoseState")
  uCharacter.ClientSidePoseState = ESTEPoseState.Stand
  if Game:IsBioVehicle(self.Object) then
    if slua.isValid(self.CapsuleComponent) and self.CapsuleComponent:ComponentHasTag("QuickSignIgnore") then
      local nRemoveIndex = -1
      for i = 0, self.CapsuleComponent.ComponentTags:Num() - 1 do
        local sTag = self.CapsuleComponent.ComponentTags:Get(i)
        if sTag == "QuickSignIgnore" then
          nRemoveIndex = i
          break
        end
      end
      if 0 <= nRemoveIndex then
        self.CapsuleComponent.ComponentTags:Remove(nRemoveIndex)
      end
    end
    if slua.isValid(self.HeadCapsuleComponent) and self.HeadCapsuleComponent:ComponentHasTag("QuickSignIgnore") then
      local nRemoveIndex = -1
      for i = 0, self.HeadCapsuleComponent.ComponentTags:Num() - 1 do
        local sTag = self.HeadCapsuleComponent.ComponentTags:Get(i)
        if sTag == "QuickSignIgnore" then
          nRemoveIndex = i
          break
        end
      end
      if 0 <= nRemoveIndex then
        self.HeadCapsuleComponent.ComponentTags:Remove(nRemoveIndex)
      end
    end
  end
end
function LuaVehicleBase:ClientHandleChangeVehicleSeat(uCharacter, OldSeatType, NewSeatType)
  if not slua.isValid(uCharacter) then
    return
  end
end
function LuaVehicleBase:OnEndChangeVehicleItemAvatar()
  print(bWriteLog and "LuaVehicleBase:OnEndChangeVehicleItemAvatar")
  self:CheckAvatarDormant()
end
function LuaVehicleBase:CheckAvatarDormant()
  local uAvatarComp = self:GetAvatarComponent()
  if slua.isValid(uAvatarComp) then
    local bNeedTick = uAvatarComp.bNeedUpdateLightMat or uAvatarComp:IsLobbyActor() or uAvatarComp.NeedTickModifyMatParam or uAvatarComp.HasWelComeLight
    print(bWriteLog and "LuaVehicleBase:CheckAvatarDormant uAvatarComp", bNeedTick)
    uAvatarComp:SetComponentTickEnabled(bNeedTick)
  end
  local uAdvanceAvatarComp = self:GetAdvanceAvatarComponent()
  if slua.isValid(uAdvanceAvatarComp) then
    local bNeedTick = uAdvanceAvatarComp.bNeedUpdateLightMat or uAdvanceAvatarComp:IsLobbyActor() or uAdvanceAvatarComp.EntityTickList:Num() > 0
    print(bWriteLog and "LuaVehicleBase:CheckAvatarDormant uAdvanceAvatarComp", bNeedTick)
    uAdvanceAvatarComp:SetComponentTickEnabled(bNeedTick)
  end
end
function LuaVehicleBase:SpawnBoxComponent()
  if not self:HasAuthority() then
    return
  end
  local BoxComponentClass = import("BoxComponent")
  if BoxComponentClass == nil then
    return
  end
  print(bWriteLog and "LuaVehicleBase:StateChanged Destory SpanwBoxComponent")
  local uBoxComponent = Game:AddComponent(BoxComponentClass, self, "DeadVehicleBox")
  if not Game:IsValid(uBoxComponent) then
    return
  end
  local EAttachmentRule = import("EAttachmentRule")
  local ret = uBoxComponent:K2_AttachToComponent(self.Mesh, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, false)
  if not ret then
    return
  end
  local ECC_Trigger = 18
  uBoxComponent:SetBoxExtent(FVector(200, 200, 200), true)
  uBoxComponent:K2_SetRelativeLocation(FVector(0, 0, 90), false, nil, true)
  uBoxComponent:SetCollisionObjectType(ECC_Trigger)
  uBoxComponent.bGenerateOverlapEvents = true
end
function LuaVehicleBase:BPGetQueryIgnoreActors()
  local IgnoreArray = {}
  table.insert(IgnoreArray, self.Object)
  return IgnoreArray
end
function LuaVehicleBase:OpenPhysicForAMoment(nSecond)
  if not self:HasAuthority() then
    return
  end
  if self:IsSimulatePhysics() then
    return
  end
  print(bWriteLog and "LuaVehicleBase:OpenPhysicForAMoment", self.Role)
  self:SetSimulatePhysics(true)
  if self.PhysicTimer ~= nil then
    Game:ClearTimer(self.PhysicTimer)
    self.PhysicTimer = nil
  end
  self.PhysicTimer = Game:SetTimer(nSecond, false, function()
    self:SetSimulatePhysics(false)
    Game:ClearTimer(self.PhysicTimer)
    self.PhysicTimer = nil
  end)
end
function LuaVehicleBase:ReceiveEndPlay(EndPlayReason)
  if self.PhysicTimer ~= nil then
    Game:ClearTimer(self.PhysicTimer)
    self.PhysicTimer = nil
  end
  self.bIsDeformed = false
  self.VehicleRegisterSkills = {}
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_ENDPLAY, self.Object)
  self:ClearVehicleFeatures()
  if self.LuaBroadcast then
    self:LuaBroadcast("VehicleEndPlayEvent")
  end
  self.Super:ReceiveEndPlay(EndPlayReason)
  LuaVehicleBase.__super.ReceiveEndPlay(self, EndPlayReason)
end
function LuaVehicleBase:GetMoveComponent()
  if not slua.isValid(self.MoveComponent) then
    local ComponentClass = import("STExtraVehicleMovementComponent4W")
    self.MoveComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.MoveComponent
end
function LuaVehicleBase:GetCommonComponent()
  if not slua.isValid(self.CommonComponent) then
    local ComponentClass = import("VehicleCommonComponent")
    self.CommonComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.CommonComponent
end
function LuaVehicleBase:GetSeatComponent()
  if not slua.isValid(self.SeatComponent) and slua.isValid(self.Object) then
    local ComponentClass = import("VehicleSeatComponent")
    self.SeatComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.SeatComponent
end
function LuaVehicleBase:GetAvatarComponent()
  if not slua.isValid(self.AvatarComponent) then
    local ComponentClass = import("VehicleAvatarComponent")
    self.AvatarComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.AvatarComponent
end
function LuaVehicleBase:GetAdvanceAvatarComponent()
  if not slua.isValid(self.AdvanceAvatarComponent) then
    local ComponentClass = import("VehicleAdvanceAvatarComponent")
    self.AdvanceAvatarComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.AdvanceAvatarComponent
end
function LuaVehicleBase:GetProtectionComponent()
  if not slua.isValid(self.ProtectionComponent) then
    local ComponentClass = import("WheeledVehicleProtectionComponent")
    self.ProtectionComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.ProtectionComponent
end
function LuaVehicleBase:GetMotorbikeComponent()
  if not slua.isValid(self.MotorbikeComponent) then
    local MotorbikeClass = import("VehicleMotorbikeComponent")
    self.MotorbikeComponent = self:GetComponentByClass(MotorbikeClass)
  end
  return self.MotorbikeComponent
end
function LuaVehicleBase:GetMusicComponent()
  if not slua.isValid(self.MusicComponent) then
    local MusicClass = import("VehicleMusicComponent")
    self.MusicComponent = self:GetComponentByClass(MusicClass)
  end
  return self.MusicComponent
end
function LuaVehicleBase:GetBuffComponent()
  if not slua.isValid(self.BuffSystemComp) then
    local BuffSystemClass = import("STBuffSystemComponent")
    self.BuffSystemComp = self:GetComponentByClass(BuffSystemClass)
  end
  return self.BuffSystemComp
end
function LuaVehicleBase:GetAccelerationComponent()
  if not slua.isValid(self.AccelerateComponent) then
    local AccelerateClass = import("VehicleAccelerateComponent")
    self.AccelerateComponent = self:GetComponentByClass(AccelerateClass)
  end
  return self.AccelerateComponent
end
function LuaVehicleBase:GetPickupComponent()
  if not slua.isValid(self.VehiclePickableComponent) then
    local PickableComponentClass = import("VehiclePickableComponent")
    self.VehiclePickableComponent = self:GetComponentByClass(PickableComponentClass)
  end
  return self.VehiclePickableComponent
end
function LuaVehicleBase:GetLicenseComponent()
  if not slua.isValid(self.VehicleLicenseComponent) then
    local ComponentClass = import("VehicleLicenseNumberComponent")
    self.VehicleLicenseComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.VehicleLicenseComponent
end
function LuaVehicleBase:GetVehicleCabrioletComponent()
  if not slua.isValid(self.VehicleCabrioletComponent) then
    local ComponentClass = import("VehicleCabrioletComponent")
    self.VehicleCabrioletComponent = self:GetComponentByClass(ComponentClass)
  end
  return self.VehicleCabrioletComponent
end
function LuaVehicleBase:AddDynamicComponentLoadCompletedCallbacks(handleFunc, ...)
  local common = require("client.slua_ui_framework.common")
  local args = table.pack(...)
  local handle = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  if self:DynamicComponentAllLoadCompleted() then
    handle()
  else
    if self.DynamicComponentLoadCompletedCallbacks == nil then
      self.DynamicComponentLoadCompletedCallbacks = {}
    end
    table.insert(self.DynamicComponentLoadCompletedCallbacks, handle)
  end
end
function LuaVehicleBase:ForceExitCharacters(bForceNetUpdate)
  if self:HasAuthority() then
    local VehicleSeat = self:GetSeatComponent()
    if not slua.isValid(VehicleSeat) then
      return
    end
    for _, Character in VehicleSeat.SeatOccupiers:Pairs() do
      if slua.isValid(Character) then
        local Controller = Character:GetPlayerControllerSafety()
        if slua.isValid(Controller) and slua.isValid(Controller.VehicleUserComp) then
          Controller.VehicleUserComp:ForceExitVehicle(true, "Owner exited", true)
        end
        if not slua.isValid(Controller) then
          local AIController = Character:GetControllerSafety()
          if slua.isValid(AIController) then
            local VehicleUser = AIController:GetVehicleUserComp()
            if slua.isValid(VehicleUser) then
              VehicleUser:ForceExitVehicle(true, "Owner exited", true)
            end
          end
        end
        if bForceNetUpdate == true then
          Character:ForceNetUpdate()
          local uWeaponManager = Character:GetWeaponManager()
          local WeaponList = slua.isValid(uWeaponManager) and uWeaponManager:GetAllInventoryWeaponList(false)
          if WeaponList then
            for _, uWeapon in pairs(WeaponList) do
              if slua.isValid(uWeapon) then
                uWeapon:ForceNetUpdate()
              end
            end
          end
        end
      end
    end
  end
end
function LuaVehicleBase:HandleDriverChanged(LastDriver, NewDriver)
  print(bWriteLog and "LuaVehicleBase:HandleDriverChanged")
  self:ResetCandidateAvatarID(NewDriver)
  if CGameMode then
    local UniqueID = CGame:GetActorUniqueID(self)
    local Entry = CGameMode:GetVehicleReportEntry(UniqueID)
    if not Entry.Drived then
      Entry.VehicleShapeType = self.VehicleShapeType
      Entry.Drived = true
      CGameMode:SetVehicleReportEntry(UniqueID, Entry)
      print(bWriteLog and "LuaVehicleBase:HandleDriverChanged, Vehicle TLog")
    end
  end
end
function LuaVehicleBase:HandleSeatOccupiersChanged()
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_SEAT_OCCUPIERS_CHANGED, self.Object)
  local VehicleSeat = self:GetSeatComponent()
  if slua.isValid(VehicleSeat) then
    local LastOccupiers = {}
    if self.LastOccupiers and next(self.LastOccupiers) then
      local Occupiers = {}
      for _, Character in pairs(VehicleSeat.SeatOccupiers) do
        if slua.isValid(Character) then
          Occupiers[Character] = true
        end
      end
      local EDetachmentRule = import("EDetachmentRule")
      for Index, Character in pairs(self.LastOccupiers) do
        if slua.isValid(Character) and not Occupiers[Character] then
          LastOccupiers[Index] = Character
        end
      end
    end
    if Client and not Client.IsEnableDSGrayPublishFlag(2199023255552) and not Client.IsEditor() and slua.isValid(self.Object) and not self.IsUnmannedVehicle and slua.isValid(VehicleSeat) then
      local OneVector = FVector(1, 1, 1)
      local ZeroRotator = FRotator(0, 0, 0)
      for _, Character in pairs(LastOccupiers) do
        if slua.isValid(Character) and slua.isValid(Character:GetCurrentVehicle()) then
          local DoExec = false
          local Controller = Character:GetPlayerControllerSafety()
          if slua.isValid(Controller) and Controller.GetVehicleUserComp and not Controller:IsSpectator() then
            local VehicleUser = Controller:GetVehicleUserComp()
            DoExec = slua.isValid(VehicleUser) and not slua.isValid(VehicleUser:GetVehicle())
          end
          if DoExec then
            local AttachSocket = Character.AttachmentReplication.AttachSocket
            Character:SetAttachment(nil, Character.AttachmentReplication.AttachComponent, FVector.ZeroVector, ZeroRotator, OneVector, AttachSocket)
            Character:OnRep_AttachmentReplication()
            print(bWriteLog and "LuaVehicleBase:HandleSeatOccupiersChanged, redetach OnRep_AttachmentReplication: ", self.Object, Character)
          end
        end
      end
      local RelativeLocation = FVector(0, 0, 0)
      for Index, Character in pairs(VehicleSeat.SeatOccupiers) do
        if slua.isValid(Character) and not slua.isValid(Character:GetCurrentVehicle()) then
          local DoExec = false
          local Controller = Character:GetPlayerControllerSafety()
          if slua.isValid(Controller) and Controller.GetVehicleUserComp and not Controller:IsSpectator() then
            local VehicleUser = Controller:GetVehicleUserComp()
            DoExec = slua.isValid(VehicleUser) and slua.isValid(VehicleUser:GetVehicle())
          end
          local AttachComponent = self:GetMesh()
          if DoExec and slua.isValid(AttachComponent) and 0 <= Index and Index < VehicleSeat.Seats:Num() then
            local SeatConfig = VehicleSeat.Seats:Get(Index)
            RelativeLocation.Z = Character:GetSimpleCollisionHalfHeightInStandPose()
            Character:SetAttachment(self, AttachComponent, RelativeLocation, ZeroRotator, OneVector, SeatConfig.EnterVehicleSocket)
            Character:OnRep_AttachmentReplication()
            print(bWriteLog and "LuaVehicleBase:HandleSeatOccupiersChanged, reattach OnRep_AttachmentReplication: ", self.Object, Character)
          end
        end
      end
    end
    print(bWriteLog and "LuaVehicleBase:HandleSeatOccupiersChanged, Reattach all characters")
    if slua.isValid(VehicleSeat) then
      for idx, Character in pairs(VehicleSeat.SeatOccupiers) do
        if slua.isValid(Character) then
          print(bWriteLog and "LuaVehicleBase:HandleSeatOccupiersChanged, ClientChangeSeatCameraData")
          VehicleSeat:ClientChangeSeatCameraData(Character, -1, idx)
        end
      end
    end
  end
  self.LastOccupiers = {}
  for Index, Character in pairs(VehicleSeat.SeatOccupiers) do
    if slua.isValid(Character) then
      self.LastOccupiers[Index] = Character
    end
  end
end
function LuaVehicleBase:ResetCandidateAvatarID(NewDriver)
  print(bWriteLog and "ResetCandidateAvatarID", NewDriver)
  if self:HasAuthority() and not slua.isValid(NewDriver) then
    self.CandidateAvatarID = 0
  end
end
function LuaVehicleBase:IsSeatAvailable(SeatIndex, uPlayer)
  local VehicleSeat = self:GetSeatComponent()
  if slua.isValid(VehicleSeat) then
    return VehicleSeat:IsSeatIndexAvailable(SeatIndex)
  end
  return false
end
function LuaVehicleBase:HandleServerAvatarEquiped()
  print(bWriteLog and "LuaVehicleBase:HandleServerAvatarEquiped")
  local VehicleAvatar = self:GetAvatarComponent()
  if not slua.isValid(VehicleAvatar) then
    print(bWriteLog and "LuaVehicleBase:HandleServerAvatarEquiped, VehicleAvatarComponent is invaild")
    return
  end
  self:ModifyEnterSocket(VehicleAvatar:GetCurrentAvatarID())
end
function LuaVehicleBase:HandleVehicleLoadedFPPMesh()
  print(bWriteLog and "LuaVehicleBase:VehicleLoadedFPPMesh")
  self:HandleClientAvatarEquiped()
  if slua.isValid(self.BP_VehicleDIYComp) then
    local EAvatarActionType = import("EAvatarActionType")
    self.BP_VehicleDIYComp:RemoveActionByType(1, EAvatarActionType.ApplyDIYPattern, true)
  end
end
function LuaVehicleBase:HandleClientAvatarEquiped()
  print(bWriteLog and "LuaVehicleBase:HandleClientAvatarEquiped")
  local VehicleAvatar = self:GetAvatarComponent()
  if slua.isValid(VehicleAvatar) then
    local CurrentAvatarID = VehicleAvatar:GetCurrentAvatarID()
    if CurrentAvatarID == self.ClientUsedAvatarID then
      print(bWriteLog and "LuaVehicleBase:HandleClientAvatarEquiped, CurrentAvatarID == self.ClientUsedAvatarID", CurrentAvatarID)
      self:DeactiveEffect("Exhaust")
      self:ReActivateExhaustParticle()
      return
    end
    self.ClientUsedAvatarID = CurrentAvatarID
    EventSystem.postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_AVATAR_EQUIPED, self.Object, CurrentAvatarID)
    local DebugAvatarNotExist = KismetSystemLibrary.GetConsoleVariableIntValue("avatar.debug.notexist")
    local AvatarHandlePath = VehicleAvatar:GetItemAvatarHandlePath(CurrentAvatarID)
    local nTargetAvatarID = CurrentAvatarID
    if DebugAvatarNotExist ~= 0 or not VehicleAvatar:IsAssetsAlreadyAvailable(CurrentAvatarID) then
      nTargetAvatarID = VehicleAvatar:GetDefaultAvatarID()
    end
    print(bWriteLog and "LuaVehicleBase:HandleClientAvatarEquiped, ClientTargetAvatarID, CurrentAvatarID, AvatarHandlePath", nTargetAvatarID, CurrentAvatarID, AvatarHandlePath)
    self:UpdateParticle(nTargetAvatarID)
    self:ChangeAssetByAvatar(nTargetAvatarID)
    self:CheckAndSetStartUpEffect(nTargetAvatarID)
    self:ModifyEnterSocket(nTargetAvatarID)
  end
end
function LuaVehicleBase:HandleClientVehicleSwitchEffectEnd()
  print(bWriteLog and "LuaVehicleBase:HandleClientVehicleSwitchEffectEnd")
  self:InitVehicleDIYComponent(self.ClientUsedAvatarID)
  local uLisenceComp = self:GetLicenseComponent()
  if slua.isValid(uLisenceComp) then
    log(bWriteLog and "LuaVehicleBase:HandleClientAvatarEquiped BP_VehicleLicenseComponentBase")
    uLisenceComp:OnVehicleMeshAvatarEquiped(self.ClientUsedAvatarID)
  end
end
function LuaVehicleBase:DeactiveSkinSpecialEffect()
  self:DeactiveEffect("Exhaust")
  self:DeactiveEffect("SpoilersTail")
  self:DeactiveEffect("SpoilersTailInLift")
  self:DeactiveEffect("StartUpFX")
end
function LuaVehicleBase:HandleAdvanceAvatarEquipped()
  if self:HasAuthority() then
    self:HandleServerAdvanceAvatarEquipped()
  else
    self:HandleClientAdvanceAvatarEquipped()
  end
end
function LuaVehicleBase:CheckAndSetStartUpEffect(nAvatarID)
  return false
end
function LuaVehicleBase:HandleServerAdvanceAvatarEquipped()
  print(bWriteLog and "LuaVehicleBase:HandleServerAdvanceAvatarEquipped")
  local AdvanceAvatar = self:GetAdvanceAvatarComponent()
  if not slua.isValid(AdvanceAvatar) then
    print(bWriteLog and "LuaVehicleBase:HandleServerAdvanceAvatarEquipped, AdvanceAvatarComponent is invalid")
    return
  end
  self:ModifyEnterSocket(AdvanceAvatar.VehicleSkinID)
end
function LuaVehicleBase:HandleClientAdvanceAvatarEquipped()
  local AdvanceAvatar = self:GetAdvanceAvatarComponent()
  if not slua.isValid(AdvanceAvatar) then
    print(bWriteLog and "LuaVehicleBase:HandleClientAdvanceAvatarEquipped; AdvanceAvatar is not valid")
    return
  end
  local CurrentAvatarID = AdvanceAvatar.VehicleSkinID
  if CurrentAvatarID == self.ClientUsedAvatarID then
    print(bWriteLog and "LuaVehicleBase:HandleClientAdvanceAvatarEquipped; CurrentAvatarID == self.ClientUsedAvatarID", CurrentAvatarID)
    self:DeactiveEffect("Exhaust")
    self:ReActivateExhaustParticle()
    return
  end
  self.ClientUsedAvatarID = CurrentAvatarID
  print(bWriteLog and "LuaVehicleBase:HandleClientAdvanceAvatarEquipped", CurrentAvatarID)
  local DefaultAvatarID = self:GetAvatarComponent():GetDefaultAvatarID()
  self:UpdateParticle(CurrentAvatarID)
  self:ChangeAssetByAvatar(DefaultAvatarID)
  self:CheckAndSetStartUpEffect(self.ClientUsedAvatarID)
  self:ModifyEnterSocket(CurrentAvatarID)
  local avatarComponent = self:GetAvatarComponent()
  if slua.isValid(avatarComponent) then
    avatarComponent:RefreshLastEquipedAvatarId(0)
  end
end
function LuaVehicleBase:HandleCabrioletStateChanged(newCabrioletState)
  if not newCabrioletState then
    log(bWriteLog and "LuaVehicleBase:HandleCabrioletStateChanged invalid newCabrioletState")
    return
  end
  log(bWriteLog and "LuaVehicleBase:HandleCabrioletStateChanged newCabrioletState:" .. tostring(newCabrioletState))
  if Client then
    log(bWriteLog and "LuaVehicleBase:HandleCabrioletStateChanged Client")
    return
  end
  local VehicleSeat = self:GetSeatComponent()
  if not slua.isValid(VehicleSeat) then
    log(bWriteLog and "LuaVehicleBase:HandleCabrioletStateChanged invalid VehicleSeat")
    return
  end
  for _, Character in pairs(VehicleSeat.SeatOccupiers) do
    if slua.isValid(Character) then
      local uCharacterAvatarComp = Character:getAvatarComponent2()
      if slua.isValid(uCharacterAvatarComp) and uCharacterAvatarComp.UpdateCutPlaneState then
        uCharacterAvatarComp:UpdateCutPlaneState()
      end
    end
  end
end
function LuaVehicleBase:GetVehicleCabrioletState()
  local VehicleCabrioletComponent = self:GetVehicleCabrioletComponent()
  if not slua.isValid(VehicleCabrioletComponent) then
    return nil
  end
  return VehicleCabrioletComponent:GetCabrioletState()
end
function LuaVehicleBase:ChangeAssetByAvatar(nAvatarID)
  print(bWriteLog and "LuaVehicleBase:ChangeAssetByAvatar, nAvatarID = ", nAvatarID)
  local VehicleAvatar = self:GetAvatarComponent()
  if not slua.isValid(VehicleAvatar) then
    print(bWriteLog and "LuaVehicleBase:ChangeAssetByAvatar failed")
    return
  end
  local AvatarHandle = VehicleAvatar:GetItemAvatarHandle(nAvatarID)
  if not slua.isValid(AvatarHandle) then
    print(bWriteLog and "LuaVehicleBase:ChangeAssetByAvatar: failed")
    return
  end
  self:ChangeCharacterAnim(AvatarHandle)
  self:ChangeCharacterAnimNew(nAvatarID)
  print(bWriteLog and "LuaVehicleBase:ChangeAssetByAvatar: success; AvatarHandle =", AvatarHandle)
end
function LuaVehicleBase:UpdateParticle(nAvatarID)
  print(bWriteLog and "LuaVehicleBase:UpdateParticle nAvatarID" .. tostring(nAvatarID))
  self:DeactiveSkinSpecialEffect()
  self:ChangeAssetBy(nAvatarID)
  self:ReActivateExhaustParticle()
end
function LuaVehicleBase:ChangeParticles(AvatarID)
  local AvatarComp = self:GetAvatarComponent()
  if not slua.isValid(AvatarComp) then
    print(bWriteLog and "LuaVehicleBase:ChangeParticles AvatarComp is not Valid failed")
    return
  end
  self.RuntimeParticleSoftWrapperMap = self.ParticleSoftWrapperMap
  local ItemAvatarHandle = AvatarComp:GetItemAvatarHandle(AvatarID)
  if slua.isValid(ItemAvatarHandle) and ItemAvatarHandle.ParticleSfx:Num() > 0 then
    for TypeName, ParticleArray in pairs(ItemAvatarHandle.ParticleSfx) do
      self:ChangeOrAddParticleWrapperArray(TypeName, ParticleArray)
    end
  end
  if self.ReplaceParticleMap:Get(AvatarID) and 0 < self.ReplaceParticleMap:Get(AvatarID).ParticleSfx:Num() then
    for TypeName, ParticleArray in pairs(self.ReplaceParticleMap:Get(AvatarID).ParticleSfx) do
      self:ChangeParticleWrapperArray(TypeName, ParticleArray)
    end
  end
  if self.AdditionalParticleMap:Get(AvatarID) and 0 < self.AdditionalParticleMap:Get(AvatarID).ParticleSfx:Num() then
    for TypeName, ParticleArray in pairs(self.AdditionalParticleMap:Get(AvatarID).ParticleSfx) do
      self:AppendParticleWrapperArray(TypeName, ParticleArray)
    end
  end
  self:AutoLoadEffect()
  self:BroadCastVehicleHealthStateChanged()
end
function LuaVehicleBase:ModifyEnterSocket(nAvatarID)
  print(bWriteLog and "LuaVehicleBase:ModifyEnterSocket", nAvatarID)
  local VehicleSeat = self:GetSeatComponent()
  if not slua.isValid(VehicleSeat) then
    print(bWriteLog and "LuaVehicleBase:ModifyEnterSocket failed, this vehicle does not have UVehicleSeatComponent")
    return
  end
  local TableEntry = GamePlayTools.GetTableData("VehicleAttrBPTable", nAvatarID)
  if TableEntry and TableEntry.EnterVehicleSocket_an:Num() > 0 then
    VehicleSeat:ChangeCharacterSeatSocket(TableEntry.EnterVehicleSocket_an)
    print(bWriteLog and "LuaVehicleBase:ModifyEnterSocket success")
  end
end
function LuaVehicleBase:ChangeCharacterAnim(InAvatarHandle)
  if not slua.isValid(InAvatarHandle) or InAvatarHandle.VehCharAnimData:Num() == 0 then
    local VehicleAvatar = self:GetAvatarComponent()
    if slua.isValid(VehicleAvatar) and slua.isValid(VehicleAvatar.DefaultItemAvatarHandle) and 0 < VehicleAvatar.DefaultItemAvatarHandle.VehCharAnimData:Num() then
      InAvatarHandle = VehicleAvatar.DefaultItemAvatarHandle
      print(bWriteLog and "LuaVehicleBase:ChangeCharacterAnim, use default character anim")
    else
      return
    end
  end
  print(bWriteLog and "LuaVehicleBase:ChangeCharacterAnim, replace character anim")
  local ComponentClass = import("UAEChaVehAnimListComponent")
  for _, AnimData in InAvatarHandle.VehCharAnimData:Pairs() do
    local Components = self:GetComponentsByTag(ComponentClass, AnimData.AnimCompTag)
    if Components:Num() > 0 then
      local Component = Components:Get(0)
      if slua.isValid(Component) then
        Component:ChangeAnimData(slua.IndexReference(AnimData, "VehCharAnimDataList"))
      end
    end
  end
end
function LuaVehicleBase:ChangeCharacterAnimNew(InAvatarID)
  if InAvatarID == nil then
    print(bWriteLog and "LuaVehicleBase:ChangeCharacterAnimNew, AvatarID is nil")
    return
  end
  local NewAnimListCompClass = import("VehicleCharacterAnimListComponentBase")
  local NewAnimListComp = self:GetComponentByClass(NewAnimListCompClass)
  if slua.isValid(NewAnimListComp) then
    print(bWriteLog and "LuaVehicleBase:ChangeCharacterAnimNew, New AvatarID is: " .. InAvatarID)
    NewAnimListComp:ChangeAnimData(InAvatarID)
  end
end
function LuaVehicleBase:LuaHandleHealthStateChanged(NewHealthState)
end
function LuaVehicleBase:LuaHandleVehicleHealthDestroy()
  self:ClearDecals()
  if CGameMode then
    local UniqueID = CGame:GetActorUniqueID(self)
    local Entry = CGameMode:GetVehicleReportEntry(UniqueID)
    Entry.VehicleShapeType = self.VehicleShapeType
    Entry.IsDestroyed = true
    Entry.LastAttackedTime = GameplayStatics.GetTimeSeconds(self)
    CGameMode:SetVehicleReportEntry(UniqueID, Entry)
    print(bWriteLog and "LuaVehicleBase:LuaHandleHealthStateChanged, Vehicle TLog")
  end
  local EGameModeSubType = import("EGameModeSubType")
  if slua.isValid(CGameState) and CGameState.GameModeSubType == EGameModeSubType.EPlanDGameMode then
    local uFloatingVehicleClass = import("STExtraFloatingVehicle")
    print(bWriteLog and "LuaVehicleBase:LuaHandleHealthStateChanged", uFloatingVehicleClass)
    if not Game:IsClassOf(self.Object, uFloatingVehicleClass) then
      self:SpawnBoxComponent()
      print(bWriteLog and "LuaVehicleBase:LuaHandleHealthStateChanged SpawnBoxDone")
    end
  end
end
function LuaVehicleBase:OnRep_CandidateAvatar()
  print(bWriteLog and "LuaVehicleBase:OnRep_CandidateAvatar")
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_AVATAR_CHANGE_MSG, self.Object, self.CandidateAvatarID ~= 0)
end
function LuaVehicleBase:HandleSeatChanged(Character, LastSeatType, LastSeatIndex, NewSeatType, NewSeatIndex)
  self:HandleOnSeatChanged(Character, LastSeatType, LastSeatIndex, NewSeatType, NewSeatIndex)
  if Character and slua.isValid(Character) and Character.getAvatarComponent2 and slua.isValid(Character:getAvatarComponent2()) then
    Character:getAvatarComponent2():DoAllAvatarReplaceOnVehicle()
  end
end
function LuaVehicleBase:HandleSeatAttached(InCharacter, InSeatType, InSeatIndex)
  if slua.isValid(InCharacter) then
    if InCharacter.SwitchPoseState then
      local ESTEPoseState = import("ESTEPoseState")
      InCharacter:SwitchPoseState(ESTEPoseState.Stand, false, false, true, false)
    end
    if InCharacter.PlayerKey and slua.isValid(InCharacter.STCharacterMovement) and InCharacter.STCharacterMovement.ResolvePenetrationData then
      self.AttachedCharacterLocation[InCharacter.PlayerKey] = InCharacter.STCharacterMovement.ResolvePenetrationData.ValidLocation
      self.AttachedCharacterBlock[InCharacter.PlayerKey] = self:IsCharacterBlockFromValidLoc(InCharacter, InCharacter.STCharacterMovement.ResolvePenetrationData.ValidLocation)
    end
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_PLAYER_CHANGED, self.Object, InCharacter, true)
  end
end
function LuaVehicleBase:IsCharacterBlockFromValidLoc(uCharacter, ValidLoc)
  if not slua.isValid(uCharacter) or ValidLoc == nil then
    return false
  end
  local Actor_C = import("/Script/Engine.Actor")
  local HitResult = import("/Script/Engine.HitResult")()
  local uIgnoreActorArray = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  uIgnoreActorArray:Add(uCharacter)
  uIgnoreActorArray:Add(self.Object)
  local uVehicleSeat = self:GetSeatComponent()
  if slua.isValid(uVehicleSeat) then
    for Index, OtherCharacter in pairs(uVehicleSeat.SeatOccupiers) do
      if slua.isValid(OtherCharacter) and OtherCharacter ~= uCharacter then
        uIgnoreActorArray:Add(OtherCharacter)
      end
    end
  end
  local Success = false
  Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceBlock(self.Object, ValidLoc, uCharacter:K2_GetActorLocation(), HitResult, uIgnoreActorArray, true)
  if HitResult.bBlockingHit then
    return true
  end
  return false
end
function LuaVehicleBase:HandleOnSeatDetachedBefore(uCharacter, nSeatType, nSeatIdx)
  if slua.isValid(uCharacter) then
    self.DetachBeforeCharacterLocation = uCharacter:K2_GetActorLocation()
  end
end
function LuaVehicleBase:HandleSeatDetached(uCharacter, nSeatType, nSeatIdx)
  if slua.isValid(uCharacter) then
    EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_PLAYER_CHANGED, self.Object, uCharacter, false)
    local uAttachVehicleLocation = self.AttachedCharacterLocation[uCharacter.PlayerKey]
    if not uAttachVehicleLocation then
      return
    end
    if self.DetachBeforeCharacterLocation == nil or self.AttachedCharacterBlock[uCharacter.PlayerKey] == nil then
      return
    end
    local bOverlapOrPassWall = self.AttachedCharacterBlock[uCharacter.PlayerKey] == true and FVector.Dist(self.DetachBeforeCharacterLocation, uAttachVehicleLocation) < 800
    local DettachValidLocation = self.DetachBeforeCharacterLocation
    if bOverlapOrPassWall then
      DettachValidLocation = uAttachVehicleLocation
      print(bWriteLog and "HandleSeatDetached Attach passwall PlayerKey:", uCharacter.PlayerKey)
    end
    if not bOverlapOrPassWall then
      bOverlapOrPassWall = self:IsCharacterBlockFromValidLoc(uCharacter, self.DetachBeforeCharacterLocation)
      if bOverlapOrPassWall then
        print(bWriteLog and "HandleSeatDetached dettach passwall PlayerKey:", uCharacter.PlayerKey)
      end
    end
    if bOverlapOrPassWall then
      local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
      local ResolveParams = FResolvePenetrationParams()
      slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(uCharacter)
      slua.IndexReference(ResolveParams, "OverlapIgnoreActors"):Add(uCharacter)
      slua.IndexReference(ResolveParams, "PassWallIgnoreActors"):Add(self.Object)
      local bFindLocOK = false
      local uNoPassWallLocation = FVector(0, 0, 0)
      bFindLocOK, uNoPassWallLocation = uCharacter:FindActorLocationSafetyWithParams(uNoPassWallLocation, DettachValidLocation, ResolveParams)
      if bFindLocOK then
        uCharacter:SetActorLocationSafety(uNoPassWallLocation)
        uCharacter:ClientSetLeaveVehicleLocation(uNoPassWallLocation)
        print(bWriteLog and "HandleSeatDetached bFindLocOK true PlayerKey:", uCharacter.PlayerKey)
      else
        print(bWriteLog and "HandleSeatDetached bFindLocOK false PlayerKey:", uCharacter.PlayerKey)
      end
    else
      print(bWriteLog and "HandleSeatDetached uOverlapComps.Num==0 PlayerKey:", uCharacter.PlayerKey)
    end
  end
end
function LuaVehicleBase:HandleHPPreChange(InDamage, InHP)
  local VehicleCommon = self:GetCommonComponent()
  if CGameMode and slua.isValid(VehicleCommon) then
    local MaxHP = VehicleCommon:GetVehicleHPMax()
    if InHP == MaxHP then
      local UniqueID = CGame:GetActorUniqueID(self)
      local Entry = CGameMode:GetVehicleReportEntry(UniqueID)
      Entry.VehicleShapeType = self.VehicleShapeType
      Entry.FirstAttackedTime = GameplayStatics.GetTimeSeconds(self)
      CGameMode:SetVehicleReportEntry(UniqueID, Entry)
      print(bWriteLog and "LuaVehicleBase:HandleHPPreChange, Vehicle TLog")
    end
  end
end
function LuaVehicleBase:HandleForbidEnterVehicle(_, _, Player, MsgName, Forbid)
  if MsgName == "HideInteractiveUI" then
    self:ShowVehicleEnterButton(true)
    local Hide = tonumber(Forbid)
    if Hide == 1 then
      self:ShowVehicleEnterButton(false)
    end
  end
end
function LuaVehicleBase:ServerResetToTransform(FLocation, FRotation, bClientSetTo)
  if FLocation == nil then
    FLocation = self.DefaultStartLocation
  end
  if FRotation == nil then
    FRotation = self.DefaultStartRotation
  end
  self:SetSimulatePhysics(false)
  if slua.isValid(self:GetProtectionComponent()) then
    self.ProtectionComponent:SetTickEnabled(false)
    self:AddTimer(0.1, function()
      self.ProtectionComponent:ResetValidTransform()
      self.ProtectionComponent:SetTickEnabled(true)
    end)
  end
  if bClientSetTo == true then
    self:ClientResetAdnSetToTransform(FLocation, FRotation)
  else
    self:ClientResetToTransform()
  end
  self:ServerResetToPosition(FLocation, FRotation, true)
  if slua.isValid(self:GetMotorbikeComponent()) then
    self:UnregisterComponentTick(self:GetMotorbikeComponent())
    self:UnregisterComponentWeakTick(self:GetMotorbikeComponent())
    self:AddTimer(0.1, function()
      local fRotator = self:GetMesh():K2_GetComponentRotation()
      fRotator.Roll = 0.0
      self:GetMesh():K2_SetWorldRotation(fRotator, false, nil, true)
      self:RegisterComponentTick(self:GetMotorbikeComponent())
      self:RegisterComponentWeakTick(self:GetMotorbikeComponent())
    end)
  end
  self:AddTimer(0.5, function()
    self:SetSimulatePhysics(true)
  end)
  print(bWriteLog and "LuaVehicleBase:ServerResetToTransform, Location = " .. FLocation:ToString() .. ", Rotation = " .. FRotation:ToString())
end
function LuaVehicleBase:ServerTeleportVehicleMaintainSpeed(FLocation, FRotation, InVelocity, bServerSetVelocity)
  self:ServerResetToPosition(FLocation, FRotation, false)
  if bServerSetVelocity == true then
    local uVehicleMesh = self:GetMesh()
    if slua.isValid(uVehicleMesh) then
      uVehicleMesh:SetPhysicsLinearVelocity(InVelocity, false, "None")
    end
  end
  local uVehicleVelocity = InVelocity
  if slua.isValid(self:GetProtectionComponent()) then
    self:GetProtectionComponent():ResetValidTransform()
  end
  self:ClientTeleportVehicleMaintainSpeed(FLocation, FRotation, uVehicleVelocity)
end
LuaVehicleBase.ClientRPC.ClientTeleportVehicleMaintainSpeed = {
  Reliable = true,
  Params = {
    import("/Script/CoreUObject.Vector"),
    import("/Script/CoreUObject.Rotator"),
    import("/Script/CoreUObject.Vector")
  }
}
function LuaVehicleBase:ClientTeleportVehicleMaintainSpeed(InLoc, InRot, InVelocity)
  local uVehicleMesh = self:GetMesh()
  if slua.isValid(uVehicleMesh) then
    self:SetPhysicsLinearVelocity(InVelocity, false, "None")
  end
  self:K2_SetActorLocationAndRotation(InLoc, InRot, false, nil, true)
  if slua.isValid(self:GetProtectionComponent()) then
    self:GetProtectionComponent():ResetValidTransform()
  end
end
LuaVehicleBase.ClientRPC.ClientResetToTransform = {
  Reliable = true,
  Params = {}
}
function LuaVehicleBase:ClientResetToTransform()
  self:_ClientResetToTransform()
end
LuaVehicleBase.ClientRPC.ClientResetAdnSetToTransform = {
  Reliable = true,
  Params = {
    import("/Script/CoreUObject.Vector"),
    import("/Script/CoreUObject.Rotator")
  }
}
function LuaVehicleBase:ClientResetAdnSetToTransform(InLoc, InRot)
  print(bWriteLog and "LuaVehicleBase:ClientResetAdnSetToTransform")
  self:_ClientResetToTransform(InLoc, InRot)
end
function LuaVehicleBase:_ClientResetToTransform(InLoc, InRot)
  self:StopVehicle()
  if slua.isValid(self:GetProtectionComponent()) then
    self.ProtectionComponent:SetTickEnabled(false)
    self:AddTimer(0.1, function()
      self.ProtectionComponent:ResetValidTransform()
      self.ProtectionComponent:SetTickEnabled(true)
    end)
  end
  if InLoc ~= nil and InRot ~= nil then
    self:K2_SetActorLocationAndRotation(InLoc, InRot, false, nil, true)
  end
  if slua.isValid(self:GetMotorbikeComponent()) then
    self:UnregisterComponentTick(self:GetMotorbikeComponent())
    self:UnregisterComponentWeakTick(self:GetMotorbikeComponent())
    self:SetSimulatePhysics(false)
    self.bUseSyncAtClient = false
    self:AddTimer(0.1, function()
      local fRotator = self:GetMesh():K2_GetComponentRotation()
      fRotator.Roll = 0.0
      self:GetMesh():K2_SetWorldRotation(fRotator, false, nil, true)
      self:RegisterComponentTick(self:GetMotorbikeComponent())
      self:RegisterComponentWeakTick(self:GetMotorbikeComponent())
      self:SetSimulatePhysics(true)
      self.bUseSyncAtClient = true
    end)
  end
  self:ResetVehicleSpringArm()
  print(bWriteLog and "LuaVehicleBase:_ClientResetToTransform, Location = " .. self:K2_GetActorLocation():ToString() .. ", Rotation = " .. self:K2_GetActorRotation():ToString())
end
function LuaVehicleBase:StopVehicle()
  local moveComp = self:GetMoveComponent()
  if moveComp then
    moveComp:StopMovementImmediately()
    if moveComp.SetVehicleToRestState then
      moveComp:SetVehicleToRestState()
    end
  end
  if self.STReplicatedState then
    self.STReplicatedState.SteeringInput = 0
    self.STReplicatedState.ThrottleInput = 0
    self.STReplicatedState.BrakeInput = 127
    self.STReplicatedState.HandBrakeInput = 127
    self.STReplicatedState.CurrentGear = 0
  end
  if slua.isValid(self:GetMesh()) then
    self:SetAllPhysicsLinearVelocity(FVector.ZeroVector, false)
    self:GetMesh():SetAllPhysicsAngularVelocity(FVector.ZeroVector, false)
  end
  self:SetPhysActive(false, -1)
end
function LuaVehicleBase:ResetVehicleSpringArm()
  local vehicleSprintArm = self:GetVehicleSpringArm()
  if not slua.isValid(vehicleSprintArm) then
    return
  end
  vehicleSprintArm.bUsePawnControlRotation = true
  local fRotator = FRotator(0, 0, 0)
  vehicleSprintArm.SmartCamRotationExtra = fRotator
  vehicleSprintArm:SetFreeCameraAutoReturn(true)
  vehicleSprintArm:ForceUpdateDesiredArmLocation(false, false, true, 0.01)
end
function LuaVehicleBase:ServerApplyVehicleImpulse(ImpulseVector)
  print(bWriteLog and "LuaVehicleBase:ServerApplyVehicleImpulse, ImpulseVector = " .. ImpulseVector:ToString())
  self:ApplyVehicleImpulse(ImpulseVector, true)
  self:ClientApplyVehicleImpulse(ImpulseVector)
end
LuaVehicleBase.ClientRPC.ClientApplyVehicleImpulse = {
  Reliable = true,
  Params = {
    import("/Script/CoreUObject.Vector")
  }
}
function LuaVehicleBase:ClientApplyVehicleImpulse(ImpulseVector)
  print(bWriteLog and "LuaVehicleBase:ClientApplyVehicleImpulse, ImpulseVector = " .. ImpulseVector:ToString())
  self:ApplyVehicleImpulse(ImpulseVector, true)
end
function LuaVehicleBase:RecordVehicleTransfrom()
  self.DefaultStartRotation = self:K2_GetActorRotation()
  self.DefaultStartLocation = self:K2_GetActorLocation()
end
function LuaVehicleBase:OnPreAttachBy(InActor, AttachComponent, AttachSocket, RelativeLocation, RelativeRotation, RelativeScale3D)
  if not slua.isValid(InActor) or not slua.isValid(AttachComponent) then
    return
  end
  local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  if GameLuaAPI.IsClassOf(InActor, ASTExtraBaseCharacter) then
    self:OnPreAttachByCharacter(InActor, AttachComponent, AttachSocket, RelativeLocation, RelativeRotation, RelativeScale3D)
  end
end
function LuaVehicleBase:OnPreAttachByCharacter(InCharacter, AttachComponent, AttachSocket, RelativeLocation, RelativeRotation, RelativeScale3D)
  if not slua.isValid(InCharacter) or not slua.isValid(AttachComponent) then
    return
  end
  local VehicleSeat = self:GetSeatComponent()
  if not slua.isValid(VehicleSeat) then
    return
  end
  local SeatIndex = VehicleSeat:GetChracterSeatIndex(InCharacter)
  if SeatIndex < 0 or SeatIndex >= VehicleSeat.Seats:Num() then
    return
  end
  local SeatConfig = VehicleSeat.Seats:Get(SeatIndex)
  if AttachSocket == SeatConfig.VehicleWeaponSeatSocket then
    print(bWriteLog and "LuaVehicleBase:OnPreAttachByCharacter, attach to VehicleWeaponSeatSocket", SeatConfig.VehicleWeaponSeatSocket)
    return
  end
  if AttachSocket ~= SeatConfig.EnterVehicleSocket then
    InCharacter:SetAttachment(self, AttachComponent, RelativeLocation, RelativeRotation, RelativeScale3D, SeatConfig.EnterVehicleSocket)
    print(bWriteLog and "LuaVehicleBase:OnPreAttachByCharacter, ", self.Object, InCharacter, SeatConfig.EnterVehicleSocket)
  end
end
function LuaVehicleBase:IsCurrentVehicleUseBetterAvatar()
  if not slua.isValid(self:GetAvatarComponent()) then
    print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvatar return false, AvatarComp is Invalid")
    return false
  end
  local nDefaultID = self:GetAvatarComponent():GetDefaultAvatarID()
  print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvatar", self.ClientUsedAvatarID, nDefaultID)
  if self.ClientUsedAvatarID and self.ClientUsedAvatarID ~= nDefaultID then
    if CDataTable.GetTableData("BetterVehicleEffect", self.ClientUsedAvatarID) then
      print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvatar true AvatarID is", self.ClientUsedAvatarID)
      return true
    else
      print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvatar, table doesnot have this ID", self.ClientUsedAvatarID)
    end
  end
  print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvatar return false")
  return false
end
function LuaVehicleBase:IsCurrentVehicleUseBetterAvataMusic(VehicleSkinId)
  local uAvatarComp = self:GetAvatarComponent()
  if not slua.isValid(uAvatarComp) then
    print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvataMusic return false, AvatarComp is Invalid")
    return false
  end
  local nDefaultID = uAvatarComp:GetDefaultAvatarID()
  if not VehicleSkinId or VehicleSkinId == nDefaultID then
    print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvataMusic, VehicleSkinId default id")
    return false
  end
  local BetterVehicleEffect = CDataTable.GetTableData("BetterVehicleEffect", VehicleSkinId)
  if not BetterVehicleEffect or BetterVehicleEffect.VehicleMusic ~= 1 then
    print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvataMusic, BetterVehicleEffect is nil or VehicleMusic ~= 1")
    return false
  end
  print(bWriteLog and "LuaVehicleBase:IsCurrentVehicleUseBetterAvataMusic return true")
  return true
end
function LuaVehicleBase:SetVehicleMusicPlayState(bEnabled)
  local MusicComp = self:GetMusicComponent()
  if slua.isValid(MusicComp) then
    MusicComp:SetDefaultMusicPlayState(bEnabled)
  end
end
function LuaVehicleBase:BPCanCharacterEnter(uCharacter, SeatType)
  if slua.isValid(uCharacter) and uCharacter.CanEnterVehicle then
    print(bWriteLog and "LuaVehicleBase:BPCanCharacterEnter CanEnterVehicle")
    if not uCharacter:CanEnterVehicle(self) then
      print(bWriteLog and "LuaVehicleBase:BPCanCharacterEnter CanEnterVehicle false")
      return false
    end
  end
  return true
end
function LuaVehicleBase:IsVaildToStopSkillWhenEnterVehicle(uCharacter)
  if slua.isValid(uCharacter) and uCharacter:IsCastingSkillIDFix(1014711) then
    return false
  end
  return true
end
function LuaVehicleBase:SetVehicleCanExit(bInCanVehicleExit)
  self.bCanVehicleExit = bInCanVehicleExit
end
function LuaVehicleBase:ShouldShowVehicleEnterUIToCharacher(uCharacter)
  if slua.isValid(uCharacter) then
    if uCharacter.CanEnterVehicle and not uCharacter:CanEnterVehicle(self) then
      print(bWriteLog and "LuaVehicleBase:ShouldShowVehicleEnterUIToCharacher CanEnterVehicle false")
      return false
    end
    if slua.isValid(uCharacter) then
      local VehicleSeat = self:GetVehicleSeats()
      if slua.isValid(VehicleSeat) then
        return VehicleSeat:IsSeatAvailableTeam(uCharacter)
      end
    end
    return true
  end
  return false
end
function LuaVehicleBase:GetDiedBoxAvatarID()
  local Driver = self:GetDriver()
  if not slua.isValid(Driver) then
    print(bWriteLog and "[VehicleDiedBox] LuaVehicleBase GetDiedBoxAvatarID Driver is not Valid ")
    return -1
  end
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local VehicleAvatarID = self:GetAvatarID()
  local DiedBoxID = VehiclePlateLicenseUtil.GetDiedBoxID(Driver.PlayerUID, VehicleAvatarID)
  print(bWriteLog and "[VehicleDiedBox] LuaVehicleBase GetDiedBoxAvatarID DiedBoxID" .. tostring(DiedBoxID) .. "PlayerUID" .. tostring(Driver.PlayerUID) .. " VehicleAvatarID" .. tostring(VehicleAvatarID))
  return DiedBoxID
end
function LuaVehicleBase:GetDirverOrOwner()
  local Driver = self:GetDriver()
  if slua.isValid(Driver) then
    return Driver
  end
  if self.Ownership then
    local OwnerPlayerKey = self.Ownership.BelongToPlayerKey
    local uPawn = Game:GetPlayerByPlayerKey(OwnerPlayerKey)
    if slua.isValid(uPawn) then
      return uPawn
    end
  end
  return
end
function LuaVehicleBase:ReActivateExhaustParticle()
  if self.IsBoosting and not self:IsBoosting() then
    return
  end
  local NeedReActivateExhaust = true
  if self.IsUsingFPPModel and self:IsUsingFPPModel() then
    print(bWriteLog and "LuaVehicleBase:HandleClientAvatarEquiped FPP Loaded")
    NeedReActivateExhaust = false
  end
  if NeedReActivateExhaust and self.ActiveEffectAsync then
    self:ActiveEffectAsync("Exhaust")
    if slua.isValid(self.Mesh) then
      local AnimInstance = self.Mesh:GetAnimInstance()
      if AnimInstance and AnimInstance.InLift then
        self:ActiveEffectAsync("SpoilersTailInLift")
      end
    end
  end
end
function LuaVehicleBase:CanActiveEffect(EffectName)
  if EffectName == "Exhaust" then
    local VehicleAvatar = self:GetAvatarComponent()
    if Game:IsValid(VehicleAvatar) and VehicleAvatar.VehicleAvatarHandle and VehicleAvatar.VehicleAvatarHandle.bNeedHideExhaustWhenScope then
      local GameplayData = require("GameLua.GameCore.Data.GameplayData")
      local Character = GameplayData.GetPlayerCharacter()
      if slua.isValid(Character) and Character.IsLocalActuallyScopeIn then
        print(bWriteLog and "LuaVehicleBase:CanActiveEffect Exhaust false")
        return false
      end
    end
  end
  if EffectName == "SpoilersTailInLift" then
    if self.IsBoosting and not self:IsBoosting() then
      return false
    end
    if slua.isValid(self.Mesh) then
      local AnimInstance = self.Mesh:GetAnimInstance()
      if not AnimInstance or not AnimInstance.InLift then
        return false
      end
    end
  end
  return true
end
function LuaVehicleBase:OnBoostingChanged()
  self.Super:OnBoostingChanged()
  if self.IsBoosting and self:IsBoosting() then
    self:ActiveEffectAsync("SpoilersTailInLift")
  else
    self:DeactiveEffect("SpoilersTailInLift")
  end
end
function LuaVehicleBase:InitOptimizeLeaveVehicle()
  if Client then
    return
  end
  print(bWriteLog and "LuaVehicleBase:InitOptimizeLeaveVehicle", self.Object)
  local uSeatComponent = self:GetSeatComponent()
  if not slua.isValid(uSeatComponent) or not uSeatComponent.LeaveVehicleConfig then
    return
  end
  local LeaveVehicleConfig = require("GameLua.GameCore.Module.Vehicle.Config.LeaveVehicleConfig")
  local tLeaveConfig = LeaveVehicleConfig.GetConfig(self.VehicleShapeType)
  local sLogStr = ""
  if tLeaveConfig then
    for Key, Value in pairs(tLeaveConfig) do
      local LeaveVehicleConfig = slua.IndexReference(uSeatComponent, "LeaveVehicleConfig")
      if LeaveVehicleConfig[Key] ~= nil then
        local PreValue = LeaveVehicleConfig[Key]
        LeaveVehicleConfig[Key] = Value
        sLogStr = sLogStr .. Key .. " from " .. tostring(PreValue) .. " to " .. tostring(Value) .. " | "
      end
    end
    print(bWriteLog and string.format("[Vehicle] %s InitOptimizeLeaveVehicle. %s", KismetSystemLibrary.GetObjectName(self.Object), sLogStr))
  end
end
function LuaVehicleBase:RegisterVehicleSkill(SkillID, SkillFeatrue)
  self.VehicleRegisterSkills[SkillID] = SkillFeatrue
end
function LuaVehicleBase:GetCurVehicleSkillBySkillID(SkillID)
  return self.VehicleRegisterSkills[SkillID]
end
function LuaVehicleBase:GetVehicleAccessorySlotConfig(nAvatarID, slotName)
  if not nAvatarID or not slotName then
    log(bWriteLog and "[VehicleAccessory] LuaVehicleBase:GetVehicleAccessorySlotConfig, param is nil")
    return nil
  end
  log(bWriteLog and "[VehicleAccessory] LuaVehicleBase:GetVehicleAccessorySlotConfig, nAvatarID = " .. tostring(nAvatarID) .. " slotType = " .. tostring(slotName))
  local VehicleAvatar = self:GetAvatarComponent()
  if not slua.isValid(VehicleAvatar) or not VehicleAvatar.GetItemAvatarHandle then
    log(bWriteLog and "[VehicleAccessory] LuaVehicleBase:GetVehicleAccessorySlotConfig VehicleAvatar is nil")
    return nil
  end
  local AvatarHandle = VehicleAvatar:GetItemAvatarHandle(nAvatarID)
  if not slua.isValid(AvatarHandle) then
    log(bWriteLog and "[VehicleAccessory] LuaVehicleBase:GetVehicleAccessorySlotConfig AvatarHandle is nil")
    return nil
  end
  if not AvatarHandle.VehicleAccessorySlotCfgs or AvatarHandle.VehicleAccessorySlotCfgs:Num() == 0 then
    log(bWriteLog and "[VehicleAccessory] LuaVehicleBase:GetVehicleAccessorySlotConfig VehicleAccessorySlotCfgs is nil")
    return nil
  end
  for i = 0, AvatarHandle.VehicleAccessorySlotCfgs:Num() - 1 do
    local VehicleAccessorySlotConfig = AvatarHandle.VehicleAccessorySlotCfgs:Get(i)
    if VehicleAccessorySlotConfig and VehicleAccessorySlotConfig.AccessorySlotName == slotName then
      log(bWriteLog and "[VehicleAccessory] LuaVehicleBase:GetVehicleAccessorySlotConfig VehicleAccessorySlotCfgs Get")
      return VehicleAccessorySlotConfig
    end
  end
  log(bWriteLog and "[VehicleAccessory] LuaVehicleBase:GetVehicleAccessorySlotConfig VehicleAccessorySlotCfgs nil")
  return nil
end
function LuaVehicleBase:SetHPBarShowName(sName)
  self.VehicleHPBarName = sName
end
function LuaVehicleBase:GetHPBarShowName()
  if self.VehicleHPBarName and self.VehicleHPBarName ~= "" then
    return self.VehicleHPBarName
  end
  local AvatarID = self.AvatarDefaultCfg.TypeSpecificID
  local uItemData = CDataTable.GetTableData("Item", AvatarID)
  self.VehicleHPBarName = uItemData and uItemData.ItemName or ""
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  local HPBarConfig = ClientGameMain.GetUIOtherSetting("HPBarConfig")
  if HPBarConfig and HPBarConfig.VehicleItemIDNameConfig and HPBarConfig.VehicleItemIDNameConfig[AvatarID] then
    self.VehicleHPBarName = LocUtil.GetLocalizeResStr(HPBarConfig.VehicleItemIDNameConfig[AvatarID]) or self.VehicleHPBarName
  end
  return self.VehicleHPBarName
end
function LuaVehicleBase:InitVehicleDIYComponent(VehicleID)
  if not VehicleID then
    log(bWriteLog and "LuaVehicleBase:InitVehicleDIYComponent not VehicleID")
    return
  end
  local Cfg = CDataTable.GetTableData("VehicleDIYCfg", tonumber(VehicleID))
  if not Cfg then
    if slua.isValid(self.BP_VehicleDIYComp) then
      self.BP_VehicleDIYComp:K2_DestroyComponent(self.BP_VehicleDIYComp)
      self.BP_VehicleDIYComp = nil
    end
    return
  end
  if not slua.isValid(self.BP_VehicleDIYComp) then
    local BP_VehicleDIYComp_C = import("/Game/BluePrints/AvatarDIY/BP_VehicleDIYComp.BP_VehicleDIYComp_C")
    self.BP_VehicleDIYComp = Game:AddComponent(BP_VehicleDIYComp_C, self, "BP_VehicleDIYComp")
  end
  if slua.isValid(self.BP_VehicleDIYComp) then
    self.BP_VehicleDIYComp:UpdateCarOwnerInGame()
  end
end
function LuaVehicleBase:StartRecordDriveData(uCharacter)
  if Client then
    return
  end
  if not slua.isValid(uCharacter) then
    return
  end
  self.RecordCharacter = uCharacter
  local uKismetMathLibrary = import("KismetMathLibrary")
  if not self.UseTimer then
    self.DrivingDistance = 0
    self.LastLocation = self:K2_GetActorLocation()
    self.UseTimer = self:AddGameTimer(0.1, true, function()
      if slua.isValid(self.Object) and self.LastLocation then
        local Offset = self:K2_GetActorLocation() - self.LastLocation
        self.DrivingDistance = self.DrivingDistance + uKismetMathLibrary.VSize(Offset) / 100
        self.LastLocation = self:K2_GetActorLocation()
      end
    end)
  end
end
function LuaVehicleBase:EndRecordDriveData(uCharacter)
  if Client then
    return
  end
  if not slua.isValid(uCharacter) then
    return
  end
  if not self.DriverDistanceTLogID then
    return
  end
  if self.RecordCharacter ~= uCharacter then
    return
  end
  self.RecordCharacter = nil
  self:RemoveGameTimer(self.UseTimer)
  self.UseTimer = nil
  local uPlayerState = uCharacter:GetPlayerStateSafety()
  if slua.isValid(uPlayerState) then
    local Distance = math.floor(self.DrivingDistance)
    uPlayerState:AddGeneralCount(self.DriverDistanceTLogID, Distance, false)
  end
end
function LuaVehicleBase:RecordVehicleTlog(uCharacter)
  if Client then
    return
  end
  if not slua.isValid(uCharacter) then
    return
  end
  if not self.EnterCountTlogID then
    return
  end
  local uPlayerState = uCharacter:GetPlayerStateSafety()
  if slua.isValid(uPlayerState) then
    uPlayerState:AddGeneralCount(self.EnterCountTlogID, 1, false)
  end
end
function LuaVehicleBase:CanBeCatched(PickParams)
  local bRes = true
  if self.UltraHandBeCatchedFeature then
    bRes = self.UltraHandBeCatchedFeature:CanBeCatched(PickParams)
  end
  return bRes
end
function LuaVehicleBase:SetVehicleProtectionStuckInternal(InCheckStuckInterval, InStuckDuration, ResetSeconds)
  if self.VehicleProtectionInternalTimer ~= nil and self.VehicleProtectionInternalTimer > 0 then
    self:RemoveGameTimer(self.VehicleProtectionInternalTimer)
  end
  local uProtectionComp = self:GetProtectionComponent()
  if uProtectionComp and slua.isValid(uProtectionComp) then
    uProtectionComp.CheckStuckInterval = InCheckStuckInterval
    uProtectionComp.StuckDuration = InStuckDuration
    self.VehicleProtectionInternalTimer = self:AddGameTimer(ResetSeconds, false, function()
      if uProtectionComp and slua.isValid(uProtectionComp) then
        uProtectionComp.CheckStuckInterval = self.OriginalCheckStuckInterval
        uProtectionComp.StuckDuration = self.OriginalStuckDuration
      end
      self.VehicleProtectionInternalTimer = nil
    end)
  end
end
function LuaVehicleBase:RefreshVehiclePassengersParticle()
  print(bWriteLog and "LuaVehicleBase:RefreshVehiclePassengersParticle")
  local VehicleSeat = self:GetSeatComponent()
  if not slua.isValid(VehicleSeat) then
    log(bWriteLog and "LuaVehicleBase:RefreshVehiclePassengersParticle invalid VehicleSeat")
    return
  end
  for _, Character in pairs(VehicleSeat.SeatOccupiers) do
    if slua.isValid(Character) then
      log(bWriteLog and "LuaVehicleBase:RefreshVehiclePassengersParticle Character PlayerKey:" .. tostring(Character.PlayerKey))
      local uCharacterAvatarComp = Character:getAvatarComponent2()
      if slua.isValid(uCharacterAvatarComp) and uCharacterAvatarComp.RefreshAvatarParticlesShow then
        uCharacterAvatarComp:RefreshAvatarParticlesShow(Character.IsLocalActuallyScopeIn)
      end
    end
  end
end
function LuaVehicleBase:HandlePlayerAttachedToVehcicle(Character)
  if Client and slua.isValid(Character) and Character.CheckAttachedOrDetachedVehicle then
    Character:CheckAttachedOrDetachedVehicle(true)
  end
end
function LuaVehicleBase:OnRep_BlockForwardInput()
  print(bWriteLog and "LuaVehicleBase:OnRep_BlockForwardInput")
  if self.Super.OnRep_BlockForwardInput then
    self.Super:OnRep_BlockForwardInput()
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local playerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(playerCharacter) and playerCharacter.GetCurrentVehicle and slua.isValid(playerCharacter:GetCurrentVehicle()) and playerCharacter:GetCurrentVehicle() == self.Object then
    if Game:IsClassOf(self.Object, import("BioVehicleBase")) or Game:IsClassOf(self.Object, import("VehicleBike")) or Game:IsClassOf(self.Object, import("VehicleMotorGlider")) then
      return
    end
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_VEHICLE_CANNT_MOVE_SHOW, self.bBlockForwardInput)
  end
end
function LuaVehicleBase:OnMeshPhysicsCreateExt()
  self:LuaBroadcast(self.OnMeshPhysicsCreateDelegate)
end
function LuaVehicleBase:FellOutOfWorldExt(InData)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local IsPlayingPlayback = slua.isValid(GameInstance) and GameInstance:IsPlayingAnyPlayback()
  local IsNotFinishedState = slua.isValid(CGameState) and CGameState:GetGameModeState() ~= "FinishedState"
  if Client and Client.IsDevelopment() and not IsPlayingPlayback and IsNotFinishedState then
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local ActorName = KismetSystemLibrary.GetDisplayName(self.Object)
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.ShowMsgBox(1, "Vehicle falls out of world" .. CGame:GetCurDateTimeString(), "Please get the log and contact <walkercbwu> for confirmation:\n" .. ActorName .. InData)
  end
end
function LuaVehicleBase:OutsideWorldBoundsExt(InData)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local IsPlayingPlayback = slua.isValid(GameInstance) and GameInstance:IsPlayingAnyPlayback()
  local IsNotFinishedState = slua.isValid(CGameState) and CGameState:GetGameModeState() ~= "FinishedState"
  if Client and Client.IsDevelopment() and not IsPlayingPlayback and IsNotFinishedState then
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local ActorName = KismetSystemLibrary.GetDisplayName(self.Object)
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.ShowMsgBox(1, "<Vehicle outside world bounds>" .. CGame:GetCurDateTimeString(), "Please get the log and contact <walkercbwu> for confirmation:\n" .. ActorName .. InData)
  end
end
function LuaVehicleBase:NeedCreateShootDriverComp()
  local VehicleShootDriverConfig = require("GameLua.GameCore.Module.Vehicle.Config.VehicleShootDriverConfig")
  if VehicleShootDriverConfig and VehicleShootDriverConfig.GetCfg(self.Object) then
    return true
  end
  return false
end
function LuaVehicleBase:IsSocialIslandVehicle()
  return false
end
function LuaVehicleBase:LuaShouldLeaveFitCloseToGround()
  local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
  if self.VehicleShapeType == ESTExtraVehicleShapeType.VST_UH60 or self.VehicleShapeType == ESTExtraVehicleShapeType.VST_HeavyUH60 or self.VehicleShapeType == ESTExtraVehicleShapeType.VST_Motorglider or self.VehicleShapeType == ESTExtraVehicleShapeType.VST_WingMan or self.VehicleShapeType == ESTExtraVehicleShapeType.VST_Fighter or self.VehicleShapeType == ESTExtraVehicleShapeType.VST_Aircraft then
    return false
  end
  return true
end
function LuaVehicleBase:IsBornIslandVehicle()
  return self.bIsBornIslandVehicle
end
local class = require("class")
local CVehicleUIOperator = require("GameLua.GameCore.Module.Vehicle.ALuaVehicleUIOperator")
local CLuaVehicleBase = class(CVehicleUIOperator, nil, LuaVehicleBase)
return require("combine_class").DeclareFeature(CLuaVehicleBase, {
  {
    VehicleHealthEffectFeature = "GameLua.GameCore.Module.Vehicle.Features.Effect.VehicleHealthEffectFeature"
  },
  {
    SpringArmComponentTickProtectionFeature = "GameLua.GameCore.Module.Vehicle.Features.Protection.SpringArmComponentTickProtectionFeature"
  },
  {
    UltraHandBeCatchedFeature = "GameLua.Mod.Library.GamePlay.Skill.Feature.UltraHandBeCatchedFeature"
  },
  {
    VehicleUsersSkillTokenFeature = "GameLua.Mod.Library.GamePlay.Vehicle.VehicleFeatures.VehicleUsersSkillTokenFeature"
  }
}, "VehicleBase")