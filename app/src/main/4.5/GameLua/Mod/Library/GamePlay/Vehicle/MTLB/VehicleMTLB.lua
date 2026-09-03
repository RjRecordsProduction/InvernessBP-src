local VehicleMTLB = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EAvatarSlotType = import("EAvatarSlotType")
local EForceHideState = import("EForceHideState")
local EForceHideStateReason = import("EForceHideStateReason")
function VehicleMTLB:ctor(InSelfType)
  VehicleMTLB.__super.ctor(self, InSelfType)
end
function VehicleMTLB:_PostConstruct()
  VehicleMTLB.__super._PostConstruct(self)
end
function VehicleMTLB:GetUIConfig()
  local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
  return {
    moduleName = "GameLua.Mod.Library.GamePlay.Vehicle.MTLB.MTLBControlUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/MTLB/MTLBControl_UIBP.MTLBControl_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MTLBControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  }
end
function VehicleMTLB:GetVehicleControlUIConfig()
  return {
    CommonUIGroup = {
      "MTLBControlUI"
    },
    DriverUIGroup = {
      "VehicleControlUISpeed"
    },
    VehicleMode = "General",
    ShowLastWeaponUI = true
  }
end
function VehicleMTLB:GetCameraModify()
  local BPCameraTranferClass = "/Game/BluePrints/CamMaster/BP_CameraModifier_TransTo.BP_CameraModifier_TransTo"
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.PlayerCameraManager then
    return
  end
  local uCameraTranferClass = slua.loadClass(BPCameraTranferClass)
  local uSmartCameraModifier = uPlayerController.PlayerCameraManager:FindCameraModifierByClass(uCameraTranferClass)
  return uSmartCameraModifier
end
function VehicleMTLB:HandleSeatChanged(Character, LastSeatType, LastSeatIndex, NewSeatType, NewSeatIndex)
  VehicleMTLB.__super.HandleSeatChanged(self, Character, LastSeatType, LastSeatIndex, NewSeatType, NewSeatIndex)
  if LastSeatIndex == 1 then
    self:SetControlMachineGun(Character, false)
  end
  if NewSeatIndex == 1 then
    self:SetControlMachineGun(Character, true)
  end
end
function VehicleMTLB:HandleSeatAttached(InCharacter, InSeatType, InSeatIndex)
  VehicleMTLB.__super.HandleSeatAttached(self, InCharacter, InSeatType, InSeatIndex)
  if InSeatIndex == 1 then
    self:SetControlMachineGun(InCharacter, true)
  end
end
function VehicleMTLB:HandleSeatDetached(uCharacter, nSeatType, nSeatIdx)
  VehicleMTLB.__super.HandleSeatDetached(self, uCharacter, nSeatType, nSeatIdx)
  if nSeatIdx == 1 then
    self:SetControlMachineGun(uCharacter, false)
  end
end
function VehicleMTLB:SetControlMachineGun(uCharacter, bControl)
  if uCharacter and slua.isValid(uCharacter) and uCharacter:IsAuthority() then
    local uCharacterAvatarComp = uCharacter:getAvatarComponent2()
    if uCharacterAvatarComp and slua.isValid(uCharacterAvatarComp) then
      if bControl then
        uCharacterAvatarComp:SetForceHideState(8, EForceHideState.All, EForceHideStateReason.Server_InTank)
      else
        uCharacterAvatarComp:SetForceHideState(8, EForceHideState.None, EForceHideStateReason.Server_InTank)
      end
      local uWeaponMgrCom = uCharacter:GetWeaponManager()
      if slua.isValid(uWeaponMgrCom) then
        uWeaponMgrCom.ShowMainWeaponModelOnBack = not bControl
      end
    end
  end
end
function VehicleMTLB:SkipModifyPassengerDamage(Damage, EventInstigator, InPassenger)
  if not slua.isValid(self.Object) then
    return true
  end
  if slua.isValid(InPassenger) and InPassenger:GetTemporaryWeapon() then
    return true
  end
  return false
end
local class = require("class")
local CVehicleBase = require("GameLua.GameCore.Module.Vehicle.ALuaVehicleBase")
local CVehicleMTLB = class(CVehicleBase, nil, VehicleMTLB)
return CVehicleMTLB