local VehicleSlipAudio = {}
local EPhysicalSurface = import("EPhysicalSurface")
function VehicleSlipAudio:ctor(_, InAudioType, InVehicle, InAudioFeature)
  VehicleSlipAudio.__super.ctor(self, _, InAudioType, InVehicle, InAudioFeature)
end
function VehicleSlipAudio:RegisterEvents()
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
function VehicleSlipAudio:UnregisterEvents()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  self:RemoveControlEvent(self.OwnerVehicle, "OnSimulatePhysicsChangeDelegate")
  local VehicleMesh = self.OwnerVehicle:GetMesh()
  if not slua.isValid(VehicleMesh) then
    self:RemoveControlEvent(VehicleMesh, "OnComponentWake")
    self:RemoveControlEvent(VehicleMesh, "OnComponentSleep")
  end
  local BuoyancyForceComp = self.OwnerVehicle:GetBuoyancyForce()
  if slua.isValid(BuoyancyForceComp) then
    self:RemoveControlEvent(BuoyancyForceComp, "OnEnterWater")
  end
end
function VehicleSlipAudio:OnSimulatePhysicsChange(IsSimulatingPhysics)
  print(bWriteLog and "VehicleSlipAudio:OnSimulatePhysicsChange", self.OwnerVehicle)
  self:ToggleActive()
  self:PlayOrStop()
end
function VehicleSlipAudio:OnVehiclePhysicsWakeUp()
  print(bWriteLog and "VehicleSlipAudio:OnVehiclePhysicsWakeUp", self.OwnerVehicle)
  self:ToggleActive()
  self:PlayOrStop()
end
function VehicleSlipAudio:OnVehiclePhysicsSleep()
  print(bWriteLog and "VehicleSlipAudio:OnVehiclePhysicsSleep", self.OwnerVehicle)
  self:ToggleActive()
  self:PlayOrStop()
end
function VehicleSlipAudio:OnEnterWater()
  print(bWriteLog and "VehicleSlipAudio:OnEnterWater", self.OwnerVehicle)
  self:ToggleActive()
end
function VehicleSlipAudio:ShouldActivate()
  if VehicleSlipAudio.__super.ShouldActivate(self) then
    return slua.isValid(self.OwnerVehicle) and self.OwnerVehicle:IsSimulatePhysics() and not self.OwnerVehicle:GetIsPhysSleep() and not self.OwnerVehicle:IsEntirelyUnderWater()
  end
  return false
end
function VehicleSlipAudio:CanPlay()
  if VehicleSlipAudio.__super.CanPlay(self) and slua.isValid(self.OwnerVehicle) and self.OwnerVehicle:IsSimulatePhysics() and not self.OwnerVehicle:GetIsPhysSleep() then
    local ForwardSpeed = self.OwnerVehicle:GetForwardSpeed()
    if self.OwnerVehicle.bIsEngineStarted and not self.OwnerVehicle:IsInMidAir() then
      return ForwardSpeed * self.OwnerVehicle.InputState.CurrentGear < 0 or 0 > ForwardSpeed * self.OwnerVehicle:GetMoveForwardRate()
    end
  end
  return false
end
function VehicleSlipAudio:Update()
  if not slua.isValid(self.OwnerVehicle) or not slua.isValid(self.AkComponent) then
    return
  end
  self:PlayOrStop()
end
local class = require("class")
local CAudioBase = require("GameLua.Mod.Library.GamePlay.Vehicle.VehicleAudios.VehicleAudioBase")
return class(CAudioBase, nil, VehicleSlipAudio)