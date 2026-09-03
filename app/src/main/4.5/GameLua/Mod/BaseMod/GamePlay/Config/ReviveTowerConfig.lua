local ReviveTowerConfig = {
  DisableTimeConfig = {
    Default = {ReviveTowerDisableTimeTips1 = 120, ReviveTowerDisableTimeTips2 = 30},
    Baltic = {ReviveTowerDisableTimeTips1 = 120, ReviveTowerDisableTimeTips2 = 30},
    BalticRolePlay = {ReviveTowerDisableTimeTips1 = 120, ReviveTowerDisableTimeTips2 = 30},
    Desert = {ReviveTowerDisableTimeTips1 = 120, ReviveTowerDisableTimeTips2 = 30},
    Livik = {ReviveTowerDisableTimeTips1 = 120, ReviveTowerDisableTimeTips2 = 30},
    LivikRolePlay = {ReviveTowerDisableTimeTips1 = 120, ReviveTowerDisableTimeTips2 = 30}
  },
  SendMessageCD = 5,
  TowerState = {
    Disabled = 0,
    Enabled = 1,
    Calling = 2,
    Success = 3
  },
  ParticleSystemPath = {
    "/Game/Arts_Effect/ParticleSystems/Share/P_CSSignalTower_01_xq.P_CSSignalTower_01_xq",
    "/Game/Arts_Effect/ParticleSystems/Share/P_CSSignalTower_02_xq.P_CSSignalTower_02_xq",
    "/Game/Arts_Effect/ParticleSystems/Share/P_CSSignalTower_04_xq.P_CSSignalTower_04_xq"
  },
  MapMarkIconChangeScale = {
    [0] = 2,
    ["/Game/Mod/Sink/Maps/Sink_Main"] = 1.5,
    ["/Game/Mod/FourMaps/Maps/FourMaps_Main"] = 1.5,
    ["/Game/Mod/Livik/Maps/FourMaps_Main"] = 1.5,
    ["/Game/Maps/PUBG_Baltic/Baltic_Main"] = 2,
    ["/Game/Maps/PUBG_Desert/PUBG_Desert"] = 2
  }
}
return ReviveTowerConfig