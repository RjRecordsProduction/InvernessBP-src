local FeatureWildState = {}
local Trait = require("common.trait")
local TFeatureWildState = Trait(Trait.TraitPrototype, nil, FeatureWildState)
function FeatureWildState:PlayWeaponWildState()
  self:SetWeaponWildState(2)
end
function FeatureWildState:StopWeaponWildState()
  self:SetWeaponWildState(1)
end
function FeatureWildState:SetWeaponWildState(State)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local ShowWeapon = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if slua.isValid(ShowWeapon) then
    if ShowWeapon.GetCurSubOperator then
      local CurOperator = ShowWeapon:GetCurSubOperator()
      if CurOperator == nil then
        return
      end
      CurOperator:ChangeWeaponShowState(State)
    elseif ShowWeapon.ChangeWeaponShowState then
      ShowWeapon:ChangeWeaponShowState(State)
    end
  end
  if ModelDisplayer.GetShowingAvatar() and slua.isValid(ModelDisplayer.GetShowingAvatar():GetModel()) then
    local CurWeapon = ModelDisplayer.GetShowingAvatar():GetModel().curEquipingWeapon
    if slua.isValid(CurWeapon) then
      CurWeapon:ChangeWeaponShowState(State)
    end
  end
end
return TFeatureWildState