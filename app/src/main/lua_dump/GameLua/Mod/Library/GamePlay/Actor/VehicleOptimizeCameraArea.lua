local VehicleOptimizeCameraArea = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
function VehicleOptimizeCameraArea:ctor()
  self.ClassPathFilter = "STExtraVehicleBase"
  self.OverlappedVehicles = {}
  self.OverlappedSpectator = nil
end
function VehicleOptimizeCameraArea:ReceiveBeginPlay()
  VehicleOptimizeCameraArea.__super.ReceiveBeginPlay(self)
  if Client then
    self:AddGameTimer(1.0, true, function()
      self:ProcessSpectatorPassengerCamera()
    end)
  else
    self:MarkNetDormancyForReplay(true, false)
  end
end
function VehicleOptimizeCameraArea:ReceiveEndPlay(_, bClearTable)
  print(bWriteLog and "VehicleOptimizeCameraArea:ReceiveEndPlay")
  VehicleOptimizeCameraArea.__super.ReceiveEndPlay(self, _, bClearTable)
end
function VehicleOptimizeCameraArea:OnOtherActorEnterOrLeave(uOtherActor, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("VehicleOptimizeCameraArea OnOtherActorEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName), uOtherActor)
  local bHugeVehicle = false
  for i, SoftHugeVehicleClass in pairs(self.HugeVehicleClass) do
    local SoftPath = SoftHugeVehicleClass:ToSoftObjectPath()
    local CHugeVehicle = USTExtraBlueprintFunctionLibrary.GetAssetByAssetReference(SoftPath)
    if Game:IsClassOf(uOtherActor, CHugeVehicle) then
      bHugeVehicle = true
      break
    end
  end
  for i, Type in pairs(self.HugeVehicleType) do
    if uOtherActor.VehicleType and uOtherActor.VehicleType == Type then
      bHugeVehicle = true
      break
    end
  end
  if not bHugeVehicle then
    return
  end
  sandbox.LogNormal(bWriteLog and string.format("VehicleOptimizeCameraArea HugeVehicle bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName), uOtherActor)
  if bEnter then
    self.OverlappedVehicles[uOtherActor] = true
  else
    self.OverlappedVehicles[uOtherActor] = nil
  end
  local uSpringArm = self:GetVehicleSpringArm(uOtherActor)
  if slua.isValid(uSpringArm) then
    print(bWriteLog and "VehicleOptimizeCameraArea ClientHandleEnterVehicle Vehicle Camera bDoCollisionTest %s", tostring(not bEnter))
    uSpringArm.bDoCollisionTest = not bEnter
  end
  local uLocalCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uLocalCharacter) and uLocalCharacter:GetCurrentVehicle() == uOtherActor then
    local uTPPSpringArm = uLocalCharacter:GetThirdPersonSpringArm()
    if bEnter then
      uTPPSpringArm.bDoCollisionTest = false
      self:AddControlEvent(uOtherActor, "OnClientEnterVehicleEvent", self.ClientHandleEnterVehicle, self, uOtherActor)
      self:AddControlEvent(uOtherActor, "OnClientExitVehicleEvent", self.ClientHandleExitVehicle, self, uOtherActor)
    else
      uTPPSpringArm.bDoCollisionTest = true
      self:RemoveControlEvent(uOtherActor, "OnClientEnterVehicleEvent")
      self:RemoveControlEvent(uOtherActor, "OnClientExitVehicleEvent")
    end
  end
end
function VehicleOptimizeCameraArea:ServerOnVehicleEnterOrLeave(uVehicle, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("BaseLevelEnterArea ServerOnVehicleEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uVehicle))
end
function VehicleOptimizeCameraArea:ClientOnVehicleEnterOrLeave(uVehicle, bEnter)
  sandbox.LogNormal(bWriteLog and string.format("VehicleOptimizeCameraArea ClientOnVehicleEnterOrLeave bEnter:%s AreaID:%s, Self:%s", tostring(bEnter), tostring(self.AreaID), self.ActorName, uVehicle))
  self:OnOtherActorEnterOrLeave(uVehicle, bEnter)
end
function VehicleOptimizeCameraArea:GetVehicleSpringArm(uVehicle)
  if slua.isValid(uVehicle.VehicleSpringArm) then
    return uVehicle.VehicleSpringArm
  else
    local CSpringArm = import("/Script/Engine.SpringArmComponent")
    local uSpringArm = uVehicle:GetComponentByClass(CSpringArm)
    if slua.isValid(uSpringArm) then
      return uSpringArm
    end
  end
  return nil
end
function VehicleOptimizeCameraArea:ProcessSpectatorPassengerCamera()
  local uLocalCharacter = GameplayData.GetPlayerCharacter()
  local uLocalController = GameplayData.GetPlayerController()
  if not slua.isValid(uLocalController) then
    return
  end
  local uCurPawn = uLocalController:GetCurPlayerCharacter()
  local bConditionSatisfied = false
  if slua.isValid(uCurPawn) and uCurPawn ~= uLocalCharacter then
    local uCurVehicle = uCurPawn:GetCurrentVehicle()
    if slua.isValid(uCurVehicle) and self.OverlappedVehicles[uCurVehicle] then
      bConditionSatisfied = true
      local uSpringArm = self:GetVehicleSpringArm(uCurVehicle)
      if slua.isValid(uSpringArm) then
        print(bWriteLog and "VehicleOptimizeCameraArea ProcessSpectatorPassengerCamera Vehicle Camera bDoCollisionTest false")
        uSpringArm.bDoCollisionTest = false
      end
    end
  end
  if slua.isValid(self.OverlappedSpectator) then
    print(bWriteLog and "VehicleOptimizeCameraArea ProcessSpectatorPassengerCamera Spectator %s Camera bDoCollisionTest true", tostring(self.OverlappedSpectator.PlayerKey))
    local uTPPSpringArm = self.OverlappedSpectator:GetThirdPersonSpringArm()
    if slua.isValid(uTPPSpringArm) then
      uTPPSpringArm.bDoCollisionTest = true
      self.OverlappedSpectator = nil
    end
  end
  if bConditionSatisfied and slua.isValid(uCurPawn) then
    print(bWriteLog and "VehicleOptimizeCameraArea ProcessSpectatorPassengerCamera Spectator %s Camera bDoCollisionTest false", tostring(uCurPawn.PlayerKey))
    local uTPPSpringArm = uCurPawn:GetThirdPersonSpringArm()
    if slua.isValid(uTPPSpringArm) then
      uTPPSpringArm.bDoCollisionTest = false
      self.OverlappedSpectator = uCurPawn
    end
  end
end
function VehicleOptimizeCameraArea:ClientHandleEnterVehicle(uVehicle, uCharacter, SeatType)
  if SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat and self.OverlappedVehicles[uVehicle] then
    local uSpringArm = self:GetVehicleSpringArm(uVehicle)
    if slua.isValid(uSpringArm) then
      print(bWriteLog and "VehicleOptimizeCameraArea ClientHandleEnterVehicle Vehicle Camera bDoCollisionTest false PlayerKey:%s", tostring(uCharacter.PlayerKey))
      uSpringArm.bDoCollisionTest = false
    end
  end
  if slua.isValid(uCharacter) then
    local uTPPSpringArm = uCharacter:GetThirdPersonSpringArm()
    if slua.isValid(uTPPSpringArm) then
      print(bWriteLog and "VehicleOptimizeCameraArea ClientHandleEnterVehicle PlayerKey:%s", tostring(uCharacter.PlayerKey))
      uTPPSpringArm.bDoCollisionTest = false
    end
  end
end
function VehicleOptimizeCameraArea:ClientHandleExitVehicle(uVehicle, uCharacter, SeatType)
  if slua.isValid(uCharacter) then
    local uTPPSpringArm = uCharacter:GetThirdPersonSpringArm()
    if slua.isValid(uTPPSpringArm) then
      print(bWriteLog and "VehicleOptimizeCameraArea ClientHandleExitVehicle PlayerKey:%s", tostring(uCharacter.PlayerKey))
      uTPPSpringArm.bDoCollisionTest = true
    end
  end
end
local Class = require("class")
local object = require("GameLua.Mod.Library.GamePlay.Actor.BaseLevelEnterArea")
local CVehicleOptimizeCameraArea = Class(object, nil, VehicleOptimizeCameraArea)
return CVehicleOptimizeCameraArea