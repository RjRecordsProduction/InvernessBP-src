local VehicleEffectsFeature = {}
local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
function VehicleEffectsFeature:ctor(_, InVehicle)
  VehicleEffectsFeature.__super.ctor(self, _, InVehicle)
  self.UpdateInterval = 0.1
  self.EffectSetups = {}
  self.EffectMap = {}
  self.ActiveEffects = {}
end
function VehicleEffectsFeature:_PostConstruct()
  VehicleEffectsFeature.__super._PostConstruct(self)
  for EffectType, EffectSetup in pairs(self.EffectSetups) do
    if slua.IsLuaModuleExists(EffectSetup.ClassPath) then
      local EffectClass = require(EffectSetup.ClassPath)
      local EffectInstance = EffectClass(EffectType, self.OwnerVehicle, self)
      if EffectInstance then
        for Key, Value in pairs(EffectSetup.Attributes) do
          EffectInstance[Key] = Value
        end
        EffectInstance:_PostConstruct()
        self:RegisterEffect(EffectType, EffectInstance)
      end
    end
  end
end
function VehicleEffectsFeature:Dispose()
  VehicleEffectsFeature.__super.Dispose(self)
  print(bWriteLog and "VehicleEffectsFeature:Dispose", self.OwnerVehicle)
  for EffectType, EffectInstance in pairs(self.EffectMap) do
    self:DeactivateEffect(EffectType)
    EffectInstance:Terminate()
  end
  self.EffectMap = {}
end
function VehicleEffectsFeature:SetActive(InActive)
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  print(bWriteLog and "VehicleEffectsFeature:SetActive", InActive, self.OwnerVehicle)
  if InActive then
    if not self.TimerHandle then
      self.TimerHandle = self:AddGameTimer(self.UpdateInterval, true, function()
        self:Update()
      end)
    end
  else
    self:RemoveGameTimer(self.TimerHandle)
    self.TimerHandle = nil
  end
end
function VehicleEffectsFeature:ActivateEffect(InEffectType)
  if self.EffectMap[InEffectType] then
    print(bWriteLog and "VehicleEffectsFeature:ActivateEffect", InEffectType, self.OwnerVehicle)
    self.ActiveEffects[InEffectType] = true
    self:SetActive(true)
  end
end
function VehicleEffectsFeature:DeactivateEffect(InEffectType)
  if self.ActiveEffects[InEffectType] then
    print(bWriteLog and "VehicleEffectsFeature:DeactivateEffect", InEffectType, self.OwnerVehicle)
    self.ActiveEffects[InEffectType] = nil
    if not next(self.ActiveEffects) then
      self:SetActive(false)
    end
  end
end
function VehicleEffectsFeature:RegisterEffect(InEffectType, InEffectInstance)
  if not InEffectType or not InEffectInstance then
    return
  end
  print(bWriteLog and "VehicleEffectsFeature:RegisterEffect", InEffectType, self.OwnerVehicle)
  self:UnregisterEffect(InEffectType)
  self.EffectMap[InEffectType] = InEffectInstance
  InEffectInstance:ToggleActive()
  InEffectInstance:PlayOrStop()
end
function VehicleEffectsFeature:UnregisterEffect(InEffectType)
  if not self.EffectMap[InEffectType] then
    return
  end
  print(bWriteLog and "VehicleEffectsFeature:UnregisterEffect", InEffectType, self.OwnerVehicle)
  local EffectInstance = self.EffectMap[InEffectType]
  if EffectInstance then
    self:DeactivateEffect(InEffectType)
    EffectInstance:Terminate()
  end
  self.EffectMap[InEffectType] = nil
end
function VehicleEffectsFeature:Update()
  local CurrentActiveEffects = {}
  for EffectType, _ in pairs(self.ActiveEffects) do
    table.insert(CurrentActiveEffects, EffectType)
  end
  for _, EffectType in pairs(CurrentActiveEffects) do
    local EffectInstance = self.EffectMap[EffectType]
    if EffectInstance then
      EffectInstance:Update()
    end
  end
  if not next(self.ActiveEffects) then
    self:SetActive(false)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.GameCore.Module.Vehicle.VehicleFeatures.VehicleFeatureBase")
return class(CFeatureBase, nil, VehicleEffectsFeature)