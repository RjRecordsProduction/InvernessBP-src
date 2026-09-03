local ModConfig = {
  Export = {
    Name = "LootTruck",
    AutoExportAllConfig = true,
    LuaFeature = {
      GameState = {
        {
          LootTruckGarageFeature = "GameLua.ExtraModule.LootTruck.GamePlay.Feature.LootTruckGarageFeature"
        }
      }
    }
  }
}
ModConfig.Export.Inject = {
  ExcludeModeID = {
    {1022, 1063},
    {1070, 1072},
    {1094, 1096},
    {1122, 1136}
  },
  ExcludeMod = {
    "TPlan",
    "TDM",
    "HeavyWeapon",
    "SlayTheBot",
    "Sink",
    "Sink2",
    "CreativeBase",
    "ZNQ6th",
    "Egypt2",
    "Dinosaur"
  },
  Map = {
    "Baltic",
    "Livik",
    "Savage",
    "Desert"
  }
}
return ModConfig