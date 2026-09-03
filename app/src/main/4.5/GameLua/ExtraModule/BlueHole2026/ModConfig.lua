local ModConfig = {
  Export = {
    Name = "BlueHole2026",
    AutoExportAllConfig = true,
    Inject = {
      BlueHoleVersionOnly = true,
      Mod = {"GodTrial"},
      ModeID = {
        {1, 99999999}
      }
    },
    LuaFeature = {
      GameState = {
        {
          GameStateBHFAFeature = "GameLua.ExtraModule.BlueHole2026.Gameplay.Feature.GameStateBHFAFeature"
        }
      },
      PlayerCharacter = {
        {
          PlayerCharacterBHFAFeature = "GameLua.ExtraModule.BlueHole2026.Gameplay.Feature.PlayerCharacterBHFAFeature"
        }
      }
    }
  }
}
return ModConfig