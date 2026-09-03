local VehicleShootDriverComponent = {}
local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
local EVHSeatWeaponHoldType = import("EVHSeatWeaponHoldType")
function VehicleShootDriverComponent:ctor(SelfType)
end
function VehicleShootDriverComponent:ReceiveBeginPlay()
  print(bWriteLog and string.format("VehicleShootDriverComponent:ReceiveBeginPlay %s", tostring(self.Object)))
end
function VehicleShootDriverComponent:ReceiveEndPlay()
  print(bWriteLog and string.format("VehicleShootDriverComponent:ReceiveEndPlay %s", tostring(self.Object)))
  self:Dispose()
end
function VehicleShootDriverComponent:InitShootDriverSeatIndex()
  local uMyVehicle = self:GetOwner()
  local VehicleShootDriverConfig = require("GameLua.GameCore.Module.Vehicle.Config.VehicleShootDriverConfig")
  local ShootDriverCfg = VehicleShootDriverConfig.GetCfg(uMyVehicle)
  print(bWriteLog and string.format("VehicleShootDriverComponent:InitShootDriverSeatIndex %s %s", tostring(self.Object), tostring(ShootDriverCfg)))
  if not ShootDriverCfg then
    self.Super:InitShootDriverSeatIndex()
    return
  end
  local AnimBpIndex = ShootDriverCfg.AnimBpIndex or 1
  local CharacterInVehicleAnimBPs = uMyVehicle.CharacterInVehicleAnimBPs
  local AnimBPsNum = slua.isValid(CharacterInVehicleAnimBPs) and CharacterInVehicleAnimBPs:Num()
  local AnimBP = AnimBpIndex < AnimBPsNum and CharacterInVehicleAnimBPs:Get(AnimBpIndex)
  if AnimBP then
    self.Shoot  else
    print(bWriteLog and string.format("VehicleShootDriverComponent:InitShootDriverSeatIndex fail AnimBPsNum=%s, AnimBpIndex=%s", tostring(AnimBPsNum), tostring(AnimBpIndex)))
  end
  local uMyVehicleSeats = uMyVehicle:GetVehicleSeats()
  local VehicleSeatsNum = slua.isValid(uMyVehicleSeats) and uMyVehicleSeats.Seats and uMyVehicleSeats.Seats:Num() or 0
  local DriverSeat = 0 < VehicleSeatsNum and uMyVehicleSeats.Seats:Get(0)
  if DriverSeat then
    self.ShootDriverSeat.EnterVehicleSocket = DriverSeat.EnterVehicleSocket
    self.ShootDriverSeat.LeaveVehicleSocket = DriverSeat.LeaveVehicleSocket
    self.ShootDriverSeat.SeatSpecialType = DriverSeat.SeatSpecialType
  else
    print(bWriteLog and string.format("VehicleShootDriverComponent:InitShootDriverSeatIndex fail uMyVehicleSeats=%s ", tostring(slua.isValid(uMyVehicleSeats))))
  end
  uMyVehicle.bNeedWeaponSlot = true
  self.bCanUseShootWeapon = true
  self.bCanUseMeleeWeapon = ShootDriverCfg.CanUseMeleeWeapon or false
  self.bCanUseGrenadeWeapon = ShootDriverCfg.CanUseGrenadeWeapon or false
  self.ShootDriverSeat.bUseWeaponIDBlackList = false
  self.bAutoLeanOutAfterSwitch = false
  self.bUseSwitchAnimation = true
  self.ShootDriverSeat.SeatType = ESTExtraVehicleSeatType.ESeatType_ShootDriver
  self.ShootDriverSeat.HoldWeaponType = ShootDriverCfg.HoldWeaponType or EVHSeatWeaponHoldType.ESeatWeapon_RifleOnly
  local SimilarSeat = AnimBpIndex < VehicleSeatsNum and uMyVehicleSeats.Seats:Get(AnimBpIndex)
  local SimilarSeatAnimCompTagName = SimilarSeat and SimilarSeat.AnimCompTagName or ""
  self.ShootDriverSeat.AnimCompTagName = ShootDriverCfg.AnimCompTagName or SimilarSeatAnimCompTagName
  self.ShootDriverSeat.bUseWeaponIDBlackList = true
  local HoldWeaponIDBlackList = self.ShootDriverSeat.HoldWeaponIDBlackList
  local WeaponBlackLists = {
    VehicleShootDriverConfig.CommonWeaponBlackList,
    ShootDriverCfg.WeaponBlackList
  }
  if WeaponBlackLists then
    for _, WeaponBlackList in pairs(WeaponBlackLists) do
      if WeaponBlackList then
        for _, WeaponID in pairs(WeaponBlackList) do
          HoldWeaponIDBlackList:Add(WeaponID)
        end
      end
    end
  end
  self.WeaponUnsupportTipsID = ShootDriverCfg.WeaponUnsupportTipsID or 69985
  self.Super:InitShootDriverSeatIndex()
end
function VehicleShootDriverComponent:CanChangeSeat(Character, LocalSeatIdx, FailedTipsID)
  local uVehicle = self:GetOwner()
  if slua.isValid(uVehicle) and slua.isValid(uVehicle.VehicleNitroBoostComponent) and uVehicle.VehicleNitroBoostComponent:IsNitroBoosting() then
    local uVehicleSeat = uVehicle:GetVehicleSeats()
    local SeatType = uVehicleSeat:GetSeatType(LocalSeatIdx)
    local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
    if SeatType == ESTExtraVehicleSeatType.ESeatType_ShootDriver then
      FailedTipsID = 6350034
      return false, FailedTipsID
    end
  end
  return self.Super:CanChangeSeat(Character, LocalSeatIdx, FailedTipsID)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, VehicleShootDriverComponent)