local ButtonKickPlayerWrap = {}
function ButtonKickPlayerWrap:ctor()
  self.MarginData = {
    Left = -83,
    Top = 265,
    Right = 100,
    Bottom = 30
  }
  self.AnchorsData = {
    MinX = 1,
    MinY = 0,
    MaxX = 1,
    MaxY = 0
  }
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(UIBase, nil, ButtonKickPlayerWrap)