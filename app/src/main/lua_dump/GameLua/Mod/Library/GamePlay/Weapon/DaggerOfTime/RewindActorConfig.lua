local EPawnState = import("EPawnState")
local Config = {
  DaggerOfTimeAdvID = 108018,
  AttachRelativeLoc = FVector(-4.699673, -1.634363, 2.674775),
  AttachRelativeRot = FRotator(-36.348396, 137.82309, -176.813309),
  CancelRewindState = {
    EPawnState.Dying,
    EPawnState.Dead,
    EPawnState.DriveVehicle,
    EPawnState.InVehicle,
    EPawnState.Swim,
    EPawnState.InParachute,
    EPawnState.InPlane,
    EPawnState.InZipline,
    EPawnState.StairsMove,
    EPawnState.InActivityActor,
    EPawnState.DriveMovePlatForm,
    EPawnState.AirBorne,
    EPawnState.SplineMove,
    EPawnState.Shocked
  },
  RewindDistanceLimit = 20000,
  WeaponSkillConfig = {
    [108017] = {
      RewindBeginSkill = 1030701,
      RewindProcessSkill = 1030711,
      RewindStateBuffID = 60460,
      RewindSkillCD = 120,
      RewindPhaseTime = 11,
      RewindSpeedRate = 4.0,
      FixVehicleSkillID = 1030730
    },
    [108019] = {
      RewindBeginSkill = 1030702,
      RewindProcessSkill = 1030712,
      RewindStateBuffID = 60460,
      RewindSkillCD = 50,
      RewindPhaseTime = 10,
      RewindSpeedRate = 3.0,
      FixVehicleSkillID = 1030730
    },
    [108020] = {
      RewindBeginSkill = 1030703,
      RewindProcessSkill = 1030713,
      RewindStateBuffID = 60460,
      RewindSkillCD = 50,
      RewindPhaseTime = 10,
      RewindSpeedRate = 4.0,
      FixVehicleSkillID = 1030730
    },
    [108018] = {
      RewindBeginSkill = 1030704,
      RewindProcessSkill = 1030714,
      RewindStateBuffID = 60463,
      RewindSkillCD = 100,
      RewindPhaseTime = 13,
      RewindSpeedRate = 5.0,
      FixVehicleSkillID = 1030730
    }
  },
  DyingRewindHp = 10,
  FixVehicleColor = FLinearColor(1, 0.854993, 0, 1),
  FixVehicleLink = "/Game/Library/Res/Weapons/DaggerOfTime/Art_Effect/Par/P_Mecha_AttractLine_Sand.P_Mecha_AttractLine_Sand",
  FixTargetEffect = "/Game/Library/Res/Weapons/DaggerOfTime/Art_Effect/Par/P_ZNQ7th_Sceneltem_int_138_Loop.P_ZNQ7th_Sceneltem_int_138_Loop",
  FixBioVehicleTargetEffectOffset = FVector(0, 0, 0),
  FixPhyVehicleTargetEffectOffset = FVector(0, 0, 75),
  FixChestTargetEffectOffset = FVector(0, 0, -50),
  ChestNotOpenTips = 370046,
  ChestNoFixTips = 370028,
  VehicleNotNeedFixTips = 370029,
  DestroyTips = 370041,
  RewindLocInvalidTips = 370049,
  ChestUpgradeSpecialDropMode = {
    91067,
    91068,
    91071,
    91072,
    91081,
    91082,
    91085,
    91086
  },
  ChestUpgradeSpecialDropID = 370900023,
  ChestUpgradeDropID = 370900043,
  ChestUpgradeEffect = "/Game/Library/Res/Weapons/DaggerOfTime/Art_Effect/Par/P_ZNQ7th_DeluxeTreasure_01.P_ZNQ7th_DeluxeTreasure_01",
  RewindLocEffect = "/Game/Library/Res/Weapons/DaggerOfTime/Art_Effect/Par/P_ZNQ7th_Sceneltem_int_138_Loop.P_ZNQ7th_Sceneltem_int_138_Loop",
  RewindLocAdvEffect = "/Game/Library/Res/Weapons/DaggerOfTime/Art_Effect/Par/P_ZNQ7th_Sceneltem_int_138_Loop_2.P_ZNQ7th_Sceneltem_int_138_Loop_2",
  Tlog_PickUpDaggerOfTime = 1435,
  Tlog_PickUpDaggerOfTimeAdv = 1436,
  Tlog_RewindSkillTimes = 1437,
  Tlog_RewindSuccessTimes = 1438,
  Tlog_RewindVehicleTimes = 1439,
  Tlog_RewindChestTimes = 1440,
  Tlog_DyingAutoRewindTimes = 1530,
  Tlog_DaggerOfTimeBuildTimes = 1531,
  Tlog_AdvRewindTimes = 1503,
  RewindBeginSound = "/Game/Library/Res/Weapons/DaggerOfTime/WwiseEvent/ZNQ7th_DaggerOfTime_370/Play_ZNQ7th_DaggerOfTime_Skill1_Casting.Play_ZNQ7th_DaggerOfTime_Skill1_Casting",
  RewindingTailSound = "/Game/Library/Res/Weapons/DaggerOfTime/WwiseEvent/ZNQ7th_DaggerOfTime_370/Play_ZNQ7th_DaggerOfTime_Skill1_Screen_Loop.Play_ZNQ7th_DaggerOfTime_Skill1_Screen_Loop",
  RewindingShadowSound = "/Game/Library/Res/Weapons/DaggerOfTime/WwiseEvent/ZNQ7th_DaggerOfTime_370/Play_ZNQ7th_DaggerOfTime_Skill1_Trail.Play_ZNQ7th_DaggerOfTime_Skill1_Trail",
  RewindEndBoomSound = "/Game/Library/Res/Weapons/DaggerOfTime/WwiseEvent/ZNQ7th_DaggerOfTime_370/Play_ZNQ7th_DaggerOfTime_Skill1_End.Play_ZNQ7th_DaggerOfTime_Skill1_End",
  RewindingBallMoveSound = "/Game/Library/Res/Weapons/DaggerOfTime/WwiseEvent/ZNQ7th_DaggerOfTime_370/Play_ZNQ7th_DaggerOfTime_Skill1_RollBack_Loop.Play_ZNQ7th_DaggerOfTime_Skill1_RollBack_Loop",
  NeedRemoveBuff = {
    10101,
    10102,
    10103
  }
}
return Config