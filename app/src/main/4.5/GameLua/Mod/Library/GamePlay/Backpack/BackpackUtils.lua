local BackpackUtils = {}
function BackpackUtils:ctor()
  print(bWriteLog and "BackpackUtils:ctor")
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBackpackUtils = class(CDelegateContainer, nil, BackpackUtils)
return CBackpackUtils