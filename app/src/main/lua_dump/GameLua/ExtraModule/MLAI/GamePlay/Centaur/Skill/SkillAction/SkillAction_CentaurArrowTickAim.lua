local SkillAction_CentaurArrowTickAim = {
  sObjectName = "SkillAction_CentaurArrowTickAim",
  PlayerBBKey = "",
  LocationBBKey = ""
}
function SkillAction_CentaurArrowTickAim:ctor(selfType)
  self.AimTimer = nil
end
function SkillAction_CentaurArrowTickAim:LuaRealDoAction()
  printf("SkillAction_CentaurArrowTickAim:LuaRealDoAction, LocationBBKey: %s, PlayerBBKey: %s", tostring(self.LocationBBKey), tostring(self.PlayerBBKey))
  if not self.LocationBBKey or self.LocationBBKey == "" then
    return false
  end
  if not self.PlayerBBKey or self.PlayerBBKey == "" then
    return false
  end
  local uOwnerPawn = self:GetOwnerPawn()
  local nCurSkillID = -1
  if slua.isValid(uOwnerPawn) then
    local uSkillMgr = uOwnerPawn:GetSkillManager()
    if slua.isValid(uSkillMgr) then
      nCurSkillID = uSkillMgr:GetCurSkillID()
    end
  end
  if 0 < nCurSkillID then
    self.AimTimer = self:AddGameTimer(0.1, true, function()
      if slua.isValid(uOwnerPawn) then
        local TargetPlayer = Game:GetSkillBlackboardValue(uOwnerPawn, nCurSkillID, UEnums.EBlackBoardKeyType.WeakObject, self.PlayerBBKey)
        if slua.isValid(TargetPlayer) then
          local PlayerLocation = TargetPlayer:K2_GetActorLocation()
          Game:SetSkillBlackboardValue(uOwnerPawn, nCurSkillID, UEnums.EBlackBoardKeyType.Vector, self.LocationBBKey, PlayerLocation)
          local KismetStringLibrary = import("KismetStringLibrary")
          local KismetSystemLibrary = import("KismetSystemLibrary")
          printf("SkillAction_CentaurArrowTickAim:LuaRealDoAction, Timer: Set Location: %s, Player: %s", KismetStringLibrary.Conv_VectorToString(PlayerLocation), KismetSystemLibrary.GetObjectName(TargetPlayer))
        end
      end
    end)
  else
    printf("SkillAction_CentaurArrowTickAim:LuaRealDoAction, nCurSkillID <= 0")
  end
  return true
end
function SkillAction_CentaurArrowTickAim:LuaUndoAction()
  SkillAction_CentaurArrowTickAim.__super.LuaUndoAction(self)
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_CentaurArrowTickAim = class(CSkillNodeBase, nil, SkillAction_CentaurArrowTickAim)
return CSkillAction_CentaurArrowTickAim