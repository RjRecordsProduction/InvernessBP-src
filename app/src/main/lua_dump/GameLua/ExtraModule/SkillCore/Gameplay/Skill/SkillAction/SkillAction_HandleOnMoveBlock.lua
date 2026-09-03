local SkillAction_HandleOnMoveBlock = {
  sObjectName = "SkillAction_HandleOnMoveBlock"
}
local USTExtraGameplayStatics = import("STExtraGameplayStatics")
function SkillAction_HandleOnMoveBlock:ctor(selfType)
  print(bWriteLog and "SkillAction_HandleOnMoveBlock:ctor")
end
function SkillAction_HandleOnMoveBlock:LuaRealDoAction()
  local uCharacter = self:GetOwnerPawn()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaRealDoAction - uCharacter is nil")
    return false
  end
  if not uCharacter:HasAuthority() then
    return false
  end
  print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaRealDoAction")
  self:AddControlEvent(uCharacter, "OnMoveBlockDelegate", self.HandleOnMoveBlock, self)
  return true
end
function SkillAction_HandleOnMoveBlock:LuaResetAction()
  print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaResetAction")
  local uCharacter = self:GetOwnerPawn()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaResetAction - uCharacter is nil")
    return
  end
  if not uCharacter:HasAuthority() then
    return
  end
  if self.bReverseOnUndo then
    return
  end
  self.bHasReset = true
  print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaResetAction - RemoveControlEvent")
  self:RemoveControlEvent(uCharacter, "OnMoveBlockDelegate")
end
function SkillAction_HandleOnMoveBlock:LuaUndoAction()
  print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaUndoAction")
  local uCharacter = self:GetOwnerPawn()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaUndoAction - uCharacter is nil")
    return
  end
  if not uCharacter:HasAuthority() then
    return
  end
  if self.bHasReset then
    self.bHasReset = nil
    return
  end
  print(bWriteLog and "SkillAction_HandleOnMoveBlock:LuaUndoAction - RemoveControlEvent")
  self:RemoveControlEvent(uCharacter, "OnMoveBlockDelegate")
end
function SkillAction_HandleOnMoveBlock:HandleOnMoveBlock(uSelfCharacter, uInHitResult)
  if not uInHitResult then
    return
  end
  local HitActor = uInHitResult.Actor
  local HitComponent = uInHitResult.Component
  print(bWriteLog and string.format("SkillAction_HandleOnMoveBlock:HandleOnMoveBlock - HitActor:%s, HitComponent:%s", tostring(HitActor), tostring(HitComponent)))
  USTExtraGameplayStatics.ClientDrawDebugPoint(FVector(uInHitResult.ImpactPoint.X, uInHitResult.ImpactPoint.Y, uInHitResult.ImpactPoint.Z), 20, FLinearColor.Red, 3)
  local uSkillManager = self:GetOwnerSkillManager()
  if not slua.isValid(uSkillManager) then
    return
  end
  local InSkillID = self.OwnerSkill.SkillID
  uSkillManager:TriggerStringEvent(InSkillID, "OnMoveBlock")
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_HandleOnMoveBlock = class(CSkillNodeBase, nil, SkillAction_HandleOnMoveBlock)
return CSkillAction_HandleOnMoveBlock