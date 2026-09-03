local SkillAction_BroadcastGrenadeThrowState = {
  sObjectName = "SkillAction_BroadcastGrenadeThrowState"
}
local EThrowState = {
  Ready = 0,
  Prepare = 1,
  Aim = 2,
  Throw = 3,
  Cancel = 4
}
local ENetRole = import("ENetRole")
function SkillAction_BroadcastGrenadeThrowState:LuaRealDoAction()
  local uSelfPawn = self:GetOwnerPawn()
  if not slua.isValid(uSelfPawn) or uSelfPawn.Role == ENetRole.ROLE_Authority then
    return false
  end
  local uCurWeapon = uSelfPawn.GetCurrentWeapon and uSelfPawn:GetCurrentWeapon() or nil
  if not slua.isValid(uCurWeapon) or not uCurWeapon.OnWeaponThrowStateChanged then
    return false
  end
  local NewGrenadeThrowStateName = self:GetValueAsName("State")
  if not NewGrenadeThrowStateName then
    return false
  end
  local NewGrenadeThrowState = EThrowState[NewGrenadeThrowStateName]
  if not NewGrenadeThrowState then
    return false
  end
  uCurWeapon:BroadcastWeaponThrowStateChanged(NewGrenadeThrowState)
  return true
end
function SkillAction_BroadcastGrenadeThrowState:LuaUndoAction()
end
function SkillAction_BroadcastGrenadeThrowState:LuaResetAction()
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_BroadcastGrenadeThrowState = class(CSkillNodeBase, nil, SkillAction_BroadcastGrenadeThrowState)
return CSkillAction_BroadcastGrenadeThrowState