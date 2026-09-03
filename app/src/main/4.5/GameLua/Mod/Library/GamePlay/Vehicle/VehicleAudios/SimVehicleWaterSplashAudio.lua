local WaterSplashAudio = {}
function WaterSplashAudio:ctor(_, InAudioType, InVehicle, InAudioFeature)
  WaterSplashAudio.__super.ctor(self, _, InAudioType, InVehicle, InAudioFeature)
end
function WaterSplashAudio:RegisterEvents()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  local VehicleMesh = self.OwnerVehicle:GetMesh()
  if not slua.isValid(VehicleMesh) then
    return
  end
  self:AddControlEvent(self.OwnerVehicle, "OnSimulatePhysicsChangeDelegate", self.OnSimulatePhysicsChange, self)
  self:AddControlEvent(VehicleMesh, "OnComponentWake", self.OnVehiclePhysicsWakeUp, self)
  self:AddControlEvent(VehicleMesh, "OnComponentSleep", self.OnVehiclePhysicsSleep, self)
end
function WaterSplashAudio:UnregisterEvents()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  local VehicleMesh = self.OwnerVehicle:GetMesh()
  if not slua.isValid(VehicleMesh) then
    return
  end
  self:RemoveControlEvent(self.OwnerVehicle, "OnSimulatePhysicsChangeDelegate")
  self:RemoveControlEvent(VehicleMesh, "OnComponentWake")
  self:RemoveControlEvent(VehicleMesh, "OnComponentSleep")
end
function WaterSplashAudio:OnSimulatePhysicsChange(IsSimulatingPhysics)
  print(bWriteLog and "WaterSplashAudio:OnSimulatePhysicsChange", self.OwnerVehicle)
  self:ToggleActive()
  self:PlayOrStop()
end
function WaterSplashAudio:OnVehiclePhysicsWakeUp()
  print(bWriteLog and "WaterSplashAudio:OnVehiclePhysicsWakeUp", self.OwnerVehicle)
  self:ToggleActive()
  self:PlayOrStop()
end
function WaterSplashAudio:OnVehiclePhysicsSleep()
  print(bWriteLog and "WaterSplashAudio:OnVehiclePhysicsSleep", self.OwnerVehicle)
  self:ToggleActive()
  self:PlayOrStop()
end
function WaterSplashAudio:ShouldActivate()
  if WaterSplashAudio.__super.ShouldActivate(self) then
    return slua.isValid(self.OwnerVehicle) and self.OwnerVehicle:IsSimulatePhysics() and not self.OwnerVehicle:GetIsPhysSleep()
  end
  return false
end
function WaterSplashAudio:CanPlay()
  if WaterSplashAudio.__super.CanPlay(self) and slua.isValid(self.OwnerVehicle) and self.OwnerVehicle:IsSimulatePhysics() and not self.OwnerVehicle:GetIsPhysSleep() then
    local FloatingMovement = self.OwnerVehicle:GetFloatingMovement()
    return slua.isValid(FloatingMovement) and FloatingMovement:IsActive()
  end
  return false
end
function WaterSplashAudio:Update()
  if not slua.isValid(self.OwnerVehicle) or not slua.isValid(self.AkComponent) then
    return
  end
  self:PlayOrStop()
end
local class = require("class")
local CAudioBase = require("GameLua.Mod.Library.GamePlay.Vehicle.VehicleAudios.VehicleAudioBase")
return class(CAudioBase, nil, WaterSplashAudio)