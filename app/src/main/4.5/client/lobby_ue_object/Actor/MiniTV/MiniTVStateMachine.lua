local MiniTVStateMachine = {}
function MiniTVStateMachine:new()
  local o = {
    currentState = nil,
    states = {},
    actor = nil
  }
  setmetatable(o, self)
  self.__index = self
  return o
end
function MiniTVStateMachine:Init(actor)
  self.end
function MiniTVStateMachine:RegisterState(stateName, state)
  self.states[stateName] = state
  printf("MiniTVStateMachine:RegisterState - Register state: %s", stateName)
end
function MiniTVStateMachine:ChangeState(stateName, args)
  local newState = self.states[stateName]
  if not newState then
    printf("MiniTVStateMachine:ChangeState - State not found: %s", stateName)
    return false
  end
  if self.currentState == newState then
    return false
  end
  local oldState = self.currentState
  if self.currentState then
    self.currentState:OnExit(self.actor)
  end
  self.currentState = newState
  self.currentState:OnEnter(self.actor, args)
  if bWriteLog then
    printf("MiniTVStateMachine:ChangeState - State transition: %s -> %s", oldState and oldState:GetStateName() or "None", newState:GetStateName())
  end
  return true
end
function MiniTVStateMachine:Update(deltaTime)
  if self.currentState then
    self.currentState:OnUpdate(self.actor, deltaTime)
  end
end
function MiniTVStateMachine:GetCurrentStateName()
  if self.currentState then
    return self.currentState:GetStateName()
  end
  return "None"
end
function MiniTVStateMachine:Destroy()
  self.currentState = nil
  self.states = {}
  self.actor = nil
end
local MiniTVStateBase = {}
function MiniTVStateBase:new(StateName)
  local o = {
    StateName = StateName or "BaseState"
  }
  setmetatable(o, self)
  self.__index = self
  return o
end
function MiniTVStateBase:OnEnter(actor, args)
end
function MiniTVStateBase:OnUpdate(actor, deltaTime)
end
function MiniTVStateBase:OnExit(actor)
end
function MiniTVStateBase:GetStateName()
  return self.StateName
end
return {StateBase = MiniTVStateBase, StateMachine = MiniTVStateMachine}