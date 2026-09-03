local WeaponLibrary = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function WeaponLibrary.IsScriptWeapon(WeaponId)
  print(bWriteLog and "WeaponLibrary.IsScriptWeapon", WeaponId)
  if WeaponId then
    local WeaponConfigTable = GamePlayTools.GetCurrentConfig("WeaponConfig")
    local TableUtil = require("common.table_util")
    return TableUtil.GetTableValue(WeaponConfigTable, WeaponId)
  end
end
function WeaponLibrary.SetValueToAttributeSafety(Weapon, AttributeName, Value)
  if not slua.isValid(Weapon) then
    return
  end
  Weapon.AttrModifierCompoment:LuaSetValueToAttributeSafety(AttributeName, Value)
end
function WeaponLibrary.GetWeaponConfig(WeaponId)
  local WeaponConfigTable = GamePlayTools.GetCurrentConfig("WeaponConfig")
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(WeaponConfigTable, WeaponId)
end
return WeaponLibrary