local ModClass = function()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local ModPath = GamePlayTools.LuaGetModPathDirectly("GamePlay.Weapon.ModWeaponBase")
  if GamePlayTools.LuaFileExits(ModPath) then
    return require(ModPath)
  else
    return require("GameLua.GameCore.Module.Weapon.WeaponBase")
  end
end
return ModClass