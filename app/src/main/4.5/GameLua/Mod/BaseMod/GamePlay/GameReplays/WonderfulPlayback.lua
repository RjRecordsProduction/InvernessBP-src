local WonderfulPlayback = {}
function WonderfulPlayback:ctor()
  print(bWriteLog and "WonderfulPlayback:ctor")
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.GamePlay.GameReplays.GameReplay")
return class(base, nil, WonderfulPlayback)