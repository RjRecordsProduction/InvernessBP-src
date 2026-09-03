local SkillAction_StartHealTeammate = {
  tMedicalItemID = {
    [601004] = {
      Key = "Skill_Bandage",
      Type = 0,
      Value = 10,
      LimitValue = 75
    },
    [601005] = {
      Key = "Skill_FirstAidKit",
      Type = 0,
      Value = 75,
      LimitValue = 75
    },
    [601006] = {
      Key = "Skill_MedKit",
      Type = 0,
      Value = 100,
      LimitValue = 0
    }
  },
  SkillCancelDelayTime = 0
}
local FHealthPredictShowData = import("HealthPredictShowData")
local UTSkillStopReason = import("UTSkillStopReason")
local UGameplayStatics = import("GameplayStatics")
function SkillAction_StartHealTeammate:ctor()
  self.StartTime = 0
  self.PhaseDuration = 2.5
end
function SkillAction_StartHealTeammate:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    return false
  end
  local uTargetTeammate = self:GetValueAsWeakObject("TeammateObject")
  if not slua.isValid(uTargetTeammate) or not Game:IsClassOf(uTargetTeammate, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    printf(bWriteLog and "SkillAction_StartHealTeammate uTargetTeammate not value PlayerKey:%u", uOwnerPawn.PlayerKey)
    return false
  end
  if uTargetTeammate:IsLocallyControlled() then
    self:AddOrRemoveTeammateRecoverPrompt(uTargetTeammate, true, false)
    local uSkillManager = self:GetOwnerSkillManager()
    if slua.isValid(uSkillManager) then
      self:RemoveControlEvent(uSkillManager, "SkillStopEvent")
      self:AddControlEvent(uSkillManager, "SkillStopEvent", self.OnSkillCancelFunc, self)
    end
    self.StartTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
    local uSkillManagerComp = self:GetOwnerSkillManager()
    if not slua.isValid(uSkillManagerComp) then
      return
    end
    local uOwnerSkill = self:GetOwnerSkill()
    if not slua.isValid(uOwnerSkill) then
      return
    end
    local uCurPhase = uOwnerSkill:GetCurSkillPhase(uSkillManagerComp)
    if slua.isValid(uCurPhase) then
      self.PhaseDuration = uCurPhase.BaseData.PhaseDuration
    end
  end
  local TeammateName = ""
  if slua.isValid(uTargetTeammate) then
    TeammateName = uTargetTeammate:GetPlayerNameSafety()
  end
  if uOwnerPawn:IsLocallyControlled() then
    local PlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(PlayerController) and PlayerController.SendStringMsg then
      local MsgContent = LocUtil.LocalizeResFormat(79809, TeammateName)
      PlayerController:SendStringMsg(MsgContent, 0, 0, "", 0, 0, true)
    end
  end
  if Client then
    self:HideOrShowWeapon(true)
  end
  return true
end
function SkillAction_StartHealTeammate:HideOrShowWeapon(bHide)
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local uWeapon = uOwnerPawn:GetCurrentWeapon()
  if slua.isValid(uWeapon) then
    uWeapon:SetActorHiddenInGameMask(bHide, 6)
  end
end
function SkillAction_StartHealTeammate:OnSkillCancelFunc(nSkillID, EStopReason)
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local uOwnerSkill = self:GetOwnerSkill()
  if not slua.isValid(uOwnerSkill) then
    return
  end
  local CurTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  local ElapseTime = CurTime - self.StartTime
  if self.PhaseDuration - ElapseTime > self.SkillCancelDelayTime and EStopReason == UTSkillStopReason.SkillStopReason_Finished then
    EStopReason = UTSkillStopReason.SkillStopReason_Interrupted
  end
  if nSkillID == uOwnerSkill.SkillID and EStopReason ~= UTSkillStopReason.SkillStopReason_Finished then
    local uTargetTeammate = self:GetValueAsWeakObject("TeammateObject")
    if not slua.isValid(uTargetTeammate) or not Game:IsClassOf(uTargetTeammate, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
      printf(bWriteLog and "SkillAction_StartHealTeammate uTargetTeammate not value PlayerKey:%u", uOwnerPawn.PlayerKey)
      return
    end
    if uTargetTeammate:IsLocallyControlled() then
      self:AddOrRemoveTeammateRecoverPrompt(uTargetTeammate, false, true)
      local uSkillManager = self:GetOwnerSkillManager()
      if slua.isValid(uSkillManager) then
        self:RemoveControlEvent(uSkillManager, "SkillStopEvent")
      end
    end
  end
end
function SkillAction_StartHealTeammate:AddOrRemoveTeammateRecoverPrompt(uTargetTeammate, bAdd, bForceRemove)
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local nItemID = self:GetValueAsUInt("ItemID")
  if nItemID == 0 then
    printf(bWriteLog and "SkillAction_StartHealTeammate AddOrRemoveTeammateRecoverPrompt Error nItemID == 0 PlayerKey:%u", uTargetTeammate.PlayerKey)
    return
  end
  local PromptInfo = self.tMedicalItemID[nItemID]
  if bAdd then
    local HealthPredictData = FHealthPredictShowData()
    HealthPredictData.ShowDataKey = PromptInfo.Key
    HealthPredictData.ShowType = PromptInfo.Type
    HealthPredictData.Value = PromptInfo.Value
    HealthPredictData.LimitValue = PromptInfo.LimitValue
    HealthPredictData.CauserPlayerKey = uOwnerPawn.PlayerKey
    local MaxPredict = math.max(PromptInfo.LimitValue, PromptInfo.Value)
    uTargetTeammate:SetValueLimitForHealthPredict(MaxPredict)
    uTargetTeammate:AddHealthPredictShowData(HealthPredictData)
  elseif nItemID ~= 601004 or bForceRemove then
    uTargetTeammate:RemoveHealthPredictShowDataWithCauser(PromptInfo.Key, uOwnerPawn.PlayerKey)
  end
end
function SkillAction_StartHealTeammate:LuaResetAction()
  if Client then
    self:HideOrShowWeapon(false)
  end
end
function SkillAction_StartHealTeammate:LuaUndoAction()
  local uTargetTeammate = self:GetValueAsWeakObject("TeammateObject")
  if not slua.isValid(uTargetTeammate) or not Game:IsClassOf(uTargetTeammate, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    return
  end
  if uTargetTeammate:IsLocallyControlled() then
    self:AddOrRemoveTeammateRecoverPrompt(uTargetTeammate, false, false)
  end
  if Client then
    self:HideOrShowWeapon(false)
  end
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CObjectBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_StartHealTeammate = class(CObjectBase, nil, SkillAction_StartHealTeammate)
return CSkillAction_StartHealTeammate