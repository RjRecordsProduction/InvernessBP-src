local StrongestSquadFeatureConfig = {
  StrongestTipsID = 0,
  StatueScale = 1,
  ShowStatueEffect = "",
  StatueEffectOffset = FVector(0, 0, -90),
  StatueEffectScale = FVector(1, 1, 1),
  StatueEffectLifeTime = 10,
  AvatarMaterialPath = "",
  PlayerAnimationList = {
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Animation/Vectory_Pose_1_Montage.Vectory_Pose_1_Montage",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Animation/Vectory_Pose_2_Montage.Vectory_Pose_2_Montage",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Animation/Vectory_Pose_3_Montage.Vectory_Pose_3_Montage",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Animation/Vectory_Pose_4_Montage.Vectory_Pose_4_Montage"
  },
  SimpleMaleAnimationList = {
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1429_01.Sceneltem_int_1429_01",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1429_02.Sceneltem_int_1429_02",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1429_03.Sceneltem_int_1429_03",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1429_04.Sceneltem_int_1429_04"
  },
  SimpleFemaleAnimationList = {
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1430_01.Sceneltem_int_1430_01",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1430_02.Sceneltem_int_1430_02",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1430_03.Sceneltem_int_1430_03",
    "/Game/Library/Res/Actors/StrongestSquad/Arts_Player/Characters/Mesh/Sceneltem_int_1430_04.Sceneltem_int_1430_04"
  },
  SphereRadius = 200,
  SameAreaIDCanBeSummoned = false,
  SummonExcludeAreaIDList = {},
  TeleportIDConfig = 1001,
  SummonReviveAudio = "/Game/Library/Res/Actors/StrongestSquad/WwiseEvent/PlanTF_POI_Call_Common/Play_PlanTF_POI_Called_Player.Play_PlanTF_POI_Called_Player",
  BeSummonedRevivedAudio = "/Game/Library/Res/Actors/StrongestSquad/WwiseEvent/PlanTF_POI_Call_Common/Play_PlanTF_POI_Call_Teamate.Play_PlanTF_POI_Call_Teamate",
  SummonReviveEffect = "/Game/Arts_Effect/ParticleSystems/Drop/P_Halloween4_Relive_Blue_02_L2.P_Halloween4_Relive_Blue_02_L2",
  SummonReviveEffectOffset = FVector(0, 0, -100),
  BeSummonedRevivedEffect = "/Game/Arts_Effect/ParticleSystems/Drop/P_Halloween4_Relive_Blue_03_L2.P_Halloween4_Relive_Blue_03_L2",
  BeSummonedRevivedEffectOffset = FVector(0, 0, -100),
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
  RevivePosition = {
    FVector(500, 0, 200),
    FVector(-500, 0, 200),
    FVector(0, -500, 200),
    FVector(0, 500, 200)
  }
}
return StrongestSquadFeatureConfig