local GodTrialConfig = {
  ArenaLightClass = "/Game/Mod/GodTrial/BluePrints/Actor/Dungeon/SummonLightActor.SummonLightActor",
  FakeIslandClass = "/Game/Mod/GodTrial/BluePrints/Actor/Dungeon/BP_FakeIsland.BP_FakeIsland",
  ArenaGoldenCoinClass = "/Game/Mod/GodTrial/BluePrints/Actor/Dungeon/BP_ArenaGoldenCoin.BP_ArenaGoldenCoin",
  ArenaNotEnoughCoinTipID = 4401001,
  ArenaHasTeleportTipID = 4401002,
  BossPerformanceSeqTime = 13,
  TheDescendedSeq = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/Sequence/TheTempleDescended.TheTempleDescended",
  SequenceActorPath = "/Game/Mod/GodTrial/Arts_PlayerBluePrints/Sequence/TheTempleDescendedSeqActor.TheTempleDescendedSeqActor_C",
  TheDescendedSeqTime = 15,
  DelayTimeWhenBossDie = 4,
  DUNGEON_LEVEL_PATHS = {
    "/Game/Mod/GodTrial/Maps/DynamicLevels/Baltic_Dynamic_GodTrial_Island",
    "/Game/Mod/GodTrial/Maps/DynamicLevels/Baltic_BigPOI_Dynamic_GodTrial_DSForceLoad"
  },
  EHonorTypeToTlogIDMap = {
    [0] = 2133,
    [1] = 2129,
    [2] = 2130,
    [3] = 2132,
    [4] = 2131,
    [5] = 2151,
    [7] = 2134,
    [8] = 2149,
    [9] = 2150,
    [10] = 2135
  },
  EHonorTypeToTlogIDMap2 = {
    [0] = 2211,
    [1] = 2207,
    [2] = 2208,
    [3] = 2210,
    [4] = 2209,
    [5] = 2219,
    [7] = 2212,
    [8] = 2213,
    [9] = 2218
  },
  ArenaLightHighAltitudeThreshold = 500,
  DefaultMapConfig = {
    ArenaBeginTeleportTime = 600,
    ArenaBeginTeleportTipTime = {
      60,
      30,
      10
    },
    ArenaBeginTeleportTipID = 4401003,
    ArenaMinimumScore = {
      [1] = 50,
      [2] = 50,
      [4] = 50
    },
    ArenaChoosenTeamNum = {
      [1] = 4,
      [2] = 4,
      [4] = 4
    },
    ArenaMinimumDistance = 2000,
    ArenaLightLastingTime = 30,
    ArenaLightOffsetMixDistance = 100,
    ArenaLightOffsetMaxDistance = 100,
    ArenaLightRandomHalfAngle = 30,
    ArenaCircleIndex = 1,
    ArenaInitialHeight = 190000,
    ArenaFinalHeight = 90000,
    ArenaBeginDescendTime = 580,
    RealIslandGenerateTime = 15,
    FakeIslandOffset = FVector(0, 0, 0),
    ArenaCoinNum = 12,
    ArenaOpenNeedCoinNum = 5,
    FlameChariotActiveWaitTime = 0.1,
    FlameChariotInviteTipID = {
      Content = 4401011,
      Reject = 110035,
      Accept = 110036
    },
    FlameChariotRunTime = 20,
    BossRoomCloseTime = 180,
    FakeIslandMoveTime = 60,
    BossRoomCloseTimeAfterBossDead = 60,
    HonorScoreKill = 10,
    HonorScoreAssist = 5,
    HonorScoreRescue = 3,
    HonorScoreRevive = 8,
    HonorScoreKillBoss = 100,
    AvoidPOIRadius = 30000
  },
  HonorMapConfig = {
    Livik = {
      ArenaBeginTeleportTime = 420,
      ArenaChoosenTeamNum = {
        [1] = 1,
        [2] = 1,
        [4] = 1
      },
      ArenaBeginDescendTime = 400,
      SkipArenaStage = true
    }
  }
}
function GodTrialConfig.GetMapConfig(MapType)
  local Override = GodTrialConfig.HonorMapConfig[MapType]
  local Default = GodTrialConfig.DefaultMapConfig
  if not Override then
    return Default
  end
  return setmetatable(Override, {__index = Default})
end
return GodTrialConfig