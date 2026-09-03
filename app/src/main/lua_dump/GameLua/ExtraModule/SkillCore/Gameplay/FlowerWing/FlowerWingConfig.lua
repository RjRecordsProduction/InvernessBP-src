local FlowerWingConfig = {
  SkillID = 4201001,
  FlutterSkillID = 4201003,
  FlashSkillID = 4201004,
  DivingSkillID = 4201005,
  TransformJumpVelocityZ = -100,
  FlutterCostEnergy = -15,
  FlutterSpeedBuff = 4203002,
  PitchAngleMin = -90,
  PitchAngleMax = -10,
  DivingDownMinDis = 0,
  DivingDownMaxDis = 15000,
  DivingDownMinHeight = 0,
  FlashShadowLifeTime = 0,
  FlowerWingActorClass = "/Game/Library/Res/Skills/FlowerWing/Arts_PlayerBluePrints/Skill/BP_FlowerWingActor.BP_FlowerWingActor_c",
  FlowerWingMeshSkinPath = "/Game/Library/Res/Skills/FlowerWing/Arts_Player/Mesh/Sceneltem_int_1948_Skin_2.Sceneltem_int_1948_Skin_2",
  MoveAnimClassPath = "/Game/Library/Res/Skills/FlowerWing/Arts_PlayerBluePrints/Skill/CH_Base_AnimBP_Movement_FlowerWing.CH_Base_AnimBP_Movement_FlowerWing_C",
  StandbyAnimPath = "/Game/Library/Res/Skills/FlowerWing/Arts_Player/Ani/Characters/SceneItem_int_1948_idle01_Montage.SceneItem_int_1948_idle01_Montage",
  IdleFxPath = "/Game/Library/Res/Skills/FlowerWing/Arts_Effect/Par/P_SceneItem_int_1948_idle_01_L3.P_SceneItem_int_1948_idle_01_L3",
  IdleFxOffset = FVector(0, 0, 10),
  IdleSoundPlay = "/Game/Library/Res/Skills/FlowerWing/WwiseEvent/MysticPlant_FlowerWing_420/MysticPlant_FlowerWing_Fly/Play_MysticPlant_FlowerWing_Fly_Magic_Loop.Play_MysticPlant_FlowerWing_Fly_Magic_Loop",
  IdleSoundStop = "/Game/Library/Res/Skills/FlowerWing/WwiseEvent/MysticPlant_FlowerWing_420/MysticPlant_FlowerWing_Fly/Stop_MysticPlant_FlowerWing_Fly_Magic_Loop.Stop_MysticPlant_FlowerWing_Fly_Magic_Loop",
  FlashShadowConfig = {
    BornFxPath = "/Game/Library/Res/Skills/FlowerWing/Arts_Effect/Par/P_SceneItem_int_1948_Skill02_Born_L3.P_SceneItem_int_1948_Skill02_Born_L3",
    BornFxOffset = FVector(0, 15, 130),
    ShadowFxPath = "/Game/Library/Res/Skills/FlowerWing/Arts_Effect/Par/P_SceneItem_int_1948_Skill02_B_L3.P_SceneItem_int_1948_Skill02_B_L3",
    ShadowFxOffset = FVector(0, 20, 130),
    DisappearFxPath = "/Game/Library/Res/Skills/FlowerWing/Arts_Effect/Par/P_SceneItem_int_1948_Skill02_Disappear_L3.P_SceneItem_int_1948_Skill02_Disappear_L3",
    DisappearFxOffset = FVector(0, 20, 130)
  },
  FlashActorAnimConfig = {
    "/Game/Library/Res/Skills/FlowerWing/Arts_Player/AE_Ani/SceneItem_int_1948_Skill02_F.SceneItem_int_1948_Skill02_F",
    "/Game/Library/Res/Skills/FlowerWing/Arts_Player/AE_Ani/SceneItem_int_1948_Skill02_R.SceneItem_int_1948_Skill02_R",
    "/Game/Library/Res/Skills/FlowerWing/Arts_Player/AE_Ani/SceneItem_int_1948_Skill02_B.SceneItem_int_1948_Skill02_B",
    "/Game/Library/Res/Skills/FlowerWing/Arts_Player/AE_Ani/SceneItem_int_1948_Skill02_L.SceneItem_int_1948_Skill02_L"
  }
}
return FlowerWingConfig