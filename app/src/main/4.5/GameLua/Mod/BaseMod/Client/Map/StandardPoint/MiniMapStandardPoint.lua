local MiniMapStandardPoint = {}
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
function MiniMapStandardPoint:ReceiveBeginPlay()
  MiniMapStandardPoint.__super.ReceiveBeginPlay(self)
  local MapType = GameMainConfig.GetMapType()
  local ModType = GameMainConfig.GetModType()
  if MapType == "Livik" and ModType == "Sink2" then
    self:K2_SetActorLocation(FVector(200200, 199900, 0), false, nil, false)
    self.LevelBoundExtent = 242000.0
  end
  self.Super:ReceiveBeginPlay()
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
return class(CActorBase, nil, MiniMapStandardPoint)