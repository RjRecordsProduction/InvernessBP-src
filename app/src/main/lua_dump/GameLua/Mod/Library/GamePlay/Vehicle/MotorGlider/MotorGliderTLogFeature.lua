local MotorGliderTLogFeature = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
function MotorGliderTLogFeature:ctor()
  self.TriggerName = "BridgeArch"
  self.TLogID_PassThroughBridgeArch = 1008
  self.TipID_PassThroughBridgeArch = 12044
  self.TLogID_UpsideDownFlying = 1009
  self.TipID_UpsideDownFlying = 12045
end
function MotorGliderTLogFeature:_PostConstruct()
  MotorGliderTLogFeature.__super._PostConstruct(self)
  if slua.isValid(self.Owner.Object) then
    local AircraftMovement = self.Owner:GetAircraftMovementComponent()
    if slua.isValid(AircraftMovement) then
      self:AddControlEvent(AircraftMovement, "OnExitTrigger", self.OnExitTrigger, self)
      self:AddControlEvent(AircraftMovement, "OnUpsideDownFlyingSuccess", self.OnUpsideDownFlyingSuccess, self)
    end
  end
end
function MotorGliderTLogFeature:OnExitTrigger(InTrigger)
  if not slua.isValid(self.Owner.Object) or not UKismetSystemLibrary.IsServer(self.Owner) then
    return
  end
  local VehicleSeat = self.Owner:GetVehicleSeats()
  if not slua.isValid(VehicleSeat) then
    return
  end
  local Driver = VehicleSeat:GetDriver()
  if not slua.isValid(Driver) then
    return
  end
  local AircraftMovement = self.Owner:GetAircraftMovementComponent()
  if not slua.isValid(AircraftMovement) then
    return
  end
  local EAircraftMovementStage = import("EAircraftMovementStage")
  local CurrentStage = AircraftMovement:GetMovementStageType()
  if CurrentStage ~= EAircraftMovementStage.Flying then
    return
  end
  if slua.isValid(InTrigger) and InTrigger:ActorHasTag(self.TriggerName) then
    local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
    DSCommonTLogSubsystem:AddPlayerGeneralCount(Driver.PlayerKey, self.TLogID_PassThroughBridgeArch, 1, true)
    self:PopTips(self.TipID_PassThroughBridgeArch)
    print(bWriteLog and "MotorGliderTLogFeature:OnExitTrigger, pass through bridge arch", self.Owner.Object)
  end
end
function MotorGliderTLogFeature:OnUpsideDownFlyingSuccess()
  if not slua.isValid(self.Owner.Object) or not UKismetSystemLibrary.IsServer(self.Owner) then
    return
  end
  local VehicleSeat = self.Owner:GetVehicleSeats()
  if not slua.isValid(VehicleSeat) then
    return
  end
  local Driver = VehicleSeat:GetDriver()
  if not slua.isValid(Driver) then
    return
  end
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
  DSCommonTLogSubsystem:AddPlayerGeneralCount(Driver.PlayerKey, self.TLogID_UpsideDownFlying, 1, true)
  self:PopTips(self.TipID_UpsideDownFlying)
  print(bWriteLog and "MotorGliderTLogFeature:OnUpsideDownFlyingSuccess", self.Owner.Object)
end
function MotorGliderTLogFeature:PopTips(TipID)
  if not TipID then
    return
  end
  if not slua.isValid(self.Owner.Object) then
    return
  end
  local VehicleSeat = self.Owner:GetVehicleSeats()
  if not slua.isValid(VehicleSeat) then
    return
  end
  local Driver = VehicleSeat:GetDriver()
  if not slua.isValid(Driver) then
    return
  end
  Game:UIShowImageTips(Driver.PlayerKey, TipID)
end
local class = require("class")
local CFeature = require("GameLua.Mod.BaseMod.Gameplay.Feature.Common.FeatureBase")
return class(CFeature, nil, MotorGliderTLogFeature)