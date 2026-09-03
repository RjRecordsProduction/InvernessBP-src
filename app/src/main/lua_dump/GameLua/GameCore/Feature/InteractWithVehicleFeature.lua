local InteractWithVehicleFeature = {}
function InteractWithVehicleFeature:ctor()
  self.EnableCameraLag = false
  self.UnmmanedVehicleStates = {}
end
function InteractWithVehicleFeature:_PostConstruct()
  InteractWithVehicleFeature.__super._PostConstruct(self)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  local LastSyncData = self.Owner.LastUnmannedVehicleSyncData
  table.insert(self.UnmmanedVehicleStates, {
    LastSyncData.CurrentUAVUseType,
    LastSyncData.CurrentUnmannedVehicle
  })
  self:AddControlEvent(self.Owner, "OnPostRepAttachment", self.OnPostRepAttachment, self)
  self:BindLuaObjEvent(self.Owner, "OnUnmannedVehicleStateChange", self.OnUnmannedVehicleStateChange, self)
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTID_PLAYEREVENT_PLAYERKEY_CHANGE, self.OnPlayerKeyChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CONTROLLER_PLAYERKEY_CHANGE, self.OnPlayerControllerKeyChange, self)
end
local IsFirstCharacter = function(Character)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  return slua.isValid(PlayerController) and slua.isValid(Character) and Character.PlayerKey ~= 0 and Character.PlayerKey == PlayerController.PlayerKey
end
local GetVehicleUserComp = function()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    return PlayerController:GetVehicleUserComp()
  end
end
function InteractWithVehicleFeature:OnPostRepAttachment(uAttachParent, uAttachComponent, uAttachSocket, uLocationOffset, uRotationOffset, uRelativeScale3D)
  print(bWriteLog and "InteractWithVehicleFeature:OnPostRepAttachment", self.Owner.Object, uAttachParent, uAttachComponent, uAttachSocket, uLocationOffset, uRotationOffset, uRelativeScale3D)
  local VehicleBaseClass = import("STExtraVehicleBase")
  if Game:IsClassOf(uAttachParent, VehicleBaseClass) then
    self:OnGetOnVehicle(uAttachParent)
  elseif slua.isValid(self.Owner:GetCurrentVehicle()) or self.Owner.bIsAttachedToVehicle then
    self:OnGetOffVehicle(self.Owner:GetCurrentVehicle())
  end
end
function InteractWithVehicleFeature:OnGetOnVehicle(InVehicle)
  if not slua.isValid(InVehicle) then
    return
  end
  print(bWriteLog and "InteractWithVehicleFeature:OnGetOnVehicle", self.Owner.Object, InVehicle)
  local SpringArmComp = self.Owner:GetThirdPersonSpringArm()
  if slua.isValid(SpringArmComp) then
    self.EnableCameraLag = SpringArmComp.bEnableCameraLag
    SpringArmComp.bEnableCameraLag = false
    print(bWriteLog and "InteractWithVehicleFeature:OnGetOnVehicle, disable camera lag", self.Owner.Object)
  end
  self:UpdateClientEnterData(InVehicle)
end
function InteractWithVehicleFeature:OnGetOffVehicle(InVehicle)
  if InVehicle == nil then
    print(bWriteLog and "InteractWithVehicleFeature:OnGetOffVehicle InVehicle == nil")
    return
  end
  print(bWriteLog and string.format("InteractWithVehicleFeature:OnGetOffVehicle,slua.isValid(InVehicle)=%s, bIsAttachedToVehicle=%s", tostring(slua.isValid(InVehicle)), tostring(self.Owner.bIsAttachedToVehicle)))
  print(bWriteLog and "InteractWithVehicleFeature:OnGetOffVehicle", self.Owner.Object, InVehicle)
  local SpringArmComp = self.Owner:GetThirdPersonSpringArm()
  if slua.isValid(SpringArmComp) then
    SpringArmComp.bEnableCameraLag = self.EnableCameraLag
    print(bWriteLog and "InteractWithVehicleFeature:OnGetOnVehicle, restore camera lag", self.Owner.Object, SpringArmComp.bEnableCameraLag)
  end
  self:UpdateClientExitData()
end
function InteractWithVehicleFeature:OnPlayerKeyChange(_, _, Character)
  if not slua.isValid(Character) or self.Owner.Object ~= Character then
    return
  end
  print(bWriteLog and "InteractWithVehicleFeature:OnPlayerKeyChange", Character)
  self:UpdateClientEnterData(Character:GetCurrentVehicle())
  self:UpdateClientUnmannedVehicleState()
end
function InteractWithVehicleFeature:OnPlayerControllerKeyChange(_, _, PlayerController)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  if not slua.isValid(PlayerController) then
    return
  end
  local Character = self.Owner.Object
  print(bWriteLog and "InteractWithVehicleFeature:OnPlayerControllerKeyChange", Character, PlayerController)
  self:UpdateClientEnterData(Character:GetCurrentVehicle())
  self:UpdateClientUnmannedVehicleState()
end
function InteractWithVehicleFeature:OnUnmannedVehicleStateChange()
  if self.Owner and slua.isValid(self.Owner.Object) then
    print(bWriteLog and "InteractWithVehicleFeature:OnUnmannedVehicleStateChange")
    local CurrentSyncData = {
      self.Owner.CurrentUnmannedVehicleSyncData.CurrentUAVUseType,
      self.Owner.CurrentUnmannedVehicleSyncData.CurrentUnmannedVehicle
    }
    self:UpdateClientUnmannedVehicleState(CurrentSyncData)
  end
end
function InteractWithVehicleFeature:UpdateClientEnterData(Vehicle)
  if Client and slua.isValid(Vehicle) and IsFirstCharacter(self.Owner.Object) then
    print(bWriteLog and "InteractWithVehicleFeature:UpdateClientEnterData", self.Owner.Object, Vehicle)
    local VehicleUserComp = GetVehicleUserComp()
    if slua.isValid(VehicleUserComp) then
      VehicleUserComp:UpdateVehicleAndCharacterData(Vehicle, self.Owner.Object)
    end
  end
end
function InteractWithVehicleFeature:UpdateClientExitData()
  if Client and IsFirstCharacter(self.Owner.Object) then
    print(bWriteLog and "InteractWithVehicleFeature:UpdateClientExitData", self.Owner.Object)
    local VehicleUserComp = GetVehicleUserComp()
    if slua.isValid(VehicleUserComp) then
      VehicleUserComp:UpdateVehicleAndCharacterData()
    end
  end
end
function InteractWithVehicleFeature:UpdateClientUnmannedVehicleState(InSyncData)
  if not (Client and self.Owner) or not slua.isValid(self.Owner.Object) then
    return
  end
  local VehicleUtils = import("/Script/ShadowTrackerExtra.VehicleUtils")
  if VehicleUtils.UnmanedVehicleReconnectImpl() == 0 then
    return
  end
  local TryCacheSyncData = function()
    local PrevSyncData = self.UnmmanedVehicleStates[#self.UnmmanedVehicleStates]
    if InSyncData and PrevSyncData and (PrevSyncData[1] ~= InSyncData[1] or PrevSyncData[2] ~= InSyncData[2]) then
      table.insert(self.UnmmanedVehicleStates, InSyncData)
    end
  end
  print(bWriteLog and "InteractWithVehicleFeature:UpdateClientUnmannedVehicleState")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    print(bWriteLog and "InteractWithVehicleFeature:UpdateClientUnmannedVehicleState, PlayerController nil")
    TryCacheSyncData()
    return
  end
  if self.Owner.PlayerKey == 0 or PlayerController.PlayerKey == 0 then
    print(bWriteLog and "InteractWithVehicleFeature:UpdateClientUnmannedVehicleState, PlayerKey 0")
    TryCacheSyncData()
    return
  end
  if self.Owner.PlayerKey ~= PlayerController.PlayerKey then
    self.UnmmanedVehicleStates = {}
    return
  end
  local VehicleUserComp = GetVehicleUserComp()
  if not slua.isValid(VehicleUserComp) then
    print(bWriteLog and "InteractWithVehicleFeature:UpdateClientUnmannedVehicleState, VehicleUserComp nil")
    self.UnmmanedVehicleStates = {}
    return
  end
  local SyncData = InSyncData or self.UnmmanedVehicleStates[#self.UnmmanedVehicleStates]
  if SyncData then
    local EUAVUseType = import("/Script/ShadowTrackerExtra.EUAVUseType")
    if SyncData[1] == EUAVUseType.UAV_None then
      local LastSyncData = self.UnmmanedVehicleStates[1]
      if LastSyncData and LastSyncData[1] > EUAVUseType.UAV_Init and slua.isValid(LastSyncData[2]) then
        VehicleUserComp:ClientPauseUnmannedVehicle(LastSyncData[2])
        self:UnBindLuaObjEvent(LastSyncData[2], "VehicleEndPlayEvent")
      end
    elseif SyncData[1] > EUAVUseType.UAV_Init and slua.isValid(SyncData[2]) then
      local LastSyncData = self.UnmmanedVehicleStates[1]
      if LastSyncData and LastSyncData[1] <= EUAVUseType.UAV_Init then
        print(bWriteLog and "InteractWithVehicleFeature:UpdateClientUnmannedVehicleState, call ClientLaunchUnmannedVehicle")
        self:BindLuaObjEvent(SyncData[2], "VehicleEndPlayEvent", function()
          self:OnUnmannedVehicleEndPlay(SyncData[2])
        end)
        VehicleUserComp:ClientLaunchUnmannedVehicle(SyncData[2])
      end
      if SyncData[1] == EUAVUseType.UAV_Standby then
        print(bWriteLog and "InteractWithVehicleFeature:UpdateClientUnmannedVehicleState, call ClientPauseUnmannedVehicle")
        VehicleUserComp:ClientPauseUnmannedVehicle(SyncData[2])
        self:UnBindLuaObjEvent(SyncData[2], "VehicleEndPlayEvent")
      end
    end
  end
  self.UnmmanedVehicleStates = {SyncData}
end
function InteractWithVehicleFeature:OnUnmannedVehicleEndPlay(InVehicle)
  if not slua.isValid(InVehicle) then
    return
  end
  print(bWriteLog and "InteractWithVehicleFeature:OnUnmannedVehicleEndPlay", InVehicle)
  local EUAVUseType = import("/Script/ShadowTrackerExtra.EUAVUseType")
  local SyncData = {
    EUAVUseType.UAV_None,
    nil
  }
  self:UpdateClientUnmannedVehicleState(SyncData)
end
local class = require("class")
local CFeature = require("GameLua.Mod.BaseMod.Gameplay.Feature.Common.FeatureBase")
return class(CFeature, nil, InteractWithVehicleFeature)