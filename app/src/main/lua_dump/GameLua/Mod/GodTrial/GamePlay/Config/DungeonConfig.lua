local EPawnState = import("EPawnState")
local DungeonConfig = {
  Default = {
    Instance = {
      Type = "Level",
      LevelName = "Baltic_GodTrial_Arena_DSForceLoad",
      ActorAssetPath = "/Game/Mod/GodTrial/BluePrints/Actor/Dungeon/BP_GodTrialDungeon.BP_GodTrialDungeon",
      SelectMethod = {
        Type = "MaxTeamOneDungeon",
        MaxNum = 3
      },
      AutoDestroyIfNoPlayers = false,
      Timeout = {
        Duration = -1,
        TipsId = 4200037,
        ShowRestTime = {},
        CloseDungeonTimeFromFighting = 1500,
        KickPlayerTime = 810
      },
      NavData = {
        LevelName = "ArenaDungeon",
        EnableNav = true,
        AgentNavDataPaths = {
          {
            AgentName = "Mannequin",
            NavDataPath = "Mod/GodTrial/NAV/GodTrial_DynamicSetting_GodTrial.navmesh"
          },
          {
            AgentName = "Giant",
            NavDataPath = "Mod/GodTrial/NAV/GodTrial_DynamicSetting_Giant_GodTrial.navmesh"
          },
          {
            AgentName = "Medium",
            NavDataPath = "Mod/GodTrial/NAV/GodTrial_DynamicSetting_Medium_GodTrial.navmesh"
          }
        },
        OriginLoc = FVector(0, 0, 90000),
        bBoxShape = true,
        BoxExtent = FVector(50000, 50000, 20000),
        SphereRadius = 0
      }
    },
    TeleportConfigId = 440002,
    PlayerSlideSkillID = 4400010,
    Character = {
      SkipDrowning = true,
      HidePet = true,
      SkipCirclePain = true,
      NotAffectKDA = false,
      NotLeaveWhenGameFinished = true,
      TeamInvite = {
        bEnabled = false,
        InviteDuration = 10.0,
        PromptTextIds = {
          Content = 4201185,
          Reject = 110035,
          Accept = 110036
        },
        CountdownTime = {Left = 5, Right = 5}
      },
      Forbid = {
        Skill = {
          Ids = {
            1013707,
            1013709,
            1013711,
            1013464,
            4401001,
            4401002,
            4401003,
            4401004,
            4401005,
            4401006
          },
          TagIds = {403}
        },
        SandTablePawnStates = {
          EPawnState.HoldGrenade,
          EPawnState.GunFire,
          EPawnState.MeleeAttack,
          EPawnState.SwitchWeapon,
          EPawnState.Prone
        },
        SandTableDisableSkillIDs = {
          4201001,
          4202006,
          4200015,
          4203001
        }
      },
      EnterCareBuff = {
        RemoveBuffIDs = {80007}
      }
    }
  },
  ParkourTrial = {
    Instance = {
      MaxNum = {
        Baltic = 12,
        Livik = 6,
        Savage = 5
      },
      SelectMethod = {
        Type = "OneTeamOneDungeon"
      },
      ActorAssetPath = "/Game/Mod/GodTrial/BluePrints/Actor/Trial/Parkour/BP_PKTrialManager.BP_PKTrialManager",
      Timeout = {Duration = 70},
      Location = {
        BaseOffset = 30000,
        BaseHeight = 50000,
        GetLocation2D = function(Config)
          local X = 20000 + Config.GlobalIndex * Config.BaseOffset
          local Y = 20000 + Config.GlobalIndex * Config.BaseOffset
          return X, Y
        end
      },
      AutoDestroyIfNoPlayers = true
    },
    TeleportConfigId = 440001,
    Character = {
      SkipCirclePain = true,
      Invincible = true,
      ResetHealthOnExit = false,
      Forbid = {
        PawnStates = {
          EPawnState.Build
        },
        Skill = {
          Ids = {
            4401001,
            4401002,
            4401003
          }
        },
        Flaregun = true
      },
      TeamInvite = {bEnabled = false}
    }
  }
}
local TableUtil = require("common.table_util")
local BaseDungeonConfig = TableUtil.CopyTable(require("GameLua.Mod.BaseMod.GamePlay.Config.DungeonConfig"))
return TableUtil.MergeTable(BaseDungeonConfig, DungeonConfig)