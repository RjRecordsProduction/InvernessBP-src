local ModClass = function()
  if Client then
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local FinalPath = GamePlayTools.LuaGetModPath("Client.AvatarCapture.AvatarCaptureActor")
    return require(FinalPath)
  else
    return require("GameLua.Mod.BaseMod.Client.AvatarCapture.AvatarCaptureActor")
  end
end
return ModClass