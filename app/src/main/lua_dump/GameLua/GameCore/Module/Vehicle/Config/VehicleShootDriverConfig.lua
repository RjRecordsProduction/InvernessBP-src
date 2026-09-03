local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local EVHSeatWeaponHoldType = import("EVHSeatWeaponHoldType")
local EVHSeatSpecialType = import("EVHSeatSpecialType")
local UScriptGameplayStatics = import("ScriptGameplayStatics")
local VehicleShootDriverConfig = {}
VehicleShootDriverConfig.CommonWeaponBlackList = {106011}
VehicleShootDriverConfig.ConfigMap = {
  [ESTExtraVehicleShapeType.VST_Motorbike] = {
    AnimBpIndex = 1,
    AnimCompTagName = "ShootDriver",
    HoldWeaponType = EVHSeatWeaponHoldType.ESeatWeapon_ShortOnly,
    CanUseMeleeWeapon = false,
    CanUseGrenadeWeapon = true,
    WeaponBlackList = {106011},
    WeaponUnsupportTipsID = 86461
  },
  [ESTExtraVehicleShapeType.VST_Motorbike_SideCart] = {
    AnimBpIndex = 1,
    AnimCompTagName = "ShootDriver",
    HoldWeaponType = EVHSeatWeaponHoldType.ESeatWeapon_ShortOnly,
    CanUseMeleeWeapon = false,
    CanUseGrenadeWeapon = true,
    WeaponUnsupportTipsID = 86461
  },
  [ESTExtraVehicleShapeType.VST_Scooter] = {
    AnimBpIndex = 2,
    AnimCompTagName = "ShootDriver",
    HoldWeaponType = EVHSeatWeaponHoldType.ESeatWeapon_ShortOnly,
    CanUseMeleeWeapon = false,
    CanUseGrenadeWeapon = true,
    WeaponUnsupportTipsID = 86461
  },
  [ESTExtraVehicleShapeType.VST_Bike] = {
    AnimBpIndex = 1,
    AnimCompTagName = "ShootDriver",
    HoldWeaponType = EVHSeatWeaponHoldType.ESeatWeapon_ShortOnly,
    CanUseMeleeWeapon = false,
    CanUseGrenadeWeapon = true,
    WeaponUnsupportTipsID = 86461
  },
  [ESTExtraVehicleShapeType.VST_Bike_WithRack] = {
    AnimBpIndex = 2,
    AnimCompTagName = "ShootDriver",
    HoldWeaponType = EVHSeatWeaponHoldType.ESeatWeapon_ShortOnly,
    CanUseMeleeWeapon = false,
    CanUseGrenadeWeapon = true,
    WeaponUnsupportTipsID = 86461
  }
}
function VehicleShootDriverConfig.GetCfg(uVehicle)
  local VehicleShapeType = slua.isValid(uVehicle) and uVehicle.VehicleShapeType
  if VehicleShootDriverConfig.ConfigMap and VehicleShapeType then
    return VehicleShootDriverConfig.ConfigMap[VehicleShapeType]
  end
end
return VehicleShootDriverConfig