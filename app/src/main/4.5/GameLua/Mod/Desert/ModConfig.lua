local ModConfig = {
  Import = {
    LootTruck = {
      LuaFeature = {
        GameState = "BRGameStateBase"
      }
    }
  },
  Export = {
    Name = "Desert",
    AutoExportAllConfig = true,
    Inject = {
      ModeID = {
        {64445, 64456},
        {64409, 64420},
        {65080, 65091}
      }
    }
  },
  Define = {
    ClassNamePath = {
      BRPlayerCharacterBase = "GameLua.Mod.BRMod.Gameplay.Core.BRPlayerCharacterBase",
      BRGameStateBase = "GameLua.Mod.BRMod.Gameplay.Core.BRGameStateBase",
      BRPlayerStateBase = "GameLua.Mod.BRMod.Gameplay.Core.BRPlayerStateBase",
      PetSpectatorCharacterBase = "GameLua.Mod.BaseMod.GamePlay.Actor.Pet.PetSpectatorCharacterBase"
    },
    LuaFeature = {
      BRPlayerCharacterBase = {
        {
          SandStormEffectFeature = "GameLua.Mod.Desert.Gameplay.Feature.SandStormEffectFeature"
        }
      },
      BRGameStateBase = {
        {
          SandStormMgrFeature = "GameLua.Mod.Desert.Gameplay.Feature.SandStormMgrFeature"
        },
        {
          SellStoreFeature = "GameLua.Mod.Desert.Gameplay.Feature.GameStateSellStoreFeatureBase"
        }
      },
      BRPlayerStateBase = {
        {
          SellStoreFeature = "GameLua.Mod.Desert.GamePlay.Feature.PlayerStateSellStoreFeatureBase"
        }
      },
      PetSpectatorCharacterBase = {
        {
          SandStormEffectFeature = "GameLua.Mod.Desert.Gameplay.Feature.SandStormEffectFeature"
        }
      }
    }
  }
}
return ModConfig