local VehicleEffectBase = {}
function VehicleEffectBase:ctor(_, InEffectType, InVehicle, InEffectFeature)
  self.bShouldActivate = false
  self.MinSpeed = 0
  self.EffectType = InEffectType
  self.OwnerVehicle = InVehicle
  self.EffectFeature = InEffectFeature
  self.AssetLoadState = {IsCompleted = false, Handle = nil}
end
function VehicleEffectBase:_PostConstruct()
  self:RegisterEvents()
end
function VehicleEffectBase:RegisterEvents()
end
function VehicleEffectBase:UnregisterEvents()
end
function VehicleEffectBase:GetObjectByPath(InPath)
  if string.len(InPath) > 0 then
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local SoftObjectPath = KismetSystemLibrary.MakeSoftObjectPath(InPath)
    return STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(SoftObjectPath)
  end
  return nil
end
function VehicleEffectBase:CheckAndAddAssetPath(OutAssets, InPath)
  if InPath and string.len(InPath) > 0 then
    table.insert(OutAssets, InPath)
  end
end
function VehicleEffectBase:GetAssets()
  return {}
end
function VehicleEffectBase:OnLoadComplete()
  print(bWriteLog and "VehicleEffectBase:OnLoadComplete", self.OwnerVehicle)
  self.AssetLoadState.IsCompleted = true
  self.AssetLoadState.Handle = nil
  if slua.isValid(self.OwnerVehicle) then
    self.OwnerVehicle:HookObjectByPaths(self:GetAssets())
  end
end
function VehicleEffectBase:_LoadAssets()
  if self.AssetLoadState.IsCompleted then
    return true
  end
  if not self.AssetLoadState.Handle then
    print(bWriteLog and "VehicleEffectBase:_LoadAssets: try loading assets", self.OwnerVehicle)
    self:AsyncLoadAssetArray(self:GetAssets(), function()
      self:OnLoadComplete()
    end)
  end
  return false
end
function VehicleEffectBase:CanPlay()
  if slua.isValid(self.OwnerVehicle) then
    local Speed = self.OwnerVehicle:GetForwardSpeed() * 0.01
    return Speed >= self.MinSpeed
  end
  return false
end
function VehicleEffectBase:PlayOrStop()
  if self:CanPlay() then
    self:Play()
  else
    self:Stop()
  end
end
function VehicleEffectBase:Play()
end
function VehicleEffectBase:Stop()
end
function VehicleEffectBase:Update(DeltaTime)
end
function VehicleEffectBase:ShouldActivate()
  return self.bShouldActivate and slua.isValid(self.OwnerVehicle)
end
function VehicleEffectBase:Activate()
  if self.EffectFeature then
    self.EffectFeature:ActivateEffect(self.EffectType)
  end
end
function VehicleEffectBase:Deactivate()
  if self.EffectFeature then
    self.EffectFeature:DeactivateEffect(self.EffectType)
  end
end
function VehicleEffectBase:ToggleActive()
  if self:ShouldActivate() then
    self:Activate()
  else
    self:Deactivate()
    self:Stop()
  end
end
function VehicleEffectBase:Terminate()
  self:Stop()
  self:UnregisterEvents()
  if slua.isValid(self.OwnerVehicle) then
    self.OwnerVehicle:UnhookObjectByPaths(self:GetAssets())
  end
  self.EffectType = nil
  self.OwnerVehicle = nil
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local BaseClass = class(CDelegateContainer, nil, VehicleEffectBase)
local MetaTable = getmetatable(BaseClass)
function MetaTable.__newindex(t, k, v)
  rawset(t, k, v)
end
setmetatable(BaseClass, MetaTable)
return BaseClass