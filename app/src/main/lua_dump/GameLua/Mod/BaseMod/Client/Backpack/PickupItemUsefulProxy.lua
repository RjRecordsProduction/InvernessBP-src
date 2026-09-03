local NeedCompDurabilityIDTable = {
  [501201] = true
}
local PickupItemUsefulProxy = {}
local BackpackUtils = import("BackpackUtils")
local math_max = math.max
function PickupItemUsefulProxy:ctor(selfType)
  PickupItemUsefulProxy.__super.ctor(self, selfType)
end
function PickupItemUsefulProxy:LuaInitialize()
  print(bWriteLog and "PickupItemUsefulProxy:LuaInitialize()")
end
function PickupItemUsefulProxy:LuaDeinitialize()
  print(bWriteLog and "PickupItemUsefulProxy:LuaDeinitialize()")
end
function PickupItemUsefulProxy:LuaCalcItemUseful_Armor_BackSubType(PickUpItemDefineID, BattleItemDefineID, PickUpItemWeightforOrder, BackItemWeightforOrder, PickUpDurability, BackpackDurability)
  print(bWriteLog and "PickupItemUsefulProxy:LuaCalcItemUseful_Armor_BackSubType()")
  local PickUpItemID = PickUpItemDefineID.TypeSpecificID
  local BattleItemID = BattleItemDefineID.TypeSpecificID
  if NeedCompDurabilityIDTable[PickUpItemID] and NeedCompDurabilityIDTable[BattleItemID] then
    return BackpackDurability < PickUpDurability and 1 or 0
  elseif (NeedCompDurabilityIDTable[PickUpItemID] or NeedCompDurabilityIDTable[BattleItemID]) and PickUpItemWeightforOrder == BackItemWeightforOrder then
    return BackpackDurability < PickUpDurability and 1 or 0
  end
  return BackItemWeightforOrder < PickUpItemWeightforOrder and 1 or 0
end
function PickupItemUsefulProxy:LuaCalcItemUseful_Melee(WeaponComp, BackpackComp, SpecificID)
  local AutoPickMeleeID = BackpackUtils.GetBPUtils().AutoPickMeleeID
  if (SpecificID == AutoPickMeleeID or SpecificID == 108033) and not BackpackComp:HasItemBySpecificID(AutoPickMeleeID) and not BackpackComp:HasItemBySpecificID(108033) then
    return 1
  end
  return 0
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CPickupItemUsefulProxy = class(CDelegateContainer, nil, PickupItemUsefulProxy)
return CPickupItemUsefulProxy