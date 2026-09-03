local GetModPath = function()
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType = GameMainConfig.GetModType()
  local ModPath = string.format("GameLua.Mod.%s.Client.Backpack.PickUpItemNewBP", ModType)
  local DefaultPath = "GameLua.Mod.BaseMod.Client.Backpack.PickUpItemNewBP"
  local FinalPath = GamePlayTools.LuaFileExits(ModPath) and ModPath or DefaultPath
  return require(FinalPath)
end
return GetModPath