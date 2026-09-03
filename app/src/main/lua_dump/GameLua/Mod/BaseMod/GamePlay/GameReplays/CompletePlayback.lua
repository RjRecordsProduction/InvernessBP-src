local CompletePlayback = {}
function CompletePlayback:ctor()
  print(bWriteLog and "CompletePlayback:ctor")
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.GamePlay.GameReplays.GameReplay")
return class(base, nil, CompletePlayback)