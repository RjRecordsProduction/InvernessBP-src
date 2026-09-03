local DeathPlayback = {}
function DeathPlayback:ctor()
  print(bWriteLog and "DeathPlayback:ctor")
end
function DeathPlayback:StopPlay()
  print(bWriteLog and "DeathPlayback:StopPlay", self.DeathPlayCameraShot)
  if slua.isValid(self.DeathPlayCameraShot) then
    self.DeathPlayCameraShot:K2_DestroyActor()
  end
  self.DeathPlayCameraShot = nil
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.GamePlay.GameReplays.GameReplay")
return class(base, nil, DeathPlayback)