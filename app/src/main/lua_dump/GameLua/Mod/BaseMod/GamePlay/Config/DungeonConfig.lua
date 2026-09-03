local EPawnState = import("EPawnState")
local DungeonConfig = {
  Default = {
    Instance = {
      Type = "Blueprint",
      PreloadNum = 0,
      MaxNum = 8,
      ActorAssetPath = "",
      Timeout = {
        Duration = 600,
        TipsId = 0,
        ShowRestTime = {10},
        CloseDungeonTimeFromFighting = -1
      },
      SelectMethod = {
        Type = "MaxTeamOneDungeon",
        MaxNum = 1
      },
      Location = {BaseOffset = 20000, BaseHeight = 100000},
      AutoDestroyIfNoPlayers = true,
      ClearActorClass = {},
      NavData = {
        EnableNav = false,
        LevelName = "ArenaDungeon",
        NavDataPath = "Mod/GodTrial/NAV/GodTrial_DynamicSetting_GodTrial.navmesh",
        OriginLoc = FVector(0, 0, 0),
        bBoxShape = true,
        BoxExtent = FVector(50000, 50000, 20000),
        SphereRadius = 0
      }
    },
    TeleportConfigId = 0,
    SkyTransitionId = 0,
    Character = {
      SkipCirclePain = true,
      SkipDrowning = false,
      BringItemsOnPlane = true,
      ReInitParachuteItem = true,
      NotAffectKDA = true,
      HidePet = false,
      Invincible = false,
      ResetHealthOnExit = true,
      NotLeaveWhenGameFinished = false,
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
      GrantItems = {},
      Forbid = {
        Skill = {
          Ids = {1013707},
          TagIds = {}
        },
        PawnStates = {
          EPawnState.InActivityActor
        },
        Flaregun = true
      },
      EnterCareBuff = {
        AddBuffIDs = {},
        RemoveBuffIDs = {}
      },
      LeaveCareBuff = {
        AddBuffIDs = {},
        RemoveBuffIDs = {}
      }
    }
  }
}
return DungeonConfig