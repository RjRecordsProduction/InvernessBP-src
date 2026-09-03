local VehicleAudiosFeature = {}
local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
function VehicleAudiosFeature:ctor(_, InVehicle)
  VehicleAudiosFeature.__super.ctor(self, _, InVehicle)
  self.UpdateInterval = 0.1
  self.AudioSetups = {}
  self.AudioMap = {}
  self.ActiveAudios = {}
end
function VehicleAudiosFeature:_PostConstruct()
  VehicleAudiosFeature.__super._PostConstruct(self)
  for AudioType, AudioSetup in pairs(self.AudioSetups) do
    if slua.IsLuaModuleExists(AudioSetup.ClassPath) then
      local AudioClass = require(AudioSetup.ClassPath)
      local AudioInstance = AudioClass(AudioType, self.OwnerVehicle, self)
      if AudioInstance then
        for Key, Value in pairs(AudioSetup.Attributes) do
          AudioInstance[Key] = Value
        end
        AudioInstance:_PostConstruct()
        self:RegisterAudio(AudioType, AudioInstance)
      end
    end
  end
end
function VehicleAudiosFeature:Dispose()
  VehicleAudiosFeature.__super.Dispose(self)
  print(bWriteLog and "VehicleAudiosFeature:Dispose", self.OwnerVehicle)
  for AudioType, AudioInstance in pairs(self.AudioMap) do
    self:DeactivateAudio(AudioType)
    AudioInstance:Terminate()
  end
  self.AudioMap = {}
end
function VehicleAudiosFeature:SetActive(InActive)
  if not slua.isValid(self.OwnerVehicle) then
    return
  end
  print(bWriteLog and "VehicleAudiosFeature:SetActive", InActive, self.OwnerVehicle)
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
function VehicleAudiosFeature:ActivateAudio(InAudioType)
  if self.AudioMap[InAudioType] then
    print(bWriteLog and "VehicleAudiosFeature:ActivateAudio", InAudioType, self.OwnerVehicle)
    self.ActiveAudios[InAudioType] = true
    self:SetActive(true)
  end
end
function VehicleAudiosFeature:DeactivateAudio(InAudioType)
  if self.ActiveAudios[InAudioType] then
    print(bWriteLog and "VehicleAudiosFeature:DeactivateAudio", InAudioType, self.OwnerVehicle)
    self.ActiveAudios[InAudioType] = nil
    if not next(self.ActiveAudios) then
      self:SetActive(false)
    end
  end
end
function VehicleAudiosFeature:RegisterAudio(InAudioType, InAudioInstance)
  if not InAudioType or not InAudioInstance then
    return
  end
  print(bWriteLog and "VehicleAudiosFeature:RegisterAudio", InAudioType, self.OwnerVehicle)
  self:UnregisterAudio(InAudioType)
  self.AudioMap[InAudioType] = InAudioInstance
  InAudioInstance:ToggleActive()
  InAudioInstance:PlayOrStop()
end
function VehicleAudiosFeature:UnregisterAudio(InAudioType)
  if not self.AudioMap[InAudioType] then
    return
  end
  print(bWriteLog and "VehicleAudiosFeature:UnregisterAudio", InAudioType, self.OwnerVehicle)
  local AudioInstance = self.AudioMap[InAudioType]
  if AudioInstance then
    self:DeactivateAudio(InAudioType)
    AudioInstance:Terminate()
  end
  self.AudioMap[InAudioType] = nil
end
function VehicleAudiosFeature:Update()
  local CurrentActiveAudios = {}
  for AudioType, _ in pairs(self.ActiveAudios) do
    table.insert(CurrentActiveAudios, AudioType)
  end
  for _, AudioType in pairs(CurrentActiveAudios) do
    local AudioInstance = self.AudioMap[AudioType]
    if AudioInstance then
      AudioInstance:Update()
    end
  end
  if not next(self.ActiveAudios) then
    self:SetActive(false)
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.GameCore.Module.Vehicle.VehicleFeatures.VehicleFeatureBase")
return class(CFeatureBase, nil, VehicleAudiosFeature)