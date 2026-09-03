local NGConditionHasWeaponInBackpack = {}
function NGConditionHasWeaponInBackpack:ctor(selfType, Params)
end
function NGConditionHasWeaponInBackpack:CheckConditionOK(...)
  log(bWriteLog and "Debug NewbieGuide: NGConditionHasWeaponInBackpack CheckConditionOK")
  local bSuperOk = NGConditionHasWeaponInBackpack.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not slua.isValid(uPlayerController.BackpackComponent) then
    return false
  end
  local UBackpackUtils = import("BackpackUtils")
  local WeaponsInBackpack = UBackpackUtils.GetWeaponsInBackpack(uPlayerController.BackpackComponent)
  if WeaponsInBackpack:Num() > 0 then
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionHasWeaponInBackpack = class(CObject, nil, NGConditionHasWeaponInBackpack)
return CNGConditionHasWeaponInBackpack