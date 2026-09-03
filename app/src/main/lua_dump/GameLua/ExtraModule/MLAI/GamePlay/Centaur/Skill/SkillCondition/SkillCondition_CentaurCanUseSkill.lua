local SkillCondition_CentaurCanUseSkill = {
  sObjectName = "SkillCondition_CentaurCanUseSkill"
}
function SkillCondition_CentaurCanUseSkill:ctor(selfType)
end
function SkillCondition_CentaurCanUseSkill:LuaIsConditionOK()
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    return false
  end
  if uOwnerPawn.IsBoss and uOwnerPawn:IsBoss() then
    return true
  elseif uOwnerPawn.IsMercenaryAI and uOwnerPawn:IsMercenaryAI() then
    return true
  end
  print(bWriteLog and "SkillCondition_CentaurCanUseSkill:LuaIsConditionOK false", uOwnerPawn)
  return false
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillCondition_CentaurCanUseSkill = class(CObjectBase, nil, SkillCondition_CentaurCanUseSkill)
return CSkillCondition_CentaurCanUseSkill