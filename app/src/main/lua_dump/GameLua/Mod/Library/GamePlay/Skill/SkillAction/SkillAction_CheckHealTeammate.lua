local SkillAction_CheckHealTeammate = {
  sObjectName = "SkillAction_CheckHealTeammate",
  tMedicalItemID = {
    [601004] = {
      Percent = 0.75,
      Scale = 0.5,
      NextPhase = 1
    },
    [601005] = {
      Percent = 0.75,
      Scale = 0.75,
      NextPhase = 2
    },
    [601006] = {
      Percent = 1,
      Scale = 1,
      NextPhase = 3
    }
  }
}
local UTSkillStopReason = import("UTSkillStopReason")
local EPawnState = import("EPawnState")
function SkillAction_CheckHealTeammate:ctor()
  self.AttrModifyName = "UseHealItemTimeScale"
end
function SkillAction_CheckHealTeammate:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  local uOwnerSkill = self:GetOwnerSkill()
  local uSkillManager = self:GetOwnerSkillManager()
  if not (slua.isValid(uOwnerPawn) and slua.isValid(uOwnerSkill)) or not slua.isValid(uSkillManager) then
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn uOwnerSkill uSkillManager Error ")
    return false
  end
  local uWeapon = uOwnerPawn:GetCurrentWeapon()
  if not slua.isValid(uWeapon) or uWeapon:GetWeaponID() ~= 108035 then
    uSkillManager:StopSkill(uOwnerSkill.SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn PlayerKey:%u uWeapon invalid", uOwnerPawn.PlayerKey)
    return false
  end
  if uOwnerPawn:HasState(EPawnState.Dying) then
    return false
  end
  local uTargetTeammate = self:GetValueAsWeakObject("TeammateObject")
  if not slua.isValid(uTargetTeammate) or not Game:IsClassOf(uTargetTeammate, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792206)
    uSkillManager:StopSkill(uOwnerSkill.SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn PlayerKey:%u not uTargetTeammate invalid", uOwnerPawn.PlayerKey)
    return false
  end
  local uPlayerState = uOwnerPawn:GetPlayerStateSafety()
  if not uPlayerState:IsTeammate(uTargetTeammate.PlayerKey) then
    Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792206)
    uSkillManager:StopSkill(uOwnerSkill.SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn PlayerKey:%u not IsTeammate invalid", uOwnerPawn.PlayerKey)
    return false
  end
  local nItemID = self:GetValueAsUInt("ItemID")
  if nItemID == 0 then
    Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792216)
    uSkillManager:StopSkill(uOwnerSkill.SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn PlayerKey:%u nItemID == 0 invalid", uOwnerPawn.PlayerKey)
    return false
  end
  local HealthItemInfo = self.tMedicalItemID[nItemID]
  if HealthItemInfo == nil then
    Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792205)
    uSkillManager:StopSkill(uOwnerSkill.SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn PlayerKey:%u nItemID:%d invalid", uOwnerPawn.PlayerKey, nItemID)
    return false
  end
  local CurHealthPercent = uTargetTeammate.Health / uTargetTeammate.HealthMax
  if CurHealthPercent >= HealthItemInfo.Percent or uTargetTeammate:HasState(EPawnState.Dying) then
    Game:UIShowTips(Game:GetPlayerKey(uOwnerPawn), 792207)
    uSkillManager:StopSkill(uOwnerSkill.SkillID, UTSkillStopReason.SkillStopReason_Interrupted)
    printf(bWriteLog and "SkillAction_CheckHealTeammate uOwnerPawn PlayerKey:%u CurHealthPercent:%f invalid", uOwnerPawn.PlayerKey, CurHealthPercent)
    return false
  end
  uOwnerSkill:JumpToPhase(uSkillManager, HealthItemInfo.NextPhase)
  return true
end
function SkillAction_CheckHealTeammate:LuaResetAction()
end
function SkillAction_CheckHealTeammate:LuaUndoAction()
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CObjectBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_CheckHealTeammate = class(CObjectBase, nil, SkillAction_CheckHealTeammate)
return CSkillAction_CheckHealTeammate