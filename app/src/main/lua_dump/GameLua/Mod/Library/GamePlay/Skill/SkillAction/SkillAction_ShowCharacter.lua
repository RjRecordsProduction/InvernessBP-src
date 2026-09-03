local SkillAction_ShowCharacter = {
  sObjectName = "SkillAction_ShowCharacter"
}
function SkillAction_ShowCharacter:ctor(selfType)
end
local ENetRole = import("ENetRole")
function SkillAction_ShowCharacter:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) and Client then
    print(bWriteLog and "SkillAction_ShowCharacter LuaUndoAction SetActorHiddenInGame(true)")
    local EActorHiddenMask = import("EActorHiddenMask")
    uOwnerPawn:SetActorHiddenInGameMask(true, EActorHiddenMask.ActorHiddenMask7)
  end
  return true
end
function SkillAction_ShowCharacter:LuaUndoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) and Client then
    print(bWriteLog and "SkillAction_ShowCharacter LuaUndoAction SetActorHiddenInGame(false)")
    local EActorHiddenMask = import("EActorHiddenMask")
    uOwnerPawn:SetActorHiddenInGameMask(false, EActorHiddenMask.ActorHiddenMask7)
  end
end
function SkillAction_ShowCharacter:LuaResetAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) and Client then
    local ReverseOnReset = self.ReverseOnReset
    if ReverseOnReset then
      print(bWriteLog and "SkillAction_ShowCharacter LuaResetAction SetActorHiddenInGame(false)")
      local EActorHiddenMask = import("EActorHiddenMask")
      uOwnerPawn:SetActorHiddenInGameMask(false, EActorHiddenMask.ActorHiddenMask7)
    end
  end
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CObjectBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_ShowCharacter = class(CObjectBase, nil, SkillAction_ShowCharacter)
return CSkillAction_ShowCharacter