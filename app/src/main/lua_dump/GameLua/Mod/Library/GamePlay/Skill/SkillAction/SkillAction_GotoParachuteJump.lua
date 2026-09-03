local SkillAction_GotoParachuteJump = {
  sObjectName = "SkillAction_GotoParachuteJump"
}
function SkillAction_GotoParachuteJump:ctor(selfType)
end
local ENetRole = import("ENetRole")
function SkillAction_GotoParachuteJump:LuaRealDoAction()
  print(bWriteLog and string.format("%s:LuaRealDoAction", self.sObjectName))
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) and uOwnerPawn.Role == ENetRole.ROLE_Authority then
    local uPlayerController = uOwnerPawn:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      local EStateType = import("EStateType")
      uPlayerController:ReInitParachuteItem()
      uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
      if self.CanOpenParachuteHeight then
        uPlayerController.CanOpenParachuteHeight = self.CanOpenParachuteHeight
      end
      if self.ForceOpenParachuteHeight then
        uPlayerController.ForceOpenParachuteHeight = self.ForceOpenParachuteHeight
      end
      if self.CloseParachuteHeight then
        uPlayerController.CloseParachuteHeight = self.CloseParachuteHeight
      end
      local LeaveAreaFlyComponentPath = self.LeaveAreaFlyComponentPath
      if LeaveAreaFlyComponentPath and LeaveAreaFlyComponentPath ~= "" then
        local LeaveAreaFlyComponent_C = import(LeaveAreaFlyComponentPath)
        local uLeaveAreaFlyComponent = uOwnerPawn:GetComponentByClass(LeaveAreaFlyComponent_C)
        if slua.isValid(uLeaveAreaFlyComponent) then
          uLeaveAreaFlyComponent:SetChangeParachuteParam(true)
        end
      end
    end
  end
  return false
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
local CSkillAction_GotoParachuteJump = class(CObjectBase, nil, SkillAction_GotoParachuteJump)
return CSkillAction_GotoParachuteJump