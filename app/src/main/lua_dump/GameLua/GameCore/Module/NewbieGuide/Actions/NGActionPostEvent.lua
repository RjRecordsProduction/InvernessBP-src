local NGActionPostEvent = {}
function NGActionPostEvent:ctor(selfType, Params)
  self.StartEventType = Params.StartEventType
  self.StartEventID = Params.StartEventID
  self.StartEventParam1 = Params.StartEventParam1
  self.StartEventParam2 = Params.StartEventParam2
  self.EndEventType = Params.EndEventType
  self.EndEventID = Params.EndEventID
  self.EndEventParam1 = Params.EndEventParam1
  self.EndEventParam2 = Params.EndEventParam2
end
function NGActionPostEvent:RunAction(InGuideID)
  NGActionPostEvent.__super.RunAction(self, InGuideID)
  print(bWriteLog and "Debug NewbieGuide: NGActionPostEvent RunAction", _G[self.StartEventType], _G[self.StartEventID])
  EventSystem:postEvent(_G[self.StartEventType], _G[self.StartEventID], self.StartEventParam1, self.StartEventParam2)
  return true
end
function NGActionPostEvent:EndAction()
  NGActionPostEvent.__super.EndAction(self)
  print(bWriteLog and "Debug NewbieGuide: NGActionPostEvent EndAction", _G[self.EndEventType], _G[self.EndEventID])
  EventSystem:postEvent(_G[self.EndEventType], _G[self.EndEventID], self.EndEventParam1, self.EndEventParam2)
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Actions.NewbieGuideActionBase")
local CNGActionPostEvent = class(CObject, nil, NGActionPostEvent)
return CNGActionPostEvent