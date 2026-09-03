local WheeledVehicleBoostEffect = {}
function WheeledVehicleBoostEffect:ctor(_, InEffectType, InVehicle, InEffectFeature)
  WheeledVehicleBoostEffect.__super.ctor(self, _, InEffectType, InVehicle, InEffectFeature)
  self.BoostEffectName = "ExhaustBody"
  self.ExhaustEffectName = "Exhaust"
  if slua.isValid(self.OwnerVehicle) then
    self.OwnerVehicle.bEnableUpdateExhuastEffectBP = false
  end
end
function WheeledVehicleBoostEffect:_PostConstruct()
  WheeledVehicleBoostEffect.__super._PostConstruct(self)
  self:UpdateEffect()
end
function WheeledVehicleBoostEffect:RegisterEvents()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  self:AddControlEvent(self.OwnerVehicle, "OnVehicleBoostChanged", self.OnVehicleBoostChanged, self)
  self:BindLuaObjEvent(self.OwnerVehicle, "OnUseMotorAudio", self.OnUseMotorAudio, self)
  self:BindLuaObjEvent(self.OwnerVehicle, "OnExhuastEffectRefresh", self.OnExhuastEffectRefresh, self)
end
function WheeledVehicleBoostEffect:UpdateEffect()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  if self.OwnerVehicle:IsBoosting() and not self.OwnerVehicle:IsUsingFPPModel() then
    self.OwnerVehicle:ActiveEffectAsync(self.BoostEffectName)
    if not self.OwnerVehicle:IsHybridAudioEnabled() or not self.OwnerVehicle:IsUsingMotorAudio() then
      self.OwnerVehicle:ActiveEffectAsync(self.ExhaustEffectName)
    else
      self.OwnerVehicle:DeactiveEffect(self.ExhaustEffectName)
    end
  else
    self.OwnerVehicle:DeactiveEffect(self.BoostEffectName)
    self.OwnerVehicle:DeactiveEffect(self.ExhaustEffectName)
  end
end
function WheeledVehicleBoostEffect:OnVehicleBoostChanged(IsBoosting)
  self:UpdateEffect()
end
function WheeledVehicleBoostEffect:OnUseMotorAudio(InEnabled)
  self:UpdateEffect()
end
function WheeledVehicleBoostEffect:OnExhuastEffectRefresh()
  self:UpdateEffect()
end
local class = require("class")
local CVehicleEffectBase = require("GameLua.Mod.Library.GamePlay.Vehicle.VehicleEffects.VehicleEffectBase")
return class(CVehicleEffectBase, nil, WheeledVehicleBoostEffect)