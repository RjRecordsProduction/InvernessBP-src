local SkillCondition_CheckIsInteractiveSkill = {
  sObjectName = "SkillCondition_CheckIsInteractiveSkill"
}
function SkillCondition_CheckIsInteractiveSkill:ctor(selfType)
end
function SkillCondition_CheckIsInteractiveSkill:LuaIsConditionOK()
  local uPawn = self:GetOwnerPawn()
  print(bWriteLog and "SkillCondition_CheckIsInteractiveSkill", uPawn)
  local uCurSkill = uPawn:GetCurSkill()
  if slua.isValid(uCurSkill) and uCurSkill.InteractiveSkill then
    local uPlayerController = uPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(30121)
    end
    print(bWriteLog and "SkillCondition_CheckIsInteractiveSkill InteractiveSkill==true, return false")
    return false
  end
  return true
end
function SkillCondition_CheckIsInteractiveSkill:LuaResetCondition()
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillCondition_CheckIsInteractiveSkill = class(CObjectBase, nil, SkillCondition_CheckIsInteractiveSkill)
return CSkillCondition_CheckIsInteractiveSkill