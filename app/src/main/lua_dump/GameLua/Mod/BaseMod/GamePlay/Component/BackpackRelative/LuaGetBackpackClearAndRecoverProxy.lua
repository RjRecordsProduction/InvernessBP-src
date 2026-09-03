local ModClass = function()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local FinalPath = GamePlayTools.LuaGetModPath("GamePlay.Component.BackpackRelative.BackpackClearAndRecoverProxy")
  return require(FinalPath)
end
return ModClass