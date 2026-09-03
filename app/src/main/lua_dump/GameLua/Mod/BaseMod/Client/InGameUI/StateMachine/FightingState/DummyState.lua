local DummyState = {}
function DummyState:ctor()
  self.StateName = "DummyState"
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateBase")
return class(CDelegateContainer, nil, DummyState)