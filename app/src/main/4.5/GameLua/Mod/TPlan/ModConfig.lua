local ModConfig = {
  Import = {
    Livik = {}
  },
  Export = {
    Name = "TPlan",
    AutoExportAllConfig = true,
    Inject = {
      ModeID = {
        64693,
        64680,
        91089,
        64457,
        64940
      }
    }
  },
  Define = {
    ClassNamePath = {
      SpawnSysPlugin_Spawner = "GameLua.Mod.Library.GamePlay.SpawnSystem.SpawnSysPlugin_Spawner"
    },
    LuaFeature = {
      SpawnSysPlugin_Spawner = {
        {
          DynamicAIInfo = "GameLua.Mod.TPlanE.GamePlay.Feature.DynamicAIInfoFeature"
        }
      }
    }
  }
}
return ModConfig