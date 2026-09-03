local SkillCDDefine = require("GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCDDefine")
local ESkillIconStatus = import("ESkillIconStatus")
local Config = {
  UltraHandSkill = {
    SkillID = 1032211,
    SkillWeaponID = 1032212,
    SkillArmorID = 1032213,
    SkillCD = 3,
    ConfirmDuration = 5,
    BreakFreeReduceInternal = 0.2,
    BreakFreeReduceSeconds = 30,
    NormalPickTargetDelay = 0.1,
    SpawnEmptyTargetDelay = 0.5,
    SpawnEmptyTargetNoCatchLifeTime = 60,
    CatchTeammateInternal = 120,
    HoverVehicleSpeedScale = 0.7,
    MechaVehicleSpeedScale = 0.7,
    WeaponSpeedScale = -0.3,
    ArmorSpeedScale = -0.3,
    FollowMoveDistanceMax = 5000,
    PreviewTargetShowTime = 1,
    ThrowVehicleDelayEnableProtectionSeconds = 4,
    CacheSpawnStoneNumMax = 4,
    SkillDuration = 20,
    tSkillDynamicData = {
      [1032211] = {
        CatchCharacterDuration = 10.0,
        CatchVechileDuration = 10.0,
        CatchDestructibleDuration = 10.0,
        ThrowCharacterImpulse = FVector(3000, 0, 600),
        ThrowVehicleImpulse = FVector(3000, 0, 600),
        ThrowMechaVehicleImpulse = FVector(3000, 0, 600),
        ThrowDestructibleActor = FVector(4000, 0, 600),
        ThrowAirDropImpulse = FVector(3000, 0, 600)
      },
      [1032212] = {
        CatchCharacterDuration = 10.0,
        CatchVechileDuration = 10.0,
        CatchDestructibleDuration = 10.0,
        ThrowCharacterImpulse = FVector(1500, 0, 450),
        ThrowVehicleImpulse = FVector(3000, 0, 450),
        ThrowMechaVehicleImpulse = FVector(2000, 0, 450),
        ThrowDestructibleActor = FVector(2000, 0, 250),
        ThrowAirDropImpulse = FVector(1500, 0, 450)
      },
      [1032213] = {
        CatchCharacterDuration = 10.0,
        CatchVechileDuration = 3.0,
        CatchDestructibleDuration = 10.0,
        ThrowCharacterImpulse = FVector(1500, 0, 450),
        ThrowVehicleImpulse = FVector(1500, 0, 400),
        ThrowMechaVehicleImpulse = FVector(1500, 0, 400),
        ThrowDestructibleActor = FVector(2000, 0, 250),
        ThrowAirDropImpulse = FVector(1500, 0, 450)
      }
    }
  }
}
return Config