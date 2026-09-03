local NewbieGuideActionBase = {}
function NewbieGuideActionBase:ctor(selfType, Params)
  self.GuideID = 0
end
function NewbieGuideActionBase:RunAction(InGuideID, ...)
  self.GuideID = InGuideID
  return true
end
function NewbieGuideActionBase:EndAction()
end
function NewbieGuideActionBase:Clear()
end
local class = require("class")
local CObject = require("object")
local CNewbieGuideActionBase = class(CObject, nil, NewbieGuideActionBase)
return CNewbieGuideActionBase