local SpringArmComponentTickProtectionFeature = {}
function SpringArmComponentTickProtectionFeature:ctor()
  self.ProtectionEnabled = true
  self.TimerHandle_EnableSpringArmTick = nil
end
function SpringArmComponentTickProtectionFeature:_PostConstruct()
  SpringArmComponentTickProtectionFeature.__super._PostConstruct(self)
  if not slua.isValid(self.Owner.Object) then
    return
  end
  if Client then
    local VehicleSeat = self.Owner:GetVehicleSeats()
    if slua.isValid(VehicleSeat) then
      self:AddControlEvent(VehicleSeat, "OnClientDriverChange", self.HandleClientDriverChange, self)
    end
  end
end
function SpringArmComponentTickProtectionFeature:SetProtectionEnabled(bEnabled)
  self.ProtectionEnabled = bEnabled
  self:EnableProtection(bEnabled)
end
function SpringArmComponentTickProtectionFeature:EnableProtection(bEnabled)
  if bEnabled then
    if self.ProtectionEnabled and not self.TimerHandle_EnableSpringArmTick then
      self.TimerHandle_EnableSpringArmTick = self:AddGameTimer(5, true, function()
        if not slua.isValid(self.Owner.Object) or not self.Owner:IsLocallyControlled() then
          return
        end
        local VehicleSpringArm = self.Owner:GetVehicleSpringArm()
        if not slua.isValid(VehicleSpringArm) then
          return
        end
        if not VehicleSpringArm:IsComponentTickEnabled() then
          VehicleSpringArm:SetComponentTickEnabled(true)
          print(bWriteLog and "SpringArmComponentTickProtectionFeature:EnableProtection, enable SpringArmComponent tick", self.Object)
        end
      end)
    end
  elseif self.TimerHandle_EnableSpringArmTick then
    self:RemoveGameTimer(self.TimerHandle_EnableSpringArmTick)
    self.TimerHandle_EnableSpringArmTick = nil
  end
end
function SpringArmComponentTickProtectionFeature:HandleClientDriverChange(LastDriver, NewDriver)
  self:EnableProtection(slua.isValid(NewDriver))
end
local class = require("class")
local CFeature = require("GameLua.Mod.BaseMod.Gameplay.Feature.Common.FeatureBase")
return class(CFeature, nil, SpringArmComponentTickProtectionFeature)