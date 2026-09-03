local EFatalDamageRelationship = import("EFatalDamageRelationShip")
local EFatalDamageCharacterType = import("EFatalDamageCharacterType")
local E_DamageType = UEnums.DamageType
local KillInfoCfg = {
  AdditionalWeaponList = {
    [1] = 107002,
    [2] = 107020,
    [3] = 602091,
    [4] = 602120,
    [5] = 602121,
    [6] = 602063
  },
  DamageType2WeaponIconMap = {
    [E_DamageType.DrowningDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_drown_r.killfeed_cause_drown_r",
    [E_DamageType.GrenadeRadiusDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_grenade.killfeed_cause_grenade",
    [E_DamageType.FallingDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_fall_r.killfeed_cause_fall_r",
    [E_DamageType.MeleeDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_punch_r.killfeed_cause_punch_r",
    [E_DamageType.SkillDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_punch_r.killfeed_cause_punch_r",
    [E_DamageType.PoisonDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_playzone_r.killfeed_cause_playzone_r",
    [E_DamageType.VehicleExplodeRadiusDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_explosion_r.killfeed_cause_explosion_r",
    [E_DamageType.AirAttackDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_explosion_r.killfeed_cause_explosion_r",
    [E_DamageType.BurningDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_ranshaodan.killfeed_cause_ranshaodan",
    [E_DamageType.VehicleDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_vehicle_r.killfeed_cause_vehicle_r",
    [E_DamageType.PoisonFogDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_poison_fog.killfeed_cause_poison_fog",
    [E_DamageType.Resurrection] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_RevivalTower.killfeed_RevivalTower",
    [E_DamageType.LowTemperatureDamage] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_dongsi.killfeed_cause_dongsi",
    [E_DamageType.GasolineCanExplosion] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_explosion_r.killfeed_cause_explosion_r",
    [E_DamageType.LastBreathWithoutRescue] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_death.killfeed_cause_death"
  },
  DamageType2WeaponGeneralIconPath = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_condition_HS.killfeed_condition_HS",
  DeadIconMap = {
    [1] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_condition_HS-DBNO.killfeed_condition_HS-DBNO",
    [2] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_condition_HS.killfeed_condition_HS",
    [3] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_condition_DBNO.killfeed_condition_DBNO",
    [4] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_death.killfeed_cause_death"
  },
  FatalDamageRelationship2ColorMap = {
    [EFatalDamageRelationship.MyTeamateIsCauser] = FLinearColor(0.274677, 0.896269, 1, 1),
    [EFatalDamageRelationship.MyTeammateIsVictim] = FLinearColor(1, 0.41978, 0.412543, 1),
    [EFatalDamageRelationship.NotRelated] = FLinearColor(1, 1, 1, 1),
    [EFatalDamageRelationship.MyTeammateIsCauserAndVictim] = FLinearColor(1, 1, 1, 1)
  },
  FatalDamageCharacterType2WeaponIconMap = {
    [EFatalDamageCharacterType.EMonster] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Zombie.killfeed_cause_Zombie",
    [EFatalDamageCharacterType.EBoss] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Boss.killfeed_cause_Boss",
    [EFatalDamageCharacterType.EInfecZombie] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Zombie.killfeed_cause_Zombie",
    [EFatalDamageCharacterType.EInfecRevenger] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_Macheteknife.killfeed_cause_Macheteknife"
  },
  FatalDamageMonsterID2WeaponIconMap = {
    [-4000010] = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_ToiletPerson.killfeed_cause_ToiletPerson"
  },
  EnumShowMode = {
    KillInfo = 1,
    CareerInfo = 2,
    PhaseInfo = 3
  },
  TeamPlayerColorTable = {
    [1] = FLinearColor(0.645833, 0.550796, 0.029071, 0.9),
    [2] = FLinearColor(0.545724, 0.144128, 0.024158, 0.9),
    [3] = FLinearColor(0.022174, 0.258183, 0.462077, 0.9),
    [4] = FLinearColor(0.104616, 0.371238, 0.028426, 0.9),
    [5] = FLinearColor(0.51, 0.08, 0.48, 0.9),
    [6] = FLinearColor(0.1, 0.39, 0.38, 0.9),
    [7] = FLinearColor(0.73, 0.13, 0.16, 0.9),
    [8] = FLinearColor(0.19, 0.17, 0.71, 0.9)
  },
  DamageTypeSpecialCauserNameTipIdCfg = {
    [E_DamageType.AirAttackDamage] = 37189,
    [E_DamageType.VehicleExplodeRadiusDamage] = 37190,
    [E_DamageType.LowTemperatureDamage] = 37191,
    [E_DamageType.FallingDamage] = 37192,
    [E_DamageType.DrowningDamage] = 37194
  },
  FarKillDamageType = {
    [E_DamageType.ShootDamage] = true,
    [E_DamageType.STPointDamage] = true,
    [E_DamageType.CustomRadiusDamage] = true,
    [E_DamageType.MeleeDamage] = true,
    [E_DamageType.GrenadeRadiusDamage] = true,
    [E_DamageType.BurningDamage] = true,
    [E_DamageType.VehicleDamage] = true,
    [E_DamageType.VehicleExplodeRadiusDamage] = true,
    [E_DamageType.SkillDamage] = true,
    [E_DamageType.GasolineCanExplosion] = true,
    [E_DamageType.RPGExplosionDamage] = true,
    [E_DamageType.CartridgeExplosionDamage] = true
  },
  tDBZWeaponID2CauserAndVictimHeroID = {
    [1090101] = {101, 103},
    [1090102] = {101, 105},
    [1090201] = {102, 101},
    [1090203] = {102, 104},
    [1090301] = {103, 102},
    [1090305] = {103, 105},
    [1090401] = {104, 101},
    [1090402] = {104, 103},
    [1090503] = {105, 102},
    [1090504] = {105, 104}
  }
}
return KillInfoCfg