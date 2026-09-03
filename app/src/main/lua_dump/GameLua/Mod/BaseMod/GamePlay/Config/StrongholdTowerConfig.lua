local TowerConfig = {
  TowerState = {
    Disabled = 0,
    Enabled = 1,
    Activating = 2,
    Increasing = 3,
    Pausing = 4,
    EnemyDecreasing = 5,
    NoOneDecreasing = 6,
    Success = 7,
    Cooldown = 8
  },
  ParticleSystemPath = {
    Enabled = "/Game/Mod/BRMod/Arts_Effect/ParticleSystems/P_Sink_Scene_RiseLoop_xq.P_Sink_Scene_RiseLoop_xq",
    Progress = "/Game/Mod/BRMod/Arts_Effect/ParticleSystems/P_Sink_Scene_RiseGroundRune_01_xq.P_Sink_Scene_RiseGroundRune_01_xq",
    Active = "/Game/Mod/EvoBase/Arts_Effect/ParticleSystems/P_Sink_Scene_RiseActive_xq.P_Sink_Scene_RiseActive_xq",
    AnyOne = "/Game/Mod/EvoBase/Arts_Effect/ParticleSystems/P_Sink_Scene_RiseActiveLoop_xq.P_Sink_Scene_RiseActiveLoop_xq",
    Success = "/Game/Mod/EvoBase/Arts_Effect/ParticleSystems/P_Sink_Scene_RiseActiveFinial_xq.P_Sink_Scene_RiseActiveFinial_xq"
  },
  SendMessageCD = 5,
  CooldownDuration = 180,
  DelayToDecrease = 0.5,
  TickInterval = 0.2,
  VelocityOfIncrease = 200,
  VelocityOfDecrease = 500,
  MaxProgress = 10000,
  DisableTowerInBlueCircle = true,
  StrongholdTowerDisableTimeTips1 = 120,
  StrongholdTowerDisableTimeTips2 = 30,
  MapMarkIconChangeScale = 1.5,
  NetEncodeMagnification = 100000,
  StrongholdWeaponPoor = {
    TimePoint = 360,
    BeforeWeaponPoor = {
      BeginEquip = {
        [1] = {
          [{
            {305001, 90},
            {204004, 1},
            {501001, 1},
            {502001, 1},
            {503113, 1},
            {601011, 6},
            {601012, 1},
            {108005, 1}
          }] = 100
        },
        [2] = {
          [{
            {102002, 1}
          }] = 33
        }
      }
    },
    AfterWeaponPoor = {
      BeginEquip = {
        [1] = {
          [{
            {305001, 90},
            {204004, 1},
            {501002, 1},
            {502002, 1},
            {503114, 1},
            {601011, 6},
            {601012, 2},
            {1004001, 1},
            {206207, 1},
            {108005, 1}
          }] = 100
        },
        [2] = {
          [{
            {102002, 1}
          }] = 33
        }
      }
    }
  }
}
return TowerConfig