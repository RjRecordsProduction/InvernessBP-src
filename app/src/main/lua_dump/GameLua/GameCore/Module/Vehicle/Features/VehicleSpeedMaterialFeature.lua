local VehicleSpeedMaterialFeature = {}
local UKismetMathLibrary = import("KismetMathLibrary")
local VehicleSpeedMaterialConfig = require("GameLua.GameCore.Module.Vehicle.Config.VehicleSpeedMaterialConfig")
function VehicleSpeedMaterialFeature:ctor(_, InVehicle)
  self.OwnerVehicle = InVehicle
  self.UpdateInterval = nil
  self.bEnabled = nil
  self.tConfig = {
    MaterialConfigs = {}
  }
  self.nUpdateTimer = nil
  self.tMaterialInstances = {}
  self.nCurrentItemID = nil
end
function VehicleSpeedMaterialFeature:_PostConstruct()
  print(bWriteLog and "VehicleSpeedMaterialFeature:_PostConstruct")
  VehicleSpeedMaterialFeature.__super._PostConstruct(self)
  self:RefreshMaterialConfig()
  if self.bEnabled and Client then
    self:AddTimerOnce(0, function()
      self:InitFeature()
    end)
  end
end
function VehicleSpeedMaterialFeature:InitFeature()
  if not self.bEnabled then
    return
  end
  if not Client then
    return
  end
  local Vehicle = self.OwnerVehicle
  if slua.isValid(Vehicle) then
    local VehicleAvatar = Vehicle:GetAvatarComponent()
    if slua.isValid(VehicleAvatar) then
      self:AddControlEvent(VehicleAvatar, "OnVehicleSwitchEffectEnd", self.HandleVehicleSwitchEffectEnd, self)
    end
  end
  self:RefreshMaterialConfig()
  self:InitMaterialInstances()
  if #self.tConfig.MaterialConfigs > 0 then
    self.nUpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
      self:UpdateMaterialParameters()
    end)
  end
end
function VehicleSpeedMaterialFeature:RefreshMaterialConfig()
  local Vehicle = self.OwnerVehicle
  if not slua.isValid(Vehicle) then
    return
  end
  local VehicleAvatar = Vehicle:GetAvatarComponent()
  if not slua.isValid(VehicleAvatar) then
    return
  end
  local ItemID = VehicleAvatar:GetCurItemAvatarID()
  if not ItemID or ItemID <= 0 then
    return
  end
  if self.nCurrentItemID == ItemID then
    return
  end
  self.nCurrent  local MaterialConfigs = VehicleSpeedMaterialConfig.GetMaterialConfig(ItemID)
  if MaterialConfigs then
    self.tConfig.  else
    self.tConfig.MaterialConfigs = {}
  end
  if self.nUpdateTimer and #self.tConfig.MaterialConfigs == 0 then
    self:RemoveGameTimer(self.nUpdateTimer)
    self.nUpdateTimer = nil
    self.tMaterialInstances = {}
  end
end
function VehicleSpeedMaterialFeature:HandleVehicleSwitchEffectEnd()
  print(bWriteLog and "VehicleSpeedMaterialFeature:HandleVehicleSwitchEffectEnd")
  self:RefreshMaterialConfig()
  self:InitMaterialInstances()
  if #self.tConfig.MaterialConfigs > 0 and self.bEnabled then
    if not self.nUpdateTimer then
      self.nUpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
        self:UpdateMaterialParameters()
      end)
    end
  elseif self.nUpdateTimer then
    self:RemoveGameTimer(self.nUpdateTimer)
    self.nUpdateTimer = nil
  end
end
function VehicleSpeedMaterialFeature:InitMaterialInstances()
  local Vehicle = self.OwnerVehicle
  if slua.isValid(Vehicle) then
    local VehicleAvatar = Vehicle:GetAvatarComponent()
    if slua.isValid(VehicleAvatar) and VehicleAvatar.CheckIsPlayingEffectSwitch and VehicleAvatar:CheckIsPlayingEffectSwitch() then
      print(bWriteLog and "VehicleSpeedMaterialFeature:InitMaterialInstances - Vehicle switch effect is playing, skip")
      return
    end
  else
    return
  end
  local uMesh = Vehicle:GetMesh()
  if not slua.isValid(uMesh) then
    print(bWriteLog and "VehicleSpeedMaterialFeature:InitMaterialInstances - Mesh is invalid")
    return
  end
  self.tMaterialInstances = {}
  for i, MaterialConfig in ipairs(self.tConfig.MaterialConfigs) do
    local MaterialSlotIndex = MaterialConfig.MaterialSlotIndex
    if MaterialConfig.MaterialSlotName and MaterialSlotIndex == nil then
      MaterialSlotIndex = uMesh:GetMaterialIndex(MaterialConfig.MaterialSlotName)
      if MaterialSlotIndex < 0 then
        print(bWriteLog and string.format("VehicleSpeedMaterialFeature:InitMaterialInstances - Material slot '%s' not found", MaterialConfig.MaterialSlotName))
    end
    elseif MaterialSlotIndex == nil or MaterialSlotIndex < 0 then
      print(bWriteLog and string.format("VehicleSpeedMaterialFeature:InitMaterialInstances - Invalid material slot index: %s", tostring(MaterialSlotIndex)))
    else
      local CurrentMaterial = uMesh:GetMaterial(MaterialSlotIndex)
      if not slua.isValid(CurrentMaterial) then
        print(bWriteLog and string.format("VehicleSpeedMaterialFeature:InitMaterialInstances - Material at slot %d is invalid", MaterialSlotIndex))
      else
        local matIns = uMesh:CreateDynamicMaterialInstance(MaterialSlotIndex, CurrentMaterial)
        table.insert(self.tMaterialInstances, {
          MaterialInstance = matIns,
          Config = MaterialConfig,
          SlotIndex = MaterialSlotIndex
        })
      end
    end
  end
  print(bWriteLog and string.format("VehicleSpeedMaterialFeature:InitMaterialInstances - Initialized %d material instances", #self.tMaterialInstances))
end
function VehicleSpeedMaterialFeature:UpdateMaterialParameters()
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  for _, MaterialData in ipairs(self.tMaterialInstances) do
    if slua.isValid(MaterialData.MaterialInstance) then
      local CurrentSpeed = self:GetVehicleSpeed(MaterialData.Config)
      self:UpdateSingleMaterialParameter(MaterialData.MaterialInstance, MaterialData.Config, CurrentSpeed)
    end
  end
end
function VehicleSpeedMaterialFeature:GetVehicleSpeed(Config)
  if not slua.isValid(self.OwnerVehicle) then
    return 0
  end
  local UseForwardSpeed = true
  if Config and Config.UseForwardSpeed == false then
    UseForwardSpeed = false
  end
  if UseForwardSpeed then
    local ForwardSpeed = self.OwnerVehicle:GetForwardSpeed()
    if ForwardSpeed then
      return math.abs(ForwardSpeed) * 3.6 / 100.0
    end
  end
  local Velocity = self.OwnerVehicle:GetVelocity()
  if Velocity then
    local Speed = UKismetMathLibrary.VSize(Velocity)
    return Speed * 3.6 / 100.0
  end
  return 0
end
function VehicleSpeedMaterialFeature:UpdateSingleMaterialParameter(MaterialInstance, Config, CurrentSpeed)
  if not slua.isValid(MaterialInstance) or not Config then
    return
  end
  local SpeedMin = Config.SpeedMin or 0
  local SpeedMax = Config.SpeedMax or 200
  local SpeedRange = SpeedMax - SpeedMin
  if SpeedRange <= 0 then
    SpeedRange = 1
  end
  local NormalizedSpeed = UKismetMathLibrary.FClamp((CurrentSpeed - SpeedMin) / SpeedRange, 0.0, 1.0)
  local ValueMin = Config.ValueMin or 0.0
  local ValueMax = Config.ValueMax or 1.0
  local LerpValue = UKismetMathLibrary.Lerp(ValueMin, ValueMax, NormalizedSpeed)
  local ParameterType = Config.ParameterType or "Scalar"
  local ParameterName = Config.ParameterName
  if not ParameterName then
    print(bWriteLog and "VehicleSpeedMaterialFeature:UpdateSingleMaterialParameter - ParameterName is nil")
    return
  end
  if ParameterType == "Scalar" then
    local FinalValue = LerpValue
    if Config.UseAdditive then
      local CurrentValue = MaterialInstance:K2_GetScalarParameterValue(ParameterName)
      if CurrentValue then
        FinalValue = CurrentValue + LerpValue * self.UpdateInterval
      end
      if Config.AdditiveMod then
        FinalValue = FinalValue % Config.AdditiveMod
      end
    end
    MaterialInstance:SetScalarParameterValue(ParameterName, FinalValue)
  elseif ParameterType == "Vector" then
    local VectorValue = Config.VectorValue
    if VectorValue then
      MaterialInstance:SetVectorParameterValue(ParameterName, VectorValue)
    else
      local Vector = FVector(FinalValue, FinalValue, FinalValue)
      MaterialInstance:SetVectorParameterValue(ParameterName, Vector)
    end
  elseif ParameterType == "Texture" then
    if Config.TextureMap then
      local SelectedTexture = self:SelectTextureBySpeed(CurrentSpeed, Config.TextureMap)
      if slua.isValid(SelectedTexture) then
        MaterialInstance:SetTextureParameterValue(ParameterName, SelectedTexture)
      end
    end
  else
    print(bWriteLog and string.format("VehicleSpeedMaterialFeature:UpdateSingleMaterialParameter - Unknown parameter type: %s", ParameterType))
  end
end
function VehicleSpeedMaterialFeature:SelectTextureBySpeed(CurrentSpeed, TextureMap)
  local SelectedTexture
  local MaxSpeed = -1
  for _, Entry in ipairs(TextureMap) do
    if CurrentSpeed >= Entry.Speed and MaxSpeed < Entry.Speed then
      MaxSpeed = Entry.Speed
      SelectedTexture = Entry.Texture
    end
  end
  return SelectedTexture
end
function VehicleSpeedMaterialFeature:SetUpdateInterval(Interval)
  if Interval and 0 < Interval then
    self.Update    if self.nUpdateTimer then
      self:RemoveGameTimer(self.nUpdateTimer)
      if self.bEnabled and 0 < #self.tConfig.MaterialConfigs then
        self.nUpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
          self:UpdateMaterialParameters()
        end)
      end
    end
  end
end
function VehicleSpeedMaterialFeature:SetEnabled(bEnabled)
  self.  if bEnabled then
    if not self.nUpdateTimer and #self.tConfig.MaterialConfigs > 0 then
      self:InitMaterialInstances()
      self.nUpdateTimer = self:AddGameTimer(self.UpdateInterval, true, function()
        self:UpdateMaterialParameters()
      end)
    end
  elseif self.nUpdateTimer then
    self:RemoveGameTimer(self.nUpdateTimer)
    self.nUpdateTimer = nil
  end
end
local class = require("class")
local VehicleFeatureBase = require("GameLua.GameCore.Module.Vehicle.VehicleFeatures.VehicleFeatureBase")
return class(VehicleFeatureBase, nil, VehicleSpeedMaterialFeature)