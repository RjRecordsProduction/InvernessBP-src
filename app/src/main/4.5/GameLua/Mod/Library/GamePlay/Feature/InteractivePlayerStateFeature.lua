local InteractivePlayerStateFeature = {
  ServerRPC = {}
}
function InteractivePlayerStateFeature:_PostConstruct()
  InteractivePlayerStateFeature.__super._PostConstruct(self)
  self.InteractiveState = 0
  self.CurrentInteractiveSkillId = 0
end
function InteractivePlayerStateFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "InteractiveState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "CurrentInteractiveSkillId",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Int
    }
  }
  return RepTable
end
function InteractivePlayerStateFeature:OnRep_InteractiveState()
  printf("InteractivePlayerStateFeature:OnRep_InteractiveState InteractiveState=%s, CurrentInteractiveSkillId=%s", self.InteractiveState, self.CurrentInteractiveSkillId)
  if self.Owner.OnRep_InteractiveState then
    self.Owner:OnRep_InteractiveState()
  end
end
function InteractivePlayerStateFeature:OnRep_CurrentInteractiveSkillId()
  printf("InteractivePlayerStateFeature:OnRep_CurrentInteractiveSkillId CurrentInteractiveSkillId=%s ", self.CurrentInteractiveSkillId)
  if self.Owner.OnRep_CurrentInteractiveSkillId then
    self.Owner:OnRep_CurrentInteractiveSkillId()
  end
end
InteractivePlayerStateFeature.ServerRPC.RPC_Server_EnterInteractiveState = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
InteractivePlayerStateFeature.ServerRPC.RPC_Server_ExitInteractiveState = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
function InteractivePlayerStateFeature:RPC_Server_EnterInteractiveState(EStateMask, SkillId)
  printf("InteractivePlayerStateFeature:RPC_Server_EnterInteractiveState EStateMask:%s, SkillId:%s", EStateMask, SkillId)
  self:EnterInteractiveStateMask(EStateMask, SkillId)
end
function InteractivePlayerStateFeature:RPC_Server_ExitInteractiveState(EStateMask)
  printf("InteractivePlayerStateFeature:RPC_Server_ExitInteractiveState EStateMask:%s", EStateMask)
  self:ExitInteractiveStateMask(EStateMask)
end
function InteractivePlayerStateFeature:EnterInteractiveStateMask(EStateMask, SkillId)
  printf("InteractivePlayerStateFeature:EnterInteractiveStateMask EStateMask=%s, SkillId=%s", EStateMask, SkillId)
  if self:HasAuthority() then
    self.InteractiveState = self.InteractiveState | EStateMask
    SkillId = SkillId or 0
    self.CurrentInteractive    self:ForceNetUpdate()
  end
end
function InteractivePlayerStateFeature:ExitInteractiveStateMask(EStateMask)
  printf("InteractivePlayerStateFeature:ExitInteractiveStateMask EStateMask=%s", EStateMask)
  if self:HasAuthority() then
    self.InteractiveState = self.InteractiveState & ~EStateMask
    self.CurrentInteractiveSkillId = 0
    self:ForceNetUpdate()
  end
end
function InteractivePlayerStateFeature:HasInteractiveStateMask(EStateMask)
  return self.InteractiveState & EStateMask ~= 0
end
function InteractivePlayerStateFeature:IsInteractiveStateIdle(ignoreMask)
  local state = self.InteractiveState
  if ignoreMask then
    state = state & ~ignoreMask
  end
  printf("InteractivePlayerStateFeature:IsInteractiveStateIdle ignoreMask=%s, state=%s", ignoreMask, state)
  return state == 0
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, InteractivePlayerStateFeature)