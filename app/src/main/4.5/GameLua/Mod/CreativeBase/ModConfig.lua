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
      VehicleBase = "GameLua.GameCore.Module.Vehicle.ALuaVehicleBase",
      PositiveBubble = "GameLua.Mod.Atlantis.Gameplay.Actor.PositiveBubble",
      DetectCircleActor = "GameLua.Mod.Library.GamePlay.Actor.DetectCircleActor",
      SkillManagerComponent = "GameLua.Mod.CreativeBase.Gameplay.Component.Skill.CreativeSkillManagerComponent",
      AIMobSkillComponent = "GameLua.GameCore.Module.AI.Component.AIMobSkillComponent",
      IceWorld3BuildDestructibleActorBase = "GameLua.Mod.IceWorld3.Gameplay.Actor.BuildDestructibleActorBase",
      BuildDestructibleActorBase = "GameLua.ExtraModule.SkillCore.Gameplay.BuildDestructible.Actor.BuildDestructibleActorBase"
    },
    LuaFeature = {
      NormalStore = {
        {
          StoreFeature = "GameLua.Mod.CreativeBase.Gameplay.Store.CreativeModeStoreActorFeature"
        }
      },
      AIMobBase = {
        {
          CreativePawnDropItemFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.CreativePawnDropItemFeature"
        },
        {
          UGCLevelFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.UGCLevelFeature"
        },
        {
          CreativeMobAnimFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.CreativeMobAnimFeature"
        },
        {
          UGCAISkillFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.UGCAISkillFeature"
        }
      },
      AIModBaseCharacter = {
        {
          CreativePawnDropItemFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.CreativePawnDropItemFeature"
        },
        {
          UGCLevelFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.UGCLevelFeature"
        },
        {
          UGCCharacterAnimFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.UGCCharacterAnimFeature"
        },
        {
          UGCAISkillFeature = "GameLua.Mod.CreativeBase.Gameplay.Module.AI.Feature.UGCAISkillFeature"
        }
      },
      VehicleBase = {
        {
          CreativeVehicleCollisionFeature = "GameLua.Mod.CreativeBase.Gameplay.Feature.CreativeVehicleCollisionFeature"
        }
      },
      PositiveBubble = {
        {
          SkillSpawnActorFeature = "GameLua.Mod.CreativeBase.Gameplay.Skill.SkillSpawnActorFeature"
        }
      },
      DetectCircleActor = {
        {
          SkillSpawnActorFeature = "GameLua.Mod.CreativeBase.Gameplay.Skill.SkillSpawnActorFeature"
        }
      },
      SkillManagerComponent = {
        {
          CreativeSkillCompFeature = "GameLua.Mod.CreativeBase.Gameplay.Skill.Feature.CreativeSkillCompFeature"
        }
      },
      AIMobSkillComponent = {
        {
          CreativeSkillCompFeature = "GameLua.Mod.CreativeBase.Gameplay.Skill.Feature.CreativeSkillCompFeature"
        }
      },
      IceWorld3BuildDestructibleActorBase = {
        {
          SkillSpawnActorFeature = "GameLua.Mod.CreativeBase.Gameplay.Skill.SkillSpawnActorFeature"
        }
      },
      BuildDestructibleActorBase = {
        {
          CreativeSkillCompFeature = "GameLua.Mod.CreativeBase.Gameplay.Skill.Feature.CreativeSkillCompFeature"
        }
      }
    }
  }
}
ModConfig.Export.Inject = {
  ModeID = {
    600092,
    600093,
    600094,
    600095
  }
}
return ModConfig