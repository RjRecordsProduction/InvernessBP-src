local Config = {
  IsForTraining = false,
  TrainingStateStartTime = 0.16,
  TrainingStateSendTime = 0.22,
  TrainingStateTimeOut = 0.23,
  DebugInstanceID = 100000,
  bSearchNearbyItem = true,
  bRoundModeForTraining = false,
  bEditorOnlineTestCmdMode = false,
  bReloadWithNoCost = true,
  bUseLerpRotation = true,
  LerpRotationThreshold = 5.0,
  bShouldSendVehicleInfo = true,
  OnlineRequestTimeMS = 220,
  OnlineLowerLimitOffsetMS = -10,
  OnlineGlobalStateOffsetMS = -100,
  AllocateTimeOutSec = 10,
  ActionTimeOutSec = 10,
  ReconnectTimes = 5,
  ReconnectCD = 1,
  StartGameTimeOutSec = 5,
  MaxResendGameStartTimes = 2,
  DelayExitTime = 15,
  DynamicObjectConfig = {
    [1] = "/Game/Mod/ZNQ5th/BluePrints/Actor/BuildableActor/Block_Simple1.Block_Simple1",
    [2] = "/Game/Mod/ZNQ5th/BluePrints/Actor/BuildableActor/Block_Simple2.Block_Simple2",
    [3] = "/Game/Mod/ZNQ5th/BluePrints/Actor/BuildableActor/Block_SpringTrigger.Block_SpringTrigger",
    [4] = "/Game/Mod/ZNQ5th/BluePrints/Actor/BuildableActor/Block_Cannon.Block_Cannon"
  },
  GameModeDynamicItemScheme = {
    [1] = "0"
  },
  AIAllocateStyle = {
    Style_Normal = 1,
    Style_NormalDelivery = 2,
    Style_MultiTeam = 3,
    Style_Airdrop = 4,
    Style_VehicleAI = 5,
    Style_SignalGun = 6,
    Style_Throw = 7,
    Style_VehicleKillAI = 8,
    Style_ParachuteFollowAI = 9,
    Style_ParachuteAI = 10,
    Style_ReviveParachuteAI = 11,
    Style_JumpFollowAI = 12,
    Style_HumanoidMonsterAI = 13,
    Style_Mercenary = 36,
    Style_EscapeAI = 20,
    Style_FireTruckAI = 21,
    Style_MultipleKillsAI = 22,
    Style_ResurrectionTowerAttackAI = 23,
    Style_ResurrectionTowerDefenseAI = 24,
    Style_GuardBridgeAttackAI = 25,
    Style_GuardBridgeDefenseAI = 26,
    Style_SneakAttackAI = 27,
    Style_SniperAI = 28,
    Style_LonesomeCompensateAI = 29,
    Style_GuardDeliver = 33,
    Style_EncounterDeliver = 34,
    Style_BT2ML = 201,
    Style_PlayerDelivery = 202,
    Style_CostOptBT2ML = 203,
    Style_ReadyStateBTAI = 204,
    Style_Teammate = 301,
    Style_TakeOverTeammate = 302
  },
  bOpenResponseLog = false,
  bOpenDiffLog = false,
  bOpenNearbyDebug = false,
  UseNewDiffCmds = true,
  UseTablePool = true,
  EditorMLAITest = false,
  EditorMLAITestType = 0,
  EditorTeammateTakeOverTest = false,
  IsForEditorOnlineTest = false,
  bDumpDiffLog = false,
  EditorPVESuperAiType = 0,
  bOpenTraingLog = false,
  GameAllocateType = {
    Type_Fighting = 0,
    Type_AllProcess = 1,
    Type_Ready_Fighting = 2
  },
  MLAIStateCheckTime = {
    Baltic = 1310,
    Livik = 780,
    Borderland = 405,
    Neon = 1180
  },
  SpawnOriginalBTAITime = {
    Baltic = 125,
    Livik = 85,
    Borderland = 73
  },
  ModMLAIParachuteCheckTime = {NewbieGame2 = 550},
  BTForbiddenWeaponList = {
    107037,
    106007,
    106103,
    107039,
    107040,
    107005
  },
  AIAllocateReason = {
    None = 0,
    MLAIAllocate = 1,
    ExitSilenceState = 2,
    Revive = 3
  },
  AIDestroyReason = {
    None = 0,
    Death = 1,
    EnterSilence = 2,
    GameStartException = 3,
    ActionTimeout = 4,
    DeliveryTimeout = 5,
    AllocateTimeout = 6,
    GameStop = 7,
    EnterPlane = 8,
    AllTeammateExited = 9
  },
  EnableLogServerIPAddress = {
    [1] = {
      IPAddress = "30.47.95.56",
      PrintType = 0
    },
    [2] = {IPAddress = "9.219.90.8", PrintType = 0},
    [3] = {
      IPAddress = "11.147.23.201",
      PrintType = 0
    }
  }
}
return Config