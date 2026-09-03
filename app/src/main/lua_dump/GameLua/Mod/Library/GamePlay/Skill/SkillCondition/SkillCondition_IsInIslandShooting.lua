local SkillCondition_IsInIslandShooting = {
  sObjectName = "SkillCondition_IsInIslandShooting"
}
function SkillCondition_IsInIslandShooting:LuaIsConditionOK()
  local Character = self:GetOwnerPawn()
  local CurSkill = self:GetOwnerSkill()
  if not slua.isValid(Character) or not slua.isValid(CurSkill) then
    log(bWriteLog and "  SkillCondition_IsInIslandShooting:LuaIsConditionOK.  not slua.isValid(Character) or not slua.isValid(CurSkill)")
    return false
  end
  local uSkillManagerComp = Character:GetSkillManager()
  if not slua.isValid(uSkillManagerComp) then
    log(bWriteLog and "  SkillCondition_IsInIslandShooting:LuaIsConditionOK. no uSkillManagerComp")
    return false
  end
  if not GetSocialIslandShootingTrain then
    return true
  end
  local SocialIslandShootingTrain = GetSocialIslandShootingTrain()
  if not SocialIslandShootingTrain then
    return true
  end
  if SocialIslandShootingTrain:PlayerIsInIslandShooting(Character) then
    log(bWriteLog and "  SkillCondition_IsInIslandShooting:LuaIsConditionOK.  PlayerIsInIslandShooting")
    uSkillManagerComp:TriggerStringEvent(CurSkill.SkillID, "OnConstruction_Failed")
    return false
  end
  return true
end
local class = require("class")
local COBject = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
return class(COBject, nil, SkillCondition_IsInIslandShooting)