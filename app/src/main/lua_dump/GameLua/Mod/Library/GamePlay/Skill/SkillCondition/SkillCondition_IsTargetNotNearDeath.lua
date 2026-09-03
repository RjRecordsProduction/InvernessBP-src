local SkillCondition_IsTargetNotNearDeath = {
  sObjectName = "SkillCondition_IsTargetNotNearDeath"
}
function SkillCondition_IsTargetNotNearDeath:LuaIsConditionOK()
  local uTargetTeammate = self:GetValueAsWeakObject("TeammateObject")
  if not slua.isValid(uTargetTeammate) or not Game:IsClassOf(uTargetTeammate, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    printf(bWriteLog and "SkillCondition_IsTargetNotNearDeath uTargetTeammate not value PlayerKey:%u", uOwnerPawn.PlayerKey)
    return false
  end
  if uTargetTeammate:IsNearDeath() then
    return false
  end
  return true
end
local class = require("class")
local COBject = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
return class(COBject, nil, SkillCondition_IsTargetNotNearDeath)