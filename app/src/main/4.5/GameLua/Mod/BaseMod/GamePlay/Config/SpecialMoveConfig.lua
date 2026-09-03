local ESpecialMovementType = import("ESpecialMovementType")
local ECustomMovmentMode = import("ECustomMovmentMode")
local SpecialMoveConfig = {
  SpecialMoveObjPathInfos = {
    bDeepOverwrite = true,
    [ESpecialMovementType.SPECIAL_MOVE_LifterControl] = "/Game/Mod/EvoBase/BluePrints/Actor/BP_LifterControlMoveObj.BP_LifterControlMoveObj_C",
    [ESpecialMovementType.SPECIAL_MOVE_LuaCustom] = "/Game/Library/Res/Skills/LuaCustomMove/BP_LuaCustomMoveObj.BP_LuaCustomMoveObj_C"
  },
  CustomMoveToSpecialMoveTypes = {
    bDeepOverwrite = true,
    [ECustomMovmentMode.CUSTOM_MOVE_LifterControl] = ESpecialMovementType.SPECIAL_MOVE_LifterControl
  },
  LuaCustomVariants = {
    {
      Key = "Default",
      VariantPath = "GameLua.Mod.Library.GamePlay.SpecialMove.LuaCustomMove.Variants.DefaultVariant"
    }
  }
}
return SpecialMoveConfig