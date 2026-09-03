local FeatureUtil = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureUtil")
local StateMachineFeature = {}
local NONE_STATE = {Id = -1, Name = "None"}
local ON_STATE_CHANGED_EVENT = "OnStateChanged"
function StateMachineFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "StateId",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function StateMachineFeature:_PostConstruct()
  self.StateId = NONE_STATE.Id
  self.OldStateId = NONE_STATE.Id
  self.LastStateId = NONE_STATE.Id
  self._StateMachineDelegate = FeatureUtil.LuaDelegate()
end
function StateMachineFeature:ReceiveEndPlay(EndPlayReason)
  if EndPlayReason == import("EEndPlayReason").Destroyed then
    self._StateConfigs = nil
    if self._StateMachineDelegate then
      self._StateMachineDelegate:Dispose()
    end
  end
  StateMachineFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function StateMachineFeature:Init(StateConfigs, InitStateId)
  assert(type(StateConfigs) == "table", "StateConfigs(table) required")
  assert(type(InitStateId) == "number", "InitStateId(int) required")
  for _, StateConfig in ipairs(StateConfigs) do
    self:_RegisterState(StateConfig)
  end
  self:SetState(InitStateId)
  self.StateId = InitStateId
  self.  return self
end
function StateMachineFeature:_RegisterState(StateConfig)
  if not self._StateConfigs then
    self._StateConfigs = {}
  end
  local StateId = StateConfig.Id
  assert(type(StateId) == "number" and type(StateConfig.Name) == "string", "State Id(int) and Name(string) required")
  if self._StateConfigs[StateId] == nil then
    self._StateConfigs[StateId] = StateConfig
  else
    FeatureUtil.printf("State Id %s is exist", StateId)
  end
  if not self._StateNameToID then
    self._StateNameToID = {}
  end
  if self._StateNameToID[StateConfig.Name] == nil then
    self._StateNameToID[StateConfig.Name] = StateId
  else
    FeatureUtil.printf("State Name %s is exist", StateConfig.Name)
  end
end
function StateMachineFeature:GetState()
  return self.StateId
end
function StateMachineFeature:GetStateName()
  return self:GetStateNameById(self.StateId)
end
function StateMachineFeature:GetStateNameById(StateId)
  local StateConfig = self:_GetStateMachineConfig(StateId)
  if StateConfig then
    return StateConfig.Name
  end
end
function StateMachineFeature:SetState(StateId)
  if not self:HasAuthority() and not self.IsEnableClientSetState then
    return
  end
  local StateConfig = self:_GetStateMachineConfig(StateId)
  if not StateConfig then
    return
  end
  if self.StateId == StateId then
    FeatureUtil.printf("StateMachineFeature:SetState Cannot set same state: %s", StateMachineFeature.ToString(StateConfig))
    return
  end
  local LastStateConfig = self:_GetStateMachineConfig(self.StateId)
  FeatureUtil.printf("%s StateMachineFeature:SetState %s -> %s", self.Owner.Object, StateMachineFeature.ToString(LastStateConfig), StateMachineFeature.ToString(StateConfig))
  self.OldStateId = self.StateId
  self.StateId = StateConfig.Id
  self:ForceNetUpdate()
  self:OnChangeState(self.OldStateId, self.StateId)
end
function StateMachineFeature:OnRep_StateId(OldValue)
  if self:_IsNoneState(self.StateId) then
    return
  end
  local StateMachineStateId = self.StateId
  local StateConfig = self:_GetStateMachineConfig(StateMachineStateId)
  if self.LastStateId == self.StateId then
    FeatureUtil.printf("%s StateMachineFeature:OnRep_StateId: %s, Error! Same State", self.Owner.Object, StateMachineFeature.ToString(StateConfig))
    return
  end
  self.OldStateId = self.LastStateId
  self.LastStateId = self.StateId
  FeatureUtil.printf("%s StateMachineFeature:OnRep_StateId: %s", self.Owner.Object, StateMachineFeature.ToString(StateConfig))
  self:OnChangeState(self.OldStateId, self.StateId)
end
function StateMachineFeature:OnChangeState(OldStateId, NewStateId)
  self._StateMachineDelegate:Broadcast(ON_STATE_CHANGED_EVENT, NewStateId, OldStateId)
  local StateName = self:GetStateNameById(OldStateId)
  if StateName then
    local CallFunc = self.Owner["OnSMStateEnd_" .. StateName]
    if CallFunc then
      CallFunc(self.Owner, NewStateId)
    end
  end
  StateName = self:GetStateNameById(NewStateId)
  if StateName then
    local CallFunc = self.Owner["OnSMStateBegin_" .. StateName]
    if CallFunc then
      CallFunc(self.Owner, OldStateId)
    end
  end
end
function StateMachineFeature:SetStateByStateName(sStateName)
  if not self:HasAuthority() and not self.IsEnableClientSetState then
    return
  end
  if self._StateNameToID and sStateName and self._StateNameToID[sStateName] then
    self:SetState(self._StateNameToID[sStateName])
  else
    FeatureUtil.printf("StateMachineFeature:SetStateByStateName Cannot set state: %s", tostring(sStateName))
  end
end
function StateMachineFeature:OnStateChanged(Callback, Caller)
  self._StateMachineDelegate:Add(ON_STATE_CHANGED_EVENT, Callback, Caller)
  return self
end
function StateMachineFeature:OffStateChanged(Caller)
  self._StateMachineDelegate:RemoveByCaller(ON_STATE_CHANGED_EVENT, Caller)
  return self
end
function StateMachineFeature:_GetStateMachineConfig(StateId)
  if self:_IsNoneState(StateId) then
    return NONE_STATE
  end
  if self._StateConfigs then
    return self._StateConfigs[StateId]
  end
end
function StateMachineFeature:_IsNoneState(StateId)
  return StateId == NONE_STATE.Id
end
function StateMachineFeature.ToString(StateConfig)
  if StateConfig == nil then
    return "(nil)"
  end
  return string.format("(%s: %s)", StateConfig.Id, StateConfig.Name)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, StateMachineFeature)