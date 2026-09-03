local VehicleMotorcycle = {}
function VehicleMotorcycle:ReceiveBeginPlay()
  VehicleMotorcycle.__super.ReceiveBeginPlay(self)
  if slua.isValid(self.PhysicsConstraint) then
    self:K2_DestroyComponent(self.PhysicsConstraint)
  end
  if slua.isValid(self.VehicleBalance) then
    self:K2_DestroyComponent(self.VehicleBalance)
  end
end
function VehicleMotorcycle:HandleDriverChanged(LastDriver, NewDriver)
  VehicleMotorcycle.__super.HandleDriverChanged(self, LastDriver, NewDriver)
  if not slua.isValid(NewDriver) then
    self:SetAirControlF(0)
    self:SetAirControlB(0)
  end
end
function VehicleMotorcycle:HandleSeatOccupiersChanged()
  VehicleMotorcycle.__super.HandleSeatOccupiersChanged(self)
  if not Client then
    return
  end
  local uVehicleSeatComp = self:GetSeatComponent()
  if not slua.isValid(uVehicleSeatComp) then
    log(bWriteLog and "VehicleMotorcycle:HandleSeatOccupiersChanged uVehicleSeatComp is nil")
    return
  end
  local nSeatNum = uVehicleSeatComp:GetInUseSeatNum()
  log(bWriteLog and "VehicleMotorcycle:HandleSeatOccupiersChanged nSeatNum:" .. tostring(nSeatNum))
  if 0 < nSeatNum then
    self:CheckAndSetStartUpEffect(self.ClientUsedAvatarID)
  else
    self:RemoveStartUpFXTimer()
  end
end
function VehicleMotorcycle:CheckIsWheelDestoryed()
  if not self.VehicleCommon or not self.VehicleCommon.WheelsCurrentHP then
    return false
  end
  for _, WheelsHP in pairs(self.VehicleCommon.WheelsCurrentHP) do
    if WheelsHP and WheelsHP <= 0 then
      return true
    end
  end
  return false
end
function VehicleMotorcycle:CheckAndSetStartUpEffect(nAvatarID)
  self:RemoveStartUpFXTimer()
  if not nAvatarID then
    log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect nAvatarID is nil")
    return false
  end
  local RefitInfo = CDataTable.GetTableData("VehicleRefitInfo", nAvatarID)
  if RefitInfo and RefitInfo.vehicle_group_id and RefitInfo.vehicle_group_id <= 3 then
    log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect advance vehicle")
    return false
  end
  log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect nAvatarID:" .. tostring(nAvatarID))
  local VehicleAvatar = self:GetAvatarComponent()
  if not slua.isValid(VehicleAvatar) or not VehicleAvatar.GetItemAvatarHandle then
    log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect VehicleAvatar is nil")
    return false
  end
  if self:CheckIsWheelDestoryed() then
    log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect Wheel Destoryed")
    return
  end
  local AvatarHandle = VehicleAvatar:GetItemAvatarHandle(nAvatarID)
  if not slua.isValid(AvatarHandle) or not AvatarHandle.ParticleSfx then
    log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect AvatarHandle is nil")
    return false
  end
  local StartUpFXArray = AvatarHandle.ParticleSfx:Get("StartUpFX")
  if not StartUpFXArray or not StartUpFXArray.WrapperArray then
    log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect StartUpFXArray Not Valid")
    return false
  end
  local StartUpFXArrayNum = StartUpFXArray.WrapperArray:Num()
  if StartUpFXArrayNum <= 0 then
    log(bWriteLog and "VehicleMotorcycle:CheckHasStartUpEffect StartUpFXArrayNum <= 0")
    return false
  end
  self:SetStartUpFXTimer()
  return true
end
function VehicleMotorcycle:UpdateStartUpEffect()
  if not slua.isValid(self.Object) then
    self:RemoveStartUpFXTimer()
    log(bWriteLog and "VehicleMotorcycle:UpdateStartUpEffect self.Object is invalid")
    return
  end
  if self:CheckIsWheelDestoryed() then
    log(bWriteLog and "VehicleMotorcycle:UpdateStartUpEffect Wheel Destoryed")
    self:RemoveStartUpFXTimer()
    return
  end
  local curSpeed = self:GetForwardSpeed()
  if curSpeed and math.abs(curSpeed) >= 13.9 then
    self:ActiveEffectAsync("StartUpFX")
  else
    self:DeactiveEffect("StartUpFX")
  end
end
function VehicleMotorcycle:SetStartUpFXTimer()
  log(bWriteLog and "VehicleMotorcycle:SetStartUpFXTimer")
  if self.StartUpFXTimer then
    self:RemoveStartUpFXTimer()
    self.StartUpFXTimer = nil
  end
  self.StartUpFXTimer = self:AddTimerLoop(0.1, function()
    self:UpdateStartUpEffect()
  end, TIMER_INFINITE, 0.1)
end
function VehicleMotorcycle:RemoveStartUpFXTimer()
  log(bWriteLog and "VehicleMotorcycle:RemoveStartUpFXTimer")
  self:DeactiveEffect("StartUpFX")
  if self.StartUpFXTimer then
    self:RemoveTimer(self.StartUpFXTimer)
  end
  self.StartUpFXTimer = nil
end
local class = require("class")
local CVehicleBase = require("GameLua.GameCore.Module.Vehicle.ALuaVehicleBase")
return class(CVehicleBase, nil, VehicleMotorcycle)