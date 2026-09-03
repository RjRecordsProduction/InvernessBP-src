local SkillActorBase = {
  sUIName = "SkillActorBase"
}
local ENetRole = import("ENetRole")
local EUAESkillEvent = import("EUAESkillEvent")
function SkillActorBase:LuaOnSkillActive(uSkillManagerComp, SkillID)
  print(bWriteLog and string.format("SkillActorBase:LuaOnSkillActive SkillID=%d", SkillID))
  self:ActiveSkill(uSkillManagerComp, SkillID)
  if Game:IsValid(uSkillManagerComp) then
    local uOwnerPawn = uSkillManagerComp:GetOwner()
    if Game:IsValid(uOwnerPawn) then
      if uSkillManagerComp.CreativeSkillCompFeature then
        local Skill = uSkillManagerComp:GetSkill(SkillID)
        if Game:Isvalid(Skill) then
          uSkillManagerComp.CreativeSkillCompFeature:OnCreativeSkillEvent(uOwnerPawn, Skill, "ActiveSkill")
        end
      end
      if Client then
        EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SKILL_CLIENT_ADDSKILL, SkillID, uOwnerPawn)
      end
    end
  end
end
function SkillActorBase:LuaOnSkillClose(uSkillManagerComp, SkillID)
  print(bWriteLog and string.format("SkillActorBase:LuaOnSkillClose SkillID=%d", SkillID))
  self:CloseSkill(uSkillManagerComp, SkillID)
  if Game:IsValid(uSkillManagerComp) then
    local uOwnerPawn = uSkillManagerComp:GetOwner()
    if Game:IsValid(uOwnerPawn) then
      if uSkillManagerComp.CreativeSkillCompFeature then
        local Skill = uSkillManagerComp:GetSkill(SkillID)
        if Game:Isvalid(Skill) then
          uSkillManagerComp.CreativeSkillCompFeature:OnCreativeSkillEvent(uOwnerPawn, Skill, "CloseSkill")
        end
      end
      if Client then
        EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_SKILL_CLIENT_REMOVESKILL, SkillID, uOwnerPawn)
      end
    end
  end
end
function SkillActorBase:ActiveSkill(uSkillManagerComp, SkillID)
  if slua.isValid(uSkillManagerComp) then
    local OwnerRole = uSkillManagerComp:GetRealOwnerRoleSafety()
    if OwnerRole == ENetRole.ROLE_Authority then
      local uOwnerPawn = uSkillManagerComp:GetOwner()
      if slua.isValid(uOwnerPawn) then
        uOwnerPawn:AddSkillToken(SkillID)
      end
    end
  end
end
function SkillActorBase:CloseSkill(uSkillManagerComp, SkillID)
  if slua.isValid(uSkillManagerComp) then
    local OwnerRole = uSkillManagerComp:GetRealOwnerRoleSafety()
    if OwnerRole == ENetRole.ROLE_Authority then
      local uOwnerPawn = uSkillManagerComp:GetOwner()
      if slua.isValid(uOwnerPawn) then
        uOwnerPawn:ClearSkillToken(SkillID)
      end
    end
  end
end
function SkillActorBase:ShowSkillButton(uSkillManagerComp, SkillID)
  if slua.isValid(uSkillManagerComp) then
    local OwnerRole = uSkillManagerComp:GetRealOwnerRoleSafety()
    if OwnerRole == ENetRole.ROLE_AutonomousProxy then
      local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
      uSkillManagerComp:HandleLoadSkillUI(SkillID, SkillUtils.GetSkillTemplateID(SkillID))
    end
  end
end
function SkillActorBase:HideSkillButton(uSkillManagerComp, SkillID)
  if slua.isValid(uSkillManagerComp) then
    local OwnerRole = uSkillManagerComp:GetRealOwnerRoleSafety()
    if OwnerRole == ENetRole.ROLE_AutonomousProxy then
      uSkillManagerComp:RemoveSkillUIWidget(SkillID)
    end
  end
end
function SkillActorBase:GetPromtDurationDynamically(SkillID)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  local PromptDuration = -1
  if slua.isValid(uPlayerCharacter) then
    PromptDuration = Game:GetSkillBlackboardValue(uPlayerCharacter, SkillID, UEnums.EBlackBoardKeyType.Float, "PromptDuration")
  end
  return PromptDuration
end
function SkillActorBase:GetPromtConfig(SkillID)
  return nil
end
function SkillActorBase:LuaHandleSkillStart(uSkillManagerComp, SkillID)
  if slua.isValid(uSkillManagerComp) then
    local OwnerRole = uSkillManagerComp:GetRealOwnerRoleSafety()
    if OwnerRole == ENetRole.ROLE_Authority then
      local uOwnerPawn = uSkillManagerComp:GetOwner()
      if slua.isValid(uOwnerPawn) and uOwnerPawn.OnTakeDamageDynamicDelegate then
        self:AddControlEvent(uOwnerPawn, "OnTakeDamageDynamicDelegate", self.PostTakeDamageEvent, self)
      end
    end
  end
end
function SkillActorBase:LuaHandleSkillStop(uSkillManagerComp, SkillID)
  if slua.isValid(uSkillManagerComp) then
    local OwnerRole = uSkillManagerComp:GetRealOwnerRoleSafety()
    if OwnerRole == ENetRole.ROLE_Authority then
      local uOwnerPawn = uSkillManagerComp:GetOwner()
      if slua.isValid(uOwnerPawn) and uOwnerPawn.OnTakeDamageDynamicDelegate then
        self:RemoveControlEvent(uOwnerPawn, "OnTakeDamageDynamicDelegate", self.PostTakeDamageEvent, self)
      end
    end
  end
end
function SkillActorBase:PostTakeDamageEvent(FinalDamage, uDamageEvent, uHitCharacter, uAttackCharacter, uExtraInfo)
  local EDamageType = import("EDamageType")
  if uExtraInfo.DamageTypeId == EDamageType.PoisonDamage then
    return
  end
  if 0 < FinalDamage and slua.isValid(uHitCharacter) and uHitCharacter.TriggerCustomEvent then
    uHitCharacter:TriggerCustomEvent(EUAESkillEvent.Hurt, -1)
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CSkillActorBase = class(CActorBase, nil, SkillActorBase)
return CSkillActorBase