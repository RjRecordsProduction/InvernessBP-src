local SkillAction_DisableCameraRotate = {
  sObjectName = "SkillAction_DisableCameraRotate"
}
function SkillAction_DisableCameraRotate:ctor(selfType)
  print(bWriteLog and "SkillAction_DisableCameraRotate:ctor")
end
function SkillAction_DisableCameraRotate:LuaRealDoAction()
  print(bWriteLog and "SkillAction_DisableCameraRotate:LuaRealDoAction")
  if Client then
    local uOwnerPawn = self:GetOwnerPawn()
    if not slua.isValid(uOwnerPawn) then
      print(bWriteLog and "SkillAction_DisableCameraRotate:LuaRealDoAction not slua.isValid(uOwnerPawn)")
      return
    end
    local uPlayerController = uOwnerPawn:GetController()
    if slua.isValid(uPlayerController) and uPlayerController:IsPlayerController() then
      uPlayerController:SetDisableTouchMoveInput(true)
      print(bWriteLog and "SkillAction_DisableCameraRotate:LuaRealDoAction uPlayerController:SetDisableTouchMoveInput true")
    end
  end
  return true
end
function SkillAction_DisableCameraRotate:LuaResetAction()
  print(bWriteLog and "SkillAction_DisableCameraRotate:LuaResetAction")
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    print(bWriteLog and "SkillAction_DisableCameraRotate:LuaResetAction not slua.isValid(uOwnerPawn)")
    return
  end
  if Client then
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and uPlayerController:IsPlayerController() then
      uPlayerController:SetDisableTouchMoveInput(false)
      print(bWriteLog and "SkillAction_DisableCameraRotate:LuaResetAction uPlayerController:SetDisableTouchMoveInput false")
    end
  end
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillAction_DisableCameraRotate = class(CObjectBase, nil, SkillAction_DisableCameraRotate)
return CSkillAction_DisableCameraRotate