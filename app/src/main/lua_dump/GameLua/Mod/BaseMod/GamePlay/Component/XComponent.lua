local XComponent = {}
function XComponent:ctor()
  print(bWriteLog and "Lua XComponent:ctor()")
end
function XComponent:ReceiveBeginPlay()
  print(bWriteLog and "Lua XComponent:ReceiveBeginPlay()")
end
function XComponent:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and string.format("Lua XComponent:ReceiveEndPlay(%d)", EndPlayReason))
end
local Class = require("class")
local Object = require("common.delegate_container")
local CXComponent = Class(Object, nil, XComponent)
return CXComponent