local ClientInGameReplay = {}
function ClientInGameReplay:ctor()
  print(bWriteLog and "ClientInGameReplay:ctor")
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.GamePlay.GameReplays.GameReplay")
return class(base, nil, ClientInGameReplay)