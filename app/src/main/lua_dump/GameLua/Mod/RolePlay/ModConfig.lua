local ModConfig = {
  Export = {
    Name = "RolePlay",
    Inject = {
      ModeID = {
        {60112, 60117},
        {90010, 90015}
      }
    },
    LuaFeature = {
      PlayerState = {
        {
          HeroPropFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.PlayerStateHeroPropFeature"
        },
        {
          SkillPropFeature = "GameLua.Mod.RolePlay.Gameplay.Feature.PlayerStateSkillPropFeature"
        },
        {
          SkillCDRepFeature = "GameLua.Mod.Library.GamePlay.Skill.Feature.PlayerStateSkillCDRepFeature"
        }
      },
      GameState = {
        {
          SkillPropFeature = "GameLua.Mod.RolePlay.Gameplay.Feature.GameStateSkillPropFeature"
        },
        {
          ClientOptimizationFeature = "GameLua.Mod.RolePlay.Gameplay.Feature.ClientOptimizationFeature"
        }
      },
      PlayerController = {},
      PlayerCharacter = {
        {
          SkillPropFeature = "GameLua.Mod.RolePlay.Gameplay.Feature.PlayerCharacterSkillPropFeature"
        }
      }
    },
    Dev = {
      "GMConfig",
      "GMFuncConfig"
    },
    Client = {
      "CircleChooseCfg",
      "NewbieGuideConfig",
      "NewMapMarkConfig",
      "ScreenMarkConfig",
      "UIConfig",
      "SettingUIElemLayoutConfig"
    },
    DS = {},
    GamePlay = {
      "EventDefine",
      "SubsystemConfig"
    }
  }
}
return ModConfig