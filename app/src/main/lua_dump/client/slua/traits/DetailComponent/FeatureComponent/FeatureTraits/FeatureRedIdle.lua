local FeatureRedIdle = {}
local Trait = require("common.trait")
local TFeatureRedIdle = Trait(Trait.TraitPrototype, nil, FeatureRedIdle)
function FeatureRedIdle:UnEquipeWeapon()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local avatar = ModelDisplayer.GetShowingAvatar()
  if avatar then
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    avatar:PutoffSubtype(wardrobe_macro.Enum_ItemMainType.Enum_ItemMainType_Weapon)
  end
end
return TFeatureRedIdle