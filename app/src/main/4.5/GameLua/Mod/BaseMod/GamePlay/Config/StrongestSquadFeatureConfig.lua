local StrongestSquadFeatureConfig = {
  StrongestTipsID = 0,
  StatueScale = 1,
  ShowStatueEffect = "",
  StatueEffectOffset = FVector(0, 0, -90),
  StatueEffectScale = FVector(1, 1, 1),
  StatueEffectLifeTime = 10,
  AvatarMaterialPath = "",
  PlayerAnimationList = {
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Ani/TheStrongestSquad_03_Montage.TheStrongestSquad_03_Montage",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Ani/TheStrongestSquad_04_Montage.TheStrongestSquad_04_Montage",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Ani/TheStrongestSquad_01_Montage.TheStrongestSquad_01_Montage",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Ani/TheStrongestSquad_02_Montage.TheStrongestSquad_02_Montage"
  },
  SimpleMaleAnimationList = {
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1429_450_11.Sceneltem_int_1429_450_11",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1429_450_12.Sceneltem_int_1429_450_12",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1429_450_09.Sceneltem_int_1429_450_09",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1429_450_10.Sceneltem_int_1429_450_10"
  },
  SimpleFemaleAnimationList = {
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1430_450_11.Sceneltem_int_1430_450_11",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1430_450_12.Sceneltem_int_1430_450_12",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1430_450_09.Sceneltem_int_1430_450_09",
    "/Game/Mod/PlanSP/Arts_Player/Characters/TheStrongestSquad/Mesh/Sceneltem_int_1430_450_10.Sceneltem_int_1430_450_10"
  },
  SphereRadius = 200,
  ForceShowItemIDList = {},
  SameAreaIDCanBeSummoned = false,
  SummonExcludeAreaIDList = {},
  TeleportIDConfig = 1001,
  SummonReviveAudio = "/Game/Library/Res/Actors/StrongestSquad/WwiseEvent/PlanTF_POI_Call_Common/Play_PlanTF_POI_Called_Player.Play_PlanTF_POI_Called_Player",
  BeSummonedRevivedAudio = "/Game/Library/Res/Actors/StrongestSquad/WwiseEvent/PlanTF_POI_Call_Common/Play_PlanTF_POI_Call_Teamate.Play_PlanTF_POI_Call_Teamate",
  SummonReviveEffect = "/Game/Arts_Effect/ParticleSystems/Drop/P_Halloween4_Relive_Blue_02_L2.P_Halloween4_Relive_Blue_02_L2",
  SummonReviveEffectOffset = FVector(0, 0, -100),
  BeSummonedRevivedEffect = "/Game/Arts_Effect/ParticleSystems/Drop/P_Halloween4_Relive_Blue_03_L2.P_Halloween4_Relive_Blue_03_L2",
  BeSummonedRevivedEffectOffset = FVector(0, 0, -100),
  NameUIClass = "GameLua.Mod.Library.Client.UI.StrongestSquadNameUI",
  PreLoadAssetKey = {
    "ShowPawnActorClassPath",
    "SimpleShowPawnActorClassPath",
    "PlayerAnimationList",
    "SimpleMaleAnimationList",
    "SimpleFemaleAnimationList"
  },
  ShowPawnActorPath = "/Game/Library/Res/Actors/StrongestSquad/BluePrints/StrongestSquadShowPawn.StrongestSquadShowPawn",
  SimpleShowPawnActorPath = "/Game/Library/Res/Actors/StrongestSquad/BluePrints/StrongestSquadSimplePawn.StrongestSquadSimplePawn",
  ShowPawnActorClassPath = "/Game/Library/Res/Actors/StrongestSquad/BluePrints/StrongestSquadShowPawn.StrongestSquadShowPawn_C",
  SimpleShowPawnActorClassPath = "/Game/Library/Res/Actors/StrongestSquad/BluePrints/StrongestSquadSimplePawn.StrongestSquadSimplePawn_C",
  LobbyPawnPosition3 = {
    FVector(0, 20, 200),
    FVector(-120, 16, 200),
    FVector(120, 16, 200)
  },
  LobbyPawnPosition4 = {
    FVector(-50, 20, 200),
    FVector(50, 20, 200),
    FVector(-150, 16, 200),
    FVector(150, 16, 200)
  },
  NamePositionOffset = {
    FVector(10, 40, 40),
    FVector(10, 40, 10),
    FVector(10, 40, 10),
    FVector(10, 40, 40)
  },
  RevivePosition = {
    FVector(500, 0, 200),
    FVector(-500, 0, 200),
    FVector(0, -500, 200),
    FVector(0, 500, 200)
  }
}
return StrongestSquadFeatureConfig