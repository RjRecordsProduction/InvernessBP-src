local SpecialReplacementRule = {
  [108035] = {
    [108001] = false,
    [108002] = false,
    [108003] = false,
    [108004] = false,
    [108005] = false,
    [108033] = false
  }
}
local CommonReplacementRule = {
  [108035] = false
}
local MeleeWeaponItemHandle = {}
function MeleeWeaponItemHandle:ShouldDropInDisuse(BackpackComponent, CurrentPickupItemDefineID, ThisItemDefineID, KeptCount, Reason)
  if not slua.isValid(BackpackComponent) then
    return true
  end
  if KeptCount <= 0 then
    return true
  end
  if not BackpackComponent:CanDisuseToBackpack(ThisItemDefineID) then
    return true
  end
  local PickupTypeSpecificID = CurrentPickupItemDefineID.TypeSpecificID
  local ThisTypeSpecificID = ThisItemDefineID.TypeSpecificID
  local SpecialRule = SpecialReplacementRule[PickupTypeSpecificID]
  if SpecialRule and SpecialRule[ThisTypeSpecificID] ~= nil then
    return SpecialRule[ThisTypeSpecificID]
  end
  if CommonReplacementRule[ThisTypeSpecificID] ~= nil then
    return CommonReplacementRule[ThisTypeSpecificID]
  end
  return true
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
return class(CObjectBase, nil, MeleeWeaponItemHandle)