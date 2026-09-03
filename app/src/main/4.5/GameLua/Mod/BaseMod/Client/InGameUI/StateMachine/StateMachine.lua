local StateMachine = {}
function StateMachine:ctor()
  self.CurrentState = nil
  self.StateInstanceConfig = {}
end
function StateMachine:OnRelease()
  StateMachine.__super.OnRelease(self)
  if self.CurrentState then
    self.CurrentState:Exit()
  end
  for _, StateInstance in pairs(self.StateInstanceConfig) do
    StateInstance:OnRelease()
  end
  self.CurrentState = nil
  self.StateInstanceConfig = {}
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, StateMachine)