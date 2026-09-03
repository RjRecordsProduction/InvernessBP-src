local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local ModConfig = {
  Export = {
    Name = "CreativeBase",
    AutoExportAllConfig = true
  },
  Import = {
    Halloween4Hero = {}
  },
  Define = {
    ClassNamePath = {
      NormalStore = "GameLua.Mod.BaseMod.Actor.Store.NormalStore",
      AIMobBase = "GameLua.GameCore.Module.AI.AIMobBase",
      AIModBaseCharacter = "GameLua.Mod.Library.Gameplay.AI.AIModBaseCharacter",
      VehicleBase = "GameLua.GameCore.Module.Vehicle.ALuaVehicleBase"
    },
    LuaFeature = {
      NormalStore = {
        {
          StoreFeature = "GameLua.Mod.CreativeBase.Gameplay.Store.CreativeModeStoreActorFeature"
        }
      },
      AIMobBase = {
        {
          CreativePawnDropItemFeature = "GameLua.GameCore.Module.AI.Feature.CreativePawnDropItemFeature"
        }
      },
      AIModBaseCharacter = {
        {
          CreativePawnDropItemFeature = "GameLua.GameCore.Module.AI.Feature.CreativePawnDropItemFeature"
        }
      },
      VehicleBase = {
        {
          CreativeVehicleCollisionFeature = "GameLua.Mod.CreativeBase.Gameplay.Feature.CreativeVehicleCollisionFeature"
        }
      }
    }
  }
}
ModConfig.Export.Inject = {
  ModeID = {
    600092,
    600093,
    600094
  }
}
return ModConfig