local SwitchWeaponAuxLib = {}
function SwitchWeaponAuxLib.SwitchWeaponBySlot(PlayerCharacter, Slot, bUseAnimation, bForceFinishPreviousSwitch, ignoreState)
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchWeaponAuxLib.SwitchWeaponBySlot PlayerCharacter is not Valid")
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.BP_VehicleUser then
    print(bWriteLog and "SwitchWeaponAuxLib.SwitchWeaponBySlot cont find PC or BP_VehicleUser")
    return
  end
  local SeatType = PlayerController.BP_VehicleUser.SeatType
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  local GameplayActorData = require("GameLua.GameCore.Data.GameplayActorData")
  local CurrentVehicle = GameplayActorData.GetCurrentVehicle()
  if SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat and slua.isValid(CurrentVehicle) and CurrentVehicle.bNeedWeaponSlot and slua.isValid(CurrentVehicle.ShootDriverComponent) then
    CurrentVehicle.ShootDriverComponent:UseWeaponOnDriverSeat(PlayerCharacter, Slot)
    return
  end
  PlayerCharacter:SwitchWeaponBySlot(Slot, bUseAnimation, bForceFinishPreviousSwitch, ignoreState)
end
function SwitchWeaponAuxLib.UseGrenadebyRing(PlayerCharacter, ItemID)
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchWeaponAuxLib.UseGrenadebyRing PlayerCharacter is not Valid")
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.BP_VehicleUser then
    print(bWriteLog and "SwitchWeaponAuxLib.UseGrenadebyRing cont find PC or BP_VehicleUser")
    return
  end
  local SeatType = PlayerController.BP_VehicleUser.SeatType
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  local GameplayActorData = require("GameLua.GameCore.Data.GameplayActorData")
  local CurrentVehicle = GameplayActorData.GetCurrentVehicle()
  if SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat and slua.isValid(CurrentVehicle) and CurrentVehicle.bNeedWeaponSlot and slua.isValid(CurrentVehicle.ShootDriverComponent) then
    CurrentVehicle.ShootDriverComponent:UseGrenadeOnDriverSeat(PlayerCharacter, ItemID)
    return
  end
  PlayerCharacter:SpawnAndSwithToGrenadeServerCall(ItemID)
end
function SwitchWeaponAuxLib.ServerUseItem(PlayerController, PlayerCharacter, DefineID, Target, Reason)
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "SwitchWeaponAuxLib.ServerUseItem PlayerCharacter is not Valid")
    return
  end
  if not slua.isValid(PlayerController) or not PlayerController.BP_VehicleUser then
    print(bWriteLog and "SwitchWeaponAuxLib.ServerUseItem cont find PC or BP_VehicleUser")
    return
  end
  local SeatType = PlayerController.BP_VehicleUser.SeatType
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  local GameplayActorData = require("GameLua.GameCore.Data.GameplayActorData")
  local CurrentVehicle = GameplayActorData.GetCurrentVehicle()
  if SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat and slua.isValid(CurrentVehicle) and CurrentVehicle.bNeedWeaponSlot and slua.isValid(CurrentVehicle.ShootDriverComponent) then
    CurrentVehicle.ShootDriverComponent:UseMeleeOnDriverSeat(PlayerCharacter, DefineID, Target, Reason)
    return
  end
  PlayerController:ServerUseItem(DefineID, Target, Reason)
end
return SwitchWeaponAuxLib