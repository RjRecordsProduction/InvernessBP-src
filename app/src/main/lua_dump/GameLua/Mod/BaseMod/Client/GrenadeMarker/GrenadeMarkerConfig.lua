local GrenadeMarkerConfig = {
  GrenadeID2Config = {
    [602004] = {
      LifeTime = 7,
      VisibleRange = 300,
      InvisibleRange = 1110,
      AnimSpeed = 1.0,
      SpeedUpAnimLeftTime = 3.0
    },
    [602111] = {
      LifeTime = 2.9,
      VisibleRange = 725,
      InvisibleRange = 725,
      AnimSpeed = 1.0,
      SpeedUpAnimLeftTime = 0,
      InValidCallback = function()
        local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        if InGameUITools and InGameUITools.IsUGC then
          return InGameUITools.IsUGC()
        end
        return false
      end
    },
    [602113] = {
      LifeTime = 2.9,
      VisibleRange = 500,
      InvisibleRange = 500,
      AnimSpeed = 1.0,
      SpeedUpAnimLeftTime = 0
    },
    [107001] = {
      LifeTime = 2,
      VisibleRange = 550,
      InvisibleRange = 550,
      AnimSpeed = 0.6,
      SpeedUpAnimLeftTime = 2,
      BlockTest = true
    }
  }
}
return GrenadeMarkerConfig