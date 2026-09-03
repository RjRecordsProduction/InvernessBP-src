local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local ModConfig = {
  Export = {
    Name = "Halloween4Hero",
    Client = {
      "UIConfig",
      "CircleChooseCfg"
    },
    GamePlay = {
      "HeroSpecialConfig",
      "SpecialMoveConfig",
      "SubsystemConfig",
      "SkillConfig"
    }
  }
}
ModConfig.Export.Inject = {
  IsUGCMode = true,
  Mod = {
    "Halloween4",
    "CreativeBase",
    "TDCard"
  }
}
return ModConfig