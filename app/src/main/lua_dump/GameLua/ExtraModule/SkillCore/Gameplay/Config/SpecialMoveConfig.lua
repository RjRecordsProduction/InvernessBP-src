local ESpecialMovementType = import("ESpecialMovementType")
local ECustomMovmentMode = import("ECustomMovmentMode")
local SpecialMoveConfig = {
  SpecialMoveObjPathInfos = {
    [ESpecialMovementType.SPECIAL_MOVE_ODMGear] = "/Game/Library/Res/Skills/GasHook/Arts_PlayerBluePrints/GasHookMoveObj.GasHookMoveObj_C",
    [ESpecialMovementType.SPECIAL_MOVE_GhostBalloon] = "/Game/Library/Res/Skills/GhostBalloon/Arts_PlayerBluePrints/Skill/GhostBalloonMoveObj.GhostBalloonMoveObj_C",
    [ESpecialMovementType.SPECIAL_MOVE_FlowerWing] = "/Game/Library/Res/Skills/FlowerWing/Arts_PlayerBluePrints/Skill/BP_FlowerWingMoveObj.BP_FlowerWingMoveObj_C"
  },
  CustomMoveToSpecialMoveTypes = {
    [ECustomMovmentMode.CUSTOM_MOVE_ODMGear] = ESpecialMovementType.SPECIAL_MOVE_ODMGear,
    [ECustomMovmentMode.CUSTOM_MOVE_GhostBalloon] = ESpecialMovementType.SPECIAL_MOVE_GhostBalloon,
    [ECustomMovmentMode.CUSTOM_MOVE_FlowerWing] = ESpecialMovementType.SPECIAL_MOVE_FlowerWing
  }
}
return SpecialMoveConfig