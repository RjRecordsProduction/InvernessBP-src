local ObservingReplay = {}
function ObservingReplay:ctor()
  print(bWriteLog and "ObservingReplay:ctor")
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.GamePlay.GameReplays.GameReplay")
return class(base, nil, ObservingReplay)