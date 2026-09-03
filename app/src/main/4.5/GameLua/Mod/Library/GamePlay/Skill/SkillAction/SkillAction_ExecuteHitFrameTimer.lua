local SkillAction_ExecuteHitFrameTimer = {
  sObjectName = "SkillAction_ExecuteHitFrameTimer",
  ConfigTableName = "ExecuteSkinTable",
  PlanIDBlackboardKey = "ExecutePlanID",
  TargetBlackboardKey = "ExecuteTarget",
  HitFrameColumnName = "HitFrame_f",
  TotalDurationColumnName = "TotalDuration_f",
  DefaultHitFrameTime = 1.2,
  DefaultTotalDuration = 2.5,
  DamageOnExecute = 999.0
}
function SkillAction_ExecuteHitFrameTimer:ctor(selfType)
  self.bHitFrameReached = false
  self.HitFrameTimerHandle = nil
  self.TotalDurationTimerHandle = nil
end
function SkillAction_ExecuteHitFrameTimer:LuaRealDoAction()
  if Client then
    return true
  end
  local bIsCreativeWoW = (not CGameMode or not CGameMode.bIsCreativeWoW) and CGameState and CGameState.bIsCreativeWoW
  if bIsCreativeWoW then
    print(bWriteLog and "SkillAction_ExecuteHitFrameTimer:LuaRealDoAction aborted by CreativeWoW mode")
    return false
  end
  print(bWriteLog and "SkillAction_ExecuteHitFrameTimer:LuaRealDoAction")
  self.bHitFrameReached = false
  local uOwnerPawn = self:GetOwnerPawn()
  local uCurSkill = self:GetOwnerSkill()
  local uSkillManager = self:GetOwnerSkillManager()
  if not (slua.isValid(uOwnerPawn) and slua.isValid(uCurSkill)) or not slua.isValid(uSkillManager) then
    print(bWriteLog and "SkillAction_ExecuteHitFrameTimer:LuaRealDoAction invalid Owner/Skill/SkillMgr")
    return false
  end
  local PlanID = uSkillManager:GetValueAsInt(uCurSkill.SkillID, self.PlanIDBlackboardKey)
  local HitFrameTime, TotalDuration = self:QueryPlanTiming(PlanID)
  print(bWriteLog and string.format("SkillAction_ExecuteHitFrameTimer:LuaRealDoAction PlanID=%d HitFrame=%.3f Total=%.3f", PlanID, HitFrameTime, TotalDuration))
  self.HitFrameTimerHandle = self:AddGameTimer(HitFrameTime, false, function()
    self.HitFrameTimerHandle = nil
    self.bHitFrameReached = true
    print(bWriteLog and string.format("SkillAction_ExecuteHitFrameTimer:HitFrame REACHED, SkillID=%d locked", uCurSkill.SkillID))
  end)
  self.TotalDurationTimerHandle = self:AddGameTimer(TotalDuration, false, function()
    self.TotalDurationTimerHandle = nil
    local Pawn = self:GetOwnerPawn()
    local Skill = self:GetOwnerSkill()
    if slua.isValid(Pawn) and slua.isValid(Skill) then
      print(bWriteLog and string.format("SkillAction_ExecuteHitFrameTimer:TotalDuration reached, StopSkill(%d)", Skill.SkillID))
      Pawn:StopSkill(Skill.SkillID)
    end
  end)
  return true
end
function SkillAction_ExecuteHitFrameTimer:LuaUndoAction()
  if Client then
    SkillAction_ExecuteHitFrameTimer.__super.LuaUndoAction(self)
    return
  end
  print(bWriteLog and string.format("SkillAction_ExecuteHitFrameTimer:LuaUndoAction bHitFrameReached=%s", tostring(self.bHitFrameReached)))
  self:_ClearTimers()
  local uOwnerPawn = self:GetOwnerPawn()
  local uCurSkill = self:GetOwnerSkill()
  local uSkillManager = self:GetOwnerSkillManager()
  local uTarget
  if slua.isValid(uSkillManager) and slua.isValid(uCurSkill) then
    uTarget = uSkillManager:GetValueAsWeakObject(uCurSkill.SkillID, self.TargetBlackboardKey)
  end
  if self.bHitFrameReached and slua.isValid(uTarget) and not uTarget.bDead then
    self:_DoExecuteKill(uOwnerPawn, uTarget)
  end
  self.bHitFrameReached = false
  SkillAction_ExecuteHitFrameTimer.__super.LuaUndoAction(self)
end
function SkillAction_ExecuteHitFrameTimer:QueryPlanTiming(PlanID)
  local UAETableManager = import("UAETableManager")
  local Table = UAETableManager.GetDataTableStatic(self.ConfigTableName)
  if not slua.isValid(Table) then
    print(bWriteLog and string.format("SkillAction_ExecuteHitFrameTimer: Table %s not found, use defaults", self.ConfigTableName))
    return self.DefaultHitFrameTime, self.DefaultTotalDuration
  end
  local STExtraBPLib = import("STExtraBlueprintFunctionLibrary")
  local RowName = tostring(PlanID)
  local HitFrameTime = STExtraBPLib.GetTableData_Float(Table, RowName, self.HitFrameColumnName)
  local TotalDuration = STExtraBPLib.GetTableData_Float(Table, RowName, self.TotalDurationColumnName)
  if HitFrameTime <= 0.01 then
    HitFrameTime = self.DefaultHitFrameTime
  end
  if TotalDuration <= 0.01 then
    TotalDuration = self.DefaultTotalDuration
  end
  return HitFrameTime, TotalDuration
end
function SkillAction_ExecuteHitFrameTimer:_ClearTimers()
  if self.HitFrameTimerHandle then
    self:RemoveGameTimer(self.HitFrameTimerHandle)
    self.HitFrameTimerHandle = nil
  end
  if self.TotalDurationTimerHandle then
    self:RemoveGameTimer(self.TotalDurationTimerHandle)
    self.TotalDurationTimerHandle = nil
  end
end
function SkillAction_ExecuteHitFrameTimer:_DoExecuteKill(uOwnerPawn, uTarget)
  if not slua.isValid(uOwnerPawn) or not slua.isValid(uTarget) then
    return
  end
  local uController
  if uOwnerPawn.GetController then
    uController = uOwnerPawn:GetController()
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local EAvatarDamagePosition = import("EAvatarDamagePosition")
  local EMeleeDamageSubType = import("EMeleeDamageSubType")
  local ItemDefineID = FItemDefineID(6, 0)
  STExtraBlueprintFunctionLibrary.ApplyMeleeDamage(uTarget, uController, uOwnerPawn, self.DamageOnExecute, false, EAvatarDamagePosition.BigBody, EMeleeDamageSubType.Fist, 0.0, ItemDefineID, nil)
  print(bWriteLog and string.format("SkillAction_ExecuteHitFrameTimer:DoExecuteKill Target=%s killed by %s", tostring(uTarget), tostring(uOwnerPawn)))
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
return class(CSkillNodeBase, nil, SkillAction_ExecuteHitFrameTimer)