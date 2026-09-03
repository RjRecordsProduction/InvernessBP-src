local SkillActionBase = {
  __PrivateFuncList = {
    LuaRealDoAction = true,
    LuaResetAction = true,
    LuaUndoAction = true,
    LuaUpdateAction = true
  }
}
function SkillActionBase:WrapCallback(Func)
  local ScopeUniqueKey = rawget(self, "__ScopeUniqueKey")
  local ScopeOwnerPtr = self.CurOwnerActorComponent
  local NewFunc = function(...)
    local OldUniqueKey = rawget(self, "__ScopeUniqueKey")
    local OldScopeOwnerPtr = self.CurOwnerActorComponent
    rawset(self, "__ScopeUniqueKey", ScopeUniqueKey)
    self:SetStaticData("CurOwnerActorComponent", slua.isValid(ScopeOwnerPtr) and ScopeOwnerPtr or nil)
    local ret = Func(...)
    rawset(self, "__ScopeUniqueKey", OldUniqueKey)
    self:SetStaticData("CurOwnerActorComponent", slua.isValid(OldScopeOwnerPtr) and OldScopeOwnerPtr or nil)
    return ret
  end
  return NewFunc
end
function SkillActionBase:GetPrivateUniqueKey()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) then
    return self.ObjectName .. "_" .. tostring(uOwnerPawn.PlayerKey)
  end
  return nil
end
function SkillActionBase:LuaUndoAction()
  self:Dispose()
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CPrivateNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.PrivateNodeBase")
local CSkillActionBase = class(CPrivateNodeBase, nil, SkillActionBase)
return CSkillActionBase