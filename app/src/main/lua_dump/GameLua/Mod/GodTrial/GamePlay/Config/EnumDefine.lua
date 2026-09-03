local EnumDefine = {}
EnumDefine.EHonorType = {
  Kill = 0,
  FireAltar = 1,
  TDTrial = 2,
  EPTrial = 3,
  PKTrial = 4,
  FBTrial = 5,
  FPTrial = 6,
  Rescue = 7,
  Assist = 8,
  Revive = 9,
  KillBoss = 10
}
EnumDefine.ETrialType = {
  Unknown = 0,
  TowerDefense = 1,
  EatPoint = 2,
  Parkour = 3,
  Football = 4,
  FramePlatform = 5,
  ArenaArea = 6,
  BossArea = 7
}
EnumDefine.ETrialState = {
  Inactive = 0,
  Preparing = 1,
  Start = 2,
  Ending = 3,
  Finished = 4
}
EnumDefine.EPKEntryState = {
  Inactive = 1,
  Active = 2,
  Opened = 3,
  Closed = 4
}
EnumDefine.EFireTrapState = {
  Idle = 0,
  Warning = 1,
  Firing = 2,
  Cooldown = 3
}
EnumDefine.ETDFailedReason = {FlagDie = 1, LeaveArea = 2}
EnumDefine.EFBFailedReason = {
  Timeout = 1,
  ManualExit = 2,
  TakeDamage = 3,
  Displacement = 4
}
EnumDefine.ECommonTrialTipsType = {
  EnterArea = 1,
  Success = 2,
  Failed = 3,
  Ready = 4,
  Start = 5,
  LeaveAreaWarning = 6
}
EnumDefine.ETDEnemySoundType = {
  None = 0,
  Normal = 1,
  Rage = 2
}
EnumDefine.ETDBattleFlagState = {
  None = 1,
  Normal = 2,
  Buff = 3,
  Finished = 4
}
EnumDefine.ETDEnemySpawnerState = {Normal = 1, End = 2}
EnumDefine.EHonorArenaState = {
  None = 0,
  HonorCollecting = 1,
  WaitEnterArena = 2,
  ArenaReady = 3,
  GoldenCollecting = 4,
  GoldenFinished = 5,
  FlameChariotWaiting = 6,
  FlameChariotRunning = 7,
  BossAreaWaiting = 8,
  BossAreaFighting = 9,
  BossAreaFailded = 10,
  BossAreaSuccess = 11,
  BossAreaFinished = 12,
  Finished = 13
}
return EnumDefine