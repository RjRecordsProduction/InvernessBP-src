local VehicleAudioBase = {}
function VehicleAudioBase:ctor(_, InAudioType, InVehicle, InAudioFeature)
  self.AudioPath = ""
  self.StopAudioPath = ""
  self.bShouldActivate = false
  self.MinSpeed = 0
  self.AudioType = InAudioType
  self.OwnerVehicle = InVehicle
  self.AudioFeature = InAudioFeature
  self.AkComponent = slua.isValid(InVehicle) and InVehicle:GetSoundComponent() or nil
  self.AssetLoadState = {IsCompleted = false, Handle = nil}
  self.PostEventID = nil
end
function VehicleAudioBase:_PostConstruct()
  self:RegisterEvents()
end
function VehicleAudioBase:RegisterEvents()
end
function VehicleAudioBase:UnregisterEvents()
end
function VehicleAudioBase:GetObjectByPath(InPath)
  if string.len(InPath) > 0 then
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local SoftObjectPath = KismetSystemLibrary.MakeSoftObjectPath(InPath)
    return STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(SoftObjectPath)
  end
  return nil
end
function VehicleAudioBase:CheckAndAddAssetPath(OutAssets, InPath)
  if InPath and string.len(InPath) > 0 then
    table.insert(OutAssets, InPath)
  end
end
function VehicleAudioBase:GetAssets()
  local Assets = {}
  self:CheckAndAddAssetPath(Assets, self.AudioPath)
  self:CheckAndAddAssetPath(Assets, self.StopAudioPath)
  return Assets
end
function VehicleAudioBase:OnLoadComplete()
  print(bWriteLog and "VehicleAudioBase:OnLoadComplete", self.OwnerVehicle)
  self.AssetLoadState.IsCompleted = true
  self.AssetLoadState.Handle = nil
  if slua.isValid(self.OwnerVehicle) then
    self.OwnerVehicle:HookObjectByPaths(self:GetAssets())
  end
end
function VehicleAudioBase:_LoadAssets()
  if self.AssetLoadState.IsCompleted then
    return true
  end
  if not self.AssetLoadState.Handle then
    print(bWriteLog and "VehicleAudioBase:_LoadAssets: try loading assets", self.OwnerVehicle)
    self.AssetLoadState.Handle = self:AsyncLoadAssetArray(self:GetAssets(), function()
      self:OnLoadComplete()
    end)
  end
  return false
end
function VehicleAudioBase:CanPlay()
  if slua.isValid(self.OwnerVehicle) and slua.isValid(self.AkComponent) then
    local Speed = math.abs(self.OwnerVehicle:GetForwardSpeed()) * 0.01
    return Speed >= self.MinSpeed
  end
  return false
end
function VehicleAudioBase:PlayOrStop()
  if self:CanPlay() then
    self:Play()
  else
    self:Stop()
  end
end
function VehicleAudioBase:Play()
  self:_LoadAssets()
  if not self.AssetLoadState.IsCompleted or not slua.isValid(self.AkComponent) then
    return
  end
  if not self.PostEventID then
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local AudioEvent = self:GetObjectByPath(self.AudioPath)
    local AudioEventName = KismetSystemLibrary.GetObjectName(AudioEvent)
    self.PostEventID = self.AkComponent:PostAkEventByName(AudioEventName)
    print(bWriteLog and "VehicleAudioBase:Play", self.AudioPath, self.OwnerVehicle)
  end
end
function VehicleAudioBase:Stop()
  if self.PostEventID then
    local StopAudioEvent = self:GetObjectByPath(self.StopAudioPath)
    if slua.isValid(StopAudioEvent) then
      local KismetSystemLibrary = import("KismetSystemLibrary")
      local StopAudioEventName = KismetSystemLibrary.GetObjectName(StopAudioEvent)
      self.AkComponent:PostAkEventByName(StopAudioEventName)
    else
      self.AkComponent:StopPlayingID(self.PostEventID)
    end
    self.PostEventID = nil
    print(bWriteLog and "VehicleAudioBase:Stop", self.AudioPath, self.OwnerVehicle)
  end
end
function VehicleAudioBase:Update()
end
function VehicleAudioBase:ShouldActivate()
  return self.bShouldActivate and slua.isValid(self.OwnerVehicle) and slua.isValid(self.AkComponent)
end
function VehicleAudioBase:Activate()
  if self.AudioFeature then
    self.AudioFeature:ActivateAudio(self.AudioType)
  end
end
function VehicleAudioBase:Deactivate()
  if self.AudioFeature then
    self.AudioFeature:DeactivateAudio(self.AudioType)
  end
end
function VehicleAudioBase:ToggleActive()
  if self:ShouldActivate() then
    self:Activate()
  else
    self:Deactivate()
  end
end
function VehicleAudioBase:Terminate()
  self:Stop()
  self:UnregisterEvents()
  if slua.isValid(self.OwnerVehicle) then
    self.OwnerVehicle:UnhookObjectByPaths(self:GetAssets())
  end
  self.AudioType = nil
  self.OwnerVehicle = nil
  self.AkComponent = nil
  self:Dispose()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local BaseClass = class(CDelegateContainer, nil, VehicleAudioBase)
local MetaTable = getmetatable(BaseClass)
function MetaTable.__newindex(t, k, v)
  rawset(t, k, v)
end
setmetatable(BaseClass, MetaTable)
return BaseClass