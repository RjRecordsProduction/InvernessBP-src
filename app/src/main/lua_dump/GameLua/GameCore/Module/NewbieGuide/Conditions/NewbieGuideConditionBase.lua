local NewbieGuideConditionBase = {}
function NewbieGuideConditionBase:ctor(selfType, Params)
end
function NewbieGuideConditionBase:CheckConditionOK(...)
  return true
end
function NewbieGuideConditionBase:Clear()
end
local class = require("class")
local CObject = require("object")
local CNewbieGuideConditionBase = class(CObject, nil, NewbieGuideConditionBase)
return CNewbieGuideConditionBase