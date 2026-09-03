local FeatureAccelerateEffect = {}
local Trait = require("common.trait")
local TFeatureAccelerateEffect = Trait(Trait.TraitPrototype, nil, FeatureAccelerateEffect)
function FeatureAccelerateEffect:PlayAccelerateEffect(data)
  log(bWriteLog and "StoreDetail PlayAccelerateEffect")
  local animInstance = self:GetVehicleAnimIns()
  self:NotifyOtherFeatureStop(data)
  EventSystem:postEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_PLAYACC_EFFECT, true)
  if animInstance and animInstance.PlayAccelerateEffect then
    animInstance:PlayAccelerateEffect()
  else
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
    if not slua.isValid(actor) or not actor:GetVehicleActor() then
      return
    end
    local vehicle = actor:GetVehicleActor()
    if not slua.isValid(vehicle) then
      return
    end
    if vehicle.PlayAccelerateEffect then
      vehicle:PlayAccelerateEffect()
    end
  end
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.ChangeCameraRotation(FRotator(-20, 0, 0))
end
function FeatureAccelerateEffect:StopAccelerateEffect()
  log(bWriteLog and "StoreDetail StopAccelerateEffect ")
  local animInstance = self:GetVehicleAnimIns()
  if not animInstance then
    log_error("StoreDetail StopAccelerateEffect vehicle not have animInstance")
    return
  end
  if animInstance.StopAccelerateEffect then
    animInstance:StopAccelerateEffect()
  else
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    local actor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
    if not slua.isValid(actor) or not actor:GetVehicleActor() then
      return
    end
    local vehicle = actor:GetVehicleActor()
    if not slua.isValid(vehicle) then
      return
    end
    if vehicle.StopAccelerateEffect then
      vehicle:StopAccelerateEffect()
    end
  end
end
return TFeatureAccelerateEffect