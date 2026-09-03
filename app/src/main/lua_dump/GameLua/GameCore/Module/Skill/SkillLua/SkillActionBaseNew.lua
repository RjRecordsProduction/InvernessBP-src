local SkillActionBase = {}
function SkillActionBase:WrapCallback(Func)
  local ScopeUniqueKey = self:GetPrivateUniqueKey()
  local ScopeOwnerPtr = self.CurOwnerActorComponent
  local NewFunc = function(...)
    local OldUniqueKey = self:GetPrivateUniqueKey()
    local OldScopeOwnerPtr = self.CurOwnerActorComponent
    self:SetPrivateUniqueKey(ScopeUniqueKey)
    self:SetStaticData("CurOwnerActorComponent", slua.isValid(ScopeOwnerPtr) and ScopeOwnerPtr or nil)
    local ret = Func(...)
    self:SetPrivateUniqueKey(OldUniqueKey)
    self:SetStaticData("CurOwnerActorComponent", slua.isValid(OldScopeOwnerPtr) and OldScopeOwnerPtr or nil)
    return ret
  end
  return NewFunc
end
function SkillActionBase:LuaUndoAction()
  self:Dispose()
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CPrivateNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.PrivateNodeBaseNew")
local CSkillActionBase = class(CPrivateNodeBase, nil, SkillActionBase)
return CSkillActionBase