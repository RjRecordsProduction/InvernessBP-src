local StateBase = {}
function StateBase:ctor()
  self.StateName = ""
end
function StateBase:Enter(bReconnect)
  print(bWriteLog and "StateMachine StateBase--:Enter:" .. self.StateName)
end
function StateBase:Exit()
  self:Dispose()
  print(bWriteLog and "StateMachine StateBase--:Exit:" .. self.StateName)
end
function StateBase:OnRelease()
  self:Dispose()
  print(bWriteLog and "StateMachine StateBase--:OnRelease:" .. self.StateName)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, StateBase)