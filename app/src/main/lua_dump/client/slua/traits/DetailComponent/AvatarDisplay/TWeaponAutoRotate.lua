local TWeaponAutoRotate = {}
local Trait = require("common.trait")
local TTWeaponAutoRotate = Trait(Trait.TraitPrototype, nil, TWeaponAutoRotate)
function TWeaponAutoRotate:SetWeaponAutoRotate()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if ModelDisplayer.GetShowingStatus() == ModelDisplayer.Enum_Status.Model then
    local WeaponModelLogic = require("client.slua.logic.manager.WeaponModelLogic")
    local curActor = WeaponModelLogic.GetProperWeaponShowActor()
    if slua.isValid(curActor) then
      local ConstView = require("client.slua.traits.DetailComponent.ViewComponent.ConstView")
      curActor:SetAutoRotate(true)
      curActor:SetAutoRotateSpeed(ConstView.C_WEAPON_AUTO_ROTATE_SPEED)
    end
  end
end
return TTWeaponAutoRotate