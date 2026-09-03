local CarryDeadBoxInfo = {
  CarryDeadBoxSkillID = 1016000,
  PutDownDeadBoxSkillID = 1016001,
  AttachSocket = "item_lSocket",
  DeadBoxCheckDistance = 500,
  BlendData = "/Game/Arts_Player/Characters/Animation/Base_AnimBP/Feature/DefaultCarryDeadBoxModifyBlendData.DefaultCarryDeadBoxModifyBlendData",
  CarryedDeadBoxUpdateFrequency = 18,
  PutDownDeadBoxUpdateFrequency = 0.5,
  FakeViewTargetClass = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Skill/CarryDeadBox/DeadBoxViewTarget.DeadBoxViewTarget",
  PutLocationCheckBox = FVector(5, 5, 2),
  PutLocationCheckOffset = FVector(50, 0, 100),
  PutLocationUpOffset = FVector(0, 0, 1),
  PutLocationTraceDownOffset = 15000,
  TlogCarryDeadBoxTimes = 1919
}
return CarryDeadBoxInfo