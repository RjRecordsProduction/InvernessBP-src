local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
local SearchCondition_CheckCarryBox = {
  sObjectName = "SkillCondition_CheckInEventArea"
}
function SearchCondition_CheckCarryBox:ctor(selfType)
  print(bWriteLog and "SearchCondition_CheckCarryBox:ctor", selfType)
end
function SearchCondition_CheckCarryBox:LuaIsAllowSearch(InOwner)
  local uPlayerCharacter = InOwner
  if not slua.isValid(uPlayerCharacter) then
    return false
  end
  return uPlayerCharacter.CarryDeadBoxFeature and slua.isValid(uPlayerCharacter.CarryDeadBoxFeature.AttachedDeadBox)
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSearchCondition_CheckCarryBox = class(CObjectBase, nil, SearchCondition_CheckCarryBox)
return CSearchCondition_CheckCarryBox