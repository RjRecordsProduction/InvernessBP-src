local SkillCondition_CheckNotOnMovePlatform = {
  sObjectName = "SkillCondition_CheckNotOnMovePlatform"
}
function SkillCondition_CheckNotOnMovePlatform:ctor(selfType)
  print(bWriteLog and "SkillCondition_CheckNotOnMovePlatform:ctor", selfType)
end
function SkillCondition_CheckNotOnMovePlatform:LuaIsConditionOK()
  print(bWriteLog and string.format("%s:LuaIsConditionOK", self.sObjectName))
  local uPawn = self:GetOwnerPawn()
  if Game:IsValid(uPawn) and uPawn.CheckOnMoveablePlatform and uPawn:CheckOnMoveablePlatform() then
    local sFailShowTipID = self.ConditionParams:Get("FailShowTipID") or 0
    if sFailShowTipID then
      local nFailShowTipID = tonumber(sFailShowTipID) or 0
      if nFailShowTipID and 0 < nFailShowTipID then
        print(bWriteLog and "SkillCondition_CheckNotOnMovePlatform:LuaIsConditionOK:" .. tostring(nFailShowTipID))
        Game:UIShowTips(uPawn.PlayerKey, nFailShowTipID)
      end
    end
    return false
  end
  return true
end
function SkillCondition_CheckNotOnMovePlatform:LuaResetCondition()
  print(bWriteLog and string.format("%s:LuaResetCondition", self.sObjectName))
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillCondition_CheckNotOnMovePlatform = class(CObjectBase, nil, SkillCondition_CheckNotOnMovePlatform)
return CSkillCondition_CheckNotOnMovePlatform