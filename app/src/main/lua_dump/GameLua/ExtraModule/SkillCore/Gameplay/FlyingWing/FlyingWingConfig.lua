local FlyingWingConfig = {
  ItemID = 44060803,
  TowerItemID = 44060804,
  SkillID = 4401003,
  TowerSkillID = 4401006,
  JumpSkillID = 4401004,
  WingActorClass = "/Game/Library/Res/Skills/FlyingWing/Arts_PlayerBluePrints/Item/BP_FlyingWingActor.BP_FlyingWingActor_C",
  DissolveShowHideMaterialPath = "/Game/Library/Res/Skills/FlyingWing/Arts_Player/SceneItem_int_2196/Mat/M_SceneItem_int_2196_01.M_SceneItem_int_2196_01",
  DissolveDestroyMaterialPath = "/Game/Library/Res/Skills/FlyingWing/Arts_Player/SceneItem_int_2196/Mat/M_SceneItem_int_2196_01_Red.M_SceneItem_int_2196_01_Red",
  WingMeshSkinPath = "/Game/Library/Res/Skills/FlyingWing/Arts_Player/SceneItem_int_2196/Mat/M_SceneItem_int_2196_02.M_SceneItem_int_2196_02",
  DestroyWingMeshSkinPath = "/Game/Library/Res/Skills/FlyingWing/Arts_Player/SceneItem_int_2196/Mat/M_SceneItem_int_2196_02_Red.M_SceneItem_int_2196_02_Red",
  BurnFxMat = "/Game/Library/Res/Skills/FlyingWing/Arts_Player/SceneItem_int_2196/Mat/M_FireWing_Outline_Inst.M_FireWing_Outline_Inst",
  DissolveShowDuration = 1.5,
  DissolveHideDuration = 1.0,
  DissolveDestroyDuration = 30.0,
  DestroyLandEffectPath = "/Game/Library/Res/Skills/FlyingWing/Arts_Effect/Par/P_SceneItem_int_2196_Land_L2.P_SceneItem_int_2196_Land_L2",
  DestroyLandEffectSocket = "spine_01",
  DestroyLandEffectOffset = FVector(16.715471, 0.13772, 0.075897),
  DestroyLandEffectRotation = FRotator(-89.733116, 0.798961, -4.6E-5),
  UnequipDuringDestroyEffectPath = "/Game/Library/Res/Skills/FlyingWing/Arts_Effect/Par/P_SceneItem_int_2196_Land_L3.P_SceneItem_int_2196_Land_L3",
  UnequipDuringDestroyEffectSocket = "root"
}
return FlyingWingConfig