local ESpecialMovementType = import("ESpecialMovementType")
local ECustomMovmentMode = import("ECustomMovmentMode")
local SpecialMoveConfig = {
  SpecialMoveObjPathInfos = {
    bDeepOverwrite = true,
    [ESpecialMovementType.SPECIAL_MOVE_LifterControl] = "/Game/Mod/EvoBase/BluePrints/Actor/BP_LifterControlMoveObj.BP_LifterControlMoveObj_C"
  },
  CustomMoveToSpecialMoveTypes = {
    bDeepOverwrite = true,
    [ECustomMovmentMode.CUSTOM_MOVE_LifterControl] = ESpecialMovementType.SPECIAL_MOVE_LifterControl
  }
}
return SpecialMoveConfig