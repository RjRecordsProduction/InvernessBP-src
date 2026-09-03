local EWeaponTypeNew = import("EWeaponTypeNew")
local TableUtil = require("common.table_util")
local HighlightMomentConfig_Vehicle = require("GameLua.Mod.BaseMod.GamePlay.Config.HighlightMomentConfig_Vehicle")
local HighlightMomentConfig = {
  bShowDebug = false,
  [1] = {
    HighlightName = "RapidKillStreak",
    SmartCameraID = 30006,
    EmoteID = 12220100,
    DamageType = -1,
    DamageItemID = -1,
    CloseTime = 9.5,
    SeqEventMsg = "RapidKillStreakMsg",
    MinKillNum = 4,
    Timeout = 20,
    NameID = 18010345,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/128/Trials_Icon_QuadraKill.Trials_Icon_QuadraKill",
    TipsText = 33020029,
    TriggerAchievementID = 44,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_QuadraKill.Trials_Icon_QuadraKill"
  },
  [2] = {
    HighlightName = "SingleGrenadeMultiKill",
    SmartCameraID = 30008,
    EmoteID = 12220102,
    DamageType = UEnums.DamageType.GrenadeRadiusDamage,
    DamageItemID = 602004,
    CloseTime = 9.5,
    SeqEventMsg = "SingleGrenadeMultiKillMsg",
    TLogID = 1926,
    MinKillNum = 2,
    Timeout = 30,
    NameID = 18010346,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_ThunderFury.Trials_Icon_ThunderFury",
    TipsText = 33020033,
    TriggerAchievementID = 45,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_ThunderFury.Trials_Icon_ThunderFury"
  },
  [3] = {
    HighlightName = "LongRangeSnipeKill",
    SmartCameraID = 30007,
    EmoteID = 12220101,
    DamageType = UEnums.DamageType.ShootDamage,
    DamageItemID = -1,
    CloseTime = 9.5,
    SeqEventMsg = "LongRangeSnipeKillMsg",
    Distance = 280,
    NameID = 69012,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_Hawkeye.Trials_Icon_Hawkeye",
    TipsText = 33020030,
    TriggerAchievementID = 3,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_Hawkeye.Trials_Icon_Hawkeye"
  },
  [4] = {
    HighlightName = "SingleShotMultiKill",
    SmartCameraID = 30010,
    EmoteID = 12220349,
    DamageType = UEnums.DamageType.ShootDamage,
    DamageItemID = -1,
    CloseTime = 11,
    SeqEventMsg = "SingleShotMultiKillMsg",
    NameID = 18010347,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_OneArrowDoubleEagle.Trials_Icon_OneArrowDoubleEagle",
    TipsText = 33020031,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_OneArrowDoubleEagle.Trials_Icon_OneArrowDoubleEagle"
  },
  [5] = {
    bIgnoreCheck = true,
    HighlightName = "KingElimination",
    SmartCameraID = 30011,
    EmoteID = 12220501,
    CloseTime = 15,
    DamageType = UEnums.DamageType.ShootDamage,
    DamageItemID = -1,
    SeqEventMsg = "KingEliminationMsg",
    bShowTips = false,
    NameID = 76971,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_EliminationKing.Trials_Icon_EliminationKing"
  },
  [6] = {
    HighlightName = "VehicleMultiKill",
    DamageType = -1,
    DamageItemID = -1,
    CloseTime = -1,
    SeqEventMsg = "VehicleMultiKillMsg",
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_FirepowerFrenzy.Trials_Icon_FirepowerFrenzy",
    TipsText = 33020032,
    NameID = 18010348,
    TriggerAchievementID = 47,
    TwoTeammeatesKillConfig = {Time = 120.0, KillNum = 2},
    FourTeammeatesKillConfig = {Time = 120.0, KillNum = 2},
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_FirepowerFrenzy.Trials_Icon_FirepowerFrenzy"
  },
  [7] = {
    HighlightName = "UpgradedWeaponKill",
    DamageType = UEnums.DamageType.ShootDamage,
    DamageItemID = -1,
    bIgnoreVictimDying = true,
    bIgnoreKnockDown = true,
    CloseTime = -1,
    bCanPlayIndoor = true,
    SeqEventMsg = "UpgradedWeaponKillMsg",
    NameID = 69012
  },
  [8] = {
    IgnoreHighlight = true,
    HighlightName = "HighSpeedKill",
    SmartCameraID = 30007,
    EmoteID = 12220101,
    DamageType = UEnums.DamageType.ShootDamage,
    DamageItemID = -1,
    CloseTime = 9.5,
    SeqEventMsg = "HighSpeedKillMsg",
    Speed = 40,
    NameID = 69012,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_PreciseMonitoring.Trials_Icon_PreciseMonitoring",
    TipsText = 33020030,
    TriggerAchievementID = 4,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_PreciseMonitoring.Trials_Icon_PreciseMonitoring"
  },
  [9] = {
    HighlightName = "MultipleKill",
    bIgnoreCheck = true,
    SmartCameraID = 30012,
    EmoteID = 12220535,
    CloseTime = 15,
    SeqEventMsg = "MultipleKillMsg",
    KillNum = 10,
    NameID = 38629,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_MarsDescends.Trials_Icon_MarsDescends",
    TipsText = 38629,
    TriggerAchievementID = 5,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_MarsDescends.Trials_Icon_MarsDescends"
  },
  [12] = {
    HighlightName = "AllWeaponKill",
    SmartCameraID = 30013,
    EmoteID = 12220534,
    DamageType = UEnums.DamageType.ShootDamage,
    DamageItemID = -1,
    CloseTime = 15,
    SeqEventMsg = "AllWeaponKillMsg",
    SubTypeConfig = {
      101,
      102,
      103,
      104,
      105,
      106
    },
    NameID = 18010350,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_AllRounder.Trials_Icon_AllRounder",
    TipsText = 18010350,
    TriggerAchievementID = 49,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_AllRounder.Trials_Icon_AllRounder"
  },
  [14] = {
    HighlightName = "GrenadeInVehicle",
    SmartCameraID = 30015,
    EmoteID = 12220737,
    CloseTime = 15,
    SeqEventMsg = "GrenadeInVehicleMsg",
    NameID = 18010371,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_FlyingCarExplosion.Trials_Icon_FlyingCarExplosion",
    TipsText = 18010371,
    TriggerAchievementID = 52,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_FlyingCarExplosion.Trials_Icon_FlyingCarExplosion"
  },
  [15] = {
    HighlightName = "AngelRescue",
    bIgnoreCheck = true,
    SmartCameraID = 30015,
    EmoteID = 12220738,
    CloseTime = 15,
    SeqEventMsg = "AngelRescueMsg",
    NameID = 18010372,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_GuardianAngel.Trials_Icon_GuardianAngel",
    TipsText = 18010372,
    TriggerAchievementID = 53,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_GuardianAngel.Trials_Icon_GuardianAngel",
    RescueCount = 5
  },
  [16] = {
    HighlightName = "LightningWar",
    bIgnoreCheck = true,
    SmartCameraID = 30015,
    EmoteID = 12220739,
    CloseTime = 15,
    SeqEventMsg = "LightningWarMsg",
    NameID = 18010373,
    IconPath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_Blitz.Trials_Icon_Blitz",
    TipsText = 18010373,
    TriggerAchievementID = 54,
    BadgePath = "/Game/Arts/UI/TableIcons/RankIntegralLevel/Brag_Medal/Trials/Trials_Icon_Blitz.Trials_Icon_Blitz",
    Time = 600,
    KillNum = 8
  }
}
HighlightMomentConfig.CheckFreeEmoteID = {
  [12220881] = true,
  [12220882] = true,
  [12220883] = true,
  [12220884] = true,
  [12220885] = true,
  [12220535] = true,
  [12220534] = true,
  [12220533] = true
}
HighlightMomentConfig.BattleResultAchievementHighlightMap = {
  [48] = 11,
  [50] = 13
}
HighlightMomentConfig = TableUtil.MergeTable(HighlightMomentConfig, HighlightMomentConfig_Vehicle)
return HighlightMomentConfig