local TrackDustEffect = {}
local EPhysicalSurface = import("EPhysicalSurface")
local AIUtilsLibrary = import("AIUtilsLibrary")
function TrackDustEffect:ctor(_, InEffectType, InVehicle, InEffectFeature)
  TrackDustEffect.__super.ctor(self, _, InEffectType, InVehicle, InEffectFeature)
  self.EffectMap = {}
  self.ForwardSocketNames = {}
  self.BackwardSocketNames = {}
  self.EffectState = {}
  self.ActiveEffects = {}
end
function TrackDustEffect:RegisterEvents()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  self:AddControlEvent(self.OwnerVehicle, "OnSimulatePhysicsChangeDelegate", self.OnSimulatePhysicsChange, self)
  local VehicleMesh = self.OwnerVehicle:GetMesh()
  if slua.isValid(VehicleMesh) then
    self:AddControlEvent(VehicleMesh, "OnComponentWake", self.OnVehiclePhysicsWakeUp, self)
    self:AddControlEvent(VehicleMesh, "OnComponentSleep", self.OnVehiclePhysicsSleep, self)
  end
  local BuoyancyForceComp = self.OwnerVehicle:GetBuoyancyForce()
  if slua.isValid(BuoyancyForceComp) then
    self:AddControlEvent(BuoyancyForceComp, "OnEnterWater", self.OnEnterWater, self)
  end
end
function TrackDustEffect:UnregisterEvents()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  self:RemoveControlEvent(self.OwnerVehicle, "OnSimulatePhysicsChangeDelegate")
  local VehicleMesh = self.OwnerVehicle:GetMesh()
  if slua.isValid(VehicleMesh) then
    self:RemoveControlEvent(VehicleMesh, "OnComponentWake")
    self:RemoveControlEvent(VehicleMesh, "OnComponentSleep")
  end
  local BuoyancyForceComp = self.OwnerVehicle:GetBuoyancyForce()
  if slua.isValid(BuoyancyForceComp) then
    self:RemoveControlEvent(BuoyancyForceComp, "OnEnterWater")
  end
end
function TrackDustEffect:OnSimulatePhysicsChange(IsSimulatingPhysics)
  print(bWriteLog and "TrackDustEffect:OnSimulatePhysicsChange", self.OwnerVehicle)
  self:ToggleActive()
end
function TrackDustEffect:OnVehiclePhysicsWakeUp()
  print(bWriteLog and "TrackDustEffect:OnVehiclePhysicsWakeUp", self.OwnerVehicle)
  self:ToggleActive()
end
function TrackDustEffect:OnVehiclePhysicsSleep()
  print(bWriteLog and "TrackDustEffect:OnVehiclePhysicsSleep", self.OwnerVehicle)
  self:ToggleActive()
end
function TrackDustEffect:OnEnterWater()
  print(bWriteLog and "TrackDustEffect:OnEnterWater", self.OwnerVehicle)
  self:ToggleActive()
end
function TrackDustEffect:GetAssets()
  local Assets = {}
  for _, Path in pairs(self.EffectMap) do
    self:CheckAndAddAssetPath(Assets, Path)
  end
  return Assets
end
function TrackDustEffect:Stop()
  for _, EffectData in pairs(self.ActiveEffects) do
    local SurfaceType = EffectData.SurfaceType
    local Effect = EffectData.Effect
    if slua.isValid(Effect) then
      Effect:Deactivate()
      local Effects = self.EffectState[SurfaceType] or {}
      table.insert(Effects, Effect)
      self.EffectState[SurfaceType] = Effects
    end
  end
  self.ActiveEffects = {}
end
function TrackDustEffect:ShouldActivate()
  if TrackDustEffect.__super.ShouldActivate(self) then
    return slua.isValid(self.OwnerVehicle) and self.OwnerVehicle:IsSimulatePhysics() and not self.OwnerVehicle:GetIsPhysSleep() and not self.OwnerVehicle:IsEntirelyUnderWater()
  end
  return false
end
function TrackDustEffect:Update()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  local VehicleMovement = self.OwnerVehicle:GetVehicleMovement()
  if not slua.isValid(VehicleMovement) then
    return
  end
  local ForwardSpeed = self.OwnerVehicle:GetForwardSpeed()
  if math.abs(ForwardSpeed) * 0.01 < self.MinSpeed then
    for _, EffectData in pairs(self.ActiveEffects) do
      local SurfaceType = EffectData.SurfaceType
      local Effect = EffectData.Effect
      if slua.isValid(Effect) then
        Effect:Deactivate()
        local Effects = self.EffectState[SurfaceType] or {}
        table.insert(Effects, Effect)
        self.EffectState[SurfaceType] = Effects
      end
    end
    self.ActiveEffects = {}
    return
  end
  for _, EffectData in pairs(self.ActiveEffects) do
    local Effects = self.EffectState[EffectData.SurfaceType] or {}
    table.insert(Effects, EffectData.Effect)
    self.EffectState[EffectData.SurfaceType] = Effects
  end
  local ETrackType = import("ETrackType")
  local EAttachLocation = import("EAttachLocation")
  local SocketNames = 0 < ForwardSpeed and self.ForwardSocketNames or self.BackwardSocketNames
  local SurfaceTypes = self:EvalTrackContactSurfaceTypes()
  local ActiveEffects = {
    {},
    {}
  }
  for i = 1, ETrackType.NumTracks do
    local SurfaceType = SurfaceTypes[i]
    if SurfaceType ~= EPhysicalSurface.SurfaceType_Max then
      local Effects = self.EffectState[SurfaceType] or {}
      if next(Effects) then
        ActiveEffects[i].        ActiveEffects[i].Effect = Effects[1]
        table.remove(Effects, 1)
      else
        local STExtraGameplayStatics = import("STExtraGameplayStatics")
        local EffectTemplate = self:GetObjectByPath(self.EffectMap[SurfaceType])
        if slua.isValid(EffectTemplate) then
          ActiveEffects[i].          ActiveEffects[i].Effect = STExtraGameplayStatics.SpawnEmitterAttached(EffectTemplate, self.OwnerVehicle:GetMesh(), SocketNames[i], FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), EAttachLocation.KeepRelativeOffset, false)
        end
      end
    end
  end
  for _, Effects in pairs(self.EffectState) do
    for _, Effect in pairs(Effects) do
      if slua.isValid(Effect) then
        Effect:Deactivate()
      end
    end
  end
  self.  for Index, EffectData in pairs(ActiveEffects) do
    local Effect = EffectData.Effect
    if slua.isValid(Effect) then
      if Effect:GetAttachSocketName() ~= SocketNames[Index] then
        local EAttachmentRule = import("EAttachmentRule")
        Effect:K2_AttachToComponent(Effect:GetAttachParent(), SocketNames[Index], EAttachmentRule.KeepRelative, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, false)
      end
      if not Effect:IsActive() then
        print(bWriteLog and "TrackDustEffect:Update, activate effect", EffectData.SurfaceType, Effect)
        Effect:Activate(true)
      end
    end
  end
end
function TrackDustEffect:EvalTrackContactSurfaceTypes()
  local SurfaceTypes = {
    EPhysicalSurface.SurfaceType_Max,
    EPhysicalSurface.SurfaceType_Max
  }
  if not slua.isValid(self.OwnerVehicle) then
    return SurfaceTypes
  end
  local MovementLOD = self.OwnerVehicle:GetVehicleMovement()
  if not slua.isValid(MovementLOD) then
    return SurfaceTypes
  end
  local WheelSimStates = slua.Array(UEnums.EPropertyClass.Struct, import("BufferedWheelSimState"))
  local AIUtilsLibrary = import("AIUtilsLibrary")
  local WheelSimStates = MovementLOD:GetWheelSimStates(WheelSimStates)
  local EvalSurfaceType = function(InWheelIndex)
    local WheelSetups = MovementLOD.WheelSetups
    if InWheelIndex >= WheelSetups:Num() then
      return
    end
    local TrackType = InWheelIndex % 2 + 1
    if SurfaceTypes[TrackType] ~= EPhysicalSurface.SurfaceType_Max then
      return
    end
    local WheelSimState = WheelSimStates:Get(InWheelIndex)
    local SurfaceType = AIUtilsLibrary.PhysicalMaterialDetermineSurfaceType(WheelSimState.ContactState.ContactMaterial)
    SurfaceTypes[TrackType] = self.EffectMap[SurfaceType] and SurfaceType or EPhysicalSurface.SurfaceType_Default
  end
  local Speed = self.OwnerVehicle:GetForwardSpeed()
  if 0 < Speed then
    for Index = WheelSimStates:Num() - 1, 0, -1 do
      EvalSurfaceType(Index)
    end
  else
    for Index = 0, WheelSimStates:Num() - 1 do
      EvalSurfaceType(Index)
    end
  end
  return SurfaceTypes
end
local class = require("class")
local CEffectBase = require("GameLua.Mod.Library.GamePlay.Vehicle.VehicleEffects.VehicleEffectBase")
return class(CEffectBase, nil, TrackDustEffect)